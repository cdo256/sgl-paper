TEXFILES := $(wildcard *.tex)
OUTDIR := ./result
LATEXMKARGS := -interaction=nonstopmode

all: $(TEXFILES:.tex=.pdf)

%.pdf: %.tex
	@mkdir -p $(OUTDIR)
	latexmk -pdf -output-directory=$(OUTDIR) $(LATEXMKARGS) $<

clean:
	latexmk -C -output-directory=$(OUTDIR)
	rm -rf $(OUTDIR)

.PHONY: all clean