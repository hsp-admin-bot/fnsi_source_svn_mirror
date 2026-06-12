package jp.co.nikkiso.ntss.admin_web.service.statusList.dto.monitorData;


import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

import lombok.Getter;

/**
 *  モニタデータ(DAD)クラス.
 */
@Getter
//@Setter
public class MonitorDataDAD implements MonitorData {
  /** 1:工程 **/
  MonitorDataItem processName;
  /** 2:B原液濃度 **/
  MonitorDataItem B_StockSolutionCONC;
  /** 3:A原液濃度 **/
  MonitorDataItem A_StockSolutionCONC;
  /** 4:給水圧 **/
  MonitorDataItem waterPressure;
  /** 5:薬液検知電圧 **/
  MonitorDataItem mediDitectVoltage;
  /** 6:B溶解槽温度 **/
  MonitorDataItem B_ReserverTEMP;
  /** 7:A溶解槽温度 **/
  MonitorDataItem A_ReserverTEMP;
  /** 8:B貯水槽原液残量 **/
  MonitorDataItem B_waterTankRemained;
  /** 9:A貯水槽原液残量 **/
  MonitorDataItem A_waterTankRemained;
  /** 10:B原液濃度警報点（上限） **/
  MonitorDataItem B_StockSolConcAlarmPoint_Upper;
  /** 11:B原液濃度警報点（下限） **/
  MonitorDataItem B_StockSolConcAlarmPoint_Lower;
  /** 12:A原液濃度警報点（上限） **/
  MonitorDataItem A_StockSolConcAlarmPoint_Upper;
  /** 13:A原液濃度警報点（下限） **/
  MonitorDataItem A_StockSolConcAlarmPoint_Lower;
  /** 14:給水圧警報点（下限） **/
  MonitorDataItem waterPressureAlarmPoint_Lower;
  /** 15:薬液消毒濃度下限報知点 **/
  MonitorDataItem mediSterilizationConcAlarmPoint_Lower;
  /** 16:薬液消毒漏れ警報点 **/
  MonitorDataItem mediSterilizationLeakAlarmPoint;
  /** 17:貯水槽原液減少報知点１ **/
  MonitorDataItem stockSolDecreaseInformPoint1;
  /** 18:貯水槽原液減少報知点２ **/
  MonitorDataItem stockSolDecreaseInformPoint2;
  /** 19:貯水槽原液減少報知点３ **/
  MonitorDataItem stockSolDecreaseInformPoint3;
  /** 20:B溶解槽温度警報（上限） **/
  MonitorDataItem B_ReserverTempAlarmPoint_Upper;
  /** 21:A溶解槽温度警報（上限） **/
  MonitorDataItem A_ReserverTempAlarmPoint_Upper;
  /** 22:溶解ボトル使用数 **/
  MonitorDataItem bottleUseCount;
  /** 23:残り薬剤数 **/
  MonitorDataItem mediRemained;
  /** 24:原液減予想時刻 **/
  MonitorDataItem stockSolLossTime;

  /**
   * コンストラクタ
   * モニタデータのJSON文字列から各値がクラスフィールドに展開されます。
   * @param moniData モニタデータのJSON文字列
   */
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
  public MonitorDataDAD(String moniData) throws tools.jackson.core.JacksonException {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
    if (moniData != null && !moniData.isEmpty()) {
      // 引数を展開
      this.setItems(moniData);
    }
  }

  /**
   * 項目コード(1～24)を指定して、値を取得します。
   * @param itemCd DADモニタデータ項目番号(アドレス)
   * @return
   */
  public MonitorDataItem getByItemCd(int itemCd) {
    MonitorDataItem rtn = null;

    if (itemCd == 1) {
      rtn = this.processName;
    }
    if (itemCd == 2) {
      rtn = this.B_StockSolutionCONC;
    }
    if (itemCd == 3) {
      rtn = this.A_StockSolutionCONC;
    }
    if (itemCd == 4) {
      rtn = this.waterPressure;
    }
    if (itemCd == 5) {
      rtn = this.mediDitectVoltage;
    }
    if (itemCd == 6) {
      rtn = this.B_ReserverTEMP;
    }
    if (itemCd == 7) {
      rtn = this.A_ReserverTEMP;
    }
    if (itemCd == 8) {
      rtn = this.B_waterTankRemained;
    }
    if (itemCd == 9) {
      rtn = this.A_waterTankRemained;
    }
    if (itemCd == 10) {
      rtn = this.B_StockSolConcAlarmPoint_Upper;
    }
    if (itemCd == 11) {
      rtn = this.B_StockSolConcAlarmPoint_Lower;
    }
    if (itemCd == 12) {
      rtn = this.A_StockSolConcAlarmPoint_Upper;
    }
    if (itemCd == 13) {
      rtn = this.A_StockSolConcAlarmPoint_Lower;
    }
    if (itemCd == 14) {
      rtn = this.waterPressureAlarmPoint_Lower;
    }
    if (itemCd == 15) {
      rtn = this.mediSterilizationConcAlarmPoint_Lower;
    }
    if (itemCd == 16) {
      rtn = this.mediSterilizationLeakAlarmPoint;
    }
    if (itemCd == 17) {
      rtn = this.stockSolDecreaseInformPoint1;
    }
    if (itemCd == 18) {
      rtn = this.stockSolDecreaseInformPoint2;
    }
    if (itemCd == 19) {
      rtn = this.stockSolDecreaseInformPoint3;
    }
    if (itemCd == 20) {
      rtn = this.B_ReserverTempAlarmPoint_Upper;
    }
    if (itemCd == 21) {
      rtn = this.A_ReserverTempAlarmPoint_Upper;
    }
    if (itemCd == 22) {
      rtn = this.bottleUseCount;
    }
    if (itemCd == 23) {
      rtn = this.mediRemained;
    }
    if (itemCd == 24) {
      rtn = this.stockSolLossTime;
    }

    return rtn;
  }

