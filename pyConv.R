library(shiny)
library(DT)
library(RColorBrewer)
library(reticulate)

reticulate::py_install("pandas")
reticulate::source_python("data_cleaning.py")

materialSampleType <- function(data, column, check, replace) 
{
  # data = dataframe
  # column = selected column from dataframe
  # check = values already in data frame, vector created to check for these values
  # replace = what the values from the check vector are to be replaced with
  for(i in 1:length(check)) # i is incremented by 1, it starts at one and goes through how ever many values are in check
  {
    data[,column][data[,column] == check[i]] <- replace[i]
  }
  return(data)
}

mst_dict = read_csv("MST_dict.csv")

df <- open_df("https://raw.githubusercontent.com/futres/fovt-data-mapping/master/Scripts/pythonConversion/1987to2019_Cougar_Weight_Length_Public_Request.csv")
df <- remove_rcna(df)
df <- yc(df)
df <- verLocal_oneCol(df,c("Management Unit"))
arr <- c("Management Unit", "County")
print(arr[1])
print(arr)
paste(cat(colcheck(df)))


