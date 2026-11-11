-- Extracted from Lab5_SDAG_Team3 (3).pdf, PDF pages 15-18.
-- PDF line wrapping removed only where verified against the original SQL files.
-- Query logic and source naming are preserved. Select your SQL Server database first.

INSERT INTO CLIENT (client_id, name, contact, email, address, acc_creation_date,
customer_type) VALUES
(1, N'BrightTech Pte Ltd', N'80000002', N'ops@brighttech.example', N'20 Example Avenue', '2025-02-01', N'Corporate'),
(2, N'Alicia Tan', N'80000001', N'alicia@example.com', N'10 Example Road', '2025-01-01', N'Retail');

INSERT INTO CATALOG (catalog_id, manufacturer_name, model_name, warranty_duration,
device_category) VALUES
(1, N'Apple', N'iPhone 14', 12, N'Smartphone'),
(2, N'Sony', N'WH-1000XM5', 12, N'Headphones');

INSERT INTO EMPLOYEE (id, name, role) VALUES
(1, N'Grace Lee', N'Front Desk'),
(2, N'Henry Goh', N'Workshop Manager'),
(11, N'Iris Ng', N'Technician'),
(12, N'Jason Koh', N'Technician'),
(13, N'Kelly Low', N'Inventory Manager');

INSERT INTO TECHNICIAN (employee_id, specialization, certification_level,
hourly_rate) VALUES
(11, N'Display', N'Level 2', 120.00),
(12, N'Audio', N'Level 2', 60.00);

INSERT INTO STATION (station_id, station_type, station_status, employee_id) VALUES
(1, N'Mobile Repair Bench', N'Occupied', 2),
(2, N'Audio Testing Bench', N'Occupied', 2);

INSERT INTO VENDOR (vendor_id, supplier_name, email, phone, payment_term) VALUES
(1, N'Metro Components', N'sales@metro.example', N'80000101', N'Credit');

INSERT INTO ITEMS (part_code, description, minimum_reorder_threshold, price,
category, quantity) VALUES
(N'CLEAN', N'Electronics-safe cleaning consumable', 20, 12.00, N'Consumables', 3),
(N'SEAL', N'Phone display sealing strip', 10, 20.00, N'Seals', 8);

INSERT INTO GADGET (serial_no_IMEI, color, description, storage, client_id,
catalog_id) VALUES
(N'S101', N'Black', N'Corporate iPhone', 128, 1, 1),
(N'S102', N'Blue', N'Corporate iPhone', 128, 1, 1),
(N'S103', N'White', N'Corporate iPhone', 256, 1, 1),




(N'S104', N'Red', N'Corporate iPhone', 128, 1, 1),
(N'H105', N'Black', N'Walk-in headphones', NULL, 2, 2);

INSERT INTO TICKET (ticket_id, status, description, received_dateTime, cost,
employee_id) VALUES
(101, N'Completed', N'Corporate screen fault', '2026-09-01T08:00:00', 196.20, 1),
(102, N'Completed', N'Corporate audio fault', '2026-09-03T08:00:00', 109.00, 1),
(103, N'Completed', N'Corporate charging fault', '2026-09-05T08:00:00', 446.90, 1),
(104, N'Completed', N'Corporate intermittent display fault', '2026-09-07T08:00:00',
512.30, 1),
(105, N'Completed', N'Walk-in headphone audio fault', '2026-09-09T08:00:00', 92.65,
1),
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

INSERT INTO [PROCEDURE] (ticket_id, procedure_no, procedure_type, procedure_name,
status, station_id) VALUES
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

INSERT INTO DIAGNOSTIC_ASSESSMENT (ticket_id, procedure_no, assessment_id,




recommended_action, error_code, liquid_damage, battery_health, technician_id)
VALUES
(101, 1, 1, N'Replace display', N'WATER', N'Liquid Damage', 86.00, 11),
(102, 1, 1, N'Inspect audio fault', N'WATER', N'Tripped', 84.00, 11),
(103, 1, 1, N'Inspect charging port', N'CHARGE', N'Clear', 88.00, 11),
(104, 1, 1, N'Inspect intermittent display', N'DISPLAY', N'Clear', 83.00, 11),
(105, 1, 1, N'Inspect headphones', N'AUDIO', N'Clear', NULL, 12),
(106, 1, 1, N'Clean device', N'CLEAN', N'Clear', 90.00, 11),
(107, 1, 1, N'Inspect walk-in headphones', N'AUDIO', N'Clear', NULL, 12);

INSERT INTO WORK_SESSION (ticket_id, procedure_no, session_id, start_time,
end_time, billable_time, technician_id) VALUES
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

INSERT INTO PART_ALLOCATION (ticket_id, procedure_no, part_code, allocation_id,
quantity_used, locked_price, allocation_datetime) VALUES
(101, 2, N'CLEAN', 1, 1, 10.00, '2026-09-01T10:00:00'),
(101, 2, N'SEAL', 2, 1, 20.00, '2026-09-01T10:01:00'),
(102, 2, N'CLEAN', 1, 1, 10.00, '2026-09-03T10:00:00'),
(103, 2, N'SEAL', 1, 1, 20.00, '2026-09-05T10:00:00'),
(104, 2, N'SEAL', 1, 1, 20.00, '2026-09-07T10:00:00'),
(105, 2, N'CLEAN', 1, 1, 10.00, '2026-09-09T10:00:00');

INSERT INTO PURCHASED_ORDER (purchase_id, vendor_id, cost, order_date,
delivery_date, order_status) VALUES
(1, 1, 180.00, '2026-10-01', '2026-10-27', N'Pending');

INSERT INTO STOCK_REQUEST (part_code, request_id, request_date, request_quantity,
employee_id, vendor_id, purchase_id) VALUES
(N'CLEAN', 1, '2026-10-01', 20, 13, 1, 1),
(N'SEAL', 2, '2026-10-01', 5, 13, 1, 1);





INSERT INTO BILLING_CALCULATION (labor_charge, component_cost, tax_rate, discount,
net_balance) VALUES
(150.00, 30.00, 0.090000, 0.00, 196.20),
(90.00, 10.00, 0.090000, 0.00, 109.00),
(390.00, 20.00, 0.090000, 0.00, 446.90),
(450.00, 20.00, 0.090000, 0.00, 512.30),
(75.00, 10.00, 0.090000, 0.00, 92.65);

INSERT INTO BILLING_STATEMENT (ticket_id, billing_id, payment_status, billing_date,
labor_charge, component_cost, tax_rate, discount) VALUES
(101, 1, N'Paid', '2026-09-01', 150.00, 30.00, 0.090000, 0.00),
(102, 1, N'Paid', '2026-09-03', 90.00, 10.00, 0.090000, 0.00),
(103, 1, N'Paid', '2026-09-05', 390.00, 20.00, 0.090000, 0.00),
(104, 1, N'Paid', '2026-09-07', 450.00, 20.00, 0.090000, 0.00),
(105, 1, N'Paid', '2026-09-09', 75.00, 10.00, 0.090000, 0.00);

INSERT INTO WARRANTY_CLAIM (ticket_id, billing_id, claim_number, review_status,
submission_date, description, approved_remedy, refund_value) VALUES
(101, 1, 1, N'Approved', '2026-09-26', N'Water damage recurred after repair',
N'Refund', 20.00),
(102, 1, 1, N'Approved', '2026-09-28', N'Audio fault recurred after repair',
N'Refund', 30.00);
