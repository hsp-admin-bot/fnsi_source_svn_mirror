package jp.co.nikkiso.ntss.device_edge.util.WeightInfo;

// add #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
import java.math.BigDecimal;
// add #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
import java.util.Date;
import java.util.Objects;

import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.device_edge.util.Utilities;
import lombok.Getter;

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
  /** 治療記録で選択された再循環率の番号 **/
  Integer reLoopRateMain;

  /**
   * コンストラクタ
   * 体重情報をクラスフィールドに展開します。
   * @param weightInfo 体重情報のJSON文字列
   */
  public WeightInfo(String weightInfo) {
    // 引数を展開
    this.setWeightInfo(weightInfo);
  }

  /**
   * 体重情報をクラスフィールドに展開します。
   * @param weightInfo 体重情報のJSON文字列
   */
  private void setWeightInfo(String weightInfo) {
    if (Objects.isNull(weightInfo)) {
      return;
    }
    ObjectMapper mapper = new ObjectMapper();
    try {
      JsonNode jsonNode_parent = mapper.readTree(weightInfo);
      this.setItems(jsonNode_parent);

    } catch (Exception e) {
    }
  }

  /**
   * 体重情報のJSONノード配列から各フィールドへ展開する。
   * @param jsonNode
   */
  private void setItems(JsonNode jsonNode) {
    // 各キーのJSONノードを取得
    JsonNode weightMeasureBeforeNode = jsonNode.get("weight_measure_before");
    JsonNode weightBeforeNode = jsonNode.get("weight_before");
    JsonNode weightBeforeDateNode = jsonNode.get("weight_before_date");
    JsonNode weightMeasureAfterNode = jsonNode.get("weight_measure_after");
    JsonNode weightAfterNode = jsonNode.get("weight_after");
    JsonNode weightAfterDateNode = jsonNode.get("weight_after_date");
    JsonNode ctrNode = jsonNode.get("ctr");
    JsonNode ctrMeasureDateNode = jsonNode.get("ctr_measure_date");
    JsonNode ctrWeightNode = jsonNode.get("ctr_weight");
    JsonNode waterRemovalTargetNode = jsonNode.get("water_removal_target");
    JsonNode waterRemovalRstNode = jsonNode.get("water_removal_rst");
    JsonNode addTotalNode = jsonNode.get("add_total");
    JsonNode addWaterTotalNode = jsonNode.get("add_water_total");
    JsonNode ktVMeasureNode = jsonNode.get("kt_v_measure");
    JsonNode urrNode = jsonNode.get("urr");
    JsonNode weightDecreasedNode = jsonNode.get("weight_decreased");
    JsonNode reLoopRateMainNode = jsonNode.get("re_loop_rate_main");
    // それぞれのJSONノードから値を取得
    this.weightMeasureBefore = (weightMeasureBeforeNode == null) ? null : weightMeasureBeforeNode.asText();
    this.weightBefore = weightBeforeNode.asText();
    this.weightBeforeDate = Utilities.dateStringToDate_iso8601(weightBeforeDateNode.asText());
    this.weightMeasureAfter = (weightMeasureAfterNode == null) ? null : weightMeasureAfterNode.asText();
    this.weightAfter = weightAfterNode.asText();
    this.weightAfterDate = Utilities.dateStringToDate_iso8601(weightAfterDateNode.asText());
    this.ctr = ctrNode.asText();
    this.ctrMeasureDate = Utilities.dateStringToDate_iso8601(ctrMeasureDateNode.asText());
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
    //this.ctrWeight = ctrWeightNode.asText();
    this.ctrWeight = ctrWeightNode.decimalValue();
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    this.waterRemovalTarget = waterRemovalTargetNode.asText();
    this.waterRemovalRst = waterRemovalRstNode.asText();
    this.addTotal = addTotalNode.asText();
    this.addWaterTotal = addWaterTotalNode.asText();
    this.ktVMeasure = ktVMeasureNode.asText();
    this.urr = urrNode.asText();
    this.weightDecreased = weightDecreasedNode.asText();
    this.reLoopRateMain = reLoopRateMainNode.asInt();

  }

}
