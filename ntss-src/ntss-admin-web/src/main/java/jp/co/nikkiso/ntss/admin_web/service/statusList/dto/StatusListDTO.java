package jp.co.nikkiso.ntss.admin_web.service.statusList.dto;

import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.statusList.Util;
import jp.co.nikkiso.ntss.admin_web.service.statusList.dto.condInfo.CondInfo;
import jp.co.nikkiso.ntss.admin_web.service.statusList.dto.condInfo.CondInfoItem;
import jp.co.nikkiso.ntss.admin_web.service.statusList.dto.condInfo.CondInfoService;
import jp.co.nikkiso.ntss.admin_web.service.statusList.dto.monitorData.MonitorDataDCS;
import jp.co.nikkiso.ntss.admin_web.service.statusList.dto.monitorData.MonitorDataItem;
import jp.co.nikkiso.ntss.admin_web.service.statusList.dto.offWaterInfo.OffWaterInfo;
import jp.co.nikkiso.ntss.admin_web.service.statusList.dto.physicalInfo.PhysicalInfo;
import jp.co.nikkiso.ntss.admin_web.service.statusList.dto.physicalInfo.PhysicalInfoItem;
import jp.co.nikkiso.ntss.admin_web.service.statusList.dto.weightInfo.WeightInfo;
import jp.co.nikkiso.ntss.admin_web.service.utils.DateTimeUtils;
import jp.co.nikkiso.ntss.admin_web.service.utils.MasterCacheHandler;
import jp.co.nikkiso.ntss.admin_web.service.utils.StrUtils;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.MstKur;
import jp.co.nikkiso.ntss.core.entity.MstMedicine;
import jp.co.nikkiso.ntss.core.entity.MstMedicineMix;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.PatUnique;
import jp.co.nikkiso.ntss.core.entity.custom.TreatmentStatusList;
import lombok.Getter;
import lombok.Setter;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Timestamp;
import java.text.DecimalFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;

/**
 * 治療状況リスト算出項目のDTO
 *
 */
@Component
@Getter
@Setter
public class StatusListDTO {

  //wp アプリケーションログの適正化 Add Start
  //@Autowired
  //@Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  /** オーダー情報 **/
  TreatmentStatusList ord;
  /** 透析条件情報取得用サービス **/
  CondInfoService condInfoService;

  /**
  * ロギングのServiceインタフェース.
  */
  //@Autowired
  //private LogService logService = new LogServiceImpl();

  /** オーダーに紐づくクールマスタ情報 **/
//  boolean loadedMstKur = false;
  MstKur mstKur;
  /** オーダーに紐づく患者基本情報 **/
//  boolean loadedPatUnique = false;
  PatUnique patUnique;
  /** オーダーに紐づくモニタ情報 **/
//  boolean loadedMniMonitor = false;
  MntMachineState mntMachineState;
  MniMonitor mniMonitor;
  /** オーダーに紐づくモニタ情報(現在血圧) **/
  MniMonitor mniMonitorNowBloodPressure;
  /** オーダーに紐づくモニタ情報(前血圧) **/
  MniMonitor mniMonitorBeforeBloodPressure;
  /** オーダーに紐づくモニタ情報(後血圧) **/
  MniMonitor mniMonitorAfterBloodPressure;
  /** オーダーに対する前回後体重情報 **/
//  boolean loadedLastWeightInfo = false;
  String lastWeightInfo;
  // add FNSI-モニタデータ取得変更 付 start
  /** オーダーに紐づくモニタ情報(中血圧) **/
  MniMonitor mniMonitorMiddleBloodPressure;
  /** オーダーに紐づくモニタ情報(体温) **/
  MniMonitor mniMonitorTemperaturePressure;
  /** オーダーに紐づくモニタ情報(再循環率) **/
  MniMonitor mniMonitorCyclePressure;
  // add FNSI-モニタデータ取得変更 付 end

  /** 各マスタの並び順 */
  List<MstSelector> mstSelectors;

  /** 観察記録件数 */
//  boolean loadedPatEventCount = false;
  Long patEventCount = 0L;
  /** 再循環率有効値  */
  boolean loadedReLoopRateMain = false;
  String reLoopRateMain = "";

//  // 透析液情報
//  boolean loadedDialysisFluidInfo = false;
//  HashMap<String,String> mapDialysisFluidInfo = new HashMap<String, String>();
//  // 抗凝固剤情報
//  boolean loadedAnticoagulant = false;
//  HashMap<String,String> mapAnticoagulant = new HashMap<String, String>();
//  // 補液情報
//  boolean loadedFluidReplacement = false;
//  HashMap<String,String> mapFluidReplacement = new HashMap<String, String>();


  /** 対オフライン装置  **/
  boolean offline = false;

  // add #6746 データの早期取得によるパフォーマンスの向上 查 start
  Map<Integer, String> mstEquipmentMap;

  Map<Integer, MstDialyzer> mstDialyzerMap;

  Map<Integer, String> mstVaMap;

  Map<String, CondInfo> indCondInfoMap;
  Map<String, CondInfo> rstCondInfoMap;
  // add #6746 データの早期取得によるパフォーマンスの向上 查 end

  Map<String, JsonNode> jsonNodeMap = new HashMap<>();

  Map<String, WeightInfo> weightInfoMap = new HashMap<>();
  Map<String, MonitorDataDCS> monitorDataMap = new HashMap<>();

  /**
   * アイテム取得処理の結果を保持するレコード
   * {@code getByItemCd} メソッドで、値（colValue）とマスタ表示順（msOrderIndex）をまとめて返すために使用します。
   */
  public record ItemResult(
    /**
     * 該当アイテムの値
     */
    String colValue,
    /**
     * マスタ表示順
     */
    Long msOrderIndex
  ) {}

  /**
   * Object Mapper
   */
  private ObjectMapper mapper = new ObjectMapper();

  /**
   * 初期化
   */
  public void initValue(){

    // StatusListDTO オブジェクト内のログ出力エラー対応
    logEventUtils = null;

    /** オーダー情報 **/
    ord = null;
    /** 透析条件情報取得用サービス **/
    condInfoService = null;


    /** オーダーに紐づくクールマスタ情報 **/
//    loadedMstKur = false;
    mstKur = null;
    /** オーダーに紐づく患者基本情報 **/
//    loadedPatUnique = false;
    patUnique = null;
    /** オーダーに紐づくモニタ情報 **/
//    loadedMniMonitor = false;
    mntMachineState = null;
    mniMonitor = null;
    /** オーダーに紐づくモニタ情報(現在血圧) **/
    mniMonitorNowBloodPressure = null;
    /** オーダーに紐づくモニタ情報(前血圧) **/
    mniMonitorBeforeBloodPressure = null;
    /** オーダーに紐づくモニタ情報(後血圧) **/
    mniMonitorAfterBloodPressure = null;
    /** オーダーに対する前回後体重情報 **/
//    loadedLastWeightInfo = false;
    lastWeightInfo = "";
    // add FNSI-モニタデータ取得変更 付 start
    /** オーダーに紐づくモニタ情報(中血圧) **/
    mniMonitorMiddleBloodPressure = null;
    /** オーダーに紐づくモニタ情報(体温) **/
    mniMonitorTemperaturePressure = null;
    /** オーダーに紐づくモニタ情報(再循環率) **/
    mniMonitorCyclePressure = null;
    // add FNSI-モニタデータ取得変更 付 end

    /** 観察記録件数 */
//    loadedPatEventCount = false;
    patEventCount = 0L;
    /** 再循環率有効値  */
    loadedReLoopRateMain = false;
    reLoopRateMain = "";

    offline = false;

  }


  /**
   * 「DW」を取得します。
   * @return DWの文字列。患者基本情報がnullの場合空文字列を返す。
   */
  public String getDW() {
    String rtn = "";
    try {
      // 治療状態判定
      if (ord.getRstDialysisState().equals("0")) {
        if (Objects.isNull(ord.getIndDw())) {
          // 未送信
          if (patUnique != null) {
            // 患者基本情報から身体情報を取得する
            PhysicalInfo physicalInfo = new PhysicalInfo(patUnique.getPhysical_info());
            PhysicalInfoItem dwItem = lastDwMeasure(physicalInfo, ord.getTreatDate());
            // 身体情報からDWを取得し戻り値にセット
            rtn = dwItem.getDw();
          }
        } else {
          rtn = ord.getIndDw().toString();
        }
      } else {
        // 条件送信以降
        rtn = ord.getRstDw().toString();
      }
    } catch (Exception e) {
      rtn = "";
    }
    return rtn;
  }

  /**
   * 最後にDWに値がセットされた患者個人身体情報を取得
   * @param physicalInfo
   * @param baseDate yyyyMMdd
   * @return
   */
  private PhysicalInfoItem lastDwMeasure(PhysicalInfo physicalInfo, String baseDate) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl="最後にDWに値がセットされた患者個人身体情報を取得";
    // wp アプリケーションログの適正化 Add End

    // #9312 Modify by Z.T. Start
    LocalDateTime baseDateTime;
    if (!StringUtils.hasText(baseDate)) {
//      baseDateTime = LocalDate.now().plusDays(1).atTime(0, 0);
      baseDateTime = LocalDateTime.now();
    } else {
      try {
        LocalDate localBaseDate = LocalDate.parse(baseDate, DateTimeFormatter.ofPattern("uuuuMMdd"));
//        baseDateTime = localBaseDate.plusDays(1).atTime(0, 0);
        // mod #11312 【たくしん会】治療状況リスト・マップの表示項目DWの参照データ不正 zkm start
//        baseDateTime = localBaseDate.atStartOfDay();
        baseDateTime = localBaseDate.plusDays(1).atTime(0, 0);
        // mod #11312 【たくしん会】治療状況リスト・マップの表示項目DWの参照データ不正 zkm end
      } catch (Exception ex) {
//        baseDateTime = LocalDate.now().plusDays(1).atTime(0, 0);
        // mod #11312 【たくしん会】治療状況リスト・マップの表示項目DWの参照データ不正 zkm start
//        baseDateTime = LocalDateTime.now();
        baseDateTime = LocalDate.now().plusDays(1).atTime(0, 0);
        // mod #11312 【たくしん会】治療状況リスト・マップの表示項目DWの参照データ不正 zkm end
      }
    }

    // 全記録格納フィールドを測定日時[ExaminDate]で降順ソート
    List<PhysicalInfoItem> records = physicalInfo.getAllRecords();
//    records.sort((a, b) -> {
//      String examDateA = a.getExamDate();
//      String examDateB = b.getExamDate();
//      if (examDateA.length() < 11) {
//        examDateA += "T00:00:00.000+09:00";
//      }
//      if (examDateB.length() < 11) {
//        examDateB += "T00:00:00.000+09:00";
//      }
//      Date A = DateTimeUtils.dateStringToDate_iso8601(examDateA);
//      Date B = DateTimeUtils.dateStringToDate_iso8601(examDateB);
//      return B.compareTo(A);
//    });
//
//    for (PhysicalInfoItem record : records) {
//      LocalDateTime examDate;
//      String examDateStr = record.getExamDate();
//      if (examDateStr.length() < 11) {
//        examDateStr += "T00:00:00.000+09:00";
//      }
//      try {
//        Date A = DateTimeUtils.dateStringToDate_iso8601(examDateStr);
//        Instant instant = A.toInstant();
//        examDate = LocalDateTime.ofInstant(instant, ZoneId.systemDefault());
//      } catch (Exception e) {
////        EventLogMessage eventLogMessage = new EventLogMessage();
////        eventLogMessage.setLogMessage(e.getLocalizedMessage());
////        logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, SERVICE_NAME.FNSI, null);
//
//        // wp アプリケーションログの適正化 Add Start
//      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),  FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, AFTER_LOG_FLG_ERROR, mappingUrl + ": " + e.getMessage(), ord.getFacilityCd(),
//        null);
//      // wp アプリケーションログの適正化 Add End
//        // 変換できない日付は未来にして対象外とする
//        examDate = LocalDateTime.now().plusYears(10);
//      }
//      if (examDate.isAfter(baseDateTime) || examDate.isEqual(baseDateTime)) {
//        // 基準日よりも後に登録したデータは無視
//        continue;
//      }
//      if (record.getDw() != null && !record.getDw().isEmpty() && !Objects.equals(record.getDw(), "null")) {
//        // 最後にCTRに値がセットされている時点のレコード
//        return record;
//      }
//    }

