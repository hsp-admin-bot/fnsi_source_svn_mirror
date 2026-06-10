# NTSS Database Design

- Source workbook: `NTSSデータベース設計書.xlsm`
- Output policy: avoid raw cell dumps and full generated SQL; keep table definitions, config/reference sheets, and guides at a codebase-oriented granularity.
- Layout: `tables/` for table definitions, `config/` for settings and JSON/reference notes, `data/` for sample/comment data, `overview/` and `guides/` for workbook-level references.

## Counts

- Tables: 204
- Config/reference sheets: 100
- Data/sample sheets: 3
- Overview sheets: 9
- Guide sheets: 8

## Entry Points

- [overview/table-summary.md](overview/table-summary.md)
- [overview/table-list.md](overview/table-list.md)
- [overview/indexes.md](overview/indexes.md)
- [guides/db-design-rules.md](guides/db-design-rules.md)
- [guides/available-types.md](guides/available-types.md)

## Table Groups

- `bbs`: 1
- `log`: 6
- `maintenance-state`: 18
- `master`: 119
- `monitoring`: 1
- `order-treatment`: 12
- `other`: 1
- `patient`: 19
- `sales`: 1
- `system`: 26
