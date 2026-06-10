-- modify by chamaojia 2024-06-07 [10754] 接頭文字対応  --start
select
/*%if target == "EQUIP" */    --- 医療材料用
    mst.equipment_cd as cd,     --- 取得処理を共通化するための別名cd
    mst.equipment_name as name  --- 取得処理を共通化するための別名name
     -- add by chamaojia 2024-01-26 [10196] Append query results  --start
     , mst.unit
     -- add by chamaojia 2024-01-26 [10196] Append query results  --end
     , met_class.class_type as class_type
     , mst.use_end_date as use_end_date
     , mst.is_disp as is_disp
     , mst.is_del as is_del
/*%elseif target == "VA" */   ---VA用
     mst.va_cd as cd,            --- 取得処理を共通化するための別名cd
     mst.va_name as name         --- 取得処理を共通化するための別名name
     , mst.is_disp as is_disp
     , mst.is_del as is_del
/*%end*/
from
/*%if target == "EQUIP" */    --- 医療材料用
    mst_equipment mst
        left outer join mst_equipment_class met_class
            on mst.facility_cd = met_class.facility_cd
            and mst.class_cd = met_class.class_cd
/*%elseif target == "VA" */   ---VA用
    mst_va mst
/*%end*/
where
    mst.facility_cd = /*facility_cd*/''
  and
/*%if target == "EQUIP" */    --- 医療材料用
    mst.equipment_cd
/*%elseif target == "VA" */   ---VA用
    mst.va_cd
/*%end*/
    in /*cdList*/()
-- modify by chamaojia 2024-06-07 [10754] 接頭文字対応  --end