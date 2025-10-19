# SQL Practice Project - HR Database
A comprehensive SQL learning project using a custom HR database for advanced SQL query practice.

## Quick Start

### Step 1: Generate HR Database
#### 1. Clone the repository
```
git clone https://github.com/mingjie-wei/SQL_Guidebook.git
cd SQL_Guidebook
```

#### 2. Generate SQLite database
#### 2.1 Create hr database
```
def create_hr_database():
    # Create SQLite database
    conn = sqlite3.connect('company_hr.sqlite')
    cursor = conn.cursor()

    # Create table structure
    tables_sql = [
        """
        CREATE TABLE employees (
            emp_no INTEGER PRIMARY KEY,
            birth_date DATE NOT NULL,
            first_name TEXT NOT NULL,
            last_name TEXT NOT NULL,
            gender TEXT NOT NULL,
            hire_date DATE NOT NULL
        )
        """,
        """
        CREATE TABLE departments (
            dept_no TEXT PRIMARY KEY,
            dept_name TEXT NOT NULL UNIQUE
        )
        """,
        """
        CREATE TABLE dept_emp (
            emp_no INTEGER NOT NULL,
            dept_no TEXT NOT NULL,
            from_date DATE NOT NULL,
            to_date DATE NOT NULL,
            PRIMARY KEY (emp_no, dept_no),
            FOREIGN KEY (emp_no) REFERENCES employees(emp_no),
            FOREIGN KEY (dept_no) REFERENCES departments(dept_no)
        )
        """,
        """
        CREATE TABLE dept_manager (
            dept_no TEXT NOT NULL,
            emp_no INTEGER NOT NULL,
            from_date DATE NOT NULL,
            to_date DATE NOT NULL,
            PRIMARY KEY (dept_no, emp_no),
            FOREIGN KEY (emp_no) REFERENCES employees(emp_no),
            FOREIGN KEY (dept_no) REFERENCES departments(dept_no)
        )
        """,
        """
        CREATE TABLE salaries (
            emp_no INTEGER NOT NULL,
            salary INTEGER NOT NULL,
            from_date DATE NOT NULL,
            to_date DATE NOT NULL,
            PRIMARY KEY (emp_no, from_date),
            FOREIGN KEY (emp_no) REFERENCES employees(emp_no)
        )
        """,
        """
        CREATE TABLE titles (
            emp_no INTEGER NOT NULL,
            title TEXT NOT NULL,
            from_date DATE NOT NULL,
            to_date DATE NOT NULL,
            PRIMARY KEY (emp_no, title, from_date),
            FOREIGN KEY (emp_no) REFERENCES employees(emp_no)
        )
        """
    ]

    # Execute table creation statements
    for sql in tables_sql:
        cursor.execute(sql)

    # Insert sample data
    insert_sample_data(cursor)

    conn.commit()
    conn.close()
    print("✅ HR database created successfully: company_hr.sqlite")
```

