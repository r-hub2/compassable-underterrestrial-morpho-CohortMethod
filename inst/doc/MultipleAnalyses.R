## ----echo = FALSE, message = FALSE, warning = FALSE---------------------------
library(CohortMethod)
folder <- "e:/temp/cohortMethodVignette2"
folderExists <- dir.exists(folder)

## ----eval=FALSE---------------------------------------------------------------
# connectionDetails <- createConnectionDetails(dbms = "postgresql",
#                                              server = "localhost/ohdsi",
#                                              user = "joe",
#                                              password = "supersecret")
# 
# cdmDatabaseSchema <- "my_cdm_data"
# cohortDatabaseSchema <- "my_results"
# cohortTable <- "my_cohorts"
# options(sqlRenderTempEmulationSchema = NULL)

## ----eval=FALSE---------------------------------------------------------------
# library(Capr)
# 
# celecoxibConceptId <- 1118084
# diclofenacConceptId <- 1124300
# osteoArthritisOfKneeConceptId <- 4079750
# 
# celecoxib <- cs(
#   descendants(celecoxibConceptId),
#   name = "Celecoxib"
# )
# 
# celecoxibCohort <- cohort(
#   entry = entry(
#     drugExposure(celecoxib)
#   ),
#   exit = exit(endStrategy = drugExit(celecoxib,
#                                      persistenceWindow = 30,
#                                      surveillanceWindow = 0))
# )
# 
# diclofenac  <- cs(
#   descendants(diclofenacConceptId),
#   name = "Diclofenac"
# )
# 
# diclofenacCohort <- cohort(
#   entry = entry(
#     drugExposure(diclofenac)
#   ),
#   exit = exit(endStrategy = drugExit(diclofenac,
#                                      persistenceWindow = 30,
#                                      surveillanceWindow = 0))
# )
# 
# osteoArthritisOfKnee <- cs(
#   descendants(osteoArthritisOfKneeConceptId),
#   name = "Osteoarthritis of knee"
# )
# 
# osteoArthritisOfKneeCohort <- cohort(
#   entry = entry(
#     conditionOccurrence(osteoArthritisOfKnee, firstOccurrence())
#   ),
#   exit = exit(
#     endStrategy = observationExit()
#   )
# )
# # Note: this will automatically assign cohort IDs 1,2, and 3, respectively:
# exposuresAndIndicationCohorts <- makeCohortSet(celecoxibCohort,
#                                                diclofenacCohort,
#                                                osteoArthritisOfKneeCohort)

## ----eval=FALSE---------------------------------------------------------------
# library(PhenotypeLibrary)
# outcomeCohorts <- getPlCohortDefinitionSet(77) # GI bleed

## ----eval=FALSE---------------------------------------------------------------
# negativeControlIds <- c(29735, 140673, 197494,
#                         198185, 198199, 200528, 257315,
#                         314658, 317376, 321319, 380731,
#                         432661, 432867, 433516, 433701,
#                         433753, 435140, 435459, 435524,
#                         435783, 436665, 436676, 442619,
#                         444252, 444429, 4131756, 4134120,
#                         4134454, 4152280, 4165112, 4174262,
#                         4182210, 4270490, 4286201, 4289933)
# negativeControlCohorts <- tibble(
#   cohortId = negativeControlIds,
#   cohortName = sprintf("Negative control %d", negativeControlIds),
#   outcomeConceptId = negativeControlIds
# )

## ----eval=FALSE---------------------------------------------------------------
# library(CohortGenerator)
# allCohorts <- bind_rows(outcomeCohorts,
#                         exposuresAndIndicationCohorts)
# cohortTableNames <- getCohortTableNames(cohortTable = cohortTable)
# createCohortTables(connectionDetails = connectionDetails,
#                    cohortDatabaseSchema = cohortDatabaseSchema,
#                    cohortTableNames = cohortTableNames)
# generateCohortSet(connectionDetails = connectionDetails,
#                   cdmDatabaseSchema = cdmDatabaseSchema,
#                   cohortDatabaseSchema = cohortDatabaseSchema,
#                   cohortTableNames = cohortTableNames,
#                   cohortDefinitionSet = allCohorts)
# generateNegativeControlOutcomeCohorts(connectionDetails = connectionDetails,
#                                       cdmDatabaseSchema = cdmDatabaseSchema,
#                                       cohortDatabaseSchema = cohortDatabaseSchema,
#                                       cohortTableNames  = cohortTableNames,
#                                       negativeControlOutcomeCohortSet = negativeControlCohorts)

