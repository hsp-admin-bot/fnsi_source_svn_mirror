-- コードの末尾が0
UPDATE
  mst_machine_record
SET
  is_default='1'
  , log_class=NULL
  , target_model=NULL
WHERE
  machine_record_cd LIKE '%0'
;

-- コードの末尾が1
UPDATE
  mst_machine_record
SET
  is_default='1'
  , log_class='1'
  , target_model='1'
WHERE
  machine_record_cd LIKE '%1'
;

-- コードの末尾が2
UPDATE
  mst_machine_record
SET
  is_default='1'
  , log_class='2'
  , target_model='3'
WHERE
  machine_record_cd LIKE '%2'
;

-- コードの末尾が3
UPDATE
  mst_machine_record
SET
  is_default='1'
  , log_class='4'
  , target_model='2'
WHERE
  machine_record_cd LIKE '%3'
;

-- コードの末尾が4
UPDATE
  mst_machine_record
SET
  is_default='1'
  , log_class='6'
  , target_model='6'
WHERE
  machine_record_cd LIKE '%4'
;

-- コードの末尾が5
UPDATE
  mst_machine_record
SET
  is_default='0'
  , log_class='2'
  , target_model='3'
WHERE
  machine_record_cd LIKE '%5'
;

-- コードの末尾が6
UPDATE
  mst_machine_record
SET
  is_default='0'
  , log_class='4'
  , target_model='5'
WHERE
  machine_record_cd LIKE '%6'
;

-- コードの末尾が7
UPDATE
  mst_machine_record
SET
  is_default='0'
  , log_class='1'
  , target_model='2'
WHERE
  machine_record_cd LIKE '%7'
;

-- コードの末尾が8
UPDATE
  mst_machine_record
SET
  is_default='0'
  , log_class='6'
  , target_model='6'
WHERE
  machine_record_cd LIKE '%8'
;

-- コードの末尾が9
UPDATE
  mst_machine_record
SET
  is_default='0'
  , log_class=NULL
  , target_model='1'
WHERE
  machine_record_cd LIKE '%9'
;

-- コードの末尾がA
UPDATE
  mst_machine_record
SET
  is_default='0'
  , log_class=NULL
  , target_model='4'
WHERE
  machine_record_cd LIKE '%A'
;

-- コードの末尾がB
UPDATE
  mst_machine_record
SET
  is_default='0'
  , log_class=NULL
  , target_model='6'
WHERE
  machine_record_cd LIKE '%B'
;

-- コードの末尾がC
UPDATE
  mst_machine_record
SET
  is_default='0'
  , log_class='1'
  , target_model=NULL
WHERE
  machine_record_cd LIKE '%C'
;

-- コードの末尾がD
UPDATE
  mst_machine_record
SET
  is_default='0'
  , log_class='5'
  , target_model=NULL
WHERE
  machine_record_cd LIKE '%D'
;

-- コードの末尾がE
UPDATE
  mst_machine_record
SET
  is_default='0'
  , log_class='6'
  , target_model=NULL
WHERE
  machine_record_cd LIKE '%E'
;

-- コードの末尾がF
UPDATE
  mst_machine_record
SET
  is_default='0'
  , log_class=NULL
  , target_model=NULL
WHERE
  machine_record_cd LIKE '%F'
;
