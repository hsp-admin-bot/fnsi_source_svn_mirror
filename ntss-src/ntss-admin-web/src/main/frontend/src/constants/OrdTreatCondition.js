/**
 * 治療記録(装置設定)で使用する変換定義
 */
 export const ORD_TREAT_CONDITION = {
  "14": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "透析時間",
    name: "治療時間",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "分",
    conversion: {}
  },
  "15": {
    name: "治療モード",
    unit: "",
    conversion: {
      0: "HD",
      1: "ECUM",
      2: "HDF",
      3: "HF",
      4: "HD+補液",
      6: "AFBF",
      7: "OHDF",
      8: "OHF",
      10: "I-HDF",
      9: "特殊血液浄化"
    }
  },
  "16": {
    name: "ECUM選択",
    unit: "",
    conversion: {
      0: "HD",
      1: "ECUM"
    }
  },
  "17": {
    name: "ECUM量",
    unit: "L",
    conversion: {}
  },
  "18": {
    name: "ECUM時間",
    unit: "",
    conversion: {}
  },
  "19": {
    name: "ECUM時間カウント選択",
    unit: "",
    conversion: {
      0: "含まない",
      1: "透析時間に含む"
    }
  },
  "20": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "除水目標値",
    name: "目標除水量",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "L",
    conversion: {}
  },
  "21": {
    name: "除水計算選択",
    unit: "",
    conversion: {
      0: "透析時間",
      1: "設定時刻"
    }
  },
  "22": {
    name: "除水計算優先項目選択",
    unit: "",
    conversion: {
      0: "除水速度算出",
      1: "除水量設定算出"
    }
  },
  "23": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "シングルニードル電源SW",
    name: "シングルニードル使用",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {
      1: "あり",
      0: "なし"
    }
  },
  "24": {
    name: "シングルニードル切替圧上限",
    unit: "mmHg",
    conversion: {}
  },
  "25": {
    name: "シングルニードル切替圧下限",
    unit: "mmHg",
    conversion: {}
  },
  "26": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "透析液温度設定",
    name: "透析液温度",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "℃",
    conversion: {}
  },
  "27": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "透析液流量設定値",
    name: "透析液流量",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "mL/min",
    conversion: {}
  },
  "28": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "血流量設定",
    name: "血流量",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "mL/min",
    conversion: {}
  },
  "29": {
    name: "IP使用選択",
    unit: "",
    conversion: {
      1: "使用する",
      0: "使用しない"
    }
  },
  "30": {
    // add FNSI-装置設定の小数点有効桁数の修正 徐 start
    // name: "IP速度設定0",
    name: "IP速度",
    // add FNSI-装置設定の小数点有効桁数の修正 徐 end
    unit: "L/h",
    conversion: {}
  },
  "31": {
    name: "IPスタート",
    unit: "",
    conversion: {
      0: "手動",
      1: "自動"
    }
  },
  "32": {
    name: "IPワンショットスタート",
    unit: "",
    conversion: {
      1: "自動",
      0: "手動"
    }
  },
  "33": {
    name: "IPワンショット量",
    unit: "mL",
    conversion: {}
  },
  "34": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "IP電源報知切りSW",
    name: "IP電源OKモニタ切り",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {
      0: "切",
      1: "入"
    }
  },
  "35": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "IP電源報知切り時間",
    name: "IP電源OKモニタ切り時間",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "分前",
    conversion: {}
  },
  "36": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "IP電源自動切りSW",
    name: "IP電源自動切り",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {
      0: "切",
      1: "入"
    }
  },
  "37": {
    name: "IP電源自動切り時間",
    unit: "分前",
    conversion: {}
  },
  "38": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "クリップ式気泡検出器切りSW",
    name: "動脈側気泡検出器",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {
      0: "使用する",
      1: "使用しない"
    }
  },
  "39": {
    name: "除水開始遅延時間",
    unit: "分",
    conversion: {}
  },
  "40": {
    name: "透析前体重",
    unit: "Kg",
    conversion: {}
  },
  "41": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "ＤＷ",
    name: "DW",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "Kg",
    conversion: {}
  },
  "42": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "補正値の合計",
    name: "除水補正合計",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "g",
    conversion: {}
  },
  "43": {
    name: "除水量制限",
    unit: "Kg",
    conversion: {}
  },
  "44": {
    name: "除水量計算値",
    unit: "L",
    conversion: {}
  },
  "45": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "除水補正項目名1",
    name: "除水補正項目1名称",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {}
  },
  "53": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "除水補正値1",
    name: "除水補正項目1重さ",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "g",
    conversion: {}
  },
  "54": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "除水補正項目名2",
    name: "除水補正項目2名称",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {}
  },
  "62": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "除水補正値2",
    name: "除水補正項目2重さ",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "g",
    conversion: {}
  },
  "63": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "除水補正項目名3",
    name: "除水補正項目3名称",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {}
  },
  "71": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "除水補正値3",
    name: "除水補正項目3重さ",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "g",
    conversion: {}
  },
  "72": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "除水補正項目名4",
    name: "除水補正項目4名称",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {}
  },
  "80": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "除水補正値4",
    name: "除水補正項目4重さ",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "g",
    conversion: {}
  },
  "81": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "除水補正項目名5",
    name: "除水補正項目5名称",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {}
  },
  "89": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "除水補正値5",
    name: "除水補正項目5重さ",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "g",
    conversion: {}
  },
  "90": {
    name: "濾過率",
    unit: "%",
    conversion: {}
  },
  "91": {
    name: "ヘマトクリット(Ht)",
    unit: "%",
    conversion: {}
  },
  "92": {
    name: "総タンパク(TP)",
    unit: "g/dL",
    conversion: {}
  },
  "100": {
    name: "静脈圧自動設定警報幅上限HD/ECUM",
    unit: "mmHg",
    conversion: {}
  },
  "101": {
    name: "静脈圧自動設定警報幅下限HD/ECUM",
    unit: "mmHg",
    conversion: {}
  },
  "102": {
    name: "静脈圧自動設定警報限界上限",
    unit: "mmHg",
    conversion: {}
  },
  "103": {
    name: "静脈圧自動設定警報限界下限",
    unit: "mmHg",
    conversion: {}
  },
  "104": {
    name: "静脈圧固定警報上限",
    unit: "mmHg",
    conversion: {}
  },
  "105": {
    name: "静脈圧固定警報下限",
    unit: "mmHg",
    conversion: {}
  },
  "106": {
    name: "静脈圧自動設定警報幅上限HDF/HF",
    unit: "mmHg",
    conversion: {}
  },
  "107": {
    name: "静脈圧自動設定警報幅下限HDF/HF",
    unit: "mmHg",
    conversion: {}
  },
  "108": {
    name: "静脈圧固定警報上限透析準備",
    unit: "mmHg",
    conversion: {}
  },
  "109": {
    name: "静脈圧固定警報下限透析準備",
    unit: "mmHg",
    conversion: {}
  },
  "110": {
    name: "静脈圧固定警報上限SN",
    unit: "mmHg",
    conversion: {}
  },
  "111": {
    name: "静脈圧固定警報下限SN",
    unit: "mmHg",
    conversion: {}
  },
  "112": {
    name: "液圧自動設定警報幅上限HD/ECUM",
    unit: "mmHg",
    conversion: {}
  },
  "113": {
    name: "液圧自動設定警報幅下限HD/ECUM",
    unit: "mmHg",
    conversion: {}
  },
  "114": {
    name: "液圧自動設定警報限界上限",
    unit: "mmHg",
    conversion: {}
  },
  "115": {
    name: "液圧自動設定警報限界下限",
    unit: "mmHg",
    conversion: {}
  },
  "116": {
    name: "液圧固定警報上限",
    unit: "mmHg",
    conversion: {}
  },
  "117": {
    name: "液圧固定警報下限",
    unit: "mmHg",
    conversion: {}
  },
  "118": {
    name: "液圧自動設定警報幅上限HDF/HF",
    unit: "mmHg",
    conversion: {}
  },
  "119": {
    name: "液圧自動設定警報幅下限HDF/HF",
    unit: "mmHg",
    conversion: {}
  },
  "120": {
    name: "液圧自動設定警報幅上限SN",
    unit: "mmHg",
    conversion: {}
  },
  "121": {
    name: "液圧自動設定警報幅下限SN",
    unit: "mmHg",
    conversion: {}
  },
  "122": {
    name: "液圧自動設定警報限界上限SN",
    unit: "mmHg",
    conversion: {}
  },
  "123": {
    name: "液圧自動設定警報限界下限SN",
    unit: "mmHg",
    conversion: {}
  },
  "124": {
    name: "液圧固定警報上限SN",
    unit: "mmHg",
    conversion: {}
  },
  "125": {
    name: "液圧固定警報下限SN",
    unit: "mmHg",
    conversion: {}
  },
  "126": {
    name: "TMP自動追従警報幅上限HD/ECUM",
    unit: "mmHg",
    conversion: {}
  },
  "127": {
    name: "TMP自動追従警報幅下限HD/ECUM",
    unit: "mmHg",
    conversion: {}
  },
  "128": {
    name: "TMP自動設定警報幅上限HD/ECUM",
    unit: "mmHg",
    conversion: {}
  },
  "129": {
    name: "TMP自動設定警報幅下限HD/ECUM",
    unit: "mmHg",
    conversion: {}
  },
  "130": {
    name: "TMP自動設定警報限界上限",
    unit: "mmHg",
    conversion: {}
  },
  "131": {
    name: "TMP自動設定警報限界下限",
    unit: "mmHg",
    conversion: {}
  },
  "132": {
    name: "TMP固定警報上限",
    unit: "mmHg",
    conversion: {}
  },
  "133": {
    name: "TMP固定警報下限",
    unit: "mmHg",
    conversion: {}
  },
  "134": {
    name: "TMP自動追従警報幅上限HDF/HF",
    unit: "mmHg",
    conversion: {}
  },
  "135": {
    name: "TMP自動追従警報幅下限HDF/HF",
    unit: "mmHg",
    conversion: {}
  },
  "136": {
    name: "TMP自動設定警報幅上限HDF/HF",
    unit: "mmHg",
    conversion: {}
  },
  "137": {
    name: "TMP自動設定警報幅下限HDF/HF",
    unit: "mmHg",
    conversion: {}
  },
  "138": {
    name: "TMP自動追従警報幅上限SN",
    unit: "mmHg",
    conversion: {}
  },
  "139": {
    name: "TMP自動追従警報幅下限SN",
    unit: "mmHg",
    conversion: {}
  },
  "140": {
    name: "TMP自動設定警報幅上限SN",
    unit: "mmHg",
    conversion: {}
  },
  "141": {
    name: "TMP自動設定警報幅下限SN",
    unit: "mmHg",
    conversion: {}
  },
  "142": {
    name: "TMP自動設定警報限界上限SN",
    unit: "mmHg",
    conversion: {}
  },
  "143": {
    name: "TMP自動設定警報限界下限SN",
    unit: "mmHg",
    conversion: {}
  },
  "144": {
    name: "TMP固定警報上限SN",
    unit: "mmHg",
    conversion: {}
  },
  "145": {
    name: "TMP固定警報下限SN",
    unit: "mmHg",
    conversion: {}
  },
  "146": {
    name: "ダイアライザー差圧自動設定警報幅上限HD/ECUM",
    unit: "mmHg",
    conversion: {}
  },
  "147": {
    name: "ダイアライザー差圧自動設定警報幅下限HD/ECUM",
    unit: "mmHg",
    conversion: {}
  },
  "148": {
    name: "ダイアライザー差圧固定警報上限",
    unit: "mmHg",
    conversion: {}
  },
  "149": {
    name: "ダイアライザー差圧固定警報下限",
    unit: "mmHg",
    conversion: {}
  },
  "150": {
    name: "ダイアライザー差圧自動設定警報幅上限HDF/HF",
    unit: "mmHg",
    conversion: {}
  },
  "151": {
    name: "ダイアライザー差圧自動設定警報幅下限HDF/HF",
    unit: "mmHg",
    conversion: {}
  },
  "152": {
    name: "ダイアライザー入口圧自動設定警報幅上限HD/ECUM",
    unit: "mmHg",
    conversion: {}
  },
  "153": {
    name: "ダイアライザー入口圧自動設定警報幅下限HD/ECUM",
    unit: "mmHg",
    conversion: {}
  },
  "154": {
    name: "ダイアライザー入口圧自動設定警報限界上限",
    unit: "mmHg",
    conversion: {}
  },
  "155": {
    name: "ダイアライザー入口圧自動設定警報限界下限",
    unit: "mmHg",
    conversion: {}
  },
  "156": {
    name: "ダイアライザー入口圧固定警報上限",
    unit: "mmHg",
    conversion: {}
  },
  "157": {
    name: "ダイアライザー入口圧固定警報下限",
    unit: "mmHg",
    conversion: {}
  },
  "158": {
    name: "ダイアライザー入口圧自動設定警報幅上限HDF/HF",
    unit: "mmHg",
    conversion: {}
  },
  "159": {
    name: "ダイアライザー入口圧自動設定警報幅下限HDF/HF",
    unit: "mmHg",
    conversion: {}
  },
  "160": {
    name: "ダイアライザー入口圧固定警報上限透析準備",
    unit: "mmHg",
    conversion: {}
  },
  "161": {
    name: "ダイアライザー入口圧固定警報下限透析準備",
    unit: "mmHg",
    conversion: {}
  },
  "162": {
    name: "ダイアライザー入口圧固定警報上限SN",
    unit: "mmHg",
    conversion: {}
  },
  "163": {
    name: "ダイアライザー入口圧固定警報下限SN",
    unit: "mmHg",
    conversion: {}
  },
  "164": {
    name: "初期UFR警報上限",
    unit: "mL/h/mmHg",
    conversion: {}
  },
  "165": {
    name: "初期UFR警報下限",
    unit: "mL/h/mmHg",
    conversion: {}
  },
  "166": {
    name: "UFR低下警報点",
    unit: "％",
    conversion: {}
  },
  "167": {
    name: "TMPゼロ補正警報中点HD",
    unit: "mmHg",
    conversion: {}
  },
  "168": {
    name: "TMPゼロ補正警報上限HD",
    unit: "mmHg",
    conversion: {}
  },
  "169": {
    name: "TMPゼロ補正警報下限HD",
    unit: "mmHg",
    conversion: {}
  },
  "170": {
    name: "TMPゼロ補正警報中点ECUM",
    unit: "mmHg",
    conversion: {}
  },
  "171": {
    name: "TMPゼロ補正警報上限ECUM",
    unit: "mmHg",
    conversion: {}
  },
  "172": {
    name: "TMPゼロ補正警報下限ECUM",
    unit: "mmHg",
    conversion: {}
  },
  "173": {
    name: "TMPゼロ補正警報中点HDF",
    unit: "mmHg",
    conversion: {}
  },
  "174": {
    name: "TMPゼロ補正警報上限HDF",
    unit: "mmHg",
    conversion: {}
  },
  "175": {
    name: "TMPゼロ補正警報下限HDF",
    unit: "mmHg",
    conversion: {}
  },
  "176": {
    name: "TMPゼロ補正警報中点HF",
    unit: "mmHg",
    conversion: {}
  },
  "177": {
    name: "TMPゼロ補正警報上限HF",
    unit: "mmHg",
    conversion: {}
  },
  "178": {
    name: "TMPゼロ補正警報下限HF",
    unit: "mmHg",
    conversion: {}
  },
  "179": {
    name: "血流量操作範囲上限",
    unit: "mL/min",
    conversion: {}
  },
  "180": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "IP速度操作範囲上限",
    name: "IP速度最大値",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "mL/h",
    conversion: {}
  },
  "181": {
    name: "除水速度操作範囲上限",
    unit: "L/h",
    conversion: {}
  },
  "182": {
    name: "透析液温度操作範囲上限",
    unit: "℃",
    conversion: {}
  },
  "183": {
    name: "透析液温度操作範囲下限",
    unit: "℃",
    conversion: {}
  },
  "184": {
    name: "Na注入濃度操作範囲上限",
    unit: "mEq/L",
    conversion: {}
  },
  "185": {
    name: "補液速度操作範囲上限(HDF)",
    unit: "L/h",
    conversion: {}
  },
  "186": {
    name: "補液速度操作範囲上限(HF)",
    unit: "L/h",
    conversion: {}
  },
  "187": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "ダイアライザ 尿素クリアランス",
    name: "ダイアライザ尿素クリアランス",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "mL/min",
    conversion: {}
  },
  "188": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "ダイアライザ 血流量",
    name: "ダイアライザ血流量",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "mL/min",
    conversion: {}
  },
  "189": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "ダイアライザ 透析液流量",
    name: "ダイアライザ透析液流量",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "mL/min",
    conversion: {}
  },
  "190": {
    name: "血圧自動測定間隔",
    unit: "min",
    conversion: {}
  },
  "191": {
    name: "血圧ｶﾌ選択",
    unit: "",
    conversion: {
      0: "成人",
      1: "幼児"
    }
  },
  "192": {
    name: "昇圧値",
    unit: "mmHg",
    conversion: {}
  },
  "193": {
    name: "昇圧方法選択",
    unit: "",
    conversion: {
      0: "手動",
      1: "自動",
      2: "スマート昇圧"
    }
  },
  "194": {
    name: "血圧連続測定動作選択",
    unit: "",
    conversion: {
      0: "12分",
      1: "5分"
    }
  },
  "195": {
    name: "血圧測定方法選択",
    unit: "",
    //FNSI 7199-add 血圧測定方法選択の転換 ljx start
    conversion: {
      1: "降圧測定",
      2: "昇圧測定"
    }
    //FNSI 7199-add 血圧測定方法選択の転換 ljx end
  },
  "196": {
    name: "BV-UFC使用選択",
    unit: "",
    conversion: {
      0: "使用しない",
      1: "使用する"
    }
  },
  "197": {
    name: "UFC期間除水速度上限",
    unit: "L/h",
    conversion: {}
  },
  "198": {
    name: "UFC期間除水速度下限",
    unit: "L/h",
    conversion: {}
  },
  "199": {
    name: "開始期間 時間",
    unit: "min",
    conversion: {}
  },
  // add FNSI-改修内容 プログラム補液削除 房 start
  "200": {
    name: "I-HDF 補液量設定",
    unit: "mL",
    conversion: {}
  },
  "201": {
    name: "I-HDF 補液速度",
    unit: "mL/min",
    conversion: {}
  },
  "202": {
    name: "I-HDF 補液周期",
    unit: "min",
    conversion: {}
  },
  "203": {
    name: "I-HDF 補液開始時間",
    unit: "min",
    conversion: {}
  },
  "204": {
    name: "I-HDF 除水再開時間",
    unit: "min",
    conversion: {}
  },
  "205": {
    name: "I-HDF 総補液量上限",
    unit: "L",
    conversion: {}
  },
  // add FNSI-改修内容 プログラム補液削除 房 end
  "206": {
    name: "開始期間 除水速度倍率",
    unit: "",
    conversion: {}
  },
  "207": {
    name: "固定倍率除水期間 時間",
    unit: "min",
    conversion: {}
  },
  "208": {
    name: "固定倍率除水期間 除水速度倍率",
    unit: "",
    conversion: {}
  },
  "209": {
    name: "固定倍率除水終了条件 最高血圧",
    unit: "mmHg",
    conversion: {}
  },
  "210": {
    name: "固定倍率除水終了条件 脈拍",
    unit: "bpm",
    conversion: {}
  },
  "211": {
    name: "最高血圧上限",
    unit: "mmHg",
    conversion: {}
  },
  "212": {
    name: "最高血圧下限",
    unit: "mmHg",
    conversion: {}
  },
  "213": {
    name: "最低血圧上限",
    unit: "mmHg",
    conversion: {}
  },
  "214": {
    name: "最低血圧下限",
    unit: "mmHg",
    conversion: {}
  },
  "215": {
    name: "平均血圧上限",
    unit: "mmHg",
    conversion: {}
  },
  "216": {
    name: "平均血圧下限",
    unit: "mmHg",
    conversion: {}
  },
  "217": {
    name: "脈拍数上限",
    unit: "bpm",
    conversion: {}
  },
  "218": {
    name: "脈拍数下限",
    unit: "bpm",
    conversion: {}
  },
  "219": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    name: "最高血圧上限警報 血液ポンプ 動作選択",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {
      0: "OFF",
      1: "ON"
    }
  },
  "220": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "最高血圧下限警報 BP 動作選択",
    name: "最高血圧下限警報 血液ポンプ 動作選択",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {
      0: "OFF",
      1: "ON"
    }
  },
  "221": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "最高血圧上限警報 除水 動作選択",
    name: "最高血圧上限警報 除水ポンプ 動作選択",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {
      0: "OFF",
      1: "ON"
    }
  },
  "222": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "最高血圧下限警報 除水 動作選択",
    name: "最高血圧下限警報 除水ポンプ 動作選択",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {
      0: "OFF",
      1: "ON"
    }
  },
  "223": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "最高血圧上限警報 Na注入 動作選択",
    name: "最高血圧上限警報 Na注入ポンプ 動作選択",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {
      0: "OFF",
      1: "ON"
    }
  },
  "224": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "最高血圧下限警報 Na注入 動作選択",
    name: "最高血圧下限警報 Na注入ポンプ 動作選択",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {
      0: "OFF",
      1: "ON"
    }
  },
  "225": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "最高血圧上限警報 補液 動作選択",
    name: "最高血圧上限警報 補液ポンプ 動作選択",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {
      0: "OFF",
      1: "ON"
    }
  },
  "226": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "最高血圧下限警報 補液 動作選択",
    name: "最高血圧下限警報 補液ポンプ 動作選択",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {
      0: "OFF",
      1: "ON"
    }
  },
  "227": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "最高血圧上限警報 BP 速度",
    name: "最高血圧上限警報 血液ポンプ 速度",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "mL/min",
    conversion: {}
  },
  "228": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "最高血圧下限警報 BP 速度",
    name: "最高血圧下限警報 血液ポンプ 速度",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "mL/min",
    conversion: {}
  },
  "229": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "最高血圧上限警報 除水 速度",
    name: "最高血圧上限警報 除水ポンプ 速度",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "L/h",
    conversion: {}
  },
  "230": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "最高血圧下限警報 除水 速度",
    name: "最高血圧下限警報 除水ポンプ 速度",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "L/h",
    conversion: {}
  },
  "231": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "最高血圧上限警報 Na注入 速度",
    name: "最高血圧上限警報 Na注入ポンプ 速度",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "mEq/L",
    conversion: {}
  },
  "232": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "最高血圧下限警報 Na注入 速度",
    name: "最高血圧下限警報 Na注入ポンプ 速度",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "mEq/L",
    conversion: {}
  },
  "233": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "最高血圧上限警報 補液 速度",
    name: "最高血圧上限警報 補液ポンプ 速度",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "L/h",
    conversion: {}
  },
  "234": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "最高血圧下限警報 補液 速度",
    name: "最高血圧下限警報 補液ポンプ 速度",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "L/h",
    conversion: {}
  },
  "235": {
    name: "警報連動測定開始時刻",
    unit: "min",
    conversion: {}
  },
  "236": {
    name: "治療条件連動測定時刻",
    unit: "min",
    conversion: {}
  },
  "237": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "血圧測定自動停止(警報発生)",
    name: "静脈圧警報発生時の血圧測定",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {
      0: "継続",
      1: "中断・終了"
    }
  },
  "238": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "血圧測定自動停止(条件変更)",
    name: "血流量または除水速度変更時の血圧測定",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {
      0: "継続",
      1: "中断・終了"
    }
  },
  "239": {
    name: "高速測定選択",
    unit: "",
    conversion: {
      0: "なし",
      1: "あり"
    }
  },
  "240": {
    name: "TMP監視モード",
    unit: "",
    conversion: {}
  },
  "241": {
    name: "TMPゼロ補正の選択",
    unit: "",
    conversion: {
      0: "あり",
      1: "なし"
    }
  },
  "242": {
    name: "静脈圧自動設定警報監視有無",
    unit: "",
    conversion: {
      0: "無",
      1: "有"
    }
  },
  "243": {
    name: "ダイアライザー血液入口圧自動設定警報監視有無",
    unit: "",
    conversion: {
      0: "無",
      1: "有"
    }
  },
  "244": {
    name: "透析液圧自動設定警報監視有無",
    unit: "",
    conversion: {
      0: "無",
      1: "有"
    }
  },
  "245": {
    name: "TMP自動設定警報監視有無",
    unit: "",
    conversion: {
      0: "無",
      1: "有"
    }
  },
  "246": {
    name: "差圧自動設定警報監視有無",
    unit: "",
    conversion: {
      0: "無",
      1: "有"
    }
  },
  "247": {
    name: "Na濃度自動設定警報監視有無",
    unit: "",
    conversion: {
      0: "無",
      1: "有"
    }
  },
  "248": {
    name: "固定倍率除水終了条件 ΔBV",
    unit: "%",
    conversion: {}
  },
  "249": {
    name: "終了前期間 時間",
    unit: "min",
    conversion: {}
  },
  "250": {
    name: "透析液濃度プログラム自動設定警報幅上限",
    unit: "%",
    conversion: {}
  },
  "251": {
    name: "透析液濃度プログラム自動設定警報幅下限",
    unit: "%",
    conversion: {}
  },
  "252": {
    name: "B液濃度プログラム自動設定警報幅上限",
    unit: "%",
    conversion: {}
  },
  "253": {
    name: "B液濃度プログラム自動設定警報幅下限",
    unit: "%",
    conversion: {}
  },
  "254": {
    name: "Na濃度自動設定警報幅上限",
    unit: "mEq/L",
    conversion: {}
  },
  "255": {
    name: "Na濃度自動設定警報幅下限",
    unit: "mEq/L",
    conversion: {}
  },
  "256": {
    name: "Na濃度固定警報上限",
    unit: "mEq/L",
    conversion: {}
  },
  "257": {
    name: "Na濃度固定警報下限",
    unit: "mEq/L",
    conversion: {}
  },
  "258": {
    name: "アクセス再循環測定使用選択",
    unit: "",
    conversion: {
      0: "使用しない",
      1: "使用する"
    }
  },
  "259": {
    name: "自動測定1",
    unit: "",
    conversion: {}
  },
  "260": {
    name: "ΔBV低下警報点1",
    unit: "%",
    conversion: {}
  },
  "261": {
    name: "ΔBV低下警報点2",
    unit: "%",
    conversion: {}
  },
  "262": {
    name: "ΔBV変化率警報点",
    unit: "%/min",
    conversion: {}
  },
  "263": {
    name: "自動測定2",
    unit: "",
    conversion: {}
  },
  "264": {
    name: "自動測定3",
    unit: "",
    conversion: {}
  },
  "265": {
    name: "自動測定4",
    unit: "",
    conversion: {}
  },
  "266": {
    name: "自動測定5",
    unit: "",
    conversion: {}
  },
  "267": {
    name: "ブラッドボリューム計使用の選択",
    unit: "",
    conversion: {
      0: "使用しない",
      1: "使用する"
    }
  },
  "268": {
    name: "透析液流量 設定方法の選択",
    unit: "",
    conversion: {}
  },
  "269": {
    name: "透析液流量 比率設定値",
    unit: "",
    conversion: {}
  },
  "270": {
    name: "D-FAS 返血 動脈側返血使用選択",
    unit: "",
    conversion: {
      0: "使用しない",
      1: "使用する"
    }
  },
  "271": {
    name: "開始時ΔBV基準値",
    unit: "%",
    conversion: {}
  },
  "272": {
    name: "ΔBV基準線 指数1",
    unit: "",
    conversion: {}
  },
  "273": {
    name: "ΔBV基準線 指数2",
    unit: "",
    conversion: {}
  },
  "274": {
    name: "ΔBV基準線 指数3",
    unit: "",
    conversion: {}
  },
  "275": {
    name: "終了時ΔBV基準値",
    unit: "%",
    conversion: {}
  },
  "277": {
    name: "ΔBV除水低下速度",
    unit: "L/h",
    conversion: {}
  },
  "278": {
    name: "ΔBV除水低下遅延時間",
    unit: "min",
    conversion: {}
  },
  "281": {
    name: "再循環率報知",
    unit: "%",
    conversion: {}
  },
  "282": {
    name: "透析量プログラム使用選択",
    unit: "",
    conversion: {
      0: "使用しない",
      1: "使用する"
    }
  },
  "283": {
    name: "体液量計算時後体重",
    unit: "",
    conversion: {}
  },
  "284": {
    name: "体液量+補正値",
    unit: "",
    conversion: {}
  },
  "285": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "目標後体重",
    name: "目標体重",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {}
  },
  "286": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "標準血流量",
    name: "血流量",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {}
  },
  "287": {
    name: "KoA",
    unit: "",
    conversion: {}
  },
  "288": {
    name: "目標Kt/V",
    unit: "",
    conversion: {}
  },
  "290": {
    name: "UFRプログラム電源SW",
    unit: "",
    conversion: {
      0: "切り",
      1: "入り[ステップ]",
      2: "入り[コース]"
    }
  },
  "291": {
    name: "治療モード1",
    unit: "",
    conversion: {
      0: "HD",
      1: "ECUM"
    }
  },
  "292": {
    name: "治療モード2",
    unit: "",
    conversion: {
      0: "HD",
      1: "ECUM"
    }
  },
  "293": {
    name: "治療モード3",
    unit: "",
    conversion: {
      0: "HD",
      1: "ECUM"
    }
  },
  "294": {
    name: "治療モード4",
    unit: "",
    conversion: {
      0: "HD",
      1: "ECUM"
    }
  },
  "295": {
    name: "治療モード5",
    unit: "",
    conversion: {
      0: "HD",
      1: "ECUM"
    }
  },
  "296": {
    name: "治療モード6",
    unit: "",
    conversion: {
      0: "HD",
      1: "ECUM"
    }
  },
  "297": {
    name: "治療モード7",
    unit: "",
    conversion: {
      0: "HD",
      1: "ECUM"
    }
  },
  "298": {
    name: "治療モード8",
    unit: "",
    conversion: {
      0: "HD",
      1: "ECUM"
    }
  },
  "299": {
    name: "治療モード9",
    unit: "",
    conversion: {
      0: "HD",
      1: "ECUM"
    }
  },
  "300": {
    name: "治療モード10",
    unit: "",
    conversion: {
      0: "HD",
      1: "ECUM"
    }
  },
  "301": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "UFRプログラム指数1",
    name: "除水プログラム指数1",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {}
  },
  "302": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "UFRプログラム指数2",
    name: "除水プログラム指数2",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {}
  },
  "303": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "UFRプログラム指数3",
    name: "除水プログラム指数3",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {}
  },
  "304": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "UFRプログラム指数4",
    name: "除水プログラム指数4",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {}
  },
  "305": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "UFRプログラム指数5",
    name: "除水プログラム指数5",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {}
  },
  "306": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "UFRプログラム指数6",
    name: "除水プログラム指数6",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {}
  },
  "307": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "UFRプログラム指数7",
    name: "除水プログラム指数7",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {}
  },
  "308": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "UFRプログラム指数8",
    name: "除水プログラム指数8",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {}
  },
  "309": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "UFRプログラム指数9",
    name: "除水プログラム指数9",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {}
  },
  "310": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "UFRプログラム指数10",
    name: "除水プログラム指数10",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {}
  },
  "311": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "UFRプログラム最終位置",
    name: "除水プログラム最終位置",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {}
  },
  "312": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "UFRプログラムコース",
    name: "除水プログラムコース",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {}
  },
  "313": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "UFRプログラム開始数値",
    name: "除水プログラム開始数値",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {}
  },
  "314": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "UFRプログラム終了数値",
    name: "除水プログラム終了数値",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {}
  },
  "315": {
    name: "Na注入プログラム電源SW",
    unit: "",
    conversion: {
      0: "切り",
      1: "入り[ステップ]",
      2: "入り[コース]"
    }
  },
  "316": {
    name: "Na注入プログラム設定1",
    unit: "mEq/L",
    conversion: {}
  },
  "317": {
    name: "Na注入プログラム設定2",
    unit: "mEq/L",
    conversion: {}
  },
  "318": {
    name: "Na注入プログラム設定3",
    unit: "mEq/L",
    conversion: {}
  },
  "319": {
    name: "Na注入プログラム設定4",
    unit: "mEq/L",
    conversion: {}
  },
  "320": {
    name: "Na注入プログラム設定5",
    unit: "mEq/L",
    conversion: {}
  },
  "321": {
    name: "Na注入プログラム設定6",
    unit: "mEq/L",
    conversion: {}
  },
  "322": {
    name: "Na注入プログラム設定7",
    unit: "mEq/L",
    conversion: {}
  },
  "323": {
    name: "Na注入プログラム設定8",
    unit: "mEq/L",
    conversion: {}
  },
  "324": {
    name: "Na注入プログラム設定9",
    unit: "mEq/L",
    conversion: {}
  },
  "325": {
    name: "Na注入プログラム設定10",
    unit: "mEq/L",
    conversion: {}
  },
  "326": {
    name: "Na注入プログラム切替時間",
    unit: "分",
    conversion: {}
  },
  "327": {
    name: "Na注入プログラム UFRプロとの連動選択",
    unit: "",
    conversion: {
      0: "OFF",
      1: "ON"
    }
  },
  "328": {
    name: "Na注入プログラムコース",
    unit: "",
    conversion: {}
  },
  "329": {
    name: "Na注入プログラム開始数値",
    unit: "mEq/L",
    conversion: {}
  },
  "330": {
    name: "Na注入プログラム終了数値",
    unit: "mEq/L",
    conversion: {}
  },
  "331": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "D-FAS 脱血 同時脱血 脱血量",
    name: "D-FAS 脱血 同時脱血脱血量",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "mL",
    conversion: {}
  },
  "332": {
    name: "D-FAS 脱血 片側脱血への切替え透析液圧",
    unit: "mmHg",
    conversion: {}
  },
  "333": {
    name: "D-FAS 脱血 脱血速度",
    unit: "mL/min",
    conversion: {}
  },
  "334": {
    name: "D-FAS 脱血 片側脱血(除水なし) 脱血量",
    unit: "mL",
    conversion: {}
  },
  "335": {
    //mod FNSI 外結バッグ69 房 start
    // FNSI-add 装置設定画面表示の修正 徐 start
    name: "D-FAS 治療 治療開始時 血液ポンプ速度",
    // name: "D-FAS 治療 治療開始時血流量",
    // unit: "",
    // conversion: {
    //   0: "使用しない",
    //   1: "使用する"
    // }
    unit: "mL/min",
    conversion: {}
    // FNSI-add 装置設定画面表示の修正 徐 end
    //mod FNSI 外結バッグ69 房 end
  },
  "336": {
    name: "緊急補液 補液速度",
    unit: "mL/min",
    conversion: {}
  },
  "337": {
    name: "緊急補液 補液量",
    unit: "mL",
    conversion: {}
  },
  "338": {
    name: "D-FAS 脱血 片側脱血(除水あり) 脱血量",
    unit: "mL",
    conversion: {}
  },
  "339": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "D-FAS 脱血 脱血方法選択",
    name: "D-FAS 脱血 脱血方法",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {
      0: "同時脱血",
      1: "片側脱血(除水あり)",
      2: "片側脱血(除水なし)"
    }
  },
  "340": {
    name: "濃度プログラム電源SW",
    unit: "",
    conversion: {
      0: "切り",
      1: "入り[B,A共通ステップ]",
      2: "入り[B,A別ステップ]",
      3: "入り[B,A別コース]"
    }
  },
  "341": {
    name: "透析液濃度プログラム設定1",
    unit: "mS/cm",
    conversion: {}
  },
  "342": {
    name: "透析液濃度プログラム設定2",
    unit: "mS/cm",
    conversion: {}
  },
  "343": {
    name: "透析液濃度プログラム設定3",
    unit: "mS/cm",
    conversion: {}
  },
  "344": {
    name: "透析液濃度プログラム設定4",
    unit: "mS/cm",
    conversion: {}
  },
  "345": {
    name: "透析液濃度プログラム設定5",
    unit: "mS/cm",
    conversion: {}
  },
  "346": {
    name: "透析液濃度プログラム設定6",
    unit: "mS/cm",
    conversion: {}
  },
  "347": {
    name: "透析液濃度プログラム設定7",
    unit: "mS/cm",
    conversion: {}
  },
  "348": {
    name: "透析液濃度プログラム設定8",
    unit: "mS/cm",
    conversion: {}
  },
  "349": {
    name: "透析液濃度プログラム設定9",
    unit: "mS/cm",
    conversion: {}
  },
  "350": {
    name: "透析液濃度プログラム設定10",
    unit: "mS/cm",
    conversion: {}
  },
  "351": {
    name: "B液濃度プログラム設定1",
    unit: "mS/cm",
    conversion: {}
  },
  "352": {
    name: "B液濃度プログラム設定2",
    unit: "mS/cm",
    conversion: {}
  },
  "353": {
    name: "B液濃度プログラム設定3",
    unit: "mS/cm",
    conversion: {}
  },
  "354": {
    name: "B液濃度プログラム設定4",
    unit: "mS/cm",
    conversion: {}
  },
  "355": {
    name: "B液濃度プログラム設定5",
    unit: "mS/cm",
    conversion: {}
  },
  "356": {
    name: "B液濃度プログラム設定6",
    unit: "mS/cm",
    conversion: {}
  },
  "357": {
    name: "B液濃度プログラム設定7",
    unit: "mS/cm",
    conversion: {}
  },
  "358": {
    name: "B液濃度プログラム設定8",
    unit: "mS/cm",
    conversion: {}
  },
  "359": {
    name: "B液濃度プログラム設定9",
    unit: "mS/cm",
    conversion: {}
  },
  "360": {
    name: "B液濃度プログラム設定10",
    unit: "mS/cm",
    conversion: {}
  },
  "361": {
    name: "透析液濃度プログラムステップ切替無し コース",
    unit: "",
    conversion: {}
  },
  "362": {
    name: "透析液濃度プログラム開始数値",
    unit: "mS/cm",
    conversion: {}
  },
  "363": {
    name: "透析液濃度プログラム終了数値",
    unit: "mS/cm",
    conversion: {}
  },
  "364": {
    name: "B液濃度プログラムステップ切替無し コース",
    unit: "",
    conversion: {}
  },
  "365": {
    name: "B液濃度プログラム開始数値",
    unit: "mS/cm",
    conversion: {}
  },
  "366": {
    name: "B液濃度プログラム終了数値",
    unit: "mS/cm",
    conversion: {}
  },
  "367": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "濃度プログラム切替時間",
    name: "透析液濃度プログラム工程切替時間",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "分",
    conversion: {}
  },
  "368": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "濃度プログラム UFRプロとの連動選択",
    name: "除水プログラムとの連動選択",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {
      0: "OFF",
      1: "ON"
    }
  },
  "369": {
    name: "DP=Qd+Qs(補液速度加算)",
    unit: "",
    conversion: {
      1: "使用しない",
      2: "使用する"
    }
  },
  "370": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "返血機能 使用液量",
    name: "返血 使用液量",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "mL",
    conversion: {}
  },
  "371": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "返血機能 流速",
    name: "返血 流速",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "mL/min",
    conversion: {}
  },
  "372": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "返血機能 血液判別器による終了選択",
    name: "返血 血液判別器による終了選択",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {
      0: "OFF",
      1: "ON"
    }
  },
  "373": {
    name: "D-FAS 返血 静脈側返血速度",
    unit: "mL/min",
    conversion: {}
  },
  "374": {
    name: "D-FAS 返血 静脈側最大返血量",
    unit: "mL",
    conversion: {}
  },
  "376": {
    name: "D-FAS 返血 動脈側最大返血量",
    unit: "mL",
    conversion: {}
  },
  "377": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "D-FAS 返血 静脈側返血 血液判別器使用選択",
    name: "D-FAS 返血 静脈側返血血液判別器使用選択",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {
      0: "使用しない",
      1: "使用する"
    }
  },
  "378": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "D-FAS 返血 動脈側返血 血液判別器使用選択",
    name: "D-FAS 返血 動脈側返血血液判別器使用選択",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {
      0: "使用しない",
      1: "使用する"
    }
  },
  "379": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "OHDF 補液速度比率",
    name: "補液比率(OHDF用)",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "%",
    conversion: {}
  },
  "380": {
    name: "補液速度",
    unit: "L/h",
    conversion: {}
  },
  "381": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "補液温度設定値",
    name: "補液温度",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "℃",
    conversion: {}
  },
  "382": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "補液量設定値",
    name: "補液量",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "L",
    conversion: {}
  },
  "383": {
    name: "補液量設定値制限(OHDF・OHF用)",
    unit: "L",
    conversion: {}
  },
  "384": {
    name: "AFBF 補液比率使用選択",
    unit: "",
    conversion: {
      // mod #9916 by zhangruixue 2023-10-13 --start
      0: "使用しない",
      1: "使用する"
      // mod #9916 by zhangruixue 2023-10-13 --end
    }
  },
  "385": {
    name: "AFBF 補液比率",
    unit: "%",
    conversion: {}
  },
  "386": {
    name: "補液速度設定範囲上限(AFBF)",
    unit: "L/h",
    conversion: {}
  },
  "387": {
    name: "補液速度設定範囲下限(AFBF)",
    unit: "L/h",
    conversion: {}
  },
  "388": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "補液選択(前・後)",
    name: "補液選択",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {
      1: "前",
      0: "後"
    }
  },
  "389": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "OHDF/OHF補液計算優先項目選択",
    name: "補液計算優先項目(OHDF・OHF用)",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {
      0: "補液速度算出",
      1: "補液量設定算出",
      2: "補液比率",
      // add #9916 by zhangruixue 2023-10-13 --start
      3: "濾過率から算出"
      // add #9916 by zhangruixue 2023-10-13 --end
    }
  },
  "390": {
    name: "TMPゼロ補正警報中点OHDF",
    unit: "mmHg",
    conversion: {}
  },
  "391": {
    name: "TMPゼロ補正警報上限OHDF",
    unit: "mmHg",
    conversion: {}
  },
  "392": {
    name: "TMPゼロ補正警報下限OHDF",
    unit: "mmHg",
    conversion: {}
  },
  "393": {
    name: "TMPゼロ補正警報中点OHF",
    unit: "mmHg",
    conversion: {}
  },
  "394": {
    name: "TMPゼロ補正警報上限OHF",
    unit: "mmHg",
    conversion: {}
  },
  "395": {
    name: "TMPゼロ補正警報下限OHF",
    unit: "mmHg",
    conversion: { 0: "使用しない", 1: "使用する" }
  },
  "396": {
    name: "補液速度操作範囲上限(OHDF)",
    unit: "L/h",
    conversion: {}
  },
  "397": {
    name: "補液速度操作範囲上限(OHF)",
    unit: "L/h",
    conversion: {}
  },
  "398": {
    name: "補液開始遅延時間",
    unit: "分",
    conversion: {}
  },
  "400": {
    name: "QBプログラム血流量1",
    unit: "mL/min",
    conversion: {}
  },
  "401": {
    name: "QBプログラム血流量2",
    unit: "mL/min",
    conversion: {}
  },
  "402": {
    name: "QBプログラム血流量3",
    unit: "mL/min",
    conversion: {}
  },
  "403": {
    name: "QBプログラム血流量4",
    unit: "mL/min",
    conversion: {}
  },
  "404": {
    name: "QBプログラム血流量5",
    unit: "mL/min",
    conversion: {}
  },
  "405": {
    name: "QBプログラム血流量6",
    unit: "mL/min",
    conversion: {}
  },
  "406": {
    name: "QBプログラム血流量7",
    unit: "mL/min",
    conversion: {}
  },
  "407": {
    name: "QBプログラム血流量8",
    unit: "mL/min",
    conversion: {}
  },
  "408": {
    name: "QBプログラム血流量9",
    unit: "mL/min",
    conversion: {}
  },
  "409": {
    name: "QBプログラム血流量10",
    unit: "mL/min",
    conversion: {}
  },
  "410": {
    name: "QDプログラム透析液流量1",
    unit: "mL/min",
    conversion: {}
  },
  "411": {
    name: "QDプログラム透析液流量2",
    unit: "mL/min",
    conversion: {}
  },
  "412": {
    name: "QDプログラム透析液流量3",
    unit: "mL/min",
    conversion: {}
  },
  "413": {
    name: "QDプログラム透析液流量4",
    unit: "mL/min",
    conversion: {}
  },
  "414": {
    name: "QDプログラム透析液流量5",
    unit: "mL/min",
    conversion: {}
  },
  "415": {
    name: "QDプログラム透析液流量6",
    unit: "mL/min",
    conversion: {}
  },
  "416": {
    name: "QDプログラム透析液流量7",
    unit: "mL/min",
    conversion: {}
  },
  "417": {
    name: "QDプログラム透析液流量8",
    unit: "mL/min",
    conversion: {}
  },
  "418": {
    name: "QDプログラム透析液流量9",
    unit: "mL/min",
    conversion: {}
  },
  "419": {
    name: "QDプログラム透析液流量10",
    unit: "mL/min",
    conversion: {}
  },
  "420": {
    name: "QB,QBプログラム切替時間1",
    unit: "分",
    conversion: {}
  },
  "421": {
    name: "QB,QBプログラム切替時間2",
    unit: "分",
    conversion: {}
  },
  "422": {
    name: "QB,QBプログラム切替時間3",
    unit: "分",
    conversion: {}
  },
  "423": {
    name: "QB,QBプログラム切替時間4",
    unit: "分",
    conversion: {}
  },
  "424": {
    name: "QB,QBプログラム切替時間5",
    unit: "分",
    conversion: {}
  },
  "425": {
    name: "QB,QBプログラム切替時間6",
    unit: "分",
    conversion: {}
  },
  "426": {
    name: "QB,QBプログラム切替時間7",
    unit: "分",
    conversion: {}
  },
  "427": {
    name: "QB,QBプログラム切替時間8",
    unit: "分",
    conversion: {}
  },
  "428": {
    name: "QB,QBプログラム切替時間9",
    unit: "分",
    conversion: {}
  },
  "429": {
    name: "QB,QDプログラム最大ステップ数",
    unit: "",
    conversion: {}
  },
  "430": {
    name: "QBプログラム電源",
    unit: "",
    conversion: {
      0: "切",
      1: "入"
    }
  },
  "431": {
    name: "QDプログラム電源",
    unit: "",
    conversion: {
      0: "切",
      1: "入"
    }
  },
  "432": {
    name: "I-HDFプログラム使用選択",
    unit: "",
    conversion: {
      0: "使用しない",
      1: "使用する"
    }
  },
  "433": {
    name: "予定補液回数",
    unit: "回",
    conversion: {}
  },
  "434": {
    name: "補液バランス制限",
    unit: "mL",
    conversion: {}
  },
  "435": {
    name: "補液量01",
    unit: "mL",
    conversion: {}
  },
  "436": {
    name: "補液量02",
    unit: "mL",
    conversion: {}
  },
  "437": {
    name: "補液量03",
    unit: "mL",
    conversion: {}
  },
  "438": {
    name: "補液量04",
    unit: "mL",
    conversion: {}
  },
  "439": {
    name: "補液量05",
    unit: "mL",
    conversion: {}
  },
  "440": {
    name: "補液量06",
    unit: "mL",
    conversion: {}
  },
  "441": {
    name: "補液量07",
    unit: "mL",
    conversion: {}
  },
  "442": {
    name: "補液量08",
    unit: "mL",
    conversion: {}
  },
  "443": {
    name: "補液量09",
    unit: "mL",
    conversion: {}
  },
  "444": {
    name: "補液量10",
    unit: "mL",
    conversion: {}
  },
  "445": {
    name: "補液量11",
    unit: "mL",
    conversion: {}
  },
  "446": {
    name: "補液量12",
    unit: "mL",
    conversion: {}
  },
  "447": {
    name: "補液量13",
    unit: "mL",
    conversion: {}
  },
  "448": {
    name: "補液量14",
    unit: "mL",
    conversion: {}
  },
  "449": {
    name: "補液量15",
    unit: "mL",
    conversion: {}
  },
  "450": {
    name: "補液量16",
    unit: "mL",
    conversion: {}
  },
  "451": {
    name: "回収量01",
    unit: "mL",
    conversion: {}
  },
  "452": {
    name: "回収量02",
    unit: "mL",
    conversion: {}
  },
  "453": {
    name: "回収量03",
    unit: "mL",
    conversion: {}
  },
  "454": {
    name: "回収量04",
    unit: "mL",
    conversion: {}
  },
  "455": {
    name: "回収量05",
    unit: "mL",
    conversion: {}
  },
  "456": {
    name: "回収量06",
    unit: "mL",
    conversion: {}
  },
  "457": {
    name: "回収量07",
    unit: "mL",
    conversion: {}
  },
  "458": {
    name: "回収量08",
    unit: "mL",
    conversion: {}
  },
  "459": {
    name: "回収量09",
    unit: "mL",
    conversion: {}
  },
  "460": {
    name: "回収量10",
    unit: "mL",
    conversion: {}
  },
  "461": {
    name: "回収量11",
    unit: "mL",
    conversion: {}
  },
  "462": {
    name: "回収量12",
    unit: "mL",
    conversion: {}
  },
  "463": {
    name: "回収量13",
    unit: "mL",
    conversion: {}
  },
  "464": {
    name: "回収量14",
    unit: "mL",
    conversion: {}
  },
  "465": {
    name: "回収量15",
    unit: "mL",
    conversion: {}
  },
  "466": {
    name: "回収量16",
    unit: "mL",
    conversion: {}
  },
  "467": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "ダイアライザー膜面積",
    name: "ダイアライザ膜面積",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {}
  },
  "468": {
    name: "VA確認報知基準値(静的静脈圧)",
    unit: "mmHg",
    conversion: {}
  },
  "469": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "VA確認報知基準値(アクセス内圧力比率)",
    name: "VA確認報知基準値(IAP ratio)",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "",
    conversion: {}
  },
  "470": {
    name: "静的静脈圧記録 自動実施選択",
    unit: "",
    conversion: {
      1: "実施しない",
      2: "脱血時",
      3: "返血時"
    }
  },
  "471": {
    name: "血圧測定 自動実施選択",
    unit: "",
    conversion: {
      0: "実施しない",
      1: "実施する"
    }
  },
  "472": {
    name: "TMP閾値 速度低下",
    unit: "mmHg",
    conversion: {}
  },
  "473": {
    name: "TMP閾値 速度復帰",
    unit: "mmHg",
    conversion: {}
  },
  "474": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "補液量 速度低下",
    name: "速度変化率 速度低下",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "%",
    conversion: {}
  },
  "475": {
    // FNSI-add 装置設定画面表示の修正 徐 start
    // name: "補液量 速度復帰",
    name: "速度変化率 速度復帰",
    // FNSI-add 装置設定画面表示の修正 徐 end
    unit: "%",
    conversion: {}
  // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 start
  //}
  },
  "476": {
    name: "ΔSO2低下報知点",
    unit: "%",
    conversion: {}
  }
  // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 end
};
