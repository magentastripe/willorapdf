# WilloraPDF extension: explicit "unmatched" double-quote shortcuts.
#
# This is to work around a shortcoming in Asciidoctor when a double-quote is
# right up against a non-word character -- em-dashes, ellipses, etc. TL;DR
# it's better to let Asciidoctor handle ("`) and (`") automatically by
# default EXCEPT FOR the times we need to wrangle it ourselves.
s,\&_OPENDOUBLEQUOTE;,\"\`,g
s,\&_CLOSEDOUBLEQUOTE;,\`\",g
