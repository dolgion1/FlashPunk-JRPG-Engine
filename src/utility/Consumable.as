package utility 
{
	/**
	 * ...
	 * @author dolgion
	 */
	public class Consumable extends Item
	{
		public var statusAlterations:Array = new Array();
		public var temporary:Boolean;
		public var duration:int;
		public var description:String;
		
		public function Consumable() {}
		
		/*public function Consumable(_statusAlterations:Array, _temporary:Boolean, _duration:int) 
		{
			statusAlterations = _statusAlterations;
			temporary = _temporary;
			duration = _duration;
		}*/
		
	}

}