select

/*%if medicine_type != 2 */   --- 通常薬剤の場合(調整薬剤以外)
    medi.medicine_cd as cd,       --- 指示で使用
    medi.class_cd as class_cd,
    mclass.class_name as class_name,
    mclass.class_type as class_type,
    medi.medicine_name as name,
    medi.medicine_short_name as short_name,
    medi.unit as unit,
    medi.unit_second as unit_second,
    medi.unit_decimal_point as dec_pt,
    medi.unit_decimal_point_second as dec_pt_second,
    -- add by chamaojia 2024-06-07 [10754] 接頭文字対応  --start
    medi.use_end_date as use_end_date,
    medi.is_disp as is_disp,
    medi.is_del as is_del
    -- add by chamaojia 2024-06-07 [10754] 接頭文字対応  --end
/*%else */   --- 調整薬剤の場合
    medi.medicine_mix_cd as cd, --- 指示で使用
    medi.class_cd as class_cd,
    mclass.class_name as class_name,
    mclass.class_type as class_type,
    medi.medicine_mix_name as name,
    medi.medicine_mix_short_name as short_name,
    medi.unit as unit,
    medi.unit_decimal_point as dec_pt,
    -- add by chamaojia 2024-06-07 [10754] 接頭文字対応  --start
    medi.is_disp as is_disp,
    medi.is_del as is_del,
    medi.mix_info as mix_info
    -- add by chamaojia 2024-06-07 [10754] 接頭文字対応  --end
/*%end*/

from

/*%if medicine_type != 2 */   --- 通常薬剤の場合(調整薬剤以外)
    mst_medicine medi
/*%else */   --- 調整薬剤の場合
    mst_medicine_mix medi
/*%end*/
    left outer join mst_medicine_class mclass
    on medi.facility_cd = mclass.facility_cd
    and medi.class_cd = mclass.class_cd

where

    medi.facility_cd = /*facility_cd*/''
    and
/*%if medicine_type != 2 */   --- 通常薬剤の場合(調整薬剤以外)
    medi.medicine_cd = /*cd*/0
/*%else */   --- 調整薬剤の場合
    medi.medicine_mix_cd = /*cd*/0
/*%end*/
;
