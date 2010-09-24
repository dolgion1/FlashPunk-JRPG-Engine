package entities 
{
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	
	
	/**
	 * ...
	 * @author dolgion
	 */
	public class PlayerPortrait extends Entity
	{
		[Embed(source = "../../assets/gfx/player_portrait.png")] public const PLAYER_PORTRAIT:Class;
		
		public var xOffset:int;
		public var yOffset:int;
		
		public function PlayerPortrait(_xOffset:int, _yOffset:int)
		{
			graphic = new Image(PLAYER_PORTRAIT);
			xOffset = _xOffset;
			yOffset = _yOffset;
		}
		
		override public function update():void
		{
			x = FP.camera.x + xOffset;
			y = FP.camera.y + yOffset;
		}
	}

}