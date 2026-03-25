# -*- coding: utf-8 -*-
"""
Filename: ianseo_scraper.py
Author: Joel Harris joelharris251@gmail.com
Date: 22-01-2026
Version: 2.0
Dependencies: bs4, re, requests, os, pandas, shutil, sys, pathlib
Python version: 3.11.9
License: GNU GENERAL PUBLIC LICENSE v.3

Description: 
    This script scrapes archery competition data from ianseo. 
    For each url supplied, it will create an excel workbook.

Temporary files: 
    3 temporary directories will be created and automatically deleted after the program finishes. 
    These are "excel_data", "ianseo_pages", and "raw_data".

Input: 
    "urls" directory containing excel sheets of urls to ianseo pages.
    Excel sheet must be formatted as "competitionName_urls.xlsx"

Output: 
    "results" directory containing subdirectories for each input excel sheet. 
    Subdirectories will contain 1 multisheet excel workbook for each url in an excel sheet.

Modification history:
    22-01-2026: 
        Created a basic version of the scraper which only worked on data from the Archery GB Indoor Nationals.
    28-01-2026: 
        Generalised the scraper to work on any Ianseo page for a WA18 or single Portsmouth competition which stores each category as a separate .php file. 
        Removed most hardcoded names and numbers to improve generalisability.
        Added documentation for the code
        Added a progress tracker
        Improved overall efficiency.
    01-02-2026:
        Changed parse_html_to_excel() to record competition name and year as columns in each sheet
    03-02-2026:
        Improved handling of broken urls
    24-03-2026:
        Improved speed
"""


from bs4 import BeautifulSoup
import re
import requests
import os
import pandas as pd
import shutil
import sys
from pathlib import Path


#Compile regexes needed for multiple functions for greater efficiency
year_pattern = re.compile(r"/(\d{4})/")
name_pattern = re.compile(r"/([^/]+)\.[^/]+$")
php_pattern = re.compile(r"\.php")

session = requests.Session()


def DL_php(phpURL, savePath):
    """
    Download .php file from ianseo web url

    Parameters
    ----------
    phpURL : str
        Url to Ianseo webpage for a given competition.
    
    savePath : str
        Filepath to desired location to save .php file.

    Returns
    -------
    None
    """

    r = session.get(phpURL)
    with open(savePath, "wb") as f:
        f.write(r.content)
    f.close()
    
    return 

def get_competition_name(filepath):
    """
    Pulls the competition name from a downloaded Ianseo webpage.

    Parameters
    ----------
    filepath : str
        Filepath to the downloaded competition Ianseo webpage.

    Returns
    -------
    competition_name : string
        Name of competition.
    """

    #Open file and store as document
    file = open(filepath, "r")
    document = file.read()
    file.close()

    #Parse document with bs4 to make navigation easier
    document = BeautifulSoup(document, 'html.parser')

    #It's Ianseo so of course the competition name is saved in 2 different ways
    center = document.select_one(".results-header-center")
    if center is not None:
        raw_name = center.find("div").get_text(strip=True)
    else:
        header = document.find("table", id="TourHeader")
        th = header.find("th") if header else None
        raw_name = th.get_text(separator="\n", strip=True).split("\n")[0]

    competition_name = raw_name.replace(" ", "_")

    return competition_name




