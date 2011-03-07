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
		public var consumableType:int;
		public var spellName:String;
		
		public function Consumable() { }
		
		public function copy(_consumable:Consumable):void
		{
			name = _consumable.name;
			consumableType = _consumable.consumableType;
			description = _consumable.description;

			if (_consumable.consumableType == GC.CONSUMABLE_TYPE_POTION)
			{
				statusAlterations = _consumable.statusAlterations;
				duration = _consumable.duration;				
				temporary = _consumable.temporary;
			}
			else if (_consumable.consumableType == GC.CONSUMABLE_TYPE_SCROLL)
			{
				spellName = _consumable.spellName;
			}
		}
	}

}
