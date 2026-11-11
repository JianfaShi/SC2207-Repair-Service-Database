# Submitted assumptions

Source: Lab5_SDAG_Team3 (3).pdf, pages 21-22. Text extracted with original wording.

Each sample ticket concerns one gadget, and gadget ownership remains unchanged throughout
the sample period.
Each ticket has one inspection assessment, treated as its initial diagnostic report because
assessment chronology is not recorded separately.
Q1 measures elapsed procedure duration from the earliest work-session start to the latest end,
including gaps. Completed inspection procedures are included.
Billable time is recorded in hours. Technician hourly rates remain constant during the sample
period. Q2 reports earned labor and parts charges for completed tickets before tax, discounts and
refunds.
Discounts are fixed currency amounts applied before tax. Net balance is calculated as
ROUND((labor_charge + component_cost − discount) × (1 + tax_rate), 2). The sample tax rate is 9%.
For Q3, Display is compatible with Smartphone and Audio with Headphones. Once a customer
qualifies through a mismatched repair, all their claims are counted by manufacturer.





For Q4, the two qualifying sample claims were approved in full, so their requested amounts equal
refund_value. The schema cannot independently represent requested amounts.
Q5 treats a ticket as a warranty job when the same device has an earlier Approved claim, submitted
on or before the new ticket’s receipt date, and the new ticket arrives within 90 days of the earlier
billing date. Each scenario requests one unit and runs inside a transaction that is rolled back, so
stock and allocations are unchanged afterwards. Scenario 5c adds a temporary claim to show the
warranty exception.
Q6 counts separate tickets by receipt month and year, including tickets still in progress.
