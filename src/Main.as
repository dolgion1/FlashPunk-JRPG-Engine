﻿package 
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

	public class Main extends Engine 
	{
		public static var game:Game = new Game();
		
		public function Main():void
		{
			super(624, 480, 60, false);
			FP.console.enable();
			FP.world = game;
		}
		
		override public function init():void 
		{
			FP.log("FlashPunk started successfully.");
		}
	}
}
