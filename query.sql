
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

-- 2.3 Department managers with employee details (RIGHT JOIN)
select t1.dept_no
,t2.dept_name
,t3.first_name
,t3.last_name
,t1.from_date as manager_since
from departments t2
right join dept_manager t1
	on t1.dept_no = t2.dept_no 
right join employees t3
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
join dept_emp t0 
	on t0.emp_no = t1.emp_no
join departments t2 
	on t0.dept_no = t2.dept_no
join titles t3 
	on t1.emp_no = t3.emp_no
join salaries t4 
	on t1.emp_no = t4.emp_no
where t0.to_date = '9999-01-01'
    and t3.to_date = '9999-01-01'
    and t4.to_date = '9999-01-01'
;


/******** 03 - aggregate functions  ********/

-- 3.1 Department salary statistics
select t1.dept_name
,count(distinct t2.emp_no) as emp_cnt
,round(avg(t3.salary),2) as avg_salary
,min(t3.salary) as min_salary
,max(t3.salary) as max_salary
,sum(t3.salary) as total_salary
from departments t1
left join dept_emp t2
	on t1.dept_no = t2.dept_no 
left join salaries t3
	on t2.emp_no = t3.emp_no
where t2.to_date = '9999-01-01'
	and t3.to_date = '9999-01-01'
group by t1.dept_name
order by avg_salary desc
;

-- 3.2 HAVING clause - departments with high average salary
select t1.dept_name
,count(distinct t2.emp_no) as emp_cnt
,round(avg(t3.salary),2) as avg_salary
from departments t1
left join dept_emp t2
	on t1.dept_no = t2.dept_no 
left join salaries t3
	on t2.emp_no = t3.emp_no
where t2.to_date = '9999-01-01'
	and t3.to_date = '9999-01-01'
group by t1.dept_name
having avg(t3.salary) > 80000
order by avg_salary desc
;


/******** 04 - window functions  ********/

-- 4.1 Salary ranking within departments
select t1.emp_no
,t1.first_name
,t1.last_name
,t2.dept_name
,t3.salary
,rank() over(partition by t2.dept_name order by t3.salary desc) as salary_rank
,round(percent_rank() over(partition by t2.dept_name order by t3.salary),3) as percentile_rank
from employees t1
left join dept_emp t0 
	on t1.emp_no = t0.emp_no 
left join departments t2
	on t0.dept_no = t2.dept_no 
left join salaries t3
	on t1.emp_no = t3.emp_no
where t0.to_date = '9999-01-01'
    and t3.to_date = '9999-01-01'
order by t2.dept_name, salary_rank
;

-- 4.2 Moving average and cumulative salary
select t3.dept_no
,t1.hire_date
,t1.first_name
,t1.last_name
,t2.salary
,round(avg(t2.salary) over(
	partition by t3.dept_no order by t1.hire_date
	rows between 2 preceding and current row),2) as moving_avg_salary
,sum(t2.salary) over(
	partition by t3.dept_no order by t1.hire_date) as cumulative_dept_salary
from employees t1
left join salaries t2
	on t1.emp_no = t2.emp_no 
left join dept_emp t3
	on t1.emp_no = t3.emp_no 
where t2.to_date = '9999-01-01'
    and t3.to_date = '9999-01-01'
order by t3.dept_no, t1.hire_date
;

-- 4.3 LAG and LEAD for salary comparison
select t1.emp_no
,t1.hire_date 
,t4.title
,t3.salary as current_salary
,lag(t3.salary) over (partition by t4.title order by t1.hire_date) as previous_salary
,lead(t3.salary) over (partition by t4.title order by t1.hire_date) as next_salary
from employees t1
left join dept_emp t0
	on t1.emp_no = t0.emp_no
left join departments t2
	on t0.dept_no = t2.dept_no
left join salaries t3
	on t1.emp_no = t3.emp_no
left join titles t4
	on t1.emp_no = t4.emp_no
where t0.to_date = '9999-01-01'
	and t4.to_date = '9999-01-01'
order by t4.title, t1.hire_date
;


/******** 05 - cte  ********/
-- 5.1 Multiple CTEs for high_earners analysis
with high_earners as (
	select t1.emp_no
	,t1.first_name
	,t1.last_name
	,t3.salary
	,t2.dept_name
	from employees t1
	left join dept_emp t0
		on t1.emp_no = t0.emp_no 
	left join departments t2
		on t0.dept_no = t2.dept_no 
	left join salaries t3
		on t1.emp_no = t3.emp_no 
	where t3.salary > 100000
		and t3.to_date = '9999-01-01'
		and t0.to_date = '9999-01-01'
),
dept_high_earners as (
	select dept_name
	,count(*) as high_earner_count
	from high_earners 
	group by 1
)

select 
    d.dept_name,
    count(de.emp_no) as total_employees,
    coalesce(dhec.high_earner_count, 0) as high_earners,
    round(coalesce(dhec.high_earner_count, 0) * 100.0 / count(de.emp_no), 2) as high_earner_percentage
from departments d
left join dept_emp de 
	on d.dept_no = de.dept_no and de.to_date = '9999-01-01'
