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
		
		// Spell Elements
		public static const ELEMENT_FIRE:int = 0;
		public static const ELEMENT_ICE:int = 1;
		public static const ELEMENT_LIGHTNING:int = 2;
		public static const ELEMENT_WIND:int = 3;
		public static const ELEMENT_EARTH:int = 4;
		
		
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
		
		// Spell Entity constants
		public static const FIRE_SPELL_SPRITE_WIDTH:int = 221;
		public static const FIRE_SPELL_SPRITE_HEIGHT:int = 160;
		public static const ICE_SPELL_SPRITE_WIDTH:int = 221;
		public static const ICE_SPELL_SPRITE_HEIGHT:int = 160;
		
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
		public static const TYPE_ENEMY:String = "enemy";
		
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
		
		/*
		 * Battle Screen Constants
		 */ 
			
		public static const BATTLE_PLAYER_X:int = 468;
		public static const BATTLE_PLAYER_Y:int = 195;
		
		public static const BATTLE_ENEMY_ONE_X:int = 100;
		public static const BATTLE_ENEMY_ONE_Y:int = 30;
		
		public static const BATTLE_ENEMY_TWO_X:int = 100;
		public static const BATTLE_ENEMY_TWO_Y:int = 300;
		
		public static const BATTLE_ENEMY_THREE_X:int = 0;
		public static const BATTLE_ENEMY_THREE_Y:int = 156;
		
		// Arrow constants
		public static const ARROW_SPRITE_WIDTH:int = 72;
		public static const ARROW_SPRITE_HEIGHT:int = 21;
		
		// Player Battle constants
		public static const PLAYER_BATTLE_SPRITE_WIDTH:Number = 127;
		public static const PLAYER_BATTLE_SPRITE_HEIGHT:Number = 91;
		
		// Player Battle constants
		public static const ZELDA_BATTLE_SPRITE_WIDTH:Number = 155;
		public static const ZELDA_BATTLE_SPRITE_HEIGHT:Number = 200;
		
		public static const VELDA_BATTLE_SPRITE_WIDTH:Number = 155;
		public static const VELDA_BATTLE_SPRITE_HEIGHT:Number = 200;
		
		public static const ENEMY_TYPE_ZELDA:int = 0;
		public static const ENEMY_TYPE_VELDA:int = 1;
		
		// Zelda Stats
		public static const ENEMY_HEALTH_ZELDA:int = 60;
		public static const ENEMY_MANA_ZELDA:int = 40;
		public static const ENEMY_STRENGTH_ZELDA:int = 8;
		public static const ENEMY_AGILITY_ZELDA:int = 10;
		public static const ENEMY_SPIRITUALITY_ZELDA:int = 12;
		public static const ENEMY_DAMAGE_RATING_ZELDA:int = 3;
		public static const ENEMY_ARMOR_RATING_ZELDA:int = 2;
		
		public static const ENEMY_HEALTH_VELDA:int = 70;
		public static const ENEMY_MANA_VELDA:int = 40;
		public static const ENEMY_STRENGTH_VELDA:int = 10;
		public static const ENEMY_AGILITY_VELDA:int = 9;
		public static const ENEMY_SPIRITUALITY_VELDA:int = 10;
		public static const ENEMY_DAMAGE_RATING_VELDA:int = 4;
		public static const ENEMY_ARMOR_RATING_VELDA:int = 1;
				
		public function GC() {}
		

	}

}
