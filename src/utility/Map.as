package utility 
{
	import entities.Player;
	import entities.Tiles;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.xml.*;
	
	/**
	 * ...
	 * @author dolgion
	 */
	public class Map
	{
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
		public var exits:Array = new Array(GC.MAP_NONE, GC.MAP_NONE, GC.MAP_NONE, GC.MAP_NONE);
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
			
			if (type == GC.MAP_INDOOR)
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
			
			for (i = 0; i <= height; i += GC.MAP_TILE_SIZE)
			{
				for (j = 0; j <= width; j += GC.MAP_TILE_SIZE)
				{
					counter++;
					square = new GridSquare(j, i, counter, true);
					gridSquares.push(square);
				}
			}
			
			// find the collision rects from the xml
			// and set those squares to unwalkable that
			// overlap with the rects
			if (xml.solid[0] != null)
			{
				for each (var solid:XML in xml.solid[0].rect)
				{
					for (i = 0; i < gridSquares.length; i++)
					{
						var rect1:Rectangle = new Rectangle(gridSquares[i].x,
															gridSquares[i].y,
															GC.MAP_TILE_SIZE, GC.MAP_TILE_SIZE);
						var rect2:Rectangle = new Rectangle(solid.@x,
															solid.@y,
															solid.@w,
															solid.@h);
						if (rect1.intersects(rect2))
						{
							gridSquares[i].walkable = false;
						}
					}
				}
			}
		}
	}

}
