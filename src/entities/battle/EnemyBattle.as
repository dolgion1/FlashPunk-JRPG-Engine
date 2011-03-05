package entities.battle 
{
	import entities.DisplayText;
	import flash.geom.Point;
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import utility.*;
	/**
	 * ...
	 * @author dolgion1
	 */
	public class EnemyBattle extends Entity
	{
		
		public var spritemap:Spritemap;
		public var curAnimation:String;
		public var mobType:int;
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
		
		public function EnemyBattle(_position:Point, _keyIndex:int) 
		{
			graphic = spritemap;
			spritemap.play(curAnimation);
			
			x = _position.x;
			y = _position.y;
			key = "Enemy" + _keyIndex;
			
			statDisplay = new DisplayText(health + "/" + maxHealth + " " + mana + "/" + maxMana, 
										  x + 40, 
										  y, 
										  "default", 
										  GC.INVENTORY_DEFAULT_FONT_SIZE, 
										  0xFFFFFF, 
										  500);
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
