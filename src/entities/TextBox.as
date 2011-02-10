package entities 
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Text;
	import utility.*;
	
	/**
	 * ...
	 * @author dolgion
	 */
	public class TextBox extends Entity
	{
		public var xOffset:Number;
		public var yOffset:Number;
		public var image:Image;
		
		public function TextBox(_xOffset:Number, _yOffset:Number, _scaleX:Number, _scaleY:Number) 
		{
			image = new Image(GFX.TEXT_BOX);
			image.scaleX = _scaleX;
			image.scaleY = _scaleY;
			graphic = image;
			
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