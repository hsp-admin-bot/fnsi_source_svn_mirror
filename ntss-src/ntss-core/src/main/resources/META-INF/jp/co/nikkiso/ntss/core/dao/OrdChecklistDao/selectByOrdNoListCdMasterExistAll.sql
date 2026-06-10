select
 /*%expand "A" */*
from
  -- 指定オーダー番号、リストコードのチェックリスト実績を取得
  (select
    checklist_ctl_no,
    ord_no,
    is_check,
    rst_class,
    list_cd,
    func_class,
    rst_checklist_info,
    reg_staff_info,
    is_disp,
    case
      when ord.func_class = '0' then
      '0' -- 「0：通常リスト」⇒表示
      when (ord.func_class = '1')and(ord.rst_checklist_info->>'class_cd' in ('5')) then
      (select COALESCE(mst.is_del, '1') from mst_dialyzer as mst where mst.facility_cd = ord.facility_cd and mst.dialyzer_cd = (ord.rst_checklist_info->>'code')::int4) -- 「1：治療条件 > ダイアライザ」
      when (ord.func_class = '1')and(ord.rst_checklist_info->>'class_cd' in ('6', '7', '8', '9', '10', '11', '13')) then
      (select case when mst.class_cd = -1 then COALESCE(mst.is_del, '1') when COALESCE(mst.is_del, '1') = '0' then COALESCE(cls.is_del, '1') else COALESCE(mst.is_del, '1') end from mst_equipment as mst
			  left join mst_equipment_class as cls on cls.class_cd = mst.class_cd
			  where mst.facility_cd = ord.facility_cd and mst.equipment_cd = (ord.rst_checklist_info->>'code')::int4) -- 「1：治療条件 > 医療材料」
      when (ord.func_class = '1')and(ord.rst_checklist_info->>'class_cd' in ('15', '19', '25'))and(ord.rst_checklist_info->>'medicine_type' = '2') then
      (select case when mst.class_cd = -1 then COALESCE(mst.is_del, '1') when COALESCE(mst.is_del, '1') = '0' then COALESCE(cls.is_del, '1') else COALESCE(mst.is_del, '1') end from mst_medicine_mix as mst
			  left join mst_medicine_class as cls on cls.class_cd = mst.class_cd
			  where mst.facility_cd = ord.facility_cd and mst.medicine_mix_cd = (ord.rst_checklist_info->>'code')::int4) -- 「1：治療条件 > 調製薬剤」
      when (ord.func_class = '1')and(ord.rst_checklist_info->>'class_cd' in ('15', '19', '25'))and(ord.rst_checklist_info->>'medicine_type' != '2') then
      (select case when mst.class_cd = -1 then COALESCE(mst.is_del, '1') when COALESCE(mst.is_del, '1') = '0' then COALESCE(cls.is_del, '1') else COALESCE(mst.is_del, '1') end from mst_medicine as mst
			  left join mst_medicine_class as cls on cls.class_cd = mst.class_cd
			  where mst.facility_cd = ord.facility_cd and mst.medicine_cd = (ord.rst_checklist_info->>'code')::int4) -- 「1：治療条件 > 通常薬剤」
      when (ord.func_class = '2')and(ord.rst_checklist_info->>'class_cd' = '0') then
      (select COALESCE(mst.is_del, '1') from mst_dialyzer as mst where mst.facility_cd = ord.facility_cd and mst.dialyzer_cd = (ord.rst_checklist_info->>'code')::int4) -- 「2：医療材料 > ダイアライザ」
      when (ord.func_class = '2')and(ord.rst_checklist_info->>'class_cd' != '0') then
      (select case when mst.class_cd = -1 then COALESCE(mst.is_del, '1') when COALESCE(mst.is_del, '1') = '0' then COALESCE(cls.is_del, '1') else COALESCE(mst.is_del, '1') end from mst_equipment as mst
			  left join mst_equipment_class as cls on cls.class_cd = mst.class_cd
			  where mst.facility_cd = ord.facility_cd and mst.equipment_cd = (ord.rst_checklist_info->>'code')::int4) -- 「2：医療材料 > 医療材料」
      when (ord.func_class = '3')and(ord.rst_checklist_info->>'medicine_type' = '2') then
      (select case when mst.class_cd = -1 then COALESCE(mst.is_del, '1') when COALESCE(mst.is_del, '1') = '0' then COALESCE(cls.is_del, '1') else COALESCE(mst.is_del, '1') end from mst_medicine_mix as mst
			  left join mst_medicine_class as cls on cls.class_cd = mst.class_cd
			  where mst.facility_cd = ord.facility_cd and mst.medicine_mix_cd = (ord.rst_checklist_info->>'code')::int4) -- 「3：投与薬剤 > 調製薬剤」
      when (ord.func_class = '3')and(ord.rst_checklist_info->>'medicine_type' != '2') then
      (select case when mst.class_cd = -1 then COALESCE(mst.is_del, '1')when COALESCE(mst.is_del, '1') = '0' then COALESCE(cls.is_del, '1') else COALESCE(mst.is_del, '1') end from mst_medicine as mst
			  left join mst_medicine_class as cls on cls.class_cd = mst.class_cd
			  where mst.facility_cd = ord.facility_cd and mst.medicine_cd = (ord.rst_checklist_info->>'code')::int4) -- 「3：投与薬剤 > 通常薬剤」
      else'0' -- 「その他」⇒表示
    end as is_del,
    occur_date,
    reg_date,
    up_date,
    facility_cd
  from ord_checklist as ord
  where
    ord_no in /*ordNos*/(1)
  and
    is_del = '0'
  ) A
where A.is_del = '0'
;
