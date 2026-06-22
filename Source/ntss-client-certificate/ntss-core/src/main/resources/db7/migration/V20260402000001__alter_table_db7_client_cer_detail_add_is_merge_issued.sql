-- client_cer_detail テーブルに is_merge_issued カラムを追加する。
--
-- カラム仕様:
--   カラム名 : is_merge_issued
--   型       : character varying(1)、NULL 許容
--   取得値   : '1' = ntss-certificate-download の証明書マージ機能で発行
--              '0' または NULL = 管理側（ntss-certificate-management）から通常発行
--
-- 用途:
--   ntss-certificate-download の /user 画面（証明書ダウンロード一覧）において、
--   is_merge_issued = '1' のレコードを表示対象から除外するために使用する。
--   マージ発行証明書はマージ完了時にその場でダウンロードするため、
--   ダウンロード一覧への表示は不要。
ALTER TABLE client_cer_detail
    ADD COLUMN IF NOT EXISTS is_merge_issued character varying(1);

COMMENT ON COLUMN client_cer_detail.is_merge_issued IS
'マージ発行フラグ。'
'取得値: ''1'' = ntss-certificate-download の証明書マージ機能（/merge 画面）で発行、''0'' または NULL = 管理側（ntss-certificate-management）から通常発行。'
'is_merge_issued = ''1'' のレコードは ntss-certificate-download の /user 画面（証明書ダウンロード一覧）の表示対象から除外される。';
