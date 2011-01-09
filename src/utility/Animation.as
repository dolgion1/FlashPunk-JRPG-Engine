package utility
{
	/**
	 * ...
	 * @author dolgion
	 */
	public class Animation
	{
		public var name:String;
		public var frames:Array;
		public var frameRate:int;
		public var loop:Boolean;

		public function Animation(_name:String, _frames:Array, _frameRate:int, _loop:Boolean):void
		{
			name = _name;
			frames = _frames;
			frameRate = _frameRate;
			loop = _loop;
		}
		
	}

}
