package entities 
{
	import flash.geom.Point;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	/**
	 * ...
	 * @author dolgion
	 */
	public class Cursor extends Entity
	{
		[Embed(source = "../../assets/gfx/cursor.png")] public const CURSOR:Class;
		
		public var xOffset:int;
		public var yOffset:int;
		
		public function Cursor(_xOffset:int, _yOffset:int)
		{
			graphic = new Image(CURSOR);
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