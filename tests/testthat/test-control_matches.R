test_that("control_matches() preserves NAs in x", {
  x <- c("red", NA, "blue")
  result <- control_matches(x, colour_thesaurus)

  expect_equal(nrow(result), 3)
  expect_true(all(is.na(result[2, ])))
  expect_true(all(!is.na(result[1, ])))
  expect_true(all(!is.na(result[3, ])))
})

test_that("control_matches() returns a data frame with correct columns", {
  x <- c("red", "lipstick", "green")
  result <- control_matches(x, colour_thesaurus)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 3)
  expect_equal(ncol(result), 2)
  expect_true("term" %in% names(result))
  expect_true("exact_match" %in% names(result))
})

test_that("control_matches() includes term column with original values", {
  x <- c("red", "lipstick", "green")
  result <- control_matches(x, colour_thesaurus)

  expect_equal(result$term, x)
})

test_that("control_matches() returns columns for each active match type", {
  x <- c("RED", "lipstick")
  result <- control_matches(x, colour_thesaurus, case_insensitive = TRUE)

  expect_equal(ncol(result), 3)
  expect_true("term" %in% names(result))
  expect_true("exact_match" %in% names(result))
  expect_true("case_insensitive_match" %in% names(result))
})

test_that("control_matches() works with exact matching", {
  result <- control_matches(colour_thesaurus$shade, colour_thesaurus)

  expect_equal(result$exact_match, colour_thesaurus$colour)
})

test_that("control_matches() works with case insensitive matching", {
  result <- control_matches(toupper(colour_thesaurus$shade), colour_thesaurus,
                            case_insensitive = TRUE)

  expect_equal(result$case_insensitive_match, colour_thesaurus$colour)
})

test_that("control_matches() works with fuzzy matching", {
  df <- data.frame(canon = "foo bar", variant = "foo-bar")
  result <- control_matches(c("foo bar", "foo_bar"), df, fuzzy_boundary = TRUE)

  expect_equal(result$fuzzy_boundary_match, c("foo bar", "foo bar"))
})

test_that("control_matches() aborts if `x` is not a vector", {
  expect_error(control_matches(data.frame(), colour_thesaurus),
               regexp = "`x` must be a vector")
})
