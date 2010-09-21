package utility
{
	import entities.*;
	/**
	 * ...
	 * @author dolgion
	 */
	public class NPCDialogBox
	{
		public const DEFAULT_FONT_SIZE:int = 12;
		
		// entities
		public var textBox:TextBox;
		public var displayTexts:Array = new Array();
		
		public var pages:Array = new Array();
		public var x:int;
		public var y:int;
		public var currentPage:int;
		public var charsPerRow:int;
		public var rowsPerPage:int;
		private var text:String;
		private var visibility:Boolean;
		
		public function NPCDialogBox(_x:int, _y:int, _scaleX:Number, _scaleY:Number)
		{
			x = _x;
			y = _y;
			textBox = new TextBox(_x, _y,  _scaleX,  _scaleY);
			charsPerRow = _scaleX * 46;
			rowsPerPage = _scaleY * 3;
			initDisplayTexts(_scaleX);
		}
		
		public function set line(_text:String):void
		{
			pages = new Array();
			
			// find the subset of words that is within the max character count
			var words:Array = _text.split(" ");
			var charCount:int = 0;
			var j:int = 0;
			for (var i:int = 0; i < words.length; i++)
			{
				// Going through all words of the given text
				// the text must be distributed over pages, each able
				// to contain [rowsPerPage * charsPerRow] characters
				
				// we count the characters of the words combined
				// if the charCount would be above [rowsPerPage * charsPerRow] if the 
				// next word was added, we know that the subset of 
				// words from j to i has to be pushed into pages
				charCount += words[i].length + (i - j); // i - j is to add up the spaces
				
				if (charCount > (charsPerRow * rowsPerPage))
				{
					// push the subset of words that is within [charsPerRow * rowsPerPage] chars
					pages.push(words.slice(j, i + 1));
					charCount = 0;
					j = i;
				}
				
				if (i == words.length - 1)
				{
					// we are at the end of the words array
					pages.push(words.slice(j, i + 1));
				}
			}
			
			currentPage = 0;
			nextPage();
		}
		
		public function nextPage():void
		{
			// clear up eventual text from before
			resetDisplayTexts();
			
			// this method has the task to display the current page 
			// in the displayTexts array of DisplayText instances
			// each line can contain [charsPerRow] characters though, so if the page
			// has more characters in total, they must be broken up over
			// maximum [rowsPerPage] rows. It is assured that a single page has
			// at maximum [rowsPerPage * charsPerRow] charactes though
			
			var displayTextIndex:int = 0;
			var currentRow:int = 0;
			var charCount:int = 0;
			var j:int = 0;
			var page:Array = pages[currentPage];
			
			for (var i:int = 0; i < page.length; i++)
			{
				charCount += page[i].length + (i - j);
				
				if (charCount > charsPerRow)
				{
					displayTexts[displayTextIndex].displayText.text = page.slice(j, i).join(" ");
					displayTextIndex++;
					charCount = 0;
					j = i;
				}
				if (i == page.length - 1)
				{
					displayTexts[displayTextIndex].displayText.text = page.slice(j, i + 1).join(" ");
					displayTextIndex++;
					break;
				}
			}
			currentPage++;
		}
		
		public function initDisplayTexts(_scaleX:int):void
		{
			for (var i:int = 0; i < rowsPerPage; i++)
			{
				displayTexts[i] = new DisplayText("", x + 10 + (_scaleX * 3), y + (i * 30), "default", DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			}
		}
		
		public function resetDisplayTexts():void
		{
			for (var i:int = 0; i < rowsPerPage; i++)
			{
				displayTexts[i].displayText.text = "";
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