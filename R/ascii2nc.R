
#' Convert an ASCII file into NetCDF
#'
#' @param ascii \code{character}, name of the ascii file.
#' @param nc \code{character}, name of the NetCDF file to be created.
#' @param col_value \code{character}, name of the value column.
#' @param col_date \code{character}, name of the date column. Date values must be
#' interpretable by \code{\link{as.Date}}.
#' @param varname \code{character}, name of the (single) variable in the ASCII file.
#' @param col_lon \code{character}, optional, name of the longitude column. If not given
#' (default) a single site is assumed.
#' @param col_lat \code{character}, optional, name of the latitude column. If not given
#' (default) a single site is assumed.
#' @param ... Arguments passed to \code{\link[utils]{read.table}} for reading of the ascii
#' file.
#'
#' @details
#' Data in the ASCII file are expected to be in a \href{https://en.wikipedia.org/wiki/Tidy_data}{tidy format},
#' i.e. \emph{rows correspond to sample individuals and columns to variables, so that the entry in
#' the ith row and jth column gives the value of the jth variate as measured or observed on the ith individual}.
#'
#' It is important to give the correct file specifications as optional arguments passed to
#' \code{\link[utils]{read.table}} to read the ASCII file (e.g. \code{header = ...} or
#' \code{sep = ...})! See also examples below.
#'
#' @note So far only daily values and a single variable per file are supported
#' (and expected in the ascii file).
#'
#' Metadata are kept to a minimum. A coordinate system is not assigned.
#' Please add them manually if needed.
#'
#' @return A NetCDF file is created. This does not follow any conventions! The dimension
#' names (\code{col_date}, \code{col_lon}, \code{col_lat}) and data are passed as given.
#'
#' @example inst/examples/ascii2nc.R
#' @export
ascii2nc <- function(ascii, nc,
                     col_value = "value", col_date = "date", varname,
                     col_lon, col_lat, ...) {
  if (missing(ascii)) stop("Argument 'ascii' has to be given!", call. = FALSE)
  if (missing(nc)) stop("Argument 'nc' has to be given!", call. = FALSE)
  if (missing(varname)) stop("Argument 'varname' must be given!", call. = FALSE)

  # read data from ascii file
  dat <- utils::read.table(ascii, ...)

  # create dimensions of the NetCDF
  dims <- list()
  if (!missing(col_lon)) dims[["longitude"]] <- ncdf4::ncdim_def("longitude", "<unknown>", unique(dat[[col_lon]]))
  if (!missing(col_lat)) dims[["latitude"]] <- ncdf4::ncdim_def("latitude", "<unknown>", unique(dat[[col_lat]]))
  dims[["time"]] <- ncdf4::ncdim_def("time", "days since 1970-01-01", unique(as.numeric(as.Date(dat[[col_date]]))))

  # variable
  dat[[col_value]][is.na(dat[[col_value]])] <- -9999
  vardef <- ncdf4::ncvar_def(varname, "", dims, -9999, prec = "float")

  # create ncdf
  ncnew <- ncdf4::nc_create(nc, vardef)
  on.exit(ncdf4::nc_close(ncnew), add = TRUE)

  # write values
  ncdf4::ncvar_put(ncnew, vardef, dat[[col_value]])
  ncdf4::ncatt_put(ncnew, 0, "Note",
            paste0("Created with R function ncdftools::ascii2nc(), version ", as.character(packageVersion("ncdftools")), ", https://github.com/tpilz/ncdftools"))
  ncdf4::ncatt_put(ncnew, 0, "date", as.character(Sys.time(), usetz = T))
}
