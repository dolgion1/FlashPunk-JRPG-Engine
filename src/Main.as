﻿package 
{
	import net.flashpunk.Engine;
	import net.flashpunk.FP;
	import worlds.Game;
	
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
			FP.world = new Game();
			FP.console.enable();
		}
		
		override public function init():void 
		{
			trace("FlashPunk started successfully.");
		}
	}
}