left join dept_high_earners dhec 
	on d.dept_name = dhec.dept_name
group by d.dept_name, dhec.high_earner_count
order by high_earner_percentage desc
;


/******** 06 - data transformation  ********/

-- 6.1 CASE WHEN for salary categorization
select t1.emp_no
,t1.first_name
,t1.last_name
,t2.dept_name
,t3.salary
,case when t3.salary < 60000 then 'Entry Level'
      when t3.salary between 60000 and 90000 then 'Mid Level'
      when t3.salary between 90001 and 120000 then 'Senior Level'
      else 'Executive'
    end as salary_grade
,case when t1.gender = 'M' then 'Male'
      when t1.gender = 'F' then 'Female'
      else 'Other'
    end as gender_full
from employees t1
left join dept_emp t0 
	on t1.emp_no = t0.emp_no
left join departments t2 
	on t0.dept_no = t2.dept_no
left join salaries t3 
	on t1.emp_no = t3.emp_no
where t0.to_date = '9999-01-01'
    and t3.to_date = '9999-01-01'
order by t3.salary desc
;

-- 6.2 String manipulation and formatting
SELECT 
    emp_no,
    first_name,
    last_name,
    UPPER(first_name) as first_name_upper,
    LOWER(last_name) as last_name_lower,
    first_name || ' ' || last_name as full_name,
    LENGTH(first_name) as first_name_length,
    SUBSTR(first_name, 1, 3) as name_prefix,
    REPLACE(gender, 'M', 'Male') as gender_full
FROM employees
LIMIT 10;

/******** 07 - date functions  ********/

-- 7.1 Employee tenure calculation
select emp_no
,first_name
,hire_date
,date() as current_date
,julianday(date()) - julianday(hire_date) as days_employed
,round((julianday(date()) - julianday(hire_date)) / 365.25, 2) as years_employed
,case when (julianday(date()) - julianday(hire_date)) / 365.25 >= 5 then 'senior'
      when (julianday(date()) - julianday(hire_date)) / 365.25 >= 2 then 'mid-level'
      else 'junior'
    end as experience_level
from employees
where hire_date is not null
order by years_employed desc
;

/******** 08 - interview-practice  ********/

-- 8.1 find the second highest salary in each department
with rankedsalaries as (
    select e.emp_no,
        e.first_name,
        e.last_name,
        d.dept_name,
        s.salary,
        dense_rank() over (partition by d.dept_name order by s.salary desc) as salary_rank
    from employees e
    left join dept_emp de 
    	on e.emp_no = de.emp_no
    left join departments d 
    	on de.dept_no = d.dept_no
    left join salaries s 
    	on e.emp_no = s.emp_no
    where de.to_date = '9999-01-01'
        and s.to_date = '9999-01-01'
)
select emp_no,
    first_name,
    last_name,
    dept_name,
    salary
from rankedsalaries
where salary_rank = 2
;

-- 8.2 employees who are managers (self-join concept)
select 
    e.emp_no,
    e.first_name,
    e.last_name,
    d.dept_name,
    'manager' as role_type
from employees e
join dept_manager dm on e.emp_no = dm.emp_no
join departments d on dm.dept_no = d.dept_no
where dm.to_date = '9999-01-01'

union

select 
    e.emp_no,
    e.first_name,
    e.last_name,
    d.dept_name,
    'regular employee' as role_type
from employees e
join dept_emp de on e.emp_no = de.emp_no
join departments d on de.dept_no = d.dept_no
left join dept_manager dm on e.emp_no = dm.emp_no and dm.to_date = '9999-01-01'
where de.to_date = '9999-01-01'
    and dm.emp_no is null
;

-- 8.3 find departments where average salary is above company average
with companystats as (
    select 
        avg(s.salary) as company_avg_salary
    from salaries s
    where s.to_date = '9999-01-01'
)
select 
    d.dept_name,
    count(distinct e.emp_no) as employee_count,
    round(avg(s.salary), 2) as dept_avg_salary,
    cs.company_avg_salary,
    round(avg(s.salary) - cs.company_avg_salary, 2) as difference_from_avg
from departments d
join dept_emp de on d.dept_no = de.dept_no
join employees e on de.emp_no = e.emp_no
join salaries s on e.emp_no = s.emp_no
cross join companystats cs
where de.to_date = '9999-01-01'
    and s.to_date = '9999-01-01'
group by d.dept_name, cs.company_avg_salary
having avg(s.salary) > cs.company_avg_salary
order by difference_from_avg desc
;

-- 8.4 find employees with the same salary (duplicate detection)
select 
    s1.salary,
    e1.emp_no as emp1_id,
    e1.first_name as emp1_first_name,
    e1.last_name as emp1_last_name,
    e2.emp_no as emp2_id,
    e2.first_name as emp2_first_name,
    e2.last_name as emp2_last_name
from salaries s1
join salaries s2 on s1.salary = s2.salary and s1.emp_no < s2.emp_no
join employees e1 on s1.emp_no = e1.emp_no
join employees e2 on s2.emp_no = e2.emp_no
where s1.to_date = '9999-01-01'
    and s2.to_date = '9999-01-01'
order by s1.salary desc
limit 10
;
