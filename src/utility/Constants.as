package utility
{
	import net.flashpunk.FP;
	import flash.geom.Point;
	import flash.utils.ByteArray;

	/**
	 * ...
	 * @author dolgion
	 */
	public class Constants
	{
		[Embed(source = "../../assets/scripts/constants_data.xml", mimeType = "application/octet-stream")] 
		private static var constantsData:Class;

		public static var cameraOffset:int;

		public static var mapDisplayText:Point;
		public static var daytimeDisplayText:Point;
		public static var timeDisplayText:Point;

		public static var npcDialogBoxX:int;
		public static var npcDialogBoxY:int;
		public static var npcDialogBoxScaleX:Number;
		public static var npcDialogBoxScaleY:Number;

		public static var playerDialogBoxX:int;
		public static var playerDialogBoxY:int;
		public static var playerDialogBoxScaleX:Number;
		public static var playerDialogBoxScaleY:Number;

		public static var npcSpriteWidth:int;
		public static var npcSpriteHeight:int;
		public static var npcHitboxWidth:int;
		public static var npcHitboxHeight:int;
		public static var npcHitboxOffsetX:int;
		public static var npcHitboxOffsetY:int;
		public static var npcSpeed:Number;
		public static var npcAnimations:Array;

		public static var playerSpriteWidth:int;
		public static var playerSpriteHeight:int;
		public static var playerHitboxWidth:int;
		public static var playerHitboxHeight:int;
		public static var playerHitboxOffsetX:int;
		public static var playerHitboxOffsetY:int;
		public static var playerNormalSpeed:Number;
		public static var playerDiagonalSpeed:Number;
		public static var playerDialogDistance:int;
		public static var playerEnterHouseDistance:int;
		public static var playerAnimations:Array;

		public static var tileSize:int;
		public static var rectSize:int;

		public static var npcDialogBoxDefaultFontSize:int;
		public static var npcDialogBoxScaleXMultiplier:Number;
		public static var npcDialogBoxScaleYMultiplier:Number;

		public static var playerDialogBoxDefaultFontSize:int;
		public static var playerDialogBoxScaleXMultiplier:Number;
		public static var playerDialogBoxScaleYMultiplier:Number;

		public static var pathfindingNormalCost:int;
		public static var pathfindingDiagonalCost:int;

		public static var gridOverlayScaleDivider:int;

		public static var inventoryOffsetX:int;
		public static var inventoryOffsetY:int;
		public static var inventoryScaleX:Number;
		public static var inventoryScaleY:Number;
		public static var inventoryItemRows:int;
		public static var inventoryItemColumns:int;
	

		public function Constants() { }
		
		public static function loadData():void
		{
			var constantsDataByteArray:ByteArray = new constantsData;
			var constantsDataXML:XML = new XML(constantsDataByteArray.readUTFBytes(constantsDataByteArray.length));

			cameraOffset = constantsDataXML.camera_offset;

			mapDisplayText = new Point(constantsDataXML.map_display_text.@x, constantsDataXML.map_display_text.@y);
			daytimeDisplayText = new Point(constantsDataXML.daytime_display_text.@x, constantsDataXML.daytime_display_text.@y);
			timeDisplayText = new Point(constantsDataXML.time_display_text.@x, constantsDataXML.time_display_text.@y);

			npcDialogBoxX = constantsDataXML.npc_dialog_box.@x;
			npcDialogBoxY = constantsDataXML.npc_dialog_box.@y;
			npcDialogBoxScaleX = constantsDataXML.npc_dialog_box.@scaleX;
			npcDialogBoxScaleY = constantsDataXML.npc_dialog_box.@scaleY;
			npcDialogBoxScaleXMultiplier = constantsDataXML.npc_dialog_box.@scaleXMultiplier;
			npcDialogBoxScaleYMultiplier = constantsDataXML.npc_dialog_box.@scaleYMultiplier;
			npcDialogBoxDefaultFontSize = constantsDataXML.npc_dialog_box.@defaultFontSize;

			playerDialogBoxX = constantsDataXML.player_dialog_box.@x;
			playerDialogBoxY = constantsDataXML.player_dialog_box.@y;
			playerDialogBoxScaleX = constantsDataXML.player_dialog_box.@scaleX;
			playerDialogBoxScaleY = constantsDataXML.player_dialog_box.@scaleY;
			playerDialogBoxScaleXMultiplier = constantsDataXML.player_dialog_box.@scaleXMultiplier;
			playerDialogBoxScaleYMultiplier = constantsDataXML.player_dialog_box.@scaleYMultiplier;
			playerDialogBoxDefaultFontSize = constantsDataXML.player_dialog_box.@defaultFontSize;

			npcSpriteWidth = constantsDataXML.npc_sprite.@width;
			npcSpriteHeight = constantsDataXML.npc_sprite.@height;
			npcHitboxWidth = constantsDataXML.npc_hitbox.@width;
			npcHitboxHeight = constantsDataXML.npc_hitbox.@height;
			npcHitboxOffsetX = constantsDataXML.npc_hitbox.@xOffset;
			npcHitboxOffsetY = constantsDataXML.npc_hitbox.@yOffset;
			npcSpeed = constantsDataXML.npc_speed;

			npcAnimations = new Array();
			for each (var anim:XML in constantsDataXML.npc_animation)
			{
				var frameIndexArray:Array = new Array();
				if (anim.@loop == true)
				{
					for (var i:int = anim.@startFrame; i < anim.@endFrame; i++)
					{
						frameIndexArray.push(i);
					}
					npcAnimations.push(new Animation(anim.@name, frameIndexArray, anim.@frameRate, true));
				}
				else 
				{
					frameIndexArray.push(anim.@frame);
					npcAnimations.push(new Animation(anim.@name, frameIndexArray, 0, false));
				}
			}

			playerSpriteWidth = constantsDataXML.player_sprite.@width;
			playerSpriteHeight = constantsDataXML.player_sprite.@height;
			playerHitboxWidth = constantsDataXML.player_hitbox.@width;
			playerHitboxHeight = constantsDataXML.player_hitbox.@height;
			playerHitboxOffsetX = constantsDataXML.player_hitbox.@xOffset;
			playerHitboxOffsetY = constantsDataXML.player_hitbox.@yOffset;
			playerNormalSpeed = constantsDataXML.player_speed.@normal;
			playerDiagonalSpeed = constantsDataXML.player_speed.@diagonal;
			playerDialogDistance = constantsDataXML.player_dialog_distance;
			playerEnterHouseDistance = constantsDataXML.player_enter_house_distance;

			playerAnimations = new Array();
			for each (anim in constantsDataXML.player_animation)
			{
				frameIndexArray = new Array();
				if (anim.@loop == true)
				{
					for (i = anim.@startFrame; i < anim.@endFrame; i++)
					{
						frameIndexArray.push(i);
					}
					playerAnimations.push(new Animation(anim.@name, frameIndexArray, anim.@frameRate, true));
				}
				else 
				{
					frameIndexArray.push(anim.@frame);
					playerAnimations.push(new Animation(anim.@name, frameIndexArray, 0, false));
				}
			}

			tileSize = constantsDataXML.tile_size;
			rectSize = constantsDataXML.rect_size;

			pathfindingNormalCost = constantsDataXML.pathfinding_normal_cost;
			pathfindingDiagonalCost = constantsDataXML.pathfinding_diagonal_cost;

			gridOverlayScaleDivider = constantsDataXML.grid_overlay_scale_divider;

			inventoryOffsetX = constantsDataXML.inventory_x_offset;
			inventoryOffsetY = constantsDataXML.inventory_y_offset;
			inventoryScaleX = constantsDataXML.inventory_x_scale;
			inventoryScaleY = constantsDataXML.inventory_y_scale;
			inventoryItemRows = constantsDataXML.inventory_item_rows;
			inventoryItemColumns = constantsDataXML.inventory_item_columns;
		}

	}

}
