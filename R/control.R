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

#' Show detailed match results from a thesaurus
#'
#' @description
#' `control_matches()` returns a data frame showing which type of match was used
#' for each value in `x`. This is useful for debugging or inspecting how
#' `control()` recodes values.
#'
#' @inheritParams control
#' @param ... Other arguments passed to [control()]. This includes fuzzy
#'   matching options (`case_insensitive`, `fuzzy_boundary`, `fuzzy_encoding`)
#'   and output options (`quiet`, `warn_unmatched`).
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

validate_thesaurus <- function(thesaurus) {
  if (ncol(thesaurus) != 2) {
    rlang::abort("`thesaurus_cols` must specify exactly 2 columns.")
  }

  if (anyDuplicated(thesaurus[[2]]) > 0) {
    rlang::abort("Variants (column 2 of `thesaurus`) must be unique.")
  }

  invisible(thesaurus)
}

prepare_thesaurus <- function(thesaurus, thesaurus_cols) {
  thesaurus <- as.data.frame(thesaurus)[, thesaurus_cols, drop = FALSE]
  validate_thesaurus(thesaurus)
  names(thesaurus) <- c("canon", "variant")
  thesaurus
}

fuzzy_match <- function(terms, variants, canon, char_class, ignore_case = FALSE) {
  patterns <- paste0("^", gsub(char_class, ".?", variants, perl = TRUE), "$")
  vapply(terms, function(term) {
    idx <- which(vapply(patterns, grepl, logical(1), x = term, ignore.case = ignore_case, perl = TRUE))
    if (length(idx) > 0) canon[idx[1]] else NA_character_
  }, character(1))
}

match_terms <- function(terms, thesaurus,
                        case_insensitive = FALSE,
                        fuzzy_boundary = FALSE,
                        fuzzy_encoding = FALSE) {
  result <- data.frame(term = terms)

  result$exact <- thesaurus$canon[match(result$term, thesaurus$variant)]

  if (isTRUE(case_insensitive)) {
    result$case_insensitive <- thesaurus$canon[match(tolower(result$term),
                                                     tolower(thesaurus$variant))]
  }

  if (isTRUE(fuzzy_boundary)) {
    result$fuzzy_boundary <- fuzzy_match(result$term,
                                         thesaurus$variant,
                                         thesaurus$canon,
                                         "[[:punct:][:space:]]",
                                         ignore_case = case_insensitive)
  }

  if (isTRUE(fuzzy_encoding)) {
    result$fuzzy_encoding <- fuzzy_match(result$term,
                                         thesaurus$variant,
                                         thesaurus$canon,
                                         "[^[:ascii:]]",
                                         ignore_case = case_insensitive)
  }

  result
}
