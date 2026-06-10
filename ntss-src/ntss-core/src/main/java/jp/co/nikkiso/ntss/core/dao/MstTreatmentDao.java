package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.OrdMain;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstTreatment;

/**
 * 治療方法マスタのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstTreatmentDao {

  //  add #7327-治療方法マスタ操作時の動作がおかしい 徐博 start
  @Select
  int getOrdMainByCd(String indTreatmentCd);
  //  add #7327-治療方法マスタ操作時の動作がおかしい 徐博 end

  /**
   * <code>params</code>に登録された施設コードに登録されている全治療方法マスタを取得する.
   * 取得時の並び順は{@link jp.co.nikkiso.ntss.core.entity.MstSelector}で登録されている順番とする.
   * ※<code>is_disp</code>:0(非表示)かつ、<code>is_del</code>:1(削除)は取得しない.
   *
   * @param options オプション
   * @param params 検索パラメータ
   *               ※施設コードのみ有効
   * @return {@link MstTreatment}のリスト
   */
  @Select
  List<MstTreatment> selectAll(SelectOptions options, MstTreatment params);

// FNSI-修正 マスタ削除の対応 chen add start
  /**
   * <code>params</code>に登録された施設コードに登録されている全治療方法マスタを取得する.
   * 取得時の並び順は{@link jp.co.nikkiso.ntss.core.entity.MstSelector}で登録されている順番とする.
   * ※<code>is_del</code>:1(削除)は取得.
   *
   * @param options オプション
   * @param params 検索パラメータ
   *               ※施設コードのみ有効
   * @return {@link MstTreatment}のリスト
   */
  @Select
  List<MstTreatment> selectAllDel(SelectOptions options, MstTreatment params);
// FNSI-修正 マスタ削除の対応 chen add end

  /**
   * <code>params</code>に登録された施設コードに登録されている全治療方法マスタを取得する.
   * 取得時の並び順は{@link jp.co.nikkiso.ntss.core.entity.MstSelector}で登録されている順番とする.
   * ※<code>is_disp</code>、<code>is_del</code>の値は考慮せず取得する.
   *
   * @param options オプション
   * @param params 検索パラメータ
   *               ※施設コードのみ有効
   * @return {@link MstTreatment}のリスト
   */
  @Select
  List<MstTreatment> selectAllIncludeDeleted(SelectOptions options, MstTreatment params);

  /**
   * <code>treatmentCd</code>に該当する治療方法マスタを取得する.
   * この関数では、<code>is_disp</code>:0(非表示)のレコードも取得される.
   * ※<code>is_del</code>:1(削除)のレコードは取得しない.
   *
   * @param treatmentCd 治療方法コード
   * @return 治療方法コードに該当する治療方法マスタ
   *         該当データがない場合には、<code>null</code>を返却する.
   */
  @Select
  MstTreatment selectByCd(Integer treatmentCd);

  // add 10150_9664 by kangjie 20240802 start
  @Select
  List<Integer> selectCdListByDeviceMode(List<Integer> deviceModeList, String facilityCd);
  @Select
  List<Integer> selectCdListByNotContainDeviceMode(List<Integer> deviceModeList, String facilityCd);
  // add 10150_9664 by kangjie 20240802 end

  //upd by ztc 2023-03-02 [Optimize runtime No.6968] --start /
  @Select
  List<MstTreatment> selectByCdListByTreatCd(List<String> treatmentCdList);
  //upd by ztc 2023-03-02 [Optimize runtime No.6968] --end /

  /**
   * <code>ordNo</code>に該当するオーダ情報の実績情報に格納されている治療方法マスタを取得する.
   * 該当データがない場合、<code>null</code>を返却する.
   * ※<code>is_disp</code>:0(非表示)かつ、<code>is_del</code>:1(削除)は取得しない.
   *
   * @param ordNo オーダ番号
   * @return オーダ番号に該当する治療方法マスタ
   *         該当データがない場合には、<code>null</code>を返却する.
   */
  @Select
  MstTreatment selectByOrdNo(Long ordNo);

  /**
   * <code>ordNo</code>に該当するオーダ情報の予定情報に格納されている治療方法マスタを取得する.
   * 該当データがない場合、<code>null</code>を返却する.
   * ※<code>is_disp</code>:0(非表示)かつ、<code>is_del</code>:1(削除)は取得しない.
   *
   * @param ordNo オーダ番号
   * @return オーダ番号に該当する治療方法マスタ
   *         該当データがない場合には、<code>null</code>を返却する.
   */
  @Select
  MstTreatment selectIndByOrdNo(Long ordNo);

  /**
   * 与えられたオーダ番号のリストの指示情報に該当する治療方法マスタのリストを取得する.
   * 該当データがない場合、空のリストを返却する.
   * ※<code>is_disp</code>:0(非表示)かつ、<code>is_del</code>:1(削除)は取得しない.
   *
   * @param ordNoList オーダ番号のリスト
   * @return オーダ番号リストの指示情報に登録されている治療方法マスタのリスト
   *         該当データがない場合には、空のリストを返却する.
   */
  @Select
  List<MstTreatment> selectByOrdNoList(List<Long> ordNoList);

  /* add by chamaojia 2026-03-24 [12462] 患者情報共有->患者経過総合ビューア --start */
  @Select
  List<MstTreatment> selectByOrdNoListToIndAndRst(List<Long> ordNoList);
  /* add by chamaojia 2026-03-24 [12462] 患者情報共有->患者経過総合ビューア --end */

  //add FNSI内容修正 外部Api調用 房 start
  @Select
  Integer getCheckIsHave(Long ordNo, String facilityCd);
  //add FNSI内容修正 外部Api調用 房 end

  //add 帳票コード取得修正 房 start
  @Select
  List<OrdMain> selectTreatingOrdno(Long patId, List<String> stateList);
  //add 帳票コード取得修正 房 end
