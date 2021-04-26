# script to prepare `colour_thesaurus` dataset
# data from Ingrid Sundberg, <https://ingridsundberg.com/2014/02/04/the-color-thesaurus/>

colour_thesaurus <- read.delim("data-raw/colour_thesaurus.tsv")
usethis::use_data(colour_thesaurus, overwrite = TRUE)
