"""
Functions for Data Clean UP
Prasiddhi Gyawali & Meghan Balk & Neeka Sewnath
prasiddhi@email.arizona.edu; balkm@email.arizona.edu; nsewnath@ufl.edu
"""

#===========================================================================================================================================

import pandas as pd
import re
import json
import uuid
import warnings
import numpy as np

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

def inConv(df):
    """
    Converts length from inches to millimeters
    """
    df['Length'] = df['Length'] * 25.4
    return df

#===========================================================================================================================================

def lbsConv(df):
    """
    Converts weight from pounds to grams
    """
    df['Weight'] = df['Weight'] * 453.59237
    return df

#===========================================================================================================================================

def cmConv(df):
    """
    Converts length from cenitmeters to millimeters
    """
    df['Length'] = df['Length'] * 10
    return df

#===========================================================================================================================================

def kgConv(df):
    """
    Converts weight from kilograms to grams
    """
    df['Weight'] = df['Weight'] * 1000
    return df

#===========================================================================================================================================

def mConv(df):
    """
    Converts length from meters to millimeters
    """
    df['Length'] = df['Length'] * 1000
    return df

#===========================================================================================================================================

def mgConv(df):
    """
    Converts weight from milligrams to grams
    """
    df['Weight'] = df['Weight'] / 1000
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

    return (f"These column names do not match the template: {error}\nThese required columns are missing: {missing_req}")

#    # renames columns through user input
#    col_names = []
#    for i in range(len(df.columns)):
#        inpt = input("What would you like column " + str(i + 1) + " to be named?: ")
#        col_names.append(inpt)
#    df.columns = col_names
#    return df

#===========================================================================================================================================

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
    df = df.assign(materialSampleID = [uuid.uuid4().hex for _ in range(len(df.index))])
    df = df.assign(eventID = df["materialSampleID"])
    return df

#===========================================================================================================================================

def handle_conversion(df):
    """
    Handles conversion based on user input
    
    """
    # Applying weight converstion functions in accordance to inputed unit
    if wght == "pounds":
        df = lbsConv(df)
    elif wght == "kilograms":
        df = kgConv(df)
    elif wght == " milligrams":
        df = mgConv(df)

    # Applying length converstion functions in accordance to inputed unit
    if lngth == "inches":
        df = inConv(df)
    elif lngth == "centimeters":
        df = cmConv(df)
    elif lngth == " meters":
        df = mConv(df)

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
    
#===========================================================================================================================================

#TODO: print out non geome columns and prompt user to proceed

def to_json(df):
    """
    Turns all columns that are not matching to GEOME columns into a singular dynamicProperties column
    """

    geome_col_names = pd.read_csv("https://raw.githubusercontent.com/futres/fovt-data-mapping/master/Mapping%20Files/template_col_names.csv")
    df_col_names = df.columns

    non_geome_cols_names = list(set(df_col_names) - set(geome_col_names["Template Column Names"]))
    non_geome_df_cols = df[non_geome_cols_names]

    df = df.assign(dynamicProperties="")

    for i in non_geome_df_cols.index:
        df["dynamicProperties"][i] = non_geome_df_cols.loc[i].to_json()
    
    return df

#===========================================================================================================================================

def callAll(df):
    """
    Calls all standard data cleaning functions
    """
    print("Removing blank rows and columns...")
    df = remove_rcna(df)
    print("Adding verbatimLocality...")
    df = verLocal(df)
    #print("Cleaning materialSampleType...")
    #df = matSampType(df)
    print("Cleaning sex column...")
    df = sex(df)
    print("Cleaning yearCollected column...")
    df = yc(df)
    print("Adding materialSampleID and eventID...")
    df = add_ms_and_evID(df)
    print("Converting to long format...")
    df = dataMelt(df)
   # print("Generating dynamicProperties column...")
   # df = to_json(df)
    return df

#===========================================================================================================================================

'''
if __name__ == '__main__':

    #todo: we need to force the user to have correct column names before proceeding to cleaning

    # import matSamp_dict
    matSamp_dict = pd.read_csv("https://raw.githubusercontent.com/futres/fovt-data-mapping/master/Mapping%20Files/MST_dict.csv")

    # import cougar data directly from github
    df = pd.read_csv("https://raw.githubusercontent.com/futres/fovt-data-mapping/master/Scripts/pythonConversion/1987to2019_Cougar_Weight_Length_Public_Request.csv")

    colcheck(df)

    # asking what the units of the weight values are
    wght = input("What units are the weight values in? ")

    #todo: How do we handle mixed weight values here?

    while True:
        if wght == "pounds" or wght == "kilomgrams" or wght == "milligrams" or wght == "grams":
            break
        print("Sorry! That is not an accepted weight unit.")
        print("This program accepts: ""pounds"", ""kilograms"", ""milligrams"", and ""grams"".")
        wght = input("What units are the weight values in? ")

    # asking what the units of the length values are
    lngth = input("What units are the length values in? ")

    while True:
        if lngth == "inches" or lngth == "centimeters" or lngth == "meters" or lngth == "millimeters":
            break
        print("Sorry! That is not an accepted length unit.")
        print("This program accepts: ""inches"", ""centimeters"", ""meters"", and ""millimeters"".")
        lngth = input("What units are the length values in? ")

    df = matSampType(df)
    df = handle_conversion(df)
    df = callAll(df)

    # print data frame as it is right now
    print("This is your current data frame: ")
    print(df)

    required_columns = ['eventID', 'country','locality','yearCollected','samplingProtocol',
                        'materialSampleID', 'basisOfRecord','scientificName','diagnosticID',
                        'measurementMethod','measurementUnit','measurementType','measurementValue']

    print(f'These required columns are still missing: {list(set(required_columns) - set(df.columns))}')
'''

df = pd.read_csv("https://raw.githubusercontent.com/futres/fovt-data-mapping/master/Scripts/pythonConversion/1987to2019_Cougar_Weight_Length_Public_Request.csv")
df = remove_rcna(df)