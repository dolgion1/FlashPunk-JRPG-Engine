package utility 
{
	/**
	 * ...
	 * @author dolgion
	 */
	public class DefenseSpell extends Spell
	{
		public var statusVariable:int;
		public var alteration:int;
		
		public function DefenseSpell() {}
		
		public function copy(_defenseSpell:DefenseSpell):void
		{
			name = _defenseSpell.name;
			temporary = _defenseSpell.temporary;
			duration = _defenseSpell.duration;
			statusVariable = _defenseSpell.statusVariable;
			alteration = _defenseSpell.alteration;
			manaCost = _defenseSpell.manaCost; 
		}
		
	}

}
