package entities 
{
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import net.flashpunk.*;
	import net.flashpunk.debug.Console;
	import net.flashpunk.utils.*;
	import net.flashpunk.graphics.*;
	import utility.*;
	import worlds.Game;
	
	/**
	 * ...
	 * @author dolgion
	 */
	public class Player extends Entity
	{
		[Embed(source = "../../assets/gfx/player.png")]
		public const PLAYER:Class;
		public const SPRITE_WIDTH:Number = 23;
		public const SPRITE_HEIGHT:Number = 28;
		public const HITBOX_WIDTH:int = 16;
		public const HITBOX_HEIGHT:int = 23;
		public const HITBOX_X_OFFSET:int = -4;
		public const HITBOX_Y_OFFSET:int = -3;
		
		public static var speed:Number = 2;
		public static var diagonalSpeed:Number = 1.4;
		public var playerSpritemap:Spritemap;
		public var curAnimation:String = "stand_down";
		public var currentMapIndex:int;
		
		public var dialogs:Array = new Array();
		public var dialogPartner:String;
		public var dialogsInTotal:Dictionary = new Dictionary();
		public var dialogCounters:Dictionary = new Dictionary();
		
		// character stats
		public var experience:int = 0;
		public var strength:int = 10; // determines what weapon and armor can be used and inventory capacity
		public var agility:int = 10; // determines chance to hit and evade attacks
		public var spirituality:int = 10; // determines effectiveness of magical weapons and what spells can be used
		
		// directly combat related stats
		public var damageType:int = -1;
		public var damageRating:int = 0;
		public var attackType:int = -1;
		public var armorRating:int = 0;
		
		public var items:Array = new Array();
		public var equipment:Dictionary = new Dictionary();
		
		public function Player(_position:GlobalPosition, _dialogs:Array)
		{
			setupSpritesheet();
			graphic = playerSpritemap;
			playerSpritemap.play(curAnimation);
			
			x = _position.x;
			y = _position.y;
			currentMapIndex = _position.mapIndex;
			dialogs = _dialogs;
			setupUpDialogsInTotal();
			
			setHitbox(HITBOX_WIDTH, HITBOX_HEIGHT, HITBOX_X_OFFSET, HITBOX_Y_OFFSET);
			type = "player";
			
			defineInputKeys();
			initEquipment();
			initItems();
		}
		
		override public function update():void
		{
			var horizontalMovement:Boolean = true;
			var verticalMovement:Boolean = true;
			var xSpeed:Number = 0;
			var ySpeed:Number = 0;
			var newX:Number;
			var newY:Number;
			
			playerSpritemap.play(curAnimation);
			
			// Movement input checks
			if (Game.gameMode == Game.NORMAL_MODE)
			{
				if (Input.check("walk_left"))
				{
					newX = x - speed;
					if (!colliding(new Point(newX, y)))
					{
						xSpeed = speed * (-1);
						curAnimation = "walk_left";
					}
					else {
						curAnimation = "stand_left";
					}
				}
				else if (Input.check("walk_right"))
				{
					newX = x + speed;
					if (!colliding(new Point(newX, y)))
					{
						xSpeed = speed;
						curAnimation = "walk_right";
					}
					else {
						curAnimation = "stand_right";
					}
				}
				else horizontalMovement = false;
				
				if (Input.check("walk_up"))
				{
					newY = y - speed;
					if (!colliding(new Point(x, newY)))
					{
						ySpeed = speed * (-1);
						curAnimation = "walk_up";
					}
					else {
						curAnimation = "stand_up";
					}
				}
				else if (Input.check("walk_down"))
				{
					newY = y + speed;
					if (!colliding(new Point(x, newY)))
					{
						ySpeed = speed;
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
					x += xSpeed / 1.4;
					y += ySpeed / 1.4;
				}
				else
				{
					x += xSpeed;
					y += ySpeed;
				}
			}
			
			// Interaction input checks
			if (Input.pressed("action") && (Game.gameMode != Game.DIALOG_MODE) && (!Game.dialogEndedThisFrame))
			{
				var npc:NPC;
				if (curAnimation == "walk_left" || 
					curAnimation == "stand_left")
				{
					if (collide("npc", x - 3, y))
					{
						npc = collide("npc", x - 3, y) as NPC;
						Game.gameMode = Game.DIALOG_MODE;
						dialogPartner = npc.name;
					}
				}
				else if (curAnimation == "walk_right" || 
					curAnimation == "stand_right")
				{
					if (collide("npc", x + 3, y))
					{
						npc = collide("npc", x + 3, y) as NPC;
						Game.gameMode = Game.DIALOG_MODE;
						dialogPartner = npc.name;
					}
				}
				else if (curAnimation == "walk_up" || 
					curAnimation == "stand_up")
				{
					if (collide("npc", x, y - 3))
					{
						npc = collide("npc", x, y - 3) as NPC;
						Game.gameMode = Game.DIALOG_MODE;
						dialogPartner = npc.name;
					}	
				}
				else if (curAnimation == "walk_down" || 
					curAnimation == "stand_down")
				{
					if (collide("npc", x, y + 3))
					{
						npc = collide("npc", x, y + 3) as NPC;
						Game.gameMode = Game.DIALOG_MODE;
						dialogPartner = npc.name;
					}
				}
			}
			
			// Check if the player wants to open a chest
			if (Input.pressed("action") && Game.gameMode == Game.NORMAL_MODE)
			{
				var chest:Chest;
				var w:InventoryItem;
				var a:InventoryItem;
				var c:InventoryItem;
				
				if (curAnimation == "walk_up" || 
					curAnimation == "stand_up")
				{
					if (collide("chest", x, y - 3))
					{
						chest = collide("chest", x, y - 3) as Chest;
						if (chest.faceDirection == "down")
						{
							chest.chestSpritemap.play("open_face_down");
							for each (w in chest.items[Item.WEAPON])
							{
								FP.log("Picked up " + w.weapon.name + " quantity " + w.quantity);
								addWeapon(w);
							}
							for each (a in chest.items[Item.ARMOR])
							{
								FP.log("Picked up " + a.armor.name + " quantity " + a.quantity);
								addArmor(a);
							}
							for each (c in chest.items[Item.CONSUMABLE])
							{
								FP.log("Picked up " + c.consumable.name + " quantity " + c.quantity);
								addConsumable(c);
							}
							chest.empty();
						}
					}
				}
				else if (curAnimation == "walk_left" || 
					curAnimation == "stand_left")
				{
					if (collide("chest", x - 3, y))
					{
						chest = collide("chest", x - 3, y) as Chest;
						if (chest.faceDirection == "right")
						{
							chest.chestSpritemap.play("open_face_right");
							for each (w in chest.items[Item.WEAPON])
							{
								FP.log("Picked up " + w.weapon.name + " quantity " + w.quantity);
								addWeapon(w);
							}
							for each (a in chest.items[Item.ARMOR])
							{
								FP.log("Picked up " + a.armor.name + " quantity " + a.quantity);
								addArmor(a);
							}
							for each (c in chest.items[Item.CONSUMABLE])
							{
								FP.log("Picked up " + c.consumable.name + " quantity " + c.quantity);
								addConsumable(c);
							}
							chest.empty();
						}
					}
				}
				else if (curAnimation == "walk_right" || 
					curAnimation == "stand_right")
				{
					if (collide("chest", x + 3, y))
					{
						chest = collide("chest", x + 3, y) as Chest;
						if (chest.faceDirection == "left")
						{
							chest.chestSpritemap.play("open_face_left");
							for each (w in chest.items[Item.WEAPON])
							{
								FP.log("Picked up " + w.weapon.name + " quantity " + w.quantity);
								addWeapon(w);
							}
							for each (a in chest.items[Item.ARMOR])
							{
								FP.log("Picked up " + a.armor.name + " quantity " + a.quantity);
								addArmor(a);
							}
							for each (c in chest.items[Item.CONSUMABLE])
							{
								FP.log("Picked up " + c.consumable.name + " quantity " + c.quantity);
								addConsumable(c);
							}
							chest.empty();
						}
					}
				}
				else if (curAnimation == "walk_down" || 
					curAnimation == "stand_down")
				{
					if (collide("chest", x, y + 3))
					{
						chest = collide("chest", x, y + 3) as Chest;
						if (chest.faceDirection == "up")
						{
							chest.chestSpritemap.play("open_face_up");
							for each (w in chest.items[Item.WEAPON])
							{
								FP.log("Picked up " + w.weapon.name + " quantity " + w.quantity);
								addWeapon(w);
							}
							for each (a in chest.items[Item.ARMOR])
							{
								FP.log("Picked up " + a.armor.name + " quantity " + a.quantity);
								addArmor(a);
							}
							for each (c in chest.items[Item.CONSUMABLE])
							{
								FP.log("Picked up " + c.consumable.name + " quantity " + c.quantity);
								addConsumable(c);
							}
							chest.empty();
						}
					}
				}
			}
		}
		
		public function enteringHouse():Entity
		{
			return collide("house", x, y - 3);
		}
		
		public function colliding(position:Point):Boolean
		{
			if (collide("solid", position.x, position.y)) return true;
			else if (collide("npc", position.x, position.y)) return true;
			else if (collide("chest", position.x, position.y)) return true;
			else return false;
		}
		
		public function defineInputKeys():void
		{
			Input.define("walk_left", Key.A, Key.LEFT);
			Input.define("walk_right", Key.D, Key.RIGHT);
			Input.define("walk_up", Key.W, Key.UP);
			Input.define("walk_down", Key.S, Key.DOWN);
			Input.define("action", Key.SPACE);
		}
		
		public function setupSpritesheet():void
		{
			playerSpritemap = new Spritemap(PLAYER, SPRITE_WIDTH, SPRITE_HEIGHT);
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
			equipment["WeaponEquipPrimary"] = null;
			equipment["WeaponEquipSecondary"] = null;
			equipment["ArmorEquipHead"] = null;
			equipment["ArmorEquipTorso"] = null;
			equipment["ArmorEquipLegs"] = null;
			equipment["ArmorEquipHands"] = null;
			equipment["ArmorEquipFeet"] = null;
		}
		
		public function initItems():void
		{
			items.push(new Array());
			items.push(new Array());
			items.push(new Array());
		}
		
		public function updateStats():void {
			
			// loop through the equipment and recalculate the combat related stats
			if (equipment["WeaponEquipPrimary"] != null)
			{
				damageType = equipment["WeaponEquipPrimary"].damageType;
				damageRating = equipment["WeaponEquipPrimary"].damageRating;
				attackType = equipment["WeaponEquipPrimary"].attackType;
			}
			
			armorRating = 0;
			
			if (equipment["ArmorEquipHead"] != null) armorRating += equipment["ArmorEquipHead"].armorRating;
			if (equipment["ArmorEquipTorso"] != null) armorRating += equipment["ArmorEquipTorso"].armorRating;
			if (equipment["ArmorEquipLegs"] != null) armorRating += equipment["ArmorEquipLegs"].armorRating;
			if (equipment["ArmorEquipHands"] != null) armorRating += equipment["ArmorEquipHands"].armorRating;
			if (equipment["ArmorEquipFeet"] != null) armorRating += equipment["ArmorEquipFeet"].armorRating;
		}
		
		public function get stats():Array
		{
			FP.log("Combat Stats: " + damageType + ", " + damageRating + ", " + attackType + ", " + armorRating);
			return new Array(experience, strength, agility, spirituality, damageRating, damageType, attackType, armorRating);
		}
		
		public function addWeapon(_weapon:InventoryItem):void
		{
			for each (var i:InventoryItem in items[Item.WEAPON])
			{
				if (i.weapon.name == _weapon.weapon.name)
				{
					i.quantity += _weapon.quantity;
					return;
				}
			}
			
			items[Item.WEAPON].push(_weapon);
		}
		
		public function addArmor(_armor:InventoryItem):void
		{
			for each (var i:InventoryItem in items[Item.ARMOR])
			{
				if (i.armor.name == _armor.armor.name)
				{
					i.quantity += _armor.quantity;
					return;
				}
			}
			
			items[Item.ARMOR].push(_armor);
		}
		
		public function addConsumable(_consumable:InventoryItem):void
		{
			for each (var i:InventoryItem in items[Item.CONSUMABLE])
			{
				if (i.consumable.name == _consumable.consumable.name)
				{
					i.quantity += _consumable.quantity;
					return;
				}
			}
			
			items[Item.CONSUMABLE].push(_consumable);
		}
	}
}