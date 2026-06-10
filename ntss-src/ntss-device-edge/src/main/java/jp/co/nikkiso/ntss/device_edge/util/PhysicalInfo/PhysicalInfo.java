package jp.co.nikkiso.ntss.device_edge.util.PhysicalInfo;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;

import lombok.Getter;
import org.joda.time.DateTime;

/**
 *  身体情報情報クラス.
 */
@Getter
//@Setter
public class PhysicalInfo {
  /* 管理番号(全レコードの中の現在日付以前のnull以外の最新データ、それぞれが同じ検査日のデータとなっていないことに注意) */
  Integer ctlNo;
  /* 検査日時(全レコードの中の現在日付以前のnull以外の最新データ、それぞれが同じ検査日のデータとなっていないことに注意) */
  String examDate;
  /*検査区分(全レコードの中の現在日付以前のnull以外の最新データ、それぞれが同じ検査日のデータとなっていないことに注意) */
  Integer orderClass;
  /* 身長(全レコードの中の現在日付以前のnull以外の最新データ、それぞれが同じ検査日のデータとなっていないことに注意) */
  String height;
  /* 検査時の体重(全レコードの中の現在日付以前のnull以外の最新データ、それぞれが同じ検査日のデータとなっていないことに注意) */
  // #11175 2024.10.17 mod ctr_weight は文字列で保存されている TDC片口 start
//  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
//  //String ctrWeight;
//  BigDecimal ctrWeight;
//  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
  private String ctrWeight;
  // #11175 2024.10.17 mod ctr_weight は文字列で保存されている TDC片口 end
  /* 心横径(全レコードの中の現在日付以前のnull以外の最新データ、それぞれが同じ検査日のデータとなっていないことに注意) */
  String breastDia;
  /* 胸郭横径(全レコードの中の現在日付以前のnull以外の最新データ、それぞれが同じ検査日のデータとなっていないことに注意) */
  String chestDia;
  /* CTR(全レコードの中の現在日付以前のnull以外の最新データ、それぞれが同じ検査日のデータとなっていないことに注意) */
  String ctr;
  /* DW(全レコードの中の現在日付以前のnull以外の最新データ、それぞれが同じ検査日のデータとなっていないことに注意) */
  String dw;
  /* 目標体重(全レコードの中の現在日付以前のnull以外の最新データ、それぞれが同じ検査日のデータとなっていないことに注意) */
  String targetWeight;
  /* 指示者(全レコードの中の現在日付以前のnull以外の最新データ、それぞれが同じ検査日のデータとなっていないことに注意) */
  String indicatorCd;
  /*  コメント(全レコードの中の現在日付以前のnull以外の最新データ、それぞれが同じ検査日のデータとなっていないことに注意) */
  String memo;
  /* 前体重許容割合（上限）(全レコードの中の現在日付以前のnull以外の最新データ、それぞれが同じ検査日のデータとなっていないことに注意) */
  String preScaleUpper;
  /* 前体重許容割合（下限）(全レコードの中の現在日付以前のnull以外の最新データ、それぞれが同じ検査日のデータとなっていないことに注意) */
  String preScaleLower;
  /* PhysicalInfoのデータ数 */ // #9147 2024.03.14 add 次患者整形 指示DW→無ければpat_uniqueの透析日以前の最新DW TDC山崎
  final int DATA_COUNT = 14;
    /** 全記録リスト **/
  List<PhysicalInfoItem> allRecords;

