WITH DATA1 AS (
SELECT DISTINCT mm.mainte_no                                                      -- 点検結果コード
     , ml.layout_name              AS category_name                               -- カテゴリー名
     , ''                          AS mainte_type                                 -- 点検種別
     , ml.layout_class                                                            -- レイアウトクラス
  FROM mnt_mainte_main mm                                                         -- 点検結果
 INNER JOIN mst_mainte_layout ml                                                  -- 日常・定期点検レイアウトマスタ
    ON mm.mainte_layout_cd          = ml.mainte_layout_cd                         -- 点検レイアウトコード
   AND ml.facility_cd = /*facilityCd*/NULL
   AND ml.layout_class              = '1'                                         -- レイアウトクラス
   AND ml.is_del                    = '0'                                         -- 削除フラグ
   AND ml.is_disp                   = '1'                                         -- 表示フラグ
 WHERE mm.is_del                    = '0'                                         -- 削除フラグ
   AND mm.is_disp                   = '1'                                         -- 表示フラグ
   AND date(mm.mainte_date)       >= /*startDate*/NULL                           -- 点検日
   AND date(mm.mainte_date)       <= /*endDate*/NULL                             -- 点検日
   AND mm.facility_cd = /*facilityCd*/NULL
), DATA2 AS (
SELECT DISTINCT mm.mainte_no                                                      -- 点検結果コード
     , mg.group_name AS category_name                                                           -- カテゴリー名
     , '点検記録簿'                  AS mainte_type                                 -- 点検種別
     , ml.layout_class                                                            -- レイアウトクラス
  FROM mnt_mainte_main mm                                                         -- 点検結果
 INNER JOIN mst_mainte_layout_group mg                                            -- 定期点検機種別レイアウトマスタ
    ON mm.mainte_layout_group_cd    = mg.mainte_layout_group_cd                   -- 点検レイアウトグループコード
   AND mg.facility_cd = /*facilityCd*/NULL
   AND mg.is_del                    = '0'                                         -- 削除フラグ
   AND mg.is_disp                   = '1'                                         -- 表示フラグ
    AND date(mm.mainte_date)       >= /*startDate*/NULL                           -- 点検日
    AND date(mm.mainte_date)       <= /*endDate*/NULL                             -- 点検日
 INNER JOIN mst_mainte_layout ml                                                  -- 日常・定期点検レイアウトマスタ
    ON mm.mainte_layout_cd          = ml.mainte_layout_cd                         -- 点検レイアウトコード
   AND ml.facility_cd = /*facilityCd*/NULL
   AND ml.layout_class              = '2'                                         -- レイアウトクラス
   AND ml.is_del                    = '0'                                         -- 削除フラグ
   AND ml.is_disp                   = '1'                                         -- 表示フラグ
 CROSS JOIN jsonb_array_elements(mm.detail) di1                          -- 詳細検査リスト1
 CROSS JOIN jsonb_array_elements(di1) di2                            -- 詳細検査リスト1
  LEFT JOIN mst_mainte_category mc                                                -- 日常・定期点検項目グループマスタ
    ON mc.mainte_category_cd::TEXT  = di2 ->> 'cate_cd'                                -- 点検カテゴリコード
   AND mc.facility_cd = /*facilityCd*/NULL
 WHERE mm.is_del                    = '0'                                         -- 削除フラグ
   AND mm.is_disp                   = '1'                                         -- 表示フラグ
   AND di2 ->> 'tableIndex'         = '1'
   AND mm.facility_cd = /*facilityCd*/NULL
), DATA3 AS (
SELECT DISTINCT mm.mainte_no                                                      -- 点検結果コード
     , mg.group_name AS category_name                                                           -- カテゴリー名
     , '交換部品記録簿'               AS mainte_type                                 -- 点検種別
     , ml.layout_class                                                            -- レイアウトクラス
  FROM mnt_mainte_main mm                                                         -- 点検結果
 INNER JOIN mst_mainte_layout_group mg                                            -- 定期点検機種別レイアウトマスタ
    ON mm.mainte_layout_group_cd    = mg.mainte_layout_group_cd                   -- 点検レイアウトグループコード
   AND mg.facility_cd = /*facilityCd*/NULL
   AND mg.is_del                    = '0'                                         -- 削除フラグ
   AND mg.is_disp                   = '1'                                         -- 表示フラグ
   AND date(mm.mainte_date)       >= /*startDate*/NULL                           -- 点検日
   AND date(mm.mainte_date)       <= /*endDate*/NULL                             -- 点検日
 INNER JOIN mst_mainte_layout ml                                                  -- 日常・定期点検レイアウトマスタ
    ON mm.mainte_layout_cd          = ml.mainte_layout_cd                         -- 点検レイアウトコード
   AND ml.facility_cd = /*facilityCd*/NULL
   AND ml.layout_class              = '2'                                         -- レイアウトクラス
   AND ml.is_del                    = '0'                                         -- 削除フラグ
   AND ml.is_disp                   = '1'                                         -- 表示フラグ
    CROSS JOIN jsonb_array_elements(mm.detail) di3                          -- 詳細検査リスト1
    CROSS JOIN jsonb_array_elements(di3) di4                            -- 詳細検査リスト1
  LEFT JOIN mst_mainte_category mc                                                -- 日常・定期点検項目グループマスタ
    ON mc.mainte_category_cd::TEXT  = di4 ->> 'cate_cd'                                -- 点検カテゴリコード
   AND mc.facility_cd = /*facilityCd*/NULL
 WHERE mm.is_del                    = '0'                                         -- 削除フラグ
   AND mm.is_disp                   = '1'                                         -- 表示フラグ
   AND di4 ->> 'tableIndex'         = '2'
   AND mm.facility_cd = /*facilityCd*/NULL
), DATA4 AS (
SELECT * FROM DATA1
 UNION ALL
SELECT * FROM DATA2
 UNION ALL
SELECT * FROM DATA3
), DATA7 AS (
SELECT
    mnt.mainte_no
  , mnt.machine_no
  , mnt.mainte_date
  , mnt.checker_id_1
  , mnt.checker_id_2
  , mnt.rec_no
  , mnt.is_del
  , mnt.is_disp
  , de
FROM ntss.mnt_mainte_main mnt
    CROSS JOIN LATERAL jsonb_array_elements(mnt.detail) deTmp
    CROSS JOIN LATERAL jsonb_array_elements(deTmp) de
WHERE mnt.mainte_class = '2'
  AND mnt.is_del                   = '0'                                         -- 削除フラグ
  AND mnt.is_disp                  = '1'                                         -- 表示フラグ
  AND date(mnt.mainte_date)       >= /*startDate*/NULL                           -- 点検日
  AND date(mnt.mainte_date)       <= /*endDate*/NULL                             -- 点検日
  AND mnt.facility_cd = /*facilityCd*/NULL
  AND de ->> 'tableIndex'          = '2'
)
SELECT DISTINCT mst.machine_type_cd                                               -- 型式コード
              , mst.machine_serial                                                         -- 製造番号
              , mst.machine_name                                                           -- 装置名
              , mst.machine_no                                                             -- 装置番号
              , mt.machine_type                                                            -- 型式
              , mb.bed_name                                                                -- ベッド名
              , mst.setting_date                                                           -- 設置日
              , DATA4.category_name                                                        -- カテゴリー名
              , DATA4.mainte_type                                                          -- 点検種別
              , DATA4.layout_class                                                         -- 定期/日常
              , md.mainte_content_1                                                        -- 項目1（定期・日常共通）
              , md.mainte_content_2                                                        -- 項目2（定期・日常共通）
              , md.mainte_content_3                                                        -- 項目3（定期のみ）
              , mnt.checker_id_1                                                           -- 実施者（定期・日常共通）
              , mnt.checker_id_2                                                           -- 確認者（定期のみ）
              , de ->> 'judge'              AS judge                                       -- 点検結果（定期・日常共通）
              , mnt.rec_no                                                                 -- 点検記録番号（定期のみ）
              , de ->> 'comment'            AS comment                                     -- 点検コメント（日常のみ）
              , de ->> 'sub_cmt'            AS sub_cmt                                     -- 補足コメント（定期・日常共通）
              , mnt.mainte_date                                                            -- 点検日
