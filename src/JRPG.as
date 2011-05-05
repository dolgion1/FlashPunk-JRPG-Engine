package 
{
	import net.flashpunk.Engine;
	import net.flashpunk.FP;
	import worlds.Battle;
	import worlds.Game;
	import utility.GC;
	
	/**
	 * ...
	 * @author Dolgion
	 */

	[SWF(width = "624", height = "480")]

	public class JRPG extends Engine 
	{
		public static var game:Game = new Game();
		
		public function JRPG():void
		{
			super(624, 480, 60, false);
			FP.console.enable();
			FP.world = game;
		}
		
		override public function init():void 
		{
			FP.log("Checking if the move to eclipse worked again.");
		}
	}
}
