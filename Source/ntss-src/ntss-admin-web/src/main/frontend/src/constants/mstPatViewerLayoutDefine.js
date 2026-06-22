/**
 * 患者経過総合ビューアレイアウトマスタの項目定義
 * @summary
 *  category: 大項目
 *  subCategory: 中項目
 *  item: 小項目
 */
export const mstPatViewerLayoutDefine = [
  {
    categoryNo: 1,
    categoryName: "治療情報",
    component: "treatment-contents",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "治療予定",
        component: "treat-plan",
        //mod 内部5988 【結合仕様書作成】患者経過総合ビューア グラフ 張 start
        subCategoryItem: [{ itemNo: 1, itemName: "治療予定", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 2,
        subCategoryName: "治療方法",
        component: "treat-method",
        subCategoryItem: [{ itemNo: 1, itemName: "治療方法", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 3,
        subCategoryName: "スケジュール",
        component: "schedule",
        subCategoryItem: [
          { itemNo: 1, itemName: "クール", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 2, itemName: "治療開始時刻", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 3, itemName: "ベッド", itemColor: "#000000", itemPoint: "triangle" }
        ]
      },
      {
        subCategoryNo: 4,
        subCategoryName: "治療条件",
        component: "treat-cond",
        subCategoryItem: [
          { itemNo: 1, itemName: "治療時間", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 2, itemName: "VA", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: -1, itemName: "DW", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 3, itemName: "目標体重", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 4, itemName: "除水量制限", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 5, itemName: "ダイアライザ", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 6, itemName: "吸着カラム", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 7, itemName: "1次膜", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 8, itemName: "2次膜", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 9, itemName: "穿刺針(A針)", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 10, itemName: "穿刺針(V針)", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 11, itemName: "穿刺針(SN)", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 12, itemName: "シングルニードル使用", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 13, itemName: "血液回路", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 14, itemName: "血流量", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 15, itemName: "透析液", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 16, itemName: "透析液流量", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 17, itemName: "透析液使用数", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 18, itemName: "透析液温度", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 19, itemName: "補液", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 20, itemName: "補液量", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 21, itemName: "補液選択", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 22, itemName: "補液使用数", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 23, itemName: "補液温度", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 24, itemName: "補液速度", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 25, itemName: "抗凝固剤", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 26, itemName: "抗凝固剤ワンショット量", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 27, itemName: "抗凝固剤持続速度", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 28, itemName: "抗凝固剤持続総量", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 29, itemName: "IP使用選択", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 30, itemName: "IPスタート", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 31, itemName: "IPワンショット量", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 32, itemName: "IP速度", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 33, itemName: "IP速度最大値", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 34, itemName: "IPワンショットスタート", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 35, itemName: "IP電源自動切り", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 36, itemName: "IP電源自動切り時間", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 37, itemName: "IP電源OKモニタ切り", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 38, itemName: "IP電源OKモニタ切り時間", itemColor: "#000000", itemPoint: "triangle" }
        ]
      },
      {
        subCategoryNo: 5,
        subCategoryName: "投与薬剤",
        component: "medicine",
        subCategoryItem: [
          { itemNo: 1, itemName: "投与薬剤(数量+単位)", itemColor: "#000000", itemPoint: "triangle" },
          { itemNo: 2, itemName: "投与薬剤(薬剤名+数量+単位)", itemColor: "#000000", itemPoint: "triangle" }
        ]
      },
      {
        subCategoryNo: 6,
        subCategoryName: "医療材料",
        component: "equipment",
        subCategoryItem: [{ itemNo: 1, itemName: "医療材料", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 7,
        subCategoryName: "指示コメント",
        component: "ind-comment",
        subCategoryItem: [{ itemNo: 1, itemName: "指示コメント", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 8,
        subCategoryName: "風袋",
        component: "tare-info",
        subCategoryItem: [{ itemNo: 1, itemName: "風袋", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 9,
        subCategoryName: "除水補正",
        component: "off-water-info",
        subCategoryItem: [{ itemNo: 1, itemName: "除水補正", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 10,
        subCategoryName: "除水プログラム",
        component: "ufr-program",
        subCategoryItem: [{ itemNo: 1, itemName: "除水プログラム", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 11,
        subCategoryName: "Na注入プログラム",
        component: "na-program",
        subCategoryItem: [{ itemNo: 1, itemName: "Na注入プログラム", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 12,
        subCategoryName: "透析液濃度プログラム",
        component: "dialysate-program",
        subCategoryItem: [{ itemNo: 1, itemName: "透析液濃度プログラム", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 13,
        subCategoryName: "QB・QDプログラム",
        component: "qbqd-program",
        subCategoryItem: [{ itemNo: 1, itemName: "QB・QDプログラム", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 14,
        subCategoryName: "I-HDF設定",
        component: "i-hdf",
        subCategoryItem: [{ itemNo: 1, itemName: "I-HDF設定", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 15,
        subCategoryName: "BV-UFC",
        component: "bv-ufc",
        subCategoryItem: [{ itemNo: 1, itemName: "BV-UFC", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 16,
        subCategoryName: "透析量プログラム",
        component: "diaysis-program",
        subCategoryItem: [{ itemNo: 1, itemName: "透析量プログラム", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 17,
        subCategoryName: "治療開始日時",
        rstCd: 1,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "治療開始日時", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 18,
        subCategoryName: "治療終了日時",
        rstCd: 2,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "治療終了日時", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 19,
        subCategoryName: "入外区分",
        rstCd: 3,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "入外区分", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 20,
        subCategoryName: "透析回数",
        rstCd: 4,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "透析回数", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 22,
        subCategoryName: "穿刺者名1",
        rstCd: 6,
        component: "rst-info",
        // subCategoryItem: []
        subCategoryItem: [{ itemNo: 1, itemName: "穿刺者名1", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 23,
        subCategoryName: "穿刺者名2",
        rstCd: 7,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "穿刺者名2", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 24,
        subCategoryName: "穿刺日時",
        rstCd: 8,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "穿刺日時", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 25,
        subCategoryName: "返血者名1",
        rstCd: 9,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "返血者名1", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 26,
        subCategoryName: "返血者名2",
        rstCd: 10,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "返血者名2", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 27,
        subCategoryName: "返血日時",
        rstCd: 11,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "返血日時", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 28,
        subCategoryName: "担当者名1",
        rstCd: 12,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "担当者名1", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 29,
        subCategoryName: "担当者名2",
        rstCd: 13,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "担当者名2", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 30,
        subCategoryName: "治療時間(実績)",
        rstCd: 14,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "治療時間(実績)", itemColor: "#000000", itemPoint: "triangle" }]
      },
      //  del 5920 項目の削除 start 鞠 修正の時
      // {
      //   subCategoryNo: 31,
      //   subCategoryName: "Kt/V",
      //   rstCd: 15,
      //   component: "rst-info",
      //   // subCategoryItem: []
      //   subCategoryItem: [{ itemNo: 1, itemName: "Kt/V" }]
      // },
      // {
      //   subCategoryNo: 32,
      //   subCategoryName: "透析記録確認日時",
      //   rstCd: 16,
      //   component: "rst-info",
      //   // subCategoryItem: []
      //   subCategoryItem: [{ itemNo: 1, itemName: "透析記録確認日時" }]
      // },
      //  del 5920 項目の削除 end 鞠 修正の時
      {
        subCategoryNo: 33,
        subCategoryName: "送信管理番号",
        rstCd: 17,
        component: "rst-info",
        // subCategoryItem: []
        subCategoryItem: [{ itemNo: 1, itemName: "送信管理番号", itemColor: "#000000", itemPoint: "triangle" }]
      },
      //  del 5920 項目の削除 start 鞠 修正の時
      // {
      //   subCategoryNo: 34,
      //   subCategoryName: "血液浄化装置名称",
      //   rstCd: 18,
      //   component: "rst-info",
      //   // subCategoryItem: []
      //   subCategoryItem: [{ itemNo: 1, itemName: "血液浄化装置名称" }]
      // },
      // //  del 5920 項目の削除 end 鞠 修正の時
      {
        subCategoryNo: 35,
        subCategoryName: "I-HDF引き残し",
        rstCd: 19,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "I-HDF引き残し", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 36,
        subCategoryName: "透析前体重測定値",
        rstCd: 20,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "透析前体重測定値", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 37,
        subCategoryName: "透析前体重",
        rstCd: 21,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "透析前体重", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 38,
        subCategoryName: "前体重測定日時",
        rstCd: 22,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "前体重測定日時", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 39,
        subCategoryName: "透析後体重測定値",
        rstCd: 23,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "透析後体重測定値", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 40,
        subCategoryName: "透析後体重",
        rstCd: 24,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "透析後体重", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 41,
        subCategoryName: "後体重測定日時",
        rstCd: 25,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "後体重測定日時", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 42,
        subCategoryName: "CTR",
        rstCd: 26,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "CTR", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 43,
        subCategoryName: "CTR測定日時",
        rstCd: 27,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "CTR測定日時", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 44,
        subCategoryName: "CTR測定時体重",
        rstCd: 28,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "CTR測定時体重", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 45,
        subCategoryName: "目標除水量",
        rstCd: 29,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "目標除水量", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 46,
        subCategoryName: "実績除水量",
        rstCd: 30,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "実績除水量", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 47,
        subCategoryName: "除水積算量",
        rstCd: 31,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "除水積算量", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 48,
        subCategoryName: "補液積算量",
        rstCd: 32,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "補液積算量", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 63,
        subCategoryName: "静的静脈圧",
        rstCd: 43,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "静的静脈圧", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 64,
        subCategoryName: "IAP Ratio",
        rstCd: 44,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "IAP Ratio", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 49,
        subCategoryName: "Kt/V測定値",
        rstCd: 33,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "Kt/V測定値", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 50,
        subCategoryName: "URR",
        rstCd: 34,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "URR", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 73,
        subCategoryName: "再循環率",
        rstCd: 45,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "再循環率", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 51,
        subCategoryName: "減少量",
        rstCd: 35,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "減少量", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 52,
        subCategoryName: "前血圧",
        rstCd: 36,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "前血圧", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 53,
        subCategoryName: "後血圧",
        rstCd: 37,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "後血圧", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 54,
        subCategoryName: "体温(1回目)",
        rstCd: 38,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "体温(1回目)", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 55,
        subCategoryName: "体温(最終)",
        rstCd: 39,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "体温(最終)", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 56,
        subCategoryName: "愁訴処置情報",
        rstCd: 40,
        component: "rst-info",
        subCategoryItem: []
      },
      {
        subCategoryNo: 74,
        subCategoryName: "加算・管理料",
        rstCd: 46,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "加算・管理料", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 57,
        subCategoryName: "回診記録情報",
        rstCd: 41,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "回診記録情報", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 58,
        subCategoryName: "バイタル・モニタグラフ①-1　入室～退室",
        component: "vital",
        subClassify: "vital1",
        subCategoryItem: []
      },
      {
        subCategoryNo: 65,
        subCategoryName: "バイタル・モニタグラフ①-2　入室～退室",
        component: "vital",
        subClassify: "vital1",
        subCategoryItem: []
      },
      {
        subCategoryNo: 66,
        subCategoryName: "バイタル・モニタグラフ①-3　入室～退室",
        component: "vital",
        subClassify: "vital1",
        subCategoryItem: []
      },
      {
        subCategoryNo: 59,
        subCategoryName: "バイタル・モニタグラフ②-1　入室～退室",
        component: "vital",
        subClassify: "vital2",
        subCategoryItem: []
      },
      {
        subCategoryNo: 67,
        subCategoryName: "バイタル・モニタグラフ②-2　入室～退室",
        component: "vital",
        subClassify: "vital2",
        subCategoryItem: []
      },
      {
        subCategoryNo: 68,
        subCategoryName: "バイタル・モニタグラフ②-3　入室～退室",
        component: "vital",
        subClassify: "vital2",
        subCategoryItem: []
      },
      {
        subCategoryNo: 60,
        subCategoryName: "バイタル・モニタグラフ③-1　入室～退室",
        component: "vital",
        subClassify: "vital3",
        subCategoryItem: []
      },
      {
        subCategoryNo: 69,
        subCategoryName: "バイタル・モニタグラフ③-2　入室～退室",
        component: "vital",
        subClassify: "vital3",
        subCategoryItem: []
      },
      {
        subCategoryNo: 70,
        subCategoryName: "バイタル・モニタグラフ③-3　入室～退室",
        component: "vital",
        subClassify: "vital3",
        subCategoryItem: []
      },
      {
        subCategoryNo: 61,
        subCategoryName: "バイタル・モニタグラフ④-1　入室～退室",
        component: "vital",
        subClassify: "vital4",
        subCategoryItem: []
      },
      {
        subCategoryNo: 71,
        subCategoryName: "バイタル・モニタグラフ④-2　入室～退室",
        component: "vital",
        subClassify: "vital4",
        subCategoryItem: []
      },
      {
        subCategoryNo: 72,
        subCategoryName: "バイタル・モニタグラフ④-3　入室～退室",
        component: "vital",
        subClassify: "vital4",
        subCategoryItem: []
      },
    ]
  },
  {
    categoryNo: 12,
    categoryName: "検査予定",
    component: "exam-info",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "検査予定",
        component: "exam-info",
        subCategoryItem: [{ itemNo: 1, itemName: "検査予定", itemColor: "#000000", itemPoint: "triangle" }]
      }
    ]
  },
  {
    categoryNo: 13,
    categoryName: "一般撮影検査予定",
    component: "rad-info",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "一般撮影検査予定",
        component: "rad-info",
        subCategoryItem: [{ itemNo: 1, itemName: "一般撮影検査予定", itemColor: "#000000", itemPoint: "triangle" }]
      }
    ]
  },
  {
    categoryNo: 2,
    categoryName: "バイタル・モニタグラフ①　24h",
    component: "vital",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "バイタル・モニタグラフ①-1　24h",
        component: "vital",
        subCategoryItem: []
      },
      {
        subCategoryNo: 2,
        subCategoryName: "バイタル・モニタグラフ①-2　24h",
        component: "vital",
        subCategoryItem: []
      },
      {
        subCategoryNo: 3,
        subCategoryName: "バイタル・モニタグラフ①-3　24h",
        component: "vital",
        subCategoryItem: []
      }
    ]
  },
  {
    categoryNo: 3,
    categoryName: "バイタル・モニタグラフ②　24h",
    component: "vital",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "バイタル・モニタグラフ②-1　24h",
        component: "vital",
        subCategoryItem: []
      },
      {
        subCategoryNo: 2,
        subCategoryName: "バイタル・モニタグラフ②-2　24h",
        component: "vital",
        subCategoryItem: []
      },
      {
        subCategoryNo: 3,
        subCategoryName: "バイタル・モニタグラフ②-3　24h",
        component: "vital",
        subCategoryItem: []
      }
    ]
  },
  {
    categoryNo: 4,
    categoryName: "バイタル・モニタグラフ③　24h",
    component: "vital",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "バイタル・モニタグラフ③-1　24h",
        component: "vital",
        subCategoryItem: []
      },
      {
        subCategoryNo: 2,
        subCategoryName: "バイタル・モニタグラフ③-2　24h",
        component: "vital",
        subCategoryItem: []
      },
      {
        subCategoryNo: 3,
        subCategoryName: "バイタル・モニタグラフ③-3　24h",
        component: "vital",
        subCategoryItem: []
      }
    ]
  },
  {
    categoryNo: 5,
    categoryName: "バイタル・モニタグラフ④　24h",
    component: "vital",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "バイタル・モニタグラフ④-1　24h",
        component: "vital",
        subCategoryItem: []
      },
      {
        subCategoryNo: 2,
        subCategoryName: "バイタル・モニタグラフ④-2　24h",
        component: "vital",
        subCategoryItem: []
      },
      {
        subCategoryNo: 3,
        subCategoryName: "バイタル・モニタグラフ④-3　24h",
        component: "vital",
        subCategoryItem: []
      }
    ]
  },
  {
    categoryNo: 6,
    categoryName: "体重グラフ①",
    component: "weight",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "体重グラフ①",
        component: "weight",
        subCategoryItem: []
      },
      {
        subCategoryNo: 2,
        subCategoryName: "体重グラフ②",
        component: "weight",
        subCategoryItem: []
      },
      {
        subCategoryNo: 3,
        subCategoryName: "体重グラフ③",
        component: "weight",
        subCategoryItem: []
      }
    ]
  },
  {
    categoryNo: 7,
    categoryName: "体重グラフ②",
    component: "weight",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "体重グラフ①",
        component: "weight",
        subCategoryItem: []
      },
      {
        subCategoryNo: 2,
        subCategoryName: "体重グラフ②",
        component: "weight",
        subCategoryItem: []
      },
      {
        subCategoryNo: 3,
        subCategoryName: "体重グラフ③",
        component: "weight",
        subCategoryItem: []
      }
    ]
  },
  {
    categoryNo: 18,
    categoryName: "体重グラフ③",
    component: "weight",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "体重グラフ①",
        component: "weight",
        subCategoryItem: []
      },
      {
        subCategoryNo: 2,
        subCategoryName: "体重グラフ②",
        component: "weight",
        subCategoryItem: []
      },
      {
        subCategoryNo: 3,
        subCategoryName: "体重グラフ③",
        component: "weight",
        subCategoryItem: []
      }
    ]
  },
  {
    categoryNo: 19,
    categoryName: "体重グラフ④",
    component: "weight",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "体重グラフ①",
        component: "weight",
        subCategoryItem: []
      },
      {
        subCategoryNo: 2,
        subCategoryName: "体重グラフ②",
        component: "weight",
        subCategoryItem: []
      },
      {
        subCategoryNo: 3,
        subCategoryName: "体重グラフ③",
        component: "weight",
        subCategoryItem: []
      }
    ]
  },
  {
    categoryNo: 8,
    categoryName: "検査結果グラフ①",
    component: "exam-result",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "検査結果グラフ①",
        component: "exam-result",
        subCategoryItem: []
      },
      {
        subCategoryNo: 2,
        subCategoryName: "検査結果グラフ②",
        component: "exam-result",
        subCategoryItem: []
      },
      {
        subCategoryNo: 3,
        subCategoryName: "検査結果グラフ③",
        component: "exam-result",
        subCategoryItem: []
      }
    ]
  },
  {
    categoryNo: 9,
    categoryName: "検査結果グラフ②",
    component: "exam-result",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "検査結果グラフ①",
        component: "exam-result",
        subCategoryItem: []
      },
      {
        subCategoryNo: 2,
        subCategoryName: "検査結果グラフ②",
        component: "exam-result",
        subCategoryItem: []
      },
      {
        subCategoryNo: 3,
        subCategoryName: "検査結果グラフ③",
        component: "exam-result",
        subCategoryItem: []
      }
    ]
  },
  {
    categoryNo: 10,
    categoryName: "検査結果グラフ③",
    component: "exam-result",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "検査結果グラフ①",
        component: "exam-result",
        subCategoryItem: []
      },
      {
        subCategoryNo: 2,
        subCategoryName: "検査結果グラフ②",
        component: "exam-result",
        subCategoryItem: []
      },
      {
        subCategoryNo: 3,
        subCategoryName: "検査結果グラフ③",
        component: "exam-result",
        subCategoryItem: []
      }
    ]
  },
  {
    categoryNo: 11,
    categoryName: "検査結果グラフ④",
    component: "exam-result",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "検査結果グラフ①",
        component: "exam-result",
        subCategoryItem: []
      },
      {
        subCategoryNo: 2,
        subCategoryName: "検査結果グラフ②",
        component: "exam-result",
        subCategoryItem: []
      },
      {
        subCategoryNo: 3,
        subCategoryName: "検査結果グラフ③",
        component: "exam-result",
        subCategoryItem: []
      }
    ]
  },
  {
    categoryNo: 14,
    categoryName: "紹介状",
    component: "letter",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "紹介状",
        component: "letter",
        // subCategoryItem: []
        subCategoryItem: [{ itemNo: 1, itemName: "紹介状", itemColor: "#000000", itemPoint: "triangle" }]
      }
    ]
  },
  // {
  //   categoryNo: 15,
  //   categoryName: "観察記録",
  //   component: "obser",
  //   categoryItem: [
  //     {
  //       subCategoryNo: 1,
  //       subCategoryName: "観察記録",
  //       component: "obser",
  //       subCategoryItem: []
  //     },
  //   ]
  // },
  {
    categoryNo: 16,
    categoryName: "患者イベント",
    component: "patient",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "患者イベント",
        component: "patient",
        subCategoryItem: []
      },
    ]
  },
  {
    categoryNo: 17,
    categoryName: "処方",
    component: "prescription",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "処方",
        component: "prescription",
        subCategoryItem: [{ itemNo: 1, itemName: "処方", itemColor: "#000000", itemPoint: "triangle" }]
      }
    ]
  },
  {
    categoryNo: 1016,
    categoryName: "治療記録集計",
    component: "treatment",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "治療方法",
        component: "treatment",
        // subCategoryItem: []
        subCategoryItem: [{ itemNo: 1, itemName: "治療方法", itemColor: "#000000", itemPoint: "triangle" }]
      }
    ]
  },
  {
    categoryNo: 1017,
    categoryName: "愁訴処置",
    component: "complaint",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "愁訴処置",
        component: "complaint",
        subCategoryItem: []
        // subCategoryItem: [{ itemNo: 1, itemName: "愁訴処置集計" }]
      }
    ]
  },
  {
    categoryNo: 1018,
    categoryName: "医療材料集計",
    component: "medical",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "医療材料集計分類",
        component: "medical",
        subCategoryItem: []
        // subCategoryItem: [{ itemNo: 1, itemName: "医療材料" }]
      }
    ]
  },
  {
    categoryNo: 1022,
    categoryName: "薬剤集計",
    component: "drugAggregate",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "薬剤集計分類",
        component: "drugAggregate",
        subCategoryItem: []
        // subCategoryItem: [{ itemNo: 1, itemName: "医療材料" }]
      }
    ]
  },
  {
    categoryNo: 1019,
    categoryName: "ダイアライザ集計",
    component: "dialyzer",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "ダイアライザ",
        component: "dialyzer",
        subCategoryItem: []
        // subCategoryItem: [{ itemNo: 1, itemName: "ダイアライザ" }]
      }
    ]
  },
  {
    categoryNo: 1028,
    categoryName: "投薬支援マスタ対象",
    component: "medicationSupport",
    medicineGroupCd: null,
    categoryItem: [{
      component: "medicationSupport",
      subCategoryNo: 1,
      subCategoryItem: [{
        itemNo: 1,
        itemName: "投薬支援マスタ対象", itemColor: "#000000", itemPoint: "triangle"
      }],
      subCategoryName: "投薬支援マスタ対象"
    }]
  },
  {
    categoryNo: 1002,
    categoryName: "バイタル・モニタグラフ①",
    component: "vital",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "バイタル・モニタグラフ①",
        component: "vital",
        subCategoryItem: []
      },
      {
        subCategoryNo: 2,
        subCategoryName: "バイタル・モニタグラフ②",
        component: "vital",
        subCategoryItem: []
      },
      {
        subCategoryNo: 3,
        subCategoryName: "バイタル・モニタグラフ③",
        component: "vital",
        subCategoryItem: []
      }
    ]
  },
  {
    categoryNo: 1003,
    categoryName: "バイタル・モニタグラフ②",
    component: "vital",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "バイタル・モニタグラフ①",
        component: "vital",
        subCategoryItem: []
      },
      {
        subCategoryNo: 2,
        subCategoryName: "バイタル・モニタグラフ②",
        component: "vital",
        subCategoryItem: []
      },
      {
        subCategoryNo: 3,
        subCategoryName: "バイタル・モニタグラフ③",
        component: "vital",
        subCategoryItem: []
      }
    ]
  },
  {
    categoryNo: 1004,
    categoryName: "バイタル・モニタグラフ③",
    component: "vital",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "バイタル・モニタグラフ①",
        component: "vital",
        subCategoryItem: []
      },
      {
        subCategoryNo: 2,
        subCategoryName: "バイタル・モニタグラフ②",
        component: "vital",
        subCategoryItem: []
      },
      {
        subCategoryNo: 3,
        subCategoryName: "バイタル・モニタグラフ③",
        component: "vital",
        subCategoryItem: []
      }
    ]
  },
  {
    categoryNo: 1005,
    categoryName: "バイタル・モニタグラフ④",
    component: "vital",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "バイタル・モニタグラフ①",
        component: "vital",
        subCategoryItem: []
      },
      {
        subCategoryNo: 2,
        subCategoryName: "バイタル・モニタグラフ②",
        component: "vital",
        subCategoryItem: []
      },
      {
        subCategoryNo: 3,
        subCategoryName: "バイタル・モニタグラフ③",
        component: "vital",
        subCategoryItem: []
      }
    ]
  },
  {
    categoryNo: 1006,
    categoryName: "体重グラフ①",
    component: "weight",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "体重グラフ①",
        component: "weight",
        subCategoryItem: []
      },
      {
        subCategoryNo: 2,
        subCategoryName: "体重グラフ②",
        component: "weight",
        subCategoryItem: []
      },
      {
        subCategoryNo: 3,
        subCategoryName: "体重グラフ③",
        component: "weight",
        subCategoryItem: []
      }
    ]
  },
  {
    categoryNo: 1007,
    categoryName: "体重グラフ②",
    component: "weight",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "体重グラフ①",
        component: "weight",
        subCategoryItem: []
      },
      {
        subCategoryNo: 2,
        subCategoryName: "体重グラフ②",
        component: "weight",
        subCategoryItem: []
      },
      {
        subCategoryNo: 3,
        subCategoryName: "体重グラフ③",
        component: "weight",
        subCategoryItem: []
      }
    ]
  },
  {
    categoryNo: 1020,
    categoryName: "体重グラフ③",
    component: "weight",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "体重グラフ①",
        component: "weight",
        subCategoryItem: []
      },
      {
        subCategoryNo: 2,
        subCategoryName: "体重グラフ②",
        component: "weight",
        subCategoryItem: []
      },
      {
        subCategoryNo: 3,
        subCategoryName: "体重グラフ③",
        component: "weight",
        subCategoryItem: []
      }
    ]
  },
  {
    categoryNo: 1021,
    categoryName: "体重グラフ④",
    component: "weight",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "体重グラフ①",
        component: "weight",
        subCategoryItem: []
      },
      {
        subCategoryNo: 2,
        subCategoryName: "体重グラフ②",
        component: "weight",
        subCategoryItem: []
      },
      {
        subCategoryNo: 3,
        subCategoryName: "体重グラフ③",
        component: "weight",
        subCategoryItem: []
      }
    ]
  },
  {
    categoryNo: 1008,
    categoryName: "検査結果グラフ①",
    component: "exam-result",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "検査結果グラフ①",
        component: "exam-result",
        subCategoryItem: []
      },
      {
        subCategoryNo: 2,
        subCategoryName: "検査結果グラフ②",
        component: "exam-result",
        subCategoryItem: []
      },
      {
        subCategoryNo: 3,
        subCategoryName: "検査結果グラフ③",
        component: "exam-result",
        subCategoryItem: []
      }
    ]
  },
  {
    categoryNo: 1009,
    categoryName: "検査結果グラフ②",
    component: "exam-result",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "検査結果グラフ①",
        component: "exam-result",
        subCategoryItem: []
      },
      {
        subCategoryNo: 2,
        subCategoryName: "検査結果グラフ②",
        component: "exam-result",
        subCategoryItem: []
      },
      {
        subCategoryNo: 3,
        subCategoryName: "検査結果グラフ③",
        component: "exam-result",
        subCategoryItem: []
      }
    ]
  },
  {
    categoryNo: 1010,
    categoryName: "検査結果グラフ③",
    component: "exam-result",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "検査結果グラフ①",
        component: "exam-result",
        subCategoryItem: []
      },
      {
        subCategoryNo: 2,
        subCategoryName: "検査結果グラフ②",
        component: "exam-result",
        subCategoryItem: []
      },
      {
        subCategoryNo: 3,
        subCategoryName: "検査結果グラフ③",
        component: "exam-result",
        subCategoryItem: []
      }
    ]
  },
  {
    categoryNo: 1011,
    categoryName: "検査結果グラフ④",
    component: "exam-result",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "検査結果グラフ①",
        component: "exam-result",
        subCategoryItem: []
      },
      {
        subCategoryNo: 2,
        subCategoryName: "検査結果グラフ②",
        component: "exam-result",
        subCategoryItem: []
      },
      {
        subCategoryNo: 3,
        subCategoryName: "検査結果グラフ③",
        component: "exam-result",
        subCategoryItem: []
      }
    ]
  },
  {
    categoryNo: 1012,
    categoryName: "薬剤グラフ①",
    component: "drug-graph",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "薬剤グラフ①",
        component: "drug-graph",
        summaryDate: "day",
        subCategoryItem: []
      },
      {
        subCategoryNo: 2,
        subCategoryName: "薬剤グラフ②",
        component: "drug-graph",
        summaryDate: "day",
        subCategoryItem: []
      },
      {
        subCategoryNo: 3,
        subCategoryName: "薬剤グラフ③",
        component: "drug-graph",
        summaryDate: "day",
        subCategoryItem: []
      }
    ]
  },
  {
    categoryNo: 1013,
    categoryName: "薬剤グラフ②",
    component: "drug-graph",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "薬剤グラフ①",
        component: "drug-graph",
        summaryDate: "day",
        subCategoryItem: []
      },
      {
        subCategoryNo: 2,
        subCategoryName: "薬剤グラフ②",
        component: "drug-graph",
        summaryDate: "day",
        subCategoryItem: []
      },
      {
        subCategoryNo: 3,
        subCategoryName: "薬剤グラフ③",
        component: "drug-graph",
        summaryDate: "day",
        subCategoryItem: []
      }
    ]
  },
  {
    categoryNo: 1014,
    categoryName: "薬剤グラフ③",
    component: "drug-graph",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "薬剤グラフ①",
        component: "drug-graph",
        summaryDate: "day",
        subCategoryItem: []
      },
      {
        subCategoryNo: 2,
        subCategoryName: "薬剤グラフ②",
        component: "drug-graph",
        summaryDate: "day",
        subCategoryItem: []
      },
      {
        subCategoryNo: 3,
        subCategoryName: "薬剤グラフ③",
        component: "drug-graph",
        summaryDate: "day",
        subCategoryItem: []
      }
    ]
  },
  {
    categoryNo: 1015,
    categoryName: "薬剤グラフ④",
    component: "drug-graph",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "薬剤グラフ①",
        component: "drug-graph",
        summaryDate: "day",
        subCategoryItem: []
      },
      {
        subCategoryNo: 2,
        subCategoryName: "薬剤グラフ②",
        component: "drug-graph",
        summaryDate: "day",
        subCategoryItem: []
      },
      {
        subCategoryNo: 3,
        subCategoryName: "薬剤グラフ③",
        component: "drug-graph",
        summaryDate: "day",
        subCategoryItem: []
      }
    ]
  },
  {
    categoryNo: 1024,
    categoryName: "複合グラフ①",
    component: "comprehensive",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "複合グラフ①",
        component: "comprehensive",
        subCategoryItem: []
      },
      {
        subCategoryNo: 2,
        subCategoryName: "複合グラフ②",
        component: "comprehensive",
        subCategoryItem: []
      },
      {
        subCategoryNo: 3,
        subCategoryName: "複合グラフ③",
        component: "comprehensive",
        subCategoryItem: []
      }
    ]
  },
  {
    categoryNo: 1025,
    categoryName: "複合グラフ②",
    component: "comprehensive",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "複合グラフ①",
        component: "comprehensive",
        subCategoryItem: []
      },
      {
        subCategoryNo: 2,
        subCategoryName: "複合グラフ②",
        component: "comprehensive",
        subCategoryItem: []
      },
      {
        subCategoryNo: 3,
        subCategoryName: "複合グラフ③",
        component: "comprehensive",
        subCategoryItem: []
      }
    ]
  },
  {
    categoryNo: 1026,
    categoryName: "複合グラフ③",
    component: "comprehensive",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "複合グラフ①",
        component: "comprehensive",
        subCategoryItem: []
      },
      {
        subCategoryNo: 2,
        subCategoryName: "複合グラフ②",
        component: "comprehensive",
        subCategoryItem: []
      },
      {
        subCategoryNo: 3,
        subCategoryName: "複合グラフ③",
        component: "comprehensive",
        subCategoryItem: []
      }
    ]
  },
  {
    categoryNo: 1027,
    categoryName: "複合グラフ④",
    component: "comprehensive",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "複合グラフ①",
        component: "comprehensive",
        subCategoryItem: []
      },
      {
        subCategoryNo: 2,
        subCategoryName: "複合グラフ②",
        component: "comprehensive",
        subCategoryItem: []
      },
      {
        subCategoryNo: 3,
        subCategoryName: "複合グラフ③",
        component: "comprehensive",
        subCategoryItem: []
      }
    ]
  },
];

