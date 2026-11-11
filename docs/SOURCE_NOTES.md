# Source notes

## Selected material

The content source is `Lab5_SDAG_Team3 (3).pdf`, a 38-page report recovered from local downloads. Its local modification time is 30 October 2026 at 00:43 (Singapore time), later than the other recovered report variants. The `(2)` and `(3)` variants have the same extracted technical text; their text differences concern contribution descriptions. The older 37-page report differs materially and was not used for the extracted SQL.

This selection identifies the latest recovered local variant, not proof of what was ultimately uploaded to the university. The user requested content only, so the full report, team contribution material and signatures are not included.

| Repository content | Source |
| --- | --- |
| `diagrams/lab5-er-diagram.png` | Embedded image on report page 3, extracted without redrawing |
| `schema/relational-schema.md` | Report pages 4-8; continued table rows joined |
| `schema/create_tables.sql` | Report pages 9-14 |
| `data/sample_data.sql` | Report pages 15-18 |
| `docs/ASSUMPTIONS.md` | Report pages 21-22 |
| Nine numbered query files | Report pages 23-37; individual page references in file headers |
| `schema/originals/techpulse_setup_updated.sql` | Unchanged local standalone setup script |
| `queries/originals/techpulse_queries_updated.sql` | Unchanged local standalone query script |
| Two `SC2207_LAB.drawio*.png` files | Unchanged original local diagram exports |

Source hashes and extraction transformations are recorded in [SOURCE_MANIFEST.json](SOURCE_MANIFEST.json). The original SQL files are working source artifacts, not assumed to be identical to every query printed in the report. The numbered query files are the submitted versions.

## Preserved differences

- The report's PURCHASED_ORDER schema table describes `(purchase_id, vendor_id)` as its primary key; the SQL defines `purchase_id` as the primary key. Both source representations are retained.
- The STOCK_REQUEST schema table names `request_id` as its key, but its normalization explanation refers to a composite key involving `part_code`. The SQL implements `request_id` as the primary key.
- CLIENT, CATALOG and WORK_SESSION list alternate functional dependencies while some normalization wording refers to only one non-trivial dependency. That wording is preserved as submitted.
- Q4 retains the alias `approved_claims_with_qualifying_inspection` even though the submitted query has no Approved-only filter. Its payout interpretation depends on the report's stated assumption.
- The standalone query script uses different formulations for several queries, including Q1's `DATEDIFF(MINUTE, ...)` compared with the submission's second-based duration calculation. The originals are retained in their own folders so these versions are not mixed.
- The diagram named exactly `SC2207_LAB.drawio.png` is an earlier export. The ER image extracted from the selected Lab 5 report is presented as the primary preview.

These notes describe source differences; they do not constitute a new correctness audit or changes to the submitted work.

## Completeness

All requested categories were recovered: ER diagrams, relational schema tables, SQL table definitions, sample insertions and Lab 5 Queries 1-7. The complete report and recordings are intentionally excluded from this content-only repository. Fresh SQL Server execution results and independent confirmation of the official university submission are unavailable.

The repository does not assign a new open-source license or claim sole authorship of the team coursework.
