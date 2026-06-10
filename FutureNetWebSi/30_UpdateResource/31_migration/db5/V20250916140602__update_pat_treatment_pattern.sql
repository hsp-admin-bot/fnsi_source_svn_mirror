UPDATE pat_treatment_pattern
SET ind_medi_info = (
  SELECT jsonb_agg(medi - 'isAmountchg')
  FROM jsonb_array_elements(ind_medi_info) AS medi
)
WHERE EXISTS (
    SELECT 1
    FROM jsonb_array_elements(ind_medi_info) AS elem
    WHERE elem ? 'isAmountchg'
  );