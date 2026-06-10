WITH med AS (
	select
		m.medicine_cd,
		m.medicine_name,
		m.standard_medicine_cd,
		m.unit_decimal_point,
		m.unit,
		m.unit_second,
		ms.index
	from
		mst_medicine m,
		(
			select mss.facility_cd, ms.*, row_number() over() as index
			from
				mst_selector mss
			cross join lateral jsonb_to_recordset(mss.order_settings->'items') as ms
			(
				code int,
				name text
			)
			where
				mss.facility_cd = /* facilityCd*/null
			and
				mss.master_physical_name = 'mst_medicine'
    ) ms
	where
	-- add FNSI5516-処方薬剤選択画面の表示が遅い 周 start
	m.medicine_cd IS NOT null and
	-- add FNSI5516-処方薬剤選択画面の表示が遅い 周 end
		m.is_disp = '1' and m.is_del ='0'
	/*%if classCd != null */
	and m.class_cd = /*classCd*/0
	/*%end*/
	/*%if medicineName != null */
	and m.medicine_name like /*medicineName*/'0'
	/*%end*/
	and m.facility_cd = /*facilityCd*/null
	and m.medicine_cd = ms.code
), gen AS (
	select
	medicine_type,
	generic_cd,
	generic_name,
	search_code_list,
	unit_first,
	unit_second
	from sys_generic_medicine
	where is_disp = '1' and is_del ='0'
	/*%if genericName != null */
	and generic_name like /*genericName*/'0'
	/*%end*/
)
select
	med.medicine_cd as medicine_cd,
	med.medicine_name as medicine_name,
	gen.generic_cd as generic_cd,
	gen.generic_name as generic_name,
	gen.medicine_type as medicine_type,
	med.unit_decimal_point as unit_decimal_point,
	med.unit as unit,
	med.unit_second as unit_second,
	gen.unit_first as gen_unit_first,
	COALESCE(med.unit_second , gen.unit_second) as unit_second,
	is_generic_taboo_type(gen.medicine_type, gen.generic_cd,/*patId*/0) as generic_taboo_type,
	is_medicine_taboo_type(CAST(med.medicine_cd as character varying),/*patId*/0) as medicine_taboo_type
FROM med
	left JOIN gen
	ON json_array_contains_array_value(COALESCE(gen.search_code_list,'[]'),'cd',substring(med.standard_medicine_cd,0,10))
-- 	-- add FNSI5516-処方薬剤選択画面の表示が遅い 周 start
-- 	and med.medicine_cd is not null
-- 	-- add FNSI5516-処方薬剤選択画面の表示が遅い 周 end
-- ) A
-- full outer join (
-- 	select med.medicine_cd, med.medicine_name,med.standard_medicine_cd, med.unit_decimal_point, med.unit, med.unit_second,
-- 	gen.search_code_list, gen.generic_cd, gen.generic_name, gen.medicine_type, gen.unit_first as gen_unit_first, gen.unit_second as gen_unit_second
-- 	from  med
-- 	right JOIN gen
-- 	on json_array_contains_array_value(COALESCE(gen.search_code_list,'[]'),'cd',substring(med.standard_medicine_cd,0,10))
-- 	-- add FNSI5516-処方薬剤選択画面の表示が遅い 周 start
-- 	and med.medicine_cd is not null
-- 	-- add FNSI5516-処方薬剤選択画面の表示が遅い 周 end
-- ) B
-- ON A.medicine_cd = B.medicine_cd
-- AND A.generic_cd  = B.generic_cd
-- ORDER BY A.index
ORDER BY med.index
-- add FNSI5516-処方薬剤選択画面の表示が遅い 周 start
/*%if offset != null */
offset /*offset*/0
/*%end*/
/*%if limit != null */
limit /*limit*/100
/*%end*/
-- add FNSI5516-処方薬剤選択画面の表示が遅い 周 end
;
