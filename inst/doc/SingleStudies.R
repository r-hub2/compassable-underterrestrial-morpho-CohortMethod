## ----echo = FALSE, message = FALSE, warning = FALSE---------------------------------------------------------------------------------------------------------------------------------------------------
options(width = 200)
library(CohortMethod)
outputFolder <- "e:/temp/cohortMethodVignette"
folderExists <- dir.exists(outputFolder)

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# library(CohortMethod)
# connectionDetails <- createConnectionDetails(dbms = "postgresql",
#                                              server = "localhost/ohdsi",
#                                              user = "joe",
#                                              password = "supersecret")
# 
# cdmDatabaseSchema <- "my_cdm_data"
# cohortDatabaseSchema <- "my_results"
# cohortTable <- "my_cohorts"
# options(sqlRenderTempEmulationSchema = NULL)

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# library(PhenotypeLibrary)
# outcomeCohorts <- getPlCohortDefinitionSet(77) # GI bleed

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# allCohorts <- bind_rows(outcomeCohorts,
#                         exposuresAndIndicationCohorts)
# 
# library(CohortGenerator)
# cohortTableNames <- getCohortTableNames(cohortTable = cohortTable)
# createCohortTables(connectionDetails = connectionDetails,
#                    cohortDatabaseSchema = cohortDatabaseSchema,
#                    cohortTableNames = cohortTableNames)
# generateCohortSet(connectionDetails = connectionDetails,
#                   cdmDatabaseSchema = cdmDatabaseSchema,
#                   cohortDatabaseSchema = cohortDatabaseSchema,
#                   cohortTableNames = cohortTableNames,
#                   cohortDefinitionSet = allCohorts)

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# connection <- DatabaseConnector::connect(connectionDetails)
# sql <- "SELECT cohort_definition_id, COUNT(*) AS count
# FROM @cohortDatabaseSchema.@cohortTable
# GROUP BY cohort_definition_id"
# cohortCounts <- DatabaseConnector::renderTranslateQuerySql(
#   connection = connection,
#   sql = sql,
#   cohortDatabaseSchema = cohortDatabaseSchema,
#   cohortTable = cohortTable
#   )
# DatabaseConnector::disconnect(connection)

## ----echo=FALSE,message=FALSE-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
data.frame(cohort_concept_id = c(1, 2, 3, 77),count = c(917230, 1791695, 993116, 1123643))

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# # Define which types of covariates must be constructed:
# covSettings <- createDefaultCovariateSettings(
#   excludedCovariateConceptIds = c(diclofenacConceptId, celecoxibConceptId),
#   addDescendantsToExclude = TRUE
# )
# 
# #Load data:
# cohortMethodData <- getDbCohortMethodData(
#   connectionDetails = connectionDetails,
#   cdmDatabaseSchema = cdmDatabaseSchema,
#   targetId = 1,
#   comparatorId = 2,
#   outcomeIds = 77,
#   exposureDatabaseSchema = cohortDatabaseSchema,
#   exposureTable = cohortTable,
#   outcomeDatabaseSchema = cohortDatabaseSchema,
#   outcomeTable = cohortTable,
#   nestingCohortDatabaseSchema = cohortDatabaseSchema,
#   nestingCohortTable = cohortTable,
#   getDbCohortMethodDataArgs = createGetDbCohortMethodDataArgs(
#     removeDuplicateSubjects = "keep first, truncate to second",
#     firstExposureOnly = TRUE,
#     washoutPeriod = 365,
#     restrictToCommonPeriod = TRUE,
#     nestingCohortId = 3,
#     covariateSettings = covSettings
#   )
# )
# cohortMethodData

## ----echo=FALSE,message=FALSE,eval=TRUE---------------------------------------------------------------------------------------------------------------------------------------------------------------
if (folderExists) {
  cohortMethodData <- loadCohortMethodData(file.path(outputFolder, "cohortMethodData.zip"))
}

