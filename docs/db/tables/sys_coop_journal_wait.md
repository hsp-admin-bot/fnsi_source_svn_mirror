# sys_coop_journal_wait

- Source workbook: `NTSSデータベース設計書_外部データ連携.xlsm`
- Source sheet: `sys_coop_journal_wait(削除済み)`
- Logical name: 外部連携用ジャーナル
- Physical name: `sys_coop_journal_wait`
- Source physical cell: `sys_coop_journal_wait(削除済み)`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `ctl_no`

## Related Config / Reference Values

- [../config/coop_cd.md](../config/coop_cd.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 管理番号 | ctl_no | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  |  |
|  | 電文種別 | coop_cd | character varying | 20 | 1 |  | 電文種別（機能）の名称<br>シート@coop_cdを参照 |
|  | 付帯情報（電文） | coop_cd_index | character varying | 10 | 1 | '' | （IBM)電文種別の付帯情報<br>レポート等にも使う?<br>'同一電文種別で複数のレイアウトが必要な際に使用する |
|  | 作成更新区分 | crud | character varying | 1 | 1 |  | C:新規   U:更新    D:削除 |
|  | 向き（送受信） | direction | character varying | 1 | 1 |  | S:送信　R:受信 |
|  | （次世代FN)オーダ番号 | ord_no | bigint |  |  |  | システムから付番したオーダ番号 |
|  | （連携先)オーダ番号 | coop_ord_no | character varying |  |  |  | カルテから付番されてきたオーダ番号 |
|  | 患者番号（連携用） | hosp_pat_id | character varying | 12 |  |  | hosp_pat_id |
|  | 患者番号（システム） | pat_id | bigint |  |  |  | pat_id |
|  | 受付番号 | accept_no | bigint |  |  |  |  |
|  | 基準日 | base_date | timestamp(3) |  |  |  | 予定送信時や実績送信時、<br>オーダ受け時の透析日や検査日をジャーナルに格納する |
|  | レポートCD | report_cd | bigint |  |  |  | mst_reportとの関連付けに使用する |
|  | 変換処理ステータス | ana_result | character varying | 2 | 1 | '0' | 0:未処理<br>1:処理中<br>9:処理完了<br><br>S:スキップ<br>E1:内部エラー（NKK内部処理でのエラー）<br>E2:外部エラー（電カルからのエラーリターン。ないと思う） |
|  | 変換処理開始日時 | in_ana_date | timestamp(3) |  |  |  |  |
|  | 変換処理完了日時 | out_ana_date | timestamp(3) |  |  |  |  |
|  | 配信処理ステータス | coop_result | character varying | 2 | 1 | '0' | 0:未処理<br>1:処理中<br>8:応答待ち<br>9:処理完了<br><br>R:リトライ<br>S:スキップ<br>E1:内部エラー（NKK内部処理でのエラー９<br>E2:外部エラー（電カルからのエラーリターン） |
|  | 配信処理開始日時 | in_reg_date | timestamp(3) |  |  |  |  |
|  | 配信処理完了日時 | out_reg_date | timestamp(3) |  |  |  |  |
|  | メッセージ | message | character varying |  |  |  | エラーメッセージ等を格納する |
|  | 電文パス | dump_path | character varying |  |  |  | 電文ファイルの格納されている共有ﾌｫﾙﾀﾞへのリンク |
|  | 電文内容 | dump | bytea |  |  |  | 電文の中身 |
|  | 編集可否フラグ | is_editable | character varying | 1 | 1 | '1' | '0'：編集不可、'1'：編集可 |
|  | 削除フラグ | is_del | character varying | 1 | 1 | '0' | '0':通常、'1':削除 |
|  | 操作者ID | user_id | bigint |  |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |

## SQL

