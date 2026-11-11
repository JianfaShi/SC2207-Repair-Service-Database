/* =====================================================================
   TechPulse - Lab 5 setup script (SQL Server)
   Before the first run, create the database once:
       CREATE DATABASE TechPulse;
   Then run this whole file with Alt+X (nothing highlighted).
   Safe to re-run: it drops and recreates every table.
   ===================================================================== */
USE TechPulse;
GO

/* ---------- Drop tables (children before parents) ---------- */
DROP TABLE IF EXISTS WARRANTY_CLAIM;
DROP TABLE IF EXISTS BILLING_STATEMENT;
DROP TABLE IF EXISTS BILLING_CALCULATION;
DROP TABLE IF EXISTS STOCK_REQUEST;
DROP TABLE IF EXISTS PURCHASED_ORDER;
DROP TABLE IF EXISTS PART_ALLOCATION;
DROP TABLE IF EXISTS WORK_SESSION;
DROP TABLE IF EXISTS DIAGNOSTIC_ASSESSMENT;
DROP TABLE IF EXISTS [PROCEDURE];
DROP TABLE IF EXISTS GADGET_TICKET;
DROP TABLE IF EXISTS TICKET;
DROP TABLE IF EXISTS GADGET;
DROP TABLE IF EXISTS ITEMS;
DROP TABLE IF EXISTS VENDOR;
DROP TABLE IF EXISTS STATION;
DROP TABLE IF EXISTS TECHNICIAN;
DROP TABLE IF EXISTS EMPLOYEE;
DROP TABLE IF EXISTS CATALOG;
DROP TABLE IF EXISTS CLIENT;
GO

/* =====================================================================
   CREATE TABLES
   ===================================================================== */

CREATE TABLE CLIENT (
  client_id INT NOT NULL,
  name NVARCHAR(150) NOT NULL,
  contact NVARCHAR(40) NOT NULL,
  email NVARCHAR(254) NOT NULL UNIQUE,
  address NVARCHAR(500) NULL,
  acc_creation_date DATE NOT NULL,
  customer_type NVARCHAR(30) NOT NULL CHECK (customer_type IN ('Retail', 'Corporate')),
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
  station_status NVARCHAR(40) NOT NULL CHECK (station_status IN ('Free', 'Occupied', 'Maintenance')),
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
  procedure_type NVARCHAR(100) NOT NULL CHECK (procedure_type IN ('Inspection', 'Repair')),
  procedure_name NVARCHAR(150) NOT NULL,
  status NVARCHAR(40) NOT NULL CHECK (status IN ('Pending', 'In Progress', 'Completed')),
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
  liquid_damage NVARCHAR(40) NULL CHECK (liquid_damage IS NULL OR liquid_damage IN ('Clear', 'Tripped', 'Liquid Damage')),
  battery_health DECIMAL(5,2) NULL CHECK (battery_health IS NULL OR battery_health BETWEEN 0 AND 100),
  technician_id INT NOT NULL,
  PRIMARY KEY (ticket_id, procedure_no, assessment_id),
  FOREIGN KEY (ticket_id, procedure_no) REFERENCES [PROCEDURE] (ticket_id, procedure_no)
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
  FOREIGN KEY (ticket_id, procedure_no) REFERENCES [PROCEDURE] (ticket_id, procedure_no)
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
  FOREIGN KEY (ticket_id, procedure_no) REFERENCES [PROCEDURE] (ticket_id, procedure_no)
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
  order_status NVARCHAR(40) NOT NULL CHECK (order_status IN ('Pending', 'Shipped', 'Received')),
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
  FOREIGN KEY (purchase_id, vendor_id) REFERENCES PURCHASED_ORDER (purchase_id, vendor_id)
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
  CHECK (net_balance = ROUND((labor_charge + component_cost - discount) * (1 + tax_rate), 2))
);

