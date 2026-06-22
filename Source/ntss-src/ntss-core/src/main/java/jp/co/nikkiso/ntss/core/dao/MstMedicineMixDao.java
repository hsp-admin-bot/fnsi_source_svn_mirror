package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.MstMedicineMix;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import java.util.List;
import java.util.Map;


@ConfigAutowireable
@Dao
public interface MstMedicineMixDao extends MasterDao<Map<String,Object>>, UnifiedByCodeListDao {
  @Select
  List<MstMedicineMix> selectAll(SelectOptions options, MstMedicineMix params);
// FNSI-修正 マスタ削除の対応 chen add start
  @Select
  List<MstMedicineMix> selectAllDel(SelectOptions options, MstMedicineMix params);
  @Select
  MstMedicineMix selectByCdNoDel(String facilityCd, Integer medicineMixCd);
// FNSI-修正 マスタ削除の対応 chen add end

  // add FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 start
  @Select
  List<MstMedicineMix> selectMstMedicineMixAllergyData(SelectOptions options, MstMedicineMix params);
  // add FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 end

  /**
   * 指定した薬剤が含まれる調製薬剤リストを返却する
   * @param facilityCd
   * @param medicineCdList
   * @return
   */
  @Select
  // mod FNSI-改修内容6618修正 xuty start
  // List<MstMedicineMix> selectByMedicineCdList(String facilityCd, List<Integer> medicineCdList);
  List<MstMedicineMix> selectByMedicineCdList(String facilityCd, List<String> medicineCdList);
  // mod FNSI-改修内容6618修正 xuty end

  /**
   * 指定した調製薬剤コードの調製薬剤リストを返却する
   * @param facilityCd
   * @param medicineMixCdList(省略可能)
   * @return
   */
  @Select
  List<MstMedicineMix> selectByMedicineMixCdList(String facilityCd, List<Integer> medicineMixCdList);

  /**
   * 指定した調製薬剤コードの調製薬剤を返却する
   * @param facilityCd
   * @param medicineMixCd
   * @return
   */
  @Select
  MstMedicineMix selectByCd(String facilityCd, Integer medicineMixCd);


  //add #10196 Ord_Material_Save operation 20240126 ztc start
  /**
   * 指定した調製薬剤コードの調製薬剤を返却する
   * @param medicineMixCd
   * @return
   */
  @Select
  MstMedicineMix selectByMedicineMixCd(Integer medicineMixCd);
  //add #10196 Ord_Material_Save operation 20240126 ztc end


  /**
   * 指定した調製薬剤コードの調製薬剤を返却する
   * @param medicineMixCd
   * @return
   */
  @Select
  MstMedicineMix selectByMedicineMixIncludeDelByCd(Integer medicineMixCd);
  /**
   * 指定した調製薬剤コードの調製薬剤リストを返却する
   * @param medicineMixCdList
   * @return
   */
  @Select
  List<MstMedicineMix> selectByMedicineMixCdList2(List<Integer> medicineMixCdList);

  /**
   * selectByMedicineMixCdの一括版（施設指定、is_del='0'のみ）
   * @param facilityCd 施設コード
   * @param medicineMixCdList 調製薬剤コードリスト
   * @return 調製薬剤リスト
   */
  @Select
  List<MstMedicineMix> selectAllByMedicineMixCdList(String facilityCd, List<Integer> medicineMixCdList);

  /**
   * 削除済みを含むすべての調整薬剤リストを取得する
   * @param options 検索オプション
   * @param params 施設コードを指定するパラメータ
   * @return
   */
  @Select
  List<MstMedicineMix> selectAllIncludeDeleted(SelectOptions options, MstMedicineMix params);
  /*add FNSI-改修内容5204 任 start*/
  @Select
  List<MstMedicineMix> selectAllMstMedicineMixUnit(SelectOptions options, MstMedicineMix params);
  /*add FNSI-改修内容5204 任 end*/

  /*add FNSI-改修内容8315 ljx start*/
  @Select
  String selectIsDisp(int cd);
  /*add FNSI-改修内容8315 ljx end*/
  //add 10310 調整薬剤マスタから情報取得 gjn start
  @Select
  List<MstMedicineMix> selectAllByCdListCheckList(SelectOptions options, List<Integer> medicineMixCdList, String facilityCd);
  //add 10310 調整薬剤マスタから情報取得 gjn end

  /**
   * 指定した調製薬剤コード、施設コードの調製薬剤を返却する（削除済みを含む）
   * @param facilityCd
   * @param medicineMixCd
   * @return
   */
  @Select
  MstMedicineMix selectByCdWithDeletedRecord(String facilityCd, Integer medicineMixCd);

  @Override
  @Select
  List<Map<String,Object>> selectAllStatus(Map<String,String> params);

  /* add by chamaojia 2026-03-31 [12462] 患者情報共有->患者経過総合ビューア --start */
  @Select
  List<MstMedicineMix> selectByOrdNoList(List<Long> ordNoList);
  /* add by chamaojia 2026-03-31 [12462] 患者情報共有->患者経過総合ビューア --end */

  @Override
  @Select
  List<Map<String, Object>> selectAllStatusByCodeList(List<Integer> codeList);
}
