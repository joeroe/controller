test_that("control() aborts if `x` is not a vector", {
  expect_error(control(data.frame(), colour_thesaurus),
               regexp = "`x` must be a vector")
})

test_that("control() with exact matching works", {
  expect_equal(control(colour_thesaurus$shade, colour_thesaurus, quiet = TRUE),
               colour_thesaurus$colour)
})

test_that("control() with case insensitive matching works", {
  expect_equal(control_ci(toupper(colour_thesaurus$shade), colour_thesaurus, quiet = TRUE),
               colour_thesaurus$colour)
})

test_that("control() issues correct messages and warnings", {
  x <- c("a", "b", "c", "x", "y", "z")
  y <- data.frame(c("X", "Y", "Z"), c("x", "y", "z"))
  z <- c(data.frame(c("a", "b", "c", "x", "y", "z"),
                    c("a", "b", "c", "x", "y", "z")))

  # Replacement message, unmatched warning
  expect_message(control(x, y, warn_unmatched = FALSE), regexp = "Replaced values")
  expect_warning(control(x, y, quiet = TRUE), class = "controller_incomplete_control")

  # No replacement message, no warning
  expect_message(control(x, z), regexp = "No values replaced")
  expect_warning(control(x, z, quiet = TRUE), regexp = NA)

  # Suppressed message + warning
  expect_message(control(x, y, warn_unmatched = FALSE, quiet = TRUE), regexp = NA)
  expect_warning(control(x, y, warn_unmatched = FALSE, quiet = TRUE), regexp = NA)
})

test_that("control() preserves NAs in x", {
  x <- c("red", NA, "blue")
  result <- control(x, colour_thesaurus, quiet = TRUE)

  expect_equal(result, c("red", NA, "blue"))
  expect_equal(is.na(result), c(FALSE, TRUE, FALSE))
})

test_that("control() preserves NAs with coalesce = FALSE", {
  x <- c("red", NA, "blue")
  result <- control(x, colour_thesaurus, coalesce = FALSE, quiet = TRUE)

  expect_equal(nrow(result), 3)
  expect_true(all(is.na(result[2, ])))
  expect_false(is.na(result[1, ]))
  expect_false(is.na(result[3, ]))
})

test_that("control() does not warn about unmatched NAs", {
  expect_warning(control(c("red", NA), colour_thesaurus, quiet = TRUE), regexp = NA)
  expect_warning(control(c("red", NA), colour_thesaurus, coalesce = FALSE, quiet = TRUE), regexp = NA)
})

test_that("control() accepts thesaurus_cols by name", {
  df <- data.frame(colour = c("red", "green"), shade = c("crimson", "mint"))
  expect_equal(control(c("crimson", "mint"), df, thesaurus_cols = c("colour", "shade"), quiet = TRUE),
               c("red", "green"))
})

test_that("control() accepts thesaurus_cols by position", {
  df <- data.frame(colour = c("red", "green"), shade = c("crimson", "mint"))
  expect_equal(control(c("crimson", "mint"), df, thesaurus_cols = c("colour", "shade"), quiet = TRUE),
               control(c("crimson", "mint"), df, thesaurus_cols = c(1, 2), quiet = TRUE))
})

test_that("control() errors if thesaurus doesn't have exactly 2 columns", {
  df <- data.frame(a = 1:3, b = 1:3, c = 1:3)
  expect_error(control(1:3, df, thesaurus_cols = 1:3, quiet = TRUE), "`thesaurus_cols` must specify exactly 2 columns")
})

test_that("control() errors if variants are not unique", {
  df <- data.frame(a = c("x", "x"), b = c("y", "y"))
  expect_error(control("y", df, quiet = TRUE), "Variants .* must be unique")
})

test_that("control() with fuzzy boundary matching works", {
  df <- data.frame(canon = "foo bar", variant = "foo-bar")
  expect_equal(
    control(c("foo bar", "foo_bar", "foobar"), df,
            fuzzy_boundary = TRUE, quiet = TRUE, warn_unmatched = FALSE),
    c("foo bar", "foo bar", "foo bar")
  )
})

test_that("control() with fuzzy encoding matching works", {
  df <- data.frame(canon = "bar", variant = "fo\u00f6")
  expect_equal(
    control("foo", df, fuzzy_encoding = TRUE, quiet = TRUE, warn_unmatched = FALSE),
    "bar"
  )
})

test_that("control_fuzzy() combines all matching strategies", {
  boundary <- data.frame(canon = "foo bar", variant = "foo-bar")
  encoding <- data.frame(canon = "baz", variant = "ba\u00e7")

  expect_equal(
    control_fuzzy(c("foo bar", "foo_bar", "bac"), rbind(boundary, encoding),
                  quiet = TRUE, warn_unmatched = FALSE),
    c("foo bar", "foo bar", "baz")
  )
})
