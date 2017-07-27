
default: output/noisesocket.html output/noisesocket.pdf

# Pandoc 1.17.2, Pandoc-citeproc  

output/noisesocket.html: noisesocket.md template_pandoc.html spec_markdown.css my.bib
	pandoc noisesocket.md -s --toc \
	        -f markdown\
		--template template_pandoc.html \
		--css=spec_markdown.css \
		--filter pandoc-citeproc \
		-o output/noisesocket.html

output/noisesocket.pdf: noisesocket.md template_pandoc.latex my.bib
	pandoc noisesocket.md -s --toc \
	        -f markdown\
		--template template_pandoc.latex \
		--filter pandoc-citeproc \
		-o output/noisesocket.pdf

clean:
	rm output/noisesocket.html output/noisesocket.pdf
