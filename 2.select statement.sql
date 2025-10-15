select * 
from parks_and_recreation.employee_demographics; # dataabase is selected in query , the query is  select * from database.table

select 
first_name , 
last_name, 
age 
from parks_and_recreation.employee_demographics;# for specific column query is , select column_name from database.table 

#PEMDAS

select 
first_name , 
last_name, 
age ,
age + 10
from parks_and_recreation.employee_demographics;# here we create the new columns in query

select distinct gender 
from parks_and_recreation.employee_demographics;# its give the unique output


