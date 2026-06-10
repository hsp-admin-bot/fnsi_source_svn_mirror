DO $do$
DECLARE
    v_last_ord_no   bigint := 1;
    v_rows_updated  int    := 1;
BEGIN
    WHILE v_rows_updated > 0 LOOP
        WITH ids AS (
            SELECT t.ord_no
            FROM ord_main t
            WHERE t.ord_no > v_last_ord_no
              AND (
                    COALESCE(t.ind_cond_info->'25'->>'value', '') LIKE '%$%'
                 OR COALESCE(t.rst_cond_info->'25'->>'value', '') LIKE '%$%'
              )
            ORDER BY t.ord_no
            LIMIT 1000
        ),
        upd AS (
            UPDATE ord_main t
            SET
                ind_cond_info = CASE
                    WHEN t.ind_cond_info IS NOT NULL
                     AND t.ind_cond_info ? '25'
                     AND COALESCE(t.ind_cond_info->'25'->>'value', '') LIKE '%$%'
                    THEN jsonb_set(
                        t.ind_cond_info,
                        '{25,value}',
                        to_jsonb(replace(t.ind_cond_info->'25'->>'value', '$', '')),
                        false
                    )
                    ELSE t.ind_cond_info
                END,
                rst_cond_info = CASE
                    WHEN t.rst_cond_info IS NOT NULL
                     AND t.rst_cond_info ? '25'
                     AND COALESCE(t.rst_cond_info->'25'->>'value', '') LIKE '%$%'
                    THEN jsonb_set(
                        t.rst_cond_info,
                        '{25,value}',
                        to_jsonb(replace(t.rst_cond_info->'25'->>'value', '$', '')),
                        false
                    )
                    ELSE t.rst_cond_info
                END
            FROM ids
            WHERE t.ord_no = ids.ord_no
            RETURNING t.ord_no
        )

        SELECT
            COUNT(*),
            COALESCE(MAX(ord_no), v_last_ord_no)
        INTO
            v_rows_updated,
            v_last_ord_no
        FROM upd;
        RAISE NOTICE 'last_ord_no: %, updated rows: %', v_last_ord_no, v_rows_updated;
    END LOOP;
END
$do$;