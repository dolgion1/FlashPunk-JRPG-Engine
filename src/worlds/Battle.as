package worlds 
{
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import utility.*;
	import entities.*;
	import entities.battle.*;
	import net.flashpunk.*;
	import net.flashpunk.utils.*;
	
	/**
	 * ...
	 * @author dolgion1
	 */
	public class Battle extends World
	{
		public var player:Player;
		public var playerBattle:PlayerBattle;
		public var enemies:Array = new Array();
		public var enemyPositions:Array = new Array();
		public var combattants:Array = new Array();
		public var currentTurn:int;
		public var playerTurn:Boolean;
		public var enemyTurnTimer:int = 10;
		public var frameCount:int = 0;
		public var attackDisplay:DisplayText;
		public var defendDisplay:DisplayText;
		public var itemDisplay:DisplayText;
		public var cursor:Cursor;
		public var cursorPositions:Dictionary;
		public var currentCursorPositionKey:String = "Attack";
		public var dataloader:DataLoader = new DataLoader();
		public var targeting:Boolean = false;
		public var itemListBox:TextBox;
		public var browsingItems:Boolean = false;
		
		public var itemListDisplays:Array = new Array();
		public var itemListStartIndex:int = 0;
		public var itemListEndIndex:int = 0;
		
		public function Battle(_player:Player, _enemy:Enemy) 
		{
			cursorPositions = dataloader.setupBattleUIData()[0];
			cursor = new Cursor(0, 0);
			cursor.visible = true;
			cursor.setPosition(cursorPositions[currentCursorPositionKey].getPosition());
			itemListBox = new TextBox(200, 200, 2, 2);
			initEnemyPositions();
			
			player = _player;
			playerBattle = new PlayerBattle(GC.BATTLE_PLAYER_X, GC.BATTLE_PLAYER_Y);
			
			initEnemies(_enemy);
			loadEntities();
			initCombattants();
			initDisplayTexts();
			populateItemListDisplays();
		}
		
		override public function update():void
		{
			super.update();
			
			processGeneralInput();
			
			if (!playerTurn)
			{
				frameCount++;
				if (frameCount % FP.assignedFrameRate == 0)
				{
					FP.log("New turn in: " + enemyTurnTimer);
					enemyTurnTimer--;
					if (enemyTurnTimer < 1)
					{
						enemyTurnTimer = 4;
						currentTurn++;
						if (currentTurn >= combattants.length)
						{
							frameCount = 0;
							beginPlayerTurn()
						}
						FP.log("Turn no." + currentTurn);
					}
				}
			}
			
		}
		
		public function processGeneralInput():void
		{
			if (Input.pressed(GC.BUTTON_EXIT))
			{
				FP.world = Main.game;
			}
			
			if (playerTurn)
			{
				if (Input.pressed(GC.BUTTON_ACTION))
				{
					if (currentCursorPositionKey == "Attack")
					{
						targeting = true;
						cursorPositions["Enemy1"].valid = true;
						cursorPositions["Enemy2"].valid = true;
						cursorPositions["Enemy3"].valid = true;
						currentCursorPositionKey = "Enemy1";
						cursor.position = cursorPositions[currentCursorPositionKey].getPosition();
					}
					else if (targeting)
					{
						// reduce health of the targetted EnemyBattle
						playerAttackEnemy(); // still need to implement proper damage calculation
						
						// end turn
						targeting = false;
						cursorPositions["Enemy1"].valid = false;
						cursorPositions["Enemy2"].valid = false;
						cursorPositions["Enemy3"].valid = false;
						endPlayerTurn();
					}
					else if (currentCursorPositionKey == "Defend")
					{
						// need to increase armorRating for one turn
						endPlayerTurn();
					}
					else if (currentCursorPositionKey == "Item")
					{
						itemListBox.visible = true;
						browsingItems = true;
						for each (var d:DisplayText in itemListDisplays)
						{
							d.visible = true;
						}
						currentCursorPositionKey = "ItemListRow1";
						cursor.position = cursorPositions["ItemListRow1"].getPosition();
					}
					else if (browsingItems)
					{
						// TODO: consuming some shit
						
						endPlayerTurn();
					}
				}
				
				if (Input.pressed(GC.BUTTON_LEFT))
				{
					if (cursorPositions[currentCursorPositionKey].leftKey != null)
					{
						currentCursorPositionKey = cursorPositions[currentCursorPositionKey].leftKey;
						cursor.position = cursorPositions[currentCursorPositionKey].getPosition();
					}
				}
				else if (Input.pressed(GC.BUTTON_RIGHT))
				{
					if (cursorPositions[currentCursorPositionKey].rightKey != null)
					{
						currentCursorPositionKey = cursorPositions[currentCursorPositionKey].rightKey;
						cursor.position = cursorPositions[currentCursorPositionKey].getPosition();
					}
				}
				else if (Input.pressed(GC.BUTTON_UP))
				{
					if (cursorPositions[currentCursorPositionKey].upKey != null)
					{
						currentCursorPositionKey = cursorPositions[currentCursorPositionKey].upKey;
						cursor.position = cursorPositions[currentCursorPositionKey].getPosition();
					}
				}
				else if (Input.pressed(GC.BUTTON_DOWN))
				{
					if (cursorPositions[currentCursorPositionKey].downKey != null)
					{
						currentCursorPositionKey = cursorPositions[currentCursorPositionKey].downKey;
						cursor.position = cursorPositions[currentCursorPositionKey].getPosition();
					}
				}
			}
		}
		
		public function playerAttackEnemy():void
		{
			for each (var e:EnemyBattle in enemies)
			{
				if (e.key == currentCursorPositionKey)
				{
					e.health -= player.damageRating;
					e.updateStatDisplay();
				}
			}
		}
		
		
		public function initDisplayTexts():void
		{
			attackDisplay = new DisplayText("Attack", 370, 380, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			defendDisplay = new DisplayText("Defend", 455, 380, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			itemDisplay = new DisplayText("Item", 540, 380, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			attackDisplay.visible = true;
			defendDisplay.visible = true;
			itemDisplay.visible = true;
			itemListBox.visible = false;
			add(attackDisplay);
			add(defendDisplay);
			add(itemDisplay);
			add(itemListBox);
			
			itemListDisplays.push(new DisplayText("", 250, 230, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500));
			itemListDisplays.push(new DisplayText("", 250, 250, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500));
			itemListDisplays.push(new DisplayText("", 250, 270, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500));
			itemListDisplays.push(new DisplayText("", 250, 290, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500));
			itemListDisplays.push(new DisplayText("", 250, 310, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500));
			itemListDisplays.push(new DisplayText("", 250, 330, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500));
			
			for each (var d:DisplayText in itemListDisplays)
			{
				add(d);
				d.visible = false;
			}
			add(cursor);
		}
		
		public function populateItemListDisplays():void
		{
			if (player.items[GC.ITEM_CONSUMABLE].length > 6)
			{
				itemListEndIndex = 6;
			}
			else itemListEndIndex = player.items[GC.ITEM_CONSUMABLE].length;
			
			for (var i:int = 0; i < itemListEndIndex; i++)
			{
				itemListDisplays[i].displayText.text = player.items[GC.ITEM_CONSUMABLE][i].item[GC.ITEM_CONSUMABLE].name;
			}
		}
		
		public function initEnemyPositions():void
		{
			enemyPositions.push(new Point(GC.BATTLE_ENEMY_ONE_X, GC.BATTLE_ENEMY_ONE_Y));
			enemyPositions.push(new Point(GC.BATTLE_ENEMY_TWO_X, GC.BATTLE_ENEMY_TWO_Y));
			enemyPositions.push(new Point(GC.BATTLE_ENEMY_THREE_X, GC.BATTLE_ENEMY_THREE_Y));
		}
		
		public function initCombattants():void
		{
			combattants.push(playerBattle);
			for each (var e:EnemyBattle in enemies)
			{
				combattants.push(e);
			}
			currentTurn = 0;
			playerTurn = true;
		}
		
		public function initEnemies(_enemy:Enemy):void
		{
			var enemyIndex:int = 0;
			for each (var mob:Mob in _enemy.mobs)
			{
				for (var i:int = 0; i < mob.quantity; i++)
				{
					switch (mob.type)
					{
						case (GC.ENEMY_TYPE_ZELDA): {
							enemies.push(new ZeldaBattle(enemyPositions[enemyIndex++], enemyIndex));
							break;
						}
						case (GC.ENEMY_TYPE_VELDA): {
							enemies.push(new VeldaBattle(enemyPositions[enemyIndex++], enemyIndex));
							break;
						}
					}
				}
			}
		}
		
		public function loadEntities():void
		{
			add(playerBattle);
			
			for each (var e:EnemyBattle in enemies)
			{
				add(e);
				add(e.statDisplay);
			}
			
			
		}
		
		public function beginPlayerTurn():void
		{
			currentTurn = 0;
			playerTurn = true;
			attackDisplay.visible = true;
			defendDisplay.visible = true;
			itemDisplay.visible = true;
			cursor.visible = true;
		}
		
		public function endPlayerTurn():void
		{
			currentTurn++;
			playerTurn = false;
			attackDisplay.visible = false;
			defendDisplay.visible = false;
			itemDisplay.visible = false;
			cursor.visible = false;
			currentCursorPositionKey = "Attack";
			cursor.position = cursorPositions["Attack"].getPosition();
		}
	}

}