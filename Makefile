all: fetch

fetch:
	php fetch.php

prices:
	R --quiet --no-save < prices.R

bestfood:
	R --quiet --no-save < bestfood.R
