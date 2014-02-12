package application.view.events
{
	import framework.base.BaseEvent;
	
	public class CommonEvent extends BaseEvent
	{
		
		public static const START_RUN:String = "START_RUN";
		
		public function CommonEvent(type:String, data:Object=null, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, data, bubbles, cancelable);
		}
	}
}