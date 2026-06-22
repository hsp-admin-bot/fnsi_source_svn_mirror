package jp.co.nikkiso.ntss.coop_api.utils;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
// mod #7047 GX連携用sys_coop_noでcoop_ord_cdが重複するデータが存在する 2022-12-09 孟堅 start
public class ReceiveCoopOrdNoConstants {

  public static final String ID_FACILITY_CD = "@facilityCd";
  public static final String ID_PAT_ID = "@patId";
  public static final String ID_USER_ID = "@userId";
  public static final String ID_ORD_NO = "@ordNo";
  public static final String ID_HOSP_PAT_ID = "@hospPatId";
  public static final String ID_CRUD = "@crud";
  public static final String ID_TREAT_DATE = "@treatDate";

  public static final String GX_INIDIAL_COOP_NO="$journal.pat_coop_detail.save_2.ord_no";
// add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  public static final String ID_KEY0 = "@key0";
  public static final String ID_COOP_VERSION = "@coopVersion";
// add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

  /* del by chamaojia 2026-05-06 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  // public Map<String, Object> paraMap = new HashMap<>();
  // public Map<String, Object> resultJsonMap = new LinkedHashMap<>();
  /* del by chamaojia 2026-05-06 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
  // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 20231027  孟堅 start
  public static  final String EXAMMAINCD = "@examMainCd";
  // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 20231027  孟堅 end
}
// mod #7047 GX連携用sys_coop_noでcoop_ord_cdが重複するデータが存在する 2022-12-09 孟堅 end
