package entities 
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	/**
	 * ...
	 * @author dolgion
	 */
	public class GridOverlay extends Entity
	{
		[Embed (source = "../../assets/gfx/grid_overlay_small.png")]
		private var GRID_OVERLAY:Class;
		private var scaleDivider:int = 16;
		private var image:Image;
		
		public function GridOverlay(_x:Number, _y:Number, _width:Number, _height:Number) 
		{
			type = "grid_overlay";
			x = _x;
			y = _y;
			width = _width;
			height = _height;
			setHitbox(_width, _height, 0, 0);
			image = new Image(GRID_OVERLAY);
			image.scaleX = _width/scaleDivider;
			image.scaleY = _height/scaleDivider;
			graphic = image;
		}
	}

}
