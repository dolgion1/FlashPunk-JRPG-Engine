package utility 
{
	import flash.geom.Point;
	import utility.*;
	/**
	 * ...
	 * @author dolgion
	 */
	public class MapPathfinder
	{
		
		private var maps:Array = new Array();
		private var mapPath:Array = new Array();
		private var startMapIndex:int;
		private var endMapIndex:int;
		private var queue:Array = new Array();
		private var visitedMaps:Array = new Array();
		
		public function MapPathfinder() {}
		
		public function pathfinding(_maps:Array, _startMapIndex:int, _endMapIndex:int):Array
		{
			maps = _maps;
			startMapIndex = _startMapIndex;
			endMapIndex = _endMapIndex;
			visitedMaps = new Array();
			mapPath = new Array();
			determineMapPath(startMapIndex);
			mapPath.reverse();
			return mapPath;
		}
		
		public function findNextExitPoint(maps:Array, mapPath:Array, mapPathIndex:int, x:int, y:int, endPoint:GlobalPosition):GlobalPosition
		{
			if (mapPathIndex == (mapPath.length - 1))
			{
				return endPoint;
			}
			
			// find the exit point to the next map
			var i:int;
			var exitPoint:GlobalPosition;
			var currentMap:Map = maps[mapPath[mapPathIndex]];
			var nextMap:Map = maps[mapPath[mapPathIndex + 1]];
			
			if (currentMap.type == Map.OUTDOOR && nextMap.type == Map.OUTDOOR)
			{
				// find the direction to the next map
				var exitDirection:int;
				for (i = 0; i < currentMap.exits.length; i++)
				{
					if (currentMap.exits[i] == nextMap.index)
					{
						// i is now the direction
						switch (i)
						{
							case (Map.NORTH): exitPoint = new GlobalPosition(currentMap.index, x, 0); break;
							case (Map.EAST): exitPoint = new GlobalPosition(currentMap.index, currentMap.width - 48, y); break;
							case (Map.SOUTH): exitPoint = new GlobalPosition(currentMap.index, x, currentMap.height - 48); break;
							case (Map.WEST): exitPoint = new GlobalPosition(currentMap.index, 0, y); break;
						}
					}
				}
			}
			else if (currentMap.type == Map.OUTDOOR && nextMap.type == Map.INDOOR)
			{
				// go to one of the child maps
				var exit:GlobalPosition;
				for each (exit in currentMap.transitionPoints)
				{
					if (exit.mapIndex == nextMap.index)
					{
						exitPoint = new GlobalPosition(currentMap.index, exit.x, exit.y);
						break;
					}
				}
			}
			else if (currentMap.type == Map.INDOOR)
			{
				exitPoint = new GlobalPosition(currentMap.index, currentMap.transitionPoints[0].x, currentMap.transitionPoints[0].y);
			}
			
			return exitPoint;
		}
		
		public function determineNewStartingPosition(maps:Array, mapPath:Array, mapPathIndex:int, x:int, y:int):Point
		{
			var i:int;
			var previousMap:Map = maps[mapPath[mapPathIndex - 1]];
			var newMap:Map = maps[mapPath[mapPathIndex]];
			var startingPoint:Point = new Point();
			
			if (previousMap.type == Map.OUTDOOR && newMap.type == Map.OUTDOOR)
			{
				// find from which direction the npc came
				for (i = 0; i < previousMap.exits.length; i++)
				{
					if (previousMap.exits[i] == newMap.index)
					{
						switch (i)
						{
							case Map.NORTH: startingPoint.y = newMap.height - 48; startingPoint.x = x; break;
							case Map.EAST: startingPoint.x = 0; startingPoint.y = y; break;
							case Map.SOUTH: startingPoint.y = 0; startingPoint.x = x; break;
							case Map.WEST: startingPoint.x = newMap.width - 48; startingPoint.y = y; break;
						}
					}
				}
			}
			else if (previousMap.type == Map.OUTDOOR && newMap.type == Map.INDOOR)
			{
				startingPoint.x = newMap.transitionPoints[0].x;
				startingPoint.y = newMap.transitionPoints[0].y;
			}
			else 
			{
				// loop through the startingPoints and find the one with the mapIndex of the previous map
				for (i = 0; i < newMap.transitionPoints.length; i++)
				{
					if (newMap.transitionPoints[i].mapIndex == previousMap.index)
					{
						startingPoint.x = newMap.transitionPoints[i].x;
						startingPoint.y = newMap.transitionPoints[i].y;
					}
				}
			}
			
			return startingPoint;
		}
		
		public function determineMapPath(curMapIndex:int):Boolean
		{
			var i:int;
			var result:Boolean;

			if (curMapIndex == endMapIndex) 
			{
				mapPath.push(curMapIndex);
				visitedMaps.push(curMapIndex);
				return true;
			}
			
			if (maps[curMapIndex].type == Map.INDOOR)
			{
				// If the map is indoors, there are only 2 possible outcomes
				// 1. It is the starting map
				// 2. It is a dead end, move back
				
				if (startMapIndex == curMapIndex) 
				{
					visitedMaps.push(curMapIndex);
					result = determineMapPath(maps[curMapIndex].outsideMapIndex);
					if (result)
					{
						mapPath.push(curMapIndex);
						return true;
					}
					else return false;
				}
				else 
				{
					visitedMaps.push(curMapIndex);
					return false;
				}
			}
			else if (maps[curMapIndex].type == Map.OUTDOOR)
			{
				// go through children maps
				for (i = 0; i < maps[curMapIndex].childMaps.length; i++)
				{
					if (visitedMaps.indexOf(maps[curMapIndex].childMaps[i], 0) == ( -1))
					{
						result = determineMapPath(maps[curMapIndex].childMaps[i]);
						if (result)
						{
							mapPath.push(curMapIndex);
							return true;
						}
					}
				}
								
				// go through children maps
				for (i = 0; i < maps[curMapIndex].exits.length; i++)
				{
					if (maps[curMapIndex].exits[i] != Map.NONE) 
					{
						if (visitedMaps.indexOf(maps[curMapIndex].exits[i], 0) == ( -1))
						{
							result = determineMapPath(maps[curMapIndex].exits[i]);
							visitedMaps.push(curMapIndex);
							if (result)
							{
								mapPath.push(curMapIndex);
								return true;
							}
						}
					}
				}
				visitedMaps.push(curMapIndex);

			}
			return false;
		}
	}

}