    final LocalDateTime base = baseDateTime;
    return records
      .stream()
      .peek(record -> {
        if (StringUtils.hasText(record.getExamDate()) && record.getExamDate().length() < 11)
          record.setExamDate(record.getExamDate() + "T00:00:00.000+09:00");
      })
      // mod #11312 【たくしん会】治療状況リスト・マップの表示項目DWの参照データ不正 zkm start
//      .sorted(Comparator.comparing(record -> DateTimeUtils.dateStringToDate_iso8601(record.getExamDate())))
      .sorted(this::compareByExamDateDesc)
      // mod #11312 【たくしん会】治療状況リスト・マップの表示項目DWの参照データ不正 zkm end
      .filter(record -> {
        try {
          // mod #11312 【たくしん会】治療状況リスト・マップの表示項目DWの参照データ不正 zkm start
//          return StringUtils.hasText(record.getDw())
          return StringUtils.hasText(record.getDw()) && !Objects.equals(record.getDw(), "null")
          // mod #11312 【たくしん会】治療状況リスト・マップの表示項目DWの参照データ不正 zkm end
            && base.isAfter(
            LocalDateTime.ofInstant(
              DateTimeUtils.dateStringToDate_iso8601(record.getExamDate()).toInstant()
              , ZoneId.systemDefault())
          );
        } catch (Exception e) {
          logEventUtils
            .resourceLogOutput(
              getClassName()
              , getMethodName()
              , FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, AFTER_LOG_FLG_ERROR
              , mappingUrl + ": " + e.getMessage()
              , ord.getFacilityCd()
              , null);
          return false;
        }
      })
      .findFirst()
      .orElse(null);
    // #9312 Modify by Z.T. End
  }

  // add #11312 【たくしん会】治療状況リスト・マップの表示項目DWの参照データ不正 zkm start
  private int compareByExamDateDesc(PhysicalInfoItem item1, PhysicalInfoItem item2) {
    Date d1 = DateTimeUtils.dateStringToDate_iso8601(item1.getExamDate());
    Date d2 = DateTimeUtils.dateStringToDate_iso8601(item2.getExamDate());
    // 全記録格納フィールドを測定日時[ExaminDate]で降順ソート
    return d2.compareTo(d1);
  }
  // add #11312 【たくしん会】治療状況リスト・マップの表示項目DWの参照データ不正 zkm end

  /**
   * 「DWから」(前体重-DW)の算出値を返します。
   * @return 算出値の文字列。例外が発生した場合は空文字列を返す。
   */
  public String getDiffBetweenBeforeWeightAndDW() {
    String rtn = "";
    try {
      // 治療状態判定
      if (!ord.getRstDialysisState().equals("0") && ord.getRstWeightInfo() != null) {
        // 条件送信以降

        // 体重情報取得
        WeightInfo weightInfo = null;
        String rstWeightInfo = ord.getRstWeightInfo();
        if (weightInfoMap.containsKey(rstWeightInfo)) {
          weightInfo = weightInfoMap.get(rstWeightInfo);
        } else {
          weightInfo = new WeightInfo(rstWeightInfo);
          weightInfoMap.put(rstWeightInfo, weightInfo);
        }
        // 前体重取得
        BigDecimal beforeWeight = new BigDecimal(weightInfo.getWeightBefore());
        // DW取得
        BigDecimal dw = ord.getRstDw();

        // 算出値
        BigDecimal diff = beforeWeight.subtract(dw);
        // 文字列にして戻す
        rtn = diff.toString();
      }
    } catch (Exception e) {
      rtn = "";
    }
    return rtn;
  }

  /**
   * 目標体重
   * @return
   */
  public String getTargetWeight() {

      // wp アプリケーションログの適正化 Add Start
      String mappingUrl="目標体重";

    String rtn = "";
    try {
      //del FNSI redmine 5756 start
//        // wp アプリケーションログの適正化 Add
//      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, BEFORE_LOG_FLG_INFO, mappingUrl, ord.getFacilityCd(),
//        null);
//      // wp アプリケーションログの適正化 Add End
      //del FNSI redmine 5756 end

      // 治療状態判定
      if (ord.getRstDialysisState().equals("0")) {
        // 未送信

        // 治療条件情報取得
        // mod #6746 取得データ方式の変更 查 start
//        CondInfo condInfo = condInfoService.createCondInfo(ord.getIndCondInfo());
        CondInfo condInfo = indCondInfoMap.get(ord.getIndCondInfo());
        // mod #6746 取得データ方式の変更 查 end
        // 目標体重
        rtn = condInfo.getTargetWeight().getValue();
        if (rtn == null || rtn.isEmpty() || Objects.equals(rtn, "-1") || Objects.equals(rtn, "null")) {
          rtn = this.getDW();
        }
      } else {
        // 条件送信済み以降

        // 治療条件情報取得
        // mod #6746 取得データ方式の変更 查 start
//        CondInfo condInfo = condInfoService.createCondInfo(ord.getRstCondInfo());
        CondInfo condInfo = rstCondInfoMap.get(ord.getRstCondInfo());
        // mod #6746 取得データ方式の変更 查 end
        // 目標体重
        rtn = condInfo.getTargetWeight().getValue();
        //add FNSI redmine 5756 start
        if (rtn == null || rtn.isEmpty() || Objects.equals(rtn, "-1") || Objects.equals(rtn, "null")) {
          rtn = this.getDW();
        }
        //add FNSI redmine 5756 end
      }
      //del FNSI redmine 5756 start
//      // wp アプリケーションログの適正化 Add Start
//      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, AFTER_LOG_FLG_INFO, mappingUrl, ord.getFacilityCd(),
//        null);
//      // wp アプリケーションログの適正化 Add End
      //del FNSI redmine 5756 end
    } catch (Exception e) {
      rtn = "";
      //del FNSI redmine 5756 start
//      // wp アプリケーションログの適正化 Add Start
//      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, AFTER_LOG_FLG_ERROR, mappingUrl + ": " + e.getMessage(), ord.getFacilityCd(),
//        null);
//      // wp アプリケーションログの適正化 Add End
      //del FNSI redmine 5756 end
    }
    return rtn;
  }

  /**
   * 「目標体重から」(前体重-目標体重)の算出値を返します。
   * @return 算出値の文字列。例外が発生した場合は空文字列を返す。
   */
  public String getDiffBetweenBeforeWeightAndTargetWeight() {
    String rtn = "";
    try {
      // 治療状態判定
      if (!ord.getRstDialysisState().equals("0") && ord.getRstWeightInfo() != null) {
        // 条件送信以降

        // 体重情報取得
        WeightInfo weightInfo = null;
        String rstWeightInfo = ord.getRstWeightInfo();
        if (weightInfoMap.containsKey(rstWeightInfo)) {
          weightInfo = weightInfoMap.get(rstWeightInfo);
        } else {
          weightInfo = new WeightInfo(rstWeightInfo);
          weightInfoMap.put(rstWeightInfo, weightInfo);
        }

        // 前体重取得
        BigDecimal beforeWeight = new BigDecimal(weightInfo.getWeightBefore());

        // 目標体重取得
        BigDecimal targetWeight = new BigDecimal(this.getTargetWeight());

        // 算出値
        BigDecimal diff = beforeWeight.subtract(targetWeight);
        // 文字列にして戻す
        rtn = diff.toString();
      }
    } catch (Exception e) {
      rtn = "";
    }
    return rtn;
  }

  /**
   * 透析開始日付時刻を返します。
   * 透析前：治療予定の指示：治療開始時刻
   * 運転開始以降：治療状況の実績：治療開始日時
   * 透析前で指示の治療開始時刻が未設定の場合、空文字列を返します。
   * @return 透析開始日付時刻を表す日付時刻型(LocaDateTime)
   */
  public LocalDateTime getTreatStartTime() {
    LocalDateTime date = null;

    // 治療状態判定
    if (Integer.parseInt(ord.getRstDialysisState()) < 3) {
      // 透析前判定
      if (!StringUtils.isEmpty(ord.getIndTreatStartTime())) {
        // 日付時刻変換(YYYYMMDDHHMMSS形式)
        String strwork = ord.getTreatDate() + ord.getIndTreatStartTime();
        date = Util.dateTimeStringToLocalDateTime(strwork, "uuuuMMddHHmm");
      }
    } else {
      // 透析中判定
      date = ord.getRstStartDate().toLocalDateTime();
    }

    return date;
  }

  /**
   * 終了予測時刻を返します。
   * 除水完了をもとにした終了予測時刻と透析終了をもとにした終了予測時刻と補液完了をもとにした終了予測時刻のうち遅いほうを返します。
   * 除水完了をもとにした終了予測時刻を取得する場合はgetEstimateEndTimeWaterRemoveFinishメソッドを使用して下さい。
   * 透析終了をもとにした終了予測時刻を取得する場合はgetEstimateEndTimeDialysisFinishメソッドを使用して下さい。
   * 補液完了をもとにした終了予測時刻を取得する場合はgetEstimateEndTimeFluidReplacemantFinishメソッドを使用して下さい。
   * @return 終了予測の日付時刻(LocalDateTime)
   */
  public LocalDateTime getEstimateEndTime() {
    LocalDateTime ret = null;
    Long tmpRet = 0L;

    // 終了予測(除水完了)
    LocalDateTime endTimeWaterRemoval = this.getEstimateEndTimeWaterRemoveFinish();
    // 終了予測(透析終了)
    LocalDateTime endTimeDialysis = this.getEstimateEndTimeDialysisFinish();
    // 終了予測(補液完了)
    LocalDateTime endTimeFluidReplacemant = this.getEstimateEndTimeFluidReplacemantFinish();

    // 数値に換算
    Long longWaterRemoval = endTimeWaterRemoval == null ? 0L : Timestamp.valueOf(endTimeWaterRemoval).getTime();
    Long longDialysis = endTimeDialysis == null ? 0L : Timestamp.valueOf(endTimeDialysis).getTime();
    Long longFluidReplacemant = endTimeFluidReplacemant == null ? 0L : Timestamp.valueOf(endTimeFluidReplacemant).getTime();

    // 大きいほうを戻り値とする
    if (longWaterRemoval.longValue() > longDialysis.longValue()) {
      ret = endTimeWaterRemoval;
      tmpRet = longWaterRemoval;
    } else {
      ret = endTimeDialysis;
      tmpRet = longDialysis;
    }
    if (longFluidReplacemant.longValue() > tmpRet.longValue()) {
      ret = endTimeFluidReplacemant;
    }
    return ret;
  }

  /**
   * 終了予測(除水完了)時刻を返します。
   * 定義：開始日時+残り時間(除水完了)(モニタデータ)
   * @return 終了予測の日付時刻(LocalDateTime)
   */
  public LocalDateTime getEstimateEndTimeWaterRemoveFinish() {
    return this.estimateEndTime(0);

  }

  /**
   * 終了予測(透析終了)時刻を返します。
   * 定義：開始日時＋残り時間(透析終了)(モニタデータ)
   * @return 終了予測の日付時刻(LocalDateTime)
   */
  public LocalDateTime getEstimateEndTimeDialysisFinish() {
    return this.estimateEndTime(1);

  }

  /**
   * 終了予測(補液完了)時刻を返します。
   * 定義：開始日時＋残り時間(補液完了)(モニタデータ)
   * @return 終了予測の日付時刻(LocalDateTime)
   */
  public LocalDateTime getEstimateEndTimeFluidReplacemantFinish() {
    return this.estimateEndTime(2);
  }

  /**
   * 終了予測取得プライベートメソッド。
   * 除水完了と透析終了と補液完了の区別を引数に与えます。
   * @param mode 0:除水完了、1:透析終了、 2：補液完了
   * @return 終了予測の日付時刻(LocalDateTime)
   */
  private LocalDateTime estimateEndTime(Integer mode) {
    LocalDateTime ret = null;
    try {
      if (ord != null && (mode == 0 || mode == 1 || mode == 2)) {
        // モニタデータ項目コードの定義：除水完了の場合コード:3
        Integer itemCd = 3;
        // 透析終了の場合コード:4
        if (mode == 1) {
          itemCd = 4;
        }
        // 補液完了の場合コード:78
        if (mode == 2) {
          itemCd = 78;
        }

        // 状態の取得
        int status = 0;
        if(ord.getRstDialysisState() !=null && StrUtils.isNumber(ord.getRstDialysisState())) {
          status = Integer.parseInt(ord.getRstDialysisState());
        }
        if (status == 3 && ord.getRstStartDate() != null) {
          Long remain = 0L;

          // 開始日時取得
          LocalDateTime start = ord.getRstStartDate().toLocalDateTime();

          if (mntMachineState != null) {
            // モニタデータ取得
            MonitorDataDCS monitorData = null;
            String monitorDataStr = mntMachineState.getMonitorData();
            if (monitorDataStr != null) {
              if (monitorDataMap.containsKey(monitorDataStr)) {
                monitorData = monitorDataMap.get(monitorDataStr);
              } else {
                monitorData = new MonitorDataDCS(monitorDataStr);
                monitorDataMap.put(monitorDataStr, monitorData);
              }
            }

            if (monitorData != null) {
              // 経過時間の取得
              MonitorDataItem progressItem = monitorData.getByItemCd(1);
              remain += progressItem == null ? 0 : progressItem.isValidValue() ? Long.parseLong(progressItem.getValue()): 0;
              // 残り時間の取得
              MonitorDataItem remainItem = monitorData.getByItemCd(itemCd);
              remain += remainItem == null ? 0 : remainItem.isValidValue() ? Long.parseLong(remainItem.getValue()) : 0;
            }
          } else {
            // オフライン装置の場合
            if (this.isOffline()) {
              // 治療時間の取得
              Integer treatTime = this.getTreatTime();
              if (treatTime != null) {
                remain += treatTime.longValue();
              }
            }
          }
          // 時刻の加算
          ret = start.plusMinutes(remain);
        } else if (status > 3) {
          // 実績治療終了日時取得
          Timestamp endDateTime = ord.getRstEndDate();
          if (endDateTime != null) {
            ret = endDateTime.toLocalDateTime();
          }
        }
      }
    } catch (Exception e) {
    }
    return ret;
  }

  /**
   * 治療予定時間
   * @return
   */
  public Integer getTreatTime() {
      // wp アプリケーションログの適正化 Add Start
      String mappingUrl="治療予定時間";
//      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, BEFORE_LOG_FLG_INFO, mappingUrl, ord.getFacilityCd(), null);
      // wp アプリケーションログの適正化 Add End

    Integer ret = null;
    String work = "";
    try {
      // mod #6746 取得データ方式の変更 查 start
//      String condInfoText = null;
//      // 治療状態判定
//      if (ord.getRstDialysisState().equals("0")) {
//        // 未送信
//        condInfoText = ord.getIndCondInfo();
//      } else {
//        // 条件送信後
//        condInfoText = ord.getRstCondInfo();
//      }
//      if (null != condInfoText) {
//        CondInfo condInfo = condInfoService.createCondInfo(condInfoText);
//        CondInfoItem condItem = condInfo.getTreatTime();
//        work = condItem.getValue();
//        if( StrUtils.isNumber(work)) {
//          ret = Integer.parseInt(work);
//        }
//      }

      CondInfo condInfo = null;
      if ("0".equals(ord.getRstDialysisState())) {
        condInfo = indCondInfoMap.get(ord.getIndCondInfo());
      } else {
        condInfo = rstCondInfoMap.get(ord.getRstCondInfo());
      }
      if (condInfo != null) {
        CondInfoItem condItem = condInfo.getTreatTime();
        work = condItem.getValue();
        if( StrUtils.isNumber(work)) {
          ret = Integer.parseInt(work);
        }
      }
      // mod #6746 取得データ方式の変更 查 end

      // wp アプリケーションログの適正化 Add Start
//      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, AFTER_LOG_FLG_INFO, mappingUrl, ord.getFacilityCd(),
//        null);
      // wp アプリケーションログの適正化 Add End

    } catch (Exception e) {
        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, AFTER_LOG_FLG_ERROR, mappingUrl, ord.getFacilityCd(),
          null);
        // wp アプリケーションログの適正化 Add End
    }
    return ret;
  }

  /**
   * 遅れ時間を返します。
   * 定義：終了予測 - 開始日時 - 透析時間(透析条件)
   * (上記式の展開)：(開始日時+残り時間)-開始日時-透析時間=残り時間-透析時間
   * TODO:元の定義は経過時間(モニタデータ) + 終了予測 - 透析時間(透析条件)だが、時刻ではなく時間であるべきでは？
   * @return 遅れ時間(分)
   */
  public Integer getDelayTime() {
    // 治療中以外は 0 で応答する
    if (ord != null) {
      if (ord.getRstDialysisState() !=null && StrUtils.isNumber(ord.getRstDialysisState())) {
        if (Integer.parseInt(ord.getRstDialysisState()) != 3) {
          return 0;
        }
      }
    } else {
      return 0;
    }

    Integer rtn = null;
    try {
      // 終了予測：YYYYMMDDHH24MISS形式
      LocalDateTime estimateEndTime = this.getEstimateEndTime();
      if (estimateEndTime != null) {
        // 秒に換算
        Long estimateEndTime_s = Timestamp.valueOf(estimateEndTime).getTime() / 1000;

        // 開始日時取得
        LocalDateTime startDateTime = this.getTreatStartTime();
        if ( startDateTime != null ) {
          // 秒に換算
          Long startTime_s = Timestamp.valueOf(startDateTime).getTime() / 1000;

          // 透析時間：分
          Integer runningTime = this.getTreatTime();
          // 秒に換算
          Long runningTime_s =  runningTime * 60L;

          // 遅れ時間(秒)(終了予測 - 開始日時 - 透析時間
          Long delay_s = estimateEndTime_s - startTime_s - runningTime_s;
          // 遅れ時間(分)
          rtn = (int)(delay_s / 60L);
        }
      }
    } catch (Exception e) {
    }

    return rtn;
  }

  /**
   * 前体重-後体重を返します。
   * @return
   */
  public String getDiffBetweenBeforeWeightAndAfterWeight() {
    String rtn = "";

    try {
      // 体重情報取得
      if (ord.getRstWeightInfo() == null) {
        return rtn;
      }
      WeightInfo weightInfo = null;
      String rstWeightInfo = ord.getRstWeightInfo();
      if (weightInfoMap.containsKey(rstWeightInfo)) {
        weightInfo = weightInfoMap.get(rstWeightInfo);
      } else {
        weightInfo = new WeightInfo(rstWeightInfo);
        weightInfoMap.put(rstWeightInfo, weightInfo);
      }
      // 前体重
      BigDecimal weightBefore = new BigDecimal(weightInfo.getWeightBefore());
      // 後体重
      BigDecimal weightAfter = new BigDecimal(weightInfo.getWeightAfter());

      // 前体重-後体重
      BigDecimal buf = weightBefore.subtract(weightAfter);

      rtn = buf.toString();
    } catch (Exception e) {
      rtn = "";
    }
    return rtn;
  }

  /**
   * 予想引き残しを返します。
   * (前体重－除水目標)－目標体重＋除水補正値合計。
   * 除水目標値は条件送信時の値ではなく、モニタ値の除水目標。
   * @return 引き残し重量の文字列(単位:kg)
   */
  public String getEstimateWaterRemain() {

    String rtn = "";
    // wp アプリケーションログの適正化 Add
    String mappingUrl="予想引き残し";


    if (ord != null && mniMonitor != null && ord.getRstWeightInfo() != null) {

        // wp アプリケーションログの適正化 Add
//      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, BEFORE_LOG_FLG_INFO, mappingUrl, ord.getFacilityCd(), null);

      String weightBeforeStr = null;
      try {
        // 前体重(定義　単位:[kg])
        WeightInfo weightInfo = null;
        String rstWeightInfo = ord.getRstWeightInfo();
        if (weightInfoMap.containsKey(rstWeightInfo)) {
          weightInfo = weightInfoMap.get(rstWeightInfo);
        } else {
          weightInfo = new WeightInfo(rstWeightInfo);
          weightInfoMap.put(rstWeightInfo, weightInfo);
        }
        weightBeforeStr = weightInfo.getWeightBefore();
        if (weightBeforeStr == null || "".equals(weightBeforeStr) || "null".equals(weightBeforeStr)) {
          return rtn;
        }
        BigDecimal weightBefore = new BigDecimal(weightBeforeStr);

        // 除水目標(定義　単位：[L] 範囲：0.00～39.90)
        MonitorDataDCS monitorData = null;
        String monitorDataStr = mniMonitor.getMonitorData();
        if (monitorDataStr != null) {
          if (monitorDataMap.containsKey(monitorDataStr)) {
            monitorData = monitorDataMap.get(monitorDataStr);
          } else {
            monitorData = new MonitorDataDCS(monitorDataStr);
            monitorDataMap.put(monitorDataStr, monitorData);
          }
        }
        MonitorDataItem moniItem = monitorData != null ? monitorData.getByItemCd(32) : null;
        String waterRemovalTargetStr = null;
        if (moniItem != null) {
          waterRemovalTargetStr = moniItem.getValue();
        }
        if (waterRemovalTargetStr == null || waterRemovalTargetStr.isEmpty()) {
          waterRemovalTargetStr = "0.0";
        }
        BigDecimal waterRemovalTarget = new BigDecimal(waterRemovalTargetStr);

        // 目標体重(定義　単位:[kg])
        // mod #6746 取得データ方式の変更 查 start
//        CondInfo condInfo = condInfoService.createCondInfo(ord.getRstCondInfo());
        CondInfo condInfo = rstCondInfoMap.get(ord.getRstCondInfo());
        String targetWeightStr = null;
        if (condInfo != null) {
          targetWeightStr = condInfo.getTargetWeight().getValue();
        }
        // mod #6746 取得データ方式の変更 查 end
//        CondInfoItem condItem = condInfo.getTargetWeight();
//        String targetWeightStr = condItem.getValue();
        if (targetWeightStr == null || targetWeightStr.isEmpty()) {
          targetWeightStr = "0.0";
        }
        BigDecimal targetWeight = new BigDecimal(targetWeightStr);

        // 除水補正値(定義　単位:[g])
        BigDecimal offWaterWeightTotal = new BigDecimal(0);
        if (ord.getIndOffWaterInfo() != null) {
          OffWaterInfo offWaterInfo = new OffWaterInfo(ord.getIndOffWaterInfo());
          if (offWaterInfo != null && offWaterInfo.getOffWaterWeightTotal() != null) {
            offWaterWeightTotal = offWaterInfo.getOffWaterWeightTotal();
          }
        }

        // グラムにそろえて計算
        BigDecimal weightBefore_g = weightBefore.multiply(new BigDecimal("1000"));
        BigDecimal waterRemovalTarget_g = waterRemovalTarget.multiply(new BigDecimal("1000"));
        BigDecimal targetWeight_g = targetWeight.multiply(new BigDecimal("1000"));

        BigDecimal buf1 = weightBefore_g.subtract(waterRemovalTarget_g);
        BigDecimal buf2 = buf1.subtract(targetWeight_g);
        BigDecimal buf3 = buf2.add(offWaterWeightTotal);

        // kgに直す(小数点第3位を切り捨て)
        BigDecimal buf4 = buf3.divide(new BigDecimal("1000"), 2, BigDecimal.ROUND_DOWN);

        // 文字列にして戻す
        rtn = buf4.toString();

        // wp アプリケーションログの適正化 Add Start
//        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, AFTER_LOG_FLG_INFO, mappingUrl, ord.getFacilityCd(), null);
        // wp アプリケーションログの適正化 Add End

      } catch (Exception e) {
        rtn = "";
        // wp アプリケーションログの適正化 Add Start
       logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, AFTER_LOG_FLG_ERROR, mappingUrl + ": " + e.getMessage(), ord.getFacilityCd(),
         e.getMessage());
       // wp アプリケーションログの適正化 Add End
      }
    }

    return rtn;
  }

  /**
   * 引き残しを返します。
   * 引き残し：後体重ー目標体重
   * @return 引き残し重量の文字列(単位:kg)
   */
  public String getWaterRemain() {
    String rtn = "";
    // wp アプリケーションログの適正化 Add
    String mappingUrl="引き残し";

    try {
        // wp アプリケーションログの適正化 Add
//        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, BEFORE_LOG_FLG_INFO, mappingUrl, ord.getFacilityCd(), null);

      // 後体重(定義　単位:[kg])
      if (ord.getRstWeightInfo() == null) {
        return rtn;
      }
      WeightInfo weightInfo = null;
      String rstWeightInfo = ord.getRstWeightInfo();
      if (weightInfoMap.containsKey(rstWeightInfo)) {
        weightInfo = weightInfoMap.get(rstWeightInfo);
      } else {
        weightInfo = new WeightInfo(rstWeightInfo);
        weightInfoMap.put(rstWeightInfo, weightInfo);
      }
      // mod #6746 取得データ方式の変更 查 start
      if (weightInfo.getWeightAfter() != null && !"null".equals(weightInfo.getWeightAfter())) {
        BigDecimal weightAfter = new BigDecimal(weightInfo.getWeightAfter());

        // 目標体重(定義　単位:[kg])
//        CondInfo condInfo = condInfoService.createCondInfo(ord.getRstCondInfo());
        CondInfo condInfo = rstCondInfoMap.get(ord.getRstCondInfo());
        if (condInfo == null) {
          return rtn;
        }
        CondInfoItem condItem = condInfo.getTargetWeight();
        BigDecimal targetWeight = new BigDecimal(condItem.getValue());

        // 引き残しを算出
        BigDecimal waterRemain = weightAfter.subtract(targetWeight);

        // 文字列にして戻す
        rtn = waterRemain.toString();
      }
      // mod #6746 取得データ方式の変更 查 end

      // wp アプリケーションログの適正化 Add Start
//      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, AFTER_LOG_FLG_INFO, mappingUrl, ord.getFacilityCd(), null);
      // wp アプリケーションログの適正化 Add End

    } catch (Exception e) {
      rtn = "";
      // wp アプリケーションログの適正化 Add Start
     logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, AFTER_LOG_FLG_ERROR, mappingUrl, ord.getFacilityCd(),
       e.getMessage());
     // wp アプリケーションログの適正化 Add End

    }

    return rtn;
  }

  /**
   * 達成率を返します。
   * 除水量現在値÷総除水量
   * @return
   */
  public String getAchievementRate() {
    String ret = "";
    try {
      // 総除水量
      if(ord.getRstWeightInfo() == null) {
        return ret;
      }
      WeightInfo weightInfo = null;
      String rstWeightInfo = ord.getRstWeightInfo();
      if (weightInfoMap.containsKey(rstWeightInfo)) {
        weightInfo = weightInfoMap.get(rstWeightInfo);
      } else {
        weightInfo = new WeightInfo(rstWeightInfo);
        weightInfoMap.put(rstWeightInfo, weightInfo);
      }
      String strWaterRemoveTarget = weightInfo.getWaterRemovalTarget();
      BigDecimal waterRemoveTarget = new BigDecimal(strWaterRemoveTarget);

      // 除水量現在値
      String strNowWaterRemove = "";
      if (mniMonitor != null) {
        // モニタデータ取得
        MonitorDataDCS monitorData = null;
        String monitorDataStr = mniMonitor.getMonitorData();
        if (monitorDataStr != null) {
          if (monitorDataMap.containsKey(monitorDataStr)) {
            monitorData = monitorDataMap.get(monitorDataStr);
          } else {
            monitorData = new MonitorDataDCS(monitorDataStr);
            monitorDataMap.put(monitorDataStr, monitorData);
          }
        }
        // 除水量現在値
        MonitorDataItem monitorItem = monitorData != null ? monitorData.getByItemCd(5) : null;
        if (monitorItem != null && !monitorItem.getValue().isEmpty()) {
          strNowWaterRemove = monitorItem.getValue();
          BigDecimal nowWaterRemove = new BigDecimal(strNowWaterRemove);

          // 達成率算出(除水量現在値÷総除水量 ※小数第2位で四捨五入)
          BigDecimal retBigDecimal = nowWaterRemove.divide(waterRemoveTarget,2, RoundingMode.HALF_UP);
          // 100倍して整数化（画面表示は%表示のため）
          retBigDecimal = retBigDecimal.multiply(BigDecimal.valueOf(100)).setScale(0, RoundingMode.HALF_UP);
          // 文字列に変換
          ret = retBigDecimal.toPlainString();
        }
      }
    } catch (Exception e) {
    }
    return ret;
  }

  /**
   * 条件確認状態を返します
   * ただし？？？？患者の場合は空を返す
   * @return
   */
  public String getCondConfirm() {
    String ret = "";
    if (ord.getPatId() != null && 2 <= Integer.parseInt(ord.getRstDialysisState())) {
      ret = "済";
    }
    return ret;
  }

  /**
   * 終了予定を返します。
   * 透析前：指示透析開始時刻＋治療条件治療時間
   * ただし指示透析開始時刻に値がない場合、クールマスタの標準開始時刻＋治療条件治療時間
   * 運転開始以降：実績運転開始時刻＋治療条件治療時間
   * @return 終了予定を表すYYYYMMDDHH24MISS形式の文字列
   */
  public LocalDateTime getEndTimePlan() {
    LocalDateTime ret = null;
    try {
      // 状態3まで場合のの処理
      int status = 0;
      if(ord.getRstDialysisState() !=null && StrUtils.isNumber(ord.getRstDialysisState())) {
        status = Integer.parseInt(ord.getRstDialysisState());
      }
      if (status <= 3) {
        // 治療条件治療時間(分)
        Integer treatTime = this.getTreatTime();

        // 開始日付時刻を取得する
        LocalDateTime start = this.getTreatStartTime();

        // 終了予定(開始日時 + 治療時間)を算出
        ret = start.plusMinutes(treatTime);
      } else {
        // 状態4以降の場合
        Timestamp endDateTime = ord.getRstEndDate();
        if (endDateTime != null) {
          ret = endDateTime.toLocalDateTime();
        }
      }
    } catch (Exception e) {
    }
    return ret;
  }

  /**
   * 増加量を返します。
   * 増加量：前体重ー前回後体重
   * @return 増加量(単位：kg)
   */
  public String getIncrement() {
    String rtn = "";
    try {
      if ( ord != null && ord.getRstWeightInfo() != null) {
        // 前体重(単位:[kg])
        WeightInfo weightInfo = null;
        String rstWeightInfo = ord.getRstWeightInfo();
        if (weightInfoMap.containsKey(rstWeightInfo)) {
          weightInfo = weightInfoMap.get(rstWeightInfo);
        } else {
          weightInfo = new WeightInfo(rstWeightInfo);
          weightInfoMap.put(rstWeightInfo, weightInfo);
        }
        String weightBeforeStr = weightInfo.getWeightBefore();
        BigDecimal weightBefore = new BigDecimal(weightBeforeStr);

        // 前回後体重
        String lastAfterWeightStr = this.getLastAfterWeight();
        BigDecimal lastWeightAfter = new BigDecimal(lastAfterWeightStr);

        // 増加量
        BigDecimal increment = weightBefore.subtract(lastWeightAfter);

        // 文字列にして戻す
        rtn = increment.toString();
      }
    } catch( Exception e ) {
    }
    return rtn;
  }

  /**
   * 増加率を返します。
   * １）前回後体重から算出（((前体重 - 前回後体重) / 前回後体重) * 100）
   * ２）DWから算出（((前体重 - DW) / DW) * 100）
   * 上記の選択はシステム設定にて切り替え。初期値は１）
   * @return 増加率(小数点以下2桁、単位：%)
   */
  public String getIncrementRate() {
    // TODO:システム設定が決まり次第設定値を取得する
    // システム設定値(暫定で1)
    Integer sysSetting = 1;
    String rtn = "";

    try {
      if ( ord != null && ord.getRstWeightInfo() != null) {
        // 前体重(単位:[kg])
        WeightInfo weightInfo = null;
        String rstWeightInfo = ord.getRstWeightInfo();
        if (weightInfoMap.containsKey(rstWeightInfo)) {
          weightInfo = weightInfoMap.get(rstWeightInfo);
        } else {
          weightInfo = new WeightInfo(rstWeightInfo);
          weightInfoMap.put(rstWeightInfo, weightInfo);
        }
        String weightBeforeStr = weightInfo.getWeightBefore();
        BigDecimal weightBefore = new BigDecimal(weightBeforeStr);

        BigDecimal calcValue = null;
        if (sysSetting == 1) {
          // 増加率を前回後体重から算出
          // 前回後体重を計算値として使用する
          String lastAfterWeight = this.getLastAfterWeight();
          calcValue = new BigDecimal(lastAfterWeight);
        } else {
          // 増加率をDWから算出
          // DWを計算値として使用する
          if (ord.getRstDw() != null) {
            calcValue = ord.getRstDw();
          }
        }

        if ( calcValue != null ) {
          // 増加率の算出
          BigDecimal buf1 = weightBefore.subtract(calcValue);
          BigDecimal buf2 = buf1.multiply(new BigDecimal("100"));
          BigDecimal buf3 = buf2.divide(calcValue, 2, RoundingMode.DOWN);
          rtn = buf3.toPlainString();
        }
      }
    } catch ( Exception ex ) {
    }
    // 文字列にして戻す
    return rtn;
  }

  /**
   * 前回後体重を返します。
   * @return 体重値の文字列(単位：kg)
   */
  public String getLastAfterWeight() {
    String rtn = "";
    try {
      // 前回後体重の体重情報
      if (this.lastWeightInfo == null) {
        return rtn;
      }
      WeightInfo lastWeightInfo = null;
      String rstWeightInfo = this.lastWeightInfo;
      if (weightInfoMap.containsKey(rstWeightInfo)) {
        lastWeightInfo = weightInfoMap.get(rstWeightInfo);
      } else {
        lastWeightInfo = new WeightInfo(rstWeightInfo);
        weightInfoMap.put(rstWeightInfo, lastWeightInfo);
      }
      // 後体重を取得し返す
      rtn = lastWeightInfo.getWeightAfter();
    } catch (Exception e) {
      rtn = "";
    }
    return rtn;
  }

  /**
   * 血圧表示フォーマット
   * @param max：最大血圧
   * @param min：最小血圧
   * @param ave：平均血圧
   * @param pulse：脈拍
   * @return
   */
  private String makeBloodPressureText(String max, String min, String ave, String pulse) {
    String ret = "";
    if (!max.isEmpty() || !min.isEmpty() || !ave.isEmpty() || !pulse.isEmpty()) {
      ret = String.format("%s/ %s/ %s (%s)", max, min, ave, pulse);
    }
    return ret;
  }

  /**
   * 現在血圧を返します
   * @return
   */
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
  public String getNowBloodPressure() throws tools.jackson.core.JacksonException {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    // モニタデータ取得
    if (mniMonitorNowBloodPressure != null) {
      MonitorDataDCS monitorData = null;
      String monitorDataStr = mniMonitorNowBloodPressure.getMonitorData();
      if (monitorDataStr != null) {
        if (monitorDataMap.containsKey(monitorDataStr)) {
          monitorData = monitorDataMap.get(monitorDataStr);
        } else {
          monitorData = new MonitorDataDCS(monitorDataStr);
          monitorDataMap.put(monitorDataStr, monitorData);
        }
      }
      if (monitorData != null) {
        return makeBloodPressureText(
            monitorData.getByItemCd(90).getValue(), monitorData.getByItemCd(91).getValue(),
            monitorData.getByItemCd(92).getValue(), monitorData.getByItemCd(93).getValue());
      }
    }
    return "";
  }

  /**
   * 前血圧(最高)を返します。
   * @return
   */
  public String getBpMaxBefore() {
    String rtn = "";
    try {
      // モニタデータ取得
      //mod FNSI redmine 6408 劉祥霖 start
//    if (mniMonitorNowBloodPressure != null) {
      if (mniMonitorBeforeBloodPressure != null) {
        //mod FNSI redmine 6408 劉祥霖 end
        MonitorDataDCS monitorData = null;
        String monitorDataStr = mniMonitorBeforeBloodPressure.getMonitorData();
        if (monitorDataStr != null) {
          if (monitorDataMap.containsKey(monitorDataStr)) {
            monitorData = monitorDataMap.get(monitorDataStr);
          } else {
            monitorData = new MonitorDataDCS(monitorDataStr);
            monitorDataMap.put(monitorDataStr, monitorData);
          }
        }
        if (monitorData != null) {
          rtn = monitorData.getByItemCd(90).getValue();
        }
      }
    } catch (Exception e) {
      rtn = "";
    }
    return rtn;
  }

  /**
   * 前血圧(最低)を返します。
   * @return
   */
  public String getBpMinBefore() {
    String rtn = "";
    try {
      // モニタデータ取得
      //mod FNSI redmine 6408 劉祥霖 start
//    if (mniMonitorNowBloodPressure != null) {
      if (mniMonitorBeforeBloodPressure != null) {
        //mod FNSI redmine 6408 劉祥霖 end
        MonitorDataDCS monitorData = null;
        String monitorDataStr = mniMonitorBeforeBloodPressure.getMonitorData();
        if (monitorDataStr != null) {
          if (monitorDataMap.containsKey(monitorDataStr)) {
            monitorData = monitorDataMap.get(monitorDataStr);
          } else {
            monitorData = new MonitorDataDCS(monitorDataStr);
            monitorDataMap.put(monitorDataStr, monitorData);
          }
        }
        if (monitorData != null) {
          rtn = monitorData.getByItemCd(91).getValue();
        }
      }
    } catch (Exception e) {
      rtn = "";
    }
    return rtn;
  }

  /**
   * 前血圧(平均)を返します。
   * @return
   */
  public String getBpAveBefore() {
    String rtn = "";
    try {
      // モニタデータ取得
      //mod FNSI redmine 6408 劉祥霖 start
//    if (mniMonitorNowBloodPressure != null) {
      if (mniMonitorBeforeBloodPressure != null) {
      //mod FNSI redmine 6408 劉祥霖 end
        MonitorDataDCS monitorData = null;
        String monitorDataStr = mniMonitorBeforeBloodPressure.getMonitorData();
        if (monitorDataStr != null) {
          if (monitorDataMap.containsKey(monitorDataStr)) {
            monitorData = monitorDataMap.get(monitorDataStr);
          } else {
            monitorData = new MonitorDataDCS(monitorDataStr);
            monitorDataMap.put(monitorDataStr, monitorData);
          }
        }
        if (monitorData != null) {
          rtn = monitorData.getByItemCd(92).getValue();
        }
      }
    } catch (Exception e) {
      rtn = "";
    }
    return rtn;
  }

  /**
   * 前血圧を返します。
   * @return
   */
  public String getBpBefore() {
    String rtn = "";
    try {
      // モニタデータ取得
      //mod FNSI redmine 6408 劉祥霖 start
//    if (mniMonitorNowBloodPressure != null) {
      if (mniMonitorBeforeBloodPressure != null) {
      //mod FNSI redmine 6408 劉祥霖 end
        MonitorDataDCS monitorData = null;
        String monitorDataStr = mniMonitorBeforeBloodPressure.getMonitorData();
        if (monitorDataStr != null) {
          if (monitorDataMap.containsKey(monitorDataStr)) {
            monitorData = monitorDataMap.get(monitorDataStr);
          } else {
            monitorData = new MonitorDataDCS(monitorDataStr);
            monitorDataMap.put(monitorDataStr, monitorData);
          }
        }
        if (monitorData != null) {
          return makeBloodPressureText(
              monitorData.getByItemCd(90).getValue(), monitorData.getByItemCd(91).getValue(),
              monitorData.getByItemCd(92).getValue(), monitorData.getByItemCd(93).getValue());
        }
      }
    } catch (Exception e) {
    }
    return rtn;

  }

  /**
   * 前脈拍を返します。
   * @return
   */
  public String getPulseBefore() {
    String rtn = "";
    try {
      // モニタデータ取得
      //mod FNSI redmine 6408 劉祥霖 start
//    if (mniMonitorNowBloodPressure != null) {
      if (mniMonitorBeforeBloodPressure != null) {
        //mod FNSI redmine 6408 劉祥霖 end
        MonitorDataDCS monitorData = null;
        String monitorDataStr = mniMonitorBeforeBloodPressure.getMonitorData();
        if (monitorDataStr != null) {
          if (monitorDataMap.containsKey(monitorDataStr)) {
            monitorData = monitorDataMap.get(monitorDataStr);
          } else {
            monitorData = new MonitorDataDCS(monitorDataStr);
            monitorDataMap.put(monitorDataStr, monitorData);
          }
        }
        if (monitorData != null) {
          rtn = monitorData.getByItemCd(93).getValue();
        }
      }
    } catch (Exception e) {
      rtn = "";
    }
    return rtn;
  }

  /**
   * 後血圧(最高)を返します。
   * @return
   */
  public String getBpMaxAfter() {
    String rtn = "";
    try {
      // モニタデータ取得
      //mod FNSI-redmine6018 劉祥霖 start
      if (mniMonitorAfterBloodPressure != null) {
//    if (mniMonitorNowBloodPressure != null) {
      //mod FNSI-redmine6018 劉祥霖 end
        MonitorDataDCS monitorData = null;
        String monitorDataStr = mniMonitorAfterBloodPressure.getMonitorData();
        if (monitorDataStr != null) {
          if (monitorDataMap.containsKey(monitorDataStr)) {
            monitorData = monitorDataMap.get(monitorDataStr);
          } else {
            monitorData = new MonitorDataDCS(monitorDataStr);
            monitorDataMap.put(monitorDataStr, monitorData);
          }
        }
        if (monitorData != null) {
          rtn = monitorData.getByItemCd(90).getValue();
        }
      }
    } catch (Exception e) {
      rtn = "";
    }
    return rtn;
  }

  /**
   * 後血圧(最低)を返します。
   * @return
   */
  public String getBpMinAfter() {
    String rtn = "";
    try {
      // モニタデータ取得
      //mod FNSI-redmine6018 劉祥霖 start
      if (mniMonitorAfterBloodPressure != null) {
//    if (mniMonitorNowBloodPressure != null) {
      //mod FNSI-redmine6018 劉祥霖 end
        MonitorDataDCS monitorData = null;
        String monitorDataStr = mniMonitorAfterBloodPressure.getMonitorData();
        if (monitorDataStr != null) {
          if (monitorDataMap.containsKey(monitorDataStr)) {
            monitorData = monitorDataMap.get(monitorDataStr);
          } else {
            monitorData = new MonitorDataDCS(monitorDataStr);
            monitorDataMap.put(monitorDataStr, monitorData);
          }
        }
        if (monitorData != null) {
          rtn = monitorData.getByItemCd(91).getValue();
        }
      }
    } catch (Exception e) {
      rtn = "";
    }
    return rtn;
  }

  /**
   * 後血圧(平均)を返します。
   * @return
   */
  public String getBpAveAfter() {
    String rtn = "";
    try {
      // モニタデータ取得
      //mod FNSI-redmine6018 劉祥霖 start
      if (mniMonitorAfterBloodPressure != null) {
//    if (mniMonitorNowBloodPressure != null) {
      //mod FNSI-redmine6018 劉祥霖 end
        MonitorDataDCS monitorData = null;
        String monitorDataStr = mniMonitorAfterBloodPressure.getMonitorData();
        if (monitorDataStr != null) {
          if (monitorDataMap.containsKey(monitorDataStr)) {
            monitorData = monitorDataMap.get(monitorDataStr);
          } else {
            monitorData = new MonitorDataDCS(monitorDataStr);
            monitorDataMap.put(monitorDataStr, monitorData);
          }
        }
        if (monitorData != null) {
          rtn = monitorData.getByItemCd(92).getValue();
        }
      }
    } catch (Exception e) {
      rtn = "";
    }
    return rtn;
  }

  /**
   * 後血圧を返します。
   * @return
   */
  public String getBpAfter() {
    String rtn = "";
    try {
      // モニタデータ取得
      //mod FNSI-redmine6018 劉祥霖 start
      if (mniMonitorAfterBloodPressure != null) {
//    if (mniMonitorNowBloodPressure != null) {
      //mod FNSI-redmine6018 劉祥霖 end
        MonitorDataDCS monitorData = null;
        String monitorDataStr = mniMonitorAfterBloodPressure.getMonitorData();
        if (monitorDataStr != null) {
          if (monitorDataMap.containsKey(monitorDataStr)) {
            monitorData = monitorDataMap.get(monitorDataStr);
          } else {
            monitorData = new MonitorDataDCS(monitorDataStr);
            monitorDataMap.put(monitorDataStr, monitorData);
          }
        }
        if (monitorData != null) {
          //mod FNSI redmine 6123 6018 劉祥霖　start
          rtn=makeBloodPressureText(
            monitorData.getByItemCd(90).getValue(), monitorData.getByItemCd(91).getValue(),
            monitorData.getByItemCd(92).getValue(), monitorData.getByItemCd(93).getValue());
          if(rtn.contains("(null)")){
            rtn=rtn.replaceAll("\\(null\\)","");
          }
          return rtn;
          ////mod FNSI redmine 6123 6018 劉祥霖　end
        }
      }
    } catch (Exception e) {
    }
    return rtn;
  }

  /**
   * 後脈拍を返します。
   * @return
   */
  public String getPulseAfter() {
    String rtn = "";
    try {
      // モニタデータ取得
      //mod FNSI-redmine6018 劉祥霖 start
      if (mniMonitorAfterBloodPressure != null) {
//    if (mniMonitorNowBloodPressure != null) {
      //mod FNSI-redmine6018 劉祥霖 end
        MonitorDataDCS monitorData = null;
        String monitorDataStr = mniMonitorAfterBloodPressure.getMonitorData();
        if (monitorDataStr != null) {
          if (monitorDataMap.containsKey(monitorDataStr)) {
            monitorData = monitorDataMap.get(monitorDataStr);
          } else {
            monitorData = new MonitorDataDCS(monitorDataStr);
            monitorDataMap.put(monitorDataStr, monitorData);
          }
        }
        if (monitorData != null) {
          rtn = monitorData.getByItemCd(93).getValue();
        }
      }
    } catch (Exception e) {
      rtn = "";
    }
    return rtn;
  }


  /**
   * JSON形式文字列から指定キーの情報を取得する
   * @param jsonText JSON文字列
   * @param keyName キー情報
   * @return データ
   */
  private String getJsonNodeValue(String jsonText, String keyName) {
    String ret = "";
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl =  "JSON形式文字列から指定キーの情報を取得する";
//    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, BEFORE_LOG_FLG_INFO, mappingUrl, null,
//      null);
    // wp アプリケーションログの適正化 Add End

    try {
      JsonNode node = null;
      if (jsonNodeMap.containsKey(jsonText)) {
        node = jsonNodeMap.get(jsonText);
      } else {
        node = mapper.readTree(jsonText);
        jsonNodeMap.put(jsonText, node);
      }
      if (keyName.length() > 0) {
        String[] keyNameArray = keyName.split(",");
        for (String key : keyNameArray) {
          if ( node != null && node.has(key) ) {
            node = node != null ? node.get(key) : null;
          } else {
            node = null;
            break;
          }
        }
      }
      ret =  node != null ? node.asText() : "";
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage("API error by getJsonNodeValue : " +  e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
    }
    return ret;
  }

  /**
   * 回診データ取得
   * @return ItemResult
   *         - colValue: 回診カテゴリ名（未回診の場合は空文字列）
   *         - msOrderIndex: 回診記録マスタ並び順
   */
  private ItemResult getRoundsInfo() {
    String ret = "";
    Long msOrderIndex = null;

    // 回診記録マスタ並び順Map生成
    Map<Long, Long> selectorMap = Util.createSelectorsMap(mstSelectors, "mst_round_type");

    // 回診情報取得
    String info = ord.getRstRoundsInfo();
    if ( info != null ) {
      ret = this.getJsonNodeValue( info, "round_type_name");
      // 並び順取得
      String cd = this.getJsonNodeValue( info, "round_type_cd");
      msOrderIndex = (cd != null && !cd.isEmpty()) ? selectorMap.get(Long.valueOf(cd)) : null;
    }
    return new ItemResult(ret, msOrderIndex);
  }

  /**
   * 投与状態取得
   * @return
   */
  private String getEffectMedicineState() {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl =  "投与状態取得";
//    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, BEFORE_LOG_FLG_INFO, mappingUrl, null,
//      null);
    // wp アプリケーションログの適正化 Add End
    String ret = "";
    try {
      // 投薬情報取得
      String info = "";
      // 治療状態判定
      if (ord.getRstDialysisState().equals("0")) {
        // 未送信
        info = ord.getIndMediInfo();
      } else {
        // 条件送信済み
        info = ord.getRstMediInfo();
      }
      if( info != null && ! info.isEmpty() ) {
        Integer effectCount = 0;
        JsonNode jsonNode = null;
        if (jsonNodeMap.containsKey(info)) {
          jsonNode = jsonNodeMap.get(info);
        } else {
          jsonNode = mapper.readTree(info);
          jsonNodeMap.put(info, jsonNode);
        }
        for (int lop = 0; lop < jsonNode.size(); lop++) {
          JsonNode nodeItem = jsonNode.get(lop);
          // 実施判定
          if (nodeItem.has("effect_flg") && nodeItem.get("effect_flg").asInt() == 1) {
            effectCount++;
          }
        }
        // 表示整形：投与済み/全薬剤
        ret = String.format("%d/%d", effectCount, jsonNode.size());
      }
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage("API error by getEffectMedicine : "+ e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
    }
    return ret;
  }

  /**
   * 最新の愁訴情報を取得
   * @return
   */
  private String getLastComplaint() {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl =  "最新の愁訴情報を取得";
//    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, BEFORE_LOG_FLG_INFO, mappingUrl, null,
//      null);
    // wp アプリケーションログの適正化 Add End
    StringBuilder ret = new StringBuilder();
    try {
      // 愁訴情報取得
      String info = ord.getRstComplaintInfo();
      if( info != null && ! info.isEmpty() ) {
        // 最新日時検索
        String occurDate  = "";
//        JsonNode jsonNode = mapper.readTree(info);
        JsonNode jsonNode = null;
        if (jsonNodeMap.containsKey(info)) {
          jsonNode = jsonNodeMap.get(info);
        } else {
          jsonNode = mapper.readTree(info);
          jsonNodeMap.put(info, jsonNode);
        }
        for (int lop = 0; lop < jsonNode.size(); lop++) {
          JsonNode nodeItem = jsonNode.get(lop);
          //mod FNSI redmine 6123 6018 劉祥霖　start
          String occurDate2="";
          if (nodeItem.has("occur_date")) {
            String occurDateString = nodeItem.get("occur_date").asText();
            if (occurDateString.length() == 29) {
              // 日付判定(YYYYMMDDHHMMにて判定)
              occurDate2 = Util.localDateTimeToDateTimeString(
                Util.iso8601StringToLocalDateTime(occurDateString)
                , "uuuuMMddHHmm");
            } else if (occurDateString.length() == 19) {
              occurDate2 = occurDateString.substring(0,16);
              occurDate2 = occurDate2.replace(":", "");
              occurDate2 = occurDate2.replace("-", "");
              occurDate2 = occurDate2.replace("T", "");
            }
            if (0 > occurDate.compareToIgnoreCase(occurDate2)) {
              // 最新日付更新
              occurDate = occurDate2;
            }
            //mod FNSI redmine 6123 6018 劉祥霖 end
          }
        }
        // 情報作成
        if ( !occurDate.isEmpty()) {
          // 発生日付
          ret.append( occurDate.substring(8, 10));
          ret.append( ":" );
          ret.append( occurDate.substring(10));
          // 情報作成
          for (int lop = 0; lop < jsonNode.size(); lop++) {
            JsonNode nodeItem = jsonNode.get(lop);
            //mod FNSI redmine 6123 6018 劉祥霖 start
            String occurDate2="";
            if (nodeItem.has("occur_date")) {
              String occurDateString=nodeItem.get("occur_date").asText();
              if(occurDateString.length()==29){
                // 日付判定(YYYYMMDDHHMMにて判定)
                occurDate2 = Util.localDateTimeToDateTimeString(
                  Util.iso8601StringToLocalDateTime(occurDateString)
                  ,"uuuuMMddHHmm") ;
              }else if(occurDateString.length()==19){
                occurDate2=occurDateString.substring(0,16);
                occurDate2=occurDate2.replace(":","");
                occurDate2=occurDate2.replace("-","");
                occurDate2=occurDate2.replace("T","");
              }
              //mod FNSI redmine 6123 6018 劉祥霖 end
              if ( occurDate.equals(occurDate2)) {
                // 区切り
                ret.append("\r\n　");
                // 愁訴内容
                ret.append(nodeItem.get("complaint").isNull() ? "" : nodeItem.get("complaint").asText());
              }
            }
          }
        }
      }
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage("API error by getLastComplaint : " + e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, SERVICE_NAME.FNSI, null);


      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
    }
    return ret.toString();
  }

  /**
   * 最新の処置情報を取得
   * @return
   */
  private String getLastTreatment() {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl =  "最新の処置情報を取得";
//    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, BEFORE_LOG_FLG_INFO, mappingUrl, null,
//      null);
    // wp アプリケーションログの適正化 Add End
    StringBuilder ret = new StringBuilder();
    try {
      // 処置情報取得
      String info = ord.getRstTreatmentInfo();
      if( info != null && ! info.isEmpty() ) {
        // 最新日時検索
        String occurDate  = "";
//        JsonNode jsonNode = mapper.readTree(info);
        JsonNode jsonNode = null;
        if (jsonNodeMap.containsKey(info)) {
          jsonNode = jsonNodeMap.get(info);
        } else {
          jsonNode = mapper.readTree(info);
          jsonNodeMap.put(info, jsonNode);
        }
        for (int lop = 0; lop < jsonNode.size(); lop++) {
          if (!jsonNode.has(lop)) {
            continue;
          }
          JsonNode nodeItem = jsonNode.get(lop);
          //mod FNSI redmine 6123 6018 劉祥霖 start
          String occurDate2="";
          if (nodeItem.has("occur_date")) {
            String occurDateString=nodeItem.get("occur_date").asText();
            if(occurDateString.length()==29){
              // 日付判定(YYYYMMDDHHMMにて判定)
              occurDate2 = Util.localDateTimeToDateTimeString(
                Util.iso8601StringToLocalDateTime(occurDateString)
                ,"uuuuMMddHHmm") ;
            }else if(occurDateString.length()==19){
              occurDate2=occurDateString.substring(0,16);
              occurDate2=occurDate2.replace(":","");
              occurDate2=occurDate2.replace("-","");
              occurDate2=occurDate2.replace("T","");
            }
          }
          if ( 0 > occurDate.compareToIgnoreCase(occurDate2)) {
            // 最新日付更新
            occurDate = occurDate2;
          }
          //mod FNSI redmine 6123 6018 劉祥霖 end
        }
        // 情報作成
        if ( !occurDate.isEmpty()) {
          // 発生日付
          ret.append( occurDate.substring(8, 10));
          ret.append( ":" );
          ret.append( occurDate.substring(10));
          for (int lop = 0; lop < jsonNode.size(); lop++) {
            if (!jsonNode.has(lop)) {
              continue;
            }
            JsonNode nodeItem = jsonNode.get(lop);
            //mod FNSI redmine 6123 6018 劉祥霖 start
            String occurDate2="";
            if (nodeItem.has("occur_date")) {
              String occurDateString=nodeItem.get("occur_date").asText();
              if(occurDateString.length()==29){
                // 日付判定(YYYYMMDDHHMMにて判定)
                occurDate2 = Util.localDateTimeToDateTimeString(
                  Util.iso8601StringToLocalDateTime(occurDateString)
                  ,"uuuuMMddHHmm") ;
              }else if(occurDateString.length()==19){
                occurDate2=occurDateString.substring(0,16);
                occurDate2=occurDate2.replace(":","");
                occurDate2=occurDate2.replace("-","");
                occurDate2=occurDate2.replace("T","");
              }
              //mod FNSI redmine 6123 6018 劉祥霖 end
              if ( occurDate.equals(occurDate2)) {
                // 区切り
                ret.append("\r\n　");
                // 処置内容
                ret.append((!nodeItem.has("treat_name") || nodeItem.get("treat_name").isNull()) ? "" : nodeItem.get("treat_name").asText());
              }
            }
          }
        }
      }
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage("API error by getLastComplaint : " + e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
    }
    return ret.toString();
  }

  /**
   * 指定JsonNode内のweight1～weight5の合計を返す
   * @param node
   * @return 合計値
   */
  private String sumNodeWeight( JsonNode node ) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl =  "指定JsonNode内のweight1～weight5の合計を返す";
//    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, BEFORE_LOG_FLG_INFO, mappingUrl, null,
//      null);
    // wp アプリケーションログの適正化 Add End
    String ret = "";
    try {
      boolean flag = false;
      Long sum = 0L;
      for( int lop = 1; lop <= 5; lop++ ) {
        String key = String.format("weight_%d", lop);
        if (node.has(key)) {
          String data = node.get(key).asText();
          if( StrUtils.isNumber( data )) {
            sum += Long.parseLong(data);
            flag = true;
          }
        }
      }
      // 情報があった場合
      if ( flag ) {
        ret = sum.toString();
      }
    } catch ( Exception e ) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage("API error by getsumNodeWeight : " + e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
    }

    return ret;
  }

  /**
   * 前/後体重風袋合計取得
   * @param mode    取得対象[0：前/1：後]
   * @return
   */
  private String getTareInfo( Integer mode) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl =  "前/後体重風袋合計取得";
//    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, BEFORE_LOG_FLG_INFO, mappingUrl, null,
//      null);
    // wp アプリケーションログの適正化 Add End
    String ret = "";
    //add FNSI redmine 6123 6018 劉祥霖　start
    if(mode == 1&&
        (ord.getRstDialysisState().equals("1")||
         ord.getRstDialysisState().equals("2")||
         ord.getRstDialysisState().equals("3")||
         ord.getRstDialysisState().equals("4"))){
      return "";
    }
    //add FNSI redmine 6123 6018 劉祥霖　end
    try {
      // 風袋補正取得
      String info = "";
      // 治療状態判定
      if (ord.getRstDialysisState().equals("0")) {
        // 未送信

        // 取得対象処理
        if ( mode == 0 ) {
          // 前体重風袋
          info = ord.getIndTareInfo();
        }
      } else {
        // 条件送信済み
        info = ord.getRstTareInfo();
      }
      if( info != null && ! info.isEmpty() ) {
//        JsonNode jsonNode = mapper.readTree(info);
        JsonNode jsonNode = null;
        if (jsonNodeMap.containsKey(info)) {
          jsonNode = jsonNodeMap.get(info);
        } else {
          jsonNode = mapper.readTree(info);
          jsonNodeMap.put(info, jsonNode);
        }
        // 実績：前判定
        if( mode == 0 && jsonNode.has( "before")) {
          jsonNode = jsonNode.get("before");
        }
        // 実績：後判定
        if( mode == 1 && jsonNode.has( "after")) {
          jsonNode = jsonNode.get("after");
        }
        // weight1～weight5の合計値算出
        String sum = this.sumNodeWeight(jsonNode);
        if ( ! sum.isEmpty() ) {
          // [g]→[kg]換算
          BigDecimal dec = new BigDecimal( sum );
          dec = dec.divide(new BigDecimal(1000));
          // 表示整形：0.000
          ret = Util.getFormattedNumber(dec.toString(), 3);
        }
      }
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage("API error by getBeforeTareInfo : " + e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
    }
    return ret;
  }

  /**
   * 除水補正合計取得
   * @return
   */
  private String getOffWaterInfo() {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl =  "除水補正合計取得";
//    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, BEFORE_LOG_FLG_INFO, mappingUrl, null,
//      null);
    // wp アプリケーションログの適正化 Add End
    String ret = "";
    try {
      // 除水補正取得
      String info = "";
      // 治療状態判定
      if (ord.getRstDialysisState().equals("0")) {
        // 未送信
        info = ord.getIndOffWaterInfo();
      } else {
        // 条件送信済み
        info = ord.getRstOffWaterInfo();
      }
      if( info != null && ! info.isEmpty() ) {
//        JsonNode jsonNode = mapper.readTree(info);
        JsonNode jsonNode = null;
        if (jsonNodeMap.containsKey(info)) {
          jsonNode = jsonNodeMap.get(info);
        } else {
          jsonNode = mapper.readTree(info);
          jsonNodeMap.put(info, jsonNode);
        }
        // weight1～weight5の合計値算出
        String sum = this.sumNodeWeight(jsonNode);
        if ( ! sum.isEmpty() ) {
          // [g]→[kg]換算
          BigDecimal dec = new BigDecimal( sum );
          dec = dec.divide(new BigDecimal(1000));
          // 表示整形：0.000
          ret = Util.getFormattedNumber(dec.toString(), 3);
        }
      }
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage("API error by getBeforeTareInfo : " +  e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
    }
    return ret;
  }

  /**
   * 最後にCTRに値がセットされた患者個人身体情報を取得
   * @param physicalInfo
   * @param baseDate yyyyMMdd
   * @return
   */
  private PhysicalInfoItem lastCTRMeasure(PhysicalInfo physicalInfo, String baseDate) {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl =  "最後にCTRに値がセットされた患者個人身体情報を取得";
//    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, BEFORE_LOG_FLG_INFO, mappingUrl, null,
//      null);
    // wp アプリケーションログの適正化 Add End


    LocalDateTime baseDateTime;
    if (Objects.isNull(baseDate)) {
      baseDateTime = LocalDate.now().plusDays(1).atTime(0, 0);
    } else {
      try {
        LocalDate localBaseDate = LocalDate.parse(baseDate, DateTimeFormatter.ofPattern("uuuuMMdd"));
        baseDateTime = localBaseDate.plusDays(1).atTime(0, 0);
      } catch (Exception ex) {
        baseDateTime = LocalDate.now().plusDays(1).atTime(0, 0);
      }
    }

    // 全記録格納フィールドを測定日時[ExaminDate]で降順ソート
    List<PhysicalInfoItem> records = physicalInfo.getAllRecords();
    // mod #11312 【たくしん会】治療状況リスト・マップの表示項目DWの参照データ不正 zkm start
//    records.sort((a, b) -> {
//      String examDateA = a.getExamDate();
//      String examDateB = b.getExamDate();
//      if (examDateA.length() < 11) {
//        examDateA += "T00:00:00.000+09:00";
//      }
//      if (examDateB.length() < 11) {
//        examDateB += "T00:00:00.000+09:00";
//      }
//      Date A = DateTimeUtils.dateStringToDate_iso8601(examDateA);
//      Date B = DateTimeUtils.dateStringToDate_iso8601(examDateB);
//      return B.compareTo(A);
//    });
//
//    for (PhysicalInfoItem record : records) {
//      LocalDateTime examDate;
//      String examDateStr = record.getExamDate();
//      if (examDateStr.length() < 11) {
//        examDateStr += "T00:00:00.000+09:00";
//      }
//      try {
//        Date A = DateTimeUtils.dateStringToDate_iso8601(examDateStr);
//        Instant instant = A.toInstant();
//        examDate = LocalDateTime.ofInstant(instant, ZoneId.systemDefault());
//      } catch (Exception e) {
//
////        EventLogMessage eventLogMessage = new EventLogMessage();
////        eventLogMessage.setLogMessage(e.getLocalizedMessage());
////        logService.log(LogLevel.DEBUG, eventLogMessage,  FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, SERVICE_NAME.REMS, null);
//        // 変換できない日付は未来にして対象外とする
//        examDate = LocalDateTime.now().plusYears(10);
//
//        // wp アプリケーションログの適正化 Add Start
//        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
//        // wp アプリケーションログの適正化 Add End
//      }
//      if (examDate.isAfter(baseDateTime) || examDate.isEqual(baseDateTime)) {
//        // 基準日よりも後に登録したデータは無視
//        continue;
//      }
//      if (record.getCtr() != null && !record.getCtr().isEmpty() && !Objects.equals(record.getCtr(), "null")) {
//        // 最後にCTRに値がセットされている時点のレコード
//        return record;
//      }
//    }
//    return null;
    final LocalDateTime base = baseDateTime;
    return records
      .stream()
      .peek(record -> {
        if (StringUtils.hasText(record.getExamDate()) && record.getExamDate().length() < 11)
          record.setExamDate(record.getExamDate() + "T00:00:00.000+09:00");
      })
      .sorted(this::compareByExamDateDesc)
      .filter(record -> {
        try {
          return StringUtils.hasText(record.getCtr()) && !Objects.equals(record.getCtr(), "null")
            && base.isAfter(
            LocalDateTime.ofInstant(
              DateTimeUtils.dateStringToDate_iso8601(record.getExamDate()).toInstant()
              , ZoneId.systemDefault())
          );
        } catch (Exception e) {
          logEventUtils
            .resourceLogOutput(
              getClassName()
              , getMethodName()
              , FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, AFTER_LOG_FLG_ERROR
              , mappingUrl + ": " + e.getMessage()
              , ord.getFacilityCd()
              , null);
          return false;
        }
      })
      .findFirst()
      .orElse(null);
    // mod #11312 【たくしん会】治療状況リスト・マップの表示項目DWの参照データ不正 zkm end
  }

  /**
   * 「CTR」を取得します。
   * @return CTRの文字列。患者基本情報がnullの場合空文字列を返す。
   */
  private String getCTR() {
    String ret = "";
    try {
      // 治療状態判定
      if (ord.getRstDialysisState().equals("0")) {
        // 未送信
        if (patUnique != null) {
          // 患者基本情報から身体情報を取得する
          PhysicalInfo physicalInfo = new PhysicalInfo(patUnique.getPhysical_info());
          PhysicalInfoItem dwItem = lastCTRMeasure(physicalInfo, ord.getTreatDate());
          // 身体情報からCTRを取得し戻り値にセット
          ret = dwItem.getCtr();
        }
      } else {
        // 条件送信以降
        // 体重情報取得
        String info = ord.getRstWeightInfo();
        if( info != null ) {
            ret = this.getJsonNodeValue( info, "ctr");
        }
      }
    } catch (Exception e) {
    }
    return ret;
  }


  /**
   * 「VA名」を取得
   * @return ItemResult
   *         - colValue: VA名
   *         - msOrderIndex: VAマスタ並び順
   */
  private ItemResult getVAName() {
    String ret = "";
    Long msOrderIndex = null;

    // VAマスタ並び順Map生成
    Map<Long, Long> selectorMap = Util.createSelectorsMap(mstSelectors, "mst_va");

    // wp アプリケーションログの適正化 Add
    String mappingUrl="「VA名」を取得";

    try {
      // 治療状態判定
      if (ord.getRstDialysisState().equals("0")) {

          // wp アプリケーションログの適正化 Add
//          logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, "条件未送信の場合：" + mappingUrl, ord.getFacilityCd(), null);

        // 未送信
        // 治療条件情報取得
        // mod #6746 取得データ方式の変更 查 start
//        CondInfo condInfo = condInfoService.createCondInfo(ord.getIndCondInfo());
        CondInfo condInfo = indCondInfoMap.get(ord.getIndCondInfo());
//        ret = condInfoService.findVaName(condInfo.getVa().getValue());
        if (condInfo != null) {
          ret = mstVaMap.get(Integer.valueOf(condInfo.getVa().getValue()));
          // 並び順取得
          String cd = condInfo.getVa().getValue();
          msOrderIndex = (cd != null && !cd.isEmpty()) ? selectorMap.get(Long.valueOf(cd)) : null;
        }
        // mod #6746 取得データ方式の変更 查 end
      } else {
          // wp アプリケーションログの適正化 Add
//          logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, "条件送信済みの場合：" +mappingUrl, ord.getFacilityCd(), null);
        // 条件送信済み
        // 治療条件情報取得
        // mod #6746 取得データ方式の変更 查 start
//        CondInfo condInfo = condInfoService.createCondInfo(ord.getRstCondInfo());
        CondInfo condInfo = rstCondInfoMap.get(ord.getRstCondInfo());
        // mod #6746 取得データ方式の変更 查 end
        if (condInfo != null) {
          ret = condInfo.getVa().getName();
          // 並び順取得
          String cd = condInfo.getVa().getValue();
          msOrderIndex = (cd != null && !cd.isEmpty()) ? selectorMap.get(Long.valueOf(cd)) : null;
        }
      }
    } catch (Exception e) {
        // wp アプリケーションログの適正化 Add Start
       logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl + ": " + e.getMessage(), ord.getFacilityCd(),
         e.getMessage());
       // wp アプリケーションログの適正化 Add End
    }
//    // wp アプリケーションログの適正化 Add Start
//    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, ord.getFacilityCd(), null);
//    // wp アプリケーションログの適正化 Add End

    return new ItemResult(ret, msOrderIndex);
  }

  /**
   * 「ダイアライザー」を取得
   * ※メーカー[型式]
   * @return ItemResult
   *         - colValue: ダイアライザ名
   *         - msOrderIndex: ダイアライザマスタ並び順
   */
  private ItemResult getDialyzerName() {
    String ret = "";
    Long msOrderIndex = null;

    // ダイアライザマスタ並び順Map生成
    Map<Long, Long> selectorMap = Util.createSelectorsMap(mstSelectors, "mst_dialyzer");

    // wp アプリケーションログの適正化 Add
    String mappingUrl="「ダイアライザー」を取得";

    try {
      // 治療状態判定
      if (ord.getRstDialysisState().equals("0")) {

          // wp アプリケーションログの適正化 Add
//        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, "条件未送信の場合：" + mappingUrl, ord.getFacilityCd(), null);

        // 未送信
        // 治療条件情報取得
        // mod #6746 取得データ方式の変更 查 start
//        CondInfo condInfo = condInfoService.createCondInfo(ord.getIndCondInfo());
        CondInfo condInfo = indCondInfoMap.get(ord.getIndCondInfo());
//        ret = condInfoService.findDialyzerName(condInfo.getDialyzer().getValue());
        if (condInfo != null && condInfo.getDialyzer().getValue() != null
          && StrUtils.isNumber(condInfo.getDialyzer().getValue())) {
          MstDialyzer mstDialyzer = mstDialyzerMap.get(Integer.parseInt(condInfo.getDialyzer().getValue()));

          ret = String.format("%s[%s]", mstDialyzer.getMaker(), mstDialyzer.getModelNumber());
          // 並び順取得
          String cd = condInfo.getDialyzer().getValue();
          msOrderIndex = (cd != null && !cd.isEmpty()) ? selectorMap.get(Long.valueOf(cd)) : null;
        }
        // mod #6746 取得データ方式の変更 查 end
      } else {
          // wp アプリケーションログの適正化 Add
//          logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, "条件送信済みの場合：" +mappingUrl, ord.getFacilityCd(), null);
        // 条件送信済み
        // 治療条件情報取得
        // mod #6746 取得データ方式の変更 查 start
//        CondInfo condInfo = condInfoService.createCondInfo(ord.getRstCondInfo());
        CondInfo condInfo = rstCondInfoMap.get(ord.getRstCondInfo());
        if (condInfo == null) {
          return new ItemResult(ret, msOrderIndex);
        }
        // mod #6746 取得データ方式の変更 查 end
        // add FNSI-画面表示null 付 start
        String name1 = "";
        String name2 = "";
        if (condInfo.getDialyzer().getName2() != null && !Objects.equals(condInfo.getDialyzer().getName2(), "null")) {
          name2 = condInfo.getDialyzer().getName2();
        } else {
          name2 = "";
        }
        if (condInfo.getDialyzer().getName() != null && !Objects.equals(condInfo.getDialyzer().getName(), "null")) {
          name1 = condInfo.getDialyzer().getName();
        } else {
          name1 = "";
        }
        if (Objects.equals("", name1) && Objects.equals("", name2)) {
          ret = "";
        } else {
          ret = String.format("%s[%s]", name2, name1);
          // 並び順取得
          String cd = condInfo.getDialyzer().getValue();
          msOrderIndex = (cd != null && !cd.isEmpty()) ? selectorMap.get(Long.valueOf(cd)) : null;
        }
//        ret = String.format("%s[%s]",condInfo.getDialyzer().getName2(), condInfo.getDialyzer().getName());
        // add FNSI-画面表示null 付 end
      }
    } catch (Exception e) {
        // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl + ": " + e.getMessage(), ord.getFacilityCd(),
         e.getMessage());
       // wp アプリケーションログの適正化 Add End
    }
    // wp アプリケーションログの適正化 Add Start
//    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, ord.getFacilityCd(), null);
    // wp アプリケーションログの適正化 Add End
    return new ItemResult(ret, msOrderIndex);
  }

  /**
   * 指定キー番号の値を取得
   * @param key データのキー番号
   * @return
   */
  private String getValue( int key ) {
    String ret = "";
    String unit = "";

    List<Integer> case1List = new ArrayList<>();
    case1List.add(26);  // 抗凝固剤ワンショット量
    case1List.add(27);  // 抗凝固剤持続速度
    case1List.add(28);  // 抗凝固剤持続総量
    List<Integer> case2List = new ArrayList<>();
    case2List.add(17);  // 透析液使用数
    case2List.add(22);  // 補液使用数

    // wp アプリケーションログの適正化 Add
    String mappingUrl="指定キー番号の値を取得";
    try {
      // 治療状態判定
      if (ord.getRstDialysisState().equals("0")) {
          // wp アプリケーションログの適正化 Add
//          logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, "条件未送信の場合：" + mappingUrl, ord.getFacilityCd(), null);

        // 未送信
        // 治療条件情報取得
        // mod #6746 取得データ方式の変更 查 start
//        CondInfo condInfo = condInfoService.createCondInfo(ord.getIndCondInfo());
        CondInfo condInfo = indCondInfoMap.get(ord.getIndCondInfo());
        // mod #6746 取得データ方式の変更 查 end
        // mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 start
        if (condInfo != null) {
          ret = condInfo.getItem((short) key).getValue();
          MasterCacheHandler masterCacheHandler = MasterCacheHandler.get();
          CondInfoItem condInfoItem = new CondInfoItem();
          Boolean inOrNot = false;
          if (case1List.contains(key)) {
            condInfoItem = condInfo.getItem((short) 25);
            inOrNot = true;
          } else if (case2List.contains(key)) {
            condInfoItem = condInfo.getItem((short) 15);
            inOrNot = true;
          }
          if(inOrNot){
            String mediCd = condInfoItem.getValue();
            int decPoint = 0;
            if (condInfoItem.getMedicineType() == 1) {
              // 通常薬剤
              if (case1List.contains(key)) {
                MstMedicine mstMedicine = masterCacheHandler.getMstMedicineByCd(Integer.valueOf(mediCd));
                decPoint = mstMedicine.getUnitDecimalPoint();
                unit = mstMedicine.getUnit();
              } else if (case2List.contains(key)) {
                MstMedicine mstMedicine = masterCacheHandler.getMstMedicineByCd(Integer.valueOf(mediCd));
                decPoint = mstMedicine.getUnitDecimalPointSecond();
                unit = mstMedicine.getUnit();
              }
            } else if (condInfoItem.getMedicineType() == 2) {
              // 調整薬剤
              MstMedicineMix mstMedicineMix = masterCacheHandler.getMstMedicineMixByCd(Integer.valueOf(mediCd));
              decPoint = mstMedicineMix.getUnitDecimalPoint();
              unit = mstMedicineMix.getUnit();
            }
            BigDecimal decimal = new BigDecimal(ret);
            decimal = decimal.stripTrailingZeros();
            int valPointLength = 0;
            String numberString = decimal.toPlainString();
            int decimalIndex = numberString.indexOf('.');
            if (decimalIndex != -1) {
              valPointLength = numberString.length() - decimalIndex - 1;
            }
            if (valPointLength > decPoint || decPoint == 0) {
              ret = numberString;
            } else {
              String fmt = "0" + "." + "0".repeat(decPoint);
              DecimalFormat df = new DecimalFormat(fmt);
              ret = df.format(decimal);
            }

            // 単位登録ありの場合、単位を連結
            if (unit != null) {
              // 27: 抗凝固剤持続速度の場合は"/h"を追加、そうでなければunitだけを連結
              ret += " " + unit + ((key == 27) ? "/h" : "");
            }
          }
        }
        // mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 end
      } else {
          // wp アプリケーションログの適正化 Add
//          logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, "送信済みの場合：" + mappingUrl, ord.getFacilityCd(), null);

        // 条件送信済み
        // 治療条件情報取得
        // mod #6746 取得データ方式の変更 查 start
//        CondInfo condInfo = condInfoService.createCondInfo(ord.getRstCondInfo());
        CondInfo condInfo = rstCondInfoMap.get(ord.getRstCondInfo());
        // mod #6746 取得データ方式の変更 查 end
        if (condInfo != null) {
          ret = condInfo.getItem((short)key).getValue();
          unit = condInfo.getItem((short) key).getUnit();
          if (case1List.contains(key) || case2List.contains(key)) {
            // 単位登録ありの場合、単位を連結
            // 27: 抗凝固剤持続速度の場合、単位なしでも/hが実績の治療条件に登録されるので"/h"は表示しない
            if (unit != null && !"/h".equals(unit)) {
              ret += " " + unit;
            }
          }
        }
      }
    } catch (Exception e) {
        // wp アプリケーションログの適正化 Add Start
       logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl + ": " + e.getMessage(), ord.getFacilityCd(),
         e.getMessage());
       // wp アプリケーションログの適正化 Add End
    }
    // wp アプリケーションログの適正化 Add Start
//    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, ord.getFacilityCd(), null);
    // wp アプリケーションログの適正化 Add End
    return ret;
  }

  /**
   * 指定キーの医療材料名を取得
   * @param key
   * @return ItemResult
   *         - colValue: 医療材料名
   *         - msOrderIndex: 医療材料マスタ並び順
   */
  private ItemResult getEquipName( int key ) {
    String ret = "";
    Long msOrderIndex = null;

    // 医療材料マスタ並び順Map生成
    Map<Long, Long> selectorMap = Util.createSelectorsMap(mstSelectors, "mst_equipment");

    // wp アプリケーションログの適正化 Add
    String mappingUrl="医療材料名を取得";
    try {
      // 治療状態判定
      if (ord.getRstDialysisState().equals("0")) {
          // wp アプリケーションログの適正化 Add
//         logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, "条件未送信の場合：" + mappingUrl, ord.getFacilityCd(), null);
        // 未送信
        // 治療条件情報取得
        // mod #6746 取得データ方式の変更 查 start
//        CondInfo condInfo = condInfoService.createCondInfo(ord.getIndCondInfo());
        CondInfo condInfo = indCondInfoMap.get(ord.getIndCondInfo());
        if (condInfo == null) {
          return new ItemResult(ret, msOrderIndex);
        }
        // 医療材料検索
        String equipCd = condInfo.getItem((short)key).getValue();
//        HashMap<String, String> info = condInfoService.findEquipmentInfo(equipCd);
//        if ( 0 < info.size() ) {
//          // 名前取得
//          ret = info.get("name");
//        }
        /* modify by chamaojia 2024-03-03 [10303、10304] add null value judgment --start */
        if (org.apache.commons.lang3.StringUtils.isNotEmpty(equipCd)) {
          ret = mstEquipmentMap.get(Integer.parseInt(equipCd));
          // 並び順取得
          msOrderIndex = (equipCd != null && !equipCd.isEmpty()) ? selectorMap.get(Long.valueOf(equipCd)) : null;
        }
        /* modify by chamaojia 2024-03-03 [10303、10304] add null value judgment --end */
        // mod #6746 取得データ方式の変更 查 end
      } else {
          // wp アプリケーションログの適正化 Add
//          logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, "条件送信済みの場合：" + mappingUrl, ord.getFacilityCd(), null);

        // 条件送信済み
        // 治療条件情報取得
        // mod #6746 取得データ方式の変更 查 start
//        CondInfo condInfo = condInfoService.createCondInfo(ord.getRstCondInfo());
        CondInfo condInfo = rstCondInfoMap.get(ord.getRstCondInfo());
        if (condInfo == null) {
          return new ItemResult(ret, msOrderIndex);
        }
        // mod #6746 取得データ方式の変更 查 end
        ret = condInfo.getItem((short)key).getName();
        // 並び順取得
        String equipCd = condInfo.getItem((short)key).getValue();
        msOrderIndex = (equipCd != null && !equipCd.isEmpty()) ? selectorMap.get(Long.valueOf(equipCd)) : null;
      }
      if (ret != null ) {
      }
    } catch (Exception e) {
        // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl + ": " + e.getMessage(), ord.getFacilityCd(), e.getMessage());
        // wp アプリケーションログの適正化 Add End
    }
    return new ItemResult(ret, msOrderIndex);
  }

  /**
   * 指定キーの薬剤/調整薬剤名を取得
   * @param key
   * @return ItemResult
   *         - colValue: 薬剤/調整薬剤名
   *         - msOrderIndex: 薬剤/調整薬剤マスタ並び順
   */
  private ItemResult getMedicineName( int key ) {
    String ret = "";
    Long msOrderIndex = null;

    // 薬剤マスタ並び順Map生成
    Map<Long, Long> selectorMap = Util.createSelectorsMap(mstSelectors, "mst_medicine");
    // 調整薬剤マスタ並び順Map生成
    Map<Long, Long> selectorMapMix = Util.createSelectorsMap(mstSelectors, "mst_medicine_mix");

    // wp アプリケーションログの適正化 Add
    String mappingUrl="調整薬剤名を取得";
    try {
      // 治療状態判定
      if (ord.getRstDialysisState().equals("0")) {
          // wp アプリケーションログの適正化 Add
//         logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, "条件未送信の場合：" + mappingUrl, ord.getFacilityCd(), null);

        // 未送信
        // 治療条件情報取得
        // mod #6746 取得データ方式の変更 查 start
//        CondInfo condInfo = condInfoService.createCondInfo(ord.getIndCondInfo());
        CondInfo condInfo = indCondInfoMap.get(ord.getIndCondInfo());
        if (condInfo == null) {
          return new ItemResult(ret, msOrderIndex);
        }
        // mod #6746 取得データ方式の変更 查 end
        // 薬剤/調整薬剤検索
        // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
        //String mediType = condInfo.getItem((short)key).getMedicineType();
        String mediType = condInfo.getItem((short)key).getMedicineType().toString();
        // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
        String mediCd = condInfo.getItem((short)key).getValue();
        // mod NULL値判定の追加 查 start
        if (!StringUtils.isEmpty(mediType)
          && !StringUtils.isEmpty(mediCd) ) {
        // mod NULL値判定の追加 查 end
          HashMap<String, String> info = condInfoService.findMedicineInfo(mediType, mediCd);
          if ( 0 < info.size() ) {
            // 名前取得
            ret = info.get("name");
            // 並び順取得
            Map<Long, Long> targetMap = Objects.equals(mediType, "2") ? selectorMapMix : selectorMap;
            msOrderIndex = (mediCd != null && !mediCd.isEmpty()) ? targetMap.get(Long.valueOf(mediCd)) : null;
            // 調整薬剤マスタの場合は加算。画面ソート時に薬剤マスタ前方、調整薬剤マスタ後方にする
            if (msOrderIndex != null && Objects.equals(mediType, "2")) {
                msOrderIndex = msOrderIndex + 300000L;
            }
          }
        }
      } else {
          // wp アプリケーションログの適正化 Add
//          logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, "条件送信済みの場合：" + mappingUrl, ord.getFacilityCd(), null);

        // 条件送信済み
        // 治療条件情報取得
        // mod #6746 取得データ方式の変更 查 start
//        CondInfo condInfo = condInfoService.createCondInfo(ord.getRstCondInfo());
        CondInfo condInfo = rstCondInfoMap.get(ord.getRstCondInfo());
        if (condInfo == null) {
          return new ItemResult(ret, msOrderIndex);
        }
        // mod #6746 取得データ方式の変更 查 end
        ret = condInfo.getItem((short)key).getName();
        String mediType = condInfo.getItem((short)key).getMedicineType().toString();
        String mediCd = condInfo.getItem((short)key).getValue();
        if (!StringUtils.isEmpty(mediType)
            && !StringUtils.isEmpty(mediCd) ) {
          // 並び順取得
          Map<Long, Long> targetMap = Objects.equals(mediType, "2") ? selectorMapMix : selectorMap;
          msOrderIndex = (mediCd != null && !mediCd.isEmpty()) ? targetMap.get(Long.valueOf(mediCd)) : null;
          // 調整薬剤マスタの場合は加算。画面ソート時に薬剤マスタ前方、調整薬剤マスタ後方にする
          if (msOrderIndex != null && Objects.equals(mediType, "2")) {
              msOrderIndex = msOrderIndex + 300000L;
          }
        }
      }
      if (ret != null ) {
      }
    } catch (Exception e) {
        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl + ": " + e.getMessage(), ord.getFacilityCd(), null);
        // wp アプリケーションログの適正化 Add End
    }
    return new ItemResult(ret, msOrderIndex);

  }

  /**
   * 1：使用する/0：使用しないを取得
   * @param value
   * @return
   */
  private String getUseText( String value ) {
    String ret = "";
    if( Objects.equals(value, "0")) {
      ret = "使用しない";
    } else if( Objects.equals(value, "1")) {
      ret = "使用する";
    }
    return ret;
  }

  /**
   * 1：入/0：切を取得
   * @param value
   * @return
   */
  private String getOnOffText( String value ) {
    String ret = "";
    if( Objects.equals(value, "0")) {
      ret = "切";
    } else if( Objects.equals(value, "1")) {
      ret = "入";
    }
    return ret;
  }


  /**
   * 経過時間[分]
   * @return
   */
  public Long getElapsedTime() {
    Long ret = null;

    try {
      // 治療状況判定
      if ( 0 < Objects.compare(ord.getRstDialysisState(), "2", Comparator.naturalOrder() )) {
        // 治療中の場合

        // オフライン装置判定
        if ( this.isOffline()) {
          // 現在時刻-治療開始時刻により経過時間を算出

          // 開始日時取得
          LocalDateTime startDateTime = this.getTreatStartTime();
          if ( startDateTime != null ) {
            Long startTime = Timestamp.valueOf(startDateTime).getTime();

            // 現在時刻
            Date now = new Date();
            Long nowTime = now.getTime();

            // 終了日時取得
            Timestamp endDateTime = ord.getRstEndDate();
            if ( endDateTime != null ) {
              nowTime = endDateTime.getTime();
            }

            // 経過時間(ミリ秒→分換算)
            ret = (nowTime - startTime) / (1000 * 60);
          }
        } else {
          // オンライン装置

          if (mniMonitor != null) {
            // モニタデータ取得
            MonitorDataDCS monitorData = null;
            String monitorDataStr = mniMonitor.getMonitorData();
            if (monitorDataStr != null) {
              if (monitorDataMap.containsKey(monitorDataStr)) {
                monitorData = monitorDataMap.get(monitorDataStr);
              } else {
                monitorData = new MonitorDataDCS(monitorDataStr);
                monitorDataMap.put(monitorDataStr, monitorData);
              }
            }
            // 残り時間
            MonitorDataItem remainItem = monitorData.getByItemCd(4);
            String val = remainItem != null ? remainItem.getValue() : "";
            // データ判定
            if (StrUtils.isNumber(val)) {
              // モニタデータから取得できた場合
              // 残り時間(透析完了)を数値化
              Long time = Long.parseLong(val);

              // 透析時間[分]
              Long condTime  = this.getTreatTime().longValue();

              // 経過時間(治療時間-残り時間)
              ret = condTime - time;
            }
          }
        }
      }
    } catch (Exception ex) {
    }
    return ret;
  }
  /**
   * 残り時間[分]
   * @return
   */
  public Long getRemainTime() {
    Long ret = null;

    try {
      // 治療状況判定
      if ( 0 < Objects.compare(ord.getRstDialysisState(), "2", Comparator.naturalOrder() )) {
        // 治療中の場合

        // オフライン装置判定
        if ( this.isOffline()) {
          // 透析時間[分]
          Long condTime  = this.getTreatTime().longValue();

          // 経過時間
          Long time = this.getElapsedTime();

          // 残り時間(治療時間-経過時間)
          ret = condTime - time;
        } else {
          // オンライン装置

          if (mniMonitor != null) {
            // モニタデータ取得
            MonitorDataDCS monitorData = null;
            String monitorDataStr = mniMonitor.getMonitorData();
            if (monitorDataStr != null) {
              if (monitorDataMap.containsKey(monitorDataStr)) {
                monitorData = monitorDataMap.get(monitorDataStr);
              } else {
                monitorData = new MonitorDataDCS(monitorDataStr);
                monitorDataMap.put(monitorDataStr, monitorData);
              }
            }
            // 残り時間
            MonitorDataItem remainItem = monitorData.getByItemCd(4);
            String val = remainItem != null ? remainItem.getValue() : "";
            // データ判定
            if (StrUtils.isNumber(val)) {
              // モニタデータから取得できた場合
              // 残り時間(透析完了)を数値化
              ret = Long.parseLong(val);
            }
          }
        }
      }
    } catch (Exception ex) {
    }
    return ret;
  }
  /**
   * 進捗率[%]
   *  経過時間 ÷ 透析予定時間 ×100
   * @return
   */
  private String getProgressRate() {
    String ret = "";
    try {

      // 治療状況判定
      if ( 0 < Objects.compare(ord.getRstDialysisState(), "2", Comparator.naturalOrder() )) {
        // 治療中の場合

        // 透析時間[分]
//        Long condTime  = this.getTreatTime().longValue();
        BigDecimal condTime = this.getTreatTime() == null || this.getTreatTime() == 0
          ? null : BigDecimal.valueOf(this.getTreatTime());
        // 経過時間[分]
//        Long remainTime = this.getElapsedTime();
        BigDecimal remainTime = this.getElapsedTime() == null ? BigDecimal.ZERO : BigDecimal.valueOf(this.getElapsedTime());
        // (100 * 経過時間 / 透析予定時間)[%]
//        Integer rate = Math.round(100 * remainTime / condTime);
//        ret = rate.toString();
        BigDecimal rate = condTime == null ?
          BigDecimal.ZERO
          : remainTime.divide(condTime, 2, RoundingMode.HALF_UP).multiply(BigDecimal.valueOf(100));
        // #9312 進捗率 補足パーセント
        ret = rate.toPlainString();
      }
    } catch( Exception ex ) {
    }
    return ret;
  }


  /**
   * 項目コード指定で値を取得します。
   * @param itemCd  項目コード
   * @param dateFormt 日付フォーマット "yyyy/MM/dd HH:mm" or "HH:mm"
   * @return    取得したデータ
   */
  public ItemResult getByItemCd(Integer itemCd, String dateFormat) {

    // 日付フォーマットをDataTimeFormatterの日付時刻書式文字列に変換
    String dataTimeFormatter = dateFormat.replace("yyyy", "uuuu");

    // wp アプリケーションログの適正化 Add Start
    //del 治療状況リスト画面に内容が表示されない　劉祥霖　start
//    String mappingUrl =  "項目コード指定で値を取得します";
//    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, BEFORE_LOG_FLG_INFO, mappingUrl, null,
//      null);
    //del 治療状況リスト画面に内容が表示されない　劉祥霖　end
    // wp アプリケーションログの適正化 Add End
    String rtn = "";
    String wk = "";
    Long msOrderIndex = -1L; // マスタ並び順未使用項目の場合: -1L、使用項目の場合: -1L以外を設定
    try {
      switch (itemCd) {
      case 4:   // DW
        rtn = this.getDW();
        break;
      case 5:   // DWから
        rtn = this.getDiffBetweenBeforeWeightAndDW();
        break;
      case 6:   // 目標体重
        rtn = this.getTargetWeight();
        break;
      case 7:   // 目標体重から
        rtn = this.getDiffBetweenBeforeWeightAndTargetWeight();
        break;
      case 8:   // 透析開始
        rtn = Util.localDateTimeToDateTimeString(this.getTreatStartTime(), dataTimeFormatter);
        break;
      case 9:   //終了予測
        rtn = Util.localDateTimeToDateTimeString(this.getEstimateEndTime(), dataTimeFormatter);
        break;
      case 10:  // 終了予測(除水完了)
        rtn = Util.localDateTimeToDateTimeString(this.getEstimateEndTimeWaterRemoveFinish(), dataTimeFormatter);
        break;
      case 11:  // 終了予測(透析終了)
        rtn = Util.localDateTimeToDateTimeString(this.getEstimateEndTimeDialysisFinish(), dataTimeFormatter);
        break;
      case 112: // 終了予測(補液完了)
        rtn = Util.localDateTimeToDateTimeString(this.getEstimateEndTimeFluidReplacemantFinish(), dataTimeFormatter);
        break;
      case 13:  // 治療時間
        // HH:MM形式文字列にして戻す
        rtn = Util.ElapsedMinutesToHHMM(this.getTreatTime());
        break;
      case 15:  // 遅れ時間
        // HH:MM形式文字列にして戻す
        rtn = Util.ElapsedMinutesToHHMM(this.getDelayTime());
        break;
      case 17:  // 前血圧(最高)
        rtn = this.getBpMaxBefore();
        break;
      case 18:  // 前血圧(最低)
        rtn = this.getBpMinBefore();
        break;
      case 19:  // 前血圧(平均)
        rtn = this.getBpAveBefore();
        break;
      case 20:  // 前血圧
        rtn = this.getBpBefore();
        break;
      case 21:  // 前脈拍
        rtn = this.getPulseBefore();
        break;
      case 22:  // 現在血圧
        rtn = this.getNowBloodPressure();
        break;
      case 38:  // 前体重-後体重
        rtn = this.getDiffBetweenBeforeWeightAndAfterWeight();
        break;
      case 39:  // 予想引き残し
        rtn = this.getEstimateWaterRemain();
        break;
      case 40:  // 引き残し
        rtn = this.getWaterRemain();
        break;
      case 41:  // 後血圧(最高)
        rtn = this.getBpMaxAfter();
        break;
      case 42:  // 後血圧(最低)
        rtn = this.getBpMinAfter();
        break;
      case 43:  // 後血圧(平均)
        rtn = this.getBpAveAfter();
        break;
      case 44:  // 後血圧
        rtn = this.getBpAfter();
        break;
      case 45:  // 後脈拍
        rtn = this.getPulseAfter();
        break;
      case 49:  // 達成率
        rtn = this.getAchievementRate();
        break;
      case 50:  // 患者確認
        rtn = this.getCondConfirm();
        break;
      case 52:  // 終了予定
        rtn = Util.localDateTimeToDateTimeString(this.getEndTimePlan(), dataTimeFormatter);
        break;
      case 53:  // 前回後体重
        rtn = this.getLastAfterWeight();
        break;
      case 54:  // 増加量
        rtn = this.getIncrement();
        break;
      case 55:  // 増加率
        rtn = this.getIncrementRate();
        break;
      case 58:  // 進捗率
        rtn = this.getProgressRate();
        break;
      case 60:  // 治療日
        rtn = ord.getTreatDate().substring(0, 4) + "/" + ord.getTreatDate().substring(4, 6)+ "/" + ord.getTreatDate().substring(6);
        break;
      case 61:  // クール
        if (ord.getRstDialysisState() == null ||
        ord.getRstDialysisState().isEmpty() ||
        ord.getRstDialysisState().equals("0")) {
          // 予定
          rtn = ord.getIndMstKurName();
        } else {
          // 実績
          rtn = ord.getRstKurName();
        }
        break;
      case 62:  // 回診状態
        if (ord.getRstDialysisState() != null
            && 0<= ord.getRstDialysisState().compareTo( "1" )) {
          ItemResult itemResult62 = this.getRoundsInfo();
          if( itemResult62.colValue().isEmpty() ) {
            rtn = "未";
          } else {
            rtn = "済";
          }
        }
        break;
      case 63:  // 回診データ
        if (ord.getRstDialysisState() != null
          && 0<= ord.getRstDialysisState().compareTo( "1" )) {
          ItemResult itemResult63 = this.getRoundsInfo();
          rtn = itemResult63.colValue();
          msOrderIndex = itemResult63.msOrderIndex();
          if ( rtn.isEmpty() ) {
            rtn = "未回診";
            msOrderIndex = -99L; // 画面でソート実行時に未回診前方にソートする
          }
        }
        break;
      case 64:  // 投与状況
        rtn = this.getEffectMedicineState();
        break;
      case 65:  // 観察記録件数
        if (ord.getRstDialysisState() != null
        && 0<= ord.getRstDialysisState().compareTo( "1" )) {
          rtn = this.patEventCount.toString();
        }
        break;
      case 66:  // 最新愁訴
        rtn = this.getLastComplaint();
        break;
      case 67:  // 最新処置
        rtn = this.getLastTreatment();
        break;
      case 68:  // CTR
        rtn = this.getCTR();
        break;
      case 69:  // 前体重風袋合計
        rtn = this.getTareInfo(0);
        break;
      case 70:  // 後体重風袋合計
        rtn = this.getTareInfo(1);
        break;
      case 71:  // 除水補正合計
        rtn = this.getOffWaterInfo();
        break;
      case 72:  // 再循環率有効値
        rtn = this.reLoopRateMain;
        break;

// 治療条件
      case 73:  // VA
        ItemResult itemResult73 = this.getVAName();
        rtn = itemResult73.colValue();
        msOrderIndex = itemResult73.msOrderIndex();
        break;
      case 74:  // 除水量制限
        rtn = Util.getFormattedNumber(this.getValue(4), 2);
        break;
      case 75:  // ダイアライザー
        ItemResult itemResult75 = this.getDialyzerName();
        rtn = itemResult75.colValue();
        msOrderIndex = itemResult75.msOrderIndex();
      break;

      case 76:  // 吸着カラム
        ItemResult itemResult76 = this.getEquipName(6);
        rtn = itemResult76.colValue();
        msOrderIndex = itemResult76.msOrderIndex();
        break;
      case 77:  // 1次膜
        ItemResult itemResult77 = this.getEquipName(7);
        rtn = itemResult77.colValue();
        msOrderIndex = itemResult77.msOrderIndex();
        break;
      case 78:  // 2次膜
        ItemResult itemResult78 = this.getEquipName(8);
        rtn = itemResult78.colValue();
        msOrderIndex = itemResult78.msOrderIndex();
        break;
      case 79:  // 穿刺針(A針)
        ItemResult itemResult79 = this.getEquipName(9);
        rtn = itemResult79.colValue();
        msOrderIndex = itemResult79.msOrderIndex();
        break;
      case 80:  // 穿刺針(V針)
        ItemResult itemResult80 = this.getEquipName(10);
        rtn = itemResult80.colValue();
        msOrderIndex = itemResult80.msOrderIndex();
        break;
      case 81:  // 穿刺針(SN)
        ItemResult itemResult81 = this.getEquipName(11);
        rtn = itemResult81.colValue();
        msOrderIndex = itemResult81.msOrderIndex();
        break;
      case 82:  // シングルニードル使用
        rtn = this.getUseText(this.getValue(12));
        break;

      case 83:  // 血液回路
        ItemResult itemResult83 = this.getEquipName(13);
        rtn = itemResult83.colValue();
        msOrderIndex = itemResult83.msOrderIndex();
        break;
      case 84:  // 血流量
        rtn = this.getValue(14);
        break;

      case 85:  // 透析液
        ItemResult itemResult85 = this.getMedicineName(15);
        rtn = itemResult85.colValue();
        msOrderIndex = itemResult85.msOrderIndex();
        break;
      case 86:  // 透析液流量
        rtn = this.getValue(16);
        break;
      case 87:  // 透析液量
        rtn = this.getValue(17);
        break;
      case 88:  // 透析液温度
        rtn = Util.getFormattedNumber(this.getValue(18), 1);
      break;
      case 89:  // 補液
        ItemResult itemResult89 = this.getMedicineName(19);
        rtn = itemResult89.colValue();
        msOrderIndex = itemResult89.msOrderIndex();
        break;
      case 90:  // 補液量
        rtn = this.getValue(20);
        //add FNSI redmine 6123 6018 劉祥霖　start
        //小数点後1位まで追加する
        // add #9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 dengshen start
        if ("-1".equals(rtn)){
          rtn = "濾過率から算出";
        } else
        // add #9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 dengshen end
        if(!rtn.contains(".")&&!"".equals(rtn)&&rtn!=null){
          rtn=rtn+".0";
        }
        //add FNSI redmine 6123 6018 劉祥霖　end
        break;
      case 91:  // 補液選択
        wk = this.getValue(21);
        if( Objects.equals(wk,  "0")) {
          rtn = "後補液";
        } else if(Objects.equals(wk,  "1")) {
          rtn = "前補液";
        }
        break;
      case 92:  // 補液使用数
        rtn = this.getValue(22);
        break;
      case 93:  // 補液温度
        rtn = Util.getFormattedNumber(this.getValue(23), 1);
        break;
      case 94:  // 補液速度
        // mod #8501 【デグレ】治療状況リスト，マップの補液速度（治療条件）の桁が不正 dou start
        // rtn = this.getValue(24);
        rtn = Util.getFormattedNumber(this.getValue(24), 2);
        // mod #8501 【デグレ】治療状況リスト，マップの補液速度（治療条件）の桁が不正 dou end
        //add FNSI redmine 6123 6018 劉祥霖　start
        //小数点後２位まで追加する
        // add #9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 dengshen start
        if ("-1.00".equals(rtn)){
          rtn = "濾過率から算出";
        } else
        // add #9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 dengshen end
        if(rtn.contains(".")){
          String[] rtns=rtn.split(".");
          if(rtns[1].length()==1){
            rtn=rtn+"0";
          }
        }else if(!"".equals(rtn)&&rtn!=null){
          rtn=rtn+".00";
        }
        //add FNSI redmine 6123 6018 劉祥霖　end
        break;

      case 95:  // 抗凝固剤
        ItemResult itemResult95 = this.getMedicineName(25);
        rtn = itemResult95.colValue();
        msOrderIndex = itemResult95.msOrderIndex();
        break;
      case 96:  // 抗凝固剤ワンショット量
        rtn = this.getValue(26);
        break;
      case 97:  // 抗凝固剤持続速度
        rtn = this.getValue(27);
        break;
      case 98:  // 抗凝固剤持続総量
        rtn = this.getValue(28);
        break;

      case 99:  // IP使用選択
        rtn = this.getUseText(this.getValue(29));
        break;
      case 100: // IPスタート
        wk = this.getValue(30);
        if( Objects.equals(wk,  "0")) {
          rtn = "手動";
        } else if(Objects.equals(wk,  "1")) {
          rtn = "自動";
        }
        break;
      case 101: // IPワンショット量
        rtn = Util.getFormattedNumber(this.getValue(31), 1);
        break;
      case 102: // IP速度
        rtn = Util.getFormattedNumber(this.getValue(32), 1);
        break;
      case 103: // IP速度最大値
        rtn = Util.getFormattedNumber(this.getValue(33), 1);
        break;
      case 104: // IPワンショットスタート
        wk = this.getValue(34);
        if (Objects.equals(wk, "0")) {
          rtn = "手動";
        } else if (Objects.equals(wk, "1")) {
          rtn = "自動";
        }
        break;
      case 105: // IP電源自動切
        rtn = this.getOnOffText(this.getValue(35));
        break;
      case 106: // IP電源自動切時間
        rtn = this.getValue(36);
        break;
      case 107: // IP電源OKモニタ切
        rtn = this.getOnOffText(this.getValue(37));
        break;
      case 108: // IP電源OKモニタ切時間
        rtn = this.getValue(38);
        break;

      }
    } catch (Exception ex) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage("REST request error by get getByItemCd : " + itemCd + " -> " + ex.getMessage());
//      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      //del 治療状況リスト画面に内容が表示されない　劉祥霖　start
      //logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_STATUS_LIST_MAIN, AFTER_LOG_FLG_ERROR, mappingUrl, null, ex.getMessage());
      //del 治療状況リスト画面に内容が表示されない　劉祥霖　end
      // wp アプリケーションログの適正化 Add End
    }
    return new ItemResult(rtn, msOrderIndex);
  }


  //add #11553 治療状況表示項目不足( 残り時間:113) zrx start
  public String get113FieldValue(String rstDialysisState, String columnName, String functionCode, StatusListDTO dto, MntMachineState machine) {
    String result = "";
    Integer max113Value = 0;
    String fieldValue = "";
    /**
     * tableName = "mni_monitor" what data is available:
     * 1. mst_add_monitor (customized data items)
     * 2. sys_monitor_item  moni_data_type is null
     * These data all need to be read as 【mni_monitor】, but it is necessary to confirm the 【data_type】
     */
     // モニタ
    if (rstDialysisState != null) {
      switch (rstDialysisState) {
        case "0":
        case "1":
        case "2":
        case "3":
          // 治療状況リスト -> 治療状況/装置一覧  治療状況マップ -> 治療状況/スケジュール
          fieldValue = Util.getMachineStateColumnData(machine, columnName).toString();
          break;
        case "4":
        case "5":
        case "6":
          if ("2".equals(functionCode)) {  // 治療状況リスト -> 装置一覧
            fieldValue = Util.getMachineStateColumnData(machine, columnName).toString();
          } else {
            // 治療状況リスト -> 治療状況  治療状況マップ -> スケジュール
            fieldValue = Util.getMniMonitorColumnData(dto.getMniMonitor(), columnName).toString();
          }
          break;
      }
    } else {
      /**
       * 2: 治療状況リスト -> 装置一覧 、3: 治療状況マップ -> 治療状況
       * these two functions require reading mnt_machine_state in the absence of a patient
       */
      if ("2".equals(functionCode) || "3".equals(functionCode)) {
        fieldValue = Util.getMachineStateColumnData(machine, columnName).toString();
      }
    }
    if(StringUtils.hasText(fieldValue)) {
      try {
        ObjectMapper objectMapper = new ObjectMapper();
        Map<String, Object> map = objectMapper.readValue(fieldValue, Map.class);
        String value3Str = map.get("3") != null ? map.get("3").toString() : "0";
        String value4Str = map.get("4") != null ? map.get("4").toString() : "0";
        String value78Str = map.get("78") != null ? map.get("78").toString() : "0";

        Integer value3 = Integer.valueOf(value3Str);
        Integer value4 = Integer.valueOf(value4Str);
        Integer value78 = Integer.valueOf(value78Str);
        Integer maxValue = Math.max(value3, Math.max(value4, value78));
        if (maxValue > max113Value) {
          max113Value = maxValue;
        }
        if (maxValue == 0 &&
          ("0:00".equals(value3Str) || "0".equals(value3Str) ||
            "0:00".equals(value4Str) || "0".equals(value4Str) ||
            "0:00".equals(value78Str) || "0".equals(value78Str))) {
          result = "0:00";
        }
        if (maxValue <= 0) {
          result = "0:00";
        }
      } catch (Exception ex) {

      }
    }
    if(max113Value > 0) {
      result = Util.ElapsedMinutesToHHMM(max113Value);
    }
    return result;
  }
  //add #11553 治療状況表示項目不足( 残り時間:113) zrx end

  /**
   * クラス名取得
   */
  private String getClassName() {
    return this.getClass().getName();
  }

  /**
   * メソッド名取得
   */
  private String getMethodName() {
    return Thread.currentThread().getStackTrace()[2].getMethodName();
  }

}
