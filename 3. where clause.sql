-- where clause
select *from parks_and_recreation.employee_salary;

select *
from parks_and_recreation.employee_salary
where salary >= 50000;# where query is select * from database.table where condtion

-- logical operater AND OR NOT
select *
from parks_and_recreation.employee_salary
where salary >= 50000 AND employee_id > 5;# selecr * from database.table where codition with AND operator

select *
from parks_and_recreation.employee_demographics
where (first_name = 'Leslie' AND age = 44) or age > 50 ; # select * from database.table where condtion with AND ,OR operator

-- like statement 
-- symbol is denoted by % or __ 
select * from parks_and_recreation.employee_demographics
where first_name like 'jer%'; #select *from database.table where column_name like'%' 


select * from parks_and_recreation.employee_demographics
where first_name like '%er%'; #select *from database.table where column_name like'%' 


select * from parks_and_recreation.employee_demographics
where first_name like 'a__'; #select *from database.table where column_name like'__' 

