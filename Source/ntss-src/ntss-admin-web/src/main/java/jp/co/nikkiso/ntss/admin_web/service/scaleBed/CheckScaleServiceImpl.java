package jp.co.nikkiso.ntss.admin_web.service.scaleBed;

import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import info.sunjune.solve.calculation.calculator.NumberCalculator;
import jp.co.nikkiso.ntss.admin_web.response.weight.WeightOrderResponse;
import jp.co.nikkiso.ntss.admin_web.service.FacilitySettingService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.master.weight.MstWeightService;
import jp.co.nikkiso.ntss.admin_web.service.scaleBed.constant.CheckingParameterCode;
import jp.co.nikkiso.ntss.admin_web.service.scaleBed.dto.CheckScaleMessage;
import jp.co.nikkiso.ntss.admin_web.service.scaleBed.dto.CheckingParameter;
import jp.co.nikkiso.ntss.admin_web.service.scaleBed.dto.TargetPhysicalInfo;
import jp.co.nikkiso.ntss.admin_web.service.weight.WeightService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstBedDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.entity.MstWeight;
import jp.co.nikkiso.ntss.core.entity.custom.PatUniquePhysicalInfo;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.apache.commons.lang3.math.NumberUtils;
import org.springframework.lang.Nullable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;
import java.util.Objects;


@Service
public class CheckScaleServiceImpl implements CheckScaleService {

  @Autowired
  private WeightService weightService;
  @Autowired
  private MstWeightService mstWeightService;
  @Autowired
  private FacilitySettingService facilitySettingService;
  @Autowired
  private PatPersonalMainDao patPersonalMainDao;
  @Autowired
  private MstFacilityDao mstFacilityDao;
  @Autowired
  private MstBedDao mstBedDao;

  @Autowired
  private LogService logService;
  @Autowired
  private ObjectMapper objectMapper;

  /**
   * {@inheritDoc}
   */
  @Override
  public CheckingParameter buildCheckingParameter(BigDecimal scaleValue, Timestamp measureDate, Long ordNo, ScaleMode scaleMode, String facilityCd, Long bedCdByOrdNull) {

    CheckingParameter checkingParameter = new CheckingParameter();
    CheckingParameter.PrintParameter printParameter = new CheckingParameter.PrintParameter();

    var eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(facilityCd);
    eventLogMessage.setLogMessage("測定値チェック用パラメータ収集開始");
    logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);

    if (scaleValue == null) {
      eventLogMessage.setLogMessage("測定値null");
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      return null;
    }
    if (ordNo == null) {
      // スケジュール無し
      eventLogMessage.setLogMessage("スケジュールなし");
      logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);

