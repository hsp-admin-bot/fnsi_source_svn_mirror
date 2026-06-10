--------------------------------------------------------------------------------
-- 11471_upd_ord_main.sql
-- oldName:fix_rst_device_mode_procedure_11471.txt
-- 
-- 【概要】
--      ord_mainテーブルのrst_device_modeデータ修正
-- 
-- 【管理番号】
--      
-- 
-- 【変更履歴】
--      初期作成                                2025/04/02
-- 
-- 【備考】
--      
-- 
--------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE ntss.update_ord_main_rst_device_mode()
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    batch_size INT := 1000;
    offset_t INT := 0;
    total_rows INT;
BEGIN
    SELECT COUNT(1) INTO total_rows FROM ord_main 
     WHERE rst_treatment_cd is not null and rst_device_mode is null and rst_dialysis_state > '0';
    RAISE NOTICE 'total_rows : %', total_rows;

    WHILE offset_t < total_rows LOOP
		update ord_main o 
		set rst_device_mode = (select device_mode from mst_treatment m where m.treatment_cd = o.rst_treatment_cd) 
		where o.ord_no in (select ord_no from ord_main 
                                         where rst_treatment_cd is not null and rst_device_mode is null 
                                               and rst_dialysis_state > '0' limit batch_size);

        offset_t := offset_t + batch_size;

        COMMIT;

        RAISE NOTICE 'offset : %', offset_t;

--        PERFORM pg_sleep(2);
    END LOOP;

END;
$procedure$
;

-- ストアドプロシージャを呼び出してデータを修正
CALL ntss.update_ord_main_rst_device_mode();

-- 処理が完了したら、関数を削除
DROP PROCEDURE IF EXISTS ntss.update_ord_main_rst_device_mode();