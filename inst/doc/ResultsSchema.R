## ----setup, include=FALSE-----------------------------------------------------
library(dplyr)
library(knitr)

## ----echo=FALSE, results="asis", warning=FALSE, message=FALSE-----------------
specifications <- readr::read_csv(system.file(
  "csv",
  "resultsDataModelSpecification.csv",
  package = "CohortMethod"
)) |>
  SqlRender::snakeCaseToCamelCaseNames()
tables <- split(specifications, specifications$tableName)

table <- tables[[1]]
for (table in tables) {
  header <- sprintf("## Table %s", table$tableName[1])

  table <- table |>
    select(Field = "columnName", Type = "dataType", Key = "primaryKey", "Min. count" = "minCellCount", Deprecated = deprecated, Description = "description") |>
    kable(format = "simple", linesep = "", booktabs = TRUE, longtable = TRUE)

  writeLines("")
  writeLines(header)
  writeLines(table)
}

