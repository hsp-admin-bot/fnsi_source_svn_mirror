SELECT
    jsonb_object_agg ( master_physical_name, code_list ) AS result_map
FROM
    (
SELECT
    m.master_physical_name,
    jsonb_agg(elem->>'code') AS code_list
FROM
    mst_selector m,
    jsonb_array_elements(m.order_settings->'items') AS elem
WHERE
        m.facility_cd = /*facilityCd*/'1'
  AND m.master_physical_name IN (
                                 'mst_treatment',
                                 'mst_severity',
                                 'mst_transport',
                                 'mst_disease',
                                 'mst_course',
                                 'mst_ward',
                                 'mst_dialysis_difficulty'
    )
GROUP BY
    m.master_physical_name) T;
