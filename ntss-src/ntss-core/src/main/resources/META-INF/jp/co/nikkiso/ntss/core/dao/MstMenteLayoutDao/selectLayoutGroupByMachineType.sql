SELECT
    mg.mainte_layout_group_cd,
    mg.group_name,
    (
    SELECT json_agg(json_build_object(
        'machineTypeCd',m.machine_type_cd
    )) from
        (SELECT machine_type_cd FROM mst_machine_type where machine_type_cd::text
         in
            (SELECT json_array_elements_text(
            (SELECT to_json(lt.type_info)))::text)) as m) as type_info
FROM mst_mainte_layout as lt
INNER JOIN mst_mainte_layout_group as mg
    ON lt.mainte_layout_cd = ANY (SELECT jsonb_array_elements(mg.layout_list)::bigint) -- 点検レイアウトコード
    AND mg.is_del                    = '0'                                         -- 削除フラグ
    AND mg.is_disp                   = '1'
WHERE lt.layout_class = '2'
    AND lt.facility_cd = /* facilityCd*/'000000'
    AND lt.is_disp = '1'
    AND lt.is_del = '0'

