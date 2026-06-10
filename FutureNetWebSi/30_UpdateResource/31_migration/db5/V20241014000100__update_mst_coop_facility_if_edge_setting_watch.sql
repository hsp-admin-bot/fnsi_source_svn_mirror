WITH updated_data AS (
    SELECT facility_cd,
           jsonb_agg(
                   jsonb_set(
                           elem,
                           '{coop_version}',
                           concat('"', new_coop_version, '"')::jsonb,
                           FALSE
                       )
               ) AS updated_if_edge_setting_receive_watch
    FROM (
             SELECT facility_cd,
                    jsonb_array_elements(if_edge_setting -> 'receive' -> 'watch') AS elem,
                    CASE facility_cd
                        WHEN 'nkknkk' THEN
                            'NKK'
                        WHEN 'F_hosp' THEN
                            'GX'
                        WHEN 'N_hosp' THEN
                            'HR'
                        WHEN 'S_hosp' THEN
                            'SSI'
                        WHEN 'NEC-iS' THEN
                            'IS'
                        WHEN 'C_hosp' THEN
                            'CSI'
                        WHEN 'P_hosp' THEN
                            'MED'
                        END AS new_coop_version
             FROM
                 mst_coop_facility
             WHERE
                     facility_cd IN ('nkknkk', 'F_hosp', 'N_hosp', 'S_hosp', 'NEC-iS', 'C_hosp', 'P_hosp')
         ) a
    GROUP BY facility_cd
)
UPDATE mst_coop_facility A
SET if_edge_setting = jsonb_set(if_edge_setting, '{receive, watch}', updated_data.updated_if_edge_setting_receive_watch,
                                FALSE)
FROM updated_data
WHERE A.facility_cd = updated_data.facility_cd;
