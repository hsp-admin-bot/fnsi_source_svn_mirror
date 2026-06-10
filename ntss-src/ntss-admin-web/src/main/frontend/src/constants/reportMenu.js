/* mstReport */

// 帳票種別

export const REPORT_CLASS = {
  // add 2020-10-09 FNSI-仕様修正 名称変更 李 start
  // 1: "透析レポート",
  1: "治療経過表",
  // add 2020-10-09 FNSI-仕様修正 名称変更 李 end
  2: "単患者帳票",
  3: "複数患者帳票",
  4: "準備リスト",
  5: "配布リスト(ベッド)",
  6: "配布リスト(物品)",
  7: "装置帳票",
  8: "ラベル",
  9: "紹介状",
  // add FNSI-523 2次元帳票対応 夏 start
  10: "単集計",
  11: "複数集計"
  // add FNSI-523 2次元帳票対応 夏 end
};

// 下記帳票区分では「ベッド名」と「クール名」の列は非表示です

/*mod FNSI-改修内容 各帳票の並び順調整。 吉 start*/
/*export const REPORT_HIDDEN = [3,4,5,6,7,8];*/
export const REPORT_HIDDEN = [7];
/*mod FNSI-改修内容 各帳票の並び順調整。 吉 end*/


// データ抽出条件

