#
# willora.mk
# Charlotte Koch <charlotte@magentastripe.com>
#

WILLORABASE?=	${.CURDIR}

NAME?=			mybook
PAPERBACK_OUT?=		${NAME}-paperback.pdf
HARDCOVER_OUT?=		${NAME}-hardcover.pdf
EPUB_OUT?=		${NAME}.epub
DOCBOOK_OUT?=		${NAME}.xml
DOCX_OUT?=		${NAME}.docx
ODT_OUT?=		${NAME}.odt
BASE_ERB=		${NAME}-base.adoc.erb

ALL_OUT= \
	${PAPERBACK_OUT} \
	${HARDCOVER_OUT} \
	${EPUB_OUT}

# One of these for each edition
PAPERBACK_ADOC_TOTAL=	${PAPERBACK_OUT}.adoc
HARDCOVER_ADOC_TOTAL=	${HARDCOVER_OUT}.adoc
EPUB_ADOC_TOTAL=	${EPUB_OUT}.adoc
DOCBOOK_ADOC_TOTAL=	${DOCBOOK_OUT}.adoc

BUNDLE?=	bundle
RUBY?=		ruby
PANDOC?=	pandoc
THEME?=		poppy
THEMEDIR?=	${WILLORABASE}/themes
FONTDIR?=	${WILLORABASE}/fonts
MEDIA?=		prepress
PUBLISHER?=	WilloraPDF

THEMEFILES?=	${THEMEDIR}/${THEME}-theme.yml

PAPERBACK_ISBN?=	111-1-11111111-1-1
HARDCOVER_ISBN?=	222-2-22222222-2-2
EPUB_ISBN?=		333-3-33333333-3-3
PAPERBACK_CATNO?=	MSM-000001
HARDCOVER_CATNO?=	MSM-000002
EPUB_CATNO?=		MSM-000003

########## ########## ##########

FRONTMATTER_TEMPLATE?=		adoc/frontmatter-template.adoc.erb
COLOPHON_TEMPLATE=		adoc/colophon-template.adoc.erb
COLOPHONCONTENT_TEMPLATE=	adoc/colophon-content.adoc.erb
DEDICATION_TEMPLATE=		adoc/dedication-template.adoc.erb
DEDICATIONCONTENT_TEMPLATE=	adoc/dedication-content.adoc.erb

PAPERBACK_COLOPHONCONTENT_FILE=		colophoncontent-paperback.adoc
HARDCOVER_COLOPHONCONTENT_FILE=		colophoncontent-hardcover.adoc
EPUB_COLOPHONCONTENT_FILE=		colophoncontent-epub.adoc
DEDICATION_CONTENT_FILE=		dedication-content.adoc

PAPERBACK_COLOPHON_FILE?=	colophon-paperback.adoc
HARDCOVER_COLOPHON_FILE?=	colophon-hardcover.adoc
PAPERBACK_COLOPHON_OUT?=	colophon-paperback.pdf
HARDCOVER_COLOPHON_OUT?=	colophon-hardcover.pdf

PAPERBACK_DEDICATION_FILE?=	dedication-paperback.adoc
HARDCOVER_DEDICATION_FILE?=	dedication-hardcover.adoc
PAPERBACK_DEDICATION_OUT?=	dedication-paperback.pdf
HARDCOVER_DEDICATION_OUT?=	dedication-hardcover.pdf

EPUB_STYLESHEET=	${THEMEDIR}/epub3.scss
EPUB_BLURBFILE=		epub-assets/epub_blurb.html
EPUB_COVER_FILE=	epub-assets/cover.jpg
EPUB_REVDATE?=		1970-01-01

ACKNOWLEDGMENTS_FILE=	adoc/acknowledgments.adoc
BIOGRAPHY_FILE=		adoc/biography.adoc

ACKNOWLEDGMENTS_OUT?=	acknowledgments.pdf
BIOGRAPHY_OUT?=		biography.pdf

