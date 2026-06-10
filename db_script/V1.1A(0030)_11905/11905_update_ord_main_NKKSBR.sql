--------------------------------------------------------------------------------
-- V1.1A(0030)_11905\11905_update_ord_main_NKKSBR.sql
-- 
-- 【概要】
--      11905_insert_ord_material_save_batch_NKKSBRによりデータ修復時、
--      発見したord_mainの不正データを修復する
--      不正データ：治療条件（予定／実績）、投与薬剤、医療材料で、数量が文字列の「"null」
--      で開始するデータ、正しくはnull ←※文字列の"null"ではない
-- 【管理番号】
--      #11905のV1.1A補正対策
-- 
-- 【変更履歴】
--      初期作成                                2025/07/16
-- 
-- 【備考】
--      ※重要：11905_insert_ord_material_save_batch_NKKSBR.sqlより先に実行すること!!!
-- 
--------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS repair_ord_main_data_11905_procedure();
CREATE OR REPLACE PROCEDURE repair_ord_main_data_11905_procedure()
LANGUAGE plpgsql
AS $$
DECLARE
    total_start_time TIMESTAMP; --開始時刻記録用
    total_end_time TIMESTAMP;   --終了時刻記録用
    v_row_count INT;            --更新済みレコード件数記録用
    param_facility_cd CONSTANT TEXT := 'NKKSBR';  --修復対象施設コード！必ず修正すること!!!
