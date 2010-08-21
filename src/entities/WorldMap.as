package entities
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	/**
	 * ...
	 * @author ...
	 */
	public class WorldMap extends Entity
	{
		[Embed(source = "../../assets/gfx/world_map.png")] public var WORLDMAP:Class;
		
		public function WorldMap() 
		{
			graphic = new Image(WORLDMAP, null);
		}
		
	}

}