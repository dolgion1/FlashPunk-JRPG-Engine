package utility
{
	import entities.*;
	/**
	 * ...
	 * @author dolgion
	 */
	public class PlayerDialogBox
	{
		public const DEFAULT_FONT_SIZE:int = 12;
		
		public var textBox:TextBox;
		public var displayTexts:Array = new Array();
		public var dialogOptions:Array = new Array();
		public var displayTextFeed:Array = new Array();
		public var x:int;
		public var y:int;
		public var currentPage:int;
		public var charsPerRow:int;
		public var maxRows:int;
		public var startDisplayTextFeedIndex:int;
		public var endDisplayTextFeedIndex:int;
		public var chosenVersion:int;
		private var text:String;
		private var visibility:Boolean;
		
		
		private var charCount:int;
		private var words:Array = new Array();
		
		public function PlayerDialogBox(_x:int, _y:int, _scaleX:Number, _scaleY:Number)
		{
			x = _x;
			y = _y;
			textBox = new TextBox(_x, _y,  _scaleX,  _scaleY);
			charsPerRow = _scaleX * 46;
			maxRows = _scaleY * 3;
			initDisplayTexts(_scaleX, _scaleY);
		}
		
		public function set lineVersions(_versions:Array):void
		{
			dialogOptions = _versions; // an array containing the strings for the dialog options of the current line
			displayTextFeed = new Array();
			startDisplayTextFeedIndex = 0;
			endDisplayTextFeedIndex = 0;
			var dCounter:int = 1;
			for each (var d:String in dialogOptions)
			{
				words = d.split(" ");
				words[0] = dCounter + ". " + words[0];
				dCounter++;
				charCount = 0;
				var j:int = 0;
				for (var i:int = 0; i < words.length; i++)
				{
					charCount += words[i].length + i;
					if (charCount > charsPerRow)
					{
						// We take the previous elements
						// and join them together with a space character
						// it becomes a member in the displayTextFeed
						var line:String = words.slice(j, i).join(" ");
						displayTextFeed.push(line);
						j = i;
						charCount = 0;
						
						if (displayTextFeed.length == maxRows)
						{
							endDisplayTextFeedIndex = displayTextFeed.length;
						}
					}
					if (i == words.length - 1)
					{
						displayTextFeed.push(words.slice(j, i + 1).join(" "));
						if (endDisplayTextFeedIndex < maxRows)
						{
							endDisplayTextFeedIndex = displayTextFeed.length;
						}
					}
				}
			}
			
			// At this point, we have the altered displayTextFeed ready for serving
			chosenVersion = 1;
			populateDisplayTexts();
		}
		
		public function populateDisplayTexts():void
		{
			// clear up eventual text from before
			resetDisplayTexts();
			var currentVersion:int = chosenVersion;
			var displayTextIndex:int = 0;
			var chosenRows:Array = new Array(); // contains the indices of displayTexts elements that are to be highlighted
			for (var i:int = startDisplayTextFeedIndex; i < endDisplayTextFeedIndex; i++)
			{
				if (displayTextFeed[i].charCodeAt(0) >= 49 && 
					displayTextFeed[i].charCodeAt(0) <= 57)
				{
					currentVersion = int(versionPortion(displayTextFeed[i]));
					displayTexts[displayTextIndex].displayText.text = displayTextFeed[i];
					
					// When the beginning of a new dialog option is at the first row,
					// update the current version
					if (displayTextIndex == 0) 
					{
						chosenVersion = currentVersion;
						displayTexts[displayTextIndex].displayText.color = 0xFF0000;
						displayTexts[displayTextIndex].displayText.size = 14;
					}
				}
				else
				{
					displayTexts[displayTextIndex].displayText.text = "  " + displayTextFeed[i];
					if (currentVersion == chosenVersion)
					{
						displayTexts[displayTextIndex].displayText.color = 0xFF0000;
						displayTexts[displayTextIndex].displayText.size = 14;
					}
				}
				
				
				displayTextIndex++;
			}
			
		}
		
		public function versionPortion(_line:String):String
		{
			for (var i:int = 0; i < _line.length; i++)
			{
				if (_line.charAt(i) == ".")
				{
					return _line.substring(0, i);
				}
			}
			return null;
		}
		
		public function scrollUp():void
		{
			if (startDisplayTextFeedIndex > 0)
			{
				startDisplayTextFeedIndex--;
				endDisplayTextFeedIndex--;
				populateDisplayTexts();
			}
		}
		
		public function scrollDown():void
		{
			if (endDisplayTextFeedIndex < displayTextFeed.length)
			{
				startDisplayTextFeedIndex++;
				endDisplayTextFeedIndex++;
				populateDisplayTexts();
			}
		}
		
		public function initDisplayTexts(_scaleX:int, _scaleY:int):void
		{
			for (var i:int = 0; i < maxRows; i++)
			{
				displayTexts[i] = new DisplayText("", x + 10 + (_scaleX * 3), y + (i * 30) + (_scaleY * 3), "default", DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			}
		}
		
		public function resetDisplayTexts():void
		{
			for (var i:int = 0; i < maxRows; i++)
			{
				displayTexts[i].displayText.text = "";
				displayTexts[i].displayText.color = 0xFFFFFF;
				displayTexts[i].displayText.size = DEFAULT_FONT_SIZE;
			}
		}
		
		public function get visible():Boolean
		{
			return visibility;
		}
		
		public function set visible(_visible:Boolean):void
		{
			visibility = _visible;
			textBox.visible = _visible;
			for each (var d:DisplayText in displayTexts)
			{
				d.visible = _visible;
			}
		}
		
	}

}