CUSTOM_PDF_CONVERTER=	${WILLORABASE}/lib/${THEME}_pdf_converter.rb
ERBBER_SCRIPT=		script/erbber.rb
UNICODE_TABLE=		script/unicodify.sed
UNICODE_TABLE_2=	script/unicodify2.sed
DOCX_FIXUP=		script/docx_fixup.sed
EPUB_FONT_STUFFER=	script/epub_font_stuffer.sh

DOCX_MANUSCRIPT_REF=	lib/WilloraPDF_Manuscript_Reference.docx
ODT_MANUSCRIPT_REF=	lib/WilloraPDF_Manuscript_Reference.odt

ALL_SECTIONS_COMMON=	${DEDICATION_OUT}
ALL_SECTIONS_COMMON+=	${ACKNOWLEDGMENTS_OUT}
ALL_SECTIONS_COMMON+=	${BIOGRAPHY_OUT}
ALL_SECTIONS_COMMON+=	${EXTRA_OUT}

PREREQS_COMMON=		${CUSTOM_PDF_CONVERTER}
PREREQS_COMMON+=	${THEMEFILES}
PREREQS_COMMON+=	Gemfile.lock

EXTRA_ARGS?=		# defined

########## ########## ##########

.PHONY: default
default: paperback

.PHONY: all
all: ${ALL_OUT}

.PHONY: base
base: ${BASE_ERB}

.PHONY: paperback
paperback: ${PAPERBACK_OUT}

# Legacy synonym
.PHONY: pdf
pdf: paperback

.PHONY: hardcover
hardcover: ${HARDCOVER_OUT}

.PHONY: epub
epub: ${EPUB_OUT}

.PHONY: docbook
docbook: ${DOCBOOK_OUT}

.PHONY: docx
docx: ${DOCX_OUT}

.PHONY: odt
odt: ${ODT_OUT}

########## ########## ##########

# ===== PAPERBACK =====

CLEANFILES+=	${PAPERBACK_OUT}
${PAPERBACK_OUT}: ${PREREQS_COMMON} ${ALL_SECTIONS_COMMON} ${PAPERBACK_ADOC_TOTAL} ${PAPERBACK_COLOPHON_OUT} ${PAPERBACK_DEDICATION_OUT}
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
		${EXTRA_ARGS} \
		${PAPERBACK_ADOC_TOTAL}

CLEANFILES+=	${PAPERBACK_ADOC_TOTAL}
${PAPERBACK_ADOC_TOTAL}: ${BASE_ERB} ${ERBBER_SCRIPT}
	${BUNDLE} exec ${RUBY} ${ERBBER_SCRIPT} \
		-DISBN=${PAPERBACK_ISBN} \
		-DCATNO=${PAPERBACK_CATNO} \
		-DVOLUMEKIND=PAPERBACK \
		--input ${BASE_ERB} > ${.TARGET}

# -- Paperback colophon ---

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
		-a media=${MEDIA} \
		-a text-align=justify \
		${EXTRA_ARGS} \
		${PAPERBACK_COLOPHON_FILE}

CLEANFILES+=	${PAPERBACK_COLOPHON_FILE}
${PAPERBACK_COLOPHON_FILE}: ${PAPERBACK_COLOPHONCONTENT_FILE} ${COLOPHON_TEMPLATE} ${ERBBER_SCRIPT}
	${BUNDLE} exec ${RUBY} ${ERBBER_SCRIPT} \
		-DISBN=${PAPERBACK_ISBN} \
		-DCATNO=${PAPERBACK_CATNO} \
		-DVOLUMEKIND=PAPERBACK \
		--input ${COLOPHON_TEMPLATE} > ${.TARGET}

CLEANFILES+=	${PAPERBACK_COLOPHONCONTENT_FILE}
${PAPERBACK_COLOPHONCONTENT_FILE}: ${COLOPHONCONTENT_TEMPLATE} ${ERBBER_SCRIPT}
	${BUNDLE} exec ${RUBY} ${ERBBER_SCRIPT} \
		-DISBN=${PAPERBACK_ISBN} \
		-DCATNO=${PAPERBACK_CATNO} \
		-DVOLUMEKIND=PAPERBACK \
		--input ${COLOPHONCONTENT_TEMPLATE} > ${.TARGET}

# -- Paperback dedication ---

