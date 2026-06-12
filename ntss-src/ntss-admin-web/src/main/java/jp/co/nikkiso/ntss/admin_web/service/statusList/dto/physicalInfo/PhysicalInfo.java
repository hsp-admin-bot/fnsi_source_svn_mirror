package jp.co.nikkiso.ntss.admin_web.service.statusList.dto.physicalInfo;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import tools.jackson.core.JacksonException;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import tools.jackson.databind.node.ObjectNode;

import lombok.Getter;

/**
 *  身体情報情報クラス.
 */
@Getter
//@Setter
public class PhysicalInfo {
  /* 管理番号 */
  Integer ctlNo;
  /* 検査日時 */
  String examDate;
  /*検査区分  */
  Integer orderClass;
  /* 身長 */
  String height;
  /* 検査時の体重 */
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
  //String ctrWeight;
  BigDecimal ctrWeight;
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
  /* 心横径 */
  String breastDia;
  /* 胸郭横径 */
  String chestDia;
  /* CTR */
  String ctr;
  /* DW */
  String dw;
  /* 目標体重 */
  String targetWeight;
  /* 指示者 */
  String indicatorCd;
  /*  コメント*/
  String memo;
  /* 前体重許容割合（上限） */
  String preScaleUpper;
  /* 前体重許容割合（下限） */
  String preScaleLower;
  /** 全記録リスト **/
  List<PhysicalInfoItem> allRecords;

  /**
   * コンストラクタ
   * 身体情報をクラスフィールドに展開します。
   * フィールドには最新(examin_dateの最大レコードから順に値があったもの)値を保持します。
   * すべての記録はgetAllRecordsメソッドで取り出して下さい。
   * @param physicalInfo 身体情報のJSON文字列
   */
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
  public PhysicalInfo(String physicalInfo)  throws tools.jackson.core.JacksonException {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    // allRecordsフィールドを初期化
    this.allRecords = new ArrayList<PhysicalInfoItem>();
    // 引数を展開
    this.setPhysicalInfo(physicalInfo);
  }

  /**
   * フィールド名を指定して該当の値を取得します。
   * @param fieldName
   * @return
   */
  public String getByFieldName(String fieldName) {
    String rtn = "";
    switch (fieldName) {
    case "ctl_no":
      rtn = ctlNo.toString();
      break;
    case "exam_date":
      rtn = examDate;
      break;
    case "order_class":
      rtn = orderClass.toString();
      break;
    case "height":
      rtn = height;
      break;
    case "ctr_weight":
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //rtn = ctrWeight;
      rtn = ctrWeight.toString();
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      break;
    case "breast_dia":
      rtn = breastDia;
      break;
    case "chest_dia":
      rtn = chestDia;
      break;
    case "ctr":
      rtn = ctr;
      break;
    case "dw":
      rtn = dw;
      break;
    case "target_weight":
      rtn = targetWeight;
      break;
    case "indicator_cd":
      rtn = indicatorCd;
      break;
    case "memo":
      rtn = memo;
      break;
    case "pre_scale_upper":
      rtn = preScaleUpper;
      break;
    case "pre_scale_lower":
      rtn = preScaleLower;
      break;
    }
    return rtn;
  }

  /**
   * このインスタンスが保持している値をJSON文字列として出力します。
   * 本メソッドで出力される内容はctl_noが最大の値セットのみです。
   */
  public String writeJsonString() {
    String rtn = "";
    // ObjectNode構築
    ObjectMapper mapper = new ObjectMapper();
    ObjectNode root = mapper.createObjectNode();
    // 各値をセット
    root.put("ctl_no", ctlNo);
    root.put("exam_date", examDate);
    root.put("order_class", orderClass);
    root.put("height", height);
    root.put("ctr_weight", ctrWeight);
    root.put("breast_dia", breastDia);
    root.put("chest_dia", chestDia);
    root.put("ctr", ctr);
    root.put("dw", dw);
    root.put("target_weight", targetWeight);
    root.put("indicator_cd", indicatorCd);
    root.put("memo", memo);
    root.put("pre_scale_upper", preScaleUpper);
    root.put("pre_scale_lower", preScaleLower);

    // JSON文字列として出力
    try {
      rtn = mapper.writeValueAsString(root);
    } catch (JacksonException e) {
      // 例外が発生した場合は空文字列を返す
      rtn = "";
    }
    return rtn;
  }

  /**
   * 身体情報をクラスフィールドに展開します。
   * @param physicalInfo 身体情報のJSON文字列
   */
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
  private void setPhysicalInfo(String physicalInfo)  throws tools.jackson.core.JacksonException {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    if (physicalInfo != null) {
      ObjectMapper mapper = new ObjectMapper();
      try {
        JsonNode jsonNode_parent = mapper.readTree(physicalInfo);
        this.setItems(jsonNode_parent);

      } catch (tools.jackson.core.JacksonException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        throw e;
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      }
    }
  }

