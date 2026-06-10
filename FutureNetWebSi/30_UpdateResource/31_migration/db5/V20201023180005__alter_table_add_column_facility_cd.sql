-- 通知メッセージテーブル
ALTER TABLE
  mnt_notification_message
ADD COLUMN IF NOT EXISTS 
  facility_cd character varying(6)  --施設コード
;
COMMENT ON COLUMN "mnt_notification_message"."facility_cd" IS E'施設コード';


-- 通知状態管理
ALTER TABLE
  mnt_notification_status
ADD COLUMN IF NOT EXISTS 
  facility_cd character varying(6)  --施設コード
;
COMMENT ON COLUMN "mnt_notification_status"."facility_cd" IS E'施設コード';


-- 体重計状態管理
ALTER TABLE
  mnt_weight_state
ADD COLUMN IF NOT EXISTS 
  facility_cd character varying(6)  --施設コード
;
COMMENT ON COLUMN "mnt_weight_state"."facility_cd" IS E'施設コード';

UPDATE
  mnt_weight_state
SET
  facility_cd = mst_weight.facility_cd
FROM
  mst_weight
WHERE
  mnt_weight_state.weight_cd = mst_weight.weight_cd
;


-- 利用者マスタ
ALTER TABLE
  mst_user
ADD COLUMN IF NOT EXISTS 
  facility_cd character varying(6)  --施設コード
;
COMMENT ON COLUMN "mst_user"."facility_cd" IS E'施設コード';


-- 体重計印字項目マスタ
ALTER TABLE
  mst_weight_print
ADD COLUMN IF NOT EXISTS 
  facility_cd character varying(6)  --施設コード
;
COMMENT ON COLUMN "mst_weight_print"."facility_cd" IS E'施設コード';


-- チェックリスト実績
ALTER TABLE
  ord_checklist
ADD COLUMN IF NOT EXISTS 
  facility_cd character varying(6)  --施設コード
;
COMMENT ON COLUMN "ord_checklist"."facility_cd" IS E'施設コード';

UPDATE
  ord_checklist
SET
  facility_cd = ord_main.facility_cd
FROM
  ord_main
WHERE
  ord_checklist.ord_no = ord_main.ord_no
;


-- 患者グループ詳細
ALTER TABLE
  pat_group_detail
ADD COLUMN IF NOT EXISTS 
  facility_cd character varying(6)  --施設コード
;
COMMENT ON COLUMN "pat_group_detail"."facility_cd" IS E'施設コード';

UPDATE
  pat_group_detail
SET
  facility_cd = pat_group.facility_cd
FROM
  pat_group
WHERE
  pat_group_detail.pat_group_cd = pat_group.pat_group_cd
;


-- 指示受け承認情報
ALTER TABLE
  pat_ind_approve
ADD COLUMN IF NOT EXISTS 
  facility_cd character varying(6)  --施設コード
;
COMMENT ON COLUMN "pat_ind_approve"."facility_cd" IS E'施設コード';

UPDATE
  pat_ind_approve
SET
  facility_cd = ord_main.facility_cd
FROM
  ord_main
WHERE
  pat_ind_approve.ord_no = ord_main.ord_no
;


-- 指示受け・承認詳細
ALTER TABLE
  pat_ind_approve_history
ADD COLUMN IF NOT EXISTS 
  facility_cd character varying(6)  --施設コード
;
COMMENT ON COLUMN "pat_ind_approve_history"."facility_cd" IS E'施設コード';

UPDATE
  pat_ind_approve_history
SET
  facility_cd = ord_main.facility_cd
FROM
  ord_main
WHERE
  pat_ind_approve_history.ord_no = ord_main.ord_no
;


-- 患者基本情報
ALTER TABLE
  pat_unique
ADD COLUMN IF NOT EXISTS 
  facility_cd character varying(6)  --施設コード
;
COMMENT ON COLUMN "pat_unique"."facility_cd" IS E'施設コード';

UPDATE
  pat_unique
SET
  facility_cd = pat_main.facility_cd
FROM
  pat_main
WHERE
  pat_unique.pat_id = pat_main.pat_id
;
