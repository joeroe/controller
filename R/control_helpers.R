# control_helpers.R
# Internal helpers for control verbs

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
