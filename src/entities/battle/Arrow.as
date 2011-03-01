package entities.battle 
{
	import flash.geom.Point;
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import utility.*;
	
	/**
	 * ...
	 * @author dolgion
	 */
	public class Arrow extends Entity
	{
		public var spritemap:Spritemap;
		public var curAnimation:String = "left";
		
		public function Arrow()
		{
			setupSpritesheet();
			graphic = spritemap;
		}
		
		override public function update():void
		{
			spritemap.play(curAnimation);
		}
		
		public function setupSpritesheet():void
		{
			spritemap = new Spritemap(GFX.ARROW, GC.ARROW_SPRITE_WIDTH, GC.ARROW_SPRITE_HEIGHT);
			spritemap.add("right", [0], 1, false);
			spritemap.add("left", [1], 1, false);
		}
	}

}
