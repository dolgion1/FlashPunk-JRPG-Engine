package utility 
{
	/**
	 * ...
	 * @author dolgion
	 */
	public class Dialog
	{
		public var partner:String;
		public var index:int;
		public var lines:Array = new Array();
		
		public function Dialog(_partner:String, _index:int, _lines:Array) 
		{
			partner = _partner;
			index = _index;
			lines = _lines;
		}
		
	}

}