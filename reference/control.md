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
  case_insensitive = FALSE,
  fuzzy_boundary = FALSE,
  fuzzy_encoding = FALSE,
  quiet = FALSE,
  warn_unmatched = TRUE,
  coalesce = TRUE
)

control_ci(x, thesaurus, ...)

control_fuzzy(x, thesaurus, ...)
```

## Arguments

- x:

  Vector to recode.

- thesaurus:

  Data frame with two columns: a vector of preferred terms, and a vector
  of variants.

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

- coalesce:

  If `TRUE` (the default), return only the closest matches in `x`. If
  `FALSE`, return all matches.

- ...:

  For `control_ci()` and `control_fuzzy`, other arguments passed to
  `control()`.

## Value

If `coalesce = TRUE` (the default), a vector the same length as `x` with
values matching variants in `thesaurus` replaced with the preferred
term. NAs in `x` are preserved as NAs.

If `coalesce = FALSE`, a data frame with the same number of rows as `x`,
and columns for each type of match (e.g. `exact`, `case_insensitive`,
`fuzzy_boundary`, `fuzzy_encoding`). Rows for NA values in `x` are all
NAs.

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

# coalesce = FALSE returns all matches as a data frame, which can be useful
# for debugging:
control(x, colour_thesaurus, case_insensitive = TRUE, coalesce = FALSE)
#> Replaced values:
#> ℹ RED → red
#> ℹ LIPSTICK → red
#> ℹ GREEN → green
#> ℹ MINT → green
#> ℹ BLUE → blue
#> ℹ AZURE → blue
#>   exact case_insensitive
#> 1  <NA>              red
#> 2  <NA>              red
#> 3  <NA>            green
#> 4  <NA>            green
#> 5  <NA>             blue
#> 6  <NA>             blue
```
