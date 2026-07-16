# fish.R
# Functions for Historic England's FISH controlled vocabularies
# <https://heritage-standards.org.uk/fish-vocabularies/>

#' Read a FISH controlled vocabulary
#'
#' Reads controlled vocabularies from Historic England's FISH (Forum on
#' Information Standards in Heritage) group. These can be downloaded from:
#' <https://heritage-standards.org.uk/fish-vocabularies/>.
#'
#' @param path Path or URL to a vocabulary in FISH's CSV format. Can be
#'   either a `.zip` archive or a directory containing already uncompressed
#'   files, or a URL.
#'
#' @return
#' A data frame with two columns: `preferred` and `term`.
#'
#' @references
#' * Forum on Information Standards in Heritage, "FISH Thesaurus Table Structure",
#'   Available from: <https://heritage-standards.org.uk/fish-vocabularies/>.
#'
#' @export
#'
#' @examples
#' # Read a FISH vocabulary from a local zip file
#' nationality_zip <- system.file("extdata", "fish-nationality.zip",
#'                                package = "controller")
#' read_fish(nationality_zip)
read_fish <- function(path) {
  cleanup <- character()
  on.exit(unlink(cleanup, recursive = TRUE), add = TRUE)

  # Download if URL (don't check extension)
  if (is_url(path)) {
    tmp <- fs::file_temp(ext = "zip")
    cleanup <- c(cleanup, tmp)
    path <- curl::curl_download(path, tmp)
  }

  # Determine file list
  if (fs::file_exists(path) && is_zip(path)) {
    tmp_dir <- fs::file_temp()
    fs::dir_create(tmp_dir)
    cleanup <- c(cleanup, tmp_dir)
    files <- utils::unzip(path, exdir = tmp_dir)
  }
  else if (fs::file_exists(path) && fs::is_dir(path)) {
    files <- fs::dir_ls(path)
  }
  else {
    rlang::abort(
      "`path` must be a path to an existing .zip file or directory, or a URL.",
      class = "controller_read_error"
    )
  }

  # Normalize file names
  file_names <- fs::path_ext_remove(fs::path_file(files))
  normalized <- gsub("_", "", tolower(file_names))
  names(files) <- normalized

  # Validate required files
  required <- c("thesaurusterms", "thesaurustermpreferences")
  missing <- setdiff(required, names(files))
  if (length(missing) > 0) {
    rlang::abort(
      c("FISH vocabulary is missing required files.",
        i = paste("Expected:", paste(required, collapse = ", ")),
        x = paste("Found:", paste(names(files), collapse = ", "))),
      class = "controller_read_error"
    )
  }

  # Read data
  terms <- utils::read.csv(files[["thesaurusterms"]])
  preferred <- utils::read.csv(files[["thesaurustermpreferences"]])

  data.frame(
    preferred = terms$TERM[match(preferred$THE_TE_UID_2, terms$THE_TE_UID)],
    term = terms$TERM[match(preferred$THE_TE_UID_1, terms$THE_TE_UID)]
  )
}
