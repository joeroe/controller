test_that("is_url() identifies valid URLs", {
  expect_true(is_url("http://example.com"))
  expect_true(is_url("https://example.com"))
  expect_true(is_url("ftp://example.com/file"))
  expect_true(is_url("sftp://example.com/file"))
})

test_that("is_url() rejects non-URLs", {
  expect_false(is_url("example.com"))
  expect_false(is_url("/path/to/file"))
  expect_false(is_url("not a url"))
  expect_false(is_url(""))
})

test_that("is_url() is vectorized", {
  urls <- c("https://example.com", "not a url", "ftp://test.org", "/local/path")
  result <- is_url(urls)
  expect_equal(result, c(TRUE, FALSE, TRUE, FALSE))
})

test_that("is_zip() identifies zip files", {
  tmp <- tempfile(fileext = ".zip")
  on.exit(unlink(tmp))

  # Create a minimal zip file using base R's zip()
  src <- tempfile(fileext = ".txt")
  writeLines("test content", src)
  zip(tmp, src)
  unlink(src)

  expect_true(is_zip(tmp))
})

test_that("is_zip() rejects non-zip files", {
  tmp <- tempfile(fileext = ".txt")
  on.exit(unlink(tmp))

  writeLines("not a zip file", tmp)
  expect_false(is_zip(tmp))
})

test_that("is_zip() rejects non-existent files", {
  expect_false(is_zip("/nonexistent/file/path.zip"))
})

test_that("is_zip() rejects directories", {
  tmp <- tempfile()
  on.exit(unlink(tmp, recursive = TRUE))

  dir.create(tmp)
  expect_false(is_zip(tmp))
})

test_that("is_zip() rejects files too small to be zips", {
  tmp <- tempfile()
  on.exit(unlink(tmp))

  writeBin(as.raw(c(0x50, 0x4B)), tmp)  # Only 2 bytes, need 4
  expect_false(is_zip(tmp))
})
