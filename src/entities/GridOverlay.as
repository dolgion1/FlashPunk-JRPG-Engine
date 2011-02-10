package entities 
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	import utility.GFX;
	import utility.GC;
	
	/**
	 * ...
	 * @author dolgion
	 */
	public class GridOverlay extends Entity
	{
		private var image:Image;
		
		public function GridOverlay(_x:Number, _y:Number, _width:Number, _height:Number) 
		{
			type = GC.TYPE_GRID_OVERLAY;
			x = _x;
			y = _y;
			width = _width;
			height = _height;
			setHitbox(_width, _height, 0, 0);
			image = new Image(GFX.GRID_OVERLAY);
			image.scaleX = _width/GC.GRID_OVERLAY_SCALE_DIVIDER;
			image.scaleY = _height/GC.GRID_OVERLAY_SCALE_DIVIDER;
			graphic = image;
		}
	}

}