      checkingParameter.setMeasureValue(scaleValue);
      printParameter.setFacilityName(mstFacilityDao.selectNameByCd(facilityCd));
      var bed = mstBedDao.selectByBedCd(bedCdByOrdNull, null, null);
      if (bed != null) {
        String bedName = bed.getBedName();
        if (!"1".equals(bed.getIsDisp())) {
          bedName = CoreConstant.NamePrefixJapan.DELETED + bedName;
        }
        printParameter.setBedName(bedName);
      }
      checkingParameter.setPrintParameter(printParameter);
      return checkingParameter;
    }

    // 指示・実績情報
    var ordParameter = weightService.buildOrderResponse(ordNo);
    eventLogMessage.setPatId(String.valueOf(ordParameter.ord.getPatId()));

    // 身体情報
    var physical = getTargetPhysicalInfo(ordParameter.physicalInfo, measureDate);
    // 前回測定情報
    var lastScaleInfo = weightService.fetchLastWeightScale(ordNo, scaleMode.equals(ScaleMode.BEFORE) ? (short)0 : (short)1);
    // 患者個人情報
    var patPersonal = patPersonalMainDao.selectById(ordParameter.ord.getPatId());

    // 施設名称
    printParameter.setFacilityName(ordParameter.facilityName);
    // ベッド名
    printParameter.setBedName(scaleMode.equals(ScaleMode.BEFORE) ? ordParameter.ord.getIndBedName() : ordParameter.ord.getRstBedName());
    // 院内患者ID
    printParameter.setHospPatId(patPersonal.getHosp_pat_id());
    // 患者名
    printParameter.setPatName(patPersonal.getPat_last_name() + " " + patPersonal.getPat_first_name());

    // 測定値チェックに必要なパラメータをセット
    // DW
    var dw = getDw(ordParameter, physical);
    checkingParameter.setDw(dw);

    // 身長
    checkingParameter.setPatHeight(physical.getPatHeight());

    // 測定値
    // TODO: 2回測定チェックは対応する必要があるか？
    checkingParameter.setMeasureValue(scaleValue);
    // 前体重許容上限
    checkingParameter.setBeforeWeightMax(physical.getPreScaleUpper());
    // 前体重許容下限
    checkingParameter.setBeforeWeightMax(physical.getPreScaleLower());

    // 治療条件
    var condInfoStr = scaleMode.equals(ScaleMode.AFTER) ? ordParameter.ord.getRstCondInfo() : ordParameter.ord.getIndCondInfo();

    // 治療時間
    printParameter.setDialysisTime(getDialysisTime(condInfoStr, eventLogMessage));

    // 目標体重
    BigDecimal targetWeight = getTargetWeight(condInfoStr, dw, eventLogMessage);
    checkingParameter.setTargetWeight(targetWeight);

    // 風袋
    String tareJson = getTareJsonStr(ordParameter, scaleMode, eventLogMessage);
    BigDecimal tareWeight = getTareWeight(tareJson, eventLogMessage);
    checkingParameter.setTare(tareWeight);
    checkingParameter.setTareJsonStr(tareJson);

    // 除水補正
    String offWaterJson = getOffWaterJsonStr(ordParameter, scaleMode);
    BigDecimal offWaterWeight = getOffWaterWeight(offWaterJson, eventLogMessage);
    checkingParameter.setOffWater(offWaterWeight);
    checkingParameter.setOffWaterJsonStr(offWaterJson);

    // 除水制限
    BigDecimal limitOffWater = getLimitOffWater(condInfoStr, eventLogMessage);
    checkingParameter.setLimitOffWater(limitOffWater);

    // 測定実績
    var rstWeightInfo = parseNode(ordParameter.ord.getRstWeightInfo(), eventLogMessage);

    // I-HDF引き残し
    String iHdfPll = null;
    if (rstWeightInfo != null && rstWeightInfo.has("ihdf_pll")) {
      iHdfPll = rstWeightInfo.get("ihdf_pll").asText();
    }
    checkingParameter.setPg(iHdfPll);

    // 透析時間実績
    printParameter.setRstStartDate(ordParameter.ord.getRstStartDate());
    printParameter.setRstEndDate(ordParameter.ord.getRstEndDate());

    BigDecimal beforeWeight;
    BigDecimal afterWeight = null;
    BigDecimal targetOffWater = null;
    BigDecimal resultOffWater = null;

    // 体重値 = 測定値-風袋合計値
    BigDecimal weightValue = scaleValue.subtract(tareWeight);

    if ((scaleMode.equals(ScaleMode.AFTER) || scaleMode.equals(ScaleMode.NOW_DIALYSIS)) && rstWeightInfo != null) {
      // 後体重モード or 透析中
      // 後体重 = 体重値
      afterWeight = weightValue;

      // 後体重測定時は前体重と除水積算をあらかじめ取得しておく
      // 前体重[実績から]
      var beforeWeightStr = checkHasValue(rstWeightInfo, "weight_before") ? rstWeightInfo.get("weight_before").asText() : null;
      beforeWeight = beforeWeightStr == null ? null : new BigDecimal(beforeWeightStr);
      // 目標除水量[実績から]
      var targetOffWaterStr = checkHasValue(rstWeightInfo,"water_removal_target") ? rstWeightInfo.get("water_removal_target").asText() : null;
      targetOffWater = targetOffWaterStr == null ? null : new BigDecimal(targetOffWaterStr);
      // 除水実績[実績から]
      var resultOffWaterStr = checkHasValue(rstWeightInfo,"water_removal_rst") ? rstWeightInfo.get("water_removal_rst").asText() : null;
      resultOffWater = resultOffWaterStr == null ? null : new BigDecimal(resultOffWaterStr);
    } else {
      // 前体重モード
      // 前体重 = 体重値
      beforeWeight = weightValue;
      if (limitOffWater != null) {
        // 目標除水量 = (前体重＋除水補正)-目標体重
        BigDecimal targetOffWaterValue = (weightValue.add(offWaterWeight)).subtract(targetWeight);
        // 除水制限を超えている場合はそれが上限
        if (targetOffWaterValue.compareTo(limitOffWater) > 0) {
          targetOffWaterValue = limitOffWater;
        }
        targetOffWater = targetOffWaterValue;
      }
    }
    // 前体重
    checkingParameter.setBeforeWeight(beforeWeight);
    // 後体重
    checkingParameter.setAfterWeight(afterWeight);
    // 目標除水量
    checkingParameter.setTargetOffWater(targetOffWater);
    // 除水実績
    checkingParameter.setResultOffWater(resultOffWater);

    // TODO: 車いす関係の取得は必要に応じて実装
    BigDecimal wheelChairWeight = null;
    if (lastScaleInfo != null && lastScaleInfo.getWheelChairWeight() != null) {
      wheelChairWeight =  gram2KilogramFloor(lastScaleInfo.getWheelChairWeight());
    }
    checkingParameter.setWheelChair(wheelChairWeight);

    String nextDate1 = "予定なし";
    String nextDate2 = "予定なし";
    Timestamp nextSchedule = null;
    if (ordParameter.nextOrd != null) {
      // 次回透析予定
      var nextDate = ordParameter.nextOrd.getTreatDate();
      var year = nextDate.substring(0, 4);
      var month = nextDate.substring(4, 6);
      var date = nextDate.substring(6, 8);
      nextDate1 = month + "/" + date;
      nextDate2 = year + "/" + month + "/" + date;
      var nextStartTime = ordParameter.nextOrd.getIndTreatStartTime();
      if (nextStartTime != null && !nextStartTime.isEmpty()) {
        var hour = nextStartTime.substring(0, 2);
        var minute = nextStartTime.substring(2, 4);
        nextSchedule = Timestamp.valueOf(year + "-" + month + "-" + date + " " + hour + ":" + minute + ":00");
      }
    }
    // 次回透析予定１
    checkingParameter.setNextDate1(nextDate1);
    // 次回透析予定2
    checkingParameter.setNextDate2(nextDate2);
    // 次回スケジュール
    printParameter.setNextSchedule(nextSchedule);

    // 前回後体重
    BigDecimal lastWeight = null;
    try {
      var weightScale = mstWeightService.mstWeightScaleSelectByFacility(facilityCd);
      var lastWeightRecord = weightService.getLastWeightRecord(ordNo, Integer.valueOf(weightScale.getPreviousWeightSourceClass()));
      if (lastWeightRecord.getWeightAfter() != null){
        lastWeight = lastWeightRecord.getWeightAfter();
      }
    } catch (Exception e) {
      eventLogMessage.setLogMessage("前回後体重取得失敗:" + e.getMessage());
      logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    }
    checkingParameter.setLastAfterWeight(lastWeight);

    // BMI
    String bmi = null;
    if (physical.getPatHeight() != null &&
      physical.getPatHeight().compareTo(BigDecimal.ZERO) > 0
    ) {
      var metre = physical.getPatHeight().divide(BigDecimal.valueOf(100), 3, RoundingMode.HALF_UP);
      var powMetre = metre.pow(2);
      var bmiValue = weightValue.divide(powMetre, 2, RoundingMode.HALF_UP);
      bmi = String.valueOf(bmiValue);
    } else if (checkingParameter.getPatHeight() == null) {
      bmi = "身長未測定";
    }
    checkingParameter.setBmi(bmi);

    checkingParameter.setPrintParameter(printParameter);
    return checkingParameter;
  }

  /**
   * JsonNodeの指定のキーについて
   * キーがない
   * キーの値がnull
   * キーの値が"null"
   * のいずれかならばFalseを返す
   * @param node JsonNode
   * @param key キー文字列
   * @return t/f
   */
  private boolean checkHasValue(JsonNode node, String key) {
    if (node == null || node.isNull() || key == null || key.isEmpty()) {
      // 取得対象無し
      return false;
    } else if (!node.has(key)) {
      // 該当キーがない
      return false;
    } else if (node.get(key).isNull()) {
      // 該当キーがnull
      return false;
    }
    var value = node.get(key).asText();
    // 空文字、"null" ならば false
    return !value.isEmpty() && !Objects.equals(value, "null");
  }

  private BigDecimal getOffWaterWeight(String offWaterJsonStr, EventLogMessage eventLogMessage) {
    JsonNode offWaterInfo = parseNode(offWaterJsonStr, eventLogMessage);

    // 除水セット
    BigDecimal offWaterInfoWeight1 = StringToBigDecimal(getJsonValueSafe(offWaterInfo, "weight_1"));
    BigDecimal offWaterInfoWeight2 = StringToBigDecimal(getJsonValueSafe(offWaterInfo, "weight_2"));
    BigDecimal offWaterInfoWeight3 = StringToBigDecimal(getJsonValueSafe(offWaterInfo, "weight_3"));
    BigDecimal offWaterInfoWeight4 = StringToBigDecimal(getJsonValueSafe(offWaterInfo, "weight_4"));
    BigDecimal offWaterInfoWeight5 = StringToBigDecimal(getJsonValueSafe(offWaterInfo, "weight_5"));

    BigDecimal totalWeight = offWaterInfoWeight1.add(offWaterInfoWeight2).add(offWaterInfoWeight3).add(offWaterInfoWeight4).add(offWaterInfoWeight5);

    // キログラムに直して小数点第３位で切り上げ
    return gram2KilogramCeil(totalWeight);
  }

  private String getOffWaterJsonStr(WeightOrderResponse ordParameter, ScaleMode scaleMode) {
    if (scaleMode.equals(ScaleMode.AFTER)) {
      return ordParameter.ord.getRstOffWaterInfo();
    } else {
      return ordParameter.ord.getIndOffWaterInfo();
    }
  }

  private BigDecimal getTareWeight(String tareJsonInfo, EventLogMessage eventLogMessage) {
    JsonNode tareInfo = parseNode(tareJsonInfo, eventLogMessage);

    // 風袋セット
    BigDecimal tareInfoWeight1 = StringToBigDecimal(getJsonValueSafe(tareInfo, "weight_1"));
    BigDecimal tareInfoWeight2 = StringToBigDecimal(getJsonValueSafe(tareInfo, "weight_2"));
    BigDecimal tareInfoWeight3 = StringToBigDecimal(getJsonValueSafe(tareInfo, "weight_3"));
    BigDecimal tareInfoWeight4 = StringToBigDecimal(getJsonValueSafe(tareInfo, "weight_4"));
    BigDecimal tareInfoWeight5 = StringToBigDecimal(getJsonValueSafe(tareInfo, "weight_5"));

    BigDecimal totalWeight = tareInfoWeight1.add(tareInfoWeight2).add(tareInfoWeight3).add(tareInfoWeight4).add(tareInfoWeight5);

    // キログラムに直して小数点第３位で切り捨て
    return gram2KilogramFloor(totalWeight);
  }

  private String getTareJsonStr(WeightOrderResponse ordParameter, ScaleMode scaleMode, EventLogMessage eventLogMessage) {
    JsonNode tareInfo;
    if (scaleMode.equals(ScaleMode.AFTER)) {
      //後体重の場合
      var tareStr = ordParameter.ord.getRstTareInfo();
      var rstTareInfo = parseNode(tareStr, eventLogMessage);
      if (rstTareInfo == null) {
        return null;
      }
      tareInfo = rstTareInfo.has("after") ? rstTareInfo.get("after") : null;
      if (tareInfo == null) {
        return null;
      } else {
        return tareInfo.toString();
      }
    } else {
      //前体重の場合
      var tareStr = ordParameter.ord.getRstTareInfo();
      var rstTareInfo = parseNode(tareStr, eventLogMessage);
      if (rstTareInfo == null) {
        return ordParameter.ord.getIndTareInfo();
      }
      else {
        return ordParameter.ord.getRstTareInfo();
      }
    }

  }
  private static @Nullable BigDecimal getDw(WeightOrderResponse ordParameter, TargetPhysicalInfo physical) {
    BigDecimal dw = null;
    if (!Objects.isNull(ordParameter.ord.getRstDw()) && ordParameter.ord.getRstDw().compareTo(BigDecimal.ZERO) > 0) {
      // rst_dwがあれば最優先
      dw = ordParameter.ord.getRstDw();
    } else if (!Objects.isNull(ordParameter.ord.getIndDw()) && ordParameter.ord.getIndDw().compareTo(BigDecimal.ZERO) > 0) {
      // ind_dwが身体情報より優先
      dw = ordParameter.ord.getIndDw();
    } else if (!Objects.isNull(physical.getDw())){
      // PhysicalInfoから最新のDWを取得
      dw = physical.getDw();
    }
    return dw;
  }

  private @Nullable BigDecimal getTargetWeight(String condInfoStr, BigDecimal dw, EventLogMessage eventLogMessage) {
    JsonNode condInfo = parseNode(condInfoStr, eventLogMessage);
    if (condInfo == null) {
      eventLogMessage.setLogMessage("目標体重取得失敗");
      logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      return null;
    }
    JsonNode targetNode = condInfo.has("3") ? condInfo.get("3") : null;
    String valueStr = (targetNode != null && targetNode.has("value")) ? targetNode.get("value").asText() : null;
    if (valueStr == null || valueStr.equals("null") || valueStr.equals("-1") || valueStr.isEmpty()) {
      // 目標体重 = DW
      return Objects.requireNonNullElse(dw, BigDecimal.ZERO);
    }
    return (new BigDecimal(valueStr));
  }

  /**
   * 除水制限取得
   * @param condInfoStr 治療条件
   * @param eventLogMessage ログ
   * @return 除水制限値
   */
  private @Nullable BigDecimal getLimitOffWater(String condInfoStr, EventLogMessage eventLogMessage) {
    JsonNode condInfo = parseNode(condInfoStr, eventLogMessage);
    if (condInfo == null) {
      eventLogMessage.setLogMessage("除水制限取得失敗");
      logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      return null;
    }
    JsonNode targetNode = condInfo.has("4") ? condInfo.get("4") : null;
    String valueStr = (targetNode != null && targetNode.has("value")) ? targetNode.get("value").asText() : null;
    if (valueStr == null || valueStr.equals("null") || valueStr.isEmpty()) {
      return null;
    }
    return (new BigDecimal(valueStr));
  }

  private @Nullable String getDialysisTime(String condInfoStr, EventLogMessage eventLogMessage) {
    JsonNode condInfo = parseNode(condInfoStr, eventLogMessage);
    if (condInfo == null) {
      eventLogMessage.setLogMessage("治療時間取得失敗");
      logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      return null;
    }
    JsonNode targetNode = condInfo.has("1") ? condInfo.get("1") : null;
    String valueStr = (targetNode != null && targetNode.has("value")) ? targetNode.get("value").asText() : null;
    if (valueStr == null || valueStr.equals("null") ||  valueStr.isEmpty()) {
      return null;
    }
    return valueStr;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public int checkScaleAsNumber(CheckingParameter param, MstWeight mstWeight, ScaleMode scaleMode, String facilityCd) {

    List<CheckScaleMessage> returnValue = checkScale(param, mstWeight, scaleMode, facilityCd);

    var isWarn = returnValue.stream().anyMatch(CheckScaleMessage::isWarn);
    var isError = returnValue.stream().anyMatch(CheckScaleMessage::isError);
    return isError ?
      2 :
      isWarn ? 1 : 0;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<CheckScaleMessage> checkScale(CheckingParameter param, MstWeight mstWeight, ScaleMode scaleMode, String facilityCd) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(facilityCd);

    List<CheckScaleMessage> checkScaleMessages = new ArrayList<>();

    eventLogMessage.setLogMessage("測定値チェック処理開始: 測定値=" + param.getMeasureValue() + ", 目標体重=" + param.getTargetWeight() + ", 体重計名=" + mstWeight.getWeightName());
    logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);

    // TODO: 2回測定チェックは必要か？

    // ***************
    // 前体重許容チェック
    // ***************

    if (scaleMode.equals(ScaleMode.BEFORE)) {
      // 前体重許容量の判定
      String IS_BEFORE_WEIGHT_TOLERANCE_RANGE_CHECK = "1068";
      var settingCdList = new String[]{IS_BEFORE_WEIGHT_TOLERANCE_RANGE_CHECK};

      // 施設設定を取得
      var facilitySetting = facilitySettingService.getFacilitySettingValueMap(facilityCd, Arrays.stream(settingCdList).toList());
      var isBeforeWeightToleranceRangeCheck = !"0".equals(facilitySetting.get(IS_BEFORE_WEIGHT_TOLERANCE_RANGE_CHECK));
      if (isBeforeWeightToleranceRangeCheck) {
        // 前体重許容範囲チェック
        var targetWeight = param.getTargetWeight();
        var beforeWeight = param.getBeforeWeight();
        if (
          targetWeight != null && targetWeight.compareTo(BigDecimal.ZERO) > 0 &&
          beforeWeight != null && beforeWeight.compareTo(BigDecimal.ZERO) > 0)
        {
          boolean isPreScaleError = checkIsPreScaleError(param, targetWeight, beforeWeight);

          if (isPreScaleError) {
            var message = "前体重許容範囲外";

            eventLogMessage.setLogMessage(message + ": 前体重=" + beforeWeight + ", 目標体重=" + targetWeight);
            logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);

            var checkScaleMessage = new CheckScaleMessage();
            checkScaleMessage.setMessage(message);
            checkScaleMessage.setWarnValue(true);
            checkScaleMessage.setDisp(true);

            checkScaleMessages.add(checkScaleMessage);
          }
        }
      }
    }

    // ***************
    // 設定に基づく測定値チェック
    // ***************
    var checkConfig = parseNode(mstWeight.getCheckContent(), eventLogMessage);
    if (checkConfig != null) {
      // 要素をリストに変換
      List<JsonNode> checkConfigArray = new ArrayList<>();
      checkConfig.forEach(checkConfigArray::add);

      // ソート
      checkConfigArray.sort(Comparator.comparingInt(node -> node.get("disp_order").asInt()));

      var configList = checkConfigArray.stream().filter((item) -> {
        // 無効フラグが立っているものは除外
        if (item.get("is_disable").asText().equals("1")) {
          return false;
        }
        // 前体重・後体重で使用するものだけを抽出
        if (scaleMode == ScaleMode.BEFORE) {
          return item.get("is_disp_before").asBoolean();
        } else if (scaleMode == ScaleMode.AFTER) {
          return item.get("is_disp_after").asBoolean();
        }
        return false;
      }).toList();

      // ***************
      // チェック設定項目に値を置換
      // ***************
      for (JsonNode config : configList) {
        var msg = new CheckScaleMessage(
          config.get("calculate").asText(),
          config.get("use_condition").asInt(),
          config.get("condition_left").asText(),
          config.get("condition_right").asText(),
          config.get("condition_ineq").asInt()
        );

        for (String code : CheckingParameterCode.ALL_CODE) {
          // 値を取得
          var value = param.getByCode(code);
          var replaceValue = value == null ? "" : value;

          var repCd = code.replace("[", "\\[").replace("]", "\\]");
          // 対象文字がある場合(計算式)
          var calc = msg.getCalc().replaceAll(repCd, replaceValue);
          // 対象文字がある場合(右辺)
          var right = msg.getCondition().getRight().replaceAll(repCd, replaceValue);
          // 対象文字がある場合(左辺)
          var left = msg.getCondition().getLeft().replaceAll(repCd, replaceValue);

          msg.setCalc(calc.trim());
          msg.getCondition().setRight(right.trim());
          msg.getCondition().setLeft(left.trim());
        }

        // ***************
        // 計算
        // ***************
        // 印刷時データタイプ [0:number 1:date 2:text]
        var printDataType = config.get("print_datatype").asInt();
        if (printDataType == 0) {
          // 数値
          // 計算式の文字列を計算
          NumberCalculator calculator = new NumberCalculator();
          try {
            var calcAnswer = calculator.calculation(msg.getCalc());
            eventLogMessage.setLogMessage("計算：" + msg.getCalc() + " = " + calcAnswer);
            logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);

            if (config.get("decimal_point").asInt() >= 0) {
              // 小数点桁数を調整
              var value = new BigDecimal(String.valueOf(calcAnswer))
                .divide(BigDecimal.ONE, config.get("decimal_point").asInt(), RoundingMode.HALF_UP);
              msg.setValue(String.valueOf(value));
            } else {
              msg.setValue("<計算失敗>");

              eventLogMessage.setLogMessage("設定値エラー：decimal_point = " + config.get("decimal_point").asText());
              logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
            }

          } catch (Exception e) {
            msg.setValue("<計算失敗>");

            eventLogMessage.setLogMessage("計算失敗：" + msg.getCalc());
            logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        } else {
          // 数値以外の場合
          if (msg.getCalc() != null) {
            msg.setValue(msg.getCalc());
          } else {
            msg.setValue("<情報なし>");
          }
        }
        // ***************************
        // 表示チェック
        // ***************************
        var useCondition = msg.getCondition().getUse();
        if (useCondition == CheckScaleMessage.UseCondition.ALWAYS ) {
          msg.setDisp(true);
        } else {
          NumberCalculator calculator = new NumberCalculator();
          try {
            var left = msg.getCondition().getLeft().replaceAll("\\s+", "");
            var right = msg.getCondition().getRight().replaceAll("\\s+", "");
            var calcAnswerLeft = new BigDecimal(String.valueOf(calculator.calculation(left)));
            var calcAnswerRight = new BigDecimal(String.valueOf(calculator.calculation(right)));

            switch (msg.getCondition().getIneq()) {
              case CheckScaleMessage.ConditionIneq.LESS:
                msg.getCondition().setResult(calcAnswerLeft.compareTo(calcAnswerRight) < 0);
                break;
              case CheckScaleMessage.ConditionIneq.LESS_EQUAL:
                msg.getCondition().setResult(calcAnswerLeft.compareTo(calcAnswerRight) <= 0);
                break;
              case CheckScaleMessage.ConditionIneq.EQUAL:
                msg.getCondition().setResult(calcAnswerLeft.compareTo(calcAnswerRight) == 0);
                break;
              case CheckScaleMessage.ConditionIneq.NOT_EQUAL:
                msg.getCondition().setResult(calcAnswerLeft.compareTo(calcAnswerRight) != 0);
                break;
              case CheckScaleMessage.ConditionIneq.MORE_EQUAL:
                msg.getCondition().setResult(calcAnswerLeft.compareTo(calcAnswerRight) >= 0);
                break;
              case CheckScaleMessage.ConditionIneq.MORE:
                msg.getCondition().setResult(calcAnswerLeft.compareTo(calcAnswerRight) > 0);
                break;
              default:
                msg.getCondition().setResult(null);
                break;
            }
          } catch (Exception e) {
            msg.getCondition().setResult(null);

            eventLogMessage.setLogMessage("比較式の計算失敗：left=" + msg.getCondition().getLeft() + " right=" + msg.getCondition().getRight());
            logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          }

          if (msg.getCondition().getUse() == CheckScaleMessage.UseCondition.IS_TRUE_VIEW) {
            // チェックを満たす場合に表示 null のケースがあるので Trueと比較
            msg.setDisp(msg.getCondition().getResult() == Boolean.TRUE);
          } else if (
            msg.getCondition().getUse() == CheckScaleMessage.UseCondition.IS_FALSE_VIEW
          ) {
            // チェックを満たさない場合に表示 null のケースがあるので Trueと比較
            msg.setDisp(msg.getCondition().getResult() != Boolean.TRUE);
          }
        }
        // ***************************
        // 異常値チェック
        // ***************************
        if (
          config.get("is_check_warn").asBoolean() && NumberUtils.isParsable(msg.getValue())) {
          var value = new BigDecimal(msg.getValue());
          if (NumberUtils.isParsable(config.get("min_warn").asText())) {
            // 最小値より小さい
            var minWarn = new BigDecimal(config.get("min_warn").asText());
            msg.setWarnValue(msg.isWarnValue() || value.compareTo(minWarn) <= 0);
          }
          if (NumberUtils.isParsable(config.get("max_warn").asText())) {
            // 最大値より大きい
            var maxWarn = new BigDecimal(config.get("max_warn").asText());
            msg.setWarnValue(msg.isWarnValue() || value.compareTo(maxWarn) >= 0);
          }
        }
        // ***************************
        // 条件送信可否チェック
        // ***************************
        switch (config.get("sendable").asInt()) {
          case CheckScaleMessage.Sendable.CHECK_WARN:
            if (msg.isWarnValue()) {
              msg.setWarn(true);
              msg.setError(false);
              msg.setChecked(false);
            }
            break;
          case CheckScaleMessage.Sendable.CHECK_ERROR:
            if (msg.isWarnValue()) {
              msg.setWarn(false);
              msg.setError(true);
            }
            break;
          case CheckScaleMessage.Sendable.VIEW_WARN:
            if (msg.isDisp()) {
              msg.setWarn(true);
              msg.setError(false);
              msg.setChecked(false);
            }
            break;
          case CheckScaleMessage.Sendable.VIEW_ERROR:
            if (msg.isDisp()) {
              msg.setWarn(false);
              msg.setError(true);
            }
            break;
          case CheckScaleMessage.Sendable.OK:
            msg.setWarn(false);
            msg.setError(false);
            break;
          default:
            break;
        }
        msg.setMessage(config.get("before_word").asText() + msg.getValue() + config.get("after_word").asText());
        checkScaleMessages.add(msg);

        if (msg.isWarn()) {
          eventLogMessage.setLogMessage("警告条件該当: " + msg.getMessage());
          logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        }
        if (msg.isError()) {
          eventLogMessage.setLogMessage("エラー条件該当: " + msg.getMessage());
          logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        }
      }
    }

    return checkScaleMessages;
  }

  private static boolean checkIsPreScaleError(CheckingParameter param, BigDecimal targetWeight, BigDecimal beforeWeight) {
    boolean isPreScaleError = false;
    var beforeWeightMax = param.getBeforeWeightMax();
    if (
      beforeWeightMax != null && beforeWeightMax.compareTo(BigDecimal.ZERO) > 0)
    {
      // 目標体重＋許容上限
      var targetMaxBeforeWeight = targetWeight.add(beforeWeightMax);
      if (beforeWeight.compareTo(targetMaxBeforeWeight) > 0) {
        isPreScaleError = true;
      }
    }
    var beforeWeightMin = param.getBeforeWeightMin();
    if (
      beforeWeightMin != null && beforeWeightMin.compareTo(BigDecimal.ZERO) > 0)
    {
      // 目標体重-許容下限
      var targetMinBeforeWeight = targetWeight.subtract(beforeWeightMin);
      if (beforeWeight.compareTo(targetMinBeforeWeight) < 0) {
        isPreScaleError = true;
      }
    }
    return isPreScaleError;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public TargetPhysicalInfo getTargetPhysicalInfo(List<PatUniquePhysicalInfo> physicalInfo, Timestamp measureDate) {

    //検査日時:降順に並べ替え(要素0が検査日時最新のデータという並び)
    physicalInfo.sort(
      (s1, s2)
        ->
        s2.getExam_date().compareTo(s1.getExam_date())
    );
    // 測定日時より未来の検査日は除外
    var targetPhysicalInfoList = physicalInfo.stream()
      .filter(f -> !f.getExam_date().after(measureDate))
      .toList();

    BigDecimal dw = null;
    BigDecimal preScaleLower = null;
    BigDecimal preScaleUpper = null;
    BigDecimal patHeight = null;
    for (PatUniquePhysicalInfo info : targetPhysicalInfoList) {
      var currentDwStr = info.getDw();

      if (dw == null &&
          currentDwStr != null &&
          !currentDwStr.isEmpty() &&
          !currentDwStr.equals("null") &&
          NumberUtils.isParsable(currentDwStr)
      ) {
        // キーが有った場合、値が数値かを確認する
        try {
          dw = new BigDecimal(currentDwStr);
        } catch (Exception e) {
          // 変換できなかった
        }
      }
      var currentPreScaleLowerStr = info.getPre_scale_lower();
      if (
        preScaleLower == null &&
          currentPreScaleLowerStr != null &&
          !currentPreScaleLowerStr.isEmpty() &&
          !currentPreScaleLowerStr.equals("null") &&
          NumberUtils.isParsable(currentPreScaleLowerStr)
      ) {
        // キーが有った場合、値が数値かを確認する
        try {
          preScaleLower = new BigDecimal(currentPreScaleLowerStr);
        } catch (Exception e) {
          // 変換できなかった
        }
      }
      var currentPreScaleUpperStr = info.getPre_scale_upper();
      if (
        preScaleUpper == null &&
          currentPreScaleUpperStr != null &&
          !currentPreScaleUpperStr.isEmpty() &&
          !currentPreScaleUpperStr.equals("null") &&
          NumberUtils.isParsable(currentPreScaleUpperStr)
      ) {
        // キーが有った場合、値が数値かを確認する
        try {
          preScaleUpper = new BigDecimal(currentPreScaleUpperStr);
        } catch (Exception e) {
          // 変換できなかった
        }
      }
      var currentPatHeightStr = info.getHeight();
      if (
        patHeight == null &&
          currentPatHeightStr != null &&
          !currentPatHeightStr.isEmpty() &&
          !currentPatHeightStr.equals("null") &&
          NumberUtils.isParsable(currentPatHeightStr)
      ) {
        // キーが有った場合、値が数値かを確認する
        try {
          patHeight = new BigDecimal(currentPatHeightStr);
        } catch (Exception e) {
          // 変換できなかった
        }
      }

      if (dw != null && preScaleUpper != null && preScaleLower != null && patHeight != null) {
        // すべての値が確定したので ループ終了
        break;
      }
    }
    var returnValue = new TargetPhysicalInfo();
    returnValue.setDw(dw);
    returnValue.setPreScaleLower(preScaleLower);
    returnValue.setPreScaleUpper(preScaleUpper);
    returnValue.setPatHeight(patHeight);
    return returnValue;
  }

  private BigDecimal StringToBigDecimal(String value){
    // NULL、空白、"null"文字列の場合は0を返す
    if (value == null || value.trim().isEmpty() || "null".equals(value)) {
      return BigDecimal.valueOf(0);
    }
    try {
      // 数値に変換を試みる
      return new BigDecimal(value.trim());
    } catch (NumberFormatException e) {
      // 数値以外の文字が含まれている場合は0を返す
      return BigDecimal.valueOf(0);
    }
  }
  /**
   * JSONNode から NULL 安全に文字列値を取得
   *
   * @param node JSONNode
   * @param key        キー名
   * @return 値が存在すれば文字列、存在しなければ null を返す
   */
  private String getJsonValueSafe(JsonNode node, String key) {
    if (node == null || !node.has(key)) {
      return null;
    }
    Object value = node.get(key);
    if (value == null || "null".equals(value.toString())) {
      return null;
    }
    return value.toString();
  }

  private @Nullable JsonNode parseNode(String jsonString, EventLogMessage eventLogMessage) {
    if (jsonString == null || jsonString.isEmpty()) {
      return null;
    }
    try {
      return objectMapper.readTree(jsonString);
    } catch (Exception e) {
      eventLogMessage.setLogMessage(e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      return null;
    }
  }

  /**
   * グラムをキログラム化し、小数点３位で切り捨て。主に風袋
   * @param gram グラム
   * @return キログラム
   */
  private BigDecimal gram2KilogramFloor(BigDecimal gram) {
    if (gram == null) {
      return null;
    }
    return gram.divide(new BigDecimal(1000), 2, RoundingMode.FLOOR);
  }
  /**
   * グラムをキログラム化し、小数点３位で切り上げ。主に除水補正
   * @param gram グラム
   * @return キログラム
   */
  private BigDecimal gram2KilogramCeil(BigDecimal gram) {
    if (gram == null) {
      return null;
    }
    return gram.divide(new BigDecimal(1000), 2, RoundingMode.CEILING);
  }
}
