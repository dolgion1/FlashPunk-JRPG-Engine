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
		
		// entities
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
					charCount += words[i].length + (i - j);
					if (charCount > charsPerRow)
					{
						// We take the previous elements
						// and join them together with a space character
						// it becomes a member in the displayTextFeed
						var line:String = words.slice(j, i).join(" ");
						displayTextFeed.push(new DisplayTextFeed(line, dCounter - 1));
						j = i;
						charCount = 0;
						
						if (displayTextFeed.length == maxRows)
						{
							endDisplayTextFeedIndex = displayTextFeed.length;
						}
					}
					if (i == words.length - 1)
					{
						displayTextFeed.push(new DisplayTextFeed(words.slice(j, i + 1).join(" "), dCounter - 1));
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
			highlightChosenVersion();
		}
		
		public function populateDisplayTexts():void
		{
			// clear up eventual text from before
			resetDisplayTexts();
			var displayTextIndex:int = 0;
			for (var i:int = startDisplayTextFeedIndex; i < endDisplayTextFeedIndex; i++)
			{
				if (displayTextFeed[i].text.charCodeAt(0) >= 49 && 
					displayTextFeed[i].text.charCodeAt(0) <= 57)
				{
					displayTexts[displayTextIndex].displayText.text = displayTextFeed[i].text;
				}
				else
				{
					displayTexts[displayTextIndex].displayText.text = "  " + displayTextFeed[i].text;
				}
				displayTextIndex++;
			}
		}
		
		public function highlightChosenVersion():void
		{
			// find the displayTexts that show a part if not the entire dialog option
			// and highlight them
			var currentDisplayText:int = 0;
			for (var i:int = startDisplayTextFeedIndex; i < endDisplayTextFeedIndex; i++)
			{
				if (displayTextFeed[i].version == chosenVersion)
				{
					highlightDisplayText(currentDisplayText);
				}
				else
				{
					unhighlightDisplayText(currentDisplayText);
				}
				currentDisplayText++;
			}
		}
		
		public function versionPortion(_line:String):int
		{
			for (var i:int = 0; i < _line.length; i++)
			{
				if (_line.charAt(i) == ".")
				{
					return int(_line.substring(0, i));
				}
			}
			return -1;
		}
		
		public function selectionUp():void
		{
			if (chosenVersion > 1)
			{
				chosenVersion--;
				changeSelection("up");
			}
		}
		
		public function selectionDown():void
		{
			if (chosenVersion < dialogOptions.length)
			{
				chosenVersion++;
				changeSelection("down");
			}
		}
		
		public function changeSelection(_direction:String):void
		{
			// find out if the chosen dialog option is displayed in the text box
			var startIndex:int = 0;
			var endIndex:int = 0;
			for (var i:int = 0; i < displayTextFeed.length; i++)
			{
				if (displayTextFeed[i].version == chosenVersion)
				{
					startIndex = i;
					break;
				}
			}
			for (i = startIndex; i < displayTextFeed.length; i++)
			{
				if (displayTextFeed[i].version != chosenVersion)
				{
					endIndex = i;
					break;
				}
				else if (i == displayTextFeed.length - 1)
				{
					endIndex = displayTextFeed.length;
					break;
				}
			}
			
			// if the dialog option is too huge to display all at once, display the first portion
			if (maxRows < (endIndex - startIndex)) 
			{
				startDisplayTextFeedIndex = startIndex;
				endDisplayTextFeedIndex = startDisplayTextFeedIndex + maxRows;
				populateDisplayTexts();
				highlightChosenVersion();
			}
			else if ((_direction == "up") && (startDisplayTextFeedIndex > startIndex)) // if the dialog portion starts above what is seen now, scroll there
			{
				startDisplayTextFeedIndex = startIndex;
				endDisplayTextFeedIndex = startDisplayTextFeedIndex + maxRows;
				populateDisplayTexts();
				highlightChosenVersion();
			}
			else if ((_direction == "down") && (endDisplayTextFeedIndex < endIndex)) // if the dialog portion ends below what is seen now, scroll there
			{
				endDisplayTextFeedIndex = endIndex;
				startDisplayTextFeedIndex = endDisplayTextFeedIndex - maxRows;
				populateDisplayTexts();
				highlightChosenVersion();
			}
			else // simply change the highlight, since the dialog option is already fully visible
			{
				highlightChosenVersion();
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
		
		public function highlightDisplayText(_index:int):void
		{
			displayTexts[_index].displayText.color = 0xFF0000;
		}
		
		public function unhighlightDisplayText(_index:int):void
		{
			displayTexts[_index].displayText.color = 0xFFFFFF;
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