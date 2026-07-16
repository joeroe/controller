# Show detailed match results from a thesaurus

`control_matches()` returns a data frame showing which type of match was
used for each value in `x`. This is useful for debugging or inspecting
how [`control()`](https://controller.joeroe.io/reference/control.md)
recodes values.

## Usage

``` r
control_matches(
  x,
  thesaurus,
  thesaurus_cols = c(1, 2),
  case_insensitive = FALSE,
  fuzzy_boundary = FALSE,
  fuzzy_encoding = FALSE
)
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

## Value

A data frame with the same number of rows as `x`. The first column
(`term`) contains the original values. Subsequent columns contain the
match result for each match type (e.g. `exact_match`,
`case_insensitive_match`, `fuzzy_boundary_match`,
`fuzzy_encoding_match`). Rows for NA values in `x` are all NAs.

## Examples

``` r
data(colour_thesaurus)

x <- c("red", "lipstick", "green", "mint", "blue", "azure")
control_matches(x, colour_thesaurus)
#>       term exact_match
#> 1      red         red
#> 2 lipstick         red
#> 3    green       green
#> 4     mint       green
#> 5     blue        blue
#> 6    azure        blue
```
