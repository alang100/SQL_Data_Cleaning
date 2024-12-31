# Data Cleaning and Analysis Using SQL
I have been using MS SQL extensively while working at DEWR for the past 12 months. I use SQL extensively at DEWR, but I cannot showcase any of the SQL work I carry out there. Most of the tables I use at work are of high quality with clean data. I thought it would be interesting to make cleaning project to demonstrate good working knowledge of data cleaning an untidy dataset in SQL and performing EDA (Exploratory Data Analysis) to reveal interesting and meaningful insights. This project was done using MySQL. There is only one table used in the project, so there are no joins involved, which is something I do regularly at work. I am planning on creating a more detailed SQL project in the near future.

In this repository, I have attached the original dataset, the SQL file containing my code and a PDF presentation which consists mainly of screenshots of the code combined with the output, making it is easier for the viewer to follow the results, rather than just reading the code. They are available on the following links:

- The [layoffs dataset](Covid19_layoffs.csv)
- The [project SQL code](Data%20Cleaning%20Project%20and%20EDA%20-%20Layoffs%20CSV%20file.sql)
- The [code presentation PDF](SQL%20Data%20Cleaning%20Project.pdf) file

*Note: To download a file, click the link and then use the download button on the top right of the GitHub interface.*

---

## Project Introduction
Data cleaning is one of the most important steps in preparing data for meaningful analysis. This project focuses on cleaning a dataset of global layoffs during the COVID-19 pandemic using SQL, with the goal of transforming raw, messy data into a clean and reliable dataset. The dataset includes information on layoffs by companies across the globe, covering attributes like company name, location, industry, total layoffs, and dates. The aim of the project is to transform the raw data into a clean, reliable, and usable dataset, making it ready for exploratory data analysis and revealing insights.

## Methodology
In this project I followed a standard approach to data cleaning, which was broken down into four key steps:

1. **Removing Duplicate Rows**  
   Duplicate rows were identified and removed to ensure data integrity. Care was taken to keep valid records of layoffs occurring on different dates or in different locations from the same company, etc.

2. **Standardization of Data**  
   Text-based columns were standardized by trimming unnecessary spaces, correcting misspellings, and normalizing inconsistent entries (e.g., location names like "Dusseldorf" and "Düsseldorf"). Numeric fields, such as percentages, were also adjusted to be consistent making them easier to understand.

3. **Handling Missing Values**  
   Missing data was addressed by either imputing values (e.g., assigning industries based on company names) or removing rows where imputation was not practical. For example, records with both `total_laid_off` and `percentage_laid_off` missing were removed as they gave no information as to the amount of layoffs.

4. **Removing Unnecessary Columns**  
   Columns irrelevant to the analysis, such as those used for intermediate processing, were removed as they are not required.


## Exploratory Data Analysis
After cleaning the data, exploratory queries were conducted to discover insights:

- **Timeframe Covered:**  
  The dataset ranges from March 2020 to March 2023, showing the number of layoffs during and after the COVID-19 pandemic.

- **Key Statistics:**  
  - Total layoffs: 383,659  
  - Total funds raised: $1.601 billion  

- **Layoff Trends Over Time:**  
  Layoffs peaked in January 2023 with 84,714 layoffs, followed by significant layoffs in November 2022 and February 2023.

- **Industries Affected:**  
  The Consumer and Retail industries experienced the highest layoffs, with 44,782 and 43,613 respectively. Manufacturing was the least affected industry.

- **Countries Affected:**  
  The USA and India recorded the highest layoffs, they also have very large populations and workforce sizes.

- **Layoffs by Company:**  
  Amazon, Google, and Meta were the companies with the largest layoffs in this dataset.

## Major Insights
- **COVID-19 Impact on Layoffs:**  
  The pandemic and consequent lockdowns significantly affected layoffs, especially in the industries of Consumer, Retail, and Technology.

- **National Disparities:**  
  Layoffs were concentrated in specific countries. The US and India had by far the largest. They are among the largest populations.
  The Netherlands and Sweden were next, they have much smaller populations.
  The countries with the least number of layoffs were Poland (25) and Chile (30). This is undoubtedly more of a reflection on the dataset, in which data was not collected well for companies in these regions. Layoffs would have certainly been far higher in these countries.

- **Economic Challenges:**  
  High layoff numbers in late 2022 and early 2023 indicate to broader economic challenges likely caused by the pandemic.


## Skills Demonstrated
This project involved several skills that are vital to a data analyst's role:
- **SQL Proficiency:**  
  The use of advanced SQL features, like Common Table Expressions (CTEs), Window Functions, and Aggregations for data transformation and analysis.
  
- **Data Cleaning:**  
  Handling duplicates, standardizing data, correcting incorrect text, and choosing to impute missing values effectively or not to impute.

- **Exploratory Data Analysis (EDA):**  
  Writing queries to reveal trends and insights within the data.

- **Attention to Detail:**  
  Carefully validating changes and maintaining data integrity throughout the process.

## Conclusion
This is a project that highlights the importance of data cleaning as a foundational step in any analysis. Datasets are often
not perfectly clean, so there are many important steps to ensure that they have been prepared optimally and as accurately as possible.
By searching for irregularities and errors in the dataset, I transformed the raw data into a structured format suitable for analysis and possible modelling.

The explorartory data analysis revealed important trends in global layoffs during the COVID-19 pandemic. 
In this project I learned and demonstrated essential data preparation and analysis skills utilising SQL. 
Future work will be to expand on the EDA and possible make a Power BI dashboard.
