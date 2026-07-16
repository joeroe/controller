# Control the names of an object

`control_names()` controls the names of an object using a thesaurus. It
extracts the names of `x`, passes them to
[`control()`](https://controller.joeroe.io/reference/control.md), and
reassigns the result to `names(x)`.

`control_names_ci()` and `control_names_fuzzy()` are convenience aliases
for case insensitive and full fuzzy matching respectively.

## Usage

``` r
control_names(x, thesaurus, thesaurus_cols = c(1, 2), ...)

control_names_ci(x, thesaurus, thesaurus_cols = c(1, 2), ...)

control_names_fuzzy(x, thesaurus, thesaurus_cols = c(1, 2), ...)
```

## Arguments

- x:

  Object with names to control.

- thesaurus:

  Data frame with a vector of preferred terms and a vector of variants.

- thesaurus_cols:

  Vector of two column names or positions specifying which columns in
  `thesaurus` contain the preferred terms and variants respectively.
  Defaults to the first two columns.

- ...:

  Other arguments passed to
  [`control()`](https://controller.joeroe.io/reference/control.md). This
  includes fuzzy matching options (`case_insensitive`, `fuzzy_boundary`,
  `fuzzy_encoding`) and output options (`quiet`, `warn_unmatched`).

## Value

The object `x` with its names replaced by controlled values.

## Examples

``` r
df <- data.frame(temp = 20, humid = 65, `wind speed` = 10, date = "2024-01-01")
thesaurus <- data.frame(
  preferred = c("temperature", "humidity", "wind_speed"),
  variant = c("temp", "humid", "wind speed")
)
control_names(df, thesaurus)
#> Replaced values:
#> ℹ temp → temperature
#> ℹ humid → humidity
#> Warning: Some values of `x` were not matched in `thesaurus`:
#> ✖ wind.speed
#> ✖ date
#>   temperature humidity wind.speed       date
#> 1          20       65         10 2024-01-01
```