CREATE TABLE BILLING_STATEMENT (
  ticket_id INT NOT NULL,
  billing_id INT NOT NULL,
  payment_status NVARCHAR(40) NOT NULL CHECK (payment_status IN ('Unpaid', 'Paid', 'Partial')),
  billing_date DATE NOT NULL,
  labor_charge DECIMAL(12,2) NOT NULL,
  component_cost DECIMAL(12,2) NOT NULL,
  tax_rate DECIMAL(7,6) NOT NULL,
  discount DECIMAL(12,2) NOT NULL,
  PRIMARY KEY (ticket_id, billing_id),
  FOREIGN KEY (ticket_id) REFERENCES TICKET (ticket_id)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (labor_charge, component_cost, tax_rate, discount)
    REFERENCES BILLING_CALCULATION (labor_charge, component_cost, tax_rate, discount)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE WARRANTY_CLAIM (
  ticket_id INT NOT NULL,
  billing_id INT NOT NULL,
  claim_number INT NOT NULL,
  review_status NVARCHAR(40) NOT NULL CHECK (review_status IN ('Under Review', 'Approved', 'Rejected')),
  submission_date DATE NOT NULL,
  description NVARCHAR(2000) NOT NULL,
  approved_remedy NVARCHAR(1000) NULL,
  refund_value DECIMAL(12,2) NULL CHECK (refund_value IS NULL OR refund_value >= 0),
  PRIMARY KEY (ticket_id, billing_id, claim_number),
  FOREIGN KEY (ticket_id, billing_id) REFERENCES BILLING_STATEMENT (ticket_id, billing_id)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);
GO

/* =====================================================================
   INSERT SAMPLE DATA (90 rows)
   ===================================================================== */

INSERT INTO CLIENT (client_id, name, contact, email, address, acc_creation_date, customer_type) VALUES
(1, N'BrightTech Pte Ltd', N'80000002', N'ops@brighttech.example', N'20 Example Avenue', '2025-02-01', N'Corporate'),
(2, N'Alicia Tan', N'80000001', N'alicia@example.com', N'10 Example Road', '2025-01-01', N'Retail');

INSERT INTO CATALOG (catalog_id, manufacturer_name, model_name, warranty_duration, device_category) VALUES
(1, N'Apple', N'iPhone 14', 12, N'Smartphone'),
(2, N'Sony', N'WH-1000XM5', 12, N'Headphones');

INSERT INTO EMPLOYEE (id, name, role) VALUES
(1, N'Grace Lee', N'Front Desk'),
(2, N'Henry Goh', N'Workshop Manager'),
(11, N'Iris Ng', N'Technician'),
(12, N'Jason Koh', N'Technician'),
(13, N'Kelly Low', N'Inventory Manager');

INSERT INTO TECHNICIAN (employee_id, specialization, certification_level, hourly_rate) VALUES
(11, N'Display', N'Level 2', 120.00),
(12, N'Audio', N'Level 2', 60.00);

INSERT INTO STATION (station_id, station_type, station_status, employee_id) VALUES
(1, N'Mobile Repair Bench', N'Occupied', 2),
(2, N'Audio Testing Bench', N'Occupied', 2);

INSERT INTO VENDOR (vendor_id, supplier_name, email, phone, payment_term) VALUES
(1, N'Metro Components', N'sales@metro.example', N'80000101', N'Credit');

INSERT INTO ITEMS (part_code, description, minimum_reorder_threshold, price, category, quantity) VALUES
(N'CLEAN', N'Electronics-safe cleaning consumable', 20, 12.00, N'Consumables', 3),
(N'SEAL', N'Phone display sealing strip', 10, 20.00, N'Seals', 8);

INSERT INTO GADGET (serial_no_IMEI, color, description, storage, client_id, catalog_id) VALUES
(N'S101', N'Black', N'Corporate iPhone', 128, 1, 1),
(N'S102', N'Blue', N'Corporate iPhone', 128, 1, 1),
(N'S103', N'White', N'Corporate iPhone', 256, 1, 1),
(N'S104', N'Red', N'Corporate iPhone', 128, 1, 1),
(N'H105', N'Black', N'Walk-in headphones', NULL, 2, 2);

INSERT INTO TICKET (ticket_id, status, description, received_dateTime, cost, employee_id) VALUES
(101, N'Completed', N'Corporate screen fault', '2026-09-01T08:00:00', 196.20, 1),
(102, N'Completed', N'Corporate audio fault', '2026-09-03T08:00:00', 109.00, 1),
(103, N'Completed', N'Corporate charging fault', '2026-09-05T08:00:00', 446.90, 1),
(104, N'Completed', N'Corporate intermittent display fault', '2026-09-07T08:00:00', 512.30, 1),
(105, N'Completed', N'Walk-in headphone audio fault', '2026-09-09T08:00:00', 92.65, 1),
(106, N'In Progress', N'Corporate repeat visit for cleaning', '2026-10-15T08:00:00', 120.00, 1),
(107, N'In Progress', N'Walk-in paid repeat visit for a separate issue', '2026-10-16T08:00:00', 80.00, 1);

INSERT INTO GADGET_TICKET (serial_no_IMEI, ticket_id) VALUES
(N'S101', 101),
(N'S102', 102),
(N'S103', 103),
(N'S104', 104),
(N'H105', 105),
(N'S101', 106),
(N'H105', 107);

INSERT INTO [PROCEDURE] (ticket_id, procedure_no, procedure_type, procedure_name, status, station_id) VALUES
(101, 1, N'Inspection', N'Initial inspection', N'Completed', 1),
(101, 2, N'Repair', N'Display repair', N'Completed', 1),
(102, 1, N'Inspection', N'Initial inspection', N'Completed', 1),
(102, 2, N'Repair', N'Audio fault repair', N'Completed', 1),
(103, 1, N'Inspection', N'Initial inspection', N'Completed', 1),
(103, 2, N'Repair', N'Charging fault repair', N'Completed', 1),
(104, 1, N'Inspection', N'Initial inspection', N'Completed', 1),
(104, 2, N'Repair', N'Display fault repair', N'Completed', 1),
(105, 1, N'Inspection', N'Initial inspection', N'Completed', 2),
(105, 2, N'Repair', N'Headphone audio repair', N'Completed', 2),
(106, 1, N'Inspection', N'Initial inspection', N'Completed', 1),
(106, 2, N'Repair', N'Cleaning in progress', N'In Progress', 1),
(107, 1, N'Inspection', N'Initial inspection', N'Completed', 2),
(107, 2, N'Repair', N'Paid repair in progress', N'In Progress', 2);

INSERT INTO DIAGNOSTIC_ASSESSMENT (ticket_id, procedure_no, assessment_id, recommended_action, error_code, liquid_damage, battery_health, technician_id) VALUES
(101, 1, 1, N'Replace display', N'WATER', N'Liquid Damage', 86.00, 11),
(102, 1, 1, N'Inspect audio fault', N'WATER', N'Tripped', 84.00, 11),
(103, 1, 1, N'Inspect charging port', N'CHARGE', N'Clear', 88.00, 11),
(104, 1, 1, N'Inspect intermittent display', N'DISPLAY', N'Clear', 83.00, 11),
(105, 1, 1, N'Inspect headphones', N'AUDIO', N'Clear', NULL, 12),
(106, 1, 1, N'Clean device', N'CLEAN', N'Clear', 90.00, 11),
(107, 1, 1, N'Inspect walk-in headphones', N'AUDIO', N'Clear', NULL, 12);

INSERT INTO WORK_SESSION (ticket_id, procedure_no, session_id, start_time, end_time, billable_time, technician_id) VALUES
(101, 1, 1, '2026-09-01T09:00:00', '2026-09-01T09:15:00', 0.25, 11),
(101, 2, 1, '2026-09-01T10:00:00', '2026-09-01T11:00:00', 1.00, 11),
(102, 1, 1, '2026-09-03T09:00:00', '2026-09-03T09:15:00', 0.25, 11),
(102, 2, 1, '2026-09-03T10:00:00', '2026-09-03T11:00:00', 1.00, 12),
(103, 1, 1, '2026-09-05T09:00:00', '2026-09-05T09:15:00', 0.25, 11),
(103, 2, 1, '2026-09-05T10:00:00', '2026-09-05T13:00:00', 3.00, 11),
(104, 1, 1, '2026-09-07T09:00:00', '2026-09-07T09:15:00', 0.25, 11),
(104, 2, 1, '2026-09-07T10:00:00', '2026-09-07T13:30:00', 3.50, 11),
(105, 1, 1, '2026-09-09T09:00:00', '2026-09-09T09:15:00', 0.25, 12),
(105, 2, 1, '2026-09-09T10:00:00', '2026-09-09T10:30:00', 0.50, 12),
(105, 2, 2, '2026-09-09T11:30:00', '2026-09-09T12:00:00', 0.50, 12),
(106, 1, 1, '2026-10-15T09:00:00', '2026-10-15T09:15:00', 0.25, 11),
(107, 1, 1, '2026-10-16T09:00:00', '2026-10-16T09:15:00', 0.25, 12);

INSERT INTO PART_ALLOCATION (ticket_id, procedure_no, part_code, allocation_id, quantity_used, locked_price, allocation_datetime) VALUES
(101, 2, N'CLEAN', 1, 1, 10.00, '2026-09-01T10:00:00'),
(101, 2, N'SEAL', 2, 1, 20.00, '2026-09-01T10:01:00'),
(102, 2, N'CLEAN', 1, 1, 10.00, '2026-09-03T10:00:00'),
(103, 2, N'SEAL', 1, 1, 20.00, '2026-09-05T10:00:00'),
(104, 2, N'SEAL', 1, 1, 20.00, '2026-09-07T10:00:00'),
(105, 2, N'CLEAN', 1, 1, 10.00, '2026-09-09T10:00:00');

INSERT INTO PURCHASED_ORDER (purchase_id, vendor_id, cost, order_date, delivery_date, order_status) VALUES
(1, 1, 180.00, '2026-10-01', '2026-10-27', N'Pending');

INSERT INTO STOCK_REQUEST (part_code, request_id, request_date, request_quantity, employee_id, vendor_id, purchase_id) VALUES
(N'CLEAN', 1, '2026-10-01', 20, 13, 1, 1),
(N'SEAL', 2, '2026-10-01', 5, 13, 1, 1);

INSERT INTO BILLING_CALCULATION (labor_charge, component_cost, tax_rate, discount, net_balance) VALUES
(150.00, 30.00, 0.090000, 0.00, 196.20),
(90.00, 10.00, 0.090000, 0.00, 109.00),
(390.00, 20.00, 0.090000, 0.00, 446.90),
(450.00, 20.00, 0.090000, 0.00, 512.30),
(75.00, 10.00, 0.090000, 0.00, 92.65);

INSERT INTO BILLING_STATEMENT (ticket_id, billing_id, payment_status, billing_date, labor_charge, component_cost, tax_rate, discount) VALUES
(101, 1, N'Paid', '2026-09-01', 150.00, 30.00, 0.090000, 0.00),
(102, 1, N'Paid', '2026-09-03', 90.00, 10.00, 0.090000, 0.00),
(103, 1, N'Paid', '2026-09-05', 390.00, 20.00, 0.090000, 0.00),
(104, 1, N'Paid', '2026-09-07', 450.00, 20.00, 0.090000, 0.00),
(105, 1, N'Paid', '2026-09-09', 75.00, 10.00, 0.090000, 0.00);

INSERT INTO WARRANTY_CLAIM (ticket_id, billing_id, claim_number, review_status, submission_date, description, approved_remedy, refund_value) VALUES
(101, 1, 1, N'Approved', '2026-09-26', N'Water damage recurred after repair', N'Refund', 20.00),
(102, 1, 1, N'Approved', '2026-09-28', N'Audio fault recurred after repair', N'Refund', 30.00);
GO

/* =====================================================================
   CHECK: row count per table (should add up to 90)
   ===================================================================== */
SELECT 'CLIENT' AS table_name, COUNT(*) AS row_count FROM CLIENT
UNION ALL SELECT 'CATALOG', COUNT(*) FROM CATALOG
UNION ALL SELECT 'EMPLOYEE', COUNT(*) FROM EMPLOYEE
UNION ALL SELECT 'TECHNICIAN', COUNT(*) FROM TECHNICIAN
UNION ALL SELECT 'STATION', COUNT(*) FROM STATION
UNION ALL SELECT 'VENDOR', COUNT(*) FROM VENDOR
UNION ALL SELECT 'ITEMS', COUNT(*) FROM ITEMS
UNION ALL SELECT 'GADGET', COUNT(*) FROM GADGET
UNION ALL SELECT 'TICKET', COUNT(*) FROM TICKET
UNION ALL SELECT 'GADGET_TICKET', COUNT(*) FROM GADGET_TICKET
UNION ALL SELECT 'PROCEDURE', COUNT(*) FROM [PROCEDURE]
UNION ALL SELECT 'DIAGNOSTIC_ASSESSMENT', COUNT(*) FROM DIAGNOSTIC_ASSESSMENT
UNION ALL SELECT 'WORK_SESSION', COUNT(*) FROM WORK_SESSION
UNION ALL SELECT 'PART_ALLOCATION', COUNT(*) FROM PART_ALLOCATION
UNION ALL SELECT 'PURCHASED_ORDER', COUNT(*) FROM PURCHASED_ORDER
UNION ALL SELECT 'STOCK_REQUEST', COUNT(*) FROM STOCK_REQUEST
UNION ALL SELECT 'BILLING_CALCULATION', COUNT(*) FROM BILLING_CALCULATION
UNION ALL SELECT 'BILLING_STATEMENT', COUNT(*) FROM BILLING_STATEMENT
UNION ALL SELECT 'WARRANTY_CLAIM', COUNT(*) FROM WARRANTY_CLAIM;
