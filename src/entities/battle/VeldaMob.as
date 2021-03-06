package entities.battle 
{
	import flash.geom.Point;
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import utility.*;
	import entities.*;
	import entities.spells.*;
	import worlds.*;
	import flash.utils.*;
	
	/**
	 * ...
	 * @author dolgion1
	 */
	public class VeldaMob extends MobEntity
	{
		// instances of entities for the spells that Velda can cast
		public var iceSpell:IceSpell;
		
		public function VeldaMob(_position:Point, _keyIndex:int, _items:Array) 
		{
			setupSpritesheets();
			curAnimation = "stand_right";
			health = GC.ENEMY_HEALTH_VELDA;
			maxHealth = GC.ENEMY_HEALTH_VELDA;
			mana = GC.ENEMY_MANA_VELDA;
			maxMana = GC.ENEMY_MANA_VELDA;
			strength = GC.ENEMY_STRENGTH_VELDA;
			agility = GC.ENEMY_AGILITY_VELDA;
			spirituality = GC.ENEMY_SPIRITUALITY_VELDA;
			damageRating = GC.ENEMY_DAMAGE_RATING_VELDA;
			armorRating = GC.ENEMY_ARMOR_RATING_VELDA;
			
			super(_position, _keyIndex, GC.MOB_VELDA, _items);
		}
		
		override public function update():void
		{
			super.update();
			
			if (moving)
			{
				x -= delta.x / FP.assignedFrameRate;
				y -= delta.y / FP.assignedFrameRate;
				statDisplay.x -= delta.x / FP.assignedFrameRate;
				statDisplay.y -= delta.y / FP.assignedFrameRate;
				
				if ((Math.abs(x - targetPosition.x) < GC.MOB_DESTINATION_RADIUS) &&
					(Math.abs(y - targetPosition.y) < GC.MOB_DESTINATION_RADIUS))
				{
					if (curAnimation == "walk_right")
					{
						curAnimation = "melee_right";
						targetPosition.x = defaultPosition.x;
						targetPosition.y = defaultPosition.y;
						delta.x = x - targetPosition.x;
						delta.y = y - targetPosition.y;
						moving = false;
						calculateDamage();
					}
					else if (curAnimation == "walk_left")
					{
						moving = false;
						curAnimation = "stand_right";
						Battle.enterNextTurn = true;
						x = targetPosition.x;
						y = targetPosition.y;
					}
				}
			}
			
		}
		
		public function setupSpritesheets():void
		{
			spritemap = new Spritemap(GFX.VELDA_BATTLE, GC.VELDA_BATTLE_SPRITE_WIDTH, GC.VELDA_BATTLE_SPRITE_HEIGHT);
			spritemap.add("stand_right", [0], 0, false);
			spritemap.add("stand_left", [1], 0, false);
			spritemap.add("walk_right", [5, 6, 7, 8, 9], 9, true);
			spritemap.add("walk_left", [10, 11, 12, 13, 14], 9, true);
			spritemap.add("cast_right", [15, 16, 17, 18, 19], 9, false);
			spritemap.add("cast_left", [20, 21, 22, 23, 24], 9, false);
			spritemap.add("melee_right", [25, 26, 27, 28], 9, true);
			spritemap.add("melee_left", [30, 31, 32, 33], 9, false);
			spritemap.callback = animationCallback;
		}
		
		public function battleAction(_player:PlayerBattle):void
		{
			// check if action must be taken to heal up
			if (health < (maxHealth/2))
			{
				// the amount of health that the mob has lost
 				var healthDeficit:int = maxHealth - health; 
				
				var healthPotionIndices:Array = new Array();
				
				// get all possible health potions
				for (var i:int = 0; i < consumables.length; i++)
				{
					if (consumables[i].item[GC.ITEM_CONSUMABLE].statusAlterations.length == 1)
					{
						if (consumables[i].item[GC.ITEM_CONSUMABLE].statusAlterations[0].statusVariable == 0)
						{
							if (consumables[i].item[GC.ITEM_CONSUMABLE].statusAlterations[0].alteration > 0)
							{
								healthPotionIndices.push(i);
								continue;
							}
						}
					}
				}
				
				if (healthPotionIndices.length > 0) 
				{
					// figure out with potion is the most efficient to heal the damage
					var bestSuitedPotionIndex:int = 0;
					for (i = 0; i < healthPotionIndices.length; i++)
					{
						var healthBoost:int = consumables[healthPotionIndices[i]].item[GC.ITEM_CONSUMABLE].statusAlterations[0].alteration;
						if (Math.abs(healthDeficit - healthBoost) < Math.abs(healthDeficit - consumables[healthPotionIndices[bestSuitedPotionIndex]].item[GC.ITEM_CONSUMABLE].statusAlterations[0].alteration))
						{
							bestSuitedPotionIndex = i;
						}
					}
					
					// drink the potion
					consume(consumables[healthPotionIndices[bestSuitedPotionIndex]]);
					
					// decrease the potion's quantity and remove it if all of its kind are used up
					consumables[healthPotionIndices[bestSuitedPotionIndex]].quantity--;
					if (consumables[healthPotionIndices[bestSuitedPotionIndex]].quantity < 1)
					{
						consumables.splice(healthPotionIndices[bestSuitedPotionIndex], 1);
					}
					
					updateStatDisplay();
					Battle.enterNextTurn = true;
					return;
				}
			}
			
			// choose between casting a spell or doing a normal attack, based on damage
			var useSpell:Boolean = false;
			if (spells.length > 0)
			{
				// only the first spell is compared as of now
				if (Game.spells[spells[0] + ""].manaCost <= mana)
				{
					if (Game.spells[spells[0] + ""].damageRating > attackDamage)
					{
						useSpell = true;
					}
				}
			}
			
			if (useSpell)
			{
				curAnimation = "cast_right";
				spritemap.play("cast_right");
				
				player = _player;
			}
			else
			{
				// if there isn't, do a melee attack
				// first, move towards player
				curAnimation = "walk_right";
				spritemap.play(curAnimation);
				moving = true;
				player = _player;
				targetPosition.x = _player.x;
				targetPosition.y = _player.y;
				delta.x = x - targetPosition.x;
				delta.y = y - targetPosition.y;
			}
		}
		
		public function animationCallback():void
		{
			if (curAnimation == "cast_right")
			{
				// display the spell entity and its animation
				// hard-coded the ice spell for now
				iceSpell = new IceSpell(player.x, player.y);
				this.world.add(iceSpell);
				
				// hurt the player
				player.player.health -= Game.spells[spells[0]].damageRating;
				if (player.player.health < 1) 
				{
					player.player.dead = true;
				}
				
				// pay the mana cost
				mana -= Game.spells[spells[0]].manaCost;
				if (mana < 0) mana = 0;
				
				updateStatDisplay();
				curAnimation = "stand_right";
				spritemap.play(curAnimation);
			}
			else if (curAnimation == "melee_right")
			{
				moving = true;
				curAnimation = "walk_left";
				spritemap.play(curAnimation);
			}
		}
		
		public function consume(_inventoryItem:InventoryItem):void
		{
			// consume a consumable and apply status alterations
			// no temporary effects for now
			switch (_inventoryItem.item[GC.ITEM_CONSUMABLE].statusAlterations[0].statusVariable)
			{
				case (GC.STATUS_HEALTH): 
				{
					health += _inventoryItem.item[GC.ITEM_CONSUMABLE].statusAlterations[0].alteration;
					if (health > maxHealth) health = maxHealth;
					break;
				}
				case (GC.STATUS_MANA): 
				{
					mana += _inventoryItem.item[GC.ITEM_CONSUMABLE].statusAlterations[0].alteration;
					if (mana > maxMana) mana = maxMana;
					break;
				}
				case (GC.STATUS_STRENGTH): 
				{
					strength += _inventoryItem.item[GC.ITEM_CONSUMABLE].statusAlterations[0].alteration;
					break;
				}
				case (GC.STATUS_AGILITY): 
				{
					agility += _inventoryItem.item[GC.ITEM_CONSUMABLE].statusAlterations[0].alteration;
					break;
				}
				case (GC.STATUS_SPIRITUALITY): 
				{
					spirituality += _inventoryItem.item[GC.ITEM_CONSUMABLE].statusAlterations[0].alteration;
					break;
				}
			}
		}
		
		public function calculateDamage():void
		{
			var damage:int = attackDamage - player.player.armorRating;
			if (damage < 0) damage = 0;
			player.player.health -= damage;
			player.updateStatDisplay();
			if (player.player.health < 1)
			{
				player.player.dead = true;
			}
		}
	}

}
