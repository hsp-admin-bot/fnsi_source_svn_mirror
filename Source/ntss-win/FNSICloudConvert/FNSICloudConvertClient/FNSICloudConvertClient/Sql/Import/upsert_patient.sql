-- 患者データを upsert する
-- パラメーター:
--   :patientId   患者ID
--   :facilityCd  施設コード
--   :patientNo   患者番号
--   :name        氏名
--   :birthDate   生年月日
--   :sex         性別
INSERT INTO patient (
    patient_id,
    facility_cd,
    patient_no,
    name,
    birth_date,
    sex,
    created_at,
    updated_at
) VALUES (
    /* :patientId */0,
    /* :facilityCd */'F001',
    /* :patientNo */'000001',
    /* :name */'テスト太郎',
    /* :birthDate */'1990-01-01',
    /* :sex */1,
    NOW(),
    NOW()
)
ON CONFLICT (patient_id) DO UPDATE SET
    facility_cd = EXCLUDED.facility_cd,
    patient_no  = EXCLUDED.patient_no,
    name        = EXCLUDED.name,
    birth_date  = EXCLUDED.birth_date,
    sex         = EXCLUDED.sex,
    updated_at  = NOW()
