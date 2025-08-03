create database user;

use user;

create table department(
id BIGINT PRIMARY KEY AUTO_INCREMENT,
department_name VARCHAR(20) NOT NULL UNIQUE
);

create table employee (
id BIGINT PRIMARY KEY AUTO_INCREMENT,
employee_name VARCHAR(20) NOT NULL,
email VARCHAR(100) NOT NULL UNIQUE,
salary INT,
department_id BIGINT,
date_joined DATE NOT NULL,
FOREIGN KEY(department_id) REFERENCES department(id)
);

create table project(
id BIGINT PRIMARY KEY,
project_name VARCHAR(20) NOT NULL UNIQUE,
startdate DATE,
enddate DATE,
budget DECIMAL(10,2)
);

create table employee_project(
employee_id BIGINT,
project_id BIGINT,
allocation_percentage INT CHECK ( allocation_percentage BETWEEN 0 AND 100),
PRIMARY KEY (employee_id, project_id),
FOREIGN KEY(employee_id) references employee(id),
FOREIGN KEY(project_id) references project(id)
);


INSERT into department (department_name) VALUES
('Sales'),
('HR'),
('Marketing');



INSERT into employee (employee_name, email, salary, department_id, date_joined) VALUES
('Alice', 'alice@example.com', 90000, 1, '2021-03-10'),
('Bob', 'bob@example.com', 85000, 1, '2022-06-15'),
('Charlie', 'charlie@example.com', 60000, 2, '2020-09-01'),
('Diana', 'diana@example.com', 65000, 2, '2019-12-12'),
('Eve', 'eve@example.com', 50000, 3, '2023-01-01'),
('Frank', 'frank@example.com', 55000, 4, '2023-03-15'),
('Grace', 'grace@example.com', 70000, 1, '2024-01-20');

INSERT INTO project (id, project_name, startdate, enddate, budget) VALUES
(101, 'Alpha', '2023-01-01', '2023-06-30', 100000.00),
(102, 'Beta', '2023-03-15', '2023-09-15', 200000.00),
(103, 'Gamma', '2022-07-01', '2023-01-01', 150000.00),
(104, 'Delta', '2024-01-01', '2024-12-31', 300000.00);

INSERT INTO employee_project (employee_id, project_id, allocation_percentage) VALUES
(1, 101, 50),
(2, 101, 50),
(1, 102, 30),
(3, 102, 70),
(4, 103, 100),
(5, 104, 100),
(6, 101, 20),
(6, 104, 30),
(7, 104, 50);


--  🔹 Basic SELECTs and Filters
use user;
-- 1. Retrieve all employees and their department names.
select e.*, d.department_name from employee e LEFT join department d ON e.department_id = d.id; -- null employees included
select e.*, d.department_name from employee e JOIN department d ON e.department_id = d.id; -- null employees dont appear

-- 2. List all projects with their start and end dates.
select p. project_name, p.startdate, p.enddate from project p;


-- 3. Get all employees who joined after Jan 1, 2022.
select * from employee where date_joined > '2022-01-01';
select * from employee where YEAR(date_joined) > 2023;

-- 4. Find employees with salaries greater than 70,000.
select * from employee where salary>70000;

-- 5. Show all employees who are not assigned to any project.
select e.* from employee e LEFT JOIN employee_project ep on e.id = ep.project_id where ep.project_id = null;

-- 6. List all employees in the 'Engineering' department.
select e.* from employee e JOIN department d ON e.department_id = d.id where d.department_name = 'Engineering';

-- 7. Display the project names and the number of employees assigned to each.
select p.project_name, count(ep.employee_id) as count from project p LEFT JOIN employee_project ep ON p.id = ep.project_id group by p.id, p.project_name;

-- 8. Get employee names who are working on the 'Alpha' project.
select e.employee_name from employee e
JOIN employee_project ep on e.id = ep.employee_id
JOIN project p on p.id = ep.project_id
where p.project_name = "Alpha";

-- 9. List departments with more than 1 employee.
select d.department_name, COUNT(d.id) as count from department d JOIN employee e on e.department_id = d.id
group by d.id having COUNT(d.id) >1;

-- 10. Get project details where budget is more than 150000.
select * from project where budget>150000;

-- 11. Find the average salary by department.
select AVG(e.salary) as average_salary, d.department_name from employee e JOIN department d
on e.department_id = d.id group by d.id;

-- 12. Find the maximum and minimum salary in the company.
select MAX(salary) as max_salary, MIN(salary) as min_salary from employee;

-- 13. Count number of employees in each department.
select COUNT(*) as employee_count, d.department_name from employee e JOIN department d ON e.department_id = d.id group by d.id;

-- 14. Get the total budget allocated across all projects.
select SUM(budget) as total_budget from project;

-- 15. For each project, find the total allocation percentage.
select SUM(ep.allocation_percentage) as total_allocation, p.project_name from employee_project ep JOIN project p on ep.project_id = p.id group by p.id;

-- 16. Show the total number of projects each employee is working on.
select COUNT(e.id) as emp_count, p.project_name from employee e
LEFT JOIN employee_project ep ON e.id = ep.employee_id
JOIN project p ON ep.project_id = p.id
 group by ep.project_id;

select COUNT(p.id) as project_count, e.id from employee e
LEFT JOIN employee_project ep ON e.id = ep.employee_id
JOIN project p ON ep.project_id = p.id
group by e.id;


-- 17. Get departments with total salary exceeding 100,000.
select d.department_name from department d JOIN employee e ON d.id = e.department_id
 group by d.id, d.department_name having SUM(e.salary) > 100000;

