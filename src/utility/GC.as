package utility
{
	import net.flashpunk.FP;
	import flash.geom.Point;
	import flash.utils.ByteArray;

	/**
	 * ...
	 * @author dolgion
	 */
	public class GC
	{
		/*
		 *  Game Constants 
		 */
		
		// Input buttons
		public static const BUTTON_UP:String = "up";
		public static const BUTTON_DOWN:String = "down";
		public static const BUTTON_LEFT:String = "left";
		public static const BUTTON_RIGHT:String = "right";
		public static const BUTTON_MAP:String = "map";
		public static const BUTTON_CANCEL:String = "cancel";
		public static const BUTTON_EXIT:String = "exit";
		public static const BUTTON_ACTION:String = "action";
		public static const BUTTON_STATUS_SCREEN:String = "status_screen";
		public static const BUTTON_INVENTORY_SCREEN:String = "inventory_screen";
		
		// Status Variables
		public static const STATUS_HEALTH:int = 0;
		public static const STATUS_MAX_HEALTH:int = 1;
		public static const STATUS_MANA:int = 2;
		public static const STATUS_MAX_MANA:int = 3;
		public static const STATUS_STRENGTH:int = 4;
		public static const STATUS_AGILITY:int = 5;
		public static const STATUS_SPIRITUALITY:int = 6;
		public static const STATUS_EXPERIENCE:int = 7;
		public static const STATUS_DAMAGE:int = 8;
		public static const STATUS_DAMAGE_TYPE:int = 9;
		public static const STATUS_ATTACK_TYPE:int = 10;
		public static const STATUS_ARMOR:int = 11;
		
		// Item Types
		public static const ITEM_WEAPON:int = 0;
		public static const ITEM_ARMOR:int = 1;
		public static const ITEM_CONSUMABLE:int = 2;
		
		// Chest constants
		public static const CHEST_SPRITE_WIDTH:int = 20;
		public static const CHEST_SPRITE_HEIGHT:int = 28;
		
		// Grid Overlay constants
		public static const GRID_OVERLAY_SCALE_DIVIDER:int = 16;
		
		// House constants
		public static const HOUSE_HITBOX_SIZE:int = 48;
		
		// NPC constants
		public static const NPC_SPRITE_WIDTH:int = 25;
		public static const NPC_SPRITE_HEIGHT:int = 29;
		public static const NPC_HITBOX_WIDTH:int = 16;
		public static const NPC_HITBOX_HEIGHT:int = 23;
		public static const NPC_HITBOX_X_OFFSET:int = -4;
		public static const NPC_HITBOX_Y_OFFSET:int = -3;
		public static const NPC_ACTIVITY_NONE:int = 0;
		public static const NPC_ACTIVITY_WALK:int = 1;
		public static const NPC_MIN_DISTANCE:Number = 10;
		public static const NPC_SPAWN_END:int = 2;
		public static const NPC_PATHFINDING_MIN_DISTANCE:int = 10;
		public static const NPC_MOVEMENT_SPEED:int = 1;
		
		// Player constants
		public static const PLAYER_SPRITE_WIDTH:Number = 23;
		public static const PLAYER_SPRITE_HEIGHT:Number = 28;
		public static const PLAYER_HITBOX_WIDTH:int = 16;
		public static const PLAYER_HITBOX_HEIGHT:int = 23;
		public static const PLAYER_HITBOX_X_OFFSET:int = -4;
		public static const PLAYER_HITBOX_Y_OFFSET:int = -3;
		public static const PLAYER_MOVEMENT_SPEED:Number = 2;
		public static const PLAYER_DIAGONAL_MOVEMENT_SPEED:Number = 1.4;
		
		// Tiles constants
		public static const TILES_TILE_SIZE:int = 48;
		public static const TILES_RECT_SIZE:int = 16;
		
		// Trees constants
		public static const TREE_TILE_SIZE:int = 48;
		
		// Armor Types
		public static const ARMOR_TYPE_HEAD:int = 0;
		public static const ARMOR_TYPE_TORSO:int = 1;
		public static const ARMOR_TYPE_LEGS:int = 2;
		public static const ARMOR_TYPE_HANDS:int = 3;
		public static const ARMOR_TYPE_FEET:int = 4;
		
		// Attack Types
		public static const ATTACK_TYPE_NO_ATTACK:int = -1;
		public static const ATTACK_TYPE_MELEE:int = 0;
		public static const ATTACK_TYPE_RANGED:int = 1;
		
		// Damage Types
		public static const DAMAGE_TYPE_NO_DAMAGE:int = -1;
		public static const DAMAGE_TYPE_SLASHING:int = 0;
		public static const DAMAGE_TYPE_PIERCING:int = 1;
		public static const DAMAGE_TYPE_IMPACT:int = 2;
		public static const DAMAGE_TYPE_MAGIC:int = 3; 
		
		// Dialog constants
		public static const DIALOG_NPC_TURN:int = 0;
		public static const DIALOG_PLAYER_TURN:int = 1;
		
		// Inventory constants
		public static const INVENTORY_DEFAULT_FONT_SIZE:int = 12;
		public static const INVENTORY_ARMOR_EQUIP_HEAD_DISPLAY_TEXT:int = 3;
		public static const INVENTORY_ARMOR_EQUIP_TORSO_DISPLAY_TEXT:int = 4;
		public static const INVENTORY_ARMOR_EQUIP_LEGS_DISPLAY_TEXT:int = 5;
		public static const INVENTORY_ARMOR_EQUIP_HANDS_DISPLAY_TEXT:int = 6;
		public static const INVENTORY_ARMOR_EQUIP_FEET_DISPLAY_TEXT:int = 7;
		public static const INVENTORY_WEAPON_EQUIP_PRIMARY_DISPLAY_TEXT:int = 8;
		public static const INVENTORY_WEAPON_EQUIP_SECONDARY_DISPLAY_TEXT:int = 9;
		public static const INVENTORY_INFO_DISPLAY_TEXT_ONE:int = 10;
		public static const INVENTORY_INFO_DISPLAY_TEXT_TWO:int = 11;
		public static const INVENTORY_INFO_DISPLAY_TEXT_THREE:int = 12;
		public static const INVENTORY_INFO_DISPLAY_TEXT_FOUR:int = 13;
		public static const INVENTORY_INFO_DISPLAY_TEXT_FIVE:int = 14;
		public static const INVENTORY_INFO_DISPLAY_TEXT_SIX:int = 15;
		public static const INVENTORY_INFO_DISPLAY_TEXT_SEVEN:int = 16;
		public static const INVENTORY_INFO_DISPLAY_TEXT_EIGHT:int = 17;
		
		public static const INVENTORY_MAX_ITEM_ROWS:int = 6;
		public static const INVENTORY_MAX_ITEM_COLUMNS:int = 3;
		public static const INVENTORY_OFFSET_X:int = 10;
		public static const INVENTORY_OFFSET_Y:int = 10;
		public static const INVENTORY_SCALE_X:Number = 3;
		public static const INVENTORY_SCALE_Y:Number = 4.5;
		
		public static const INVENTORY_WEAPON_ITEM_COLUMN:int = 0;
		public static const INVENTORY_ARMOR_ITEM_COLUMN:int = 1;
		public static const INVENTORY_CONSUMABLE_ITEM_COLUMN:int = 2;
		public static const INVENTORY_ARMOR_EQUIP_COLUMN:int = 3;
		public static const INVENTORY_WEAPON_EQUIP_COLUMN:int = 4;
		
		public static const INVENTORY_NORMAL_MODE:int = 0;
		public static const INVENTORY_EQUIP_MODE:int = 1;
		
		public static const INVENTORY_KEY_ARMOR_EQUIP:String = "ArmorEquip";
		public static const INVENTORY_KEY_ARMOR_EQUIP_HEAD:String = "ArmorEquipHead";
		public static const INVENTORY_KEY_ARMOR_EQUIP_TORSO:String = "ArmorEquipTorso";
		public static const INVENTORY_KEY_ARMOR_EQUIP_LEGS:String = "ArmorEquipLegs";
		public static const INVENTORY_KEY_ARMOR_EQUIP_HANDS:String = "ArmorEquipHands";
		public static const INVENTORY_KEY_ARMOR_EQUIP_FEET:String = "ArmorEquipFeet";
		public static const INVENTORY_KEY_WEAPON_EQUIP:String = "WeaponEquip";
		public static const INVENTORY_KEY_WEAPON_EQUIP_PRIMARY:String = "WeaponEquipPrimary";
		public static const INVENTORY_KEY_WEAPON_EQUIP_SECONDARY:String = "WeaponEquipSecondary";
		public static const INVENTORY_KEY_WEAPON_ITEM:String = "WeaponItem";
		public static const INVENTORY_KEY_ARMOR_ITEM:String = "ArmorItem";
		public static const INVENTORY_KEY_CONSUMABLE_ITEM:String = "ConsumableItem";
		
		// Map constants
		public static const MAP_INDOOR:int = 0;
		public static const MAP_OUTDOOR:int = 1;
		
		public static const MAP_NONE:int = -1;
		public static const MAP_NORTH:int = 0;
		public static const MAP_EAST:int = 1;
		public static const MAP_SOUTH:int = 2;
		public static const MAP_WEST:int = 3;
		public static const MAP_TILE_SIZE:int = 48;
		
		// Map Pathfinder constants
		public static const MAP_PATHFINDER_TILE_SIZE:int = 48;
		
		// Player Dialog Box constants
		public static const PLAYER_DIALOG_BOX_DEFAULT_FONT_SIZE:int = 12;
		public static const PLAYER_DIALOG_BOX_SCALE_X_MULTIPLIER:int = 46;
		public static const PLAYER_DIALOG_BOX_SCALE_Y_MULTIPLIER:int = 3;
		
		// NPC Dialog Box constants
		public static const NPC_DIALOG_BOX_DEFAULT_FONT_SIZE:int = 12;
		public static const NPC_DIALOG_BOX_SCALE_X_MULTIPLIER:int = 46;
		public static const NPC_DIALOG_BOX_SCALE_Y_MULTIPLIER:int = 3;
		
		// Pathfinder constants
		public static const PATHFINDER_NORMAL_COST:int = 10;
		public static const PATHFINDER_DIAGONAL_COST:int = 14;
		public static const PATHFINDER_TILE_SIZE:int = 48;
		
		// Status Screen constants
		public static const STATUS_SCREEN_DEFAULT_FONT_SIZE:int = 12;
		
		// Daytime strings
		public static const NIGHT_STRING:String = "Night";
		public static const MORNING_STRING:String = "Morning";
		public static const AFTERNOON_STRING:String = "Afternoon";
		public static const EVENING_STRING:String = "Evening";
		
		public static const CAMERA_OFFSET:int = 200;
		
		/*
		 *  Collision Types 
		 */
		public static const TYPE_GRID_OVERLAY:String = "grid_overlay"
		public static const TYPE_CHEST:String = "chest";
		public static const TYPE_HOUSE:String = "house";
		public static const TYPE_NPC:String = "npc";
		public static const TYPE_PLAYER:String = "player";
		public static const TYPE_TILES:String = "solid";
		public static const TYPE_TREE:String = "tree";
		
		/*
		 * Strings used in GUI
		 */
		public static const NAME_STRING:String = "Name";
		public static const DAMAGE_TYPE_STRING:String = "Damage Type";
		public static const DAMAGE_STRING:String = "Damage";
		public static const QUANTITY_STRING:String = "Quantity";
		public static const ATTACK_TYPE_STRING:String = "Attack Type";
		public static const WEAPON_TWO_HANDED_STRING:String = "Two Handed";
		public static const WEAPON_ONE_HANDED_STRING:String = "One Handed";
		public static const BODY_PART_STRING:String = "Body Part";
		public static const ARMOR_STRING:String = "Armor";
		public static const RESISTANCE_STRING:String = "Resistance";
		public static const EFFECT_STRING:String = "Effect";
		
		// Damage Type names
		public static const DAMAGE_TYPE_NO_DAMAGE_STRING:String = "Unarmed";
		public static const DAMAGE_TYPE_SLASHING_STRING:String = "Slashing";
		public static const DAMAGE_TYPE_PIERCING_STRING:String = "Piercing";
		public static const DAMAGE_TYPE_IMPACT_STRING:String = "Impact";
		public static const DAMAGE_TYPE_MAGIC_STRING:String = "Magic";
		
		// Body Part names
		public static const BODY_PART_HEAD_STRING:String = "Head";
		public static const BODY_PART_TORSO_STRING:String = "Torso";
		public static const BODY_PART_LEGS_STRING:String = "Legs";
		public static const BODY_PART_HANDS_STRING:String = "Hands";
		public static const BODY_PART_FEET_STRING:String = "Feet";
		
		// Weapon names
		public static const PRIMARY_WEAPON_STRING:String = "Primary Weapon";
		public static const SECONDARY_WEAPON_STRING:String = "Secondary Weapon";
		
		// Attack Type names
		public static const ATTACK_TYPE_NO_ATTACK_STRING:String = "Unarmed";
		public static const ATTACK_TYPE_MELEE_STRING:String = "Melee";
		public static const ATTACK_TYPE_RANGED_STRING:String = "Ranged";
		
		// Status Variable names
		public static const EXPERIENCE_STRING:String = "Experience";
		public static const STRENGTH_STRING:String = "Strength";
		public static const AGILITY_STRING:String = "Agility";
		public static const SPIRITUALITY_STRING:String = "Spirituality";
		public static const HEALTH_STRING:String = "Health";
		public static const MANA_STRING:String = "Mana";
		
		/*[Embed(source = "../../assets/scripts/constants_data.xml", mimeType = "application/octet-stream")] 
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
		public static var inventoryItemColumns:int;*/
		
		
		public function GC() {}
		
		public static function loadData():void
		{
			/*var constantsDataByteArray:ByteArray = new constantsData;
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
			inventoryItemColumns = constantsDataXML.inventory_item_columns;*/
		}

	}

}
