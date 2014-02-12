package application.view
{
	import application.events.ModuleEvent;
	import application.model.SettingProxy;
	import application.view.events.CommonEvent;
	
	import framework.base.BaseMediator;
	
	public class SettingPanelMediator extends BaseMediator
	{
		[Inject]
		public var proxy:SettingProxy;
		public function SettingPanelMediator()
		{
			super();
		}
		
		override public function onRegister():void{
			(viewComponent as SettingPanel).update(proxy.settingInfo);
			addViewListener(CommonEvent.START_RUN, startRun);
			addContextListener(ModuleEvent.START_RUN_COMPLETE, startRunComplete);
			addContextListener(ModuleEvent.ADD_LOG, addLog);
		}
		
		private function addLog(evt:ModuleEvent):void
		{
			(viewComponent as SettingPanel).addLog(String(evt.data));
		}
		
		private function startRunComplete(evt:ModuleEvent):void
		{
			(viewComponent as SettingPanel).update(proxy.settingInfo);
		}
		
		private function startRun(evt:CommonEvent):void
		{
			dispatch(new ModuleEvent(ModuleEvent.START_RUN,evt.data));
		}
	}
}