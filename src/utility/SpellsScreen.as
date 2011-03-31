package utility 
{
	import entities.*;
	import net.flashpunk.*;
	import flash.utils.*;
	import worlds.*;
	
	/**
	 * ...
	 * @author dolgion
	 */
	public class SpellsScreen
	{
		public var player:Player; 
		public var background:TextBox;
		public var displayTexts:Array = new Array();
		
		public var spellsHeader:DisplayText;
		public var manaDisplay:DisplayText;
		public var listDisplays:Array = new Array();
		public var listStartIndex:int = 0;
		public var listEndIndex:int = 0;
		public var listDisplayOne:DisplayText;
		public var listDisplayTwo:DisplayText;
		public var listDisplayThree:DisplayText;
		public var listDisplayFour:DisplayText;
		
		public var cursor:Cursor;
		public var cursorPositions:Dictionary;
		public var currentCursorPositionKey:String = "ListRow1";
		
		private var visibility:Boolean = false;
		
		public function SpellsScreen(_spellsScreenUIData:Array) 
		{
			cursorPositions = _spellsScreenUIData[0];
			background = new TextBox(10, 10, 3, 4.5);
			cursor = new Cursor(0, 0);
			cursor.setPosition(cursorPositions[currentCursorPositionKey].getPosition());
			
			initDisplayTexts();
		}
		
		public function initDisplayTexts():void
		{
			// initialize all display texts
			spellsHeader = new DisplayText(GC.SPELLS_STRING, 40, 40, "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			manaDisplay = new DisplayText(GC.MANA_STRING + ": ", 400, 40, "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			
			listDisplays.push(new DisplayText("", 80, 70, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500));
			listDisplays.push(new DisplayText("", 80, 90, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500));
			listDisplays.push(new DisplayText("", 80, 110, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500));
			listDisplays.push(new DisplayText("", 80, 130, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500));
			listDisplays.push(new DisplayText("", 80, 150, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500));
			listDisplays.push(new DisplayText("", 80, 170, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500));
			
			listDisplayOne = new DisplayText("", 300, 70, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			listDisplayTwo = new DisplayText("", 300, 90, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			listDisplayThree = new DisplayText("", 300, 110, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			listDisplayFour = new DisplayText("", 300, 130, "default", GC.INVENTORY_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			
			// push them to the stage
			displayTexts.push(spellsHeader);
			displayTexts.push(manaDisplay);
			displayTexts.push(listDisplays[0]);
			displayTexts.push(listDisplays[1]);
			displayTexts.push(listDisplays[2]);
			displayTexts.push(listDisplays[3]);
			displayTexts.push(listDisplays[4]);
			displayTexts.push(listDisplays[5]);
			
			displayTexts.push(listDisplayOne);
			displayTexts.push(listDisplayTwo);
			displayTexts.push(listDisplayThree);
			displayTexts.push(listDisplayFour);
		}
		
		public function initialize(_player:Player):void
		{
			// when opening the spells screen
			player = _player;
			populateSpellListDisplays();
			setInfoDisplayTexts();
			manaDisplay.displayText.text = GC.MANA_STRING + ": " + player.mana;
		}
		
		public function populateSpellListDisplays():void
		{
			// invalidate cursor positions for the list row displays
			// and empty their texts
			for (var i:int = 0; i < 6; i++)
			{
				listDisplays[i].displayText.text = "";
				cursorPositions["ListRow" + (i + 1)].valid = false;
			}
			
			// set up listEndIndex
			if (player.spells.length > 6)
			{
				listEndIndex = 6;
			}
			else listEndIndex = player.spells.length;
			
			// validate cursor positions and set the texts for the 
			// corresponding list rows
			for (i = 0; i < listEndIndex; i++)
			{
				listDisplays[i].displayText.text = player.spells[i];
				cursorPositions["ListRow" + (i + 1)].valid = true;
			}
		}
		
		public function setInfoDisplayTexts():void
		{
			// set the texts of the info display texts based on the spell selected
			var spellIndex:int = int(currentCursorPositionKey.charAt(currentCursorPositionKey.length - 1)) - 1;
			var spell:String = listDisplays[spellIndex].displayText.text;
			
			listDisplayOne.displayText.text = "Name: " + spell;
			listDisplayTwo.displayText.text = "Effect: " + Game.spells[spell].description;
			listDisplayThree.displayText.text = "Manacost: " + Game.spells[spell].manaCost;
			
			if (Game.spells[spell].temporary)
			{ 
				listDisplayFour.displayText.text = "Duration: " + Game.spells[spell].duration;
			}
			else listDisplayFour.displayText.text = "";
		}
		
		public function cursorMovement(_direction:String):void
		{
			// handle cursor movement, checking whether a cursor position exists or is valid
			var newCursorPositionKey:String;
			
			switch(_direction)
			{
				case GC.BUTTON_UP: newCursorPositionKey = cursorPositions[currentCursorPositionKey].upKey; break;
				case GC.BUTTON_DOWN: newCursorPositionKey = cursorPositions[currentCursorPositionKey].downKey; break;
			}
			
			if (newCursorPositionKey != null)
			{
				if (cursorPositions[newCursorPositionKey].valid)
				{
					cursor.position = cursorPositions[newCursorPositionKey].getPosition();
					currentCursorPositionKey = newCursorPositionKey;
					setInfoDisplayTexts();
				}
			}
			
		}
		
		public function actionPress():void
		{
			var spellIndex:int = int(currentCursorPositionKey.charAt(currentCursorPositionKey.length - 1)) - 1 + listStartIndex;
			
			// only allow casting of defense spells in the spells screen
			if (Game.spells[player.spells[spellIndex]] is DefenseSpell)
			{
				var defenseSpell:DefenseSpell = new DefenseSpell();
				defenseSpell.name = Game.spells[player.spells[spellIndex]].name;
				defenseSpell.temporary = Game.spells[player.spells[spellIndex]].temporary;
				defenseSpell.duration = Game.spells[player.spells[spellIndex]].duration;
				defenseSpell.statusVariable = Game.spells[player.spells[spellIndex]].statusVariable;
				defenseSpell.alteration = Game.spells[player.spells[spellIndex]].alteration;
				defenseSpell.manaCost = Game.spells[player.spells[spellIndex]].manaCost; 
				
				if (!defenseSpell.temporary)
				{
					player.castOnSelf(defenseSpell);
					manaDisplay.displayText.text = GC.MANA_STRING + ": " + player.mana;
				}
			}
		}
		
		public function get visible():Boolean
		{
			return visibility;
		}
		
		public function set visible(_visible:Boolean):void
		{
			visibility = _visible;
			background.visible = _visible;
			cursor.visible = _visible;
			for each (var d:DisplayText in displayTexts)
			{
				d.visible = _visible;	
			}
		}
	}

}
