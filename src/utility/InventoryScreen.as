package utility 
{
	import entities.Cursor;
	import entities.CursorEquip;
	import entities.DisplayText;
	import entities.Player;
	import entities.TextBox;
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
		public var items:Array = new Array();
		public var equipment:Dictionary = new Dictionary();
		
		public var itemColumns:Array = new Array();
		public var itemsStartIndex:Array = new Array();
		public var itemsEndIndex:Array = new Array();
		
		public var currentMode:int = GC.INVENTORY_NORMAL_MODE;
		private var visibility:Boolean = false;
		private var maxRows:int = GC.INVENTORY_MAX_ITEM_ROWS;
		
		public var currentCursorPositionKey:String = GC.INVENTORY_KEY_ARMOR_EQUIP_HEAD;
		public var currentCursorColumn:int = GC.INVENTORY_ARMOR_EQUIP_COLUMN;
		public var cursorPositions:Dictionary = new Dictionary();
		public var cursorPositionsNodes:Dictionary = new Dictionary();
		public var cursorPositionsValidity:Dictionary = new Dictionary();
		public var columnKeys:Array = new Array();
		
		public var currentEquipmentKey:String;
		
		public function InventoryScreen(_uiDatastructures:Array) 
		{
			initUIDatastructures(_uiDatastructures);
			initItemColumnDisplayTexts();
			
			for each (var c:Array in itemColumns)
			{
				for each (var d:DisplayText in c)
				{
					displayTexts.push(d);
				}
			}
			
			background = new TextBox(GC.INVENTORY_OFFSET_X, GC.INVENTORY_OFFSET_Y, GC.INVENTORY_SCALE_X, GC.INVENTORY_SCALE_Y);
			cursor = new Cursor(0, 0);
			cursorEquip = new CursorEquip(0, 0);
			cursorEquip.visible = false;
		}
		
		public function initialize(_player:Player):void
		{
			player = _player;
			items = _player.items;
			equipment = _player.equipment;
			
			currentMode = GC.INVENTORY_NORMAL_MODE;
			currentCursorPositionKey = GC.INVENTORY_KEY_ARMOR_EQUIP_HEAD;
			currentCursorColumn = GC.INVENTORY_ARMOR_EQUIP_COLUMN;
			currentEquipmentKey = "";
			
			populateEquipmentColumns();
			populateItemColumns();
		}
		
		public function populateEquipmentColumns():void
		{
			if (equipment[GC.INVENTORY_KEY_ARMOR_EQUIP_HEAD] != null) displayTexts[GC.INVENTORY_ARMOR_EQUIP_HEAD_DISPLAY_TEXT].displayText.text = GC.BODY_PART_HEAD_STRING + ": " + equipment["ArmorEquipHead"].name;
			else displayTexts[GC.INVENTORY_ARMOR_EQUIP_HEAD_DISPLAY_TEXT].displayText.text = GC.BODY_PART_HEAD_STRING + ": ";
			
			if (equipment[GC.INVENTORY_KEY_ARMOR_EQUIP_TORSO] != null) displayTexts[GC.INVENTORY_ARMOR_EQUIP_TORSO_DISPLAY_TEXT].displayText.text = GC.BODY_PART_TORSO_STRING + ": " + equipment["ArmorEquipTorso"].name;
			else displayTexts[GC.INVENTORY_ARMOR_EQUIP_TORSO_DISPLAY_TEXT].displayText.text = GC.BODY_PART_TORSO_STRING + ": ";
			
			if (equipment[GC.INVENTORY_KEY_ARMOR_EQUIP_LEGS] != null) displayTexts[GC.INVENTORY_ARMOR_EQUIP_LEGS_DISPLAY_TEXT].displayText.text = GC.BODY_PART_LEGS_STRING + ": " + equipment["ArmorEquipLegs"].name;
			else displayTexts[GC.INVENTORY_ARMOR_EQUIP_LEGS_DISPLAY_TEXT].displayText.text = GC.BODY_PART_LEGS_STRING + ": ";
			
			if (equipment[GC.INVENTORY_KEY_ARMOR_EQUIP_HANDS] != null) displayTexts[GC.INVENTORY_ARMOR_EQUIP_HANDS_DISPLAY_TEXT].displayText.text = GC.BODY_PART_HANDS_STRING + ": " + equipment["ArmorEquipHands"].name;
			else displayTexts[GC.INVENTORY_ARMOR_EQUIP_HANDS_DISPLAY_TEXT].displayText.text = GC.BODY_PART_HANDS_STRING + ": ";
			
			if (equipment[GC.INVENTORY_KEY_ARMOR_EQUIP_FEET] != null) displayTexts[GC.INVENTORY_ARMOR_EQUIP_FEET_DISPLAY_TEXT].displayText.text = GC.BODY_PART_FEET_STRING + ": " + equipment["ArmorEquipFeet"].name;
			else displayTexts[GC.INVENTORY_ARMOR_EQUIP_FEET_DISPLAY_TEXT].displayText.text = GC.BODY_PART_FEET_STRING + ": ";
			
			if (equipment[GC.INVENTORY_KEY_WEAPON_EQUIP_PRIMARY] != null) displayTexts[GC.INVENTORY_WEAPON_EQUIP_PRIMARY_DISPLAY_TEXT].displayText.text = GC.PRIMARY_WEAPON_STRING + ": " + equipment["WeaponEquipPrimary"].name;
			else displayTexts[GC.INVENTORY_WEAPON_EQUIP_PRIMARY_DISPLAY_TEXT].displayText.text = GC.PRIMARY_WEAPON_STRING + ": ";
			
			if (equipment[GC.INVENTORY_KEY_WEAPON_EQUIP_SECONDARY] != null) displayTexts[GC.INVENTORY_WEAPON_EQUIP_SECONDARY_DISPLAY_TEXT].displayText.text = GC.SECONDARY_WEAPON_STRING + ": " + equipment["WeaponEquipSecondary"].name;
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
				if (items.length == i) break;
				
				// set the end index of the items[i] subset
				if (items[i].length < maxRows)
				{
					itemsEndIndex[i] = items[i].length;
				}
				else itemsEndIndex[i] = maxRows;
				
				for (j = 0; j < maxRows; j++)
				{
					if (items[i].length == j) 
					{
						break;
					}
					
					itemColumns[i][j].displayText.text = items[i][j].item[i].name;
					cursorPositionsValidity[columnKeys[i][j]] = true;
				}
			}
			cursor.position = cursorPositions[currentCursorPositionKey];
		}
		
		public function updateItemColumn(_column:int):void
		{
			var currentItemIndex:int;
			var currentInventoryItem:InventoryItem;
			var currentItemName:String;
			
			for (var i:int = 0; i < maxRows; i++)
			{
				currentItemIndex = itemsStartIndex[_column] + i;
				if (currentItemIndex < itemsEndIndex[_column])
				{
					currentInventoryItem = items[_column][currentItemIndex];
					currentItemName = currentInventoryItem.item[currentInventoryItem.type].name;
					itemColumns[_column][i].displayText.text = currentItemName;
				}
				else break;
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
			itemColumns[0] = new Array();
			itemColumns[1] = new Array();
			itemColumns[2] = new Array();
			
			for (var i:int = 0; i < maxRows; i++)
			{
				itemColumns[0].push(new DisplayText("", 100, 200 + (i * 20), "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500));
			}
			for (i = 0; i < maxRows; i++)
			{
				itemColumns[1].push(new DisplayText("", 250, 200 + (i * 20), "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500));
			}
			for (i = 0; i < maxRows; i++)
			{
				itemColumns[2].push(new DisplayText("", 400, 200 + (i * 20), "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500));
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
				if (items.length == i) break;
				
				for (var j:int = 0; j < itemColumns[i].length; j++)
				{
					if (items[i].length == j) break;
					itemColumns[i][j].displayText.color = 0xFFFFFF;
				}
			}
		}
		
		public function highlightValidEquipment():void
		{
			for (var i:int = 0; i < itemColumns[currentCursorColumn].length; i++)
			{
				if (items[currentCursorColumn].length == i) break;
				
				if (currentCursorColumn == GC.INVENTORY_ARMOR_ITEM_COLUMN)
				{
					var armor:Armor = items[currentCursorColumn][itemsStartIndex[currentCursorColumn] + i].item[GC.ITEM_ARMOR];
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
					var inventoryItem:InventoryItem = items[currentCursorColumn][itemsStartIndex[currentCursorColumn] + i];
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
							if (equipment[GC.INVENTORY_KEY_WEAPON_EQUIP_PRIMARY] != null &&
								equipment[GC.INVENTORY_KEY_WEAPON_EQUIP_PRIMARY].twoHanded)
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
		
		public function cancelPress():void
		{
			if (currentMode == GC.INVENTORY_NORMAL_MODE)
			{
				if (currentCursorColumn == GC.INVENTORY_ARMOR_EQUIP_COLUMN ||
					currentCursorColumn == GC.INVENTORY_WEAPON_EQUIP_COLUMN)
				{
					if (equipment[currentCursorPositionKey] != null)
					{
						equipment[currentCursorPositionKey].equipped = false;
						equipment[currentCursorPositionKey] = null;
						
						populateEquipmentColumns();
					}
				}
			}
			else if (currentMode == GC.INVENTORY_EQUIP_MODE)
			{
				currentMode = GC.INVENTORY_NORMAL_MODE;
				cursorEquip.visible = false;
				cursor.position = cursorPositions[currentEquipmentKey];
				currentCursorPositionKey = currentEquipmentKey;
				currentEquipmentKey = "";
				updateCurrentCursorColumn();
				resetItemHighlights();
			}
		}
		
		public function actionPress():void
		{
			if (currentMode == GC.INVENTORY_NORMAL_MODE)
			{
				if (currentCursorColumn == GC.INVENTORY_ARMOR_EQUIP_COLUMN)
				{
					// if there are no armor items, don't move the cursor
					// and change modes
					if (items[GC.INVENTORY_ARMOR_ITEM_COLUMN].length == 0)
					{
						return;
					}
					
					// move the cursor to the appropriate column's first position
					// set the cursorEquip at the current position
					cursorEquip.visible = true;
					cursorEquip.position = cursorPositions[currentCursorPositionKey];
					
					cursor.position = cursorPositions[GC.INVENTORY_KEY_ARMOR_ITEM + "1"];
					currentEquipmentKey = currentCursorPositionKey;
					currentCursorPositionKey = GC.INVENTORY_KEY_ARMOR_ITEM + "1";
					updateCurrentCursorColumn();
					currentMode = GC.INVENTORY_EQUIP_MODE;
					highlightValidEquipment();
				}
				else if (currentCursorColumn == GC.INVENTORY_WEAPON_EQUIP_COLUMN)
				{
					// if there are no weapon items, don't move the cursor
					// and change modes
					if (items[GC.INVENTORY_WEAPON_ITEM_COLUMN].length == 0)
					{
						return;
					}
					
					// move the cursor to the appropriate column's first position
					// set the cursorEquip at the current position
					cursorEquip.visible = true;
					cursorEquip.position = cursorPositions[currentCursorPositionKey];
					
					cursor.position = cursorPositions[GC.INVENTORY_KEY_WEAPON_ITEM + "1"];
					currentEquipmentKey = currentCursorPositionKey;
					currentCursorPositionKey = GC.INVENTORY_KEY_WEAPON_ITEM + "1";
					updateCurrentCursorColumn();
					currentMode = GC.INVENTORY_EQUIP_MODE;
					highlightValidEquipment();
				}
				else if (currentCursorColumn == GC.INVENTORY_CONSUMABLE_ITEM_COLUMN)
				{
					// find the consumable in the items array
					var consumableIndex:int = int(currentCursorPositionKey.charAt(currentCursorPositionKey.length - 1)) - 1;
					consumableIndex += itemsStartIndex[currentCursorColumn];
					
					// alter the player stats
					// need to copy the instance or else the consume function is only given a reference
					var consumable:Consumable = new Consumable();
					consumable.copy(items[GC.ITEM_CONSUMABLE][consumableIndex].item[GC.ITEM_CONSUMABLE]);
					player.consume(consumable);
					
					// decrease quantity of the consumable. if it's now at 0, delete the inventoryItem
					// from the items array and update the itemsColumn
					items[GC.ITEM_CONSUMABLE][consumableIndex].quantity--;
					
					if (items[GC.ITEM_CONSUMABLE][consumableIndex].quantity < 1)
					{
						items[GC.ITEM_CONSUMABLE].splice(consumableIndex, 1);
						populateItemColumns();
						
						if (items[GC.ITEM_CONSUMABLE].length < maxRows)
						{
							cursorPositionsValidity[GC.INVENTORY_KEY_CONSUMABLE_ITEM + (items[GC.ITEM_CONSUMABLE].length + 1)] = false;
							itemsEndIndex[GC.INVENTORY_CONSUMABLE_ITEM_COLUMN]--;
							
							if (items[GC.ITEM_CONSUMABLE].length > 0)
							{
								cursor.position = cursorPositions[GC.INVENTORY_KEY_CONSUMABLE_ITEM + items[GC.ITEM_CONSUMABLE].length];
								currentCursorPositionKey = GC.INVENTORY_KEY_CONSUMABLE_ITEM + items[GC.ITEM_CONSUMABLE].length;
							}
							else 
							{
								cursor.position = cursorPositions[GC.INVENTORY_KEY_ARMOR_EQUIP_HEAD];
								currentCursorPositionKey = GC.INVENTORY_KEY_ARMOR_EQUIP_HEAD;
								currentCursorColumn = GC.INVENTORY_ARMOR_EQUIP_COLUMN;
							}
						}
					}
					displayItemInformation();
				}
			}
			else if (currentMode == GC.INVENTORY_EQUIP_MODE)
			{
				// get the Weapon or Armor instance of the currently 
				// selected (cursored) item entry
				var index:int = int(currentCursorPositionKey.charAt(currentCursorPositionKey.length - 1)) - 1;
				index += itemsStartIndex[currentCursorColumn];
				
				var validSelection:Boolean = false;
				var itemType:int;
				
				switch (currentEquipmentKey)
				{
					case GC.INVENTORY_KEY_ARMOR_EQUIP_HEAD: 
					{
						if ((items[currentCursorColumn][index].item[GC.ITEM_ARMOR].armorType == GC.ARMOR_TYPE_HEAD) &&
							(!items[currentCursorColumn][index].item[GC.ITEM_ARMOR].equipped))
						{
							validSelection = true;
						}
						itemType = GC.ITEM_ARMOR;
						break;
					}
					case GC.INVENTORY_KEY_ARMOR_EQUIP_TORSO:
					{
						if ((items[currentCursorColumn][index].item[GC.ITEM_ARMOR].armorType == GC.ARMOR_TYPE_TORSO) &&
							(!items[currentCursorColumn][index].item[GC.ITEM_ARMOR].equipped))
						{
							validSelection = true;
						}
						itemType = GC.ITEM_ARMOR;
						break;
					}
					case GC.INVENTORY_KEY_ARMOR_EQUIP_LEGS: 
					{
						if ((items[currentCursorColumn][index].item[GC.ITEM_ARMOR].armorType == GC.ARMOR_TYPE_LEGS) &&
							(!items[currentCursorColumn][index].item[GC.ITEM_ARMOR].equipped))
						{
							validSelection = true;
						}
						itemType = GC.ITEM_ARMOR;
						break;
					}
					case GC.INVENTORY_KEY_ARMOR_EQUIP_HANDS:
					{
						if ((items[currentCursorColumn][index].item[GC.ITEM_ARMOR].armorType == GC.ARMOR_TYPE_HANDS) &&
							(!items[currentCursorColumn][index].item[GC.ITEM_ARMOR].equipped))
						{
							validSelection = true;
						}
						itemType = GC.ITEM_ARMOR;
						break;
					}
					case GC.INVENTORY_KEY_ARMOR_EQUIP_FEET:
					{
						if ((items[currentCursorColumn][index].item[GC.ITEM_ARMOR].armorType == GC.ARMOR_TYPE_FEET) &&
							(!items[currentCursorColumn][index].item[GC.ITEM_ARMOR].equipped))
						{
							validSelection = true;
						}
						itemType = GC.ITEM_ARMOR;
						break;
					}
					case GC.INVENTORY_KEY_WEAPON_EQUIP_PRIMARY:
					{
						if ((items[currentCursorColumn][index].quantity > 1 && 
							items[currentCursorColumn][index].item[GC.ITEM_WEAPON].equipped) ||
							(!items[currentCursorColumn][index].item[GC.ITEM_WEAPON].equipped))
						{
							validSelection = true;
							if (items[currentCursorColumn][index].item[GC.ITEM_WEAPON].twoHanded)
							{
								if (equipment[GC.INVENTORY_KEY_WEAPON_EQUIP_SECONDARY]!= null)
								{
									equipment[GC.INVENTORY_KEY_WEAPON_EQUIP_SECONDARY].equipped = false;
									equipment[GC.INVENTORY_KEY_WEAPON_EQUIP_SECONDARY] = null;
								}
							}
						}
						
						itemType = GC.ITEM_WEAPON;
						break;
					}
					case GC.INVENTORY_KEY_WEAPON_EQUIP_SECONDARY:
					{
						if ((items[currentCursorColumn][index].quantity > 1 && 
							items[currentCursorColumn][index].item[GC.ITEM_WEAPON].equipped) ||
							(!items[currentCursorColumn][index].item[GC.ITEM_WEAPON].equipped))
						{
							if (equipment[GC.INVENTORY_KEY_WEAPON_EQUIP_PRIMARY] != null)
							{
								if ((!equipment[GC.INVENTORY_KEY_WEAPON_EQUIP_PRIMARY].twoHanded) &&
									(!items[currentCursorColumn][index].item[GC.ITEM_WEAPON].twoHanded))
								{
									validSelection = true;
								}
							}
							else
							{
								if (!items[currentCursorColumn][index].item[GC.ITEM_WEAPON].twoHanded)
								{
									validSelection = true;
								}
							}
						}
						itemType = GC.ITEM_WEAPON;
						break;
					}
				}
				
				if (validSelection)
				{
					if (equipment[currentEquipmentKey] != null)
					{
						equipment[currentEquipmentKey].equipped = false;
					}
					
					if (itemType == GC.ITEM_WEAPON)
					{
						equipment[currentEquipmentKey] = items[currentCursorColumn][index].item[GC.ITEM_WEAPON];
						items[currentCursorColumn][index].item[GC.ITEM_WEAPON].equipped = true;
					}
					else if (itemType == GC.ITEM_ARMOR)
					{
						equipment[currentEquipmentKey] = items[currentCursorColumn][index].item[GC.ITEM_ARMOR];
						items[currentCursorColumn][index].item[GC.ITEM_ARMOR].equipped = true;
					}
					
					populateEquipmentColumns();
					
					currentMode = GC.INVENTORY_NORMAL_MODE;
					cursorEquip.visible = false;
					cursor.position = cursorPositions[currentEquipmentKey];
					currentCursorPositionKey = currentEquipmentKey;
					currentEquipmentKey = "";
					updateCurrentCursorColumn();
					resetItemHighlights();
				}
			}
		}
		
		public function cursorMovement(_direction:String):void
		{
			if (currentMode == GC.INVENTORY_NORMAL_MODE)
			{
				var newPosition:Point;
				switch(_direction)
				{
					case GC.BUTTON_UP: newPosition = cursorPositions[cursorPositionsNodes[currentCursorPositionKey].upKey]; break;
					case GC.BUTTON_DOWN: newPosition = cursorPositions[cursorPositionsNodes[currentCursorPositionKey].downKey]; break;
					case GC.BUTTON_LEFT: newPosition = cursorPositions[cursorPositionsNodes[currentCursorPositionKey].leftKey]; break;
					case GC.BUTTON_RIGHT: newPosition = cursorPositions[cursorPositionsNodes[currentCursorPositionKey].rightKey]; break;
				}
				if (newPosition != null)
				{
					var moveCursor:Boolean = true;
					if ((currentCursorPositionKey == GC.INVENTORY_KEY_WEAPON_ITEM + "1") && _direction == GC.BUTTON_UP)
					{
						// find out if there are more items beyond the current itemsEndIndex[WEAPON_COLUMN]
						if (itemsStartIndex[GC.INVENTORY_WEAPON_ITEM_COLUMN] > 0)
						{
							itemsStartIndex[GC.INVENTORY_WEAPON_ITEM_COLUMN]--;
							itemsEndIndex[GC.INVENTORY_WEAPON_ITEM_COLUMN]--;
							updateItemColumn(GC.INVENTORY_WEAPON_ITEM_COLUMN);
							moveCursor = false;
						}
					}
					else if ((currentCursorPositionKey == GC.INVENTORY_KEY_ARMOR_ITEM + "1") && _direction == GC.BUTTON_UP)
					{
						// find out if there are more items beyond the current itemsEndIndex[WEAPON_COLUMN]
						if (itemsStartIndex[GC.INVENTORY_ARMOR_ITEM_COLUMN] > 0)
						{
							itemsStartIndex[GC.INVENTORY_ARMOR_ITEM_COLUMN]--;
							itemsEndIndex[GC.INVENTORY_ARMOR_ITEM_COLUMN]--;
							updateItemColumn(GC.INVENTORY_ARMOR_ITEM_COLUMN);
							moveCursor = false;
						}
					}
					else if ((currentCursorPositionKey == GC.INVENTORY_KEY_WEAPON_ITEM + "1") && _direction == GC.BUTTON_UP)
					{
						// find out if there are more items beyond the current itemsEndIndex[WEAPON_COLUMN]
						if (itemsEndIndex[GC.INVENTORY_CONSUMABLE_ITEM_COLUMN] > 0)
						{
							itemsStartIndex[GC.INVENTORY_CONSUMABLE_ITEM_COLUMN]--;
							itemsEndIndex[GC.INVENTORY_CONSUMABLE_ITEM_COLUMN]--;
							updateItemColumn(GC.INVENTORY_CONSUMABLE_ITEM_COLUMN);
							moveCursor = false;
						}
					}
					
					// Check if there was an obstacle
					if (moveCursor) 
					{
						var newCursorPositionKey:String;
						switch(_direction)
						{
							case GC.BUTTON_UP: newCursorPositionKey = cursorPositionsNodes[currentCursorPositionKey].upKey; break;
							case GC.BUTTON_DOWN: newCursorPositionKey = cursorPositionsNodes[currentCursorPositionKey].downKey; break;
							case GC.BUTTON_LEFT: newCursorPositionKey = cursorPositionsNodes[currentCursorPositionKey].leftKey; break;
							case GC.BUTTON_RIGHT: newCursorPositionKey = cursorPositionsNodes[currentCursorPositionKey].rightKey; break;
						}
						if (cursorPositionsValidity[newCursorPositionKey])
						{
							currentCursorPositionKey = newCursorPositionKey;
							cursor.position = newPosition;
							
							updateCurrentCursorColumn();
						}
					}
				}
				else
				{
					if ((currentCursorPositionKey == GC.INVENTORY_KEY_WEAPON_ITEM + GC.INVENTORY_MAX_ITEM_ROWS) 
							&& _direction == GC.BUTTON_DOWN)
					{
						// find out if there are more items beyond the current itemsEndIndex[WEAPON_COLUMN]
						if (items[GC.INVENTORY_WEAPON_ITEM_COLUMN].length > itemsEndIndex[GC.INVENTORY_WEAPON_ITEM_COLUMN])
						{
							itemsStartIndex[GC.INVENTORY_WEAPON_ITEM_COLUMN]++;
							itemsEndIndex[GC.INVENTORY_WEAPON_ITEM_COLUMN]++;
							updateItemColumn(GC.INVENTORY_WEAPON_ITEM_COLUMN);
						}
					}
					else if ((currentCursorPositionKey == GC.INVENTORY_KEY_ARMOR_ITEM + GC.INVENTORY_MAX_ITEM_ROWS) 
								&& _direction == GC.BUTTON_DOWN)
					{
						// find out if there are more items beyond the current itemsEndIndex[WEAPON_COLUMN]
						if (items[GC.INVENTORY_ARMOR_ITEM_COLUMN].length > itemsEndIndex[GC.INVENTORY_ARMOR_ITEM_COLUMN])
						{
							itemsStartIndex[GC.INVENTORY_ARMOR_ITEM_COLUMN]++;
							itemsEndIndex[GC.INVENTORY_ARMOR_ITEM_COLUMN]++;
							updateItemColumn(GC.INVENTORY_ARMOR_ITEM_COLUMN);
						}
					}
					else if ((currentCursorPositionKey == GC.INVENTORY_KEY_CONSUMABLE_ITEM + GC.INVENTORY_MAX_ITEM_ROWS) && _direction == "down")
					{
						// find out if there are more items beyond the current itemsEndIndex[WEAPON_COLUMN]
						if (items[GC.INVENTORY_CONSUMABLE_ITEM_COLUMN].length > itemsEndIndex[GC.INVENTORY_CONSUMABLE_ITEM_COLUMN])
						{
							itemsStartIndex[GC.INVENTORY_CONSUMABLE_ITEM_COLUMN]++;
							itemsEndIndex[GC.INVENTORY_CONSUMABLE_ITEM_COLUMN]++;
							updateItemColumn(GC.INVENTORY_CONSUMABLE_ITEM_COLUMN);
						}
					}
				}
			}
			else if (currentMode == GC.INVENTORY_EQUIP_MODE)
			{
				switch(_direction)
				{
					case GC.BUTTON_UP: newPosition = cursorPositions[cursorPositionsNodes[currentCursorPositionKey].upKey]; break;
					case GC.BUTTON_DOWN: newPosition = cursorPositions[cursorPositionsNodes[currentCursorPositionKey].downKey]; break;
				}
				if (newPosition != null)
				{
					moveCursor = true;
					if ((currentCursorPositionKey == GC.INVENTORY_KEY_WEAPON_ITEM + "1") && _direction == GC.BUTTON_UP)
					{
						// find out if there are more items beyond the current itemsEndIndex[WEAPON_ITEM_COLUMN]
						if (itemsStartIndex[GC.INVENTORY_WEAPON_ITEM_COLUMN] > 0)
						{
							itemsStartIndex[GC.INVENTORY_WEAPON_ITEM_COLUMN]--;
							itemsEndIndex[GC.INVENTORY_WEAPON_ITEM_COLUMN]--;
							updateItemColumn(GC.INVENTORY_WEAPON_ITEM_COLUMN);
							highlightValidEquipment();
							moveCursor = false;
						}
						else if (itemsStartIndex[GC.INVENTORY_WEAPON_ITEM_COLUMN] == 0)
						{
							moveCursor = false;
						}
					}
					else if ((currentCursorPositionKey == GC.INVENTORY_KEY_ARMOR_ITEM + "1") && _direction == GC.BUTTON_UP)
					{
						// find out if there are more items beyond the current itemsEndIndex[ARMOR_ITEM_COLUMN]
						if (itemsStartIndex[GC.INVENTORY_ARMOR_ITEM_COLUMN] > 0)
						{
							itemsStartIndex[GC.INVENTORY_ARMOR_ITEM_COLUMN]--;
							itemsEndIndex[GC.INVENTORY_ARMOR_ITEM_COLUMN]--;
							updateItemColumn(GC.INVENTORY_ARMOR_ITEM_COLUMN);
							highlightValidEquipment();
							moveCursor = false;
						}
						else if (itemsStartIndex[GC.INVENTORY_WEAPON_ITEM_COLUMN] == 0)
						{
							moveCursor = false;
						}
					}
					else if ((currentCursorPositionKey == GC.INVENTORY_KEY_CONSUMABLE_ITEM + "1") && _direction == GC.BUTTON_UP)
					{
						// find out if there are more items beyond the current itemsEndIndex[CONSUMABLE_ITEM_COLUMN]
						if (itemsEndIndex[GC.INVENTORY_CONSUMABLE_ITEM_COLUMN] > 0)
						{
							itemsStartIndex[GC.INVENTORY_CONSUMABLE_ITEM_COLUMN]--;
							itemsEndIndex[GC.INVENTORY_CONSUMABLE_ITEM_COLUMN]--;
							updateItemColumn(GC.INVENTORY_CONSUMABLE_ITEM_COLUMN);
							highlightValidEquipment();
							moveCursor = false;
						}
						else if (itemsStartIndex[GC.INVENTORY_WEAPON_ITEM_COLUMN] == 0)
						{
							moveCursor = false;
						}
					}
					
					// Check if there was an obstacle
					if (moveCursor) 
					{
						switch(_direction)
						{
							case GC.BUTTON_UP: newCursorPositionKey = cursorPositionsNodes[currentCursorPositionKey].upKey; break;
							case GC.BUTTON_DOWN: newCursorPositionKey = cursorPositionsNodes[currentCursorPositionKey].downKey; break;
						}
						if (cursorPositionsValidity[newCursorPositionKey])
						{
							currentCursorPositionKey = newCursorPositionKey;
							cursor.position = newPosition;
							
							updateCurrentCursorColumn();
						}
					}
				}
				else
				{
					if ((currentCursorPositionKey == GC.INVENTORY_KEY_WEAPON_ITEM + GC.INVENTORY_MAX_ITEM_ROWS) 
							&& _direction == GC.BUTTON_DOWN)
					{
						// find out if there are more items beyond the current itemsEndIndex[WEAPON_COLUMN]
						if (items[GC.INVENTORY_WEAPON_ITEM_COLUMN].length > itemsEndIndex[GC.INVENTORY_WEAPON_ITEM_COLUMN])
						{
							itemsStartIndex[GC.INVENTORY_WEAPON_ITEM_COLUMN]++;
							itemsEndIndex[GC.INVENTORY_WEAPON_ITEM_COLUMN]++;
							updateItemColumn(GC.INVENTORY_WEAPON_ITEM_COLUMN);
							highlightValidEquipment();
						}
					}
					else if ((currentCursorPositionKey == GC.INVENTORY_KEY_ARMOR_ITEM + GC.INVENTORY_MAX_ITEM_ROWS) 
								&& _direction == GC.BUTTON_DOWN)
					{
						// find out if there are more items beyond the current itemsEndIndex[WEAPON_COLUMN]
						if (items[GC.INVENTORY_ARMOR_ITEM_COLUMN].length > itemsEndIndex[GC.INVENTORY_ARMOR_ITEM_COLUMN])
						{
							itemsStartIndex[GC.INVENTORY_ARMOR_ITEM_COLUMN]++;
							itemsEndIndex[GC.INVENTORY_ARMOR_ITEM_COLUMN]++;
							updateItemColumn(GC.INVENTORY_ARMOR_ITEM_COLUMN);
							highlightValidEquipment();
						}
					}
					else if ((currentCursorPositionKey == GC.INVENTORY_KEY_WEAPON_ITEM + GC.INVENTORY_MAX_ITEM_ROWS) 
							&& _direction == GC.BUTTON_DOWN)
					{
						// find out if there are more items beyond the current itemsEndIndex[WEAPON_COLUMN]
						if (items[GC.INVENTORY_CONSUMABLE_ITEM_COLUMN].length > itemsEndIndex[GC.INVENTORY_CONSUMABLE_ITEM_COLUMN])
						{
							itemsStartIndex[GC.INVENTORY_CONSUMABLE_ITEM_COLUMN]++;
							itemsEndIndex[GC.INVENTORY_CONSUMABLE_ITEM_COLUMN]++;
							updateItemColumn(GC.INVENTORY_CONSUMABLE_ITEM_COLUMN);
							highlightValidEquipment();
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
				if (equipment[currentCursorPositionKey] != null)
				{
					itemName = equipment[currentCursorPositionKey].name;
					itemType = GC.ITEM_ARMOR;
				}
			}
			else if (currentCursorColumn == GC.INVENTORY_WEAPON_EQUIP_COLUMN)
			{
				if (equipment[currentCursorPositionKey] != null)
				{
					itemName = equipment[currentCursorPositionKey].name;
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
				for each (var item:InventoryItem in items[i])
				{
					if (item.item[i].name == itemName)
					{
						setInfoDisplayTexts(item, i);
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
			cursorPositionsValidity = _uiDatastructures[1];
			cursorPositionsNodes = _uiDatastructures[2];
			columnKeys = _uiDatastructures[3];
			displayTexts = _uiDatastructures[4];
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
