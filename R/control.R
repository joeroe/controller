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
#' @param thesaurus Data frame with two columns: a vector of preferred terms,
#'   and a vector of variants.
#' @param case_insensitive Set to `TRUE` to perform case insensitive matching.
#' @param fuzzy_boundary Set to `TRUE` to perform fuzzy matching that ignores
#'   differences in the word boundaries used (e.g. `"foo bar"` matches `"foo-bar"`).
#' @param fuzzy_encoding Set to `TRUE` to perform fuzzy matching that ignores
#'   non-ASCII characters that may have been encoded differently (e.g. `"foo"`
#'   matches `"foö"`).
#' @param quiet Set to `TRUE` suppress messages about replaced values.
#' @param warn_unmatched If `TRUE` (the default), issues a warning for values
#'   that couldn't be matched in `thesaurus`.
#' @param coalesce If `TRUE` (the default), return only the closest matches in
#'   `x`. If `FALSE`, return all matches.
#' @param ... For `control_ci()` and `control_fuzzy`, other arguments passed to
#'   `control()`.
#'
#' @return
#' If `coalesce = TRUE` (the default), a vector the same length as `x` with
#' values matching variants in `thesaurus` replaced with the preferred term.
#'
#' If `coalesce = FALSE`, a data frame with the same number of rows as `x`, and
#' columns for each type of match (e.g. `exact`, `case_insensitive`,
#' `fuzzy_boundary`, `fuzzy_encoding`).
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
#' # coalesce = FALSE returns all matches as a data frame, which can be useful
#' # for debugging:
#' control(x, colour_thesaurus, case_insensitive = TRUE, coalesce = FALSE)
control <- function(x, thesaurus,
                    case_insensitive = FALSE,
                    fuzzy_boundary = FALSE,
                    fuzzy_encoding = FALSE,
                    quiet = FALSE,
                    warn_unmatched = TRUE,
                    coalesce = TRUE) {
  controlled <- data.frame(term = unique(x))
  # TODO: Validate thesaurus
  names(thesaurus) <- c("canon", "exact")

  # Exact matching
  controlled$exact <- thesaurus$canon[match(controlled$term, thesaurus$exact)]

  # Case insensitive matching
  if (isTRUE(case_insensitive)) {
    controlled$case_insensitive <- thesaurus$canon[match(tolower(controlled$term),
                                                         tolower(thesaurus$exact))]
  }

  # Fuzzy boundary matching
  if (isTRUE(fuzzy_boundary)) {
    # TODO
    rlang::abort("Sorry, fuzzy boundary matching is not yet implemented!",
                 class = "controller_not_implemented")
  }

  # Fuzzy encoding matching
  if (isTRUE(fuzzy_encoding)) {
    # TODO
    rlang::abort("Sorry, fuzzy encoding matching is not yet implemented!",
                 class = "controller_not_implemented")
  }

  # Determine best match
  controlled <- dplyr::relocate(controlled, !.data$term)
  controlled$match <- do.call(dplyr::coalesce, controlled)

  # TODO: detect ambiguous matches and warn or error

  # Inform
  if (isFALSE(quiet)) {
    replaced <- controlled[controlled$term != controlled$match,]
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
    matches <- controlled[,!colnames(controlled) %in% c("term", "match"),
                          drop = FALSE]
    unmatched <- controlled$term[rowSums(is.na(matches)) == ncol(matches)]

    if (length(unmatched) > 0) {
      names(unmatched) <- rep("x", length(unmatched))
      rlang::warn(
        c("Some values of `x` were not matched in `thesaurus`:", unmatched),
        class = "controller_incomplete_control"
      )
    }
  }

  # Return match(es)
  if (isTRUE(coalesce)) {
    controlled <- controlled$match[match(x, controlled$term)]
  }
  else {
    controlled <- controlled[match(x, controlled$term),
                             !colnames(controlled) %in% c("term", "match"),
                             drop = FALSE]
    row.names(controlled) <- NULL
  }

  return(controlled)
}

#' @rdname control
#' @export
control_ci <- function(x, thesaurus, ...) {
  control(x, thesaurus, case_insensitive = TRUE, fuzzy_boundary = FALSE,
          fuzzy_encoding = FALSE, ...)
}

#' @rdname control
#' @export
control_fuzzy <- function(x, thesaurus, ...) {
  control(x, thesaurus, case_insensitive = TRUE, fuzzy_boundary = TRUE,
          fuzzy_encoding = TRUE, ...)
}
