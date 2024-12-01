CREATE TABLE employees (
    employee_ID VARCHAR(7) PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    current_dept VARCHAR(8) NOT NULL,
    current_position VARCHAR(20) NOT NULL,
    phone VARCHAR(15),
    email VARCHAR(30)
);

CREATE TABLE employees_detail (
    employee_ID VARCHAR(7) PRIMARY KEY,
    resident_number CHAR(13) NOT NULL,
    address VARCHAR(255),
    cellphone VARCHAR(15),
    bank_account VARCHAR(20),
    FOREIGN KEY (employee_ID) REFERENCES employees(employee_ID)
);

CREATE TABLE departments (
    dept_ID VARCHAR(7) PRIMARY KEY,
    dept_name VARCHAR(10) NOT NULL,
    upper_dept_ID VARCHAR(7),
    FOREIGN KEY (upper_dept_ID) REFERENCES departments(dept_ID) ON DELETE SET NULL
);

CREATE TABLE position_history (
    pos_history_ID VARCHAR(7) PRIMARY KEY,
    employee_ID VARCHAR(7) NOT NULL,
    dept_ID VARCHAR(7) NOT NULL,
    position VARCHAR(20),
    start_date DATE NOT NULL,
    end_date DATE,
    FOREIGN KEY (employee_ID) REFERENCES employees(employee_ID),
    FOREIGN KEY (dept_ID) REFERENCES departments(dept_ID)
);

CREATE TABLE status_history (
    sta_history_ID VARCHAR(7) PRIMARY KEY,
    employee_ID VARCHAR(7) NOT NULL,
    status ENUM('Employed', 'Leave', 'Retire') NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    FOREIGN KEY (employee_ID) REFERENCES employees(employee_ID)
);

CREATE TABLE basic_salary (
    salary_ID VARCHAR(7) PRIMARY KEY,
    employee_ID VARCHAR(7) NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    salary_month DATE NOT NULL,
    FOREIGN KEY (employee_ID) REFERENCES employees(employee_ID)
);

CREATE TABLE payment (
    pay_ID VARCHAR(7) PRIMARY KEY,
    salary_ID VARCHAR(7) NOT NULL,
    pay_cat_ID VARCHAR(7) NOT NULL,
    employee_ID VARCHAR(7) NOT NULL,
    amount DECIMAL(10, 2) DEFAULT 0,
    date DATE NOT NULL,
    FOREIGN KEY (salary_ID) REFERENCES basic_salary(salary_ID),
    FOREIGN KEY (pay_cat_ID) REFERENCES payment_category(pay_cat_ID),
    FOREIGN KEY (employee_ID) REFERENCES employees(employee_ID)
);

CREATE TABLE payment_category (
    pay_cat_ID VARCHAR(7) PRIMARY KEY,
    category VARCHAR(50) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL
);

CREATE TABLE attendance (
    attendance_ID VARCHAR(7) PRIMARY KEY,
    employee_ID VARCHAR(7) NOT NULL,
    date DATE NOT NULL,
    start_time TIME,
    end_time TIME,
    FOREIGN KEY (employee_ID) REFERENCES employees(employee_ID)
);

CREATE TABLE permission (
    dept_ID VARCHAR(7) PRIMARY KEY,
    account_management TINYINT,
    account_period_management TINYINT,
    budget_management TINYINT,
    FOREIGN KEY (dept_ID) REFERENCES departments(dept_ID)
);

CREATE TABLE participation (
    dept_ID VARCHAR(7) NOT NULL,
    project_ID VARCHAR(7) NOT NULL,
    PRIMARY KEY (dept_ID, project_ID),
    FOREIGN KEY (dept_ID) REFERENCES departments(dept_ID),
    FOREIGN KEY (project_ID) REFERENCES project(project_ID)
);

CREATE TABLE project (
    project_ID VARCHAR(7) PRIMARY KEY,
    project_name VARCHAR(20) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE
);

CREATE TABLE journal (
    journal_ID VARCHAR(7) PRIMARY KEY,
    total_debit DECIMAL(10, 2) NOT NULL,
    total_credit DECIMAL(10, 2) NOT NULL,
    dept_ID VARCHAR(7) NOT NULL,
    is_approved TINYINT NOT NULL,
    FOREIGN KEY (dept_ID) REFERENCES departments(dept_ID)
);

CREATE TABLE bank_account (
    bank_account_ID VARCHAR(7) PRIMARY KEY,
    account_name VARCHAR(10) NOT NULL,
    bank_name VARCHAR(10) NOT NULL,
    account_number VARCHAR(45) NOT NULL,
    is_active SMALLINT NOT NULL
);

CREATE TABLE approval (
    approval_ID VARCHAR(7) PRIMARY KEY,
    journal_ID VARCHAR(7) NOT NULL,
    status ENUM('Pending', 'Approved', 'Rejected') NOT NULL,
    approver VARCHAR(45),
    approved_date DATE,
    FOREIGN KEY (journal_ID) REFERENCES journal(journal_ID)
);

CREATE TABLE payment_card (
    card_ID VARCHAR(7) PRIMARY KEY,
    card_number VARCHAR(45) NOT NULL,
    card_holder VARCHAR(45) NOT NULL,
    card_type VARCHAR(45) NOT NULL,
    card_issuer VARCHAR(45) NOT NULL,
    expiration DATE NOT NULL,
    bank_account_ID VARCHAR(7) NOT NULL,
    FOREIGN KEY (bank_account_ID) REFERENCES bank_account(bank_account_ID)
);

