ALTER TABLE pat_insurance ADD COLUMN fn_ctl_no VARCHAR(1) DEFAULT NULL;
comment on column pat_insurance.fn_ctl_no  is 'FNW+で管理する施設内の一意な職種コード';