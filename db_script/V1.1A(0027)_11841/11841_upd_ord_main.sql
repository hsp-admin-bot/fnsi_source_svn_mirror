-- ストアドプロシージャを削除（存在する場合）
DROP PROCEDURE IF EXISTS reset_ord_main_11841_procedure();

-- ストアドプロシージャを作成
CREATE OR REPLACE PROCEDURE reset_ord_main_11841_procedure()
LANGUAGE plpgsql
AS $$
DECLARE
    batch_size CONSTANT INT := 1000; -- 1回でコミットする件数
    rec RECORD;
    rec_list INT[] := '{}'; -- 対象ord_no一覧
    total_counter INT := 0;
    total_start_time TIMESTAMP;
    total_end_time TIMESTAMP;
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    i INT := 1;
	affected_rows INT;
BEGIN
    total_start_time := clock_timestamp();

    -- 対象レコードのord_noを収集
    SELECT ARRAY(
        SELECT ord_no FROM ord_main 
        WHERE is_del = '0'
          AND rst_dialysis_state = '0'
    ) INTO rec_list;

    WHILE i <= array_length(rec_list, 1) LOOP
        start_time := clock_timestamp();

        -- 指定バッチ分のord_noで更新実行
        WITH target AS (
            SELECT ord_no FROM unnest(rec_list[i:i+batch_size-1]) AS ord_no
        )
        UPDATE ord_main om
        SET
            ind_medi_info =  CASE WHEN ind_medi_info IS NOT NULL THEN (
                SELECT jsonb_agg(elem - 'name' - 'unit' - 'class_cd' - 'class_name' - 'class_type' - 'short_name' - 'timing_name' - 'procedure_name')
                FROM jsonb_array_elements(om.ind_medi_info) AS elem
            )
						ELSE ind_medi_info
						END,
			ind_equip_info = CASE WHEN ind_equip_info IS NOT NULL THEN (
                SELECT jsonb_agg(elem - 'name' - 'unit' - 'class_cd' - 'class_name' - 'class_type' - 'short_name')
                FROM jsonb_array_elements(om.ind_equip_info) AS elem
            ) ELSE ind_equip_info
						END,
			ind_cond_info = CASE WHEN ind_cond_info IS NOT NULL THEN (
                SELECT jsonb_object_agg(key, value - 'unit' - 'value_name_1' - 'value_name_2')
                FROM jsonb_each(om.ind_cond_info)
            )
						 ELSE ind_cond_info 
						 END
        FROM target
        WHERE om.ord_no = target.ord_no;

		GET DIAGNOSTICS affected_rows = ROW_COUNT;
		total_counter := total_counter + affected_rows;
        end_time := clock_timestamp();

        RAISE NOTICE 'バッチ % (% - %) 完了。時間: % 秒', (i-1)/batch_size + 1, i, LEAST(i+batch_size-1, array_length(rec_list,1)), end_time - start_time;
        i := i + batch_size;
        COMMIT;
    END LOOP;

    total_end_time := clock_timestamp();
    RAISE NOTICE '総処理件数: %', total_counter;
    RAISE NOTICE '合計処理時間: % 秒', total_end_time - total_start_time;
END;
$$;

-- ストアドプロシージャを実行
call reset_ord_main_11841_procedure();
-- ストアドプロシージャを削除
DROP PROCEDURE IF EXISTS reset_ord_main_11841_procedure();