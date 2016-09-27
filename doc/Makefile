SimpleGraph.pdf: SimpleGraph.tex
	pdflatex SimpleGraph
	pdflatex SimpleGraph
	make clean

.phony: clean
clean:
	rm -rf *aux *log *~ auto

.phony: very-clean
very-clean:
	make clean
	rm *pdf
