"""
Functions for Data Clean UP
Prasiddhi Gyawali & Meghan Balk & Neeka Sewnath
prasiddhi@email.arizona.edu; balkm@email.arizona.edu; nsewnath@ufl.edu
"""

#===========================================================================================================================================

import pandas as pd
import numpy as np
import re
import json
import uuid
import warnings

# from sphinx.config import eval_config_file

#===========================================================================================================================================

try:
    warnings.filterwarnings('ignore')
except:
    pass

#===========================================================================================================================================

## allows for the dataframe to be opened using python
def open_df(df):
    return pd.read_csv(df)

#===========================================================================================================================================

def individualID(df):
    df.insert(0,'individualID', np.arange(1,len(df)+1))
    return df

def diagnosticId(df):
    df['diagnosticID'] = np.arange(1,len(df)+1)
    return df

def mst_add(dictionary,check,replace):
    '''
    adds values to MST dictionary
    '''
    for i in range(len(check)):
        new_row = {'userTerm':check[i], 'replacedWith':replace[i]}
        dictionary = dictionary.append(new_row, ignore_index=True)
    return dictionary
#===========================================================================================================================================

def remove_rcna(df):
    """
    Removes empty columns and rows from df
    """
    df.dropna(how = 'all', axis = 'columns', inplace = True)
    df.dropna(how = 'all', axis = 'rows', inplace = True)
    return df

#===========================================================================================================================================

## 
def verLocal(df,arr): 
    """ 
    Creates verbatimLocality column from user specified columns
    """
    locality_cols = arr

    df["verbatimLocality"] = df[locality_cols].astype(str).apply(", ".join, axis=1)
    return df

def verLocal_oneCol(df,inpt):
    """ 
    Creates verbatimLocality column from user specified columns
    """
    df["verbatimLocality"] = df[inpt]
    return df
#===========================================================================================================================================
#TODO: This needs to be modified to handle universal data
#HOW: Let the user decide which words convert to which materialSampleType
#print out unique list of what's in there
#ask them to write a dictionary or fix it; column of theirs and fill in column with options

def matSampType(df,check,replace):

    '''
    More description to status column -- in connection with GENOME
    '''

    for i in range(len(check)):
        checking_vals = df['materialSampleType'].eq(check[i])
        df['materialSampleType'][checking_vals == True] = replace[i]
    return df

#===========================================================================================================================================
#TODO: make for non-english labels

def sex(df):
    """ 
    Standardizes sex values with GEOME vocabulary 
    """
    female = df['sex'].eq("F", "f")
    male = df['sex'].eq("M", "m")
    df['sex'][(female == False)&(male==False)] = "not collected"
    df['sex'][female == True] = "female"
    df['sex'][male == True] = "male"
    return df

#===========================================================================================================================================

def inConv(df,col):
    """
    Converts length from inches to millimeters
    """
    df[col] = df[col] * 25.4
    return df

#===========================================================================================================================================

def lbsConv(df,col):
    """
    Converts weight from pounds to grams
    """
    df[col] = df[col] * 453.59237
    return df

#===========================================================================================================================================

def cmConv(df,col):
    """
    Converts length from cenitmeters to millimeters
    """
    df[col] = df[col] * 10
    return df

#===========================================================================================================================================

def kgConv(df,col):
    """
    Converts weight from kilograms to grams
    """
    df[col] = df[col] * 1000
    return df

#===========================================================================================================================================

def mConv(df,col):
    """
    Converts length from meters to millimeters
    """
    df[col] = df[col] * 1000
    return df

#===========================================================================================================================================

def mgConv(df,col):
    """
    Converts weight from milligrams to grams
    """
    df[col] = df[col] / 1000
    return df

#===========================================================================================================================================
#ask which column is EventDate or use column eventDate (should have it based off READ.md)

def yc(df):
    """
    Create and populate yearCollected through the date column
    """
    df = df.assign(yearCollected = df['Date'].str[:4])
    df = df.rename(columns = {"Date" : "verbatimEventDate"})
    return df

#===========================================================================================================================================