BEGIN  
    total_start_time := clock_timestamp();

    --治療条件（予定）で修正対象レコードのデータを収集
    -- NULLではない（つまり文字列）且つ文字列のなかで、文字列がnullで始まる
    WITH ind_expanded AS (
    SELECT
      om.ord_no,
      om.facility_cd,
      key,
      value,
      CASE
        WHEN value ->> 'value' IS NOT NULL AND TRIM(value ->> 'value') ~* '^null'
        THEN jsonb_set(value, '{value}', 'null'::jsonb, true)
        ELSE value
      END AS new_value
    FROM ord_main om,
         jsonb_each(om.ind_cond_info)
    WHERE om.facility_cd = param_facility_cd 
      AND om.is_del = '0' 
    ),
    --治療条件（実績）で修正対象レコードのデータを収集
    -- NULLではない（つまり文字列）且つ文字列のなかで、文字列がnullで始まる
    rst_expanded AS (
     SELECT
       om.ord_no,
       om.facility_cd,
       key,
       value,
       CASE
         WHEN value ->> 'value' IS NOT NULL AND TRIM(value ->> 'value') ~* '^null'
         THEN jsonb_set(value, '{value}', 'null'::jsonb, true)
         ELSE value
       END AS new_value
     FROM ord_main om,
          jsonb_each(om.rst_cond_info)
     WHERE om.facility_cd = param_facility_cd
       AND om.is_del = '0' 
    ),
    --治療条件（予定）修復済みデータをJsonに戻す
    ind_recombined AS (
      SELECT
        ord_no,
        facility_cd,
        jsonb_object_agg(key, new_value) AS new_ind_cond_info
      FROM ind_expanded
      GROUP BY ord_no, facility_cd
    ),
    --治療条件（実績）修復済みデータをJsonに戻す
    rst_recombined AS (
      SELECT
        ord_no,
        facility_cd,
        jsonb_object_agg(key, new_value) AS new_rst_cond_info
      FROM rst_expanded
      GROUP BY ord_no, facility_cd
    ),
    --投与薬剤（予定）で修正対象レコードのデータを収集
    -- NULLではない（つまり文字列）且つ文字列のなかで、文字列がnullで始まる
    ind_medi_expanded AS (
      SELECT
        om.ord_no,
        om.facility_cd,
        idx,
        elem,
        CASE
          WHEN elem ->> 'amount' IS NOT NULL AND TRIM(elem ->> 'amount') ~* '^null'
          THEN jsonb_set(elem, '{amount}', 'null'::jsonb, true)
          ELSE elem
        END AS new_elem
      FROM ord_main om,
           jsonb_array_elements(om.ind_medi_info) WITH ORDINALITY AS t(elem, idx)
      WHERE om.facility_cd = param_facility_cd
        AND om.is_del = '0' 
    ),
    --投与薬剤（予定）修復済みデータをJsonに戻す
    ind_medi_recombined AS (
      SELECT
        ord_no,
        facility_cd,
        jsonb_agg(new_elem ORDER BY idx) AS new_ind_medi_info
      FROM ind_medi_expanded
      GROUP BY ord_no, facility_cd
    ),
    --投与薬剤（実績）で修正対象レコードのデータを収集
    -- NULLではない（つまり文字列）且つ文字列のなかで、文字列がnullで始まる
    rst_medi_expanded AS (
      SELECT
        om.ord_no,
        om.facility_cd,
        idx,
        elem,
        CASE
          WHEN elem ->> 'amount' IS NOT NULL AND TRIM(elem ->> 'amount') ~* '^null'
          THEN jsonb_set(elem, '{amount}', 'null'::jsonb, true)
          ELSE elem
        END AS new_elem
      FROM ord_main om,
           jsonb_array_elements(om.rst_medi_info) WITH ORDINALITY AS t(elem, idx)
      WHERE om.facility_cd = param_facility_cd
        AND om.is_del = '0' 
    ),
    --投与薬剤（実績）修復済みデータをJsonに戻す
    rst_medi_recombined AS (
      SELECT
        ord_no,
        facility_cd,
        jsonb_agg(new_elem ORDER BY idx) AS new_rst_medi_info
      FROM rst_medi_expanded
      GROUP BY ord_no, facility_cd
    ),
    --医療材料（予定）で修正対象レコードのデータを収集
    -- NULLではない（つまり文字列）且つ文字列のなかで、文字列がnullで始まる
    ind_equip_expanded AS (
      SELECT
        om.ord_no,
        om.facility_cd,
        idx,
        elem,
        CASE
          WHEN elem ->> 'amount' IS NOT NULL AND TRIM(elem ->> 'amount') ~* '^null'
          THEN jsonb_set(elem, '{amount}', 'null'::jsonb, true)
          ELSE elem
        END AS new_elem
      FROM ord_main om,
           jsonb_array_elements(om.ind_equip_info) WITH ORDINALITY AS t(elem, idx)
      WHERE om.facility_cd = param_facility_cd
        AND om.is_del = '0' 
    ),
    ---医療材料（予定）修復済みデータをJsonに戻す
    ind_equip_recombined AS (
      SELECT
        ord_no,
        facility_cd,
        jsonb_agg(new_elem ORDER BY idx) AS new_ind_equip_info
      FROM ind_equip_expanded
      GROUP BY ord_no, facility_cd
    ),
    --医療材料（実績）で修正対象レコードのデータを収集
    -- NULLではない（つまり文字列）且つ文字列のなかで、文字列がnullで始まる
    rst_equip_expanded AS (
      SELECT
        om.ord_no,
        om.facility_cd,
        idx,
        elem,
        CASE
          WHEN elem ->> 'amount' IS NOT NULL AND TRIM(elem ->> 'amount') ~* '^null'
          THEN jsonb_set(elem, '{amount}', 'null'::jsonb, true)
          ELSE elem
        END AS new_elem
      FROM ord_main om,
           jsonb_array_elements(om.rst_equip_info) WITH ORDINALITY AS t(elem, idx)
      WHERE om.facility_cd = param_facility_cd
        AND om.is_del = '0' 
    ),
    ---医療材料（実績）修復済みデータをJsonに戻す
    rst_equip_recombined AS (
      SELECT
        ord_no,
        facility_cd,
        jsonb_agg(new_elem ORDER BY idx) AS new_rst_equip_info
      FROM rst_equip_expanded
      GROUP BY ord_no, facility_cd
    ),
    --更新対象のord_noを収集
    -- NULLではない（つまり文字列）且つ文字列のなかで、文字列がnullで始まる
    ord_no_to_update AS (
      SELECT DISTINCT ord_no, facility_cd
      FROM (
        SELECT ord_no, facility_cd
        FROM ind_expanded
        WHERE value ->> 'value' IS NOT NULL AND TRIM(value ->> 'value') ~* '^null'
     
        UNION
     
        SELECT ord_no, facility_cd
        FROM rst_expanded
        WHERE value ->> 'value' IS NOT NULL AND TRIM(value ->> 'value') ~* '^null'
     
        UNION
        SELECT ord_no, facility_cd
        FROM ind_medi_expanded
        WHERE elem ->> 'amount' IS NOT NULL
          AND TRIM(elem ->> 'amount') ~* '^null'
     
        UNION
        SELECT ord_no, facility_cd
        FROM rst_medi_expanded
        WHERE elem ->> 'amount' IS NOT NULL
          AND TRIM(elem ->> 'amount') ~* '^null'
     
        UNION
        SELECT ord_no, facility_cd
        FROM ind_equip_expanded
        WHERE elem ->> 'amount' IS NOT NULL
          AND TRIM(elem ->> 'amount') ~* '^null'
     
        UNION
        SELECT ord_no, facility_cd
        FROM rst_equip_expanded
        WHERE elem ->> 'amount' IS NOT NULL
          AND TRIM(elem ->> 'amount') ~* '^null'
      ) t
    )
     
    --Debug用
    -- select * from ind_recombined
    
    --ord_mainを更新
    UPDATE ord_main
    SET
      ind_cond_info = case 
      when ind.new_ind_cond_info is not null then ind.new_ind_cond_info
      else ind_cond_info
      end,
      rst_cond_info = case 
      when rst.new_rst_cond_info is not null then rst.new_rst_cond_info
      else rst_cond_info
      end,
      ind_medi_info = case 
      when ind_medi.new_ind_medi_info is not null then ind_medi.new_ind_medi_info
      else ind_medi_info
      end,
      rst_medi_info = case 
      when rst_medi.new_rst_medi_info is not null then rst_medi.new_rst_medi_info
      else rst_medi_info
      end,
      ind_equip_info = case 
      when ind_equip.new_ind_equip_info is not null then ind_equip.new_ind_equip_info
      else ind_equip_info
      end,
      rst_equip_info = case 
      when rst_equip.new_rst_equip_info is not null then rst_equip.new_rst_equip_info
      else rst_equip_info
      end
    FROM ord_no_to_update upd
    left JOIN ind_recombined ind
      ON upd.ord_no = ind.ord_no AND upd.facility_cd = ind.facility_cd
    left JOIN rst_recombined rst
      ON upd.ord_no = rst.ord_no AND upd.facility_cd = rst.facility_cd
    left JOIN ind_medi_recombined ind_medi
      ON upd.ord_no = ind_medi.ord_no AND upd.facility_cd = ind_medi.facility_cd
    left JOIN rst_medi_recombined rst_medi
      ON upd.ord_no = rst_medi.ord_no AND upd.facility_cd = rst_medi.facility_cd
    left JOIN ind_equip_recombined ind_equip
      ON upd.ord_no = ind_equip.ord_no AND upd.facility_cd = ind_equip.facility_cd
    left JOIN rst_equip_recombined rst_equip
      ON upd.ord_no = rst_equip.ord_no AND upd.facility_cd = rst_equip.facility_cd
    WHERE ord_main.ord_no = upd.ord_no
      AND ord_main.facility_cd = upd.facility_cd;


    --更新済みレコード件数を取得
    GET DIAGNOSTICS v_row_count = ROW_COUNT;

    total_end_time := clock_timestamp();
    RAISE NOTICE '処理完了、計%件', v_row_count;
    RAISE NOTICE '開始時間: %、終了時間: %', total_start_time, total_end_time;
    RAISE NOTICE '合計時間: %', total_end_time - total_start_time;
    
END;
$$;
call repair_ord_main_data_11905_procedure();
DROP PROCEDURE IF EXISTS repair_ord_main_data_11905_procedure();


