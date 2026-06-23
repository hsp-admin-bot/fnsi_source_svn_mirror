-- mst_personal_tab_defineに列を追加
ALTER TABLE
  mst_personal_tab_define
ADD COLUMN mode character varying(1) -- モード 1.共通画面を使用 2.個別画面を使用
;
COMMENT ON COLUMN "mst_personal_tab_define"."mode" IS E'モード 1.共通画面を使用 2.個別画面を使用';

-- マイグレーション時に存在するレコードは一律「個別画面」に。この時点で「独自画面」はないので。
UPDATE
  mst_personal_tab_define
SET
  mode='2'
;

-- modeカラムをNOT NULLに。
ALTER TABLE
  mst_personal_tab_define
ALTER COLUMN mode SET NOT NULL
;

