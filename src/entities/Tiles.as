package entities 
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.Grid;
	import utility.*;
	
	/**
	 * ...
	 * @author dolgion
	 */
	public class Tiles extends Entity
	{
		public var tilemap:Tilemap;
		public var grid:Grid;
		
		public function Tiles(map:XML)
		{
			type = GC.TYPE_TILES;
			graphic = tilemap = new Tilemap(GFX.TILES, map.width, map.height, GC.TILES_TILE_SIZE, GC.TILES_TILE_SIZE);
			for each (var tile:XML in map.ground[0].tile)
			{
				tilemap.setTile(tile.@x / GC.TILES_TILE_SIZE, tile.@y / GC.TILES_TILE_SIZE, 
								tilemap.getIndex(tile.@tx / GC.TILES_TILE_SIZE, tile.@ty / GC.TILES_TILE_SIZE));
			}
			
			mask = grid = new Grid(map.width, map.height, GC.TILES_RECT_SIZE, GC.TILES_RECT_SIZE);
			if (map.solid[0] != null) 
			{
				for each (var solid:XML in map.solid[0].rect)
				{
					grid.setRect(solid.@x / GC.TILES_RECT_SIZE, solid.@y / GC.TILES_RECT_SIZE, 
								 solid.@w / GC.TILES_RECT_SIZE, solid.@h / GC.TILES_RECT_SIZE);
				}
			}
		}
	}
}