export const selectInfoOptions = {
  treatCondInfo: [],
  vitalInfo: [
    { itemNo: 0, itemName: "工程", itemColor: "#000000", itemPoint: "triangle"},
    { itemNo: 1, itemName: "経過時間", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 2, itemName: "経過時間（ＥＣＵＭ）", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 3, itemName: "残り時間（除水完了）", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 4, itemName: "残り時間（透析完了）", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 5, itemName: "除水積算値", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 6, itemName: "除水速度", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 7, itemName: "血液循環量", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 8, itemName: "血流量", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 9, itemName: "ＩＰ総量", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 10, itemName: "ＩＰ速度", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 11, itemName: "静脈圧", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 12, itemName: "透析液圧", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 13, itemName: "ＴＭＰ", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 14, itemName: "ダイアライザー入口圧", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 15, itemName: "ダイアライザー差圧", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 16, itemName: "血液入口～静脈平均圧", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 17, itemName: "ΔBV", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 18, itemName: "バイカーボ濃度", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 19, itemName: "透析液濃度", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 20, itemName: "Ｎａ濃度", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 21, itemName: "透析液温度", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 22, itemName: "透析液流量", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 23, itemName: "漏血量", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 24, itemName: "給液圧（上限）", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 25, itemName: "給液圧（下限）", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 26, itemName: "ＵＦＲ", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 27, itemName: "ＵＦＲ低下率", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 28, itemName: "初期ＵＦＲ測定値", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 29, itemName: "ＴＭＰ補正値", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 30, itemName: "透析運転時間", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 31, itemName: "治療モード", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 32, itemName: "除水目標値", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 33, itemName: "除水速度設定値", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 34, itemName: "透析液温度設定値", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 35, itemName: "透析液流量設定値", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 36, itemName: "血流量設定値", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 37, itemName: "ＩＰ速度設定", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 38, itemName: "Kt/V（測定値）", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 39, itemName: "静脈圧警報点（上限）", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 40, itemName: "静脈圧警報点（下限）", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 41, itemName: "透析液圧警報点（上限）", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 42, itemName: "透析液圧警報点（下限）", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 43, itemName: "ＴＭＰ警報点（上限）", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 44, itemName: "ＴＭＰ警報点（下限）", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 45, itemName: "ダイアライザー入口圧警報点（上限）", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 46, itemName: "ダイアライザー入口圧警報点（下限）", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 47, itemName: "ダイアライザー差圧警報点（上限）", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 48, itemName: "ダイアライザー差圧警報点（下限）", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 49, itemName: "ΔＢＶ低下警報点1", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 50, itemName: "ΔＢＶ低下警報点2", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 51, itemName: "ΔBV変化率警報点", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 52, itemName: "ＢＰＭ関連データ９", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 53, itemName: "ＢＰＭ関連データ１０", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 54, itemName: "バイカーボ濃度警報点（上限）", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 55, itemName: "バイカーボ濃度警報点（下限）", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 56, itemName: "透析液濃度警報点（上限）", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 57, itemName: "透析液濃度警報点（下限）", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 58, itemName: "Ｎａ濃度警報点（上限）", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 59, itemName: "Ｎａ濃度警報点（下限）", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 60, itemName: "透析液温度警報点（上限）", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 61, itemName: "透析液温度警報点（下限）", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 62, itemName: "漏血量警報", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 63, itemName: "給水圧警報点（上限）", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 64, itemName: "給水圧警報点（下限）", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 65, itemName: "初期ＵＦＲ警報点（上限）", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 66, itemName: "初期ＵＦＲ警報点（下限）", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 67, itemName: "ＵＦＲ低下率警報", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 68, itemName: "Kt/V", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 69, itemName: "運転中の血流量積算値", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 70, itemName: "補液量設定値", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 71, itemName: "補液速度", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 72, itemName: "補液量現在値", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 73, itemName: "補液速度設定値", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 74, itemName: "補液温度", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 75, itemName: "補液温度設定値", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 76, itemName: "濾液速度", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 77, itemName: "荷重計", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 78, itemName: "残り時間（補液完了）", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 79, itemName: "ＵＲＲ", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 80, itemName: "ΔＢＶ変化率", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 81, itemName: "ＰＷＩ", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 82, itemName: "ＢＰＭ関連データ１", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 83, itemName: "ＢＰＭ関連データ２", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 84, itemName: "ＢＰＭ関連データ３", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 85, itemName: "ΔBVリファレンスエリア上限", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 86, itemName: "ΔBVリファレンスエリア下限", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 87, itemName: "ＢＰＭ関連データ６", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 88, itemName: "ＰＲＲ", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 89, itemName: "再循環率測定結果（BVMS連携用）", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 90, itemName: "最高血圧", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 91, itemName: "最低血圧", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 92, itemName: "平均血圧", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 93, itemName: "脈拍", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 94, itemName: "体温", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 95, itemName: "ΔＢＶ 5分平均値", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 96, itemName: "ΔＢＶ 最大最小を除いた5分平均値", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 97, itemName: "推定血流量", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 98, itemName: "血流量不足率", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 99, itemName: "予約", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 100, itemName: "ΔBV(BVplus)", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 101, itemName: "Ｈｔ", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: 102, itemName: "ＬＤＱｂ", itemColor: "#000000", itemPoint: "triangle" }
  ],
  weightInfo: [
    { itemNo: "rst_dw", itemName: "ＤＷ", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: "weight_before", itemName: "透析前体重", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: "increase", itemName: "増加量", itemColor: "#000000", itemPoint: "triangle" },
    //mod 患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
    // { itemNo: "increase_rate", itemName: "増加率", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: "increase_rate", itemName: "増加率(%)", itemColor: "#000000", itemPoint: "triangle" },
    //mod 患者経過総合ビューアにてグラフ項目が正しく表示されない 張 end
    { itemNo: "fluid_volume", itemName: "補液量", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: "water_removal_rst", itemName: "実績除水量", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: "weight_after", itemName: "透析後体重", itemColor: "#000000", itemPoint: "triangle" },
    //mod 5929体重グラフの表示不正 張start
    // { itemNo: "reduction", itemName: "透析後体重", itemColor: "#000000", itemPoint: "triangle" },
    // { itemNo: "reduction_rate", itemName: "透析後体重", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: "reduction", itemName: "減少量", itemColor: "#000000", itemPoint: "triangle" },
    //mod 患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
    // { itemNo: "reduction_rate", itemName: "減少率", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: "reduction_rate", itemName: "減少率(%)", itemColor: "#000000", itemPoint: "triangle" },
    //mod 患者経過総合ビューアにてグラフ項目が正しく表示されない 張 end
    //mod 5929体重グラフの表示不正 張end
    { itemNo: "ktv_measurements", itemName: "Kt/V測定値", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: "urr", itemName: "URR", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: "re_loop_rate_main", itemName: "再循環率", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: "re_loop_rate_main_blood_flow", itemName: "再循環率測定時血流量", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: "ctr", itemName: "CTR", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: "sttc_vns_prssr", itemName: "静的静脈圧", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: "iap_rt", itemName: "IAP rate", itemColor: "#000000", itemPoint: "triangle" },
  ],
  treatmentConditions: [
    { itemNo: "method_of_treatment", itemName: "治療方法", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: "rst_dw2", itemName: "ＤＷ", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: "target_weight", itemName: "目標体重", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: "dializer", itemName: "ダイアライザ", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: "treatment_time", itemName: "治療時間", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: "blood_flow", itemName: "血流量", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: "dialysate_flow_rate", itemName: "透析液流量", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: "fluid_infusion", itemName: "補液", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: "fluid_volume2", itemName: "補液量", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: "anticoagulant", itemName: "抗凝固剤", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: "anticoagulant_one_shot_amount", itemName: "抗凝固剤ワンショット量", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: "anticoagulant_duration", itemName: "抗凝固剤持続速度", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: "anticoagulant_sustained_total_amount", itemName: "抗凝固剤持続総量", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: "total_amount_of_anticoagulant", itemName: "抗凝固剤総量", itemColor: "#000000", itemPoint: "triangle" },
  ],
  inspectionResultSupport: [
    { itemNo: "prediction", itemName: "予測値", itemColor: "#000000", itemPoint: "triangle", isMasterData: 0 },
    { itemNo: "regression_line", itemName: "回帰直線", itemColor: "#000000", itemPoint: "triangle", isMasterData: 0 },
    //mod 内部5988 【結合仕様書作成】患者経過総合ビューア グラフ 張 end
  ],
  drugDosingSupport: [
    { itemNo: "target_investment", itemName: "目標投与量", itemColor: null, itemDate: null },
  ],
  electroCardiogram:[{ itemNo: 'electroCardiogramCd', itemName: "心電図", complaintClassify: "3"},],
  acidInhalation:[{ itemNo: 'acidInhalationCd', itemName: "酸素吸入",  complaintClassify: "4"},]
  /* #9312 ADD START */
  , vitalInfoPlus : [
    { itemNo: "1*2*89", itemName: "再循環率", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: "1*2*112", itemName: "透析前最高血圧", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: "1*2*113", itemName: "透析前最低血圧", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: "1*2*114", itemName: "透析前平均血圧", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: "1*2*115", itemName: "透析後最高血圧", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: "1*2*116", itemName: "透析後最低血圧", itemColor: "#000000", itemPoint: "triangle" },
    { itemNo: "1*2*117", itemName: "透析後平均血圧", itemColor: "#000000", itemPoint: "triangle" }
  ]
  /* #9312 ADD END*/
};