  /**
   * 身体情報のJSONノード配列から各フィールドへ展開する。
   * @param jsonNodeArray
   */
  private void setItems(JsonNode jsonNodeArray) {

    for (int lop = 0; lop < jsonNodeArray.size(); lop++) {
      JsonNode jsonNode = jsonNodeArray.get(lop);
      // PhysicalInfoItemクラスに格納
      PhysicalInfoItem physicalInfoItem = this.createPhysicalInfoItem(jsonNode);
      // 全記録格納フィールドに追加
      this.allRecords.add(physicalInfoItem);
    }

    // 全記録格納フィールドを測定日時[ExaminDate]で降順ソート
    this.allRecords.sort((a, b) -> b.getExamDate().compareTo(a.getExamDate()));

    // 最新情報から各項目に情報がない場合に格納
    for (int lop = 0; lop < jsonNodeArray.size(); lop++) {
      PhysicalInfoItem item = this.allRecords.get(lop);
      if (this.ctlNo == null) {
        this.ctlNo = item.getCtlNo();
      }
      if (this.examDate == null || this.examDate.equals("")) {
        this.examDate = item.getExamDate();
        if (this.examDate != null && this.examDate.equals("null")) {
          this.examDate = null;
        }
      }
      if (this.orderClass == null) {
        this.orderClass = item.getOrderClass();
      }
      if (this.height == null || this.height.equals("")) {
        this.height = item.getHeight();
        if (this.height != null && this.height.equals("null")) {
          this.height = null;
        }
      }
      if (this.ctrWeight == null || this.ctrWeight.equals("")) {
        this.ctrWeight = item.getCtrWeight();
        if (this.ctrWeight != null && this.ctrWeight.equals("null")) {
          this.ctrWeight = null;
        }
      }
      if (this.breastDia == null || this.breastDia.equals("")) {
        this.breastDia = item.getBreastDia();
        if (this.breastDia != null && this.breastDia.equals("null")) {
          this.breastDia = null;
        }
      }
      if (this.chestDia == null || this.chestDia.equals("")) {
        this.chestDia = item.getChestDia();
        if (this.chestDia != null && this.chestDia.equals("null")) {
          this.chestDia = null;
        }
      }
      if (this.ctr == null || this.ctr.equals("")) {
        this.ctr = item.getCtr();
        if (this.ctr != null && this.ctr.equals("null")) {
          this.ctr = null;
        }
      }
      if (this.dw == null || this.dw.equals("")) {
        this.dw = item.getDw();
        if (this.dw != null && this.dw.equals("null")) {
          this.dw = null;
        }
      }
      if (this.targetWeight == null || this.targetWeight.equals("")) {
        this.targetWeight = item.getTargetWeight();
        if (this.targetWeight != null && this.targetWeight.equals("null")) {
          this.targetWeight = null;
        }
      }
      if (this.indicatorCd == null || this.indicatorCd.equals("")) {
        this.indicatorCd = item.getIndicatorCd();
        if (this.indicatorCd != null && this.indicatorCd.equals("null")) {
          this.indicatorCd = null;
        }
      }
      if (this.memo == null || this.memo.equals("")) {
        this.memo = item.getMemo();
        if (this.memo != null && this.memo.equals("null")) {
          this.memo = null;
        }
      }
      if (this.preScaleUpper == null || this.preScaleUpper.equals("")) {
        this.preScaleUpper = item.getPreScaleUpper();
        if (this.preScaleUpper != null && this.preScaleUpper.equals("null")) {
          this.preScaleUpper = null;
        }
      }
      if (this.preScaleLower == null || this.preScaleLower.equals("")) {
        this.preScaleLower = item.getPreScaleLower();
        if (this.preScaleLower != null && this.preScaleLower.equals("null")) {
          this.preScaleLower = null;
        }
      }
    }
  }

  /**
   * JSONノードからPhysicalInfoItemへ展開する。
   * @param jsonNode
   * @return
   */
  private PhysicalInfoItem createPhysicalInfoItem(JsonNode jsonNode) {
    // 各要素のノードを取得
    JsonNode ctlNo_node = jsonNode.get("ctl_no");
    JsonNode examDate_node = jsonNode.get("exam_date");
    JsonNode orderClass_node = jsonNode.get("order_class");
    JsonNode height_node = jsonNode.get("height");
    JsonNode ctrWeight_node = jsonNode.get("ctr_weight");
    JsonNode breastDia_node = jsonNode.get("breast_dia");
    JsonNode chestDia_node = jsonNode.get("chest_dia");
    JsonNode ctr_node = jsonNode.get("ctr");
    JsonNode dw_node = jsonNode.get("dw");
    JsonNode targetWeight_node = jsonNode.get("target_weight");
    JsonNode indicatorCd_node = jsonNode.get("indicator_cd");
    JsonNode memo_node = jsonNode.get("memo");
    JsonNode preScaleUpper_node = jsonNode.get("pre_scale_upper");
    JsonNode preScaleLower_node = jsonNode.get("pre_scale_lower");

    // 戻り値に格納
    PhysicalInfoItem rtn = new PhysicalInfoItem();
    rtn.ctlNo = ctlNo_node.asInt();
    rtn.examDate = examDate_node == null ? "" : examDate_node.asText();
    rtn.orderClass = orderClass_node == null ? null : orderClass_node.asInt();
    rtn.height = height_node == null ? "" : height_node.asText();
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
    //rtn.ctrWeight = ctrWeight_node == null ? "" : ctrWeight_node.asText();
    String tempCtrWeight = null;
    if(ctrWeight_node != null && !ctrWeight_node.isNull()) {
      tempCtrWeight = ctrWeight_node.asString();
    }
    rtn.ctrWeight = tempCtrWeight == null ? null : new BigDecimal(tempCtrWeight);
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    rtn.breastDia = breastDia_node == null ? "" : breastDia_node.asText();
    rtn.chestDia = chestDia_node == null ? "" : chestDia_node.asText();
    rtn.ctr = ctr_node == null ? "" : ctr_node.asText();
    rtn.dw = dw_node == null ? "" : dw_node.asText();
    rtn.targetWeight = targetWeight_node == null ? "" : targetWeight_node.asText();
    rtn.indicatorCd = indicatorCd_node == null ? "" : indicatorCd_node.asText();
    rtn.memo = memo_node == null ? "" : memo_node.asText();
    rtn.preScaleUpper = preScaleUpper_node == null ? "" : preScaleUpper_node.asText();
    rtn.preScaleLower = preScaleLower_node == null ? "" : preScaleLower_node.asText();

    return rtn;
  }
}
