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
		public var dl:DataLoader = new DataLoader();
		public var resultsScreen:TextBox;
		public var resultsExperienceGained:DisplayText;
		public var resultsGoldReceived:DisplayText;
		public var resultsLootReceived:DisplayText;
		public var battleEnded:Boolean = false;
		
		public static var spells:Dictionary = new Dictionary();
		public var items:Array = new Array();
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
		public var dataloader:DataLoader = new DataLoader();
		public var targeting:Boolean = false;
		public var listBox:TextBox;
		public var browsingItems:Boolean = false;
		public var browsingSpells:Boolean = false;
		public var targetingSpell:Boolean = false;
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
		
		
		public function Battle(_player:Player, _enemy:Enemy) 
		{
			spells = dl.setupSpells();
			items = dl.setupItems();
			cursorPositions = dataloader.setupBattleUIData()[0];
			cursor = new Cursor(0, 0);
			cursor.visible = true;
			cursor.setPosition(cursorPositions[currentCursorPositionKey].getPosition());
			listBox = new TextBox(200, 200, 2, 2);
			initEnemyPositions();
			experiencePoints = _enemy.experiencePoints;
			
			enemy = _enemy;
			player = _player;
			playerBattle = new PlayerBattle(GC.BATTLE_PLAYER_X, GC.BATTLE_PLAYER_Y, player);
			
			initEnemies(_enemy);
			loadEntities();
			initCombattants();
			initDisplayTexts();
			beginPlayerTurn();
			
			resultsScreen = new TextBox(GC.INVENTORY_OFFSET_X, GC.INVENTORY_OFFSET_Y, GC.INVENTORY_SCALE_X, GC.INVENTORY_SCALE_Y);
			resultsExperienceGained = new DisplayText("Experience Gained: ", 100, 100, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			resultsGoldReceived = new DisplayText("Gold Received: ", 100, 130, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			resultsLootReceived = new DisplayText("Loot: ", 100, 160, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			resultsScreen.visible = false;
			resultsExperienceGained.visible = false;
			resultsGoldReceived.visible = false;
			resultsLootReceived.visible = false;
			add(resultsScreen);
			add(resultsExperienceGained);
			add(resultsGoldReceived);
			add(resultsLootReceived);
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
							FP.log("combattant " + currentTurn + " not dead, start battle action");
							combattants[currentTurn].battleAction(playerBattle);
						}
						else
						{
							FP.log("combattant " + currentTurn + " dead, skip battle action");
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
							FP.log("There are still survivors");
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
						FP.log("current cursor position key: " + currentCursorPositionKey);
						if (currentCursorPositionKey == "Attack")
						{
							FP.log("FFS: attack");
							if (!((player.equipment["WeaponEquipPrimary"] == null) && 
								(player.equipment["WeaponEquipSecondary"] == null)))
							{
								targeting = true;
								
								// loop through enemies and determine
								// which cursorPosition is valid, setting 
								// true and false for each
								for (var i:int = (enemies.length - 1); i >= 0; i--)
								{
									if (enemies[i].dead)
									{
										FP.log("enemy " + i + " is dead");
										cursorPositions["Enemy" + (i + 1)].valid = false;
									}
									else 
									{
										FP.log("enemy " + i + " is alive");
										cursorPositions["Enemy" + (i + 1)].valid = true;
										currentCursorPositionKey = "Enemy" + (i + 1);
									}
								}
								cursor.position = cursorPositions[currentCursorPositionKey].getPosition();
							}
						}
						else if (targeting)
						{
							FP.log("FFS: targeting");
							// reduce health of the targetted EnemyBattle
							playerAttackEnemy(); // still need to implement proper damage calculation
							
							// end turn
							targeting = false;
							cursor.visible = false;
							cursorPositions["Enemy1"].valid = false;
							cursorPositions["Enemy2"].valid = false;
							cursorPositions["Enemy3"].valid = false;
						}
						else if (currentCursorPositionKey == "Spell")
						{
							FP.log("FFS: Spell");
							if (player.spells.length > 0)
							{
								populateSpellListDisplays();
								listBox.visible = true;
								browsingSpells = true;
								for each (var d:DisplayText in listDisplays)
								{
									d.visible = true;
								}
								listDisplayOne.visible = true;
								listDisplayTwo.visible = true;
								listDisplayThree.visible = true;
								listDisplayFour.visible = true;
								
								currentCursorPositionKey = "ListRow1";
								cursor.position = cursorPositions["ListRow1"].getPosition();
								
								setInfoDisplayTexts();
							}
						}
						else if (browsingSpells)
						{
							FP.log("FFS: browsingSpells");
							// Get instance of the spell
							var spellIndex:int = int(currentCursorPositionKey.charAt(currentCursorPositionKey.length - 1)) - 1 + listStartIndex;
							
							if (player.mana >= spells[player.spells[spellIndex]].manaCost)
							{
								if (spells[player.spells[spellIndex]] is DefenseSpell)
								{
									var defenseSpell:DefenseSpell = new DefenseSpell();
									defenseSpell.name = spells[player.spells[spellIndex]].name;
									defenseSpell.temporary = spells[player.spells[spellIndex]].temporary;
									defenseSpell.duration = spells[player.spells[spellIndex]].duration;
									defenseSpell.statusVariable = spells[player.spells[spellIndex]].statusVariable;
									defenseSpell.alteration = spells[player.spells[spellIndex]].alteration;
									defenseSpell.manaCost = spells[player.spells[spellIndex]].manaCost; 
									
									playerBattle.castOnSelf(defenseSpell);
									
									listBox.visible = false;
									for each (d in listDisplays)
									{
										d.visible = false;
									}
									listDisplayOne.visible = false;
									listDisplayTwo.visible = false;
									listDisplayThree.visible = false;
									listDisplayFour.visible = false;
									
									// until we have entities for the animation for casting on oneself,
									// we just move to the next turn
									enterNextTurn = true;
								}
								else if (spells[player.spells[spellIndex]] is OffenseSpell)
								{
									targetedSpell = player.spells[spellIndex];
									targetingSpell = true;
									for (i = (enemies.length - 1); i >= 0; i--)
									{
										if (enemies[i].dead)
										{
											FP.log("enemy " + i + " is dead");
											cursorPositions["Enemy" + (i + 1)].valid = false;
										}
										else 
										{
											FP.log("enemy " + i + " is alive");
											cursorPositions["Enemy" + (i + 1)].valid = true;
											currentCursorPositionKey = "Enemy" + (i + 1);
										}
									}
									cursor.position = cursorPositions[currentCursorPositionKey].getPosition();
								}
								
								browsingSpells = false;
							}
						}
						else if (targetingSpell)
						{
							FP.log("FFS: targetingSpell");
							playerCastOnEnemy();
							cursor.visible = false;
							targetingSpell = false;
							listBox.visible = false;
							for each (d in listDisplays)
							{
								d.visible = false;
							}
							listDisplayOne.visible = false;
							listDisplayTwo.visible = false;
							listDisplayThree.visible = false;
							listDisplayFour.visible = false;
							
							if (castingScroll)
							{
								// go through player's inventory and decrease quantity of consumable 
								// with spell name targetedSpell
								for (i = 0; i < player.items[GC.ITEM_CONSUMABLE].length; i++)
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
						else if (currentCursorPositionKey == "Defend")
						{
							FP.log("FFS: Defend");
							// need to increase armorRating for one turn
							FP.log("what is the problem..??");
							FP.log("what is the problem..??" + enterNextTurn);
							enterNextTurn = true;
							FP.log("Really.." + enterNextTurn);
						}
						else if (currentCursorPositionKey == "Item")
						{
							FP.log("FFS: Item");
							if (player.items[GC.ITEM_CONSUMABLE].length > 0)
							{
								populateItemListDisplays();
								listBox.visible = true;
								browsingItems = true;
								for each (d in listDisplays)
								{
									d.visible = true;
								}
								listDisplayOne.visible = true;
								listDisplayTwo.visible = true;
								listDisplayThree.visible = true;
								listDisplayFour.visible = false;
								
								currentCursorPositionKey = "ListRow1";
								cursor.position = cursorPositions["ListRow1"].getPosition();
								
								setInfoDisplayTexts();
							}
						}
						else if (browsingItems)
						{
							FP.log("FFS: browsingItems");
							var consumableIndex:int = int(currentCursorPositionKey.charAt(currentCursorPositionKey.length - 1)) - 1;
							consumableIndex += listStartIndex;
							
							var consumable:Consumable = new Consumable();
							consumable.copy(player.items[GC.ITEM_CONSUMABLE][consumableIndex].item[GC.ITEM_CONSUMABLE]);
							if (consumable.consumableType == GC.CONSUMABLE_TYPE_POTION)
							{
								player.consume(consumable);
								playerBattle.updateStatDisplay();
								
								// decrease quantity of the consumable
								player.items[GC.ITEM_CONSUMABLE][consumableIndex].quantity--;
								if (player.items[GC.ITEM_CONSUMABLE][consumableIndex].quantity < 1)
								{
									player.items[GC.ITEM_CONSUMABLE].splice(consumableIndex, 1);
								}
								listBox.visible = false;
								for each (d in listDisplays)
								{
									d.visible = false;
								}
								listDisplayOne.visible = false;
								listDisplayTwo.visible = false;
								listDisplayThree.visible = false;
								listDisplayFour.visible = false;
								
								enterNextTurn = true;
							}
							// functionality for casting spells from scrolls 
							else if (consumable.consumableType == GC.CONSUMABLE_TYPE_SCROLL)
							{
								FP.log("Casting scroll: " + consumable.spellName);
								if (spells[consumable.spellName] is DefenseSpell)
								{
									defenseSpell = new DefenseSpell();
									defenseSpell.name = spells[consumable.spellName].name;
									defenseSpell.temporary = spells[consumable.spellName].temporary;
									defenseSpell.duration = spells[consumable.spellName].duration;
									defenseSpell.statusVariable = spells[consumable.spellName].statusVariable;
									defenseSpell.alteration = spells[consumable.spellName].alteration;
									defenseSpell.manaCost = 0; 
									
									playerBattle.castOnSelf(defenseSpell);
									
									listBox.visible = false;
									for each (d in listDisplays)
									{
										d.visible = false;
									}
									listDisplayOne.visible = false;
									listDisplayTwo.visible = false;
									listDisplayThree.visible = false;
									listDisplayFour.visible = false;
									
									// until we have entities for the animation for casting on oneself,
									// we just move to the next turn
									enterNextTurn = true;
									player.items[GC.ITEM_CONSUMABLE][consumableIndex].quantity--;
									if (player.items[GC.ITEM_CONSUMABLE][consumableIndex].quantity < 1)
									{
										player.items[GC.ITEM_CONSUMABLE].splice(consumableIndex, 1);
									}
								}
								else if (spells[consumable.spellName] is OffenseSpell)
								{
									targetedSpell = consumable.spellName;
									targetingSpell = true;
									for (i = (enemies.length - 1); i >= 0; i--)
									{
										if (enemies[i].dead)
										{
											FP.log("enemy " + i + " is dead");
											cursorPositions["Enemy" + (i + 1)].valid = false;
										}
										else 
										{
											FP.log("enemy " + i + " is alive");
											cursorPositions["Enemy" + (i + 1)].valid = true;
											currentCursorPositionKey = "Enemy" + (i + 1);
										}
									}
									cursor.position = cursorPositions[currentCursorPositionKey].getPosition();
									castingScroll = true;
								}
							}
							browsingItems = false;
						}
					}
					else if (Input.pressed(GC.BUTTON_LEFT))
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
								currentCursorPositionKey = newKey;
								cursor.position = cursorPositions[newKey].getPosition();
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
								currentCursorPositionKey = newKey;
								cursor.position = cursorPositions[newKey].getPosition();
								if (browsingItems || browsingSpells)
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
								currentCursorPositionKey = newKey;
								cursor.position = cursorPositions[newKey].getPosition();
								if (browsingItems || browsingSpells)
								{
									setInfoDisplayTexts();
								}
							}
						}
					}
					else if (Input.pressed(GC.BUTTON_CANCEL))
					{
						if (targeting)
						{
							currentCursorPositionKey = "Attack";
							cursor.position = cursorPositions[currentCursorPositionKey].getPosition();
							targeting = false;
						}
						else if (browsingItems)
						{
							listBox.visible = false;
							for each (d in listDisplays)
							{
								d.visible = false;
							}
							listDisplayOne.visible = false;
							listDisplayTwo.visible = false;
							listDisplayThree.visible = false;
							listDisplayFour.visible = false;
							
							currentCursorPositionKey = "Item";
							cursor.position = cursorPositions[currentCursorPositionKey].getPosition();
							
							browsingItems = false;
						}
						else if (browsingSpells)
						{
							listBox.visible = false;
							for each (d in listDisplays)
							{
								d.visible = false;
							}
							listDisplayOne.visible = false;
							listDisplayTwo.visible = false;
							listDisplayThree.visible = false;
							listDisplayFour.visible = false;
							
							currentCursorPositionKey = "Spell";
							cursor.position = cursorPositions[currentCursorPositionKey].getPosition();
							
							browsingSpells = false;
							FP.log("cancelled browsing spells");
						}
						else if (targetingSpell)
						{
							currentCursorPositionKey = "ListRow1";
							cursor.position = cursorPositions[currentCursorPositionKey].getPosition();
							targetingSpell = false;
							browsingSpells = true;
							castingScroll = false;
						}
					}
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
		
		public function initDisplayTexts():void
		{
			attackDisplay = new DisplayText("Attack", 300, 380, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			spellDisplay = new DisplayText("Spell", 385, 380, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			defendDisplay = new DisplayText("Defend", 470, 380, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			itemDisplay = new DisplayText("Item", 555, 380, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			attackDisplay.visible = true;
			spellDisplay.visible = true;
			defendDisplay.visible = true;
			itemDisplay.visible = true;
			listBox.visible = false;
			add(attackDisplay);
			add(spellDisplay);
			add(defendDisplay);
			add(itemDisplay);
			add(listBox);
			
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
			
			listDisplayOne.visible = false;
			listDisplayTwo.visible = false;
			listDisplayThree.visible = false;
			listDisplayFour.visible = false;
			
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
			FP.log("spells: " + player.spells.length)
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
			if (browsingItems)
			{
				var consumableIndex:int = int(currentCursorPositionKey.charAt(currentCursorPositionKey.length - 1)) - 1;
				consumableIndex += listStartIndex;
				
				var consumable:InventoryItem = player.items[GC.ITEM_CONSUMABLE][consumableIndex];
				
				listDisplayOne.displayText.text = "Name: " + consumable.item[GC.ITEM_CONSUMABLE].name;
				listDisplayTwo.displayText.text = "Quantity: " + consumable.quantity;
				listDisplayThree.displayText.text = "Effect: " + consumable.item[GC.ITEM_CONSUMABLE].description;
			}
			else if (browsingSpells)
			{
				var spellIndex:int = int(currentCursorPositionKey.charAt(currentCursorPositionKey.length - 1)) - 1;
				//spellIndex += listStartIndex;
				

				//var spell:String = player.spells[spellIndex];
				var spell:String = listDisplays[spellIndex].displayText.text;
				
				FP.log("FfS: " + player.spells.length + " which is " + spell);
				listDisplayOne.displayText.text = "Name: " + spell;
				listDisplayTwo.displayText.text = "Effect: " + spells[spell].description;
				listDisplayThree.displayText.text = "Manacost: " + spells[spell].manaCost;
				
				if (spells[spell].temporary)
				{ 
					listDisplayFour.displayText.text = "Duration: " + spells[spell].duration;
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
							enemies.push(new ZeldaBattle(enemyPositions[enemyIndex++], enemyIndex, items));
							break;
						}
						case (GC.ENEMY_TYPE_VELDA): {
							enemies.push(new VeldaBattle(enemyPositions[enemyIndex++], enemyIndex, items));
							break;
						}
					}
				}
			}
		}
		
		public function loadEntities():void
		{
			add(playerBattle);
			add(playerBattle.statDisplay);
			for each (var e:EnemyBattle in enemies)
			{
				add(e);
				add(e.statDisplay);
			}
			
		}
		
		public function beginPlayerTurn():void
		{
			FP.log("in beginPlayerTurn");
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
			playerTurn = false;
			browsingItems = false;
			attackDisplay.visible = false;
			spellDisplay.visible = false;
			defendDisplay.visible = false;
			itemDisplay.visible = false;
			cursor.visible = false;
			currentCursorPositionKey = "Attack";
			cursor.position = cursorPositions["Attack"].getPosition();
			FP.log("in endplayerturn. currentTurn is " + currentTurn);
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
