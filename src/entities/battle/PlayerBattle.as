package entities.battle 
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import utility.*;
	
	/**
	 * ...
	 * @author dolgion1
	 */
	public class PlayerBattle extends Entity
	{
		public var spritemap:Spritemap;
		public var curAnimation:String = "melee_left";
		
		public function PlayerBattle(_x:int, _y:int) 
		{
			setupSpritesheet();
			graphic = spritemap;
			spritemap.play(curAnimation);
			
			x = _x;
			y = _y;
		}
		
		override public function update():void
		{
			super.update();
			
			spritemap.play(curAnimation);
		}
		
		public function setupSpritesheet():void
		{
			spritemap = new Spritemap(GFX.PLAYER_BATTLE, GC.PLAYER_BATTLE_SPRITE_WIDTH, GC.PLAYER_BATTLE_SPRITE_HEIGHT);
			spritemap.add("stand_left", [0], 0, false);
			spritemap.add("stand_right", [1], 0, false);
			spritemap.add("ranged_left", [12], 0, false);
			spritemap.add("ranged_right", [13], 0, false);
			spritemap.add("melee_left", [24, 25, 26], 9, false);
			spritemap.add("melee_right", [27, 28, 29], 9, false);
			spritemap.add("walk_left", [36, 37, 38, 39, 40, 41], 9, true);
			spritemap.add("walk_right", [42, 43, 44, 45, 46, 47], 9, true);
			spritemap.add("cast_left", [48], 0, false);
			spritemap.add("cast_right", [49], 0, false);
		}
	}

}