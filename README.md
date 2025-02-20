> **Note:**  This is done with the understanding that I have to perform this analysis keeping engineering practices in mind and creating an ideal structure which is scalable, I have added the reports at the end in the semantic layer as well which can be connected to any dashboard and can provide the required information. 

# Setting up environment on macos
Run the following command
```sh script.sh```
____
# DBT using postres database

1. I am assuming you have a postgres connection
2. I have setup a postgres on local host
3. Additionally I have created various schemas in order to differentiate between the stages of tranformation namely:

    - dl_capacity_data: stores the raw data in this layer
    - stage_capacity_data: will store the flattened structure or data with basic transformations
    - dl_capacity_data: will store facts and marts after modelling
    - sl_capacity_data: will store aggregated data


4. I have used the following sql code to achieve this, In future we can manage this using terraform:

`create schema stage_capacity_data;
create schema dm_capacity_data;
create schema sl_capacity_data;
create schema dl_capacity_data;`

___

## Populating data in Datalake

All the files that have been shared has been stored in the data lake layer using seeds from dbt, you can use the following command to run all seeds

    dbt seed --target dev --profiles-dir ../

___

## Populating data in Staging layer

Basic data cleanups, standardisation and fixing the timezone issues will be taken care of here

___

## Populating data in Datamarts

Ideally i would convert the data into dims and facts and i have a different plan for data models but for simplicity i am just converting them to views here and additionally creating the fact_dates here which is useful for me further

___


___

## Populating data in Reports

I am creating three reports in the reporting layer which we can use with the dashboards to reflect the information required

___

___

## Test for data quality

I have added around * 28 tests * on the source data to ensure data integrity and quality of the data we recieve from the source.

And around * 40 tests * at the stage layer, Data marts here would not need the tests because they are views so adding tests would not add value

Ideally i would setup more in the stage and marts after discussions with analysts and business stakeholders. you can use the following command to run the tests at the source.

`dbt test --target dev --profiles-dir ../ --select seeds/*`

Following is the command to run all tests at stage:

`dbt test --target dev --profiles-dir ../ --select models/stage/*`
___


# High level picture of architetcure
![Alt text for image](high_level_arch.jpg)



___

## Orchestration in Airflow [Later stage]

All the commands will be run in the airflow later

