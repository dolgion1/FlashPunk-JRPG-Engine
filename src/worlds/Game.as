package worlds 
{
	import entities.*;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import net.flashpunk.graphics.Text;
	import utility.*;
	import net.flashpunk.*;
	import net.flashpunk.utils.*;
	
	/**
	 * ...
	 * @author dolgion
	 */
	public class Game extends World
	{
		// Entities
		public var player:Player;
		public var npcs:Array = new Array();
		public var tiles:Tiles;
		public var trees:Trees;
		public var houses:Array;
		public var worldMap:WorldMap;
		public var worldMapMarker:WorldMapMarker;
		public var mapDisplay:DisplayText;
		public var daytimeDisplay:DisplayText;
		public var timeDisplay:DisplayText;
		public var npcTextBox:TextBox;
		public var npcText:DisplayText;
		public var gridOverlays:Array = new Array();
		
		// Helper Datastructures
		public var maps:Array = new Array();
		public var currentMap:Map;
		public var enteredHouse:House;
		
		// Helper state variables
		public static var currentMapIndex:int;
		public var worldMapOpened:Boolean = false;
		
		// Utilities
		public var time:Time = new Time();
		public var camera:Camera;
		public var dataloader:DataLoader = new DataLoader();
		
		public function Game() 
		{
			// dataloader, do your thing...
			maps = dataloader.setupMaps();
			player = dataloader.setupPlayer();
			currentMapIndex = player.currentMapIndex;
			npcs = dataloader.setupNPCs(maps);
			
			// prepare the stage
			loadMap();
			
			// set up camera
			camera = new Camera(200, Player.speed);
			camera.adjustToPlayer(currentMap.height, currentMap.width, player);
		}
		
		override public function update():void
		{
			// Process general input
			processGeneralInput();
			
			super.update();
			
			if (worldMapOpened) return;
			
			// Iterate the global time
			var currentTime:Array = time.newMinute();
			if (currentTime)
			{
				// Do AI logic of NPCs each new game minute
				for each (var npc:NPC in npcs)
				{
					npc.aiUpdate(currentTime[0], currentTime[1]);
				}
				
				daytimeDisplay.displayText.text = time.daytimeString;
				timeDisplay.displayText.text = time.timeString;
			}
			
			// Camera moves if player reaches cam offset
			camera.followPlayer(currentMap.height, currentMap.width, player);
			
			// Check if player leaves the map
			if (checkSwitchToNewMap())
			{
				resetStage();
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
			
			// load npc
			for each (var npc:NPC in npcs) add(npc);
			
			// load trees
			trees = new Trees(currentMap.xml);
			add(trees);
			
			// load houses
			if (currentMap.type == Map.INDOOR)
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
			daytimeDisplay = new DisplayText("Morning", 450, 0, "default", 10, 0xFFFFFF, 50);
			add(daytimeDisplay);
			
			// show the exact time of the day
			timeDisplay = new DisplayText("00:00", 550, 0, "default", 10, 0xFFFFFF, 50);
			add(timeDisplay);
			
			/* TODO: TextBox feature
			 *	// show the text box of the npc
			 *	npcTextBox = new TextBox(100, 0);
			 *	add(npcTextBox);
			 *	
			 *	// ..and the text
			 *	npcText = new DisplayText("Hi Link!", 150, 50, "default", 10, 0xFFFFFF, 50);
			 *	add(npcText);
			 */
		}
		
		public function processGeneralInput():void
		{
			// Check for input that opens or closes the world map
			if (Input.check(Key.M))
				if (!worldMapOpened) openWorldMap();
			
			if (Input.check(Key.ESCAPE))
				if (worldMapOpened) closeWorldMap();
		}
		
		public function resetStage():void
		{
			removeAll();
			loadMap();
			camera.adjustToPlayer(currentMap.height, currentMap.width, player);
		}
		
		public function openWorldMap():void
		{
			worldMapOpened = true;
			removeAll();
			worldMap = new WorldMap();
			
			if (currentMap.type == Map.INDOOR)
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
			worldMapOpened = false;
			resetStage();
		}
		
		public function checkSwitchToNewMap():Boolean
		{
			var direction:int = checkMapBoundaries();
			if (direction != Map.NONE)
			{
				if (currentMap.type == Map.INDOOR)
				{
					player.x = enteredHouse.x + (enteredHouse.width / 2) - (player.SPRITE_WIDTH / 2);
					player.y = enteredHouse.y + enteredHouse.height + 5;
					currentMapIndex = currentMap.outsideMapIndex;
					return true;
				}
				else {
					currentMapIndex = currentMap.exits[direction]
					switch (direction)
					{
						case Map.EAST:
						{
							player.x = 0
							return true;
						}
						case Map.WEST:
						{
							player.x = maps[currentMapIndex].width - player.SPRITE_WIDTH;
							return true;
						}
						case Map.NORTH:
						{
							player.y = maps[currentMapIndex].height - player.SPRITE_HEIGHT;
							return true;
						}
						case Map.SOUTH:
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
				player.y = maps[currentMapIndex].height - player.SPRITE_HEIGHT - 10;
				return true;
			}
			
			return false;
		}
		
		public function checkMapBoundaries():int
		{
			if (player.x < 0) return Map.WEST;
			else if (player.x > currentMap.width) return Map.EAST;
			
			if (player.y < 0) return Map.NORTH;
			else if (player.y > currentMap.height) return Map.SOUTH;
			
			return Map.NONE;
		}
	}
}