TEXFILES := $(wildcard *.tex)

OUTDIR := ./result
PDFFILES := $(patsubst %.tex,$(OUTDIR)/%.pdf,$(TEXFILES))
LATEXMKARGS := -interaction=nonstopmode -silent

all: $(PDFFILES)

$(OUTDIR)/%.pdf: %.tex library/*.tex
	@mkdir -p $(OUTDIR)
	latexmk -pdf -output-directory=$(OUTDIR) $(LATEXMKARGS) $<

clean:
	latexmk -C -output-directory=$(OUTDIR)
	rm -rf $(OUTDIR)

.PHONY: all clean