## ----eval=FALSE---------------------------------------------------------------
# connection <- DatabaseConnector::connect(connectionDetails)
# sql <- "SELECT cohort_definition_id, COUNT(*) AS count
# FROM @cohortDatabaseSchema.@cohortTable
# GROUP BY cohort_definition_id"
# DatabaseConnector::renderTranslateQuerySql(
#   connection = connection,
#   sql = sql,
#   cohortDatabaseSchema = cohortDatabaseSchema,
#   cohortTable = cohortTable
#   )
# DatabaseConnector::disconnect(connection)

## ----echo=FALSE,message=FALSE-------------------------------------------------
if (folderExists) {
 readRDS(file.path(folder, "cohortCounts.rds")) 
}

## ----eval=FALSE---------------------------------------------------------------
# outcomeOfInterest <- createOutcome(outcomeId = 77,
#                                    outcomeOfInterest = TRUE)
# negativeControlOutcomes <- lapply(
#   negativeControlIds,
#   function(outcomeId) createOutcome(outcomeId = outcomeId,
#                                     outcomeOfInterest = FALSE,
#                                     trueEffectSize = 1)
# )
# tcos <- createTargetComparatorOutcomes(
#   targetId = 1,
#   comparatorId = 2,
#   nestingCohortId = 3,
#   outcomes = append(list(outcomeOfInterest),
#                     negativeControlOutcomes),
#   excludedCovariateConceptIds = c(1118084, 1124300)
# )
# targetComparatorOutcomesList <- list(tcos)

## ----eval=TRUE----------------------------------------------------------------
covarSettings <- createDefaultCovariateSettings(
  addDescendantsToExclude = TRUE
)

getDbCmDataArgs <- createGetDbCohortMethodDataArgs(
  removeDuplicateSubjects = "keep first, truncate to second",
  firstExposureOnly = TRUE,
  washoutPeriod = 183,
  restrictToCommonPeriod = TRUE,
  covariateSettings = covarSettings
)

createStudyPopArgs <- createCreateStudyPopulationArgs(
  removeSubjectsWithPriorOutcome = TRUE,
  minDaysAtRisk = 1,
  riskWindowStart = 0,
  startAnchor = "cohort start",
  riskWindowEnd = 30,
  endAnchor = "cohort end"
)

fitOutcomeModelArgs1 <- createFitOutcomeModelArgs(
  modelType = "cox"
)

## ----eval=TRUE----------------------------------------------------------------
cmAnalysis1 <- createCmAnalysis(
  analysisId = 1,
  description = "No matching, simple outcome model",
  getDbCohortMethodDataArgs = getDbCmDataArgs,
  createStudyPopulationArgs = createStudyPopArgs,
  fitOutcomeModelArgs = fitOutcomeModelArgs1
)

## ----eval=TRUE----------------------------------------------------------------
createPsArgs <- createCreatePsArgs() # Use default settings only

matchOnPsArgs <- createMatchOnPsArgs(
  maxRatio = 100
)

computeSharedCovBalArgs <- createComputeCovariateBalanceArgs()

computeCovBalArgs <- createComputeCovariateBalanceArgs(
  covariateFilter = CohortMethod::getDefaultCmTable1Specifications()
)

fitOutcomeModelArgs2 <- createFitOutcomeModelArgs(
  modelType = "cox",
  stratified = TRUE
)

cmAnalysis2 <- createCmAnalysis(
  analysisId = 2,
  description = "Matching",
  getDbCohortMethodDataArgs = getDbCmDataArgs,
  createStudyPopulationArgs = createStudyPopArgs,
  createPsArgs = createPsArgs,
  matchOnPsArgs = matchOnPsArgs,
  computeSharedCovariateBalanceArgs = computeSharedCovBalArgs,
  computeCovariateBalanceArgs = computeCovBalArgs,
  fitOutcomeModelArgs = fitOutcomeModelArgs2
)

stratifyByPsArgs <- createStratifyByPsArgs(
  numberOfStrata = 10
)

cmAnalysis3 <- createCmAnalysis(
  analysisId = 3,
  description = "Stratification",
  getDbCohortMethodDataArgs = getDbCmDataArgs,
  createStudyPopulationArgs = createStudyPopArgs,
  createPsArgs = createPsArgs,
  stratifyByPsArgs = stratifyByPsArgs,
  computeSharedCovariateBalanceArgs = computeSharedCovBalArgs,
  computeCovariateBalanceArgs = computeCovBalArgs,
  fitOutcomeModelArgs = fitOutcomeModelArgs2
)

truncateIptwArgs <- createTruncateIptwArgs(
  maxWeight = 10
)

