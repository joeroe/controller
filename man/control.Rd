% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/control.R
\name{control}
\alias{control}
\alias{control_ci}
\alias{control_fuzzy}
\title{Recode values using a thesaurus}
\usage{
control(
  x,
  thesaurus,
  case_insensitive = FALSE,
  fuzzy_boundary = FALSE,
  fuzzy_encoding = FALSE,
  quiet = FALSE,
  warn_unmatched = TRUE,
  coalesce = TRUE
)

control_ci(x, thesaurus, ...)

control_fuzzy(x, thesaurus, ...)
}
\arguments{
\item{x}{Vector to recode.}

\item{thesaurus}{Data frame with two columns: a vector of preferred terms,
and a vector of variants.}

\item{case_insensitive}{Set to \code{TRUE} to perform case insensitive matching.}

\item{fuzzy_boundary}{Set to \code{TRUE} to perform fuzzy matching that ignores
differences in the word boundaries used (e.g. \code{"foo bar"} matches \code{"foo-bar"}).}

\item{fuzzy_encoding}{Set to \code{TRUE} to perform fuzzy matching that ignores
non-ASCII characters that may have been encoded differently (e.g. \code{"foo"}
matches \code{"foö"}).}

\item{quiet}{Set to \code{TRUE} suppress messages about replaced values.}

\item{warn_unmatched}{If \code{TRUE} (the default), issues a warning for values
that couldn't be matched in \code{thesaurus}.}

\item{coalesce}{If \code{TRUE} (the default), return only the closest matches in
\code{x}. If \code{FALSE}, return all matches.}

\item{...}{For \code{control_ci()} and \code{control_fuzzy}, other arguments passed to
\code{control()}.}
}
\value{
If \code{coalesce = TRUE} (the default), a vector the same length as \code{x} with
values matching variants in \code{thesaurus} replaced with the preferred term.

If \code{coalesce = FALSE}, a data frame with the same number of rows as \code{x}, and
columns for each type of match (e.g. \code{exact}, \code{case_insensitive},
\code{fuzzy_boundary}, \code{fuzzy_encoding}).

By default gives a message listing replaced values and a warning listing any
values not matched in the thesaurus. These can be suppressed with
\code{quiet = TRUE} and \code{warn_unmatched = FALSE} respectively.
}
\description{
The \code{control()} verb replaces values in a vector with values looked up in a
thesaurus. It is similar to \code{\link[=switch]{switch()}} or \code{\link[dplyr:recode]{dplyr::recode()}}, but the
replacement values are specified as a data frame instead of as individual
arguments.

By default \code{control()} replaces only values of \code{x} that exactly match terms
in \code{thesaurus}. Additional arguments allow for case insensitive and fuzzy
matching strategies (see details). \code{control_ci()} and \code{control_fuzzy()} are
convenience aliases for case insensitive exact matching and full fuzzy
matching respectively.
}
\examples{
data(colour_thesaurus)

# Exact matching
x <- c("red", "lipstick", "green", "mint", "blue", "azure")
control(x, colour_thesaurus)

# Case insensitive matching
x <- toupper(x)
control_ci(x, colour_thesaurus)

# coalesce = FALSE returns all matches as a data frame, which can be useful
# for debugging:
control(x, colour_thesaurus, case_insensitive = TRUE, coalesce = FALSE)
}
