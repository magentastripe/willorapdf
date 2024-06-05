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

PAPERBACK_ISBN?=	111-1-11111111-1-1
HARDCOVER_ISBN?=	222-2-22222222-2-2
EPUB_ISBN?=		333-3-33333333-3-3
PAPERBACK_CATNO?=	MSM-000001
HARDCOVER_CATNO?=	MSM-000002
EPUB_CATNO?=		MSM-000003

PAPERBACK_FRONTMATTER=		frontmatter-paperback.adoc
HARDCOVER_FRONTMATTER=		frontmatter-hardcover.adoc
EPUB_FRONTMATTER=		frontmatter-epub.adoc
PAPERBACK_COLOPHON_OUT?=	colophon-paperback.pdf
HARDCOVER_COLOPHON_OUT?=	colophon-hardcover.pdf
EPUB_COLOPHON_OUT?=		colophon-epub.pdf

EPUB_STYLESHEET=	${THEMEDIR}/epub3.scss
# XXX FIXME vv this shows up as "ISBN" on kobo
#EPUB_UUID=		4af808df-05d7-442f-a04d-5e23f394b4af 
# XXX FIXME vv this should be the real publication date
EPUB_REVDATE=		2024-01-01 
EPUB_BLURBFILE=		epub-assets/epub_blurb.html

DEDICATION_OUT?=	dedication.pdf
ACKNOWLEDGMENTS_OUT?=	acknowledgments.pdf
BIOGRAPHY_OUT?=		biography.pdf

CUSTOM_PDF_CONVERTER=	${WILLORABASE}/lib/${THEME}_pdf_converter.rb
ERBBER_SCRIPT=		script/erbber.rb
UNICODE_TABLE=		script/unicodify.sed
DOCX_FIXUP=		script/docx_fixup.sed

VOLUMEKIND_PAPERBACK=	PAPERBACK
VOLUMEKIND_HARDCOVER=	HARDCOVER
VOLUMEKIND_EPUB=	EPUB

ALL_SECTIONS_COMMON=	${DEDICATION_OUT}
ALL_SECTIONS_COMMON+=	${ACKNOWLEDGMENTS_OUT}
ALL_SECTIONS_COMMON+=	${BIOGRAPHY_OUT}
ALL_SECTIONS_COMMON+=	${EXTRA_OUT}

PREREQS_COMMON=		${CUSTOM_PDF_CONVERTER}
PREREQS_COMMON+=	${THEMEDIR}/${THEME}-theme.yml
PREREQS_COMMON+=	Gemfile.lock

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

.PHONY: docbook
docbook: ${DOCBOOK_OUT}

.PHONY: docx
docx: ${DOCX_OUT}

.PHONY: odt
odt: ${ODT_OUT}

########## ########## ##########

# ===== PAPERBACK =====

CLEANFILES+=	${PAPERBACK_OUT}
${PAPERBACK_OUT}: ${PREREQS_COMMON} ${ALL_SECTIONS_COMMON} ${PAPERBACK_ADOC_TOTAL} ${PAPERBACK_COLOPHON_OUT}
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
		-a media=${MEDIA} \
		-a text-align=justify \
		${PAPERBACK_COLOPHON_FILE}

CLEANFILES+=	${PAPERBACK_COLOPHON_FILE}
${PAPERBACK_COLOPHON_FILE}: ${COLOPHON_TEMPLATE} ${ERBBER_SCRIPT}
	${BUNDLE} exec ${RUBY} ${ERBBER_SCRIPT} \
		-DISBN13=${PAPERBACK_ISBN} \
		-DCATNO=${PAPERBACK_CATNO} \
		-DVOLUMEKIND=${VOLUMEKIND_PAPERBACK} \
		--input ${COLOPHON_TEMPLATE} > ${.TARGET}


CLEANFILES+=	${PAPERBACK_FRONTMATTER}
${PAPERBACK_FRONTMATTER}: ${FRONTMATTER_TEMPLATE}
	${BUNDLE} exec ${RUBY} ${ERBBER_SCRIPT} \
		-DVOLUMEKIND=${VOLUMEKIND_PAPERBACK} \
		--input ${FRONTMATTER_TEMPLATE} > ${.TARGET}

########## ########## ##########

# ===== HARDCOVER =====

CLEANFILES+=	${HARDCOVER_OUT}
${HARDCOVER_OUT}: ${PREREQS_COMMON} ${ALL_SECTIONS_COMMON} ${HARDCOVER_ADOC_TOTAL} ${HARDCOVER_COLOPHON_OUT}
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
		-a media=${MEDIA} \
		-a text-align=justify \
		${HARDCOVER_COLOPHON_FILE}