fitOutcomeModelArgs3 <- createFitOutcomeModelArgs(
  modelType = "cox",
  inversePtWeighting = TRUE,
  bootstrapCi = TRUE
)

cmAnalysis4 <- createCmAnalysis(
  analysisId = 4,
  description = "Inverse probability weighting",
  getDbCohortMethodDataArgs = getDbCmDataArgs,
  createStudyPopulationArgs = createStudyPopArgs,
  createPsArgs = createPsArgs,
  truncateIptwArgs = truncateIptwArgs,
  computeSharedCovariateBalanceArgs = computeSharedCovBalArgs,
  computeCovariateBalanceArgs = computeCovBalArgs,
  fitOutcomeModelArgs = fitOutcomeModelArgs3
)

fitOutcomeModelArgs4 <- createFitOutcomeModelArgs(
  useCovariates = TRUE,
  modelType = "cox",
  stratified = TRUE
)

cmAnalysis5 <- createCmAnalysis(
  analysisId = 5,
  description = "Matching plus full outcome model",
  getDbCohortMethodDataArgs = getDbCmDataArgs,
  createStudyPopulationArgs = createStudyPopArgs,
  createPsArgs = createPsArgs,
  matchOnPsArgs = matchOnPsArgs,
  computeSharedCovariateBalanceArgs = computeSharedCovBalArgs,
  computeCovariateBalanceArgs = computeCovBalArgs,
  fitOutcomeModelArgs = fitOutcomeModelArgs4
)

interactionCovariateIds <- c(8532001, 201826210, 21600960413) # Female, T2DM, concurent use of antithrombotic agents

fitOutcomeModelArgs5 <- createFitOutcomeModelArgs(
  modelType = "cox",
  stratified = TRUE,
  interactionCovariateIds = interactionCovariateIds
)

cmAnalysis6 <- createCmAnalysis(
  analysisId = 6,
  description = "Stratification plus interaction terms",
  getDbCohortMethodDataArgs = getDbCmDataArgs,
  createStudyPopulationArgs = createStudyPopArgs,
  createPsArgs = createPsArgs,
  stratifyByPsArgs = stratifyByPsArgs,
  computeSharedCovariateBalanceArgs = computeSharedCovBalArgs,
  computeCovariateBalanceArgs = computeCovBalArgs,
  fitOutcomeModelArgs = fitOutcomeModelArgs5
)


## ----eval=TRUE----------------------------------------------------------------
cmAnalysisList <- list(cmAnalysis1, 
                       cmAnalysis2, 
                       cmAnalysis3, 
                       cmAnalysis4, 
                       cmAnalysis5, 
                       cmAnalysis6)

## ----eval=FALSE---------------------------------------------------------------
# multiThreadingSettings <- createDefaultMultiThreadingSettings(parallel::detectCores())
# 
# result <- runCmAnalyses(
#   connectionDetails = connectionDetails,
#   cdmDatabaseSchema = cdmDatabaseSchema,
#   exposureDatabaseSchema = cohortDatabaseSchema,
#   exposureTable = cohortTable,
#   outcomeDatabaseSchema = cohortDatabaseSchema,
#   outcomeTable = cohortTable,
#   nestingCohortDatabaseSchema = cohortDatabaseSchema,
#   nestingCohortTable = cohortTable,
#   outputFolder = folder,
#   multiThreadingSettings = multiThreadingSettings,
#   cmAnalysesSpecifications = createCmAnalysesSpecifications(
#     cmAnalysisList = cmAnalysisList,
#     targetComparatorOutcomesList = targetComparatorOutcomesList
#   )
# )

## ----eval=FALSE---------------------------------------------------------------
# psFile <- result |>
#   filter(targetId == 1,
#          comparatorId == 2,
#          outcomeId == 77,
#          analysisId == 5) |>
#   pull(psFile)
# ps <- readRDS(file.path(folder, psFile))
# plotPs(ps)

## ----echo=FALSE,message=FALSE-------------------------------------------------
if (folderExists) {
  result <- readRDS(file.path(folder, "outcomeModelReference.rds"))
  psFile <- result |>
    filter(targetId == 1,
           comparatorId == 2,
           outcomeId == 77,
           analysisId == 5) |>
    pull(psFile)
  ps <- readRDS(file.path(folder, psFile))
  plotPs(ps)
}

## ----eval=FALSE---------------------------------------------------------------
# result <- getFileReference(folder)

## ----eval=FALSE---------------------------------------------------------------
# resultsSum <- getResultsSummary(folder)
# resultsSum

## ----echo=FALSE,message=FALSE-------------------------------------------------
if (folderExists) {
  resultsSum <- getResultsSummary(folder)
  resultsSum
}

