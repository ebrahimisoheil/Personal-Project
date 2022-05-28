# About the task:


##### 1st Exercise is done in data-ingestion-Copy1.ipynb

- Fetching data from API, Validation, and loading to sqlite DB

##### 2nd Exercise 

- Data modeling scripts are saved as queries in stg_to_dim.sql file
I have created factless fact tables based on the most granular levels of activities: posts, comments

##### 3rd Exercise

- The queries are in the stg_to_dim.sql file

##### 4th Exercise

- Ideal Architecture and modeling for the project:

Data Source/ Data Lake
1 - Fetching data using an Airflow task and Spark
2 - Loading Data into a Scalable DB 
3 - Monitoring Airflow tasks with Prometheus and Grafana
Staging Layer
1- Loading data to staging area using DBT
2- Data Validation
DW Layer
1- Designing Dims and Facts based on the docs and load data to dw using DBT
Analytical 
1- Create OBTs for high performance analysis