// 拡張設定項目-表示対象設定項目
export const advancedSettingDispItemList = [
  "diaysis-program","bv-ufc"
];

/**
 * カテゴリの定数クラス
 */
export const CATEGORY_NO = {
  // 治療情報
  TREATMENT_CONTENT : 1,
  // バイタル・モニタグラフ(24H)1
  VITAL_MONITOR_GRAPH_24H_1 : 2,
  // バイタル・モニタグラフ(24H)2
  VITAL_MONITOR_GRAPH_24H_2 : 3,
  // バイタル・モニタグラフ(24H)3
  VITAL_MONITOR_GRAPH_24H_3 : 4,
  // バイタル・モニタグラフ(24H)4
  VITAL_MONITOR_GRAPH_24H_4 : 5,
  // バイタル・モニタグラフ1
  VITAL_MONITOR_GRAPH_COL_1 : 1002,
  // バイタル・モニタグラフ2
  VITAL_MONITOR_GRAPH_COL_2 : 1003,
  // バイタル・モニタグラフ3
  VITAL_MONITOR_GRAPH_COL_3 : 1004,
  // バイタル・モニタグラフ4
  VITAL_MONITOR_GRAPH_COL_4 : 1005,
  // 複合グラフ①
  VITAL_COMPREHENSIVE_COL_1 : 1024,
  // 複合グラフ②
  VITAL_COMPREHENSIVE_COL_2 : 1025,
  // 複合グラフ③
  VITAL_COMPREHENSIVE_COL_3 : 1026,
  // 複合グラフ④
  VITAL_COMPREHENSIVE_COL_4 : 1027,
};

