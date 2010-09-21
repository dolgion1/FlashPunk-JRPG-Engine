package entities
{
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Text;
	/**
	 * ...
	 * @author ...
	 */
	public class DisplayText extends Entity
	{
		public var displayText:Text;
		public var xOffset:Number;
		public var yOffset:Number;
		
		public function DisplayText(_text:String, _xOffset:Number, _yOffset:Number, _font:String, _size:Number, _color:uint, _width:Number)
		{
			displayText = new Text("DEFAULT", 10, 10, _width, 0);
			super(x, y, displayText);
			
			xOffset = _xOffset;
			yOffset = _yOffset;
			displayText.text = _text;
			displayText.x = 0;
			displayText.y = 10;
			displayText.color = _color;
			displayText.size = _size;
			displayText.font = _font;
		}
		
		override public function update():void
		{
			x = FP.camera.x + xOffset;
			y = FP.camera.y + yOffset;
		}
	}
}