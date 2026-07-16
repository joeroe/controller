# utils.R
# Miscellaneous internal utility functions

# Is a path a URL?
# Copied from readr:::is_url()
is_url <- function(x) {
  grepl("^((http|ftp)s?|sftp)://", x)
}

# Is a file a zip archive?
# Checks magic bytes (PK signature: 50 4B 03 04)
is_zip <- function(path) {
  if (!fs::file_exists(path) || fs::is_dir(path)) return(FALSE)
  bytes <- readBin(path, "raw", n = 4)
  length(bytes) >= 4 &&
    bytes[1] == as.raw(0x50) &&
    bytes[2] == as.raw(0x4B) &&
    bytes[3] == as.raw(0x03) &&
    bytes[4] == as.raw(0x04)
}
