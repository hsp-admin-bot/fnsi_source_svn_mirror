package jp.co.nikkiso.ntss.coop_api.utils;

//　add #5607 連動機能の実装確認 20221205 孟堅　start
/**
 * 電文種別クラス.
 */
public class CoopCdConstant {
// del 2023-01-12 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  @Getter
//  public enum CoopIniMemo {
//    NKKNKK("日機装"),
//    F_HOSP("富士通GX");
//    private String result;
//
//    public boolean isSameResult(String target) {
//      return this.result.equals(target);
//    }
//
//    CoopIniMemo(String result) {
//      this.result = result;
//    }
//  }
// del 2023-01-12 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  // 送信
  public static final String IND_DIAL = "ind_dial";
  public static final String RST_DIAL = "rst_dial";
  public static final String KARTE_ORD = "karte_ord";
  public static final String VIT_COP = "vit_cop";
  public static final String REP_DIAL = "rep_dial";
  public static final String ACCEPT = "accept";
  public static final String EXAM_ORD = "exam_ord";
  public static final String RAD_ORD = "rad_ord";

  //add #10901 #10902 mst_coop_apilinkの動作について 20241004 zhaoqi start
  public static final String PHY_ORD = "phy_ord";
  //add #10901 #10902 mst_coop_apilinkの動作について 20241004 zhaoqi end

  public static final String PROFILE = "profile";
  // #8102-GX連携で実装されていない機能（処方情報連携） 周 add start
  public static final String PRE_ORD = "pre_ord";
  // #8102-GX連携で実装されていない機能（処方情報連携） 周 add end
  //　受信
  public static final String EXAM_RST = "exam_rst";
  public static final String STAFF_MST = "staff_mst";
  public static final String INI_DIAL = "ini_dial";
  public static final String ORD_DIAL = "ord_dial";
  public static final String CRUD_CREATE = "C";
  public static final String CRUD_DELETE = "D";
  public static final String CRUD_UPDATE = "U";

}
//　add #5607 連動機能の実装確認 20221205 孟堅　end
