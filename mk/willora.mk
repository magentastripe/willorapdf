#
# willora.mk
# Charlotte Koch <charlotte@magentastripe.com>
#

WILLORABASE?=	${.CURDIR}

NAME?=			mybook
PAPERBACK_OUT?=		${NAME}-paperback.pdf
HARDCOVER_OUT?=		${NAME}-hardcover.pdf
EPUB_OUT?=		${NAME}.epub
PAPERBACK_ADOC_TOTAL=	${PAPERBACK_OUT}.adoc
HARDCOVER_ADOC_TOTAL=	${HARDCOVER_OUT}.adoc
EPUB_ADOC_TOTAL=	${EPUB_OUT}.adoc

BUNDLE?=	bundle
RUBY?=		ruby
THEME?=		poppy
THEMEDIR?=	${WILLORABASE}/themes
FONTDIR?=	${WILLORABASE}/fonts
MEDIA?=		prepress
PUBLISHER?=	WilloraPDF

PAPERBACK_FRONTMATTER=		adoc/frontmatter-paperback.adoc
HARDCOVER_FRONTMATTER=		adoc/frontmatter-hardcover.adoc
EPUB_FRONTMATTER=		adoc/frontmatter-epub.adoc
PAPERBACK_COLOPHON_OUT?=	colophon-paperback.pdf
HARDCOVER_COLOPHON_OUT?=	colophon-hardcover.pdf
EPUB_COLOPHON_OUT?=		colophon-epub.pdf

DEDICATION_OUT?=	dedication.pdf
ACKNOWLEDGMENTS_OUT?=	acknowledgments.pdf

CUSTOM_PDF_CONVERTER=	${WILLORABASE}/lib/${THEME}_pdf_converter.rb
ERBBER_SCRIPT=		script/erbber.rb
UNICODE_TABLE=		script/unicodify.sed

########## ########## ##########

.PHONY: all
all: ${PAPERBACK_OUT} ${HARDCOVER_OUT} ${EPUB_OUT}

# Legacy synonym
.PHONY: pdf
pdf: paperback

.PHONY: paperback
paperback: ${PAPERBACK_OUT}

.PHONY: hardcover
hardcover: ${HARDCOVER_OUT}

.PHONY: epub
epub: ${EPUB_OUT}

########## ########## ##########

# ===== PAPERBACK =====

CLEANFILES+=	${PAPERBACK_OUT}
${PAPERBACK_OUT}: ${THEMEDIR}/${THEME}-theme.yml ${CUSTOM_PDF_CONVERTER} ${PAPERBACK_ADOC_TOTAL} Gemfile.lock ${PAPERBACK_COLOPHON_OUT} ${DEDICATION_OUT} ${ACKNOWLEDGMENTS_OUT}
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
		${PAPERBACK_ADOC_TOTAL}

CLEANFILES+=	${PAPERBACK_ADOC_TOTAL}
${PAPERBACK_ADOC_TOTAL}: ${PAPERBACK_FRONTMATTER} ${CHAPTERS} ${UNICODE_TABLE}
	rm -f ${.TARGET}
	cp ${PAPERBACK_FRONTMATTER} ${.TARGET}
.for chapter in ${CHAPTERS}
	printf '\n\n' >> ${.TARGET}
	dos2unix < ${chapter} | sed -E -f ${UNICODE_TABLE} >> ${.TARGET}
.endfor

CLEANFILES+=	${PAPERBACK_COLOPHON_OUT}
${PAPERBACK_COLOPHON_OUT}: ${THEMEDIR}/${THEME}-colophon-theme.yml ${PAPERBACK_COLOPHON_FILE} ${CUSTOM_PDF_CONVERTER} Gemfile.lock
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
		${PAPERBACK_COLOPHON_FILE}

CLEANFILES+=	${PAPERBACK_COLOPHON_FILE}
${PAPERBACK_COLOPHON_FILE}: ${COLOPHON_TEMPLATE} ${ERBBER_SCRIPT}
	${BUNDLE} exec ${RUBY} ${ERBBER_SCRIPT} -DISBN13=${PAPERBACK_ISBN} --input ${COLOPHON_TEMPLATE} > ${.TARGET}

########## ########## ##########

# ===== HARDCOVER =====

CLEANFILES+=	${HARDCOVER_OUT}
${HARDCOVER_OUT}: ${THEMEDIR}/${THEME}-theme.yml ${CUSTOM_PDF_CONVERTER} ${HARDCOVER_ADOC_TOTAL} Gemfile.lock ${HARDCOVER_COLOPHON_OUT} ${DEDICATION_OUT} ${ACKNOWLEDGMENTS_OUT}
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
		${PAPERBACK_ADOC_TOTAL}

CLEANFILES+=	${HARDCOVER_ADOC_TOTAL}
${HARDCOVER_ADOC_TOTAL}: ${HARDCOVER_FRONTMATTER} ${CHAPTERS} ${UNICODE_TABLE}
	rm -f ${.TARGET}
	cp ${HARDCOVER_FRONTMATTER} ${.TARGET}
.for chapter in ${CHAPTERS}
	printf '\n\n' >> ${.TARGET}
	dos2unix < ${chapter} | sed -E -f ${UNICODE_TABLE} >> ${.TARGET}
.endfor

CLEANFILES+=	${HARDCOVER_COLOPHON_OUT}
${HARDCOVER_COLOPHON_OUT}: ${THEMEDIR}/${THEME}-colophon-theme.yml ${HARDCOVER_COLOPHON_FILE} ${CUSTOM_PDF_CONVERTER} Gemfile.lock
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
		${HARDCOVER_COLOPHON_FILE}

CLEANFILES+=	${HARDCOVER_COLOPHON_FILE}
${HARDCOVER_COLOPHON_FILE}: ${COLOPHON_TEMPLATE} ${ERBBER_SCRIPT}
	${BUNDLE} exec ${RUBY} ${ERBBER_SCRIPT} -DISBN13=${HARDCOVER_ISBN} --input ${COLOPHON_TEMPLATE} > ${.TARGET}

########## ########## ##########

# ===== EPUB =====

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

CLEANFILES+=	${EPUB_ADOC_TOTAL}
${EPUB_ADOC_TOTAL}: ${EPUB_FRONTMATTER} ${CHAPTERS} ${UNICODE_TABLE}
	rm -f ${.TARGET}
	cp ${EPUB_FRONTMATTER} ${.TARGET}
.for chapter in ${CHAPTERS}
	printf '\n\n' >> ${.TARGET}
	dos2unix < ${chapter} | sed -E -f ${UNICODE_TABLE} >> ${.TARGET}
.endfor

CLEANFILES+=	${EPUB_COLOPHON_FILE}
${EPUB_COLOPHON_FILE}: ${COLOPHON_TEMPLATE} ${ERBBER_SCRIPT}
	${BUNDLE} exec ${RUBY} ${ERBBER_SCRIPT} -DISBN13=${EPUB_ISBN} --input ${COLOPHON_TEMPLATE} > ${.TARGET}


########## ########## ##########

# ===== COMMON =====

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

Gemfile.lock: Gemfile
	${BUNDLE} install

########## ########## ##########

.PHONY: clean
clean:
	rm -f ${CLEANFILES}
