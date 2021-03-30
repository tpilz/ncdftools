# one year of daily data (random values, normally distributed)
data <- data.frame(
  date = seq.Date(as.Date("2000-01-01"), as.Date("2000-12-31"), by = "day"),
  value = rnorm(n = 366, mean = 10, sd = 4)
)

# save as ascii file (here as temporary file)
ascfile <- tempfile()
write.table(data, ascfile, sep = "\t", row.names = FALSE, quote = FALSE)
\dontrun{
  ascii2nc(ascfile, "test.nc", varname = "Precipitation", header = TRUE, sep = "\t")
}

# spatial grid
data <- data.frame(
  date = rep(seq.Date(as.Date("2000-01-01"), as.Date("2000-12-31"), by = "day"), 9),
  value = rnorm(n = 366*9, mean = 10, sd = 4),
  lon = rep(rep(c(30, 30.5, 31), each = 366), 3), lat = rep(c(40,40.5,41), each = 3*366)
)
ascfile <- tempfile()
write.table(data, ascfile, sep = "\t", row.names = FALSE, quote = FALSE)
\dontrun{
  ascii2nc(ascfile, "test_sp.nc", varname = "Precipitation",
         col_lon = "lon", col_lat = "lat", header = TRUE, sep = "\t")
}
