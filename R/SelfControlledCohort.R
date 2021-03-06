# @file SelfControlledCohort.R
#
# Copyright 2021 Observational Health Data Sciences and Informatics
#
# This file is part of Eumaeus
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#' @export
runSelfControlledCohort <- function(connectionDetails,
                                    cdmDatabaseSchema,
                                    oracleTempSchema = NULL,
                                    outcomeDatabaseSchema = cdmDatabaseSchema,
                                    outcomeTable = "cohort",
                                    exposureDatabaseSchema = cdmDatabaseSchema,
                                    exposureTable = "drug_era",
                                    outputFolder,
                                    cdmVersion = "5",
                                    maxCores) {
    start <- Sys.time()

    sccFolder <- file.path(outputFolder, "selfControlledCohort")
    if (!file.exists(sccFolder))
        dir.create(sccFolder)

    sccSummaryFile <- file.path(outputFolder, "sccSummary.rds")
    if (!file.exists(sccSummaryFile)) {
        allControls <- read.csv(file.path(outputFolder , "allControls.csv"))
        allControls <- unique(allControls[, c("targetId", "outcomeId")])
        eoList <- list()
        for (i in 1:nrow(allControls)) {
            eoList[[length(eoList) + 1]] <- SelfControlledCohort::createExposureOutcome(exposureId = allControls$targetId[i],
                                                                                      outcomeId = allControls$outcomeId[i])
        }
        sccAnalysisListFile <- system.file("settings", "sccAnalysisSettings.txt", package = "Eumaeus")
        sccAnalysisList <- SelfControlledCohort::loadSccAnalysisList(sccAnalysisListFile)

        sccResult <- SelfControlledCohort::runSccAnalyses(connectionDetails = connectionDetails,
                                                          cdmDatabaseSchema = cdmDatabaseSchema,
                                                          oracleTempSchema = oracleTempSchema,
                                                          exposureDatabaseSchema = exposureDatabaseSchema,
                                                          exposureTable = exposureTable,
                                                          outcomeDatabaseSchema = outcomeDatabaseSchema,
                                                          outcomeTable = outcomeTable,
                                                          sccAnalysisList = sccAnalysisList,
                                                          exposureOutcomeList = eoList,
                                                          cdmVersion = cdmVersion,
                                                          outputFolder = sccFolder,
                                                          analysisThreads = min(10, maxCores))
        sccSummary <- SelfControlledCohort::summarizeAnalyses(sccResult, sccFolder)
        saveRDS(sccSummary, sccSummaryFile)
    }
    delta <- Sys.time() - start
    ParallelLogger::logInfo("Completed SelfControlledCohort analyses in ", signif(delta, 3), " ", attr(delta, "units"))
}