  /**
   * モニタデータをクラスフィールドに展開します。
   * @param moniDataJsonString バイタル情報のJSON文字列
   */
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
  private void setItems(String moniDataJsonString) throws tools.jackson.core.JacksonException {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
    final String TEMP_UNIT = "℃";
    final String PRESSURE_UNIT = "kPa";
    final String VOLUME_UNIT = "L";
    final String CONC_UNIT = "mS/cm";
    final String VOLTAGE_UNIT = "V";
    final String SET_UNIT = "セット";

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

        /** 2:B原液濃度 **/
        this.B_StockSolutionCONC = new MonitorDataItem();
        this.B_StockSolutionCONC.value = this.getJsonValueByKey(jsonNode, "2");
        this.B_StockSolutionCONC.Unit = CONC_UNIT;

        /** 3:A原液濃度 **/
        this.A_StockSolutionCONC = new MonitorDataItem();
        this.A_StockSolutionCONC.value = this.getJsonValueByKey(jsonNode, "3");
        this.A_StockSolutionCONC.Unit = CONC_UNIT;

        /** 4:給水圧 **/
        this.waterPressure = new MonitorDataItem();
        this.waterPressure.value = this.getJsonValueByKey(jsonNode, "4");
        this.waterPressure.Unit = PRESSURE_UNIT;

        /** 5:薬液検知電圧 **/
        this.mediDitectVoltage = new MonitorDataItem();
        this.mediDitectVoltage.value = this.getJsonValueByKey(jsonNode, "5");
        this.mediDitectVoltage.Unit = VOLTAGE_UNIT;

        /** 6:B溶解槽温度 **/
        this.B_ReserverTEMP = new MonitorDataItem();
        this.B_ReserverTEMP.value = this.getJsonValueByKey(jsonNode, "6");
        this.B_ReserverTEMP.Unit = TEMP_UNIT;

        /** 7:A溶解槽温度 **/
        this.A_ReserverTEMP = new MonitorDataItem();
        this.A_ReserverTEMP.value = this.getJsonValueByKey(jsonNode, "7");
        this.A_ReserverTEMP.Unit = TEMP_UNIT;

        /** 8:B貯水槽原液残量 **/
        this.B_waterTankRemained = new MonitorDataItem();
        this.B_waterTankRemained.value = this.getJsonValueByKey(jsonNode, "8");
        this.B_waterTankRemained.Unit = VOLUME_UNIT;

        /** 9:A貯水槽原液残量 **/
        this.A_waterTankRemained = new MonitorDataItem();
        this.A_waterTankRemained.value = this.getJsonValueByKey(jsonNode, "9");
        this.A_waterTankRemained.Unit = VOLUME_UNIT;

        /** 10:B原液濃度警報点（上限） **/
        this.B_StockSolConcAlarmPoint_Upper = new MonitorDataItem();
        this.B_StockSolConcAlarmPoint_Upper.value = this.getJsonValueByKey(jsonNode, "10");
        this.B_StockSolConcAlarmPoint_Upper.Unit = CONC_UNIT;

        /** 11:B原液濃度警報点（下限） **/
        this.B_StockSolConcAlarmPoint_Lower = new MonitorDataItem();
        this.B_StockSolConcAlarmPoint_Lower.value = this.getJsonValueByKey(jsonNode, "11");
        this.B_StockSolConcAlarmPoint_Lower.Unit = CONC_UNIT;

        /** 12:A原液濃度警報点（上限） **/
        this.A_StockSolConcAlarmPoint_Upper = new MonitorDataItem();
        this.A_StockSolConcAlarmPoint_Upper.value = this.getJsonValueByKey(jsonNode, "12");
        this.A_StockSolConcAlarmPoint_Upper.Unit = CONC_UNIT;

        /** 13:A原液濃度警報点（下限） **/
        this.A_StockSolConcAlarmPoint_Lower = new MonitorDataItem();
        this.A_StockSolConcAlarmPoint_Lower.value = this.getJsonValueByKey(jsonNode, "13");
        this.A_StockSolConcAlarmPoint_Lower.Unit = CONC_UNIT;

        /** 14:給水圧警報点（下限） **/
        this.waterPressureAlarmPoint_Lower = new MonitorDataItem();
        this.waterPressureAlarmPoint_Lower.value = this.getJsonValueByKey(jsonNode, "14");
        this.waterPressureAlarmPoint_Lower.Unit = PRESSURE_UNIT;

        /** 15:薬液消毒濃度下限報知点 **/
        this.mediSterilizationConcAlarmPoint_Lower = new MonitorDataItem();
        this.mediSterilizationConcAlarmPoint_Lower.value = this.getJsonValueByKey(jsonNode, "15");
        this.mediSterilizationConcAlarmPoint_Lower.Unit = VOLTAGE_UNIT;

        /** 16:薬液消毒漏れ警報点 **/
        this.mediSterilizationLeakAlarmPoint = new MonitorDataItem();
        this.mediSterilizationLeakAlarmPoint.value = this.getJsonValueByKey(jsonNode, "16");
        this.mediSterilizationLeakAlarmPoint.Unit = VOLTAGE_UNIT;

        /** 17:貯水槽原液減少報知点１ **/
        this.stockSolDecreaseInformPoint1 = new MonitorDataItem();
        this.stockSolDecreaseInformPoint1.value = this.getJsonValueByKey(jsonNode, "17");
        this.stockSolDecreaseInformPoint1.Unit = VOLUME_UNIT;

        /** 18:貯水槽原液減少報知点２ **/
        this.stockSolDecreaseInformPoint2 = new MonitorDataItem();
        this.stockSolDecreaseInformPoint2.value = this.getJsonValueByKey(jsonNode, "18");
        this.stockSolDecreaseInformPoint2.Unit = VOLUME_UNIT;

        /** 19:貯水槽原液減少報知点３ **/
        this.stockSolDecreaseInformPoint3 = new MonitorDataItem();
        this.stockSolDecreaseInformPoint3.value = this.getJsonValueByKey(jsonNode, "19");
        this.stockSolDecreaseInformPoint3.Unit = VOLUME_UNIT;

        /** 20:B溶解槽温度警報（上限） **/
        this.B_ReserverTempAlarmPoint_Upper = new MonitorDataItem();
        this.B_ReserverTempAlarmPoint_Upper.value = this.getJsonValueByKey(jsonNode, "20");
        this.B_ReserverTempAlarmPoint_Upper.Unit = TEMP_UNIT;

        /** 21:A溶解槽温度警報（上限） **/
        this.A_ReserverTempAlarmPoint_Upper = new MonitorDataItem();
        this.A_ReserverTempAlarmPoint_Upper.value = this.getJsonValueByKey(jsonNode, "21");
        this.A_ReserverTempAlarmPoint_Upper.Unit = TEMP_UNIT;

        /** 22:溶解ボトル使用数 **/
        this.bottleUseCount = new MonitorDataItem();
        this.bottleUseCount.value = this.getJsonValueByKey(jsonNode, "22");
        this.bottleUseCount.Unit = SET_UNIT;

        /** 23:残り薬剤数 **/
        this.mediRemained = new MonitorDataItem();
        this.mediRemained.value = this.getJsonValueByKey(jsonNode, "23");
        this.mediRemained.Unit = SET_UNIT;

        /** 24:原液減予想時刻 **/
        this.stockSolLossTime = new MonitorDataItem();
        this.stockSolLossTime.value = this.getJsonValueByKey(jsonNode, "24");

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
   * @param cd 工程コード(0～7)
   * @return 工程名称
   */
  private String getProcessName(int cd) {
    String rtn;
    switch (cd) {
    case 0:
      rtn = "休止";
      break;
    case 1:
      rtn = "洗消準備";
      break;
    case 2:
      rtn = "洗消";
      break;
    case 3:
      rtn = "溶解準備";
      break;
    case 4:
      rtn = "溶解";
      break;
    case 5:
      rtn = "原点復帰";
      break;
    case 6:
      rtn = "手動操作";
      break;
    case 7:
      rtn = "調整";
      break;
    default:
      rtn = null;
    }

    return rtn;
  }

}
