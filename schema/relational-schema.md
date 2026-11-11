# Relational schema from the Lab 5 submission

Extracted from PDF pages 4-8. The 18 conceptual relation entries include BILLING, which the report decomposes into BILLING_CALCULATION and BILLING_STATEMENT, giving 19 implemented tables. Original wording is preserved; see [source notes](../docs/SOURCE_NOTES.md) for differences from the SQL definitions.

## CLIENT

Source: PDF page 4 (including continuation rows where applicable).

| Field | Submitted content |
| --- | --- |
| Relation | CLIENT (client_id, name, contact, email, address, acc_creation_date,<br>customer_type) |
| Keys | client_id, email |
| Primary Key | client_id |
| Functional Dependencies | client_id -> name, contact, email, address, acc_creation_date,<br>customer_type<br>email - > client_id, name, contact, address, acc_creation_date,<br>customer_type |
| In 3NF? | Yes. The only stated non-trivial FD has client_id on its left-hand side. Since<br>client_id is a key, CLIENT is in BCNF, and therefore also in 3NF. |

## GADGET

Source: PDF page 4 (including continuation rows where applicable).

| Field | Submitted content |
| --- | --- |
| Relation | GADGET (serial_no_IMEI, color, description, storage, CLIENT.client_id,<br>CATALOG.catalog_id) |
| Keys | serial_no_IMEI |
| Primary Key | serial_no_IMEI |
| Functional Dependencies | serial_no_IMEI -> color, description, storage, client_id, catalog_id |
| In 3NF? | Yes. serial_no_IMEI is the only key, and every other attribute depends<br>directly on it. None of the other attributes determine each other, therefore<br>the only FD is serial_no_IMEI --> color, description, storage,<br>client_id,catalog_id, its determinant is trivially the key itself. |

## CATALOG

Source: PDF page 4 (including continuation rows where applicable).

| Field | Submitted content |
| --- | --- |
| Relation | CATALOG (catalog_id, manufacturer_name, model_name,<br>warranty_duration, device_category) |
| Keys | catalog_id, (manufacturer_name, model_name) |
| Primary Key | catalog_id |
| Functional Dependencies | catalog_id -> manufacturer_name, model_name, warranty_duration,<br>device_category<br>manufacturer_name, model_name -> catalog_id, warranty_duration,<br>device_category |
| In 3NF? | Yes. The only stated non-trivial FD has catalog_id on its left-hand side. Since<br>catalog_id is a key, CATALOG is in BCNF, and therefore also in 3NF. |

## TICKET

Source: PDF page 4 (including continuation rows where applicable).

| Field | Submitted content |
| --- | --- |
| Relation | TICKET (ticket_id, status, description, received_dateTime, cost,<br>EMPLOYEE.id) |
| Keys | ticket_id |
| Primary Key | ticket_id |
| Functional Dependencies | ticket_id -> status, description, received_dateTime, cost, EMPLOYEE.id |
| In 3NF? | Yes. The only stated non-trivial FD has ticket_id on its left-hand side. Since<br>ticket_id is a key, TICKET is in BCNF, and therefore also in 3NF. |

## GADGET_TICKET

Source: PDF page 5 (including continuation rows where applicable).

| Field | Submitted content |
| --- | --- |
| Relation | GADGET_TICKET (serial_no_IMEI , ticket_id ) |
| Keys | (serial_no_IMEI, ticket_id) |
| Primary Key | (serial_no_IMEI, ticket_id) |
| Functional Dependencies | No non-trivial FDs within this relation. The key determines only its own<br>attributes, which are trivial FDs. |
| In 3NF? | Yes. There is no non-trivial FD that could violate 3NF. |

## BILLING

Source: PDF page 5 (including continuation rows where applicable).

| Field | Submitted content |
| --- | --- |
| Relation | BILLING (TICKET.ticket_id, billing_id, payment_status, billing_date,<br>labor_charge, component_cost, tax_rate, discount, net_balance) |
| Keys | (TICKET.ticket_id, billing_id) |
| Primary Key | (TICKET.ticket_id, billing_id) |
| Functional Dependencies | ticket_id, billing_id -> payment_status, billing_date, labor_charge,<br>component_cost, tax_rate, discount, net_balance<br>labor_charge, component_cost, tax_rate, discount -> net_balance |
| In 3NF? | No, (labor_charge, component_cost, tax_rate, discount -> net_balance), the<br>determinant (labor_charge, component_cost, tax_rate, discount) is not a<br>superkey, and net_balance is not a prime attribute. This transitive<br>dependency violates 3NF.<br>Decomposed second FD, we have the sub FD1 and FD2<br>BILLING_CALCULATION(labor_charge, component_cost, tax_rate,<br>discount, net_balance)<br>Key: (labor_charge, component_cost, tax_rate, discount)<br>FD: labor_charge, component_cost, tax_rate, discount → net_balance<br>BILLING_STATEMENT(ticket_id, billing_id, payment_status, billing_date,<br>labor_charge, component_cost, tax_rate, discount)<br>Key: (ticket_id, billing_id)<br>FD: ticket_id, billing_id → payment_status, billing_date, labor_charge,<br>component_cost, tax_rate, discount<br>Foreign key: (labor_charge, component_cost, tax_rate, discount) references<br>BILLING_CALCULATION |

