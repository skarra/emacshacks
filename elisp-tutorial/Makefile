##
## Sriram Karra
##
## $Id$
## 
## Makefile for the Emacs Lisp tutorial's source.  

latex=latex
latex2html=latex2html
dvips=dvips

# Americans might be interested in "letter"
paper=A4

## Should not need to change anything below this.

source_base=tutorial

default: ps html

cleanps:
	rm -f .dvi $(source_base).ps $(source_base).dvi $(source_base).aux \
	*.log

cleanhtml:
	rm -rf $(source_base)

clean: cleanps cleanhtml

superclean: clean
	rm -f *~ 

## Run the command twice to resolve all cross references
ps: $(source_base).tex
	$(latex) -interaction=batchmode $< && \
	$(dvips) $(source_base).dvi -t $(paper) -o $(source_base).ps
	$(latex) -interaction=batchmode $< && \
	$(dvips) $(source_base).dvi -t $(paper) -o $(source_base).ps

html: $(source_base).tex
	$(latex2html) $<
