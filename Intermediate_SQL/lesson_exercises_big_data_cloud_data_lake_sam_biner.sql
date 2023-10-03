/*
### S3 Data Lake Setup

# Create S3 bucket in us-east-1: lesson-exercises-fname-lname
	Done on the AWS website

# Connect to CloudShell
	Done on the AWS website

### Unpartitioned Dataset
# List the S3 bucket via the aws cli
	"aws s3 ls"

# Confirm you're in the home directory
	"pwd"

# Make a data directory
	"mkdir data"

# Change into the data directory
	"cd data"

# Confirm you're in the data directory
	"pwd"

# Download https://lesson-exercises-data.s3.amazonaws.com/state-names-unpartitioned.csv.gz to CloudShell
	"wget https://lesson-exercises-data.s3.amazonaws.com/state-names-unpartitioned.csv.gz"

# Confirm the dataset was downloaded
	"ls"

# Decompress state-names-unpartitioned.csv.gz
	"gunzip state-names-unpartitioned.csv.gz"

# View first 10 rows of state-names-unpartitioned.csv
	"head state-names-unpartitioned.csv"

# Confirm all 5,647,426 rows present
	"wc -l state-names-unpartitioned.csv"

# Copy state-names-unpartitioned.csv to state-names-unpartitioned folder in S3 bucket (S3 will create the folder if it doesn't exist)
	"aws s3 cp state-names-unpartitioned.csv s3://lesson-exercises-sam-biner/state-names-unpartitioned/"

# Confirm state-names-unpartitioned.csv is in the S3 bucket via the aws cli
	"aws s3 ls s3://lesson-exercises-sam-biner/state-names-unpartitioned/"

# Confirm state-names-unpartitioned.csv is in the S3 bucket via the AWS S3 console
	Go to the AWS S3 dashboard and click down into the folder and it should show the file has been added


*/




-- Create lesson_exercises database
	-- CREATE DATABASE lesson_exercises;

-- ### Unpartitioned Table

-- Create state_names_unpartitioned table
-- https://docs.aws.amazon.com/athena/latest/ug/data-types.html
-- https://docs.aws.amazon.com/athena/latest/ug/supported-serdes.html


CREATE EXTERNAL TABLE lesson_exercises.state_names_unpartitioned (
    `state_name_id` INT,
    `name` STRING,
    `year` INT,
    `gender` STRING,
    `state` STRING,
    `name_count` INT
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
    'separatorChar' = ','
)
LOCATION 's3://lesson-exercises-sam-biner/state-names-unpartitioned/'
TBLPROPERTIES (
    'has_encrypted_data' = 'false'
);



-- Select the first 10 rows from the table
SELECT *
FROM lesson_exercises.state_names_unpartitioned
LIMIT 10;
-- 


-- Count the # of rows in the state_names_unpartitioned table
SELECT COUNT(*)
FROM lesson_exercises.state_names_unpartitioned;
-- Run time: 4.995 sec; Data scanned: 147.53 MB


-- Count the # of rows by year for females
SELECT `year`,
	COUNT(*)
FROM lesson_exercises.state_names_unpartitioned
WHERE gender = 'F'
GROUP BY `year`;
-- Run time: 4.997 sec; Data scanned: 147.53 MB


-- Count the # of rows by year for females in California
SELECT 
    `year`,
    COUNT(*)
FROM lesson_exercises.state_names_unpartitioned
WHERE gender = 'F' 
    AND state = 'CA'
GROUP BY `year`;
-- Run time: 4.98 sec; Data scanned: 147.53 MB
-- Run time: 1.387 sec; Data scanned: 4.36 MB


-- ### Partitioned Table

-- Determine partions based on cardinality
SELECT COUNT(DISTINCT gender) AS gender_cardinality,
    COUNT(DISTINCT `year`) AS year_cardinality,
    COUNT(DISTINCT state) AS state_cardinality,
    COUNT(DISTINCT name) AS name_cardinality
FROM lesson_exercises.state_names_unpartitioned;
-- Run time: 6.44 sec; Data scanned: 147.53 MB

/*
Bash script to create partitioned file directory structure.

parse_state_names.sh:

#!/bin/bash

file="$1"
echo "file: $file"

while IFS="," read state_name_id name year gender state name_count
do
	mkdir -p /home/ec2-user/data/state-names-partitioned/gender=$gender/state=$state
	echo "$state_name_id,$name,$year,$name_count" >> /home/ec2-user/data/state-names-partitioned/gender=$gender/state=$state/data.csv
done < $file
-------------------------------------------------------------------------------------------
[ec2-user@ip-172-31-25-164 scripts]$ time sh parse_state_names.sh ../data/state-names-unpartitioned.csv
file: ../data/state-names-unpartitioned.csv

real    97m42.079s
user    77m11.414s
sys     19m47.577s
*/