export const EXTRACTION_CONDITION = {
  1: { // report_class
    isRangeTime: 0, // 1 is 有効, 0 is 無効
    isSpecifyDate: 1,
    isInspectionDate: 0,
    isEquipment: 0,
    isMedicine: 0,
    isLabelStart: 0,
    isSort: 1,
    // add #11603 検査予定のラベル出力とフィルタ機能 高 start
    isExamSet: 0,
    // add #11603 検査予定のラベル出力とフィルタ機能 高 end
    // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe start
    isInspection: 0
    // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe end
  },
  2: {
    isRangeTime: 1,
    isSpecifyDate: 1,
    isInspectionDate: 1,
    isEquipment: 0,
    isMedicine: 0,
    isLabelStart: 0,
    isSort: 1,
    // add #11603 検査予定のラベル出力とフィルタ機能 高 start
    isExamSet: 0,
    // add #11603 検査予定のラベル出力とフィルタ機能 高 end
    // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe start
    isInspection: 0
    // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe end
  },
  3: {
    isRangeTime: 1,
    isSpecifyDate: 1,
    isInspectionDate: 1,
    //// mod #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe start
    //isEquipment: 1,
    //isMedicine: 1,
    isEquipment: 0,
    isMedicine: 0,
    // add #11603 検査予定のラベル出力とフィルタ機能 高 start
    isExamSet: 0,
    // add #11603 検査予定のラベル出力とフィルタ機能 高 end
    //// mod #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe end
    isLabelStart: 0,
    isSort: 1,
    // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe start
    isInspection: 0
    // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe end
  },
  4: {
    isRangeTime: 0,
    isSpecifyDate: 1,
    isInspectionDate: 0,
    isEquipment: 1,
    isMedicine: 1,
    isLabelStart: 0,
    isSort: 1,
    // add #11603 検査予定のラベル出力とフィルタ機能 高 start
    isExamSet: 0,
    // add #11603 検査予定のラベル出力とフィルタ機能 高 end
    // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe start
    // mod #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
    // isInspection: 1
    isInspection: 0
    // mod #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
    // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe end
  },
  /*mod FNSI-改修内容 各帳票の並び順調整。 吉 start*/
  /*5: {
    isRangeTime: 0,
    isSpecifyDate: 1,
    isInspectionDate: 0,
    isEquipment: 1,
    isMedicine: 1,
    isLabelStart: 0,
    isSort: 0
  },*/
  5: {
    isRangeTime: 0,
    isSpecifyDate: 1,
    isInspectionDate: 0,
    isEquipment: 1,
    isMedicine: 1,
    isLabelStart: 0,
    isSort: 1,
    // add #11603 検査予定のラベル出力とフィルタ機能 高 start
    isExamSet: 0,
    // add #11603 検査予定のラベル出力とフィルタ機能 高 end
    // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe start
    // mod #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
    // isInspection: 1
    isInspection: 0
    // mod #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
    // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe end
  },
  /*mod FNSI-改修内容 各帳票の並び順調整。 吉 end*/
  6: {
    isRangeTime: 0,
    isSpecifyDate: 1,
    isInspectionDate: 0,
    isEquipment: 1,
    isMedicine: 1,
    isLabelStart: 0,
    isSort: 1,
    // add #11603 検査予定のラベル出力とフィルタ機能 高 start
    isExamSet: 0,
    // add #11603 検査予定のラベル出力とフィルタ機能 高 end
    // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe start
    // mod #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
    // isInspection: 1
    isInspection: 0
    // mod #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
    // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe end
  },

  /*mod FNSI-改修内容 各帳票の並び順調整。 吉 start*/
  /*7: {
    isRangeTime: 0,
    isSpecifyDate: 1,
    isInspectionDate: 0,
    isEquipment: 1,
    isMedicine: 1,
    isLabelStart: 0,
    isSort: 0
  },*/
  7: {
    // mod #699,700,751 陳 start
    // isRangeTime: 0,
    isRangeTime: 1,
    // mod #699,700,751 陳 end
    isSpecifyDate: 1,
    isInspectionDate: 1,
    // mod #11180 日常点検・定期点検で印刷情報が出ない limingzhe start
    //isEquipment: 1,
    //isMedicine: 1,
    isEquipment: 0,
    isMedicine: 0,
    // mod #11180 日常点検・定期点検で印刷情報が出ない limingzhe end
    isLabelStart: 0,
    isSort: 1,
    // add #11603 検査予定のラベル出力とフィルタ機能 高 start
    isExamSet: 0,
    // add #11603 検査予定のラベル出力とフィルタ機能 高 end
    // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe start
    isInspection: 0
    // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe end
  },
  /*mod FNSI-改修内容 各帳票の並び順調整。 吉 end*/
  8: {
    isRangeTime: 0,
    isSpecifyDate: 1,
    isInspectionDate: 0,
    isEquipment: 1,
    isMedicine: 1,
    isLabelStart: 1,
    isSort: 1,
    // add #11603 検査予定のラベル出力とフィルタ機能 高 start
    isExamSet: 1,
    // add #11603 検査予定のラベル出力とフィルタ機能 高 end
    // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe start
    isInspection: 1
    // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe end
  },
  9: {
    isRangeTime: 1,
    isSpecifyDate: 1,
    isInspectionDate: 1,
    //// mod #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe start
    //isEquipment: 1,
    //isMedicine: 1,
    isEquipment: 0,
    isMedicine: 0,
    //// mod #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe end
    isLabelStart: 1,
    isSort: 1,
    // add #11603 検査予定のラベル出力とフィルタ機能 高 start
    isExamSet: 0,
    // add #11603 検査予定のラベル出力とフィルタ機能 高 end
    // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe start
    isInspection: 0
    // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe end
  },
  // add FNSI-523 2次元帳票対応 夏 start
  10: {
    isRangeTime: 1,
    isSpecifyDate: 1,
    isInspectionDate: 1,
    // mod 2次元帳票医療材料や薬剤の選択が可能です 吉 start
    // isEquipment: 0,
    // isMedicine: 0,
    isEquipment: 1,
    isMedicine: 1,
    // mod 2次元帳票医療材料や薬剤の選択が可能です 吉 end
    isLabelStart: 0,
    isSort: 0,
    // add #11603 検査予定のラベル出力とフィルタ機能 高 start
    isExamSet: 0,
    // add #11603 検査予定のラベル出力とフィルタ機能 高 end
    // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe start
    // mod #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
    // isInspection: 1
    isInspection: 0
    // mod #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
    // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe end
  },
  11: {
    isRangeTime: 1,
    isSpecifyDate: 1,
    isInspectionDate: 1,
    // mod 2次元帳票医療材料や薬剤の選択が可能です 吉 start
    // isEquipment: 0,
    // isMedicine: 0,
    isEquipment: 1,
    isMedicine: 1,
    // mod 2次元帳票医療材料や薬剤の選択が可能です 吉 end
    isLabelStart: 0,
    isSort: 0,
    // add #11603 検査予定のラベル出力とフィルタ機能 高 start
    isExamSet: 0,
    // add #11603 検査予定のラベル出力とフィルタ機能 高 end
    // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe start
    // mod #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
    // isInspection: 1
    isInspection: 0
    // mod #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
    // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe end
  }
  // add FNSI-523 2次元帳票対応 夏 end
};

// 患者リスト表示順

