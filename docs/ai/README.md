# AIルール参照ガイド

このファイルは、Codex などの AI が作業前に参照するルールの索引である。
運用ルールの本文は各参照先に置き、同じ内容をこのファイルへ重複して書かない。

AI の作業手順として参照するカスタム指示は `docs/ai` に集約する。
DB 設計書由来の生成資料は、必要に応じて `docs/db` を参照する。

## ファイル編集

- ファイルを編集する際は該当ファイルを直接編集すると共に、編集内容を以下のルールで記録する
- [docs\ai\change-log-rule.md](change-log-rule.md)

## 常時参照

- [docs/ai/common.md](common.md)
- [docs/ai/repo-structure.md](repo-structure.md)
- [docs/ai/context-reporting.md](context-reporting.md)

## 状況別参照

### Git確認・差分確認時

- [docs/ai/git-notes.md](git-notes.md)

### マイグレーション確認時

- [docs/ai/migration-diff.md](migration-diff.md)

### Doma SQL 調査時

- [docs/ai/doma-sql-mapper.md](doma-sql-mapper.md)

### IFEdge・外部システム設定調査時

- [docs/ai/ifedge-external-system-setting.md](ifedge-external-system-setting.md)

### 連携イベント作成・中止ツール調査時

- [docs/ai/coop-event-tool.md](coop-event-tool.md)
- [docs/ai/pat-event-api.md](pat-event-api.md)
- [docs/ai/rad-order.md](rad-order.md)
- [docs/ai/coop-journal.md](coop-journal.md)

### ope_cd 調査時

- [docs/ai/ope-cd.md](ope-cd.md)