// add FNSI-No196 透析前後の判断の最適化 関 start
  @Select
  List<MstTreatment> selectByFacilityCd(String facilityCd);
// add FNSI-No196 透析前後の判断の最適化 関 end

  @Select
  List<MstTreatment> selectByCdList(List<String> treatmentCdList,String facilityCd);

  // add by zhaoqj 2023-03-29 [#8495] 解決フライアウト早期クローズと一括クエリーの変更 --start /
  @Select
  List<Integer> getOrdMainByCds(List<Integer> indTreatmentCdList);
  // add by zhaoqj 2023-03-29 [#8495] 解決フライアウト早期クローズと一括クエリーの変更 --end /

  // add #8144 【デグレ】検査計算結果が検査後にしか反映されない 関 start
  @Select
  List<MstTreatment> selectDeviceModeByFacilityCd(String facilityCd);
  // add #8144 【デグレ】検査計算結果が検査後にしか反映されない 関 end

  // add 9326 ????患者の透析記録用紙が透析装置に表示されない　吉 start
  @Select
  MstTreatment selectMstTreaByFacilityCd(String facilityCd);
  // add 9326 ????患者の透析記録用紙が透析装置に表示されない　吉 end

  //add #9973 by ztc 20231027 mst_treatment変更後にmst _treatment_set start
  @Update(sqlFile = true)
  int updIndCondInfoByDisUse(String facilityCd, Integer treatmentCode, String indCondInfoDefault, String getDisUseCtlNoRst);
  //add #9973 by ztc 20231027 mst_treatment変更後にmst _treatment_set end

  // add 10150_9664 by kangjie 20240527 start
  @Update(sqlFile = true)
  int updIndCondInfoByDisUseAndDel(String facilityCd, Integer treatmentCode, String indCondInfoDefault, String getDisUseCtlNoRst);
  @Update(sqlFile = true)
  int updIndCondInfoByDisUseAndOne(String facilityCd, Integer treatmentCode, String indCondInfoDefault, String getDisUseCtlNoRst);
  @Update(sqlFile = true)
  int updIndCondInfoByDisUseAndTwo(String facilityCd, Integer treatmentCode, String indCondInfoDefault, String getDisUseCtlNoRst);
  @Update(sqlFile = true)
  int updIndCondInfoByDisUseAndThree(String facilityCd, Integer treatmentCode, String indCondInfoDefault, String getDisUseCtlNoRst);
  @Update(sqlFile = true)
  int updIndCondInfoByDisUseAndFour(String facilityCd, Integer treatmentCode, String indCondInfoDefault, String getDisUseCtlNoRst);
  // add 10150_9664 by kangjie 20240527 end

  // add #12589 どこかで使用している帳票も削除出来てしまう sunsy start
  /**
   * 治療帳票マスタに設定している帳票を取得
   * @param facilityCd
   * @return 帳票コード
   */
  @Select
  List<Integer> selectReportCdsByFacilityCd(String facilityCd);
  // add #12589 どこかで使用している帳票も削除出来てしまう sunsy end

}
