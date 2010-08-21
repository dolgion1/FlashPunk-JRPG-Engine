package entities 
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.Grid;
	
	/**
	 * ...
	 * @author dolgion
	 */
	public class Trees extends Entity
	{
		[Embed(source = "../../assets/gfx/tiles.png")]
		private var TILES:Class;
		
		public var tilemap:Tilemap;
		
		public function Trees(map:XML)
		{
			type = "tree";
			graphic = tilemap = new Tilemap(TILES, map.width, map.height, 48, 48);
			if (map.trees[0])
			{
				for each (var tile:XML in map.trees[0].tile)
				{
					tilemap.setTile(tile.@x / 48, tile.@y / 48, tilemap.getIndex(tile.@tx / 48, tile.@ty / 48));
				}
			}
		}
	}
}