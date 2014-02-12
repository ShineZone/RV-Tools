package utils
{
	import flash.filesystem.File;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;

	public class Utils
	{
		public function Utils()
		{
		}
		
		/**
		 * 获取文件类型 
		 * @param file
		 * @return 
		 * 
		 */		
		public static function getFileType(file:File):String{
			var index:int = file.name.lastIndexOf(".");
			return file.name.substr(index);
		}
		
		/**
		 * 判断是否包含某些类型文件 
		 * @param folder
		 * @param fileFilters
		 * @return 
		 * 
		 */		
		public static function checkContainFile(folder:File,fileFilters:Array):Boolean{
			var b:Boolean 	= false;
			var temp:Array 	= folder.getDirectoryListing();
			for (var i:int = 0, len:int = temp.length; i < len; i++)
			{
				if(fileFilters.indexOf(getFileType(temp[i])) >= 0){
					b = true;
					break;
				}
			}
			return b;
		}
		
		/**
		 * 二进制混淆 
		 * @param byteArray
		 * @param key
		 * @param bit
		 * @return 
		 * 
		 */		
		public static function encrypt(byteArray:ByteArray, key:uint = 253, bit:uint = 100) : ByteArray
		{
			var itemValue:int;
			var itemNewValue:int;
			var newByteArray:ByteArray = byteArray;//new ByteArray();
			var i:uint =0;
			var len:uint = byteArray.length;
			byteArray.position = 0;
			for(i = 0;i<bit;i++)
			{
				itemValue = byteArray[i];
				key = key* 214013 + 2531011;
				itemNewValue = itemValue ^ key & 255;
				newByteArray.writeByte(itemNewValue);
			}
			newByteArray.position = 0;
			return newByteArray;
		}
	}
}