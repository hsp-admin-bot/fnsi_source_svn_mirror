SELECT
-- mod #6264 2022-08-04 治療状況リスト・マップの表示項目の参照先がmni_monitor→mnt_machine_state.monitor_dataに変更されていない。 dou start
--     A.monitor_data->>'3' AS remain_uf
--     , A.monitor_data->>'4' AS remain_dialysis
--     , A.monitor_data->>'90' AS bp_max
--     , A.monitor_data->>'91' AS bp_min
--     , A.monitor_data->>'92' AS bp_ave
    B.monitor_data->>'3' AS remain_uf
    , B.monitor_data->>'4' AS remain_dialysis
    , B.monitor_data->>'78' AS remain_fr
    , B.monitor_data->>'90' AS bp_max
    , B.monitor_data->>'91' AS bp_min
    , B.monitor_data->>'92' AS bp_ave
-- mod #6264 2022-08-04 治療状況リスト・マップの表示項目の参照先がmni_monitor→mnt_machine_state.monitor_dataに変更されていない。 dou end
    , A.occur_date
    , A.ord_no
    , A.data_type
FROM
    ntss.mni_monitor A
-- add #6264 2022-08-04 治療状況リスト・マップの表示項目の参照先がmni_monitor→mnt_machine_state.monitor_dataに変更されていない。 dou start
    LEFT JOIN mnt_machine_state B ON A.facility_cd = B.facility_cd
    AND A.machine_type_cd = B.machine_type_cd
    AND A.machine_serial = B.machine_serial
    AND A.ord_no = B.ord_no
    AND A.pat_id = B.pat_id
WHERE
    A.facility_cd = /*facilityCd*/NULL
AND
-- add #6264 2022-08-04 治療状況リスト・マップの表示項目の参照先がmni_monitor→mnt_machine_state.monitor_dataに変更されていない。 dou end
    A.ord_no IN /* ordNoList */('0')
AND
    A.is_del = '0'
ORDER BY
    A.ord_no ASC
    , A.occur_date DESC
;
