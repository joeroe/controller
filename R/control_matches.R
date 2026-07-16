# control_matches.R
# Inspect detailed match results

#' Show detailed match results from a thesaurus
#'
#' @description
#' `control_matches()` returns a data frame showing which type of match was used
#' for each value in `x`. This is useful for debugging or inspecting how
#' `control()` recodes values.
#'
#' @inheritParams control
#'
#' @return
#' A data frame with the same number of rows as `x`. The first column (`term`)
#' contains the original values. Subsequent columns contain the match result
#' for each match type (e.g. `exact_match`, `case_insensitive_match`,
#' `fuzzy_boundary_match`, `fuzzy_encoding_match`). Rows for NA values in `x`
#' are all NAs.
#'
#' @export
#'
#' @examples
#' data(colour_thesaurus)
#'
#' x <- c("red", "lipstick", "green", "mint", "blue", "azure")
#' control_matches(x, colour_thesaurus)
control_matches <- function(x, thesaurus,
                            thesaurus_cols = c(1, 2),
                            case_insensitive = FALSE,
                            fuzzy_boundary = FALSE,
                            fuzzy_encoding = FALSE) {
  if (!is.vector(x)) {
    rlang::abort("`x` must be a vector.")
  }

  terms <- unique(x[!is.na(x)])
  thesaurus <- prepare_thesaurus(thesaurus, thesaurus_cols)

  matched <- match_terms(terms, thesaurus, case_insensitive,
                         fuzzy_boundary, fuzzy_encoding)

  # Rename match columns to add _match suffix
  match_cols <- setdiff(names(matched), "term")
  names(matched)[names(matched) %in% match_cols] <- paste0(match_cols, "_match")

  result <- matched[match(x, matched$term), , drop = FALSE]
  row.names(result) <- NULL
  result
}