/**
 * サブカテゴリの定数クラス
 */
export const SUB_CATEGORY_NO = {
  // バイタル・モニタグラフ①-①入室～退室
  VITAL_MONITOR_GRAPH_IN_OUT_1_1 : 58,
  // バイタル・モニタグラフ①-②入室～退室
  VITAL_MONITOR_GRAPH_IN_OUT_1_2 : 65,
  // バイタル・モニタグラフ①-②入室～退室
  VITAL_MONITOR_GRAPH_IN_OUT_1_3 : 66,
  // バイタル・モニタグラフ②-①入室～退室
  VITAL_MONITOR_GRAPH_IN_OUT_2_1 : 59,
  // バイタル・モニタグラフ②-②入室～退室
  VITAL_MONITOR_GRAPH_IN_OUT_2_2 : 67,
  // バイタル・モニタグラフ②-③入室～退室
  VITAL_MONITOR_GRAPH_IN_OUT_2_3 : 68,
  // バイタル・モニタグラフ③-①入室～退室
  VITAL_MONITOR_GRAPH_IN_OUT_3_1 : 60,
  // バイタル・モニタグラフ③-①入室～退室
  VITAL_MONITOR_GRAPH_IN_OUT_3_2 : 69,
  // バイタル・モニタグラフ③-①入室～退室
  VITAL_MONITOR_GRAPH_IN_OUT_3_3 : 70,
  // バイタル・モニタグラフ④-①入室～退室
  VITAL_MONITOR_GRAPH_IN_OUT_4_1 : 61,
  // バイタル・モニタグラフ④-①入室～退室
  VITAL_MONITOR_GRAPH_IN_OUT_4_2 : 71,
  // バイタル・モニタグラフ④-①入室～退室
  VITAL_MONITOR_GRAPH_IN_OUT_4_3 : 72,
}

