ALTER TABLE pat_insurance
  ADD COLUMN IF NOT EXISTS start_date_temp character varying(8),
  ADD COLUMN IF NOT EXISTS end_date_temp character varying(8),
  ADD COLUMN IF NOT EXISTS check_date_temp character varying(8);
 
UPDATE pat_insurance
SET
  start_date_temp = to_char(start_date, 'YYYYMMDD'),
  end_date_temp = to_char(end_date, 'YYYYMMDD'),
  check_date_temp = to_char(check_date, 'YYYYMMDD');

ALTER TABLE pat_insurance
  DROP COLUMN start_date,
  DROP COLUMN end_date,
  DROP COLUMN check_date;

ALTER TABLE pat_insurance RENAME COLUMN start_date_temp TO start_date;
ALTER TABLE pat_insurance RENAME COLUMN end_date_temp TO end_date;
ALTER TABLE pat_insurance RENAME COLUMN check_date_temp TO check_date;
