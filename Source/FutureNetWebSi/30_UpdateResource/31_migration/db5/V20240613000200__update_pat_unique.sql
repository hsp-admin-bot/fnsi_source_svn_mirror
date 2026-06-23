update pat_unique set medical_hst_info = jsonb_set(
  medical_hst_info,
  '{0,out_come}',  -- The first element in JsonArray
  '"0"'::jsonb,  -- The default value '0' to set
  false  -- If true, this will make a new key if it doesn't exist in the jsonb
)
where pat_id = 2004;


update pat_unique set medical_hst_info = jsonb_set(
  medical_hst_info,
  '{0,out_come}',  -- The first element in JsonArray
  '"0"'::jsonb,  -- The default value '0' to set
  false  -- If true, this will make a new key if it doesn't exist in the jsonb
)
where pat_id = 2007;


update pat_unique set medical_hst_info = jsonb_set(
  medical_hst_info,
  '{0,out_come}',  -- The first element in JsonArray
  '"0"'::jsonb,  -- The default value '0' to set
  false  -- If true, this will make a new key if it doesn't exist in the jsonb
 )
where pat_id = 2008;


update pat_unique set medical_hst_info = jsonb_set(
  medical_hst_info,
  '{0,out_come}',  -- The first element in JsonArray
  '"0"'::jsonb,  -- The default value '0' to set
  false  -- If true, this will make a new key if it doesn't exist in the jsonb
)
where pat_id = 2009;


update pat_unique set medical_hst_info = jsonb_set(
  medical_hst_info,
  '{1,out_come}',  -- The second element in JsonArray
  '"0"'::jsonb,  -- The default value '0' to set
  false  -- If true, this will make a new key if it doesn't exist in the jsonb
)
where pat_id = 2176;


update pat_unique set medical_hst_info = jsonb_set(
  medical_hst_info,
  '{0,out_come}',  -- The first element in JsonArray
  '"0"'::jsonb,  -- The default value '0' to set
  false  -- If true, this will make a new key if it doesn't exist in the jsonb
)
where pat_id = 2187;


update pat_unique set medical_hst_info = jsonb_set(
  medical_hst_info,
  '{0,out_come}',  -- The first element in JsonArray
  '"0"'::jsonb,  -- The default value '0' to set
  false  -- If true, this will make a new key if it doesn't exist in the jsonb
)
where pat_id = 2188;


update pat_unique set medical_hst_info = jsonb_set(
  medical_hst_info,
  '{0,out_come}',  -- The first element in JsonArray
  '"0"'::jsonb,  -- The default value '0' to set
  false  -- If true, this will make a new key if it doesn't exist in the jsonb
)
where pat_id = 16634;
