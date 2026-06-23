DELETE FROM ntss.sys_data_set
WHERE sql_cd IN(-2450,-2071)
;
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2450, 'WITH
  elements AS (
    SELECT
      ctlno,
      setname,
      elemkey,
      datapattern,
      defaultvalue
    FROM
      jsonb_to_recordset(
        ''[
    {"ctlno":"1","setname":"静脈圧自動設定警報幅上限HD/ECUM","elemkey":"dev-A-0100","datapattern":"1","defaultvalue":"50","level1":"war","level2":"dev","level3":"A","level4":"100"},
    {"ctlno":"2","setname":"静脈圧自動設定警報幅下限HD/ECUM","elemkey":"dev-A-0101","datapattern":"1","defaultvalue":"-30","level1":"war","level2":"dev","level3":"A","level4":"101"},
    {"ctlno":"3","setname":"静脈圧自動設定警報限界上限","elemkey":"dev-A-0102","datapattern":"1","defaultvalue":"200","level1":"war","level2":"dev","level3":"A","level4":"102"},
    {"ctlno":"4","setname":"静脈圧自動設定警報限界下限","elemkey":"dev-A-0103","datapattern":"1","defaultvalue":"10","level1":"war","level2":"dev","level3":"A","level4":"103"},
    {"ctlno":"5","setname":"静脈圧固定警報上限","elemkey":"dev-A-0104","datapattern":"1","defaultvalue":"200","level1":"war","level2":"dev","level3":"A","level4":"104"},
    {"ctlno":"6","setname":"静脈圧固定警報下限","elemkey":"dev-A-0105","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"105"},
    {"ctlno":"7","setname":"静脈圧自動設定警報幅上限HDF/HF","elemkey":"dev-A-0106","datapattern":"1","defaultvalue":"70","level1":"war","level2":"dev","level3":"A","level4":"106"},
    {"ctlno":"8","setname":"静脈圧自動設定警報幅下限HDF/HF","elemkey":"dev-A-0107","datapattern":"1","defaultvalue":"-70","level1":"war","level2":"dev","level3":"A","level4":"107"},
    {"ctlno":"9","setname":"静脈圧固定警報上限準備回収","elemkey":"dev-A-0108","datapattern":"1","defaultvalue":"250","level1":"war","level2":"dev","level3":"A","level4":"108"},
    {"ctlno":"10","setname":"静脈圧固定警報下限準備回収","elemkey":"dev-A-0109","datapattern":"1","defaultvalue":"-200","level1":"war","level2":"dev","level3":"A","level4":"109"},
    {"ctlno":"11","setname":"静脈圧固定警報上限ＳＮ","elemkey":"dev-A-0110","datapattern":"1","defaultvalue":"400","level1":"war","level2":"dev","level3":"A","level4":"110"},
    {"ctlno":"12","setname":"静脈圧固定警報下限ＳＮ","elemkey":"dev-A-0111","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"111"},
    {"ctlno":"13","setname":"液圧自動設定警報幅上限HD/ECUM","elemkey":"dev-A-0112","datapattern":"1","defaultvalue":"50","level1":"war","level2":"dev","level3":"A","level4":"112"},
    {"ctlno":"14","setname":"液圧自動設定警報幅下限HD/ECUM","elemkey":"dev-A-0113","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"113"},
    {"ctlno":"15","setname":"液圧自動設定警報限界上限","elemkey":"dev-A-0114","datapattern":"1","defaultvalue":"300","level1":"war","level2":"dev","level3":"A","level4":"114"},
    {"ctlno":"16","setname":"液圧自動設定警報限界下限","elemkey":"dev-A-0115","datapattern":"1","defaultvalue":"-300","level1":"war","level2":"dev","level3":"A","level4":"115"},
    {"ctlno":"17","setname":"液圧固定警報上限","elemkey":"dev-A-0116","datapattern":"1","defaultvalue":"300","level1":"war","level2":"dev","level3":"A","level4":"116"},
    {"ctlno":"18","setname":"液圧固定警報下限","elemkey":"dev-A-0117","datapattern":"1","defaultvalue":"-300","level1":"war","level2":"dev","level3":"A","level4":"117"},
    {"ctlno":"19","setname":"液圧自動設定警報幅上限HDF/HF","elemkey":"dev-A-0118","datapattern":"1","defaultvalue":"70","level1":"war","level2":"dev","level3":"A","level4":"118"},
    {"ctlno":"20","setname":"液圧自動設定警報幅下限HDF/HF","elemkey":"dev-A-0119","datapattern":"1","defaultvalue":"-70","level1":"war","level2":"dev","level3":"A","level4":"119"},
    {"ctlno":"21","setname":"液圧自動設定警報幅上限ＳＮ","elemkey":"dev-A-0120","datapattern":"1","defaultvalue":"70","level1":"war","level2":"dev","level3":"A","level4":"120"},
    {"ctlno":"22","setname":"液圧自動設定警報幅下限ＳＮ","elemkey":"dev-A-0121","datapattern":"1","defaultvalue":"-70","level1":"war","level2":"dev","level3":"A","level4":"121"},
    {"ctlno":"23","setname":"液圧自動設定警報限界上限ＳＮ","elemkey":"dev-A-0122","datapattern":"1","defaultvalue":"300","level1":"war","level2":"dev","level3":"A","level4":"122"},
    {"ctlno":"24","setname":"液圧自動設定警報限界下限ＳＮ","elemkey":"dev-A-0123","datapattern":"1","defaultvalue":"-300","level1":"war","level2":"dev","level3":"A","level4":"123"},
    {"ctlno":"25","setname":"液圧固定警報上限ＳＮ","elemkey":"dev-A-0124","datapattern":"1","defaultvalue":"300","level1":"war","level2":"dev","level3":"A","level4":"124"},
    {"ctlno":"26","setname":"液圧固定警報下限ＳＮ","elemkey":"dev-A-0125","datapattern":"1","defaultvalue":"-300","level1":"war","level2":"dev","level3":"A","level4":"125"},
    {"ctlno":"27","setname":"ＴＭＰ自動追従警報幅上限HD/ECUM","elemkey":"dev-A-0126","datapattern":"1","defaultvalue":"20","level1":"war","level2":"dev","level3":"A","level4":"126"},
    {"ctlno":"28","setname":"ＴＭＰ自動追従警報幅下限HD/ECUM","elemkey":"dev-A-0127","datapattern":"1","defaultvalue":"-20","level1":"war","level2":"dev","level3":"A","level4":"127"},
    {"ctlno":"29","setname":"ＴＭＰ自動設定警報幅上限HD/ECUM","elemkey":"dev-A-0128","datapattern":"1","defaultvalue":"50","level1":"war","level2":"dev","level3":"A","level4":"128"},
    {"ctlno":"30","setname":"ＴＭＰ自動設定警報幅下限HD/ECUM","elemkey":"dev-A-0129","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"129"},
    {"ctlno":"31","setname":"ＴＭＰ自動設定警報限界上限","elemkey":"dev-A-0130","datapattern":"1","defaultvalue":"500","level1":"war","level2":"dev","level3":"A","level4":"130"},
    {"ctlno":"32","setname":"ＴＭＰ自動設定警報限界下限","elemkey":"dev-A-0131","datapattern":"1","defaultvalue":"-30","level1":"war","level2":"dev","level3":"A","level4":"131"},
    {"ctlno":"33","setname":"ＴＭＰ固定警報上限","elemkey":"dev-A-0132","datapattern":"1","defaultvalue":"300","level1":"war","level2":"dev","level3":"A","level4":"132"},
    {"ctlno":"34","setname":"ＴＭＰ固定警報下限","elemkey":"dev-A-0133","datapattern":"1","defaultvalue":"-30","level1":"war","level2":"dev","level3":"A","level4":"133"},
    {"ctlno":"35","setname":"ＴＭＰ自動追従警報幅上限HDF/HF","elemkey":"dev-A-0134","datapattern":"1","defaultvalue":"50","level1":"war","level2":"dev","level3":"A","level4":"134"},
    {"ctlno":"36","setname":"ＴＭＰ自動追従警報幅下限HDF/HF","elemkey":"dev-A-0135","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"135"},
    {"ctlno":"37","setname":"ＴＭＰ自動設定警報幅上限HDF/HF","elemkey":"dev-A-0136","datapattern":"1","defaultvalue":"70","level1":"war","level2":"dev","level3":"A","level4":"136"},
    {"ctlno":"38","setname":"ＴＭＰ自動設定警報幅下限HDF/HF","elemkey":"dev-A-0137","datapattern":"1","defaultvalue":"-70","level1":"war","level2":"dev","level3":"A","level4":"137"},
    {"ctlno":"39","setname":"ＴＭＰ自動追従警報幅上限ＳＮ","elemkey":"dev-A-0138","datapattern":"1","defaultvalue":"50","level1":"war","level2":"dev","level3":"A","level4":"138"},
    {"ctlno":"40","setname":"ＴＭＰ自動追従警報幅下限ＳＮ","elemkey":"dev-A-0139","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"139"},
    {"ctlno":"41","setname":"ＴＭＰ自動設定警報幅上限ＳＮ","elemkey":"dev-A-0140","datapattern":"1","defaultvalue":"70","level1":"war","level2":"dev","level3":"A","level4":"140"},
    {"ctlno":"42","setname":"ＴＭＰ自動設定警報幅下限ＳＮ","elemkey":"dev-A-0141","datapattern":"1","defaultvalue":"-70","level1":"war","level2":"dev","level3":"A","level4":"141"},
    {"ctlno":"43","setname":"ＴＭＰ自動設定警報限界上限ＳＮ","elemkey":"dev-A-0142","datapattern":"1","defaultvalue":"500","level1":"war","level2":"dev","level3":"A","level4":"142"},
    {"ctlno":"44","setname":"ＴＭＰ自動設定警報限界下限ＳＮ","elemkey":"dev-A-0143","datapattern":"1","defaultvalue":"-30","level1":"war","level2":"dev","level3":"A","level4":"143"},
    {"ctlno":"45","setname":"ＴＭＰ固定警報上限ＳＮ","elemkey":"dev-A-0144","datapattern":"1","defaultvalue":"500","level1":"war","level2":"dev","level3":"A","level4":"144"},
    {"ctlno":"46","setname":"ＴＭＰ固定警報下限ＳＮ","elemkey":"dev-A-0145","datapattern":"1","defaultvalue":"-30","level1":"war","level2":"dev","level3":"A","level4":"145"},
    {"ctlno":"47","setname":"ダイアライザー差圧自動設定警報幅上限HD/ECUM","elemkey":"dev-A-0146","datapattern":"1","defaultvalue":"250","level1":"war","level2":"dev","level3":"A","level4":"146"},
    {"ctlno":"48","setname":"ダイアライザー差圧自動設定警報幅下限HD/ECUM","elemkey":"dev-A-0147","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"147"},
    {"ctlno":"49","setname":"ダイアライザー差圧固定警報上限","elemkey":"dev-A-0148","datapattern":"1","defaultvalue":"250","level1":"war","level2":"dev","level3":"A","level4":"148"},
    {"ctlno":"50","setname":"ダイアライザー差圧固定警報下限","elemkey":"dev-A-0149","datapattern":"1","defaultvalue":"0","level1":"war","level2":"dev","level3":"A","level4":"149"},
    {"ctlno":"51","setname":"ダイアライザー差圧自動設定警報幅上限HDF/HF","elemkey":"dev-A-0150","datapattern":"1","defaultvalue":"200","level1":"war","level2":"dev","level3":"A","level4":"150"},
    {"ctlno":"52","setname":"ダイアライザー差圧自動設定警報幅下限HDF/HF","elemkey":"dev-A-0151","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"151"},
    {"ctlno":"53","setname":"ダイアライザー入口圧自動設定警報幅上限HD/ECUM","elemkey":"dev-A-0152","datapattern":"1","defaultvalue":"50","level1":"war","level2":"dev","level3":"A","level4":"152"},
    {"ctlno":"54","setname":"ダイアライザー入口圧自動設定警報幅下限HD/ECUM","elemkey":"dev-A-0153","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"153"},
    {"ctlno":"55","setname":"ダイアライザー入口圧自動設定警報限界上限","elemkey":"dev-A-0154","datapattern":"1","defaultvalue":"350","level1":"war","level2":"dev","level3":"A","level4":"154"},
    {"ctlno":"56","setname":"ダイアライザー入口圧自動設定警報限界下限","elemkey":"dev-A-0155","datapattern":"1","defaultvalue":"0","level1":"war","level2":"dev","level3":"A","level4":"155"},
    {"ctlno":"57","setname":"ダイアライザー入口圧固定警報上限","elemkey":"dev-A-0156","datapattern":"1","defaultvalue":"350","level1":"war","level2":"dev","level3":"A","level4":"156"},
    {"ctlno":"58","setname":"ダイアライザー入口圧固定警報下限","elemkey":"dev-A-0157","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"157"},
    {"ctlno":"59","setname":"ダイアライザー入口圧自動設定警報幅上限HDF/HF","elemkey":"dev-A-0158","datapattern":"1","defaultvalue":"70","level1":"war","level2":"dev","level3":"A","level4":"158"},
    {"ctlno":"60","setname":"ダイアライザー入口圧自動設定警報幅下限HDF/HF","elemkey":"dev-A-0159","datapattern":"1","defaultvalue":"-70","level1":"war","level2":"dev","level3":"A","level4":"159"},
    {"ctlno":"61","setname":"ダイアライザー入口圧固定警報上限準備回収","elemkey":"dev-A-0160","datapattern":"1","defaultvalue":"400","level1":"war","level2":"dev","level3":"A","level4":"160"},
    {"ctlno":"62","setname":"ダイアライザー入口圧固定警報下限準備回収","elemkey":"dev-A-0161","datapattern":"1","defaultvalue":"-200","level1":"war","level2":"dev","level3":"A","level4":"161"},
    {"ctlno":"63","setname":"ダイアライザー入口圧固定警報上限ＳＮ","elemkey":"dev-A-0162","datapattern":"1","defaultvalue":"500","level1":"war","level2":"dev","level3":"A","level4":"162"},
    {"ctlno":"64","setname":"ダイアライザー入口圧固定警報下限ＳＮ","elemkey":"dev-A-0163","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"163"},
    {"ctlno":"69","setname":"ＴＭＰゼロ補正警報上限HD","elemkey":"dev-A-0168","datapattern":"1","defaultvalue":"50","level1":"ope","level2":"dev","level3":"A","level4":"168"},
    {"ctlno":"70","setname":"ＴＭＰゼロ補正警報下限HD","elemkey":"dev-A-0169","datapattern":"1","defaultvalue":"-50","level1":"ope","level2":"dev","level3":"A","level4":"169"},
    {"ctlno":"72","setname":"ＴＭＰゼロ補正警報上限ECUM","elemkey":"dev-A-0171","datapattern":"1","defaultvalue":"50","level1":"ope","level2":"dev","level3":"A","level4":"171"},
    {"ctlno":"73","setname":"ＴＭＰゼロ補正警報下限ECUM","elemkey":"dev-A-0172","datapattern":"1","defaultvalue":"-50","level1":"ope","level2":"dev","level3":"A","level4":"172"},
    {"ctlno":"75","setname":"ＴＭＰゼロ補正警報上限HDF","elemkey":"dev-A-0174","datapattern":"1","defaultvalue":"50","level1":"ope","level2":"dev","level3":"A","level4":"174"},
    {"ctlno":"76","setname":"ＴＭＰゼロ補正警報下限HDF","elemkey":"dev-A-0175","datapattern":"1","defaultvalue":"-50","level1":"ope","level2":"dev","level3":"A","level4":"175"},
    {"ctlno":"78","setname":"ＴＭＰゼロ補正警報上限HF","elemkey":"dev-A-0177","datapattern":"1","defaultvalue":"50","level1":"ope","level2":"dev","level3":"A","level4":"177"},
    {"ctlno":"79","setname":"ＴＭＰゼロ補正警報下限HF","elemkey":"dev-A-0178","datapattern":"1","defaultvalue":"-50","level1":"ope","level2":"dev","level3":"A","level4":"178"},
    {"ctlno":"80","setname":"血流量操作範囲上限","elemkey":"dev-A-0179","datapattern":"1","defaultvalue":"300","level1":"ope","level2":"dev","level3":"A","level4":"179"},
    {"ctlno":"82","setname":"除水速度操作範囲上限","elemkey":"dev-A-0181","datapattern":"1","defaultvalue":"2","level1":"ope","level2":"dev","level3":"A","level4":"181"},
    {"ctlno":"83","setname":"透析液温度操作範囲上限","elemkey":"dev-A-0182","datapattern":"1","defaultvalue":"40","level1":"ope","level2":"dev","level3":"A","level4":"182"},
    {"ctlno":"84","setname":"透析液温度操作範囲下限","elemkey":"dev-A-0183","datapattern":"1","defaultvalue":"33","level1":"ope","level2":"dev","level3":"A","level4":"183"},
    {"ctlno":"86","setname":"前補液 補液速度操作範囲上限(HDF)","elemkey":"dev-A-0185","datapattern":"1","defaultvalue":"6","level1":"ope","level2":"dev","level3":"A","level4":"185"},
    {"ctlno":"87","setname":"前補液 補液速度操作範囲上限(HF)","elemkey":"dev-A-0186","datapattern":"1","defaultvalue":"6","level1":"ope","level2":"dev","level3":"A","level4":"186"},
    {"ctlno":"88","setname":"血圧自動測定間隔","elemkey":"dev-A-0190","datapattern":"1","defaultvalue":"30","level1":"bp","level2":"dev","level3":"A","level4":"190"},
    {"ctlno":"89","setname":"血圧ｶﾌ選択","elemkey":"dev-A-0191","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"191"},
    {"ctlno":"90","setname":"昇圧値","elemkey":"dev-A-0192","datapattern":"1","defaultvalue":"200","level1":"bp","level2":"dev","level3":"A","level4":"192"},
    {"ctlno":"91","setname":"昇圧方法選択","elemkey":"dev-A-0193","datapattern":"1","defaultvalue":"1","level1":"bp","level2":"dev","level3":"A","level4":"193"},
    {"ctlno":"92","setname":"血圧連続測定動作選択","elemkey":"dev-A-0194","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"194"},
    {"ctlno":"93","setname":"最高血圧上限","elemkey":"dev-A-0211","datapattern":"1","defaultvalue":"200","level1":"bp","level2":"dev","level3":"A","level4":"211"},
    {"ctlno":"94","setname":"最高血圧下限","elemkey":"dev-A-0212","datapattern":"1","defaultvalue":"80","level1":"bp","level2":"dev","level3":"A","level4":"212"},
    {"ctlno":"95","setname":"最低血圧上限","elemkey":"dev-A-0213","datapattern":"1","defaultvalue":"160","level1":"bp","level2":"dev","level3":"A","level4":"213"},
    {"ctlno":"96","setname":"最低血圧下限","elemkey":"dev-A-0214","datapattern":"1","defaultvalue":"50","level1":"bp","level2":"dev","level3":"A","level4":"214"},
    {"ctlno":"97","setname":"平均血圧上限","elemkey":"dev-A-0215","datapattern":"1","defaultvalue":"180","level1":"bp","level2":"dev","level3":"A","level4":"215"},
    {"ctlno":"98","setname":"平均血圧下限","elemkey":"dev-A-0216","datapattern":"1","defaultvalue":"60","level1":"bp","level2":"dev","level3":"A","level4":"216"},
    {"ctlno":"99","setname":"脈拍数上限","elemkey":"dev-A-0217","datapattern":"1","defaultvalue":"170","level1":"bp","level2":"dev","level3":"A","level4":"217"},
    {"ctlno":"100","setname":"脈拍数下限","elemkey":"dev-A-0218","datapattern":"1","defaultvalue":"50","level1":"bp","level2":"dev","level3":"A","level4":"218"},
    {"ctlno":"101","setname":"最高血圧上限警報 BP 動作選択","elemkey":"dev-A-0219","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"219"},
    {"ctlno":"102","setname":"最高血圧下限警報 BP 動作選択","elemkey":"dev-A-0220","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"220"},
    {"ctlno":"103","setname":"最高血圧上限警報 除水 動作選択","elemkey":"dev-A-0221","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"221"},
    {"ctlno":"104","setname":"最高血圧下限警報 除水 動作選択","elemkey":"dev-A-0222","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"222"},
    {"ctlno":"105","setname":"最高血圧上限警報 Na注入 動作選択","elemkey":"dev-A-0223","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"223"},
    {"ctlno":"106","setname":"最高血圧下限警報 Na注入 動作選択","elemkey":"dev-A-0224","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"224"},
    {"ctlno":"107","setname":"最高血圧上限警報 補液 動作選択","elemkey":"dev-A-0225","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"225"},
    {"ctlno":"108","setname":"最高血圧下限警報 補液 動作選択","elemkey":"dev-A-0226","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"226"},
    {"ctlno":"109","setname":"最高血圧上限警報 BP 速度","elemkey":"dev-A-0227","datapattern":"1","defaultvalue":"100","level1":"bp","level2":"dev","level3":"A","level4":"227"},
    {"ctlno":"110","setname":"最高血圧下限警報 BP 速度","elemkey":"dev-A-0228","datapattern":"1","defaultvalue":"100","level1":"bp","level2":"dev","level3":"A","level4":"228"},
    {"ctlno":"111","setname":"最高血圧上限警報 除水 速度","elemkey":"dev-A-0229","datapattern":"1","defaultvalue":"0.1","level1":"bp","level2":"dev","level3":"A","level4":"229"},
    {"ctlno":"112","setname":"最高血圧下限警報 除水 速度","elemkey":"dev-A-0230","datapattern":"1","defaultvalue":"0.1","level1":"bp","level2":"dev","level3":"A","level4":"230"},
    {"ctlno":"113","setname":"最高血圧上限警報 Na注入 速度","elemkey":"dev-A-0231","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"231"},
    {"ctlno":"114","setname":"最高血圧下限警報 Na注入 速度","elemkey":"dev-A-0232","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"232"},
    {"ctlno":"115","setname":"最高血圧上限警報 補液 速度","elemkey":"dev-A-0233","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"233"},
    {"ctlno":"116","setname":"最高血圧下限警報 補液 速度","elemkey":"dev-A-0234","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"234"},
    {"ctlno":"117","setname":"警報連動測定開始時刻","elemkey":"dev-A-0235","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"235"},
    {"ctlno":"118","setname":"治療条件連動測定時刻","elemkey":"dev-A-0236","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"236"},
    {"ctlno":"119","setname":"血圧測定自動停止(警報発生)","elemkey":"dev-A-0237","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"237"},
    {"ctlno":"120","setname":"血圧測定自動停止(条件変更)","elemkey":"dev-A-0238","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"238"},
    {"ctlno":"121","setname":"高速測定選択","elemkey":"dev-A-0239","datapattern":"1","defaultvalue":"1","level1":"bp","level2":"dev","level3":"A","level4":"239"},
    {"ctlno":"122","setname":"ＴＭＰ監視モード","elemkey":"dev-A-0240","datapattern":"1","defaultvalue":"0","level1":"war","level2":"dev","level3":"A","level4":"240"},
    {"ctlno":"123","setname":"ＴＭＰゼロ補正の選択","elemkey":"dev-A-0241","datapattern":"1","defaultvalue":"0","level1":"ope","level2":"dev","level3":"A","level4":"241"},
    {"ctlno":"124","setname":"静脈圧自動設定警報監視有無","elemkey":"dev-A-0242","datapattern":"1","defaultvalue":"1","level1":"war","level2":"dev","level3":"A","level4":"242"},
    {"ctlno":"125","setname":"ダイアライザー血液入口圧自動設定警報監視有無","elemkey":"dev-A-0243","datapattern":"1","defaultvalue":"1","level1":"war","level2":"dev","level3":"A","level4":"243"},
    {"ctlno":"126","setname":"透析液圧自動設定警報監視有無","elemkey":"dev-A-0244","datapattern":"1","defaultvalue":"1","level1":"war","level2":"dev","level3":"A","level4":"244"},
    {"ctlno":"127","setname":"ＴＭＰ自動設定警報監視有無","elemkey":"dev-A-0245","datapattern":"1","defaultvalue":"1","level1":"war","level2":"dev","level3":"A","level4":"245"},
    {"ctlno":"128","setname":"差圧自動設定警報監視有無","elemkey":"dev-A-0246","datapattern":"1","defaultvalue":"1","level1":"war","level2":"dev","level3":"A","level4":"246"},
    {"ctlno":"129","setname":"Ｎａ濃度自動設定警報監視有無","elemkey":"dev-A-0247","datapattern":"1","defaultvalue":"1","level1":"war","level2":"dev","level3":"A","level4":"247"},
    {"ctlno":"130","setname":"透析液濃度プログラム自動設定警報幅上限","elemkey":"dev-A-0250","datapattern":"1","defaultvalue":"5","level1":"cpro","level2":"dev","level3":"A","level4":"250"},
    {"ctlno":"131","setname":"透析液濃度プログラム自動設定警報幅下限","elemkey":"dev-A-0251","datapattern":"1","defaultvalue":"-5","level1":"cpro","level2":"dev","level3":"A","level4":"251"},
    {"ctlno":"132","setname":"Ｂ液濃度プログラム自動設定警報幅上限","elemkey":"dev-A-0252","datapattern":"1","defaultvalue":"5","level1":"cpro","level2":"dev","level3":"A","level4":"252"},
    {"ctlno":"133","setname":"Ｂ液濃度プログラム自動設定警報幅下限","elemkey":"dev-A-0253","datapattern":"1","defaultvalue":"-5","level1":"cpro","level2":"dev","level3":"A","level4":"253"},
    {"ctlno":"134","setname":"Ｎａ濃度自動設定警報幅上限","elemkey":"dev-A-0254","datapattern":"1","defaultvalue":"5","level1":"war","level2":"dev","level3":"A","level4":"254"},
    {"ctlno":"135","setname":"Ｎａ濃度自動設定警報幅下限","elemkey":"dev-A-0255","datapattern":"1","defaultvalue":"-5","level1":"war","level2":"dev","level3":"A","level4":"255"},
    {"ctlno":"136","setname":"Ｎａ濃度固定警報上限","elemkey":"dev-A-0256","datapattern":"1","defaultvalue":"190","level1":"war","level2":"dev","level3":"A","level4":"256"},
    {"ctlno":"137","setname":"Ｎａ濃度固定警報下限","elemkey":"dev-A-0257","datapattern":"1","defaultvalue":"120","level1":"war","level2":"dev","level3":"A","level4":"257"},
    {"ctlno":"138","setname":"アクセス再循環測定使用選択","elemkey":"dev-A-0258","datapattern":"1","defaultvalue":"0","level1":"bv","level2":"dev","level3":"A","level4":"258"},
    {"ctlno":"139","setname":"自動測定1","elemkey":"dev-A-0259","datapattern":"1","defaultvalue":"0","level1":"bv","level2":"dev","level3":"A","level4":"259"},
    {"ctlno":"140","setname":"⊿ＢＶ低下警報点１","elemkey":"dev-A-0260","datapattern":"1","defaultvalue":"-10","level1":"bv","level2":"dev","level3":"A","level4":"260"},
    {"ctlno":"141","setname":"⊿ＢＶ低下警報点２","elemkey":"dev-A-0261","datapattern":"1","defaultvalue":"-25","level1":"bv","level2":"dev","level3":"A","level4":"261"},
    {"ctlno":"142","setname":"⊿BV変化率警報点","elemkey":"dev-A-0262","datapattern":"1","defaultvalue":"-3","level1":"bv","level2":"dev","level3":"A","level4":"262"},
    {"ctlno":"143","setname":"ブラッドボリューム計使用の選択","elemkey":"dev-A-0267","datapattern":"1","defaultvalue":"1","level1":"bv","level2":"dev","level3":"A","level4":"267"},
    {"ctlno":"144","setname":"⊿ＢＶ除水低下速度","elemkey":"dev-A-0277","datapattern":"1","defaultvalue":"0","level1":"bv","level2":"dev","level3":"A","level4":"277"},
    {"ctlno":"145","setname":"⊿ＢＶ除水低下遅延時間","elemkey":"dev-A-0278","datapattern":"1","defaultvalue":"5","level1":"bv","level2":"dev","level3":"A","level4":"278"},
    {"ctlno":"146","setname":"再循環率報知","elemkey":"dev-A-0281","datapattern":"1","defaultvalue":"0","level1":"bv","level2":"dev","level3":"A","level4":"281"},
    {"ctlno":"185","setname":"同時脱血 脱血量","elemkey":"dev-A-0331","datapattern":"1","defaultvalue":"150","level1":"dfas","level2":"dev","level3":"A","level4":"331"},
    {"ctlno":"186","setname":"片側脱血への切替え透析液圧","elemkey":"dev-A-0332","datapattern":"1","defaultvalue":"-200","level1":"dfas","level2":"dev","level3":"A","level4":"332"},
    {"ctlno":"187","setname":"脱血速度","elemkey":"dev-A-0333","datapattern":"1","defaultvalue":"100","level1":"dfas","level2":"dev","level3":"A","level4":"333"},
    {"ctlno":"188","setname":"片側脱血(除水なし) 脱血量","elemkey":"dev-A-0334","datapattern":"1","defaultvalue":"150","level1":"dfas","level2":"dev","level3":"A","level4":"334"},
    {"ctlno":"190","setname":"補液速度","elemkey":"dev-A-0336","datapattern":"1","defaultvalue":"100","level1":"ope","level2":"dev","level3":"A","level4":"336"},
    {"ctlno":"191","setname":"補液量","elemkey":"dev-A-0337","datapattern":"1","defaultvalue":"100","level1":"ope","level2":"dev","level3":"A","level4":"337"},
    {"ctlno":"192","setname":"片側脱血(除水あり) 脱血量","elemkey":"dev-A-0338","datapattern":"1","defaultvalue":"50","level1":"dfas","level2":"dev","level3":"A","level4":"338"},
    {"ctlno":"193","setname":"脱血方法選択","elemkey":"dev-A-0339","datapattern":"1","defaultvalue":"2","level1":"dfas","level2":"dev","level3":"A","level4":"339"},
    {"ctlno":"223","setname":"自動回収 使用液量","elemkey":"dev-A-0370","datapattern":"1","defaultvalue":"200","level1":"pri","level2":"dev","level3":"A","level4":"370"},
    {"ctlno":"224","setname":"自動回収 流速","elemkey":"dev-A-0371","datapattern":"1","defaultvalue":"100","level1":"pri","level2":"dev","level3":"A","level4":"371"},
    {"ctlno":"225","setname":"自動回収 血液判別器による終了選択","elemkey":"dev-A-0372","datapattern":"1","defaultvalue":"0","level1":"pri","level2":"dev","level3":"A","level4":"372"},
    {"ctlno":"226","setname":"静脈側返血速度","elemkey":"dev-A-0373","datapattern":"1","defaultvalue":"100","level1":"dfas","level2":"dev","level3":"A","level4":"373"},
    {"ctlno":"227","setname":"静脈側最大返血量","elemkey":"dev-A-0374","datapattern":"1","defaultvalue":"250","level1":"dfas","level2":"dev","level3":"A","level4":"374"},
    {"ctlno":"228","setname":"動脈側最大返血量","elemkey":"dev-A-0376","datapattern":"1","defaultvalue":"30","level1":"dfas","level2":"dev","level3":"A","level4":"376"},
    {"ctlno":"229","setname":"静脈側返血 血液判別器使用選択","elemkey":"dev-A-0377","datapattern":"1","defaultvalue":"0","level1":"dfas","level2":"dev","level3":"A","level4":"377"},
    {"ctlno":"230","setname":"動脈側返血 血液判別器使用選択","elemkey":"dev-A-0378","datapattern":"1","defaultvalue":"0","level1":"dfas","level2":"dev","level3":"A","level4":"378"},
    {"ctlno":"234","setname":"補液量設定値制限(OHDF・OHF用)","elemkey":"dev-A-0383","datapattern":"1","defaultvalue":"1","level1":"ope","level2":"dev","level3":"A","level4":"383"},
    {"ctlno":"235","setname":"AFBF 補液比率使用選択","elemkey":"dev-A-0384","datapattern":"1","defaultvalue":"1","level1":"ope","level2":"dev","level3":"A","level4":"384"},
    {"ctlno":"236","setname":"AFBF 補液比率","elemkey":"dev-A-0385","datapattern":"1","defaultvalue":"13","level1":"ope","level2":"dev","level3":"A","level4":"385"},
    {"ctlno":"237","setname":"補液速度設定範囲上限(AFBF)","elemkey":"dev-A-0386","datapattern":"1","defaultvalue":"2.5","level1":"ope","level2":"dev","level3":"A","level4":"386"},
    {"ctlno":"238","setname":"補液速度設定範囲下限(AFBF)","elemkey":"dev-A-0387","datapattern":"1","defaultvalue":"1","level1":"ope","level2":"dev","level3":"A","level4":"387"},
    {"ctlno":"240","setname":"OHDF/OHF補液計算優先項目選択","elemkey":"dev-A-0389","datapattern":"1","defaultvalue":"0","level1":"ope","level2":"dev","level3":"A","level4":"389"},
    {"ctlno":"242","setname":"ＴＭＰゼロ補正警報上限OHDF","elemkey":"dev-A-0391","datapattern":"1","defaultvalue":"50","level1":"ope","level2":"dev","level3":"A","level4":"391"},
    {"ctlno":"243","setname":"ＴＭＰゼロ補正警報下限OHDF","elemkey":"dev-A-0392","datapattern":"1","defaultvalue":"-50","level1":"ope","level2":"dev","level3":"A","level4":"392"},
    {"ctlno":"245","setname":"ＴＭＰゼロ補正警報上限OHF","elemkey":"dev-A-0394","datapattern":"1","defaultvalue":"50","level1":"ope","level2":"dev","level3":"A","level4":"394"},
    {"ctlno":"246","setname":"ＴＭＰゼロ補正警報下限OHF","elemkey":"dev-A-0395","datapattern":"1","defaultvalue":"-50","level1":"ope","level2":"dev","level3":"A","level4":"395"},
    {"ctlno":"247","setname":"前補液 補液速度操作範囲上限(OHDF)","elemkey":"dev-A-0396","datapattern":"1","defaultvalue":"12","level1":"ope","level2":"dev","level3":"A","level4":"396"},
    {"ctlno":"248","setname":"前補液 補液速度操作範囲上限(OHF)","elemkey":"dev-A-0397","datapattern":"1","defaultvalue":"12","level1":"ope","level2":"dev","level3":"A","level4":"397"},
    {"ctlno":"249","setname":"補液開始遅延時間","elemkey":"dev-A-0398","datapattern":"1","defaultvalue":"0","level1":"ope","level2":"dev","level3":"A","level4":"398"},
    {"ctlno":"280","setname":"前補液 補液速度操作範囲上限(HD+補液)","elemkey":"dev-B-0030","datapattern":"1","defaultvalue":"12","level1":"ope","level2":"dev","level3":"B","level4":"030"},
    {"ctlno":"281","setname":"後補液 補液速度操作範囲上限(HDF)","elemkey":"dev-B-0031","datapattern":"1","defaultvalue":"6","level1":"ope","level2":"dev","level3":"B","level4":"031"},
    {"ctlno":"282","setname":"後補液 補液速度操作範囲上限(HF)","elemkey":"dev-B-0032","datapattern":"1","defaultvalue":"6","level1":"ope","level2":"dev","level3":"B","level4":"032"},
    {"ctlno":"283","setname":"後補液 補液速度操作範囲上限(HD+補液)","elemkey":"dev-B-0033","datapattern":"1","defaultvalue":"6","level1":"ope","level2":"dev","level3":"B","level4":"033"},
    {"ctlno":"284","setname":"後補液 補液速度操作範囲上限(OHDF)","elemkey":"dev-B-0034","datapattern":"1","defaultvalue":"6","level1":"ope","level2":"dev","level3":"B","level4":"034"},
    {"ctlno":"285","setname":"後補液 補液速度操作範囲上限(OHF)","elemkey":"dev-B-0035","datapattern":"1","defaultvalue":"6","level1":"ope","level2":"dev","level3":"B","level4":"035"},
    {"ctlno":"286","setname":"治療開始時血流量使用有無","elemkey":"dev-B-0036","datapattern":"1","defaultvalue":"1","level1":"dfas","level2":"dev","level3":"B","level4":"036"},
    {"ctlno":"287","setname":"ＴＭＰゼロ補正警報上限(HD+補液)","elemkey":"dev-B-0037","datapattern":"1","defaultvalue":"50","level1":"ope","level2":"dev","level3":"B","level4":"037"},
    {"ctlno":"288","setname":"ＴＭＰゼロ補正警報下限(HD+補液)","elemkey":"dev-B-0038","datapattern":"1","defaultvalue":"-50","level1":"ope","level2":"dev","level3":"B","level4":"038"},
    {"ctlno":"289","setname":"プライミング補助動脈充填液量","elemkey":"pat-A-0219","datapattern":"1","defaultvalue":"200","level1":"pri","level2":"pat","level3":"A","level4":"219"},
    {"ctlno":"290","setname":"プライミング補助動脈充填流速","elemkey":"pat-A-0220","datapattern":"1","defaultvalue":"100","level1":"pri","level2":"pat","level3":"A","level4":"220"},
    {"ctlno":"291","setname":"プライミング補助静脈充填液量","elemkey":"pat-A-0221","datapattern":"1","defaultvalue":"200","level1":"pri","level2":"pat","level3":"A","level4":"221"},
    {"ctlno":"292","setname":"プライミング補助静脈充填流速","elemkey":"pat-A-0222","datapattern":"1","defaultvalue":"100","level1":"pri","level2":"pat","level3":"A","level4":"222"},
    {"ctlno":"293","setname":"プライミング補助気泡抜き液量","elemkey":"pat-A-0223","datapattern":"1","defaultvalue":"400","level1":"pri","level2":"pat","level3":"A","level4":"223"},
    {"ctlno":"294","setname":"プライミング補助気泡抜き流速","elemkey":"pat-A-0224","datapattern":"1","defaultvalue":"300","level1":"pri","level2":"pat","level3":"A","level4":"224"},
    {"ctlno":"295","setname":"プライミング補助動脈充填後継続の有無","elemkey":"pat-A-0225","datapattern":"1","defaultvalue":"0","level1":"pri","level2":"pat","level3":"A","level4":"225"},
    {"ctlno":"296","setname":"プライミング補助静脈充填後継続の有無","elemkey":"pat-A-0226","datapattern":"1","defaultvalue":"0","level1":"pri","level2":"pat","level3":"A","level4":"226"},
    {"ctlno":"297","setname":"プライミング補助気泡抜き間欠動作選択","elemkey":"pat-A-0227","datapattern":"1","defaultvalue":"0","level1":"pri","level2":"pat","level3":"A","level4":"227"},
    {"ctlno":"298","setname":"プライミング補助液交換量","elemkey":"pat-A-0228","datapattern":"1","defaultvalue":"800","level1":"pri","level2":"pat","level3":"A","level4":"228"},
    {"ctlno":"299","setname":"プライミング補助間欠動作動作時間","elemkey":"pat-A-0229","datapattern":"1","defaultvalue":"2","level1":"pri","level2":"pat","level3":"A","level4":"229"},
    {"ctlno":"300","setname":"プライミング補助間欠動作停止時間","elemkey":"pat-A-0230","datapattern":"1","defaultvalue":"1","level1":"pri","level2":"pat","level3":"A","level4":"230"},
    {"ctlno":"301","setname":"自動プライミング開始時間","elemkey":"pat-A-0231","datapattern":"1","defaultvalue":"420","level1":"pri","level2":"pat","level3":"A","level4":"231"},
    {"ctlno":"302","setname":"自動プライミング落差時間","elemkey":"pat-A-0232","datapattern":"1","defaultvalue":"40","level1":"pri","level2":"pat","level3":"A","level4":"232"},
    {"ctlno":"303","setname":"自動プライミング送液液量","elemkey":"pat-A-0233","datapattern":"1","defaultvalue":"250","level1":"pri","level2":"pat","level3":"A","level4":"233"},
    {"ctlno":"304","setname":"自動プライミング送液流速1回目","elemkey":"pat-A-0234","datapattern":"1","defaultvalue":"250","level1":"pri","level2":"pat","level3":"A","level4":"234"},
    {"ctlno":"305","setname":"自動プライミング送液流速2回目以降","elemkey":"pat-A-0235","datapattern":"1","defaultvalue":"250","level1":"pri","level2":"pat","level3":"A","level4":"235"},
    {"ctlno":"306","setname":"自動プライミング循環流速","elemkey":"pat-A-0236","datapattern":"1","defaultvalue":"400","level1":"pri","level2":"pat","level3":"A","level4":"236"},
    {"ctlno":"307","setname":"自動プライミング循環時間","elemkey":"pat-A-0237","datapattern":"1","defaultvalue":"300","level1":"pri","level2":"pat","level3":"A","level4":"237"},
    {"ctlno":"308","setname":"自動プライミング総量","elemkey":"pat-A-0238","datapattern":"1","defaultvalue":"600","level1":"pri","level2":"pat","level3":"A","level4":"238"},
    {"ctlno":"310","setname":"IPラインプライミング使用選択","elemkey":"pat-B-0001","datapattern":"1","defaultvalue":"1","level1":"dfas","level2":"pat","level3":"B","level4":"001"},
    {"ctlno":"311","setname":"中空糸 プライミング時のBP速度","elemkey":"pat-B-0005","datapattern":"1","defaultvalue":"300","level1":"dfas","level2":"pat","level3":"B","level4":"005"},
    {"ctlno":"312","setname":"中空糸 送液最大時間","elemkey":"pat-B-0007","datapattern":"1","defaultvalue":"60","level1":"dfas","level2":"pat","level3":"B","level4":"007"},
    {"ctlno":"313","setname":"中空糸 回路内洗浄送液量","elemkey":"pat-B-0008","datapattern":"1","defaultvalue":"200","level1":"dfas","level2":"pat","level3":"B","level4":"008"},
    {"ctlno":"314","setname":"中空糸 気泡抜き動作実行回数","elemkey":"pat-B-0009","datapattern":"1","defaultvalue":"0","level1":"dfas","level2":"pat","level3":"B","level4":"009"},
    {"ctlno":"315","setname":"中空糸 気泡抜き圧力上限","elemkey":"pat-B-0010","datapattern":"1","defaultvalue":"150","level1":"dfas","level2":"pat","level3":"B","level4":"010"},
    {"ctlno":"317","setname":"補液選択","elemkey":"dev-B-0030","datapattern":"1","defaultvalue":null,"level1":"ope","level2":"dev","level3":"B","level4":"030"},
    {"ctlno":"318","setname":"前補液 ダイアライザー気泡抜き時間","elemkey":"dev-B-0031","datapattern":"1","defaultvalue":"2","level1":"ope","level2":"dev","level3":"B","level4":"031"},
    {"ctlno":"319","setname":"前補液 動脈チャンバ液面作成時間","elemkey":"pat-B-0032","datapattern":"1","defaultvalue":"90","level1":"pri","level2":"pat","level3":"B","level4":"032"},
    {"ctlno":"320","setname":"前補液 循環洗浄時間","elemkey":"pat-B-0033","datapattern":"1","defaultvalue":"3","level1":"pri","level2":"pat","level3":"B","level4":"033"},
    {"ctlno":"321","setname":"治療モード","elemkey":"dev-B-0034","datapattern":"1","defaultvalue":null,"level1":"ope","level2":"dev","level3":"B","level4":"034"},
    {"ctlno":"322","setname":"後補液 ダイアライザー気泡抜き時間","elemkey":"pat-B-0051","datapattern":"1","defaultvalue":"2","level1":"pri","level2":"pat","level3":"B","level4":"051"},
    {"ctlno":"323","setname":"後補液 動脈チャンバ液面作成時間","elemkey":"pat-B-0052","datapattern":"1","defaultvalue":"60","level1":"pri","level2":"pat","level3":"B","level4":"052"},
    {"ctlno":"324","setname":"後補液 循環洗浄時間","elemkey":"pat-B-0053","datapattern":"1","defaultvalue":"3","level1":"pri","level2":"pat","level3":"B","level4":"053"},
    {"ctlno":"325","setname":"積層 送液最大時間","elemkey":"pat-B-0054","datapattern":"1","defaultvalue":"60","level1":"dfas","level2":"pat","level3":"B","level4":"054"},
    {"ctlno":"326","setname":"積層 回路内洗浄送液量","elemkey":"pat-B-0055","datapattern":"1","defaultvalue":"200","level1":"dfas","level2":"pat","level3":"B","level4":"055"},
    {"ctlno":"327","setname":"積層 気泡抜き動作実行回数","elemkey":"pat-B-0056","datapattern":"1","defaultvalue":"0","level1":"dfas","level2":"pat","level3":"B","level4":"056"},
    {"ctlno":"328","setname":"積層 気泡抜き圧力上限","elemkey":"pat-B-0057","datapattern":"1","defaultvalue":"150","level1":"dfas","level2":"pat","level3":"B","level4":"057"},
    {"ctlno":"329","setname":"積層 除水ポンプ速度","elemkey":"pat-B-0058","datapattern":"1","defaultvalue":"0.2","level1":"dfas","level2":"pat","level3":"B","level4":"058"},
    {"ctlno":"330","setname":"積層 プライミング時のBP速度","elemkey":"pat-B-0059","datapattern":"1","defaultvalue":"150","level1":"dfas","level2":"pat","level3":"B","level4":"059"},
    {"ctlno":"331","setname":"DP=Qd+Qs(補液速度加算)","elemkey":"dev-A-0369","datapattern":"1","defaultvalue":"1","level1":"ope","level2":"dev","level3":"A","level4":"369"},
    {"ctlno":"332","setname":"前補液　OHDF/OHF　補液速度比率","elemkey":"dev-A-0379","datapattern":"1","defaultvalue":"20","level1":"ope","level2":"dev","level3":"A","level4":"379"},
    {"ctlno":"333","setname":"後補液　OHDF/OHF　補液速度比率","elemkey":"dev-B-0039","datapattern":"1","defaultvalue":"20","level1":"ope","level2":"dev","level3":"B","level4":"039"},
    {"ctlno":"334","setname":"自動測定2","elemkey":"dev-A-0263","datapattern":"1","defaultvalue":"0","level1":"bv","level2":"dev","level3":"A","level4":"263"},
    {"ctlno":"335","setname":"自動測定3","elemkey":"dev-A-0264","datapattern":"1","defaultvalue":"0","level1":"bv","level2":"dev","level3":"A","level4":"264"},
    {"ctlno":"336","setname":"自動測定4","elemkey":"dev-A-0265","datapattern":"1","defaultvalue":"0","level1":"bv","level2":"dev","level3":"A","level4":"265"},
    {"ctlno":"337","setname":"自動測定5","elemkey":"dev-A-0266","datapattern":"1","defaultvalue":"0","level1":"bv","level2":"dev","level3":"A","level4":"266"},
    {"ctlno":"338","setname":"除水開始遅延時間","elemkey":"dev-A-0039","datapattern":"1","defaultvalue":"0","level1":"ope","level2":"dev","level3":"A","level4":"039"},
    {"ctlno":"339","setname":"動脈側返血使用選択","elemkey":"dev-A-0270","datapattern":"1","defaultvalue":"1","level1":"dfas","level2":"dev","level3":"A","level4":"270"},
    {"ctlno":"346","setname":"濾過率（前補液）","elemkey":"dev-A-0090","datapattern":"1","defaultvalue":"50","level1":"ope","level2":"dev","level3":"A","level4":"090"},
    {"ctlno":"347","setname":"ヘマトクリット（Ht）","elemkey":"dev-A-0091","datapattern":"1","defaultvalue":"33","level1":"ope","level2":"dev","level3":"A","level4":"091"},
    {"ctlno":"348","setname":"総タンパク（TP）","elemkey":"dev-A-0092","datapattern":"1","defaultvalue":"6.5","level1":"ope","level2":"dev","level3":"A","level4":"092"},
    {"ctlno":"349","setname":"血圧測定方法選択","elemkey":"dev-A-0195","datapattern":"1","defaultvalue":"1","level1":"bp","level2":"dev","level3":"A","level4":"195"},
    {"ctlno":"350","setname":"濾過率（後補液）","elemkey":"dev-B-0040","datapattern":"1","defaultvalue":"40","level1":"ope","level2":"dev","level3":"B","level4":"040"},
    {"ctlno":"362","setname":"透析液流量　設定方法","elemkey":"dev-A-0268","datapattern":"1","defaultvalue":"1","level1":"ope","level2":"dev","level3":"A","level4":"268"},
    {"ctlno":"363","setname":"透析液流量　比率設定","elemkey":"dev-A-0269","datapattern":"1","defaultvalue":"2.0","level1":"ope","level2":"dev","level3":"A","level4":"269"},
    {"ctlno":"436","setname":"VA確認報知基準値(静的静脈圧)","elemkey":"dev-A-0468","datapattern":"1","defaultvalue":"80","level1":"iap","level2":"dev","level3":"A","level4":"468"},
    {"ctlno":"437","setname":"VA確認報知基準値(IAP ratio)","elemkey":"dev-A-0469","datapattern":"1","defaultvalue":"0.5","level1":"iap","level2":"dev","level3":"A","level4":"469"},
    {"ctlno":"438","setname":"静的静脈圧記録 自動実施選択","elemkey":"dev-A-0470","datapattern":"1","defaultvalue":"1","level1":"iap","level2":"dev","level3":"A","level4":"470"},
    {"ctlno":"439","setname":"血圧測定 自動実施選択","elemkey":"dev-A-0471","datapattern":"1","defaultvalue":"0","level1":"iap","level2":"dev","level3":"A","level4":"471"},
    {"ctlno":"440","setname":"TMP閾値 速度低下","elemkey":"dev-A-0472","datapattern":"1","defaultvalue":"0","level1":"ope","level2":"dev","level3":"A","level4":"472"},
    {"ctlno":"441","setname":"TMP閾値 速度復帰","elemkey":"dev-A-0473","datapattern":"1","defaultvalue":"0","level1":"ope","level2":"dev","level3":"A","level4":"473"},
    {"ctlno":"442","setname":"速度変化率 速度低下","elemkey":"dev-A-0474","datapattern":"1","defaultvalue":"5","level1":"ope","level2":"dev","level3":"A","level4":"474"},
    {"ctlno":"443","setname":"速度変化率 速度復帰","elemkey":"dev-A-0475","datapattern":"1","defaultvalue":"5","level1":"ope","level2":"dev","level3":"A","level4":"475"},
    {"ctlno":"444","setname":"⊿SO2低下報知点","elemkey":"dev-A-0476","datapattern":"1","defaultvalue":"5","level1":"ope","level2":"dev","level3":"A","level4":"476"},
    {"ctlno":"445","setname":"条件送信時血流量","elemkey":"dev-A-0477","datapattern":"1","defaultvalue":null,"level1":"ope","level2":"dev","level3":"A","level4":"477"},
    {"ctlno":"65","setname":"初期ＵＦＲ警報上限","elemkey":"ufr_warning_max","datapattern":"4","defaultvalue":"200","level1":"ufr_warning_max","level2":"","level3":"","level4":"ufr_warning_max"},
    {"ctlno":"66","setname":"初期ＵＦＲ警報下限","elemkey":"ufr_warning_min","datapattern":"4","defaultvalue":"1","level1":"ufr_warning_min","level2":"","level3":"","level4":"ufr_warning_min"},
    {"ctlno":"67","setname":"ＵＦＲ低下警報点","elemkey":"ufr_warning_reduction","datapattern":"4","defaultvalue":"50","level1":"ufr_warning_reduction","level2":"","level3":"","level4":"ufr_warning_reduction"},
    {"ctlno":"68","setname":"ＴＭＰゼロ補正警報中点HD","elemkey":"tmp_center_hd","datapattern":"5","defaultvalue":"-30","level1":"tmp_center_hd","level2":"","level3":"","level4":"tmp_center_hd"},
    {"ctlno":"71","setname":"ＴＭＰゼロ補正警報中点ECUM","elemkey":"tmp_center_ecum","datapattern":"5","defaultvalue":"-65","level1":"tmp_center_ecum","level2":"","level3":"","level4":"tmp_center_ecum"},
    {"ctlno":"74","setname":"ＴＭＰゼロ補正警報中点HDF","elemkey":"tmp_center_hdf","datapattern":"5","defaultvalue":"-30","level1":"tmp_center_hdf","level2":"","level3":"","level4":"tmp_center_hdf"},
    {"ctlno":"77","setname":"ＴＭＰゼロ補正警報中点HF","elemkey":"tmp_center_hf","datapattern":"5","defaultvalue":"-65","level1":"tmp_center_hf","level2":"","level3":"","level4":"tmp_center_hf"},
    {"ctlno":"81","setname":"ＩＰ速度操作範囲上限","elemkey":"ind_cond_info-33-value","datapattern":"3","defaultvalue":"10","level1":"33","level2":"ind_cond_info","level3":"33","level4":"value"},
    {"ctlno":"85","setname":"Ｎａ注入濃度操作範囲上限","elemkey":"dev-A-0184","datapattern":"2","defaultvalue":"50","level1":"na","level2":"dev","level3":"A","level4":"184"},
    {"ctlno":"147","setname":"透析量プログラム使用選択","elemkey":"dev-A-0282","datapattern":"2","defaultvalue":"0","level1":"dia","level2":"dev","level3":"A","level4":"282"},
    {"ctlno":"148","setname":"体液量計算時後体重","elemkey":"calc_body_fluids_date","datapattern":"6","defaultvalue":null,"level1":"","level2":"","level3":"","level4":"calc_body_fluids_date"},
    {"ctlno":"149","setname":"体液量+補正値","elemkey":"calc_body_fluids","datapattern":"6","defaultvalue":null,"level1":"","level2":"","level3":"","level4":"calc_body_fluids"},
    {"ctlno":"150","setname":"目標後体重","elemkey":"ind_cond_info-3-value","datapattern":"3","defaultvalue":null,"level1":"3","level2":"ind_cond_info","level3":"3","level4":"value"},
    {"ctlno":"151","setname":"標準血流量","elemkey":"ind_cond_info-14-value","datapattern":"3","defaultvalue":null,"level1":"14","level2":"ind_cond_info","level3":"14","level4":"value"},
    {"ctlno":"152","setname":"KoA","elemkey":"koa","datapattern":"4","defaultvalue":null,"level1":"koa","level2":"","level3":"","level4":"koa"},
    {"ctlno":"153","setname":"目標Kt/V","elemkey":"dev-A-0288","datapattern":"2","defaultvalue":null,"level1":"dia","level2":"dev","level3":"A","level4":"288"},
    {"ctlno":"154","setname":"ＵＦＲプログラム電源ＳＷ","elemkey":"dev-A-0290","datapattern":"2","defaultvalue":"0","level1":"ufr","level2":"dev","level3":"A","level4":"290"},
    {"ctlno":"155","setname":"ＵＦＲプログラム指数１","elemkey":"dev-A-0301","datapattern":"2","defaultvalue":"200","level1":"ufr","level2":"dev","level3":"A","level4":"301"},
    {"ctlno":"156","setname":"ＵＦＲプログラム指数２","elemkey":"dev-A-0302","datapattern":"2","defaultvalue":"150","level1":"ufr","level2":"dev","level3":"A","level4":"302"},
    {"ctlno":"157","setname":"ＵＦＲプログラム指数３","elemkey":"dev-A-0303","datapattern":"2","defaultvalue":"100","level1":"ufr","level2":"dev","level3":"A","level4":"303"},
    {"ctlno":"158","setname":"ＵＦＲプログラム指数４","elemkey":"dev-A-0304","datapattern":"2","defaultvalue":"50","level1":"ufr","level2":"dev","level3":"A","level4":"304"},
    {"ctlno":"159","setname":"ＵＦＲプログラム指数５","elemkey":"dev-A-0305","datapattern":"2","defaultvalue":"0","level1":"ufr","level2":"dev","level3":"A","level4":"305"},
    {"ctlno":"160","setname":"ＵＦＲプログラム指数６","elemkey":"dev-A-0306","datapattern":"2","defaultvalue":"0","level1":"ufr","level2":"dev","level3":"A","level4":"306"},
    {"ctlno":"161","setname":"ＵＦＲプログラム指数７","elemkey":"dev-A-0307","datapattern":"2","defaultvalue":"50","level1":"ufr","level2":"dev","level3":"A","level4":"307"},
    {"ctlno":"162","setname":"ＵＦＲプログラム指数８","elemkey":"dev-A-0308","datapattern":"2","defaultvalue":"100","level1":"ufr","level2":"dev","level3":"A","level4":"308"},
    {"ctlno":"163","setname":"ＵＦＲプログラム指数９","elemkey":"dev-A-0309","datapattern":"2","defaultvalue":"150","level1":"ufr","level2":"dev","level3":"A","level4":"309"},
    {"ctlno":"164","setname":"ＵＦＲプログラム指数１０","elemkey":"dev-A-0310","datapattern":"2","defaultvalue":"200","level1":"ufr","level2":"dev","level3":"A","level4":"310"},
    {"ctlno":"165","setname":"ＵＦＲプログラム最終位置","elemkey":"dev-A-0311","datapattern":"2","defaultvalue":"10","level1":"ufr","level2":"dev","level3":"A","level4":"311"},
    {"ctlno":"166","setname":"ＵＦＲプログラムコース","elemkey":"dev-A-0312","datapattern":"2","defaultvalue":"1","level1":"ufr","level2":"dev","level3":"A","level4":"312"},
    {"ctlno":"167","setname":"ＵＦＲプログラム開始数値","elemkey":"dev-A-0313","datapattern":"2","defaultvalue":"100","level1":"ufr","level2":"dev","level3":"A","level4":"313"},
    {"ctlno":"168","setname":"ＵＦＲプログラム終了数値","elemkey":"dev-A-0314","datapattern":"2","defaultvalue":"100","level1":"ufr","level2":"dev","level3":"A","level4":"314"},
    {"ctlno":"169","setname":"Ｎａ注入プログラム電源ＳＷ","elemkey":"dev-A-0315","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"315"},
    {"ctlno":"170","setname":"Ｎａ注入プログラム設定１","elemkey":"dev-A-0316","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"316"},
    {"ctlno":"171","setname":"Ｎａ注入プログラム設定２","elemkey":"dev-A-0317","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"317"},
    {"ctlno":"172","setname":"Ｎａ注入プログラム設定３","elemkey":"dev-A-0318","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"318"},
    {"ctlno":"173","setname":"Ｎａ注入プログラム設定４","elemkey":"dev-A-0319","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"319"},
    {"ctlno":"174","setname":"Ｎａ注入プログラム設定５","elemkey":"dev-A-0320","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"320"},
    {"ctlno":"175","setname":"Ｎａ注入プログラム設定６","elemkey":"dev-A-0321","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"321"},
    {"ctlno":"176","setname":"Ｎａ注入プログラム設定７","elemkey":"dev-A-0322","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"322"},
    {"ctlno":"177","setname":"Ｎａ注入プログラム設定８","elemkey":"dev-A-0323","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"323"},
    {"ctlno":"178","setname":"Ｎａ注入プログラム設定９","elemkey":"dev-A-0324","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"324"},
    {"ctlno":"179","setname":"Ｎａ注入プログラム設定１０","elemkey":"dev-A-0325","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"325"},
    {"ctlno":"180","setname":"Ｎａ注入プログラム切替時間","elemkey":"dev-A-0326","datapattern":"2","defaultvalue":"30","level1":"na","level2":"dev","level3":"A","level4":"326"},
    {"ctlno":"181","setname":"Ｎａ注入プログラム ＵＦＲプロとの連動選択","elemkey":"dev-A-0327","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"327"},
    {"ctlno":"182","setname":"Ｎａ注入プログラムコース","elemkey":"dev-A-0328","datapattern":"2","defaultvalue":"1","level1":"na","level2":"dev","level3":"A","level4":"328"},
    {"ctlno":"183","setname":"Ｎａ注入プログラム開始数値","elemkey":"dev-A-0329","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"329"},
    {"ctlno":"184","setname":"Ｎａ注入プログラム終了数値","elemkey":"dev-A-0330","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"330"},
    {"ctlno":"189","setname":"治療開始時 血液ポンプ速度","elemkey":"ind_cond_info-14-value","datapattern":"3","defaultvalue":null,"level1":"14","level2":"ind_cond_info","level3":"14","level4":"value"},
    {"ctlno":"194","setname":"濃度プログラム電源ＳＷ","elemkey":"dev-A-0340","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"A","level4":"340"},
    {"ctlno":"195","setname":"透析液濃度プログラム設定１","elemkey":"dev-A-0341","datapattern":"2","defaultvalue":"14","level1":"dc","level2":"dev","level3":"A","level4":"341"},
    {"ctlno":"196","setname":"透析液濃度プログラム設定２","elemkey":"dev-A-0342","datapattern":"2","defaultvalue":"14","level1":"dc","level2":"dev","level3":"A","level4":"342"},
    {"ctlno":"197","setname":"透析液濃度プログラム設定３","elemkey":"dev-A-0343","datapattern":"2","defaultvalue":"14","level1":"dc","level2":"dev","level3":"A","level4":"343"},
    {"ctlno":"198","setname":"透析液濃度プログラム設定４","elemkey":"dev-A-0344","datapattern":"2","defaultvalue":"14","level1":"dc","level2":"dev","level3":"A","level4":"344"},
    {"ctlno":"199","setname":"透析液濃度プログラム設定５","elemkey":"dev-A-0345","datapattern":"2","defaultvalue":"14","level1":"dc","level2":"dev","level3":"A","level4":"345"},
    {"ctlno":"200","setname":"透析液濃度プログラム設定６","elemkey":"dev-A-0346","datapattern":"2","defaultvalue":"13.5","level1":"dc","level2":"dev","level3":"A","level4":"346"},
    {"ctlno":"201","setname":"透析液濃度プログラム設定７","elemkey":"dev-A-0347","datapattern":"2","defaultvalue":"13.5","level1":"dc","level2":"dev","level3":"A","level4":"347"},
    {"ctlno":"202","setname":"透析液濃度プログラム設定８","elemkey":"dev-A-0348","datapattern":"2","defaultvalue":"13.5","level1":"dc","level2":"dev","level3":"A","level4":"348"},
    {"ctlno":"203","setname":"透析液濃度プログラム設定９","elemkey":"dev-A-0349","datapattern":"2","defaultvalue":"13.5","level1":"dc","level2":"dev","level3":"A","level4":"349"},
    {"ctlno":"204","setname":"透析液濃度プログラム設定１０","elemkey":"dev-A-0350","datapattern":"2","defaultvalue":"13.5","level1":"dc","level2":"dev","level3":"A","level4":"350"},
    {"ctlno":"205","setname":"Ｂ液濃度プログラム設定１","elemkey":"dev-A-0351","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"351"},
    {"ctlno":"206","setname":"Ｂ液濃度プログラム設定２","elemkey":"dev-A-0352","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"352"},
    {"ctlno":"207","setname":"Ｂ液濃度プログラム設定３","elemkey":"dev-A-0353","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"353"},
    {"ctlno":"208","setname":"Ｂ液濃度プログラム設定４","elemkey":"dev-A-0354","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"354"},
    {"ctlno":"209","setname":"Ｂ液濃度プログラム設定５","elemkey":"dev-A-0355","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"355"},
    {"ctlno":"210","setname":"Ｂ液濃度プログラム設定６","elemkey":"dev-A-0356","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"356"},
    {"ctlno":"211","setname":"Ｂ液濃度プログラム設定７","elemkey":"dev-A-0357","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"357"},
    {"ctlno":"212","setname":"Ｂ液濃度プログラム設定８","elemkey":"dev-A-0358","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"358"},
    {"ctlno":"213","setname":"Ｂ液濃度プログラム設定９","elemkey":"dev-A-0359","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"359"},
    {"ctlno":"214","setname":"Ｂ液濃度プログラム設定１０","elemkey":"dev-A-0360","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"360"},
    {"ctlno":"215","setname":"透析液濃度プログラムステップ切替無し コース","elemkey":"dev-A-0361","datapattern":"2","defaultvalue":"2","level1":"dc","level2":"dev","level3":"A","level4":"361"},
    {"ctlno":"216","setname":"透析液濃度プログラム開始数値","elemkey":"dev-A-0362","datapattern":"2","defaultvalue":"13.5","level1":"dc","level2":"dev","level3":"A","level4":"362"},
    {"ctlno":"217","setname":"透析液濃度プログラム終了数値","elemkey":"dev-A-0363","datapattern":"2","defaultvalue":"15","level1":"dc","level2":"dev","level3":"A","level4":"363"},
    {"ctlno":"218","setname":"Ｂ液濃度プログラムステップ切替無し コース","elemkey":"dev-A-0364","datapattern":"2","defaultvalue":"2","level1":"dc","level2":"dev","level3":"A","level4":"364"},
    {"ctlno":"219","setname":"Ｂ液濃度プログラム開始数値","elemkey":"dev-A-0365","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"365"},
    {"ctlno":"220","setname":"Ｂ液濃度プログラム終了数値","elemkey":"dev-A-0366","datapattern":"2","defaultvalue":"3","level1":"dc","level2":"dev","level3":"A","level4":"366"},
    {"ctlno":"221","setname":"濃度プログラム切替時間","elemkey":"dev-A-0367","datapattern":"2","defaultvalue":"30","level1":"dc","level2":"dev","level3":"A","level4":"367"},
    {"ctlno":"222","setname":"濃度プログラム ＵＦＲプロとの連動選択","elemkey":"dev-A-0368","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"A","level4":"368"},
    {"ctlno":"231","setname":"補液速度","elemkey":"ind_cond_info-24-value","datapattern":"3","defaultvalue":null,"level1":"24","level2":"ind_cond_info","level3":"24","level4":"value"},
    {"ctlno":"232","setname":"補液温度設定値","elemkey":"ind_cond_info-23-value","datapattern":"3","defaultvalue":null,"level1":"23","level2":"ind_cond_info","level3":"23","level4":"value"},
    {"ctlno":"233","setname":"補液量設定値","elemkey":"ind_cond_info-20-value","datapattern":"3","defaultvalue":null,"level1":"20","level2":"ind_cond_info","level3":"20","level4":"value"},
    {"ctlno":"239","setname":"補液選択(前・後)","elemkey":"ind_cond_info-21-value","datapattern":"3","defaultvalue":"0","level1":"21","level2":"ind_cond_info","level3":"21","level4":"value"},
    {"ctlno":"241","setname":"ＴＭＰゼロ補正警報中点OHDF","elemkey":"tmp_center_ohdf","datapattern":"5","defaultvalue":"-30","level1":"tmp_center_ohdf","level2":"","level3":"","level4":"tmp_center_ohdf"},
    {"ctlno":"244","setname":"ＴＭＰゼロ補正警報中点OHF","elemkey":"tmp_center_ohf","datapattern":"5","defaultvalue":"-65","level1":"tmp_center_ohf","level2":"","level3":"","level4":"tmp_center_ohf"},
    {"ctlno":"250","setname":"UFRプログラム工程1の指数","elemkey":"dev-B-0000","datapattern":"2","defaultvalue":"50","level1":"ufr","level2":"dev","level3":"B","level4":"000"},
    {"ctlno":"251","setname":"UFRプログラム工程2の指数","elemkey":"dev-B-0001","datapattern":"2","defaultvalue":"38","level1":"ufr","level2":"dev","level3":"B","level4":"001"},
    {"ctlno":"252","setname":"UFRプログラム工程3の指数","elemkey":"dev-B-0002","datapattern":"2","defaultvalue":"25","level1":"ufr","level2":"dev","level3":"B","level4":"002"},
    {"ctlno":"253","setname":"UFRプログラム工程4の指数","elemkey":"dev-B-0003","datapattern":"2","defaultvalue":"13","level1":"ufr","level2":"dev","level3":"B","level4":"003"},
    {"ctlno":"254","setname":"UFRプログラム工程5の指数","elemkey":"dev-B-0004","datapattern":"2","defaultvalue":"0","level1":"ufr","level2":"dev","level3":"B","level4":"004"},
    {"ctlno":"255","setname":"UFRプログラム工程6の指数","elemkey":"dev-B-0005","datapattern":"2","defaultvalue":"0","level1":"ufr","level2":"dev","level3":"B","level4":"005"},
    {"ctlno":"256","setname":"UFRプログラム工程7の指数","elemkey":"dev-B-0006","datapattern":"2","defaultvalue":"13","level1":"ufr","level2":"dev","level3":"B","level4":"006"},
    {"ctlno":"257","setname":"UFRプログラム工程8の指数","elemkey":"dev-B-0007","datapattern":"2","defaultvalue":"25","level1":"ufr","level2":"dev","level3":"B","level4":"007"},
    {"ctlno":"258","setname":"UFRプログラム工程9の指数","elemkey":"dev-B-0008","datapattern":"2","defaultvalue":"38","level1":"ufr","level2":"dev","level3":"B","level4":"008"},
    {"ctlno":"259","setname":"UFRプログラム工程10の指数","elemkey":"dev-B-0009","datapattern":"2","defaultvalue":"50","level1":"ufr","level2":"dev","level3":"B","level4":"009"},
    {"ctlno":"260","setname":"B液濃度プログラム工程1のB液濃度","elemkey":"dev-B-0010","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"010"},
    {"ctlno":"261","setname":"B液濃度プログラム工程2のB液濃度","elemkey":"dev-B-0011","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"011"},
    {"ctlno":"262","setname":"B液濃度プログラム工程3のB液濃度","elemkey":"dev-B-0012","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"012"},
    {"ctlno":"263","setname":"B液濃度プログラム工程4のB液濃度","elemkey":"dev-B-0013","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"013"},
    {"ctlno":"264","setname":"B液濃度プログラム工程5のB液濃度","elemkey":"dev-B-0014","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"014"},
    {"ctlno":"265","setname":"B液濃度プログラム工程6のB液濃度","elemkey":"dev-B-0015","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"015"},
    {"ctlno":"266","setname":"B液濃度プログラム工程7のB液濃度","elemkey":"dev-B-0016","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"016"},
    {"ctlno":"267","setname":"B液濃度プログラム工程8のB液濃度","elemkey":"dev-B-0017","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"017"},
    {"ctlno":"268","setname":"B液濃度プログラム工程9のB液濃度","elemkey":"dev-B-0018","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"018"},
    {"ctlno":"269","setname":"B液濃度プログラム工程10のB液濃度","elemkey":"dev-B-0019","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"019"},
    {"ctlno":"270","setname":"A液濃度プログラム工程1のA液濃度","elemkey":"dev-B-0020","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"020"},
    {"ctlno":"271","setname":"A液濃度プログラム工程2のA液濃度","elemkey":"dev-B-0021","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"021"},
    {"ctlno":"272","setname":"A液濃度プログラム工程3のA液濃度","elemkey":"dev-B-0022","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"022"},
    {"ctlno":"273","setname":"A液濃度プログラム工程4のA液濃度","elemkey":"dev-B-0023","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"023"},
    {"ctlno":"274","setname":"A液濃度プログラム工程5のA液濃度","elemkey":"dev-B-0024","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"024"},
    {"ctlno":"275","setname":"A液濃度プログラム工程6のA液濃度","elemkey":"dev-B-0025","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"025"},
    {"ctlno":"276","setname":"A液濃度プログラム工程7のA液濃度","elemkey":"dev-B-0026","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"026"},
    {"ctlno":"277","setname":"A液濃度プログラム工程8のA液濃度","elemkey":"dev-B-0027","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"027"},
    {"ctlno":"278","setname":"A液濃度プログラム工程9のA液濃度","elemkey":"dev-B-0028","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"028"},
    {"ctlno":"279","setname":"A液濃度プログラム工程10のA液濃度","elemkey":"dev-B-0029","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"029"},
    {"ctlno":"309","setname":"ダイアライザ選択","elemkey":"dialyzer_type","datapattern":"4","defaultvalue":"1","level1":"dialyzer_type","level2":"","level3":"","level4":"dialyzer_type"},
    {"ctlno":"316","setname":"中空糸 除水ポンプ速度","elemkey":"0000","datapattern":"7","defaultvalue":"0.2","level1":"","level2":"","level3":"","level4":""},
    {"ctlno":"340","setname":"I-HDF　補液量設定","elemkey":"dev-A-0200","datapattern":"2","defaultvalue":"200","level1":"ihdf","level2":"dev","level3":"A","level4":"200"},
    {"ctlno":"341","setname":"I-HDF　補液速度","elemkey":"dev-A-0201","datapattern":"2","defaultvalue":"100","level1":"ihdf","level2":"dev","level3":"A","level4":"201"},
    {"ctlno":"342","setname":"I-HDF　補液周期","elemkey":"dev-A-0202","datapattern":"2","defaultvalue":"30","level1":"ihdf","level2":"dev","level3":"A","level4":"202"},
    {"ctlno":"343","setname":"I-HDF　補液開始時間","elemkey":"dev-A-0203","datapattern":"2","defaultvalue":"30","level1":"ihdf","level2":"dev","level3":"A","level4":"203"},
    {"ctlno":"344","setname":"I-HDF　除水再開時間","elemkey":"dev-A-0204","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"204"},
    {"ctlno":"345","setname":"I-HDF　総補液量上限","elemkey":"dev-A-0205","datapattern":"2","defaultvalue":"1.5","level1":"ihdf","level2":"dev","level3":"A","level4":"205"},
    {"ctlno":"351","setname":"BV-UFC使用選択","elemkey":"dev-A-0196","datapattern":"2","defaultvalue":"0","level1":"bvufc","level2":"dev","level3":"A","level4":"196"},
    {"ctlno":"352","setname":"UFC期間除水速度上限","elemkey":"dev-A-0197","datapattern":"2","defaultvalue":"2.00","level1":"bvufc","level2":"dev","level3":"A","level4":"197"},
    {"ctlno":"353","setname":"UFC期間除水速度下限","elemkey":"dev-A-0198","datapattern":"2","defaultvalue":"0.00","level1":"bvufc","level2":"dev","level3":"A","level4":"198"},
    {"ctlno":"354","setname":"開始期間 時間","elemkey":"dev-A-0199","datapattern":"2","defaultvalue":"10","level1":"bvufc","level2":"dev","level3":"A","level4":"199"},
    {"ctlno":"355","setname":"開始期間 除水速度倍率","elemkey":"dev-A-0206","datapattern":"2","defaultvalue":"1.00","level1":"bvufc","level2":"dev","level3":"A","level4":"206"},
    {"ctlno":"356","setname":"固定倍率除水期間 時間","elemkey":"dev-A-0207","datapattern":"2","defaultvalue":"60","level1":"bvufc","level2":"dev","level3":"A","level4":"207"},
    {"ctlno":"357","setname":"固定倍率除水期間 除水速度倍率","elemkey":"dev-A-0208","datapattern":"2","defaultvalue":"1.30","level1":"bvufc","level2":"dev","level3":"A","level4":"208"},
    {"ctlno":"358","setname":"固定倍率除水終了条件　最高血圧","elemkey":"dev-A-0209","datapattern":"2","defaultvalue":"0","level1":"bvufc","level2":"dev","level3":"A","level4":"209"},
    {"ctlno":"359","setname":"固定倍率除水終了条件　脈拍","elemkey":"dev-A-0210","datapattern":"2","defaultvalue":"0","level1":"bvufc","level2":"dev","level3":"A","level4":"210"},
    {"ctlno":"360","setname":"固定倍率除水終了条件　ΔBV","elemkey":"dev-A-0248","datapattern":"2","defaultvalue":"0.0","level1":"bvufc","level2":"dev","level3":"A","level4":"248"},
    {"ctlno":"361","setname":"終了前期間 時間","elemkey":"dev-A-0249","datapattern":"2","defaultvalue":"20","level1":"bvufc","level2":"dev","level3":"A","level4":"249"},
    {"ctlno":"364","setname":"開始時ΔBV基準値 ","elemkey":"dev-A-0271","datapattern":"2","defaultvalue":"0.0","level1":"bvufc","level2":"dev","level3":"A","level4":"271"},
    {"ctlno":"365","setname":"ΔBV基準線　指数1","elemkey":"dev-A-0272","datapattern":"2","defaultvalue":"50","level1":"bvufc","level2":"dev","level3":"A","level4":"272"},
    {"ctlno":"366","setname":"ΔBV基準線　指数2","elemkey":"dev-A-0273","datapattern":"2","defaultvalue":"80","level1":"bvufc","level2":"dev","level3":"A","level4":"273"},
    {"ctlno":"367","setname":"ΔBV基準線　指数3","elemkey":"dev-A-0274","datapattern":"2","defaultvalue":"95","level1":"bvufc","level2":"dev","level3":"A","level4":"274"},
    {"ctlno":"368","setname":"終了時ΔBV基準値 ","elemkey":"dev-A-0275","datapattern":"2","defaultvalue":"-4.0","level1":"bvufc","level2":"dev","level3":"A","level4":"275"},
    {"ctlno":"369","setname":"QBプログラム血流量1","elemkey":"dev-A-0400","datapattern":"2","defaultvalue":"100","level1":"qbqd","level2":"dev","level3":"A","level4":"400"},
    {"ctlno":"370","setname":"QBプログラム血流量2","elemkey":"dev-A-0401","datapattern":"2","defaultvalue":"160","level1":"qbqd","level2":"dev","level3":"A","level4":"401"},
    {"ctlno":"371","setname":"QBプログラム血流量3","elemkey":"dev-A-0402","datapattern":"2","defaultvalue":"220","level1":"qbqd","level2":"dev","level3":"A","level4":"402"},
    {"ctlno":"372","setname":"QBプログラム血流量4","elemkey":"dev-A-0403","datapattern":"2","defaultvalue":"220","level1":"qbqd","level2":"dev","level3":"A","level4":"403"},
    {"ctlno":"373","setname":"QBプログラム血流量5","elemkey":"dev-A-0404","datapattern":"2","defaultvalue":"220","level1":"qbqd","level2":"dev","level3":"A","level4":"404"},
    {"ctlno":"374","setname":"QBプログラム血流量6","elemkey":"dev-A-0405","datapattern":"2","defaultvalue":"220","level1":"qbqd","level2":"dev","level3":"A","level4":"405"},
    {"ctlno":"375","setname":"QBプログラム血流量7","elemkey":"dev-A-0406","datapattern":"2","defaultvalue":"220","level1":"qbqd","level2":"dev","level3":"A","level4":"406"},
    {"ctlno":"376","setname":"QBプログラム血流量8","elemkey":"dev-A-0407","datapattern":"2","defaultvalue":"220","level1":"qbqd","level2":"dev","level3":"A","level4":"407"},
    {"ctlno":"377","setname":"QBプログラム血流量9","elemkey":"dev-A-0408","datapattern":"2","defaultvalue":"220","level1":"qbqd","level2":"dev","level3":"A","level4":"408"},
    {"ctlno":"378","setname":"QBプログラム血流量10","elemkey":"dev-A-0409","datapattern":"2","defaultvalue":"220","level1":"qbqd","level2":"dev","level3":"A","level4":"409"},
    {"ctlno":"379","setname":"QDプログラム透析液流量1","elemkey":"dev-A-0410","datapattern":"2","defaultvalue":"200","level1":"qbqd","level2":"dev","level3":"A","level4":"410"},
    {"ctlno":"380","setname":"QDプログラム透析液流量2","elemkey":"dev-A-0411","datapattern":"2","defaultvalue":"400","level1":"qbqd","level2":"dev","level3":"A","level4":"411"},
    {"ctlno":"381","setname":"QDプログラム透析液流量3","elemkey":"dev-A-0412","datapattern":"2","defaultvalue":"600","level1":"qbqd","level2":"dev","level3":"A","level4":"412"},
    {"ctlno":"382","setname":"QDプログラム透析液流量4","elemkey":"dev-A-0413","datapattern":"2","defaultvalue":"600","level1":"qbqd","level2":"dev","level3":"A","level4":"413"},
    {"ctlno":"383","setname":"QDプログラム透析液流量5","elemkey":"dev-A-0414","datapattern":"2","defaultvalue":"600","level1":"qbqd","level2":"dev","level3":"A","level4":"414"},
    {"ctlno":"384","setname":"QDプログラム透析液流量6","elemkey":"dev-A-0415","datapattern":"2","defaultvalue":"600","level1":"qbqd","level2":"dev","level3":"A","level4":"415"},
    {"ctlno":"385","setname":"QDプログラム透析液流量7","elemkey":"dev-A-0416","datapattern":"2","defaultvalue":"600","level1":"qbqd","level2":"dev","level3":"A","level4":"416"},
    {"ctlno":"386","setname":"QDプログラム透析液流量8","elemkey":"dev-A-0417","datapattern":"2","defaultvalue":"600","level1":"qbqd","level2":"dev","level3":"A","level4":"417"},
    {"ctlno":"387","setname":"QDプログラム透析液流量9","elemkey":"dev-A-0418","datapattern":"2","defaultvalue":"600","level1":"qbqd","level2":"dev","level3":"A","level4":"418"},
    {"ctlno":"388","setname":"QDプログラム透析液流量10","elemkey":"dev-A-0419","datapattern":"2","defaultvalue":"600","level1":"qbqd","level2":"dev","level3":"A","level4":"419"},
    {"ctlno":"389","setname":"QB、QDプログラム切替時間1","elemkey":"dev-A-0420","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"420"},
    {"ctlno":"390","setname":"QB、QDプログラム切替時間2","elemkey":"dev-A-0421","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"421"},
    {"ctlno":"391","setname":"QB、QDプログラム切替時間3","elemkey":"dev-A-0422","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"422"},
    {"ctlno":"392","setname":"QB、QDプログラム切替時間4","elemkey":"dev-A-0423","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"423"},
    {"ctlno":"393","setname":"QB、QDプログラム切替時間5","elemkey":"dev-A-0424","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"424"},
    {"ctlno":"394","setname":"QB、QDプログラム切替時間6","elemkey":"dev-A-0425","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"425"},
    {"ctlno":"395","setname":"QB、QDプログラム切替時間7","elemkey":"dev-A-0426","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"426"},
    {"ctlno":"396","setname":"QB、QDプログラム切替時間8","elemkey":"dev-A-0427","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"427"},
    {"ctlno":"397","setname":"QB、QDプログラム切替時間9","elemkey":"dev-A-0428","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"428"},
    {"ctlno":"398","setname":"QB、QDプログラム最大ステップ数","elemkey":"dev-A-0429","datapattern":"2","defaultvalue":"3","level1":"qbqd","level2":"dev","level3":"A","level4":"429"},
    {"ctlno":"399","setname":"QBプログラム電源","elemkey":"dev-A-0430","datapattern":"2","defaultvalue":"0","level1":"qbqd","level2":"dev","level3":"A","level4":"430"},
    {"ctlno":"400","setname":"QDプログラム電源","elemkey":"dev-A-0431","datapattern":"2","defaultvalue":"0","level1":"qbqd","level2":"dev","level3":"A","level4":"431"},
    {"ctlno":"401","setname":"I-HDFプログラム使用選択","elemkey":"dev-A-0432","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"432"},
    {"ctlno":"402","setname":"予定補液回数","elemkey":"dev-A-0433","datapattern":"2","defaultvalue":"7","level1":"ihdf","level2":"dev","level3":"A","level4":"433"},
    {"ctlno":"403","setname":"補液バランス制限","elemkey":"dev-A-0434","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"434"},
    {"ctlno":"404","setname":"補液量01","elemkey":"dev-A-0435","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"435"},
    {"ctlno":"405","setname":"補液量02","elemkey":"dev-A-0436","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"436"},
    {"ctlno":"406","setname":"補液量03","elemkey":"dev-A-0437","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"437"},
    {"ctlno":"407","setname":"補液量04","elemkey":"dev-A-0438","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"438"},
    {"ctlno":"408","setname":"補液量05","elemkey":"dev-A-0439","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"439"},
    {"ctlno":"409","setname":"補液量06","elemkey":"dev-A-0440","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"440"},
    {"ctlno":"410","setname":"補液量07","elemkey":"dev-A-0441","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"441"},
    {"ctlno":"411","setname":"補液量08","elemkey":"dev-A-0442","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"442"},
    {"ctlno":"412","setname":"補液量09","elemkey":"dev-A-0443","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"443"},
    {"ctlno":"413","setname":"補液量10","elemkey":"dev-A-0444","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"444"},
    {"ctlno":"414","setname":"補液量11","elemkey":"dev-A-0445","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"445"},
    {"ctlno":"415","setname":"補液量12","elemkey":"dev-A-0446","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"446"},
    {"ctlno":"416","setname":"補液量13","elemkey":"dev-A-0447","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"447"},
    {"ctlno":"417","setname":"補液量14","elemkey":"dev-A-0448","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"448"},
    {"ctlno":"418","setname":"補液量15","elemkey":"dev-A-0449","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"449"},
    {"ctlno":"419","setname":"補液量16","elemkey":"dev-A-0450","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"450"},
    {"ctlno":"420","setname":"回収量01","elemkey":"dev-A-0451","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"451"},
    {"ctlno":"421","setname":"回収量02","elemkey":"dev-A-0452","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"452"},
    {"ctlno":"422","setname":"回収量03","elemkey":"dev-A-0453","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"453"},
    {"ctlno":"423","setname":"回収量04","elemkey":"dev-A-0454","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"454"},
    {"ctlno":"424","setname":"回収量05","elemkey":"dev-A-0455","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"455"},
    {"ctlno":"425","setname":"回収量06","elemkey":"dev-A-0456","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"456"},
    {"ctlno":"426","setname":"回収量07","elemkey":"dev-A-0457","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"457"},
    {"ctlno":"427","setname":"回収量08","elemkey":"dev-A-0458","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"458"},
    {"ctlno":"428","setname":"回収量09","elemkey":"dev-A-0459","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"459"},
    {"ctlno":"429","setname":"回収量10","elemkey":"dev-A-0460","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"460"},
    {"ctlno":"430","setname":"回収量11","elemkey":"dev-A-0461","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"461"},
    {"ctlno":"431","setname":"回収量12","elemkey":"dev-A-0462","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"462"},
    {"ctlno":"432","setname":"回収量13","elemkey":"dev-A-0463","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"463"},
    {"ctlno":"433","setname":"回収量14","elemkey":"dev-A-0464","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"464"},
    {"ctlno":"434","setname":"回収量15","elemkey":"dev-A-0465","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"465"},
    {"ctlno":"435","setname":"回収量16","elemkey":"dev-A-0466","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"466"}
  ]'' :: jsonb
      ) AS elements(
        ctlno TEXT,
        setname TEXT,
        elemkey TEXT,
        datapattern TEXT,
        defaultvalue TEXT
      )
  ),
  ntss_db5_pm AS (
    SELECT
      pat_id,
      facility_cd,
      device_set_info,
      up_date
    FROM
      ntss.pat_main
    WHERE
      facility_cd = @facilityCd
      AND pat_id = ANY (string_to_array(@paramList1, '','')::bigint[])
      AND is_del <> ''1''
  ),
  -- 治療情報マスタ：指示 *修正版
  ind_ord_main_before_rank AS (
    SELECT
      subquery.pat_id,
      subquery.facility_cd,
      subquery.ord_no,
      subquery.treat_week,
      subquery.treat_date,
      subquery.up_date,
      subquery.ind_device_set_info,
      subquery.ind_cond_info,
      subquery.rst_cond_info,
      subquery.ind_bed_cd,
      subquery.rst_weight_info,
      subquery.rst_running_time,
      subquery.min_treatment_date,
      RANK() OVER (
        PARTITION BY subquery.pat_id,
        subquery.treat_week
        ORDER BY
          CASE
            WHEN subquery.ind_kur_cd = ''0'' THEN 2
            ELSE 1
          END,
          CASE
            WHEN subquery.ind_kur_cd = ''0'' THEN ntss_db5_mst_sel.sortkey :: integer
            ELSE (subquery.ind_treat_start_time) :: integer
          END,
          ntss_db5_mst_sel.sortkey
      ) AS priority
    FROM
      (
        SELECT
          ord_main.*,
          MIN(TO_DATE(ord_main.treat_date, ''YYYYMMDD'')) OVER(PARTITION BY ord_main.treat_week, ord_main.pat_id) AS min_treatment_date
        FROM
          ord_main
        WHERE
          ord_main.facility_cd = @facilityCd
          AND pat_id = ANY (string_to_array(@paramList1, '','')::bigint[])
          AND ord_main.is_del = ''0''
          AND TO_DATE(ord_main.treat_date, ''YYYYMMDD'') >= CURRENT_DATE
      ) AS subquery
      LEFT JOIN (
        SELECT
          ntss_db5_ms.facility_cd,
          setting ->> ''code'' AS code,
          ROW_NUMBER() OVER() AS sortkey
        FROM
          ntss.mst_selector ntss_db5_ms
          CROSS JOIN LATERAL jsonb_array_elements((ntss_db5_ms.order_settings #> ''{"items"}'') ) setting
        WHERE
          ntss_db5_ms.facility_cd = @facilityCd
          AND ntss_db5_ms.master_physical_name = ''mst_treatment''
      ) AS ntss_db5_mst_sel ON subquery.facility_cd = ntss_db5_mst_sel.facility_cd
      AND subquery.ind_treatment_cd :: TEXT = ntss_db5_mst_sel.code
    WHERE
      TO_DATE(treat_date, ''YYYYMMDD'') = min_treatment_date
  ),
  ind_ord_main AS (
    SELECT
      *
    FROM
      ind_ord_main_before_rank
    WHERE
      priority = 1
  ),
  -- pat_mainのデータ取得START
  ntss_db5_pm_dsi AS (
    SELECT
      ntss_db5_pm.pat_id AS pat_id,
      ''dev-A-'' || lpad(value_3.KEY, 4, ''0'') AS elemkey,
      ntss_db5_pm.up_date :: text,
      value_3.VALUE AS value_4
    FROM
      ntss_db5_pm
      JOIN jsonb_each_text(ntss_db5_pm.device_set_info) AS keysandvalue ON TRUE
      JOIN jsonb_each_text((keysandvalue.VALUE :: jsonb #>> ''{dev,A}'') :: jsonb) AS value_3 ON TRUE
    WHERE
      ntss_db5_pm.device_set_info IS NOT NULL
      AND ntss_db5_pm.device_set_info <> ''[]''
      AND value_3.KEY IS NOT NULL
    UNION ALL
    SELECT
      ntss_db5_pm.pat_id AS pat_id,
      ''dev-B-'' || lpad(value_3.KEY, 4, ''0'') AS elemkey,
      ntss_db5_pm.up_date :: text,
      value_3.VALUE AS value_4
    FROM
      ntss_db5_pm
      JOIN jsonb_each_text(ntss_db5_pm.device_set_info :: jsonb) AS keysandvalue ON TRUE
      JOIN jsonb_each_text((keysandvalue.VALUE :: jsonb #>> ''{dev,B}'') :: jsonb) AS value_3 ON TRUE
    WHERE
      ntss_db5_pm.device_set_info IS NOT NULL
      AND ntss_db5_pm.device_set_info <> ''[]''
      AND value_3.KEY IS NOT NULL
    UNION ALL
    SELECT
      ntss_db5_pm.pat_id AS pat_id,
      ''pat-A-'' || lpad(value_3.KEY, 4, ''0'') AS elemkey,
      ntss_db5_pm.up_date :: text,
      value_3.VALUE AS value_4
    FROM
      ntss_db5_pm
      JOIN jsonb_each_text(ntss_db5_pm.device_set_info :: jsonb) AS keysandvalue ON TRUE
      JOIN jsonb_each_text((keysandvalue.VALUE :: jsonb #>> ''{pat,A}'') :: jsonb) AS value_3 ON TRUE
    WHERE
      ntss_db5_pm.device_set_info IS NOT NULL
      AND ntss_db5_pm.device_set_info <> ''[]''
      AND value_3.KEY IS NOT NULL
    UNION ALL
    SELECT
      ntss_db5_pm.pat_id AS pat_id,
      ''pat-B-'' || lpad(value_3.KEY, 4, ''0'') AS elemkey,
      ntss_db5_pm.up_date :: text,
      value_3.VALUE AS value_4
    FROM
      ntss_db5_pm
      JOIN jsonb_each_text(ntss_db5_pm.device_set_info :: jsonb) AS keysandvalue ON TRUE
      JOIN jsonb_each_text((keysandvalue.VALUE :: jsonb #>> ''{pat,B}'') :: jsonb) AS value_3 ON TRUE
    WHERE
      ntss_db5_pm.device_set_info IS NOT NULL
      AND ntss_db5_pm.device_set_info <> ''[]''
      AND value_3.KEY IS NOT NULL
  ), -- pat_mainのデータ取得END
  -- ord_main,pat_treatment_patternのind_device_set_infoデータ取得START
  ntss_db5_ptp_week_date AS (
    SELECT
      ntss_db5_ptp.pat_id,
      ntss_db5_ptp.treat_week,
      max(ntss_db5_ptp.ind_treat_start_date) AS max_ind_treat_start_date
    FROM
      ntss.pat_treatment_pattern ntss_db5_ptp
    WHERE
      ntss_db5_ptp.facility_cd = @facilityCd
      AND pat_id = ANY (string_to_array(@paramList1, '','')::bigint[])
      AND ntss_db5_ptp.ind_treat_start_date :: date <= current_date
    GROUP BY
      ntss_db5_ptp.pat_id,
      ntss_db5_ptp.treat_week
  ),
  ntss_db5_ptp_week_bef_rank AS (
    SELECT
      ntss_db5_ptp.pat_id,
      ntss_db5_ptp.treat_week,
      ntss_db5_ptp.ctl_no,
      ntss_db5_ptp_week_date.max_ind_treat_start_date,
      ntss_db5_ptp.up_date,
      RANK() OVER (
        PARTITION BY ntss_db5_ptp.pat_id,
        ntss_db5_ptp.treat_week
        ORDER BY
          CASE
            WHEN ntss_db5_ptp.ind_kur_cd = ''0'' THEN 2
            ELSE 1
          END,
          CASE
            WHEN ntss_db5_ptp.ind_kur_cd = ''0'' THEN ntss_db5_mst_sel.sortkey :: integer
            ELSE (
              ntss_db5_ptp.ind_sch_info ->> ''ind_treat_start_time''
            ) :: integer
          END,
          ntss_db5_mst_sel.sortkey
      ) AS priority,
      ntss_db5_ptp.facility_cd,
      ntss_db5_ptp.ind_sch_info,
      ntss_db5_ptp.ind_cond_info,
      ntss_db5_ptp.ind_device_set_info
    FROM
      ntss.pat_treatment_pattern ntss_db5_ptp
      INNER JOIN ntss_db5_ptp_week_date ON ntss_db5_ptp.pat_id = ntss_db5_ptp_week_date.pat_id
      AND ntss_db5_ptp.treat_week = ntss_db5_ptp_week_date.treat_week
      AND ntss_db5_ptp.ind_treat_start_date = ntss_db5_ptp_week_date.max_ind_treat_start_date
      LEFT JOIN (
        SELECT
          ntss_db5_ms.facility_cd,
          setting ->> ''code'' AS code,
          ROW_NUMBER() OVER() AS sortkey
        FROM
          ntss.mst_selector ntss_db5_ms
          CROSS JOIN LATERAL jsonb_array_elements((ntss_db5_ms.order_settings #> ''{"items"}'') :: jsonb) setting
        WHERE
          ntss_db5_ms.facility_cd = @facilityCd
          AND ntss_db5_ms.master_physical_name = ''mst_treatment''
      ) ntss_db5_mst_sel ON ntss_db5_ptp.facility_cd = ntss_db5_mst_sel.facility_cd
      AND ntss_db5_ptp.ind_treatment_cd :: TEXT = ntss_db5_mst_sel.code
    WHERE
      ntss_db5_ptp.facility_cd = @facilityCd
      AND ntss_db5_ptp.ind_device_set_info IS NOT NULL
      AND ntss_db5_ptp.ind_device_set_info <> ''[]''
  ),
  ntss_db5_ptp_week AS (
    SELECT
      *
    FROM
      ntss_db5_ptp_week_bef_rank
    WHERE
      priority = 1
  ),
  yellow_idsi AS (
    SELECT
      ntss_db5_ptp_week.pat_id AS pat_id,
      ntss_db5_ptp_week.treat_week,
      ntss_db5_ptp_week.max_ind_treat_start_date AS up_date,
      ''dev-A-'' || lpad(value_3.KEY, 4, ''0'') AS elemkey,
      value_3.VALUE AS value_4,
      1 AS priority
    FROM
      ntss_db5_ptp_week
      JOIN jsonb_each_text(ntss_db5_ptp_week.ind_device_set_info :: jsonb) AS keysandvalue ON TRUE
      JOIN jsonb_each_text((keysandvalue.VALUE :: jsonb #>> ''{dev,A}'') :: jsonb) AS value_3 ON TRUE
    WHERE
      ntss_db5_ptp_week.facility_cd = @facilityCd
      AND ntss_db5_ptp_week.priority = 1
      AND ntss_db5_ptp_week.ind_device_set_info IS NOT NULL
      AND ntss_db5_ptp_week.ind_device_set_info <> ''[]''
    UNION ALL
    SELECT
      ntss_db5_ptp_week.pat_id AS pat_id,
      ntss_db5_ptp_week.treat_week,
      ntss_db5_ptp_week.max_ind_treat_start_date AS up_date,
      ''dev-B-'' || lpad(value_3.KEY, 4, ''0'') AS elemkey,
      value_3.VALUE AS value_4,
      1 AS priority
    FROM
      ntss_db5_ptp_week
      JOIN jsonb_each_text(ntss_db5_ptp_week.ind_device_set_info :: jsonb) AS keysandvalue ON TRUE
      JOIN jsonb_each_text((keysandvalue.VALUE :: jsonb #>> ''{dev,B}'') :: jsonb) AS value_3 ON TRUE
    WHERE
      ntss_db5_ptp_week.facility_cd = @facilityCd
      AND ntss_db5_ptp_week.priority = 1
      AND ntss_db5_ptp_week.ind_device_set_info IS NOT NULL
      AND ntss_db5_ptp_week.ind_device_set_info <> ''[]''
    UNION ALL
    SELECT
      ind_ord_main.pat_id AS pat_id,
      ind_ord_main.treat_week,
      ind_ord_main.up_date :: text,
      ''dev-A-'' || lpad(value_3.KEY, 4, ''0'') AS elemkey,
      value_3.VALUE AS value_4,
      2 AS priority
    FROM
      ind_ord_main
      JOIN jsonb_each_text(ind_ord_main.ind_device_set_info :: jsonb) AS keysandvalue ON TRUE
      JOIN jsonb_each_text((keysandvalue.VALUE :: jsonb #>> ''{dev,A}'') :: jsonb) AS value_3 ON TRUE
    WHERE
      ind_ord_main.ind_device_set_info IS NOT NULL
      AND ind_ord_main.ind_device_set_info <> ''[]''
    UNION ALL
    SELECT
      ind_ord_main.pat_id AS pat_id,
      ind_ord_main.treat_week,
      ind_ord_main.up_date :: text,
      ''dev-B-'' || lpad(value_3.KEY, 4, ''0'') AS elemkey,
      value_3.VALUE AS value_4,
      2 AS priority
    FROM
      ind_ord_main
      JOIN jsonb_each_text(ind_ord_main.ind_device_set_info :: jsonb) AS keysandvalue ON TRUE
      JOIN jsonb_each_text((keysandvalue.VALUE :: jsonb #>> ''{dev,B}'') :: jsonb) AS value_3 ON TRUE
    WHERE
      ind_ord_main.ind_device_set_info IS NOT NULL
      AND ind_ord_main.ind_device_set_info <> ''[]''
  ), -- ord_main,pat_treatment_patternのind_device_set_infoデータ取得END
  -- ord_main,pat_treatment_patternのind_cond_infoデータ取得START
  ntss_db5_pu_physical AS (
    SELECT
      ntss_db5_pu.pat_id,
      physical_info_json ->> ''dw'' AS dw,
      RANK() OVER (
        PARTITION BY ntss_db5_pu.pat_id
        ORDER BY
          physical_info_json ->> ''inspect_date'' DESC,
          physical_info_json ->> ''exam_date'' DESC
      ) AS priority,
      (ROW_NUMBER() OVER(PARTITION BY ntss_db5_pu.pat_id)) AS sortkey
    FROM
      pat_unique ntss_db5_pu
      INNER JOIN ntss_db5_pm ON ntss_db5_pu.pat_id = ntss_db5_pm.pat_id
      AND ntss_db5_pu.facility_cd = ntss_db5_pm.facility_cd
      CROSS JOIN LATERAL jsonb_array_elements(ntss_db5_pu.physical_info :: jsonb) AS physical_info_json
  ),
  ind_cond_info AS (
    SELECT
      ntss_db5_ptp_week.pat_id :: integer,
      ntss_db5_ptp_week.treat_week :: integer,
      ntss_db5_ptp_week.max_ind_treat_start_date :: TEXT AS up_date,
      elements.elemkey,
      CASE
        elements.ctlno
        WHEN ''81'' THEN ntss_db5_ptp_week.ind_cond_info #>> ''{33,value}''
        WHEN ''150'' THEN ntss_db5_ptp_week.ind_cond_info #>> ''{3,value}''
        WHEN ''151'' THEN ntss_db5_ptp_week.ind_cond_info #>> ''{14,value}''
        WHEN ''189'' THEN ntss_db5_ptp_week.ind_cond_info #>> ''{14,value}''
        WHEN ''231'' THEN ntss_db5_ptp_week.ind_cond_info #>> ''{24,value}''
        WHEN ''232'' THEN ntss_db5_ptp_week.ind_cond_info #>> ''{23,value}''
        WHEN ''233'' THEN ntss_db5_ptp_week.ind_cond_info #>> ''{20,value}''
        WHEN ''239'' THEN ntss_db5_ptp_week.ind_cond_info #>> ''{21,value}''
        ELSE NULL
      END AS value_4,
      1 AS priority
    FROM
      ntss_db5_ptp_week
      JOIN elements ON elements.datapattern = ''3''
    WHERE
      ntss_db5_ptp_week.ind_cond_info IS NOT NULL
      AND ntss_db5_ptp_week.ind_cond_info <> ''[]''
    UNION ALL
    SELECT
      ind_ord_main.pat_id :: integer,
      ind_ord_main.treat_week :: integer,
      ind_ord_main.up_date :: TEXT,
      elements.elemkey,
      CASE
        elements.ctlno
        WHEN ''81'' THEN ind_ord_main.ind_cond_info #>> ''{33,value}''
        WHEN ''150'' THEN ind_ord_main.ind_cond_info #>> ''{3,value}''
        WHEN ''151'' THEN ind_ord_main.ind_cond_info #>> ''{14,value}''
        WHEN ''189'' THEN ind_ord_main.ind_cond_info #>> ''{14,value}''
        WHEN ''231'' THEN ind_ord_main.ind_cond_info #>> ''{24,value}''
        WHEN ''232'' THEN ind_ord_main.ind_cond_info #>> ''{23,value}''
        WHEN ''233'' THEN ind_ord_main.ind_cond_info #>> ''{20,value}''
        WHEN ''239'' THEN ind_ord_main.ind_cond_info #>> ''{21,value}''
        ELSE NULL
      END AS value_4,
      2 AS priority
    FROM
      ind_ord_main
      JOIN elements ON elements.datapattern = ''3''
    WHERE
      ind_ord_main.ind_cond_info IS NOT NULL
      AND ind_ord_main.ind_cond_info <> ''[]''
  ), -- ord_main,pat_treatment_patternのind_cond_infoデータ取得END
  -- ベッド情報取得START
  ptp_machine AS (
    SELECT
      ntss_db5_ptp_week.pat_id AS pat_id,
      ntss_db5_ptp_week.treat_week,
      ntss_db5_mm.up_date,
      ntss_db5_mm.tmp_center_hd,
      ntss_db5_mm.tmp_center_ecum,
      ntss_db5_mm.tmp_center_hdf,
      ntss_db5_mm.tmp_center_hf,
      ntss_db5_mm.tmp_center_ohdf,
      ntss_db5_mm.tmp_center_ohf,
      1 AS priority
    FROM
      ntss_db5_ptp_week
      INNER JOIN ntss.mst_bed ntss_db5_mb ON ntss_db5_ptp_week.ind_sch_info ->> ''ind_bed_cd'' = ntss_db5_mb.bed_cd :: TEXT
      AND ntss_db5_ptp_week.facility_cd = ntss_db5_mb.facility_cd
      INNER JOIN ntss.mst_machine ntss_db5_mm ON ntss_db5_mb.machine_no = ntss_db5_mm.machine_no
      AND ntss_db5_ptp_week.facility_cd = ntss_db5_mm.facility_cd
    WHERE
      ntss_db5_ptp_week.ind_sch_info IS NOT NULL
      AND ntss_db5_ptp_week.ind_sch_info <> ''[]''
  ),
  om_machine AS (
    SELECT
      ind_ord_main.pat_id AS pat_id,
      ind_ord_main.treat_week,
      ntss_db5_mm.up_date,
      ntss_db5_mm.tmp_center_hd,
      ntss_db5_mm.tmp_center_ecum,
      ntss_db5_mm.tmp_center_hdf,
      ntss_db5_mm.tmp_center_hf,
      ntss_db5_mm.tmp_center_ohdf,
      ntss_db5_mm.tmp_center_ohf,
      2 AS priority
    FROM
      ind_ord_main
      INNER JOIN ntss.mst_bed ntss_db5_mb ON ind_ord_main.ind_bed_cd = ntss_db5_mb.bed_cd
      AND ind_ord_main.facility_cd = ntss_db5_mb.facility_cd
      INNER JOIN ntss.mst_machine ntss_db5_mm ON ntss_db5_mb.machine_no = ntss_db5_mm.machine_no
      AND ind_ord_main.facility_cd = ntss_db5_mm.facility_cd
    WHERE
      ind_ord_main.ind_bed_cd IS NOT NULL
  ),
  combined_machine AS (
    SELECT
      pat_id,
      treat_week,
      up_date,
      tmp_center_hd,
      tmp_center_ecum,
      tmp_center_hdf,
      tmp_center_hf,
      tmp_center_ohdf,
      tmp_center_ohf,
      priority
    FROM ptp_machine
    UNION ALL
    SELECT
      pat_id,
      treat_week,
      up_date,
      tmp_center_hd,
      tmp_center_ecum,
      tmp_center_hdf,
      tmp_center_hf,
      tmp_center_ohdf,
      tmp_center_ohf,
      priority
    FROM om_machine
  ),
  ranked_machine AS (
    SELECT
    *,
    ROW_NUMBER() OVER(PARTITION BY pat_id, treat_week ORDER BY priority) AS rn
  FROM combined_machine
  ),
  ranked_machine_info AS (
    SELECT
      pat_id,
      treat_week,
      up_date,
      tmp_center_hd,
      tmp_center_ecum,
      tmp_center_hdf,
      tmp_center_hf,
      tmp_center_ohdf,
      tmp_center_ohf,
      priority
    FROM ranked_machine
    WHERE rn = 1
  ),
  ptp_om_machine_info AS (
    SELECT
      pat_id,
      treat_week,
      up_date,
      elements.elemkey,
      CASE
        elements.elemkey
        WHEN ''tmp_center_hd'' THEN tmp_center_hd
        WHEN ''tmp_center_ecum'' THEN tmp_center_ecum
        WHEN ''tmp_center_hdf'' THEN tmp_center_hdf
        WHEN ''tmp_center_hf'' THEN tmp_center_hf
        WHEN ''tmp_center_ohdf'' THEN tmp_center_ohdf
        WHEN ''tmp_center_ohf'' THEN tmp_center_ohf
      END AS value_4
    FROM
      ranked_machine_info
      JOIN elements ON elements.datapattern = ''5''
  ), -- ベッド情報取得END
  -- ダイアライザ情報取得START
  ptp_dialyzer_info AS (
    SELECT
      ntss_db5_ptp_week.pat_id AS pat_id,
      ntss_db5_ptp_week.treat_week,
      COALESCE(ntss_db5_md.up_date,ntss_db5_ptp_week.up_date) AS up_date,
      ntss_db5_md.ufr_warning_max,
      ntss_db5_md.ufr_warning_min,
      ntss_db5_md.ufr_warning_reduction,
      ntss_db5_md.koa,
      COALESCE(ntss_db5_md.dialyzer_type,''0'') AS dialyzer_type,
      1 AS priority
    FROM
      ntss_db5_ptp_week
      left JOIN ntss.mst_dialyzer ntss_db5_md ON ntss_db5_md.facility_cd = ntss_db5_ptp_week.facility_cd
      AND ntss_db5_md.dialyzer_cd :: text = ntss_db5_ptp_week.ind_cond_info #>> ''{5,value}''
       AND     ntss_db5_md.facility_cd = @facilityCd
    WHERE 1 = 1
      AND ntss_db5_ptp_week.ind_cond_info IS NOT NULL
      AND ntss_db5_ptp_week.ind_cond_info <> ''[]''  
  ),
  om_dialyzer_info AS (
    SELECT
      ind_ord_main.pat_id AS pat_id,
      ind_ord_main.treat_week,
      COALESCE(ntss_db5_md.up_date,ind_ord_main.up_date) AS up_date,
      ntss_db5_md.ufr_warning_max,
      ntss_db5_md.ufr_warning_min,
      ntss_db5_md.ufr_warning_reduction,
      ntss_db5_md.koa,
      COALESCE(ntss_db5_md.dialyzer_type,''0'') AS dialyzer_type,
      2 AS priority
    FROM
      ind_ord_main
      left JOIN ntss.mst_dialyzer ntss_db5_md ON ntss_db5_md.facility_cd = ind_ord_main.facility_cd
      AND ntss_db5_md.dialyzer_cd :: text = ind_ord_main.ind_cond_info #>> ''{5,value}''
       AND     ntss_db5_md.facility_cd = @facilityCd
    WHERE 1 = 1
      AND ind_ord_main.ind_cond_info IS NOT NULL
      AND ind_ord_main.ind_cond_info <> ''[]''
  ),
  RankedInfo AS (
    SELECT
      pat_id,
      treat_week,
      up_date,
      ufr_warning_max,
      ufr_warning_min,
      ufr_warning_reduction,
      koa,
      dialyzer_type,
      ROW_NUMBER() OVER (
        PARTITION BY pat_id,
        treat_week
        ORDER BY
          CASE
            WHEN source = ''ptp'' THEN 1
            ELSE 2
          END,
          up_date DESC
      ) AS rn
    FROM
      (
        SELECT
          pat_id,
          treat_week,
          up_date,
          ufr_warning_max,
          ufr_warning_min,
          ufr_warning_reduction,
          koa,
          dialyzer_type,
          ''ptp'' AS source
        FROM
          ptp_dialyzer_info
        UNION ALL
        SELECT
          pat_id,
          treat_week,
          up_date,
          ufr_warning_max,
          ufr_warning_min,
          ufr_warning_reduction,
          koa,
          dialyzer_type,
          ''om'' AS source
        FROM
          om_dialyzer_info
      ) AS combined_info
  ),
  priority_dialyzer_info AS (
    SELECT
      pat_id,
      treat_week,
      up_date,
      ufr_warning_max,
      ufr_warning_min,
      ufr_warning_reduction,
      koa,
      dialyzer_type
    FROM
      RankedInfo
    WHERE
      rn = 1
  ),
  ind_ord_main_ptp_dialyzer AS (
    SELECT
      pat_id,
      treat_week,
      up_date,
      elements.elemkey,
      CASE
        elements.elemkey
        WHEN ''ufr_warning_max'' THEN ufr_warning_max :: text
        WHEN ''ufr_warning_min'' THEN ufr_warning_min :: text
        WHEN ''ufr_warning_reduction'' THEN ufr_warning_reduction :: text
        WHEN ''koa'' THEN koa :: text
        WHEN ''dialyzer_type'' THEN dialyzer_type :: text
      END AS value_4
    FROM
      priority_dialyzer_info
      JOIN elements ON elements.datapattern = ''4''
  ), -- ダイアライザ情報取得END
  -- 各曜日のデータ集計
  ind_ord_main_ptp_dsi AS (
    SELECT
      pat_id :: integer,
      treat_week :: integer,
      up_date :: text,
      elemkey :: text,
      value_4 :: text
    FROM
      yellow_idsi
    WHERE
      EXISTS (
        SELECT
          1
        FROM
          (
            SELECT
              pat_id,
              treat_week,
              elemkey,
              min(priority) AS min_priority
            FROM
              yellow_idsi
            GROUP BY
              pat_id,
              treat_week,
              elemkey
          ) AS priority_device
        WHERE
          yellow_idsi.pat_id = priority_device.pat_id
          AND yellow_idsi.treat_week = priority_device.treat_week
          AND yellow_idsi.elemkey = priority_device.elemkey
          AND yellow_idsi.priority = priority_device.min_priority
      )
    UNION ALL
    SELECT
      pat_id :: integer,
      treat_week :: integer,
      up_date :: text,
      elemkey :: text,
      value_4 :: text
    FROM
      ptp_om_machine_info
    UNION ALL
    SELECT
      pat_id :: integer,
      treat_week :: integer,
      up_date :: text,
      elemkey :: text,
      value_4 :: text
    FROM
      ind_ord_main_ptp_dialyzer
    UNION ALL
    SELECT
      DISTINCT ind_cond_info.pat_id :: integer,
      ind_cond_info.treat_week :: integer,
      ind_cond_info.up_date :: text,
      ind_cond_info.elemkey :: text,
      CASE
        WHEN ind_cond_info.elemkey = ''ind_cond_info-3-value''
        AND ind_cond_info.value_4 = ''-1'' THEN ntss_db5_pu_physical.dw
        ELSE ind_cond_info.value_4 :: TEXT
      END AS value_4
    FROM
      ind_cond_info
      LEFT JOIN ntss_db5_pu_physical ON ind_cond_info.pat_id = ntss_db5_pu_physical.pat_id
      AND ntss_db5_pu_physical.priority = ''1''
      AND ntss_db5_pu_physical.sortkey = ''1''
    WHERE
      EXISTS (
        SELECT
          1
        FROM
          (
            SELECT
              pat_id,
              treat_week,
              elemkey,
              min(priority) AS min_priority
            FROM
              ind_cond_info
            GROUP BY
              pat_id,
              treat_week,
              elemkey
          ) AS priority_cond
        WHERE
          ind_cond_info.pat_id = priority_cond.pat_id
          AND ind_cond_info.treat_week = priority_cond.treat_week
          AND ind_cond_info.elemkey = priority_cond.elemkey
          AND ind_cond_info.priority = priority_cond.min_priority
      )
    UNION ALL
    SELECT
      ntss_db5_ptp_week.pat_id :: integer,
      ntss_db5_ptp_week.treat_week :: integer,
      ntss_db5_ptp_week.max_ind_treat_start_date :: text AS up_date,
      elements.elemkey :: text,
      elements.defaultvalue :: text AS value_4
    FROM
      ntss_db5_ptp_week
      JOIN elements ON elements.datapattern = ''7''
    WHERE
      ntss_db5_ptp_week.priority = ''1''
  ),
  ind_ord_main_ptp_dsi_days AS (
    SELECT 
      ind_ord_main_ptp_dsi.pat_id,
      ind_ord_main_ptp_dsi.elemkey,
      max(case when ind_ord_main_ptp_dsi.treat_week = EXTRACT(ISODOW FROM CURRENT_DATE) then ind_ord_main_ptp_dsi.up_date else null end) as up_date_0,
      max(case when ind_ord_main_ptp_dsi.treat_week = EXTRACT(ISODOW FROM CURRENT_DATE) then ind_ord_main_ptp_dsi.value_4 else null end) as value_4_0,
      max(case when ind_ord_main_ptp_dsi.treat_week = ''1'' then ind_ord_main_ptp_dsi.up_date else null end) as up_date_1,
      max(case when ind_ord_main_ptp_dsi.treat_week = ''1'' then ind_ord_main_ptp_dsi.value_4 else null end) as value_4_1,
      max(case when ind_ord_main_ptp_dsi.treat_week = ''2'' then ind_ord_main_ptp_dsi.up_date else null end) as up_date_2,
      max(case when ind_ord_main_ptp_dsi.treat_week = ''2'' then ind_ord_main_ptp_dsi.value_4 else null end) as value_4_2,
      max(case when ind_ord_main_ptp_dsi.treat_week = ''3'' then ind_ord_main_ptp_dsi.up_date else null end) as up_date_3,
      max(case when ind_ord_main_ptp_dsi.treat_week = ''3'' then ind_ord_main_ptp_dsi.value_4 else null end) as value_4_3,
      max(case when ind_ord_main_ptp_dsi.treat_week = ''4'' then ind_ord_main_ptp_dsi.up_date else null end) as up_date_4,
      max(case when ind_ord_main_ptp_dsi.treat_week = ''4'' then ind_ord_main_ptp_dsi.value_4 else null end) as value_4_4,
      max(case when ind_ord_main_ptp_dsi.treat_week = ''5'' then ind_ord_main_ptp_dsi.up_date else null end) as up_date_5,
      max(case when ind_ord_main_ptp_dsi.treat_week = ''5'' then ind_ord_main_ptp_dsi.value_4 else null end) as value_4_5,
      max(case when ind_ord_main_ptp_dsi.treat_week = ''6'' then ind_ord_main_ptp_dsi.up_date else null end) as up_date_6,
      max(case when ind_ord_main_ptp_dsi.treat_week = ''6'' then ind_ord_main_ptp_dsi.value_4 else null end) as value_4_6,
      max(case when ind_ord_main_ptp_dsi.treat_week = ''7'' then ind_ord_main_ptp_dsi.up_date else null end) as up_date_7,
      max(case when ind_ord_main_ptp_dsi.treat_week = ''7'' then ind_ord_main_ptp_dsi.value_4 else null end) as value_4_7
    FROM 
      ind_ord_main_ptp_dsi
    GROUP BY 
      ind_ord_main_ptp_dsi.pat_id, ind_ord_main_ptp_dsi.elemkey
  ),
  --select5
  elements_extended AS (
    SELECT
      *,
      CASE
        WHEN elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'') THEN ''0''
        ELSE NULL
      END AS fixed_value,
      CASE
        WHEN elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'') THEN NULL
        ELSE NULL
      END AS fixed_update
    FROM
      elements
  )

SELECT
  ntss_db5_pm.pat_id AS patid,
  '''' AS hosppatid,
  '''' AS name,
  elements_extended.ctlno AS ctlno,
  elements_extended.setname AS setname,
  COALESCE(
    elements_extended.fixed_value,
    CASE
      elements_extended.datapattern
      WHEN ''1'' THEN ntss_db5_pm_dsi.value_4
      WHEN ''7'' THEN elements_extended.defaultvalue
      ELSE ind_ord_main_ptp_dsi_days.value_4_0
    END
  ) AS value,
  to_char(
    CASE
      WHEN elements_extended.elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'',''0000'') THEN ntss_db5_pm.up_date :: timestamp
      WHEN elements_extended.datapattern = ''1'' THEN ntss_db5_pm_dsi.up_date :: timestamp
      ELSE ind_ord_main_ptp_dsi_days.up_date_0 :: timestamp
    END,
    ''YYYY-MM-DD hh24:mi:ss''
  ) AS
update
,
  COALESCE(
    elements_extended.fixed_value,
    CASE
      elements_extended.datapattern
      WHEN ''1'' THEN ntss_db5_pm_dsi.value_4
      WHEN ''7'' THEN elements_extended.defaultvalue
      ELSE ind_ord_main_ptp_dsi_days.value_4_1
    END
  ) AS monvalue,
  to_char(
    CASE
      WHEN elements_extended.elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'',''0000'') THEN ntss_db5_pm.up_date :: timestamp
      WHEN elements_extended.datapattern = ''1'' THEN ntss_db5_pm_dsi.up_date :: timestamp
      ELSE ind_ord_main_ptp_dsi_days.up_date_1 :: timestamp
    END,
    ''YYYY-MM-DD hh24:mi:ss''
  ) AS monupdate,
  COALESCE(
    elements_extended.fixed_value,
    CASE
      elements_extended.datapattern
      WHEN ''1'' THEN ntss_db5_pm_dsi.value_4
      WHEN ''7'' THEN elements_extended.defaultvalue
      ELSE ind_ord_main_ptp_dsi_days.value_4_2
    END
  ) AS tuevalue,
  to_char(
    CASE
      WHEN elements_extended.elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'',''0000'') THEN ntss_db5_pm.up_date :: timestamp
      WHEN elements_extended.datapattern = ''1'' THEN ntss_db5_pm_dsi.up_date :: timestamp
      ELSE ind_ord_main_ptp_dsi_days.up_date_2 :: timestamp
    END,
    ''YYYY-MM-DD hh24:mi:ss''
  ) AS tueupdate,
  COALESCE(
    elements_extended.fixed_value,
    CASE
      elements_extended.datapattern
      WHEN ''1'' THEN ntss_db5_pm_dsi.value_4
      WHEN ''7'' THEN elements_extended.defaultvalue
      ELSE ind_ord_main_ptp_dsi_days.value_4_3
    END
  ) AS wedvalue,
  to_char(
    CASE
      WHEN elements_extended.elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'',''0000'') THEN ntss_db5_pm.up_date :: timestamp
      WHEN elements_extended.datapattern = ''1'' THEN ntss_db5_pm_dsi.up_date :: timestamp
      ELSE ind_ord_main_ptp_dsi_days.up_date_3 :: timestamp
    END,
    ''YYYY-MM-DD hh24:mi:ss''
  ) AS wedupdate,
  COALESCE(
    elements_extended.fixed_value,
    CASE
      elements_extended.datapattern
      WHEN ''1'' THEN ntss_db5_pm_dsi.value_4
      WHEN ''7'' THEN elements_extended.defaultvalue
      ELSE ind_ord_main_ptp_dsi_days.value_4_4
    END
  ) AS thuvalue,
  to_char(
    CASE
      WHEN elements_extended.elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'',''0000'') THEN ntss_db5_pm.up_date :: timestamp
      WHEN elements_extended.datapattern = ''1'' THEN ntss_db5_pm_dsi.up_date :: timestamp
      ELSE ind_ord_main_ptp_dsi_days.up_date_4 :: timestamp
    END,
    ''YYYY-MM-DD hh24:mi:ss''
  ) AS thuupdate,
  COALESCE(
    elements_extended.fixed_value,
    CASE
      elements_extended.datapattern
      WHEN ''1'' THEN ntss_db5_pm_dsi.value_4
      WHEN ''7'' THEN elements_extended.defaultvalue
      ELSE ind_ord_main_ptp_dsi_days.value_4_5
    END
  ) AS frivalue,
  to_char(
    CASE
      WHEN elements_extended.elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'',''0000'') THEN ntss_db5_pm.up_date :: timestamp
      WHEN elements_extended.datapattern = ''1'' THEN ntss_db5_pm_dsi.up_date :: timestamp
      ELSE ind_ord_main_ptp_dsi_days.up_date_5 :: timestamp
    END,
    ''YYYY-MM-DD hh24:mi:ss''
  ) AS friupdate,
  COALESCE(
    elements_extended.fixed_value,
    CASE
      elements_extended.datapattern
      WHEN ''1'' THEN ntss_db5_pm_dsi.value_4
      WHEN ''7'' THEN elements_extended.defaultvalue
      ELSE ind_ord_main_ptp_dsi_days.value_4_6
    END
  ) AS satvalue,
  to_char(
    CASE
      WHEN elements_extended.elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'',''0000'') THEN ntss_db5_pm.up_date :: timestamp
      WHEN elements_extended.datapattern = ''1'' THEN ntss_db5_pm_dsi.up_date :: timestamp
      ELSE ind_ord_main_ptp_dsi_days.up_date_6 :: timestamp
    END,
    ''YYYY-MM-DD hh24:mi:ss''
  ) AS satupdate,
  COALESCE(
    elements_extended.fixed_value,
    CASE
      elements_extended.datapattern
      WHEN ''1'' THEN ntss_db5_pm_dsi.value_4
      WHEN ''7'' THEN elements_extended.defaultvalue
      ELSE ind_ord_main_ptp_dsi_days.value_4_7
    END
  ) AS sunvalue,
  to_char(
    CASE
      WHEN elements_extended.elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'',''0000'') THEN ntss_db5_pm.up_date :: timestamp
      WHEN elements_extended.datapattern = ''1'' THEN ntss_db5_pm_dsi.up_date :: timestamp
      ELSE ind_ord_main_ptp_dsi_days.up_date_7 :: timestamp
    END,
    ''YYYY-MM-DD hh24:mi:ss''
  ) AS sunupdate
FROM
  ntss_db5_pm
  JOIN elements_extended ON TRUE
  LEFT JOIN ntss_db5_pm_dsi ON ntss_db5_pm.pat_id = ntss_db5_pm_dsi.pat_id
  AND elements_extended.elemkey = ntss_db5_pm_dsi.elemkey
  LEFT JOIN ind_ord_main_ptp_dsi_days ON ntss_db5_pm.pat_id = ind_ord_main_ptp_dsi_days.pat_id
  AND elements_extended.elemkey = ind_ord_main_ptp_dsi_days.elemkey;', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);



INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2071, '-- 【SQL_CD=-2071】
SELECT
	hosp_pat_id AS hosppatid
	,pat_id AS patid
	,CONCAT(personal_info_decrypt(pat_last_name), ''　'', personal_info_decrypt(pat_first_name)) AS name
FROM
	pat_personal_main
WHERE is_del != ''1''
	AND facility_cd = @facilityCd;
', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);