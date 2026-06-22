-- client_cer_detail テーブルに file_rand_suffix カラムを追加する。
--
-- カラム仕様:
--   カラム名 : file_rand_suffix
--   型       : character varying(3)、NULL 許容
--   設定値   : 100〜999 の3桁数字文字列（例："435"）
--              マージ発行時（is_merge_issued = '1'）にのみ設定される。
--              管理側から通常発行された証明書には設定されない（NULL）。
--
-- 用途:
--   証明書マージ機能において、同一の CN 組み合わせ（例："NKKSBR CONV45"）が
--   複数回マージされた場合でもディスク上のファイルが上書きされないよう、
--   保存ファイル名の末尾にランダムサフィックスを付与するために使用する。
--   例: /nfs/p12-path/NKKSBR/NKKSBR CONV45_435.p12
--
-- 後方互換:
--   本カラム追加前の既存レコードは NULL のままとなる。
--   ファイル読み取り時は NULL チェックを行い、
--   NULL の場合はサフィックスを付与せずに旧形式のファイルパスを使用する。
ALTER TABLE client_cer_detail
    ADD COLUMN IF NOT EXISTS file_rand_suffix character varying(3);

COMMENT ON COLUMN client_cer_detail.file_rand_suffix IS
'ファイル名ランダムサフィックス（3桁数字文字列、例: ''435''）。'
'マージ発行時（is_merge_issued = ''1''）にのみ設定され、管理側通常発行レコードは NULL。'
'同一CN組み合わせの複数回マージによるディスク上のファイル上書きを防ぐため、保存ファイル名末尾に付与する。'
'例: /nfs/p12-path/NKKSBR/NKKSBR CONV45_435.p12。'
'NULL の場合はサフィックスを付与せず旧形式のファイルパスを使用する（後方互換）。';