## ----echo=FALSE,message=FALSE-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if (folderExists) {
  cohortMethodData
}

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# getAttritionTable(cohortMethodData)

## ----echo=FALSE,message=FALSE-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if (folderExists) {
  table <- getAttritionTable(cohortMethodData)
  truncLeft <- function(x, n){
    nc <- nchar(x)
    x[nc > (n - 3)] <- paste(substr(table$description[nc > (n - 3)], 1, n - 3), '...')
    x
  }
  table$description <- truncLeft(table$description,30)
  table
}

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# summary(cohortMethodData)

## ----echo=FALSE,message=FALSE-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if (folderExists) {
  summary(cohortMethodData)
}

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# saveCohortMethodData(cohortMethodData, "coxibVsNonselVsGiBleed.zip")

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# studyPop <- createStudyPopulation(
#   cohortMethodData = cohortMethodData,
#   outcomeId = 77,
#   createStudyPopulationArgs = createCreateStudyPopulationArgs(
#     removeSubjectsWithPriorOutcome = TRUE,
#     priorOutcomeLookback = 365,
#     minDaysAtRisk = 1,
#     riskWindowStart = 0,
#     startAnchor = "cohort start",
#     riskWindowEnd = 30,
#     endAnchor = "cohort end"
#   )
# )

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# getAttritionTable(studyPop)

## ----echo=FALSE,message=FALSE-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if (folderExists) {
  studyPop <- readRDS(file.path(outputFolder, "studyPop.rds"))
  table <- getAttritionTable(studyPop)
  truncLeft <- function(x, n){
    nc <- nchar(x)
    x[nc > (n - 3)] <- paste(substr(table$description[nc > (n - 3)], 1, n - 3), '...')
    x
  }
  table$description <- truncLeft(table$description,30)
  table
}

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ps <- createPs(cohortMethodData = cohortMethodData, population = studyPop)

## ----echo=FALSE,message=FALSE,eval=TRUE---------------------------------------------------------------------------------------------------------------------------------------------------------------
if (folderExists) {
  ps <- readRDS(file.path(outputFolder, "ps.rds"))
}

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# computePsAuc(ps)

## ----echo=FALSE,message=FALSE,eval=TRUE---------------------------------------------------------------------------------------------------------------------------------------------------------------
if (folderExists) {
  readRDS(file.path(outputFolder, "auc.rds"))
}

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# plotPs(ps,
#        targetLabel = "Celexocib",
#        comparatorLabel = "Diclofenac",
#        showCountsLabel = TRUE,
#        showAucLabel = TRUE,
#        showEquipoiseLabel = TRUE)

## ----echo=FALSE,message=FALSE,warning=FALSE,eval=TRUE-------------------------------------------------------------------------------------------------------------------------------------------------
if (folderExists) {
plotPs(ps,
       targetLabel = "Celexocib",
       comparatorLabel = "Diclofenac",
       showCountsLabel = TRUE,
       showAucLabel = TRUE,
       showEquipoiseLabel = TRUE)
}

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# getPsModel(ps, cohortMethodData)

## ----echo=FALSE,message=FALSE-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if (folderExists) {
  propensityModel <- getPsModel(ps, cohortMethodData)
  truncRight <- function(x, n){
    nc <- nchar(x)
    x[nc > (n - 3)] <- paste('...',substr(x[nc > (n - 3)], nc[nc > (n - 3)] - n + 1, nc[nc > (n - 3)]),sep = "")
    x
  }
  propensityModel$covariateName <- truncRight(as.character(propensityModel$covariateName), 40)
  head(propensityModel)
}

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# CohortMethod::computeEquipoise(ps)

## ----echo=FALSE,message=FALSE-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if (folderExists) {
  CohortMethod::computeEquipoise(ps)
}

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# trimmedPop <- trimByPs(ps,
#                        trimByPsArgs = createTrimByPsArgs(
#                          equipoiseBounds = c(0.3, 0.7)
#                        ))
# # Note: we need to also provide the original PS object so the preference score
# # is computed using the original relative sizes of the cohorts:
# plotPs(trimmedPop, ps)

