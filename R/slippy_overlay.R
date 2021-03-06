#' Creates an overlay image from 'Mapbox' or 'Stamen' Maps using the 'slippymath' package
#'
#' @param raster_base A raster to use to calculate dimensions for the overlay
#' @param image_source Source for the overlay image. Valid entries are "mapbox", "stamen".
#' @param image_type The type of overlay to request. "satellite", "mapbox-streets-v8", "mapbox-terrain-v2", "mapbox-traffic-v1", "terrain-rgb", "mapbox-incidents-v1" (mapbox), "dem" (mapzen) or "watercolor", "toner", "toner-background", "toner-lite" (stamen). You can also request a custom Mapbox style by specifying \code{image_source = "mapbox", image_type = "username/mapid"}
#' @param max_tiles Maximum number of tiles to be requested by slippymath
#' @param api_key API key (required for mapbox)
#' @param return_png \code{TRUE} to return a png image. \code{FALSE} will return a raster
#' @param png_opacity Opacity of the returned image. Ignored if \code{return_png = FALSE}
#'
#' @return an overlay image for raster_base
#'
#' @examples
#' overlay_image <- slippy_overlay(example_raster(),
#'   image_source = "stamen",
#'   image_type = "watercolor",
#'   max_tiles = 2)
#' @export
slippy_overlay <- function(raster_base, image_source = "stamen", image_type = "watercolor", max_tiles = 10, api_key, return_png = TRUE, png_opacity = 0.9){

  #Calc bounding box to cover the raster
  bounding_box <- methods::as(raster::extent(raster_base), "SpatialPolygons")

  sp::proj4string(bounding_box) <- as.character(raster::crs(raster_base))

  bounding_box <- sp::spTransform(bounding_box, sp::CRS("+proj=longlat +datum=WGS84 +no_defs"))

  #Request slippy map
  raster_out <- get_slippy_map(bounding_box, image_source = image_source, image_type = image_type, max_tiles = max_tiles, api_key = api_key)

  #Transform slippy map to a png that covers raster_input
  raster_out = raster::projectRaster(raster_out, crs = raster::crs(raster_base))

  raster_out <- raster::resample(raster_out, raster_base)

  if(!return_png){
    return(raster_out)
  }

  temp_map_image <- tempfile(fileext = ".png")

  raster_to_png(raster_out, temp_map_image)

  map_image <- png::readPNG(temp_map_image)
  file.remove(temp_map_image)

  #add an alpha layer if one is not present
  if(dim(map_image)[3]==3){
    alpha_layer <- matrix(png_opacity, nrow = dim(map_image)[1], ncol = dim(map_image)[2])

    map_image <- abind::abind(map_image, alpha_layer)
  } else {
    map_image[,,4] <- png_opacity
  }

  return(map_image)
}
