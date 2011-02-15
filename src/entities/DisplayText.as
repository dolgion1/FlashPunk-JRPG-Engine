package entities
{
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Text;
	
	/**
	 * ...
	 * @author dolgion
	 */
	public class DisplayText extends Entity
	{
		public var displayText:Text;
		
		public function DisplayText(_text:String, _x:Number, _y:Number, _font:String, _size:Number, _color:uint, _width:Number)
		{
			displayText = new Text("DEFAULT", 10, 10, _width, 0);
			super(x, y, displayText);
			
			x = _x;
			y = _y;
			displayText.text = _text;
			displayText.x = 0;
			displayText.y = 10;
			displayText.color = _color;
			displayText.size = _size;
			displayText.font = _font;
			displayText.scrollX = 0;
			displayText.scrollY = 0;
		}
	}
}
