package jp.co.nikkiso.ntss.core.dao;

import java.sql.Timestamp;
import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.core.entity.EntityDao;
import jp.co.nikkiso.ntss.core.entity.custom.CusMachineInfoPeriodic;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatExamMain;

/**
 *
 * 帳票出力するDAOインタフェース
 *
 */

@ConfigAutowireable
@Dao
public interface ReportMenuDao {

	/**
	 * 指定された日で治療情報の検索
	 *
	 * @param patId
	 * @param facilityCd
	 * @param regOrderClassList
	 * @param specifyDate
	 * @return
	 */
	@Select
	List<Long> selectByDate(Long patId, String facilityCd, List<String> regOrderClassList, String specifyDate);

	/**
	 * 治療日がFROM/TO形で治療情報の検索
	 *
	 * @param patId
	 * @param facilityCd
	 * @param regOrderClassList
	 * @param fromDate
	 * @param toDate
	 * @return
	 */
	@Select
	List<Long> selectByDateFromTo(Long patId, String facilityCd, List<String> regOrderClassList, String fromDate,
			String toDate);

	/**
	 * ベッド順のソート
	 *
	 * @param patId
	 * @param sortValue
	 * @param facilityCd
	 * @return
	 */
  /*mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 start*/
  /*@Select
  List<Long> selectSortByBed(List<Long> patId, String sortValue, String facilityCd);*/
	@Select
	List<EntityDao> selectSortByBed(List<Long> patId, String sortValue, String facilityCd);
  /*mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 end*/

	/**
	 * クール順のソート
	 *
	 * @param patId
	 * @param sortValue
	 * @param facilityCd
	 * @return
	 */
  /*mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 start*/
  /*@Select
  List<Long> selectSortByCool(List<Long> patId, String sortValue, String facilityCd);*/
	@Select
	List<EntityDao> selectSortByCool(List<Long> patId, String sortValue, String facilityCd);
  /*mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 end*/

	/**
	 * 患者グループ名順のソート
	 *
	 * @param patId
	 * @param sortValue
	 * @return
	 */
  /*mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 start*/
  /*@Select
  List<Long> selectSortByGroupName(List<Long> patId, String sortValue);*/
	@Select
	List<EntityDao> selectSortByGroupName(List<Long> patId, String sortValue);
  /*mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 end*/

	/**
	 * ベッドグループ名のソート
	 *
	 * @param patId
	 * @param sortValue
	 * @return
	 */
  /*mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 start*/
  /*@Select
  List<Long> selectSortByBedGroupName(List<Long> patId, String sortValue, String facilityCd);*/
	@Select
	List<EntityDao> selectSortByBedGroupName(List<Long> patId, String sortValue, String facilityCd);
  /*mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 end*/

	/**
	 * ベッド名順のソート
	 *
	 * @param patId
	 * @param sortValue
	 * @param facilityCd
	 * @return
	 */
  /*mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 start*/
  /*@Select
  List<Long> selectSortByBedName(List<Long> patId, String sortValue, String facilityCd);*/
	@Select
	List<EntityDao> selectSortByBedName(List<Long> patId, String sortValue, String facilityCd);
  /*mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 end*/

	/**
	 * 区分順のソート
	 *
	 * @param patId
	 * @param sortValue
	 * @param facilityCd
	 * @return
	 */
  /*mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 start*/
  /*@Select
  List<Long> selectSortByInOutClass(List<Long> patId, String sortValue, String facilityCd);*/
	@Select
	List<EntityDao> selectSortByInOutClass(List<Long> patId, String sortValue, String facilityCd);
  /*mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 end*/

	/**
	 * 感染状況順のソート
	 *
	 * @param patId
	 * @param sortValue
	 * @param facilityCd
	 * @return
	 */
  /*mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 start*/
  /*@Select
  List<Long> selectSortByInfect(List<Long> patId, String sortValue, String facilityCd);*/
	@Select
	List<EntityDao> selectSortByInfect(List<Long> patId, String sortValue, String facilityCd);
  /*mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 end*/

