package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.MstReport;
import jp.co.nikkiso.ntss.core.entity.MstMachineReportList;
import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import java.util.List;

/**
 * 帳票マスタのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstReportDao {

  @Select
  List<MstReport> selectAll(final String facilityCd);
  //add 6502 6498 5984 定期・日常が分離されていない 吉 start
  @Select
  List<MstReport> selectByFlag(final String facilityCd,String vorcFlag);
  //add 6502 6498 5984 定期・日常が分離されていない 吉 end
  // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
  @Select
  List<MstReport> selectAllForFixedAndNormal(final String facilityCd, List<String> facilitySettingNos, String is_disp, String is_del);
  @Select
  MstReport selectForFixed(final String facilityCd, String facilitySettingNo, String is_disp, String is_del);
  // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end

  // mod 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 start
  //@Insert(include = {"facilityCd", "reportName", "reportPath", "reportClass", "isDisp", "regDate", "upDate"})
  // mod FNSI-699,700,751 装置帳票の記録簿対応 夏 start
  //@Insert(include = {"facilityCd", "reportName", "reportPath", "reportClass", "isDisp", "regDate", "upDate", "reportHstInfo"})
  // mod 2021-04-22 bug #4373：ラベル開始位置が選択できないのバグを対応 趙 start
  //@Insert(include = {"facilityCd", "reportName", "reportPath", "reportClass", "isDisp", "regDate", "upDate", "reportHstInfo", "reportType", "extractionCondition"})
  // mod #7880 帳票：ラベルが正しく表示されない 姜 start
  // @Insert(include = {"facilityCd", "reportName", "reportPath", "reportClass", "isDisp", "regDate", "upDate", "reportHstInfo", "reportType", "extractionCondition", "additionalInfo","multiTotalDefaul"})
  // mod 8559 動作に関する指摘２　NG4　吉 start
  // @Insert(include = {"facilityCd", "reportName", "reportPath", "reportClass", "isDisp", "regDate", "upDate", "reportHstInfo", "reportType", "extractionCondition", "additionalInfo", "multiTotalDefaul", "reportSetting"})
  // mod #10983 mst_report の未使用カラム「multi_total_defaul」を廃止 sunsy start
//  @Insert(include = {"reportCd","facilityCd", "reportName", "reportPath", "reportClass", "isDisp", "regDate", "upDate", "reportHstInfo", "reportType", "extractionCondition", "defaultPrinter", "additionalInfo", "multiTotalDefaul", "reportSetting"})
  @Insert(include = {"reportCd","facilityCd", "reportName", "reportPath", "reportClass", "isDisp", "regDate", "upDate", "reportHstInfo", "reportType", "extractionCondition", "defaultPrinter", "additionalInfo", "reportSetting"})
  // mod #10983 mst_report の未使用カラム「multi_total_defaul」を廃止 sunsy end
  // mod 8559 動作に関する指摘２　NG4　吉 end
  // add #7880 帳票：ラベルが正しく表示されない 姜 end
  // mod 2021-04-22 bug #4373：ラベル開始位置が選択できないのバグを対応 趙 end
  // mod FNSI-699,700,751 装置帳票の記録簿対応 夏 end
  // mod 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 end
  int insert(MstReport rec);
  // add 8559 動作に関する指摘２　NG4　吉 start
  @Select
  int selectMaxReport();
  // add 8559 動作に関する指摘２　NG4　吉 end
  // add 7233 デフォルト帳票について 吉 start
  @Insert(sqlFile = true)
  // mod #7922 新規施設のデフォルト帳票に作成者・更新者が登録されている / デフォルト帳票が編集できない 修正 商 start
  // int bunchinsert(String facilityCd);
  // mod #7922 新規施設のデフォルト帳票に作成者・更新者が登録されている / デフォルト帳票が編集できない 再修正 商 start
  // int bunchinsert(String facilityCd, MstReport mstReport);
  int bunchinsert(String facilityCd);
  // mod #7922 新規施設のデフォルト帳票に作成者・更新者が登録されている / デフォルト帳票が編集できない 再修正 商 end
  // mod #7922 新規施設のデフォルト帳票に作成者・更新者が登録されている / デフォルト帳票が編集できない 修正 商 end
  // add 7233 デフォルト帳票について 吉 end

  @Delete
  int delete(MstReport rec);

  @Update
  int update(MstReport rec);

  /**
   * report_nameを更新する.
   * @param rec 帳票データ
   * @return
   */
  @Update(sqlFile = true)
  int updateReportName(MstReport rec);

  /**
   * 3ファイルのフルパスを更新する.
   * @param rec 帳票データ
   * @return
   */
  @Update(sqlFile = true)
  int updateReportPath(MstReport rec);

  //add 7233 デフォルト帳票について 関 start
  /**
   * 批量修改ReportPathBucket
   *
   * @param bucket
   * @return
   */
  @Update(sqlFile = true)
  int updateReportPathBucket(String facilityCd, String bucket);
  // add デフォルト帳票について 7233 関 end
  /**
   * is_dispを更新する.
   * @param rec 帳票データ
   * @return
   */
  @Update(sqlFile = true)
  int updateIsDisp(MstReport rec);

  /**
   * 帳票マスタ取得.
   *
   * @param reportCd  帳票番号
   * @return 帳票マスタエンティティ
   */
  @Select(ensureResult = true)
  MstReport selectByCd(Long reportCd);

  /**
   * 帳票マスタ取得.
   *
   * @param reportCd  帳票番号
   * @return 帳票マスタエンティティ
   */
  @Select
  MstReport selectReportByReportCd(Long reportCd);

  // add #11501 レイアウトデザイナのユーザビリティ改善 limingzhe start
  /**
   * 帳票マスタ取得.
   *
   * @param reportCd  帳票番号
   * @return 帳票マスタエンティティ
   */
  @Select
  MstReport selectByReportCdIsNotDel(Long reportCd);
  // add #11501 レイアウトデザイナのユーザビリティ改善 limingzhe end

  /**
   * 帳票マスタ取得.
   *
   * @param reportCd レポートCD
   * @return レポートマスタ エンティティ
   */
  @Select(ensureResult = true)
  MstReport selectByReportCd(Long reportCd);

  /**
   * 帳票マスタ取得.
   *
   * @param reportClass 帳票種別
   * @param reportType 帳票区分
   * @param facilityCd 施設コード
   * @return 帳票マスタエンティティのリスト
   */
  // mod 7347 【デグレ】削除されていない帳票が帳票画面のリストに表示されない 吉 start
  //  @Select(ensureResult = true)
  @Select
  // mod 7347 【デグレ】削除されていない帳票が帳票画面のリストに表示されない 吉 end
  List<MstReport> selectReports(Integer reportClass, Integer reportType, String facilityCd);

  // add #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy start
  /**
   * 帳票マスタ取得.
   *
   * @param reportClass 帳票種別
   * @param reportType 帳票区分
   * @param facilityCd 施設コード
   * @return 帳票マスタエンティティのリスト
   */
  @Select
  List<MstReport> selectReportsNoIsDisp(Integer reportClass, Integer reportType, String facilityCd);
  // add #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy end

  /**
   * 帳票名, 表示非表示フラグ, 削除フラグを更新する.
   * @param rec 帳票データ
   * @return
   */
  @Update(sqlFile = true)
  int updateListData(MstReport rec);

  /**
   * 削除フラグを1に更新する.
   * @param rec 帳票データ
   * @return
   */
  @Update(sqlFile = true)
  int updateIsDel(MstReport rec);

  /*add FNSI-改修内容装置帳票の対応 任 start*/
  @Select
  Long selectPrintCd(Long reportCd);
  /*add FNSI-改修内容装置帳票の対応 任 end*/
  // add #7880 帳票：ラベルが正しく表示されない 姜 start
  @Select
  int selectMstMedicineCount(String facilityCd);

  @Select
  int selectMstMedicineClassCount(String facilityCd);

  @Select
  int selectMstEquipmentCount(String facilityCd);

  @Select
  int selectMstEquipmentClassCount(String facilityCd);
  // add #7880 帳票：ラベルが正しく表示されない 姜 end

  // add #7922 新規施設のデフォルト帳票に作成者・更新者が登録されている / デフォルト帳票が編集できない 修正 商 start
  /**
   * 帳票マスタ取得.
   *
   * @return 帳票マスタエンティティ
   */
  @Select(ensureResult = true)
  List<MstReport> selectNkkInfo();
  // add #7922 新規施設のデフォルト帳票に作成者・更新者が登録されている / デフォルト帳票が編集できない 修正 商 end

  // add #11257 機能帳票の出力に帳票保存のソート条件を適用する 高 start
  @Select
  MstReport selectReportSettingByReportCd(String facilityCd,Long reportCd);
  // add #11257 機能帳票の出力に帳票保存のソート条件を適用する 高 end

  // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
  @Select
  List<MstMachineReportList> selectReportCdandMachineNoListByMachineTypeCd(String mainteClass, String facilityCd, List<Long> machineNos);
  // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
  // add #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao start
  /**
   * 帳票マスタ取得.
   *
   * @param reportClass 帳票種別
   * @param reportType 帳票区分
   * @param facilityCd 施設コード
   * @return 帳票マスタエンティティのリスト
   */
  @Select
  List<MstReport> selectReportsNoIsDel(Integer reportClass, Integer reportType, String facilityCd);
  // add #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao end
}
