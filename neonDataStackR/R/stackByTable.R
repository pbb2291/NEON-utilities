##############################################################################################
#' @title Join data files in a zipped NEON data package by table type

#' @author
#' Christine Laney \email{claney@battelleecology.org}
#' Claire Lunch \email{clunch@battelleecology.org}

#' @description
#' Given a zipped data file, do a full join of all data files, grouped by table type.
#' This should result in a small number of large files.

#' @param dpID The identifier of the NEON data product to pull, in the form DPL.PRNUM.REV, e.g. DP1.10023.001
#' @param filepath The location of the zip file
#' @param savepath The location to save the output files to
#' @param package Either 'basic' or 'expanded', indicating which data package to download. Defaults to basic.
#' @param folder T or F: does the filepath point to a parent, unzipped folder, or a zip file? If F, assumes the filepath points to a zip file. Defaults to F.
#' @param saveUnzippedFiles T or F: should the unzipped monthly data folders be retained?
#' @return All files are unzipped and one file for each table type is created and written.

#' @export

#' @references
#' License: GNU AFFERO GENERAL PUBLIC LICENSE Version 3, 19 November 2007

# Changelog and author contributions / copyrights
#   2017-07-02 (Christine Laney): Original creation
#   2017-09-28 (Claire Lunch): Add error messages
#   2018-04-03 (Christine Laney):
#     * Add error/warning messages for AOP, eddy covariance, and hemispheric
#       digital photo data products (and if the latter, don't allow user to remove the unzipped files).
#     * Allow user to specify the filepath to save to
##############################################################################################

stackByTable <- function(dpID, filepath, savepath = filepath, package = 'basic', folder=FALSE, saveUnzippedFiles=FALSE){

  #### Check whether data should be stacked ####

  if(missing(dpID)){
    stop("Missing a value for dpID")
  }

  # error message if package is not basic or expanded
  if(!package %in% c("basic", "expanded")) {
    stop(paste(package, "is not a valid package name. Package must be basic or expanded", sep=" "))
  }

  # error message if dpID isn't formatted as expected
  if(regexpr("DP[1-4]{1}.[0-9]{5}.001",dpID)!=1) {
    stop(paste(dpID, "is not a properly formatted data product ID. The correct format is DP#.#####.001, where the first placeholder must be between 1 and 4.", sep=" "))
  }

  if(substr(dpID, 5, 5) == "3"){
    stop("This is an AOP data product, files cannot be stacked. Use byFileAOP() if you would like to download data.")
  }

  if(dpID == "DP4.00200.001"){
    stop("This eddy covariance data product is in HDF5 format and cannot be stacked.")
  }

  if(dpID == "DP1.10017.001" && package != 'basic'){
    saveUnzippedFiles = TRUE
    writeLines("Note: Digital hemispheric photos (in NEF format) cannot be stacked; only the CSV metadata files will be stacked.")
  }

  #### If all checks pass, unzip and stack files ####

  if(folder==FALSE) {
    savepath <- substr(filepath, 1, nchar(filepath)-4)
    unzipZipfile(zippath = filepath, outpath = savepath, level = "all")
  }
  if(folder==TRUE) {
    if(is.na(savepath)){savepath <- filepath}
    unzipZipfile(zippath = filepath, outpath = savepath, level = "in")
  }
  stackDataFiles(savepath)
  if(saveUnzippedFiles == FALSE){cleanUp(savepath)}

}