CLEANFILES+=	${PAPERBACK_DEDICATION_OUT}
${PAPERBACK_DEDICATION_OUT}: ${THEMEDIR}/${THEME}-dedication-theme.yml ${PAPERBACK_DEDICATION_FILE} ${CUSTOM_PDF_CONVERTER} Gemfile.lock
	${BUNDLE} exec asciidoctor-pdf \
		-v \
		-r ${CUSTOM_PDF_CONVERTER} \
		-d book \
		-o ${.TARGET} \
		-a pdf-fontsdir=${FONTDIR} \
		-a pdf-theme=${THEME}-dedication \
		-a pdf-themesdir=${THEMEDIR} \
		-a media=${MEDIA} \
		${EXTRA_ARGS} \
		${PAPERBACK_DEDICATION_FILE}

CLEANFILES+=	${PAPERBACK_DEDICATION_FILE}
${PAPERBACK_DEDICATION_FILE}: ${DEDICATION_TEMPLATE} ${DEDICATION_CONTENT_FILE}
	${BUNDLE} exec ${RUBY} ${ERBBER_SCRIPT} \
		-DVOLUMEKIND=PAPERBACK \
		--input ${DEDICATION_TEMPLATE} > ${.TARGET}

########## ########## ##########

# ===== HARDCOVER =====

CLEANFILES+=	${HARDCOVER_OUT}
${HARDCOVER_OUT}: ${PREREQS_COMMON} ${ALL_SECTIONS_COMMON} ${HARDCOVER_ADOC_TOTAL} ${HARDCOVER_COLOPHON_OUT} ${HARDCOVER_DEDICATION_OUT}
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
		${EXTRA_ARGS} \
		${HARDCOVER_ADOC_TOTAL}

CLEANFILES+=	${HARDCOVER_ADOC_TOTAL}
${HARDCOVER_ADOC_TOTAL}: ${BASE_ERB} ${ERBBER_SCRIPT}
	${BUNDLE} exec ${RUBY} ${ERBBER_SCRIPT} \
		-DISBN=${HARDCOVER_ISBN} \
		-DCATNO=${HARDCOVER_CATNO} \
		-DVOLUMEKIND=HARDCOVER \
		--input ${BASE_ERB} > ${.TARGET}

# -- Hardcover colophon ---

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
		-a media=${MEDIA} \
		-a text-align=justify \
		${EXTRA_ARGS} \
		${HARDCOVER_COLOPHON_FILE}

CLEANFILES+=	${HARDCOVER_COLOPHON_FILE}
${HARDCOVER_COLOPHON_FILE}: ${HARDCOVER_COLOPHONCONTENT_FILE} ${COLOPHON_TEMPLATE} ${ERBBER_SCRIPT}
	${BUNDLE} exec ${RUBY} ${ERBBER_SCRIPT} \
		-DISBN=${HARDCOVER_ISBN} \
		-DCATNO=${HARDCOVER_CATNO} \
		-DVOLUMEKIND=HARDCOVER \
		--input ${COLOPHON_TEMPLATE} > ${.TARGET}

CLEANFILES+=	${HARDCOVER_COLOPHONCONTENT_FILE}
${HARDCOVER_COLOPHONCONTENT_FILE}: ${COLOPHONCONTENT_TEMPLATE} ${ERBBER_SCRIPT}
	${BUNDLE} exec ${RUBY} ${ERBBER_SCRIPT} \
		-DISBN=${HARDCOVER_ISBN} \
		-DCATNO=${HARDCOVER_CATNO} \
		-DVOLUMEKIND=HARDCOVER \
		--input ${COLOPHONCONTENT_TEMPLATE} > ${.TARGET}

# -- Hardcover dedication ---

CLEANFILES+=	${HARDCOVER_DEDICATION_OUT}
${HARDCOVER_DEDICATION_OUT}: ${THEMEDIR}/${THEME}-dedication-theme.yml ${HARDCOVER_DEDICATION_FILE} ${CUSTOM_PDF_CONVERTER} Gemfile.lock
	${BUNDLE} exec asciidoctor-pdf \
		-v \
		-r ${CUSTOM_PDF_CONVERTER} \
		-d book \
		-o ${.TARGET} \
		-a pdf-fontsdir=${FONTDIR} \
		-a pdf-theme=${THEME}-dedication \
		-a pdf-themesdir=${THEMEDIR} \
		-a media=${MEDIA} \
		${EXTRA_ARGS} \
		${HARDCOVER_DEDICATION_FILE}

