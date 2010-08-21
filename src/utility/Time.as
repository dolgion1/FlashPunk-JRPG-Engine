package utility 
{
	import net.flashpunk.FP;
	
	/**
	 * ...
	 * @author dolgion
	 */
	public class Time
	{
		public var timer:int = 0;
		public var seconds:int = 0;
		public var dayMinutes:int = 360;
		public var hours:int;
		public var minutes:int;
		
		public function Time() {}
		
		public function newMinute():Array
		{
			timer++;
			if (timer % (FP.assignedFrameRate / 5) == 0)
			{
				dayMinutes++;
				if (dayMinutes > 1440) dayMinutes = 0;
				hours = dayMinutes / 60;
				minutes = dayMinutes % 60;
				return new Array(hours, minutes);
			}
			else return null;
		}
		
		public function get daytimeString():String
		{
			if (hours >= 0 && hours < 6) return "Night";
			else if (hours >= 6 && hours < 12) return "Morning";
			else if (hours >= 12 && hours < 18) return "Afternoon";
			else if (hours >= 18 && hours < 24) return "Evening";
			else return "";
		}
		
		public function get timeString():String
		{
			var hourString:String = hours.toString();
			var minuteString:String = minutes.toString();

			if (hourString.length == 1) hourString = "0" + hourString;
			if (minuteString.length == 1) minuteString = "0" + minuteString;
			
			return hourString + ":" + minuteString;
		}
	}

}