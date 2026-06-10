SELECT
    disease_cd,
    disease_name,
    is_disp,
    is_del
FROM
  mst_disease
WHERE
    disease_cd in /* diseaseCds */(NULL)
        