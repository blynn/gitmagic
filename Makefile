# The availaible translation languages.
# When starting a new translation, add a language code here.
#

TRANSLATIONS = de es fr ko pt_br ru uk vi zh_cn zh_tw it pl
LANGS = en $(TRANSLATIONS)
SHELL := /bin/bash

.PHONY: all clean sync public distclean $(LANGS)

all: $(LANGS)

$(LANGS): %: book-% book-%/default.css book-%.html book-%.pdf book-%.epub

# The book consists of these text files in the following order:

TXTFILES := preface.txt intro.txt basic.txt clone.txt branch.txt history.txt \
    multiplayer.txt grandmaster.txt secrets.txt drawbacks.txt translate.txt

$(foreach l,$(LANGS),book-$(l).xml): book-%.xml: $(addprefix %/,$(TXTFILES))
	# Concatenate the text files and feed to AsciiDoc.
	# If a file has not yet been translated for the target language,
	# then substitute the English version.
	# Kludge to support any translation of "Preface".
	echo '[specialsections]' > conf ; \
	if [ $* != ru ]; then \
	sed -n '/^== .* ==$$/p' $*/preface.txt | sed 's/^== \(.*\) ==$$/^\1$$=preface/' >> conf ; \
	else \
	cp lang-ru.conf conf ; fi ; \
	( for FILE in $^ ; do if [ -f $$FILE ]; then cat $$FILE; else \
	cat en/$$(basename $$FILE); fi; echo ; done ) | \
	asciidoc -a lang=$* -d book -b docbook -f conf - > $@

# This rule allows unfinished translations to build.
# Report an error if the English version of the text file is missing.
$(addprefix en/,$(TXTFILES)):
	@if [ ! -f $@ ]; then echo English file missing: $@; exit 123; fi
$(foreach l,$(TRANSLATIONS),$(addprefix $(l)/,$(TXTFILES))):
	@if [ ! -f $@ ]; then echo $@ missing: using English version; fi

# Ignore tidy's exit code because Asciidoc generates section IDs beginning with
# "_", which xmlto converts to "id" attributes of <a> tags. The standard
# insists that "id" attributes begin with a letter, which causes tidy to
# print a warning and return a nonzero code.
#
# When Asciidoc 8.3.0+ is widespread, I'll use its idprefix attribute instead
# of ignoring return codes.

$(foreach l,$(LANGS),book-$(l)): book-%: book-%.xml
	xmlto -m custom-html.xsl -o book-$* html book-$*.xml
	sed -i'' -e 's/xmlns:fo[^ ]*//g' book-$*/*.html
	-ls book-$*/*.html | xargs -n 1 tidy -utf8 -m -i -q
	./makeover $*

$(foreach l,$(LANGS),book-$(l)/default.css): book-%/default.css: book.css
	-mkdir -p book-$*
	rsync book.css book-$*/default.css

$(foreach l,$(LANGS),book-$(l).html): book-%.html: book-%.xml
	pandoc -s -f docbook -t html5 -o $@ $^

$(foreach l,$(LANGS),book-$(l).pdf): book-%.pdf: book-%.xml
	pandoc -s -f docbook -o $@  --pdf-engine=xelatex $^

book-ru.pdf: book-ru.xml
	pandoc -s -f docbook -o $@ --pdf-engine xelatex -V mainfont='DejaVuSansMono' $^

book-uk.pdf: book-uk.xml
	pandoc -s -f docbook -o $@ --pdf-engine xelatex -V mainfont='DejaVuSansMono' $^

book-ko.pdf: book-ko.xml
	pandoc -s -f docbook -o $@ --pdf-engine xelatex -V CJKmainfont='WenQuanYi Micro Hei Mono' $^

book-zh_cn.pdf: book-zh_cn.xml
	pandoc -s -f docbook -o $@ --pdf-engine xelatex -V CJKmainfont='WenQuanYi Micro Hei Mono' $^

book-zh_tw.pdf: book-zh_tw.xml
	pandoc -s -f docbook -o $@ --pdf-engine xelatex -V CJKmainfont='WenQuanYi Micro Hei Mono' $^

$(foreach l,$(LANGS),book-$(l).epub): book-%.epub: book-%.xml
	pandoc -s -f docbook -o $@ $^

clean:
	-rm -rf $(foreach l,$(LANGS),book-$(l).pdf book-$(l).xml book-$(l).html book-$(l)) \
	*.fo *.log *.out *.aux conf
