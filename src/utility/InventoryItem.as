package utility 
{
	/**
	 * ...
	 * @author dolgion1
	 */
	public class InventoryItem 
	{
		public var item:Array = new Array();
		public var quantity:int = 0;
		public var type:int;
		
		public function InventoryItem() {}
		
		public function setWeapon(_weapon:Weapon, _quantity:int):void
		{
			quantity = _quantity;
			type = GC.ITEM_WEAPON;
			item[type] = _weapon;
		}
		
		public function setArmor(_armor:Armor, _quantity:int):void
		{
			quantity = _quantity;
			type = GC.ITEM_ARMOR;
			item[type] = _armor;
		}
		
		public function setConsumable(_consumable:Consumable, _quantity:int):void
		{
			quantity = _quantity;
			type = GC.ITEM_CONSUMABLE;
			item[type] = _consumable;
		}
	}

}