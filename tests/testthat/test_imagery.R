context("imagery")

library(geoviz)

igc <- example_igc()
DEM <- example_raster()
lat = 54.4502651
long = -3.1767946
square_km = 1

test_that("slippy_overlay() has correct dimensions", {
  slippy_overlay_result <- expect_warning(slippy_overlay(DEM, max_tiles = 5))

  expect_is(slippy_overlay_result, "array")
  expect_equal(ncol(slippy_overlay_result), ncol(DEM))
  expect_equal(nrow(slippy_overlay_result), nrow(DEM))
})

test_that("slippy_raster() returns data", {
  slippy_rater_result <- expect_warning(
    slippy_raster(
      lat,
      long,
      square_km,
      image_source = "stamen",
      image_type = "watercolor",
      max_tiles = 5
    )
  )

  expect_is(slippy_rater_result, "RasterBrick")
})

test_that("elevation_shade() has correct dimensions", {
  elevation_shade_result <-
    elevation_shade(
      DEM,
      elevation_palette = c("#54843f", "#808080", "#FFFFFF"),
      return_png = TRUE
    )

  expect_is(elevation_shade_result, "array")
  expect_equal(ncol(elevation_shade_result), ncol(DEM))
  expect_equal(nrow(elevation_shade_result), nrow(DEM))
})

test_that("elevation_transparency() has correct dimensions", {
  elevation_shade_result <-
    elevation_shade(
      DEM,
      elevation_palette = c("#54843f", "#808080", "#FFFFFF"),
      return_png = TRUE
    )

  elevation_transparency_result <-
    elevation_transparency(
      elevation_shade_result,
      DEM,
      alpha_max = 0.4,
      alpha_min = 0,
      pct_alt_low = 0.05,
      pct_alt_high = 0.25
    )

  expect_is(elevation_transparency_result, "array")
  expect_equal(ncol(elevation_transparency_result), ncol(DEM))
  expect_equal(nrow(elevation_transparency_result), nrow(DEM))
})

test_that("drybrush() has correct dimensions", {
  drybrush_result <-
    drybrush(
      DEM,
      aggregation_factor = 10,
      max_colour_altitude = 30,
      opacity = 0.5,
      elevation_palette = c("#3f3f3f", "#ffa500")
    )

  expect_is(drybrush_result, "array")
  expect_equal(ncol(drybrush_result), ncol(DEM))
  expect_equal(nrow(drybrush_result), nrow(DEM))
})
