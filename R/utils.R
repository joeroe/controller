# utils.R
# Miscellaneous internal utility functions

# Is a path a URL?
# Copied from readr:::is_url()
is_url <- function(x) {
  grepl("^((http|ftp)s?|sftp)://", x)
}
