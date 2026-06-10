package jp.co.nikkiso.ntss.admin_web.constant;

import java.util.HashMap;
import java.util.Map;

//add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 start
public enum MstToMongoEnum {
  // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
  // 続柄マスタ
  MSTRELATIONSHIP("mst_relationship"),
  // 禁忌・アレルギーマスタ
  MSTTABOOALLERY("mst_taboo_allergy"),
  // 感染症マスタ
  MSTINFECTION("mst_infection"),
  // インプラントマスタ
  MSTIMPLANT("mst_implant"),
  // 重症度マスタ
  MSTSEVERITY("mst_severity"),
  // 搬送区分マスタ
  MSTTRANSPORT("mst_transport"),
  // 透析困難マスタ
  MSTDIALYSISDIFFCULTY("mst_dialysis_difficulty"),
  // 診療科マスタ
  MSTCOURSE("mst_course"),
  // 病棟マスタ
  MSTWARD("mst_ward"),
  // 患者メモマスタ
  MSTPATMEMO("mst_pat_memo"),
  // 病名マスタ
  MSTDISEASE("mst_disease"),
  // 加算・管理料マスタ
  MSTADDITION("mst_addition"),
  // 全施設マスタ
  SYSFACILITY("sys_facility"),
  // 利用者マスタ
  MSTUSER("mst_user"),
  // 施設マスタ
  MSTFACILITY("mst_facility");
  // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end


  public String strKey = null;

  MstToMongoEnum(String strKey) {
    this.strKey = strKey;
  }

  public String get() {
    return this.strKey;
  }

  private static final Map<String, MstToMongoEnum> NAME_MAP = new HashMap<>();

  static {
    for (MstToMongoEnum mstToMongoEnum : MstToMongoEnum.values()) {
      NAME_MAP.put(mstToMongoEnum.get(), mstToMongoEnum);
    }
  }

  public static MstToMongoEnum fromName(String name) {
    return NAME_MAP.get(name);
  }
}
//add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 end
