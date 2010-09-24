package utility 
{
	import entities.Cursor;
	import entities.CursorEquip;
	import entities.DisplayText;
	import entities.TextBox;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author dolgion
	 */
	public class InventoryScreen
	{
		public const DEFAULT_FONT_SIZE:int = 12;
		
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
		
		public var headEquipmentDisplay:DisplayText;
		public var torsoEquipmentDisplay:DisplayText;
		public var legsEquipmentDisplay:DisplayText;
		public var handsEquipmentDisplay:DisplayText;
		public var feetEquipmentDisplay:DisplayText;
		public var primaryEquipmentDisplay:DisplayText;
		public var secondaryEquipmentDisplay:DisplayText;
		
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
		public var cursorPositionsLabels:Array = new Array();
		
		public var currentEquipmentKey:String;
		
		public function InventoryScreen() 
		{
			background = new TextBox(10, 10, 3, 4.5);
			cursor = new Cursor(0, 0);
			cursorEquip = new CursorEquip(0, 0);
			cursorEquip.visible = false;
			
			equipmentHeader = new DisplayText("Equipment", 50, 30, "default", 14, 0xFFFFFF, 500);
			itemsHeader = new DisplayText("Items", 50, 170, "default", 14, 0xFFFFFF, 500);
			detailsHeader = new DisplayText("Details", 50, 320, "default", 14, 0xFFFFFF, 500);
			
			headEquipmentDisplay = new DisplayText("Head: ", 100, 60, "default", DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			torsoEquipmentDisplay = new DisplayText("Torso: ", 100, 80, "default", DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			legsEquipmentDisplay = new DisplayText("Legs: ", 100, 100, "default", DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			handsEquipmentDisplay = new DisplayText("Hands: ", 100, 120, "default", DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			feetEquipmentDisplay = new DisplayText("Feet: ", 100, 140, "default", DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			primaryEquipmentDisplay = new DisplayText("Primary Weapon: ", 300, 60, "default", DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			secondaryEquipmentDisplay = new DisplayText("Secondary Weapon: ", 300, 80, "default", DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			
			initItemColumnDisplayTexts();
			
			displayTexts.push(equipmentHeader);
			displayTexts.push(itemsHeader);
			displayTexts.push(detailsHeader);
			displayTexts.push(headEquipmentDisplay);
			displayTexts.push(torsoEquipmentDisplay);
			displayTexts.push(legsEquipmentDisplay);
			displayTexts.push(handsEquipmentDisplay);
			displayTexts.push(feetEquipmentDisplay);
			displayTexts.push(primaryEquipmentDisplay);
			displayTexts.push(secondaryEquipmentDisplay);
			
			for each (var c:Array in itemColumns)
			{
				for each (var d:DisplayText in c)
				{
					displayTexts.push(d);
				}
			}
			
			initCursorDatastructures();
		}
		
		public function initialize(_items:Array, _equipment:Dictionary):void
		{
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
			if (equipment["ArmorEquipHead"] != null) headEquipmentDisplay.displayText.text = "Head: " + equipment["ArmorEquipHead"].name;
			else headEquipmentDisplay.displayText.text = "Head: ";
			
			if (equipment["ArmorEquipTorso"] != null) torsoEquipmentDisplay.displayText.text = "Torso: " + equipment["ArmorEquipTorso"].name;
			else torsoEquipmentDisplay.displayText.text = "Torso: ";
			
			if (equipment["ArmorEquipLegs"] != null) legsEquipmentDisplay.displayText.text = "Legs: " + equipment["ArmorEquipLegs"].name;
			else legsEquipmentDisplay.displayText.text = "Legs: ";
			
			if (equipment["ArmorEquipHands"] != null) handsEquipmentDisplay.displayText.text = "Hands: " + equipment["ArmorEquipHands"].name;
			else handsEquipmentDisplay.displayText.text = "Hands: ";
			
			if (equipment["ArmorEquipFeet"] != null) feetEquipmentDisplay.displayText.text = "Feet: " + equipment["ArmorEquipFeet"].name;
			else feetEquipmentDisplay.displayText.text = "Feet: ";
			
			if (equipment["WeaponEquipPrimary"] != null) primaryEquipmentDisplay.displayText.text = "Primary Weapon: " + equipment["WeaponEquipPrimary"].name;
			else primaryEquipmentDisplay.displayText.text = "Primary Weapon: ";
			
			if (equipment["WeaponEquipSecondary"] != null) secondaryEquipmentDisplay.displayText.text = "Secondary Weapon: " + equipment["WeaponEquipSecondary"].name;
			else secondaryEquipmentDisplay.displayText.text = "Secondary Weapon: ";
		}
		
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
					cursorPositionsValidity[cursorPositionsLabels[i][j]] = true;
				}
			}
			
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
		
		public function cancelPress():void
		{
			if (currentMode == NORMAL_MODE)
			{
				if (currentCursorColumn == ARMOR_EQUIP_COLUMN ||
					currentCursorColumn == WEAPON_EQUIP_COLUMN)
				{
					equipment[currentCursorPositionKey] = null;
					populateEquipmentColumns();
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
					trace("Equipping: " + currentEquipmentKey);
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
						if (items[currentCursorColumn][index].armorType == Armor.HEAD)
						{
							validSelection = true;
						}
						break;
					}
					case "ArmorEquipTorso":
					{
						if (items[currentCursorColumn][index].armorType == Armor.TORSO)
						{
							validSelection = true;
						}
						break;
					}
					case "ArmorEquipLegs": 
					{
						if (items[currentCursorColumn][index].armorType == Armor.LEGS)
						{
							validSelection = true;
						}
						break;
					}
					case "ArmorEquipHands":
					{
						if (items[currentCursorColumn][index].armorType == Armor.HANDS)
						{
							validSelection = true;
						}
						break;
					}
					case "ArmorEquipFeet":
					{
						if (items[currentCursorColumn][index].armorType == Armor.FEET)
						{
							validSelection = true;
						}
						break;
					}
					case "WeaponEquipPrimary":
					{
						validSelection = true;
						if (items[currentCursorColumn][index].twoHanded)
						{
							equipment["WeaponEquipSecondary"] = null;
						}
						break;
					}
					case "WeaponEquipSecondary":
					{
						if (equipment["WeaponEquipPrimary"] != null)
						{
							trace(equipment["WeaponEquipPrimary"].twoHanded + " " + items[currentCursorColumn][index].twoHanded);
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
						break;
					}
				}
				
				if (validSelection)
				{
					equipment[currentEquipmentKey] = items[currentCursorColumn][index];					
					populateEquipmentColumns();
					
					currentMode = NORMAL_MODE;
					cursorEquip.visible = false;
					cursor.position = cursorPositions[currentEquipmentKey];
					currentCursorPositionKey = currentEquipmentKey;
					currentEquipmentKey = "";
					updateCurrentCursorColumn();
				}
			}
		}
		
		public function cursorMovement(_direction:String):void
		{
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
		}
		
		public function initCursorDatastructures():void
		{
			cursorPositions["ArmorEquipHead"] = new Point(65, 70);
			cursorPositions["ArmorEquipTorso"] = new Point(65, 90);
			cursorPositions["ArmorEquipLegs"] = new Point(65, 110);
			cursorPositions["ArmorEquipHands"] = new Point(65, 130);
			cursorPositions["ArmorEquipFeet"] = new Point(65, 150);
			cursorPositions["WeaponEquipPrimary"] = new Point(265, 70);
			cursorPositions["WeaponEquipSecondary"] = new Point(265, 90);
			cursorPositions["WeaponItem1"] = new Point(65, 210);
			cursorPositions["WeaponItem2"] = new Point(65, 230);
			cursorPositions["WeaponItem3"] = new Point(65, 250);
			cursorPositions["WeaponItem4"] = new Point(65, 270);
			cursorPositions["WeaponItem5"] = new Point(65, 290);
			cursorPositions["WeaponItem6"] = new Point(65, 310);
			cursorPositions["ArmorItem1"] = new Point(215, 210);
			cursorPositions["ArmorItem2"] = new Point(215, 230);
			cursorPositions["ArmorItem3"] = new Point(215, 250);
			cursorPositions["ArmorItem4"] = new Point(215, 270);
			cursorPositions["ArmorItem5"] = new Point(215, 290);
			cursorPositions["ArmorItem6"] = new Point(215, 310);
			cursorPositions["ConsumableItem1"] = new Point(365, 210);
			cursorPositions["ConsumableItem2"] = new Point(365, 230);
			cursorPositions["ConsumableItem3"] = new Point(365, 250);
			cursorPositions["ConsumableItem4"] = new Point(365, 270);
			cursorPositions["ConsumableItem5"] = new Point(365, 290);
			cursorPositions["ConsumableItem6"] = new Point(365, 310);
			
			cursorPositionsNodes["ArmorEquipHead"] = new CursorPositionNode(null, "ArmorEquipTorso", null, "WeaponEquipPrimary");
			cursorPositionsNodes["ArmorEquipTorso"] = new CursorPositionNode("ArmorEquipHead", "ArmorEquipLegs", null, "WeaponEquipSecondary");
			cursorPositionsNodes["ArmorEquipLegs"]= new CursorPositionNode("ArmorEquipTorso", "ArmorEquipHands", null, null);
			cursorPositionsNodes["ArmorEquipHands"] = new CursorPositionNode("ArmorEquipLegs", "ArmorEquipFeet", null, null);
			cursorPositionsNodes["ArmorEquipFeet"] = new CursorPositionNode("ArmorEquipHands", "WeaponItem1", null, null);
			cursorPositionsNodes["WeaponEquipPrimary"] = new CursorPositionNode(null, "WeaponEquipSecondary", "ArmorEquipHead", null);
			cursorPositionsNodes["WeaponEquipSecondary"] = new CursorPositionNode("WeaponEquipPrimary", "ArmorEquipLegs", "ArmorEquipTorso", null);
			cursorPositionsNodes["WeaponItem1"] = new CursorPositionNode("ArmorEquipFeet", "WeaponItem2", null, "ArmorItem1");
			cursorPositionsNodes["WeaponItem2"] = new CursorPositionNode("WeaponItem1", "WeaponItem3", null, "ArmorItem2");
			cursorPositionsNodes["WeaponItem3"] = new CursorPositionNode("WeaponItem2", "WeaponItem4", null, "ArmorItem3");
			cursorPositionsNodes["WeaponItem4"] = new CursorPositionNode("WeaponItem3", "WeaponItem5", null, "ArmorItem4");
			cursorPositionsNodes["WeaponItem5"] = new CursorPositionNode("WeaponItem4", "WeaponItem6", null, "ArmorItem5");
			cursorPositionsNodes["WeaponItem6"] = new CursorPositionNode("WeaponItem5", null, null, "ArmorItem6");
			cursorPositionsNodes["ArmorItem1"] = new CursorPositionNode("ArmorEquipFeet", "ArmorItem2", "WeaponItem1", "ConsumableItem1");
			cursorPositionsNodes["ArmorItem2"] = new CursorPositionNode("ArmorItem1", "ArmorItem3", "WeaponItem2", "ConsumableItem2");
			cursorPositionsNodes["ArmorItem3"] = new CursorPositionNode("ArmorItem2", "ArmorItem4", "WeaponItem3", "ConsumableItem3");
			cursorPositionsNodes["ArmorItem4"] = new CursorPositionNode("ArmorItem3", "ArmorItem5", "WeaponItem4", "ConsumableItem4");
			cursorPositionsNodes["ArmorItem5"] = new CursorPositionNode("ArmorItem4", "ArmorItem6", "WeaponItem5", "ConsumableItem5");
			cursorPositionsNodes["ArmorItem6"] = new CursorPositionNode("ArmorItem5", null, "WeaponItem6", "ConsumableItem6");
			cursorPositionsNodes["Consumable1"] = new CursorPositionNode("ArmorEquipFeet", "ConsumableItem2", "ArmorItem1", null);
			cursorPositionsNodes["Consumable2"] = new CursorPositionNode("ConsumableItem1", "ConsumableItem3", "ArmorItem2", null);
			cursorPositionsNodes["Consumable3"] = new CursorPositionNode("ConsumableItem2", "ConsumableItem4", "ArmorItem3", null);
			cursorPositionsNodes["Consumable4"] = new CursorPositionNode("ConsumableItem3", "ConsumableItem5", "ArmorItem4", null);
			cursorPositionsNodes["Consumable5"] = new CursorPositionNode("ConsumableItem4", "ConsumableItem6", "ArmorItem5", null);
			cursorPositionsNodes["Consumable6"] = new CursorPositionNode("ConsumableItem5", null, "ArmorItem6", null);
			
			cursorPositionsValidity["ArmorEquipHead"] = true;
			cursorPositionsValidity["ArmorEquipTorso"] = true;
			cursorPositionsValidity["ArmorEquipLegs"] = true;
			cursorPositionsValidity["ArmorEquipHands"] = true;
			cursorPositionsValidity["ArmorEquipFeet"] = true;
			cursorPositionsValidity["WeaponEquipPrimary"] = true;
			cursorPositionsValidity["WeaponEquipSecondary"] = true;
			
			cursorPositionsValidity["WeaponItem1"] = false;
			cursorPositionsValidity["WeaponItem2"] = false;
			cursorPositionsValidity["WeaponItem3"] = false;
			cursorPositionsValidity["WeaponItem4"] = false;
			cursorPositionsValidity["WeaponItem5"] = false;
			cursorPositionsValidity["WeaponItem6"] = false;
			
			cursorPositionsValidity["ArmorItem1"] = false;
			cursorPositionsValidity["ArmorItem2"] = false;
			cursorPositionsValidity["ArmorItem3"] = false;
			cursorPositionsValidity["ArmorItem4"] = false;
			cursorPositionsValidity["ArmorItem5"] = false;
			cursorPositionsValidity["ArmorItem6"] = false;
			
			cursorPositionsValidity["ConsumableItem1"] = false;
			cursorPositionsValidity["ConsumableItem2"] = false;
			cursorPositionsValidity["ConsumableItem3"] = false;
			cursorPositionsValidity["ConsumableItem4"] = false;
			cursorPositionsValidity["ConsumableItem5"] = false;
			cursorPositionsValidity["ConsumableItem6"] = false;
			
			cursorPositionsLabels[WEAPON_ITEM_COLUMN] = new Array();
			cursorPositionsLabels[ARMOR_ITEM_COLUMN] = new Array();
			cursorPositionsLabels[CONSUMABLE_ITEM_COLUMN] = new Array();
			
			for (var i:int = 0; i < 6; i++)
			{
				cursorPositionsLabels[WEAPON_ITEM_COLUMN][i] = "WeaponItem" + (i + 1);
			}
			for (i = 0; i < 6; i++)
			{
				cursorPositionsLabels[ARMOR_ITEM_COLUMN][i] = "ArmorItem" + (i + 1);
			}
			for (i = 0; i < 6; i++)
			{
				cursorPositionsLabels[CONSUMABLE_ITEM_COLUMN][i] = "ConsumableItem" + (i + 1);
			}
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