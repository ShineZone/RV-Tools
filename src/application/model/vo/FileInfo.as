/**
 * User: Ray Yee
 * Date: 14-2-12
 * All rights reserved.
 */
package application.model.vo
{

    public class FileInfo
    {
        public var pathKey : String = "";
        public var versionCode : String = "";
        public var fileSize : int = 0;

        public function FileInfo()
        {
        }

        /**
         * 获取文件名
         * (文件名不带版本号)
         */
        public function get fileName() : String
        {
            return pathKey.slice( pathKey.lastIndexOf( "/" ) + 1 );
//            return pathKey.slice( pathKey.lastIndexOf( "/" ) + 1, pathKey.lastIndexOf( "." ) );
        }

        /**
         * 获取带版本号的全路径
         */
        public function get versionPath() : String
        {
            var fileN : String = fileName;
            if ( versionCode && versionCode != "" )
            {
                var index : int = fileN.indexOf( "." );
                var newName : String = fileN.substr( 0, index ) + "_" + versionCode + fileN.substr( index );
                return pathKey.replace( fileN, newName );
            }

            else return pathKey;
        }
    }
}
