package utility 
{
	import entities.NPC;
	import entities.Player;
	/**
	 * ...
	 * @author dolgion
	 */
	public class DialogManager
	{
		public const NPC_TURN:int = 0;
		public const PLAYER_TURN:int = 1;
		
		public var currentDialog:Array = new Array;
		public var currentLine:int;
		public var currentTurn:int;
		
		public function DialogManager() {}
		
		// Check if the dialog is finished 
		public function get dialogHasEnded():Boolean
		{
			if (currentLine >= currentDialog[currentTurn].lines.length) 
			{
				currentTurn = 0;
				currentLine = 0;
				return true;
			}
			else return false;
		}
		
		// Give back the appropriate response to the player's line
		public function nextNPCLine(_playerResponse:int):String
		{
			var nextLine:String = currentDialog[NPC_TURN].lines[currentLine].versions[_playerResponse];
			currentTurn = PLAYER_TURN;
			
			return nextLine;
		}
		
		// Give back the possible dialog options as an array of strings
		public function get nextPlayerLineVersions():Array
		{
			var nextLineVersions:Array = currentDialog[PLAYER_TURN].lines[currentLine].versions;
			currentTurn = NPC_TURN;
			currentLine++;
			
			return nextLineVersions;
		}
		
		// Figure out which dialog with the given npc and player is next
		public function setCurrentDialogWithPlayer(_player:Player, _npc:NPC):Boolean
		{
			if (_npc == null) return false;
			
			currentDialog = new Array();
			
			// dialogCounters is a dictionary that stores the index of the current dialog 
			// of the dialogs[] array 
			// If there isn't even an entry for the npc, then return false
			if (_player.dialogCounters[_npc.name] == undefined)
			{
				return false;
			}
			// if there is an entry, but it indicates that all possible dialogs are already 
			// 'done', then return false as well
			else if (_player.dialogCounters[_npc.name] >= _player.dialogsInTotal[_npc.name])
			{
				return false
			}
			// If we get here, it means there IS a conversation there, so find it
			else 
			{
				var d:Dialog;
				var i:int;
				
				var dialogsWithGivenNPC:Array = new Array();
				for (i = 0; i < _player.dialogs.length; i++)
				{
					d = _player.dialogs[i];
					if (d.partner == _npc.name)
					{
						dialogsWithGivenNPC.push(d);
					}
				}
				
				var dialogsOfGivenNPC:Array = new Array();
				for (i = 0; i < _npc.dialogs.length; i++)
				{
					d = _npc.dialogs[i];
					if (d.partner == "player")
					{
						dialogsOfGivenNPC.push(d);
					}
				}
				
				currentDialog.push(dialogsOfGivenNPC[_npc.dialogCounters["player"]]);
				currentDialog.push(dialogsWithGivenNPC[_player.dialogCounters[_npc.name]]);
				
				currentTurn = NPC_TURN;
				currentLine = 0;
				
				_player.dialogCounters[_npc.name]++;
				_npc.dialogCounters["player"]++;
				
				return true;
			}
		}
	}
}