package entities.battle 
{
	import entities.DisplayText;
	import flash.geom.Point;
	import flash.utils.*;
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import utility.*;
	import entities.*;
	import worlds.*;
	
	/**
	 * ...
	 * @author dolgion1
	 */
	public class MobEntity extends Entity
	{
		
		public var spritemap:Spritemap;
		public var curAnimation:String;
		public var mobType:int;
		public var attackDamage:int;
		public var health:int;
		public var maxHealth:int;
		public var mana:int;
		public var maxMana:int;
		public var strength:int;
		public var agility:int; 
		public var spirituality:int;
		public var damageRating:int;
		public var armorRating:int;
		public var statDisplay:DisplayText;
		public var key:String;
		public var dead:Boolean = false;
		public var player:PlayerBattle;
		public var spells:Array = new Array();
		public var defaultPosition:Point = new Point(0, 0);
		public var moving:Boolean = false;
		public var delta:Point = new Point(0,0);
		public var targetPosition:Point = new Point(0,0);
		public var speed:int = 1;
		public var consumables:Array = new Array();
		
		public function MobEntity(_position:Point, _keyIndex:int, _name:String, _items:Array) 
		{
			graphic = spritemap;
			spritemap.play(curAnimation);
			
			x = _position.x;
			y = _position.y;
			defaultPosition = _position;
			key = "Enemy" + _keyIndex;
			
			statDisplay = new DisplayText(health + "/" + maxHealth + " " + mana + "/" + maxMana, 
										  x + 40, 
										  y, 
										  "default", 
										  GC.INVENTORY_DEFAULT_FONT_SIZE, 
										  0xFFFFFF, 
										  500);
			
			var properties:Array = Game.dataloader.setupMob(_name, _items);
			attackDamage = properties[0];
			spells = properties[1];
			consumables = properties[2];
		}
		
		override public function update():void
		{
			super.update();
			
			spritemap.play(curAnimation);
		}
		
		public function updateStatDisplay():void
		{
			statDisplay.displayText.text = health + "/" + maxHealth + " " + mana + "/" + maxMana;
		}
		
	}

}
