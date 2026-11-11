# Repository verification

Checked on 11 November 2026 during repository assembly.

- All 19 extracted CREATE TABLE definitions match the original standalone setup script after excluding comments, batch separators and formatting whitespace. String values were compared exactly.
- All 19 extracted INSERT statements match that same original setup script under the same comparison.
- Nine numbered query files were extracted from the selected Lab 5 report: Q1-Q4, Q5a-Q5c, Q6 and Q7. Parentheses are balanced, and each Q5 file includes its transaction and rollback boundaries.
- PDF line wraps inside string literals were restored using matching literal values in the original SQL. Each transformation is recorded in SOURCE_MANIFEST.json. All three extracted Q5 transaction blocks match the original standalone query script after excluding comments, batch separators and formatting whitespace; string values were compared exactly.
- All unchanged original files match their source SHA-256 hashes.
- All local Markdown links resolve.
- No full PDF, Word document, recording or contribution form is included.

These are source-fidelity and packaging checks, not SQL Server execution tests. Database behavior and fresh outputs have not been independently verified in this session. The submitted diagram and schema documentation may differ from the SQL as described in SOURCE_NOTES.md.
