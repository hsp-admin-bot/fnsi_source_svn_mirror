DROP TABLE IF EXISTS sys_daily_no;
create table sys_daily_no
(
    ctl_no       bigserial
        constraint unq_sys_daitly_number_01
            primary key,
    facility_cd  varchar(6)           not null,
    numbering_cd varchar(20),
    base_date    varchar(8),
    current_no   integer    default 0 not null,
    is_disp      varchar(1) default '1'::character varying,
    is_del       varchar(1) default '0'::character varying,
    up_date      timestamp(3),
    reg_date     timestamp(3),
    constraint unq_sys_daily_no_02
        unique (facility_cd, numbering_cd, base_date, is_del)
);

comment on table sys_daily_no is '受付番号採番';

comment on column sys_daily_no.ctl_no is '管理番号';

comment on column sys_daily_no.facility_cd is '施設コード';

comment on column sys_daily_no.numbering_cd is '採番種別';

comment on column sys_daily_no.is_disp is '表示フラグ';

comment on column sys_daily_no.is_del is '削除フラグ';

comment on column sys_daily_no.up_date is '更新日時';

comment on column sys_daily_no.reg_date is '登録日時';

comment on column sys_daily_no.current_no is '採番値';

comment on column sys_daily_no.base_date is '基準日';
