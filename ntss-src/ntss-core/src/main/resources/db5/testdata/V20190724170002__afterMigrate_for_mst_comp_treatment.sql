-- 愁訴処置マスタの手技コードを修正
UPDATE mst_comp_treatment SET procedure_cd = 2 WHERE comp_treatment_cd = 4;
UPDATE mst_comp_treatment SET procedure_cd = 4 WHERE comp_treatment_cd = 5;
