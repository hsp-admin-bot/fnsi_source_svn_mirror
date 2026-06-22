SELECT facility_cd ,facility_name
FROM mst_facility
WHERE
facility_cd <> /*facilityCd*/'1' AND EXISTS (
    SELECT 1
    FROM jsonb_array_elements(use_function -> 'func_cds') AS elem
    WHERE elem ->> 'func_cd' = '036'
);
