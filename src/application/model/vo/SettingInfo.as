package application.model.vo
{
	import flash.net.FileFilter;

	public class SettingInfo
	{
		/**
		 * 项目目录 
		 */		
		public var projectPath:String;
		
		/**
		 * 发布目录 
		 */		
		public var releasePath:String;
		
		/**
		 * 版本号 
		 */		
		public var version:String;
		
		/**
		 * 文件过滤 [*.swf,*.png] 
		 */		
		public var fileFilter:Array;
		
		/**
		 * 要发布的项目目录 
		 */		
		public var folders:Array;
		
		public function SettingInfo()
		{
		}
	}
}