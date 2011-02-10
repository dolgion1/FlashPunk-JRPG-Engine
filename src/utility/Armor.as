package utility 
{
	/**
	 * ...
	 * @author dolgion
	 */
	public class Armor extends Item
	{
		public var armorType:int;
		public var armorRating:int;
		public var equipped:Boolean = false;
		public var resistances:Array = new Array();
		
		public function Armor() {}
		
		public static function getArmorType(_type:int):String
		{
			switch (_type)
			{
				case (GC.ARMOR_TYPE_HEAD): return GC.BODY_PART_HEAD_STRING;
				case (GC.ARMOR_TYPE_TORSO): return GC.BODY_PART_TORSO_STRING;
				case (GC.ARMOR_TYPE_LEGS): return GC.BODY_PART_LEGS_STRING;
				case (GC.ARMOR_TYPE_HANDS): return GC.BODY_PART_HANDS_STRING;
				case (GC.ARMOR_TYPE_FEET): return GC.BODY_PART_FEET_STRING;
				default: return "";
			}
		}
		
		public static function getResistance(_type:int):String
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
	}

}