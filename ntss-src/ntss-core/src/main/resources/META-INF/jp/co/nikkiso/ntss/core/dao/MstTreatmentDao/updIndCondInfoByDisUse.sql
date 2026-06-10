UPDATE mst_treatment_set
SET ind_cond_info = ((/*indCondInfoDefault*/null)::jsonb || ind_cond_info) - (/*getDisUseCtlNoRst*/null)::text[]
WHERE facility_cd = /*facilityCd*/'000000'
  AND treatment_cd = /*treatmentCode*/-1;
