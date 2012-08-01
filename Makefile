all: fetch

fetch:
	php fetch.php

stat:
	R --quiet --no-save < stat.R
