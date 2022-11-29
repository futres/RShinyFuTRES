# RShinyFuTRES

Our goal is to help data contributors format their data for ingest into <a href="https://geome-db.org/about">GEOME</a> and the <a href="https://futres-data-interface.netlify.app/">FuTRES datastore</a>.

Please read <a href="https://futres.org/data_tutorial/">Data Tutorial</a> for more information about uploading data into <a href="https://geome-db.org/">GEOME</a> and accepted terms for the <a href="https://raw.githubusercontent.com/futres/template/910ecba9dd8159793a674de4fa5d582a40ebf8f7/template.csv">template</a>.

If you have any problems while running this program or have any questions please feel free to submit an <a href="https://github.com/futres/RShinyFuTRES/issues/new">issue</a>.

<b>Please note that this app only accepts a data file size up to 30MB.</b>

-----------------------------------------------------------------------------------------------------------------------

## Data formatting

Typically, data is in "wide" format, where each row is a specimen (individual, or element). FuTRES, however, ingests and serves data in a "long" format, where each row is a measurement.

#### Wide, unstandardized format
CatalogNo. | Species | Date | Management Unit | County | Sex | Age | Status | Weight | Length 
---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- 
0 | <i>Puma concolor</i> | 5/19/87 | Mt Emily | Umatilla | F | 4 | A | 105.0 | 75.0 
1 | <i>Puma concolor</i> |  8/12/87 | Chetco | Curry | F | 5 | A | 64.0 | NaN 
2 | <i>Puma concolor</i> |  9/21/87 | Santiam | Clackamas | M | 2 | A | 116.0 | 76.0 
3 | <i>Puma concolor</i> |  9/28/87 | Chetco | Curry | F | 3 | A | 74.0 | 70.0 
4 | <i>Puma concolor</i> |  10/4/87 | McKenzie | Lane | F | 2 | A | 76.0 | 73.0 

#### Long, standardized format
diagnoisticID | materialSampleID | individualID | scientificName | CatalogNumber | eventDate | yearCollected | sex | age | materialSampleType | measurementValue | measurementType | measurementUnit | verbatimLocality | yearCollected 
---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- 
1 | 0 | 0 | <i>Puma concolor</i> | 0 | 1987-05-19 | 1987 | female | 4 | whole organism | 47627.2 | body mass | g | Mt Emily, Umatilla 
2 | 0 | 0 | <i>Puma concolor</i> | 0 | 1987-05-19 | 1987 |  female | 4 | whole organism | 1905.0 | body length | mm | Mt Emily, Umatilla 
3 | 1 | 1 | <i>Puma concolor</i> | 1 | 1987-08-12 | 1987 |  female | 5 | whole organism | 29023.0 | body mass | g | Chetco, Curry 
4 | 2 | 2 | <i>Puma concolor</i> | 2 | 1987-09-21 | 1987 |  male | 2 | whole organism | 52616.7 | body mass | g | Santiam, Clackamas 
5 | 2 | 2 | <i>Puma concolor</i> | 2 | 1987-09-21 | 1987 |  male | 2 | whole organism | 1930.4 | body length | mm | Santiam, Clackamas 
6 | 3 | 3 | <i>Puma concolor</i> | 3 | 1987-09-28 | 1987 |  female | 3 | whole organism | 33565.8 | body mass | g | Chetco, Curry 
7 | 3 | 3 | <i>Puma concolor</i> | 3 | 1987-09-28 | 1987 |  female | 3 | whole organism | 1778.0 | body length | mm | Chetco, Curry 
8 | 4 | 4 | <i>Puma concolor</i> | 4 | 1987-10-04 | 1987 |  female | 2 | whole organism | 34473.0 | body mass | g | McKenzie, Lane 
9 | 4 | 4 | <i>Puma concolor</i> | 4 | 1987-10-04 | 1987 |  female | 2 | whole organism | 1854.2 | body length | mm | McKenzie, Lane 

FuTRES has a set of required columns and accepted columns. All other columns need to be removed (not recommended) or transformed to json format and combined into a column called "dynamicProperties".

This application tackles barriers contributors had when uploading data into GEOME:
- Converting to long format
- Transforming columns not accepted by GEOME into dynamicProperties
- Checking data values

