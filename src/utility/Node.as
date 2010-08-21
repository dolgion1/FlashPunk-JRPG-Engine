package utility 
{
	/**
	 * ...
	 * @author dolgion
	 */
	public class Node
	{
		public var square:GridSquare;
		public var fullCost:Number;
		public var movementCost:Number;
		public var heuristicCost:Number;
		public var parentNode:Node;
		
		public function Node(_square:GridSquare, _fullCost:Number,
							 _movementCost:Number, _heuristicCost:Number,
							 _parentNode:Node) 
		{
			square = _square;
			fullCost = _fullCost;
			movementCost = _movementCost;
			heuristicCost = _heuristicCost;
			parentNode = _parentNode;
		}
		
	}

}