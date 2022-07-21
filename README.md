# RShinyFuTRES
<h2>Data Manipulation Python Conversions</h2>

An <a href="https://futres.shinyapps.io/pyConvApp/">RShiny app</a> used to convert tabular data into a format for ingest into <a href="https://geome-db.org/about">GEOME</a> for the <a href="https://futres-data-interface.netlify.app/">FuTRES datastore</a>. Please see the FuTRES <a href="https://futres.org/data_tutorial/">data tutorial</a> for more instructions on how to upload data to be made available through our API. FuTRES requires specific <a href="https://github.com/futres/template/blob/master/template.csv">column names</a> and requires one record (e.g., measurement per specimen) per row. This app helps standardize column names and values, as well as converts short format (one specimen per row) into long format (one measurement per row). We also automatically generate all the IDs (diagnosticID, materialSampleID, individualID, and eventID) required for the dataset that FuTRES uses to help reason across the ontology. See <a href="https://futres.org/how_it_works/">How it Works</a> on the FuTRES website for more information.

If you have any problems while running this program or have any questions please feel free to email futres.team@gmail.com with your concerns.

We currently do not match measurement terms to our list of trait terms. Please go to GEOME to see the term list (info <a href="https://futres.org/data_tutorial/#Generating%20a%20template">here</a>. This will be available in version 2.0.0.

We also currently do not create a materialSampleID, which is a combination of individualID + bone. This will also be available in version 2.0.0.

**Make sure you have conda installed:** <br>
*<a href="https://docs.conda.io/projects/conda/en/latest/user-guide/install/macos.html">MAC</a>*<br>
*<a href="https://docs.conda.io/projects/conda/en/latest/user-guide/install/windows.html">Windows</a>*<br>
*<a href="https://docs.conda.io/projects/conda/en/latest/user-guide/install/linux.html">Linux</a>*<br>

All dependencies needed will automatically be installed.

We accept datasets that are in short format, with each row being a specimen, and possibly internal abbreviations for data fields:

```
CatalogNo.  Date  Management Unit     County Sex  Age Status  Weight  Length 
0        5/19/87        Mt Emily   Umatilla   F    4      A   105.0    75.0 
1        8/12/87          Chetco      Curry   F    5      A    64.0     NaN 
2        9/21/87         Santiam  Clackamas   M    2      A   116.0    76.0 
3        9/28/87          Chetco      Curry   F    3      A    74.0    70.0 
4        10/4/87        McKenzie       Lane   F    2      A    76.0    73.0 
...          ...             ...        ...  ..  ...    ...     ...     ...  
7836   11/7/2019         Starkey      Union   F    0      A    25.0     NaN  
7837   11/7/2019         Starkey      Union   M    0      A    28.0     NaN  
7838   11/7/2019         Starkey      Union   M    0      A    28.0     NaN  
7839  11/30/2019         Siuslaw       Lane   M    0      A    37.0    52.0  
7840  11/30/2019         Siuslaw       Lane   M    0      A    43.0    58.0  

```
However, with a couple of functions, it can be transformed into long format, where each row is a measurement, and specimens are connected through the field individualID:

```
CatalogNo.  Date     Sex  Age materialSampleType measurementValue  measurementType  measurementUnit       verbatimLocality yearCollected
0     1987-05-19  female    4     whole organism      47627.19885        body mass               g     Mt Emily, Umatilla          1987
0     1987-05-19  female    4     whole organism           1905.0      body length              mm     Mt Emily, Umatilla          1987
1     1987-08-12  female    5     whole organism      29029.91168        body mass               g          Chetco, Curry          1987
1     1987-08-12  female    5     whole organism              NaN      body length              mm          Chetco, Curry          1987
2     1987-09-21    male    2     whole organism      52616.71492        body mass               g     Santiam, Clackamas          1987
2     1987-09-21    male    2     whole organism           1930.4      body length              mm     Santiam, Clackamas          1987
3     1987-09-28  female    3     whole organism      33565.83538        body mass               g          Chetco, Curry          1987
3     1987-09-28  female    3     whole organism           1778.0      body length              mm          Chetco, Curry          1987
4     1987-10-04  female    2     whole organism      34473.02012        body mass               g          McKenzie, Lane         1987
4     1987-10-04  female    2     whole organism           1854.2      body length              mm          McKenzie, Lane         1987
...          ...     ...  ...                ...          ...     ...                 ...           ...
7836  2019-11-07  female    0     whole organism      11339.80925        body mass                g         Starkey, Union         2019
7836  2019-11-07  female    0     whole organism              NaN      body length               mm         Starkey, Union         2019
7837  2019-11-07    male    0     whole organism      12700.58636        body mass                g         Starkey, Union         2019
7837  2019-11-07    male    0     whole organism              NaN      body length               mm         Starkey, Union         2019
7838  2019-11-07    male    0     whole organism      12700.58636        body mass                g         Starkey, Union         2019
7838  2019-11-07    male    0     whole organism              NaN      body length               mm         Starkey, Union         2019
7839  2019-11-30    male    0     whole organism      16782.91769        body mass                g          Siuslaw, Lane         2019
7839  2019-11-30    male    0     whole organism           1320.8      body length               mm          Siuslaw, Lane         2019
7840  2019-11-30    male    0     whole organism      19504.47191        body mass                g          Siuslaw, Lane         2019
7840  2019-11-30    male    0     whole organism           1473.2      body length               mm          Siuslaw, Lane         2019

```
The functions offered by this program are limited at this time. However, datasets can still be cleaned and transformed 
using various functions found in the program.

-----------------------------------------------------------------------------------------------------------------------
<h3>Dataset</h3>
            
To achive best results, please set eventDate to a "YYYY-MM-DD" (format. To do this in excel, follow these steps:

      1) Select the column heading in which your date values are listed 
      2) Right click and select "Format Cells"
      3) Go to the "eventDate" category
      4) Select the "year-month-day" format and click "OK"
            
 If you have a mix of measurement units for a type of measurement (e.g., mass in both grams and pounds), please standardize before proceeding.

