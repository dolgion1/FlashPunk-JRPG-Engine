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
		public var resistances:Array = new Array();
		
		public function Armor() 
		{
			
		}
		
		public static function getArmorType(_type:int):String
		{
			switch (_type)
			{
				case (HEAD): return "Head";
				case (TORSO): return "Torso";
				case (LEGS): return "Legs";
				case (HANDS): return "Hands";
				case (FEET): return "Feet";
				default: return "";
			}
		}
		
		public static function getResistance(_type:int):String
		{
			switch (_type)
			{
				case (0): return "Slashing";
				case (1): return "Piercing";
				case (2): return "Impact";
				case (3): return "Magic";
				default: return "Unarmed";
			}
		}
	}

}