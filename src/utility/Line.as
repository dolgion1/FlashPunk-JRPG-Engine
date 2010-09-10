package utility 
{
	/**
	 * ...
	 * @author dolgion
	 */
	public class Line
	{
		// tells us if it's the first second or third or whatever general
		// line in the conversation it is
		public var index:int;
		// each line can have multiple versions, for multiple-choice and
		// -answers. It's an array of strings
		public var versions:Array = new Array();
		
		public function Line(_index:int, _versions:Array) 
		{
			index = _index;
			versions = _versions;
		}
		
	}

}