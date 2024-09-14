# Remove spaces on either end of an em-dash.
s,[[:space:]]--[[:space:]],\&\#8212;,g

# WilloraPDF extension: explicit "unmatched" double-quote shortcuts.
#
# This is to work around a shortcoming in Asciidoctor when a double-quote is
# right up against a non-word character -- em-dashes, ellipses, etc. TL;DR
# it's better to let Asciidoctor handle ("`) and (`") automatically by
# default EXCEPT FOR the times we need to wrangle it ourselves.
s,\&_OPENDOUBLEQUOTE;,\&\#8220;,g
s,\&_CLOSEDOUBLEQUOTE;,\&\#8221;,g

# Curly single quotes.
s,'`,\&\#8216;,g
s,`',\&\#8217;,g

# Diacritics.
s,\&ccedil;,\&\#231;,g
s,\&egrave;,\&\#232;,g
s,\&eacute;,\&\#233;,g
s,\&iuml;,\&\#239;,g

# Remove Asciidoc comments now, for the sake of getting more accurate
# wordcounts.
s,//.*,,g
