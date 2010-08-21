package utility 
{
	import entities.Player;
	import entities.Tiles;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.xml.*;
	/**
	 * ...
	 * @author dolgion
	 */
	public class Map
	{
		public static const INDOOR:int = 0;
		public static const OUTDOOR:int = 1;
		
		public static const NONE:int = -1;
		public static const NORTH:int = 0;
		public static const EAST:int = 1;
		public static const SOUTH:int = 2;
		public static const WEST:int = 3;
		
		public var index:int;
		public var name:String;
		public var width:int;
		public var height:int;
		public var resource:Class;
		public var xml:XML;
		public var worldMapXOffset:Number;
		public var worldMapYOffset:Number;
		public var gridSquares:Array = new Array();
		public var type:int;
		public var exits:Array = new Array(NONE, NONE, NONE, NONE);
		public var childMaps:Array = new Array();
		public var outsideMapIndex:int;
		public var transitionPoints:Array = new Array();
		
		public function Map(_resource:Class, 
							_index:int, 
							_name:String,
							_worldMapXOffset:int, 
							_worldMapYOffset:int,
							_type:int, 
							_exits:Array, 
							_childMaps:Array, 
							_transitionPoints:Array) 
		{
			resource = _resource;
			var bytes:ByteArray = new resource;
			xml = new XML(bytes.readUTFBytes(bytes.length));
			
			// load map data
			width = xml.width;
			height = xml.height;
			index = _index;
			name = _name;
			worldMapXOffset = _worldMapXOffset;
			worldMapYOffset = _worldMapYOffset;
			type = _type;
			exits = _exits;
			childMaps = _childMaps;
			transitionPoints = _transitionPoints;
			
			if (type == INDOOR)
			{
				outsideMapIndex = transitionPoints[0].mapIndex;
			}
			
			setupGridSquares();
		}
		
		public function setupGridSquares():void
		{
			// First establish the gridSquare, 
			// where all squares have the correct position and index
			var counter:int = 0;
			var i:int;
			var j:int;
			var square:GridSquare;
			
			for (i = 0; i <= height; i += 48)
			{
				for (j = 0; j <= width; j += 48)
				{
					counter++;
					square = new GridSquare(j, i, counter, true);
					gridSquares.push(square);
				}
			}
			
			// find the collision rects from the xml
			// and set those squares to unwalkable who fall into
			// the rects
			if (xml.solid[0] != null)
			{
				for each (var solid:XML in xml.solid[0].rect)
				{
					for (i = 0; i < gridSquares.length; i++)
					{
						var rectX:int = solid.@x;
						var rectY:int = solid.@y;
						var rectW:int = solid.@w;
						var rectH:int = solid.@h;
						
						if ((gridSquares[i].x >= rectX) && gridSquares[i].x < (rectX + rectW))
						{
							if ((gridSquares[i].y >= rectY) && gridSquares[i].y < (rectY + rectH))
							{
								gridSquares[i].walkable = false;
							}
						}
					}
				}
			}
		}
	}

}