package jp.co.nikkiso.ntss.admin_web.service.statusList.dto.offWaterInfo;

import java.math.BigDecimal;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
//add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.beans.factory.annotation.Autowired;
//add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end

import lombok.Getter;

/**
 *  除水補正情報クラス.
 */
@Getter
//@Setter
public class OffWaterInfo {
  OffWaterInfoItem item1;
  OffWaterInfoItem item2;
  OffWaterInfoItem item3;
  OffWaterInfoItem item4;
  OffWaterInfoItem item5;

  //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
  @Autowired
  private LogService logService;
  //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end

  /**
   * コンストラクタ
   * 除水補正情報をクラスフィールドに展開します。
   * @param offWaterInfo 除水補正情報のJSON文字列
   */
  public OffWaterInfo(String offWaterInfo) {
    // メンバ変数を初期化
    this.initialize();
    // 引数を展開
    this.setWeightInfo(offWaterInfo);
  }

  /**
   * 除水補正値1～5の合計値を取得します。
   * @return
   */
  public BigDecimal getOffWaterWeightTotal() {

    BigDecimal buf1 = this.item1.getWeight();
    if (buf1 == null) {
      return null;
    }
    BigDecimal buf2 = buf1.add(this.item2.getWeight());
    BigDecimal buf3 = buf2.add(this.item3.getWeight());
    BigDecimal buf4 = buf3.add(this.item4.getWeight());
    BigDecimal buf5 = buf4.add(this.item5.getWeight());

    return buf5;
  }

  /**
   * メンバ変数初期化処理
   */
  private void initialize() {
    this.item1 = new OffWaterInfoItem();
    this.item2 = new OffWaterInfoItem();
    this.item3 = new OffWaterInfoItem();
    this.item4 = new OffWaterInfoItem();
    this.item5 = new OffWaterInfoItem();
  }

  /**
   * 除水補正情報をクラスフィールドに展開します。
   * @param offWaterInfo 除水補正情報のJSON文字列
   */
  private void setWeightInfo(String offWaterInfo) {
    ObjectMapper mapper = new ObjectMapper();
    try {
      JsonNode jsonNode_parent = mapper.readTree(offWaterInfo);
      this.setItems(jsonNode_parent);

    } catch (Exception e) {
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("[offWaterInfo] JSONのパースに失敗しました。");
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
    JsonNode name1Node = jsonNode.get("name_1");
    JsonNode name2Node = jsonNode.get("name_2");
    JsonNode name3Node = jsonNode.get("name_3");
    JsonNode name4Node = jsonNode.get("name_4");
    JsonNode name5Node = jsonNode.get("name_5");
    JsonNode weight1Node = jsonNode.get("weight_1");
    JsonNode weight2Node = jsonNode.get("weight_2");
    JsonNode weight3Node = jsonNode.get("weight_3");
    JsonNode weight4Node = jsonNode.get("weight_4");
    JsonNode weight5Node = jsonNode.get("weight_5");

    // それぞれのJSONノードから値を取得
    this.item1.name = name1Node.asText();
    String weight1 = weight1Node.asText();
    if (weight1 == null || weight1.isEmpty()) {
      weight1 = "0.0";
    }
    this.item1.weight = new BigDecimal(weight1);

    this.item2.name = name2Node.asText();
    String weight2 = weight2Node.asText();
    if (weight2 == null || weight2.isEmpty()) {
      weight2 = "0.0";
    }
    this.item2.weight = new BigDecimal(weight2);

    this.item3.name = name3Node.asText();
    String weight3 = weight3Node.asText();
    if (weight3 == null || weight3.isEmpty()) {
      weight3 = "0.0";
    }
    this.item3.weight = new BigDecimal(weight3);

    this.item4.name = name4Node.asText();
    String weight4 = weight4Node.asText();
    if (weight4 == null || weight4.isEmpty()) {
      weight4 = "0.0";
    }
    this.item4.weight = new BigDecimal(weight4);

    this.item5.name = name5Node.asText();
    String weight5 = weight5Node.asText();
    if (weight5 == null || weight5.isEmpty()) {
      weight5 = "0.0";
    }
    this.item5.weight = new BigDecimal(weight5);
  }

}
