package jp.co.nikkiso.ntss.admin_web.service;

import jp.co.nikkiso.ntss.core.entity.SysMonitorItem;

import java.util.List;

/**
 * モニタ項目のServiceインターフェース
 */
public interface SysMonitorItemService {

  /**
   * 与えられたモニタデータ種別に該当する {@link SysMonitorItem} のリストを取得する.
   * 該当データがない場合、空のリストを返却する.
   *
   * @param moniDataType モニタデータ種別
   * @return 該当する {@link SysMonitorItem} のリスト
   */
  List<SysMonitorItem> getMonitorItemByMoniDataType(String moniDataType);

  /**
   * 与えられたモニタデータ種別及びバイタル・モニタ区分に該当する {@link SysMonitorItem} のリストを取得する.
   * 該当データがない場合、空のリストを返却する.
   *
   * @param moniDataType モニタデータ種別
   * @param vitalMonitorClass バイタル・モニタ区分
   * @return 該当する {@link SysMonitorItem} のリスト
   */
  List<SysMonitorItem> getMonitorItemByMoniDataTypeAndClass(String moniDataType, String vitalMonitorClass);


  /**
   * 変換項目が定義がされている {@link SysMonitorItem} のリストを取得する.
   * 該当データがない場合、空のリストを返却する.
   *
   * @return 該当する {@link SysMonitorItem} のリスト
   */
  List<SysMonitorItem> getMonitorItemByDefineConvItem();


  /* ===== 2024-07-04 ADD #9312 Start ===== */
  //del #12066 【横展開】酸素飽和度対応（コンバート） zrx start
//  List<SysMonitorItem> getMonitorItemByItemCodes(List<String> itemCodes);
  //del #12066 【横展開】酸素飽和度対応（コンバート） zrx end

  List<SysMonitorItem> getTreatmentGraphItems();
  /* ===== 2024-07-04 ADD #9312 End ===== */

  /**
   * 全ての{@link SysMonitorItem} を取得する.
   * 該当データがない場合、空のリストを返却する.
   *
   * @return {@link SysMonitorItem} のリスト
   */
  List<SysMonitorItem> getMonitorItemAll();
}
