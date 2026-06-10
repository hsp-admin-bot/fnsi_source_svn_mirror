﻿DROP INDEX IF EXISTS idx_pat_main_01;
CREATE INDEX idx_pat_main_01 ON pat_main USING btree (facility_cd,is_del, sch_ext_end_date);
DROP INDEX IF EXISTS idx_pat_main_medical_care_info_01;
CREATE INDEX idx_pat_main_medical_care_info_01 ON pat_main USING GIN ((medical_care_info -> 'dialysis_start_date'));
DROP INDEX IF EXISTS idx_pat_main_medical_care_info_02;
CREATE INDEX idx_pat_main_medical_care_info_02 ON pat_main USING GIN ((medical_care_info -> 'dialysis_count'), (medical_care_info -> 'purification_count'));