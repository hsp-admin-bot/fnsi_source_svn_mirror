package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.MstExamItem;
import jp.co.nikkiso.ntss.core.entity.MstExamRecordItem;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvMstExamItem;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import java.util.List;


@ConfigAutowireable
@Dao
public interface MstExamItemDao {

  /**
   * 検査項目マスタ：対象施設の検査項目取得用
   * 施設コード：必須
   * @param facilityCd 施設コード
   * @return 対象施設の検査項目一覧
   */
  @Select
  List<MstExamItem> selectByFacilityCd(String facilityCd);

  /**
   * 検査項目マスタ：対象施設の検査項目取得用
   * 施設コード：必須
   * @param facilityCd 開示先施設
   * @return 対象施設の検査項目一覧
   */
  @Select
  List<MstExamItem> selectSharingByFacilityCd(String facilityCd);

  /**
   * 検査項目マスタ：検査項目取得:検査コード指定
   * 検査コード：必須
   * @param examItemCd 検査項目コード
   * @return 検査項目
   */
  @Select
  MstExamItem selectByExamItemCd(Long examItemCd);

  /**
   * 検査項目マスタ：対象施設内の指定したシステム標準計算項目コードに該当する検査項目取得用
   * @param facilityCd 施設コード
   * @param defaultCalcExamItemCd システム標準計算 計算項目コード
   * @return 該当する検査項目の検査項目一覧
   */
  @Select
  List<Long> selectExamItemListByDefaultCalcExamItemCd(String facilityCd, String defaultCalcExamItemCd);

  // add FNSI-No196 透析前後の判断の最適化 関 start
  @Select
  List<MstExamItem> selectExamItemListDetailByDefaultCalcExamItemCd(String facilityCd, String defaultCalcExamItemCd);
  // add FNSI-No196 透析前後の判断の最適化 関 end
  /**
   * 検査項目マスタ：対象施設内の指定したシステム標準計算項目コードに該当する検査項目取得用
   * @param facilityCd 施設コード
   * @return 該当する検査項目の検査項目一覧
   */
  @Select
  List<MstExamItem> selectExamItemListForExamCalc(String facilityCd);

  /**
   * 検査項目マスタ：対象施設内の指定したシステム標準計算IDが設定された検査項目一覧を取得する
   * @param facilityCd 施設コード
   * @param systemDefaultCalcFormulaId システム標準計算ID
   * @return 該当する検査項目の検査項目一覧
   */
  @Select
  List<MstExamItem> selectExamItemSystemDefaultCalc(String facilityCd, String systemDefaultCalcFormulaId);

  /**
   * 検査項目マスタ：対象施設内のユーザが登録した検査計算が設定された検査項目一覧を取得する
   * @param facilityCd 施設コード
   * @return 該当する検査項目の検査項目一覧
   */
  @Select
  List<MstExamItem> selectExamItemUserExamCalc(String facilityCd);

  // 9729-検査再計算ツール画面について 20231115仕様変更 zhoubin add start
  /**
   * 検査項目マスタ：対象施設内のユーザが登録した検査計算が設定された検査項目一覧を取得する
   * @param facilityCd 施設コード
   * @return 該当する検査項目の検査項目一覧
   */
  @Select
  List<MstExamItem> selectExamItemForRecalcByFacilityCd(String facilityCd);
  // 9729-検査再計算ツール画面について 20231115仕様変更 zhoubin add end

  /**
   * 検査項目マスタ：指定された検査コードの対象取得（検査使用区分指定）
   * 施設コード：必須
   * @param facilityCd 施設コード
   * @param examItemCd 検査項目コード(in句)
   * @param examClass 検査使用区分(in句)
   * @return 共通施設設定情報
   */
  @Select
  List<MstExamRecordItem> selectExamItemListForItemCd(String facilityCd, List<Long> examItemCd, List<String> examClass, String dispFlg);

  /**
   * 検査項目マスタ：指定された施設の有効な全検査項目
   * 施設コード：必須
   * @param facilityCd 施設コード
   * @param examClass 検査使用区分(in句)
   * @return 共通施設設定情報
   */
  @Select
  List<MstExamRecordItem> selectExamItemListForExamClass(String facilityCd, List<String> examClass, String dispFlg);


  /**
   * 通信サーバ用検査項目マスタを取得
   * @param facilityCd 施設コード
   * @return
   */
  @Select
  List<ComsvMstExamItem> selectByFacilityCdComSv(String facilityCd);

  /**
   * 体重計レシート設定用検査項目マスタ取得用
   * @param facilityCd 施設コード
   * @return 対象施設の検査項目一覧
   */
  @Select
  List<MstExamItem> selectByFacilityCdForWeight(String facilityCd);
//  add マスタ削除対応 張 start
  /**
   *
   * @param facilityCd
   * @return
   */
  @Select
  List<Long> selectExamItemListForFacilityCd(String facilityCd);
  //  add マスタ削除対応 張 end
  /*add FNSI-改修内容5237 任 start*/
  @Select
  List<MstExamItem> selectExamItemFigure(String facilityCd);
  /*add FNSI-改修内容5237 任 end*/

  /*add #6736 総タンパク、ヘマトクリットの検査結果が装置設定に反映されない gaoey start*/
  @Select
  // mod #6736 総タンパク、ヘマトクリットの検査結果が装置設定に反映されない 鄭爽 start
  // List<Long> selectExamItemHtByFacilityCd(String facilityCd);
  List<MstExamItem> selectExamItemHtByFacilityCd(String facilityCd);
  // mod #6736 総タンパク、ヘマトクリットの検査結果が装置設定に反映されない 鄭爽 end
  /*add #6736 総タンパク、ヘマトクリットの検査結果が装置設定に反映されない gaoey end*/

  /*add #6736 総タンパク、ヘマトクリットの検査結果が装置設定に反映されない gaoey start*/
  @Select
  // mod #6736 総タンパク、ヘマトクリットの検査結果が装置設定に反映されない 鄭爽 start
  // List<Long> selectExamItemTPByFacilityCd(String facilityCd);
  List<MstExamItem> selectExamItemTPByFacilityCd(String facilityCd);
  // mod #6736 総タンパク、ヘマトクリットの検査結果が装置設定に反映されない 鄭爽 end
  /*add #6736 総タンパク、ヘマトクリットの検査結果が装置設定に反映されない gaoey end*/
  // add #8144 【デグレ】検査計算結果が検査後にしか反映されない dou start
  @Select
  List<MstExamItem> selectByExamItemCdList(String facilityCd, List<Long> examItemCdList);

  //add 9737 TAC_BUNの計算が正しくない guan start
  @Select
  List<MstExamItem> selectByExamItemCdListToTacBun(String facilityCd, String examClass, String defaultCalcExamItemCd);
  //add 9737 TAC_BUNの計算が正しくない guan end

  @Select
  List<MstExamItem> selectByDefaultCalcExamItemCdListAndExamClass(String facilityCd, List<String> defaultCalcExamItemCd, String examClass);
  // add #8144 【デグレ】検査計算結果が検査後にしか反映されない dou end
}
