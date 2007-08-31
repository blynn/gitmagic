target: book.html

TXTFILES=intro.txt basic.txt

book.xml: $(TXTFILES)
	./bookmake $^ > book.xml

book: book.xml
	xmlto -m custom-html.xsl -o book html book.xml
	-ls book/*.html | xargs -n 1 tidy -utf8 -m -i -q

book.html: book.xml
	xmlto -m custom-nochunks.xsl html-nochunks $^
	-tidy -utf8 -imq $@

clean:
	-rm -rf book.xml book.html book
