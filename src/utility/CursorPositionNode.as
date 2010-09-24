package utility 
{
	/**
	 * ...
	 * @author dolgion
	 */
	public class CursorPositionNode
	{
		public var upKey:String;
		public var downKey:String;
		public var leftKey:String;
		public var rightKey:String;
		
		public function CursorPositionNode(_upKey:String,
										   _downKey:String, 
										   _leftKey:String,
										   _rightKey:String) 
		{
			upKey = _upKey;
			downKey = _downKey;
			leftKey = _leftKey;
			rightKey = _rightKey;
		}
		
	}

}