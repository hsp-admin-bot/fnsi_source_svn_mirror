-- #12465 pat_treatment_pattern UNIQUE追加 (pat_id, ind_treatment_cd, ind_kur_cd, treat_week)
ALTER TABLE pat_treatment_pattern
ADD CONSTRAINT uniq_pat_treat_kur_week
UNIQUE (pat_id, ind_treatment_cd, ind_kur_cd, treat_week);

