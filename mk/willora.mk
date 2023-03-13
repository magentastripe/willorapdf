#
# willora.mk
# Charlotte Koch <dressupgeekout@gmail.com>
#

WILLORABASE?=	${.CURDIR}

NAME?=		mybook
PDF_OUT?=	${NAME}.pdf
ADOC_TOTAL=	${NAME}.adoc

BUNDLE?=	bundle
THEME?=		poppy
THEMEDIR?=	${WILLORABASE}/themes
FONTDIR?=	${WILLORABASE}/fonts
MEDIA?=		prepress

COLOPHON_OUT?=		colophon.pdf
DEDICATION_OUT?=	dedication.pdf

CUSTOM_PDF_CONVERTER=	${WILLORABASE}/lib/willora_pdf_converter.rb

########## ########## ##########

# XXX: Figure out why I can't do this:
# 'asciidoctor-pdf -a optimize'
# > GPL Ghostscript 9.50: Can't find initialization file gs_init.ps.
# https://docs.asciidoctor.org/pdf-converter/latest/optimize-pdf/

CLEANFILES+=	${PDF_OUT}
${PDF_OUT}: ${THEMEDIR}/${THEME}-theme.yml ${CUSTOM_PDF_CONVERTER} ${ADOC_TOTAL} Gemfile.lock ${COLOPHON_OUT} ${DEDICATION_OUT}
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
		${ADOC_TOTAL}

CLEANFILES+=	${ADOC_TOTAL}
${ADOC_TOTAL}: ${CHAPTERS}
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

Gemfile.lock:
	${BUNDLE} install

########## ########## ##########

.PHONY: clean
clean:
	rm -f ${CLEANFILES}
