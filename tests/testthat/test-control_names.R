test_that("control_names() aborts if `x` has no names", {
  expect_error(control_names(1:3, colour_thesaurus),
               regexp = "`x` must have names")
})

test_that("control_names() with exact matching works", {
  df <- data.frame(lipstick = 1, mint = 2, azure = 3)
  result <- control_names(df, colour_thesaurus, quiet = TRUE, warn_unmatched = FALSE)

  expect_equal(names(result), c("red", "green", "blue"))
  expect_equal(result$red, 1)
  expect_equal(result$green, 2)
  expect_equal(result$blue, 3)
})

test_that("control_names_ci() with case insensitive matching works", {
  df <- data.frame(LIPSTICK = 1, MINT = 2, AZURE = 3)
  result <- control_names_ci(df, colour_thesaurus, quiet = TRUE, warn_unmatched = FALSE)

  expect_equal(names(result), c("red", "green", "blue"))
})

test_that("control_names_fuzzy() with fuzzy matching works", {
  df <- data.frame(foo_bar = 1, foobar = 2)
  thesaurus <- data.frame(preferred = "foo bar", variant = "foo-bar")
  result <- control_names_fuzzy(df, thesaurus, quiet = TRUE, warn_unmatched = FALSE)

  expect_equal(names(result), c("foo bar", "foo bar"))
})

test_that("control_names() preserves object structure", {
  df <- data.frame(a = 1, b = 2, c = 3)
  thesaurus <- data.frame(preferred = "x", variant = "a")
  result <- control_names(df, thesaurus, quiet = TRUE, warn_unmatched = FALSE)

  expect_s3_class(result, "data.frame")
  expect_equal(ncol(result), 3)
  expect_equal(nrow(result), 1)
  expect_equal(result[[1]], 1)
})
