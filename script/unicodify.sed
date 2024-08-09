# Remove spaces on either end of an em-dash.
s,[[:space:]]--[[:space:]],\&\#8212;,g

# Explicitly handle double-quotes before single-quotes.
s,"`,\&\#8220;,g
s,`",\&\#8221;,g
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
