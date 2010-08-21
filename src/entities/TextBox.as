package entities 
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Text;
	
	/**
	 * ...
	 * @author dolgion
	 */
	public class TextBox extends Entity
	{
		[Embed (source = "../../assets/gfx/text_box_background.png")]
		public const TEXT_BOX:Class;
		public var xOffset:Number;
		public var yOffset:Number;
		
		public function TextBox(_xOffset:Number, _yOffset:Number) 
		{
			graphic = new Image(TEXT_BOX);
			
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