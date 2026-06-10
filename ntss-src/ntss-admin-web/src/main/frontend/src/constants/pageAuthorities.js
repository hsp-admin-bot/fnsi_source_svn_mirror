// add #10359 編集権限の動作不正 start
import {AUTHORITY_CODES} from "@/constants/userAuthority";

/**
 * 画面項目権限設定
 */
export const PAGE_AUTHORITY_CODES = {
  // 体重測定画面
  SendConditionMainComponent: {
    // デフォルト権限
    default_authority: {authority: []},
    // クールベッド
    item_schedule_button: {authority: [[AUTHORITY_CODES.IND_PEDIT, AUTHORITY_CODES.IND_EDIT, AUTHORITY_CODES.SCHE_MOVE]]},
    // 目標体重
    item_target_weight: {authority: [[AUTHORITY_CODES.IND_PEDIT, AUTHORITY_CODES.IND_EDIT]]},
    // 除水制限
    item_water_removal_limit: {authority: [[AUTHORITY_CODES.IND_PEDIT, AUTHORITY_CODES.IND_EDIT]]},
  },
  // 患者情報共通ヘッダー
  PatHeader: {
    // デフォルト権限
    default_authority: {authority: [[AUTHORITY_CODES.PAT_EDIT]]},
  },
  // 患者経過総合ビューア
  Indication: {
    // デフォルト権限
    default_authority: {authority: [[AUTHORITY_CODES.IND_PEDIT, AUTHORITY_CODES.IND_EDIT]]},
    // 患者経過総合ビューアメニュー
    item_treat_plan_menu: {authority: [[AUTHORITY_CODES.IND_PEDIT, AUTHORITY_CODES.IND_EDIT]]},
    // 手動実績作成
    item_treat_plan_menu_rstcreate: {authority: [[AUTHORITY_CODES.RST_EDIT]]},
    // 予定移動_治療日
    item_paln_move_date: {authority: [[AUTHORITY_CODES.IND_PEDIT, AUTHORITY_CODES.IND_EDIT]]},
    // スケジュール
    item_schedule: {authority: [[AUTHORITY_CODES.IND_PEDIT, AUTHORITY_CODES.IND_EDIT, AUTHORITY_CODES.SCHE_MOVE]]},
    // 風袋・除水補正
    item_base_tare_off_water: {authority: [[AUTHORITY_CODES.PAT_EDIT]]},
    // 身体情報
    item_physical_info_card: {authority: [[AUTHORITY_CODES.PAT_EDIT], [AUTHORITY_CODES.IND_PEDIT, AUTHORITY_CODES.IND_EDIT]]},
  },
  // 患者情報
  PatInfo: {
    // デフォルト権限
    default_authority: {authority: [[AUTHORITY_CODES.PAT_EDIT]]},
    // 身体情報
    item_physical_info_card: {authority: [[AUTHORITY_CODES.PAT_EDIT], [AUTHORITY_CODES.IND_PEDIT, AUTHORITY_CODES.IND_EDIT]]},
    // 患者グループ
    item_pat_group_card: {authority: [[AUTHORITY_CODES.PAT_EDIT]]},
    // カード作成
    item_createCard_btn: {authority: [[AUTHORITY_CODES.PAT_EDIT]]},
    // 削除
    item_delete_btn: {authority: [[AUTHORITY_CODES.DEL_PAT]]},
  },
  // 患者グループ
  PatGroup: {
    // デフォルト権限
    default_authority: {authority: [[AUTHORITY_CODES.PAT_EDIT]]},
  },
  // 処方
  PatPrescription: {
    // デフォルト権限
    default_authority: {authority: [[AUTHORITY_CODES.PRESCRIPTION_PEDIT, AUTHORITY_CODES.PRESCRIPTION_EDIT]]},
    // 削除
    item_delete_btn: {authority: [[AUTHORITY_CODES.DEL_PRESCRIPTION]]},
  },
  // 一般撮影検査依頼
  ExamRequest: {
    // デフォルト権限
    default_authority: {authority: [[AUTHORITY_CODES.IND_EXAM_EDIT, AUTHORITY_CODES.IND_EXAM_PEDIT]]},
  },
  // 検査依頼
  RadRequest: {
    // デフォルト権限
    default_authority: {authority: [[AUTHORITY_CODES.IND_EXAM_EDIT, AUTHORITY_CODES.IND_EXAM_PEDIT]]},
  },
  // 検査結果
  ExamRecord: {
    // デフォルト権限
    default_authority: {authority: [[AUTHORITY_CODES.RST_EXAM_EDIT]]},
    // 削除
    item_delete_btn: {authority: [[AUTHORITY_CODES.DEL_EXAM]]},
  },
  // データリスト
  MultiPatList: {
    // デフォルト権限
    default_authority: {authority: [[AUTHORITY_CODES.PAT_EDIT]]},
  },
  // 装置設定
  DevicesetInfo: {
    // デフォルト権限
    default_authority: {authority: [[AUTHORITY_CODES.PAT_DEVSET_EDIT]]},
    // 風袋・除水補正
    item_baseTareAndOffWater: {authority: [[AUTHORITY_CODES.PAT_EDIT]]},
  },
  // 指示受け・指示承認
  IndicationList: {
    // デフォルト権限
    default_authority: {authority: [[AUTHORITY_CODES.IND_RECEIVE_EDIT]]},
  },
  // 治療状況リスト・マップ
  StatusListMap: {
    // デフォルト権限
    default_authority: {authority: [[AUTHORITY_CODES.RST_EDIT]]},
    // 削除
    item_delete_btn: {authority: [[AUTHORITY_CODES.DEL_RST]]},
    // 治療状況リスト・スケジュール割り当て
    item_list_assignment: {authority: [[AUTHORITY_CODES.RST_EDIT]]},
    // 名前割り当て
    item_list_schedule: {authority: [[AUTHORITY_CODES.IND_EDIT, AUTHORITY_CODES.IND_PEDIT], [AUTHORITY_CODES.RST_EDIT]]},
    // 治療状況マップ・スケジュール割り当て
    item_map_schedule: {authority: [[AUTHORITY_CODES.RST_EDIT]]},
    // スケジュール
    item_map_schedule_move: {authority: [[AUTHORITY_CODES.IND_EDIT, AUTHORITY_CODES.IND_PEDIT, AUTHORITY_CODES.SCHE_MOVE]]},
  },
  // チェックリスト
  CheckList: {
    // デフォルト権限
    default_authority: {authority: [[AUTHORITY_CODES.RST_EDIT]]},
  },
  // 治療記録
  TreatmentRecord: {
    // デフォルト権限
    default_authority: {authority: [[AUTHORITY_CODES.RST_EDIT]]},
    // 削除
    item_delete_btn: {authority: [[AUTHORITY_CODES.DEL_RST]]},
    // 回診記録
    item_round_component: {authority: [[AUTHORITY_CODES.RST_EDIT], [AUTHORITY_CODES.IND_PEDIT, AUTHORITY_CODES.IND_EDIT]]},
    //実績マージ
    item_merge_results:{authority:[[AUTHORITY_CODES.RST_EDIT]]},
    //観察記録
    item_observation_record:{authority:[[AUTHORITY_CODES.PAT_EVENT_EDIT],[AUTHORITY_CODES.RST_EDIT]]},
  },
  // 患者イベント
  PatEvent: {
    // デフォルト権限
    default_authority: {authority: [[AUTHORITY_CODES.PAT_EVENT_EDIT]]},
    // 患者イベント削除
    item_patevent_del: {authority: [[AUTHORITY_CODES.DEL_PAT_EVENT]]},
    // 治療実績削除
    item_patrst_del: {authority: [[AUTHORITY_CODES.DEL_RST]]},
  },
  // 予定
  ScheduleList: {
    // スケジュール
    item_schedule: {authority: [[AUTHORITY_CODES.IND_EDIT, AUTHORITY_CODES.IND_PEDIT, AUTHORITY_CODES.SCHE_MOVE]]}
  },
  // 施設カレンダ
  FacilityCalendar: {
    // デフォルト権限
    default_authority: {authority: [[AUTHORITY_CODES.FCL_EDIT]]}
  },
  // add #11065 【03】編集権限バグ修正 関 start
  // 機器保守
  MotionRecord: {
    // デフォルト権限
    default_authority: {authority: [[AUTHORITY_CODES.DEV_EDIT]]}
  },
  // add #11065 【03】編集権限バグ修正 関 end
  // mod #12462 患者情報共有 関 start
  // 患者共有
  PatientShare: {
    // デフォルト権限
    default_authority: {authority: [[AUTHORITY_CODES.PATIENT_SHARE]]}
  },
  // mod #12462 患者情報共有 関 end
};
// add #10359 編集権限の動作不正 end
