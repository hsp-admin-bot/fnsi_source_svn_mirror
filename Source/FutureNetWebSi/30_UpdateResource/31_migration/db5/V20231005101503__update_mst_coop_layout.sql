UPDATE
    mst_coop_layout
SET
    user_id = -1
WHERE
    facility_cd = 'C_hosp';
    
UPDATE
    mst_coop_layout
SET
    coop_setting = '<rootnode></rootnode>'
    ,up_date = CURRENT_TIMESTAMP
WHERE
    facility_cd = 'C_hosp'
    AND coop_setting IS NULL