// 患者ID 昇順でIndex作成
db.ind_history.createIndex({ pat_id: 1 });
//
// 発行日 降順でIndex作成
db.ind_history.createIndex({ log_date: -1 });
//
// 開始日 降順でIndex作成
db.ind_history.createIndex({ treatment_start_date: -1 });
//
// 施設コード 昇順でIndex作成
db.ind_history.createIndex({ facility_cd: 1 });