def colcheck(df):
    """
    Checks dataframe columns and flags column names that do not 
    match with template. 
    Template found here: https://github.com/futres/template/blob/master/template.csv
    """

    geome_col_names = pd.read_csv("https://raw.githubusercontent.com/futres/fovt-data-mapping/master/Mapping%20Files/template_col_names.csv")
    df_col_names = df.columns
    error = list(set(df_col_names) - set(geome_col_names["Template Column Names"]))
    required_columns = ['eventID', 'country','locality','yearCollected','samplingProtocol',
                        'materialSampleID', 'basisOfRecord','scientificName','diagnosticID',
                        'measurementMethod','measurementUnit','measurementType','measurementValue']
    missing_req = list(set(required_columns) - set(df_col_names))
        
#have it break if the set difference isn't zero

    return (f"These column names do not match the template: {error}\nThese required columns are missing: {missing_req}\nThis app will take care of the following columns: materialSampleID, eventID, measurementType, measurementValue, yearCollected")

#===========================================================================================================================================

def dynamicProperties(df):
    geome_col_names = pd.read_csv("https://raw.githubusercontent.com/futres/fovt-data-mapping/master/Mapping%20Files/template_col_names.csv")
    df_col_names = df.columns
    error = list(set(df_col_names) - set(geome_col_names["Template Column Names"]))
    if len(error) != 0:
        df["dynamicProperties"] = df[error].apply(lambda x: x.to_json(), axis=1)
        df = df.drop(columns=error)
    return df

def countryValidity(df):
    '''
    Checks to make sure all country names are valid according the GENOME.
    Valid countries can be found here: https://github.com/futres/fovt-data-mapping/blob/ade4d192a16dd329364362966eaa01d116950e1d/Mapping%20Files/geome_country_list.csv
    '''
    print("Checking Validity of Countries")

    GENOMEcountries = pd.read_csv("https://raw.githubusercontent.com/futres/fovt-data-mapping/master/Mapping%20Files/geome_country_list.csv")
    invalid = list(set(df["Countries"]) - set(GENOMEcountries["GEOME_Countries"]))
    print(invalid)

#===========================================================================================================================================

def add_ms_and_indivdID(df):
    """
    Adds unique hex value materialSampleID and eventID to dataframe
    """
    # These are the column names that could match materialSampleID if they all match
    sample_cols = ["institutionCode", "individualID", "scientificName", "sex", 
                "country", "stateProvince", "lifeStage", "verbatimAgeValue",
                "basisOfRecord", "locality", "samplingProtocol", "yearCollected"]

    # Dictionary of terms and bones created from ontology codebook
    map_dict = dict(zip(aep_subset.term , aep_subset.bone))

    # Creating temp_bone column to map the measurementType to the common bone name
    long_data["temp_bone"] = long_data["measurementType"].map(map_dict)

    # Creating a json column containing everything in sample_cols
    long_data['temp_json'] = long_data[sample_cols].apply(lambda x: x.to_json(), axis=1)

    # Grouping only if temp_bone and temp_json are the same, assigning numeric ID
    long_data["materialSampleID"] = long_data.groupby(["temp_bone", "temp_json"]).ngroup()

    # Dropping unnecessary columns
    long_data = long_data.drop("temp_bone", axis = 1)
    long_data = long_data.drop("temp_json", axis = 1)
    # df['materialSampleID'] = [uuid.uuid4().hex for _ in range(len(df.index))]
    df = df.assign(individualID = np.arange(len(df)))
    return df
#===========================================================================================================================================
#TODO: dynamically update the id_vars with everything accept the term columns
#How: Let the user give the column names or range id_vars

def dataMelt(df,arr):
    """
    Converts dataframe into long format
    """
    dataCols = arr
    dfCols = df.columns.values.tolist()

    VARS = list(set(dfCols) - set(dataCols))

    ID_VARS = np.array(VARS)

    df = pd.melt(df, id_vars = ID_VARS, value_vars = dataCols, var_name = 'measurementType', value_name = 'measurementValue')
    return df
    
def measurementUnitsHelper(df):
    if 'weight' in df['measurementType'].lower() or 'mass' in df['measurementType'].lower():
        return 'g'
    else:
        return 'mm'

def measurementUnits(df):
    if 'measurementUnits' in df.columns:
        return df
    
    if 'measurementType' in df.columns:
        df['measurementUnit'] = df.apply(lambda row: measurementUnitsHelper(row), axis=1) 
    return df

#===========================================================================================================================================

def license(df,license):
    if(license == "BSD"):
        df = df.assign(License = "BSD")
    elif(license == "CC-BY"):
        df = df.assign(License = "CC-BY")
    else:
        df = df.assign(License = "CC0")
    return df

#===========================================================================================================================================