def find_data_urls(filepath): 
    """
    Searches for urls to data for a given downloaded Ianseo webpage.

    Parameters
    ----------
    file_path : str
        Filepath to the downloaded competition Ianseo webpage.

    Returns
    -------
    filtered_links : list
        List of urls to data for a given Ianseo webpage.
    """
    global php_pattern

    #Open file and store as document
    file = open(filepath, "r")
    document = file.read()
    file.close()

    #Parse document with bs4 to make navigation easier
    document = BeautifulSoup(document, 'html.parser')
    div = document.find("div",class_="results-panel-head",string="Qualification Round") #Data links are always stored in the "Qualification Round" div
    
    #Competitions may have team scores and individual scores. We are only interested in the individual scores.
    results_panel_body = div.find_next("div", class_= "results-panel-body") #Individual scores are always stored in the first "results-panel-body" div

    hrefs = results_panel_body.find_all("a", href=True) #Looking for all links (hrefs) in the "results-panel-body"
    links = [a["href"] for a in hrefs] #Extracting the actual links as a list of strings

    #Filter for links which contain ".php" as only these link to the data
    filtered_links = [item for item in links if php_pattern.search(item)]

    #Filter out broken urls which contain whitespace
    filtered_links = [s for s in filtered_links if not any(c.isspace() for c in s)]

    return filtered_links


def DL_data(file_path, competition_name):
    """
    Downloads competition data from a downloaded Ianseo webpage and saves as .php files in the "raw_data" directory.
    Calls find_data_urls() function.

    Parameters
    ----------
    file_path : str
        Filepath to the downloaded competition Ianseo webpage.
    
    competition_name : str
        Name of competition

    Returns
    -------
    None
    """

    global year_pattern #Regex compiled externally for better efficiency
    global name_pattern #Regex compiled externally for better efficiency


    urls = find_data_urls(file_path) #Extract list of data urls from ianseo webpage
    year = re.search(year_pattern, urls[0]).group(1) #Determine year of competition from the first url
    
    #Create a subdirectory in "raw_data" for the year of that competition.
    directory_name = Path("raw_data") / f"{competition_name}_{year}"
    os.makedirs(directory_name, exist_ok=True)
    
    #Convert urls from list into a valid format, find category of competition from url, and download as a .php file
    #Filename formatted as "competetionName_year_competitionCateogry.php"
    for url in urls:
        url = f"https://www.ianseo.net{url}"
        name = re.search(name_pattern, url).group(1)
        save_path = directory_name / f"{name}.php"
        DL_php(url, save_path)
    
    return


