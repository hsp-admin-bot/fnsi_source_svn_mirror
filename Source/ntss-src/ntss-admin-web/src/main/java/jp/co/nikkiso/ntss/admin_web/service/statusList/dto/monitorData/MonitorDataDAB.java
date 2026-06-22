package jp.co.nikkiso.ntss.admin_web.service.statusList.dto.monitorData;


import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

import lombok.Getter;

/**
 *  モニタデータ(DAB)クラス.
 */
@Getter
//@Setter
public class MonitorDataDAB implements MonitorData {
  /** 1:工程 **/
  MonitorDataItem processName;
  /** 2:貯槽濃度 **/
  MonitorDataItem reserverCONC;
  /** 3:透析液濃度 **/
  MonitorDataItem dialysateCONC;
  /** 4:Ｂ液濃度 **/
  MonitorDataItem B_SolutionCONC;
  /** 5:予備 **/
  /** 6:Ｂ原液濃度 **/
  MonitorDataItem B_StockSolutionCONC;
  /** 7:Ａ原液濃度 **/
  MonitorDataItem A_StockSolutionCONC;
  /** 8:貯槽液温度 **/
  MonitorDataItem reserverSolutionTEMP;
  /** 9:給水流量（水計量シリンダー） **/
  MonitorDataItem waterFlow_Cylinder;
  /** 10:給水流量（渦流量計） **/
  MonitorDataItem waterFlow_Vortex;
  /** 11:給水圧 **/
  MonitorDataItem waterPressure;
  /** 12:送液圧 **/
  MonitorDataItem sendingPressure;
  /** 13:予備 **/
  /** 14:給水流量(FM1) **/
  MonitorDataItem waterFlow_FM1;
  /** 15:給水流量(FM2) **/
  MonitorDataItem waterFlow_FM2;
  /** 16:予備 **/
  /** 17:予備 **/
  /** 18:予備 **/
  /** 19:予備 **/
  /** 20:予備 **/
  /** 21:Ｂ液濃度警報点（上限） **/
  MonitorDataItem B_SolutionConcAlarmPoint_Upper;
  /** 22:Ｂ液濃度警報点（下限） **/
  MonitorDataItem B_SolutionConcAlarmPoint_Lower;
  /** 23:透析液濃度警報点（上限） **/
  MonitorDataItem dialysateConcAlarmPoint_Upper;
  /** 24:透析液濃度警報点（下限） **/
  MonitorDataItem dialysateConcAlarmPoint_Lower;
  /** 25:貯槽濃度警報点（上限） **/
  MonitorDataItem reserverConcAlarmPoint_Upper;
  /** 26:貯槽濃度警報点（下限） **/
  MonitorDataItem reserverConcAlarmPoint_Lower;
  /** 27:予備 **/
  /** 28:予備 **/
  /** 29:透析液温度警報点（上限） **/
  MonitorDataItem dialysateTempAlarmPoint_Upper;
  /** 30:透析液温度警報点（下限） **/
  MonitorDataItem dialysateTempAlarmPoint_Lower;
  /** 31:給水圧警報点（下限） **/
  MonitorDataItem waterPressureAlarmPoint_Lower;
  /** 32:送液圧警報点（下限） **/
  MonitorDataItem sendingPressureAlarmPoint_Lower;

  /** 33:予備 **/
  /** 34:予備 **/
  /** 35:予備 **/
  /** 36:予備 **/
  /** 37:予備 **/
  /** 38:予備 **/
  /** 39:予備 **/
  /** 40:予備 **/

  /**
   * コンストラクタ
   * モニタデータのJSON文字列から各値がクラスフィールドに展開されます。
   * @param moniData モニタデータのJSON文字列
   */
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
  public MonitorDataDAB(String moniData)  throws tools.jackson.core.JacksonException {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
    if (moniData != null && !moniData.isEmpty()) {
      // 引数を展開
      this.setItems(moniData);
    }
  }

