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
	public class Trees extends Entity
	{
		public var tilemap:Tilemap;
		
		public function Trees(map:XML)
		{
			type = GC.TYPE_TREE;
			graphic = tilemap = new Tilemap(GFX.TILES, map.width, map.height, GC.TREE_TILE_SIZE, GC.TREE_TILE_SIZE);
			if (map.trees[0])
			{
				for each (var tile:XML in map.trees[0].tile)
				{
					tilemap.setTile(tile.@x / GC.TREE_TILE_SIZE, tile.@y / GC.TREE_TILE_SIZE, 
									tilemap.getIndex(tile.@tx / GC.TREE_TILE_SIZE, tile.@ty / GC.TREE_TILE_SIZE));
				}
			}
		}
	}
}
