package entities.battle 
{
	import flash.geom.Point;
	import net.flashpunk.graphics.*;
	import utility.*;
	import entities.*;
	
	/**
	 * ...
	 * @author dolgion1
	 */
	public class ZeldaBattle extends EnemyBattle
	{
		
		public function ZeldaBattle(_position:Point, _keyIndex:int) 
		{
			setupSpritesheets();
			curAnimation = "stand_right";
			health = GC.ENEMY_HEALTH_ZELDA;
			maxHealth = GC.ENEMY_HEALTH_ZELDA;
			mana = GC.ENEMY_MANA_ZELDA;
			maxMana = GC.ENEMY_MANA_ZELDA;
			strength = GC.ENEMY_STRENGTH_ZELDA;
			agility = GC.ENEMY_AGILITY_ZELDA;
			spirituality = GC.ENEMY_SPIRITUALITY_ZELDA;
			damageRating = GC.ENEMY_DAMAGE_RATING_ZELDA;
			armorRating = GC.ENEMY_ARMOR_RATING_ZELDA;
			
			super(_position, _keyIndex);
		}
		
		public function setupSpritesheets():void
		{
			spritemap = new Spritemap(GFX.ZELDA_BATTLE, GC.ZELDA_BATTLE_SPRITE_WIDTH, GC.ZELDA_BATTLE_SPRITE_HEIGHT);
			spritemap.add("stand_right", [0], 0, false);
			spritemap.add("stand_left", [1], 0, false);
			spritemap.add("walk_right", [5, 6, 7, 8, 9], 9, true);
			spritemap.add("walk_left", [10, 11, 12, 13, 14], 9, true);
			spritemap.add("cast_right", [15, 16, 17, 18, 19], 9, false);
			spritemap.add("cast_left", [20, 21, 22, 23, 24], 9, false);
			spritemap.add("melee_right", [25, 26, 27, 28], 9, true);
			spritemap.add("melee_left", [30, 31, 32, 33], 9, false);
		}
	}

}
