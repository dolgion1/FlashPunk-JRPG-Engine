package entities
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	import utility.*;
	
	/**
	 * ...
	 * @author dolgion
	 */
	public class WorldMap extends Entity
	{
		public function WorldMap() 
		{
			graphic = new Image(GFX.WORLDMAP, null);
		}
		
	}

}