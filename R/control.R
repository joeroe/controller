# control.R
# Core verb `control()`

#' Recode values using a thesaurus
#'
#' @description
#' The `control()` verb replaces values in a vector with values looked up in a
#' thesaurus. It is similar to [switch()] or [dplyr::recode()], but the
#' replacement values are specified as a data frame instead of as individual
#' arguments.
#'
#' By default `control()` replaces only values of `x` that exactly match terms
#' in `thesaurus`. Additional arguments allow for case insensitive and fuzzy
#' matching strategies (see details). `control_ci()` and `control_fuzzy()` are
#' convenience aliases for case insensitive exact matching and full fuzzy
#' matching respectively.
#'
#' @param x Vector to recode.
#' @param thesaurus Data frame with a vector of preferred terms and a vector of
#'   variants.
#' @param thesaurus_cols Vector of two column names or positions specifying which
#'   columns in `thesaurus` contain the preferred terms and variants
#'   respectively. Defaults to the first two columns.
#' @param case_insensitive Set to `TRUE` to perform case insensitive matching.
#' @param fuzzy_boundary Set to `TRUE` to perform fuzzy matching that ignores
#'   differences in the word boundaries used (e.g. `"foo bar"` matches `"foo-bar"`).
#' @param fuzzy_encoding Set to `TRUE` to perform fuzzy matching that ignores
#'   non-ASCII characters that may have been encoded differently (e.g. `"foo"`
#'   matches `"foö"`).
#' @param quiet Set to `TRUE` suppress messages about replaced values.
#' @param warn_unmatched If `TRUE` (the default), issues a warning for values
#'   that couldn't be matched in `thesaurus`.
#' @param ... For `control_ci()` and `control_fuzzy()`, other arguments passed
#'   to `control()`. This includes fuzzy matching options (`fuzzy_boundary`,
#'   `fuzzy_encoding`) and output options (`quiet`, `warn_unmatched`).
#'
#' @return
#' A vector the same length as `x` with values matching variants in `thesaurus`
#' replaced with the preferred term. NAs in `x` are preserved as NAs.
#'
#' By default gives a message listing replaced values and a warning listing any
#' values not matched in the thesaurus. These can be suppressed with
#' `quiet = TRUE` and `warn_unmatched = FALSE` respectively.
#'
#' @export
#'
#' @examples
#' data(colour_thesaurus)
#'
#' # Exact matching
#' x <- c("red", "lipstick", "green", "mint", "blue", "azure")
#' control(x, colour_thesaurus)
#'
#' # Case insensitive matching
#' x <- toupper(x)
#' control_ci(x, colour_thesaurus)
#'
#' # control_matches() returns a data frame showing which match type was used:
#' control_matches(x, colour_thesaurus, case_insensitive = TRUE)
control <- function(x, thesaurus,
                    thesaurus_cols = c(1, 2),
                    case_insensitive = FALSE,
                    fuzzy_boundary = FALSE,
                    fuzzy_encoding = FALSE,
                    quiet = FALSE,
                    warn_unmatched = TRUE) {
  if (!is.vector(x)) {
    rlang::abort("`x` must be a vector.")
  }

  terms <- unique(x[!is.na(x)])
  thesaurus <- prepare_thesaurus(thesaurus, thesaurus_cols)

  matched <- match_terms(terms, thesaurus, case_insensitive,
                         fuzzy_boundary, fuzzy_encoding)
  matched$match <- do.call(dplyr::coalesce, c(matched[, -1, drop = FALSE],
                                              matched["term"]))

  # TODO: detect ambiguous matches and warn or error (#4)

  # Inform
  if (isFALSE(quiet)) {
    replaced <- matched[matched$term != matched$match, , drop = FALSE]
    if (nrow(replaced) > 0) {
      replaced <- paste(replaced$term, "\u2192", replaced$match)
      names(replaced) <- rep("i", length(replaced))
      rlang::inform(c("Replaced values:", replaced))
    }
    else {
      rlang::inform("No values replaced.")
    }
  }

  if (isTRUE(warn_unmatched)) {
    match_types <- matched[, !colnames(matched) %in% c("term", "match"),
                           drop = FALSE]
    unmatched <- matched$term[rowSums(is.na(match_types)) == ncol(match_types)]

    if (length(unmatched) > 0) {
      names(unmatched) <- rep("x", length(unmatched))
      rlang::warn(
        c("Some values of `x` were not matched in `thesaurus`:", unmatched),
        class = "controller_incomplete_control"
      )
    }
  }

  result <- matched$match[match(x, matched$term)]
  result[is.na(x)] <- NA
  result
}

#' @rdname control
#' @export
control_ci <- function(x, thesaurus, thesaurus_cols = c(1, 2), ...) {
  control(x, thesaurus, thesaurus_cols, case_insensitive = TRUE, ...)
}

#' @rdname control
#' @export
control_fuzzy <- function(x, thesaurus, thesaurus_cols = c(1, 2), ...) {
  control(x, thesaurus, thesaurus_cols, case_insensitive = TRUE,
          fuzzy_boundary = TRUE, fuzzy_encoding = TRUE, ...)
}
