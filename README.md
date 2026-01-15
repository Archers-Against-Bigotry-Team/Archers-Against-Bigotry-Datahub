# ArchersAgainstBigotry
Systems to extract and analyse archery data.

If the code and datasets are of any use to your projects, you may cite the repository with the following DOI:
v0.1-alpha release DOI: 10.5281/zenodo.18259019

Python code to scrap IANSEO for BUCS data prepared by Lucas
R code to compile BUCS data and generate box-plots prepared by Joel

Tha IANSEO scraper works by downloading the IANSEO webpage (the .php file). 
For BUCS, each category in each tournament (e.g. Men Experienced Recurve, Women Experienced Longbow, etc.) is stored in it's own .php file.  The scraper will specifically download the qualifier rounds (i.e. the Portsmouth, WA1440, WA900, WA70).
It then finds the line that defines the table of tournament results, where the archer's rank, name, score at each distance, etc. are stored.
From there it uses the html brackets <></> to extract the data, and puts it into excel sheets.
