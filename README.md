
<!-- README.md is generated from README.Rmd. Please edit that file -->

# controller

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![R-CMD-check](https://github.com/joeroe/controller/workflows/R-CMD-check/badge.svg)](https://github.com/joeroe/controller/actions)
[![Codecov test
coverage](https://codecov.io/gh/joeroe/controller/branch/main/graph/badge.svg)](https://codecov.io/gh/joeroe/controller?branch=main)
<!-- badges: end -->

**controller** is a collection of functions for working with controlled
vocabularies in R. It introduces the `control()` verb, which recodes
values in a vector using a lookup table of preferred and variant terms
(a *thesaurus*).

## Installation

You can install the development version of controlled from GitHub using
the [remotes](https://remotes.r-lib.org/) package:

``` r
remotes::install_github("joeroe/controller")
```

<!--
You can install the released version of controller from [CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("controller")
```
-->

## Example

A common data-tidying problem is standardising variant terms for the
same concept. Imagine we have a dataset that uses a number of different
names for shades of the same colour. As data analysts, we naturally want
to recode the data to eliminate this messy creativity, for example using
[dplyr::recode()](https://dplyr.tidyverse.org/reference/recode.html):

``` r
library(dplyr, warn.conflicts = FALSE)
shades <- c("daffodil", "purple", "magenta", "azure", "navy", "violet")

recode(shades,
       daffodil = "yellow",
       purple = "purple",
       magenta = "pink",
       azure = "blue",
       navy = "blue",
       violet = "purple")
#> [1] "yellow" "purple" "pink"   "blue"   "blue"   "purple"
```

But recoding this way can be tedious, especially if there are a large
number of terms. With `control()`, we can instead use a data frame
containing a thesaurus to replace the values:

``` r
library(controller)
data("colour_thesaurus")

control(shades, colour_thesaurus)
#> Replaced values:
#> ??? daffodil ??? yellow
#> ??? magenta ??? pink
#> ??? azure ??? blue
#> ??? navy ??? blue
#> ??? violet ??? purple
#> [1] "yellow" "purple" "pink"   "blue"   "blue"   "purple"
```

`control()` also supports fuzzy matching, removing the need to
exhaustively list variants for common causes of differing terminology.
For example, to perform a case insensitive match to the thesaurus:

``` r
shades <- toupper(shades)
control_ci(shades, colour_thesaurus)
#> Replaced values:
#> ??? DAFFODIL ??? yellow
#> ??? PURPLE ??? purple
#> ??? MAGENTA ??? pink
#> ??? AZURE ??? blue
#> ??? NAVY ??? blue
#> ??? VIOLET ??? purple
#> [1] "yellow" "purple" "pink"   "blue"   "blue"   "purple"
```
