// 患者ID 昇順でIndex作成
db.pat_main_history.createIndex({ facility_cd: 1, pat_id: 1 });
db.pat_main_history.createIndex({	
    latest_flag: NumberInt("1")	
}, {	
    name: "latest_flag_1"	
});	
//施設コード Index作成
db.pat_main_history.createIndex({	
    facility_cd: NumberInt("1")	
}, {	
    name: "facility_cd_1"	
});	