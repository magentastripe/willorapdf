#
# willora.mk
# Charlotte Koch <dressupgeekout@gmail.com>
#

# XXX this should be generated w/ a configure-step?
WILLORABASE?=	${.CURDIR}

NAME?=		mybook
PDF_OUT?=	${NAME}.pdf
ADOC_TOTAL=	${NAME}.adoc

BUNDLE?=	bundle
THEME?=		poppy
THEMEDIR?=	${WILLORABASE}/themes
FONTDIR?=	${WILLORABASE}/fonts
MEDIA?=		prepress

CUSTOM_PDF_CONVERTER=	${WILLORABASE}/lib/willora_pdf_converter.rb

########## ########## ##########

# XXX: Figure out why I can't do this:
# 'asciidoctor-pdf -a optimize'
# > GPL Ghostscript 9.50: Can't find initialization file gs_init.ps.
# https://docs.asciidoctor.org/pdf-converter/latest/optimize-pdf/

${PDF_OUT}: ${THEMEDIR}/${THEME}-theme.yml ${CUSTOM_PDF_CONVERTER} ${ADOC_TOTAL} Gemfile.lock
	${BUNDLE} exec sciidoctor-pdf \
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

${ADOC_TOTAL}: ${CHAPTERS}
	rm -f ${.TARGET}
.for chapter in ${CHAPTERS}
	dos2unix < ${chapter} | sed -E \
		-e 's,[[:space:]]--[[:space:]],\&\#8212;,g' \
		-e 's,\&eacute;,\&\#233;,g' >> ${.TARGET}
	printf '\n\n' >> ${.TARGET}
.endfor

Gemfile.lock:
	${BUNDLE} install

########## ########## ##########

.PHONY: clean
clean:
	rm -f ${PDF_OUT} ${ADOC_TOTAL}