## ----echo=FALSE,message=FALSE,eval=TRUE---------------------------------------------------------------------------------------------------------------------------------------------------------------
if (folderExists) {
  trimmedPop <- trimByPs(ps,
                         trimByPsArgs = createTrimByPsArgs(
                           equipoiseBounds = c(0.3, 0.7)
                         ))
  plotPs(trimmedPop, ps)
}

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# stratifiedPop <- stratifyByPs(ps,
#                               stratifyByPsArgs = createStratifyByPsArgs(
#                                 numberOfStrata = 5
#                               ))
# plotPs(stratifiedPop)

## ----echo=FALSE,message=FALSE,eval=TRUE---------------------------------------------------------------------------------------------------------------------------------------------------------------
if (folderExists) {
  stratifiedPop <- stratifyByPs(ps, 
                                stratifyByPsArgs = createStratifyByPsArgs(
                                  numberOfStrata = 5
                                ))
  plotPs(stratifiedPop)
}

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# matchedPop <- matchOnPs(ps,
#                         matchOnPsArgs = createMatchOnPsArgs(
#                           maxRatio = 1
#                         ))
# plotPs(matchedPop, ps)

## ----echo=FALSE,message=FALSE,eval=TRUE---------------------------------------------------------------------------------------------------------------------------------------------------------------
if (folderExists) {
  matchedPop <- matchOnPs(ps,
                          matchOnPsArgs = createMatchOnPsArgs(
                            maxRatio = 1
                          ))
  plotPs(matchedPop, ps)
}

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# getAttritionTable(matchedPop)

## ----echo=FALSE,message=FALSE-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if (folderExists) {
  getAttritionTable(matchedPop)
  table <- getAttritionTable(matchedPop)
  truncLeft <- function(x, n){
    nc <- nchar(x)
    x[nc > (n - 3)] <- paste(substr(table$description[nc > (n - 3)], 1, n - 3), '...')
    x
  }
  table$description <- truncLeft(table$description,30)
  table
}

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# drawAttritionDiagram(matchedPop)

## ----echo=FALSE,message=FALSE,eval=TRUE,fig.width=6,fig.height=8.5,out.width="60%"--------------------------------------------------------------------------------------------------------------------
if (folderExists) {
  drawAttritionDiagram(matchedPop)
}

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# balance <- computeCovariateBalance(matchedPop, cohortMethodData)

## ----echo=FALSE,message=FALSE,eval=TRUE---------------------------------------------------------------------------------------------------------------------------------------------------------------
if (folderExists) {
  balance <- readRDS(file.path(outputFolder, "balance.rds"))
}

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# plotCovariateBalanceScatterPlot(balance,
#                                 showCovariateCountLabel = TRUE,
#                                 showMaxLabel = TRUE)

## ----echo=FALSE,message=FALSE,warnings=FALSE,eval=TRUE,fig.width=7,fig.height=4.5---------------------------------------------------------------------------------------------------------------------
if (folderExists) {
  plotCovariateBalanceScatterPlot(balance, 
                                  showCovariateCountLabel = TRUE, 
                                  showMaxLabel = TRUE)
}

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# plotCovariateBalanceOfTopVariables(balance)

## ----echo=FALSE,message=FALSE,warning=FALSE,eval=TRUE,fig.width=8,fig.height=5------------------------------------------------------------------------------------------------------------------------
if (folderExists) {
  plotCovariateBalanceOfTopVariables(balance)
}

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# createCmTable1(balance)

## ----comment=NA,echo=FALSE,message=FALSE--------------------------------------------------------------------------------------------------------------------------------------------------------------
if (folderExists) {
  table1 <- createCmTable1(balance)
  print(table1, row.names = FALSE, right = FALSE)
}

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# getGeneralizabilityTable(balance)

