package application
{
	import application.controller.ExportCommand;
    import application.controller.ExportNoConfigCommand;
    import application.events.ModuleEvent;
	import application.model.SettingProxy;
    import application.model.VersionCodeModel;
    import application.view.SettingPanel;
	import application.view.SettingPanelMediator;
	
	import flash.display.DisplayObjectContainer;
	
	import framework.base.BaseContext;
	/**
	 *  
	 * @author chenyh
	 * 
	 */	
	public class ApplicationContext extends BaseContext
	{
		public function ApplicationContext(contextView:DisplayObjectContainer=null, autoStartup:Boolean=true, scaleMode:String="noScale")
		{
			super(contextView, autoStartup, scaleMode);
		}
		
		override public function startup():void{
			//model
			injector.mapSingleton(SettingProxy);
            injector.mapSingleton(VersionCodeModel);
			//view
			mediatorMap.mapView(SettingPanel,SettingPanelMediator,SettingPanel);	
			mediatorMap.createMediator((contextView as Main).settingPanel);
			//controller
//			commandMap.mapEvent(ModuleEvent.START_RUN,ExportCommand);
			commandMap.mapEvent(ModuleEvent.START_RUN,ExportNoConfigCommand);
		}
	}
}