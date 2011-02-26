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
		
		public function Enemy(_maps:Array, 
							  _name:String, 
							  _spritesheetIndex:int, 
							  _position:GlobalPosition,
							  _appointments:Array,
							  _dialogs:Array,
							  _mobs:Array)
		{
			super(_maps, _name, _spritesheetIndex, _position, _appointments, _dialogs);
			this.type = GC.TYPE_ENEMY;
			mobs = _mobs;
		}
		
		override public function colliding():Boolean
		{
			return false;
		}
	}

}