# Render a thematic break as 3 hash symbols.
s,<\?asciidoc-hr\?>,\&\#35; \&\#35; \&\#35;,

# Asciidoctor puts a zero-width space after ellipses for some reason -- get
# rid of it.
s,\&\#8203;,,g