## ----comment=NA,echo=FALSE,message=FALSE--------------------------------------------------------------------------------------------------------------------------------------------------------------
if (folderExists) {
  table <- getGeneralizabilityTable(balance)
  truncRight <- function(x, n){
    nc <- nchar(x)
    x[nc > (n - 3)] <- paste('...',substr(x[nc > (n - 3)], nc[nc > (n - 3)] - n + 1, nc[nc > (n - 3)]),sep = "")
    x
  }
  table$covariateName <- truncRight(table$covariateName, 30)
  table
}

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# computeMdrr(
#   population = studyPop,
#   modelType = "cox",
#   alpha = 0.05,
#   power = 0.8,
#   twoSided = TRUE
# )

## ----echo=FALSE,message=FALSE,eval=TRUE---------------------------------------------------------------------------------------------------------------------------------------------------------------
if (folderExists) {
computeMdrr(population = studyPop,
            modelType = "cox",
            alpha = 0.05,
            power = 0.8,
            twoSided = TRUE)
}

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# computeMdrr(
#   population = matchedPop,
#   modelType = "cox",
#   alpha = 0.05,
#   power = 0.8,
#   twoSided = TRUE
# )

## ----echo=FALSE,message=FALSE,eval=TRUE---------------------------------------------------------------------------------------------------------------------------------------------------------------
if (folderExists) {
computeMdrr(population = matchedPop,
            modelType = "cox",
            alpha = 0.05,
            power = 0.8,
            twoSided = TRUE)
}

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# getFollowUpDistribution(population = matchedPop)

## ----echo=FALSE,message=FALSE,eval=TRUE---------------------------------------------------------------------------------------------------------------------------------------------------------------
if (folderExists) {
getFollowUpDistribution(population = matchedPop)
}

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# plotFollowUpDistribution(population = matchedPop)

## ----echo=FALSE,message=FALSE,eval=TRUE,fig.width=8,fig.height=5--------------------------------------------------------------------------------------------------------------------------------------
if (folderExists) {
plotFollowUpDistribution(population = matchedPop)
}

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# outcomeModel <- fitOutcomeModel(
#   population = studyPop,
#   fitOutcomeModelArgs = createFitOutcomeModelArgs(
#     modelType = "cox"
#   )
# )
# outcomeModel

## ----echo=FALSE,message=FALSE,eval=TRUE---------------------------------------------------------------------------------------------------------------------------------------------------------------
if (folderExists) {
  outcomeModel <- readRDS(file.path(outputFolder, "OutcomeModel1.rds"))
  outcomeModel
}

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# outcomeModel <- fitOutcomeModel(
#   population = matchedPop,
#   fitOutcomeModelArgs = createFitOutcomeModelArgs(
#     modelType = "cox"
#   )
# )
# outcomeModel

## ----echo=FALSE,message=FALSE,eval=TRUE---------------------------------------------------------------------------------------------------------------------------------------------------------------
if (folderExists) {
  outcomeModel <- readRDS(file.path(outputFolder, "OutcomeModel2.rds"))
  outcomeModel
}

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# outcomeModel <- fitOutcomeModel(
#   population = ps,
#   fitOutcomeModelArgs = createFitOutcomeModelArgs(
#     modelType = "cox",
#     inversePtWeighting = TRUE,
#     bootstrapCi = TRUE
#   )
# )
# outcomeModel

## ----echo=FALSE,message=FALSE,eval=TRUE---------------------------------------------------------------------------------------------------------------------------------------------------------------
if (folderExists) {
  outcomeModel <- readRDS(file.path(outputFolder, "OutcomeModel3.rds"))
  outcomeModel
}

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# interactionCovariateIds <- c(8532001, 201826210, 21600960413)
# # 8532001 = Female
# # 201826210 = Type 2 Diabetes
# # 21600960413 = Concurent use of antithrombotic agents
# outcomeModel <- fitOutcomeModel(
#   population = matchedPop,
#   cohortMethodData = cohortMethodData,
#   fitOutcomeModelArgs = createFitOutcomeModelArgs(
#     modelType = "cox",
#     interactionCovariateIds = interactionCovariateIds
#   )
# )
# outcomeModel