CLEANFILES+=	${HARDCOVER_COLOPHON_FILE}
${HARDCOVER_COLOPHON_FILE}: ${COLOPHON_TEMPLATE} ${ERBBER_SCRIPT}
	${BUNDLE} exec ${RUBY} ${ERBBER_SCRIPT} \
		-DISBN13=${HARDCOVER_ISBN} \
		-DCATNO=${HARDCOVER_CATNO} \
		-DVOLUMEKIND=${VOLUMEKIND_HARDCOVER} \
		--input ${COLOPHON_TEMPLATE} > ${.TARGET}

CLEANFILES+=	${HARDCOVER_FRONTMATTER}
${HARDCOVER_FRONTMATTER}: ${FRONTMATTER_TEMPLATE}
	${BUNDLE} exec ${RUBY} ${ERBBER_SCRIPT} \
		-DVOLUMEKIND=${VOLUMEKIND_HARDCOVER} \
		--input ${FRONTMATTER_TEMPLATE} > ${.TARGET}

########## ########## ##########

# ===== EPUB =====

EPUB_DESCR!=	cat ${EPUB_BLURBFILE}

# Includes a hack to add in my own fonts
CLEANFILES+=	${EPUB_OUT}
${EPUB_OUT}: Gemfile.lock ${EPUB_ADOC_TOTAL} ${EPUB_COVER_FILE} ${EPUB_STYLESHEET} ${EPUB_BLURBFILE}
	${BUNDLE} exec asciidoctor-epub3 \
		-v \
		-d book \
		-o ${.TARGET} \
		-a uuid="${EPUB_ISBN}" \
		-a revdate="${EPUB_REVDATE}" \
		-a producer="${PUBLISHER}" \
		-a description="${EPUB_DESCR}" \
		-a front-cover-image=${EPUB_COVER_FILE} \
		-a ebook-format=epub3 \
		-a epub3-stylesdir=${THEMEDIR} \
		-a media=${MEDIA} \
		-a text-align=justify \
		${EPUB_ADOC_TOTAL}
	rm -rf ./epub-cleanup ./cleaned.epub;		\
		mkdir -p ./epub-cleanup;		\
		sync .;					\
		cd ./epub-cleanup;			\
		unzip ../${.TARGET};			\
		rsync -avr ${FONTDIR}/ ./EPUB/fonts/;	\
		zip ../cleaned.epub -r .;		\
		cd ..;					\
		rm -rf ./epub-cleanup;			\
		mv ./cleaned.epub ${.TARGET};

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
	${BUNDLE} exec ${RUBY} ${ERBBER_SCRIPT} \
		-DISBN13=${EPUB_ISBN} \
		-DCATNO=${EPUB_CATNO} \
		-DVOLUMEKIND=${VOLUMEKIND_EPUB} \
		--input ${COLOPHON_TEMPLATE} > ${.TARGET}

CLEANFILES+=	${EPUB_FRONTMATTER}
${EPUB_FRONTMATTER}: ${FRONTMATTER_TEMPLATE}
	${BUNDLE} exec ${RUBY} ${ERBBER_SCRIPT} \
		-DVOLUMEKIND=${VOLUMEKIND_EPUB} \
		--input ${FRONTMATTER_TEMPLATE} > ${.TARGET}

########## ########## ##########

# ===== DOCBOOK =====

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
${DOCX_OUT}: ${DOCBOOK_OUT} ${DOCX_FIXUP}
	sed -E -f ${DOCX_FIXUP} ${DOCBOOK_OUT} | \
		${PANDOC} --from docbook --to docx \
		--reference-doc lib/WilloraPDF_Manuscript_Reference.docx \
		-o ${.TARGET} \
		-

########## ########## ##########

# ===== ODT =====

CLEANFILES+=	${ODT_OUT}
${ODT_OUT}: ${DOCBOOK_OUT} ${DOCX_FIXUP} lib/WilloraPDF_Manuscript_Reference.odt
	sed -E -f ${DOCX_FIXUP} ${DOCBOOK_OUT} | \
		${PANDOC} --from docbook --to odt \
		--reference-doc lib/WilloraPDF_Manuscript_Reference.odt \
		-o ${.TARGET} \
		-

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
		-a media=${MEDIA} \
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
		-a media=${MEDIA} \
		-a text-align=justify \
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
		${BIOGRAPHY_FILE}

########## ########## ##########

Gemfile.lock: Gemfile
	${BUNDLE} config set --local path ${.CURDIR}/vendor
	${BUNDLE} install

########## ########## ##########

.PHONY: wordcount
wordcount: ${PAPERBACK_ADOC_TOTAL}
	@wc -w ${PAPERBACK_ADOC_TOTAL}

.PHONY: clean
clean:
	rm -f ${CLEANFILES}
