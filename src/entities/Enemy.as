package entities 
{
	import utility.*;
	
	/**
	 * ...
	 * @author dolgion1
	 */
	public class Enemy extends NPC 
	{
		public var mobs:Array = new Array();
		public var experiencePoints:int;
		public var defeated:Boolean = false;
		public var loot:Array = new Array();
		public var gold:int;
		
		public function Enemy(_maps:Array, 
							  _name:String, 
							  _spritesheetIndex:int, 
							  _position:GlobalPosition,
							  _appointments:Array,
							  _dialogs:Array,
							  _mobs:Array,
							  _experiencePoints:int,
							  _loot:Array,
							  _gold:int)
		{
			super(_maps, _name, _spritesheetIndex, _position, _appointments, _dialogs);
			this.type = GC.TYPE_ENEMY;
			mobs = _mobs;
			experiencePoints = _experiencePoints;
			loot = _loot;
			gold = _gold;
		}
		
		override public function colliding():Boolean
		{
			return false;
		}
	}

}
