# Remove Asciidoc comments now, for the sake of getting more accurate
# wordcounts.
s,//.*,,g

# Remove spaces on either end of an em-dash. 
s,[[:space:]]*--[[:space:]]*,\&\#8212;,g

# Remove spaces before an ellipsis, while ensuring one space after.
s,[[:space:]]*\.\.\.[[:space:]]*,\&\#8230;\ ,g

# Explicitly handle curly double quotes before curly single quotes.
s,"`,\&\#8220;,g
s,`",\&\#8221;,g
s,'`,\&\#8216;,g
s,`',\&\#8217;,g

# Diacritics.
s,\&ccedil;,\&\#231;,g
s,\&egrave;,\&\#232;,g
s,\&eacute;,\&\#233;,g
s,\&iuml;,\&\#239;,g

# Remove spaces before a close-quote, which might have accidentally been
# introduced while converting ellipses earlier.
s,[[:space:]]*\&\#8221;,\&\#8221;,g
