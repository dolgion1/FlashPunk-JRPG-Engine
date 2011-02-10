package entities
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.*;
	import utility.*;
	
	/**
	 * ...
	 * @author dolgion
	 */
	public class House extends Entity
	{
		public var index:int;
		public var insideMapIndex:int;
		
		public function House(_index:int, _x:int, _y:int) 
		{
			type = GC.TYPE_HOUSE;
			index = _index;
			x = _x;
			y = _y;
			
			graphic = new Image(GFX.HOUSE);
			setHitbox(GC.HOUSE_HITBOX_SIZE, GC.HOUSE_HITBOX_SIZE);
		}
		
	}

}
