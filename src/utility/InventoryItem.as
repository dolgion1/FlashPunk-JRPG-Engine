package utility 
{
	/**
	 * ...
	 * @author dolgion1
	 */
	public class InventoryItem 
	{
		public var weapon:Weapon;
		public var armor:Armor;
		public var consumable:Consumable;
		public var quantity:int = 0;
		public var itemType:int;
		
		public function InventoryItem() {}
		
		public function setWeapon(_weapon:Weapon, _quantity:int):void
		{
			weapon = _weapon;
			quantity = _quantity;
			itemType = Item.WEAPON;
		}
		
		public function setArmor(_armor:Armor, _quantity:int):void
		{
			armor = _armor;
			quantity = _quantity;
			itemType = Item.ARMOR;
		}
		
		public function setConsumable(_consumable:Consumable, _quantity:int):void
		{
			consumable = _consumable;
			quantity = _quantity;
			itemType = Item.CONSUMABLE;
		}
	}

}