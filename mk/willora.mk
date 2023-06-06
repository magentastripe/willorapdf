#
# willora.mk
# Charlotte Koch <dressupgeekout@gmail.com>
#

WILLORABASE?=	${.CURDIR}

NAME?=		mybook
PDF_OUT?=	${NAME}.pdf
PDF_ADOC_TOTAL=	${PDF_OUT}.adoc
EPUB_OUT?=	${NAME}.epub
EPUB_ADOC_TOTAL=${EPUB_OUT}.adoc

BUNDLE?=	bundle
THEME?=		poppy
THEMEDIR?=	${WILLORABASE}/themes
FONTDIR?=	${WILLORABASE}/fonts
MEDIA?=		prepress
PUBLISHER?=	WilloraPDF

COLOPHON_OUT?=		colophon.pdf
DEDICATION_OUT?=	dedication.pdf
ACKNOWLEDGMENTS_OUT?=	acknowledgments.pdf

CUSTOM_PDF_CONVERTER=	${WILLORABASE}/lib/willora_pdf_converter.rb

########## ########## ##########

.PHONY: all
all: ${PDF_OUT} ${EPUB_OUT}

.PHONY: pdf
pdf: ${PDF_OUT}

.PHONY: epub
epub: ${EPUB_OUT}

########## ########## ##########

# XXX: Figure out why I can't do this:
# 'asciidoctor-pdf -a optimize'
# > GPL Ghostscript 9.50: Can't find initialization file gs_init.ps.
# https://docs.asciidoctor.org/pdf-converter/latest/optimize-pdf/

CLEANFILES+=	${PDF_OUT}
${PDF_OUT}: ${THEMEDIR}/${THEME}-theme.yml ${CUSTOM_PDF_CONVERTER} ${PDF_ADOC_TOTAL} Gemfile.lock ${COLOPHON_OUT} ${DEDICATION_OUT} ${ACKNOWLEDGMENTS_OUT}
	${BUNDLE} exec asciidoctor-pdf \
		-v \
		-r ${CUSTOM_PDF_CONVERTER} \
		-d book \
		-o ${.TARGET} \
		-a pdf-fontsdir=${FONTDIR} \
		-a pdf-theme=${THEME} \
		-a pdf-themesdir=${THEMEDIR} \
		-a media=${MEDIA} \
		-a text-align=justify \
		${PDF_ADOC_TOTAL}

CLEANFILES+=	${PDF_ADOC_TOTAL}
${PDF_ADOC_TOTAL}: ${CHAPTERS}
	rm -f ${.TARGET}
.for chapter in ${CHAPTERS}
	dos2unix < ${chapter} | sed -E \
		-e 's,[[:space:]]--[[:space:]],\&\#8212;,g' \
		-e 's,\&iuml;,\&\#239;,g' \
		-e 's,\&eacute;,\&\#233;,g' >> ${.TARGET}
	printf '\n\n' >> ${.TARGET}
.endfor

CLEANFILES+=	${COLOPHON_OUT}
${COLOPHON_OUT}: ${THEMEDIR}/${THEME}-colophon-theme.yml ${COLOPHON_FILE} ${CUSTOM_PDF_CONVERTER} Gemfile.lock
	${BUNDLE} exec asciidoctor-pdf \
		-v \
		-r ${CUSTOM_PDF_CONVERTER} \
		-d book \
		-o ${.TARGET} \
		-a pdf-fontsdir=${FONTDIR} \
		-a pdf-theme=${THEME}-colophon \
		-a pdf-themesdir=${THEMEDIR} \
		-a media=print \
		-a text-align=justify \
		${COLOPHON_FILE}

CLEANFILES+=	${DEDICATION_OUT}
${DEDICATION_OUT}: ${THEMEDIR}/${THEME}-dedication-theme.yml ${DEDICATION_FILE} ${CUSTOM_PDF_CONVERTER} Gemfile.lock
	${BUNDLE} exec asciidoctor-pdf \
		-v \
		-r ${CUSTOM_PDF_CONVERTER} \
		-d book \
		-o ${.TARGET} \
		-a pdf-fontsdir=${FONTDIR} \
		-a pdf-theme=${THEME}-dedication \
		-a pdf-themesdir=${THEMEDIR} \
		-a media=print \
		${DEDICATION_FILE}

CLEANFILES+=	${ACKNOWLEDGMENTS_OUT}
${ACKNOWLEDGMENTS_OUT}: ${THEMEDIR}/${THEME}-acknowledgments-theme.yml ${ACKNOWLEDGMENTS_FILE} ${CUSTOM_PDF_CONVERTER} Gemfile.lock
	${BUNDLE} exec asciidoctor-pdf \
		-v \
		-r ${CUSTOM_PDF_CONVERTER} \
		-d book \
		-o ${.TARGET} \
		-a pdf-fontsdir=${FONTDIR} \
		-a pdf-theme=${THEME}-acknowledgments \
		-a pdf-themesdir=${THEMEDIR} \
		-a media=print \
		${ACKNOWLEDGMENTS_FILE}

########## ########## ##########

# XXX: '-a ebook-validate' doesn't work because:
# > RUBYOPT=-d epubcheck
# Exception `LoadError' at /usr/pkg/lib/ruby/3.0.0/rubygems.rb:1339 - cannot
# 	load such file -- rubygems/defaults/ruby
# Exception `LoadError' at
# 	<internal:/usr/pkg/lib/ruby/3.0.0/rubygems/core_ext/kernel_require.rb>:85 -
# 	cannot load such file -- rubygems/defaults/operating_system
# Exception `LoadError' at
# 	<internal:/usr/pkg/lib/ruby/3.0.0/rubygems/core_ext/kernel_require.rb>:162 -
# 	cannot load such file -- rubygems/defaults/operating_system
# Failed to execute epubcheck

CLEANFILES+=	${EPUB_OUT}
${EPUB_OUT}: Gemfile.lock ${EPUB_ADOC_TOTAL}
	${BUNDLE} exec asciidoctor-epub3 \
		-v \
		-d book \
		-o ${.TARGET} \
		-a producer="${PUBLISHER}" \
		-a front-cover-image=${EPUB_COVER_FILE} \
		-a ebook-format=epub3 \
		-a media=${MEDIA} \
		-a text-align=justify \
		${EPUB_ADOC_TOTAL}

# XXX Needs to be different from the PDF one
CLEANFILES+=	${EPUB_ADOC_TOTAL}
${EPUB_ADOC_TOTAL}: ${CHAPTERS}
	rm -f ${.TARGET}
.for chapter in ${CHAPTERS}
	dos2unix < ${chapter} | sed -E \
		-e 's,[[:space:]]--[[:space:]],\&\#8212;,g' \
		-e 's,\&iuml;,\&\#239;,g' \
		-e 's,\&eacute;,\&\#233;,g' >> ${.TARGET}
	printf '\n\n' >> ${.TARGET}
.endfor

########## ########## ##########

Gemfile.lock:
	${BUNDLE} install

########## ########## ##########

.PHONY: clean
clean:
	rm -f ${CLEANFILES}
