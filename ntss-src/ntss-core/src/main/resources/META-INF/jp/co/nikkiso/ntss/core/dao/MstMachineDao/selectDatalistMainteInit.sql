WITH BASE_MAINTE AS (
  SELECT * FROM mnt_mainte_main                                                                       -- 点検結果
  WHERE is_del                      = '0'                                                             -- 削除フラグ
    AND is_disp                     = '1'                                                             -- 表示フラグ
    AND mainte_date                >= /*startDate*/NULL                                               -- 点検日
    AND mainte_date                 < (TO_TIMESTAMP(/*endDate*/NULL,'YYYY-MM-DD') + INTERVAL '1 day') -- 点検日
    AND facility_cd                 = /*facilityCd*/NULL                                              -- 施設コード
), DATA1 AS (
SELECT DISTINCT mm.mainte_no                                                                          -- 点検結果コード
     , ml.layout_name              AS category_name                                                   -- カテゴリー名
     , ''                          AS mainte_type                                                     -- 点検種別
     , ml.layout_class                                                                                -- レイアウトクラス
  FROM BASE_MAINTE mm                                                                                 -- 点検結果
 INNER JOIN mst_mainte_layout ml                                                                      -- 日常・定期点検レイアウトマスタ
    ON mm.mainte_layout_cd          = ml.mainte_layout_cd                                             -- 点検レイアウトコード
   AND ml.layout_class              = '1'                                                             -- レイアウトクラス
   AND ml.is_del                    = '0'                                                             -- 削除フラグ
   AND ml.is_disp                   = '1'                                                             -- 表示フラグ
), DATA2 AS (
SELECT DISTINCT mm.mainte_no                                                                          -- 点検結果コード
     , mg.group_name AS category_name                                                                 -- カテゴリー名
     , '点検記録簿'                  AS mainte_type                                                   -- 点検種別
     , ml.layout_class                                                                                -- レイアウトクラス
  FROM BASE_MAINTE mm                                                                                 -- 点検結果
 INNER JOIN mst_mainte_layout_group mg                                                                -- 定期点検機種別レイアウトマスタ
    ON mm.mainte_layout_group_cd    = mg.mainte_layout_group_cd                                       -- 点検レイアウトグループコード
   AND mg.is_del                    = '0'                                                             -- 削除フラグ
   AND mg.is_disp                   = '1'                                                             -- 表示フラグ
 INNER JOIN mst_mainte_layout ml                                                                      -- 日常・定期点検レイアウトマスタ
    ON mm.mainte_layout_cd          = ml.mainte_layout_cd                                             -- 点検レイアウトコード
   AND ml.layout_class              = '2'                                                             -- レイアウトクラス
   AND ml.is_del                    = '0'                                                             -- 削除フラグ
   AND ml.is_disp                   = '1'                                                             -- 表示フラグ
 CROSS JOIN jsonb_array_elements(ml.detail_info_1) di1                                                -- 詳細検査リスト1
 WHERE di1 ->> 'isDisp'             = 'true'                                                          -- 表示フラグ
), DATA3 AS (
SELECT DISTINCT mm.mainte_no                                                                          -- 点検結果コード
     , mg.group_name AS category_name                                                                 -- カテゴリー名
     , '交換部品記録簿'               AS mainte_type                                                  -- 点検種別
     , ml.layout_class                                                                                -- レイアウトクラス
  FROM BASE_MAINTE mm                                                                                 -- 点検結果
 INNER JOIN mst_mainte_layout_group mg                                                                -- 定期点検機種別レイアウトマスタ
    ON mm.mainte_layout_group_cd    = mg.mainte_layout_group_cd                                       -- 点検レイアウトグループコード
   AND mg.is_del                    = '0'                                                             -- 削除フラグ
   AND mg.is_disp                   = '1'                                                             -- 表示フラグ
 INNER JOIN mst_mainte_layout ml                                                                      -- 日常・定期点検レイアウトマスタ
    ON mm.mainte_layout_cd          = ml.mainte_layout_cd                                             -- 点検レイアウトコード
   AND ml.layout_class              = '2'                                                             -- レイアウトクラス
   AND ml.is_del                    = '0'                                                             -- 削除フラグ
   AND ml.is_disp                   = '1'                                                             -- 表示フラグ
 CROSS JOIN jsonb_array_elements(ml.detail_info_2) di2                                                -- 詳細検査リスト2
 WHERE di2 ->> 'isDisp'             = 'true'                                                          -- 表示フラグ
), DATA4 AS (
SELECT * FROM DATA1
 UNION ALL
SELECT * FROM DATA2
 UNION ALL
SELECT * FROM DATA3
), DATA5 AS (
SELECT DISTINCT mst.machine_type_cd                                                                   -- 型式コード
     , mst.machine_serial                                                                             -- 製造番号
     , mst.machine_name                                                                               -- 装置名
     , mst.machine_no                                                                                 -- 装置番号
     , mt.machine_type                                                                                -- 型式
     , mb.bed_name                                                                                    -- ベッド名
     , mst.setting_date                                                                               -- 設置日
     , DATA4.category_name                                                                            -- カテゴリー名
     , DATA4.mainte_type                                                                              -- 点検種別
     , DATA4.layout_class                                                                             -- 定期/日常
     , md.mainte_content_1                                                                            -- 項目1（定期・日常共通）
     , md.mainte_content_2                                                                            -- 項目2（定期・日常共通）
     , md.mainte_content_3                                                                            -- 項目3（定期のみ）
     , mnt.checker_id_1                                                                               -- 実施者（定期・日常共通）
     , mnt.checker_id_2                                                                               -- 確認者（定期のみ）
     , de ->> 'judge'              AS judge                                                           -- 点検結果（定期・日常共通）
     , mnt.rec_no                                                                                     -- 点検記録番号（定期のみ）
     , de ->> 'comment'            AS comment                                                         -- 点検コメント（日常のみ）
     , de ->> 'sub_cmt'            AS sub_cmt                                                         -- 補足コメント（定期・日常共通）
     , mnt.mainte_date                                                                                -- 点検日
  FROM (
     SELECT * FROM mst_machine                                                                        -- 装置マスタ
     WHERE facility_cd              = /*facilityCd*/NULL                                              -- 施設コード
       AND is_del                   = '0'                                                             -- 削除フラグ
       AND is_disp                  = '1'                                                             -- 表示フラグ
  ) mst
 INNER JOIN (
    SELECT * FROM BASE_MAINTE                                                                         -- 点検結果
    WHERE mainte_class              = '1'                                                             -- 検査型式
 ) mnt
    ON mnt.machine_no               = mst.machine_no                                                  -- 装置番号
 INNER JOIN DATA4
    ON DATA4.mainte_no              = mnt.mainte_no                                                   -- 点検結果コード
 CROSS JOIN jsonb_array_elements(mnt.detail) de                                                       -- 内容
 INNER JOIN mst_mainte_detail md                                                                      -- 日常・定期点検項目マスタ
    ON de ->> 'detail_cd'           = md.mainte_detail_cd::TEXT                                       -- 点検詳細品目コード
   AND md.is_del                    = '0'                                                             -- 削除フラグ
   AND md.is_disp                   = '1'                                                             -- 表示フラグ
  LEFT JOIN mst_machine_type mt                                                                       -- 型式マスタ
    ON mt.machine_type_cd           = mst.machine_type_cd                                             -- 型式コード
  LEFT JOIN mst_bed mb                                                                                -- ベッドマスタ
    ON mb.machine_no                = mst.machine_no                                                  -- 装置番号
   AND mb.is_del                    = '0'                                                             -- 削除フラグ
   AND mb.is_disp                   = '1'                                                             -- 表示フラグ
), DATA6 AS (
SELECT DISTINCT mnt.mainte_no                                                                         -- 点検結果コード
        , mnt.machine_no                                                                              -- 装置番号
        , mnt.rec_no                                                                                  -- 点検記録番号（定期のみ）
        , mnt.mainte_date                                                                             -- 点検日
        , mnt.checker_id_1                                                                            -- 実施者（定期・日常共通）
        , mnt.checker_id_2                                                                            -- 確認者（定期のみ）
        , mnt.is_disp                                                                                 -- 表示フラグ
        , mnt.is_del                                                                                  -- 削除フラグ
        , deTmp                                                                                       -- 内容
  FROM (
    SELECT * FROM BASE_MAINTE                                                                         -- 点検結果
    WHERE mainte_class              = '2'                                                             -- 検査型式
  ) mnt
  CROSS JOIN jsonb_array_elements(mnt.detail) deTmp                                                   -- 内容
), DATA7 AS (
SELECT DISTINCT DATA6.mainte_no                                                                       -- 点検結果コード
        , DATA6.machine_no                                                                            -- 装置番号
        , DATA6.rec_no                                                                                -- 点検記録番号（定期のみ）
        , DATA6.mainte_date                                                                           -- 点検日
        , DATA6.checker_id_1                                                                          -- 実施者（定期・日常共通）
        , DATA6.checker_id_2                                                                          -- 確認者（定期のみ）
        , DATA6.is_disp                                                                               -- 表示フラグ
        , DATA6.is_del                                                                                -- 削除フラグ
        , de                                                                                          -- 内容
  FROM DATA6
  CROSS JOIN jsonb_array_elements(DATA6.deTmp) de                                                     -- 内容
), DATA8 AS (
SELECT DISTINCT mst.machine_type_cd                                                                   -- 型式コード
        , mst.machine_serial                                                                          -- 製造番号
        , mst.machine_name                                                                            -- 装置名
        , mst.machine_no                                                                              -- 装置番号
        , mt.machine_type                                                                             -- 型式
        , mb.bed_name                                                                                 -- ベッド名
        , mst.setting_date                                                                            -- 設置日
        , DATA4.category_name                                                                         -- カテゴリー名
        , DATA4.mainte_type                                                                           -- 点検種別
        , DATA4.layout_class                                                                          -- 定期/日常
        , md.mainte_content_1                                                                         -- 項目1（定期・日常共通）
        , md.mainte_content_2                                                                         -- 項目2（定期・日常共通）
        , md.mainte_content_3                                                                         -- 項目3（定期のみ）
        , mnt.checker_id_1                                                                            -- 実施者（定期・日常共通）
        , mnt.checker_id_2                                                                            -- 確認者（定期のみ）
        , de ->> 'judge'              AS judge                                                        -- 点検結果（定期・日常共通）
        , mnt.rec_no                                                                                  -- 点検記録番号（定期のみ）
        , de ->> 'comment'            AS comment                                                      -- 点検コメント（日常のみ）
        , de ->> 'sub_cmt'            AS sub_cmt                                                      -- 補足コメント（定期・日常共通）
        , mnt.mainte_date                                                                             -- 点検日
  FROM (
     SELECT * FROM mst_machine                                                                        -- 装置マスタ
     WHERE facility_cd              = /*facilityCd*/NULL                                              -- 施設コード
       AND is_del                   = '0'                                                             -- 削除フラグ
       AND is_disp                  = '1'                                                             -- 表示フラグ
  ) mst
  INNER JOIN DATA7 mnt                                                                                -- 点検結果
  ON mnt.machine_no                 = mst.machine_no                                                  -- 装置番号
  INNER JOIN DATA4
  ON DATA4.mainte_no                = mnt.mainte_no                                                   -- 点検結果コード
  INNER JOIN mst_mainte_detail md                                                                     -- 日常・定期点検項目マスタ
  ON de ->> 'detail_cd'             = md.mainte_detail_cd::TEXT                                       -- 点検詳細品目コード
  AND md.is_del                     = '0'                                                             -- 削除フラグ
  AND md.is_disp                    = '1'                                                             -- 表示フラグ
  LEFT JOIN mst_machine_type mt                                                                       -- 型式マスタ
  ON mt.machine_type_cd             = mst.machine_type_cd                                             -- 型式コード
  LEFT JOIN mst_bed mb                                                                                -- ベッドマスタ
  ON mb.machine_no                  = mst.machine_no                                                  -- 装置番号
  AND mb.is_del                     = '0'                                                             -- 削除フラグ
  AND mb.is_disp                    = '1'                                                             -- 表示フラグ
)
SELECT DISTINCT machine_type_cd                                                                       -- 型式コード
     , machine_serial                                                                                 -- 製造番号
     , machine_name                                                                                   -- 装置名
     , machine_no                                                                                     -- 装置番号
     , machine_type                                                                                   -- 型式
     , bed_name                                                                                       -- ベッド名
     , setting_date                                                                                   -- 設置日
     , category_name                                                                                  -- カテゴリー名
     , mainte_type                                                                                    -- 点検種別
     , layout_class                                                                                   -- 定期/日常
     , mainte_content_1                                                                               -- 項目1（定期・日常共通）
     , mainte_content_2                                                                               -- 項目2（定期・日常共通）
     , mainte_content_3                                                                               -- 項目3（定期のみ）
     , ROW_NUMBER() OVER(PARTITION BY
       machine_type_cd                                                                                -- 型式コード
     , machine_serial                                                                                 -- 製造番号
     , machine_name                                                                                   -- 装置名
     , machine_no                                                                                     -- 装置番号
     , machine_type                                                                                   -- 型式
     , bed_name                                                                                       -- ベッド名
     , setting_date                                                                                   -- 設置日
     , category_name                                                                                  -- カテゴリー名
     , mainte_type                                                                                    -- 点検種別
     , layout_class                                                                                   -- 定期/日常
     , mainte_content_1                                                                               -- 項目1（定期・日常共通）
     , mainte_content_2                                                                               -- 項目2（定期・日常共通）
     , mainte_content_3                                                                               -- 項目3（定期のみ）
     , mainte_date                                                                                    -- 点検日
     )
  FROM DATA5
