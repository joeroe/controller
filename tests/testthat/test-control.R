test_that("control() with exact matching works", {
  expect_equal(control(colour_thesaurus$shade, colour_thesaurus),
               colour_thesaurus$colour)
})

test_that("control() with case insensitive matching works", {
  expect_equal(control_ci(toupper(colour_thesaurus$shade), colour_thesaurus),
               colour_thesaurus$colour)
})

test_that("control() issues correct messages and warnings", {
  x <- c("a", "b", "c", "x", "y", "z")
  y <- data.frame(c("X", "Y", "Z"), c("x", "y", "z"))
  z <- c(data.frame(c("a", "b", "c", "x", "y", "z"),
                    c("a", "b", "c", "x", "y", "z")))

  # Replacement message, unmatched warning
  expect_message(control(x, y, warn_unmatched = FALSE), regexp = "Replaced values")
  expect_warning(control(x, y), class = "controller_incomplete_control")

  # No replacement message, no warning
  expect_message(control(x, z), regexp = "No values replaced")
  expect_warning(control(x, z), regexp = NA)

  # Suppressed message + warning
  expect_message(control(x, y, warn_unmatched = FALSE, quiet = TRUE), regexp = NA)
  expect_warning(control(x, y, warn_unmatched = FALSE), regexp = NA)
})

test_that("control() preserves NAs in x", {
  x <- c("red", NA, "blue")
  result <- control(x, colour_thesaurus)

  expect_equal(result, c("red", NA, "blue"))
  expect_equal(is.na(result), c(FALSE, TRUE, FALSE))
})

test_that("control() preserves NAs with coalesce = FALSE", {
  x <- c("red", NA, "blue")
  result <- control(x, colour_thesaurus, coalesce = FALSE)

  expect_equal(nrow(result), 3)
  expect_true(all(is.na(result[2, ])))
  expect_false(is.na(result[1, ]))
  expect_false(is.na(result[3, ]))
})

test_that("control() does not warn about unmatched NAs", {
  expect_warning(control(c("red", NA), colour_thesaurus), regexp = NA)
  expect_warning(control(c("red", NA), colour_thesaurus, coalesce = FALSE), regexp = NA)
})

test_that("control() accepts thesaurus_cols by name", {
  df <- data.frame(colour = c("red", "green"), shade = c("crimson", "mint"))
  expect_equal(control(c("crimson", "mint"), df, thesaurus_cols = c("colour", "shade")),
               c("red", "green"))
})

test_that("control() accepts thesaurus_cols by position", {
  df <- data.frame(colour = c("red", "green"), shade = c("crimson", "mint"))
  expect_equal(control(c("crimson", "mint"), df, thesaurus_cols = c("colour", "shade")),
               control(c("crimson", "mint"), df, thesaurus_cols = c(1, 2)))
})

test_that("control() errors if thesaurus doesn't have exactly 2 columns", {
  df <- data.frame(a = 1:3, b = 1:3, c = 1:3)
  expect_error(control(1:3, df, thesaurus_cols = 1:3), "`thesaurus_cols` must specify exactly 2 columns")
})

test_that("control() errors if variants are not unique", {
  df <- data.frame(a = c("x", "x"), b = c("y", "y"))
  expect_error(control("y", df), "Variants .* must be unique")
})
