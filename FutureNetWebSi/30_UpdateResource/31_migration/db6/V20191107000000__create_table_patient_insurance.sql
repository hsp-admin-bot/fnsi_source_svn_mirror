DROP TABLE IF EXISTS pat_insurance;
CREATE TABLE pat_insurance
(
    insurance_cd bigserial NOT NULL,
    pat_id bigint NOT NULL,
    facility_cd character varying(6) NOT NULL,
    ctl_no bigint,
    fn_pat_id character varying(12),
    insu_class integer,
    insu_name character varying(256),
    insu_name_short character varying(4),
    start_date timestamp(3),
    end_date timestamp(3),
    check_date timestamp(3),
    insu_info jsonb,
    insu_pub_info jsonb,
    insu_set_info jsonb,
    insu_self_info jsonb,
    is_selected character varying(1),
    is_disp character varying(1) DEFAULT '1',
    is_del character varying(1) DEFAULT '0',
    coop_code character varying(12),
    is_coop character varying(1) DEFAULT '0',
    reg_date timestamp(3),
    up_date timestamp(3),
 
    CONSTRAINT unq_insurance_01 PRIMARY KEY (insurance_cd)
)
WITH (
    OIDS=FALSE
);