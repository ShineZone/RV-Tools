package application.controller
{

    import application.events.ModuleEvent;
    import application.model.SettingProxy;
    import application.model.vo.SettingInfo;

    import com.adobe.utils.StringUtil;

    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.ByteArray;

    import framework.base.BaseCommand;

    import utils.CRC32;
    import utils.Utils;

    /**
     * 导出版本
     * @author chenyh
     *
     */
    public class ExportCommand extends BaseCommand
    {
        [Inject]
        public var event : ModuleEvent;
        [Inject]
        public var proxy : SettingProxy;

        public var conf : File;
        public var main : File;
        private var configXml : XML;

        override public function execute() : void
        {
            var si : SettingInfo = event.data as SettingInfo;
            proxy.settingInfo = si;

            //复制所有需要的文件至发布目录
            var projectFile : File = new File( si.projectPath );
            var file : File;
            for ( var i : int = 0, len : int = si.folders.length; i < len; i++ )
            {
                file = new File( si.projectPath + File.separator + si.folders[i] );
                if ( file.exists )
                {
                    copyFolder( file, proxy.projectFile, proxy.releasePath, si.fileFilter );
                }
            }
            print( "=============== 复制所有文件结束... =======================" );
            //查找config.xml文件
            if ( conf && conf.exists )
            {
                var index : int;
                var newName : String;
                var crc : String;
                configXml = readXml( conf );
                //查找并以crc码结尾重命名文件
                for each ( var xml : XML in configXml..item )
                {
                    var oldName : String = xml.text()[0];
                    var fileSize : int;
                    var tempfile : File = new File( proxy.releasePath + xml.parent().@folder + oldName );
                    if ( tempfile && tempfile.exists )
                    {
                        fileSize = tempfile.size;
                        crc = getFileCrc( tempfile );
                        index = tempfile.name.indexOf( "." );
                        newName = tempfile.name.substr( 0, index ) + "_" + crc + tempfile.name.substr( index );
                        tempfile.moveTo( new File( tempfile.parent.nativePath + File.separator + newName ), true );
                        index = oldName.indexOf( "." );
                        var nodeValue : String = oldName.substr( 0, index ) + "_" + crc + oldName.substr( index );
                        xml.text()[0] = nodeValue;
                        xml.@size = fileSize;
                        print( "重命名 " + oldName + " 为 " + nodeValue + " 成功" );
                    }
                }
                writeXml( conf, configXml );
                print( "重写config.xml成功" );
                if ( conf )
                {
                    modifyNameBeforeDot( conf, "_" + si.version );
                }
                if ( main )
                {
                    var mainFile : File = modifyNameBeforeDot( main, "_" + si.version );
                }
//				encryptMain(mainFile);
//				print("加密wrapper.swf成功");
                print( "==============发布版本结束================" );
//				Alert.show("版本发布成功","版本发布",Alert.OK);
            }
            else
            {
                print( "==============没有找到config.xml文件================" );
            }
            proxy.saveSetting();
            dispatch( new ModuleEvent( ModuleEvent.START_RUN_COMPLETE ) );
        }

        /**
         * 加密
         * @param file
         *
         */
        private function encryptMain( file : File ) : void
        {
            var byteArray : ByteArray = new ByteArray();
            var readStream : FileStream = new FileStream();
            readStream.open( file, FileMode.READ );
            readStream.readBytes( byteArray );
            readStream.close();
            byteArray.position = 0;

            var writeStream : FileStream = new FileStream();
            writeStream.open( file, FileMode.WRITE );
            writeStream.writeBytes( Utils.encrypt( byteArray, 225, 115 ) );
            writeStream.close();
        }

        private function modifyNameBeforeDot( file : File, str : String ) : File
        {
            var index : int;
            var newName : String;
            index = file.name.indexOf( "." );
            newName = file.name.substr( 0, index ) + str + file.name.substr( index );
            var newFile : File = new File( file.parent.nativePath + File.separator + newName );
            file.moveTo( newFile, true );
            return newFile;
        }

        /**
         * 获取CRC码
         * @param file
         * @return
         *
         */
        private function getFileCrc( file : File ) : String
        {
            var readStream : FileStream = new FileStream();
            readStream.open( file, FileMode.READ );
            var byteArray : ByteArray = new ByteArray;
            readStream.readBytes( byteArray );
            byteArray.position = 0;
            var crc32 : CRC32 = new CRC32();
            crc32.update( byteArray, [] );
            readStream.close();
            return crc32.getValue().toString( 32 );
        }

        /**
         * 读取config文件
         * @param file
         * @return
         *
         */
        private function readXml( file : File ) : XML
        {
            var xml : XML;
            var fileStream : FileStream = new FileStream();
            fileStream.open( file, FileMode.READ );
            xml = XML( fileStream.readUTFBytes( fileStream.bytesAvailable ) );
            fileStream.close();
            return xml;
        }

        /**
         * 写入xml
         * @param file
         * @param xml
         *
         */
        private function writeXml( file : File, xml : XML ) : void
        {
            var fileStream : FileStream = new FileStream();
            fileStream.open( file, FileMode.WRITE );
            var outputString : String = '<?xml\rversion="1.0"\rencoding="utf-8"?>\n';
            outputString += xml.toXMLString();
            fileStream.writeUTFBytes( outputString );
            fileStream.close();
        }

        /**
         * 复制文件
         * @param file
         * @param curRoot
         * @param targetRoot
         * @param filters
         *
         */
        private function copyFolder( file : File, curRoot : String, targetRoot : String, filters : Array ) : void
        {
            if ( file.isDirectory )
            {
                var temp : Array = file.getDirectoryListing();
                //判断是否包含.xfl文件的文件夹，如果是则不复制
                if ( !Utils.checkContainFile( file, [".xfl"] ) )
                {
                    for ( var i : int = 0, len : int = temp.length; i < len; i++ )
                    {
                        var tempFile : File = temp[i];
                        copyFolder( tempFile, curRoot, targetRoot, filters );
                    }
                }
            }
            else
            {
                //文件类型过滤
                var isCopy : Boolean = true;
                if ( filters != null && filters.length != 0 )
                {
                    var index : int = file.name.lastIndexOf( "." );
                    var suffix : String = file.name.substr( index );
                    if ( filters.indexOf( suffix ) < 0 )
                    {
                        isCopy = false;
                    }
                }
                if ( isCopy )
                {
                    //如果遇到bin-debug或者bin-release,则不复制文件夹，直接复制文件
                    var newFile : File = new File( filterIngoreFolder( targetRoot + file.nativePath.substr( curRoot.length ) ) );
                    if ( file.name.toLowerCase() == "config.xml" )
                    {
                        conf = newFile;
                    }
                    else if ( file.name.toLowerCase() == "wrapper.swf" || file.name.toLowerCase() == "main.swf" )
                    {
                        main = newFile;
                    }
                    file.copyTo( newFile, true );
                    print( "复制 " + file.name + " 成功" );
                }
            }
        }

        private var ingoreList : Array = ["bin-debug", "bin-release"];

        private function filterIngoreFolder( url : String ) : String
        {
            for ( var i : int = 0, len : int = ingoreList.length; i < len; i++ )
            {
                url = StringUtil.remove( url, ingoreList[i] + File.separator );
            }
            return url;
        }

        private function print( info : String ) : void
        {
            this.dispatch( new ModuleEvent( ModuleEvent.ADD_LOG, info ) );
        }
    }
}