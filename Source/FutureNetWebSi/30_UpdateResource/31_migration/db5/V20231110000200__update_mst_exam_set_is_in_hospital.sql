UPDATE mst_exam_set SET is_in_hospital = '0' WHERE fn_exam_set_cd IS NULL AND is_in_hospital IS NULL;
