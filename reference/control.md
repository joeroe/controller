# Recode values using a thesaurus

The `control()` verb replaces values in a vector with values looked up
in a thesaurus. It is similar to
[`switch()`](https://rdrr.io/r/base/switch.html) or
[`dplyr::recode()`](https://dplyr.tidyverse.org/reference/recode.html),
but the replacement values are specified as a data frame instead of as
individual arguments.

By default `control()` replaces only values of `x` that exactly match
terms in `thesaurus`. Additional arguments allow for case insensitive
and fuzzy matching strategies (see details). `control_ci()` and
`control_fuzzy()` are convenience aliases for case insensitive exact
matching and full fuzzy matching respectively.

## Usage

``` r
control(
  x,
  thesaurus,
  thesaurus_cols = c(1, 2),
  case_insensitive = FALSE,
  fuzzy_boundary = FALSE,
  fuzzy_encoding = FALSE,
  quiet = FALSE,
  warn_unmatched = TRUE
)

control_ci(x, thesaurus, thesaurus_cols = c(1, 2), ...)

control_fuzzy(x, thesaurus, thesaurus_cols = c(1, 2), ...)
```

## Arguments

- x:

  Vector to recode.

- thesaurus:

  Data frame with a vector of preferred terms and a vector of variants.

- thesaurus_cols:

  Vector of two column names or positions specifying which columns in
  `thesaurus` contain the preferred terms and variants respectively.
  Defaults to the first two columns.

- case_insensitive:

  Set to `TRUE` to perform case insensitive matching.

- fuzzy_boundary:

  Set to `TRUE` to perform fuzzy matching that ignores differences in
  the word boundaries used (e.g. `"foo bar"` matches `"foo-bar"`).

- fuzzy_encoding:

  Set to `TRUE` to perform fuzzy matching that ignores non-ASCII
  characters that may have been encoded differently (e.g. `"foo"`
  matches `"foö"`).

- quiet:

  Set to `TRUE` suppress messages about replaced values.

- warn_unmatched:

  If `TRUE` (the default), issues a warning for values that couldn't be
  matched in `thesaurus`.

- ...:

  For `control_ci()` and `control_fuzzy()`, other arguments passed to
  `control()`. This includes fuzzy matching options (`fuzzy_boundary`,
  `fuzzy_encoding`) and output options (`quiet`, `warn_unmatched`).

## Value

A vector the same length as `x` with values matching variants in
`thesaurus` replaced with the preferred term. NAs in `x` are preserved
as NAs.

By default gives a message listing replaced values and a warning listing
any values not matched in the thesaurus. These can be suppressed with
`quiet = TRUE` and `warn_unmatched = FALSE` respectively.

## Examples

``` r
data(colour_thesaurus)

# Exact matching
x <- c("red", "lipstick", "green", "mint", "blue", "azure")
control(x, colour_thesaurus)
#> Replaced values:
#> ℹ lipstick → red
#> ℹ mint → green
#> ℹ azure → blue
#> [1] "red"   "red"   "green" "green" "blue"  "blue" 

# Case insensitive matching
x <- toupper(x)
control_ci(x, colour_thesaurus)
#> Replaced values:
#> ℹ RED → red
#> ℹ LIPSTICK → red
#> ℹ GREEN → green
#> ℹ MINT → green
#> ℹ BLUE → blue
#> ℹ AZURE → blue
#> [1] "red"   "red"   "green" "green" "blue"  "blue" 

# control_matches() returns a data frame showing which match type was used:
control_matches(x, colour_thesaurus, case_insensitive = TRUE)
#>       term exact_match case_insensitive_match
#> 1      RED        <NA>                    red
#> 2 LIPSTICK        <NA>                    red
#> 3    GREEN        <NA>                  green
#> 4     MINT        <NA>                  green
#> 5     BLUE        <NA>                   blue
#> 6    AZURE        <NA>                   blue
```
