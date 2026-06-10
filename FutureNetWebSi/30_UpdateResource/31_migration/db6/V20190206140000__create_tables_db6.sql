--------------------------------------------------
-- 患者基本情報
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS pat_personal_main;
-- テーブル作成
CREATE TABLE pat_personal_main
(
pat_id bigserial NOT NULL,  --システムで管理する一意な患者ID
fn_pat_id character varying(12),  --FNW+で管理する施設内の一意な患者ID
hosp_pat_id character varying(12),  --院内表示用の患者ID
nkk_pat_id character varying(20),  --日機装内で管理する一意な患者ID
facility_cd character varying(6),  --登録施設コード
pat_last_name character varying,  --患者氏名(漢字姓)
pat_first_name character varying,  --患者氏名(漢字名)
pat_last_name_kana character varying,  --患者氏名(カタカナ姓)
pat_first_name_kana character varying,  --患者氏名(カタカナ名)
pat_last_name_alpha character varying,  --患者氏名(英字姓)
pat_first_name_alpha character varying,  --患者氏名(英字名)
pat_birth_name character varying,  --患者誕生時氏名(旧姓)(漢字)
pat_birth_name_kana character varying,  --患者誕生時氏名(旧姓)(カタカナ)
pat_birth_name_alpha character varying,  --患者誕生時氏名(旧姓)(英字)
pat_birthday character varying(8),  --生年月日(YYYYMMDD)
pat_sex smallint,  --性別
nationality character varying(3),  --国籍
pat_blood_type_abo smallint,  --血液型ABO
pat_blood_type_rh smallint,  --血液型RH
pat_blood_type_serovar smallint,  --血液型亜型
in_out_class smallint,  --入外区分
is_die character varying(1),  --死亡患者
die_cd integer,  --死因コード
die_date timestamp(3),  --死亡日
dial_diff_com_info jsonb,  --透析困難情報
severity_cd integer,  --重症度コード
transport_cd integer,  --搬送区分コード
pat_contact_info jsonb DEFAULT E'{"zip_cd":null,"address":null,"tel1":null,"tel2":null,"fax":null,"e_mail":null,"work_name":null,"work_address":null,"work_tel":null,"memo1":null,"memo2":null}',  --本人連絡先情報
other_contact_info jsonb,  --連絡先情報
vendor_contact_info jsonb,  --業者連絡先情報
insurance_info jsonb,  --保険情報
is_del character varying(1) DEFAULT '0',  --削除フラグ
up_date timestamp(3),  --更新日時
reg_date timestamp(3),  --登録日時
CONSTRAINT unq_pat_personal_main_01 PRIMARY KEY (pat_id)
);
-- コメント追加
COMMENT ON TABLE "pat_personal_main" IS E'患者基本情報';
COMMENT ON COLUMN "pat_personal_main"."pat_id" IS E'システムで管理する一意な患者ID';
COMMENT ON COLUMN "pat_personal_main"."fn_pat_id" IS E'FNW+で管理する施設内の一意な患者ID';
COMMENT ON COLUMN "pat_personal_main"."hosp_pat_id" IS E'院内表示用の患者ID';
COMMENT ON COLUMN "pat_personal_main"."nkk_pat_id" IS E'日機装内で管理する一意な患者ID';
COMMENT ON COLUMN "pat_personal_main"."facility_cd" IS E'登録施設コード';
COMMENT ON COLUMN "pat_personal_main"."pat_last_name" IS E'患者氏名(漢字姓)';
COMMENT ON COLUMN "pat_personal_main"."pat_first_name" IS E'患者氏名(漢字名)';
COMMENT ON COLUMN "pat_personal_main"."pat_last_name_kana" IS E'患者氏名(カタカナ姓)';
COMMENT ON COLUMN "pat_personal_main"."pat_first_name_kana" IS E'患者氏名(カタカナ名)';
COMMENT ON COLUMN "pat_personal_main"."pat_last_name_alpha" IS E'患者氏名(英字姓)';
COMMENT ON COLUMN "pat_personal_main"."pat_first_name_alpha" IS E'患者氏名(英字名)';
COMMENT ON COLUMN "pat_personal_main"."pat_birth_name" IS E'患者誕生時氏名(旧姓)(漢字)';
COMMENT ON COLUMN "pat_personal_main"."pat_birth_name_kana" IS E'患者誕生時氏名(旧姓)(カタカナ)';
COMMENT ON COLUMN "pat_personal_main"."pat_birth_name_alpha" IS E'患者誕生時氏名(旧姓)(英字)';
COMMENT ON COLUMN "pat_personal_main"."pat_birthday" IS E'生年月日(YYYYMMDD)';
COMMENT ON COLUMN "pat_personal_main"."pat_sex" IS E'性別';
COMMENT ON COLUMN "pat_personal_main"."nationality" IS E'国籍';
COMMENT ON COLUMN "pat_personal_main"."pat_blood_type_abo" IS E'血液型ABO';
COMMENT ON COLUMN "pat_personal_main"."pat_blood_type_rh" IS E'血液型RH';
COMMENT ON COLUMN "pat_personal_main"."pat_blood_type_serovar" IS E'血液型亜型';
COMMENT ON COLUMN "pat_personal_main"."in_out_class" IS E'入外区分';
COMMENT ON COLUMN "pat_personal_main"."is_die" IS E'死亡患者';
COMMENT ON COLUMN "pat_personal_main"."die_cd" IS E'死因コード';
COMMENT ON COLUMN "pat_personal_main"."die_date" IS E'死亡日';
COMMENT ON COLUMN "pat_personal_main"."dial_diff_com_info" IS E'透析困難情報';
COMMENT ON COLUMN "pat_personal_main"."severity_cd" IS E'重症度コード';
COMMENT ON COLUMN "pat_personal_main"."transport_cd" IS E'搬送区分コード';
COMMENT ON COLUMN "pat_personal_main"."pat_contact_info" IS E'本人連絡先情報';
COMMENT ON COLUMN "pat_personal_main"."other_contact_info" IS E'連絡先情報';
COMMENT ON COLUMN "pat_personal_main"."vendor_contact_info" IS E'業者連絡先情報';
COMMENT ON COLUMN "pat_personal_main"."insurance_info" IS E'保険情報';
COMMENT ON COLUMN "pat_personal_main"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "pat_personal_main"."up_date" IS E'更新日時';
COMMENT ON COLUMN "pat_personal_main"."reg_date" IS E'登録日時';
