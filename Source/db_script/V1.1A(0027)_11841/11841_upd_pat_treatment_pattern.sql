DROP TYPE IF EXISTS pat_ctl_pair;

CREATE TYPE pat_ctl_pair AS (
  pat_id INT,
  ctl_no INT
);
-- ストアドプロシージャを削除（存在する場合）
DROP PROCEDURE IF EXISTS reset_pat_treatment_pattern_11841_procedure();

-- ストアドプロシージャを作成
CREATE OR REPLACE PROCEDURE reset_pat_treatment_pattern_11841_procedure()
LANGUAGE plpgsql
AS $$
DECLARE
    batch_size CONSTANT INT := 1000;
    total_counter INT := 0;
    total_start_time TIMESTAMP;
    total_end_time TIMESTAMP;
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    i INT := 1;
    affected_rows INT;

    rec_list pat_ctl_pair[];
BEGIN
    total_start_time := clock_timestamp();

    SELECT ARRAY(
        SELECT ROW(pat_id, ctl_no)::pat_ctl_pair
        FROM pat_treatment_pattern
    ) INTO rec_list;

    WHILE i <= array_length(rec_list, 1) LOOP
        start_time := clock_timestamp();

        WITH target(pat_id, ctl_no) AS (
            SELECT (x).pat_id, (x).ctl_no
            FROM unnest(rec_list[i:LEAST(i + batch_size - 1, array_length(rec_list, 1))]) AS x
        )
        UPDATE pat_treatment_pattern p
        SET
            ind_medi_info = CASE WHEN p.ind_medi_info IS NOT NULL THEN (
                SELECT COALESCE(
                    jsonb_agg(elem - 'name' - 'unit' - 'class_cd' - 'class_name' - 'class_type' - 'short_name' - 'timing_name' - 'procedure_name'),
                    '[]'::jsonb
                )
                FROM jsonb_array_elements(p.ind_medi_info) AS elem
            ) ELSE p.ind_medi_info END,

            ind_equip_info = CASE WHEN p.ind_equip_info IS NOT NULL THEN (
                SELECT COALESCE(
                    jsonb_agg(elem - 'name' - 'unit' - 'class_cd' - 'class_name' - 'class_type' - 'short_name'),
                    '[]'::jsonb
                )
                FROM jsonb_array_elements(p.ind_equip_info) AS elem
            ) ELSE p.ind_equip_info END,

            ind_cond_info = CASE WHEN p.ind_cond_info IS NOT NULL THEN (
                SELECT COALESCE(
                    jsonb_object_agg(key, value - 'unit' - 'value_name_1' - 'value_name_2'),
                    '{}'::jsonb
                )
                FROM jsonb_each(p.ind_cond_info)
            ) ELSE p.ind_cond_info END
        FROM target
        WHERE p.pat_id = target.pat_id AND p.ctl_no = target.ctl_no;

        GET DIAGNOSTICS affected_rows = ROW_COUNT;
        total_counter := total_counter + affected_rows;

        end_time := clock_timestamp();
        RAISE NOTICE 'バッチ % 件 (% - %) 完了。時間: % 秒', 
            (i - 1) / batch_size + 1, i, LEAST(i + batch_size - 1, array_length(rec_list, 1)), end_time - start_time;

        i := i + batch_size;
        COMMIT;
    END LOOP;

    total_end_time := clock_timestamp();
    RAISE NOTICE '総処理件数: %', total_counter;
    RAISE NOTICE '合計処理時間: % 秒', total_end_time - total_start_time;
END;
$$;

-- ストアドプロシージャを実行
call reset_pat_treatment_pattern_11841_procedure();
-- ストアドプロシージャを削除
DROP PROCEDURE IF EXISTS reset_pat_treatment_pattern_11841_procedure();
DROP TYPE IF EXISTS pat_ctl_pair;