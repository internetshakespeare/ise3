xquery version "3.1";
import module namespace xmldb = "http://exist-db.org/xquery/xmldb";

(: The following external variables are set by the repo:deploy function :)
(: file path pointing to the exist installation directory :)
declare variable $home external;
(: path to the directory containing the unpacked .xar package :)
declare variable $dir external;
(: the target collection into which the app is deployed :)
declare variable $target external;

(: copy index configurations into place :)
xmldb:create-collection('/db/system/config', $target),
xmldb:store-files-from-pattern(
    '/db/system/config/'||$target,
    $dir||'/xconf',
    ('*.xconf', '**/*.xconf'),
    'application/xml',
    true()
)
