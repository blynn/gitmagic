target:
	./bookmake intro.txt > book.xml
	xmlto html-nochunks book.xml

clean:
	-rm book.xml book.html