  /**
   * 項目コード(1～40)を指定して、値を取得します。
   * @param itemCd DABモニタデータ項目番号(アドレス)
   * @return
   */
  @Override
  public MonitorDataItem getByItemCd(int itemCd) {
    MonitorDataItem rtn = null;

    if (itemCd == 1) {
      rtn = this.processName;
    }
    if (itemCd == 2) {
      rtn = this.reserverCONC;
    }
    if (itemCd == 3) {
      rtn = this.dialysateCONC;
    }
    if (itemCd == 4) {
      rtn = this.B_SolutionCONC;
    }

    // 5:予備

    if (itemCd == 6) {
      rtn = this.B_StockSolutionCONC;
    }
    if (itemCd == 7) {
      rtn = this.A_StockSolutionCONC;
    }
    if (itemCd == 8) {
      rtn = this.reserverSolutionTEMP;
    }
    if (itemCd == 9) {
      rtn = this.waterFlow_Cylinder;
    }
    if (itemCd == 10) {
      rtn = this.waterFlow_Vortex;
    }
    if (itemCd == 11) {
      rtn = this.waterPressure;
    }
    if (itemCd == 12) {
      rtn = this.sendingPressure;
    }

    // 13:予備

    if (itemCd == 14) {
      rtn = this.waterFlow_FM1;
    }
    if (itemCd == 15) {
      rtn = this.waterFlow_FM2;
    }

    // 16～20:予備

    if (itemCd == 21) {
      rtn = this.B_SolutionConcAlarmPoint_Upper;
    }
    if (itemCd == 22) {
      rtn = this.B_SolutionConcAlarmPoint_Lower;
    }
    if (itemCd == 23) {
      rtn = this.dialysateConcAlarmPoint_Upper;
    }
    if (itemCd == 24) {
      rtn = this.dialysateConcAlarmPoint_Lower;
    }
    if (itemCd == 25) {
      rtn = this.reserverConcAlarmPoint_Upper;
    }
    if (itemCd == 26) {
      rtn = this.reserverConcAlarmPoint_Lower;
    }

    // 27~28：予備

    if (itemCd == 29) {
      rtn = this.dialysateTempAlarmPoint_Upper;
    }
    if (itemCd == 30) {
      rtn = this.dialysateTempAlarmPoint_Lower;
    }
    if (itemCd == 31) {
      rtn = this.waterPressureAlarmPoint_Lower;
    }
    if (itemCd == 32) {
      rtn = this.sendingPressureAlarmPoint_Lower;
    }
    // 33～40:予備

    return rtn;
  }