  /**
   * コンストラクタ
   * 身体情報をクラスフィールドに展開します。
   * フィールドには最新(ctl_noの最大レコード)値を保持します。
   * すべての記録はgetAllRecordsメソッドで取り出して下さい。
   * @param physicalInfo 身体情報のJSON文字列
   */
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
  public PhysicalInfo(String physicalInfo, String treatDateYYYYMMDD) throws JsonProcessingException {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    // allRecordsフィールドを初期化
    this.allRecords = new ArrayList<PhysicalInfoItem>();
    // 引数を展開
    this.setPhysicalInfo(physicalInfo, treatDateYYYYMMDD);
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
      // #11175 2024.10.17 mod ctr_weight は文字列で保存されている TDC片口 start
//      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
//      //rtn = ctrWeight;
//      rtn = ctrWeight.toString();
//      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      rtn = ctrWeight;
      // #11175 2024.10.17 mod ctr_weight は文字列で保存されている TDC片口 end
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
    } catch (JsonProcessingException e) {
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
  private void setPhysicalInfo(String physicalInfo, String treatDateYYYYMMDD) throws JsonProcessingException {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    if (physicalInfo != null) {
      ObjectMapper mapper = new ObjectMapper();
      try {
        JsonNode jsonNode_parent = mapper.readTree(physicalInfo);
        this.setItems(jsonNode_parent, treatDateYYYYMMDD);

      } catch (IOException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//        e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
        throw e;
      }
    }
  }

  /**
   * 身体情報のJSONノード配列から各フィールドへ展開する。
   * @param jsonNodeArray
   */
  private void setItems(JsonNode jsonNodeArray, String treatDateYYYYMMDD) {

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
    // #9147 2024.03.14 chg 次患者整形 指示DW→無ければpat_uniqueの透析日以前の最新DW TDC山崎 start
//    for (int lop = 0; lop < jsonNodeArray.size(); lop++) {
//      PhysicalInfoItem item = this.allRecords.get(lop);
//
//      if (this.ctlNo == null) {
//        this.ctlNo = item.getCtlNo();
//      }
//      if (this.examDate == null || this.examDate.equals("")) {
//        this.examDate = item.getExamDate();
//        if (this.examDate != null && this.examDate.equals("null")) {
//          this.examDate = null;
//        }
//      }
//      if (this.orderClass == null) {
//        this.orderClass = item.getOrderClass();
//      }
//      if (this.height == null || this.height.equals("")) {
//        this.height = item.getHeight();
//        if (this.height != null && this.height.equals("null")) {
//          this.height = null;
//        }
//      }
//      if (this.ctrWeight == null || this.ctrWeight.equals("")) {
//        this.ctrWeight = item.getCtrWeight();
//        if (this.ctrWeight != null && this.ctrWeight.equals("null")) {
//          this.ctrWeight = null;
//        }
//      }
//      if (this.breastDia == null || this.breastDia.equals("")) {
//        this.breastDia = item.getBreastDia();
//        if (this.breastDia != null && this.breastDia.equals("null")) {
//          this.breastDia = null;
//        }
//      }
//      if (this.chestDia == null || this.chestDia.equals("")) {
//        this.chestDia = item.getChestDia();
//        if (this.chestDia != null && this.chestDia.equals("null")) {
//          this.chestDia = null;
//        }
//      }
//      if (this.ctr == null || this.ctr.equals("")) {
//        this.ctr = item.getCtr();
//        if (this.ctr != null && this.ctr.equals("null")) {
//          this.ctr = null;
//        }
//      }
//      if (this.dw == null || this.dw.equals("")) {
//        this.dw = item.getDw();
//        if (this.dw != null && this.dw.equals("null")) {
//          this.dw = null;
//        }
//      }
//      if (this.targetWeight == null || this.targetWeight.equals("")) {
//        this.targetWeight = item.getTargetWeight();
//        if (this.targetWeight != null && this.targetWeight.equals("null")) {
//          this.targetWeight = null;
//        }
//      }
//      if (this.indicatorCd == null || this.indicatorCd.equals("")) {
//        this.indicatorCd = item.getIndicatorCd();
//        if (this.indicatorCd != null && this.indicatorCd.equals("null")) {
//          this.indicatorCd = null;
//        }
//      }
//      if (this.memo == null || this.memo.equals("")) {
//        this.memo = item.getMemo();
//        if (this.memo != null && this.memo.equals("null")) {
//          this.memo = null;
//        }
//      }
//      if (this.preScaleUpper == null || this.preScaleUpper.equals("")) {
//        this.preScaleUpper = item.getPreScaleUpper();
//        if (this.preScaleUpper != null && this.preScaleUpper.equals("null")) {
//          this.preScaleUpper = null;
//        }
//      }
//      if (this.preScaleLower == null || this.preScaleLower.equals("")) {
//        this.preScaleLower = item.getPreScaleLower();
//        if (this.preScaleLower != null && this.preScaleLower.equals("null")) {
//          this.preScaleLower = null;
//        }
//      }
//    }

    // #9147 2024.06.26 add 次患者整形 指示DW→無ければpat_uniqueの透析日以前の最新DW TDC山崎 start
    String yyyy_mm_dd;
    if (treatDateYYYYMMDD.isEmpty()) {
      yyyy_mm_dd = DateTime.now().toString("yyyy-MM-dd");
    } else {
      yyyy_mm_dd = treatDateYYYYMMDD.substring(0, 4) + "-" + treatDateYYYYMMDD.substring(4, 6) + "-" + treatDateYYYYMMDD.substring(6, 8);
    }
    // #9147 2024.06.26 add 次患者整形 指示DW→無ければpat_uniqueの透析日以前の最新DW TDC山崎 end
    int setDataCount = 0;
    for (int lop = 0; lop < jsonNodeArray.size(); lop++) {
      if (setDataCount >= DATA_COUNT) {
        break; // 全部セットされたのでループ終了
      }

      PhysicalInfoItem item = this.allRecords.get(lop);
      // #9147 2024.06.26 chg 次患者整形 指示DW→無ければpat_uniqueの透析日以前の最新DW TDC山崎 start
//      if (item.examDate.compareTo(DateTime.now().toString("yyyy-MM-dd")) > 0) {
//        continue; // 現在日付より未来方向のデータは採用しないで次のループへ
//      }
      if (item.examDate.compareTo(yyyy_mm_dd) > 0) {
        continue; // 未来方向のデータは採用しないで次のループへ
      }
      // #9147 2024.06.26 chg 次患者整形 指示DW→無ければpat_uniqueの透析日以前の最新DW TDC山崎 end

      if (this.ctlNo == null) {
        this.ctlNo = item.getCtlNo();
        if (this.ctlNo != null) { setDataCount++; }
      }
      if (this.examDate == null || this.examDate.equals("")) {
        this.examDate = item.getExamDate();
        if (this.examDate != null && this.examDate.equals("null")) { this.examDate = null; }
        if (this.examDate != null) { setDataCount++; }
      }
      if (this.orderClass == null) {
        this.orderClass = item.getOrderClass();
        if (this.orderClass != null) { setDataCount++; }
      }
      if (this.height == null || this.height.equals("")) {
        this.height = item.getHeight();
        if (this.height != null && this.height.equals("null")) { this.height = null; }
        if (this.height != null) { setDataCount++; }
      }
      if (this.ctrWeight == null || this.ctrWeight.equals("")) {
        this.ctrWeight = item.getCtrWeight();
        if (this.ctrWeight != null && this.ctrWeight.equals("null")) { this.ctrWeight = null; }
        if (this.ctrWeight != null) { setDataCount++; }
      }
      if (this.breastDia == null || this.breastDia.equals("")) {
        this.breastDia = item.getBreastDia();
        if (this.breastDia != null && this.breastDia.equals("null")) { this.breastDia = null; }
        if (this.breastDia != null) { setDataCount++; }
      }
      if (this.chestDia == null || this.chestDia.equals("")) {
        this.chestDia = item.getChestDia();
        if (this.chestDia != null && this.chestDia.equals("null")) { this.chestDia = null; }
        if (this.chestDia != null) { setDataCount++; }
      }
      if (this.ctr == null || this.ctr.equals("")) {
        this.ctr = item.getCtr();
        if (this.ctr != null && this.ctr.equals("null")) { this.ctr = null; }
        if (this.ctr != null) { setDataCount++; }
      }
      if (this.dw == null || this.dw.equals("")) {
        this.dw = item.getDw();
        if (this.dw != null && this.dw.equals("null")) { this.dw = null; }
        if (this.dw != null) { setDataCount++; }
      }
      if (this.targetWeight == null || this.targetWeight.equals("")) {
        this.targetWeight = item.getTargetWeight();
        if (this.targetWeight != null && this.targetWeight.equals("null")) { this.targetWeight = null; }
        if (this.targetWeight != null) { setDataCount++; }
      }
      if (this.indicatorCd == null || this.indicatorCd.equals("")) {
        this.indicatorCd = item.getIndicatorCd();
        if (this.indicatorCd != null && this.indicatorCd.equals("null")) { this.indicatorCd = null; }
        if (this.indicatorCd != null) { setDataCount++; }
      }
      if (this.memo == null || this.memo.equals("")) {
        this.memo = item.getMemo();
        if (this.memo != null && this.memo.equals("null")) { this.memo = null; }
        if (this.memo != null) { setDataCount++; }
      }
      if (this.preScaleUpper == null || this.preScaleUpper.equals("")) {
        this.preScaleUpper = item.getPreScaleUpper();
        if (this.preScaleUpper != null && this.preScaleUpper.equals("null")) { this.preScaleUpper = null; }
        if (this.preScaleUpper != null) { setDataCount++; }
      }
      if (this.preScaleLower == null || this.preScaleLower.equals("")) {
        this.preScaleLower = item.getPreScaleLower();
        if (this.preScaleLower != null && this.preScaleLower.equals("null")) { this.preScaleLower = null; }
        if (this.preScaleLower != null) { setDataCount++; }
      }
    }
    // #9147 2024.03.14 chg 次患者整形 指示DW→無ければpat_uniqueの透析日以前の最新DW TDC山崎 end
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
    // #11175 2024.10.17 mod ctr_weight は文字列で保存されている TDC片口 start
//    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
//    //tn.ctrWeight = ctrWeight_node == null ? "" : ctrWeight_node.asText();
//    rtn.ctrWeight = ctrWeight_node == null ? null : ctrWeight_node.decimalValue();
//    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    rtn.ctrWeight = ctrWeight_node == null ? "" : ctrWeight_node.asText();
    // #11175 2024.10.17 mod ctr_weight は文字列で保存されている TDC片口 end
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