-----------------------------------------------------------------------------------------------------------------------

<h3>Functions</h3>

```
matSampType()
```
The materialSampleType function is to standardize descriptions of the completeness of a materialSample (i.e., specimen). For example, replacing internal coding of specimen condition (e.g., sk = skinned; gut = gutted; etc.) with a controlled vocabulary: Whole organism, Part organism - whole element, Part organism - part element.

```
sex()
```
The sex function helps standardize sex terms to a controlled vocabulary accepted by GEOME. For example, it takes values like "F" and "M" and changes them 
into "female" and "male". This function also checks for values that it does not recognize and changes them into "not collected".

```
colcheck()
```
This function goes through all of the column names in the user inserted dataframe and figures out which column names do not match the <a href="https://github.com/futres/template/blob/master/template.csv">FuTRES template</a> and which of the required column names are missing.

```
verLocal()
```
The verbaitm locality function combines the existing columns which holds data regarding the location of the data into one column to retain original site identification.

```
yc()
```
The year collected function extracts information from the *modified* date column in order to only present the year in which the data was collected.

```
countryValidity()
```
If your dataframe has a "country" column this function will make sure that all of the countries listed on there are recognized by GENOME.

```
dataMelt()
```
The dataMelt function turns data into a short format, with each row as a measurement. It takes the measurementType columns (e.g., body mass, total length, etc.) and turns them into rows with the values into a new column measurementValue.

```
diagnosticID()
```
The diagnosticID is unique for each row (i.e., record) and is applied <i>after</i> the dataMelt() function. This is automatic.

```
inConv()
```
The inConv() function changes values in inches to millimeters (1 inch = 1.54 millimeters).
            
```
cmConv()
```
The cmConv() function changes values in centimeters to millimeters. 
            
```
mConv()
```
the mConv() function changes values in meters to millimeters.

```
lbsConv()
```
The lbsConv() function changes values in pounds to grams (1 pound = 453.59237 grams).
            
```
kgConv()
```
The kgConv() function changes values in kilograms to grams.
            
```
mgConv()
```
The mgConv() function changes values in milligrams to grams. 

```
license()
```
Adds licensing to the data. Licenses are assumed to be <a href="https://creativecommons.org/publicdomain/zero/1.0/legalcode">CC0</a>, unless specified as <a href="https://creativecommons.org/licenses/by/4.0/">CC BY</a> or <a href="https://opensource.org/licenses/BSD-3-Clause">BSD</a>.
            
```
to_json()
```
Converts all columns that do not match the <a href="https://github.com/futres/template/blob/master/template.csv">template</a> into a singular <a href="https://dwc.tdwg.org/list/#dwc_dynamicProperties">dwc:dynamicProperties</a> column. This is automatic.

-----------------------------------------------------------------------------------------------------------------------

<h3>After function application</h3>
            
Once users are done applying all of their desired functions they can proceed to download the cleaned version of their original dataframe onto their local drive and upload it to GEOME under the FuTRES project for validation and ingest into the FuTRES datastore.
