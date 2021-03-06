% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Characterization.R
\name{createGeneralCharacterization}
\alias{createGeneralCharacterization}
\title{Execute the Study}
\usage{
createGeneralCharacterization(
  connectionDetails,
  cdmDatabaseSchema,
  oracleTempSchema = NULL,
  exportFolder,
  databaseId,
  cdmVersion = "5"
)
}
\arguments{
\item{connectionDetails}{An object of type \code{connectionDetails} as created using the
\code{\link[DatabaseConnector]{createConnectionDetails}} function in the
DatabaseConnector package.}

\item{cdmDatabaseSchema}{Schema name where your patient-level data in OMOP CDM format resides.
Note that for SQL Server, this should include both the database and
schema name, for example 'cdm_data.dbo'.}

\item{oracleTempSchema}{Should be used in Oracle to specify a schema where the user has write
priviliges for storing temporary tables.}

\item{exportFolder}{Name of local folder to place results; make sure to use forward slashes
(/). Do not use a folder on a network drive since this greatly impacts
performance.}

\item{databaseId}{A short string for identifying the database (e.g.
'Synpuf').}

\item{cdmVersion}{Version of the Common Data Model used. Currently only version 5 is supported.}
}
\description{
Execute the Study
}
\details{
This function executes the Study.

The \code{createCohorts}, \code{synthesizePositiveControls}, \code{runAnalyses}, and \code{runDiagnostics} arguments
are intended to be used to run parts of the full study at a time, but none of the parts are considerd to be optional.
}
