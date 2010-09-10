package entities 
{
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import net.flashpunk.*;
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
			if (!Game.inDialog)
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
			if (Input.pressed("action") && (!Game.inDialog) && (!Game.dialogEndedThisFrame))
			{
				var npc:NPC;
				if (curAnimation == "walk_left" || 
					curAnimation == "stand_left")
				{
					if (collide("npc", x - 3, y))
					{
						npc = collide("npc", x - 3, y) as NPC;
						if (!Game.inDialog) 
						{
							Game.inDialog = true;
							dialogPartner = npc.name;
						}
					}
				}
				else if (curAnimation == "walk_right" || 
					curAnimation == "stand_right")
				{
					if (collide("npc", x + 3, y))
					{
						npc = collide("npc", x + 3, y) as NPC;
						if (!Game.inDialog) 
						{
							Game.inDialog = true;
							dialogPartner = npc.name;
						}
					}
				}
				else if (curAnimation == "walk_up" || 
					curAnimation == "stand_up")
				{
					if (collide("npc", x, y - 3))
					{
						npc = collide("npc", x, y - 3) as NPC;
						if (!Game.inDialog) 
						{
							Game.inDialog = true;
							dialogPartner = npc.name;
						}
					}	
				}
				else if (curAnimation == "walk_left" || 
					curAnimation == "stand_up")
				{
					if (collide("npc", x, y + 3))
					{
						npc = collide("npc", x, y + 3) as NPC;
						if (!Game.inDialog) 
						{
							Game.inDialog = true;
							dialogPartner = npc.name;
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
	}
}