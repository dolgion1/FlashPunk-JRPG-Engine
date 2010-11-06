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
		public var tileSize:int = 48;
		
		public function Trees(map:XML)
		{
			type = "tree";
			graphic = tilemap = new Tilemap(TILES, map.width, map.height, tileSize, tileSize);
			if (map.trees[0])
			{
				for each (var tile:XML in map.trees[0].tile)
				{
					tilemap.setTile(tile.@x / tileSize, tile.@y / tileSize, tilemap.getIndex(tile.@tx / tileSize, tile.@ty / tileSize));
				}
			}
		}
	}
}
