.PHONY: target clean sync push

target: book book/default.css book.html book.pdf

# The book consists of these text files in the following order:

TXTFILES=preface.txt intro.txt basic.txt clone.txt branch.txt history.txt \
    grandmaster.txt secrets.txt drawbacks.txt

LANG=en

book.xml: $(addprefix $(LANG)/,$(TXTFILES))
	( for FILE in $^ ; do cat $$FILE ; echo ; done ) | asciidoc -d book -b docbook - > $@

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

book.pdf: book.xml
	docbook2pdf book.xml

clean:
	-rm -rf book.xml book.html book

sync: target
	rsync -r book.html book.pdf book/* blynn@tl1.stanford.edu:www/gitmagic/

public:
	git push blynn@git.or.cz:srv/git/gitmagic.git
	git push git@github.com:blynn/gitmagic.git
