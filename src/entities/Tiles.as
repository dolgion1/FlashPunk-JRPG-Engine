package entities 
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.Grid;
	import utility.GridSquare;
	
	/**
	 * ...
	 * @author dolgion
	 */
	public class Tiles extends Entity
	{
		[Embed(source = "../../assets/gfx/tiles.png")]
		private var TILES:Class;
		private const TILE_SIZE:Number = 48;
		private const RECT_SIZE:Number = 16;
		public var tilemap:Tilemap;
		public var grid:Grid;
		
		public function Tiles(map:XML)
		{
			type = "solid";
			graphic = tilemap = new Tilemap(TILES, map.width, map.height, TILE_SIZE, TILE_SIZE);
			for each (var tile:XML in map.ground[0].tile)
			{
				tilemap.setTile(tile.@x / TILE_SIZE, tile.@y / TILE_SIZE, tilemap.getIndex(tile.@tx / TILE_SIZE, tile.@ty / TILE_SIZE));
			}
			
			mask = grid = new Grid(map.width, map.height, RECT_SIZE, RECT_SIZE);
			if (map.solid[0] != null) 
			{
				for each (var solid:XML in map.solid[0].rect)
				{
					grid.setRect(solid.@x / RECT_SIZE, solid.@y / RECT_SIZE, solid.@w / RECT_SIZE, solid.@h / RECT_SIZE);
				}
			}
		}
	}
}