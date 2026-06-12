/**
 * 患者経過総合ビューアレイアウトマスタ
 * @summary
 */
export const mstPatViewerLayout =
  [{
    "component": "treatment-contents",
    "categoryNo": 1,
    "categoryItem": [{
      "component": "treat-plan",
      "subCategoryNo": 1,
      "subCategoryItem": [{
        "itemNo": 1,
        "itemName": "治療予定"
      }],
      "subCategoryName": "治療予定"
    }, {
      "component": "treat-method",
      "subCategoryNo": 2,
      "subCategoryItem": [{
        "itemNo": 1,
        "itemName": "治療方法"
      }],
      "subCategoryName": "治療方法"
    }, {
      "component": "schedule",
      "subCategoryNo": 3,
      "subCategoryItem": [{
        "itemNo": 1,
        "itemName": "クール"
      }, {
        "itemNo": 2,
        "itemName": "治療開始時刻"
      }, {
        "itemNo": 3,
        "itemName": "ベッド"
      }],
      "subCategoryName": "スケジュール"
    }, {
      "component": "treat-cond",
      "subCategoryNo": 4,
      "subCategoryItem": [{
        "itemNo": 1,
        "itemName": "治療時間"
      }, {
        "itemNo": 2,
        "itemName": "VA"
      }, {
        "itemNo": -1,
        "itemName": "DW"
      }, {
        "itemNo": 3,
        "itemName": "目標体重"
      }, {
        "itemNo": 4,
        "itemName": "除水量制限"
      }, {
        "itemNo": 5,
        "itemName": "ダイアライザ"
      }, {
        "itemNo": 6,
        "itemName": "吸着カラム"
      }, {
        "itemNo": 7,
        "itemName": "1次膜"
      }, {
        "itemNo": 8,
        "itemName": "2次膜"
      }, {
        "itemNo": 9,
        "itemName": "穿刺針(A針)"
      }, {
        "itemNo": 10,
        "itemName": "穿刺針(V針)"
      }, {
        "itemNo": 11,
        "itemName": "穿刺針(SN)"
      }, {
        "itemNo": 12,
        "itemName": "シングルニードル使用"
      }, {
        "itemNo": 13,
        "itemName": "血液回路"
      }, {
        "itemNo": 14,
        "itemName": "血流量"
      }, {
        "itemNo": 15,
        "itemName": "透析液"
      }, {
        "itemNo": 16,
        "itemName": "透析液流量"
      }, {
        "itemNo": 17,
        "itemName": "透析液使用数"
      }, {
        "itemNo": 18,
        "itemName": "透析液温度"
      }, {
        "itemNo": 19,
        "itemName": "補液"
      }, {
        "itemNo": 20,
        "itemName": "補液量"
      }, {
        "itemNo": 21,
        "itemName": "補液選択"
      }, {
        "itemNo": 22,
        "itemName": "補液使用数"
      }, {
        "itemNo": 23,
        "itemName": "補液温度"
      }, {
        "itemNo": 24,
        "itemName": "補液速度"
      }, {
        "itemNo": 25,
        "itemName": "抗凝固剤"
      }, {
        "itemNo": 26,
        "itemName": "抗凝固剤ワンショット量"
      }, {
        "itemNo": 27,
        "itemName": "抗凝固剤持続速度"
      }, {
        "itemNo": 28,
        "itemName": "抗凝固剤持続総量"
      }, {
        "itemNo": 29,
        "itemName": "IP使用選択"
      }, {
        "itemNo": 30,
        "itemName": "IPスタート"
      }, {
        "itemNo": 32,
        "itemName": "IP速度"
      }, {
        "itemNo": 33,
        "itemName": "IP速度最大値"
      }, {
        "itemNo": 34,
        "itemName": "IPワンショットスタート"
      }, {
        "itemNo": 31,
        "itemName": "IPワンショット量"
      }, {
        "itemNo": 35,
        "itemName": "IP電源自動切り"
      }, {
        "itemNo": 36,
        "itemName": "IP電源自動切り時間"
      }, {
        "itemNo": 37,
        "itemName": "IP電源OKモニタ切り"
      }, {
        "itemNo": 38,
        "itemName": "IP電源OKモニタ切り時間"
      }],
      "subCategoryName": "治療条件"
    }, {
      "component": "medicine",
      "subCategoryNo": 5,
      "subCategoryItem": [{
        "itemNo": 1,
        "itemName": "投与薬剤(数量+単位)"
      }],
      "subCategoryName": "投与薬剤"
    }, {
      "component": "equipment",
      "subCategoryNo": 6,
      "subCategoryItem": [{
        "itemNo": 1,
        "itemName": "医療材料"
      }],
      "subCategoryName": "医療材料"
    }, {
      "component": "ind-comment",
      "subCategoryNo": 7,
      "subCategoryItem": [{
        "itemNo": 1,
        "itemName": "指示コメント"
      }],
      "subCategoryName": "指示コメント"
    }, {
      "component": "tare-info",
      "subCategoryNo": 8,
      "subCategoryItem": [{
        "itemNo": 1,
        "itemName": "風袋"
      }],
      "subCategoryName": "風袋"
    }, {
      "component": "off-water-info",
      "subCategoryNo": 9,
      "subCategoryItem": [{
        "itemNo": 1,
        "itemName": "除水補正"
      }],
      "subCategoryName": "除水補正"
    }, {
      "component": "ufr-program",
      "subCategoryNo": 10,
      "subCategoryItem": [{
        "itemNo": 1,
        "itemName": "除水プログラム"
      }],
      "subCategoryName": "除水プログラム"
    }, {
      "component": "na-program",
      "subCategoryNo": 11,
      "subCategoryItem": [{
        "itemNo": 1,
        "itemName": "Na注入プログラム"
      }],
      "subCategoryName": "Na注入プログラム"
    }, {
      "component": "dialysate-program",
      "subCategoryNo": 12,
      "subCategoryItem": [{
        "itemNo": 1,
        "itemName": "透析液濃度プログラム"
      }],
      "subCategoryName": "透析液濃度プログラム"
    }, {
      "component": "qbqd-program",
      "subCategoryNo": 13,
      "subCategoryItem": [{
        "itemNo": 1,
        "itemName": "Qb・Qdプログラム"
      }],
      "subCategoryName": "Qb・Qdプログラム"
    }, {
      "component": "i-hdf",
      "subCategoryNo": 14,
      "subCategoryItem": [{
        "itemNo": 1,
        "itemName": "I-HDF"
      }],
      "subCategoryName": "I-HDF"
    }, {
      "component": "bv-ufc",
      "subCategoryNo": 15,
      "subCategoryItem": [{
        "itemNo": 1,
        "itemName": "BV-UFC"
      }],
      "subCategoryName": "BV-UFC"
    }, {
      "component": "diaysis-program",
      "subCategoryNo": 16,
      "subCategoryItem": [{
        "itemNo": 1,
        "itemName": "透析量プログラム"
      }],
      "subCategoryName": "透析量プログラム"
    }, {
      "rstCd": 1,
      "component": "rst-info",
      "subCategoryNo": 17,
      "subCategoryItem": [{
        "itemNo": 1,
        "itemName": "治療開始日時"
      }],
      "subCategoryName": "治療開始日時"
    }, {
      "rstCd": 2,
      "component": "rst-info",
      "subCategoryNo": 18,
      "subCategoryItem": [{
        "itemNo": 1,
        "itemName": "治療終了日時"
      }],
      "subCategoryName": "治療終了日時"
    }, {
      "rstCd": 3,
      "component": "rst-info",
      "subCategoryNo": 19,
      "subCategoryItem": [{
        "itemNo": 1,
        "itemName": "入外区分"
      }],
      "subCategoryName": "入外区分"
    }, {
      "rstCd": 4,
      "component": "rst-info",
      "subCategoryNo": 20,
      "subCategoryItem": [{
        "itemNo": 1,
        "itemName": "透析回数"
      }],
      "subCategoryName": "透析回数"
    }, {
      "rstCd": 6,
      "component": "rst-info",
      "subCategoryNo": 22,
      "subCategoryItem": [{
        "itemNo": 1,
        "itemName": "穿刺者名1"
      }],
      "subCategoryName": "穿刺者名1"
    }, {
      "rstCd": 7,
      "component": "rst-info",
      "subCategoryNo": 23,
      "subCategoryItem": [{
        "itemNo": 1,
        "itemName": "穿刺者名2"
      }],
      "subCategoryName": "穿刺者名2"
    }, {
      "rstCd": 8,
      "component": "rst-info",
      "subCategoryNo": 24,
      "subCategoryItem": [{
        "itemNo": 1,
        "itemName": "穿刺日時"
      }],
      "subCategoryName": "穿刺日時"
    }, {
      "rstCd": 9,
      "component": "rst-info",
      "subCategoryNo": 25,
      "subCategoryItem": [{
        "itemNo": 1,
        "itemName": "返血者名1"
      }],
      "subCategoryName": "返血者名1"
    }, {
      "rstCd": 10,
      "component": "rst-info",
      "subCategoryNo": 26,
      "subCategoryItem": [{
        "itemNo": 1,
        "itemName": "返血者名2"
      }],
      "subCategoryName": "返血者名2"
    }, {
      "rstCd": 11,
      "component": "rst-info",
      "subCategoryNo": 27,
      "subCategoryItem": [{
        "itemNo": 1,
        "itemName": "返血日時"
      }],
      "subCategoryName": "返血日時"
    }, {
      "rstCd": 12,
      "component": "rst-info",
      "subCategoryNo": 28,
      "subCategoryItem": [{
        "itemNo": 1,
        "itemName": "担当者名1"
      }],
      "subCategoryName": "担当者名1"
    }, {
      "rstCd": 13,
      "component": "rst-info",
      "subCategoryNo": 29,
      "subCategoryItem": [{
        "itemNo": 1,
        "itemName": "担当者名2"
      }],
      "subCategoryName": "担当者名2"
    }, {
      "rstCd": 14,
      "component": "rst-info",
      "subCategoryNo": 30,
      "subCategoryItem": [{
        "itemNo": 1,
        "itemName": "透析運転時間"
      }],
      "subCategoryName": "透析運転時間"
    },
      // //  del 5920 項目の削除 start 鞠 追加の時
      //   {
      //   "rstCd": 15,
      //   "component": "rst-info",
      //   "subCategoryNo": 31,
      //   "subCategoryItem": [{
      //     "itemNo": 1,
      //     "itemName": "Kt/V"
      //   }],
      //   "subCategoryName": "Kt/V"
      // }, {
      //   "rstCd": 16,
      //   "component": "rst-info",
      //   "subCategoryNo": 32,
      //   "subCategoryItem": [{
      //     "itemNo": 1,
      //     "itemName": "透析記録確認日時"
      //   }],
      //   "subCategoryName": "透析記録確認日時"
      // }, {
      //   "rstCd": 18,
      //   "component": "rst-info",
      //   "subCategoryNo": 34,
      //   "subCategoryItem": [{
      //     "itemNo": 1,
      //     "itemName": "血液浄化装置名称"
      //   }],
      //   "subCategoryName": "血液浄化装置名称"
      // },
      //   //  del 5920 項目の削除 end 鞠 追加の時
      {
        "rstCd": 19,
        "component": "rst-info",
        "subCategoryNo": 35,
        "subCategoryItem": [{
          "itemNo": 1,
          "itemName": "I-HDF引き残し"
        }],
        "subCategoryName": "I-HDF引き残し"
      }, {
        "rstCd": 20,
        "component": "rst-info",
        "subCategoryNo": 36,
        "subCategoryItem": [{
          "itemNo": 1,
          "itemName": "透析前体重測定値"
        }],
        "subCategoryName": "透析前体重測定値"
      }, {
        "rstCd": 21,
        "component": "rst-info",
        "subCategoryNo": 37,
        "subCategoryItem": [{
          "itemNo": 1,
          "itemName": "透析前体重"
        }],
        "subCategoryName": "透析前体重"
      }, {
        "rstCd": 22,
        "component": "rst-info",
        "subCategoryNo": 38,
        "subCategoryItem": [{
          "itemNo": 1,
          "itemName": "前体重測定日時"
        }],
        "subCategoryName": "前体重測定日時"
      }, {
        "rstCd": 23,
        "component": "rst-info",
        "subCategoryNo": 39,
        "subCategoryItem": [{
          "itemNo": 1,
          "itemName": "透析後体重測定値"
        }],
        "subCategoryName": "透析後体重測定値"
      }, {
        "rstCd": 24,
        "component": "rst-info",
        "subCategoryNo": 40,
        "subCategoryItem": [{
          "itemNo": 1,
          "itemName": "透析後体重"
        }],
        "subCategoryName": "透析後体重"
      }, {
        "rstCd": 25,
        "component": "rst-info",
        "subCategoryNo": 41,
        "subCategoryItem": [{
          "itemNo": 1,
          "itemName": "後体重測定日時"
        }],
        "subCategoryName": "後体重測定日時"
      }, {
        "rstCd": 26,
        "component": "rst-info",
        "subCategoryNo": 42,
        "subCategoryItem": [{
          "itemNo": 1,
          "itemName": "CTR"
        }],
        "subCategoryName": "CTR"
      }, {
        "rstCd": 27,
        "component": "rst-info",
        "subCategoryNo": 43,
        "subCategoryItem": [{
          "itemNo": 1,
          "itemName": "CTR測定日時"
        }],
        "subCategoryName": "CTR測定日時"
      }, {
        "rstCd": 28,
        "component": "rst-info",
        "subCategoryNo": 44,
        "subCategoryItem": [{
          "itemNo": 1,
          "itemName": "CTR測定時体重"
        }],
        "subCategoryName": "CTR測定時体重"
      }, {
        "rstCd": 29,
        "component": "rst-info",
        "subCategoryNo": 45,
        "subCategoryItem": [{
          "itemNo": 1,
          "itemName": "目標除水量"
        }],
        "subCategoryName": "目標除水量"
      }, {
        "rstCd": 30,
        "component": "rst-info",
        "subCategoryNo": 46,
        "subCategoryItem": [{
          "itemNo": 1,
          "itemName": "実績除水量"
        }],
        "subCategoryName": "実績除水量"
      }, {
        "rstCd": 31,
        "component": "rst-info",
        "subCategoryNo": 47,
        "subCategoryItem": [{
          "itemNo": 1,
          "itemName": "除水積算量"
        }],
        "subCategoryName": "除水積算量"
      }, {
        "rstCd": 32,
        "component": "rst-info",
        "subCategoryNo": 48,
        "subCategoryItem": [{
          "itemNo": 1,
          "itemName": "補液積算量"
        }],
        "subCategoryName": "補液積算量"
      }, {
        "rstCd": 43,
        "component": "rst-info",
        "subCategoryNo": 63,
        "subCategoryItem": [{
          "itemNo": 1,
          "itemName": "静的静脈圧"
        }],
        "subCategoryName": "静的静脈圧"
      }, {
        "rstCd": 44,
        "component": "rst-info",
        "subCategoryNo": 64,
        "subCategoryItem": [{
          "itemNo": 1,
          "itemName": "IAP Ratio"
        }],
        "subCategoryName": "IAP Ratio"
      }, {
        "rstCd": 33,
        "component": "rst-info",
        "subCategoryNo": 49,
        "subCategoryItem": [{
          "itemNo": 1,
          "itemName": "Kt/V測定値"
        }],
        "subCategoryName": "Kt/V測定値"
      }, {
        "rstCd": 34,
        "component": "rst-info",
        "subCategoryNo": 50,
        "subCategoryItem": [{
          "itemNo": 1,
          "itemName": "URR"
        }],
        "subCategoryName": "URR"
      }, {
        "subCategoryNo": 73,
        "subCategoryName": "再循環率",
        "rstCd": 45,
        "component": "rst-info",
        "subCategoryItem": [{
          "itemNo": 1,
          "itemName": "再循環率" }]
      },{
        "rstCd": 35,
        "component": "rst-info",
        "subCategoryNo": 51,
        "subCategoryItem": [{
          "itemNo": 1,
          "itemName": "減少量"
        }],
        "subCategoryName": "減少量"
      }, {
        "rstCd": 36,
        "component": "rst-info",
        "subCategoryNo": 52,
        "subCategoryItem": [{
          "itemNo": 1,
          "itemName": "前血圧"
        }],
        "subCategoryName": "前血圧"
      }, {
        "rstCd": 37,
        "component": "rst-info",
        "subCategoryNo": 53,
        "subCategoryItem": [{
          "itemNo": 1,
          "itemName": "後血圧"
        }],
        "subCategoryName": "後血圧"
      }, {
        "rstCd": 38,
        "component": "rst-info",
        "subCategoryNo": 54,
        "subCategoryItem": [{
          "itemNo": 1,
          "itemName": "体温(1回目)"
        }],
        "subCategoryName": "体温(1回目)"
      }, {
        "rstCd": 39,
        "component": "rst-info",
        "subCategoryNo": 55,
        "subCategoryItem": [{
          "itemNo": 1,
          "itemName": "体温(最終)"
        }],
        "subCategoryName": "体温(最終)"
      }, {
        "rstCd": 40,
        "component": "rst-info",
        "subCategoryNo": 56,
        "subCategoryItem": [],
        "subCategoryName": "愁訴処置情報"
      }, {
        "rstCd": 46,
        "component": "rst-info",
        "subCategoryNo": 74,
        "subCategoryItem": [{
          "itemNo": 1,
          "itemName": "加算・管理料"
        }],
        "subCategoryName": "加算・管理料"
      }, {
        "rstCd": 41,
        "component": "rst-info",
        "subCategoryNo": 57,
        "subCategoryItem": [{
          "itemNo": 1,
          "itemName": "回診記録情報"
        }],
        "subCategoryName": "回診記録情報"
      }, {
        "component": "vital",
        "subClassify": "vital1",
        "subCategoryNo": 58,
        "subCategoryItem": [],
        "subCategoryName": "バイタル・モニタグラフ①-1　入室～退室"
      }, {
        "component": "vital",
        "subClassify": "vital1",
        "subCategoryNo": 65,
        "subCategoryItem": [],
        "subCategoryName": "バイタル・モニタグラフ①-2　入室～退室"
      }, {
        "component": "vital",
        "subClassify": "vital1",
        "subCategoryNo": 66,
        "subCategoryItem": [],
        "subCategoryName": "バイタル・モニタグラフ①-3　入室～退室"
      }, {
        "component": "vital",
        "subClassify": "vital2",
        "subCategoryNo": 59,
        "subCategoryItem": [],
        "subCategoryName": "バイタル・モニタグラフ②-1　入室～退室"
      }, {
        "component": "vital",
        "subClassify": "vital2",
        "subCategoryNo": 67,
        "subCategoryItem": [],
        "subCategoryName": "バイタル・モニタグラフ②-2　入室～退室"
      }, {
        "component": "vital",
        "subClassify": "vital2",
        "subCategoryNo": 68,
        "subCategoryItem": [],
        "subCategoryName": "バイタル・モニタグラフ②-3　入室～退室"
      }, {
        "component": "vital",
        "subClassify": "vital3",
        "subCategoryNo": 60,
        "subCategoryItem": [],
        "subCategoryName": "バイタル・モニタグラフ③-1　入室～退室"
      }, {
        "component": "vital",
        "subClassify": "vital3",
        "subCategoryNo": 69,
        "subCategoryItem": [],
        "subCategoryName": "バイタル・モニタグラフ③-2　入室～退室"
      }, {
        "component": "vital",
        "subClassify": "vital3",
        "subCategoryNo": 70,
        "subCategoryItem": [],
        "subCategoryName": "バイタル・モニタグラフ③-3　入室～退室"
      }, {
        "component": "vital",
        "subClassify": "vital4",
        "subCategoryNo": 61,
        "subCategoryItem": [],
        "subCategoryName": "バイタル・モニタグラフ④-1　入室～退室"
      }, {
        "component": "vital",
        "subClassify": "vital4",
        "subCategoryNo": 71,
        "subCategoryItem": [],
        "subCategoryName": "バイタル・モニタグラフ④-2　入室～退室"
      }, {
        "component": "vital",
        "subClassify": "vital4",
        "subCategoryNo": 72,
        "subCategoryItem": [],
        "subCategoryName": "バイタル・モニタグラフ④-3　入室～退室"
      }],
    "categoryName": "治療情報"
  }, {
    "component": "exam-info",
    "categoryNo": 12,
    "categoryItem": [{
      "component": "exam-info",
      "subCategoryNo": 1,
      "subCategoryItem": [{
        "itemNo": 1,
        "itemName": "検査予定"
      }],
      "subCategoryName": "検査予定"
    }],
    "categoryName": "検査予定"
  }, {
    "component": "rad-info",
    "categoryNo": 13,
    "categoryItem": [{
      "component": "rad-info",
      "subCategoryNo": 1,
      "subCategoryItem": [{
        "itemNo": 1,
        "itemName": "一般撮影検査予定"
      }],
      "subCategoryName": "一般撮影検査予定"
    }],
    "categoryName": "一般撮影検査予定"
  }, {
    "component": "letter",
    "categoryNo": 14,
    "categoryItem": [{
      "component": "letter",
      "subCategoryNo": 1,
      "subCategoryItem": [{
        "itemNo": 1,
        "itemName": "紹介状"
      }],
      "subCategoryName": "紹介状"
    }],
    "categoryName": "紹介状"
  }, {
    "component": "prescription",
    "categoryNo": 17,
    "categoryItem": [{
      "component": "prescription",
      "subCategoryNo": 1,
      "subCategoryItem": [{
        "itemNo": 1,
        "itemName": "処方"
      }],
      "subCategoryName": "処方"
    }],
    "categoryName": "処方"
  }];
