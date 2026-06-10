// --------------------------------------
// 検査項目マスタの定義
// --------------------------------------

// システムに初期登録される計算式定義
export const examItemSystemDefaultCalcList = [
  {
    name: "",
    formula: "",
    caption: ""
  },
  {
    name: "透析量(Kt/V)",
    formula: "-ln(透析後BUN/透析前BUN)",
    formulaId: "1",
    caption: ""
  },
  {
    name: "透析量(Kt/Ve)",
    formula: "Kt/Vsp - 0.6 * Kt/Vsp / 透析時間 + 0.03",
    formulaId: "2",
    caption: ""
  },
  {
    name: "透析量(Kt/Vsp)",
    formula: "-ln[(透析後BUN/透析前BUN) - 0.008 * 透析時間] + [(4 - 3.5 * (透析後BUN/透析前BUN)] * 除水積算値 / 後体重",
    formulaId: "3",
    caption: ""
  },
  {
    name: "透析量(Daugirdas Kt/V)",
    formula: "-ln[(透析後BUN/透析前BUN) - 0.008 * 透析時間] + [(4 - 3.5 * (透析後BUN/透析前BUN)] * 体重減少量 / 後体重",
    formulaId: "4",
    caption: ""
  },
  {
    name: "BUN 除去率",
    formula: "((透析前BUN-透析後BUN)/透析前BUN)*100",
    formulaId: "5",
    caption: ""
  },
  {
    name: "時間平均 BUN(TAC_BUN)",
    formula: "(前回の透析後BUN + 今回の透析前BUN) / 2",
    formulaId: "6",
    caption: ""
  },
  {
    name: "補正化 Ca",
    formula: "血清Ca濃度 - (4+ 血清アルブミン濃度)",
    formulaId: "7",
    caption: "血清アルブミン値が4以下のみ補正"
  },
  {
    name: "クリアスペース率",
    formula: "[1 - [(透析後BUN/透析前BUN - 0.008*透析時間) * (1 - 0.6/透析時間) + 0.008 * 透析時間] / [1 + 1.81 * (除水量 / 後体重)]] * 100",
    formulaId: "8",
    caption: ""
  },
  {
    name: "PCR",
    formula: "",
    formulaId: "9",
    caption: "同日の透析時間と透析前後の体重値、BUN値から算定する"
  },
  {
    name: "CreatinineIndex",
    formula: "",
    formulaId: "10",
    caption: "同日の透析時間と透析前後の体重値、クレアチニン値、BUN値と患者の年齢、性別から算定する"
  },
  {
    name: "Kt/V(shinzato)",
    formula: "",
    formulaId: "11",
    caption: "Single-poolモデルで尿素の産生を考慮し解析して得られた式 日本透析医学会、統計調査委員会に用いられている"
  },
  {
    name: "BMI",
    formula: "後体重÷（身長×身長）",
    formulaId: "12",
    caption: ""
  },
  {
    name: "GNRI",
    formula: "（14.89×透析前ｱﾙﾌﾞﾐﾝ値)＋(41.7×(後体重÷(22×身長×身長)))",
    formulaId: "13",
    caption: "*補足　・GNRI式内：(22×身長×身長) 　 計算式は理想体重の計算を行っている　 理想体重では患者の身長からBMI値が22になる体重値を求めている ・後体重>(22 * 身長 * 身長)の場合は(後体重 / (22 * 身長 * 身長))=1"
  },
  {
    name: "Cr除去率",
    formula: "(C1-C2)/C1×100",
    formulaId: "14",
    caption: "クレアチニンC1:透析前の値C2:透析後の値"
  },
  {
    name: "TSAT",
    formula: "[血清鉄(Fe)/総鉄結合能(TIBC)] * 100",
    formulaId: "15",
    caption: "※透析前の検査値で計算"
  }
];
// add #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou start
export const EXAM_RECALC_STATUS = {
  // 未処理 = 0
  UNPROGRESS: "0",
  // 処理完了 = 2
  PROGRESS_COMPLETE: "2",
  // 処理中断 = 4
  PROGRESS_PAUSE: "4",
  // 中止 = 9
  PROGRESS_STOPED: "9"
}

export const EXAM_RECALC_MSG = {
  // 処理中
  IN_PROGRESS: "現在再計算処理中です",
  // 未処理
  UNPROGRESS: "再計算処理を依頼しました",
  // 中止
  PROGRESS_STOPED: "再計算処理を中止しました\n" + "再計算処理依頼が可能です",
  // クリア
  IS_CLEAR: "依頼をクリアしました\n" + "再計算処理依頼が可能です"
}
// add #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou end
