package entities.battle 
{
	import net.flashpunk.*;
	import net.flashpunk.utils.*;
	import net.flashpunk.graphics.*;
	import utility.*;
	import flash.geom.Point;
	
	
	/**
	 * ...
	 * @author dolgion1
	 */
	public class PlayerBattle extends Entity
	{
		public var spritemap:Spritemap;
		public var curAnimation:String = "stand_left";
		public var moving:Boolean = false;
		public var delta:Point = new Point(0, 0); 
		public var targetPosition:Point;
		public var arrow:Arrow = new Arrow();
		public var arrowMoving:Boolean = false;
		
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
			
			if (moving)
			{
				x -= delta.x / FP.assignedFrameRate;
				y -= delta.y / FP.assignedFrameRate;
				
				if ((Math.abs(x - targetPosition.x) < 50) &&
					(Math.abs(y - targetPosition.y) < 50))
				{
					if (curAnimation == "walk_left")
					{
						curAnimation = "melee_left";
						targetPosition = new Point(GC.BATTLE_PLAYER_X, GC.BATTLE_PLAYER_Y);
						delta.x = x - targetPosition.x;
						delta.y = y - targetPosition.y;
						moving = false;
					}
					else if (curAnimation == "walk_right")
					{
						moving = false;
						curAnimation = "stand_left";
					}
				}
			}
			else if (arrowMoving)
			{
				arrow.x -= delta.x / FP.assignedFrameRate;
				arrow.y -= delta.y / FP.assignedFrameRate; 
				
				if ((Math.abs(arrow.x - targetPosition.x) < 50) &&
					(Math.abs(arrow.y - targetPosition.y) < 50))
				{
					this.world.remove(arrow);
					arrowMoving = false;
				}
			}
				
		}
		
		public function setupSpritesheet():void
		{
			spritemap = new Spritemap(GFX.PLAYER_BATTLE, GC.PLAYER_BATTLE_SPRITE_WIDTH, GC.PLAYER_BATTLE_SPRITE_HEIGHT);
			spritemap.add("stand_left", [0], 0, false);
			spritemap.add("stand_right", [1], 0, false);
			spritemap.add("ranged_left", [12, 0], 3, false);
			spritemap.add("ranged_right", [13, 1], 3, false);
			spritemap.add("melee_left", [24, 25, 26], 9, false);
			spritemap.add("melee_right", [27, 28, 29], 9, false);
			spritemap.add("walk_left", [36, 37, 38, 39, 40, 41], 9, true);
			spritemap.add("walk_right", [42, 43, 44, 45, 46, 47], 9, true);
			spritemap.add("cast_left", [48], 0, false);
			spritemap.add("cast_right", [49], 0, false);
			spritemap.callback = animationCallback;
		}
		
		public function meleeAttack(_targetPosition:Point):void
		{
			curAnimation = "walk_left";
			moving = true;
			
			targetPosition = _targetPosition;
			delta.x = x - _targetPosition.x;
			delta.y = y - _targetPosition.y;
		}
		
		public function rangedAttack(_targetPosition:Point):void
		{
			curAnimation = "ranged_left";
			
			// make the arrow fly towards the targetposition
			arrowMoving = true;
			arrow.x = this.x;
			arrow.y = this.y + 40;
			this.world.add(arrow);
			
			targetPosition = _targetPosition;
			targetPosition.y += 100;
			delta.x = arrow.x - targetPosition.x;
			delta.y = arrow.y - targetPosition.y;
		}
		
		public function animationCallback():void
		{
			if (curAnimation == "melee_left")
			{
				curAnimation = "walk_right";
				moving = true;
			}
			
			if (curAnimation == "ranged_left")
			{
				FP.log("ranged is done");
				curAnimation = "stand_left";
			}
		}
	}

}
