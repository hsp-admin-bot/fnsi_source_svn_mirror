DROP INDEX IF EXISTS idx_mst_infection_01;
CREATE INDEX idx_mst_infection_01
ON mst_infection (infection_cd)
WHERE
    is_del = '0'
    AND is_disp = '1'
    AND in_hospital_cd_1 IS NOT NULL;