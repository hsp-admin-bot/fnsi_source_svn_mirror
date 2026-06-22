-- add 10150_9664 by kangjie 20240528 start del 19.20.21.22.23.24
UPDATE mst_treatment_set
SET ind_cond_info = ((/*indCondInfoDefault*/null)::jsonb || ind_cond_info) - (/*getDisUseCtlNoRst*/null)::text[] - '{19,20,21,22,23,24}' ::text[]
WHERE facility_cd = /*facilityCd*/'000000'
  AND treatment_cd = /*treatmentCode*/-1;
-- add 10150_9664 by kangjie 20240528 end
