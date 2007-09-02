.PHONY: target clean

target: book book.html

TXTFILES=intro.txt basic.txt clone.txt branch.txt

book.xml: $(TXTFILES)
	cat $^ | sed 's/<tt>/<command>/g' | sed 's/<\/tt>/<\/command>/g' | ./bookmake > book.xml

book: book.xml book.css
	xmlto -m custom-html.xsl -o book html book.xml
	-ls book/*.html | xargs -n 1 tidy -utf8 -m -i -q
	./makeover
	rsync book.css book/default.css

book.html: book.xml
	xmlto -m custom-nochunks.xsl html-nochunks $^
	-tidy -utf8 -imq $@

clean:
	-rm -rf book.xml book.html book
