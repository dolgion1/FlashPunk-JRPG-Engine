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
		public const DEFAULT_FONT_SIZE:int = 12;
		
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
			
			experienceDisplay = new DisplayText("Experience: ", 250, 50, "default", DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			strengthDisplay = new DisplayText("Strength: ", 250, 90, "default", DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			agilityDisplay = new DisplayText("Agility: ", 250, 130, "default", DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			spiritualityDisplay = new DisplayText("Spirituality: ", 250, 170, "default", DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			damageRatingDisplay = new DisplayText("Damage: ", 250, 210, "default", DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			damageTypeDisplay = new DisplayText("Damage Type: ", 250, 250, "default", DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			attackTypeDisplay = new DisplayText("Attack Type: ", 250, 290, "default", DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			armorRatingDisplay = new DisplayText("Armor: ", 250, 330, "default", DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			healthDisplay = new DisplayText("Health: ", 70, 170, "default", DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			manaDisplay = new DisplayText("Mana: ", 70, 210, "default", DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			
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
			healthDisplay.displayText.text = "Health: " + _stats[Constants.STATUS_HEALTH];
			manaDisplay.displayText.text = "Mana: " + _stats[Constants.STATUS_MANA];
			strengthDisplay.displayText.text = "Strength: " + _stats[Constants.STATUS_STRENGTH];
			agilityDisplay.displayText.text = "Agility: " + _stats[Constants.STATUS_AGILITY];
			spiritualityDisplay.displayText.text = "Spirituality: " + _stats[Constants.STATUS_SPIRITUALITY];
			experienceDisplay.displayText.text = "Experience: " + _stats[Constants.STATUS_EXPERIENCE];
			
			damageRatingDisplay.displayText.text = "Damage: " + _stats[Constants.STATUS_DAMAGE];
			damageTypeDisplay.displayText.text = "Damage Type: " + Weapon.getDamageType(_stats[Constants.STATUS_DAMAGE_TYPE]);
			attackTypeDisplay.displayText.text = "Attack Type: " + Weapon.getAttackType(_stats[Constants.STATUS_ATTACK_TYPE]);
			armorRatingDisplay.displayText.text = "Armor: " + _stats[Constants.STATUS_ARMOR];
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