UNION ALL
SELECT DISTINCT machine_type_cd                                                                       -- 型式コード
     , machine_serial                                                                                 -- 製造番号
     , machine_name                                                                                   -- 装置名
     , machine_no                                                                                     -- 装置番号
     , machine_type                                                                                   -- 型式
     , bed_name                                                                                       -- ベッド名
     , setting_date                                                                                   -- 設置日
     , category_name                                                                                  -- カテゴリー名
     , mainte_type                                                                                    -- 点検種別
     , layout_class                                                                                   -- 定期/日常
     , mainte_content_1                                                                               -- 項目1（定期・日常共通）
     , mainte_content_2                                                                               -- 項目2（定期・日常共通）
     , mainte_content_3                                                                               -- 項目3（定期のみ）
     , ROW_NUMBER() OVER(PARTITION BY
       machine_type_cd                                                                                -- 型式コード
     , machine_serial                                                                                 -- 製造番号
     , machine_name                                                                                   -- 装置名
     , machine_no                                                                                     -- 装置番号
     , machine_type                                                                                   -- 型式
     , bed_name                                                                                       -- ベッド名
     , setting_date                                                                                   -- 設置日
     , category_name                                                                                  -- カテゴリー名
     , mainte_type                                                                                    -- 点検種別
     , layout_class                                                                                   -- 定期/日常
     , mainte_content_1                                                                               -- 項目1（定期・日常共通）
     , mainte_content_2                                                                               -- 項目2（定期・日常共通）
     , mainte_content_3                                                                               -- 項目3（定期のみ）
     , mainte_date                                                                                    -- 点検日
     )
  FROM DATA8
  ORDER BY machine_type_cd                                                                            -- 型式コード
     , machine_serial                                                                                 -- 製造番号
     , layout_class                                                                                   -- 定期/日常
     , mainte_type                                                                                    -- 型式
     , category_name;                                                                                 -- カテゴリー名