#### 2.2 Insert sample data
```
def insert_sample_data(cursor):

    # Insert department data
    departments = [
        ('d001', 'Marketing'),
        ('d002', 'Finance'),
        ('d003', 'Human Resources'),
        ('d004', 'Production'),
        ('d005', 'Development'),
        ('d006', 'Quality Management'),
        ('d007', 'Sales'),
        ('d008', 'Research'),
        ('d009', 'Customer Service')
    ]
    cursor.executemany("INSERT INTO departments VALUES (?, ?)", departments)

    # Insert employee data (50 employees)
    employees = []
    first_names = ['John', 'Jane', 'Robert', 'Emily',
                   'Michael', 'Sarah', 'David', 'Lisa', 'James', 'Maria']
    last_names = ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones',
                  'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez']

    for i in range(1, 51):
        emp_no = 10000 + i
        birth_date = f"{random.randint(1960, 1990)}-{random.randint(1, 12):02d}-{random.randint(1, 28):02d}"
        first_name = random.choice(first_names)
        last_name = random.choice(last_names)
        gender = random.choice(['M', 'F'])
        hire_date = f"{random.randint(2010, 2023)}-{random.randint(1, 12):02d}-{random.randint(1, 28):02d}"
        employees.append((emp_no, birth_date, first_name,
                         last_name, gender, hire_date))

    cursor.executemany(
        "INSERT INTO employees VALUES (?, ?, ?, ?, ?, ?)", employees)

    # Insert department assignments
    dept_assignments = []
    for emp_no in range(10001, 10051):
        dept_no = random.choice(
            ['d001', 'd002', 'd003', 'd004', 'd005', 'd006', 'd007', 'd008', 'd009'])
        from_date = f"{random.randint(2015, 2023)}-{random.randint(1, 12):02d}-{random.randint(1, 28):02d}"
        to_date = '9999-01-01'  # Current employment
        dept_assignments.append((emp_no, dept_no, from_date, to_date))

    cursor.executemany(
        "INSERT INTO dept_emp VALUES (?, ?, ?, ?)", dept_assignments)

    # Insert department managers
    managers = [
        ('d001', 10001, '2018-01-01', '9999-01-01'),
        ('d002', 10005, '2019-03-15', '9999-01-01'),
        ('d003', 10012, '2020-06-01', '9999-01-01'),
        ('d004', 10018, '2017-11-01', '9999-01-01'),
        ('d005', 10025, '2021-02-01', '9999-01-01')
    ]
    cursor.executemany(
        "INSERT INTO dept_manager VALUES (?, ?, ?, ?)", managers)

    # Insert salary data
    salaries = []
    for emp_no in range(10001, 10051):
        base_salary = random.randint(50000, 120000)
        from_date = f"{random.randint(2015, 2023)}-{random.randint(1, 12):02d}-{random.randint(1, 28):02d}"
        to_date = '9999-01-01'
        salaries.append((emp_no, base_salary, from_date, to_date))

    cursor.executemany("INSERT INTO salaries VALUES (?, ?, ?, ?)", salaries)

    # Insert job titles data
    titles_data = []
    job_titles = ['Engineer', 'Senior Engineer', 'Manager',
                  'Analyst', 'Senior Analyst', 'Director', 'Assistant']

    for emp_no in range(10001, 10051):
        title = random.choice(job_titles)
        from_date = f"{random.randint(2015, 2023)}-{random.randint(1, 12):02d}-{random.randint(1, 28):02d}"
        to_date = '9999-01-01'
        titles_data.append((emp_no, title, from_date, to_date))

    cursor.executemany("INSERT INTO titles VALUES (?, ?, ?, ?)", titles_data)

```

#### 2.3 Expected output:
```
✅ HR database created successfully: company_hr.sqlite
```

### Step 2: Connect with DBeaver
#### 1. Open DBeaver

#### 2. Create new connection and select SQLite

#### 3. Database file: browse and select `company_hr.sqlite`

#### 4. Click "Finish"

### Step 3: Verify Connection
Run a test query to verify the database:
```
select * from departments limit 10;
```

## Database Schema
The HR database contains 6 tables with realistic relationships:

- `employees` - Employee master data

- `departments` - Department information

- `dept_emp` - Employee department assignments

- `dept_manager` - Department managers

- `salaries` - Salary records

- `titles` - Job title history

## SQL Practice Exercises
SELECT, WHERE, ORDER BY - Basic employee queries

JOIN Operations - Combine employee and department data

Aggregate Functions - Count, average, max/min analysis

GROUP BY & HAVING - Department-level summaries

CASE WHEN - Data transformation and categorization

Window Functions - Rankings and partitions

Common Table Expressions (CTE) - Complex query breakdown

Date Functions - Tenure and timeline analysis

LAG/LEAD - Temporal data comparison

UNION/EXCEPT - Set operations