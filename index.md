# controller

**controller** is a collection of functions for working with controlled
vocabularies in R. It introduces the
[`control()`](https://controller.joeroe.io/reference/control.md) verb,
which recodes values in a vector using a lookup table of preferred and
variant terms (a *thesaurus*).

## Installation

You can install the development version of controller from GitHub using
the [remotes](https://remotes.r-lib.org/) package:

``` r

remotes::install_github("joeroe/controller")
```

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
number of terms. With
[`control()`](https://controller.joeroe.io/reference/control.md), we can
instead use a data frame containing a thesaurus to replace the values:

``` r

library(controller)
data("colour_thesaurus")

control(shades, colour_thesaurus)
#> Replaced values:
#> ℹ daffodil → yellow
#> ℹ azure → blue
#> ℹ navy → blue
#> ℹ violet → purple
#> Warning: Some values of `x` were not matched in `thesaurus`:
#> ✖ magenta
#> [1] "yellow"  "purple"  "magenta" "blue"    "blue"    "purple"
```

[`control()`](https://controller.joeroe.io/reference/control.md) also
supports fuzzy matching, removing the need to exhaustively list variants
for common causes of differing terminology. For example, to perform a
case insensitive match to the thesaurus:

``` r

shades <- toupper(shades)
control_ci(shades, colour_thesaurus)
#> Replaced values:
#> ℹ DAFFODIL → yellow
#> ℹ PURPLE → purple
#> ℹ AZURE → blue
#> ℹ NAVY → blue
#> ℹ VIOLET → purple
#> Warning: Some values of `x` were not matched in `thesaurus`:
#> ✖ MAGENTA
#> [1] "yellow"  "purple"  "MAGENTA" "blue"    "blue"    "purple"
```
