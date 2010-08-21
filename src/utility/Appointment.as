package utility 
{
	/**
	 * ...
	 * @author dolgion
	 */
	public class Appointment
	{
		public var hour:int;
		public var minute:int;
		public var position:GlobalPosition;
		
		public function Appointment(_hour:int, _minute:int, _position:GlobalPosition) 
		{
			hour = _hour;
			minute = _minute;
			position = _position;
		}
	}

}