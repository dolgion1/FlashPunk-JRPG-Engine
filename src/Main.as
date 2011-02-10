﻿package 
{
	import net.flashpunk.Engine;
	import net.flashpunk.FP;
	import worlds.Game;
	import utility.GC;
	
	/**
	 * ...
	 * @author Dolgion
	 */

	[SWF(width = "624", height = "480")]

	public class Main extends Engine 
	{
		public function Main():void
		{
			super(624, 480, 60, false);
			FP.console.enable();
			GC.loadData();
			FP.world = new Game();
			
		}
		
		override public function init():void 
		{
			FP.log("FlashPunk started successfully.");
		}
	}
}
