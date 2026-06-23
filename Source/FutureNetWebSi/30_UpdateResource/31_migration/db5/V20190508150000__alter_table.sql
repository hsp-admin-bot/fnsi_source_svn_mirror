--ord_scheduleの主キーにord_noを追加
ALTER TABLE ord_schedule DROP CONSTRAINT unq_ord_schedule_01;
ALTER TABLE ord_schedule ADD CONSTRAINT unq_ord_schedule_01 PRIMARY KEY (facility_cd,ord_no,treat_date,kur_cd,bed_cd);
