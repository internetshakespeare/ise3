<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
    
    <pattern>
        <rule context="text()[contains(., '\n')]">
            <report test="matches(., '\n\s*\t')">
                Indentation must not use hard tabs; use spaces instead.
            </report>
            
            <let name="nestingLevel" value="count(ancestor::*)"/>
            <let name="isLastChild" value="parent::*/*[last()] is ."/>
            <let name="lineStarts" value="
                tokenize(., '\n')[position() gt 1][
                    position() eq last() or
                    matches(., '\S')
                ]
            "/>
            <assert test="(
               (every $indent in
                   $lineStarts[
                       not($isLastChild) or
                       (position() ne last())
                   ]
                   satisfies (
                        string-length(replace($indent, '\S.*$', ''))
                        eq
                        ($nestingLevel * 4)
                   )
                )
                and
                (every $indent in $lineStarts[last()][$isLastChild] satisfies (
                    string-length(replace($indent, '\S.*$', ''))
                    eq
                    (($nestingLevel - 1) * 4)
                ))
            )">
                Lines should be indented by 4 spaces for every level of nesting.
            </assert>
        </rule>
    </pattern>
    
</schema>
