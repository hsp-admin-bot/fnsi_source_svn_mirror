-- DROP PROCEDURE ntss.batch_update_monitor_data(varchar, date, date);

CREATE OR REPLACE PROCEDURE ntss.batch_update_monitor_data(IN p_facility_cd character varying, IN p_start_date date, IN p_end_date date)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    batch_size CONSTANT INT := 5000;
    rows_updated INT := 0;
    total_updated INT := 0;
BEGIN
    RAISE NOTICE 'テーブル「mni_monitor」の更新が始めました。条件：施設コード=%，期間：% から %', 
                 p_facility_cd, p_start_date, p_end_date;

    LOOP
        WITH batch AS (
            SELECT bio_moni_ctl_no as id
            FROM mni_monitor
            WHERE monitor_data IS NOT NULL 
              AND occur_date < (p_end_date + INTERVAL '1 day')::timestamp 
              AND facility_cd = p_facility_cd 
              AND occur_date >= p_start_date
            ORDER BY id
            LIMIT batch_size
            OFFSET total_updated
        )
        UPDATE mni_monitor
        SET monitor_data = (
            SELECT jsonb_object_agg(
                key,
                CASE
                    WHEN jsonb_typeof(value) IN ('number', 'boolean')
                    THEN to_jsonb(value::text)
                    ELSE value
                END
            )
            FROM jsonb_each(mni_monitor.monitor_data) AS t(key, value)
        )
        WHERE bio_moni_ctl_no IN (SELECT id FROM batch);

        GET DIAGNOSTICS rows_updated = ROW_COUNT;

        EXIT WHEN rows_updated = 0;

        total_updated := total_updated + rows_updated;
        COMMIT;

        RAISE NOTICE '更新した % 件数，累計 % 件', rows_updated, total_updated;

        PERFORM pg_sleep(0.1);
    END LOOP;

    RAISE NOTICE '更新完了，全数 % 件数', total_updated;
END;
$procedure$
;

-- DROP PROCEDURE ntss.run_batch_update_by_facility_cd_and_halfyear();

CREATE OR REPLACE PROCEDURE ntss.run_batch_update_by_facility_cd_and_halfyear()
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    r           RECORD;
    v_min       date;
    v_max       date;
    v_start     date;
    v_end       date;
    v_next      date;
BEGIN
    CREATE TABLE IF NOT EXISTS ntss.run_batch_update_checkpoint (
        id           integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        facility_cd  varchar,
        next_start   date
    );

    FOR r IN
        SELECT DISTINCT facility_cd
        FROM mni_monitor
        WHERE facility_cd IS NOT NULL
        ORDER BY facility_cd
    LOOP
        SELECT MIN(occur_date)::date, MAX(occur_date)::date
        INTO v_min, v_max
        FROM mni_monitor
        WHERE facility_cd = r.facility_cd;

        RAISE NOTICE '処理中施設： facility_cd=%', r.facility_cd;

        IF v_min IS NULL OR v_max IS NULL THEN
            CONTINUE;
        END IF;

        v_start := v_min;

        WHILE v_start <= v_max LOOP
            v_next := (v_start + INTERVAL '6 months')::date;
            v_end := v_next - INTERVAL '1 day';
            IF v_end > v_max THEN
                v_end := v_max;
            END IF;

            IF EXISTS (
                SELECT 1
                FROM ntss.run_batch_update_checkpoint c
                WHERE c.facility_cd IS NOT DISTINCT FROM r.facility_cd::varchar
                  AND c.next_start = v_start
            ) THEN
                RAISE NOTICE 'スキップ（済）: facility_cd=%, v_start=%', r.facility_cd, v_start;

                EXIT WHEN v_end >= v_max;
                v_start := v_next;
                CONTINUE;
            END IF;

            RAISE NOTICE '処理中施設： facility_cd=% , occur_date 範囲 [%, %]', r.facility_cd, v_start, v_end;

            CALL ntss.batch_update_monitor_data(r.facility_cd::varchar, v_start, v_end);

            INSERT INTO ntss.run_batch_update_checkpoint (facility_cd, next_start)
            VALUES (r.facility_cd, v_start);

            COMMIT;

            EXIT WHEN v_end >= v_max;

            v_start := v_next;
        END LOOP;
    END LOOP;

    DROP TABLE IF EXISTS ntss.run_batch_update_checkpoint;
    RAISE NOTICE '正常終了: checkpoint テーブルを削除しました。';
    COMMIT;
END;
$procedure$
;