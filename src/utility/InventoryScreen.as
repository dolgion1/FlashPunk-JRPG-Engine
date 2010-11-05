package utility 
{
	import entities.Cursor;
	import entities.CursorEquip;
	import entities.DisplayText;
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
		public const DEFAULT_FONT_SIZE:int = 12;
		
		public const ARMOR_EQUIP_HEAD_DISPLAY_TEXT:int = 3;
		public const ARMOR_EQUIP_TORSO_DISPLAY_TEXT:int = 4;
		public const ARMOR_EQUIP_LEGS_DISPLAY_TEXT:int = 5;
		public const ARMOR_EQUIP_HANDS_DISPLAY_TEXT:int = 6;
		public const ARMOR_EQUIP_FEET_DISPLAY_TEXT:int = 7;
		public const WEAPON_EQUIP_PRIMARY_DISPLAY_TEXT:int = 8;
		public const WEAPON_EQUIP_SECONDARY_DISPLAY_TEXT:int = 9;
		
		public const WEAPON_ITEM_COLUMN:int = 0;
		public const ARMOR_ITEM_COLUMN:int = 1;
		public const CONSUMABLE_ITEM_COLUMN:int = 2;
		public const ARMOR_EQUIP_COLUMN:int = 3;
		public const WEAPON_EQUIP_COLUMN:int = 4;
		
		public const NORMAL_MODE:int = 0;
		public const EQUIP_MODE:int = 1;
		
		public var cursor:Cursor;
		public var cursorEquip:CursorEquip;
		public var background:TextBox;
		public var displayTexts:Array = new Array();
		public var equipmentHeader:DisplayText;
		public var itemsHeader:DisplayText;
		public var detailsHeader:DisplayText;
		
		public var items:Array = new Array();
		public var equipment:Dictionary = new Dictionary();
		
		public var itemColumns:Array = new Array();
		public var itemsStartIndex:Array = new Array();
		public var itemsEndIndex:Array = new Array();
		
		public var currentMode:int = NORMAL_MODE;
		private var visibility:Boolean = false;
		private var maxRows:int = 6;
		
		public var currentCursorPositionKey:String = "ArmorEquipHead";
		public var currentCursorColumn:int = ARMOR_EQUIP_COLUMN;
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
			
			background = new TextBox(10, 10, 3, 4.5);
			cursor = new Cursor(0, 0);
			cursorEquip = new CursorEquip(0, 0);
			cursorEquip.visible = false;
		}
		
		public function initialize(_items:Array, _equipment:Dictionary):void
		{
			FP.log("debug message");
			items = _items;
			equipment = _equipment;
			
			currentMode = NORMAL_MODE;
			currentCursorPositionKey = "ArmorEquipHead";
			currentCursorColumn = ARMOR_EQUIP_COLUMN;
			currentEquipmentKey = "";
			
			populateEquipmentColumns();
			populateItemColumns();
		}
		
		public function populateEquipmentColumns():void
		{
			if (equipment["ArmorEquipHead"] != null) displayTexts[ARMOR_EQUIP_HEAD_DISPLAY_TEXT].displayText.text = "Head: " + equipment["ArmorEquipHead"].name;
			else displayTexts[ARMOR_EQUIP_HEAD_DISPLAY_TEXT].displayText.text = "Head: ";
			
			if (equipment["ArmorEquipTorso"] != null) displayTexts[ARMOR_EQUIP_TORSO_DISPLAY_TEXT].displayText.text = "Torso: " + equipment["ArmorEquipTorso"].name;
			else displayTexts[ARMOR_EQUIP_TORSO_DISPLAY_TEXT].displayText.text = "Torso: ";
			
			if (equipment["ArmorEquipLegs"] != null) displayTexts[ARMOR_EQUIP_LEGS_DISPLAY_TEXT].displayText.text = "Legs: " + equipment["ArmorEquipLegs"].name;
			else displayTexts[ARMOR_EQUIP_LEGS_DISPLAY_TEXT].displayText.text = "Legs: ";
			
			if (equipment["ArmorEquipHands"] != null) displayTexts[ARMOR_EQUIP_HANDS_DISPLAY_TEXT].displayText.text = "Hands: " + equipment["ArmorEquipHands"].name;
			else displayTexts[ARMOR_EQUIP_HANDS_DISPLAY_TEXT].displayText.text = "Hands: ";
			
			if (equipment["ArmorEquipFeet"] != null) displayTexts[ARMOR_EQUIP_FEET_DISPLAY_TEXT].displayText.text = "Feet: " + equipment["ArmorEquipFeet"].name;
			else displayTexts[ARMOR_EQUIP_FEET_DISPLAY_TEXT].displayText.text = "Feet: ";
			
			if (equipment["WeaponEquipPrimary"] != null) displayTexts[WEAPON_EQUIP_PRIMARY_DISPLAY_TEXT].displayText.text = "Primary Weapon: " + equipment["WeaponEquipPrimary"].name;
			else displayTexts[WEAPON_EQUIP_PRIMARY_DISPLAY_TEXT].displayText.text = "Primary Weapon: ";
			
			if (equipment["WeaponEquipSecondary"] != null) displayTexts[WEAPON_EQUIP_SECONDARY_DISPLAY_TEXT].displayText.text = "Secondary Weapon: " + equipment["WeaponEquipSecondary"].name;
			else displayTexts[WEAPON_EQUIP_SECONDARY_DISPLAY_TEXT].displayText.text = "Secondary Weapon: ";
		}
		
		
		
		
		// REVIEW THIS FUNCTION. VALIDITIES ARE GETTING LOST
		public function populateItemColumns():void
		{
			resetItemColumnDisplayTexts();
			itemsStartIndex[WEAPON_ITEM_COLUMN] = 0;
			itemsStartIndex[ARMOR_ITEM_COLUMN] = 0;
			itemsStartIndex[CONSUMABLE_ITEM_COLUMN] = 0;
			
			// set the text for every display list of each column
			var i:int;
			var j:int;
			for (i = 0; i < 3; i++)
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
					
					itemColumns[i][j].displayText.text = items[i][j].name;
					cursorPositionsValidity[columnKeys[i][j]] = true;
					FP.log("validated " + columnKeys[i][j] + " which is now: " + cursorPositionsValidity[columnKeys[i][j]]);
				}
				// DEBUG LOGGING
				// print all the validities of the column that we just validated
				
				/*for (var k:int = itemsStartIndex[i]; k < itemsEndIndex[i]; k++)
				{
					FP.log("Checking the column we just went through. " + columnKeys[i][k] + " is " + cursorPositionsValidity[columnKeys[i][k]]);
				}*/
			}
			for (i = 0; i < 2; i++)
			{
				/*for (k = itemsStartIndex[i]; k < itemsEndIndex[i]; k++)
				{
					FP.log("Final Check in columns we just went through. " + columnKeys[i][k] + " is " + cursorPositionsValidity[columnKeys[i][k]]);
				}*/
			}
			//FP.log("WeaponItem1 validity: " + cursorPositionsValidity["WeaponItem1"]);
			cursor.position = cursorPositions[currentCursorPositionKey];
		}
		
		public function updateItemColumn(_column:int):void
		{
			for (var i:int = 0; i < maxRows; i++)
			{
				if (itemsStartIndex[_column] + i < itemsEndIndex[_column])
				{
					itemColumns[_column][i].displayText.text = items[_column][itemsStartIndex[_column] + i].name;
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
					d.displayText.size = DEFAULT_FONT_SIZE;
				}
			}
		}
		
		public function initItemColumnDisplayTexts():void
		{
			itemColumns[0] = new Array();
			itemColumns[1] = new Array();
			itemColumns[2] = new Array();
			
			for (var i:int = 0; i < maxRows; i++)
			{
				itemColumns[0].push(new DisplayText("", 100, 200 + (i * 20), "default", DEFAULT_FONT_SIZE, 0xFFFFFF, 500));
			}
			for (i = 0; i < maxRows; i++)
			{
				itemColumns[1].push(new DisplayText("", 250, 200 + (i * 20), "default", DEFAULT_FONT_SIZE, 0xFFFFFF, 500));
			}
			for (i = 0; i < maxRows; i++)
			{
				itemColumns[2].push(new DisplayText("", 400, 200 + (i * 20), "default", DEFAULT_FONT_SIZE, 0xFFFFFF, 500));
			}
		}
		
		public function updateCurrentCursorColumn():void
		{
			if (currentCursorPositionKey.search("WeaponItem") != ( -1))
			{
				currentCursorColumn = WEAPON_ITEM_COLUMN;
			}
			else if (currentCursorPositionKey.search("ArmorItem") != ( -1))
			{
				currentCursorColumn = ARMOR_ITEM_COLUMN;
			}
			else if (currentCursorPositionKey.search("ConsumableItem") != ( -1))
			{
				currentCursorColumn = CONSUMABLE_ITEM_COLUMN;
			}
			else if (currentCursorPositionKey.search("ArmorEquip") != ( -1))
			{
				currentCursorColumn = ARMOR_EQUIP_COLUMN;
			}
			else if (currentCursorPositionKey.search("WeaponEquip") != ( -1))
			{
				currentCursorColumn = WEAPON_EQUIP_COLUMN;
			}
		}
		
		public function resetItemHighlights():void
		{
			for (var i:int = 0; i < 3; i++)
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
				
				if (currentCursorColumn == ARMOR_ITEM_COLUMN)
				{
					var armor:Armor = items[currentCursorColumn][itemsStartIndex[currentCursorColumn] + i];
					switch (currentEquipmentKey)
					{
						case "ArmorEquipHead": 
						{
							if (armor.armorType != Armor.HEAD || armor.equipped)
							{
								itemColumns[currentCursorColumn][i].displayText.color = 0x888888;
							}
							else
							{
								itemColumns[currentCursorColumn][i].displayText.color = 0xFFFFFF;
							}
							break;
						}
						case "ArmorEquipTorso": 
						{
							if (armor.armorType != Armor.TORSO || armor.equipped)
							{
								itemColumns[currentCursorColumn][i].displayText.color = 0x888888;
							}
							else
							{
								itemColumns[currentCursorColumn][i].displayText.color = 0xFFFFFF;
							}
							break;
						}
						case "ArmorEquipLegs": 
						{
							if (armor.armorType != Armor.LEGS || armor.equipped)
							{
								itemColumns[currentCursorColumn][i].displayText.color = 0x888888;
							}
							else
							{
								itemColumns[currentCursorColumn][i].displayText.color = 0xFFFFFF;
							}
							break;
						}
						case "ArmorEquipHands": 
						{
							if (armor.armorType != Armor.HANDS || armor.equipped)
							{
								itemColumns[currentCursorColumn][i].displayText.color = 0x888888;
							}
							else
							{
								itemColumns[currentCursorColumn][i].displayText.color = 0xFFFFFF;
							}
							break;
						}
						case "ArmorEquipFeet": 
						{
							if (armor.armorType != Armor.FEET || armor.equipped)
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
				else if (currentCursorColumn == WEAPON_ITEM_COLUMN)
				{
					var weapon:Weapon = items[currentCursorColumn][itemsStartIndex[currentCursorColumn] + i];
					switch (currentEquipmentKey)
					{
						case "WeaponEquipPrimary":
						{
							if (weapon.equipped)
							{
								itemColumns[currentCursorColumn][i].displayText.color = 0x888888;
							}
							else
							{
								itemColumns[currentCursorColumn][i].displayText.color = 0xFFFFFF;
							}
							break;
						}
						case "WeaponEquipSecondary": 
						{
							// If there is a primary weapon and it's two handed
							if (equipment["WeaponEquipPrimary"] != null &&
								equipment["WeaponEquipPrimary"].twoHanded)
							{
								itemColumns[currentCursorColumn][i].displayText.color = 0x888888;
							}
							else if (weapon.twoHanded || weapon.equipped) // grey out the two handed weapons
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
			}
		}
		
		public function cancelPress():void
		{
			if (currentMode == NORMAL_MODE)
			{
				if (currentCursorColumn == ARMOR_EQUIP_COLUMN ||
					currentCursorColumn == WEAPON_EQUIP_COLUMN)
				{
					if (equipment[currentCursorPositionKey] != null)
					{
						equipment[currentCursorPositionKey].equipped = false;
						equipment[currentCursorPositionKey] = null;
						
						populateEquipmentColumns();
					}
				}
			}
			else if (currentMode == EQUIP_MODE)
			{
				currentMode = NORMAL_MODE;
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
			if (currentMode == NORMAL_MODE)
			{
				if (currentCursorColumn == ARMOR_EQUIP_COLUMN)
				{
					// move the cursor to the appropriate column's first position
					// set the cursorEquip at the current position
					cursorEquip.visible = true;
					cursorEquip.position = cursorPositions[currentCursorPositionKey];
					
					cursor.position = cursorPositions["ArmorItem1"];
					currentEquipmentKey = currentCursorPositionKey;
					currentCursorPositionKey = "ArmorItem1";
					updateCurrentCursorColumn();
					currentMode = EQUIP_MODE;
					highlightValidEquipment();
				}
				else if (currentCursorColumn == WEAPON_EQUIP_COLUMN)
				{
					// move the cursor to the appropriate column's first position
					// set the cursorEquip at the current position
					cursorEquip.visible = true;
					cursorEquip.position = cursorPositions[currentCursorPositionKey];
					
					cursor.position = cursorPositions["WeaponItem1"];
					currentEquipmentKey = currentCursorPositionKey;
					currentCursorPositionKey = "WeaponItem1";
					updateCurrentCursorColumn();
					currentMode = EQUIP_MODE;
					highlightValidEquipment();
				}
			}
			else if (currentMode == EQUIP_MODE)
			{
				// get the Weapon or Armor instance of the currently 
				// selected (cursored) item entry
				var index:int = int(currentCursorPositionKey.charAt(currentCursorPositionKey.length - 1)) - 1;
				index += itemsStartIndex[currentCursorColumn];
				
				var validSelection:Boolean = false;
				
				switch (currentEquipmentKey)
				{
					case "ArmorEquipHead": 
					{
						if ((items[currentCursorColumn][index].armorType == Armor.HEAD) &&
							(!items[currentCursorColumn][index].equipped))
						{
							validSelection = true;
						}
						break;
					}
					case "ArmorEquipTorso":
					{
						if ((items[currentCursorColumn][index].armorType == Armor.TORSO) &&
							(!items[currentCursorColumn][index].equipped))
						{
							validSelection = true;
						}
						break;
					}
					case "ArmorEquipLegs": 
					{
						if ((items[currentCursorColumn][index].armorType == Armor.LEGS) &&
							(!items[currentCursorColumn][index].equipped))
						{
							validSelection = true;
						}
						break;
					}
					case "ArmorEquipHands":
					{
						if ((items[currentCursorColumn][index].armorType == Armor.HANDS) &&
							(!items[currentCursorColumn][index].equipped))
						{
							validSelection = true;
						}
						break;
					}
					case "ArmorEquipFeet":
					{
						if ((items[currentCursorColumn][index].armorType == Armor.FEET) &&
							(!items[currentCursorColumn][index].equipped))
						{
							validSelection = true;
						}
						break;
					}
					case "WeaponEquipPrimary":
					{
						if (!items[currentCursorColumn][index].equipped)
						{
							validSelection = true;
							if (items[currentCursorColumn][index].twoHanded)
							{
								equipment["WeaponEquipSecondary"].equipped = false;
								equipment["WeaponEquipSecondary"] = null;
							}
						}
						break;
					}
					case "WeaponEquipSecondary":
					{
						if (!items[currentCursorColumn][index].equipped)
						{
							if (equipment["WeaponEquipPrimary"] != null)
							{
								if ((!equipment["WeaponEquipPrimary"].twoHanded) &&
									(!items[currentCursorColumn][index].twoHanded))
								{
									validSelection = true;
								}
							}
							else
							{
								if (!items[currentCursorColumn][index].twoHanded)
								{
									validSelection = true;
								}
							}
						}
						break;
					}
				}
				
				if (validSelection)
				{
					if (equipment[currentEquipmentKey] != null)
					{
						equipment[currentEquipmentKey].equipped = false;
					}
					equipment[currentEquipmentKey] = items[currentCursorColumn][index];
					items[currentCursorColumn][index].equipped = true;
					populateEquipmentColumns();
					
					currentMode = NORMAL_MODE;
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
			FP.log("currentCursorPositionKey: " + currentCursorPositionKey);
			if (currentMode == NORMAL_MODE)
			{
				var newPosition:Point;
				switch(_direction)
				{
					case "up": newPosition = cursorPositions[cursorPositionsNodes[currentCursorPositionKey].upKey]; break;
					case "down": newPosition = cursorPositions[cursorPositionsNodes[currentCursorPositionKey].downKey]; break;
					case "left": newPosition = cursorPositions[cursorPositionsNodes[currentCursorPositionKey].leftKey]; break;
					case "right": newPosition = cursorPositions[cursorPositionsNodes[currentCursorPositionKey].rightKey]; break;
				}
				if (newPosition != null)
				{
					var moveCursor:Boolean = true;
					if (currentCursorPositionKey == "WeaponItem1" && _direction == "up")
					{
						// find out if there are more items beyond the current itemsEndIndex[WEAPON_COLUMN]
						if (itemsStartIndex[WEAPON_ITEM_COLUMN] > 0)
						{
							itemsStartIndex[WEAPON_ITEM_COLUMN]--;
							itemsEndIndex[WEAPON_ITEM_COLUMN]--;
							updateItemColumn(WEAPON_ITEM_COLUMN);
							moveCursor = false;
						}
					}
					else if (currentCursorPositionKey == "ArmorItem1" && _direction == "up")
					{
						// find out if there are more items beyond the current itemsEndIndex[WEAPON_COLUMN]
						if (itemsStartIndex[ARMOR_ITEM_COLUMN] > 0)
						{
							itemsStartIndex[ARMOR_ITEM_COLUMN]--;
							itemsEndIndex[ARMOR_ITEM_COLUMN]--;
							updateItemColumn(ARMOR_ITEM_COLUMN);
							moveCursor = false;
						}
					}
					else if (currentCursorPositionKey == "ConsumableItem1" && _direction == "up")
					{
						// find out if there are more items beyond the current itemsEndIndex[WEAPON_COLUMN]
						if (itemsEndIndex[CONSUMABLE_ITEM_COLUMN] > 0)
						{
							itemsStartIndex[CONSUMABLE_ITEM_COLUMN]--;
							itemsEndIndex[CONSUMABLE_ITEM_COLUMN]--;
							updateItemColumn(CONSUMABLE_ITEM_COLUMN);
							moveCursor = false;
						}
					}
					
					// Check if there was an obstacle
					if (moveCursor) 
					{
						var newCursorPositionKey:String;
						switch(_direction)
						{
							case "up": newCursorPositionKey = cursorPositionsNodes[currentCursorPositionKey].upKey; break;
							case "down": newCursorPositionKey = cursorPositionsNodes[currentCursorPositionKey].downKey; break;
							case "left": newCursorPositionKey = cursorPositionsNodes[currentCursorPositionKey].leftKey; break;
							case "right": newCursorPositionKey = cursorPositionsNodes[currentCursorPositionKey].rightKey; break;
						}
						//FP.log( cursorPositionsNodes[currentCursorPositionKey].downKey);
						//FP.log("tryin to move to " + newCursorPositionKey + " and validity is: " + cursorPositionsValidity[newCursorPositionKey]);
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
					if (currentCursorPositionKey == "WeaponItem6" && _direction == "down")
					{
						// find out if there are more items beyond the current itemsEndIndex[WEAPON_COLUMN]
						if (items[WEAPON_ITEM_COLUMN].length > itemsEndIndex[WEAPON_ITEM_COLUMN])
						{
							itemsStartIndex[WEAPON_ITEM_COLUMN]++;
							itemsEndIndex[WEAPON_ITEM_COLUMN]++;
							updateItemColumn(WEAPON_ITEM_COLUMN);
						}
					}
					else if (currentCursorPositionKey == "ArmorItem6" && _direction == "down")
					{
						// find out if there are more items beyond the current itemsEndIndex[WEAPON_COLUMN]
						if (items[ARMOR_ITEM_COLUMN].length > itemsEndIndex[ARMOR_ITEM_COLUMN])
						{
							itemsStartIndex[ARMOR_ITEM_COLUMN]++;
							itemsEndIndex[ARMOR_ITEM_COLUMN]++;
							updateItemColumn(ARMOR_ITEM_COLUMN);
						}
					}
					else if (currentCursorPositionKey == "ConsumableItem6" && _direction == "down")
					{
						// find out if there are more items beyond the current itemsEndIndex[WEAPON_COLUMN]
						if (items[CONSUMABLE_ITEM_COLUMN].length > itemsEndIndex[CONSUMABLE_ITEM_COLUMN])
						{
							itemsStartIndex[CONSUMABLE_ITEM_COLUMN]++;
							itemsEndIndex[CONSUMABLE_ITEM_COLUMN]++;
							updateItemColumn(CONSUMABLE_ITEM_COLUMN);
						}
					}
				}
			}
			else if (currentMode == EQUIP_MODE)
			{
				switch(_direction)
				{
					case "up": newPosition = cursorPositions[cursorPositionsNodes[currentCursorPositionKey].upKey]; break;
					case "down": newPosition = cursorPositions[cursorPositionsNodes[currentCursorPositionKey].downKey]; break;
				}
				if (newPosition != null)
				{
					moveCursor = true;
					if (currentCursorPositionKey == "WeaponItem1" && _direction == "up")
					{
						// find out if there are more items beyond the current itemsEndIndex[WEAPON_ITEM_COLUMN]
						if (itemsStartIndex[WEAPON_ITEM_COLUMN] > 0)
						{
							itemsStartIndex[WEAPON_ITEM_COLUMN]--;
							itemsEndIndex[WEAPON_ITEM_COLUMN]--;
							updateItemColumn(WEAPON_ITEM_COLUMN);
							highlightValidEquipment();
							moveCursor = false;
						}
						else if (itemsStartIndex[WEAPON_ITEM_COLUMN] == 0)
						{
							moveCursor = false;
						}
					}
					else if (currentCursorPositionKey == "ArmorItem1" && _direction == "up")
					{
						// find out if there are more items beyond the current itemsEndIndex[ARMOR_ITEM_COLUMN]
						if (itemsStartIndex[ARMOR_ITEM_COLUMN] > 0)
						{
							itemsStartIndex[ARMOR_ITEM_COLUMN]--;
							itemsEndIndex[ARMOR_ITEM_COLUMN]--;
							updateItemColumn(ARMOR_ITEM_COLUMN);
							highlightValidEquipment();
							moveCursor = false;
						}
						else if (itemsStartIndex[WEAPON_ITEM_COLUMN] == 0)
						{
							moveCursor = false;
						}
					}
					else if (currentCursorPositionKey == "ConsumableItem1" && _direction == "up")
					{
						// find out if there are more items beyond the current itemsEndIndex[CONSUMABLE_ITEM_COLUMN]
						if (itemsEndIndex[CONSUMABLE_ITEM_COLUMN] > 0)
						{
							itemsStartIndex[CONSUMABLE_ITEM_COLUMN]--;
							itemsEndIndex[CONSUMABLE_ITEM_COLUMN]--;
							updateItemColumn(CONSUMABLE_ITEM_COLUMN);
							highlightValidEquipment();
							moveCursor = false;
						}
						else if (itemsStartIndex[WEAPON_ITEM_COLUMN] == 0)
						{
							moveCursor = false;
						}
					}
					
					// Check if there was an obstacle
					if (moveCursor) 
					{
						switch(_direction)
						{
							case "up": newCursorPositionKey = cursorPositionsNodes[currentCursorPositionKey].upKey; break;
							case "down": newCursorPositionKey = cursorPositionsNodes[currentCursorPositionKey].downKey; break;
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
					if (currentCursorPositionKey == "WeaponItem6" && _direction == "down")
					{
						// find out if there are more items beyond the current itemsEndIndex[WEAPON_COLUMN]
						if (items[WEAPON_ITEM_COLUMN].length > itemsEndIndex[WEAPON_ITEM_COLUMN])
						{
							itemsStartIndex[WEAPON_ITEM_COLUMN]++;
							itemsEndIndex[WEAPON_ITEM_COLUMN]++;
							updateItemColumn(WEAPON_ITEM_COLUMN);
							highlightValidEquipment();
						}
					}
					else if (currentCursorPositionKey == "ArmorItem6" && _direction == "down")
					{
						// find out if there are more items beyond the current itemsEndIndex[WEAPON_COLUMN]
						if (items[ARMOR_ITEM_COLUMN].length > itemsEndIndex[ARMOR_ITEM_COLUMN])
						{
							itemsStartIndex[ARMOR_ITEM_COLUMN]++;
							itemsEndIndex[ARMOR_ITEM_COLUMN]++;
							updateItemColumn(ARMOR_ITEM_COLUMN);
							highlightValidEquipment();
						}
					}
					else if (currentCursorPositionKey == "ConsumableItem6" && _direction == "down")
					{
						// find out if there are more items beyond the current itemsEndIndex[WEAPON_COLUMN]
						if (items[CONSUMABLE_ITEM_COLUMN].length > itemsEndIndex[CONSUMABLE_ITEM_COLUMN])
						{
							itemsStartIndex[CONSUMABLE_ITEM_COLUMN]++;
							itemsEndIndex[CONSUMABLE_ITEM_COLUMN]++;
							updateItemColumn(CONSUMABLE_ITEM_COLUMN);
							highlightValidEquipment();
						}
					}
				}
			}
		}
		
		public function initUIDatastructures(_uiDatastructures:Array):void
		{
			cursorPositions = _uiDatastructures[0];
			cursorPositionsValidity = _uiDatastructures[1];
			cursorPositionsNodes = _uiDatastructures[2];
			columnKeys = _uiDatastructures[3];
			displayTexts = _uiDatastructures[4];
			//cursorPositionsValidity["WeaponItem1"] = true;
			//FP.log("reset the validities");
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
