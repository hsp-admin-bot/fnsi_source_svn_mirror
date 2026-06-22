package jp.co.nikkiso.ntss.admin_web.service.statusList.dto.weightInfo;

// add #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
import java.math.BigDecimal;
// add #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
import java.util.Date;

import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.admin_web.service.utils.DateTimeUtils;
import lombok.Getter;
//add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.StringUtils;
//add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end

/**
 *  体重情報クラス.
 */
@Getter
public class WeightInfo {
  /** 透析前体重測定値（風袋・車いすを含む重量）**/
  String weightMeasureBefore;
  /** 透析前体重 **/
  String weightBefore;
  /** 前体重測定日時 **/
  Date weightBeforeDate;
  /** 透析後体重測定値（風袋・車いすを含む重量）**/
  String weightMeasureAfter;
  /** 透析後体重 **/
  String weightAfter;
  /** 後体重測定日時 **/
  Date weightAfterDate;
  /** CTR **/
  String ctr;
  /** CTR測定日時 **/
  Date ctrMeasureDate;
  /** CTR測定時体重 **/
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
  //String ctrWeight;
  BigDecimal ctrWeight;
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
  /** 目標除水量 **/
  String waterRemovalTarget;
  /** 実績除水量 **/
  String waterRemovalRst;
  /** 除水積算値 **/
  String addTotal;
  /** 補液積算値 **/
  String addWaterTotal;
  /** Kt/V測定値 **/
  String ktVMeasure;
  /** URR **/
  String urr;
  /** 減少量 **/
  String weightDecreased;
  //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
  @Autowired
  private LogService logService;
  //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end

  /**
   * コンストラクタ
   * 体重情報をクラスフィールドに展開します。
   * @param weightInfo 体重情報のJSON文字列
   */
  public WeightInfo(String weightInfo) {
    // メンバ変数を初期化
    //    this.initialize();
    // 引数を展開
    this.setWeightInfo(weightInfo);
  }

  /**
   * 体重情報をクラスフィールドに展開します。
   * @param weightInfo 体重情報のJSON文字列
   */
  private void setWeightInfo(String weightInfo) {
    ObjectMapper mapper = new ObjectMapper();
    try {
      if (!StringUtils.isEmpty(weightInfo)) {
        JsonNode jsonNode_parent = mapper.readTree(weightInfo);
        this.setItems(jsonNode_parent);
      }
    } catch (Exception e) {
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("[WeightInfo] JSONのパースに失敗しました。");
      logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end
    }
  }

  /**
   * 体重情報のJSONノード配列から各フィールドへ展開する。
   * @param jsonNode
   */
  private void setItems(JsonNode jsonNode) {
    // 各キーのJSONノードを取得
    JsonNode weightMeasureBeforeNode = jsonNode.has("weight_measure_before") ? jsonNode.get("weight_measure_before")
        : null;
    JsonNode weightBeforeNode = jsonNode.has("weight_before") ? jsonNode.get("weight_before") : null;
    JsonNode weightBeforeDateNode = jsonNode.has("weight_before_date") ? jsonNode.get("weight_before_date") : null;
    JsonNode weightMeasureAfterNode = jsonNode.has("weight_measure_after") ? jsonNode.get("weight_measure_after")
        : null;
    JsonNode weightAfterNode = jsonNode.has("weight_after") ? jsonNode.get("weight_after") : null;
    JsonNode weightAfterDateNode = jsonNode.has("weight_after_date") ? jsonNode.get("weight_after_date") : null;
    JsonNode ctrNode = jsonNode.has("ctr") ? jsonNode.get("ctr") : null;
    JsonNode ctrMeasureDateNode = jsonNode.has("ctr_measure_date") ? jsonNode.get("ctr_measure_date") : null;
    JsonNode ctrWeightNode = jsonNode.has("ctr_weight") ? jsonNode.get("ctr_weight") : null;
    JsonNode waterRemovalTargetNode = jsonNode.has("water_removal_target") ? jsonNode.get("water_removal_target")
        : null;
    JsonNode waterRemovalRstNode = jsonNode.has("water_removal_rst") ? jsonNode.get("water_removal_rst") : null;
    JsonNode addTotalNode = jsonNode.has("add_total") ? jsonNode.get("add_total") : null;
    JsonNode addWaterTotalNode = jsonNode.has("add_water_total") ? jsonNode.get("add_water_total") : null;
    JsonNode ktVMeasureNode = jsonNode.has("kt_v_measure") ? jsonNode.get("kt_v_measure") : null;
    JsonNode urrNode = jsonNode.has("urr") ? jsonNode.get("urr") : null;
    JsonNode weightDecreasedNode = jsonNode.has("weight_decreased") ? jsonNode.get("weight_decreased") : null;
    JsonNode reLoopRateMainNode = jsonNode.has("re_loop_rate_main") ? jsonNode.get("re_loop_rate_main") : null;

    // それぞれのJSONノードから値を取得
    this.weightMeasureBefore = (weightMeasureBeforeNode == null) ? null : weightMeasureBeforeNode.asText();
    this.weightBefore = (weightBeforeNode == null) ? null : weightBeforeNode.asText();
    this.weightBeforeDate = (weightBeforeDateNode == null) ? null
        : DateTimeUtils.dateStringToDate_iso8601(weightBeforeDateNode.asText());
    this.weightMeasureAfter = (weightMeasureAfterNode == null) ? null : weightMeasureAfterNode.asText();
    this.weightAfter = (weightAfterNode == null) ? null : weightAfterNode.asText();
    this.weightAfterDate = (weightAfterDateNode == null) ? null
        : DateTimeUtils.dateStringToDate_iso8601(weightAfterDateNode.asText());
    this.ctr = (ctrNode == null) ? null : ctrNode.asText();
    this.ctrMeasureDate = (ctrMeasureDateNode == null) ? null
        : DateTimeUtils.dateStringToDate_iso8601(ctrMeasureDateNode.asText());
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
    //this.ctrWeight = (ctrWeightNode == null) ? null : ctrWeightNode.asText();
    this.ctrWeight = (ctrWeightNode == null) ? null : ctrWeightNode.decimalValue();
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    this.waterRemovalTarget = (waterRemovalTargetNode == null) ? null : waterRemovalTargetNode.asText();
    this.waterRemovalRst = (waterRemovalRstNode == null) ? null : waterRemovalRstNode.asText();
    this.addTotal = (addTotalNode == null) ? null : addTotalNode.asText();
    this.addWaterTotal = (addWaterTotalNode == null) ? null : addWaterTotalNode.asText();
    this.ktVMeasure = (ktVMeasureNode == null) ? null : ktVMeasureNode.asText();
    this.urr = (urrNode == null) ? null : urrNode.asText();
    this.weightDecreased = (weightDecreasedNode == null) ? null : weightDecreasedNode.asText();

  }

}
