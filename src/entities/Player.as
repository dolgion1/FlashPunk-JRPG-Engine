package entities 
{
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import net.flashpunk.*;
	import net.flashpunk.debug.Console;
	import net.flashpunk.utils.*;
	import net.flashpunk.graphics.*;
	import utility.*;
	import worlds.Battle;
	import worlds.Game;
	
	/**
	 * ...
	 * @author dolgion
	 */
	public class Player extends Entity
	{
		public var playerSpritemap:Spritemap;
		public var curAnimation:String = "stand_down";
		public var currentMapIndex:int;
		
		public var dialogs:Array = new Array();
		public var dialogPartner:String;
		public var dialogsInTotal:Dictionary = new Dictionary();
		public var dialogCounters:Dictionary = new Dictionary();
		
		// character status variables
		public var health:int;
		public var maxHealth:int;
		public var mana:int;
		public var maxMana:int;
		
		// character stats
		public var experience:int;
		public var strength:int; // determines what non-magical weapon and armor can be used
		public var agility:int; // determines chance to hit and evade attacks
		public var spirituality:int; // determines effectiveness of magical weapons and what spells can be used
		
		// directly combat related stats, determined by equipment
		public var damageType:int = GC.DAMAGE_TYPE_NO_DAMAGE;
		public var damageRating:int = 0;
		public var attackType:int = GC.ATTACK_TYPE_NO_ATTACK;
		public var armorRating:int = 0;
		
		public var items:Array = new Array();
		public var equipment:Dictionary = new Dictionary();
		public var activeConsumables:Array = new Array();
		
		public function Player(_position:GlobalPosition, _dialogs:Array, _stats:Array)
		{
			setupSpritesheet();
			graphic = playerSpritemap;
			playerSpritemap.play(curAnimation);
			
			x = _position.x;
			y = _position.y;
			currentMapIndex = _position.mapIndex;
			dialogs = _dialogs;
			setupUpDialogsInTotal();
			
			health = _stats[GC.STATUS_HEALTH];
			maxHealth = _stats[GC.STATUS_MAX_HEALTH];
			mana = _stats[GC.STATUS_MANA];
			maxMana = _stats[GC.STATUS_MAX_MANA];
			strength = _stats[GC.STATUS_STRENGTH];
			agility = _stats[GC.STATUS_AGILITY];
			spirituality = _stats[GC.STATUS_SPIRITUALITY];
			experience = _stats[GC.STATUS_EXPERIENCE];
			
			setHitbox(GC.PLAYER_HITBOX_WIDTH, GC.PLAYER_HITBOX_HEIGHT, GC.PLAYER_HITBOX_X_OFFSET, GC.PLAYER_HITBOX_Y_OFFSET);
			type = GC.TYPE_PLAYER;
			
			defineInputKeys();
			initEquipment();
			initItems();
			updateStats();
		}
		
		override public function update():void
		{
			playerSpritemap.play(curAnimation);
			
			// Check for movement input
			handleMovement();
			
			// Check for interaction with NPCs 
			dialogCheck();
			
			// Check if the player wants to open a chest
			openChestCheck();
			
			// Check if the player is colliding with an enemy
			checkEnemyCollide();
		}
		
		public function handleMovement():void
		{
			var horizontalMovement:Boolean = true;
			var verticalMovement:Boolean = true;
			var xSpeed:Number = 0;
			var ySpeed:Number = 0;
			var newX:Number;
			var newY:Number;
			
			// Movement input checks
			if (Game.gameMode == Game.NORMAL_MODE)
			{
				if (Input.check(GC.BUTTON_LEFT))
				{
					newX = x - GC.PLAYER_MOVEMENT_SPEED;
					if (!colliding(new Point(newX, y)))
					{
						xSpeed = GC.PLAYER_MOVEMENT_SPEED * (-1);
						curAnimation = "walk_left";
					}
					else {
						curAnimation = "stand_left";
					}
				}
				else if (Input.check(GC.BUTTON_RIGHT))
				{
					newX = x + GC.PLAYER_MOVEMENT_SPEED;
					if (!colliding(new Point(newX, y)))
					{
						xSpeed = GC.PLAYER_MOVEMENT_SPEED;
						curAnimation = "walk_right";
					}
					else {
						curAnimation = "stand_right";
					}
				}
				else horizontalMovement = false;
				
				if (Input.check(GC.BUTTON_UP))
				{
					newY = y - GC.PLAYER_MOVEMENT_SPEED;
					if (!colliding(new Point(x, newY)))
					{
						ySpeed = GC.PLAYER_MOVEMENT_SPEED * (-1);
						curAnimation = "walk_up";
					}
					else {
						curAnimation = "stand_up";
					}
				}
				else if (Input.check(GC.BUTTON_DOWN))
				{
					newY = y + GC.PLAYER_MOVEMENT_SPEED;
					if (!colliding(new Point(x, newY)))
					{
						ySpeed = GC.PLAYER_MOVEMENT_SPEED;
						curAnimation = "walk_down";
					}
					else {
						curAnimation = "stand_down";
					}
				}
				else verticalMovement = false;
				
				if ((!verticalMovement) && (!horizontalMovement))
				{
					switch (curAnimation)
					{
						case "walk_left": curAnimation = "stand_left"; break;
						case "walk_right": curAnimation = "stand_right"; break;
						case "walk_up": curAnimation = "stand_up"; break;
						case "walk_down": curAnimation = "stand_down"; break;
					}				
				}
				else if (verticalMovement && horizontalMovement)
				{
					x += xSpeed / GC.PLAYER_DIAGONAL_MOVEMENT_SPEED;
					y += ySpeed / GC.PLAYER_DIAGONAL_MOVEMENT_SPEED;
				}
				else
				{
					x += xSpeed;
					y += ySpeed;
				}
			}
		}
		
		public function dialogCheck():void
		{
			if (Input.pressed(GC.BUTTON_ACTION) && 
				(Game.gameMode != Game.DIALOG_MODE) && 
				(!Game.dialogEndedThisFrame))
			{
				var npc:NPC;
				if (curAnimation == "walk_left" || 
					curAnimation == "stand_left")
				{
					if (collide(GC.TYPE_NPC, x - 3, y))
					{
						npc = collide(GC.TYPE_NPC, x - 3, y) as NPC;
						Game.gameMode = Game.DIALOG_MODE;
						dialogPartner = npc.name;
					}
				}
				else if (curAnimation == "walk_right" || 
					curAnimation == "stand_right")
				{
					if (collide(GC.TYPE_NPC, x + 3, y))
					{
						npc = collide(GC.TYPE_NPC, x + 3, y) as NPC;
						Game.gameMode = Game.DIALOG_MODE;
						dialogPartner = npc.name;
					}
				}
				else if (curAnimation == "walk_up" || 
					curAnimation == "stand_up")
				{
					if (collide(GC.TYPE_NPC, x, y - 3))
					{
						npc = collide(GC.TYPE_NPC, x, y - 3) as NPC;
						Game.gameMode = Game.DIALOG_MODE;
						dialogPartner = npc.name;
					}	
				}
				else if (curAnimation == "walk_down" || 
					curAnimation == "stand_down")
				{
					if (collide(GC.TYPE_NPC, x, y + 3))
					{
						npc = collide(GC.TYPE_NPC, x, y + 3) as NPC;
						Game.gameMode = Game.DIALOG_MODE;
						dialogPartner = npc.name;
					}
				}
			}
		}
		
		public function openChestCheck():void
		{
			if (Input.pressed(GC.BUTTON_ACTION) && Game.gameMode == Game.NORMAL_MODE)
			{
				var chest:Chest;
				var i:int;
				var item:InventoryItem;
				
				if (curAnimation == "walk_up" || 
					curAnimation == "stand_up")
				{
					if (collide(GC.TYPE_CHEST, x, y - 3))
					{
						chest = collide(GC.TYPE_CHEST, x, y - 3) as Chest;
						if (chest.faceDirection == "down")
						{
							chest.chestSpritemap.play("open_face_down");
							for (i = 0; i < 3; i++)
							{
								for each (item in chest.items[i])
								{
									FP.log("Picked up " + item.item[i].name + " quantity " + item.quantity);
									addItem(item, i);
								}
							}
							chest.empty();
						}
					}
				}
				else if (curAnimation == "walk_left" || 
					curAnimation == "stand_left")
				{
					if (collide(GC.TYPE_CHEST, x - 3, y))
					{
						chest = collide(GC.TYPE_CHEST, x - 3, y) as Chest;
						if (chest.faceDirection == "right")
						{
							chest.chestSpritemap.play("open_face_right");
							for (i = 0; i < 3; i++)
							{
								for each (item in chest.items[i])
								{
									FP.log("Picked up " + item.item[i].name + " quantity " + item.quantity);
									addItem(item, i);
								}
							}
							chest.empty();
						}
					}
				}
				else if (curAnimation == "walk_right" || 
					curAnimation == "stand_right")
				{
					if (collide(GC.TYPE_CHEST, x + 3, y))
					{
						chest = collide(GC.TYPE_CHEST, x + 3, y) as Chest;
						if (chest.faceDirection == "left")
						{
							chest.chestSpritemap.play("open_face_left");
							for (i = 0; i < 3; i++)
							{
								for each (item in chest.items[i])
								{
									FP.log("Picked up " + item.item[i].name + " quantity " + item.quantity);
									addItem(item, i);
								}
							}
							chest.empty();
						}
					}
				}
				else if (curAnimation == "walk_down" || 
					curAnimation == "stand_down")
				{
					if (collide(GC.TYPE_CHEST, x, y + 3))
					{
						chest = collide(GC.TYPE_CHEST, x, y + 3) as Chest;
						if (chest.faceDirection == "up")
						{
							chest.chestSpritemap.play("open_face_up");
							for (i = 0; i < 3; i++)
							{
								for each (item in chest.items[i])
								{
									FP.log("Picked up " + item.item[i].name + " quantity " + item.quantity);
									addItem(item, i);
								}
							}
							chest.empty();
						}
					}
				}
			}
		}
		
		public function enteringHouse():Entity
		{
			return collide(GC.TYPE_HOUSE, x, y - 3);
		}
		
		public function colliding(position:Point):Boolean
		{
			if (collide(GC.TYPE_TILES, position.x, position.y)) return true;
			else if (collide(GC.TYPE_NPC, position.x, position.y)) return true;
			else if (collide(GC.TYPE_CHEST, position.x, position.y)) return true;
			else return false;
		}
		
		public function checkEnemyCollide():void
		{
			if (collide(GC.TYPE_ENEMY, x, y))
			{
				var enemy:Enemy = collide(GC.TYPE_ENEMY, x, y) as Enemy;
				FP.world = new Battle(this, enemy);
				enemy.world.remove(enemy);
			}
		}
		
		public function defineInputKeys():void
		{
			Input.define(GC.BUTTON_UP, Key.W, Key.UP);
			Input.define(GC.BUTTON_DOWN, Key.S, Key.DOWN);
			Input.define(GC.BUTTON_LEFT, Key.A, Key.LEFT);
			Input.define(GC.BUTTON_RIGHT, Key.D, Key.RIGHT);
			Input.define(GC.BUTTON_ACTION, Key.SPACE);
		}
		
		public function setupSpritesheet():void
		{
			playerSpritemap = new Spritemap(GFX.PLAYER, GC.PLAYER_SPRITE_WIDTH, GC.PLAYER_SPRITE_HEIGHT);
			playerSpritemap.add("walk_down", [0, 1, 2, 3, 4, 5, 6, 7], 9, true);
			playerSpritemap.add("walk_up", [8, 9, 10, 11, 12, 13, 14, 15], 9, true);
			playerSpritemap.add("walk_right", [16, 17, 18, 19, 20, 21], 9, true);
			playerSpritemap.add("walk_left", [24, 25, 26, 27, 28, 29], 9, true);
			playerSpritemap.add("stand_down", [0], 0, false);
			playerSpritemap.add("stand_up", [8], 0, false);
			playerSpritemap.add("stand_right", [16], 0, false);
			playerSpritemap.add("stand_left", [24], 0, false);
		}
		
		public function setupUpDialogsInTotal():void
		{
			for each (var d:Dialog in dialogs)
			{
				if (dialogsInTotal[d.partner] == null)
				{
					dialogsInTotal[d.partner] = 1;
					dialogCounters[d.partner] = 0;
				}
				else 
				{
					dialogsInTotal[d.partner]++;
				}
			}
		}
		
		public function initEquipment():void
		{
			equipment[GC.INVENTORY_KEY_WEAPON_EQUIP_PRIMARY] = null;
			equipment[GC.INVENTORY_KEY_WEAPON_EQUIP_SECONDARY] = null;
			equipment[GC.INVENTORY_KEY_ARMOR_EQUIP_HEAD] = null;
			equipment[GC.INVENTORY_KEY_ARMOR_EQUIP_TORSO] = null;
			equipment[GC.INVENTORY_KEY_ARMOR_EQUIP_LEGS] = null;
			equipment[GC.INVENTORY_KEY_ARMOR_EQUIP_HANDS] = null;
			equipment[GC.INVENTORY_KEY_ARMOR_EQUIP_FEET] = null;
		}
		
		public function initItems():void
		{
			items.push(new Array());
			items.push(new Array());
			items.push(new Array());
		}
		
		public function updateStats():void {
			
			// loop through the equipment and recalculate the combat related stats
			if (equipment[GC.INVENTORY_KEY_WEAPON_EQUIP_PRIMARY] != null)
			{
				damageType = equipment[GC.INVENTORY_KEY_WEAPON_EQUIP_PRIMARY].damageType;
				damageRating = equipment[GC.INVENTORY_KEY_WEAPON_EQUIP_PRIMARY].damageRating;
				attackType = equipment[GC.INVENTORY_KEY_WEAPON_EQUIP_PRIMARY].attackType;
			}
			
			armorRating = 0;
			
			if (equipment[GC.INVENTORY_KEY_ARMOR_EQUIP_HEAD] != null) armorRating += equipment[GC.INVENTORY_KEY_ARMOR_EQUIP_HEAD].armorRating;
			if (equipment[GC.INVENTORY_KEY_ARMOR_EQUIP_TORSO] != null) armorRating += equipment[GC.INVENTORY_KEY_ARMOR_EQUIP_TORSO].armorRating;
			if (equipment[GC.INVENTORY_KEY_ARMOR_EQUIP_LEGS] != null) armorRating += equipment[GC.INVENTORY_KEY_ARMOR_EQUIP_LEGS].armorRating;
			if (equipment[GC.INVENTORY_KEY_ARMOR_EQUIP_HANDS] != null) armorRating += equipment[GC.INVENTORY_KEY_ARMOR_EQUIP_HANDS].armorRating;
			if (equipment[GC.INVENTORY_KEY_ARMOR_EQUIP_FEET] != null) armorRating += equipment[GC.INVENTORY_KEY_ARMOR_EQUIP_FEET].armorRating;
		}
		
		public function get stats():Array
		{
			return new Array(health, maxHealth, mana, maxMana, strength, agility, spirituality, experience, 
							 damageRating, damageType, attackType, armorRating);
		}
		
		public function addItem (_item:InventoryItem, _type:int):void
		{
			for each (var i:InventoryItem in items[_type])
			{
				if (i.item[_type].name == _item.item[_type].name)
				{
					i.quantity += _item.quantity;
					return;
				}
			}
			items[_type].push(_item);
		}
		
		
		public function consume(_consumable:Consumable):void
		{
			for each (var statusAlteration:StatusAlteration in _consumable.statusAlterations)
			{
				switch (statusAlteration.statusVariable)
				{
					case (GC.STATUS_HEALTH): 
					{
						health += statusAlteration.alteration;
						if (health > maxHealth) health = maxHealth;
						break;
					}
					case (GC.STATUS_MANA): 
					{
						mana += statusAlteration.alteration;
						if (mana > maxMana) mana = maxMana;
						break;
					}
					case (GC.STATUS_STRENGTH): 
					{
						strength += statusAlteration.alteration;
						break;
					}
					case (GC.STATUS_AGILITY): 
					{
						agility += statusAlteration.alteration;
						break;
					}
					case (GC.STATUS_SPIRITUALITY): 
					{
						spirituality += statusAlteration.alteration;
						break;
					}
				}
			}
			
			if (_consumable.temporary)
			{
				activeConsumables.push(_consumable);
			}
		}
		
		public function updateAlterations():void
		{
			for (var i:int = 0; i < activeConsumables.length; i++)
			{
				activeConsumables[i].duration--;
				if (activeConsumables[i].duration < 1)
				{
					for each (var sa:StatusAlteration in activeConsumables[i].statusAlterations)
					{
						switch (sa.statusVariable)
						{
							case (GC.STATUS_STRENGTH): 
							{
								strength -= sa.alteration;
								break;
							}
							case (GC.STATUS_AGILITY):
							{
								agility -= sa.alteration;
								break;
							}
							case (GC.STATUS_STRENGTH): 
							{
								spirituality -= sa.alteration;
								break;
							}
						}
					}
					
					activeConsumables.splice(i, 1);
				}
			}
		}
	}
}