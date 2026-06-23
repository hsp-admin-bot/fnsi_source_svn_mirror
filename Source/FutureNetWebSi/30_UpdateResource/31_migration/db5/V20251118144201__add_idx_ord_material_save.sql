DROP INDEX IF EXISTS idx_ord_material_save_03;
CREATE INDEX idx_ord_material_save_03	
ON ord_material_save (	
  facility_cd,	
  supplies_base_date,	
  pat_id	
);	