	/**
	 * 医療材料/薬剤CD順のソート
	 *
	 * @param patId
	 * @param sortValue
	 * @param facilityCd
	 * @return
	 */
  /*mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 start*/
  /*@Select
  List<Long> selectSortByEquipMedicineCode(List<Long> patId, String sortValue, String facilityCd);*/
	@Select
	List<EntityDao> selectSortByEquipMedicineCode(List<Long> patId, String sortValue, String facilityCd);
  /*mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 end*/

	/**
	 * 医療材料/薬剤分類順のソート
	 *
	 * @param patId
	 * @param sortValue
	 * @param facilityCd
	 * @return
	 */
  /*mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 start*/
  /*@Select
  List<Long> selectSortByEquipMedicineClass(List<Long> patId, String sortValue, String facilityCd);*/
	@Select
	List<EntityDao> selectSortByEquipMedicineClass(List<Long> patId, String sortValue, String facilityCd);
  /*mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 end*/

	/**
	 * 医療材料/薬剤順のソート
	 *
	 * @param patId
	 * @param sortValue
	 * @param facilityCd
	 * @return
	 */
  /*mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 start*/
  /*@Select
  List<Long> selectSortByEquipmentMedicine(List<Long> patId, String sortValue, String facilityCd);*/
	@Select
	List<EntityDao> selectSortByEquipmentMedicine(List<Long> patId, String sortValue, String facilityCd);
  /*mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 end*/

  /**
   * 治療日をターゲットとして、治療情報を取得する。
   * @param patId 患id
   * @param specifyDate 治療日（範囲指定の場合はnull）
   * @param fromDate 治療日範囲の開始
   * @param toDate 治療日範囲の終了
   * @return
   */
  @Select
  List<OrdMain> selectByTreatDate(Long patId, String specifyDate, String fromDate, String toDate);

  /**
   * 治療日をターゲットとして、治療情報を取得する。
   * @param patIds 複数患者id
   * @param specifyDate 治療日（範囲指定の場合はnull）
   * @param fromDate 治療日範囲の開始
   * @param toDate 治療日範囲の終了
   * @return
   */
  @Select
  List<OrdMain> selectByTreatDateAndPatIds(List<Long> patIds, String specifyDate, String fromDate, String toDate);

  // add 10546 複数集計出力時にサーバが高負荷になる gjn start
  /**
   * 治療日をターゲットとして、治療情報を取得する,高性能バージョン
   * @param patIds 複数患者id
   * @param specifyDate 治療日（範囲指定の場合はnull）
   * @param fromDate 治療日範囲の開始
   * @param toDate 治療日範囲の終了
   * @return
   */
  @Select
  List<OrdMain> selectByTreatDateAndPatIdsfacilityCd(List<Long> patIds, String facilityCd, String specifyDate, String fromDate, String toDate);
  // add 10546 複数集計出力時にサーバが高負荷になる gjn end

  /**
   * 指定範囲内の検査指示 + 検査結果を取得
   * @param patId 患者ID
   * @param fromDate 検索開始点
   * @param toDate 検索終了点
   * @return
   */
  @Select
  List<PatExamMain> selectExamByDate(Long patId, Timestamp fromDate, Timestamp toDate, List<String> regOrderClassList);

  /**
   * 指定日からの直近1件の治療予定を取得
   * @param patId 患者ID
   * @param treatDate 検索指定日
   * @return
   */
  @Select
  OrdMain selectNearOrdPlan(Long patId, String treatDate);

  /**
   * 治療日をターゲットとして、確定治療実績を取得する。
   * @param patId 患者ID
   * @param specifyDate 治療日（範囲指定の場合はnull）
   * @param fromDate 治療日範囲の開始
   * @param toDate 治療日範囲の終了
   * @return
   */
  @Select
  List<OrdMain> selectResultByTreatDate(Long patId, String specifyDate, String fromDate, String toDate);

  @Select
  List<OrdMain> selectResultByTreatDateAndPatIds(List<Long> patIds, String specifyDate, String fromDate, String toDate);

  /*add 2020-12-09 FNSI-添加内容 各帳票の並び順調整。 吉 start*/

  @Select
  List<EntityDao> selectSortByDialysisDay(List<Long> patId, String sortValue, String facilityCd);

