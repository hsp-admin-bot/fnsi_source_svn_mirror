package jp.co.nikkiso.ntss.device_edge.util.VitalInfo;

import java.util.ArrayList;
import java.util.List;

import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.device_edge.util.Utilities;
import lombok.Getter;
import lombok.Setter;
import tools.jackson.core.JacksonException;

/**
 *  バイタル情報クラス.
 */
@Getter
@Setter
public class VitalInfo {
  /** 前最高血圧 **/
  String bpMaxBefore;
  /** 前最低血圧 **/
  String bpMinBefore;
  /** 前平均血圧 **/
  String bpAveBefore;
  /** 前脈拍 **/
  String pulseBefore;
  /** 後最高血圧 **/
  String bpMaxAfter;
  /** 後最低血圧 **/
  String bpMinAfter;
  /** 後平均血圧 **/
  String bpAveAfter;
  /** 後脈拍 **/
  String pulseAfter;
  /** 体温最新値 **/
  String temperature;
  /** 全記録リスト **/
  List<VitalInfoItem> allRecords;

  /**
   * コンストラクタ
   * バイタル情報をクラスフィールドに展開します。
   * 透析前後測定それぞれの最新と体温の最新値を個別フィールドで保持します。
   * すべての記録はgetAllRecordsメソッドで取り出して下さい。
   * @param vitalInfo バイタル情報のJSON文字列
   */
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
  public VitalInfo(String vitalInfo) throws JacksonException {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    // allRecordsフィールドを初期化
    this.allRecords = new ArrayList<VitalInfoItem>();
    // 引数を展開
    this.setVitalInfo(vitalInfo);
  }

  /**
   * バイタル情報をクラスフィールドに展開します。
   * @param vitalInfo バイタル情報のJSON文字列
   */
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
  private void setVitalInfo(String vitalInfo) throws JacksonException {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    if (vitalInfo != null) {
      ObjectMapper mapper = new ObjectMapper();
      try {
        JsonNode jsonNode_parent = mapper.readTree(vitalInfo);
        this.setItems(jsonNode_parent);

      } catch (tools.jackson.core.JacksonException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//        e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
        throw e;
      }
    }
  }

  /**
   * バイタル情報のJSONノード配列から各フィールドへ展開する。
   * @param jsonNodeArray
   */
  private void setItems(JsonNode jsonNodeArray) {

    List<JsonNode> beforeNodes = new ArrayList<JsonNode>();
    List<JsonNode> afterNodes = new ArrayList<JsonNode>();
    List<JsonNode> temperatureNodes = new ArrayList<JsonNode>();

    for (int lop = 0; lop < jsonNodeArray.size(); lop++) {
      JsonNode jsonNode = jsonNodeArray.get(lop);
      // VitalInfoItemクラスに格納
      VitalInfoItem vitalInfoItem = this.createVitalInfoItem(jsonNode);
      // 全記録格納フィールドに追加
      this.allRecords.add(vitalInfoItem);

      // 透析前後判定
      /// 透析前後それぞれのListに格納
      /// 透析前
      if (vitalInfoItem.BPCLASS == 1) {
        beforeNodes.add(jsonNode);
      }
      /// 透析後
      if (vitalInfoItem.BPCLASS == 2) {
        afterNodes.add(jsonNode);
      }

      // 体温値が存在するものをListに格納
      if (vitalInfoItem.temperature != null) {
        temperatureNodes.add(jsonNode);
      }
    }

    // 透析前最新値をフィールドに格納
    if (beforeNodes.size() > 0) {
      int latestIdx_before = Utilities.getLatestOccurDateIndex(beforeNodes);
      JsonNode latestBeforeNode = beforeNodes.get(latestIdx_before);
      this.bpMaxBefore = latestBeforeNode.get("bp_max").asText();
      this.bpMinBefore = latestBeforeNode.get("bp_min").asText();
      this.bpAveBefore = latestBeforeNode.get("bp_ave").asText();
      this.pulseBefore = latestBeforeNode.get("pulse").asText();
    }

    // 透析後最新値をフィールドに格納
    if (afterNodes.size() > 0) {
      int latestIdx_after = Utilities.getLatestOccurDateIndex(afterNodes);
      JsonNode latestAfterNode = afterNodes.get(latestIdx_after);
      this.bpMaxAfter = latestAfterNode.get("bp_max").asText();
      this.bpMinAfter = latestAfterNode.get("bp_min").asText();
      this.bpAveAfter = latestAfterNode.get("bp_ave").asText();
      this.pulseAfter = latestAfterNode.get("pulse").asText();
    }

    // 体温最新値をフィールドに格納
    if (temperatureNodes.size() > 0) {
      int latestIdx_temperature = Utilities.getLatestOccurDateIndex(temperatureNodes);
      JsonNode latestTemperatureNode = temperatureNodes.get(latestIdx_temperature);
      this.temperature = latestTemperatureNode.get("temperature").asText();
    }

  }

  /**
   * JSONノードからVitalInfoItemへ展開する。
   * @param jsonNode
   * @return
   */
  private VitalInfoItem createVitalInfoItem(JsonNode jsonNode) {
    // 各要素のノードを取得
    JsonNode ctlNo_node = jsonNode.get("ctl_no");
    JsonNode inputClass_node = jsonNode.get("input_class");
    JsonNode BPCLASS_node = jsonNode.get("BP_CLASS");
    JsonNode occurDate_node = jsonNode.get("occur_date");
    //    JsonNode bpClass_node = jsonNode.get("bp_class");
    JsonNode bpMax_node = jsonNode.get("bp_max");
    JsonNode bpMin_node = jsonNode.get("bp_min");
    JsonNode bpAve_node = jsonNode.get("bp_ave");
    JsonNode bloodSugarLevel_node = jsonNode.get("blood_sugar_level");
    JsonNode pulse_node = jsonNode.get("pulse");
    JsonNode temperature_node = jsonNode.get("temperature");

    // 戻り値に格納
    VitalInfoItem rtn = new VitalInfoItem();
    rtn.ctlNo = ctlNo_node.asInt();
    rtn.inputClass = inputClass_node.asInt();
    rtn.BPCLASS = BPCLASS_node.asInt();
    rtn.occurDate = Utilities.dateStringToDate_iso8601(occurDate_node.asText());
    rtn.bpMax = bpMax_node.asText();
    rtn.bpMin = bpMin_node.asText();
    rtn.bpAve = bpAve_node.asText();
    rtn.bloodSugarLevel = bloodSugarLevel_node.asText();
    rtn.pulse = pulse_node.asText();
    rtn.temperature = temperature_node.asText();

    return rtn;
  }
}
