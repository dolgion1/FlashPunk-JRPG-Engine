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
		
		public var targetEnemy:MobEntity;
		public var player:Player;
		public var activeSpells:Array = new Array();
		public var spellEntities:Dictionary = new Dictionary();
		
		
		public function PlayerBattle(_x:int, _y:int, _player:Player) 
		{
			// initiate the graphics
			setupSpritesheet();
			graphic = spritemap;
			spritemap.play(curAnimation);
			
			// set up position and internal player instance
			x = _x;
			y = _y;
			player = _player;
			
			// initiate stats display
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
				// the player must move towards the destination
				// dividing the deltas by FP.assignedFrameRate means the entire walk will take 1 second
				x -= delta.x / FP.assignedFrameRate;
				y -= delta.y / FP.assignedFrameRate;
				
				// move the stat display as well
				statDisplay.x -= delta.x / FP.assignedFrameRate;
				statDisplay.y -= delta.y / FP.assignedFrameRate;
				
				// check if the player has arrived in the proximity of destination
				// within GC.PLAYER_BATTLE_DESTINATION_RADIUS 
				if ((Math.abs(x - targetPosition.x) < GC.PLAYER_BATTLE_DESTINATION_RADIUS) &&
					(Math.abs(y - targetPosition.y) < GC.PLAYER_BATTLE_DESTINATION_RADIUS))
				{
					if (curAnimation == "walk_left")
					{
						// so the player was walking to the left side, which means he was
						// walking towards an enemy
						curAnimation = "melee_left";
						
						// set the new target position to be the player's starting position
						targetPosition = new Point(GC.BATTLE_PLAYER_X, GC.BATTLE_PLAYER_Y);
						delta.x = x - targetPosition.x;
						delta.y = y - targetPosition.y;
						moving = false;
						
						// hurt the enemy
						calculateDamage(GC.INVENTORY_KEY_WEAPON_EQUIP_PRIMARY);
					}
					else if (curAnimation == "walk_right")
					{
						// so the player was walking back to his starting position.
						// end this turn then
						moving = false;
						curAnimation = "stand_left";
						Battle.enterNextTurn = true;
					}
				}
			}
			else if (arrowMoving)
			{
				// move the arrow which was shot towards the destination (enemy)
				// again, dividing delta by FP.assignedFrameRate means the arrow will take 1 second to hit
				arrow.x -= delta.x / FP.assignedFrameRate;
				arrow.y -= delta.y / FP.assignedFrameRate; 
				
				if ((Math.abs(arrow.x - targetPosition.x) < GC.PLAYER_BATTLE_DESTINATION_RADIUS) &&
					(Math.abs(arrow.y - targetPosition.y) < GC.PLAYER_BATTLE_DESTINATION_RADIUS))
				{
					// the arrow has hit, so remove it from the stage
					this.world.remove(arrow);
					arrowMoving = false;
					
					// hurt the enemy and end the turn
					calculateDamage(GC.INVENTORY_KEY_WEAPON_EQUIP_PRIMARY);
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
			
			// call this function whenever an animation finishes playing
			spritemap.callback = animationCallback; 
		}
		
		public function meleeAttack(_targetPosition:Point, _enemy:MobEntity, _meleeTwice:Boolean):void
		{
			// melee attacks start by walking towards the enemy
			curAnimation = "walk_left";
			moving = true;
			meleeTwice = _meleeTwice; // this decides whether to also hit with a secondary weapon
			
			// store the position to which to travel
			targetPosition = new Point(_targetPosition.x, _targetPosition.y);
			targetPosition.y += 40;
			
			// store the distance to travel in both axises
			delta.x = x - targetPosition.x;
			delta.y = y - targetPosition.y;
			
			// store the instance of the enemy
			targetEnemy = null;
			targetEnemy = _enemy;
		}
		
		public function rangedAttack(_targetPosition:Point, _enemy:MobEntity):void
		{
			// play the animation for ranged attacks
			curAnimation = "ranged_left";
			
			// make the arrow fly towards the targetposition
			arrowMoving = true;
			arrow.x = this.x;
			arrow.y = this.y + 40;
			this.world.add(arrow);
			
			// store the position to which to travel
			targetPosition = new Point(_targetPosition.x, _targetPosition.y);
			targetPosition.y += 100;
			
			// store the distance for the arrow to travel in both axises
			delta.x = arrow.x - targetPosition.x;
			delta.y = arrow.y - targetPosition.y;
			
			// store the instance of the enemy
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
				// the player landed a successful hit, now calculate the damage
				damage = player.equipment[_weaponEquipmentKey].damageRating - targetEnemy.armorRating;
				if (damage < 0) damage = 0;
				
				// hurt the enemy
				targetEnemy.health -= damage;
				targetEnemy.updateStatDisplay();
				
				// if the enemy died, remove him and set dead to true
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
				// the player has just performed a melee attack.
				// is there a secondary attack to perform as well?
				if (meleeTwice)
				{
					// only perform the attack animation if the enemy isn't already dead
					if (!targetEnemy.dead)
					{
						spritemap.play("melee_left", true);
						calculateDamage(GC.INVENTORY_KEY_WEAPON_EQUIP_SECONDARY);
					}
					else 
					{
						// otherwise just walk back
						curAnimation = "walk_right";
						moving = true;
					}
					
					meleeTwice = false;
				}
				else 
				{
					// walk back
					curAnimation = "walk_right";
					moving = true;
				}
			}
			
			if (curAnimation == "ranged_left")
			{
				curAnimation = "stand_left";
			}
		}
		
		public function castOnMob(_enemy:MobEntity, _offenseSpell:String, _castingScroll:Boolean):void
		{
			curAnimation = "cast_left";
			
			// instantiate the corresponding spell and add it to the stage
			// once the spell is on the stage, it's animation will play automatically
			// and it will remove itself from the stage one the animation finishes
			switch (_offenseSpell)
			{
				case GC.FIRE_SPELL: 
				{
					spellEntities[GC.FIRE_SPELL] = new FireSpell(_enemy.x, _enemy.y);
					this.world.add(spellEntities[GC.FIRE_SPELL]);
					break;
				}
				case GC.ICE_SPELL: 
				{
					spellEntities[GC.ICE_SPELL] = new IceSpell(_enemy.x, _enemy.y);
					this.world.add(spellEntities[GC.ICE_SPELL]);
					break;
				}
			}
			
			// hurt the enemy
			_enemy.health -= Game.spells[_offenseSpell].damageRating;
			_enemy.updateStatDisplay();
			
			// if the spell wasn't cast from a scroll, decrease the player's mana
			if (!_castingScroll) 
			{
				player.mana -= Game.spells[_offenseSpell].manaCost;
				
				// update stats display because mana has changed
				updateStatDisplay();
			}
			
			// check if the enemy is dead, in which case dead is set to true and the
			// enemy is removed from the stage
			if (_enemy.health < 1)
			{
				_enemy.world.remove(targetEnemy.statDisplay);
				_enemy.world.remove(targetEnemy);
				_enemy.dead = true;
			}
		}
		
		public function castOnSelf(_defenseSpell:DefenseSpell):void
		{
			// apply the status alteration of the spell on the correct
			// attribute of the player
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
			
			// if the spell is temporary, put it into the datastructure which
			// keeps track of temporary effects
			if (_defenseSpell.temporary) activeSpells.push(_defenseSpell);
			
			// decrease player's mana
			player.mana -= _defenseSpell.manaCost;
			updateStatDisplay();
		}
		
		public function updateSpellAlterations():void
		{
			// update the countdown timers of all currently effective 
			// temporary spells and reverse their effect if the timer
			// has reached 0 
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