FROM mst_machine mst                                                            -- 装置マスタ
    INNER JOIN DATA7 mnt                                                   -- 点検結果
ON mnt.machine_no               = mst.machine_no                              -- 装置番号
    AND date(mnt.mainte_date)       >= /*startDate*/NULL                           -- 点検日
    AND date(mnt.mainte_date)       <= /*endDate*/NULL                             -- 点検日
    AND mnt.is_del                   = '0'                                         -- 削除フラグ
    AND mnt.is_disp                  = '1'                                         -- 表示フラグ
    INNER JOIN DATA3 DATA4
    ON DATA4.mainte_no              = mnt.mainte_no                               -- 点検結果コード
    INNER JOIN mst_mainte_detail md                                                  -- 日常・定期点検項目マスタ
    ON de ->> 'detail_cd'           = md.mainte_detail_cd::TEXT                   -- 点検詳細品目コード
    AND md.facility_cd = /*facilityCd*/NULL
    AND md.is_del                    = '0'                                         -- 削除フラグ
    AND md.is_disp                   = '1'                                         -- 表示フラグ
    AND de ->> 'tableIndex'          = '2'
    LEFT JOIN mst_machine_type mt                                                   -- 型式マスタ
    ON mt.machine_type_cd           = mst.machine_type_cd                         -- 型式コード
    LEFT JOIN mst_bed mb                                                            -- ベッドマスタ
    ON mb.machine_no                = mst.machine_no                              -- 装置番号
    AND mb.is_del                    = '0'                                         -- 削除フラグ
    AND mb.is_disp                   = '1'                                         -- 表示フラグ
    AND mb.facility_cd = /*facilityCd*/NULL
WHERE mst.facility_cd              = /*facilityCd*/NULL                          -- 施設コード
  AND mst.is_del                   = '0'                                         -- 削除フラグ
  AND mst.is_disp                  = '1'                                         -- 表示フラグ
 ORDER BY machine_type_cd                                                         -- 型式コード
     , machine_serial                                                             -- 製造番号
