package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.SysMonitorItem;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import java.util.List;

/**
 * モニタ項目のDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface SysMonitorItemDao {

  /**
   * 登録されているモニタ項目情報を全て取得する.
   * 未登録の場合は空のリストを返却する.
   *
   * @return {@link SysMonitorItem} のリスト
   */
  @Select
  List<SysMonitorItem> selectAll();

  /**
   * モニタデータ番号に該当する {@link SysMonitorItem} を取得する.
   * 該当データがない場合には、nulｌを返却する.
   *
   * @param moniDataNo モニタデータ番号
   * @return 該当する {@link SysMonitorItem}
   */
  @Select
  SysMonitorItem selectByMoniDataNo(String moniDataNo);

  /**
   * 与えられたモニタデータ種別に該当する {@link SysMonitorItem} のリストを取得する.
   * 該当データがない場合、空のリストを返却する.
   *
   * @param moniDataType モニタデータ種別
   * @return 該当する {@link SysMonitorItem} のリスト
   */
  @Select
  List<SysMonitorItem> selectByMoniDataType(String moniDataType);

  /**
   * 与えられたモニタデータ種別及びバイタル・モニタ区分に該当する {@link SysMonitorItem} のリストを取得する.
   * 該当データがない場合、空のリストを返却する.
   *
   * @param moniDataType モニタデータ種別
   * @param vitalMonitorClass バイタル・モニタ区分
   * @return 該当する {@link SysMonitorItem} のリスト
   */
  @Select
  List<SysMonitorItem> selectByMoniDataTypeAndClass(String moniDataType, String vitalMonitorClass);


  /**
   * 変換項目が定義がされている {@link SysMonitorItem} のリストを取得する.
   * 該当データがない場合、空のリストを返却する.
   *
   * @return 該当する {@link SysMonitorItem} のリスト
   */
  @Select
  List<SysMonitorItem> selectByDefineConvItem();

  /* ===== 2024-07-04 ADD #9312 ===== */
  //mod #12066 【横展開】酸素飽和度対応（コンバート） zrx start
//  @Select
//  List<SysMonitorItem> selectByMoniDataNoList(List<String> moniDataNos);
  @Select
  List<SysMonitorItem> selectByMoniDataNoList();
  //#12066 【横展開】酸素飽和度対応（コンバート） zrx end
  /* ===== 2024-07-04 ADD #9312 ===== */
}