The application also:
- creates a unique identifier for diagnosticID
- removes rows that do not have a measurementaValue

-----------------------------------------------------------------------------------------------------------------------

## Getting Started

Please follow this <a href="https://futres.shinyapps.io/pyConvApp/">link</a> to use the application.

**If you are not using the web app, please make sure you have conda installed:** <br>
*<a href="https://docs.conda.io/projects/conda/en/latest/user-guide/install/macos.html">MAC</a>*<br>
*<a href="https://docs.conda.io/projects/conda/en/latest/user-guide/install/windows.html">Windows</a>*<br>
*<a href="https://docs.conda.io/projects/conda/en/latest/user-guide/install/linux.html">Linux</a>*<br>

All dependencies needed will automatically be installed.

*!!* If you get an error in the app because of a misspelling or missing column, please exit, fix, and return to the app.

### Data file

The app takes csv files with one row of headers for column names.

#### Template

Please refer to our <a href="https://github.com/futres/template/blob/master/template.csv">template</a> for the list of column headers we currently accept. Below are the required columns (<i>note</i>: we create diagnosticID automatically in the RShinyApp.)
Please have all required columns (in camelCase) before starting.

-----------------------------------------------------------------------------------------------------------------------

## Functions

#### Checking required fields and entries

```
colcheck()
```
This function goes through all of the column names in the user inserted dataframe and figures out which column names do not match the <a href="https://github.com/futres/template/blob/master/template.csv">FuTRES template</a> and which of the required column names are missing. If you are mising required columns, please exit the app and fix.

```
countryValidity()
```
If your dataframe has a "country" column this function will make sure that all of the countries listed on there are recognized by GENOME (generate a <a href="https://futres.org/data_tutorial/#Generating%20a%20template">template</a> and select country DEF). If the country no longer exists, please use the lat/long to find the current country.

#### Formating data

```
dataMelt()
```
The dataMelt function turns <b>wide</b> data into <b>long</b> format, with each row as a measurement. It takes the measurementType columns (e.g., body mass, total length, etc.) and turns them into rows with the values into a new column measurementValue.

The function also removes any rows that have no measurementValue, as well as any empty columns.

diagnosticID (below) is also automatically generated.

#### Creating required fields

```
diagnosticID()
```
The diagnosticID is unique for each row (i.e., record) and is applied <i>after</i> the dataMelt() function. This is automatic.

#### Retaining metadata
            
```
to_json()
```
Converts all columns that do not match the <a href="https://github.com/futres/template/blob/master/template.csv">template</a> into a singular <a href="https://dwc.tdwg.org/list/#dwc_dynamicProperties">dwc:dynamicProperties</a> column. This is automatic.

-----------------------------------------------------------------------------------------------------------------------

## After function application
            
Once users are done applying all of their desired functions they can proceed to download the cleaned version of their original dataframe onto their local drive and upload it to GEOME under the FuTRES project for validation and ingest into the FuTRES datastore.

-----------------------------------------------------------------------------------------------------------------------
## Manually fixing values

#### Formating dates
            
To achive best results, please set eventDate to a "YYYY-MM-DD" (format. To do this in <i>excel</i>, follow these steps:

      1) Select the column heading in which your date values are listed 
      2) Right click and select "Format Cells"
      3) Go to the "eventDate" category
      4) Select the "year-month-day" format and click "OK"
      
 To do this in <i>google sheets</i>, follow these steps:
 
      1) Select the cells containing dates
      2) Select "Format", then "Number", then "Custom date and time"
      3) Select the option example "1930-08-05"
      4) Click "Apply"
            
<i><b>Note</b>: you do not need to format a date column if yearCollected already exists</i>

#### Unique identifiers

Each measurement has a unique identifier, diagnosticID. Measurments on the same element (e.g., bone) are connected through materialSampleID. Elements of the same individual are connected through individualID.

The unique identifiers need to be unique <i>within</i> the dataset. Below are some examples of how to create a unique identifier for materialSampleID and individualID:

materialSampleID
- a number for each element
- a combination of number + catalogNumber
- a combingation of number + catalogNumber + materialSampleType

individualID
- a number for each specimen
- a combination of number + catalogNumber

#### Verbatim fields

If data values need to change, such as a country name, we recommend naming the original column "verbatimCountry" and updating the country name in a new column, Country.