## ----eval=FALSE---------------------------------------------------------------
# diagnostics <- getDiagnosticsSummary(folder)
# diagnostics

## ----echo=FALSE,message=FALSE-------------------------------------------------
if (folderExists) {
  diagnostics <- getDiagnosticsSummary(folder)
  diagnostics
}

## ----eval=FALSE---------------------------------------------------------------
# diagnostics |>
#   group_by(analysisId) |>
#   summarise(passing = sum(unblind))

## ----echo=FALSE,message=FALSE-------------------------------------------------
if (folderExists) {
  diagnostics |>
  group_by(analysisId) |>
  summarise(passing = sum(unblind))
}

## ----eval=FALSE---------------------------------------------------------------
# install.packages("EmpiricalCalibration")
# library(EmpiricalCalibration)
# 
# # Analysis 1: No matching, simple outcome model
# ncs <- resultsSum |>
#   filter(analysisId == 1,
#          outcomeId != 77)
# hoi <- resultsSum |>
#   filter(analysisId == 1,
#          outcomeId == 77)
# null <- fitNull(ncs$logRr, ncs$seLogRr)
# plotCalibrationEffect(logRrNegatives = ncs$logRr,
#                       seLogRrNegatives = ncs$seLogRr,
#                       logRrPositives = hoi$logRr,
#                       seLogRrPositives = hoi$seLogRr, null)

## ----echo=FALSE,message=FALSE,warning=FALSE,eval=TRUE-------------------------
if (folderExists) {
  library(EmpiricalCalibration)
  ncs <- resultsSum |>
    filter(analysisId == 1,
           outcomeId != 77)
  hoi <- resultsSum |>
    filter(analysisId == 1,
           outcomeId == 77)
  null <- fitNull(ncs$logRr, ncs$seLogRr)
  plotCalibrationEffect(logRrNegatives = ncs$logRr, 
                        seLogRrNegatives = ncs$seLogRr, 
                        logRrPositives = hoi$logRr, 
                        seLogRrPositives = hoi$seLogRr, null)
}

## ----eval=FALSE---------------------------------------------------------------
# # Analysis 2: Matching
# ncs <- resultsSum |>
#   filter(analysisId == 2,
#          outcomeId != 77)
# hoi <- resultsSum |>
#   filter(analysisId == 2,
#          outcomeId == 77)
# null <- fitNull(ncs$logRr, ncs$seLogRr)
# plotCalibrationEffect(logRrNegatives = ncs$logRr,
#                       seLogRrNegatives = ncs$seLogRr,
#                       logRrPositives = hoi$logRr,
#                       seLogRrPositives = hoi$seLogRr, null)

## ----echo=FALSE,message=FALSE,warning=FALSE,eval=TRUE-------------------------
if (folderExists) {
  library(EmpiricalCalibration)
  ncs <- resultsSum |>
    filter(analysisId == 2,
           outcomeId != 77)
  hoi <- resultsSum |>
    filter(analysisId == 2,
           outcomeId == 77)
  null <- fitNull(ncs$logRr, ncs$seLogRr)
  plotCalibrationEffect(logRrNegatives = ncs$logRr, 
                        seLogRrNegatives = ncs$seLogRr, 
                        logRrPositives = hoi$logRr, 
                        seLogRrPositives = hoi$seLogRr, null)
}

## ----eval=FALSE---------------------------------------------------------------
# # Analysis 3: Stratification
# ncs <- resultsSum |>
#   filter(analysisId == 3,
#          outcomeId != 77)
# hoi <- resultsSum |>
#   filter(analysisId == 3,
#          outcomeId == 77)
# null <- fitNull(ncs$logRr, ncs$seLogRr)
# plotCalibrationEffect(logRrNegatives = ncs$logRr,
#                       seLogRrNegatives = ncs$seLogRr,
#                       logRrPositives = hoi$logRr,
#                       seLogRrPositives = hoi$seLogRr, null)

## ----echo=FALSE,message=FALSE,warning=FALSE,eval=TRUE-------------------------
if (folderExists) {
  library(EmpiricalCalibration)
  ncs <- resultsSum |>
    filter(analysisId == 3,
           outcomeId != 77)
  hoi <- resultsSum |>
    filter(analysisId == 3,
           outcomeId == 77)
  null <- fitNull(ncs$logRr, ncs$seLogRr)
  plotCalibrationEffect(logRrNegatives = ncs$logRr, 
                        seLogRrNegatives = ncs$seLogRr, 
                        logRrPositives = hoi$logRr, 
                        seLogRrPositives = hoi$seLogRr, null)
}

