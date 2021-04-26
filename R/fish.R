# fish.R
# Functions for Historic England's FISH controlled vocabularies
# <http://www.heritage-standards.org.uk/fish-vocabularies/>

#' Read a FISH controlled vocabulary
#'
#' Reads controlled vocabularies from Historic England's FISH (Forum on
#' Information Standards in Heritage) group. These can be downloaded from:
#' <http://www.heritage-standards.org.uk/fish-vocabularies/>.
#'
#' @param path Path or URL to a vocabulary in FISH's CSV format. Can be
#'  either a `.zip` archive or a directory containing already uncompressed files.
#'
#' @return
#' A data frame with two columns: `preferred` and `term`.
#'
#' @references
#' * Forum on Information Standards in Heritage, "FISH Thesaurus Table Structure",
#'   Available from: <http://www.heritage-standards.org.uk/fish-vocabularies/>.
#'
#' @export
#'
#' @examples
read_fish <- function(path) {
  if(isTRUE(is_url(path)) && isTRUE(fs::path_ext(path) == "zip")) {
    path <- curl::curl_download(path, fs::file_temp(ext = "zip"))
  }

  if (isTRUE(fs::file_exists(path)) && isTRUE(fs::path_ext(path) == "zip")) {
    files <- utils::unzip(path, exdir = fs::path_temp())
  }
  else if (isTRUE(fs::file_exists(path)) && isTRUE(fs::is_dir(path))) {
    files <- fs::dir_ls(path)
  }
  else {
    rlang::abort("`path` must be a path to a an existing .zip file or directory, or a valid URL.",
                 class = "controller_read_error")
  }

  names(files) <- fs::path_ext_remove(fs::path_file(files))
  terms <- utils::read.csv(files["thesaurus_terms"])
  preferred <- utils::read.csv(files["thesaurus_term_preferences"])

  data.frame(
    preferred = terms$TERM[match(preferred$THE_TE_UID_2, terms$THE_TE_UID)],
    term = terms$TERM[match(preferred$THE_TE_UID_1, terms$THE_TE_UID)]
  )
}
