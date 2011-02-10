package utility
{
	import flash.geom.Point;
	import utility.*;
	
	/**
	 * ...
	 * @author dolgion
	 */
	public class Pathfinder
	{
		public var gridSquares:Array = new Array();
		public var closedNodes:Array;
		public var openNodes:Array;
		public var path:Array;
		public var startSquare:GridSquare;
		public var endSquare:GridSquare;
		
		public function Pathfinder() {}
		
		public function pathfinding(_startPoint:GlobalPosition, _endPoint:GlobalPosition, _maps:Array):Array
		{
			gridSquares = _maps[_startPoint.mapIndex].gridSquares;

			// figure out to which square the startPoint belongs
			startSquare = getGridSquare(_startPoint.point);
			
			// figure out to which square the endPoint belongs
			endSquare = getGridSquare(_endPoint.point);
			if (!endSquare.walkable) 
			{
				return null;
			}
			
			closedNodes = new Array(new Node(startSquare, 0, 0, 0, null));
			openNodes = new Array();
			path = new Array();
			
			findNextNode(0);
			return path;
		}
		
		public function findNextNode(currentNodeIndex:Number):void
		{
			// set the current node
			var node:Node = closedNodes[currentNodeIndex];
			
			// escape clause for ending the recursive procedure
			if (node.square.index == endSquare.index)
			{
				return;
			}
			
			// find all adjacent GridSquares to the current node
			// and push their nodes into the openNodes array, 
			// if they exist and fulfill the requirements (being walkable)	
			
			var currentSquare:GridSquare;
			
			// store all the points
			var testPoints:Array = new Array();
			testPoints.push(new Point(node.square.x, node.square.y - GC.PATHFINDER_TILE_SIZE)); // above
			testPoints.push(new Point(node.square.x + GC.PATHFINDER_TILE_SIZE, node.square.y)); // to the right
			testPoints.push(new Point(node.square.x, node.square.y + GC.PATHFINDER_TILE_SIZE)); // below
			testPoints.push(new Point(node.square.x - GC.PATHFINDER_TILE_SIZE, node.square.y)); // to the left
			
			/*
			 * For diagonal movement: be aware, it's almost certain they'll get stuck in 
			 * objects along the way
			 * 
			 * testPoints.push(new Point(node.square.x - 48, node.square.y - 48)); // upper left
			 * testPoints.push(new Point(node.square.x + 48, node.square.y - 48)); // upper right
			 * testPoints.push(new Point(node.square.x + 48, node.square.y + 48)); // lower right
			 * testPoints.push(new Point(node.square.x - 48, node.square.x + 48)); // lower left
			 */
			for (var i:int = 0; i < testPoints.length; i++)
			{
				// ignore the ones in closedNodes or that don't exist or those that aren't walkable
				var isClosedNode:Boolean = false;
				var isOpenNode:Boolean = false;
				currentSquare = getExactGridSquare(testPoints[i]);
				
				if (currentSquare == null)
				{
					continue;
				}
				
				for (var j:int = 0; j < closedNodes.length; j++)
				{
					if (closedNodes[j].square.index == currentSquare.index)
					{
						isClosedNode = true;
						break;
					}
				}
				if (isClosedNode) continue;
				
				// at this point it's okay to enter the square into openNodes as a new node
				var movementCost:int = GC.PATHFINDER_NORMAL_COST;

				// setting the cost, in case diagonal movement is enabled
				// if (i > 3) movementCost = DIAGONAL_COST;
				
				var heuristicCost:int = getHeuristicCost(currentSquare, endSquare);
				var fullCost:int = movementCost + heuristicCost;
				
				openNodes.push(new Node(currentSquare, fullCost, movementCost, heuristicCost, node));
			}
			
			/*
			 * At this point we have all the new openNodes freshly inserted,
			 * and now we just need to find the one with the lowest fullCost.
			 * Also, all openNodes must be moved to the closedNodes array, 
			 * so that we can empty it, for the next iteration
			 */
			var minCost:int = openNodes[0].fullCost;
			closedNodes.push(openNodes[0]);
			var nextNodeIndex:int = 0;
			
			for (i = 1; i < openNodes.length; i++)
			{
				if (openNodes[i].fullCost < minCost)
				{
					minCost = openNodes[i].fullCost;
					nextNodeIndex = i;
				}
				else closedNodes.push(openNodes[i]);
			}
			
			var lastIndex:int = closedNodes.push(openNodes[nextNodeIndex]) - 1;
			openNodes = new Array();
			path.push(new Point(closedNodes[lastIndex].square.x, closedNodes[lastIndex].square.y));
			findNextNode(lastIndex);
   		}
		
		public function getHeuristicCost(_startSquare:GridSquare, _endSquare:GridSquare):Number
		{
			var deltaX:Number = Math.abs(_startSquare.x - _endSquare.x);
			var deltaY:Number = Math.abs(_startSquare.y - _endSquare.y);
			
			var horizontalSteps:int = deltaX / GC.PATHFINDER_TILE_SIZE;
			var verticalSteps:int = deltaY / GC.PATHFINDER_TILE_SIZE;
			
			return ((horizontalSteps + verticalSteps) * 10);
		}
		
		public function getExactGridSquare(_position:Point):GridSquare
		{
			// figure out to which square the _x and _y values belong to
			for (var i:int = 0; i < gridSquares.length; i++)
			{
				// check the x coordinate
				if (gridSquares[i].x == _position.x && gridSquares[i].y  == _position.y)
				{
					// if the grid square isn't walkable, return null
					if (!gridSquares[i].walkable) return null;
					else return gridSquares[i];
				}
			}
			
			return null;
		}
		
		public function getGridSquare(_position:Point):GridSquare
		{
			// figure out to which square the _x and _y values belong to
			for (var i:int = 0; i < gridSquares.length; i++)
			{
				// check the x coordinate
				if (gridSquares[i].x <= _position.x && gridSquares[i].x + GC.PATHFINDER_TILE_SIZE > _position.x)
				{
					// if it's in the range of x, check the y coordinate
					if (gridSquares[i].y <= _position.y && gridSquares[i].y + GC.PATHFINDER_TILE_SIZE > _position.y)
					{
						return gridSquares[i];
					}
				}
			}
			
			return null;
		}
		
	}

}
