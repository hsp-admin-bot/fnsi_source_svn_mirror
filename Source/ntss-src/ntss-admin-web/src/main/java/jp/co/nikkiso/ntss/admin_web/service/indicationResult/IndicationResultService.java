package jp.co.nikkiso.ntss.admin_web.service.indicationResult;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.core.entity.ForecastInforResult;
import jp.co.nikkiso.ntss.core.entity.IndicationResult;

/**
 * 予実リスト画面のServiceインタフェース.
 */
public interface IndicationResultService {

  /**
   * 予実リストの取得.
   *
   * @param patId 患者ID
   * @param treatDateFrom 治療日(From)
   * @param treatDateTo 治療日(To)
   * @return 予実リスト
   */
  List<IndicationResult> getList(Long patId, String treatDateFrom, String treatDateTo, String facilityCd);

  // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
  /**
   * 予実リストの取得.
   *
   * @param treatDateFrom 治療日(From)
   * @param treatDateTo 治療日(To)
   * @param patId 患者ID
   * @param facilityCd 施設コード
   * @param pattern 1:(患者イベント)、3:(検査結果)、4:(一般撮影検査予定)、5:(処方)
   * @return 予実リスト
   */
  List<ForecastInforResult> getList(String treatDateFrom, String treatDateTo, Long patId, String facilityCd, int pattern);

  /**
   * チェック項目数取得(患者イベント).
   *
   * @param examSetCd 検査セットID
   * @return チェック項目数
   */
  Map<String, String> getCheckNum(String facilityCd, List<String> examSetCd);
  // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end

  // add FNSI-改修内容 治療単位の治療方法マスタの有効項目に応じた表示 dou start
  List<String> getTreatmentConditionSetting(String facilityCd,String treatmentName);
  // add FNSI-改修内容 治療単位の治療方法マスタの有効項目に応じた表示 dou end
}
