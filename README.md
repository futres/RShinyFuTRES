# RShinyFuTRES

Our goal is to help data contributors format their data for ingest into <a href="https://geome-db.org/about">GEOME</a> and the <a href="https://futres-data-interface.netlify.app/">FuTRES datastore</a>. FuTRES requires specific <a href="https://github.com/futres/template/blob/master/template.csv">column names</a> and requires one record (e.g., measurement per specimen) per row. This app helps standardize column names and values, as well as converts short format (one specimen per row) into long format (one measurement per row). We also automatically generate diagnosticID, which is required for the dataset that FuTRES uses to help reason across the ontology. Please see the FuTRES <a href="https://futres.org/data_tutorial/">data tutorial</a> for more instructions on how to upload data to be made available through our API once data is formated correctly.

This application tackles barriers contributors had when uploading data into GEOME:

1. Prechecking column headers and creating required columns
2. Converting data into a long format, with each row being a unique measurements
3. Creating a dynamicProperities column of columns not accepted by GEOME (in json format)

We create the following columns:
* diagnosticID
* yearCollected
* dynamicProperties
* license

We check the following columns:
* all required columns
* entries under country

We standardize the following columns entries:
* materialSampleID
* measurementUnit

Please make sure you have read "Getting Started", have your data file as a csv with the required columns in camelCase.

If you have any problems while running this program or have any questions please feel free to email <b>futres.team@gmail.com</b> with your concerns.

### Limitations

We currently do not match measurement terms to our list of trait terms. We feel the contirbutor can make the best judgements about which ontological trait terms match their measurements. Please go to GEOME to see the term list (generate a <a href="https://futres.org/data_tutorial/#Generating%20a%20template">template</a> and select measurementType DEF). If you need to request a trait term, please create an issue <a href="https://github.com/futres/fovt/issues">here</a> and we will make it!

We also currently do not create individualID, which is a unique ID for the specimen or all specimens belonging to the same individual organism, or materialSampleID, which is a combination of individualID + bone. We ask that the data contributor identify which measurements are on the same element and which elements are part of the same individual (there may only be one element per individual).

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

Please have all required columns before starting. Please also map your measurement terms to the accepted trait terms.

If you have columns not accepted by GEOME, please select the option to convert remaining columns to json format and these will be combined under the "dynamicProperties" header.

### Template

Please refer to our <a href="https://github.com/futres/template/blob/master/template.csv">template</a> for the list of column headers we currently accept. Below are the required columns (<i>note</i>: we create diagnosticID automatically in the RShinyApp.)
Please have all required columns (in camelCase) before starting.

column|uri|entity_alias|FuTRES_Use|type|example|Controlled_Vocabulary
-----------|----------------|------------------------------|------------------|--------------|-------------------------------|----------------------
individualID|urn:individualID|vertebrateOrganism|An identifier of a distinct individual (e.g. all bones within the same associated skeleton would have the same individualID).|string|UUID; institutionCode-collectionCode-catalogNumber|
materialSampleID|http://rs.tdwg.org/dwc/terms/materialSampleID|vertebrateOrganism|An identifier for the materialSample (single specimen, carcass, element, or bone) that is globally unique (e.g., each bone within an associated skeleton would have a unique materialSampleID).|string|UUID; institutionCode-collectionCode-catalogNumber|
diagnosticID|urn:diagnosticID|vertebrateOrganism|An identifier of a single measurement of a specimen / element that is globally unique.|string|UUID|
eventID|http://rs.tdwg.org/dwc/terms/eventID|vertebrateTraitObsProc,The collector's event identifier. This can be the same as the materialSampleID if you are using the diagnostics extension for tracking trait values.|string|UUID|
institutionCode|http://rs.tdwg.org/dwc/terms/ownerInstitutionCode|vertebrateOrganism|The code or abbreviation for the institution or museum.|string|NMNH for the National Museum of Natural History|
institutionID|http://rs.tdwg.org/dwc/terms/institutionID|vertebrateOrganism|An identifier for the institution having custody of the object(s) or information referred to in the record.|string|URL|
collectionCode|http://rs.tdwg.org/dwc/terms/collectionCode|vertebrateOrganism|The code or abbreviation for the collection or department within the museum.|string|PAL for Department of Paleontology|
catalogNumber|http://rs.tdwg.org/dwc/terms/catalogNumber|vertebrateOrganism|An identifier (preferably unique) assigned to the specimen by the institution or museum.|numerical|12345|
scientificName|http://rs.tdwg.org/dwc/terms/scientificName|vertebrateOrganism|The lowest taxonomic identification for a specimen, preferably with authorship information.|string|Neotoma cinerea|
basisOfRecord|http://rs.tdwg.org/dwc/terms/basisOfRecord|vertebrateOrganism|The specific nature of the specimen.|string||PreservedSpecimen| FossilSpecimen| LivingSpecimen| HumanObservation| MachineObservation
materialSampleType|urn:materialSampleType|vertebrateTraitObsProc|The completeness of the materialSample.|string|whole organism, part organism, whole bone, part bone, whole skeleton, gutted, skinned, gutted and skinned
lifeStage|http://rs.tdwg.org/dwc/terms/lifeStage|vertebrateOrganism|The age class or life stage of the specimen being measured.|string|Not Applicable, Not Collected, adult, immature, juvenile, subadult
measurementType|http://rs.tdwg.org/dwc/terms/measurementType|measurementDatum|The trait and anatomical or physiological feature being measured.|string||CV from list of traits
measurementValue|http://rs.tdwg.org/dwc/terms/measurementValue|measurementDatum|The numerical value of measurement.|numerical|45|
measurementUnit|http://rs.tdwg.org/dwc/terms/measurementUnit|measurementDatum|The unit associated with the measurementValue.|string||mm, cm, m, in, ft, km, g, kg, oz, lb
measurementMethod|http://rs.tdwg.org/dwc/terms/measurementMethod|measurementDatum|The description, reference, or URL of the method used for measurementType.|string|used calipers for measurementType|
measurementRemarks|http://rs.tdwg.org/dwc/terms/measurementRemarks|measurementDatum|Comments or notes accompanying MeasurementType.|string|75% of epiphysis|
measurementDeterminedDate|http://rs.tdwg.org/dwc/terms/measurementDeterminedDate|measurementDatum|The date the measurementValue was taken.|string|23/12/10|
measurementAccuracy|http://rs.tdwg.org/dwc/terms/measurementAccuracy|measurementDatum|The numerical value of measurement error for the measurementValue of either the instrument or the measurer.|string|10mm|
verbatimEventDate|http://rs.tdwg.org/dwc/terms/verbatimEventDate|vertebrateTraitObsProc|The original representation of the date and time of observation or collection.|string|date of collection event, not of measurement; Jun 1847|
yearCollected|urn:yearCollected|vertebrateTraitObsProc|The year the specimen or sample was collected.|integer|1999|
samplingProtocol|http://rs.tdwg.org/dwc/iri/samplingProtocol|vertebrateTraitObsProc|The method/protocol, reference, or URL of MeasurementType.|string|Von Der Dreish 1976|
locality|http://rs.tdwg.org/dwc/terms/locality|vertebrateTraitObsProc|The specific description of site.|string|Tecal or Quarry 4|
country|http://rs.tdwg.org/dwc/terms/county|vertebrateTraitObsProc|The country of observation or collection.|string|USA|
references|http://purl.org/dc/terms/references|vertebrateTraitObsProc|A related resource that is referenced or otherwise pointed to by the described resource.|string|DOI or Journal of Vertebrate Paleontology citation format|