#' @export
createSelfControlledCohortSettings <- function(fileName) {
    runSccArgs1 <- SelfControlledCohort::createRunSelfControlledCohortArgs(firstExposureOnly = FALSE,
                                                                           firstOutcomeOnly = TRUE,
                                                                           addLengthOfExposureExposed = TRUE,
                                                                           riskWindowStartExposed = 0,
                                                                           riskWindowEndExposed = 0,
                                                                           hasFullTimeAtRisk = FALSE,
                                                                           riskWindowEndUnexposed = -1,
                                                                           addLengthOfExposureUnexposed = TRUE,
                                                                           riskWindowStartUnexposed = -1,
                                                                           washoutPeriod = 365,
                                                                           followupPeriod = 183)

    sccAnalysis1 <- SelfControlledCohort::createSccAnalysis(analysisId = 1,
                                                            description = "Time exposed, inc. exp. start date",
                                                            runSelfControlledCohortArgs = runSccArgs1)

    runSccArgs2 <- SelfControlledCohort::createRunSelfControlledCohortArgs(firstExposureOnly = FALSE,
                                                                           firstOutcomeOnly = TRUE,
                                                                           addLengthOfExposureExposed = FALSE,
                                                                           riskWindowStartExposed = 0,
                                                                           riskWindowEndExposed = 30,
                                                                           hasFullTimeAtRisk = FALSE,
                                                                           riskWindowEndUnexposed = -1,
                                                                           addLengthOfExposureUnexposed = FALSE,
                                                                           riskWindowStartUnexposed = -30,
                                                                           washoutPeriod = 365,
                                                                           followupPeriod = 183)

    sccAnalysis2 <- SelfControlledCohort::createSccAnalysis(analysisId = 2,
                                                            description = "30 days, incl. exp. start date",
                                                            runSelfControlledCohortArgs = runSccArgs2)

    runSccArgs3 <- SelfControlledCohort::createRunSelfControlledCohortArgs(firstExposureOnly = FALSE,
                                                                           firstOutcomeOnly = TRUE,
                                                                           addLengthOfExposureExposed = TRUE,
                                                                           riskWindowStartExposed = 0,
                                                                           riskWindowEndExposed = 0,
                                                                           hasFullTimeAtRisk = TRUE,
                                                                           riskWindowEndUnexposed = -1,
                                                                           addLengthOfExposureUnexposed = TRUE,
                                                                           riskWindowStartUnexposed = -1,
                                                                           washoutPeriod = 365,
                                                                           followupPeriod = 183)

    sccAnalysis3 <- SelfControlledCohort::createSccAnalysis(analysisId = 3,
                                                            description = "Time exposed, inc. exp. start date, require full obs.",
                                                            runSelfControlledCohortArgs = runSccArgs3)


    # runSccArgs4 <- SelfControlledCohort::createRunSelfControlledCohortArgs(firstExposureOnly = FALSE,
    #                                                                        firstOutcomeOnly = TRUE,
    #                                                                        addLengthOfExposureExposed = FALSE,
    #                                                                        riskWindowStartExposed = 0,
    #                                                                        riskWindowEndExposed = 30,
    #                                                                        hasFullTimeAtRisk = TRUE,
    #                                                                        riskWindowEndUnexposed = -1,
    #                                                                        addLengthOfExposureUnexposed = FALSE,
    #                                                                        riskWindowStartUnexposed = -30,
    #                                                                        washoutPeriod = 365,
    #                                                                        followupPeriod = 183)
    #
    # sccAnalysis4 <- SelfControlledCohort::createSccAnalysis(analysisId = 4,
    #                                                         description = "30 days of each exposure, index date in exposure window, require full obs",
    #                                                         runSelfControlledCohortArgs = runSccArgs4)

    runSccArgs4 <- SelfControlledCohort::createRunSelfControlledCohortArgs(firstExposureOnly = FALSE,
                                                                           firstOutcomeOnly = TRUE,
                                                                           addLengthOfExposureExposed = TRUE,
                                                                           riskWindowStartExposed = 1,
                                                                           riskWindowEndExposed = 1,
                                                                           hasFullTimeAtRisk = FALSE,
                                                                           riskWindowEndUnexposed = -1,
                                                                           addLengthOfExposureUnexposed = TRUE,
                                                                           riskWindowStartUnexposed = -1,
                                                                           washoutPeriod = 365,
                                                                           followupPeriod = 183)

    sccAnalysis4 <- SelfControlledCohort::createSccAnalysis(analysisId = 4,
                                                            description = "Time exposed, ex. exp. start date",
                                                            runSelfControlledCohortArgs = runSccArgs4)

    runSccArgs5 <- SelfControlledCohort::createRunSelfControlledCohortArgs(firstExposureOnly = FALSE,
                                                                           firstOutcomeOnly = TRUE,
                                                                           addLengthOfExposureExposed = FALSE,
                                                                           riskWindowStartExposed = 1,
                                                                           riskWindowEndExposed = 30,
                                                                           hasFullTimeAtRisk = FALSE,
                                                                           riskWindowEndUnexposed = -1,
                                                                           addLengthOfExposureUnexposed = FALSE,
                                                                           riskWindowStartUnexposed = -30,
                                                                           washoutPeriod = 365,
                                                                           followupPeriod = 183)

    sccAnalysis5 <- SelfControlledCohort::createSccAnalysis(analysisId = 5,
                                                            description = "30 days, ex. exp. start date",
                                                            runSelfControlledCohortArgs = runSccArgs5)

    runSccArgs6 <- SelfControlledCohort::createRunSelfControlledCohortArgs(firstExposureOnly = FALSE,
                                                                           firstOutcomeOnly = TRUE,
                                                                           addLengthOfExposureExposed = TRUE,
                                                                           riskWindowStartExposed = 1,
                                                                           riskWindowEndExposed = 1,
                                                                           hasFullTimeAtRisk = TRUE,
                                                                           riskWindowEndUnexposed = -1,
                                                                           addLengthOfExposureUnexposed = TRUE,
                                                                           riskWindowStartUnexposed = -1,
                                                                           washoutPeriod = 365,
                                                                           followupPeriod = 183)

    sccAnalysis6 <- SelfControlledCohort::createSccAnalysis(analysisId = 6,
                                                            description = "Time exposed, ex. exp. start date, require full obs.",
                                                            runSelfControlledCohortArgs = runSccArgs6)


    # runSccArgs8 <- SelfControlledCohort::createRunSelfControlledCohortArgs(firstExposureOnly = FALSE,
    #                                                                        firstOutcomeOnly = TRUE,
    #                                                                        addLengthOfExposureExposed = FALSE,
    #                                                                        riskWindowStartExposed = 1,
    #                                                                        riskWindowEndExposed = 30,
    #                                                                        hasFullTimeAtRisk = TRUE,
    #                                                                        riskWindowEndUnexposed = -1,
    #                                                                        addLengthOfExposureUnexposed = FALSE,
    #                                                                        riskWindowStartUnexposed = -30,
    #                                                                        washoutPeriod = 365,
    #                                                                        followupPeriod = 183)
    #
    # sccAnalysis8 <- SelfControlledCohort::createSccAnalysis(analysisId = 8,
    #                                                         description = "30 days of each exposure, index date ignored, require full obs",
    #                                                         runSelfControlledCohortArgs = runSccArgs8)

    sccAnalysisList <- list(sccAnalysis1, sccAnalysis2, sccAnalysis3, sccAnalysis4, sccAnalysis5, sccAnalysis6)
    if (!missing(fileName) && !is.null(fileName)) {
        SelfControlledCohort::saveSccAnalysisList(sccAnalysisList, fileName)
    }
    invisible(sccAnalysisList)
}
