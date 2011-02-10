package utility 
{
	/**
	 * ...
	 * @author dolgion
	 */
	public class Weapon extends Item
	{
		public var damageType:int;
		public var attackType:int;
		public var twoHanded:Boolean;
		public var damageRating:int;
		public var equipped:Boolean = false;
		
		public function Weapon() {}
		
		public static function getDamageType(_type:int):String
		{
			switch (_type)
			{
				case (GC.DAMAGE_TYPE_SLASHING): return GC.DAMAGE_TYPE_SLASHING_STRING;
				case (GC.DAMAGE_TYPE_PIERCING): return GC.DAMAGE_TYPE_PIERCING_STRING;
				case (GC.DAMAGE_TYPE_IMPACT): return GC.DAMAGE_TYPE_IMPACT_STRING;
				case (GC.DAMAGE_TYPE_MAGIC): return GC.DAMAGE_TYPE_MAGIC_STRING;
				case (GC.DAMAGE_TYPE_NO_DAMAGE): return GC.DAMAGE_TYPE_NO_DAMAGE_STRING;
				default: return "";
			}
		}
		
		public static function getAttackType(_type:int):String
		{
			switch (_type)
			{
				case (GC.ATTACK_TYPE_MELEE): return GC.ATTACK_TYPE_MELEE_STRING;
				case (GC.ATTACK_TYPE_RANGED): return GC.ATTACK_TYPE_RANGED_STRING;
				case (GC.ATTACK_TYPE_NO_ATTACK): return GC.ATTACK_TYPE_NO_ATTACK_STRING;
				default: return "";
			}
		}
	}

}