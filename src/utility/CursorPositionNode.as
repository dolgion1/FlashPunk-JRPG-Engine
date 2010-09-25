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
			if (_upKey != "null") upKey = _upKey;
			else upKey = null;
			
			if (_downKey != "null") downKey = _downKey;
			else downKey = null;
			
			if (_leftKey != "null") leftKey = _leftKey;
			else leftKey = null;
			
			if (_rightKey != "null") rightKey = _rightKey;
			else rightKey = null;
		}
		
	}

}