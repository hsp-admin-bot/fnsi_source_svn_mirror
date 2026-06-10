package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.OrdMainDetailedConditions;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.PatUniqueDetailedConditions;
import jp.co.nikkiso.ntss.core.dto.patUnique.OrdMainForUpdTargetWeightDTO;
import jp.co.nikkiso.ntss.core.dto.patUnique.PatDWEffectsTimeLineDTO;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatUnique;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainTreatDate;
import jp.co.nikkiso.ntss.core.entity.custom.PatInOutUpdateInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatUniquePhysicalInfo;
import jp.co.nikkiso.ntss.core.entity.custom.dataFacilityCalendar.NumberOfPat;
import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import java.util.List;
import java.util.Map;


@ConfigAutowireable
@Dao
public interface PatUniqueDao {
  @Insert(sqlFile = true)
  int insert(PatUnique pat);

  /**
   * 患者IDリスト取得用
   * @param facilityCdList 抽出データ（処理対象施設の施設コードリスト）
   * @param patIdList 抽出データ（処理対象患者の患者IDリスト）
   * @return 抽出条件を満たした患者の患者IDリスト
   */
  @Select
  List<PatUnique> selectByIdList(List<Long> patIdList);

  // add 10389 患者リストのソートが遅い gjn start
  @Select
  List<PatUnique> selectByIdListToPatGroup(List<Long> patIdList);
  // add 10389 患者リストのソートが遅い gjn end

  @Select
  List<PatUnique> selectByIdListToTreatmentStatus(List<Long> patIdList);

  @Select
  PatUnique selectByPatId(Long patId);


  @Select
  List<PatUnique> selectPatInfoById(Long patId);

  @Select
  List<Map<String, Object>> selectInOut(List<String> facilityCdList, List<Long> patIdList);

  @Update(sqlFile = true)
  int updateById(long pat_id, PatUnique pat);
  /*add FNSI-改修内容転入転出の患者情報連動 任 start*/
  @Update(sqlFile = true)
  int updateUniqueById(long pat_id, PatUnique pat);
  /*add FNSI-改修内容転入転出の患者情報連動 任 end*/
  @Update(sqlFile = true)
  int updatePhysicalInfoById(long pat_id, PatUnique pat);

  /**
   * 詳細検索
   * @param conditions 検索条件
   * @param patIdList 患者IDリスト
   * @return 条件を満たした患者IDリスト
   */
  @Select
  List<Long> selectByDetailedSearchCondition(PatUniqueDetailedConditions conditions, List<Long> patIdList, List<String> facilityCdList);

  /**
   * 身体情報をexam_dateが新しいものから順にリスト化して返す
   * @param patId
   * @return
   */
  @Select
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
  // List<PatUniquePhysicalInfo> selectPhysicalInfoOfOrderNewest(Long patId);
  List<PatUniquePhysicalInfo> selectPhysicalInfoOfOrderNewest(Long patId, Integer patShareMode);
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */
  //add 8781 【デグレ】検査計算項目BMI，GNRIが計算しない 張 start
  /**
   * 現在の日付の最新データによると
   * @param patId
   * @param examDate
   * @return 身体情報
   */
  @Select
  List<PatUniquePhysicalInfo> selectPhysicalInfoByPatIdAndExamDate(Long patId,String examDate);
  //mod 8781 【デグレ】検査計算項目BMI，GNRIが計算しない 張 end

  // add #8737-検査結果更新不正 周 start
  @Select
  String selectLatestVisitHisBeforeTargetDate(String facilityCd, Long patId, String targetDate);
  // add #8737-検査結果更新不正 周 end

  /**
   * 指定日の入外・転入出情報を取得する
   * @param targetDt 検索対象日付
   * @param pat_id_list 対象患者ID
   * @return 入外・転入出情報のリスト
   */
  @Select
  List<PatInOutUpdateInfo> selectInOutUpdateInfo(String targetDt, List<Long> pat_id_list);

  @Update
  int update(PatUnique entity);

  @Update(excludeNull = true)
  int updatePatUnique(PatUnique entity);

  @Select
  PatUnique selectById(long patId);