CREATE TABLE transaction (
    trans_ID VARCHAR(7) PRIMARY KEY,
    journal_ID VARCHAR(7) NOT NULL,
    account_code VARCHAR(7) NOT NULL,
    trans_date DATE NOT NULL,
    debit DECIMAL(10, 2) NOT NULL,
    credit DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (journal_ID) REFERENCES journal(journal_ID),
    FOREIGN KEY (account_code) REFERENCES account(account_code)
);

CREATE TABLE use_account (
    account_code VARCHAR(7) NOT NULL,
    budget_ID VARCHAR(7) NOT NULL,
    amount INT NOT NULL,
    PRIMARY KEY (account_code, budget_ID),
    FOREIGN KEY (account_code) REFERENCES account(account_code),
    FOREIGN KEY (budget_ID) REFERENCES budget(budget_ID)
);

CREATE TABLE budget (
    budget_ID VARCHAR(7) PRIMARY KEY,
    dept_ID VARCHAR(7) NOT NULL,
    project_ID VARCHAR(7) NOT NULL,
    account_period_ID VARCHAR(7) NOT NULL,
    FOREIGN KEY (project_ID) REFERENCES project(project_ID),
    FOREIGN KEY (account_period_ID) REFERENCES account_period(account_period_ID),
    FOREIGN KEY (dept_ID) REFERENCES departments(dept_ID)
);

CREATE TABLE account_period (
    account_period_ID VARCHAR(7) PRIMARY KEY,
    fiscal_year VARCHAR(4) NOT NULL,
    period_name VARCHAR(45),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_closed TINYINT NOT NULL
);

CREATE TABLE account (
    account_code VARCHAR(7) PRIMARY KEY,
    account_name VARCHAR(45) NOT NULL,
    debit_credit_indicator ENUM('Debit', 'Credit') NOT NULL,
    account_type ENUM('Assets', 'Liabilities', 'Equity', 'Income', 'Expenses') NOT NULL,
    is_active TINYINT NOT NULL
);

CREATE TABLE customer (
    customer_id VARCHAR(7) NOT NULL PRIMARY KEY,
    customer_name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(20) NOT NULL,
    refund_account VARCHAR(255)
);

CREATE TABLE order_management (
    order_id VARCHAR(7) NOT NULL PRIMARY KEY,
    customer_id VARCHAR(7) NOT NULL,
    order_price INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    order_status VARCHAR(50) NOT NULL,
    delivery_address VARCHAR(255) NOT NULL,
    invoice_id VARCHAR(7),
    journal_id VARCHAR(7),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (journal_id) REFERENCES journal(journal_id)
);

CREATE TABLE payment_management (
    payment_id VARCHAR(7) NOT NULL PRIMARY KEY,
    payment_method VARCHAR(50) NOT NULL,
    order_id VARCHAR(7) NOT NULL,
    payment_price INT NOT NULL,
    payment_date DATE NOT NULL,
    payment_time TIME NOT NULL,
    payment_status BOOLEAN NOT NULL,
    FOREIGN KEY (order_id) REFERENCES order_management(order_id)
);

CREATE TABLE order_product (
    order_id VARCHAR(7) NOT NULL,
    product_id VARCHAR(7) NOT NULL,
    order_quantity INT NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES order_management(order_id),
    FOREIGN KEY (product_id) REFERENCES product_management(product_id)
);

CREATE TABLE product_management (
    product_id VARCHAR(7) NOT NULL PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    product_category VARCHAR(255) NOT NULL,
    price INT NOT NULL,
    manufacture_date DATE NOT NULL,
    is_active BOOLEAN NOT NULL
);

CREATE TABLE inventory_management (
    product_id VARCHAR(7) NOT NULL PRIMARY KEY,
    quantity INT NOT NULL,
    FOREIGN KEY (product_id) REFERENCES product_management(product_id)
);

CREATE TABLE warehouse (
    warehouse_id VARCHAR(7) NOT NULL PRIMARY KEY,
    product_id VARCHAR(7) NOT NULL,
    warehouse_name VARCHAR(255) NOT NULL,
    FOREIGN KEY (product_id) REFERENCES product_management(product_id)
);

CREATE TABLE supplier (
    supplier_id VARCHAR(7) NOT NULL PRIMARY KEY,
    supplier_name VARCHAR(255) NOT NULL,
    supplier_phone VARCHAR(20) NOT NULL
);

CREATE TABLE supply_management (
    product_id VARCHAR(7) NOT NULL,
    supplier_id VARCHAR(7) NOT NULL,
    cost INT NOT NULL,
    journal_id VARCHAR(7),  -- 연결된 journal_id 추가
    PRIMARY KEY (product_id, supplier_id),
    FOREIGN KEY (product_id) REFERENCES product_management(product_id),
    FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id),
    FOREIGN KEY (journal_id) REFERENCES journal(journal_id)  -- journal 테이블과 연결
);

CREATE TABLE production_management (
    production_id VARCHAR(7) NOT NULL PRIMARY KEY,
    product_id VARCHAR(7) NOT NULL,
    production_quantity INT NOT NULL,
    production_date DATE NOT NULL,
    production_time TIME NOT NULL,
    factory_id VARCHAR(7) NOT NULL,
    journal_id VARCHAR(7),  -- 연결된 journal_id 추가
    FOREIGN KEY (product_id) REFERENCES product_management(product_id),
    FOREIGN KEY (factory_id) REFERENCES factory(factory_id),
    FOREIGN KEY (journal_id) REFERENCES journal(journal_id)  -- journal 테이블과 연결
);

CREATE TABLE factory (
    factory_id VARCHAR(7) NOT NULL PRIMARY KEY,
    factory_name VARCHAR(255) NOT NULL,
    factory_phone VARCHAR(20) NOT NULL
);
