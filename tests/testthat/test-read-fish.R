test_that("read_fish() reads from zip file", {
  zip_path <- system.file("extdata", "fish-nationality.zip",
                          package = "controller")
  result <- read_fish(zip_path)

  expect_s3_class(result, "data.frame")
  expect_named(result, c("preferred", "term"))
  expect_gt(nrow(result), 0)
})

test_that("read_fish() reads from directory", {
  zip_path <- system.file("extdata", "fish-nationality.zip",
                          package = "controller")
  temp_dir <- fs::file_temp()
  fs::dir_create(temp_dir)
  on.exit(fs::dir_delete(temp_dir), add = TRUE)
  utils::unzip(zip_path, exdir = temp_dir)

  result <- read_fish(temp_dir)

  expect_s3_class(result, "data.frame")
  expect_named(result, c("preferred", "term"))
  expect_gt(nrow(result), 0)
})

test_that("read_fish() errors on invalid path", {
  expect_error(
    read_fish("/nonexistent/path/to/file.zip"),
    class = "controller_read_error"
  )
})

test_that("read_fish() errors on non-zip file", {
  temp_file <- fs::file_temp(ext = "zip")
  writeLines("not a zip file", temp_file)
  on.exit(fs::file_delete(temp_file), add = TRUE)

  expect_error(
    read_fish(temp_file),
    class = "controller_read_error"
  )
})

test_that("read_fish() errors on zip missing required files", {
  temp_dir <- fs::file_temp()
  fs::dir_create(temp_dir)
  on.exit(fs::dir_delete(temp_dir), add = TRUE)

  writeLines("a,b\n1,2", fs::path(temp_dir, "wrong_file.csv"))
  temp_zip <- fs::file_temp(ext = "zip")
  utils::zip(temp_zip, files = fs::path(temp_dir, "wrong_file.csv"), flags = "-r9Xq")
  on.exit(fs::file_delete(temp_zip), add = TRUE)

  expect_error(
    read_fish(temp_zip),
    class = "controller_read_error"
  )
})
