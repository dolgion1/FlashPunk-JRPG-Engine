package utility 
{
	import entities.inventory.*;
	import entities.*;
	import flash.display.TriangleCulling;
	import net.flashpunk.FP;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author dolgion
	 */
	public class InventoryScreen
	{
		public var cursor:Cursor;
		public var cursorEquip:CursorEquip;
		public var background:TextBox;
		public var displayTexts:Array = new Array();
		public var equipmentHeader:DisplayText;
		public var itemsHeader:DisplayText;
		public var detailsHeader:DisplayText;
		
		public var player:Player;
		
		public var itemColumns:Array = new Array();
		public var itemsStartIndex:Array = new Array();
		public var itemsEndIndex:Array = new Array();
		
		public var currentMode:int = GC.INVENTORY_NORMAL_MODE;
		private var visibility:Boolean = false;
		
		public var currentCursorPositionKey:String = GC.INVENTORY_KEY_ARMOR_EQUIP_HEAD;
		public var currentCursorColumn:int = GC.INVENTORY_ARMOR_EQUIP_COLUMN;
		public var cursorPositions:Dictionary = new Dictionary();
		public var columnKeys:Array = new Array();
		
		public var currentEquipmentKey:String;
		
		public function InventoryScreen(_uiDatastructures:Array) 
		{
			initUIDatastructures(_uiDatastructures);
			initItemColumnDisplayTexts();
			
			background = new TextBox(GC.INVENTORY_OFFSET_X, GC.INVENTORY_OFFSET_Y, GC.INVENTORY_SCALE_X, GC.INVENTORY_SCALE_Y);
			cursor = new Cursor(0, 0);
			cursorEquip = new CursorEquip(0, 0);
			cursorEquip.visible = false;
		}
		
		public function initialize(_player:Player):void
		{
			player = _player;
			
			currentMode = GC.INVENTORY_NORMAL_MODE;
			currentCursorPositionKey = GC.INVENTORY_KEY_ARMOR_EQUIP_HEAD;
			currentCursorColumn = GC.INVENTORY_ARMOR_EQUIP_COLUMN;
			currentEquipmentKey = "";
			cursor.setPosition(cursorPositions[currentCursorPositionKey].getPosition());
			
			populateEquipmentColumns();
			populateItemColumns();
		}
		
		public function populateEquipmentColumns():void
		{
			if (player.equipment[GC.INVENTORY_KEY_ARMOR_EQUIP_HEAD] != null) displayTexts[GC.INVENTORY_ARMOR_EQUIP_HEAD_DISPLAY_TEXT].displayText.text = GC.BODY_PART_HEAD_STRING + ": " + player.equipment["ArmorEquipHead"].name;
			else displayTexts[GC.INVENTORY_ARMOR_EQUIP_HEAD_DISPLAY_TEXT].displayText.text = GC.BODY_PART_HEAD_STRING + ": ";
			
			if (player.equipment[GC.INVENTORY_KEY_ARMOR_EQUIP_TORSO] != null) displayTexts[GC.INVENTORY_ARMOR_EQUIP_TORSO_DISPLAY_TEXT].displayText.text = GC.BODY_PART_TORSO_STRING + ": " + player.equipment["ArmorEquipTorso"].name;
			else displayTexts[GC.INVENTORY_ARMOR_EQUIP_TORSO_DISPLAY_TEXT].displayText.text = GC.BODY_PART_TORSO_STRING + ": ";
			
			if (player.equipment[GC.INVENTORY_KEY_ARMOR_EQUIP_LEGS] != null) displayTexts[GC.INVENTORY_ARMOR_EQUIP_LEGS_DISPLAY_TEXT].displayText.text = GC.BODY_PART_LEGS_STRING + ": " + player.equipment["ArmorEquipLegs"].name;
			else displayTexts[GC.INVENTORY_ARMOR_EQUIP_LEGS_DISPLAY_TEXT].displayText.text = GC.BODY_PART_LEGS_STRING + ": ";
			
			if (player.equipment[GC.INVENTORY_KEY_ARMOR_EQUIP_HANDS] != null) displayTexts[GC.INVENTORY_ARMOR_EQUIP_HANDS_DISPLAY_TEXT].displayText.text = GC.BODY_PART_HANDS_STRING + ": " + player.equipment["ArmorEquipHands"].name;
			else displayTexts[GC.INVENTORY_ARMOR_EQUIP_HANDS_DISPLAY_TEXT].displayText.text = GC.BODY_PART_HANDS_STRING + ": ";
			
			if (player.equipment[GC.INVENTORY_KEY_ARMOR_EQUIP_FEET] != null) displayTexts[GC.INVENTORY_ARMOR_EQUIP_FEET_DISPLAY_TEXT].displayText.text = GC.BODY_PART_FEET_STRING + ": " + player.equipment["ArmorEquipFeet"].name;
			else displayTexts[GC.INVENTORY_ARMOR_EQUIP_FEET_DISPLAY_TEXT].displayText.text = GC.BODY_PART_FEET_STRING + ": ";
			
			if (player.equipment[GC.INVENTORY_KEY_WEAPON_EQUIP_PRIMARY] != null) displayTexts[GC.INVENTORY_WEAPON_EQUIP_PRIMARY_DISPLAY_TEXT].displayText.text = GC.PRIMARY_WEAPON_STRING + ": " + player.equipment["WeaponEquipPrimary"].name;
			else displayTexts[GC.INVENTORY_WEAPON_EQUIP_PRIMARY_DISPLAY_TEXT].displayText.text = GC.PRIMARY_WEAPON_STRING + ": ";
			
			if (player.equipment[GC.INVENTORY_KEY_WEAPON_EQUIP_SECONDARY] != null) displayTexts[GC.INVENTORY_WEAPON_EQUIP_SECONDARY_DISPLAY_TEXT].displayText.text = GC.SECONDARY_WEAPON_STRING + ": " + player.equipment["WeaponEquipSecondary"].name;
			else displayTexts[GC.INVENTORY_WEAPON_EQUIP_SECONDARY_DISPLAY_TEXT].displayText.text = GC.SECONDARY_WEAPON_STRING + ": ";
		}
		
		public function populateItemColumns():void
		{
			resetItemColumnDisplayTexts();
			itemsStartIndex[GC.INVENTORY_WEAPON_ITEM_COLUMN] = 0;
			itemsStartIndex[GC.INVENTORY_ARMOR_ITEM_COLUMN] = 0;
			itemsStartIndex[GC.INVENTORY_CONSUMABLE_ITEM_COLUMN] = 0;
			
			// set the text for every display list of each column
			var i:int;
			var j:int;
			for (i = 0; i < GC.INVENTORY_MAX_ITEM_COLUMNS; i++)
			{
				if (player.items.length == i) break;
				
				// set the end index of the items[i] subset
				// if it happens to be less than the max rows 
				if (player.items[i].length < GC.INVENTORY_MAX_ITEM_ROWS)
				{
					itemsEndIndex[i] = player.items[i].length;
				}
				else itemsEndIndex[i] = GC.INVENTORY_MAX_ITEM_ROWS;
				
				for (j = 0; j < itemsEndIndex[i]; j++)
				{
					itemColumns[i][j].displayText.text = player.items[i][j].item[i].name;
					cursorPositions[columnKeys[i][j]].valid = true;
				}
			}
		}
		
		public function updateItemColumn(_column:int):void
		{
			var currentItemIndex:int;
			var currentInventoryItem:InventoryItem;
			var currentItemName:String;
			
			for (var i:int = 0; i < GC.INVENTORY_MAX_ITEM_ROWS; i++)
			{
				currentItemIndex = itemsStartIndex[_column] + i;
				if (currentItemIndex < itemsEndIndex[_column])
				{
					currentInventoryItem = player.items[_column][currentItemIndex];
					currentItemName = currentInventoryItem.item[currentInventoryItem.type].name;
					itemColumns[_column][i].displayText.text = currentItemName;
				}
				else 
				{
					itemColumns[_column][i].displayText.text = "";
				}
			}
		}
		
		public function resetItemColumnDisplayTexts():void
		{
			for each (var column:Array in itemColumns)
			{
				for each (var d:DisplayText in column)
				{
					d.displayText.text = "";
					d.displayText.color = 0xFFFFFF;
					d.displayText.size = GC.INVENTORY_DEFAULT_FONT_SIZE;
				}
			}
		}
		
		public function resetInfoDisplayTexts():void
		{
			displayTexts[GC.INVENTORY_INFO_DISPLAY_TEXT_ONE].displayText.text = "";
			displayTexts[GC.INVENTORY_INFO_DISPLAY_TEXT_TWO].displayText.text = "";
			displayTexts[GC.INVENTORY_INFO_DISPLAY_TEXT_THREE].displayText.text = "";
			displayTexts[GC.INVENTORY_INFO_DISPLAY_TEXT_FOUR].displayText.text = "";
			displayTexts[GC.INVENTORY_INFO_DISPLAY_TEXT_FIVE].displayText.text = "";
			displayTexts[GC.INVENTORY_INFO_DISPLAY_TEXT_SIX].displayText.text = "";
			displayTexts[GC.INVENTORY_INFO_DISPLAY_TEXT_SEVEN].displayText.text = "";
			displayTexts[GC.INVENTORY_INFO_DISPLAY_TEXT_EIGHT].displayText.text = "";
		}
		
		
		public function initItemColumnDisplayTexts():void
		{
			for (var i:int = 0; i < GC.INVENTORY_MAX_ITEM_COLUMNS; i++)
			{
				itemColumns[i] = new Array();
				for (var j:int = 0; j < GC.INVENTORY_MAX_ITEM_ROWS; j++)
				{
					itemColumns[i].push(new DisplayText("", 100 + (i * 150), 200 + (j * 20), "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500));
					displayTexts.push(itemColumns[i][j]);
				}
			}
		}
		
		public function updateCurrentCursorColumn():void
		{
			if (currentCursorPositionKey.search(GC.INVENTORY_KEY_WEAPON_ITEM) != ( -1))
			{
				currentCursorColumn = GC.INVENTORY_WEAPON_ITEM_COLUMN;
			}
			else if (currentCursorPositionKey.search(GC.INVENTORY_KEY_ARMOR_ITEM) != ( -1))
			{
				currentCursorColumn = GC.INVENTORY_ARMOR_ITEM_COLUMN;
			}
			else if (currentCursorPositionKey.search(GC.INVENTORY_KEY_CONSUMABLE_ITEM) != ( -1))
			{
				currentCursorColumn = GC.INVENTORY_CONSUMABLE_ITEM_COLUMN;
			}
			else if (currentCursorPositionKey.search(GC.INVENTORY_KEY_ARMOR_EQUIP) != ( -1))
			{
				currentCursorColumn = GC.INVENTORY_ARMOR_EQUIP_COLUMN;
			}
			else if (currentCursorPositionKey.search(GC.INVENTORY_KEY_WEAPON_EQUIP) != ( -1))
			{
				currentCursorColumn = GC.INVENTORY_WEAPON_EQUIP_COLUMN;
			}
		}
		
		public function resetItemHighlights():void
		{
			for (var i:int = 0; i < GC.INVENTORY_MAX_ITEM_COLUMNS; i++)
			{
				for (var j:int = 0; j < GC.INVENTORY_MAX_ITEM_ROWS; j++)
				{
					itemColumns[i][j].displayText.color = 0xFFFFFF;
				}
			}
		}
		
		public function highlightValidEquipment():void
		{
			for (var i:int = 0; i < itemColumns[currentCursorColumn].length; i++)
			{
				if (player.items[currentCursorColumn].length == i) break;
				
				if (currentCursorColumn == GC.INVENTORY_ARMOR_ITEM_COLUMN)
				{
					var armor:Armor = player.items[currentCursorColumn][itemsStartIndex[currentCursorColumn] + i].item[GC.ITEM_ARMOR];
					switch (currentEquipmentKey)
					{
						case GC.INVENTORY_KEY_ARMOR_EQUIP_HEAD: 
						{
							if (armor.armorType != GC.ARMOR_TYPE_HEAD|| armor.equipped)
							{
								itemColumns[currentCursorColumn][i].displayText.color = 0x888888;
							}
							else
							{
								itemColumns[currentCursorColumn][i].displayText.color = 0xFFFFFF;
							}
							break;
						}
						case GC.INVENTORY_KEY_ARMOR_EQUIP_TORSO: 
						{
							if (armor.armorType != GC.ARMOR_TYPE_TORSO || armor.equipped)
							{
								itemColumns[currentCursorColumn][i].displayText.color = 0x888888;
							}
							else
							{
								itemColumns[currentCursorColumn][i].displayText.color = 0xFFFFFF;
							}
							break;
						}
						case GC.INVENTORY_KEY_ARMOR_EQUIP_LEGS: 
						{
							if (armor.armorType != GC.ARMOR_TYPE_LEGS || armor.equipped)
							{
								itemColumns[currentCursorColumn][i].displayText.color = 0x888888;
							}
							else
							{
								itemColumns[currentCursorColumn][i].displayText.color = 0xFFFFFF;
							}
							break;
						}
						case GC.INVENTORY_KEY_ARMOR_EQUIP_HANDS: 
						{
							if (armor.armorType != GC.ARMOR_TYPE_HANDS || armor.equipped)
							{
								itemColumns[currentCursorColumn][i].displayText.color = 0x888888;
							}
							else
							{
								itemColumns[currentCursorColumn][i].displayText.color = 0xFFFFFF;
							}
							break;
						}
						case GC.INVENTORY_KEY_ARMOR_EQUIP_FEET: 
						{
							if (armor.armorType != GC.ARMOR_TYPE_FEET || armor.equipped)
							{
								itemColumns[currentCursorColumn][i].displayText.color = 0x888888;
							}
							else
							{
								itemColumns[currentCursorColumn][i].displayText.color = 0xFFFFFF;
							}
							break;
						}
					}
				}
				else if (currentCursorColumn == GC.INVENTORY_WEAPON_ITEM_COLUMN)
				{
					var inventoryItem:InventoryItem = player.items[currentCursorColumn][itemsStartIndex[currentCursorColumn] + i];
					switch (currentEquipmentKey)
					{
						case GC.INVENTORY_KEY_WEAPON_EQUIP_PRIMARY:
						{
							if (inventoryItem.item[GC.ITEM_WEAPON].equipped && 
								inventoryItem.quantity < 2)
							{
								itemColumns[currentCursorColumn][i].displayText.color = 0x888888;
							}
							else
							{
								itemColumns[currentCursorColumn][i].displayText.color = 0xFFFFFF;
							}
							break;
						}
						case GC.INVENTORY_KEY_WEAPON_EQUIP_SECONDARY: 
						{
							// If there is a primary weapon and it's two handed
							if (player.equipment[GC.INVENTORY_KEY_WEAPON_EQUIP_PRIMARY] != null &&
								player.equipment[GC.INVENTORY_KEY_WEAPON_EQUIP_PRIMARY].twoHanded)
							{
								itemColumns[currentCursorColumn][i].displayText.color = 0x888888;
							}
							else if (inventoryItem.item[GC.ITEM_WEAPON].twoHanded || 
									 (inventoryItem.item[GC.ITEM_WEAPON].equipped && inventoryItem.quantity < 2)) 
							{
								// grey out if two handed weapon or if its equipped and no other left
								itemColumns[currentCursorColumn][i].displayText.color = 0x888888;
							}
							else
							{
								itemColumns[currentCursorColumn][i].displayText.color = 0xFFFFFF;
							}
							break;
						}
					}
				}
			}
		}
		
		public function enterNormalMode():void
		{
			currentMode = GC.INVENTORY_NORMAL_MODE;
			cursorEquip.visible = false;
			cursor.position = cursorPositions[currentEquipmentKey].getPosition();
			currentCursorPositionKey = currentEquipmentKey;
			currentEquipmentKey = "";
			updateCurrentCursorColumn();
			resetItemHighlights();
		}
		
		public function cancelPress():void
		{
			if (currentMode == GC.INVENTORY_NORMAL_MODE)
			{
				if (currentCursorColumn == GC.INVENTORY_ARMOR_EQUIP_COLUMN ||
					currentCursorColumn == GC.INVENTORY_WEAPON_EQUIP_COLUMN)
				{
					if (player.equipment[currentCursorPositionKey] != null)
					{
						player.equipment[currentCursorPositionKey].equipped = false;
						player.equipment[currentCursorPositionKey] = null;
						
						populateEquipmentColumns();
					}
				}
			}
			else if (currentMode == GC.INVENTORY_EQUIP_MODE)
			{
				enterNormalMode();
			}
		}
		
		public function actionPress():void
		{
			if (currentMode == GC.INVENTORY_NORMAL_MODE)
			{
				if (currentCursorColumn == GC.INVENTORY_CONSUMABLE_ITEM_COLUMN)
				{
					// find the consumable in the items array
					var consumableIndex:int = int(currentCursorPositionKey.charAt(currentCursorPositionKey.length - 1)) - 1;
					consumableIndex += itemsStartIndex[currentCursorColumn];
					
					// alter the player stats
					// need to copy the instance or else the consume function is only given a reference
					var consumable:Consumable = new Consumable();
					consumable.copy(player.items[GC.ITEM_CONSUMABLE][consumableIndex].item[GC.ITEM_CONSUMABLE]);
					player.consume(consumable);
					
					// decrease quantity of the consumable
					player.items[GC.ITEM_CONSUMABLE][consumableIndex].quantity--;
					
					if (player.items[GC.ITEM_CONSUMABLE][consumableIndex].quantity < 1)
					{
						// remove the consumable from the player inventory
						player.items[GC.ITEM_CONSUMABLE].splice(consumableIndex, 1);
						
						if (player.items[GC.ITEM_CONSUMABLE].length < GC.INVENTORY_MAX_ITEM_ROWS)
						{
							var removedConsumableKey:String = GC.INVENTORY_KEY_CONSUMABLE_ITEM + (player.items[GC.ITEM_CONSUMABLE].length + 1);
							cursorPositions[removedConsumableKey].valid = false;
							itemsEndIndex[GC.INVENTORY_CONSUMABLE_ITEM_COLUMN]--;
							
							if (player.items[GC.ITEM_CONSUMABLE].length > 0)
							{
								if (currentCursorPositionKey == removedConsumableKey)
								{
									currentCursorPositionKey = GC.INVENTORY_KEY_CONSUMABLE_ITEM + player.items[GC.ITEM_CONSUMABLE].length;
									cursor.position = cursorPositions[currentCursorPositionKey].getPosition();
									updateCurrentCursorColumn();
								}
							}
							else 
							{
								cursor.position = cursorPositions[GC.INVENTORY_KEY_ARMOR_EQUIP_HEAD].getPosition();
								currentCursorPositionKey = GC.INVENTORY_KEY_ARMOR_EQUIP_HEAD;
								currentCursorColumn = GC.INVENTORY_ARMOR_EQUIP_COLUMN;
								updateCurrentCursorColumn();
							}
						}
					}
					updateItemColumn(GC.ITEM_CONSUMABLE);
					displayItemInformation();
				}
				else if (currentCursorColumn == GC.INVENTORY_WEAPON_EQUIP_COLUMN ||
						 currentCursorColumn == GC.INVENTORY_ARMOR_EQUIP_COLUMN)
				{
					var targetColumn:int;
					var targetKey:String;
					
					if (currentCursorColumn == GC.INVENTORY_ARMOR_EQUIP_COLUMN) 
					{
						targetKey = GC.INVENTORY_KEY_ARMOR_ITEM + "1";
						targetColumn = GC.INVENTORY_ARMOR_ITEM_COLUMN;
					}
					else if (currentCursorColumn == GC.INVENTORY_WEAPON_EQUIP_COLUMN) 
					{
						targetKey = GC.INVENTORY_KEY_WEAPON_ITEM + "1";
						targetColumn = GC.INVENTORY_WEAPON_ITEM_COLUMN;
					}
					
 					// if there are no armor items, don't move the cursor
					// and change modes
					if (player.items[targetColumn].length == 0)
					{
						return;
					}
					
					// move the cursor to the appropriate column's first position
					// set the cursorEquip at the current position
					cursorEquip.visible = true;
					cursorEquip.position = cursorPositions[currentCursorPositionKey].getPosition();
					
					cursor.position = cursorPositions[targetKey].getPosition();
					currentEquipmentKey = currentCursorPositionKey;
					currentCursorPositionKey = targetKey;
					updateCurrentCursorColumn();
					currentMode = GC.INVENTORY_EQUIP_MODE;
					highlightValidEquipment();
				}
			}
			else if (currentMode == GC.INVENTORY_EQUIP_MODE)
			{
				// get the Weapon or Armor instance of the currently 
				// selected (cursored) item entry2/18/2011 8:02 PM
				var index:int = int(currentCursorPositionKey.charAt(currentCursorPositionKey.length - 1)) - 1;
				index += itemsStartIndex[currentCursorColumn];
				
				var validSelection:Boolean = false;
				var itemType:int;
				
				if (currentCursorColumn == GC.INVENTORY_ARMOR_ITEM_COLUMN)
				{
					var armorType:int;
					switch (currentEquipmentKey)
					{
						case (GC.INVENTORY_KEY_ARMOR_EQUIP_HEAD): armorType = GC.ARMOR_TYPE_HEAD; break;
						case (GC.INVENTORY_KEY_ARMOR_EQUIP_TORSO): armorType = GC.ARMOR_TYPE_TORSO; break;
						case (GC.INVENTORY_KEY_ARMOR_EQUIP_LEGS): armorType = GC.ARMOR_TYPE_LEGS; break;
						case (GC.INVENTORY_KEY_ARMOR_EQUIP_HANDS): armorType = GC.ARMOR_TYPE_HANDS; break;
						case (GC.INVENTORY_KEY_ARMOR_EQUIP_FEET): armorType = GC.ARMOR_TYPE_FEET; break;
					}
					
					if ((player.items[currentCursorColumn][index].item[GC.ITEM_ARMOR].armorType == armorType) &&
						(!player.items[currentCursorColumn][index].item[GC.ITEM_ARMOR].equipped))
					{
						validSelection = true;
						itemType = GC.ITEM_ARMOR;
					}
				}
				else if (currentEquipmentKey == GC.INVENTORY_KEY_WEAPON_EQUIP_PRIMARY)
				{
					if (player.items[currentCursorColumn][index].item[GC.ITEM_WEAPON].twoHanded)
					{
						if (player.equipment[GC.INVENTORY_KEY_WEAPON_EQUIP_SECONDARY] != null)
						{
							player.equipment[GC.INVENTORY_KEY_WEAPON_EQUIP_SECONDARY].equipped = false;
							player.equipment[GC.INVENTORY_KEY_WEAPON_EQUIP_SECONDARY] = null;
						}	
					}
					validSelection = true;
					itemType = GC.ITEM_WEAPON;
				}
				else if (currentEquipmentKey == GC.INVENTORY_KEY_WEAPON_EQUIP_SECONDARY)
				{
					if (!player.items[currentCursorColumn][index].item[GC.ITEM_WEAPON].twoHanded)
					{
						if ((player.equipment[GC.INVENTORY_KEY_WEAPON_EQUIP_PRIMARY] == null) ||
							(!player.equipment[GC.INVENTORY_KEY_WEAPON_EQUIP_PRIMARY].twoHanded))
						{
							if (!player.items[currentCursorColumn][index].item[GC.ITEM_WEAPON].equipped)
							{
								validSelection = true;
								itemType = GC.ITEM_WEAPON;
							}
							else if ((player.items[currentCursorColumn][index].item[GC.ITEM_WEAPON].equipped) &&
									 (player.items[currentCursorColumn][index].quantity > 1))
							{
								validSelection = true;
								itemType = GC.ITEM_WEAPON;
							}
						}
					}
				}
				
				if (validSelection)
				{
					// Unequip any possibly equipped item in the current slot
					if (player.equipment[currentEquipmentKey] != null)
					{
						player.equipment[currentEquipmentKey].equipped = false;
					}
					
					player.equipment[currentEquipmentKey] = player.items[currentCursorColumn][index].item[itemType];
					player.items[currentCursorColumn][index].item[itemType].equipped = true;
					
					populateEquipmentColumns();
					enterNormalMode();
				}
			}
		}
		
		public function cursorMovement(_direction:String):void
		{
			var newCursorPositionKey:String;
			var moveCursor:Boolean;
			
			if (currentMode == GC.INVENTORY_NORMAL_MODE)
			{
				switch(_direction)
				{
					case GC.BUTTON_UP: newCursorPositionKey = cursorPositions[currentCursorPositionKey].upKey; break;
					case GC.BUTTON_DOWN: newCursorPositionKey = cursorPositions[currentCursorPositionKey].downKey; break;
					case GC.BUTTON_LEFT: newCursorPositionKey = cursorPositions[currentCursorPositionKey].leftKey; break;
					case GC.BUTTON_RIGHT: newCursorPositionKey = cursorPositions[currentCursorPositionKey].rightKey; break;
				}
				if (newCursorPositionKey != null)
				{
					// There is a valid CursorPosition where the direction is pointing at
					// Need to check first if instead of moving the cursor, a list must be scrolled
					moveCursor = true;
					
					if (currentCursorColumn < GC.INVENTORY_ARMOR_EQUIP_COLUMN)
					{
						// Special checks for item columns in case cursor is in one of them
						// Check if the cursor is in the first row while trying to move up
						if (_direction == GC.BUTTON_UP)
						{
							if (currentCursorPositionKey.charAt(currentCursorPositionKey.length - 1) == "1")
							{
								// The cursor is in the first row of an item column 
								// We need to check if the list must be scrolled or if the
								// cursor can be moved to the neighboring cursor position above
								if (itemsStartIndex[currentCursorColumn] > 0)
								{
									// Scroll the list of the current column and set the move flag to false
									itemsStartIndex[currentCursorColumn]--;
									itemsEndIndex[currentCursorColumn]--;
									updateItemColumn(currentCursorColumn);
									moveCursor = false;
								}
							}
						}
					}
					
					// Check if the cursor is good to move
					if (moveCursor) 
					{
						if (cursorPositions[newCursorPositionKey].valid)
						{
							// The cursor is set to move, the target cursor position is valid
							currentCursorPositionKey = newCursorPositionKey;
							cursor.position = cursorPositions[newCursorPositionKey].getPosition();
							
							updateCurrentCursorColumn();
						}
					}
				}
				else
				{
					// Cursor in one of the item lists?
					if (currentCursorColumn < GC.INVENTORY_ARMOR_EQUIP_COLUMN)
					{
						// Check whether trying to move down
						if (_direction == GC.BUTTON_DOWN)
						{
							/// Check if the cursor is in the last row 
							if (currentCursorPositionKey.charAt(currentCursorPositionKey.length - 1) == String(GC.INVENTORY_MAX_ITEM_ROWS))
							{
								// The cursor is in the last row of an item column, and trying to move down
								// We need to check if the list must be scrolled
								if (player.items[currentCursorColumn].length > itemsEndIndex[currentCursorColumn])
								{
									itemsStartIndex[currentCursorColumn]++;
									itemsEndIndex[currentCursorColumn]++;
									updateItemColumn(currentCursorColumn);
								}
							}
						}
					}
				}
			}
			else if (currentMode == GC.INVENTORY_EQUIP_MODE)
			{
				switch(_direction)
				{
					case GC.BUTTON_UP: newCursorPositionKey = cursorPositions[currentCursorPositionKey].upKey; break;
					case GC.BUTTON_DOWN: newCursorPositionKey = cursorPositions[currentCursorPositionKey].downKey; break;
				}
				
				if (newCursorPositionKey != null)
				{
					// There is a valid CursorPosition where we direction is pointing at
					// Need to check first if instead of moving the cursor, a list must be scrolled
					moveCursor = true;
					
					if (_direction == GC.BUTTON_UP)
					{
						if (currentCursorPositionKey.charAt(currentCursorPositionKey.length - 1) == "1")
						{
							// In any case, cursor is not going to leave the item column
							moveCursor = false;
							
							// At the first row of one of the item columns and trying to move up
							// Check if list can be scrolled any further, if not, don't do anything
							if (itemsStartIndex[currentCursorColumn] > 0)
							{
								itemsStartIndex[currentCursorColumn]--;
								itemsEndIndex[currentCursorColumn]--;
								updateItemColumn(currentCursorColumn);
								highlightValidEquipment();
							}
						}
					}
					
					// Check if cursor is good to move
					if (moveCursor) 
					{
						if (cursorPositions[newCursorPositionKey].valid)
						{
							currentCursorPositionKey = newCursorPositionKey;
							cursor.position = cursorPositions[newCursorPositionKey].getPosition();
							
							updateCurrentCursorColumn();
						}
					}
				}
				else 
				{
					if (_direction == GC.BUTTON_DOWN)
					{
						if (currentCursorPositionKey.charAt(currentCursorPositionKey.length - 1) == String(GC.INVENTORY_MAX_ITEM_ROWS))
						{
							// At the last row of on of the item columns and trying to move down
							// Check if list can be scrolled any further, if not, don't do anything
							if (player.items[currentCursorColumn].length > itemsEndIndex[currentCursorColumn])
							{
								itemsStartIndex[currentCursorColumn]++;
								itemsEndIndex[currentCursorColumn]++;
								updateItemColumn(currentCursorColumn);
								highlightValidEquipment();
							}
						}
					}
				}
			}
			
			// function that lets the information of the item that is cursored currently
			// appear in the information area
			displayItemInformation();
		}
		
		public function displayItemInformation():void
		{
			resetInfoDisplayTexts();
			
			var i:int = 0;
			var itemName:String;
			var itemType:int;
			
			if (currentCursorColumn == GC.INVENTORY_ARMOR_EQUIP_COLUMN)
			{
				if (player.equipment[currentCursorPositionKey] != null)
				{
					itemName = player.equipment[currentCursorPositionKey].name;
					itemType = GC.ITEM_ARMOR;
				}
			}
			else if (currentCursorColumn == GC.INVENTORY_WEAPON_EQUIP_COLUMN)
			{
				if (player.equipment[currentCursorPositionKey] != null)
				{
					itemName = player.equipment[currentCursorPositionKey].name;
					itemType = GC.ITEM_WEAPON;
				}
			}
			else if (currentCursorColumn == GC.INVENTORY_WEAPON_ITEM_COLUMN)
			{
				i = int(currentCursorPositionKey.charAt(currentCursorPositionKey.length - 1));
				itemName = itemColumns[GC.INVENTORY_WEAPON_ITEM_COLUMN][i - 1].displayText.text;
				itemType = GC.ITEM_WEAPON;
			}
			else if (currentCursorColumn == GC.INVENTORY_ARMOR_ITEM_COLUMN)
			{
				i = int(currentCursorPositionKey.charAt(currentCursorPositionKey.length - 1));
				itemName = itemColumns[GC.INVENTORY_ARMOR_ITEM_COLUMN][i - 1].displayText.text;
				itemType = GC.ITEM_ARMOR;
			}
			else if (currentCursorColumn == GC.INVENTORY_CONSUMABLE_ITEM_COLUMN)
			{
				i = int(currentCursorPositionKey.charAt(currentCursorPositionKey.length - 1));
				itemName = itemColumns[GC.INVENTORY_CONSUMABLE_ITEM_COLUMN][i - 1].displayText.text;
				itemType = GC.ITEM_CONSUMABLE;
			}
			
			// find the item object using its name
			for (i = 0; i < GC.INVENTORY_MAX_ITEM_COLUMNS; i++)
			{
				for each (var item:InventoryItem in player.items[i])
				{
					if (item.item[i].name == itemName)
					{
						setInfoDisplayTexts(item, i);
						return;
					}
				}
			}
		}
		
		public function setInfoDisplayTexts(_item:InventoryItem, _type:int):void
		{
			if (_type == GC.ITEM_WEAPON)
			{
				displayTexts[GC.INVENTORY_INFO_DISPLAY_TEXT_ONE].displayText.text = GC.NAME_STRING + ": " + _item.item[_type].name;
				displayTexts[GC.INVENTORY_INFO_DISPLAY_TEXT_TWO].displayText.text = GC.DAMAGE_TYPE_STRING + ": " + Weapon.getDamageType(_item.item[_type].damageType);
				displayTexts[GC.INVENTORY_INFO_DISPLAY_TEXT_THREE].displayText.text = GC.DAMAGE_STRING + ": " + _item.item[_type].damageRating;
				displayTexts[GC.INVENTORY_INFO_DISPLAY_TEXT_FOUR].displayText.text = GC.QUANTITY_STRING + ": " + _item.quantity;
				displayTexts[GC.INVENTORY_INFO_DISPLAY_TEXT_FIVE].displayText.text = GC.ATTACK_TYPE_STRING + ": " + Weapon.getAttackType(_item.item[_type].attackType);
				
				if (_item.item[_type].twoHanded)
					displayTexts[GC.INVENTORY_INFO_DISPLAY_TEXT_SIX].displayText.text = GC.WEAPON_TWO_HANDED_STRING;
				else
					displayTexts[GC.INVENTORY_INFO_DISPLAY_TEXT_SIX].displayText.text = GC.WEAPON_ONE_HANDED_STRING;
			}
			else if (_type == GC.ITEM_ARMOR)
			{
				displayTexts[GC.INVENTORY_INFO_DISPLAY_TEXT_ONE].displayText.text = GC.NAME_STRING + ": " + _item.item[_type].name;
				displayTexts[GC.INVENTORY_INFO_DISPLAY_TEXT_TWO].displayText.text = GC.BODY_PART_STRING + ": " + Armor.getArmorType(_item.item[_type].armorType);
				displayTexts[GC.INVENTORY_INFO_DISPLAY_TEXT_THREE].displayText.text = GC.ARMOR_STRING + ": " + _item.item[_type].armorRating;
				displayTexts[GC.INVENTORY_INFO_DISPLAY_TEXT_FOUR].displayText.text = GC.QUANTITY_STRING + ": " + _item.quantity;
				displayTexts[GC.INVENTORY_INFO_DISPLAY_TEXT_FIVE].displayText.text = GC.DAMAGE_TYPE_SLASHING_STRING + " " + GC.RESISTANCE_STRING + ": " + _item.item[_type].resistances[GC.DAMAGE_TYPE_SLASHING];
				displayTexts[GC.INVENTORY_INFO_DISPLAY_TEXT_SIX].displayText.text = GC.DAMAGE_TYPE_PIERCING_STRING + " " + GC.RESISTANCE_STRING + ": " + _item.item[_type].resistances[GC.DAMAGE_TYPE_PIERCING];
				displayTexts[GC.INVENTORY_INFO_DISPLAY_TEXT_SEVEN].displayText.text = GC.DAMAGE_TYPE_IMPACT_STRING + " " + GC.RESISTANCE_STRING + ": " + _item.item[_type].resistances[GC.DAMAGE_TYPE_IMPACT];
				displayTexts[GC.INVENTORY_INFO_DISPLAY_TEXT_EIGHT].displayText.text = GC.DAMAGE_TYPE_MAGIC_STRING + " " + GC.RESISTANCE_STRING + ": " + _item.item[_type].resistances[GC.DAMAGE_TYPE_MAGIC];
			}
			else if (_type == GC.ITEM_CONSUMABLE)
			{
				displayTexts[GC.INVENTORY_INFO_DISPLAY_TEXT_ONE].displayText.text = GC.NAME_STRING + ": " + _item.item[_type].name;
				displayTexts[GC.INVENTORY_INFO_DISPLAY_TEXT_TWO].displayText.text = GC.EFFECT_STRING + ": " + _item.item[_type].description;
				displayTexts[GC.INVENTORY_INFO_DISPLAY_TEXT_THREE].displayText.text = GC.QUANTITY_STRING + ": " + _item.quantity;
			}
		}
		
		public function initUIDatastructures(_uiDatastructures:Array):void
		{
			cursorPositions = _uiDatastructures[0];
			columnKeys = _uiDatastructures[1];
			displayTexts = _uiDatastructures[2];
		}
		
		public function get visible():Boolean
		{
			return visibility;
		}
		
		public function set visible(_visible:Boolean):void
		{
			visibility = _visible;
			background.visible = _visible;
			cursor.visible = _visible;
			for each (var d:DisplayText in displayTexts)
			{
				d.visible = _visible;
			}
			
			if (!_visible) cursorEquip.visible = _visible;
		}
	}

}
