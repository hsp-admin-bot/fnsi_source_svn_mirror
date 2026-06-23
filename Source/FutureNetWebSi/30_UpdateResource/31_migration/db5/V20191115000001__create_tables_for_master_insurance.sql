DROP TABLE IF EXISTS mst_insurance;
CREATE TABLE mst_insurance
(
    insu_cd bigserial NOT NULL,
    facility_cd character varying(6),
    name character varying(256),
    insu_name character varying(256),
    insu_name_short character varying(4),
    futan_g integer,
    futan_n integer,
    insu_type integer,
    reg_date timestamp(3),
    up_date timestamp(3),
    is_disp character varying(1) DEFAULT '1',
    is_del character varying(1) DEFAULT '0',
    CONSTRAINT unq_insu_01 PRIMARY KEY (insu_cd)
)
WITH (
    OIDS=FALSE
);