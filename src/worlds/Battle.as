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
		public var enemy:Enemy;
		public var mobs:Array = new Array();
		public var mobPositions:Array = new Array();
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
		public var currentCursorPositionKey:String = GC.BATTLE_KEY_ATTACK;
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
						
			// set up cursorPositions[] and cursor entity
			initCursor(_battleUIData);
			// initialize battle UI and combattant entities
			initEntities();
			// initialize combattants[]
			initCombattants();
			// set state variables for player's turn
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
				if (!playerTurn) // it's a mob's turn
				{
					if (player.dead) // if the player died in the previous turn, conclude the battle 
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
						// first check whether the current mob is alive
						if (!combattants[currentTurn].dead)
						{
							// in which case the mob's battle AI determines the next action
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
					// if all mobs are dead, conclude the battle
					var battleEnded:Boolean = true;
					for each (var m:MobEntity in mobs)
					{
						if (!m.dead) 
						{
							battleEnded = false;
							break;
						}
					}
					if (!battleEnded)
					{
						// move on
						endPlayerTurn();
					}
					else 
					{
						// conclude the battle with a victory for the player 
						player.experience += enemy.experiencePoints;
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
			// if battle ended, the results screen is shown at this point. 
			// wait for the player to press action to switch worlds
			if (battleEnded)
			{
				if (Input.pressed(GC.BUTTON_ACTION))
				{
					FP.world = JRPG.game;
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
				if (currentCursorPositionKey == GC.BATTLE_KEY_ATTACK)
				{
					// the player can only attack if there is a weapon equipped
					if (!((player.equipment[GC.INVENTORY_KEY_WEAPON_EQUIP_PRIMARY] == null) && 
						(player.equipment[GC.INVENTORY_KEY_WEAPON_EQUIP_SECONDARY] == null)))
					{
						currentMode = ATTACK_TARGETING_MODE;
						startTargeting();
					}
				}
				else if (currentCursorPositionKey == GC.BATTLE_KEY_SPELL)
				{
					// the player can only select spells he/she knows at least one
					if (player.spells.length > 0)
					{
						currentMode = BROWSING_SPELLS_MODE;
						populateSpellListDisplays();
						showListBox(true);
						setCursorPosition(GC.BATTLE_KEY_LIST_ROW + "1");
						setInfoDisplayTexts();
					}
				}
				else if (currentCursorPositionKey == GC.BATTLE_KEY_DEFEND)
				{
					// TODO: something to temporarily boost armor or something else that
					// can lessen damage from mob attacks
					enterNextTurn = true;
				}
				else if (currentCursorPositionKey == GC.BATTLE_KEY_ITEM)
				{
					// only show the list if there is at least one consumable
					if (player.items[GC.ITEM_CONSUMABLE].length > 0)
					{
						currentMode = BROWSING_ITEMS_MODE;	
						populateItemListDisplays();
						showListBox(true);
						setCursorPosition(GC.BATTLE_KEY_LIST_ROW + "1");
						setInfoDisplayTexts();
					}	
				}
			}
			
			else if (currentMode == ATTACK_TARGETING_MODE)
			{
				currentMode = NORMAL_MODE;
				playerAttackMob();
				cursor.visible = false;
			}
			
			else if (currentMode == BROWSING_SPELLS_MODE)
			{
				selectSpell();
			}
			else if (currentMode == SPELL_TARGETING_MODE)
			{
				currentMode = NORMAL_MODE;
				playerCastOnMob();
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
			// we just assign new cursor positions and update the currentCursorPositionKey
			// accordingly, but first make checks if the new positions are valid or existent at all
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
			// for up and down, we also need to update information display texts 
			// if the cursor is currently navigating the list box
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
		
		// when pressing the cancel button, the current mode must
		// be reset to the one that comes before it 
		public function cancelPress():void
		{
			if (currentMode == ATTACK_TARGETING_MODE)
			{
				setCursorPosition(GC.BATTLE_KEY_ATTACK);
				currentMode = NORMAL_MODE;
			}
			else if (currentMode == BROWSING_ITEMS_MODE)
			{
				showListBox(false);
				setCursorPosition(GC.BATTLE_KEY_ITEM);
				currentMode = NORMAL_MODE;
			}
			else if (currentMode == BROWSING_SPELLS_MODE)
			{
				showListBox(false);
				setCursorPosition(GC.BATTLE_KEY_SPELL);
				currentMode = NORMAL_MODE;
			}
			else if (currentMode == SPELL_TARGETING_MODE)
			{
				setCursorPosition(GC.BATTLE_KEY_LIST_ROW + "1");
				currentMode = BROWSING_SPELLS_MODE;
				castingScroll = false;
			}
		}
		
		// little helper function that just sets the cursor to a given position
		// by using the cursor position key
		public function setCursorPosition(_positionKey:String):void
		{
			currentCursorPositionKey = _positionKey;
			cursor.position = cursorPositions[_positionKey].getPosition();			
		}
		
		// set the visibility of the list box by the _visible parameter
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
			
			// in items mode, we don't need the fourth list info display
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
			for (var i:int = (mobs.length - 1); i >= 0; i--)
			{
				if (mobs[i].dead)
				{
					cursorPositions[GC.BATTLE_KEY_ENEMY + (i + 1)].valid = false;
				}
				else 
				{
					cursorPositions[GC.BATTLE_KEY_ENEMY + (i + 1)].valid = true;
					currentCursorPositionKey = GC.BATTLE_KEY_ENEMY + (i + 1);
				}
			}
			cursor.position = cursorPositions[currentCursorPositionKey].getPosition();
		}
		
		// Determine the spell that was selected and decide what to do next based on the
		// type of spell: offensive or defensive
		public function selectSpell():void
		{
			// Get instance of the spell
			var spellIndex:int = int(currentCursorPositionKey.charAt(currentCursorPositionKey.length - 1)) - 1 + listStartIndex;
			
			if (player.mana >= Game.spells[player.spells[spellIndex]].manaCost)
			{
				// If the spell was defensive, cast it on the player and end the turn
				if (Game.spells[player.spells[spellIndex]] is DefenseSpell)
				{
					currentMode = NORMAL_MODE;
					
					var defenseSpell:DefenseSpell = new DefenseSpell();
					defenseSpell.copy(Game.spells[player.spells[spellIndex]]);
					playerBattle.castOnSelf(defenseSpell);
					
					// until we have entities for the animation for casting on oneself,
					// we just move to the next turn
					enterNextTurn = true;
				}
				// if it was offensive, enter targeting mode
				else if (Game.spells[player.spells[spellIndex]] is OffenseSpell)
				{
					currentMode = SPELL_TARGETING_MODE;
					targetedSpell = player.spells[spellIndex];
					startTargeting();
				}
			}
		}
		
		public function playerAttackMob():void
		{
			// find the mob that the cursor points to
			for (var i:int = 0; i < mobs.length; i++)
			{
				if (mobs[i].key == currentCursorPositionKey)
				{
					if (!mobs[i].dead)
					{
						// determine the type of attack: melee, melee with dual wielding or ranged?
						if (player.attackType == GC.ATTACK_TYPE_MELEE)
						{
							if (player.equipment[GC.INVENTORY_KEY_WEAPON_EQUIP_SECONDARY] != null)
							{
								playerBattle.meleeAttack(new Point(mobs[i].x, mobs[i].y), mobs[i], true);
							}
							else 
							{
								playerBattle.meleeAttack(new Point(mobs[i].x, mobs[i].y), mobs[i], false);
							}
						}
						else if (player.attackType == GC.ATTACK_TYPE_RANGED)
						{
							playerBattle.rangedAttack(new Point(mobs[i].x, mobs[i].y), mobs[i]);
						}
					}
				}
			}
		}
		
		// find the mob that was targeted and cast the selected spell
		public function playerCastOnMob():void
		{
			for (var i:int = 0; i < mobs.length; i++)
			{
				if (mobs[i].key == currentCursorPositionKey)
				{
					if (!mobs[i].dead)
					{
						playerBattle.castOnMob(mobs[i], targetedSpell, castingScroll);
					}
				}
			}
		}
		
		public function initEntities():void
		{
			// Initialize the actors
			playerBattle = new PlayerBattle(GC.BATTLE_PLAYER_X, GC.BATTLE_PLAYER_Y, player);
			initMobPositions();
			initMobs();
			
			// Initialize UI elements
			listBox = new TextBox(200, 200, 2, 2);
			attackDisplay = new DisplayText(GC.ATTACK_STRING, 300, 380, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			spellDisplay = new DisplayText(GC.SPELL_STRING, 385, 380, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			defendDisplay = new DisplayText(GC.DEFEND_STRING, 470, 380, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			itemDisplay = new DisplayText(GC.ITEM_STRING, 555, 380, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			
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
			resultsExperienceGained = new DisplayText(GC.EXPERIENCE_GAINED_STRING + ": ", 100, 100, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			resultsGoldReceived = new DisplayText(GC.GOLD_RECEIVED_STRING + ": ", 100, 130, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			resultsLootReceived = new DisplayText(GC.LOOT_STRING + ": ", 100, 160, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			
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
			for each (var m:MobEntity in mobs)
			{
				add(m);
				add(m.statDisplay);
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
			// reset list displays and invalidate cursor positions
			for (var i:int = 0; i < 6; i++)
			{
				listDisplays[i].displayText.text = "";
				cursorPositions[GC.BATTLE_KEY_LIST_ROW + (i + 1)].valid = false;
			}
			
			// set up listEndIndex
			if (player.items[GC.ITEM_CONSUMABLE].length > 6)
			{
				listEndIndex = 6;
			}
			else listEndIndex = player.items[GC.ITEM_CONSUMABLE].length;
			
			// populate list rows with item names and validate cursor positions
			for (i = 0; i < listEndIndex; i++)
			{
				listDisplays[i].displayText.text = player.items[GC.ITEM_CONSUMABLE][i].item[GC.ITEM_CONSUMABLE].name;
				cursorPositions[GC.BATTLE_KEY_LIST_ROW + (i + 1)].valid = true;
			}
		}
		
		public function populateSpellListDisplays():void
		{
			// reset list displays and invalidate cursor positions
			for (var i:int = 0; i < 6; i++)
			{
				listDisplays[i].displayText.text = "";
				cursorPositions[GC.BATTLE_KEY_LIST_ROW + (i + 1)].valid = false;
			}
			
			// set up listEndIndex
			if (player.spells.length > 6)
			{
				listEndIndex = 6;
			}
			else listEndIndex = player.spells.length;
			
			// populate list rows with spell names and validate cursor positions
			for (i = 0; i < listEndIndex; i++)
			{
				listDisplays[i].displayText.text = player.spells[i];
				cursorPositions[GC.BATTLE_KEY_LIST_ROW + (i + 1)].valid = true;
			}
		}
		
		public function setInfoDisplayTexts ():void
		{
			// get the consumable/spell instances of the currently selected
			// list row and populate the info display texts on the right side 
			if (currentMode == BROWSING_ITEMS_MODE)
			{
				var consumableIndex:int = int(currentCursorPositionKey.charAt(currentCursorPositionKey.length - 1)) - 1;
				consumableIndex += listStartIndex;
				
				var consumable:InventoryItem = player.items[GC.ITEM_CONSUMABLE][consumableIndex];
				
				listDisplayOne.displayText.text = GC.NAME_STRING + ": " + consumable.item[GC.ITEM_CONSUMABLE].name;
				listDisplayTwo.displayText.text = GC.QUANTITY_STRING + ": " + consumable.quantity;
				listDisplayThree.displayText.text = GC.EFFECT_STRING + ": " + consumable.item[GC.ITEM_CONSUMABLE].description;
			}
			else if (currentMode == BROWSING_SPELLS_MODE)
			{
				var spellIndex:int = int(currentCursorPositionKey.charAt(currentCursorPositionKey.length - 1)) - 1;
				var spell:String = listDisplays[spellIndex].displayText.text;
				
				listDisplayOne.displayText.text = GC.NAME_STRING + ": " + spell;
				listDisplayTwo.displayText.text = GC.EFFECT_STRING + ": " + Game.spells[spell].description;
				listDisplayThree.displayText.text = GC.MANACOST_STRING + ": " + Game.spells[spell].manaCost;
				
				if (Game.spells[spell].temporary)
				{ 
					listDisplayFour.displayText.text = GC.DURATION_STRING + ": " + Game.spells[spell].duration;
				}
				else listDisplayFour.displayText.text = "";
			}
		}
		
		public function initMobPositions():void
		{
			mobPositions.push(new Point(GC.BATTLE_MOB_ONE_X, GC.BATTLE_MOB_ONE_Y));
			mobPositions.push(new Point(GC.BATTLE_MOB_TWO_X, GC.BATTLE_MOB_TWO_Y));
			mobPositions.push(new Point(GC.BATTLE_MOB_THREE_X, GC.BATTLE_MOB_THREE_Y));
		}
		
		public function initMobs():void
		{
			// loop through the mobs of _enemy and instantiate MobEntity subclasses accordingly
			var mobIndex:int = 0;
			for each (var mob:Mob in enemy.mobs)
			{
				for (var i:int = 0; i < mob.quantity; i++)
				{
					switch (mob.type)
					{
						case (GC.ENEMY_TYPE_ZELDA): {
							mobs.push(new ZeldaMob(mobPositions[mobIndex++], mobIndex, Game.items));
							break;
						}
						case (GC.ENEMY_TYPE_VELDA): {
							mobs.push(new VeldaMob(mobPositions[mobIndex++], mobIndex, Game.items));
							break;
						}
					}
				}
			}
		}
		
		public function initCombattants():void
		{
			combattants.push(playerBattle);
			for each (var m:MobEntity in mobs)
			{
				combattants.push(m);
			}
		}
		
		// setup state variables to begin the player's turn
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
		
		// setup state variables to end the player's turn
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
			setCursorPosition(GC.BATTLE_KEY_ATTACK);
		}
		
		// display the results screen UI, content depending if it's victory or defeat
		public function showResultsScreen():void
		{
			if (enemy.defeated)
			{
				resultsScreen.visible = true;
				resultsExperienceGained.visible = true;
				resultsGoldReceived.visible = true;
				resultsLootReceived.visible = true;
				
				resultsExperienceGained.displayText.text += enemy.experiencePoints;
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
				resultsExperienceGained.displayText.text = GC.BATTLE_LOST_STRING;
			}
			
			battleEnded = true;
		}
		
	}
}
