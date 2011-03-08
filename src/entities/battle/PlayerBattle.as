package entities.battle 
{
	import net.flashpunk.*;
	import net.flashpunk.utils.*;
	import net.flashpunk.graphics.*;
	import utility.*;
	import flash.geom.Point;
	import entities.*;
	import entities.spells.*;
	import flash.utils.Dictionary;
	import worlds.*;
	
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
		public var activeSpells:Array = new Array();
		public var spellEntities:Dictionary = new Dictionary();
		
		
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
				statDisplay.x -= delta.x / FP.assignedFrameRate;
				statDisplay.y -= delta.y / FP.assignedFrameRate;
				
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
						Battle.enterNextTurn = true;
						FP.log("Player's turn ended here");
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
					Battle.enterNextTurn = true;
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
			spritemap.add("cast_left", [48, 0], 3, false);
			spritemap.add("cast_right", [49, 1], 3, false);
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
			var chance:Number = (player.agility * 100)/(player.agility + targetEnemy.agility);
			var someNum:Number = Math.random()*100;
			
			if (someNum <= chance)
			{
				damage = player.equipment[_weaponEquipmentKey].damageRating - targetEnemy.armorRating;
				if (damage < 0) damage = 0;
				targetEnemy.health -= damage;
				targetEnemy.updateStatDisplay();
				FP.log("enemy was just hit");
				
				if (targetEnemy.health < 1)
				{
					targetEnemy.world.remove(targetEnemy.statDisplay);
					targetEnemy.world.remove(targetEnemy);
					targetEnemy.dead = true;
				}
			}
		}
		
		public function animationCallback():void
		{
			if (curAnimation == "melee_left")
			{
				if (meleeTwice)
				{
					if (!targetEnemy.dead)
					{
						spritemap.play("melee_left", true);
						calculateDamage("WeaponEquipSecondary");
					}
					else 
					{
						curAnimation = "walk_right";
						moving = true;
					}
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
				curAnimation = "stand_left";
			}
		}
		
		public function castOnEnemy(_enemy:EnemyBattle, _offenseSpell:String, _castingScroll:Boolean):void
		{
			curAnimation = "cast_left";
			
			switch (_offenseSpell)
			{
				case "Fire": 
				{
					spellEntities["Fire"] = new FireSpell(_enemy.x, _enemy.y);
					this.world.add(spellEntities["Fire"]);
					break;
				}
				case "Ice": 
				{
					spellEntities["Ice"] = new IceSpell(_enemy.x, _enemy.y);
					this.world.add(spellEntities["Ice"]);
					break;
				}
			}
			
			_enemy.health -= Battle.spells[_offenseSpell].damageRating;
			_enemy.updateStatDisplay();
			
			if (!_castingScroll) 
			{
				player.mana -= Battle.spells[_offenseSpell].manaCost;
			}
			
			updateStatDisplay();
			
			if (_enemy.health < 1)
			{
				_enemy.world.remove(targetEnemy.statDisplay);
				_enemy.world.remove(targetEnemy);
				_enemy.dead = true;
			}
		}
		
		public function castOnSelf(_defenseSpell:DefenseSpell):void
		{
			switch (_defenseSpell.statusVariable)
			{
				case (GC.STATUS_HEALTH): 
				{
					player.health += _defenseSpell.alteration;
					if (player.health > player.maxHealth) player.health = player.maxHealth;
					break;
				}
				case (GC.STATUS_MANA): 
				{
					player.mana += _defenseSpell.alteration;
					if (player.mana > player.maxMana) player.mana = player.maxMana;
					break;
				}
				case (GC.STATUS_STRENGTH): 
				{
					player.strength += _defenseSpell.alteration;
					break;
				}
				case (GC.STATUS_AGILITY): 
				{
					player.agility += _defenseSpell.alteration;
					break;
				}
				case (GC.STATUS_SPIRITUALITY): 
				{
					player.spirituality += _defenseSpell.alteration;
					break;
				}
			}
			
			if (_defenseSpell.temporary) activeSpells.push(_defenseSpell);
			
			player.mana -= _defenseSpell.manaCost;
			updateStatDisplay();
		}
		
		public function updateSpellAlterations():void
		{
			for (var i:int = 0; i < activeSpells.length; i++)
			{
				activeSpells[i].duration--;
				
				if (activeSpells[i].duration < 1)
				{
					switch (activeSpells[i].statusVariable)
					{
						case (GC.STATUS_HEALTH): 
						{
							player.health -= activeSpells[i].alteration;
							if (player.health < 1) player.health = 1;
							break;
						}
						case (GC.STATUS_MANA): 
						{
							player.mana -= activeSpells[i].alteration;
							if (player.mana < 1) player.mana = 0;
							break;
						}
						case (GC.STATUS_STRENGTH): 
						{
							player.strength -= activeSpells[i].alteration;
							break;
						}
						case (GC.STATUS_AGILITY): 
						{
							player.agility -= activeSpells[i].alteration;
							break;
						}
						case (GC.STATUS_SPIRITUALITY): 
						{
							player.spirituality -= activeSpells[i].alteration;
							break;
						}
					}
					
					activeSpells.splice(i, 1);
				}
			}
		}
	}

}
