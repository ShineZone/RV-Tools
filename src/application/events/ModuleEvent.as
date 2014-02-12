package application.events
{
	import framework.base.BaseEvent;
	
	public class ModuleEvent extends BaseEvent
	{
		
		public static const START_RUN:String 			= "START_RUN";
		public static const START_RUN_COMPLETE:String 	= "START_RUN_COMPLETE";
		public static const ADD_LOG:String 				= "ADD_LOG";
		
		public function ModuleEvent(type:String, data:Object=null, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, data, bubbles, cancelable);
		}
	}
}