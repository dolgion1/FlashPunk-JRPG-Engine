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
		public var intelligenceDisplay:DisplayText;
		
		private var visibility:Boolean = false;
		
		public function StatusScreen() 
		{
			background = new TextBox(10, 10, 3, 4.5);
			portrait = new PlayerPortrait(50, 50);
			
			experienceDisplay = new DisplayText("Experience: ", 250, 50, "default", DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			strengthDisplay = new DisplayText("Strength: ", 250, 90, "default", DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			agilityDisplay = new DisplayText("Agility: ", 250, 130, "default", DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			intelligenceDisplay = new DisplayText("Intelligence: ", 250, 170, "default", DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			
			displayTexts.push(experienceDisplay);
			displayTexts.push(strengthDisplay);
			displayTexts.push(agilityDisplay);
			displayTexts.push(intelligenceDisplay);
		}
		
		public function set stats(_stats:Array):void
		{
			experienceDisplay.displayText.text = "Experience: " + _stats[0];
			strengthDisplay.displayText.text = "Strength: " + _stats[1];
			agilityDisplay.displayText.text = "Agility: " + _stats[2];
			intelligenceDisplay.displayText.text = "Intelligence: " + _stats[3];
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