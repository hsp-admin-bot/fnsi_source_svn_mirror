package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.MstAddMonitor;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import java.util.List;

/**
 * バイタル・モニタ追加項目マスタのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstAddMonitorDao {

  /**
   * 指定された施設コードに該当する{@link MstAddMonitor}を取得.
   *
   * @param facilityCd 施設コード
   * @return {@link MstAddMonitor}のリスト
   */
  @Select
  List<MstAddMonitor> selectAllByFacilityCd(String facilityCd);

  /**
   * 指定されたバイタル・モニタ項目コードに該当する{@link MstAddMonitor}を取得.
   *
   * @param vitalMonitorItemCd バイタル・モニタ項目コード
   * @return バイタル・モニタ項目コードに該当する {@link MstAddMonitor}
   */
  @Select
  MstAddMonitor selectByCd(Long vitalMonitorItemCd);

  /**
   * 指定された施設コード及びバイタル・モニタ区分に該当する{@link MstAddMonitor}のリストを取得.
   * ※非表示フラグ及び削除フラグに関わらず取得.
   *
   * @param facilityCd 施設コード
   * @param vitalMonitorClass バイタル・モニタ区分（1:バイタル、2:モニタ）
   * @return 条件に該当する {@link MstAddMonitor} のリスト
   */
  @Select
  List<MstAddMonitor> selectByVitalMonitorClass(String facilityCd, String vitalMonitorClass);

  // add #8391 バイタル・モニタ項目追加マスタで追加した項目をトレンドグラフモニタ，帳票グラフに追加しても透析記録用紙に表示されない 姜 start
  @Select
  // mod #8391 バイタル・モニタ項目追加マスタで追加した項目をトレンドグラフモニタ，帳票グラフに追加しても透析記録用紙に表示されない 姜 start
  // MstAddMonitor selectByMonitorItemName(String facilityCd, Integer vitalMonitorItemCd);
  MstAddMonitor selectByMonitorItemName(String facilityCd, String vitalMonitorItemName);
  // mod #8391 バイタル・モニタ項目追加マスタで追加した項目をトレンドグラフモニタ，帳票グラフに追加しても透析記録用紙に表示されない 姜 end
  // add #8391 バイタル・モニタ項目追加マスタで追加した項目をトレンドグラフモニタ，帳票グラフに追加しても透析記録用紙に表示されない 姜 end
  // add #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou start
  /**
   * 指定された施設コードに該当する{@link MstAddMonitor}を取得.
   *
   * @param facilityCd 施設コード
   * @return {@link MstAddMonitor}のリスト
   */
  @Select
  List<MstAddMonitor> selectByFacilityCd(String facilityCd);
  // add #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou end
}
