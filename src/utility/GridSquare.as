package utility 
{
	/**
	 * ...
	 * @author dolgion
	 */
	public class GridSquare
	{
		public var x:Number;
		public var y:Number;
		public var index:Number;
		public var walkable:Boolean;
		
		public function GridSquare(_x:Number, _y:Number, _index:Number, _walkable:Boolean) 
		{
			x = _x;
			y = _y;
			index = _index;
			walkable = _walkable;
		}
		
	}

}