  /**
   * モニタデータをクラスフィールドに展開します。
   * @param moniDataJsonString バイタル情報のJSON文字列
   */
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
  private void setItems(String moniDataJsonString) throws tools.jackson.core.JacksonException {
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
    final String CONC_UNIT = "mS/cm";
    final String TEMP_UNIT = "℃";
    final String FLOW_UNIT = "L/min";
    final String PRESSURE_UNIT = "kPa";

    if (moniDataJsonString != null) {
      ObjectMapper mapper = new ObjectMapper();
      try {
        JsonNode jsonNode = mapper.readTree(moniDataJsonString);

        // インスタンス変数に各値をセット
        /** 1:工程 **/
        this.processName = new MonitorDataItem();
        if (this.getJsonValueByKey(jsonNode, "1") != null) {
          this.processName.value = this.getProcessName(Integer.parseInt(this.getJsonValueByKey(jsonNode, "1")));
        }

        /** 2:貯槽濃度 **/
        this.reserverCONC = new MonitorDataItem();
        this.reserverCONC.value = this.getJsonValueByKey(jsonNode, "2");
        this.reserverCONC.Unit = CONC_UNIT;

        /** 3:透析液濃度 **/
        this.dialysateCONC = new MonitorDataItem();
        this.dialysateCONC.value = this.getJsonValueByKey(jsonNode, "3");
        this.dialysateCONC.Unit = CONC_UNIT;

        /** 4:Ｂ液濃度 **/
        this.B_SolutionCONC = new MonitorDataItem();
        this.B_SolutionCONC.value = this.getJsonValueByKey(jsonNode, "4");
        this.B_SolutionCONC.Unit = CONC_UNIT;

        /** 6:Ｂ原液濃度 **/
        this.B_StockSolutionCONC = new MonitorDataItem();
        this.B_StockSolutionCONC.value = this.getJsonValueByKey(jsonNode, "6");
        this.B_StockSolutionCONC.Unit = CONC_UNIT;

        /** 7:Ａ原液濃度 **/
        this.A_StockSolutionCONC = new MonitorDataItem();
        this.A_StockSolutionCONC.value = this.getJsonValueByKey(jsonNode, "7");
        this.A_StockSolutionCONC.Unit = CONC_UNIT;

        /** 8:貯槽液温度 **/
        this.reserverSolutionTEMP = new MonitorDataItem();
        this.reserverSolutionTEMP.value = this.getJsonValueByKey(jsonNode, "8");
        this.reserverSolutionTEMP.Unit = TEMP_UNIT;

        /** 9:給水流量（水計量シリンダー） **/
        this.waterFlow_Cylinder = new MonitorDataItem();
        this.waterFlow_Cylinder.value = this.getJsonValueByKey(jsonNode, "9");
        this.waterFlow_Cylinder.Unit = FLOW_UNIT;

        /** 10:給水流量（渦流量計） **/
        this.waterFlow_Vortex = new MonitorDataItem();
        this.waterFlow_Vortex.value = this.getJsonValueByKey(jsonNode, "10");
        this.waterFlow_Vortex.Unit = FLOW_UNIT;

        /** 11:給水圧 **/
        this.waterPressure = new MonitorDataItem();
        this.waterPressure.value = this.getJsonValueByKey(jsonNode, "11");
        this.waterPressure.Unit = PRESSURE_UNIT;

        /** 12:送液圧 **/
        this.sendingPressure = new MonitorDataItem();
        this.sendingPressure.value = this.getJsonValueByKey(jsonNode, "12");
        this.sendingPressure.Unit = PRESSURE_UNIT;

        /** 14:給水流量(FM1) **/
        this.waterFlow_FM1 = new MonitorDataItem();
        this.waterFlow_FM1.value = this.getJsonValueByKey(jsonNode, "14");
        this.waterFlow_FM1.Unit = FLOW_UNIT;

        /** 15:給水流量(FM2) **/
        this.waterFlow_FM2 = new MonitorDataItem();
        this.waterFlow_FM2.value = this.getJsonValueByKey(jsonNode, "15");
        this.waterFlow_FM2.Unit = FLOW_UNIT;

        /** 21:Ｂ液濃度警報点（上限） **/
        this.B_SolutionConcAlarmPoint_Upper = new MonitorDataItem();
        this.B_SolutionConcAlarmPoint_Upper.value = this.getJsonValueByKey(jsonNode, "21");
        this.B_SolutionConcAlarmPoint_Upper.Unit = CONC_UNIT;

        /** 22:Ｂ液濃度警報点（下限） **/
        this.B_SolutionConcAlarmPoint_Lower = new MonitorDataItem();
        this.B_SolutionConcAlarmPoint_Lower.value = this.getJsonValueByKey(jsonNode, "22");
        this.B_SolutionConcAlarmPoint_Lower.Unit = CONC_UNIT;

        /** 23:透析液濃度警報点（上限） **/
        this.dialysateConcAlarmPoint_Upper = new MonitorDataItem();
        this.dialysateConcAlarmPoint_Upper.value = this.getJsonValueByKey(jsonNode, "23");
        this.dialysateConcAlarmPoint_Upper.Unit = CONC_UNIT;

        /** 24:透析液濃度警報点（下限） **/
        this.dialysateConcAlarmPoint_Lower = new MonitorDataItem();
        this.dialysateConcAlarmPoint_Lower.value = this.getJsonValueByKey(jsonNode, "24");
        this.dialysateConcAlarmPoint_Lower.Unit = CONC_UNIT;

        /** 25:貯槽濃度警報点（上限） **/
        this.reserverConcAlarmPoint_Upper = new MonitorDataItem();
        this.reserverConcAlarmPoint_Upper.value = this.getJsonValueByKey(jsonNode, "25");
        this.reserverConcAlarmPoint_Upper.Unit = CONC_UNIT;

        /** 26:貯槽濃度警報点（下限） **/
        this.reserverConcAlarmPoint_Lower = new MonitorDataItem();
        this.reserverConcAlarmPoint_Lower.value = this.getJsonValueByKey(jsonNode, "26");
        this.reserverConcAlarmPoint_Lower.Unit = CONC_UNIT;

        /** 29:透析液温度警報点（上限） **/
        this.dialysateTempAlarmPoint_Upper = new MonitorDataItem();
        this.dialysateTempAlarmPoint_Upper.value = this.getJsonValueByKey(jsonNode, "29");
        this.dialysateTempAlarmPoint_Upper.Unit = TEMP_UNIT;

        /** 30:透析液温度警報点（下限） **/
        this.dialysateTempAlarmPoint_Lower = new MonitorDataItem();
        this.dialysateTempAlarmPoint_Lower.value = this.getJsonValueByKey(jsonNode, "30");
        this.dialysateTempAlarmPoint_Lower.Unit = TEMP_UNIT;

        /** 31:給水圧警報点（下限） **/
        this.waterPressureAlarmPoint_Lower = new MonitorDataItem();
        this.waterPressureAlarmPoint_Lower.value = this.getJsonValueByKey(jsonNode, "31");
        this.waterPressureAlarmPoint_Lower.Unit = PRESSURE_UNIT;

        /** 32:送液圧警報点（下限） **/
        this.sendingPressureAlarmPoint_Lower = new MonitorDataItem();
        this.sendingPressureAlarmPoint_Lower.value = this.getJsonValueByKey(jsonNode, "32");
        this.sendingPressureAlarmPoint_Lower.Unit = PRESSURE_UNIT;

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
   * JSONノードから指定したキーの値を文字列として取得する。
   * 指定したキーがノードにない場合、nullを返す。
   * @param jsonNode
   * @param key
   * @return
   */
  private String getJsonValueByKey(JsonNode jsonNode, String key) {
    String rtn;
    JsonNode node = jsonNode.get(key);
    // キー存在判定
    if (node != null) {
      // キーが存在する場合はその値を返す
      rtn = node.asText();
    } else {
      // キーが存在しない場合はnullを返す
      rtn = null;
    }

    return rtn;
  }

  /**
   * 工程コードから工程名称を取得する
   * @param cd 工程コード(1～10)
   * @return 工程名称
   */
  private String getProcessName(int cd) {
    String rtn;
    switch (cd) {
    case 1:
      rtn = "透析";
      break;
    case 2:
      rtn = "予備透析";
      break;
    case 3:
      rtn = "液置換";
      break;
    case 4:
      rtn = "薬液消毒";
      break;
    case 5:
      rtn = "滞留消毒";
      break;
    case 6:
      rtn = "熱湯消毒";
      break;
    case 7:
      rtn = "酸洗浄";
      break;
    case 8:
      rtn = "洗浄";
      break;
    case 9:
      rtn = "排液";
      break;
    case 10:
      rtn = "プリセット";
      break;
    default:
      rtn = null;
    }

    return rtn;
  }

}
