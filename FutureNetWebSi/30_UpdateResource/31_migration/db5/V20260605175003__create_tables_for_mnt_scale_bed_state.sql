--#11987 スケールベッド新規リリースのためのマイグレーションファイル

--新規追加テーブル(mnt_scale_bed_state)	

--削除テーブル
DROP TABLE IF EXISTS mnt_scale_bed_state;

--テーブル生成
create table mnt_scale_bed_state (
  bed_cd bigint not null , --ベッドコード   
  weight_cd bigint not null ,  --体重計管理番号   
  facility_cd character varying(6),  --施設コード
  is_connect character varying(1),  --接続状態   
  before_send_status numeric(1),  --前体重送信状態   
  after_send_status numeric(1),  --後体重送信状態   
  before_weight_scale_no bigint,    --前体重測定管理番号コード
  after_weight_scale_no bigint,    --後体重測定管理番号コード
  reg_date timestamp(3) without time zone,  --登録日時
  up_date timestamp(3) without time zone,  --更新日時   
   primary key (bed_cd)
);

--物理名称設定
comment on table mnt_scale_bed_state is 'スケールベッド状態管理';
comment on column mnt_scale_bed_state.bed_cd is 'ベッドコード';
comment on column mnt_scale_bed_state. weight_cd is '体重計管理番号';
comment on column mnt_scale_bed_state.facility_cd is '施設コード';
comment on column mnt_scale_bed_state.is_connect is '接続状態';
comment on column mnt_scale_bed_state.before_send_status is '前体重送信状態';
comment on column mnt_scale_bed_state.after_send_status is '後体重送信状態';
comment on column mnt_scale_bed_state.before_weight_scale_no is '前体重測定管理番号コード';
comment on column mnt_scale_bed_state.after_weight_scale_no is '後体重測定管理番号コード';
comment on column mnt_scale_bed_state.reg_date is '登録日時';
comment on column mnt_scale_bed_state.up_date is '更新日時';