export const MED_DATE = [
  {text:"未登録",value:"none"},
  {text:"日",value:"day"},
  {text:"1週",value:"week"},
  {text:"2週",value:"twoWeek"},
  {text:"1ヶ月",value:"month"},
  {text:"3ヶ月",value:"threeMonth"},
]

export const complaintTreatmentInformation = [
  {text:"愁訴",value:"1"},
  {text:"処置",value:"2"},
  {text:"心電図",value:"3"},
  {text:"酸素吸入",value:"4"},
]

// add FNSI-グラフ３軸表示対応「230」バイタル・モニタグラフ分（入室～退室） 周 start
export const vitalMonitorGraphInoutDefine = [
  {
    categoryNo: 58,
    categoryName: "バイタル・モニタグラフ①　入室～退室",
    component: "vital",
    subClassify: "vital1",
    categoryItem: []
  },
  {
    categoryNo: 59,
    categoryName: "バイタル・モニタグラフ②　入室～退室",
    component: "vital",
    subClassify: "vital2",
    categoryItem: []
  },
  {
    categoryNo: 60,
    categoryName: "バイタル・モニタグラフ③　入室～退室",
    component: "vital",
    subClassify: "vital3",
    categoryItem: []
  },
  {
    categoryNo: 61,
    categoryName: "バイタル・モニタグラフ④　入室～退室",
    component: "vital",
    subClassify: "vital4",
    categoryItem: []
  }
];
// add FNSI-グラフ３軸表示対応「230」バイタル・モニタグラフ分（入室～退室） 周 end
