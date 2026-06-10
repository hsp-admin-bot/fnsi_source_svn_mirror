/**
 * 患者経過総合ビューア指示履歴レイアウトマスタの項目定義
 * @summary
 *  category: 大項目
 *  subCategory: 中項目
 *  item: 小項目
 */
export const mstPatViewerLayoutToIndicationDefine = [
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
      //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
      {
        subCategoryNo: 2,
        subCategoryName: "治療方法",
        component: "treat-method",
        subCategoryItem: [],
        itemInfo: [{itemNo: 1, itemName: null}]
      },
      {
        subCategoryNo: 3,
        subCategoryName: "スケジュール",
        component: "schedule",
        subCategoryItem: [
          {itemInfo: {itemNo: 1, itemName: "クール", itemType: null}},
          {itemInfo: {itemNo: 2, itemName: "治療開始時刻", itemType: null}},
          {itemInfo: {itemNo: 3, itemName: "ベッド", itemType: null}}
        ]
      },
      {
        subCategoryNo: 4,
        subCategoryName: "治療条件",
        component: "treat-cond",
        subCategoryItem: [
          {itemInfo: {itemNo: 1, itemName: "治療時間"}},
          {itemInfo: {itemNo: 2, itemName: "VA"}},
          {itemInfo: {itemNo: -1, itemName: "DW"}},
          {itemInfo: {itemNo: 3, itemName: "目標体重"}},
          {itemInfo: {itemNo: 4, itemName: "除水量制限"}},
          {itemInfo: {itemNo: 5, itemName: "ダイアライザ"}},
          {itemInfo: {itemNo: 6, itemName: "吸着カラム"}},
          {itemInfo: {itemNo: 7, itemName: "1次膜"}},
          {itemInfo: {itemNo: 8, itemName: "2次膜"}},
          {itemInfo: {itemNo: 9, itemName: "穿刺針(A針)"}},
          {itemInfo: {itemNo: 10, itemName: "穿刺針(V針)"}},
          {itemInfo: {itemNo: 11, itemName: "穿刺針(SN)"}},
          {itemInfo: {itemNo: 12, itemName: "シングルニードル使用"}},
          {itemInfo: {itemNo: 13, itemName: "血液回路"}},
          {itemInfo: {itemNo: 14, itemName: "血流量"}},
          {itemInfo: {itemNo: 15, itemName: "透析液"}},
          {itemInfo: {itemNo: 16, itemName: "透析液流量"}},
          {itemInfo: {itemNo: 17, itemName: "透析液使用数"}},
          {itemInfo: {itemNo: 18, itemName: "透析液温度"}},
          {itemInfo: {itemNo: 19, itemName: "補液"}},
          {itemInfo: {itemNo: 20, itemName: "補液量"}},
          {itemInfo: {itemNo: 21, itemName: "補液選択"}},
          {itemInfo: {itemNo: 22, itemName: "補液使用数"}},
          {itemInfo: {itemNo: 23, itemName: "補液温度"}},
          {itemInfo: {itemNo: 24, itemName: "補液速度"}},
          {itemInfo: {itemNo: 25, itemName: "抗凝固剤"}},
          {itemInfo: {itemNo: 26, itemName: "抗凝固剤ワンショット量"}},
          {itemInfo: {itemNo: 27, itemName: "抗凝固剤持続速度"}},
          {itemInfo: {itemNo: 28, itemName: "抗凝固剤持続総量"}},
          {itemInfo: {itemNo: 29, itemName: "IP使用選択"}},
          {itemInfo: {itemNo: 30, itemName: "IPスタート"}},
          {itemInfo: {itemNo: 32, itemName: "IP速度"}},
          {itemInfo: {itemNo: 33, itemName: "IP速度最大値"}},
          {itemInfo: {itemNo: 34, itemName: "IPワンショットスタート"}},
          {itemInfo: {itemNo: 31, itemName: "IPワンショット量"}},
          {itemInfo: {itemNo: 35, itemName: "IP電源自動切り"}},
          {itemInfo: {itemNo: 36, itemName: "IP電源自動切り時間"}},
          {itemInfo: {itemNo: 37, itemName: "IP電源OKモニタ切り"}},
          {itemInfo: {itemNo: 38, itemName: "IP電源OKモニタ切り時間"}}
        ]
      },
      {
        subCategoryNo: 5,
        subCategoryName: "投与薬剤",
        component: "medicine",
        subCategoryItem: [
          {itemInfo: { itemNo: 1, itemName: "投与薬剤(数量+単位)" }},
          {itemInfo: { itemNo: 2, itemName: "投与薬剤(薬剤名+数量+単位)" }}
        ]
      },
      {
        subCategoryNo: 6,
        subCategoryName: "医療材料",
        component: "equipment",
        subCategoryItem: [{itemInfo: { itemNo: null, itemName: "医療材料" }}]
      },
      {
        subCategoryNo: 7,
        subCategoryName: "指示コメント",
        component: "ind-comment",
        subCategoryItem: [{itemInfo: { itemNo: 1, itemName: "指示コメント", itemCd: null, itemType: null }}]
      },
      //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end
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
        subCategoryName: "Qb・Qdプログラム",
        component: "qbqd-program",
        subCategoryItem: [{ itemNo: 1, itemName: "Qb・Qdプログラム", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 14,
        subCategoryName: "I-HDF",
        component: "i-hdf",
        subCategoryItem: [{ itemNo: 1, itemName: "I-HDF", itemColor: "#000000", itemPoint: "triangle" }]
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
        subCategoryName: "透析運転時間",
        rstCd: 14,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "透析運転時間", itemColor: "#000000", itemPoint: "triangle" }]
      },
      {
        subCategoryNo: 33,
        subCategoryName: "送信管理番号",
        rstCd: 17,
        component: "rst-info",
        subCategoryItem: [{ itemNo: 1, itemName: "送信管理番号", itemColor: "#000000", itemPoint: "triangle" }]
      },
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
  }
];
