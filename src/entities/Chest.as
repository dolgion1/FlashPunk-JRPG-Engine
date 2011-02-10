package entities 
{
	import flash.geom.Point;
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Spritemap;
	import utility.*;
	import worlds.Game;
	
	/**
	 * ...
	 * @author dolgion1
	 */
	public class Chest extends Entity
	{
		public var currentMapIndex:int;
		public var faceDirection:String;
		public var items:Array = new Array();
		
		public var chestSpritemap:Spritemap = new Spritemap(GFX.CHEST_SPRITESHEET, GC.CHEST_SPRITE_WIDTH, GC.CHEST_SPRITE_HEIGHT);
		
		public function Chest(_position:GlobalPosition, _faceDirection:String)
		{
			setupSpritesheet();
			
			graphic = chestSpritemap;
			faceDirection = _faceDirection;
			
			switch (faceDirection)
			{
				case "down": chestSpritemap.play("idle_face_down"); break;
				case "right": chestSpritemap.play("idle_face_right"); break;
				case "left": chestSpritemap.play("idle_face_left"); break;
				case "up": chestSpritemap.play("idle_face_up"); break;
			}
			
			x = _position.x;
			y = _position.y;
			currentMapIndex = _position.mapIndex;
			
			setHitbox(GC.CHEST_SPRITE_WIDTH, GC.CHEST_SPRITE_HEIGHT, 0, 0);
			type = GC.TYPE_CHEST;
			
			items.push(new Array());
			items.push(new Array());
			items.push(new Array());
		}
		
		override public function update():void
		{
			if (currentMapIndex != Game.currentMapIndex)
			{
				collidable = false;
				visible = false;
			}
			else 
			{
				collidable = true;
				visible = true;
			}
		}
		
		public function empty():void
		{
			items[GC.ITEM_WEAPON] = new Array();
			items[GC.ITEM_ARMOR] = new Array();
			items[GC.ITEM_CONSUMABLE] = new Array();
		}
		
		private function setupSpritesheet():void
		{
			chestSpritemap.add("idle_face_down", [0], 0, false);
			chestSpritemap.add("idle_face_right", [4], 0, false);
			chestSpritemap.add("idle_face_left", [8], 0, false);
			chestSpritemap.add("idle_face_up", [12], 0, false);
			chestSpritemap.add("open_face_down", [0, 1, 2, 3], 10, false);
			chestSpritemap.add("open_face_right", [4, 5, 6, 7], 10, false);
			chestSpritemap.add("open_face_left", [8, 9, 10, 11], 10, false);
			chestSpritemap.add("open_face_up", [12, 13, 14, 15], 10, false);
		}
		
	}

}