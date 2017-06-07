xquery version "3.1";
declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare default element namespace "http://exist.sourceforge.net/NS/exist";
declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

if ($exist:path = '') then
    <dispatch>
        <redirect url="./index.html"/>
        <cache-control cache="yes"/>
    </dispatch>

if (ends-with($exist:path, '/')) then
    <dispatch>
        <redirect url="index.html"/>
        <cache-control cache="yes"/>
    </dispatch>

else if (doc-available($exist:root||'/content/'||$exist:path)) then
    <dispatch>
        <forward url="/content/{$exist:path}"/>
        <cache-control cache="yes"/>
    </dispatch>

else (
    response:set-status-code(404),
    <dispatch>
        <forward url="/404.html"/>
        <cache-control cache="yes"/>
    </dispatch>
)
