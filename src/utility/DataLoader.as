package utility 
{
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import net.flashpunk.*;
	import entities.*;
	import utility.*;
	/**
	 * ...
	 * @author dolgion
	 */
	public class DataLoader
	{
		[Embed(source = "../../assets/levels/outdoors_01.oel", mimeType = "application/octet-stream")] private var outdoors1:Class;
		[Embed(source = "../../assets/levels/outdoors_02.oel", mimeType = "application/octet-stream")] private var outdoors2:Class;
		[Embed(source = "../../assets/levels/indoors_01.oel", mimeType = "application/octet-stream")] private var indoors1:Class;
		[Embed(source = "../../assets/levels/indoors_02.oel", mimeType = "application/octet-stream")] private var indoors2:Class;
		[Embed(source = "../../assets/levels/indoors_03.oel", mimeType = "application/octet-stream")] private var indoors3:Class;
		[Embed(source = "../../assets/levels/indoors_04.oel", mimeType = "application/octet-stream")] private var indoors4:Class;
		[Embed(source = "../../assets/levels/indoors_05.oel", mimeType = "application/octet-stream")] private var indoors5:Class;
		[Embed(source = "../../assets/levels/indoors_06.oel", mimeType = "application/octet-stream")] private var indoors6:Class;
		
		[Embed(source = "../../assets/scripts/player_data.xml", mimeType = "application/octet-stream")] private var playerData:Class;
		[Embed(source = "../../assets/scripts/map_data.xml", mimeType = "application/octet-stream")] private var mapData:Class;
		[Embed(source = "../../assets/scripts/npc_data.xml", mimeType = "application/octet-stream")] private var npcData:Class;
		[Embed(source = "../../assets/scripts/item_data.xml", mimeType = "application/octet-stream")] private var itemData:Class;
		[Embed(source = "../../assets/scripts/chest_data.xml", mimeType = "application/octet-stream")] private var chestData:Class;
		[Embed(source = "../../assets/scripts/ui_inventory_data.xml", mimeType = "application/octet-stream")] private var inventoryUIData:Class;
		
		
		public function DataLoader() {}
		
		public function setupPlayer():Player
		{
			var playerDataByteArray:ByteArray = new playerData;
			var playerDataXML:XML = new XML(playerDataByteArray.readUTFBytes(playerDataByteArray.length));
			var p:XML;
			var q:XML;
			var r:XML;
			
			// load in the dialog
			var playerDialogs:Array = new Array();
			
			for each (p in playerDataXML.player.dialogs.dialog)
			{
				// Gonna loop through all the lines in the current dialog
				var playerDialogLines:Array = new Array();
				for each (q in p.line)
				{
					var playerDialogLineVersions:Array = new Array();
					// gonna loop through all possible dialog options
					for each (r in q.version)
					{
						playerDialogLineVersions.push(r);
					}
					var playerDialogLine:Line = new Line(q.@index, playerDialogLineVersions);
					playerDialogLines.push(playerDialogLine);
				}
				var playerDialog:Dialog = new Dialog(p.@partner, p.@index, playerDialogLines);
				playerDialogs.push(playerDialog);
			}
			
			return new Player(new GlobalPosition(playerDataXML.player.mapIndex, playerDataXML.player.x, playerDataXML.player.y), playerDialogs);
		}
		
		public function setupMaps():Array
		{
			var rawMaps:Array = new Array(outdoors1, outdoors2, indoors1, indoors2, indoors3, indoors4, indoors5, indoors6);
			var mapDataByteArray:ByteArray = new mapData;
			var mapDataXML:XML = new XML(mapDataByteArray.readUTFBytes(mapDataByteArray.length));
			var o:XML;
			var map:Map;
			var maps:Array = new Array();
			
			for (var i:int = 0; i < rawMaps.length; i++)
			{
				var mapExits:Array = new Array(mapDataXML.map[i].north,
											   mapDataXML.map[i].east,
											   mapDataXML.map[i].south,
											   mapDataXML.map[i].west);
				
				var mapType:int;
				if (mapDataXML.map[i].type == "outdoor") mapType = Map.OUTDOOR;
				else mapType = Map.INDOOR;
				
				var mapChildMaps:Array = new Array();
				for each (o in mapDataXML.map[i].child_maps[0].child)
				{
					var a:int = o.@mapIndex;
					mapChildMaps.push(a);
				}
				
				var mapTransitionPoints:Array = new Array();
				for each (o in mapDataXML.map[i].transition_points[0].transition_point)
				{
					mapTransitionPoints.push(new GlobalPosition(o.@mapIndex, o.@x, o.@y));
				}
				map = new Map(rawMaps[i], 
							  mapDataXML.map[i].index,
							  mapDataXML.map[i].name,
							  mapDataXML.map[i].worldmap_x_offset,
							  mapDataXML.map[i].worldmap_y_offset,
							  mapType,
							  mapExits,
							  mapChildMaps,
							  mapTransitionPoints);
				maps.push(map);
			}
			
			return maps;
		}
		
		public function setupNPCs(maps:Array):Array
		{
			var npcDataByteArray:ByteArray = new npcData;
			var npcDataXML:XML = new XML(npcDataByteArray.readUTFBytes(npcDataByteArray.length));
			var o:XML;
			var p:XML;
			var q:XML;
			var r:XML;
			var npc:NPC;
			var npcs:Array = new Array();
			
			for each (o in npcDataXML.npc)
			{
				// load in the appointments
				var npcAppointments:Array = new Array();
				for each (p in o.appointments.appointment)
				{
					npcAppointments.push(new Appointment(p.@hour, p.@minute, new GlobalPosition(p.@mapIndex, p.@x, p.@y)));
				}
				
				// load in the dialog
				var npcDialogs:Array = new Array();
				for each (p in o.dialogs.dialog)
				{
					// loop through all lines in the current dialog
					var npcDialogLines:Array = new Array();
					for each (q in p.line)
					{
						var npcDialogLineVersions:Array = new Array();
						// loop through all possible dialog options
						for each (r in q.version)
						{
							npcDialogLineVersions.push(r);
						}
						var npcDialogLine:Line = new Line(q.@index, npcDialogLineVersions);
						npcDialogLines.push(npcDialogLine);
					}
					var npcDialog:Dialog = new Dialog(p.@partner, p.@index, npcDialogLines);
					npcDialogs.push(npcDialog);
				}
				
				npc = new NPC(maps, o.name, o.spritesheet, new GlobalPosition(o.mapIndex, o.x, o.y), npcAppointments, npcDialogs);
				npcs.push(npc);
			}
			
			return npcs;
		}
		
		public function setupItems():Array
		{
			var itemDataByteArray:ByteArray = new itemData;
			var itemDataXML:XML = new XML(itemDataByteArray.readUTFBytes(itemDataByteArray.length));
			var i:XML;
			var items:Array = new Array();
			var weapons:Array = new Array();
			var armors:Array = new Array();
			var consumables:Array = new Array();
			
			for each (i in itemDataXML.items.weapons.weapon)
			{
				var weapon:Weapon = new Weapon();
				weapon.name = i.@name;
				weapon.damageType = i.damagetype;	
				weapon.attackType = i.attacktype;
				weapon.damageRating = i.damagerating
				
				if (i.twohanded == "true") weapon.twoHanded = true;
				else weapon.twoHanded = false;
				
				weapons.push(weapon);
			}
			
			for each (i in itemDataXML.items.armors.armor)
			{
				var armor:Armor = new Armor();
				armor.name = i.@name;
				armor.armorType = i.armortype;
				armor.armorRating= i.armorrating;
				armor.resistances[Weapon.SLASHING] = int(i.slashing);
				armor.resistances[Weapon.PIERCING] = int(i.piercing);
				armor.resistances[Weapon.IMPACT] = int(i.impact);
				armor.resistances[Weapon.MAGIC] = int(i.magic);
				armors.push(armor);
			}
			
			for each (i in itemDataXML.items.consumables.consumable)
			{
				var consumable:Consumable = new Consumable();
				consumable.name = i.@name;
				consumable.description = i.@description;
				
				if (i.@temporary == "true") consumable.temporary = true;
				else consumable.temporary = false;
				
				consumable.duration = i.@duration;
				
				for each (var j:XML in i.statusalteration)
				{
					var statusAlteration:StatusAlteration = new StatusAlteration();
					statusAlteration.statusVariable = j.@statusVariable;
					statusAlteration.alteration = j.@alteration;
					consumable.statusAlterations.push(statusAlteration);
				}
				
				consumables.push(consumable);
			}
			
			items.push(weapons);
			items.push(armors);
			items.push(consumables);
			
			return items;
		}
		
		public function setupChests(_items:Array):Array
		{
			var chestDataByteArray:ByteArray = new chestData;
			var chestDataXML:XML = new XML(chestDataByteArray.readUTFBytes(chestDataByteArray.length));
			var i:XML;
			var chestInventoryItem:XML;
			var chests:Array = new Array();
			
			for each (i in chestDataXML.chest)
			{
				var chest:Chest = new Chest(new GlobalPosition(i.mapIndex, i.x, i.y), i.direction);
				var inventoryItem:InventoryItem;
				
				// look for items
				for each (chestInventoryItem in i.items.item)
				{
					var found:Boolean = false;
					
					for each (var w:Weapon in _items[Item.WEAPON])
					{
						if (chestInventoryItem.@name == w.name)
						{
							found = true;
							inventoryItem = new InventoryItem();
							inventoryItem.setWeapon(w, chestInventoryItem.@quantity);
							chest.items[Item.WEAPON].push(inventoryItem);
							break;
						}
					}
					if (found) continue;
					
					for each (var a:Armor in _items[Item.ARMOR])
					{
						if (chestInventoryItem.@name == a.name)
						{
							found = true;
							inventoryItem = new InventoryItem();
							inventoryItem.setArmor(a, chestInventoryItem.@quantity);
							chest.items[Item.ARMOR].push(inventoryItem);
							break;
						}
					}
					if (found) continue;
					
					for each (var c:Consumable in _items[Item.CONSUMABLE])
					{
						if (chestInventoryItem.@name == c.name)
						{
							found = true;
							inventoryItem = new InventoryItem();
							inventoryItem.setConsumable(c, chestInventoryItem.@quantity);
							chest.items[Item.CONSUMABLE].push(inventoryItem);
							break;
						}
					}
					if (found) continue;
				}
				chests.push(chest);
			}
			
			return chests;
		}
		
		public function setupInventoryUIData():Array
		{
			var inventoryUIDataArray:ByteArray = new inventoryUIData;
			var inventoryUIDataXML:XML = new XML(inventoryUIDataArray.readUTFBytes(inventoryUIDataArray.length));
			var i:XML;
			var cursorPositions:Dictionary = new Dictionary();
			var cursorPositionsValidity:Dictionary = new Dictionary();
			var cursorPositionsNodes:Dictionary = new Dictionary();
			var columnKeys:Array = new Array();
			
			columnKeys[0] = new Array();
			columnKeys[1] = new Array();
			columnKeys[2] = new Array();
			
			var displayTexts:Array = new Array();
			
			for each (i in inventoryUIDataXML.cursorpositions.cursorposition)
			{
				cursorPositions["" + i.@key] = new Point(int(i.@x), int(i.@y));
				
				if (i.@validity == "true")
				{
					cursorPositionsValidity["" + i.@key] = true;
				}
				else 
				{
					cursorPositionsValidity["" + i.@key] = false;
				}
			}
			
			for each (i in inventoryUIDataXML.cursorpositionnodes.cursorpositionnode)
			{
				cursorPositionsNodes["" + i.@key] = new CursorPositionNode(i.up, i.down, i.left, i.right);
			}
			
			for each (i in inventoryUIDataXML.columnkeys.columnkey)
			{
				columnKeys[i.@column][i.@index] = new String(i.@key);
			}
			
			for each (i in inventoryUIDataXML.displaytexts.displaytext)
			{
				displayTexts.push(new DisplayText("" + i.@text, i.@x, i.@y, "default", i.@size, 0xFFFFFF, 500));
			}
			
			return new Array(cursorPositions, cursorPositionsValidity, cursorPositionsNodes, columnKeys, displayTexts);
		}
	}

}
