# The language we are building.
# For example, Run "make LANG=es" to build the Spanish edition.
LANG := en

.PHONY: target clean sync push

target: book book/default.css book.html book.pdf

# The book consists of these text files in the following order:

TXTFILES := preface.txt intro.txt basic.txt clone.txt branch.txt history.txt \
    grandmaster.txt secrets.txt drawbacks.txt translate.txt

book.xml: $(addprefix $(LANG)/,$(TXTFILES))
	# Kludge to make preface sections work for languages besides English.
	echo '[specialsections]' > conf
	sed -n '/^== .* ==$$/p' $(LANG)/preface.txt | sed 's/^== \(.*\) ==$$/^\1$$=sect-preface/' >> conf
	# Concatenate the text files and feed to AsciiDoc.
	# If a file has not yet been translated for the target language,
	# then substitute the English version.
	( for FILE in $^ ; do if [ -f $$FILE ]; then cat $$FILE; else \
	cat en/$$(basename $$FILE); fi; echo ; done ) | \
	asciidoc -a lang=$(LANG) -d book -b docbook -f conf - > $@

# This rule allows unfinished translations to build.
# Report an error if the English version of the text file is missing.
$(addprefix $(LANG)/,$(TXTFILES)) :
ifeq ($(LANG),en)
	@if [ ! -f $@ ]; then echo English file missing: $@; exit 123; fi
else
	@if [ ! -f $@ ]; then echo $@ missing: using English version; fi
endif

# Ignore tidy's exit code because Asciidoc generates section IDs beginning with
# "_", which xmlto converts to "id" attributes of <a> tags. The standard
# insists that "id" attributes begin with a letter, which causes tidy to
# print a warning and return a nonzero code.
#
# When Asciidoc 8.3.0+ is widespread, I'll use its idprefix attribute instead
# of ignoring return codes.

book: book.xml
	xmlto -m custom-html.xsl -o book html book.xml
	sed -i 's/xmlns:fo[^ ]*//g' book/*.html
	-ls book/*.html | xargs -n 1 tidy -utf8 -m -i -q
	./makeover

book/default.css: book.css
	-mkdir book
	rsync book.css book/default.css

book.html: book.xml
	xmlto -m custom-nochunks.xsl html-nochunks $^
	-tidy -utf8 -imq $@

# Set SP_ENCODING to avoid "non SGML character" errors.
# Can also do SP_ENCODING="UTF-8".
book.pdf: book.xml
	SP_ENCODING="XML" docbook2pdf book.xml

clean:
	-rm -rf book.xml book.html book

sync: target
	rsync -r book.html book.pdf book/* blynn@tl1.stanford.edu:www/gitmagic/intl/$(LANG)/

public:
	git push blynn@git.or.cz:srv/git/gitmagic.git
	git push git@github.com:blynn/gitmagic.git
	git push git@gitorious.org:gitmagic/mainline.git
