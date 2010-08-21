package utility 
{
	import flash.geom.Point;
	/**
	 * ...
	 * @author dolgion
	 */
	public class GlobalPosition
	{
		public var mapIndex:int;
		public var x:int;
		public var y:int;
		
		public function GlobalPosition(_mapIndex:int, _x:int, _y:int) 
		{
			x = _x;
			y = _y;
			mapIndex = _mapIndex;
		}
		
		public function get point():Point
		{
			return new Point(x, y);
		}
		
		public function set point(_point:Point):void
		{
			x = _point.x;
			y = _point.y;
		}
	}

}