  /* modify by chamaojia 2023-11-07 [9717] クエリー条件がコレクションに変わり、範囲クエリー  --start */
  /**
   * 転入または転出の数を選択
   * @param startDate 開始日
   * @param endDate 終了日
   * @param facilityCd  施設コード
   * @param moveInOutCdList 転入転出コードを移動する集合
   */
  @Select
  List<NumberOfPat> selectNumberOfInOrOut(String startDate, String endDate, String facilityCd, List<String> moveInOutCdList);
  /* modify by chamaojia 2023-11-07 [9717] クエリー条件がコレクションに変わり、範囲クエリー  --end */

  /**
   * 期間終了ごとに転入または転出の数を選択
   * @param startDate 開始日
   * @param endDate 終了日
   * @param facilityCd  施設コード
   * @param moveInOutCd 転入転出コードを移動する
   */
  @Select
  List<NumberOfPat> selectNumberOfInOrOutByPeriodEnd(String startDate, String endDate, String facilityCd, String moveInOutCd);

  /**
   * 転入または転出の数で患者IDを選択します
   * @param date 日付
   * @param facilityCd  施設コード
   * @param moveInOutCd 転入転出コードを移動する
   */
  @Select
  List<PatUnique> selectPatIdByInOrOut(String date, String facilityCd, String moveInOutCd);

  /**
   * 期間の終わりに転入または転出で患者IDを選択します
   * @param date 日付
   * @param facilityCd  施設コード
   * @param moveInOutCd 転入転出コードを移動する
   */
  @Select
  List<PatUnique> selectPatIdByInOrOutByPeriodEnd(String date, String facilityCd, String moveInOutCd);

  @Select
  int countMedicalAdditionTarget(Long patId, Integer diseaseCd);

// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou start
  @Select
  List<PatUnique> selectByIdListFacilityCd(List<Long> patIdList, String facilityCd);
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou end
  /**
   * 削除済み患者の削除フラグをDBに更新する
   * @param patId 患者ID
   */
  @Update(sqlFile = true)
  int updateIsDelById(Long patId);

  // mod 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
  // add 患者検索外結No7対応 趙 start
  @Select
  List<OrdMain> selectByDwSearchCondition(OrdMainDetailedConditions conditions, List<String> facilityCdList, List<Long> patIdList);
  // add 患者検索外結No7対応 趙 end
  // mod 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end

  // add FNSI-？？？？患者割り当て 陳 start
  /**
   * CTRに関する情報取得
   * @param patId 患者ID
   */
  @Select
  String selectCtrById(long patId);
  // add FNSI-？？？？患者割り当て 陳 end
  /*add FNSI-改修内容5872 任 start*/
  @Select
  List<NumberOfPat> selectNumberOfInOrOutForFacilityCd(String startDate, String endDate, String facilityCd, String moveInOutCd);
  /*add FNSI-改修内容5872 任 end*/

  /**
   * 導入日の取得
   * @param patId 患者ID
   */
  @Select
  String selectDialysisStartDateById(Long patId);

  // #10443 START
  /**  */
  @Select
  List<OrdMainForUpdTargetWeightDTO> selectOrdMainForUpdTargetWeight(String facilityCd, Long patId, String nowDateStr);

  /**  */
  @Select
  List<PatDWEffectsTimeLineDTO> selectDwEffectsTimeLine(Long patId);

  /**  */
  @Select
  List<OrdMainTreatDate> selectDwEffectsInterval(String facilityCd, Long patId, List<PatDWEffectsTimeLineDTO> dwEffects);
  // #10443 START
  // add 10443 身体情報・DW・目標体重バグ 関  start
  @Select
  List<PatUniquePhysicalInfo> selectDwByTreatDate(Long patId, String facilityCd, String treatDate);
  // add 10443 身体情報・DW・目標体重バグ 関  end
  //add #9507 一括指示受けに時間がかかる zrx start
  @Select
  PatUniquePhysicalInfo selectPhysicalInfoByTreatDate(Long patId, String facilityCd, String treatDate);
  //add #9507 一括指示受けに時間がかかる zrx end

  //add #12462 patidによるFacilityの取得 code  患者情報共有 zrx start
  @Select
  String selectFacilityCdById(Long patId);
  //add #12462 patidによるFacilityの取得 code  患者情報共有 zrx end
}