## WARRANTY_CLAIM

Source: PDF page 5 (including continuation rows where applicable).

| Field | Submitted content |
| --- | --- |
| Relation | WARRANTY_CLAIM (ticket_id, billing_id, claim_number, review_status,<br>submission_date, description, approved_remedy, refund_value) |
| Keys | ticket_id, billing_id, claim_number |
| Primary Key | (ticket_id, billing_id, claim_number) |
| Functional Dependencies | ticket_id, billing_id, claim_number -> review_status, submission_date,<br>description, approved_remedy, refund_value |
| In 3NF? | Yes, because (Ticket_id, billing_id, claim_number) is the only primary key<br>obtained from combination of supporting entity and weak entity key and is<br>on the left-hand side. |

## EMPLOYEE

Source: PDF page 6 (including continuation rows where applicable).

| Field | Submitted content |
| --- | --- |
| Relation | EMPLOYEE (id, name, role) |
| Keys | id |
| Primary Key | id |
| Functional Dependencies | id -> name, role |
| In 3NF? | Yes, because (id) is the only primary key needed to recognize employees<br>with different names and roles and is on the left-hand side. |

## TECHNICIAN

Source: PDF page 6 (including continuation rows where applicable).

| Field | Submitted content |
| --- | --- |
| Relation | TECHNICIAN (EMPLOYEE.id, specialization, certification_level, hourly_rate) |
| Keys | EMPLOYEE.id |
| Primary Key | EMPLOYEE.id |
| Functional Dependencies | EMPLOYEE.id -> specialization, certification_level, hourly_rate |
| In 3NF? | Yes, because (EMPLOYEE.id) is the inherited key from parent entity<br>EMPLOYEE and is on the left-hand side. |

## PROCEDURE

Source: PDF page 6 (including continuation rows where applicable).

| Field | Submitted content |
| --- | --- |
| Relation | PROCEDURE (TICKET.ticket_id, procedure_no, procedure_type,<br>procedure_name, status, STATION.station_id) |
| Keys | (TICKET.ticket_id, procedure_no) |
| Primary Key | (TICKET.ticket_id, procedure_no) |
| Functional Dependencies | Ticket_id, procedure_no-> procedure_type, procedure_name, status,<br>station_id |
| In 3NF? | Yes. PROCEDURE is a weak entity supported by TICKET. The composite key<br>(ticket_id, procedure_no) is minimal and serves as the LHS of the only non-<br>trivial FD, satisfying BCNF and 3NF. |

## DIAGNOSTIC_ASSESSMENT

Source: PDF page 6 (including continuation rows where applicable).

| Field | Submitted content |
| --- | --- |
| Relation | DIAGNOSTIC_ASSESSMENT (TICKET.ticket_id, PROCEDURE.procedure_no,<br>assessment_id, recommended_action, error_code, liquid_damage,<br>battery_health, TECHNICIAN.id) |
| Keys | (TICKET.ticket_id, PROCEDURE.procedure_no, assessment_id) |
| Primary Key | (TICKET.ticket_id, PROCEDURE.procedure_no, assessment_id) |
| Functional Dependencies | ticket_id, procedure_no, assessment_id -> recommended_action,<br>error_code, liquid_damage, battery_health, TECHNICIAN.id |
| In 3NF? | Yes. As a weak entity supported by PROCEDURE, its primary key combines<br>(ticket_id, procedure_no) with its partial key assessment_id. The LHS of the<br>only non-trivial FD is the candidate key, so it is in BCNF and 3NF. |

## STATION

Source: PDF page 6 (including continuation rows where applicable).

| Field | Submitted content |
| --- | --- |
| Relation | STATION (station_id, station_type, station_status, EMPLOYEE.id) |
| Keys | station_id |
| Primary Key | station_id |
| Functional Dependencies | station_id -> station_type, station_status, EMPLOYEE.id |
| In 3NF? | Yes. The dependency is in BCNF as it is non trivial and the LHS contains<br>station_id which is the key. And every relation in BCNF is also in 3NF. |

## WORK_SESSION

Source: PDF page 7 (including continuation rows where applicable).

