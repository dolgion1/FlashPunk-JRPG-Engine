package entities.battle 
{
	import net.flashpunk.*;
	import net.flashpunk.utils.*;
	import net.flashpunk.graphics.*;
	import utility.*;
	import flash.geom.Point;
	import entities.*;
	
	/**
	 * ...
	 * @author dolgion1
	 */
	public class PlayerBattle extends Entity
	{
		public var spritemap:Spritemap;
		public var curAnimation:String = "stand_left";
		public var moving:Boolean = false;
		public var meleeTwice:Boolean = false;
		public var delta:Point = new Point(0, 0); 
		public var targetPosition:Point;
		public var arrow:Arrow = new Arrow();
		public var arrowMoving:Boolean = false;
		public var statDisplay:DisplayText;
		
		public var targetEnemy:EnemyBattle;
		public var player:Player;
		
		public function PlayerBattle(_x:int, _y:int, _player:Player) 
		{
			setupSpritesheet();
			graphic = spritemap;
			spritemap.play(curAnimation);
			
			x = _x;
			y = _y;
			player = _player;
			
			statDisplay = new DisplayText(player.health + "/" + player.maxHealth + " " + player.mana + "/" + player.maxMana, 
										  x + 40, 
										  y - 30, 
										  "default", 
										  GC.INVENTORY_DEFAULT_FONT_SIZE, 
										  0xFFFFFF, 
										  500);
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
						calculateDamage("WeaponEquipPrimary");
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
					calculateDamage("WeaponEquipPrimary");
				}
			}
				
		}
		
		public function updateStatDisplay():void
		{
			statDisplay.displayText.text = player.health + "/" + player.maxHealth + " " + player.mana + "/" + player.maxMana;
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
		
		public function meleeAttack(_targetPosition:Point, _enemy:EnemyBattle, _meleeTwice:Boolean):void
		{
			curAnimation = "walk_left";
			moving = true;
			meleeTwice = _meleeTwice;
			
			targetPosition = new Point(_targetPosition.x, _targetPosition.y);
			targetPosition.y += 40;
			
			delta.x = x - targetPosition.x;
			delta.y = y - targetPosition.y;
			
			targetEnemy = null;
			targetEnemy = _enemy;
		}
		
		public function rangedAttack(_targetPosition:Point, _enemy:EnemyBattle):void
		{
			curAnimation = "ranged_left";
			
			// make the arrow fly towards the targetposition
			arrowMoving = true;
			arrow.x = this.x;
			arrow.y = this.y + 40;
			this.world.add(arrow);
			
			targetPosition = new Point(_targetPosition.x, _targetPosition.y);
			targetPosition.y += 100;
			delta.x = arrow.x - targetPosition.x;
			delta.y = arrow.y - targetPosition.y;
			
			targetEnemy = null;
			targetEnemy = _enemy;
		}
		
		public function calculateDamage(_weaponEquipmentKey:String):void
		{
			var damage:int = 0;
			FP.log(player.agility + " and " + targetEnemy.agility);
			var chance:Number = (player.agility * 100)/(player.agility + targetEnemy.agility);
			var someNum:Number = Math.random()*100;
			FP.log("Chance: " + chance + " and number pulled: " + someNum);
			if (someNum <= chance)
			{
				FP.log("Hit!");
				damage = player.equipment[_weaponEquipmentKey].damageRating - targetEnemy.armorRating;
				if (damage < 0) damage = 0;
				targetEnemy.health -= damage;
				targetEnemy.updateStatDisplay();
			}
		}
		
		public function animationCallback():void
		{
			if (curAnimation == "melee_left")
			{
				if (meleeTwice)
				{
					spritemap.play("melee_left", true);
					calculateDamage("WeaponEquipSecondary");
					meleeTwice = false;
				}
				else 
				{
					curAnimation = "walk_right";
					moving = true;
				}
			}
			
			if (curAnimation == "ranged_left")
			{
				FP.log("ranged is done");
				curAnimation = "stand_left";
			}
		}
	}

}
