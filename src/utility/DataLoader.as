package utility 
{
	import flash.utils.ByteArray;
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
				// trace("Partner: " + p.@partner);
				var playerDialogLines:Array = new Array();
				for each (q in p.line)
				{
					var playerDialogLineVersions:Array = new Array();
					// trace("  a new general line: " + q.@index);
					for each (r in q.version)
					{
						// trace("    a version of it: " + r);
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
					
					// trace("Partner: " + p.@partner);
					var npcDialogLines:Array = new Array();
					for each (q in p.line)
					{
						var npcDialogLineVersions:Array = new Array();
						// trace("  a new general line: " + q.@index);
						for each (r in q.version)
						{
							// trace("    a version of it: " + r);
							npcDialogLineVersions.push(r);
						}
						var npcDialogLine:Line = new Line(q.@index, npcDialogLineVersions);
						npcDialogLines.push(npcDialogLine);
					}
					var npcDialog:Dialog = new Dialog(p.@partner, p.@index, npcDialogLines);
					npcDialogs.push(npcDialog);
				}
				
				npc = new NPC(maps, o.name, o.spritesheet, o.x, o.y, o.mapIndex, npcAppointments, npcDialogs);
				npcs.push(npc);
			}
			
			return npcs;
		}
	}

}