## ----eval=FALSE---------------------------------------------------------------
# # Analysis 4: Inverse probability of treatment weighting
# ncs <- resultsSum |>
#   filter(analysisId == 4,
#          outcomeId != 77)
# hoi <- resultsSum |>
#   filter(analysisId == 4,
#          outcomeId == 77)
# null <- fitNull(ncs$logRr, ncs$seLogRr)
# plotCalibrationEffect(logRrNegatives = ncs$logRr,
#                       seLogRrNegatives = ncs$seLogRr,
#                       logRrPositives = hoi$logRr,
#                       seLogRrPositives = hoi$seLogRr, null)

## ----echo=FALSE,message=FALSE,warning=FALSE,eval=TRUE-------------------------
if (folderExists) {
  library(EmpiricalCalibration)
  ncs <- resultsSum |>
    filter(analysisId == 4,
           outcomeId != 77)
  hoi <- resultsSum |>
    filter(analysisId == 4,
           outcomeId == 77)
  null <- fitNull(ncs$logRr, ncs$seLogRr)
  plotCalibrationEffect(logRrNegatives = ncs$logRr, 
                        seLogRrNegatives = ncs$seLogRr, 
                        logRrPositives = hoi$logRr, 
                        seLogRrPositives = hoi$seLogRr, null)
}

## ----eval=FALSE---------------------------------------------------------------
# # Analysis 5: Stratification plus full outcome model
# ncs <- resultsSum |>
#   filter(analysisId == 5,
#          outcomeId != 77)
# hoi <- resultsSum |>
#   filter(analysisId == 5,
#          outcomeId == 77)
# null <- fitNull(ncs$logRr, ncs$seLogRr)
# plotCalibrationEffect(logRrNegatives = ncs$logRr,
#                       seLogRrNegatives = ncs$seLogRr,
#                       logRrPositives = hoi$logRr,
#                       seLogRrPositives = hoi$seLogRr, null)

## ----echo=FALSE,message=FALSE,warning=FALSE,eval=TRUE-------------------------
if (folderExists) {
  library(EmpiricalCalibration)
  ncs <- resultsSum |>
    filter(analysisId == 5,
           outcomeId != 77)
  hoi <- resultsSum |>
    filter(analysisId == 5,
           outcomeId == 77)
  null <- fitNull(ncs$logRr, ncs$seLogRr)
  plotCalibrationEffect(logRrNegatives = ncs$logRr, 
                        seLogRrNegatives = ncs$seLogRr, 
                        logRrPositives = hoi$logRr, 
                        seLogRrPositives = hoi$seLogRr, null)
}

## ----eval=FALSE---------------------------------------------------------------
# interactionResultsSum <- getInteractionResultsSummary(folder)
# 
# # Analysis 6: Stratification plus interaction terms
# ncs <- interactionResultsSum |>
#   filter(analysisId == 6,
#          interactionCovariateId == 21600960413,
#          outcomeId != 77)
# hoi <- interactionResultsSum |>
#   filter(analysisId == 6,
#          interactionCovariateId == 21600960413,
#          outcomeId == 77)
# null <- fitNull(ncs$logRr, ncs$seLogRr)
# plotCalibrationEffect(logRrNegatives = ncs$logRr,
#                       seLogRrNegatives = ncs$seLogRr,
#                       logRrPositives = hoi$logRr,
#                       seLogRrPositives = hoi$seLogRr, null)

## ----echo=FALSE,message=FALSE,eval=TRUE---------------------------------------
if (folderExists) {
  interactionResultsSum <- getInteractionResultsSummary(folder)
  ncs <- interactionResultsSum |>
    filter(analysisId == 6,
           interactionCovariateId == 21600960413,
           outcomeId != 77)
  hoi <- interactionResultsSum |>
    filter(analysisId == 6,
           interactionCovariateId == 21600960413,
           outcomeId == 77)
  null <- fitNull(ncs$logRr, ncs$seLogRr)
  plotCalibrationEffect(logRrNegatives = ncs$logRr, 
                        seLogRrNegatives = ncs$seLogRr, 
                        logRrPositives = hoi$logRr, 
                        seLogRrPositives = hoi$seLogRr, null)
}

## ----eval=FALSE---------------------------------------------------------------
# exportToCsv(
#   folder,
#   exportFolder = file.path(folder, "export"),
#   databaseId = "My CDM",
#   minCellCount = 5,
#   maxCores = parallel::detectCores()
# )

## -----------------------------------------------------------------------------
getResultsDataModelSpecifications()

## ----eval=TRUE----------------------------------------------------------------
citation("CohortMethod")

## ----eval=TRUE----------------------------------------------------------------
citation("Cyclops")

