# RShinyFuTRES
<h2>Data Manipulation Python Conversions</h2>

Conversions of the perviouly made RShiny app used to convert tabular data with some newly added functions. 

**If you have any problems while running this program(come across bugs or the program fails to work with your dataset) or have any questions please feel free to email futres.team@gmail.com with your concerns.**

Starting off, data sets tend to look like this:

```
            Date Management Unit     County Sex  Age Status  Weight  Length  Unnamed: 8  Unnamed: 9  Unnamed: 10
0        5/19/87        Mt Emily   Umatilla   F    4      A   105.0    75.0         NaN         NaN          NaN
1        8/12/87          Chetco      Curry   F    5      A    64.0     NaN         NaN         NaN          NaN
2        9/21/87         Santiam  Clackamas   M    2      A   116.0    76.0         NaN         NaN          NaN
3        9/28/87          Chetco      Curry   F    3      A    74.0    70.0         NaN         NaN          NaN
4        10/4/87        McKenzie       Lane   F    2      A    76.0    73.0         NaN         NaN          NaN
...          ...             ...        ...  ..  ...    ...     ...     ...         ...         ...          ...
7836   11/7/2019         Starkey      Union   F    0      A    25.0     NaN         NaN         NaN          NaN
7837   11/7/2019         Starkey      Union   M    0      A    28.0     NaN         NaN         NaN          NaN
7838   11/7/2019         Starkey      Union   M    0      A    28.0     NaN         NaN         NaN          NaN
7839  11/30/2019         Siuslaw       Lane   M    0      A    37.0    52.0         NaN         NaN          NaN
7840  11/30/2019         Siuslaw       Lane   M    0      A    43.0    58.0         NaN         NaN          NaN

```
However, with a couple of conversions, it can be transformed into something like this

```
            Date     Sex  Age materialSampleType       Weight  Length    verbatimLocality yearCollected
0     1987-05-19  female    4     whole organism  47627.19885  1905.0  Mt Emily, Umatilla          1987
1     1987-08-12  female    5     whole organism  29029.91168     NaN       Chetco, Curry          1987
2     1987-09-21    male    2     whole organism  52616.71492  1930.4  Santiam, Clackamas          1987
3     1987-09-28  female    3     whole organism  33565.83538  1778.0       Chetco, Curry          1987
4     1987-10-04  female    2     whole organism  34473.02012  1854.2      McKenzie, Lane          1987
...          ...     ...  ...                ...          ...     ...                 ...           ...
7836  2019-11-07  female    0     whole organism  11339.80925     NaN      Starkey, Union          2019
7837  2019-11-07    male    0     whole organism  12700.58636     NaN      Starkey, Union          2019
7838  2019-11-07    male    0     whole organism  12700.58636     NaN      Starkey, Union          2019
7839  2019-11-30    male    0     whole organism  16782.91769  1320.8       Siuslaw, Lane          2019
7840  2019-11-30    male    0     whole organism  19504.47191  1473.2       Siuslaw, Lane          2019

```
The functions offered by this program are limited at this time. However, datasets can still be cleaned and transformed 
using various functions found in the program.

To achive best results it is asked that all eventDates are set to a "year, month, day" format. To do this, follow these steps:

      1) Open up data in excel
      2) Select the column heading in which your date values are listed 
      3) Right click and select "Format Cells"
      4) Go to the "eventDate" category
      5) Select the "year-month-day" format and click "OK"

-----------------------------------------------------------------------------------------------------------------------

<h3>Functions</h3>

```
matSampType()
```
Function presented above allows for the transformation from vague descriptions like A, B, and C to descriptors that 
give more insight onto the dataset. 

Once you have finished using this program please send a pull request for the updated matSampType dictionary file.

```
sex()
```
The sex functions also provides for more description within datasets. It takes values like "F" and "M" and changes them 
into "female" and "male". This function also checks for values that it does not recognize and changes them into 
"not collected".

```
colcheck(df)
```
This function goes through all of the column names in the user inserted dataframe and figures out which column names do not match the FuTRES template and which of the required column names are missing.

```
verLocal(df)
```
The verbaitm locality function combines the existing columns which holds data regarding the location of the data into one column.

```
yc(df)
```
The year collected function extracts information from the *modified* date column in order to only present the year in which the data was collected.

```
countryValidity(df)
```
If your dataframe has a "country" column this function will make sure that all of the countries listed on there are GENOME recognized.

```
add_ms_and_evID(df)
```
This function creates a unique materialSampleID for the dataframe.

```
dataMelt(df)
```
The dataMelt function combines the quantitative measurements(like weight and length) into one column. This reduces size of the data frame and makes it cleaner.

-----------------------------------------------------------------------------------------------------------------------

<h3>Unit Converstion Function: Allow for a universally understood format which increases accessibility of the data.</h3>

<h5>If you have a mix of measurement units for a type of measurement (e.g., weight in grams and pounds), please standardize before proceeding.</h5>

<h4>Users will be asked what units their weights and lengths are in the unedited version of their data.</h4>

```
inConv(df)
```
Function changes values presented in the length column with the inch unit to millimeters (1 inch = 1.54 millimeters).

```
cmConv(df)
```
Changes values centimeter values in the length column to millimeters. 
```
mConv(df)
```
If values in the length column are in meters this function will change them to millimeters.

```
lbsConv(df)
```
Measurements in the weight column which are initially in pounds are changed to grams (1 pound = 453.59237 grams).
```
kgConv(df)
```
Kilogram to gram conversion for the weight column.
```
mgConv(df)
```
Conversion of milligrams to grams for the weight column. 

-----------------------------------------------------------------------------------------------------------------------
<h3>After function application....</h3>
Once users are done applying all of their desired functions they can proceed to download the cleaned version of their original dataframe onto their local drive.
