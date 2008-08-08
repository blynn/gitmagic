.PHONY: target clean sync push

target: book book/default.css book.html book.pdf

TXTFILES=preface.txt intro.txt basic.txt clone.txt branch.txt grandmaster.txt secrets.txt drawbacks.txt

book.xml: $(TXTFILES)
	( for FILE in $^ ; do cat $$FILE ; echo ; done ) | asciidoc -d book -b docbook - > $@

book: book.xml
	xmlto -m custom-html.xsl -o book html book.xml
	sed -i 's/xmlns:fo[^ ]*//g' book/*.html
	ls book/*.html | xargs -n 1 tidy -utf8 -m -i -q
	./makeover

book/default.css: book.css
	-mkdir book
	rsync book.css book/default.css

book.html: book.xml
	xmlto -m custom-nochunks.xsl html-nochunks $^
	tidy -utf8 -imq $@

book.pdf: book.xml
	docbook2pdf book.xml

clean:
	-rm -rf book.xml book.html book

sync: target
	rsync -r book.html book.pdf book/* blynn@tl1.stanford.edu:www/gitmagic/

public:
	git push blynn@git.or.cz:srv/git/gitmagic.git
	git push git@github.com:blynn/gitmagic.git
