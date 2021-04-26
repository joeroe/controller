# data.R
# Dataset documentation

#' Colour thesaurus
#'
#' A dataset of colour names compiled by Ingrid Sundberg, formatted as an
#' example thesaurus for use in [control()]. Contains 240 names for shades of
#' 12 colours.
#'
#' @format A data frame with 240 rows and 2 variables:
#' \describe{
#'   \item{colour}{preferred colour name: `"white"`, `"tan"`, `"yellow"`,
#'   `"orange"`, `"red"`, `"pink"`, `"purple"`, `"blue"`, `"green"`, `"brown"`,
#'   `"grey"`, or `"black"`}
#'   \item{shade}{variant names for shades of `colour`}
#' }
#' @source \url{https://ingridsundberg.com/2014/02/04/the-color-thesaurus/}
"colour_thesaurus"
