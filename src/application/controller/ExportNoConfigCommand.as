/**
 * User: Ray Yee
 * Date: 14-2-12
 * All rights reserved.
 */
package application.controller
{

    import application.events.ModuleEvent;
    import application.model.SettingProxy;
    import application.model.VersionCodeModel;
    import application.model.vo.FileInfo;
    import application.model.vo.SettingInfo;

    import com.adobe.utils.StringUtil;

    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.ByteArray;

    import framework.base.BaseCommand;

    import utils.CRC32;
    import utils.Utils;

    public class ExportNoConfigCommand extends BaseCommand
    {
        [Inject]
        public var versionCodeModel:VersionCodeModel;
        [Inject]
        public var event:ModuleEvent;
        [Inject]
        public var proxy:SettingProxy;

        //指向项目文件夹下的
        public var conf:File;

        public var main:File;
        private var configXml:XML;

        public function ExportNoConfigCommand()
        {
            super();
        }

        override public function execute():void
        {
            super.execute();
            var si:SettingInfo = event.data as SettingInfo;
            proxy.settingInfo = si;

            //复制所有需要的文件至发布目录
            var projectFile:File = new File( si.projectPath );
            var file:File;
            for ( var i:int = 0, len:int = si.folders.length; i < len; i++ )
            {
                file = new File( si.projectPath + File.separator + si.folders[i] );
                if ( file.exists )
                {
                    copyFolder( file, proxy.projectFile, proxy.releasePath, si.fileFilter );
                }
            }
            print( "=============== 复制所有文件结束... =======================" );
            var index:int;
            var newName:String;
            var oldName:String;
            var crc:String;
            //查找config.xml文件
            if ( conf && conf.exists )
            {
                readConfigDataToModel( conf );

                /*
                 configXml = readXml( conf );
                 //查找并以crc码结尾重命名文件
                 for each ( var xml : XML in configXml..item )
                 {
                 var oldName : String = xml.text()[0];
                 var fileSize : int;
                 var tempFile : File = new File( proxy.releasePath + xml.parent().@folder + oldName );
                 if ( tempFile && tempFile.exists )
                 {
                 fileSize = tempFile.size;
                 crc = getFileCrc( tempFile );
                 index = tempFile.name.indexOf( "." );
                 newName = tempFile.name.substr( 0, index ) + "_" + crc + tempFile.name.substr( index );
                 tempFile.moveTo( new File( tempFile.parent.nativePath + File.separator + newName ), true );
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
                 //				Alert.show("版本发布成功","版本发布",Alert.OK);*/

            }
            else
            {
                conf = new File( proxy.projectFile ).resolvePath( "release/version.dat" );
//                print( "==============没有找到config.xml文件================" );
            }
            var fileName:String;
            var newFilePath:String;
            var newFile:File;
            var nativeFile:File;
            for each ( var fileInfo:FileInfo in versionCodeModel.files )
            {
                /*file = new File( proxy.releasePath + fileInfo.versionPath );
                 if ( !file.exists ) file = new File( proxy.releasePath + fileInfo.pathKey );*/

                nativeFile = new File( proxy.releasePath + fileInfo.pathKey );

                if ( nativeFile.exists )
                {
                    oldName = nativeFile.nativePath;
                    crc = getFileCrc( nativeFile );
                    fileInfo.fileSize = nativeFile.size;
                    fileInfo.versionCode = crc;
                    //                versionCodeModel.addFileInfo( fileInfo.pathKey, crc );
                    fileName = fileInfo.fileName;
                    index = fileName.indexOf( "." );
                    newName = fileName.substr( 0, index ) + "_" + crc + fileName.substr( index );
                    newFilePath = nativeFile.parent.nativePath + File.separator + newName;
//                    trace( "old: ", file.nativePath );
//                    trace( "new: ", newFilePath );
                    if ( fileInfo.fileName == "GameConfig.xml" )
                    {
                        trace( nativeFile.name, fileInfo.versionCode, crc );
                    }
                    newFile = new File( newFilePath );
                    if ( newFile.name != nativeFile.name )
                    {
                        nativeFile.moveToAsync( newFile, true );
                        print( newName );
                        print( newFilePath );
                        print( "重命名 " + oldName + " \n为 " + fileInfo.versionPath + " 成功" );
                    }
                    else
                    {
                        nativeFile.deleteFile();
                    }
                }

            }
            trace(conf.nativePath);
            writeConfigData( conf );
            newFile = new File( filterIngoreFolder( proxy.releasePath + conf.nativePath.substr( proxy.projectFile.length ) ) );
            conf.copyTo( newFile, true );


            proxy.saveSetting();
            dispatch( new ModuleEvent( ModuleEvent.START_RUN_COMPLETE ) );
        }

        /**
         * 加密
         * @param file
         *
         */
        private function encryptMain( file:File ):void
        {
            var byteArray:ByteArray = new ByteArray();
            var readStream:FileStream = new FileStream();
            readStream.open( file, FileMode.READ );
            readStream.readBytes( byteArray );
            readStream.close();
            byteArray.position = 0;

            var writeStream:FileStream = new FileStream();
            writeStream.open( file, FileMode.WRITE );
            writeStream.writeBytes( Utils.encrypt( byteArray, 225, 115 ) );
            writeStream.close();
        }

        private function modifyNameBeforeDot( file:File, str:String ):File
        {
            var index:int;
            var newName:String;
            index = file.name.indexOf( "." );
            newName = file.name.substr( 0, index ) + str + file.name.substr( index );
            var newFile:File = new File( file.parent.nativePath + File.separator + newName );
            file.moveTo( newFile, true );
            return newFile;
        }

        /**
         * 获取CRC码
         * @param file
         * @return
         *
         */
        private function getFileCrc( file:File ):String
        {
            var readStream:FileStream = new FileStream();
            readStream.open( file, FileMode.READ );
            var byteArray:ByteArray = new ByteArray;
            readStream.readBytes( byteArray );
            byteArray.position = 0;
            var crc32:CRC32 = new CRC32();
            crc32.update( byteArray, [] );
            readStream.close();
            return crc32.getValue().toString( 32 );
        }

        private function readConfigDataToModel( file:File ):void
        {
            var fs:FileStream = new FileStream();
            fs.open( file, FileMode.READ );
            var fileCount:int = fs.readShort();
            var ba:ByteArray = new ByteArray();
            fs.readBytes( ba );
            ba.uncompress();
            var versionCodeCount:int;
            var keyCount:int;
            while ( 0 < fileCount-- )
            {
                keyCount = ba.readShort();
                versionCodeCount = ba.readShort();
                versionCodeModel.addFileInfo( ba.readUTFBytes( keyCount ), ba.readUTFBytes( versionCodeCount ) ).fileSize = ba.readInt();
            }
            fs.close();
        }

        private function writeConfigData( file:File ):void
        {
            var fs:FileStream = new FileStream();
            fs.open( file, FileMode.WRITE );
            var ba:ByteArray = new ByteArray();
            var fileCount:int = 0;
            var tempBytes:ByteArray = new ByteArray();
            for each ( var fileInfo:FileInfo in versionCodeModel.files )
            {
                fileCount++;
                tempBytes.length = 0;
                tempBytes.writeUTFBytes( fileInfo.pathKey );
                ba.writeShort( tempBytes.length );
                tempBytes.length = 0;
                tempBytes.writeUTFBytes( fileInfo.versionCode );
                ba.writeShort( tempBytes.length );
                ba.writeUTFBytes( fileInfo.pathKey );
                ba.writeUTFBytes( fileInfo.versionCode );
                ba.writeInt( fileInfo.fileSize );
            }
            ba.compress();
            fs.writeShort( fileCount );
            fs.writeBytes( ba );
            fs.close();
        }

        /**
         * 复制文件
         * @param file
         * @param curRoot
         * @param targetRoot
         * @param filters
         *
         */
        private function copyFolder( file:File, curRoot:String, targetRoot:String, filters:Array ):void
        {
            if ( file.isDirectory )
            {
                var temp:Array = file.getDirectoryListing();
                //判断是否包含.xfl文件的文件夹，如果是则不复制
                if ( !Utils.checkContainFile( file, [".xfl"] ) )
                {
                    for ( var i:int = 0, len:int = temp.length; i < len; i++ )
                    {
                        var tempFile:File = temp[i];
                        copyFolder( tempFile, curRoot, targetRoot, filters );
                    }
                }
            }
            else
            {
                //文件类型过滤
                var isCopy:Boolean = true;
                if ( filters != null && filters.length != 0 )
                {
                    var index:int = file.name.lastIndexOf( "." );
                    var suffix:String = file.name.substr( index );
                    if ( filters.indexOf( suffix ) < 0 )
                    {
                        isCopy = false;
                    }
                }
                if ( isCopy )
                {
                    //如果遇到bin-debug或者bin-release,则不复制文件夹，直接复制文件
                    var newFile:File = new File( filterIngoreFolder( targetRoot + file.nativePath.substr( curRoot.length ) ) );
                    if ( file.name.toLowerCase() == "config.xml" )
                    {
                        conf = newFile;
                    }
                    else if ( file.name.toLowerCase() == "version.dat" )
                    {
                        conf = file;
                        file.copyTo( newFile, true );
                    }
                    else if ( file.name.toLowerCase() == "wrapper.swf" || file.name.toLowerCase() == "main.swf" )
                    {
                        main = newFile;
                    }
                    else
                    {
                        versionCodeModel.addFileInfo( newFile.nativePath.replace( proxy.releasePath, "" ) );
                        file.copyTo( newFile, true );
                        print( "复制 " + file.name + " 成功" );
                    }
                }
            }
        }

        private var ignoreList:Array = ["bin-debug", "bin-release"];

        private function filterIngoreFolder( url:String ):String
        {
            for ( var i:int = 0, len:int = ignoreList.length; i < len; i++ )
            {
                url = StringUtil.remove( url, ignoreList[i] + File.separator );
            }
            return url;
        }

        private function print( info:String ):void
        {
            this.dispatch( new ModuleEvent( ModuleEvent.ADD_LOG, info ) );
        }
    }
}
