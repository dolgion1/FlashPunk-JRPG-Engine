package entities
{
	import utility.Map;
	import net.flashpunk.*;
	import net.flashpunk.graphics.Image;
	
	/**
	 * ...
	 * @author ...
	 */
	public class WorldMapMarker extends Entity
	{
		[Embed(source = "../../assets/gfx/world_map_marker.png")]
		private var MAP_MARKER:Class;
		private var divisor:Number;
		private var image:Image;
		
		public function WorldMapMarker(player:Player, map:Map, indoors:Boolean, house:House)
		{
			
			graphic = image = new Image(MAP_MARKER, null);
			divisor = map.width / (FP.width / 2);
			
			if (!indoors)
			{
				// If the player is not indoors, mark the location of the player
				x = player.x / divisor + map.worldMapXOffset - image.width / 2;
				y = player.y / divisor + map.worldMapYOffset - image.height / 2;
			}
			else 
			{
				// If the player is inside a house, simply mark the location of the house
				x = house.x / divisor + map.worldMapXOffset;
				y = house.y / divisor + map.worldMapYOffset;
			}
		}
	}
}