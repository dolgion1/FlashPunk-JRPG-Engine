package utility 
{
	import net.flashpunk.FP;
	import entities.Player;
	
	/**
	 * ...
	 * @author dolgion
	 */
	public class Camera
	{
		private var cameraOffset:Number;
		private var cameraSpeed:Number;
		
		public function Camera(_cameraOffset:Number, _cameraSpeed:Number) 
		{
			cameraOffset = _cameraOffset;
			cameraSpeed = _cameraSpeed;
		}
		
		public function adjustToPlayer(mapHeight:int, mapWidth:int, player:Player):void
		{
			// Find the coordinates to that would center the player 
			var newCameraX:int = (player.x + player.width/2) - FP.width / 2;
			var newCameraY:int = (player.y + player.height/2) - FP.height / 2;
			
			// Check if they go beyond map boundaries
			if (newCameraX < 0) newCameraX = 0;
			else if (newCameraX + FP.width > mapWidth) newCameraX = mapWidth - FP.width;
			
			if (newCameraY < 0) newCameraY = 0;
			else if (newCameraY + FP.height > mapHeight) newCameraY = mapHeight - FP.height;
			
			// Set the camera coordinates
			FP.camera.x = newCameraX;
			FP.camera.y = newCameraY;
		}
		
		public function followPlayer (mapHeight:Number, mapWidth:Number, player:Player):void
		{
			if (player.x - FP.camera.x < cameraOffset) 
			{
				if (FP.camera.x > 0) FP.camera.x -= cameraSpeed;
			}
			else if ((FP.camera.x + FP.width) -  (player.x + player.width) < cameraOffset)
			{
				if (FP.camera.x + FP.width < mapWidth) FP.camera.x += cameraSpeed;
			}
			
			if (player.y - FP.camera.y < cameraOffset) 
			{
				if (FP.camera.y > 0) FP.camera.y -= cameraSpeed;
			}
			else if ((FP.camera.y + FP.height) - (player.y + player.height) < cameraOffset)
			{
				if (FP.camera.y + FP.height < mapHeight) FP.camera.y += cameraSpeed;
			}
		}
	}
}