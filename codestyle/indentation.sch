<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
    
    <pattern>
        <rule context="*[text()[contains(., '\n')]]">
            <report test="some $txt in text() satisfies matches(., '\n\s*\t')">
                Indentation must not use hard tabs; use spaces instead.
            </report>

            <let name="lastChild" value="node()[last()]"/>

            <let name="nestingLevel" value="count(ancestor::*) + 1"/>
            <let name="indentSpaces" value="4"/>
            <let name="internalIndents" value="
                for $txt in text()[contains(., '\n')],
                    $line in tokenize($txt, '\n')
                        [position() gt 1]
                        [
                            not($txt is $lastChild)
                            or
                            position() ne last()
                        ]
                return
                    replace($line, '\S.*$', '')
            "/>
            <assert test="
                every $indent in ($internalIndents)
                satisfies string-length($indent) eq ($nestingLevel * $indentSpaces)
            ">
                Lines should be indented by 4 spaces for every level of nesting.
            </assert>

            <let name="finalIndentLength" value="
                ($indentSpaces * ($nestingLevel - 1))
            "/>
            <let name="finalIndent" value="
                string-join(
                    for $s in (1 to $finalIndentLength)
                    return ' '
                    ,
                    ''
                )
            "/>
            <assert test="
                not($lastChild instance of text())
                or
                ends-with(
                    $lastChild,
                    concat('\n', $finalIndent)
                )
            ">
                Expecting closing tag to be indented
                <value-of select="$finalIndentLength"/>
                spaces.
            </assert>
        </rule>
    </pattern>
    
</schema>