-- 18. List top 2 highest-paid employees from each department.
select e.id, e.employee_name, e.salary, d.department_name from employee e JOIN department d ON e.department_id = d.id
where (select COUNT(*) from employee e2 where e2.department_id = e.department_id AND e2.salary > e.salary) < 2
order by d.department_name, e.salary;

-- 19. Find the total number of employees who joined per year.
select count(*) as employee_count, year(date_joined) from employee group by YEAR(date_joined);

-- 20. Get the project that has the maximum budget.
select * from project where budget=(select MAX(budget) from project);

-- 21. Find employees who earn more than the average salary.
select * from employee where salary > (select AVG(salary) from employee);

-- 22. List projects that no employees are assigned to.
select p.project_name from project p LEFT JOIN employee_project ep ON p.id = ep.project_id where ep.project_id is null;

-- 23. Get employees working on all projects (i.e., common across all).
select * from employee e JOIN employee_project ep ON e.id = ep.employee_id
group by e.id having COUNT(ep.project_id) = (select COUNT(id) from project);

-- 24. Find departments with at least one employee having salary > 80000.
select d.id, d.department_name, count(e.id) from employee e JOIN department d ON e.department_id = d.id
group by d.id, d.department_name having MAX(e.salary) > 80000;

-- 25. Get employees who are working on the most expensive project.
select e.id, e.employee_name from employee e JOIN employee_project ep on e.id = ep.employee_id
JOIN project p ON ep.project_id = p.id where p.budget = (select MAX(p.budget) from project);

-- 26. Display all employees with their department names, even if the department is missing.
select e.*, d.department_name from employee e LEFT JOIN department d ON e.department_id = d.id;


-- 27. Show all projects and the employees working on them (even if no employees assigned).
select e.*, p.project_name from project p LEFT JOIN employee_project ep ON p.id = e
JOIN project p ON ep.project_id = p.id;

-- 28. List employees and their project names with allocation percentages.
select e.*, p.project_name, ep.allocation_percentage from employee e
JOIN employee_project ep ON e.id = ep.employee_id
JOIN project p ON p.id = ep.project_id;

-- 29. Show each department’s employee count including departments with 0 employees.
select d.department_name, count(e.id) as count from employee e RIGHT JOIN department d ON e.department_id = d.id group by d.id;

-- 30. Get a list of all employees and the total number of hours (allocation %) they are assigned.
select e.*, sum(ep.allocation_percentage) from employee e LEFT JOIN employee_project ep ON e.id = ep.employee_id group by e.id;

-- 31. Rank employees by salary in each department.
select e.id, d.department_name, e.salary,
RANK() OVER(PARTITION by d.id order by e.salary desc) AS salary_rank
from employee e JOIN department d on e.department_id = d.id;

-- 32. Find the employee with the earliest joining date in each department.
with ranked_employees AS (
select e.id, d.id as department_id, d.department_name,
RANK() OVER(partition by d.id order by e.date_joined asc ) as joinRank
from employee e JOIN department d on e.department_id = d.id
)
select * from ranked_employees where joinRank = 1;

-- 33. Calculate the running total of project budgets ordered by start date.
select * from project order by startdate ;

-- 34. Find employees whose salary is greater than the department average (using window function).
select e.* from employee e where e.salary > (select AVG(salary) from employee where e.department_id = department_id);

-- 35. Assign row numbers to all employees ordered by date_joined.
SELECT e.*, ROW_NUMBER() OVER (ORDER BY e.date_joined) AS row_num FROM employee e;

-- 36. Get employees who joined in the last 6 months.
select * from employee where MONTH(date_joined) < MONTH(NOW());
select * from employee where date_joined >= CURDATE() - interval 6 month;

-- 37. List projects that are currently ongoing (between startdate and enddate).
select * from project where startdate <= CURDATE() AND enddate >= CURDATE();

-- 38. Show how long (in days) each project lasted.
select p.*, datediff(p.startdate , p.enddate) as days from project p;

-- 39. Find employees who joined in the same year a project started.
select e.id, e.employee_name from employee e JOIN employee_project ep ON e.id = ep.employee_id
JOIN project p ON ep.project_id = p.id where YEAR(e.date_joined) = YEAR(p.startdate);

-- 40. Get projects that started in 2023.
select * from project where YEAR(startdate) = 2023;

-- 41. List each employee with a column showing “High”, “Medium”, or “Low” salary.
select id, employee_name, salary,
CASE
WHEN salary >80000 THEN "HIGH"
WHEN salary >60000 THEN "MEDIUM"
ELSE "LOW"
END
AS salary_level
from employee;


-- 42. Show employees who are not in ‘HR’ or ‘Marketing’.
select * from employee e LEFT JOIN department d ON e.department_id = d.id where
d.department_name not in ('HR', 'Marketing');

-- 43. For each employee, show department, project count, and total allocation %.
select e.id, e.employee_name, d.department_name, COUNT(e.id), SUM(ep.allocation_percentage) from employee e
JOIN department d ON e.department_id = d.id
JOIN employee_project ep ON e.id = ep.employee_id group by e.id;

-- 44. List departments where average salary is above company average.
select d.id, d.department_name from department d JOIN employee e ON d.id = e.department_id
group by d.id having AVG(e.salary) > (SELECT AVG(salary) from employee);

-- 45. Find unallocated project budget (budget - allocated employees * % * avg salary).
SELECT
  p.id AS project_id,
  p.project_name,
  p.budget,
  COALESCE(SUM(ep.allocation_percentage / 100 * e.salary), 0) AS allocated_amount,
  p.budget - COALESCE(SUM(ep.allocation_percentage / 100 * e.salary), 0) AS unallocated_budget
FROM project p
LEFT JOIN employee_project ep ON p.id = ep.project_id
LEFT JOIN employee e ON ep.employee_id = e.id
GROUP BY p.id, p.project_name, p.budget;



