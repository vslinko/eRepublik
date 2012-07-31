all: fetch prices

fetch:
	php fetch.php

prices:
	R --quiet --no-save < prices.R
