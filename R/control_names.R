# control_names.R
# Control names of an object

#' Control the names of an object
#'
#' @description
#' `control_names()` controls the names of an object using a thesaurus.
#' It extracts the names of `x`, passes them to [control()], and reassigns
#' the result to `names(x)`.
#'
#' `control_names_ci()` and `control_names_fuzzy()` are convenience aliases
#' for case insensitive and full fuzzy matching respectively.
#'
#' @param x Object with names to control.
#' @param thesaurus Data frame with a vector of preferred terms and a vector of
#'   variants.
#' @param thesaurus_cols Vector of two column names or positions specifying which
#'   columns in `thesaurus` contain the preferred terms and variants
#'   respectively. Defaults to the first two columns.
#' @param ... Other arguments passed to [control()]. This includes fuzzy
#'   matching options (`case_insensitive`, `fuzzy_boundary`, `fuzzy_encoding`)
#'   and output options (`quiet`, `warn_unmatched`, `coalesce`).
#'
#' @return
#' The object `x` with its names replaced by controlled values.
#'
#' @export
#'
#' @examples
#' df <- data.frame(temp = 20, humid = 65, `wind speed` = 10, date = "2024-01-01")
#' thesaurus <- data.frame(
#'   preferred = c("temperature", "humidity", "wind_speed"),
#'   variant = c("temp", "humid", "wind speed")
#' )
#' control_names(df, thesaurus)
control_names <- function(x, thesaurus, thesaurus_cols = c(1, 2), ...) {
  if (is.null(names(x))) {
    rlang::abort("`x` must have names.")
  }
  names(x) <- control(names(x), thesaurus, thesaurus_cols, ...)
  x
}

#' @rdname control_names
#' @export
control_names_ci <- function(x, thesaurus, thesaurus_cols = c(1, 2), ...) {
  control_names(x, thesaurus, thesaurus_cols, case_insensitive = TRUE, ...)
}

#' @rdname control_names
#' @export
control_names_fuzzy <- function(x, thesaurus, thesaurus_cols = c(1, 2), ...) {
  control_names(x, thesaurus, thesaurus_cols, case_insensitive = TRUE,
                fuzzy_boundary = TRUE, fuzzy_encoding = TRUE, ...)
}
