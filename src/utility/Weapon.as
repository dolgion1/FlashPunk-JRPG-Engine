package utility 
{
	/**
	 * ...
	 * @author dolgion
	 */
	public class Weapon extends Item
	{
		public static const NO_ATTACK:int = -1;
		public static const MELEE:int = 0;
		public static const RANGED:int = 1;
		
		public static const NO_DAMAGE:int = -1;
		public static const SLASHING:int = 0;
		public static const PIERCING:int = 1;
		public static const IMPACT:int = 2;
		public static const MAGIC:int = 3; 
		
		public var damageType:int;
		public var attackType:int;
		public var twoHanded:Boolean;
		public var damageRating:int;
		public var equipped:Boolean = false;
		
		public function Weapon() 
		{
			
		}
		
		public static function getDamageType(_type:int):String
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
		
		public static function getAttackType(_type:int):String
		{
			switch (_type)
			{
				case (0): return "Melee";
				case (1): return "Ranged";
				default: return "Unarmed";
			}
		}
	}

}