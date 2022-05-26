library(shiny)
library(DT)
library(RColorBrewer)
library(reticulate)

reticulate::py_install("pandas")
reticulate::source_python("data_cleaning.py")
