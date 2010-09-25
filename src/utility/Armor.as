package utility 
{
	/**
	 * ...
	 * @author dolgion
	 */
	public class Armor extends Item
	{
		public static const HEAD:int = 0;
		public static const TORSO:int = 1;
		public static const LEGS:int = 2;
		public static const HANDS:int = 3;
		public static const FEET:int = 4;
		
		public var armorType:int;
		public var armorRating:int;
		public var equipped:Boolean = false;
		
		public function Armor() 
		{
			
		}
		
	}

}