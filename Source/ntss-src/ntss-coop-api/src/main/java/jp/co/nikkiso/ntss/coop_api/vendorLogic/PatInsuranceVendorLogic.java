package jp.co.nikkiso.ntss.coop_api.vendorLogic;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.core.entity.custom.PatInsuInfo;

/**
 * 保険情報のベンダー別処理を規定するインタフェース。
 */
public interface PatInsuranceVendorLogic {

  /**
   * insu_class定数（保険）
   */
  int INSU_CLASS_INSU = 0;

  /**
   * insu_class定数（公費）
   */
  int INSU_CLASS_KOHI = 1;

  /**
   * insu_class定数（セット情報）
   */
  int INSU_CLASS_SET = 2;

  /**
   * 保険情報をチェック・編集する。
   *
   * @param facilityCd 施設コード
   * @param patId 患者ID
   * @param paramMap 電文から抽出した項目のマップ
   * @param patInsuInfo 既存の保険情報
   */
  void check(String facilityCd, Long patId, Map<String, Object> paramMap, PatInsuInfo patInsuInfo);

  /**
   * 保険情報をDBに登録する。
   *
   * @param facilityCd 施設コード
   * @param patId 患者ID
   * @param insNo 保険番号
   * @param insuInfoList 保険情報のリスト
   */
  void register(String facilityCd, Long patId, String insNo, List<PatInsuInfo> insuInfoList);
}
