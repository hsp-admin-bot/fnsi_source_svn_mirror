WITH mmg AS (
	SELECT
		jsonb_array_elements ( reg_medicine_info :: jsonb ) ->> 'cd' AS cd,
		jsonb_array_elements ( reg_medicine_info :: jsonb ) ->> 'conVal' AS conVal,
		jsonb_array_elements ( reg_medicine_info :: jsonb ) ->> 'mediFlg' AS mediFlg
	FROM
		mst_medicine_group
	WHERE
		medicine_group_cd = /*groupCd*/'11'
	)
SELECT
  tTab.cd,
	tTab.conVal,
	tTab.mediflg,
	tTab.sumvalue,
	tTab.multiplication,
	mm.medicine_name
FROM
(SELECT
	tab.cd,
	tab.conVal,
	tab.mediflg,
	SUM ( to_number( tab.ind_rst_value, '9999999999.99' ) ) sumvalue,
	to_number(tab.conVal, '9999999999.99') * SUM ( to_number( tab.ind_rst_value, '9999999999.99' ) ) multiplication
FROM
	(
		(
		SELECT
			mmg.cd,
			mmg.conVal,
			oms.ind_rst_value,
			mmg.mediflg
		FROM
			mmg,
			ord_material_save oms
		WHERE
			oms.facility_cd = /*facilityCd*/'1'
			AND mmg.cd = oms.supplies_cd
			--mod #7746 投与支援で薬剤に薬効換算マスタの薬剤グループを設定すると算出できない 鄭爽 start
            --AND oms.supplies_base_date = /*baseDate*/'20200609'
			AND oms.supplies_base_date >= /*startDate*/'20200609'
			AND oms.supplies_base_date <= /*endDate*/'20200609'
			--mod #7746 投与支援で薬剤に薬効換算マスタの薬剤グループを設定すると算出できない 鄭爽 end
			AND mmg.mediflg = '0'
			AND oms.pat_id = /*patId*/'33'
			AND oms.ind_rst_class = '2'
			AND oms.supplies_source_class != '5'
		) UNION
		(
		SELECT
			mmg.cd,
			mmg.conVal,
			oms.ind_rst_value,
			mmg.mediflg
		FROM
			mmg,
			ord_material_save oms
		WHERE
			oms.facility_cd = /*facilityCd*/'1'
			AND mmg.cd = oms.supplies_cd
			--mod #7746 投与支援で薬剤に薬効換算マスタの薬剤グループを設定すると算出できない 鄭爽 start
            --AND oms.supplies_base_date = /*baseDate*/'20200609'
			AND oms.supplies_base_date >= /*startDate*/'20200609'
			AND oms.supplies_base_date <= /*endDate*/'20200609'
			--mod #7746 投与支援で薬剤に薬効換算マスタの薬剤グループを設定すると算出できない 鄭爽 end
			AND mmg.mediflg = '2'
			AND oms.pat_id = /*patId*/'33'
			AND oms.ind_rst_class = '2'
			AND oms.supplies_source_class != '5'
		)
	) AS tab
GROUP BY
	cd,
	conVal,
	mediflg) tTab
LEFT JOIN mst_medicine mm
ON to_number(tTab.cd, '9999999999.99') = mm.medicine_cd