## ----echo=FALSE,message=FALSE,eval=TRUE---------------------------------------------------------------------------------------------------------------------------------------------------------------
if (folderExists) {
  outcomeModel <- readRDS(file.path(outputFolder, "OutcomeModel4.rds"))
  outcomeModel
}

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# balanceFemale <- computeCovariateBalance(
#   population,
#   cohortMethodData,
#   computeCovariateBalanceArgs = createComputeCovariateBalanceArgs(
#     subgroupCovariateId = 8532001
#   )
# )
# plotCovariateBalanceScatterPlot(balanceFemale)

## ----echo=FALSE,message=FALSE,warning=FALSE,eval=TRUE,fig.width=8,fig.height=5------------------------------------------------------------------------------------------------------------------------
if (folderExists) {
  balanceFemale <- readRDS(file.path(outputFolder, "balanceFemale.rds"))
  plotCovariateBalanceScatterPlot(balanceFemale)
}

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# outcomeModel <- fitOutcomeModel(
#   population = matchedPop,
#   cohortMethodData = cohortMethodData,
#   fitOutcomeModelArgs = createFitOutcomeModelArgs(
#     modelType = "cox",
#     useCovariates = TRUE,
#   )
# )
# outcomeModel

## ----echo=FALSE,message=FALSE,eval=TRUE---------------------------------------------------------------------------------------------------------------------------------------------------------------
if (folderExists) {
  outcomeModel <- readRDS(file.path(outputFolder, "OutcomeModel5.rds"))
  outcomeModel
}

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# exp(coef(outcomeModel))

## ----echo=FALSE,message=FALSE,eval=TRUE---------------------------------------------------------------------------------------------------------------------------------------------------------------
if (folderExists) {
  exp(coef(outcomeModel))
}

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# exp(confint(outcomeModel))

## ----echo=FALSE,message=FALSE,eval=TRUE---------------------------------------------------------------------------------------------------------------------------------------------------------------
if (folderExists) {
  exp(confint(outcomeModel))
}

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# getOutcomeModel(outcomeModel, cohortMethodData)

## ----echo=FALSE,message=FALSE-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if (folderExists) {
  outcomeModel <- getOutcomeModel(outcomeModel, cohortMethodData)
  truncRight <- function(x, n){
    nc <- nchar(x)
    x[nc > (n - 3)] <- paste('...',substr(x[nc > (n - 3)], nc[nc > (n - 3)] - n + 1, nc[nc > (n - 3)]),sep = "")
    x
  }
  outcomeModel$name <- truncRight(as.character(outcomeModel$name), 40)
  outcomeModel
}

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# plotKaplanMeier(matchedPop, includeZero = FALSE)

## ----echo=FALSE, message=FALSE, results='hide'--------------------------------------------------------------------------------------------------------------------------------------------------------
if (folderExists) {
  plotKaplanMeier(matchedPop, includeZero = FALSE)
}

## ----eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# plotTimeToEvent(
#   cohortMethodData = cohortMethodData,
#   outcomeId = 77,
#   minDaysAtRisk = 1,
#   riskWindowStart = 0,
#   startAnchor = "cohort start",
#   riskWindowEnd = 30,
#   endAnchor = "cohort end"
# )

## ----echo=FALSE, message=FALSE, results='hide'--------------------------------------------------------------------------------------------------------------------------------------------------------
if (folderExists) {
  plotTimeToEvent(
    cohortMethodData = cohortMethodData,
    outcomeId = 77,
    minDaysAtRisk = 1,
    riskWindowStart = 0,
    startAnchor = "cohort start",
    riskWindowEnd = 30,
    endAnchor = "cohort end"
  )
  
}

## ----eval=TRUE----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
citation("CohortMethod")

## ----eval=TRUE----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
citation("Cyclops")