| Field | Submitted content |
| --- | --- |
| Relation | WORK_SESSION (TICKET.ticket_id, PROCEDURE.procedure_no,<br>session_id, start_time, end_time, billable_time, TECHNICIAN.id) |
| Keys | (TICKET.ticket_id, PROCEDURE.procedure_no, session_id)<br>(TECHNICIAN.id, start_time) |
| Primary Key | (TICKET.ticket_id, PROCEDURE.procedure_no, session_id) |
| Functional Dependencies | ticket_id, procedure_no, session_id -> start_time, end_time, billable_time,<br>procedure_no, TECHNICIAN.id<br>TECHNICIAN.id, start_time -> ticket_id, procedure_no, session_id,<br>end_time, billable_time |
| In 3NF? | Yes. WORK_SESSION is a weak entity identified by PROCEDURE (ticket_id,<br>procedure_no) and its partial key session_id. The only non-trivial FD has the<br>candidate key on the LHS, so it is in BCNF and 3NF. |

## PART_ALLOCATION

Source: PDF page 7 (including continuation rows where applicable).

| Field | Submitted content |
| --- | --- |
| Relation | PART_ALLOCATION (TICKET.ticket_id, PROCEDURE.procedure_no,<br>ITEMS.part_code, allocation_id, quantity_used, locked_price,<br>allocation_datetime) |
| Keys | (TICKET.ticket_id, PROCEDURE.procedure_no, allocation_id,<br>ITEMS.part_code) |
| Primary Key | (TICKET.ticket_id, PROCEDURE.procedure_no, allocation_id,<br>ITEMS.part_code) |
| Functional Dependencies | ticket_id, allocation_id, procedure_no, part_code -> quantity_used,<br>locked_price, allocation_datetime |
| In 3NF? | Yes. The LHS of the only non-trivial FD is the composite key (ticket_id,<br>procedure_no, part_code, allocation_id), so the relation is in BCNF and<br>3NF. |

## ITEMS

Source: PDF page 7 (including continuation rows where applicable).

| Field | Submitted content |
| --- | --- |
| Relation | ITEMS (part_code, description, minimum_reorder_threshold, price,<br>category, quantity) |
| Keys | part_code |
| Primary Key | (part_code) |
| Functional Dependencies | part_code -> description, minimum_reorder_threshold, price, category,<br>quantity |
| In 3NF? | Yes. The dependency is in BCNF as it is non trivial and the LHS contains<br>part_code which is the key. And every relation in BCNF is also in 3NF. |

## STOCK_REQUEST

Source: PDF page 8 (including continuation rows where applicable).

| Field | Submitted content |
| --- | --- |
| Relation | STOCK_REQUEST (ITEMS.part_code, request_id, request_date,<br>request_quantity, EMPLOYEE.ID, VENDOR.vendor_id,<br>PURCHASED_ORDER.purchase_id) |
| Keys | (request_id) |
| Primary Key | (request_id) |
| Functional Dependencies | request_id -> EMPLOYEE.ID, request_date, request_quantity, vendor_id,<br>purchase_id |
| In 3NF? | Yes. STOCK_REQUEST is a weak entity identified solely by ITEMS.part_code<br>and its partial key request_id. vendor_id and purchase_id are nullable<br>Foreign Keys (referencing PURCHASED_ORDER) that are populated once<br>the request is combined into an order. Because (part_code, request_id) is<br>the LHS of the only non-trivial FD, it is in BCNF and 3NF. |

## PURCHASED_ORDER

Source: PDF page 8 (including continuation rows where applicable).

| Field | Submitted content |
| --- | --- |
| Relation | PURCHASED_ORDER (purchase_id, VENDOR.vendor_id, cost, order_date,<br>delivery_date, order_status) |
| Keys | (purchase_id, VENDOR.vendor_id) |
| Primary Key | (purchase_id, VENDOR.vendor_id) |
| Functional Dependencies | purchase_id, VENDOR.vendor_id -> cost, order_date, delivery_date,<br>order_status |
| In 3NF? | Yes, every non-trivial FDs have key on LHS, so it is in BCNF, which is in 3NF. |

## VENDOR

Source: PDF page 8 (including continuation rows where applicable).

| Field | Submitted content |
| --- | --- |
| Relation | VENDOR (vendor_id, supplier_name, email, phone, payment_term) |
| Keys | vendor_id, supplier_name, email |
| Primary Key | (vendor_id) |
| Functional Dependencies | vendor_id -> supplier_name, email, phone, payment_term<br>supplier_name -> vendor_id, email, phone, payment_term<br>email -> vendor_id, supplier_name, phone, payment_term |
| In 3NF? | Yes, every non-trivial FDs have key on LHS, so it is in BCNF, which is in 3NF. |
