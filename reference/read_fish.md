# Read a FISH controlled vocabulary

Reads controlled vocabularies from Historic England's FISH (Forum on
Information Standards in Heritage) group. These can be downloaded from:
<https://www.heritage-standards.org.uk/fish-vocabularies/>.

## Usage

``` r
read_fish(path)
```

## Arguments

- path:

  Path or URL to a vocabulary in FISH's CSV format. Can be either a
  `.zip` archive or a directory containing already uncompressed files.

## Value

A data frame with two columns: `preferred` and `term`.

## References

- Forum on Information Standards in Heritage, "FISH Thesaurus Table
  Structure", Available from:
  <https://www.heritage-standards.org.uk/fish-vocabularies/>.

## Examples

``` r
# Read a FISH vocabulary from a local zip file
nationality_zip <- system.file("extdata", "fish-nationality.zip",
                               package = "controller")
read_fish(nationality_zip)
#>   preferred     term
#> 1   FAROESE Faeroese
```
