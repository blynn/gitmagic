# Makefile to genereate everything needed for a translation of git-magic using po4a

SHELL := /bin/bash

# the possible targets
#
# clean - remove the folder $(POTDIR) and all the .txt files
# gettext - create the folder $(POTDIR) and generate the .po files in there
# translate - create the .txt files from the translated .po files
#             for success you must have translated already 80% of a .po file
# update - update the .po files in case the originals has changed
#             changed items are marked 'fuzzy' in the .po file to fin them easy

.PHONY: clean gettext translate update

# the path to the english original .txt files
ORGDIR := ../en

# the folder where the .po files will be created
POTDIR := pot

# the filenames for the .txt and .po files
# must be identical to the english original .txt files
FILES := preface intro basic clone branch history multiplayer grandmaster secrets drawbacks translate
# add the .txt suffix to the filenames for a list of .txt files
TXTFILES := $(addsuffix .txt, $(FILES))
# add the .po suffix to the filenames for a list of .po files
POTFILES := $(addsuffix .po, $(FILES))

# prerequisites for gettext are the .po files
gettext: $(addprefix $(POTDIR)/,$(POTFILES))

# prerequisites for translate are the .txt files
translate: $(TXTFILES)

# no prerequisites to update the translated .po files when the english original .txt has changed
update:
	( for FILE in $(FILES) ; \
		do if [ -f $(ORGDIR)/$$FILE.txt ]; \
			then po4a-updatepo -f text -m $(ORGDIR)/$$FILE.txt -M UTF-8 -p $(POTDIR)/$$FILE.po; echo $$FILE; \
		fi; \
	done )

# remove all .po and .txt files
clean:
	-rm -rf $(POTDIR)
	-rm -rf *.txt

# prerequisites for the .po files is the existance of the pot folder
$(POTFILES) : | $(POTDIR)

# create the folder for the .po files
$(POTDIR) :
	-mkdir $(POTDIR)

# rule how to make the .po files from the english original .txt file
$(POTDIR)/%.po : $(ORGDIR)/%.txt
	po4a-gettextize -f text -m $< -p $@ -M UTF-8

# rule how to make the translatets .txt files from the translated .po files
%.txt : $(POTDIR)/%.po
	po4a-translate -f text -m ../en/$@ -p $< -M UTF-8 -l $@
