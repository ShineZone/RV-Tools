/**
 * User: Ray Yee
 * Date: 14-2-12
 * All rights reserved.
 */
package application.model
{

    import application.model.vo.FileInfo;

    import flash.utils.Dictionary;

    public class VersionCodeModel
    {

//        public var folders : Dictionary = new Dictionary();

        public var files : Dictionary = new Dictionary();

        public function VersionCodeModel()
        {
        }

        public function clear() : void
        {
            files = new Dictionary();
        }

        public function addFileInfo( path : String, version : String = "" ) : FileInfo
        {
            var fileInfo : FileInfo = getFileInfo( path );
            if ( fileInfo == null )
            {
                fileInfo = new FileInfo();
                files[path] = fileInfo;
            }
            fileInfo.pathKey = path;
            if ( version != "" ) fileInfo.versionCode = version;
            return fileInfo;
        }

        public function getFileInfo( noVersionUrl : String ) : FileInfo
        {
            /*var index:int = noVersionUrl.lastIndexOf("/");
             if (index > 0)
             {
             var folderPath:String = noVersionUrl.substr(0, index);
             var folderStructureInfo:FolderStructureInfo = folders[folderPath];
             if (folderStructureInfo)
             {

             }
             }*/
            return files[noVersionUrl];
        }
    }
}
