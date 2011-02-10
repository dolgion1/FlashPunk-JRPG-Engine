package entities
{
	import utility.*;
	import net.flashpunk.*;
	import net.flashpunk.graphics.Image;
	
	/**
	 * ...
	 * @author dolgion
	 */
	public class WorldMapMarker extends Entity
	{
		private var divisor:Number;
		private var image:Image;
		
		public function WorldMapMarker(player:Player, map:Map, indoors:Boolean, house:House)
		{
			graphic = image = new Image(GFX.WORLDMAP_MARKER, null);
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