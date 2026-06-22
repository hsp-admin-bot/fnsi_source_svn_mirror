package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.ForecastInforResult;
//add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 start
import jp.co.nikkiso.ntss.core.entity.ForecastInforResultForPatEventCount;
//add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 end
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.IndicationResult;

/**
 * 予実リストのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
  public interface IndicationResultDao {

  /**
   * 予実リスト取得.
   *
   * @param patId 患者ID
   * @param treatDateFrom 治療日(From)
   * @param treatDateTo 治療日(To)
   * @return 予実リストエンティティのリスト
   */
  @Select
  List<IndicationResult> selectByPatIdAndTreatDate(Long patId, String treatDateFrom, String treatDateTo, String facilityCd);

  // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
  /**
   * 予実リスト取得(患者イベント).
   *
   * @param patId 患者ID
   * @param treatDateFrom 治療日(From)
   * @param treatDateTo 治療日(To)
   * @return 予実リストエンティティのリスト
   */
  @Select
  List<ForecastInforResult> selectPatientEventResultList(String treatDateFrom, String treatDateTo, Long patId, String facilityCd);

  /**
   * チェック項目数取得
   *
   * @param examSetCdValue 検査セットID
   * @return チェック項目のJSON情報
   */
  @Select
  List<ForecastInforResult> selectCheckNum(String examSetCdValue);

  /**
   * チェック項目数一括取得
   *
   * @param examSetCdList 検査セットIDリスト
   * @return チェック項目のJSON情報
   */
  @Select
  List<ForecastInforResult> selectCheckNumByExamSetCdList(String facilityCd, List<String> examSetCdList);

  /**
   * 予実リスト取得(検査結果).
   *
   * @param patId 患者ID
   * @param treatDateFrom 治療日(From)
   * @param treatDateTo 治療日(To)
   * @return 予実リストエンティティのリスト
   */
  @Select
  List<ForecastInforResult> selectInspectionResultList(String treatDateFrom, String treatDateTo, Long patId, String facilityCd);

  /**
   * 予実リスト取得(一般撮影検査予定).
   *
   * @param patId 患者ID
   * @param treatDateFrom 治療日(From)
   * @param treatDateTo 治療日(To)
   * @return 予実リストエンティティのリスト
   */
  @Select
  List<ForecastInforResult> selectGenPhotoInsResultList(String treatDateFrom, String treatDateTo, Long patId, String facilityCd);

  /**
   * 予実リスト取得(処方).
   *
   * @param patId 患者ID
   * @param treatDateFrom 治療日(From)
   * @param treatDateTo 治療日(To)
   * @return 予実リストエンティティのリスト
   */
  @Select
  List<ForecastInforResult> selectPrescriptionResultList(String treatDateFrom, String treatDateTo, Long patId, String facilityCd);
  // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end

  // add FNSI-改修内容 治療単位の治療方法マスタの有効項目に応じた表示 dou start
  @Select
  List<String> selectTreatmentConditionSetting(String facilityCd,String treatmentName);
  // add FNSI-改修内容 治療単位の治療方法マスタの有効項目に応じた表示 dou end
//add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 start
  /**
   * 予実リスト取得(一般撮影検査予定).
   *
   * @param patId 患者ID
   * @param treatDateFrom 治療日(From)
   * @param treatDateTo 治療日(To)
   * @return 予実リストエンティティのリスト
   */
  @Select
  List<ForecastInforResult> selectGenPhotoInsResultByPatIdAndFacilityCode(String treatDateFrom, String treatDateTo, Long patId, String facilityCd);

  /**
   * カテゴリリスト取得(患者イベント).
   *
   * @param patId 患者ID
   * @param treatDateFrom 治療日(From)
   * @param treatDateTo 治療日(To)
   * @return カテゴリリストエンティティのリスト
   */
  @Select
  List<ForecastInforResultForPatEventCount> selectPatEventCategoryCountResult(String treatDateFrom, String treatDateTo, Long patId, String facilityCd);
//add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 end
}
