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
    return pd.read_csv(df,encoding='unicode_escape')


def diagnosticId(df):
    df['diagnosticID'] = np.arange(1,len(df)+1)
    return df

#===========================================================================================================================================

def remove_rcna(df):
    """
    Removes empty columns and rows from df
    """
    df.dropna(how = 'all', axis = 'rows', inplace = True)
    required_columns = ['eventID', 'country','locality','yearCollected','samplingProtocol',
                        'materialSampleID', 'basisOfRecord','scientificName','diagnosticID',
                        'measurementMethod','measurementUnit','measurementType','measurementValue']
    df_col_names = df.columns
    unnecessary = list(set(df_col_names) - set(required_columns))
    print(unnecessary)
    for s in unnecessary:
        if df[s].isnull().sum() == df[s].shape[0]:
            df = df.drop(columns=s)
    return df

#===========================================================================================================================================

def noMeasurementsPostMelt(df):
    df.dropna(how='any', axis = 'rows', subset = ['measurementValue'], inplace = True)
    return df

def dropped_cols(df):
    df_col_names = df.columns
    required_columns = ['eventID', 'country','locality','yearCollected','samplingProtocol',
                        'materialSampleID', 'basisOfRecord','scientificName','diagnosticID',
                        'measurementMethod','measurementUnit','measurementType','measurementValue']
    unnecessary = list(set(df_col_names) - set(required_columns))
    return (f"If any of the following columns (columns not required by the template) are empty the app will automatically drop them. \n{unnecessary}\n")

def matSampTypeUnmatched(df):

    '''
    More description to status column -- in connection with GENOME
    '''

    print("Checking Validity of Countries")

    accepted = ['Whole organism', 'Part organism - whole element', 'Part organism - part element']
    unaccepted = list(set(df['materialSampleType'].unique()) - set(accepted))
    return (f"These materialSampleType values are not accpeted by the template: {unaccepted}\n")


def colcheck(df):
    """
    Checks dataframe columns and flags column names that do not 
    match with template. 
    Template found here: https://github.com/futres/template/blob/master/template.csv
    """

    geome_col_names = pd.read_csv("https://raw.githubusercontent.com/futres/template/910ecba9dd8159793a674de4fa5d582a40ebf8f7/template.csv")
    df_col_names = df.columns
    error = list(set(df_col_names) - set(geome_col_names["column"]))
    required_columns = ['eventID', 'country','locality','yearCollected','samplingProtocol',
                        'materialSampleID', 'basisOfRecord','scientificName','diagnosticID',
                        'measurementMethod','measurementUnit','measurementType','measurementValue']
    missing_req = list(set(required_columns) - set(df_col_names))
        
#have it break if the set difference isn't zero

    return (f"These column names do not match the template: {error}\nThese required columns are missing: {missing_req}\nThis app will take care of the following columns: measurementType, measurementValue, yearCollected, diagnosticID\n")

#===========================================================================================================================================

def dynamicProperties(df):
    geome_col_names = pd.read_csv("https://raw.githubusercontent.com/futres/template/910ecba9dd8159793a674de4fa5d582a40ebf8f7/template.csv")
    df_col_names = df.columns
    error = list(set(df_col_names) - set(geome_col_names["column"]))
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
    invalid = list(set(df["country"]) - set(GENOMEcountries["GEOME_Countries"]))
    return (f"These country names are not valid according to GENOME: {invalid}\n")

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
        df = df.assign(license = "BSD")
    elif(license == "CCBY"):
        df = df.assign(license = "CC-BY")
    else:
        df = df.assign(license = "CC0")
    return df

#===========================================================================================================================================