CLEANFILES+=	${HARDCOVER_DEDICATION_FILE}
${HARDCOVER_DEDICATION_FILE}: ${DEDICATION_TEMPLATE} ${DEDICATION_CONTENT_FILE}
	${BUNDLE} exec ${RUBY} ${ERBBER_SCRIPT} \
		-DVOLUMEKIND=HARDCOVER \
		--input ${DEDICATION_TEMPLATE} > ${.TARGET}

########## ########## ##########

# ===== EPUB =====

EPUB_DESCR!=	cat ${EPUB_BLURBFILE}

# Includes a hack to add in my own fonts
#
# XXX Try to include EPUB_DESCR somewhere other than ARGV
CLEANFILES+=	${EPUB_OUT}
${EPUB_OUT}: Gemfile.lock ${EPUB_ADOC_TOTAL} ${EPUB_COVER_FILE} ${EPUB_STYLESHEET} ${EPUB_BLURBFILE} ${EPUB_FONT_STUFFER}
	${BUNDLE} exec asciidoctor-epub3 \
		-v \
		-d book \
		-o prestuffed.epub \
		-a uuid="${EPUB_ISBN}" \
		-a revdate="${EPUB_REVDATE}" \
		-a producer="${PUBLISHER}" \
		-a description="${EPUB_DESCR}" \
		-a front-cover-image=${EPUB_COVER_FILE} \
		-a series-name="${EPUB_SERIESNAME}" \
		-a ebook-format=epub3 \
		-a epub3-stylesdir=${THEMEDIR} \
		-a media=${MEDIA} \
		-a text-align=justify \
		${EXTRA_ARGS} \
		${EPUB_ADOC_TOTAL}
	bash ${EPUB_FONT_STUFFER}	\
		--fontdir ${FONTDIR}	\
		--input prestuffed.epub	\
		--output ${.TARGET}
	rm -f prestuffed.epub

CLEANFILES+=	${EPUB_ADOC_TOTAL}
${EPUB_ADOC_TOTAL}: ${EPUB_COLOPHONCONTENT_FILE} ${BASE_ERB} ${ERBBER_SCRIPT}
	${BUNDLE} exec ${RUBY} ${ERBBER_SCRIPT} \
		-DISBN=${EPUB_ISBN} \
		-DCATNO=${EPUB_CATNO} \
		-DVOLUMEKIND=EPUB \
		--input ${BASE_ERB} > ${.TARGET}

CLEANFILES+=	${EPUB_COLOPHONCONTENT_FILE}
${EPUB_COLOPHONCONTENT_FILE}: ${COLOPHONCONTENT_TEMPLATE} ${ERBBER_SCRIPT}
	${BUNDLE} exec ${RUBY} ${ERBBER_SCRIPT} \
		-DISBN=${EPUB_ISBN} \
		-DCATNO=${EPUB_CATNO} \
		-DVOLUMEKIND=EPUB \
		--input ${COLOPHONCONTENT_TEMPLATE} > ${.TARGET}

########## ########## ##########

# ===== DOCBOOK =====

# Willora's DocBook output is intended for making editable files compatible
# with Microsoft Word -- it's supposed to be part of the copyediting
# workflow, not final typesetting and interior design. That's why the
# frontmatter and backmatter are "missing."

CLEANFILES+=	${DOCBOOK_OUT}
${DOCBOOK_OUT}: Gemfile.lock ${DOCBOOK_ADOC_TOTAL}
	${BUNDLE} exec asciidoctor \
		-v \
		-d book \
		-b docbook \
		-o ${.TARGET} \
		${DOCBOOK_ADOC_TOTAL}

CLEANFILES+=	${DOCBOOK_ADOC_TOTAL}
${DOCBOOK_ADOC_TOTAL}: ${CHAPTERS} ${UNICODE_TABLE}
	rm -f ${.TARGET}
