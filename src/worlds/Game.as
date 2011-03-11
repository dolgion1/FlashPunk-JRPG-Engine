package worlds 
{
	import entities.*;
	import entities.map.*;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import net.flashpunk.graphics.Text;
	import utility.*;
	import net.flashpunk.*;
	import net.flashpunk.utils.*;
	import flash.utils.*;
	
	/**
	 * ...
	 * @author dolgion
	 */
	public class Game extends World
	{
		public static const NORMAL_MODE:int = 0;
		public static const WORLD_MAP_MODE:int = 1;
		public static const DIALOG_MODE:int = 2;
		public static const STATUS_SCREEN_MODE:int = 3;
		public static const INVENTORY_SCREEN_MODE:int = 4;
		public static const SPELLS_SCREEN_MODE:int = 5;
		
		// Entities
		public var player:Player;
		public var npcs:Array = new Array();
		public var enemies:Array = new Array();
		public static var items:Array = new Array();
		public var chests:Array = new Array();
		public static var spells:Dictionary = new Dictionary();
		public var tiles:Tiles;
		public var trees:Trees;
		public var houses:Array;
		public var worldMap:WorldMap;
		public var worldMapMarker:WorldMapMarker;
		public var mapDisplay:DisplayText;
		public var daytimeDisplay:DisplayText;
		public var timeDisplay:DisplayText;
		public var npcDialogBox:NPCDialogBox;
		public var playerDialogBox:PlayerDialogBox;
		public var gridOverlays:Array = new Array();
		public var statusScreen:StatusScreen;
		public var inventoryScreen:InventoryScreen;
		public var spellsScreen:SpellsScreen;
		
		// Helper Datastructures
		public var maps:Array = new Array();
		public var currentMap:Map;
		public var enteredHouse:House;
		
		// Helper state variables
		public static var currentMapIndex:int;
		public static var gameMode:int = NORMAL_MODE;
		public var dialogModeInitiated:Boolean = false;
		public static var dialogEndedThisFrame:Boolean = false;
		
		// Utilities
		public var time:Time = new Time();
		public var cam:Camera;
		public static var dataloader:DataLoader = new DataLoader();
		public var dialogManager:DialogManager = new DialogManager();
		
		public function Game() 
		{
			// dataloader, do your thing...
			maps = dataloader.setupMaps();
			spells = dataloader.setupSpells();
			items = dataloader.setupItems();
			chests = dataloader.setupChests(items);
			player = dataloader.setupPlayer(spells);
			currentMapIndex = player.currentMapIndex;
			npcs = dataloader.setupNPCs(maps);
			enemies = dataloader.setupEnemies(maps, items);
			
			// prepare the stage
			loadMap();
			
			// set up cam
			cam = new Camera(GC.CAMERA_OFFSET, GC.PLAYER_MOVEMENT_SPEED);
			cam.adjustToPlayer(currentMap.height, currentMap.width, player);
			
			defineInputKeys();
		}
		
		override public function update():void
		{
			// Process general input
			processGeneralInput();
			
			super.update();
			
			if (gameMode == DIALOG_MODE) // Check if in dialog mode
			{
				if (!dialogModeInitiated)
					initiateDialogMode();
				
				return;
			}
			else if (gameMode == NORMAL_MODE)// normal mode
			{
				// Iterate the global time
				var currentTime:Array = time.newMinute();
				if (currentTime)
				{
					// Do AI logic of NPCs each new game minute
					for each (var npc:NPC in npcs)
					{
						npc.aiUpdate(currentTime[0], currentTime[1]);
					}
					
					for each (var enemy:Enemy in enemies)
					{
						enemy.aiUpdate(currentTime[0], currentTime[1]);
					}
					
					daytimeDisplay.displayText.text = time.daytimeString;
					timeDisplay.displayText.text = time.timeString;
					
					player.updateAlterations();
				}
				
				// Camera moves if player reaches cam offset
				cam.followPlayer(currentMap.height, currentMap.width, player);
				
				// Check if player leaves the map
				if (checkSwitchToNewMap())
				{
					resetStage();
				}
			}
		}
		
		public function loadMap():void
		{
			// helper variables
			var o:XML;
			var p:XML
			var i:int;
			var j:int;
			var house:House;
			houses = new Array();
			
			// load the level xml
			currentMap = maps[currentMapIndex];
			
			// load tiles
			tiles = new Tiles(currentMap.xml);
			add(tiles);
			
			// load player
			add(player);
			
			// load npcs
			for each (var npc:NPC in npcs) add(npc);
			
			// load enemies
			for each (var enemy:Enemy in enemies)
			{
				if (!enemy.defeated)
				{
					add(enemy);
				}
			}
			
			// load chests
			for each (var chest:Chest in chests) add(chest);
			
			// load trees
			trees = new Trees(currentMap.xml);
			add(trees);
			
			// load houses
			if (currentMap.type == GC.MAP_INDOOR)
			{
				// load up all houses of the parent map
				i = 0;
				for each (p in maps[currentMap.outsideMapIndex].xml.houses.tile)
				{
					house = new House(i, p.@x, p.@y);
					house.insideMapIndex = i;
					houses.push(house);
					i++;
				}
				// we have the currentMapIndex, so search in the parent maps' 
				// childMaps array which one of them has the same index, and take the
				// index within the array to find which element of houses this map is.
				for (j = 0; j < maps[currentMap.outsideMapIndex].childMaps.length; j++)
				{
					if (maps[currentMap.outsideMapIndex].childMaps[j] == currentMapIndex)
					{
						enteredHouse = houses[j];
						break;
					}
				}
			}
			else if (currentMap.xml.houses)
			{
				i = 0;
				for each (o in currentMap.xml.houses.tile)
				{
					house = new House(i, o.@x, o.@y);
					house.insideMapIndex = i;
					houses.push(house);
					add(house);
					i++;
				}
			}
			
			// show the collision grid
			var gridOverlay:GridOverlay;
			for each (o in currentMap.xml.solid.rect)
			{
				gridOverlay = new GridOverlay(o.@x, o.@y, o.@w, o.@h);
				gridOverlays.push(gridOverlay);
				add(gridOverlay);
			}
			
			// show the map name
			mapDisplay = new DisplayText(currentMap.name, 300, 0, "default", 10, 0xFFFFFF, 100);
			add(mapDisplay);
			
			// show the daytime of day
			daytimeDisplay = new DisplayText(GC.MORNING_STRING, 450, 0, "default", 10, 0xFFFFFF, 50);
			add(daytimeDisplay);
			
			// show the exact time of the day
			timeDisplay = new DisplayText("00:00", 550, 0, "default", 10, 0xFFFFFF, 50);
			add(timeDisplay);
			
			// create the text box of the npc
			npcDialogBox = new NPCDialogBox(200, 60, 1.5, 1);
			npcDialogBox.visible = false;
			add(npcDialogBox.textBox);
			addList(npcDialogBox.displayTexts);
			
			// create the text box of the player
			playerDialogBox = new PlayerDialogBox(10, 320, 2.5, 1.5);
			playerDialogBox.visible = false;
			add(playerDialogBox.textBox);
			addList(playerDialogBox.displayTexts);
			
			// status screen creation
			statusScreen = new StatusScreen();
			statusScreen.visible = false;
			add(statusScreen.background);
			add(statusScreen.portrait);
			addList(statusScreen.displayTexts);
			
			inventoryScreen = new InventoryScreen(dataloader.setupInventoryUIData());
			inventoryScreen.visible = false;
			add(inventoryScreen.background);
			add(inventoryScreen.cursor);
			add(inventoryScreen.cursorEquip);
			addList(inventoryScreen.displayTexts);
			
			spellsScreen = new SpellsScreen(dataloader.setupSpellsScreenUIData());
			spellsScreen.visible = false;
			add(spellsScreen.background)
			add(spellsScreen.cursor);
			addList(spellsScreen.displayTexts);
		}
		
		public function initiateDialogMode():void
		{
			if (dialogManager.setCurrentDialogWithPlayer(player, getNPCByName(player.dialogPartner)))
			{
				dialogModeInitiated = true;
				npcDialogBox.visible = true;
				
				// find the dialog that is to be displayed
				npcDialogBox.line = dialogManager.nextNPCLine(0);
			}
			else gameMode = NORMAL_MODE;
		}
		
		public function processGeneralInput():void
		{
			if (gameMode == DIALOG_MODE)
			{
				if (Input.pressed(GC.BUTTON_ACTION))
				{
					if (!dialogManager.dialogHasEnded)
					{
						if ((npcDialogBox.currentPage < npcDialogBox.pages.length))
						{
							npcDialogBox.nextPage();
						}
						else if ((dialogManager.currentTurn == GC.DIALOG_NPC_TURN))
						{
							npcDialogBox.line = dialogManager.nextNPCLine(playerDialogBox.chosenVersion - 1);
						}
						else 
						{
							if (!playerDialogBox.visible) playerDialogBox.visible = true;
							
							playerDialogBox.lineVersions = dialogManager.nextPlayerLineVersions;
						}
					}
					else 
					{
						gameMode = NORMAL_MODE;
						dialogEndedThisFrame = true;
						npcDialogBox.visible = false;
						playerDialogBox.visible = false;
						dialogModeInitiated = false;
					}
				}
				
				if (Input.pressed(GC.BUTTON_UP))
				{
					if (dialogManager.currentTurn == GC.DIALOG_NPC_TURN)
					{
						playerDialogBox.selectionUp();
					}
				}
				
				if (Input.pressed(GC.BUTTON_DOWN))
				{
					if (dialogManager.currentTurn == GC.DIALOG_NPC_TURN)
					{
						playerDialogBox.selectionDown();
					}
				}
			}
			else if (gameMode == NORMAL_MODE)
			{
				// Check for input that opens or closes the world map
				if (Input.pressed(GC.BUTTON_MAP))
				{
					openWorldMap();
				}
				else if (Input.pressed(GC.BUTTON_STATUS_SCREEN))
				{
					openStatusScreen();
				}
				else if (Input.pressed(GC.BUTTON_INVENTORY_SCREEN))
				{
					openInventoryScreen();
				}
				else if (Input.pressed(GC.BUTTON_SPELLS_SCREEN))
				{
					openSpellsScreen();
				}
				
				if (dialogEndedThisFrame) dialogEndedThisFrame = false;
			}
			else if (gameMode == WORLD_MAP_MODE)
			{
				if (Input.pressed(GC.BUTTON_MAP))
				{
					closeWorldMap();
				}
				else if (Input.pressed(GC.BUTTON_EXIT))
				{
					closeWorldMap();
				}
			}
			else if (gameMode == STATUS_SCREEN_MODE)
			{
				// Check for input that opens the menu
				if (Input.pressed(GC.BUTTON_STATUS_SCREEN))
				{
					closeStatusScreen();
				}
			}
			else if (gameMode == INVENTORY_SCREEN_MODE)
			{
				
				// Check for input that opens the menu
				if (Input.pressed(GC.BUTTON_INVENTORY_SCREEN))
				{
					closeInventoryScreen();
				}
				else if (Input.pressed(GC.BUTTON_UP))
				{
					inventoryScreen.cursorMovement(GC.BUTTON_UP);
				}
				else if (Input.pressed(GC.BUTTON_DOWN))
				{
					inventoryScreen.cursorMovement(GC.BUTTON_DOWN);
				}
				else if (Input.pressed(GC.BUTTON_LEFT))
				{
					inventoryScreen.cursorMovement(GC.BUTTON_LEFT);
				}
				else if (Input.pressed(GC.BUTTON_RIGHT))
				{
					inventoryScreen.cursorMovement(GC.BUTTON_RIGHT);
				}
				else if (Input.pressed(GC.BUTTON_ACTION))
				{
					inventoryScreen.actionPress();
				}
				else if (Input.pressed(GC.BUTTON_EXIT))
				{
					closeInventoryScreen();
				}
				else if (Input.pressed(GC.BUTTON_CANCEL))
				{
					inventoryScreen.cancelPress();
				}
			}
			else if (gameMode == SPELLS_SCREEN_MODE)
			{
				if (Input.pressed(GC.BUTTON_SPELLS_SCREEN))
				{
					closeSpellsScreen();
				}
				else if (Input.pressed(GC.BUTTON_EXIT))
				{
					closeSpellsScreen();
				}
				else if (Input.pressed(GC.BUTTON_UP))
				{
					spellsScreen.cursorMovement(GC.BUTTON_UP);
				}
				else if (Input.pressed(GC.BUTTON_DOWN))
				{
					spellsScreen.cursorMovement(GC.BUTTON_DOWN);
				}
				else if (Input.pressed(GC.BUTTON_ACTION))
				{
					spellsScreen.actionPress();
				}
			}
			
			
		}
		
		public function resetStage():void
		{
			removeAll();
			loadMap();
			cam.adjustToPlayer(currentMap.height, currentMap.width, player);
		}
		
		public function openWorldMap():void
		{
			gameMode = WORLD_MAP_MODE;
			removeAll();
			worldMap = new WorldMap();
			
			if (currentMap.type == GC.MAP_INDOOR)
			{
				worldMapMarker = new WorldMapMarker(player, maps[currentMap.outsideMapIndex], true, enteredHouse);
			}
			else worldMapMarker = new WorldMapMarker(player, maps[currentMapIndex], false, null);
				
			FP.camera.x = 0;
			FP.camera.y = 0;
			worldMap.x = 0;
			worldMap.y = 0;
			
			add(worldMap);
			add(worldMapMarker);
		}
		
		public function closeWorldMap():void 
		{
			gameMode = NORMAL_MODE;
			resetStage();
		}
		
		public function openStatusScreen():void
		{
			gameMode = STATUS_SCREEN_MODE;
			statusScreen.visible = true;
			statusScreen.stats = player.stats;	
		}
		
		public function closeStatusScreen():void
		{
			gameMode = NORMAL_MODE;
			statusScreen.visible = false;
		}
		
		public function openInventoryScreen():void
		{
			gameMode = INVENTORY_SCREEN_MODE;
			inventoryScreen.visible = true;
			inventoryScreen.initialize(player);
		}
		
		public function closeInventoryScreen():void
		{
			gameMode = NORMAL_MODE;
			inventoryScreen.visible = false;
			player.updateStats();
		}
		
		public function openSpellsScreen():void
		{
			gameMode = SPELLS_SCREEN_MODE;
			spellsScreen.visible = true;
			spellsScreen.initialize(player);
		}
		
		public function closeSpellsScreen():void
		{
			gameMode = NORMAL_MODE;
			spellsScreen.visible = false;
		}
		
		public function checkSwitchToNewMap():Boolean
		{
			var direction:int = checkMapBoundaries();
			
			if (direction != GC.MAP_NONE)
			{
				if (currentMap.type == GC.MAP_INDOOR)
				{
					player.x = enteredHouse.x + (enteredHouse.width / 2) - (GC.PLAYER_SPRITE_WIDTH / 2);
					player.y = enteredHouse.y + enteredHouse.height + 5;
					currentMapIndex = currentMap.outsideMapIndex;
					return true;
				}
				else {
					currentMapIndex = currentMap.exits[direction]
					switch (direction)
					{
						case GC.MAP_EAST:
						{
							player.x = 0
							return true;
						}
						case GC.MAP_WEST:
						{
							player.x = maps[currentMapIndex].width - GC.PLAYER_SPRITE_WIDTH;
							return true;
						}
						case GC.MAP_NORTH:
						{
							player.y = maps[currentMapIndex].height - GC.PLAYER_SPRITE_HEIGHT;
							return true;
						}
						case GC.MAP_SOUTH:
						{
							player.y = 0;
							return true;
						}
					}
				}
			}
			else if (player.enteringHouse())
			{
				enteredHouse = player.enteringHouse() as House;
				currentMapIndex = currentMap.childMaps[enteredHouse.insideMapIndex];
				player.x = maps[currentMapIndex].width / 2;
				player.y = maps[currentMapIndex].height - GC.PLAYER_SPRITE_HEIGHT - 10;
				return true;
			}
			
			return false;
		}
		
		public function checkMapBoundaries():int
		{
			if (player.x < 0) return GC.MAP_WEST;
			else if (player.x > currentMap.width) return GC.MAP_EAST;
			
			if (player.y < 0) return GC.MAP_NORTH;
			else if (player.y > currentMap.height) return GC.MAP_SOUTH;
			
			return GC.MAP_NONE;
		}
		
		public function defineInputKeys():void
		{
			Input.define(GC.BUTTON_UP, Key.W, Key.UP);
			Input.define(GC.BUTTON_DOWN, Key.S, Key.DOWN);
			Input.define(GC.BUTTON_LEFT, Key.A, Key.LEFT);
			Input.define(GC.BUTTON_RIGHT, Key.D, Key.RIGHT);
			Input.define(GC.BUTTON_MAP, Key.M);
			Input.define(GC.BUTTON_CANCEL, Key.X);
			Input.define(GC.BUTTON_EXIT, Key.ESCAPE);
			Input.define(GC.BUTTON_ACTION, Key.SPACE);
			Input.define(GC.BUTTON_STATUS_SCREEN, Key.C);
			Input.define(GC.BUTTON_INVENTORY_SCREEN, Key.I);
			Input.define(GC.BUTTON_SPELLS_SCREEN, Key.V);
		}
		
		public function getNPCByName(_name:String):NPC
		{
			for each (var n:NPC in npcs)
			{
				if (n.name == _name) return n;
			}
			
			return null;
		}
	}
}
