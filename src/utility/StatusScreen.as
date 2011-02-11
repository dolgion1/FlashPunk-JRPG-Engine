package utility 
{
	import entities.DisplayText;
	import entities.PlayerPortrait;
	import entities.TextBox;
	import net.flashpunk.Entity;
	
	/**
	 * ...
	 * @author dolgion
	 */
	public class StatusScreen
	{
		public var background:TextBox;
		public var portrait:PlayerPortrait;
		public var displayTexts:Array = new Array();
		public var experienceDisplay:DisplayText;
		public var strengthDisplay:DisplayText;
		public var agilityDisplay:DisplayText;
		public var spiritualityDisplay:DisplayText;
		public var damageRatingDisplay:DisplayText;
		public var damageTypeDisplay:DisplayText;
		public var attackTypeDisplay:DisplayText;
		public var armorRatingDisplay:DisplayText;
		public var healthDisplay:DisplayText;
		public var manaDisplay:DisplayText;
		
		private var visibility:Boolean = false;
		
		public function StatusScreen() 
		{
			background = new TextBox(10, 10, 3, 4.5);
			portrait = new PlayerPortrait(50, 50);
			
			experienceDisplay = new DisplayText(GC.EXPERIENCE_STRING + ": ", 245, 40, "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			strengthDisplay = new DisplayText(GC.STRENGTH_STRING + ": ", 245, 55, "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			agilityDisplay = new DisplayText(GC.AGILITY_STRING + ": ", 245, 70, "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			spiritualityDisplay = new DisplayText(GC.SPIRITUALITY_STRING + ": ", 245, 85, "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			damageRatingDisplay = new DisplayText(GC.DAMAGE_STRING + ": ", 245, 110, "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			damageTypeDisplay = new DisplayText(GC.DAMAGE_TYPE_STRING + ": ", 245, 125, "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			attackTypeDisplay = new DisplayText(GC.ATTACK_TYPE_STRING + ": ", 245, 140, "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			armorRatingDisplay = new DisplayText(GC.ARMOR_STRING + ": ", 245, 155, "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			healthDisplay = new DisplayText(GC.HEALTH_STRING + ": ", 55, 170, "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			manaDisplay = new DisplayText(GC.MANA_STRING + ": ", 55, 185, "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			
			displayTexts.push(experienceDisplay);
			displayTexts.push(strengthDisplay);
			displayTexts.push(agilityDisplay);
			displayTexts.push(spiritualityDisplay);
			displayTexts.push(damageRatingDisplay);
			displayTexts.push(damageTypeDisplay);
			displayTexts.push(attackTypeDisplay);
			displayTexts.push(armorRatingDisplay);
			displayTexts.push(healthDisplay);
			displayTexts.push(manaDisplay);
		}
		
		public function set stats(_stats:Array):void
		{
			healthDisplay.displayText.text = GC.HEALTH_STRING + ": " + _stats[GC.STATUS_HEALTH] + "/" + _stats[GC.STATUS_MAX_HEALTH];
			manaDisplay.displayText.text = GC.MANA_STRING + ": " + _stats[GC.STATUS_MANA] + "/" + _stats[GC.STATUS_MAX_MANA];
			strengthDisplay.displayText.text = GC.STRENGTH_STRING + ": " + _stats[GC.STATUS_STRENGTH];
			agilityDisplay.displayText.text = GC.AGILITY_STRING + ": " + _stats[GC.STATUS_AGILITY];
			spiritualityDisplay.displayText.text = GC.SPIRITUALITY_STRING + ": " + _stats[GC.STATUS_SPIRITUALITY];
			experienceDisplay.displayText.text = GC.EXPERIENCE_STRING + ": " + _stats[GC.STATUS_EXPERIENCE];
			
			damageRatingDisplay.displayText.text = GC.DAMAGE_STRING + ": " + _stats[GC.STATUS_DAMAGE];
			damageTypeDisplay.displayText.text = GC.DAMAGE_TYPE_STRING + ": " + Weapon.getDamageType(_stats[GC.STATUS_DAMAGE_TYPE]);
			attackTypeDisplay.displayText.text = GC.ATTACK_TYPE_STRING + ": " + Weapon.getAttackType(_stats[GC.STATUS_ATTACK_TYPE]);
			armorRatingDisplay.displayText.text = GC.ARMOR_STRING + ": " + _stats[GC.STATUS_ARMOR];
		}
		
		public function get visible():Boolean
		{
			return visibility;
		}
		
		public function set visible(_visible:Boolean):void
		{
			visibility = _visible;
			background.visible = _visible;
			portrait.visible = _visible;
			for each (var d:DisplayText in displayTexts)
			{
				d.visible = _visible;	
			}
		}
	}

}