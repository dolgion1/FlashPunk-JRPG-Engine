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
		public const NORMAL_MODE:int = 0;
		public const ATTACK_TARGETING_MODE:int = 1;
		public const BROWSING_SPELLS_MODE:int = 2;
		public const SPELL_TARGETING_MODE:int = 3;
		public const BROWSING_ITEMS_MODE:int = 4;
		
		public var currentMode:int = NORMAL_MODE;
		public var resultsScreen:TextBox;
		public var resultsExperienceGained:DisplayText;
		public var resultsGoldReceived:DisplayText;
		public var resultsLootReceived:DisplayText;
		public var battleEnded:Boolean = false;
		
		public var player:Player;
		public var playerBattle:PlayerBattle;
		public var experiencePoints:int;
		public var enemy:Enemy;
		public var enemies:Array = new Array();
		public var enemyPositions:Array = new Array();
		public var combattants:Array = new Array();
		public var currentTurn:int;
		public var playerTurn:Boolean;
		public var enemyTurnTimer:int = 2;
		public var frameCount:int = 0;
		public var attackDisplay:DisplayText;
		public var spellDisplay:DisplayText;
		public var defendDisplay:DisplayText;
		public var itemDisplay:DisplayText;
		public var cursor:Cursor;
		public var cursorPositions:Dictionary;
		public var currentCursorPositionKey:String = "Attack";
		public var listBox:TextBox;
		public var targetedSpell:String;
		public var castingScroll:Boolean = false;
		
		public var listDisplays:Array = new Array();
		public var listStartIndex:int = 0;
		public var listEndIndex:int = 0;
		public var listDisplayOne:DisplayText;
		public var listDisplayTwo:DisplayText;
		public var listDisplayThree:DisplayText;
		public var listDisplayFour:DisplayText;
		
		public static var enterNextTurn:Boolean = false;
		
		
		public function Battle(_player:Player, _enemy:Enemy, _battleUIData:Array) 
		{
			enemy = _enemy;
			player = _player;
			experiencePoints = _enemy.experiencePoints;
			
			initCursor(_battleUIData);
			initEntities();
			initCombattants();
			
			beginPlayerTurn();
		}
		
		override public function update():void
		{
			super.update();
			
			processGeneralInput();
			
			if (battleEnded)
			{
				return;
			}
			
			if (enterNextTurn)
			{
				if (!playerTurn)
				{
					if (player.dead)
					{
						player.dead = false;
						player.x = 200;
						player.y = 100;
						player.health = player.maxHealth;
						player.mana = player.maxMana;
						enemy.defeated = false;
						showResultsScreen();
					}
					currentTurn++;
					enterNextTurn = false;
					playerBattle.updateStatDisplay();
					
					if (currentTurn >= combattants.length)
					{
						beginPlayerTurn();
					}
					else
					{
						// the current enemy must do something
						if (!combattants[currentTurn].dead)
						{
							combattants[currentTurn].battleAction(playerBattle);
						}
						else
						{
							enterNextTurn = true;
						}
					}
				}
				else 
				{
					var battleEnded:Boolean = true;
					for each (var e:EnemyBattle in enemies)
					{
						if (!e.dead) 
						{
							battleEnded = false;
							break;
						}
					}
					if (!battleEnded)
					{
						endPlayerTurn();
					}
					else 
					{
						player.experience += experiencePoints;
						player.gold += enemy.gold;
						player.takeLoot(enemy.loot);
						enemy.defeated = true;
						enemy.world.remove(enemy);
						showResultsScreen();
					}
				}
			}
		}
		
		public function initCursor(_battleUIData:Array):void
		{
			cursorPositions = _battleUIData[0];
			cursor = new Cursor(0, 0);
			cursor.visible = true;
			cursor.setPosition(cursorPositions[currentCursorPositionKey].getPosition());
		}
		
		public function processGeneralInput():void
		{
			if (battleEnded)
			{
				if (Input.pressed(GC.BUTTON_ACTION))
				{
					FP.world = Main.game;
				}
			}
			else
			{
				if (playerTurn)
				{
					if (Input.pressed(GC.BUTTON_ACTION))
					{
						actionPress();
					}
					else if (Input.pressed(GC.BUTTON_LEFT) ||
							 Input.pressed(GC.BUTTON_RIGHT) ||
							 Input.pressed(GC.BUTTON_UP) ||
							 Input.pressed(GC.BUTTON_DOWN))
					{
						cursorMovement();
					}
					
					else if (Input.pressed(GC.BUTTON_CANCEL))
					{
						cancelPress();
					}
				}
			}
		}
		
		public function actionPress():void
		{
			if (currentMode == NORMAL_MODE)
			{
				if (currentCursorPositionKey == "Attack")
				{
					if (!((player.equipment["WeaponEquipPrimary"] == null) && 
						(player.equipment["WeaponEquipSecondary"] == null)))
					{
						currentMode = ATTACK_TARGETING_MODE;
						startTargeting();
					}
				}
				else if (currentCursorPositionKey == "Spell")
				{
					if (player.spells.length > 0)
					{
						currentMode = BROWSING_SPELLS_MODE;
						populateSpellListDisplays();
						showListBox(true);
						setCursorPosition("ListRow1");
						setInfoDisplayTexts();
					}
				}
				else if (currentCursorPositionKey == "Defend")
				{
					enterNextTurn = true;
				}
				else if (currentCursorPositionKey == "Item")
				{
					if (player.items[GC.ITEM_CONSUMABLE].length > 0)
					{
						currentMode = BROWSING_ITEMS_MODE;	
						populateItemListDisplays();
						showListBox(true);
						setCursorPosition("ListRow1");
						setInfoDisplayTexts();
					}
				}
			}
			
			else if (currentMode == ATTACK_TARGETING_MODE)
			{
				currentMode = NORMAL_MODE;
				playerAttackEnemy();
				cursor.visible = false;
			}
			
			else if (currentMode == BROWSING_SPELLS_MODE)
			{
				selectSpell();
			}
			else if (currentMode == SPELL_TARGETING_MODE)
			{
				currentMode = NORMAL_MODE;
				playerCastOnEnemy();
				cursor.visible = false;							
				showListBox(false);
				
				if (castingScroll)
				{
					// go through player's inventory and decrease quantity of consumable 
					// with spell name targetedSpell
					for (var i:int = 0; i < player.items[GC.ITEM_CONSUMABLE].length; i++)
					{
						if (player.items[GC.ITEM_CONSUMABLE][i].item[GC.ITEM_CONSUMABLE].consumableType == GC.CONSUMABLE_TYPE_SCROLL)
						{
							if (player.items[GC.ITEM_CONSUMABLE][i].item[GC.ITEM_CONSUMABLE].spellName == targetedSpell)
							{
								player.items[GC.ITEM_CONSUMABLE][i].quantity--;
								if (player.items[GC.ITEM_CONSUMABLE][i].quantity < 1)
								{
									player.items[GC.ITEM_CONSUMABLE].splice(i, 1);
								}
							}
						}
					}
					castingScroll = false;
				}
			}
			
			else if (currentMode == BROWSING_ITEMS_MODE)
			{
				var consumableIndex:int = int(currentCursorPositionKey.charAt(currentCursorPositionKey.length - 1)) - 1;
				consumableIndex += listStartIndex;
				
				var consumable:Consumable = new Consumable();
				consumable.copy(player.items[GC.ITEM_CONSUMABLE][consumableIndex].item[GC.ITEM_CONSUMABLE]);
			
				if (consumable.consumableType == GC.CONSUMABLE_TYPE_POTION)
				{
					currentMode = NORMAL_MODE;
					player.consume(consumable, consumableIndex);
					playerBattle.updateStatDisplay();
					showListBox(false);
					enterNextTurn = true;
				}
				// functionality for casting spells from scrolls 
				else if (consumable.consumableType == GC.CONSUMABLE_TYPE_SCROLL)
				{
					if (Game.spells[consumable.spellName] is DefenseSpell)
					{
						currentMode = NORMAL_MODE;
						
						var defenseSpell:DefenseSpell = new DefenseSpell();
						defenseSpell.copy(Game.spells[consumable.spellName]);
						defenseSpell.manaCost = 0; 
						
						playerBattle.castOnSelf(defenseSpell);
						player.decreaseInventoryItemQuantity(GC.ITEM_CONSUMABLE, consumableIndex);
						showListBox(false);
						
						// until we have entities for the animation for casting on oneself,
						// we just move to the next turn
						enterNextTurn = true;
					}
					else if (Game.spells[consumable.spellName] is OffenseSpell)
					{
						currentMode = SPELL_TARGETING_MODE;
						targetedSpell = consumable.spellName;
						startTargeting();
						castingScroll = true;
					}
				}
			}
		}
		
		public function cursorMovement():void
		{
			if (Input.pressed(GC.BUTTON_LEFT))
			{
				if (cursorPositions[currentCursorPositionKey].leftKey != null)
				{
					var newKey:String = cursorPositions[currentCursorPositionKey].leftKey;
					if (cursorPositions[newKey].valid)
					{
						currentCursorPositionKey = newKey;
						cursor.position = cursorPositions[newKey].getPosition();
					}
				}
			}
			else if (Input.pressed(GC.BUTTON_RIGHT))
			{
				if (cursorPositions[currentCursorPositionKey].rightKey != null)
				{
					newKey = cursorPositions[currentCursorPositionKey].rightKey;
					if (cursorPositions[newKey].valid)
					{
						setCursorPosition(newKey);
					}
				}
			}
			else if (Input.pressed(GC.BUTTON_UP))
			{
				if (cursorPositions[currentCursorPositionKey].upKey != null)
				{
					newKey = cursorPositions[currentCursorPositionKey].upKey;
					if (cursorPositions[newKey].valid)
					{
						setCursorPosition(newKey);
						
						if (currentMode == BROWSING_ITEMS_MODE || 
							currentMode == BROWSING_SPELLS_MODE)
						{
							setInfoDisplayTexts();
						}
					}
				}
			}
			else if (Input.pressed(GC.BUTTON_DOWN))
			{
				if (cursorPositions[currentCursorPositionKey].downKey != null)
				{
					newKey = cursorPositions[currentCursorPositionKey].downKey;
					if (cursorPositions[newKey].valid)
					{
						setCursorPosition(newKey);
						
						if (currentMode == BROWSING_ITEMS_MODE || 
							currentMode == BROWSING_SPELLS_MODE)
						{
							setInfoDisplayTexts();
						}
					}
				}
			}
		}
		
		public function cancelPress():void
		{
			if (currentMode == ATTACK_TARGETING_MODE)
			{
				setCursorPosition("Attack");
				currentMode = NORMAL_MODE;
			}
			else if (currentMode == BROWSING_ITEMS_MODE)
			{
				showListBox(false);
				setCursorPosition("Item");
				currentMode = NORMAL_MODE;
			}
			else if (currentMode == BROWSING_SPELLS_MODE)
			{
				showListBox(false);
				setCursorPosition("Spell");
				currentMode = NORMAL_MODE;
			}
			else if (currentMode == SPELL_TARGETING_MODE)
			{
				setCursorPosition("ListRow1");
				currentMode = BROWSING_SPELLS_MODE;
				castingScroll = false;
			}
		}
		
		public function setCursorPosition(_positionKey:String):void
		{
			currentCursorPositionKey = _positionKey;
			cursor.position = cursorPositions[_positionKey].getPosition();			
		}
		
		public function showListBox(_visible:Boolean):void
		{
			listBox.visible = _visible;
			
			for each (var d:DisplayText in listDisplays)
			{
				d.visible = _visible;
			}
			
			listDisplayOne.visible = _visible;
			listDisplayTwo.visible = _visible;
			listDisplayThree.visible = _visible;
			listDisplayFour.visible = _visible;
			
			if ((_visible) && (currentMode == BROWSING_ITEMS_MODE))
			{
				listDisplayFour.visible = false;
			}
		}
		
		public function startTargeting():void
		{			
			// loop through enemies and determine
			// which cursorPosition is valid, setting 
			// true and false for each
			for (var i:int = (enemies.length - 1); i >= 0; i--)
			{
				if (enemies[i].dead)
				{
					cursorPositions["Enemy" + (i + 1)].valid = false;
				}
				else 
				{
					cursorPositions["Enemy" + (i + 1)].valid = true;
					currentCursorPositionKey = "Enemy" + (i + 1);
				}
			}
			cursor.position = cursorPositions[currentCursorPositionKey].getPosition();
		}
		
		public function selectSpell():void
		{
			// Get instance of the spell
			var spellIndex:int = int(currentCursorPositionKey.charAt(currentCursorPositionKey.length - 1)) - 1 + listStartIndex;
			
			if (player.mana >= Game.spells[player.spells[spellIndex]].manaCost)
			{
				if (Game.spells[player.spells[spellIndex]] is DefenseSpell)
				{
					currentMode = NORMAL_MODE;
					
					var defenseSpell:DefenseSpell = new DefenseSpell();
					defenseSpell.copy(Game.spells[player.spells[spellIndex]]);
					playerBattle.castOnSelf(defenseSpell);
					showListBox(true);
					
					// until we have entities for the animation for casting on oneself,
					// we just move to the next turn
					enterNextTurn = true;
				}
				else if (Game.spells[player.spells[spellIndex]] is OffenseSpell)
				{
					currentMode = SPELL_TARGETING_MODE;
					targetedSpell = player.spells[spellIndex];
					startTargeting();
				}
			}
		}
		
		public function playerAttackEnemy():void
		{
			for (var i:int = 0; i < enemies.length; i++)
			{
				if (enemies[i].key == currentCursorPositionKey)
				{
					if (!enemies[i].dead)
					{
						var enemyPositionIndex:int = int(enemies[i].key.charAt(enemies[i].key.length - 1)) - 1;
						if (player.attackType == GC.ATTACK_TYPE_MELEE)
						{
							if (player.equipment[GC.INVENTORY_KEY_WEAPON_EQUIP_SECONDARY] != null)
							{
								playerBattle.meleeAttack(enemyPositions[enemyPositionIndex], enemies[i], true);
							}
							else 
							{
								playerBattle.meleeAttack(enemyPositions[enemyPositionIndex], enemies[i], false);
							}
						}
						else if (player.attackType == GC.ATTACK_TYPE_RANGED)
						{
							playerBattle.rangedAttack(enemyPositions[enemyPositionIndex], enemies[i]);
						}
					}
				}
			}
		}
		
		
		public function playerCastOnEnemy():void
		{
			for (var i:int = 0; i < enemies.length; i++)
			{
				if (enemies[i].key == currentCursorPositionKey)
				{
					if (!enemies[i].dead)
					{
						playerBattle.castOnEnemy(enemies[i], targetedSpell, castingScroll);
					}
				}
			}
		}
		
		public function initEntities():void
		{
			// Initialize the actors
			playerBattle = new PlayerBattle(GC.BATTLE_PLAYER_X, GC.BATTLE_PLAYER_Y, player);
			initEnemyPositions();
			initMobs(enemy);
			
			// Initialize UI elements
			listBox = new TextBox(200, 200, 2, 2);
			attackDisplay = new DisplayText("Attack", 300, 380, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			spellDisplay = new DisplayText("Spell", 385, 380, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			defendDisplay = new DisplayText("Defend", 470, 380, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			itemDisplay = new DisplayText("Item", 555, 380, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			
			listDisplays.push(new DisplayText("", 250, 230, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500));
			listDisplays.push(new DisplayText("", 250, 250, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500));
			listDisplays.push(new DisplayText("", 250, 270, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500));
			listDisplays.push(new DisplayText("", 250, 290, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500));
			listDisplays.push(new DisplayText("", 250, 310, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500));
			listDisplays.push(new DisplayText("", 250, 330, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500));
			
			listDisplayOne = new DisplayText("", 400, 230, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			listDisplayTwo = new DisplayText("", 400, 250, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			listDisplayThree = new DisplayText("", 400, 270, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			listDisplayFour = new DisplayText("", 400, 290, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			
			resultsScreen = new TextBox(GC.INVENTORY_OFFSET_X, GC.INVENTORY_OFFSET_Y, GC.INVENTORY_SCALE_X, GC.INVENTORY_SCALE_Y);
			resultsExperienceGained = new DisplayText("Experience Gained: ", 100, 100, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			resultsGoldReceived = new DisplayText("Gold Received: ", 100, 130, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			resultsLootReceived = new DisplayText("Loot: ", 100, 160, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			
			// Set the visibility of UI
			listBox.visible = false;
			attackDisplay.visible = true;
			spellDisplay.visible = true;
			defendDisplay.visible = true;
			itemDisplay.visible = true;
			
			listDisplayOne.visible = false;
			listDisplayTwo.visible = false;
			listDisplayThree.visible = false;
			listDisplayFour.visible = false;
			
			resultsScreen.visible = false;
			resultsExperienceGained.visible = false;
			resultsGoldReceived.visible = false;
			resultsLootReceived.visible = false;
			
			// Add the entities to the stage
			add(playerBattle);
			add(playerBattle.statDisplay);
			for each (var e:EnemyBattle in enemies)
			{
				add(e);
				add(e.statDisplay);
			}
			
			add(attackDisplay);
			add(spellDisplay);
			add(defendDisplay);
			add(itemDisplay);
			add(listBox);
			
			add(listDisplayOne);
			add(listDisplayTwo);
			add(listDisplayThree);
			add(listDisplayFour);
			
			for each (var d:DisplayText in listDisplays)
			{
				add(d);
				d.visible = false;
			}
			
			add(cursor);
			
			add(resultsScreen);
			add(resultsExperienceGained);
			add(resultsGoldReceived);
			add(resultsLootReceived);
		}
		
		public function populateItemListDisplays():void
		{
			for (var i:int = 0; i < 6; i++)
			{
				listDisplays[i].displayText.text = "";
				cursorPositions["ListRow" + (i + 1)].valid = false;
			}
			if (player.items[GC.ITEM_CONSUMABLE].length > 6)
			{
				listEndIndex = 6;
			}
			else listEndIndex = player.items[GC.ITEM_CONSUMABLE].length;
			
			for (i = 0; i < listEndIndex; i++)
			{
				listDisplays[i].displayText.text = player.items[GC.ITEM_CONSUMABLE][i].item[GC.ITEM_CONSUMABLE].name;
				cursorPositions["ListRow" + (i + 1)].valid = true;
			}
		}
		
		public function populateSpellListDisplays():void
		{
			for (var i:int = 0; i < 6; i++)
			{
				listDisplays[i].displayText.text = "";
				cursorPositions["ListRow" + (i + 1)].valid = false;
			}
			
			if (player.spells.length > 6)
			{
				listEndIndex = 6;
			}
			else listEndIndex = player.spells.length;
			
			for (i = 0; i < listEndIndex; i++)
			{
				listDisplays[i].displayText.text = player.spells[i];
				FP.log(player.spells[i]);
				cursorPositions["ListRow" + (i + 1)].valid = true;
			}
		}
		
		public function setInfoDisplayTexts ():void
		{
			if (currentMode == BROWSING_ITEMS_MODE)
			{
				var consumableIndex:int = int(currentCursorPositionKey.charAt(currentCursorPositionKey.length - 1)) - 1;
				consumableIndex += listStartIndex;
				
				var consumable:InventoryItem = player.items[GC.ITEM_CONSUMABLE][consumableIndex];
				
				listDisplayOne.displayText.text = "Name: " + consumable.item[GC.ITEM_CONSUMABLE].name;
				listDisplayTwo.displayText.text = "Quantity: " + consumable.quantity;
				listDisplayThree.displayText.text = "Effect: " + consumable.item[GC.ITEM_CONSUMABLE].description;
			}
			else if (currentMode == BROWSING_SPELLS_MODE)
			{
				var spellIndex:int = int(currentCursorPositionKey.charAt(currentCursorPositionKey.length - 1)) - 1;
				//spellIndex += listStartIndex;
				

				//var spell:String = player.spells[spellIndex];
				var spell:String = listDisplays[spellIndex].displayText.text;
				
				listDisplayOne.displayText.text = "Name: " + spell;
				listDisplayTwo.displayText.text = "Effect: " + Game.spells[spell].description;
				listDisplayThree.displayText.text = "Manacost: " + Game.spells[spell].manaCost;
				
				if (Game.spells[spell].temporary)
				{ 
					listDisplayFour.displayText.text = "Duration: " + Game.spells[spell].duration;
				}
				else listDisplayFour.displayText.text = "";
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
		
		public function initMobs(_enemy:Enemy):void
		{
			var enemyIndex:int = 0;
			for each (var mob:Mob in _enemy.mobs)
			{
				for (var i:int = 0; i < mob.quantity; i++)
				{
					switch (mob.type)
					{
						case (GC.ENEMY_TYPE_ZELDA): {
							enemies.push(new ZeldaBattle(enemyPositions[enemyIndex++], enemyIndex, Game.items));
							break;
						}
						case (GC.ENEMY_TYPE_VELDA): {
							enemies.push(new VeldaBattle(enemyPositions[enemyIndex++], enemyIndex, Game.items));
							break;
						}
					}
				}
			}
		}
		
		public function beginPlayerTurn():void
		{
			currentTurn = 0;
			playerTurn = true;
			attackDisplay.visible = true;
			spellDisplay.visible = true;
			defendDisplay.visible = true;
			itemDisplay.visible = true;
			cursor.visible = true;
			playerBattle.updateSpellAlterations();
		}
		
		public function endPlayerTurn():void
		{
			currentMode = NORMAL_MODE;
			playerTurn = false;
			
			showListBox(false);
			attackDisplay.visible = false;
			spellDisplay.visible = false;
			defendDisplay.visible = false;
			itemDisplay.visible = false;
			cursor.visible = false;
			setCursorPosition("Attack");
		}
		
		public function showResultsScreen():void
		{
			if (enemy.defeated)
			{
				resultsScreen.visible = true;
				resultsExperienceGained.visible = true;
				resultsGoldReceived.visible = true;
				resultsLootReceived.visible = true;
				
				resultsExperienceGained.displayText.text += experiencePoints;
				resultsGoldReceived.displayText.text += enemy.gold;
				
				for (var i:int = 0; i < 3; i++)
				{
					for (var j:int = 0; j < enemy.loot[i].length; j++)
					{
						resultsLootReceived.displayText.text += enemy.loot[i][j].item[i].name + " x" + enemy.loot[i][j].quantity;
					}
				}
			}
			else
			{
				resultsScreen.visible = true;
				resultsExperienceGained.visible = true;
				resultsExperienceGained.displayText.text = "You died. You will respawn at starting position.";
			}
			
			battleEnded = true;
		}
		
	}
}