export const SORT_CONDITION = {

  /*mod FNSI-改修内容 各帳票の並び順調整 吉 start*/
  /*1: [
      { id: "pat_id", text: "患者ID" },
      { id: "pat_last_name", text: "患者名" },
      { id: "ind_bed_cd", text: "ベッド" },
      { id: "ind_kur_cd", text: "クール" }
  ],
  2: [
      { id: "hosp_pat_id", text: "患者ID" },
      { id: "pat_last_name", text: "患者名" },
      { id: "ind_bed_cd", text: "ベッド" },
      { id: "ind_kur_cd", text: "クール" }
  ],
  3: [
      { id: "hosp_pat_id", text: "患者ID" },
      { id: "pat_last_name_kana", text: "フリガナ" },
      { id: "pat_group_name", text: "患者グループ名" },
      { id: "bed_name", text: "ベッド名" },
      { id: "rst_in_out_class", text: "入外区分" },
      { id: "ind_kur_cd", text: "クール" },
      { id: "pat_sex", text: "性別" },
      { id: "is_infect", text: "感染症患者" }
  ],
  4: [
      { id: "dialysis_day", text: "透析日" }
  ],
  5: [],
  6: [],
  7: [],
  8: [
      { id: "ind_kur_cd", text: "クール" },
      { id: "bed_name", text: "ベッド名" },
      { id: "ind_equip_cd", text: "薬剤/医材" },
      { id: "ind_equip_class", text: "分類名称" },
      { id: "room_bed_group_name", text: "ベッドグループ名" },
      { id: "medicine_name", text: "名称" }
  ],
  9: []*/
  1: [
    { id: "pat_id", text: "患者ID" },
    { id: "pat_name", text: "患者名" },
    { id: "bed_cd", text: "ベッド表示順" },
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
    // { id: "ind_kur_cd", text: "クール順" },
    { id: "ind_kur_cd", text: "クール表示順" },
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
    { id: "rst_in_out_class", text: "入外区分" },
    // mod #9323 donghao start
    // { id: "dialysis_room_group", text: "透析室表示順" },
    // { id: "room_bed_group", text: "ベッドグループ表示順" }
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
    // { id: "dialysis_room_group", text: "透析室" },
    // { id: "room_bed_group", text: "ベッドグループ" }
    { id: "dialysis_room_group", text: "透析室表示順" },
    { id: "room_bed_group", text: "ベッドグループ表示順" }
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
    // mod #9323 donghao start
  ],
  2: [
    { id: "dialysis_day", text: "治療日" },
    { id: "pat_id", text: "患者ID" },
    { id: "pat_name", text: "患者名" },
    { id: "bed_cd", text: "ベッド表示順" },
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
    // { id: "ind_kur_cd", text: "クール順" },
    { id: "ind_kur_cd", text: "クール表示順" },
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
    { id: "rst_in_out_class", text: "入外区分" }
  ],
  3: [
    { id: "pat_id", text: "患者ID" },
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
    // { id: "pat_last_name_kana", text: "フリガナ" },
    { id: "pat_last_name_kana", text: "患者名" },
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
    { id: "pat_group", text: "患者グループ表示順" },
    { id: "room_bed_group", text: "ベッドグループ表示順" },
    { id: "bed_cd", text: "ベッド表示順" },
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
    // { id: "ind_kur_cd", text: "クール順" },
    { id: "ind_kur_cd", text: "クール表示順" },
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
    { id: "rst_in_out_class", text: "入外区分" },
    { id: "pat_sex", text: "性別" },
    { id: "inf_ise_pat", text: "感染症患者" },
    { id: "blood_type", text: "血液型" },
    { id: "start_time", text: "透析開始" },
    { id: "end_time", text: "透析終了" },
    { id: "end_plan", text: "終了予定" },
    { id: "end_pred", text: "終了予測" }
  ],
  4: [
    { id: "ind_equip_name", text: "名称" },
    // mod #11435 並び替えキー「医材／薬剤」の仕様見直し 高 start
    // { id: "ind_equip_cd", text: "医材/薬剤" },
    // { id: "ind_equip_class", text: "分類名称" }
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
    // { id: "ind_equip_cd", text: "データ種別順" },
    // { id: "ind_equip_class", text: "分類名称順" }
    { id: "ind_equip_cd", text: "データ種別表示順" },
    { id: "ind_equip_class", text: "分類名称表示順" }
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
    // mod #11435 並び替えキー「医材／薬剤」の仕様見直し 高 end
  ],
// mod #9323 donghao start
  5: [
    { id: "bed_cd", text: "ベッド表示順" },
    {id: "room_bed_group", text: "ベッドグループ表示順" },
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
    // { id: "ind_kur_cd", text: "クール順" }
    { id: "ind_kur_cd", text: "クール表示順" }
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
    // mod #9323 donghao end
  ],
  6: [
    { id: "ind_equip_name", text: "名称" },
    // mod #11435 並び替えキー「医材／薬剤」の仕様見直し 高 start
    // { id: "ind_equip_cd", text: "医材/薬剤" },
    // { id: "ind_equip_class", text: "分類名称" }
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
    // { id: "ind_equip_cd", text: "データ種別順" },
    // { id: "ind_equip_class", text: "分類名称順" },
    // add #12032 配布リスト（物品）の並び順に「データ分類」がない 高　start
    // { id: "ind_equip_data_group", text: "治療条件順" }
    // add #12032 配布リスト（物品）の並び順に「データ分類」がない 高　end
    { id: "ind_equip_cd", text: "データ種別表示順" },
    { id: "ind_equip_class", text: "分類名称表示順" },
    { id: "ind_equip_data_group", text: "治療条件" }
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
    // mod #11435 並び替えキー「医材／薬剤」の仕様見直し 高 end
  ],
  /*mod FNSI-改修内容装置帳票の対応 任 start*/
  /*7: [],*/
  7: [
    // mod #9323 donghao start
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
    // { id: "machine_name", text: "装置名称"},
    { id: "machine_name", text: "装置表示順"},
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
    { id: "machine_id", text: "製造番号" },
    { id: "machine_type", text: "型式名"},
    { id: "bed_cd", text: "ベッド表示順" }
    // mod #9323 donghao start
  ],
  /*mod FNSI-改修内容装置帳票の対応 任 end*/
  // mod #7880 帳票：ラベルが正しく表示されない 姜 start
  /**
    8: [
   { id: "dialysis_room_group", text: "透析室グループ" },
   { id: "room_bed_group", text: "ベッドグループ" },
   { id: "bed_name", text: "ベッド名" },
   { id: "ind_kur_cd", text: "クール" }
   ],
   */
  8: [
    // mod #9323 donghao start
    // { id: "ind_equip_cd", text: "医材/薬剤" },
    // { id: "bed_cd", text: "ベッド表示順" },
    // { id: "kur_cd", text: "クール順" },
    // { id: "ind_equip_class", text: "分類順" },
    // { id: "medicine_name", text: "名称順" },
    // { id: "room_bed_group", text: "ベッドグループ表示順" },
    // { id: "dialysis_room_group", text: "透析室表示順" }
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
    // { id: "kur_cd", text: "クール順" },
    { id: "kur_cd", text: "クール表示順" },
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
    { id: "bed_cd", text: "ベッド表示順" },
    // mod #11435 並び替えキー「医材／薬剤」の仕様見直し 高 start
    // { id: "ind_equip_cd", text: "医材/薬剤" },
    // { id: "ind_equip_class", text: "分類順" },
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
    // { id: "ind_equip_cd", text: "データ種別順" },
    // { id: "ind_equip_class", text: "分類名称順" },
    { id: "ind_equip_cd", text: "データ種別表示順" },
    { id: "ind_equip_class", text: "分類名称表示順" },
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
    // mod #11435 並び替えキー「医材／薬剤」の仕様見直し 高 end
    { id: "room_bed_group", text: "ベッドグループ表示順" },
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
    // { id: "medicine_name", text: "名称順" },
    { id: "medicine_name", text: "名称" },
    // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
    { id: "dialysis_room_group", text: "透析室表示順" }
    // mod #9323 donghao end
  ],
  // mod #7880 帳票：ラベルが正しく表示されない 姜 end
  9: [
    { id: "dialysis_day", text: "治療日" },
    { id: "pat_id", text: "患者ID" },
    { id: "rst_in_out_class", text: "入外区分" },
    { id: "inf_ise_pat", text: "感染症患者" }
  ],
  /*mod FNSI-改修内容 各帳票の並び順調整 吉 end*/
  // add FNSI-523 2次元帳票対応 夏 start
  10: [],
  11: []
  // add FNSI-523 2次元帳票対応 夏 end
};

// デフォルト値（※データ抽出条件が未保存時、画面に設定されるべき値）
export const DEFAULT_CONDITION = {
	sortList: [{key: null,sort: 0},{key: null,sort: 0},{key: null,sort: 0}],
	dataCond: {
		dateType: 0,
		periodType: 1,
		beforeAfter: 1,
		numDay: 0,
		regOrderClass: ["1","2"],
    // add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方区分」を追加 高 start
    prescriptionClass: ["1","2"],
    // add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方区分」を追加 高 end
    letterCategory: ["0","1"],
	},
	equipment: {
		checkedList: ["all"]
	},
	medicine: {
		checkedList: ["all"]
	},
	inspect: 0
};
