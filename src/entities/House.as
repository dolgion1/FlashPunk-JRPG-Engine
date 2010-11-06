package entities
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.*;
	/**
	 * ...
	 * @author ...
	 */
	public class House extends Entity
	{
		[Embed (source = "../../assets/gfx/house.png")]
		private var HOUSE:Class;

		public var index:int;
		public var insideMapIndex:int;
		public var hitboxSize:int = 48;
		
		public function House(_index:int, _x:int, _y:int) 
		{
			type = "house";
			index = _index;
			x = _x;
			y = _y;
			
			graphic = new Image(HOUSE);
			setHitbox(hitboxSize, hitboxSize);
		}
		
	}

}
