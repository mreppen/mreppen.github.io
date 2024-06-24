SED ?= sed

ifeq ($(shell uname), Darwin)
	SED = gsed
endif

website: index replacements last_updated

index:
	eval $$(opam env) && \
	( bibtex-website --bibdir=bib *.bib template.html > index.html )

replacements:
	# This for loop instead of sed -i -E -f replacements.sed
	# in order to fail if something is not matched
	while read -r line; do \
		if ! [[ $$($(SED) --posix -i -E -e "$${line}w /dev/stdout" index.html) ]]; then \
			echo "Replacement $$line failed"; exit 1; \
		fi \
	done < replacements.sed

last_updated:
	$(SED) --posix -i -E 's|(Last update )[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}|\1'$$(date +"%Y-%m-%d")'|' index.html
