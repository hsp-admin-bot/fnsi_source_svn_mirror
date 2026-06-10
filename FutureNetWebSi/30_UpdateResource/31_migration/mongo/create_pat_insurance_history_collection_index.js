// 患者ID 昇順でIndex作成
db.pat_insurance_history.createIndex({ facility_cd: 1, pat_id: 1 });