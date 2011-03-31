package entities 
{
	import utility.*;
	
	/**
	 * ...
	 * @author dolgion1
	 */
	public class Enemy extends NPC 
	{
		// stores the instances of mobs that this enemy(-group) contains
		public var mobs:Array = new Array();
		
		// amount of experience points the player will gain when defeating the mobs
		public var experiencePoints:int;
		public var defeated:Boolean = false;
		public var loot:Array = new Array(); // an inventory of items that can be looted
		public var gold:int; // amount of gold to be had for the player
		
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
