package application.model
{
	import application.model.vo.SettingInfo;
	
	import com.adobe.serialization.json.JSON;
	
	import flash.filesystem.File;
	import flash.net.SharedObject;
	
	import framework.base.BaseProxy;
	
	public final class SettingProxy extends BaseProxy
	{
		private var _settingInfo:SettingInfo;
		private var shareObject:SharedObject;
		public function SettingProxy()
		{
			super();
			shareObject = SharedObject.getLocal("LukeVersionTool");
		}
		
		public function get settingInfo():SettingInfo {
			
			if(_settingInfo == null){
				if(shareObject.data["settingInfo"]){
					var o:Object = com.adobe.serialization.json.JSON.decode(shareObject.data["settingInfo"]);
					_settingInfo = new SettingInfo();
					for(var i:String in o)
					{
						_settingInfo[i] = o[i];
					}
				}
			}			
			return _settingInfo; 
		}
		
		public function set settingInfo(value:SettingInfo):void
		{
			if (_settingInfo == value)
				return;
			_settingInfo = value;
		}

		public function get releasePath():String
		{
			return _settingInfo.releasePath + File.separator + _settingInfo.version + File.separator;
		}
		
		public function get projectFile():String
		{
			return _settingInfo.projectPath + File.separator;
		}
		
		public function saveSetting():void{
			_settingInfo.version 				= String(_settingInfo.version).charAt(0) + (int(String(_settingInfo.version).slice(1)) + 1);
			shareObject.data["settingInfo"]		= com.adobe.serialization.json.JSON.encode(_settingInfo);	
			shareObject.flush();
		}
	}
}