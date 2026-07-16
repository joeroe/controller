# Controlled vocabularies

A *controlled vocabulary* is a predefined set of terms intended to be
used to be used in a specific context. They can solve a number of
problems of data standardisation and cleaning in data science.
controller provides functions for working with controlled vocabularies
in R.

This vignette explains the main features of the package. It introduces
the [`control()`](https://controller.joeroe.io/reference/control.md)
verb, which recodes values in a vector using a lookup table of preferred
and variant terms (a *thesaurus*).

## The `control()` verb

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

By default,
[`control()`](https://controller.joeroe.io/reference/control.md) issues
a message listing the values that were replaced and a warning for any
values that could not be matched in the thesaurus. These can be
suppressed with `quiet = TRUE` and `warn_unmatched = FALSE`
respectively.

Use
[`control_names()`](https://controller.joeroe.io/reference/control_names.md)
to control the names of an object rather than its values. This is useful
for standardising column names in data frames:

``` r

df <- data.frame(temp = 20, humid = 65, `wind speed` = 10, date = "2024-01-01")
df
#>   temp humid wind.speed       date
#> 1   20    65         10 2024-01-01

control_names(df, thesaurus = data.frame(
  preferred = c("temperature", "humidity", "wind_speed"),
  variant = c("temp", "humid", "wind speed")
))
#> Replaced values:
#> ℹ temp → temperature
#> ℹ humid → humidity
#> Warning: Some values of `x` were not matched in `thesaurus`:
#> ✖ wind.speed
#> ✖ date
#>   temperature humidity wind.speed       date
#> 1          20       65         10 2024-01-01
```

## Fuzzy matching

[`control()`](https://controller.joeroe.io/reference/control.md) also
supports fuzzy matching, removing the need to exhaustively list variants
for common causes of differing terminology. For example, to perform a
case insensitive match to the thesaurus:

``` r

shades_ci <- toupper(shades)
control_ci(shades_ci, colour_thesaurus)
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

[`control_fuzzy()`](https://controller.joeroe.io/reference/control.md)
goes further by also ignoring differences in word boundaries and
character encoding. Fuzzy boundary matching treats word boundaries like
spaces, hyphens, and underscores as equivalent:

``` r

df <- data.frame(preferred = "foo bar", variant = "foo-bar")
control(c("foo bar", "foo_bar", "foobar"), df,
        fuzzy_boundary = TRUE, quiet = FALSE)
#> Replaced values:
#> ℹ foo_bar → foo bar
#> ℹ foobar → foo bar
#> [1] "foo bar" "foo bar" "foo bar"
```

Fuzzy encoding matching ignores non-ASCII characters, so plain ASCII
input can match variants with diacritics or wrongly encoded characters
(‘mojibake’):

``` r

df <- data.frame(preferred = "bar", variant = "fo\u00f6")
control("foo", df, fuzzy_encoding = TRUE, quiet = FALSE)
#> Replaced values:
#> ℹ foo → bar
#> [1] "bar"
```

To inspect which type of match was used for each value, use
[`control_matches()`](https://controller.joeroe.io/reference/control_matches.md).
It returns a data frame with a column for each match type, rather than a
single vector:

``` r

control_matches(shades_ci, colour_thesaurus, case_insensitive = TRUE)
#>       term exact_match case_insensitive_match
#> 1 DAFFODIL        <NA>                 yellow
#> 2   PURPLE        <NA>                 purple
#> 3  MAGENTA        <NA>                   <NA>
#> 4    AZURE        <NA>                   blue
#> 5     NAVY        <NA>                   blue
#> 6   VIOLET        <NA>                 purple
```

## Thesaurus format

A thesaurus is a data frame with two columns containing preferred terms
and the variants to be controlled. Each row maps one variant to one
preferred term. The variants must be unique values – otherwise they
cannot be unambiguously matched to a preferred term.

`colour_thesaurus`,[^1] used in the examples above, is an example of a
thesaurus bundled with the package:

``` r

head(colour_thesaurus)
#>   colour     shade
#> 1  white     white
#> 2  white     pearl
#> 3  white alabaster
#> 4  white      snow
#> 5  white     ivory
#> 6  white     cream
```

Because a thesaurus is simply a data frame, it can be created or read
into R with standard tools:

``` r

my_thesaurus <- data.frame(
  preferred = c("feline", "canine"),
  variant = c("cat", "dog")
)

animals <- c("cat", "dog", "parrot")
control(animals, my_thesaurus)
#> Replaced values:
#> ℹ cat → feline
#> ℹ dog → canine
#> Warning: Some values of `x` were not matched in `thesaurus`:
#> ✖ parrot
#> [1] "feline" "canine" "parrot"
```

Use the `thesaurus_cols` argument to specify which columns of the data
frame contain the preferred and variant terms respectively:

``` r

my_wider_thesaurus <- data.frame(
  code = c("FEL", "CAN"),
  label = c("feline", "canine"),
  variant = c("cat", "dog")
)

control(animals, my_wider_thesaurus, thesaurus_cols = c("label", "variant"))
#> Replaced values:
#> ℹ cat → feline
#> ℹ dog → canine
#> Warning: Some values of `x` were not matched in `thesaurus`:
#> ✖ parrot
#> [1] "feline" "canine" "parrot"
```

The package can also read controlled vocabularies in Historic England’s
[FISH](https://www.heritage-standards.org.uk/fish-vocabularies/) (Forum
on Information Standards in Heritage) format using
[`read_fish()`](https://controller.joeroe.io/reference/read_fish.md).
The `path` argument can be a local `.zip` file, an uncompressed
directory, or a URL:

``` r

nationality_zip <- system.file("extdata", "fish-nationality.zip",
                               package = "controller")
fish_nationality <- read_fish(nationality_zip)
head(fish_nationality)
#>   preferred     term
#> 1   FAROESE Faeroese
```

The result is a data frame with columns `preferred` and `term`, ready to
use with
[`control()`](https://controller.joeroe.io/reference/control.md).

[^1]: Compiled by Ingrid Sundberg,
    <https://web.archive.org/web/20250619164626/https://ingridsundberg.com/2014/02/04/the-color-thesaurus/>.