def Parse_html_to_excel(filepath, competition_name):
    """
    Parses ianseo competition data into a pandas dataframe, then saves it as an excel sheet in the "excel_data" directory.
    Only for separately saved data. For combined data frame, look at Parse_big_html_to_excel().

    Parameters
    ----------
    file_path : str
        Filepath to the downloaded competition data .php file.

    competition_name : str
        Name of competition

    Returns
    -------
    None
    """
    #TODO: Add ability to process data when all categories are stored on a single sheet
    
    global year_pattern #Regex compiled externally for better efficiency
    global name_pattern #Regex compiled externally for better efficiency

    #Identify year and name of competition
    year = re.search(year_pattern, filepath).group(1)
    name = re.search(name_pattern, filepath).group(1)

    save_dir = Path("excel_data") / f"{competition_name}_{year}"
    os.mkdir(save_dir, exist_ok = True)
    save_path = save_dir / f"{name}.xlsx"

    #Open .php data file and store as "document"
    with open(filepath, "r", encoding="utf-8") as file:
        document = file.read()
    
    #Use bs4 to parse html to make navigating the document easier
    soup = BeautifulSoup(document, "html.parser")
    div = soup.find("div", id="Accordion")
    if div is None:
        div = soup.find("div", class_ = "container-table100")#Different years encode files slightly differently because why not
    
    #Search for data table
    table = div.find("table")
    if table is None:
        raise ValueError("No table found inside the 'Accordion' div.")
    
    header_row = table.find("tr")
    if header_row is None:
        raise ValueError("No header row <tr> found in the table.")
    
    #Look for headers under different encoding options (because ianseo)
    list_header = [th.get_text(strip=True) for th in header_row.find_all(["th", "td"])]
    max_cols = len(list_header)
    
    data_rows = table.find_all("tr")[1:]
    data = []

    for row in data_rows:
        cells = [cell.get_text(strip=True).replace("\xa0", "") for cell in row.find_all(["td", "th"])] #Encode blank cells more sensibly
        cells = [c for c in cells if c != ""] #Remove blank cells
        
        #Increase size of data if there are more cells than columns
        if cells:
            if len(cells) > max_cols:
                max_cols = len(cells)
            data.append(cells)
    
    #Add blank header names if there is more columns than headers
    if len(list_header) < max_cols:
        list_header += [""] * (max_cols - len(list_header))
    
    #Add blank cells to rows where data may be missing (or else pandas throws a hissyfit)
    normalized_data = []
    for row in data:
        if len(row) < max_cols:
            row += [""] * (max_cols - len(row))
        normalized_data.append(row)
    
    df = pd.DataFrame(data=normalized_data, columns=list_header) #Store data as pandas dataframe
    df = df.loc[:, (df != "").any(axis=0)] #Remove blank columns and rows

    #Ianseo changed their file encoding in 2021 to be extra annoying.
    #Headers before 2021 are defined once, but the headers are misaligned with the data
    #Data is stored in a relatively normal way, thank god. 
    if int(year) < 2021:
        df = df.iloc[:, :11] #Only the first 11 columns matter.
        columns_list = list(df.columns)

        #Once again, Ianseo is unhelpful. They vary between storing location data as 1 or 2 columns, and the names of those columns vary.
        if "Country Code" in df.columns and "Country" in df.columns:
            data_start_idx = df.columns.get_loc("Country") + 1
        elif "Country or State Code" in df.columns:
            data_start_idx = df.columns.get_loc("Country or State Code") + 1
        elif "Code" in df.columns:
            data_start_idx = df.columns.get_loc("Code") + 1
        elif "Country" in df.columns:
            data_start_idx = df.columns.get_loc("Country") + 1
        else:
            raise ValueError("Expected country columns not found")
        
        #The columns are misaligned with the data because of course they are. Adding columns to store the number of 10s.
        columns_list.insert(data_start_idx + 1, "X.1")
        columns_list.insert(data_start_idx + 3, "X.2")

        #To quote the great Lucas Low, "ianseo is a bitch". Ianseo will add some blank columns for no reason that fuck things up.
        df.columns = columns_list[0:11]
    
    #Ianseo changed their file encoding in 2021 to be extra annoying. Headers are repeatedly redefined in the document.
    #The real header is in the first column. Afer that, data is stored in every third column.
    #Also, Ianseo changed to store the number of 10s and scores in the same column, i.e. "score/no.10s". This must be dealt with.
    if int(year) > 2020:
        df.columns = df.iloc[0]
        df = df.iloc[1::3].reset_index(drop=True) #Taking every third row.

        if "Country Code" in df.columns and "Country" in df.columns:
            data_start_idx = df.columns.get_loc("Country") + 1
        elif "Country or State Code" in df.columns:
            data_start_idx = df.columns.get_loc("Country or State Code") + 1
        elif "Code" in df.columns:
            data_start_idx = df.columns.get_loc("Code") + 1
        elif "Country" in df.columns:
            data_start_idx = df.columns.get_loc("Country") + 1
        else:
            raise ValueError("Expected country columns not found")

        # First column split
        temp = [str(element).strip().split("/") for element in df.iloc[:, data_start_idx]] #split column and store as a nested list, i.e. [[score, 10s], [score, 10s]]

        df.iloc[:, data_start_idx] = [t[0] if len(t) > 0 else "" for t in temp] #store score in correct column if it exists.
        df.insert(data_start_idx + 1, "X.1", [t[1] if len(t) > 1 else "" for t in temp]) #store no. 10s in correct column if they exist. 

        # Second column split - same logic as above
        temp = [str(element).strip().split("/")for element in df.iloc[:, data_start_idx + 2]]

        df.iloc[:, data_start_idx + 2] = [t[0] if len(t) > 0 else "" for t in temp]
        df.insert(data_start_idx + 3,"X.2",[t[1] if len(t) > 1 else "" for t in temp])
    
    #Save competition name and year to columns

    df.insert(0, "Competition", competition_name)
    df.insert(0, "Year", year)

    #Save extracted data as an excel sheet in "excel_data" directory.
    df = df.reset_index(drop=True)
    df.to_excel(save_path, index=False)
    
    return


