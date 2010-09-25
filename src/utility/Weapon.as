package utility 
{
	/**
	 * ...
	 * @author dolgion
	 */
	public class Weapon extends Item
	{
		public const MELEE:int = 0;
		public const RANGED:int = 1;
		
		public const SLASHING:int = 0;
		public const PIERCING:int = 1;
		public const IMPACT:int = 2;
		public const MAGIC:int = 3; 
		
		public var damageType:int;
		public var attackType:int;
		public var twoHanded:Boolean;
		public var damageRating:int;
		public var equipped:Boolean = false;
		
		public function Weapon() 
		{
			
		}
		
	}

}