/*

### Partitioned Dataset

# Download https://lesson-exercises-data.s3.amazonaws.com/state-names-partitioned.tar.gz to CloudShell
	"wget https://lesson-exercises-data.s3.amazonaws.com/state-names-partitioned.tar.gz"

# Confirm the dataset was downloaded
	"ls"

# Extract state-names-partitioned.tar.gz
	"tar xzvf state-names-partitioned.tar.gz"

# Confirm the dataset was extracted by recursively listing the directories under state-names-partitioned
	"ls -R state-names-partitioned"

# View first 10 rows of a sample data.csv file
	"head state-names-partitioned/gender=F/state=SC/data.csv"

# Verify a row was added to the correct partition folder
	"grep 'Annie,1910,' state-names-unpartitioned.csv | grep SC"

# Recursively copy state-names-partitioned/ to state-names-partitioned folder in S3 bucket (S3 will create the folder if it doesn't exist)
	"aws s3 cp --recursive state-names-partitioned/ s3://lesson-exercises-sam-biner/state-names-partitioned/"

# Confirm the state-names-partitioned folder is in the S3 bucket via the aws cli
	"aws s3 ls s3://lesson-exercises-sam-biner/state-names-partitioned/"

# Confirm the state-names-partitioned folder is in the S3 bucket via the AWS S3 console

*/

-- Create state_names_partitioned table

CREATE EXTERNAL TABLE lesson_exercises.state_names_partitioned (
    `state_name_id` INT,
    `name` STRING,
    `year` INT,
    `name_count` INT
)
PARTITIONED BY (
    `gender` STRING,
    `state` STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
    'separatorChar' = ','
)
LOCATION 's3://lesson-exercises-sam-biner/state-names-partitioned/'
TBLPROPERTIES (
    'has_encrypted_data' = 'false'
);


-- Select the first 10 rows from the table
SELECT *
FROM lesson_exercises.state_names_partitioned
LIMIT 10;
-- 

-- Load partitions to view the data
MSCK REPAIR TABLE lesson_exercises.state-names-partitioned;
--


-- Select the first 10 rows from the table
SELECT *
FROM lesson_exercises.state_names_partitioned
LIMIT 10;
-- Run time: 1.6 sec; Data scanned: 837.81 KB


-- Count the # of rows in the state_names_partitioned table
SELECT COUNT(*)
FROM lesson_exercises.state_names_partitioned;
-- Run time: 2.984 sec; Data scanned: 120.60 MB


-- Count the # of rows by year for females
SELECT `year`, 
    COUNT(*)
FROM lesson_exercises.state_names_partitioned
WHERE gender = 'F'
GROUP BY `year`;
-- Run time: 2.552 sec; Data scanned: 67.60 MB


-- Count the # of rows by year for females in California
SELECT `year`, 
    COUNT(*)
FROM lesson_exercises.state_names_partitioned
WHERE gender = 'F'
    AND state = 'CA'
GROUP BY `year`;
-- Run time: 1.387 sec; Data scanned: 4.36 MB


-- ### Partitioned, Compressed, Columnar Table
-- Partitioned table in Parquet columnar storage format with Snappy compression
-- https://docs.aws.amazon.com/athena/latest/ug/compression-formats.html

-- Create state_names_partitioned_parquet_snappy table using CTAS (Create Table As Select)


--


-- Confirm the state-names-partitioned-parquet-snappy folder is in the S3 bucket via the AWS S3 console
CREATE TABLE lesson_exercises.state_names_partitioned_parquet_snappy 
WITH (
	format = 'Parquet',
	parquet.compression = 'SNAPPY',
	partitioned_by = ARRAY['gender', 'state'],
	external_location = 's3://lesson-exercises-sam-biner/state-names-partitioned-parquet-snappy/'
) AS SELECT = 
FROM lesson_exercises.state_names_partitioned;


-- Select the first 10 rows from the table
SELECT *
FROM lesson_exercises.state_names_partitioned_parquet_snappy
LIMIT 10;
-- Run time: 1.174 sec; Data scanned: 327.01 KB


-- Count the # of rows in the state_names_partitioned_parquet_snappy table
SELECT COUNT(*)
FROM lesson_exercises.state_names_partitioned_parquet_snappy;
-- Run time: 1.213 sec; Data scanned: 0


-- Count the # of rows by year for females
SELECT `year`, 
    COUNT(*)
FROM lesson_exercises.state_names_partitioned_parquet_snappy
WHERE gender = 'F'
GROUP BY `year`;
-- Run time: 1.059 sec; Data scanned: 49.59 KB


-- Count the # of rows by year for females in California
SELECT `year`, 
    COUNT(*)
FROM lesson_exercises.state_names_partitioned_parquet_snappy
WHERE gender = 'F'
    AND state = 'CA'
GROUP BY `year`;
-- Run time: 953 ms; Data scanned: 1.51 KB


-- Compare to indexes queries
-- One column in WHERE

--
-- 1: 263ms
-- 2: 289ms
-- 3: 255ms


-- Two columns in WHERE

--
-- 1: 276ms
-- 2: 248ms
-- 3: 266ms


-- Three columns in WHERE

-- 1: ???
-- 2: ???
-- 3: ???