def DL_competition(competition_name, url):
    """
    Brings everything together. Creates a multisheet excel workbook of competition data for each url in an excel workbook.
    Calls DL_php(), DL_data(), and Parse_html_to_excel() functions

    Parameters
    ----------
    competition_name : str
        Name of competition. Used to name generated files and folders.
    
    url_filepath : str
        Filepath to excel sheet containing urls to Ianseo webpages.

    Returns
    -------
    None
    """


    #Create directories for "ianseo_pages", "raw_data", "excel_data", and subdirectory "[competition_name]_data" in "results" directory
    directory_name = "ianseo_pages"
    os.makedirs(directory_name, exist_ok=True)

    directory_name = "raw_data"
    os.makedirs(directory_name, exist_ok=True)

    directory_name = "excel_data"
    os.makedirs(directory_name, exist_ok=True)

    directory_name = f"results/{competition_name}_data"
    os.makedirs(directory_name, exist_ok=True)

    #Download each Ianseo page and associated competition data for each url
    #Names each Ianseo page file using a counter instead of by year because year cannot be determined until the file has been parsed

    page_path = Path("ianseo_pages") / f"{competition_name}.php"
    DL_php(url, page_path)
    DL_data(page_path, competition_name)
    
    #Cleans up any misformatted filepaths
    for root, dirs, files in os.walk("raw_data"):
        for file in files:
            full_path = os.path.join(root, file).replace("\\", "/")
            Parse_html_to_excel(full_path)

    parent_dir = "excel_data"

    with os.scandir(parent_dir) as entries:
        directories = [entry.name for entry in entries if entry.is_dir()]#Lists subdirectories in "excel_data" - should be one per competition year

    #Now compiling every excel sheet in each subdirectory into one multisheet excel workbook and saving it in the appropriate subdirectory in the "results" directory
    for directory in directories:
        folder_path = os.path.join("excel_data", directory)
        files = [entry for entry in os.listdir(folder_path) if os.path.isfile(os.path.join(folder_path, entry))]

        output_file = os.path.join(directory_name, f"{competition_name}_{directory}.xlsx") #Name excel workbook in "competitionName_year.xlsx" format
        
        with pd.ExcelWriter(output_file) as writer:
            for file in files: #Adds each file as a sheet to the excel workbook
                file_path = os.path.join(folder_path, file)
                df = pd.read_excel(file_path)
                
                sheet_name = file.replace(".xlsx", "").replace(f"{competition_name}_", "")
                df.to_excel(writer, sheet_name=sheet_name, index=False) 
    
    #Delete temporary files to free up system memory
    shutil.rmtree("excel_data")
    shutil.rmtree("ianseo_pages")
    shutil.rmtree("raw_data") 

    return


def main():
    """
    Co-ordinates the whole program. Takes "urls" directory of excel sheets containing urls and returns "results" directory containing subdirectories for each input worksheet, each subdirectory containing multisheet excel workbooks for each year of competition.

    Returns
    -------
    None
    """
    urls_file = pd.read_excel("urls.xlsx")
    urls = urls_file.iloc[:, 0].tolist()
    total_comps = len(urls)

    #Initialise progress tracker
    print("Working on: ")
    print(f"0 of {total_comps} competitions complete")

    for i, url in enumerate(urls, start= 1):
        competition_name = get_competition_name(url)

        sys.stdout.write("\033[2F")
        sys.stdout.write(f"\rWorking on: {competition_name}\033[K\n")

        DL_competition(competition_name, url)

        sys.stdout.write(f"\r{i} of {total_comps} competitions complete\033[K\n")
        sys.stdout.flush()
    
    print("\nComplete") #Report when program is complete.


    return


if __name__ == "__main__":

    main()