```sql
↓★以下のSQL文をコピーし、「A5(SQL Mk-2)」から実行して下さい
■SQL文
-- テーブル削除
DROP TABLE IF EXISTS sys_coop_journal_wait(削除済み);
-- テーブル作成
CREATE TABLE sys_coop_journal_wait(削除済み)
(
ctl_no bigserial NOT NULL,  --管理番号
facility_cd character varying(6) NOT NULL,  --施設コード
coop_cd character varying(20) NOT NULL,  --電文種別
coop_cd_index character varying(10) NOT NULL DEFAULT '',  --付帯情報（電文）
crud character varying(1) NOT NULL,  --作成更新区分
direction character varying(1) NOT NULL,  --向き（送受信）
ord_no bigint,  --（次世代FN)オーダ番号
coop_ord_no character varying,  --（連携先)オーダ番号
hosp_pat_id character varying(12),  --患者番号（連携用）
pat_id bigint,  --患者番号（システム）
accept_no bigint,  --受付番号
base_date timestamp(3),  --基準日
report_cd bigint,  --レポートCD
ana_result character varying(2) NOT NULL DEFAULT '0',  --変換処理ステータス
in_ana_date timestamp(3),  --変換処理開始日時
out_ana_date timestamp(3),  --変換処理完了日時
coop_result character varying(2) NOT NULL DEFAULT '0',  --配信処理ステータス
in_reg_date timestamp(3),  --配信処理開始日時
out_reg_date timestamp(3),  --配信処理完了日時
message character varying,  --メッセージ
dump_path character varying,  --電文パス
dump bytea,  --電文内容
is_editable character varying(1) NOT NULL DEFAULT '1',  --編集可否フラグ
is_del character varying(1) NOT NULL DEFAULT '0',  --削除フラグ
user_id bigint,  --操作者ID
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_sys_coop_journal_wait(削除済み)_01 PRIMARY KEY (ctl_no)
using index tablespace ntss_index5
)
WITH (
OIDS=FALSE
)
tablespace ntss_db5;
-- ユーザ設定
ALTER TABLE sys_coop_journal_wait(削除済み) OWNER TO nkk5;
-- コメント追加
COMMENT ON TABLE "sys_coop_journal_wait(削除済み)" IS E'外部連携用ジャーナル';
COMMENT ON COLUMN "sys_coop_journal_wait(削除済み)"."ctl_no" IS E'管理番号';
COMMENT ON COLUMN "sys_coop_journal_wait(削除済み)"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "sys_coop_journal_wait(削除済み)"."coop_cd" IS E'電文種別';
COMMENT ON COLUMN "sys_coop_journal_wait(削除済み)"."coop_cd_index" IS E'付帯情報（電文）';
COMMENT ON COLUMN "sys_coop_journal_wait(削除済み)"."crud" IS E'作成更新区分';
COMMENT ON COLUMN "sys_coop_journal_wait(削除済み)"."direction" IS E'向き（送受信）';
COMMENT ON COLUMN "sys_coop_journal_wait(削除済み)"."ord_no" IS E'（次世代FN)オーダ番号';
COMMENT ON COLUMN "sys_coop_journal_wait(削除済み)"."coop_ord_no" IS E'（連携先)オーダ番号';
COMMENT ON COLUMN "sys_coop_journal_wait(削除済み)"."hosp_pat_id" IS E'患者番号（連携用）';
COMMENT ON COLUMN "sys_coop_journal_wait(削除済み)"."pat_id" IS E'患者番号（システム）';
COMMENT ON COLUMN "sys_coop_journal_wait(削除済み)"."accept_no" IS E'受付番号';
COMMENT ON COLUMN "sys_coop_journal_wait(削除済み)"."base_date" IS E'基準日';
COMMENT ON COLUMN "sys_coop_journal_wait(削除済み)"."report_cd" IS E'レポートCD';
COMMENT ON COLUMN "sys_coop_journal_wait(削除済み)"."ana_result" IS E'変換処理ステータス';
COMMENT ON COLUMN "sys_coop_journal_wait(削除済み)"."in_ana_date" IS E'変換処理開始日時';
COMMENT ON COLUMN "sys_coop_journal_wait(削除済み)"."out_ana_date" IS E'変換処理完了日時';
COMMENT ON COLUMN "sys_coop_journal_wait(削除済み)"."coop_result" IS E'配信処理ステータス';
COMMENT ON COLUMN "sys_coop_journal_wait(削除済み)"."in_reg_date" IS E'配信処理開始日時';
COMMENT ON COLUMN "sys_coop_journal_wait(削除済み)"."out_reg_date" IS E'配信処理完了日時';
COMMENT ON COLUMN "sys_coop_journal_wait(削除済み)"."message" IS E'メッセージ';
COMMENT ON COLUMN "sys_coop_journal_wait(削除済み)"."dump_path" IS E'電文パス';
COMMENT ON COLUMN "sys_coop_journal_wait(削除済み)"."dump" IS E'電文内容';
COMMENT ON COLUMN "sys_coop_journal_wait(削除済み)"."is_editable" IS E'編集可否フラグ';
COMMENT ON COLUMN "sys_coop_journal_wait(削除済み)"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "sys_coop_journal_wait(削除済み)"."user_id" IS E'操作者ID';
COMMENT ON COLUMN "sys_coop_journal_wait(削除済み)"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "sys_coop_journal_wait(削除済み)"."up_date" IS E'更新日時';
■テストデータ
ctl_no
```
