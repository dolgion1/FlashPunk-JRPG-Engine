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
			
			displayTexts.push(experienceDisplay);
			displayTexts.push(strengthDisplay);
			displayTexts.push(agilityDisplay);
			displayTexts.push(spiritualityDisplay);
			displayTexts.push(damageRatingDisplay);
			displayTexts.push(damageTypeDisplay);
			displayTexts.push(attackTypeDisplay);
			displayTexts.push(armorRatingDisplay);
		}
		
		public function set stats(_stats:Array):void
		{
			experienceDisplay.displayText.text = "Experience: " + _stats[0];
			strengthDisplay.displayText.text = "Strength: " + _stats[1];
			agilityDisplay.displayText.text = "Agility: " + _stats[2];
			spiritualityDisplay.displayText.text = "Spirituality: " + _stats[3];
			damageRatingDisplay.displayText.text = "Damage: " + _stats[4];
			damageTypeDisplay.displayText.text = "Damage Type: " + Weapon.getDamageType(_stats[5]);
			attackTypeDisplay.displayText.text = "Attack Type: " + Weapon.getAttackType(_stats[6]);
			armorRatingDisplay.displayText.text = "Armor: " + _stats[7];
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