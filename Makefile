.PHONY: all sheets etl

all: sheets data/posts_with_topics.csv
sheets: data/parties.csv data/labeled_posts.csv


data/posts.csv: data/etl.sql
	psql -d tami -f $<

data/posts_with_topics.csv: data/posts.csv notebooks/post-topics.jl
	julia --project=. notebooks/post-topics.jl 

data/parties.csv:
	curl -o $@ -L \
		'https://docs.google.com/spreadsheets/d/e/2PACX-1vSPeE8VPPMrJ9ARHbS_1qKJUcmkOI8-GTglsNrxMU8eKyGTaTtDdn4mrn_11Ymb76E9oqCHQzGQMJoB/pub?output=csv'

data/labeled_posts.csv:
	curl -o $@ -L \
		'https://docs.google.com/spreadsheets/d/e/2PACX-1vSxxZPjC5s2jbKyazevlY_MCFiBLyfMzUlqSCUxJwPm5UYr7DTypMlnzVYhzcwaPSN4w2P6om7Ri1Ai/pub?gid=0&single=true&output=csv'

load_tami: data/2021-01-25_tami.dump
	# manually run `dropdb tami`!
	shasum -c data/SHA1SUMS.txt
	createdb -T template0 tami
	pg_restore --dbname=tami  --no-owner $<

%.png: %.dot
	dot -Tpng $^ -o $@
%.pdf: %.dot
	dot -Tpdf $^ -o $@

images:
	python images/scripts/get_images.py
	bash images/scripts/create_images.sh

archive:
	mkdir -p archive/$(date)
	for n in 1 2 3 4 5 6 7 8; do \
		cp images/topic$$n.jpg archive/$(date)/topic$$n.jpg ; \
	done
	cp notebooks/TAMI\ Dutch\ politics.ipynb archive/$(date)/
	sed -i -e 's/..\/images\/topic/topic/g' archive/$(date)/TAMI\ Dutch\ politics.ipynb