package entities.inventory 
{
	import flash.geom.Point;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import utility.GFX;
	
	/**
	 * ...
	 * @author dolgion
	 */
	public class CursorEquip extends Entity
	{
		public var xOffset:int;
		public var yOffset:int;
		
		public function CursorEquip(_xOffset:int, _yOffset:int)
		{
			graphic = new Image(GFX.CURSOR_EQUIP);
			xOffset = _xOffset;
			yOffset = _yOffset;
		}
		
		public function set position(_position:Point):void
		{
			xOffset = _position.x;
			yOffset = _position.y;
		}
		
		override public function update():void
		{
			x = FP.camera.x + xOffset;
			y = FP.camera.y + yOffset;
		}
	}

}