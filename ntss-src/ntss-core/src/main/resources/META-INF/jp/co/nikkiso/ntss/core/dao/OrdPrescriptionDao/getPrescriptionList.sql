WITH  data1 AS (
     SELECT pat_id                                                                                                   -- 患者ID
          , prescription_type                                                                                        -- 処方種別
          , REPLACE ( SUBSTRING ( to_timestamp( issue_date, 'YYYYMMDD' ) :: TEXT, 1, 10 ), '-', '/' ) AS issue_date  -- 交付日
          , issue_date AS issue_date2                                                                                -- 交付日
          , issue_state                                                                                              -- 交付状態
          , ord_prescription_no                                                                                      -- 処方オーダー番号
       FROM ord_prescription                                                                                         -- 処方情報
      WHERE is_del = '0'                                                                                             -- 削除フラグ
        AND is_disp = '1'                                                                                            -- 表示フラグ
        AND pat_id IN /* patIdList */(0)                                                                             -- 患者ID
     )
    , data1_1 AS (
     SELECT ROW_NUMBER () OVER ( PARTITION BY pat_id ORDER BY issue_state, prescription_type, ord_prescription_no ) AS row_num
          , pat_id
          , prescription_type
          , issue_date2
          , issue_state
          , ord_prescription_no
       FROM data1
      WHERE data1.issue_date2 = /* issueDate */''
     )
    , data2 AS (
     SELECT ROW_NUMBER () OVER ( PARTITION BY pat_id ORDER BY issue_date DESC, issue_state, prescription_type, ord_prescription_no ) AS row_num -- ランキング
          , pat_id                                                                                                   -- 患者ID
          , prescription_type                                                                                        -- 処方種別
          , issue_date                                                                                               -- 交付日
          , issue_state                                                                                              -- 交付状態
          , ord_prescription_no                                                                                      -- 処方オーダー番号
       FROM data1
      WHERE issue_date < REPLACE ( SUBSTRING ( to_timestamp( /* issueDate */'', 'YYYYMMDD' ) :: TEXT, 1, 10 ), '-', '/' ) -- 交付日
        AND prescription_type IN /* prescriptionTypeList */('')                                                       -- 処方種別
     )
    , data3 AS (
     SELECT pat_id                                                                                                   -- 患者ID
          , prescription_type                                                                                        -- 処方種別
          , issue_date                                                                                               -- 交付日
          , issue_state                                                                                              -- 交付状態
          , ord_prescription_no                                                                                      -- 処方オーダー番号
          , 1 AS ord_no                                                                                              -- 順序
       FROM data2
      WHERE row_num <= 3                                                                                             -- ランキング
     )
    , data4 AS (
     SELECT ROW_NUMBER () OVER ( PARTITION BY pat_id ORDER BY issue_date ASC, issue_state, prescription_type, ord_prescription_no ) AS row_num                           -- ランキング
          , pat_id                                                                                                   -- 患者ID
          , prescription_type                                                                                        -- 処方種別
          , issue_date                                                                                               -- 交付日
          , issue_state                                                                                              -- 交付状態
          , ord_prescription_no                                                                                      -- 処方オーダー番号
       FROM data1
      WHERE issue_date > to_char( now(), 'YYYY/MM/DD' )                                                              -- 交付日
     )
    , data5 AS (
     SELECT pat_id                                                                                                   -- 患者ID
          , prescription_type                                                                                        -- 処方種別
          , issue_date                                                                                               -- 交付日
          , issue_state                                                                                              -- 交付状態
          , ord_prescription_no                                                                                      -- 処方オーダー番号
          , 0 AS ord_no                                                                                              -- 順序
       FROM data4
      WHERE row_num = 1                                                                                             -- ランキング
     )
    , data6 AS (
     SELECT * FROM data3
      UNION ALL
     SELECT * FROM data5
     )
    , order_data AS (
     SELECT pat_id
            ,ord_no
            ,facility_cd
            ,treat_date
            ,CASE WHEN ind_kur_cd = 0 THEN '未登録' ELSE ind_kur_name END AS ind_kur_name
            ,ind_kur_cd
            ,CASE WHEN ind_bed_cd = 0 THEN '未登録' ELSE ind_bed_name END AS ind_bed_name
            ,ind_bed_cd
            ,CASE WHEN ind_treatment_cd = 0 THEN '未登録' ELSE ind_treatment_name END AS ind_treatment_name
            ,ind_treatment_cd
       FROM ord_main main
      WHERE main.is_del = '0'
        AND main.treat_date = /* issueDate */''
        AND pat_id IN /* patIdList */(0)
     )
     , mss_treatment as (
     SELECT ROW_NUMBER() OVER() AS idx
                ,ms.code
                ,mss.facility_cd
          FROM mst_selector mss
        CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> 'items') AS ms(code BIGINT)
        WHERE master_physical_name = 'mst_treatment'
     )
     , mss_bed as (
     SELECT ROW_NUMBER() OVER() AS idx
                ,ms.code
                ,mss.facility_cd
          FROM mst_selector mss
        CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> 'items') AS ms(code BIGINT)
        WHERE master_physical_name = 'mst_bed'
     )
     , order_data2 AS (
      SELECT DISTINCT ON  (pat_id) pat_id
             ,treat_date
             ,CASE WHEN mst_kur.is_del = '1' THEN '【削除済み】' ELSE '' END  || COALESCE(ind_kur_name, mst_kur.kur_name) AS ind_kur_name
             ,CASE WHEN mst_bed.is_del = '1' OR mst_bed.is_disp = '0' THEN '【削除済み】' ELSE '' END  || COALESCE(ind_bed_name, mst_bed.bed_name) AS ind_bed_name
             ,CASE WHEN mst_treatment.is_del = '1' OR mst_treatment.is_disp = '0'  THEN '【削除済み】' ELSE '' END  || COALESCE(ind_treatment_name, mst_treatment.treatment_name) AS ind_treatment_name
             ,CASE WHEN ind_kur_name = '未登録' THEN '999999' ELSE mst_kur.kur_start_time END AS kur_start_time
             ,CASE WHEN ind_bed_name = '未登録' THEN 999999 ELSE mss_bed.idx END AS bed_order_index
             ,mss_treatment.idx AS treatment_order_index
       FROM order_data
       LEFT JOIN mss_treatment
         ON  mss_treatment.code = order_data.ind_treatment_cd
         AND mss_treatment.facility_cd = order_data.facility_cd
       LEFT JOIN mss_bed
         ON  mss_bed.code = order_data.ind_bed_cd
         AND mss_bed.facility_cd = order_data.facility_cd
       LEFT JOIN mst_kur
         ON  mst_kur.kur_cd = order_data.ind_kur_cd
       LEFT JOIN mst_bed
         ON  mst_bed.bed_cd = order_data.ind_bed_cd
       LEFT JOIN mst_treatment
         ON  mst_treatment.treatment_cd = order_data.ind_treatment_cd
     )
     SELECT pat_main.pat_id                                                                                          -- 患者ID
          , data6.prescription_type                                                                                  -- 処方種別
          , data6.issue_date                                                                                         -- 交付日
          , data6.issue_state                                                                                        -- 交付状態
          , data6.ord_prescription_no                                                                                -- 処方オーダー番号
          , main.ind_kur_name                                                                                        -- 実績：クール名
          , main.ind_bed_name                                                                                        -- 実績：ベッド名
          , main.ind_treatment_name                                                                                  -- 実績：治療方法名
          , main.kur_start_time                                                                                      -- 実績：クール開始時刻
          , main.bed_order_index                                                                                     -- 実績：ベッドマスタ表示順
          , main.treatment_order_index                                                                               -- 実績：治療方法マスタ表示順
          , data1_1.ord_prescription_no AS ord_prescription_no2                                                      -- 処方オーダー番号
          , data1_1.prescription_type AS prescription_type2                                                          -- 処方種別
          , data1_1.issue_state AS issue_state2                                                                      -- 交付状態
         --#12462 患者共有情報 by zrx add
          ,pat_main.facility_cd
       FROM pat_main
       LEFT JOIN data6
         ON pat_main.pat_id = data6.pat_id
       LEFT JOIN data1_1
         ON pat_main.pat_id = data1_1.pat_id
        AND data1_1.row_num = 1
       LEFT JOIN order_data2 main                                                                                    -- 治療情報
         ON pat_main.pat_id = main.pat_id                                                                            -- 患者ID
      WHERE pat_main.pat_id IN /* patIdList */(0)                                                                    -- 患者ID
      ORDER BY data6.pat_id                                                                                          -- 患者ID
          , data6.ord_no                                                                                             -- 順序
          , data6.issue_date DESC                                                                                    -- 交付日