  @Select
  List<EntityDao> selectSortByDialysisRoomGroup(List<Long> patId, String sortValue, String facilityCd,String groupClass);

//  @Select
//  List<EntityDao> selectSortByRoomBedGroup(List<Long> patId, String sortValue, String facilityCd);

  /*add 2020-12-09 FNSI-添加内容 各帳票の並び順調整。 吉 end*/

  @Select
  List<Long> selectByMedicinePatIds(List<Integer> medicineCdList, List<Long> patIds);

  @Select
  List<Long> selectByReportInfo(Long reportCd,  String facilityCd, List<Long> patIds,String fromDate,
                                String toDate);
  //add 4748 5269 5402治療方法ごとの治療経過表での出力ができない  吉 end
  @Select
  List<Long> selectByDialysisState(String facilityCd, List<Long> patIds,
                                   String fromDate, String toDate, String rstDialysisStateFlag);
  @Select
  List<Long> selectByExamStatus(String facilityCd, List<Long> patIds,
                                String examFromDate, String examToDate, String examStatusFlag);

// add #11226 患者情報系historyの取得条件見直し② limingzhe start
  @Select
  // mod #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 start
//  List<Long> selectByIssueStatus(String facilityCd, List<Long> patIds,
//                                 String issueFromDate, String issueToDate, String issueStatusFlag);
  List<Long> selectByIssueStatus(String facilityCd, List<Long> patIds,
                                String issueFromDate, String issueToDate, String issueStatusFlag, List<String> prescriptionClassList);
  // mod #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 end
// add #11226 患者情報系historyの取得条件見直し② limingzhe end

  @Select
  List<Long> selectByDialysisStateAndExam(String facilityCd, List<Long> patIds,
                                          String fromDate, String toDate, String rstDialysisStateFlag,
                                          String examFromDate, String examToDate, String examStatusFlag);
  
  @Select
  List<Long> selectByLetterIssueDate(String facilityCd, List<Long> patIds,
                                     String fromDate, String toDate, String rstDialysisStateFlag, List<String> letterCategoryList);
  
  //add 5565 並び替えを実施してもその情報が保持されない 吉 start
  @Update(sqlFile = true)
  int updateSortList(Long reportCd, String sortList);
  //add 5565 並び替えを実施してもその情報が保持されない 吉 end

  // add #5562 並び替えを行っても帳票画面のリストに反映されない 歴 start
  /**
   * 装置帳票でソート
   *
   * @param machineNo
   * @param sortId
   * @param sortValue
   * @param facilityCd
   * @return
   */
  @Select
  List<Long> selectSortByMachineInfo(List<Long> machineNo, String sortId, String sortValue, String facilityCd);
  // add #5562 並び替えを行っても帳票画面のリストに反映されない 歴 end
  //add 6502 定期・日常が分離されていない 吉 start
  @Select
  List<CusMachineInfoPeriodic> selectAllByMachineInfo(List<Long> machineNo, String sortId, String sortValue, String facilityCd);
  //add 6502  定期・日常が分離されていない 吉 end

  // add #11257 機能帳票の出力に帳票保存のソート条件を適用する 高 start
  @Select
  List<OrdMain> selectByTreatDateAndPatIdsAndRst(List<Long> ordNos, String facilityCd);
  // add #11257 機能帳票の出力に帳票保存のソート条件を適用する 高 end

  // add #10988 データ項目「処方.処方箋情報.QRコード」を追加　V1.1A 吉 start
  @Select
  List<Map<String,Object>> selectPrescriptionByDateKey(String facilityCd, String ordPrescriptionNo);

  @Select
  List<Map<String,Object>> selectPrescriptionIssueNameByDateKey(String facilityCd, String ordPrescriptionNo);

  @Select
  List<Map<String,Object>> selectPrescriptionCommontByDateKey(String facilityCd, String ordPrescriptionNo);
  // add #10988 データ項目「処方.処方箋情報.QRコード」を追加　V1.1A 吉 end

  // add #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe start
  @Select
  List<Map<String, Object>> selectByPatIdsAndData(List<Long> patIds, String facilityCd, List<String> regOrderClassList, String specifyDate, String fromDate, String toDate);
  // add #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe end
}
