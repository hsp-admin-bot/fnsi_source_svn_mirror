select
  /*%expand "A" */*
from
  ord_main A
where
  A.facility_cd = /*facilityCd*/'999999'
and
  A.ord_no in /*ordNoList*/(null)
and
  A.rst_dialysis_state = '0'
and
  A.is_del = '0'
and ( 1 = 0
/*%if treatmenCdList.size() > 0 */
or
  A.ind_treatment_cd in /*treatmenCdList*/(null)
/*%end*/
/*%if kurCdList.size() > 0 */
or
  A.ind_kur_cd in /*kurCdList*/(null)
/*%end*/
/*%if bedCdList.size() > 0 */
or
  A.ind_bed_cd in /*bedCdList*/(null)
/*%end*/
/*%if dialyzerCdList.size() > 0 */
or
  (A.ind_cond_info -> '5' ->> 'value')::int IN /*dialyzerCdList*/(null)
/*%end*/
/*%if dialyzerCdForMemoList.size() > 0 */
or
  (
    (A.ind_cond_info -> '5' ->> 'value')::int IN /*dialyzerCdForMemoList*/(null)
    AND A.ind_bed_cd in /*bedCdForMemoList*/(null)
  )
or
  (EXISTS (
    SELECT 1
    FROM jsonb_array_elements(A.ind_equip_info) AS equip_info
    WHERE (equip_info ->> 'cd')::int IN /*dialyzerCdForMemoList*/(null)
    AND (equip_info ->> 'equip_type')::text = '1'
    AND A.ind_bed_cd in /*bedCdForMemoForEquipmentList*/(null)
  ))
/*%end*/
/*%if patIdForMemoList.size() > 0 */
or
  (A.pat_id in /*patIdForMemoList*/(null) and A.ind_bed_cd in /*bedCdForMemoList*/(null))
/*%end*/
/*%if vaCdForMemoList.size() > 0 */
or
  (A.ind_va_cd in /*vaCdForMemoList*/(null) and A.ind_bed_cd in /*bedCdForMemoList*/(null))
/*%end*/
/*%if treatmenCdForMemoList.size() > 0 */
or
  (A.ind_treatment_cd in /*treatmenCdForMemoList*/(null) and A.ind_bed_cd in /*bedCdForMemoList*/(null))
/*%end*/
/*%if mstEquipmentCdForMemoList.size() > 0 */
or
  (
    ((A.ind_cond_info -> '6' ->> 'value')::int IN /*mstEquipmentCdForMemoList*/(null) and A.ind_bed_cd in /*bedCdForMemoForDialyzerList*/(null))
      or
    ((A.ind_cond_info -> '7' ->> 'value')::int IN /*mstEquipmentCdForMemoList*/(null) and (A.ind_bed_cd in /*bedCdForMemoForDialyzerList*/(null) or A.ind_bed_cd in /*bedCdForMemoForPrimaryMembraneList*/(null)))
      or
    ((A.ind_cond_info -> '8' ->> 'value')::int IN /*mstEquipmentCdForMemoList*/(null) and A.ind_bed_cd in /*bedCdForMemoForDialyzerList*/(null))
      or
    ((A.ind_cond_info -> '9' ->> 'value')::int IN /*mstEquipmentCdForMemoList*/(null) and A.ind_bed_cd in /*bedCdForMemoForANeedleMembraneList*/(null))
      or
    ((A.ind_cond_info -> '10' ->> 'value')::int IN /*mstEquipmentCdForMemoList*/(null) and A.ind_bed_cd in /*bedCdForMemoForVNeedleMembraneList*/(null))
      or
    ((A.ind_cond_info -> '11' ->> 'value')::int IN /*mstEquipmentCdForMemoList*/(null) and A.ind_bed_cd in /*bedCdForMemoForANeedleMembraneList*/(null))
      or
      (EXISTS (
          SELECT 1
          FROM jsonb_array_elements(A.ind_equip_info) AS equip_info
          WHERE (equip_info ->> 'cd')::int IN /*mstEquipmentCdForMemoList*/(null)
          AND (equip_info ->> 'equip_type')::text = '0'
        AND A.ind_bed_cd in /*bedCdForMemoList*/(null)
      ))
    )
/*%end*/
/*%if mstMedicineCdForMemoList.size() > 0 */
or
  (
    ((A.ind_cond_info -> '15' ->> 'value')::int IN /*mstMedicineCdForMemoList*/(null) and (A.ind_cond_info -> '15' ->> 'medicine_type')::text = '1' and A.ind_bed_cd in /*bedCdForMemoForDialysateList*/(null))
      or
    ((A.ind_cond_info -> '25' ->> 'value')::int IN /*mstMedicineCdForMemoList*/(null) and (A.ind_cond_info -> '25' ->> 'medicine_type')::text = '1' and A.ind_bed_cd in /*bedCdForMemoForAnticoagulantList*/(null))
      or
      (EXISTS (
      SELECT 1
      FROM jsonb_array_elements(A.ind_medi_info) AS medi_info
      WHERE (medi_info ->> 'cd')::int IN /*mstMedicineCdForMemoList*/(null)
      AND (medi_info ->> 'medicine_type')::text = '1'
    AND A.ind_bed_cd in /*bedCdForMemoList*/(null)
      ))
    )
/*%end*/
/*%if mstMedicineMixCdForMemoList.size() > 0 */
or
  (
    ((A.ind_cond_info -> '15' ->> 'value')::int IN /*mstMedicineMixCdForMemoList*/(null) and (A.ind_cond_info -> '15' ->> 'medicine_type')::text = '2' and A.ind_bed_cd in /*bedCdForMemoForDialysateList*/(null))
      or
    ((A.ind_cond_info -> '25' ->> 'value')::int IN /*mstMedicineMixCdForMemoList*/(null) and (A.ind_cond_info -> '25' ->> 'medicine_type')::text = '2' and A.ind_bed_cd in /*bedCdForMemoForAnticoagulantList*/(null))
      or
      (EXISTS (
      SELECT 1
      FROM jsonb_array_elements(A.ind_medi_info) AS medi_info
      WHERE (medi_info ->> 'cd')::int IN /*mstMedicineMixCdForMemoList*/(null)
      AND (medi_info ->> 'medicine_type')::text = '2'
    AND A.ind_bed_cd in /*bedCdForMemoList*/(null)
      ))
  )
/*%end*/
)
;
