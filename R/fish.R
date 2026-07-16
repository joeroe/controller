# fish.R
# Functions for Historic England's FISH controlled vocabularies
# <https://www.heritage-standards.org.uk/fish-vocabularies/>

#' Read a FISH controlled vocabulary
#'
#' Reads controlled vocabularies from Historic England's FISH (Forum on
#' Information Standards in Heritage) group. These can be downloaded from:
#' <https://www.heritage-standards.org.uk/fish-vocabularies/>.
#'
#' @param path Path or URL to a vocabulary in FISH's CSV format. Can be
#'  either a `.zip` archive or a directory containing already uncompressed files.
#'
#' @return
#' A data frame with two columns: `preferred` and `term`.
#'
#' @references
#' * Forum on Information Standards in Heritage, "FISH Thesaurus Table Structure",
#'   Available from: <https://www.heritage-standards.org.uk/fish-vocabularies/>.
#'
#' @export
#'
#' @examples
#' # Read a FISH vocabulary from a local zip file
#' nationality_zip <- system.file("extdata", "fish-nationality.zip",
#'                                package = "controller")
#' read_fish(nationality_zip)
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
    rlang::abort("`path` must be a path to a .zip file or directory, or a valid URL.",
                 class = "controller_read_error")
  }

  file_names <- fs::path_ext_remove(fs::path_file(files))

  # Files have been observed with varying casing
  normalized <- gsub("_", "", tolower(file_names))
  names(files) <- normalized
  terms <- utils::read.csv(files["thesaurusterms"])
  preferred <- utils::read.csv(files["thesaurustermpreferences"])

  data.frame(
    preferred = terms$TERM[match(preferred$THE_TE_UID_2, terms$THE_TE_UID)],
    term = terms$TERM[match(preferred$THE_TE_UID_1, terms$THE_TE_UID)]
  )
}
