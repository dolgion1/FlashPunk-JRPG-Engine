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
		[Embed(source = "../../assets/scripts/enemy_data.xml", mimeType = "application/octet-stream")] private var enemyData:Class;
		[Embed(source = "../../assets/scripts/item_data.xml", mimeType = "application/octet-stream")] private var itemData:Class;
		[Embed(source = "../../assets/scripts/chest_data.xml", mimeType = "application/octet-stream")] private var chestData:Class;
		[Embed(source = "../../assets/scripts/ui_inventory_data.xml", mimeType = "application/octet-stream")] private var inventoryUIData:Class;
		[Embed(source = "../../assets/scripts/ui_battle_data.xml", mimeType = "application/octet-stream")] private var battleUIData:Class;
		[Embed(source = "../../assets/scripts/spell_data.xml", mimeType = "application/octet-stream")] private var spellData:Class;
		[Embed(source = "../../assets/scripts/mob_data.xml", mimeType = "application/octet-stream")] private var mobData:Class;
		
		public function DataLoader() {}
		
		public function setupPlayer(_spells:Array):Player
		{
			var playerDataByteArray:ByteArray = new playerData;
			var playerDataXML:XML = new XML(playerDataByteArray.readUTFBytes(playerDataByteArray.length));
			var p:XML;
			var q:XML;
			var r:XML;
			var stats:Array = new Array();
			var spells:Array = new Array();
			
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
			
			stats[GC.STATUS_HEALTH] = playerDataXML.player.health;
			stats[GC.STATUS_MAX_HEALTH] = playerDataXML.player.maxHealth;
			stats[GC.STATUS_MANA] = playerDataXML.player.mana;
			stats[GC.STATUS_MAX_MANA] = playerDataXML.player.maxMana;
			stats[GC.STATUS_STRENGTH] = playerDataXML.player.strength;
			stats[GC.STATUS_AGILITY] = playerDataXML.player.agility;
			stats[GC.STATUS_SPIRITUALITY] = playerDataXML.player.spirituality;
			stats[GC.STATUS_EXPERIENCE] = playerDataXML.player.experience;
			
			for each (p in playerDataXML.player.spells.spell)
			{
				for each (var spell:Spell in _spells)
				{
					if (spell.name == p.name)
					{
						spells.push(spell);
					}
				}
			}
			
			return new Player(new GlobalPosition(playerDataXML.player.mapIndex, playerDataXML.player.x, playerDataXML.player.y), playerDialogs, stats, spells);
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
				if (mapDataXML.map[i].type == "outdoor") mapType = GC.MAP_OUTDOOR;
				else mapType = GC.MAP_INDOOR;
				
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
		
		public function setupEnemies(_maps:Array, _spells:Array, _items:Array):Array
		{
			var enemyDataByteArray:ByteArray = new enemyData;
			var enemyDataXML:XML = new XML(enemyDataByteArray.readUTFBytes(enemyDataByteArray.length));
			var o:XML;
			var p:XML;
			var q:XML;
			var r:XML;
			var enemy:Enemy;
			var enemies:Array = new Array();
			var loot:Array = new Array();
			loot.push(new Array());
			loot.push(new Array());
			loot.push(new Array());
			
			for each (o in enemyDataXML.enemy)
			{
				// load in the appointments
				var enemyAppointments:Array = new Array();
				
				for each (p in o.appointments.appointment)
				{
					enemyAppointments.push(new Appointment(p.@hour, p.@minute, new GlobalPosition(p.@mapIndex, p.@x, p.@y)));
				}
				
				var mobs:Array = new Array();
				
				for each (p in o.mobs.mob)
				{
					mobs.push(new Mob(p.@type, p.@quantity));
				}
				
				// look for items
				for each (p in o.loot.item)
				{
					var found:Boolean = false;
					var inventoryItem:InventoryItem;
					for each (var w:Weapon in _items[GC.ITEM_WEAPON])
					{
						if (p.@name == w.name)
						{
							found = true;
							inventoryItem = new InventoryItem();
							inventoryItem.setWeapon(w, p.@quantity);
							loot[GC.ITEM_WEAPON].push(inventoryItem);
							break;
						}
					}
					if (found) continue;
					
					for each (var a:Armor in _items[GC.ITEM_ARMOR])
					{
						if (p.@name == a.name)
						{
							found = true;
							inventoryItem = new InventoryItem();
							inventoryItem.setArmor(a, p.@quantity);
							loot[GC.ITEM_ARMOR].push(inventoryItem);
							break;
						}
					}
					if (found) continue;
					
					for each (var c:Consumable in _items[GC.ITEM_CONSUMABLE])
					{
						if (p.@name == c.name)
						{
							found = true;
							inventoryItem = new InventoryItem();
							inventoryItem.setConsumable(c, p.@quantity);
							loot[GC.ITEM_CONSUMABLE].push(inventoryItem);
							break;
						}
					}
					if (found) continue;
				}
				
				enemy = new Enemy(_maps, o.name, o.spritesheet, new GlobalPosition(o.mapIndex, o.x, o.y), enemyAppointments, null, mobs, o.experiencePoints, loot, o.loot.@gold);
				enemies.push(enemy);
			}
			
			return enemies;
		}
		
		public function setupMob(_name:String, _spells:Array, _items:Array):Array
		{
			var mobDataByteArray:ByteArray = new mobData;
			var mobDataXML:XML = new XML(mobDataByteArray.readUTFBytes(mobDataByteArray.length));
			var o:XML;
			var s:XML;
			var properties:Array = new Array();
			var spells:Array = new Array();
			var consumables:Array = new Array();
			
			for each (o in mobDataXML.mob)
			{
				if (o.@name == _name)
				{
					properties.push(o.@attackDamage);
					for each (s in o.spells.spell)
					{
						for each (var spell:Spell in _spells)
						{
							if (spell.name == s.@name)
							{
								spells.push(spell);
							}
						}
					}
					for each (s in o.consumables.consumable)
					{
						var inventoryItem:InventoryItem;
						for each (var c:Consumable in _items[GC.ITEM_CONSUMABLE])
						{
							if (s.@name == c.name)
							{
								inventoryItem = new InventoryItem();
								inventoryItem.setConsumable(c, s.@quantity);
								consumables.push(inventoryItem);
								break;
							}
						}
					}
					
					properties.push(spells);
					properties.push(consumables);
					return properties;
				}
			}
			return null;
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
				armor.resistances[GC.DAMAGE_TYPE_SLASHING] = int(i.slashing);
				armor.resistances[GC.DAMAGE_TYPE_PIERCING] = int(i.piercing);
				armor.resistances[GC.DAMAGE_TYPE_IMPACT] = int(i.impact);
				armor.resistances[GC.DAMAGE_TYPE_MAGIC] = int(i.magic);
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
					
					for each (var w:Weapon in _items[GC.ITEM_WEAPON])
					{
						if (chestInventoryItem.@name == w.name)
						{
							found = true;
							inventoryItem = new InventoryItem();
							inventoryItem.setWeapon(w, chestInventoryItem.@quantity);
							chest.items[GC.ITEM_WEAPON].push(inventoryItem);
							break;
						}
					}
					if (found) continue;
					
					for each (var a:Armor in _items[GC.ITEM_ARMOR])
					{
						if (chestInventoryItem.@name == a.name)
						{
							found = true;
							inventoryItem = new InventoryItem();
							inventoryItem.setArmor(a, chestInventoryItem.@quantity);
							chest.items[GC.ITEM_ARMOR].push(inventoryItem);
							break;
						}
					}
					if (found) continue;
					
					for each (var c:Consumable in _items[GC.ITEM_CONSUMABLE])
					{
						if (chestInventoryItem.@name == c.name)
						{
							found = true;
							inventoryItem = new InventoryItem();
							inventoryItem.setConsumable(c, chestInventoryItem.@quantity);
							chest.items[GC.ITEM_CONSUMABLE].push(inventoryItem);
							break;
						}
					}
					if (found) continue;
				}
				chests.push(chest);
			}
			
			return chests;
		}
		
		public function setupSpellData():Array
		{
			var spellDataByteArray:ByteArray = new spellData;
			var spellDataXML:XML = new XML(spellDataByteArray.readUTFBytes(spellDataByteArray.length));
			var i:XML;
			var spells:Array = new Array();
						
			for each (i in spellDataXML.defense.defenseSpell)
			{
				var defenseSpell:DefenseSpell = new DefenseSpell();
				defenseSpell.name = i.@name;
				
				if (i.@temporary == "true") defenseSpell.temporary = true;
				else defenseSpell.temporary = false;
				
				defenseSpell.duration = i.@duration;
				defenseSpell.statusVariable = i.@statusVariable;
				defenseSpell.alteration = i.@alteration;
				defenseSpell.description = i.@description;
				defenseSpell.manaCost = i.@manaCost;
				spells.push(defenseSpell);
			}
			
			for each (i in spellDataXML.offense.offenseSpell)
			{
				var offenseSpell:OffenseSpell = new OffenseSpell();
				offenseSpell.name = i.@name;
				
				if (i.@temporary == "true") offenseSpell.temporary = true;
				else offenseSpell.temporary = false;
				
				offenseSpell.duration = i.@duration;
				offenseSpell.element = i.@element;
				offenseSpell.damageRating = i.@damageRating;
				offenseSpell.description = i.@description;
				offenseSpell.manaCost = i.@manaCost;
				spells.push(offenseSpell);
			}
			
			return spells;
		}
		
		public function setupInventoryUIData():Array
		{
			var inventoryUIDataArray:ByteArray = new inventoryUIData;
			var inventoryUIDataXML:XML = new XML(inventoryUIDataArray.readUTFBytes(inventoryUIDataArray.length));
			var i:XML;
			var cursorPositions:Dictionary = new Dictionary();
			var columnKeys:Array = new Array();
			
			columnKeys[0] = new Array();
			columnKeys[1] = new Array();
			columnKeys[2] = new Array();
			
			var displayTexts:Array = new Array();
			
			for each (i in inventoryUIDataXML.cursorpositions.cursorposition)
			{
				var cursorPosition:CursorPosition = new CursorPosition();
				cursorPosition.x = int(i.@x);
				cursorPosition.y = int(i.@y);
				cursorPosition.key = i.@key;
				
				if (i.@validity == "true")
				{
					cursorPosition.valid = true;
				}
				else 
				{
					cursorPosition.valid = false;
				}
				
				cursorPosition.setKeys(i.@up, i.@down, i.@left, i.@right);
				cursorPositions["" + i.@key] = cursorPosition;
			}
				
			for each (i in inventoryUIDataXML.columnkeys.columnkey)
			{
				columnKeys[i.@column][i.@index] = new String(i.@key);
			}
			
			for each (i in inventoryUIDataXML.displaytexts.displaytext)
			{
				displayTexts.push(new DisplayText("" + i.@text, i.@x, i.@y, "default", i.@size, 0xFFFFFF, 500));
			}
			
			return new Array(cursorPositions, columnKeys, displayTexts);
		}
		
		public function setupBattleUIData():Array
		{
			var battleUIDataArray:ByteArray = new battleUIData;
			var battleUIDataXML:XML = new XML(battleUIDataArray.readUTFBytes(battleUIDataArray.length));
			var i:XML;
			var cursorPositions:Dictionary = new Dictionary();
			
			for each (i in battleUIDataXML.cursorpositions.cursorposition)
			{
				var cursorPosition:CursorPosition = new CursorPosition();
				cursorPosition.x = int(i.@x);
				cursorPosition.y = int(i.@y);
				cursorPosition.key = i.@key;
				
				if (i.@validity == "true")
				{
					cursorPosition.valid = true;
				}
				else 
				{
					cursorPosition.valid = false;
				}
				
				cursorPosition.setKeys(i.@up, i.@down, i.@left, i.@right);
				cursorPositions["" + i.@key] = cursorPosition;
			}
			
			return new Array(cursorPositions);
		}
	}

}
