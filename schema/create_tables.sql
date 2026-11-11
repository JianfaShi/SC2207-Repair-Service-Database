-- Extracted from Lab5_SDAG_Team3 (3).pdf, PDF pages 9-14.
-- PDF line wrapping removed only where verified against the original SQL files.
-- Query logic and source naming are preserved. Select your SQL Server database first.

CREATE TABLE CLIENT (
  client_id INT NOT NULL,
  name NVARCHAR(150) NOT NULL,
  contact NVARCHAR(40) NOT NULL,
  email NVARCHAR(254) NOT NULL UNIQUE,
  address NVARCHAR(500) NULL,
  acc_creation_date DATE NOT NULL,
  customer_type NVARCHAR(30) NOT NULL CHECK (customer_type IN ('Retail',
'Corporate')),
  PRIMARY KEY (client_id)
);

CREATE TABLE CATALOG (
  catalog_id INT NOT NULL,
  manufacturer_name NVARCHAR(100) NOT NULL,
  model_name NVARCHAR(150) NOT NULL,
  warranty_duration INT NOT NULL CHECK (warranty_duration >= 0),
  device_category NVARCHAR(60) NOT NULL,
  PRIMARY KEY (catalog_id),
  UNIQUE (manufacturer_name, model_name)
);

CREATE TABLE EMPLOYEE (
  id INT NOT NULL,
  name NVARCHAR(150) NOT NULL,
  role NVARCHAR(80) NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE TECHNICIAN (
  employee_id INT NOT NULL,
  specialization NVARCHAR(100) NOT NULL,
  certification_level NVARCHAR(80) NOT NULL,
  hourly_rate DECIMAL(12,2) NOT NULL CHECK (hourly_rate >= 0),
  PRIMARY KEY (employee_id),
  FOREIGN KEY (employee_id) REFERENCES EMPLOYEE (id)
    ON DELETE CASCADE ON UPDATE NO ACTION
);





CREATE TABLE STATION (
  station_id INT NOT NULL,
  station_type NVARCHAR(100) NOT NULL,
  station_status NVARCHAR(40) NOT NULL CHECK (station_status IN ('Free',
'Occupied', 'Maintenance')),
  employee_id INT NOT NULL,
  PRIMARY KEY (station_id),
  FOREIGN KEY (employee_id) REFERENCES EMPLOYEE (id)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE VENDOR (
  vendor_id INT NOT NULL,
  supplier_name NVARCHAR(150) NOT NULL UNIQUE,
  email NVARCHAR(254) NOT NULL UNIQUE,
  phone NVARCHAR(40) NOT NULL,
  payment_term NVARCHAR(80) NOT NULL,
  PRIMARY KEY (vendor_id)
);

CREATE TABLE ITEMS (
  part_code NVARCHAR(50) NOT NULL,
  description NVARCHAR(1000) NOT NULL,
  minimum_reorder_threshold INT NOT NULL CHECK (minimum_reorder_threshold >= 0),
  price DECIMAL(12,2) NOT NULL CHECK (price >= 0),
  category NVARCHAR(80) NOT NULL,
  quantity INT NOT NULL CHECK (quantity >= 0),
  PRIMARY KEY (part_code)
);

CREATE TABLE GADGET (
  serial_no_IMEI NVARCHAR(100) NOT NULL,
  color NVARCHAR(50) NULL,
  description NVARCHAR(1000) NULL,
  storage INT NULL CHECK (storage IS NULL OR storage >= 0),
  client_id INT NOT NULL,
  catalog_id INT NOT NULL,
  PRIMARY KEY (serial_no_IMEI),
  FOREIGN KEY (client_id) REFERENCES CLIENT (client_id)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (catalog_id) REFERENCES CATALOG (catalog_id)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);





CREATE TABLE TICKET (
  ticket_id INT NOT NULL,
  status NVARCHAR(40) NOT NULL CHECK (status IN ('Received', 'Diagnosing', 'In Progress', 'Ready for Pickup', 'Completed')),
  description NVARCHAR(2000) NOT NULL,
  received_dateTime DATETIME2(0) NOT NULL,
  cost DECIMAL(12,2) NOT NULL CHECK (cost >= 0),
  employee_id INT NOT NULL,
  PRIMARY KEY (ticket_id),
  FOREIGN KEY (employee_id) REFERENCES EMPLOYEE (id)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE GADGET_TICKET (
  serial_no_IMEI NVARCHAR(100) NOT NULL,
  ticket_id INT NOT NULL,
  PRIMARY KEY (serial_no_IMEI, ticket_id),
  FOREIGN KEY (serial_no_IMEI) REFERENCES GADGET (serial_no_IMEI)
    ON DELETE NO ACTION ON UPDATE CASCADE,
  FOREIGN KEY (ticket_id) REFERENCES TICKET (ticket_id)
    ON DELETE CASCADE ON UPDATE NO ACTION
);

CREATE TABLE [PROCEDURE] (
  ticket_id INT NOT NULL,
  procedure_no INT NOT NULL,
  procedure_type NVARCHAR(100) NOT NULL CHECK (procedure_type IN ('Inspection',
'Repair')),
  procedure_name NVARCHAR(150) NOT NULL,
  status NVARCHAR(40) NOT NULL CHECK (status IN ('Pending', 'In Progress',
'Completed')),
  station_id INT NOT NULL,
  PRIMARY KEY (ticket_id, procedure_no),
  FOREIGN KEY (ticket_id) REFERENCES TICKET (ticket_id)
    ON DELETE CASCADE ON UPDATE NO ACTION,
  FOREIGN KEY (station_id) REFERENCES STATION (station_id)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE DIAGNOSTIC_ASSESSMENT (
  ticket_id INT NOT NULL,
  procedure_no INT NOT NULL,
  assessment_id INT NOT NULL,
  recommended_action NVARCHAR(2000) NULL,




  error_code NVARCHAR(100) NULL,
  liquid_damage NVARCHAR(40) NULL CHECK (liquid_damage IS NULL OR liquid_damage IN
('Clear', 'Tripped', 'Liquid Damage')),
  battery_health DECIMAL(5,2) NULL CHECK (battery_health IS NULL OR battery_health
BETWEEN 0 AND 100),
  technician_id INT NOT NULL,
  PRIMARY KEY (ticket_id, procedure_no, assessment_id),
  FOREIGN KEY (ticket_id, procedure_no) REFERENCES [PROCEDURE] (ticket_id,
procedure_no)
    ON DELETE CASCADE ON UPDATE NO ACTION,
  FOREIGN KEY (technician_id) REFERENCES TECHNICIAN (employee_id)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE WORK_SESSION (
  ticket_id INT NOT NULL,
  procedure_no INT NOT NULL,
  session_id INT NOT NULL,
  start_time DATETIME2(0) NOT NULL,
  end_time DATETIME2(0) NOT NULL,
  billable_time DECIMAL(10,2) NOT NULL CHECK (billable_time >= 0),
  technician_id INT NOT NULL,
  PRIMARY KEY (ticket_id, procedure_no, session_id),
  UNIQUE (technician_id, start_time),
  CHECK (end_time >= start_time),
  FOREIGN KEY (ticket_id, procedure_no) REFERENCES [PROCEDURE] (ticket_id,
procedure_no)
    ON DELETE CASCADE ON UPDATE NO ACTION,
  FOREIGN KEY (technician_id) REFERENCES TECHNICIAN (employee_id)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE PART_ALLOCATION (
  ticket_id INT NOT NULL,
  procedure_no INT NOT NULL,
  part_code NVARCHAR(50) NOT NULL,
  allocation_id INT NOT NULL,
  quantity_used INT NOT NULL CHECK (quantity_used > 0),
  locked_price DECIMAL(12,2) NOT NULL CHECK (locked_price >= 0),
  allocation_datetime DATETIME2(0) NOT NULL,
  PRIMARY KEY (ticket_id, procedure_no, allocation_id, part_code),
  FOREIGN KEY (ticket_id, procedure_no) REFERENCES [PROCEDURE] (ticket_id,
procedure_no)
    ON DELETE NO ACTION ON UPDATE NO ACTION,




  FOREIGN KEY (part_code) REFERENCES ITEMS (part_code)
    ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE PURCHASED_ORDER (
  purchase_id INT NOT NULL,
  vendor_id INT NOT NULL,
  cost DECIMAL(12,2) NOT NULL CHECK (cost >= 0),
  order_date DATE NOT NULL,
  delivery_date DATE NULL,
  order_status NVARCHAR(40) NOT NULL CHECK (order_status IN ('Pending', 'Shipped',
'Received')),
  PRIMARY KEY (purchase_id, vendor_id),
  CHECK (delivery_date IS NULL OR delivery_date >= order_date),
  FOREIGN KEY (vendor_id) REFERENCES VENDOR (vendor_id)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE STOCK_REQUEST (
  part_code NVARCHAR(50) NOT NULL,
  request_id INT NOT NULL,
  request_date DATE NOT NULL,
  request_quantity INT NOT NULL CHECK (request_quantity > 0),
  employee_id INT NOT NULL,
  vendor_id INT NULL,
  purchase_id INT NULL,
  PRIMARY KEY (request_id),
  CHECK ((purchase_id IS NULL AND vendor_id IS NULL)
      OR (purchase_id IS NOT NULL AND vendor_id IS NOT NULL)),
  FOREIGN KEY (part_code) REFERENCES ITEMS (part_code)
    ON DELETE NO ACTION ON UPDATE CASCADE,
  FOREIGN KEY (employee_id) REFERENCES EMPLOYEE (id)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (purchase_id, vendor_id) REFERENCES PURCHASED_ORDER (purchase_id,
vendor_id)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE BILLING_CALCULATION (
  labor_charge DECIMAL(12,2) NOT NULL,
  component_cost DECIMAL(12,2) NOT NULL,
  tax_rate DECIMAL(7,6) NOT NULL CHECK (tax_rate >= 0),
  discount DECIMAL(12,2) NOT NULL,
  net_balance DECIMAL(12,2) NOT NULL,




  PRIMARY KEY (labor_charge, component_cost, tax_rate, discount),
  CHECK (labor_charge >= 0 AND component_cost >= 0),
  CHECK (discount >= 0 AND discount <= labor_charge + component_cost),
  CHECK (net_balance = ROUND((labor_charge + component_cost - discount) * (1 +
tax_rate), 2))
);

CREATE TABLE BILLING_STATEMENT (
  ticket_id INT NOT NULL,
  billing_id INT NOT NULL,
  payment_status NVARCHAR(40) NOT NULL CHECK (payment_status IN ('Unpaid', 'Paid',
'Partial')),
  billing_date DATE NOT NULL,
  labor_charge DECIMAL(12,2) NOT NULL,
  component_cost DECIMAL(12,2) NOT NULL,
  tax_rate DECIMAL(7,6) NOT NULL,
  discount DECIMAL(12,2) NOT NULL,
  PRIMARY KEY (ticket_id, billing_id),
  FOREIGN KEY (ticket_id) REFERENCES TICKET (ticket_id)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (labor_charge, component_cost, tax_rate, discount)
    REFERENCES BILLING_CALCULATION (labor_charge, component_cost, tax_rate,
discount)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE WARRANTY_CLAIM (
  ticket_id INT NOT NULL,
  billing_id INT NOT NULL,
  claim_number INT NOT NULL,
  review_status NVARCHAR(40) NOT NULL CHECK (review_status IN ('Under Review',
'Approved', 'Rejected')),
  submission_date DATE NOT NULL,
  description NVARCHAR(2000) NOT NULL,
  approved_remedy NVARCHAR(1000) NULL,
  refund_value DECIMAL(12,2) NULL CHECK (refund_value IS NULL OR refund_value >=
0),
  PRIMARY KEY (ticket_id, billing_id, claim_number),
  FOREIGN KEY (ticket_id, billing_id) REFERENCES BILLING_STATEMENT (ticket_id,
billing_id)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);
