package jp.co.nikkiso.ntss.admin_web.service.master.supportSetting;

import jp.co.nikkiso.ntss.core.entity.ExceptionPeriod;
import jp.co.nikkiso.ntss.core.entity.MntMedicineSupport;
import jp.co.nikkiso.ntss.core.entity.custom.CheckAvgData;

import java.util.List;
import java.util.Map;


public interface MstSupportSettingService {

  /**
   * 投薬支援の取得.
   *
   * @return 投薬支援情報.
   */
  List<MntMedicineSupport> selectMedicineSupport(String facilityCd);

  /**
   * 結果値の取得.
   *
   * @return 結果値.
   */
  List<Map<String,Object>> selectResultValue(String facilityCd, String cd, String patId, String startDate, String endDate,List<ExceptionPeriod> listExceptionPeriod);

  /**
   * 検査平均値の取得.
   *
   * @return 検査平均値.
   */
  List<CheckAvgData> selectCheckAvgData(String facilityCd, String patId, String startDate, String endDate, List<ExceptionPeriod> listExceptionPeriod, String cd);

  /**
   * 除外期間の取得.
   *
   * @return 除外期間.
   */
  List<Map<String,Object>> selectExceptionPeriod(String facilityCd, String patId);

  /**
   * 初期レンジの取得.
   *
   * @return 初期レンジ.
   */
  // #11205 -ペンテスト2－4認可制御の不備  mod 20260416 start
  Map<String,Object> selectRange(String cd, String facilityCd);
  // #11205 -ペンテスト2－4認可制御の不備  mod 20260416 end

  /**
   * 薬剤の取得.
   *
   * @return 薬剤.
   */
  List<Map<String,Object>> selectDrugData(String facilityCd, String patId, String baseDate, String cd);

  /**
   * 薬効換算の取得.
   *
   * @return 薬効換算.
   */
  List<Map<String,Object>> selectMedicineData(String cd);

  /**
   * 実績値の取得.
   *
   * @return 実績値.
   */
  String selectRstValueData(String facilityCd, String patId, String startDate,String endDate, String suppliesCd,String rstClass,List<ExceptionPeriod> listExceptionPeriod);

  /**
   * 期間値の取得.
   *
   * @return 実績値.
   */
  List<Object> selectDayOfMonth(String startDate, String endDate);

  /**
   * 平均値の取得.
   *
   * @return 平均値.
   */
  String selectAvgData(String facilityCd, String patId, String startDate, String endDate, String cd,List<ExceptionPeriod> listExceptionPeriod);

  /**
   * 単位の取得.
   *
   * @return 単位.
   */
  String selectUnitOfCd(String cd, String type);

  /**
   * 実績値の取得.
   *
   * @return 実績値.
   */
  String selectWeekCountOfCd(String cd, String baseDate, String facilityCd, String patId);

  /**
   * 実績値の取得.
   *
   * @return 実績値.
   */
  // mod #7746 投与支援で薬剤に薬効換算マスタの薬剤グループを設定すると算出できない 鄭爽 start
  // List<Map<String,Object>> selectMultiplicationData(String groupCd, String baseDate, String facilityCd, String patId);
  List<Map<String,Object>> selectMultiplicationData(String groupCd, String startDate, String endDate, String facilityCd, String patId);
  // mod #7746 投与支援で薬剤に薬効換算マスタの薬剤グループを設定すると算出できない 鄭爽 end
  /**
   * 保存処理.
   */
  int saveOrdMaterialSave(List<String> saveParameter);

  /* add by zhouyingying  2023-02-02 [CodeOptimization] start */
  /**
   * 薬剤平均投与量取得.
   * @param avgInvestParameter
   * @return
   */
  List<List<String>> getAvgInvestData(List<String> avgInvestParameter);
    /* add by zhouyingying  2023-02-02 [CodeOptimization] end */

    // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie start
    MntMedicineSupport selectMntMedicineSupportByCd(String cd);
    // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie end
}