### Data Format

We accept datasets that are in <b>short</b> format, with each row being a specimen, and possibly internal abbreviations for data fields:

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
To make datasets interoperable with one another, the data needs to be transformed into <b>long</b> format, where each row is a measurement, and specimens are connected through the field individualID:

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

#### Country 

The country list is a controlled vocabulary accepted by GEOME (generate a <a href="https://futres.org/data_tutorial/#Generating%20a%20template">template</a> and select country DEF). If the country no longer exists, please usethe latitude and longitude to determine the current country name.

#### Year Collected

yearCollected is only the year from any date (event date, field date, etc.) column you may have. Please see below for formatting.

-----------------------------------------------------------------------------------------------------------------------
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

-----------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------
#### Formaing units

If you have a mix of measurement units for a type of measurement (e.g., mass in both grams and pounds), please standardize before proceeding.

-----------------------------------------------------------------------------------------------------------------------

## Functions

#### Standardizing entries

```
matSampType()
```
The materialSampleType function is to standardize descriptions of the completeness of a materialSample (i.e., specimen). For example, replacing internal coding of specimen condition (e.g., sk = skinned) with a controlled vocabulary: whole organism, part organism, whole bone, part bone, whole skeleton, gutted, skinned, gutted and skinned.

```
sex()
```
The sex function helps standardize sex terms to a controlled vocabulary accepted by GEOME. For example, it takes values like "F" and "M" and changes them 
into "female" and "male". This function also checks for values that it does not recognize and changes them into "not collected".

_Measurement Units_

```
inConv()
```
The inConv() function changes values in inches to millimeters (1 inch = 2.54 millimeters).
            
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

#### Checking required fields and entries

```
colcheck()
```
This function goes through all of the column names in the user inserted dataframe and figures out which column names do not match the <a href="https://github.com/futres/template/blob/master/template.csv">FuTRES template</a> and which of the required column names are missing. If you are mising required columns, please exit the app and fix.

```
countryValidity()
```
If your dataframe has a "country" column this function will make sure that all of the countries listed on there are recognized by GENOME (generate a <a href="https://futres.org/data_tutorial/#Generating%20a%20template">template</a> and select country DEF). If the country no longer exists, please use the lat/long to find the current country.

#### Creating required fields
```
yc()
```
The year collected function extracts information from the *modified* date column in order to only present the year in which the data was collected.

```
license()
```
Adds licensing to the data. Licenses are assumed to be <a href="https://creativecommons.org/publicdomain/zero/1.0/legalcode">CC0</a>, unless specified as <a href="https://creativecommons.org/licenses/by/4.0/">CC BY</a> or <a href="https://opensource.org/licenses/BSD-3-Clause">BSD</a>.

```
diagnosticID()
```
The diagnosticID is unique for each row (i.e., record) and is applied <i>after</i> the dataMelt() function. This is automatic.

#### Formating data

```
dataMelt()
```
The dataMelt function turns <b>short</b> data into <b>long</b> format, with each row as a measurement. It takes the measurementType columns (e.g., body mass, total length, etc.) and turns them into rows with the values into a new column measurementValue. Values can be connected by individualID (for all measurements of elements of an individual) and materialSampleID (for all measurements of an element from an individual).

#### Retaining metadata

```
verLocal()
```
The verbaitm locality function combines the existing columns which holds data regarding the location of the data into one column to retain original site identification.
            
```
to_json()
```
Converts all columns that do not match the <a href="https://github.com/futres/template/blob/master/template.csv">template</a> into a singular <a href="https://dwc.tdwg.org/list/#dwc_dynamicProperties">dwc:dynamicProperties</a> column. This is automatic.

-----------------------------------------------------------------------------------------------------------------------

## After function application
            
Once users are done applying all of their desired functions they can proceed to download the cleaned version of their original dataframe onto their local drive and upload it to GEOME under the FuTRES project for validation and ingest into the FuTRES datastore.
