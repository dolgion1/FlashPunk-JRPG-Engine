package utility 
{
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author dolgion1
	 */
	public class CursorPosition 
	{
		public var x:int;
		public var y:int;
		public var valid:Boolean;
		public var key:String;
		
		public var upKey:String;
		public var downKey:String;
		public var leftKey:String;
		public var rightKey:String; 
		
		public function CursorPosition() {}
		
		public function setKeys(_upKey:String,
								_downKey:String, 
								_leftKey:String,
								_rightKey:String):void 
		{
			if (_upKey != "null") upKey = _upKey;
			if (_downKey != "null") downKey = _downKey;
			if (_leftKey != "null") leftKey = _leftKey;
			if (_rightKey != "null") rightKey = _rightKey;
		}
		
		public function getPosition():Point
		{
			return new Point(x, y);
		}
	}
}