.for chapter in ${CHAPTERS}
	printf '\n\n' >> ${.TARGET}
	dos2unix < ${chapter} | sed -E -f ${UNICODE_TABLE} >> ${.TARGET}
.endfor

########## ########## ##########

# ===== DOCX =====

# Thematic breaks are 'visible' in the Docbook source but they are ignored
# in the conversion to docx. So we have to make them look the way we want
# ("# # #") right now.

CLEANFILES+=	${DOCX_OUT}
${DOCX_OUT}: ${DOCBOOK_OUT} ${DOCX_FIXUP} ${DOCX_MANUSCRIPT_REF}
	sed -E -f ${DOCX_FIXUP} ${DOCBOOK_OUT} | \
		${PANDOC} --from docbook --to docx \
		--reference-doc ${DOCX_MANUSCRIPT_REF} \
		-o ${.TARGET} \
		-

########## ########## ##########

# ===== ODT =====

CLEANFILES+=	${ODT_OUT}
${ODT_OUT}: ${DOCBOOK_OUT} ${DOCX_FIXUP} ${ODT_MANUSCRIPT_REF}
	sed -E -f ${DOCX_FIXUP} ${DOCBOOK_OUT} | \
		${PANDOC} --from docbook --to odt \
		--reference-doc ${ODT_MANUSCRIPT_REF} \
		-o ${.TARGET} \
		-

########## ########## ##########

# ===== COMMON =====

CLEANFILES+=	${BASE_ERB}
${BASE_ERB}: ${FRONTMATTER_TEMPLATE} ${CHAPTERS} ${UNICODE_TABLE} ${UNICODE_TABLE_2}
	rm -f ${.TARGET}
	echo "// vim: filetype=asciidoc" >> ${.TARGET}
	cat ${FRONTMATTER_TEMPLATE} >> ${.TARGET}
.for chapter in ${CHAPTERS}
	echo >> ${.TARGET}; echo >> ${.TARGET}
	dos2unix < ${chapter} | sed -E -f ${UNICODE_TABLE} | sed -E -f ${UNICODE_TABLE_2} >> ${.TARGET}
.endfor

########## ########## ##########

# XXX Is it actually safe to assume that the dedication content is the same for
# all editions?
CLEANFILES+=	${DEDICATION_CONTENT_FILE}
${DEDICATION_CONTENT_FILE}: ${DEDICATIONCONTENT_TEMPLATE} ${ERBBER_SCRIPT}
	${BUNDLE} exec ${RUBY} ${ERBBER_SCRIPT} \
		--input ${DEDICATIONCONTENT_TEMPLATE} > ${.TARGET}

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
		-a media=${MEDIA} \
		-a text-align=justify \
		${EXTRA_ARGS} \
		${ACKNOWLEDGMENTS_FILE}

CLEANFILES+=	${BIOGRAPHY_OUT}
${BIOGRAPHY_OUT}: ${THEMEDIR}/${THEME}-acknowledgments-theme.yml ${BIOGRAPHY_FILE} ${CUSTOM_PDF_CONVERTER} Gemfile.lock
	${BUNDLE} exec asciidoctor-pdf \
		-v \
		-r ${CUSTOM_PDF_CONVERTER} \
		-d book \
		-o ${.TARGET} \
		-a pdf-fontsdir=${FONTDIR} \
		-a pdf-theme=${THEME}-acknowledgments \
		-a pdf-themesdir=${THEMEDIR} \
		-a media=${MEDIA} \
		-a text-align=justify \
		${EXTRA_ARGS} \
		${BIOGRAPHY_FILE}

########## ########## ##########

Gemfile.lock: Gemfile
	${BUNDLE} config set --local path ${.CURDIR}/vendor
	${BUNDLE} install

########## ########## ##########

.PHONY: wordcount
wordcount: ${BASE_ERB}
	@wc -w ${BASE_ERB}

.PHONY: clean
clean:
	rm -f ${CLEANFILES}

.PHONY: __WIPEOUT__
__WIPEOUT__: clean
	rm -rf Gemfile.lock ${.CURDIR}/vendor ${.CURDIR}/.bundle
