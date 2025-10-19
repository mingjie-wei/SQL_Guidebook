
-- data inspection
select * from departments limit 10
select * from dept_emp limit 10
select * from dept_manager limit 10
select * from employees limit 10
select * from salaries limit 10
select * from titles limit 10

/******** 01 - basic sql queries  ********/

-- 1.1 Select all employees
select * from employees;


-- 1.2 Find female employees
select * from employees where gender = 'F';


-- 1.3 Employees hired after 2020
select * from employees where hire_date >= '2020-01-01' order by hire_date;
/* There is no year() function in SQLite*/


-- 1.4 Employees with specific last names
select * from employees where last_name in ('Williams', 'Jones');


-- 1.5 Count employees by gender
select gender, count(*) as cnt
from employees 
group by 1;


-- 1.6 Limit results with pagination
select emp_no, first_name, last_name, hire_date
from employees
order by hire_date desc
limit 10;


/******** 02 - join operations  ********/
--make one row invalid
update dept_emp 
set to_date = '2025-10-18'
where emp_no = 10001 and to_date = '9999-01-01';


-- 2.1 Employees with their departments (INNER JOIN)
select t1.emp_no
,t1.first_name
,t1.last_name
,t2.dept_no
,t3.dept_name
from employees t1
inner join dept_emp t2
	on t1.emp_no = t2.emp_no 
inner join departments t3
	on t2.dept_no = t3.dept_no
where t2.to_date = '9999-01-01'
;


-- 2.2 All departments with employee count (LEFT JOIN)
select t1.dept_name
,count(distinct t2.emp_no) as cnt
from departments t1
left join dept_emp t2
	on t1.dept_no = t2.dept_no and t2.to_date = '9999-01-01'
group by 1
order by 2 desc
;

-- 2.3 Department managers with employee details
select t1.dept_no
,t2.dept_name
,t3.first_name
,t3.last_name
,t1.from_date as manager_since
from dept_manager t1
left join departments t2
	on t1.dept_no = t2.dept_no 
left join employees t3
	on t1.emp_no = t3.emp_no 
where t1.to_date = '9999-01-01'
;

-- 2.4 Multiple JOIN types example
select t1.emp_no
,t1.first_name
,t1.last_name
,t2.dept_name
,t3.title
,t4.salary
from employees t1
left join dept_emp t0 
	on t0.emp_no = t1.emp_no
left join departments t2 
	on t0.dept_no = t2.dept_no
left join titles t3 
	on t1.emp_no = t3.emp_no
left join salaries t4 
	on t1.emp_no = t4.emp_no
where t0.to_date = '9999-01-01'
    and t3.to_date = '9999-01-01'
    and t4.to_date = '9999-01-01'
;

