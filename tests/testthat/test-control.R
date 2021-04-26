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
