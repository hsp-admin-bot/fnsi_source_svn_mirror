-- add 10150_9664 by kangjie 20240528 start offline -> online
UPDATE mst_treatment_set
SET ind_cond_info = jsonb_merge_recursive(((/*indCondInfoDefault*/null)::jsonb || ind_cond_info) -
                                          (/*getDisUseCtlNoRst*/null)::text[],
                                          COALESCE(
                                            (SELECT jsonb_object_agg('19', VALUE)
                                             FROM jsonb_each(ind_cond_info)
                                             WHERE KEY = '15'), '{}' :: jsonb))
WHERE facility_cd = /*facilityCd*/'000000'
  AND treatment_cd = /*treatmentCode*/-1;
-- add 10150_9664 by kangjie 20240528 end
