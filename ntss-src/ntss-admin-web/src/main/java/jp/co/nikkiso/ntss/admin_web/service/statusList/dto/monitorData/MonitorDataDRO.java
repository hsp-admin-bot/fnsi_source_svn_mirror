package jp.co.nikkiso.ntss.admin_web.service.statusList.dto.monitorData;

import java.io.IOException;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.Getter;

/**
 *  モニタデータ(DRO)クラス.
 */
@Getter
//@Setter
public class MonitorDataDRO implements MonitorData {
  /** 1:運転状態 **/
  MonitorDataItem stateName;
  /** 2:RO送水量 **/
  MonitorDataItem roWaterFlow;
  /** 3:RO戻り水量 **/
  MonitorDataItem roReturnFlow;
  /** 4:RO循環水量 **/
  MonitorDataItem roCirculationFlow;
  /** 5:RO排水量 **/
  MonitorDataItem roDrainingFlow;
  /** 6:RO排水戻り水量 **/
  MonitorDataItem roDrainingReturnFlow;
  /** 7:LRO処理水量 **/
  MonitorDataItem lroFlow;
  /** 8:LRO循環水量 **/
  MonitorDataItem lroCirculationFlow;
  /** 9:LRO排水量 **/
  MonitorDataItem lroDrainingFlow;
  /** 10:原水温度 **/
  MonitorDataItem rawWaterTEMP;
  /** 11:原水監視温度 **/
  MonitorDataItem rawWaterTEMP_Watch;
  /** 12:カーボン出口温度 **/
  MonitorDataItem carbonOutTEMP;
  /** 13:LRO膜出口温度 **/
  MonitorDataItem lroMembraneOutTEMP;
  /** 14:RO膜出口温度 **/
  MonitorDataItem roMembraneOutTEMP;
  /** 15:RO水タンク温度 **/
  MonitorDataItem roWaterTEMP;
  /** 16:排水温度 **/
  MonitorDataItem drainingTEMP;
  /** 17:原水水質 **/
  MonitorDataItem rawWaterQuality;
  /** 18:LRO水質 **/
  MonitorDataItem lroQuality;
  /** 19:RO水質 **/
  MonitorDataItem roQuality;
  /** 20:原水ポンプインバータ **/
  MonitorDataItem rawWaterPumpInverter;
  /** 21:ＬＲＯポンプインバータ **/
  MonitorDataItem lroPumpInverter;
  /** 22:ＲＯポンプインバータ **/
  MonitorDataItem roPumpInverter;
  /** 23:送水ポンプ１インバータ **/
  MonitorDataItem waterFlowPumpInverter1;
  /** 24:送水ポンプ２インバータ **/
  MonitorDataItem waterFlowPumpInverter2;
  /** 25:10μフィルタ入口圧 **/
  MonitorDataItem filterInletPressure;
  /** 26:カーボンフィルタ入口圧 **/
  MonitorDataItem carbonInletPressure;
  /** 27:LROポンプ入口圧 **/
  MonitorDataItem lroPumpInletPressure;
  /** 28:LRO膜入口圧 **/
  MonitorDataItem lroMembraneInletPressure;
  /** 29:LRO膜出口圧 **/
  MonitorDataItem lroMembraneOutletPressure;
  /** 30:ROポンプ入口圧 **/
  MonitorDataItem roPumpInletPressure;
  /** 31:RO膜入口圧 **/
  MonitorDataItem roMembraneInletPressure;
  /** 32:RO膜出口圧 **/
  MonitorDataItem roMembraneOutletPressure;
  /** 33:送水ポンプ1出口圧 **/
  MonitorDataItem waterFlowPumpOutletPressure1;
  /** 34:送水ポンプ2出口圧 **/
  MonitorDataItem waterFlowPumpOutletPressure2;
  /** 35:RO処理水圧 **/
  MonitorDataItem roWaterPressure;
  /** 36:RO回収率 **/
  MonitorDataItem roRecoveryRate;
  /** 37:RO送水MV開度 **/
  MonitorDataItem roWaterFlowMVPosition;
  /** 38:RO排水MV開度 **/
  MonitorDataItem roDrainingFlowMVPosition;
  /** 39:1系洗浄水量 **/
  MonitorDataItem flushingWater1;
  /** 40:2系洗浄水量 **/
  MonitorDataItem flushingWater2;
  /** 41:1系洗浄積算水量 **/
  MonitorDataItem flushingWaterIntegrated1;
  /** 42:2系洗浄積算水量 **/
  MonitorDataItem flushingWaterIntegrated2;
  /** 43:ROタンク水位表示 **/
  MonitorDataItem roTankIndicator;
  /** 44:NO.1RO処理水量 **/
  MonitorDataItem roWaterFlowNo1;
  /** 45:NO.1RO循環水量 **/
  MonitorDataItem roCirculationFlowNo1;
  /** 46:NO.1RO排水量 **/
  MonitorDataItem roDrainingFlowNo1;
  /** 47:NO.1RO排水戻り水量 **/
  MonitorDataItem roDrainingReturnFlowNo1;
  /** 48:NO.2RO処理水量 **/
  MonitorDataItem roWaterFlowNo2;
  /** 49:NO.2RO循環水量 **/
  MonitorDataItem roCirculationFlowNo2;
  /** 50:NO.2RO排水量 **/
  MonitorDataItem roDrainingFlowNo2;
  /** 51:NO.2RO排水戻り水量 **/
  MonitorDataItem roDrainingReturnFlowNo2;
  /** 52:軟水タンク温度 **/
  MonitorDataItem softWaterTankTEMP;
  /** 53:NO.1RO膜出口温度 **/
  MonitorDataItem roMembraneOutTEMPNo1;
  /** 54:NO.2RO膜出口温度 **/
  MonitorDataItem roMembraneOutTEMPNo2;
  /** 55:RO原水水質 **/
  MonitorDataItem roRawWaterQuality;
  /** 56:NO.1RO水質 **/
  MonitorDataItem roQualityNo1;
  /** 57:NO.2RO水質 **/
  MonitorDataItem roQualityNo2;
  /** 58:軟水加圧ポンプインバータ **/
  MonitorDataItem softWaterPressurePumpInverter;
  /** 59:NO.1ROポンプインバータ **/
  MonitorDataItem roPumpInverterNo1;
  /** 60:NO.2ROポンプインバータ **/
  MonitorDataItem roPumpInverterNo2;
  /** 61:NO.1ROポンプ入口圧 **/
  MonitorDataItem roPumpInletPressureNo1;
  /** 62:NO.1RO膜入口圧 **/
  MonitorDataItem roMembraneInletPressureNo1;
  /** 63:NO.1RO膜出口圧 **/
  MonitorDataItem roMembraneOutletPressureNo1;
  /** 64:NO.2ROポンプ入口圧 **/
  MonitorDataItem roPumpInletPressureNo2;
  /** 65:NO.2RO膜入口圧 **/
  MonitorDataItem roMembraneInletPressureNo2;
  /** 66:NO.2RO膜出口圧 **/
  MonitorDataItem roMembraneOutletPressureNo2;
  /** 67:原水圧 **/
  MonitorDataItem rawWaterPressure;
  /** 68:原水減圧弁出口圧 **/
  MonitorDataItem rawWaterReducingValveOutletPressure;
  /** 69:軟水機入口圧 **/
  MonitorDataItem waterSoftenerInletPressure;
  /** 70:軟水機出口圧 **/
  MonitorDataItem waterSoftenerOutletPressure;
  /** 71:減圧弁出口圧 **/
  MonitorDataItem reducingValveOutletPressure;
  /** 72:給湯圧 **/
  MonitorDataItem waterHeaterPressure;
  /** 73:給湯減圧弁出口圧 **/
  MonitorDataItem waterheaterReducingValveOutletPressure;
  /** 74:混合弁出口圧 **/
  MonitorDataItem mixingValveOutletPressure;
  /** 75:原水流量 **/
  MonitorDataItem rawWaterFlow;
  /** 76:洗浄排水量 **/
  MonitorDataItem flushingDrainingFlow;
  /** 77:システム回収率 **/
  MonitorDataItem systemRecoveryRate;
  /** 78:NO.1RO回収率 **/
  MonitorDataItem roRecoveryRateNo1;
  /** 79:NO.2RO回収率 **/
  MonitorDataItem roRecoveryRateNo2;
  /** 80:RO阻止率 **/
  MonitorDataItem roBlockingRate;
  /** 81:NO.1RO排水戻りMV開度 **/
  MonitorDataItem roDrainingReturnFlowMVPositionNo1;
  /** 82:NO.2RO排水戻りMV開度 **/
  MonitorDataItem roDrainingReturnFlowMVPositionNo2;

  /**
   * コンストラクタ
   * モニタデータのJSON文字列から各値がクラスフィールドに展開されます。
   * @param moniData モニタデータのJSON文字列
   */
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
  public MonitorDataDRO(String moniData)  throws IOException {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    if (moniData != null && !moniData.isEmpty()) {
      // 引数を展開
      this.setItems(moniData);
    }
  }

  /**
   * 項目コード(1～82)を指定して、値を取得します。
   * @param itemCd DROモニタデータ項目番号(アドレス)
   * @return
   */
  public MonitorDataItem getByItemCd(int itemCd) {
    MonitorDataItem rtn = null;

    if (itemCd == 1) {
      rtn = this.stateName;
    }
    if (itemCd == 2) {
      rtn = this.roWaterFlow;
    }
    if (itemCd == 3) {
      rtn = this.roReturnFlow;
    }
    if (itemCd == 4) {
      rtn = this.roCirculationFlow;
    }
    if (itemCd == 5) {
      rtn = this.roDrainingFlow;
    }
    if (itemCd == 6) {
      rtn = this.roDrainingReturnFlow;
    }
    if (itemCd == 7) {
      rtn = this.lroFlow;
    }
    if (itemCd == 8) {
      rtn = this.lroCirculationFlow;
    }
    if (itemCd == 9) {
      rtn = this.lroDrainingFlow;
    }
    if (itemCd == 10) {
      rtn = this.rawWaterTEMP;
    }
    if (itemCd == 11) {
      rtn = this.rawWaterTEMP_Watch;
    }
    if (itemCd == 12) {
      rtn = this.carbonOutTEMP;
    }
    if (itemCd == 13) {
      rtn = this.lroMembraneOutTEMP;
    }
    if (itemCd == 14) {
      rtn = this.roMembraneOutTEMP;
    }
    if (itemCd == 15) {
      rtn = this.roWaterTEMP;
    }
    if (itemCd == 16) {
      rtn = this.drainingTEMP;
    }
    if (itemCd == 17) {
      rtn = this.rawWaterQuality;
    }
    if (itemCd == 18) {
      rtn = this.lroQuality;
    }
    if (itemCd == 19) {
      rtn = this.roQuality;
    }
    if (itemCd == 20) {
      rtn = this.rawWaterPumpInverter;
    }
    if (itemCd == 21) {
      rtn = this.lroPumpInverter;
    }
    if (itemCd == 22) {
      rtn = this.roPumpInverter;
    }
    if (itemCd == 23) {
      rtn = this.waterFlowPumpInverter1;
    }
    if (itemCd == 24) {
      rtn = this.waterFlowPumpInverter2;
    }
    if (itemCd == 25) {
      rtn = this.filterInletPressure;
    }
    if (itemCd == 26) {
      rtn = this.carbonInletPressure;
    }
    if (itemCd == 27) {
      rtn = this.lroPumpInletPressure;
    }
    if (itemCd == 28) {
      rtn = this.lroMembraneInletPressure;
    }
    if (itemCd == 29) {
      rtn = this.lroMembraneOutletPressure;
    }
    if (itemCd == 30) {
      rtn = this.roPumpInletPressure;
    }
    if (itemCd == 31) {
      rtn = this.roMembraneInletPressure;
    }
    if (itemCd == 32) {
      rtn = this.roMembraneOutletPressure;
    }
    if (itemCd == 33) {
      rtn = this.waterFlowPumpOutletPressure1;
    }
    if (itemCd == 34) {
      rtn = this.waterFlowPumpOutletPressure2;
    }
    if (itemCd == 35) {
      rtn = this.roWaterPressure;
    }
    if (itemCd == 36) {
      rtn = this.roRecoveryRate;
    }
    if (itemCd == 37) {
      rtn = this.roWaterFlowMVPosition;
    }
    if (itemCd == 38) {
      rtn = this.roDrainingFlowMVPosition;
    }
    if (itemCd == 39) {
      rtn = this.flushingWater1;
    }
    if (itemCd == 40) {
      rtn = this.flushingWater2;
    }
    if (itemCd == 41) {
      rtn = this.flushingWaterIntegrated1;
    }
    if (itemCd == 42) {
      rtn = this.flushingWaterIntegrated2;
    }
    if (itemCd == 43) {
      rtn = this.roTankIndicator;
    }
    if (itemCd == 44) {
      rtn = this.roWaterFlowNo1;
    }
    if (itemCd == 45) {
      rtn = this.roCirculationFlowNo1;
    }
    if (itemCd == 46) {
      rtn = this.roDrainingFlowNo1;
    }
    if (itemCd == 47) {
      rtn = this.roDrainingReturnFlowNo1;
    }
    if (itemCd == 48) {
      rtn = this.roWaterFlowNo2;
    }
    if (itemCd == 49) {
      rtn = this.roCirculationFlowNo2;
    }
    if (itemCd == 50) {
      rtn = this.roDrainingFlowNo2;
    }
    if (itemCd == 51) {
      rtn = this.roDrainingReturnFlowNo2;
    }
    if (itemCd == 52) {
      rtn = this.softWaterTankTEMP;
    }
    if (itemCd == 53) {
      rtn = this.roMembraneOutTEMPNo1;
    }
    if (itemCd == 54) {
      rtn = this.roMembraneOutTEMPNo2;
    }
    if (itemCd == 55) {
      rtn = this.roRawWaterQuality;
    }
    if (itemCd == 56) {
      rtn = this.roQualityNo1;
    }
    if (itemCd == 57) {
      rtn = this.roQualityNo2;
    }
    if (itemCd == 58) {
      rtn = this.softWaterPressurePumpInverter;
    }
    if (itemCd == 59) {
      rtn = this.roPumpInverterNo1;
    }
    if (itemCd == 60) {
      rtn = this.roPumpInverterNo2;
    }
    if (itemCd == 61) {
      rtn = this.roPumpInletPressureNo1;
    }
    if (itemCd == 62) {
      rtn = this.roMembraneInletPressureNo1;
    }
    if (itemCd == 63) {
      rtn = this.roMembraneOutletPressureNo1;
    }
    if (itemCd == 64) {
      rtn = this.roPumpInletPressureNo2;
    }
    if (itemCd == 65) {
      rtn = this.roMembraneInletPressureNo2;
    }
    if (itemCd == 66) {
      rtn = this.roMembraneOutletPressureNo2;
    }
    if (itemCd == 67) {
      rtn = this.rawWaterPressure;
    }
    if (itemCd == 68) {
      rtn = this.rawWaterReducingValveOutletPressure;
    }
    if (itemCd == 69) {
      rtn = this.waterSoftenerInletPressure;
    }
    if (itemCd == 70) {
      rtn = this.waterSoftenerOutletPressure;
    }
    if (itemCd == 71) {
      rtn = this.reducingValveOutletPressure;
    }
    if (itemCd == 72) {
      rtn = this.waterHeaterPressure;
    }
    if (itemCd == 73) {
      rtn = this.waterheaterReducingValveOutletPressure;
    }
    if (itemCd == 74) {
      rtn = this.mixingValveOutletPressure;
    }
    if (itemCd == 75) {
      rtn = this.rawWaterFlow;
    }
    if (itemCd == 76) {
      rtn = this.flushingDrainingFlow;
    }
    if (itemCd == 77) {
      rtn = this.systemRecoveryRate;
    }
    if (itemCd == 78) {
      rtn = this.roRecoveryRateNo1;
    }
    if (itemCd == 79) {
      rtn = this.roRecoveryRateNo2;
    }
    if (itemCd == 80) {
      rtn = this.roBlockingRate;
    }
    if (itemCd == 81) {
      rtn = this.roDrainingReturnFlowMVPositionNo1;
    }
    if (itemCd == 82) {
      rtn = this.roDrainingReturnFlowMVPositionNo2;
    }

    return rtn;
  }

  /**
   * モニタデータをクラスフィールドに展開します。
   * @param moniDataJsonString バイタル情報のJSON文字列
   */
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
  private void setItems(String moniDataJsonString)  throws IOException {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
    final String RATE_UNIT = "%";
    final String TEMP_UNIT = "℃";
    final String VOLUME_UNIT = "L";
    final String FLOW_UNIT = "L/min";
    final String PRESSURE_UNIT = "MPa";
    final String QUALITY_UNIT = "μS/cm";

    if (moniDataJsonString != null) {
      ObjectMapper mapper = new ObjectMapper();
      try {
        JsonNode jsonNode = mapper.readTree(moniDataJsonString);

        // インスタンス変数に各値をセット
        /** 1:運転状態 **/
        this.stateName = new MonitorDataItem();
        if (this.getJsonValueByKey(jsonNode, "1") != null) {
          this.stateName.value = this.getProcessName(Integer.parseInt(this.getJsonValueByKey(jsonNode, "1")));
        }

        /** 2:RO送水量 **/
        this.roWaterFlow = new MonitorDataItem();
        this.roWaterFlow.value = this.getJsonValueByKey(jsonNode, "2");
        this.roWaterFlow.Unit = FLOW_UNIT;

        /** 3:RO戻り水量 **/
        this.roReturnFlow = new MonitorDataItem();
        this.roReturnFlow.value = this.getJsonValueByKey(jsonNode, "3");
        this.roReturnFlow.Unit = FLOW_UNIT;

        /** 4:RO循環水量 **/
        this.roCirculationFlow = new MonitorDataItem();
        this.roCirculationFlow.value = this.getJsonValueByKey(jsonNode, "4");
        this.roCirculationFlow.Unit = FLOW_UNIT;

        /** 5:RO排水量 **/
        this.roDrainingFlow = new MonitorDataItem();
        this.roDrainingFlow.value = this.getJsonValueByKey(jsonNode, "5");
        this.roDrainingFlow.Unit = FLOW_UNIT;

        /** 6:RO排水戻り水量 **/
        this.roDrainingReturnFlow = new MonitorDataItem();
        this.roDrainingReturnFlow.value = this.getJsonValueByKey(jsonNode, "6");
        this.roDrainingReturnFlow.Unit = FLOW_UNIT;

        /** 7:LRO処理水量 **/
        this.lroFlow = new MonitorDataItem();
        this.lroFlow.value = this.getJsonValueByKey(jsonNode, "7");
        this.lroFlow.Unit = FLOW_UNIT;

        /** 8:LRO循環水量 **/
        this.lroCirculationFlow = new MonitorDataItem();
        this.lroCirculationFlow.value = this.getJsonValueByKey(jsonNode, "8");
        this.lroCirculationFlow.Unit = FLOW_UNIT;

        /** 9:LRO排水量 **/
        this.lroDrainingFlow = new MonitorDataItem();
        this.lroDrainingFlow.value = this.getJsonValueByKey(jsonNode, "9");
        this.lroDrainingFlow.Unit = FLOW_UNIT;

        /** 10:原水温度 **/
        this.rawWaterTEMP = new MonitorDataItem();
        this.rawWaterTEMP.value = this.getJsonValueByKey(jsonNode, "10");
        this.rawWaterTEMP.Unit = TEMP_UNIT;

        /** 11:原水監視温度 **/
        this.rawWaterTEMP_Watch = new MonitorDataItem();
        this.rawWaterTEMP_Watch.value = this.getJsonValueByKey(jsonNode, "11");
        this.rawWaterTEMP_Watch.Unit = TEMP_UNIT;

        /** 12:カーボン出口温度 **/
        this.carbonOutTEMP = new MonitorDataItem();
        this.carbonOutTEMP.value = this.getJsonValueByKey(jsonNode, "12");
        this.carbonOutTEMP.Unit = TEMP_UNIT;

        /** 13:LRO膜出口温度 **/
        this.lroMembraneOutTEMP = new MonitorDataItem();
        this.lroMembraneOutTEMP.value = this.getJsonValueByKey(jsonNode, "13");
        this.lroMembraneOutTEMP.Unit = TEMP_UNIT;

        /** 14:RO膜出口温度 **/
        this.roMembraneOutTEMP = new MonitorDataItem();
        this.roMembraneOutTEMP.value = this.getJsonValueByKey(jsonNode, "14");
        this.roMembraneOutTEMP.Unit = TEMP_UNIT;

        /** 15:RO水タンク温度 **/
        this.roWaterTEMP = new MonitorDataItem();
        this.roWaterTEMP.value = this.getJsonValueByKey(jsonNode, "15");
        this.roWaterTEMP.Unit = TEMP_UNIT;

        /** 16:排水温度 **/
        this.drainingTEMP = new MonitorDataItem();
        this.drainingTEMP.value = this.getJsonValueByKey(jsonNode, "16");
        this.drainingTEMP.Unit = TEMP_UNIT;

        /** 17:原水水質 **/
        this.rawWaterQuality = new MonitorDataItem();
        this.rawWaterQuality.value = this.getJsonValueByKey(jsonNode, "17");
        this.rawWaterQuality.Unit = QUALITY_UNIT;

        /** 18:LRO水質 **/
        this.lroQuality = new MonitorDataItem();
        this.lroQuality.value = this.getJsonValueByKey(jsonNode, "18");
        this.lroQuality.Unit = QUALITY_UNIT;

        /** 19:RO水質 **/
        this.roQuality = new MonitorDataItem();
        this.roQuality.value = this.getJsonValueByKey(jsonNode, "19");
        this.roQuality.Unit = QUALITY_UNIT;

        /** 20:原水ポンプインバータ **/
        this.rawWaterPumpInverter = new MonitorDataItem();
        this.rawWaterPumpInverter.value = this.getJsonValueByKey(jsonNode, "20");
        this.rawWaterPumpInverter.Unit = RATE_UNIT;

        /** 21:ＬＲＯポンプインバータ **/
        this.lroPumpInverter = new MonitorDataItem();
        this.lroPumpInverter.value = this.getJsonValueByKey(jsonNode, "21");
        this.lroPumpInverter.Unit = RATE_UNIT;

        /** 22:ＲＯポンプインバータ **/
        this.roPumpInverter = new MonitorDataItem();
        this.roPumpInverter.value = this.getJsonValueByKey(jsonNode, "22");
        this.roPumpInverter.Unit = RATE_UNIT;

        /** 23:送水ポンプ１インバータ **/
        this.waterFlowPumpInverter1 = new MonitorDataItem();
        this.waterFlowPumpInverter1.value = this.getJsonValueByKey(jsonNode, "23");
        this.waterFlowPumpInverter1.Unit = RATE_UNIT;

        /** 24:送水ポンプ２インバータ **/
        this.waterFlowPumpInverter2 = new MonitorDataItem();
        this.waterFlowPumpInverter2.value = this.getJsonValueByKey(jsonNode, "24");
        this.waterFlowPumpInverter2.Unit = RATE_UNIT;

        /** 25:10μフィルタ入口圧 **/
        this.filterInletPressure = new MonitorDataItem();
        this.filterInletPressure.value = this.getJsonValueByKey(jsonNode, "25");
        this.filterInletPressure.Unit = PRESSURE_UNIT;

        /** 26:カーボンフィルタ入口圧 **/
        this.carbonInletPressure = new MonitorDataItem();
        this.carbonInletPressure.value = this.getJsonValueByKey(jsonNode, "26");
        this.carbonInletPressure.Unit = PRESSURE_UNIT;

        /** 27:LROポンプ入口圧 **/
        this.lroPumpInletPressure = new MonitorDataItem();
        this.lroPumpInletPressure.value = this.getJsonValueByKey(jsonNode, "27");
        this.lroPumpInletPressure.Unit = PRESSURE_UNIT;

        /** 28:LRO膜入口圧 **/
        this.lroMembraneInletPressure = new MonitorDataItem();
        this.lroMembraneInletPressure.value = this.getJsonValueByKey(jsonNode, "28");
        this.lroMembraneInletPressure.Unit = PRESSURE_UNIT;

        /** 29:LRO膜出口圧 **/
        this.lroMembraneOutletPressure = new MonitorDataItem();
        this.lroMembraneOutletPressure.value = this.getJsonValueByKey(jsonNode, "29");
        this.lroMembraneOutletPressure.Unit = PRESSURE_UNIT;

        /** 30:ROポンプ入口圧 **/
        this.roPumpInletPressure = new MonitorDataItem();
        this.roPumpInletPressure.value = this.getJsonValueByKey(jsonNode, "30");
        this.roPumpInletPressure.Unit = PRESSURE_UNIT;

        /** 31:RO膜入口圧 **/
        this.roMembraneInletPressure = new MonitorDataItem();
        this.roMembraneInletPressure.value = this.getJsonValueByKey(jsonNode, "31");
        this.roMembraneInletPressure.Unit = PRESSURE_UNIT;

        /** 32:RO膜出口圧 **/
        this.roMembraneOutletPressure = new MonitorDataItem();
        this.roMembraneOutletPressure.value = this.getJsonValueByKey(jsonNode, "32");
        this.roMembraneOutletPressure.Unit = PRESSURE_UNIT;

        /** 33:送水ポンプ1出口圧 **/
        this.waterFlowPumpOutletPressure1 = new MonitorDataItem();
        this.waterFlowPumpOutletPressure1.value = this.getJsonValueByKey(jsonNode, "33");
        this.waterFlowPumpOutletPressure1.Unit = PRESSURE_UNIT;

        /** 34:送水ポンプ2出口圧 **/
        this.waterFlowPumpOutletPressure2 = new MonitorDataItem();
        this.waterFlowPumpOutletPressure2.value = this.getJsonValueByKey(jsonNode, "34");
        this.waterFlowPumpOutletPressure2.Unit = PRESSURE_UNIT;

        /** 35:RO処理水圧 **/
        this.roWaterPressure = new MonitorDataItem();
        this.roWaterPressure.value = this.getJsonValueByKey(jsonNode, "35");
        this.roWaterPressure.Unit = PRESSURE_UNIT;

        /** 36:RO回収率 **/
        this.roRecoveryRate = new MonitorDataItem();
        this.roRecoveryRate.value = this.getJsonValueByKey(jsonNode, "36");
        this.roRecoveryRate.Unit = RATE_UNIT;

        /** 37:RO送水MV開度 **/
        this.roWaterFlowMVPosition = new MonitorDataItem();
        this.roWaterFlowMVPosition.value = this.getJsonValueByKey(jsonNode, "37");
        this.roWaterFlowMVPosition.Unit = RATE_UNIT;

        /** 38:RO排水MV開度 **/
        this.roDrainingFlowMVPosition = new MonitorDataItem();
        this.roDrainingFlowMVPosition.value = this.getJsonValueByKey(jsonNode, "38");
        this.roDrainingFlowMVPosition.Unit = RATE_UNIT;

        /** 39:1系洗浄水量 **/
        this.flushingWater1 = new MonitorDataItem();
        this.flushingWater1.value = this.getJsonValueByKey(jsonNode, "39");
        this.flushingWater1.Unit = FLOW_UNIT;

        /** 40:2系洗浄水量 **/
        this.flushingWater2 = new MonitorDataItem();
        this.flushingWater2.value = this.getJsonValueByKey(jsonNode, "40");
        this.flushingWater2.Unit = FLOW_UNIT;

        /** 41:1系洗浄積算水量 **/
        this.flushingWaterIntegrated1 = new MonitorDataItem();
        this.flushingWaterIntegrated1.value = this.getJsonValueByKey(jsonNode, "41");
        this.flushingWaterIntegrated1.Unit = VOLUME_UNIT;

        /** 42:2系洗浄積算水量 **/
        this.flushingWaterIntegrated2 = new MonitorDataItem();
        this.flushingWaterIntegrated2.value = this.getJsonValueByKey(jsonNode, "42");
        this.flushingWaterIntegrated2.Unit = VOLUME_UNIT;

        /** 43:ROタンク水位表示 **/
        this.roTankIndicator = new MonitorDataItem();
        this.roTankIndicator.value = this.getJsonValueByKey(jsonNode, "43");
        this.roTankIndicator.Unit = VOLUME_UNIT;

        /** 44:NO.1RO処理水量 **/
        this.roWaterFlowNo1 = new MonitorDataItem();
        this.roWaterFlowNo1.value = this.getJsonValueByKey(jsonNode, "44");
        this.roWaterFlowNo1.Unit = FLOW_UNIT;

        /** 45:NO.1RO循環水量 **/
        this.roCirculationFlowNo1 = new MonitorDataItem();
        this.roCirculationFlowNo1.value = this.getJsonValueByKey(jsonNode, "45");
        this.roCirculationFlowNo1.Unit = FLOW_UNIT;

        /** 46:NO.1RO排水量 **/
        this.roDrainingFlowNo1 = new MonitorDataItem();
        this.roDrainingFlowNo1.value = this.getJsonValueByKey(jsonNode, "46");
        this.roDrainingFlowNo1.Unit = FLOW_UNIT;

        /** 47:NO.1RO排水戻り水量 **/
        this.roDrainingReturnFlowNo1 = new MonitorDataItem();
        this.roDrainingReturnFlowNo1.value = this.getJsonValueByKey(jsonNode, "47");
        this.roDrainingReturnFlowNo1.Unit = FLOW_UNIT;

        /** 48:NO.2RO処理水量 **/
        this.roWaterFlowNo2 = new MonitorDataItem();
        this.roWaterFlowNo2.value = this.getJsonValueByKey(jsonNode, "48");
        this.roWaterFlowNo2.Unit = FLOW_UNIT;

        /** 49:NO.2RO循環水量 **/
        this.roCirculationFlowNo2 = new MonitorDataItem();
        this.roCirculationFlowNo2.value = this.getJsonValueByKey(jsonNode, "49");
        this.roCirculationFlowNo2.Unit = FLOW_UNIT;

        /** 50:NO.2RO排水量 **/
        this.roDrainingFlowNo2 = new MonitorDataItem();
        this.roDrainingFlowNo2.value = this.getJsonValueByKey(jsonNode, "50");
        this.roDrainingFlowNo2.Unit = FLOW_UNIT;

        /** 51:NO.2RO排水戻り水量 **/
        this.roDrainingReturnFlowNo2 = new MonitorDataItem();
        this.roDrainingReturnFlowNo2.value = this.getJsonValueByKey(jsonNode, "51");
        this.roDrainingReturnFlowNo2.Unit = FLOW_UNIT;

        /** 52:軟水タンク温度 **/
        this.softWaterTankTEMP = new MonitorDataItem();
        this.softWaterTankTEMP.value = this.getJsonValueByKey(jsonNode, "52");
        this.softWaterTankTEMP.Unit = TEMP_UNIT;

        /** 53:NO.1RO膜出口温度 **/
        this.roMembraneOutTEMPNo1 = new MonitorDataItem();
        this.roMembraneOutTEMPNo1.value = this.getJsonValueByKey(jsonNode, "53");
        this.roMembraneOutTEMPNo1.Unit = TEMP_UNIT;

        /** 54:NO.2RO膜出口温度 **/
        this.roMembraneOutTEMPNo2 = new MonitorDataItem();
        this.roMembraneOutTEMPNo2.value = this.getJsonValueByKey(jsonNode, "54");
        this.roMembraneOutTEMPNo2.Unit = TEMP_UNIT;

        /** 55:RO原水水質 **/
        this.roRawWaterQuality = new MonitorDataItem();
        this.roRawWaterQuality.value = this.getJsonValueByKey(jsonNode, "55");
        this.roRawWaterQuality.Unit = QUALITY_UNIT;

        /** 56:NO.1RO水質 **/
        this.roQualityNo1 = new MonitorDataItem();
        this.roQualityNo1.value = this.getJsonValueByKey(jsonNode, "56");
        this.roQualityNo1.Unit = QUALITY_UNIT;

        /** 57:NO.2RO水質 **/
        this.roQualityNo2 = new MonitorDataItem();
        this.roQualityNo2.value = this.getJsonValueByKey(jsonNode, "57");
        this.roQualityNo2.Unit = QUALITY_UNIT;

        /** 58:軟水加圧ポンプインバータ **/
        this.softWaterPressurePumpInverter = new MonitorDataItem();
        this.softWaterPressurePumpInverter.value = this.getJsonValueByKey(jsonNode, "58");
        this.softWaterPressurePumpInverter.Unit = RATE_UNIT;

        /** 59:NO.1ROポンプインバータ **/
        this.roPumpInverterNo1 = new MonitorDataItem();
        this.roPumpInverterNo1.value = this.getJsonValueByKey(jsonNode, "59");
        this.roPumpInverterNo1.Unit = RATE_UNIT;

        /** 60:NO.2ROポンプインバータ **/
        this.roPumpInverterNo2 = new MonitorDataItem();
        this.roPumpInverterNo2.value = this.getJsonValueByKey(jsonNode, "60");
        this.roPumpInverterNo2.Unit = RATE_UNIT;

        /** 61:NO.1ROポンプ入口圧 **/
        this.roPumpInletPressureNo1 = new MonitorDataItem();
        this.roPumpInletPressureNo1.value = this.getJsonValueByKey(jsonNode, "61");
        this.roPumpInletPressureNo1.Unit = RATE_UNIT;

        /** 62:NO.1RO膜入口圧 **/
        this.roMembraneInletPressureNo1 = new MonitorDataItem();
        this.roMembraneInletPressureNo1.value = this.getJsonValueByKey(jsonNode, "62");
        this.roMembraneInletPressureNo1.Unit = PRESSURE_UNIT;

        /** 63:NO.1RO膜出口圧 **/
        this.roMembraneOutletPressureNo1 = new MonitorDataItem();
        this.roMembraneOutletPressureNo1.value = this.getJsonValueByKey(jsonNode, "63");
        this.roMembraneOutletPressureNo1.Unit = PRESSURE_UNIT;

        /** 64:NO.2ROポンプ入口圧 **/
        this.roPumpInletPressureNo2 = new MonitorDataItem();
        this.roPumpInletPressureNo2.value = this.getJsonValueByKey(jsonNode, "64");
        this.roPumpInletPressureNo2.Unit = PRESSURE_UNIT;

        /** 65:NO.2RO膜入口圧 **/
        this.roMembraneInletPressureNo2 = new MonitorDataItem();
        this.roMembraneInletPressureNo2.value = this.getJsonValueByKey(jsonNode, "65");
        this.roMembraneInletPressureNo2.Unit = PRESSURE_UNIT;

        /** 66:NO.2RO膜出口圧 **/
        this.roMembraneOutletPressureNo2 = new MonitorDataItem();
        this.roMembraneOutletPressureNo2.value = this.getJsonValueByKey(jsonNode, "66");
        this.roMembraneOutletPressureNo2.Unit = PRESSURE_UNIT;

        /** 67:原水圧 **/
        this.rawWaterPressure = new MonitorDataItem();
        this.rawWaterPressure.value = this.getJsonValueByKey(jsonNode, "67");
        this.rawWaterPressure.Unit = PRESSURE_UNIT;

        /** 68:原水減圧弁出口圧 **/
        this.rawWaterReducingValveOutletPressure = new MonitorDataItem();
        this.rawWaterReducingValveOutletPressure.value = this.getJsonValueByKey(jsonNode, "68");
        this.rawWaterReducingValveOutletPressure.Unit = PRESSURE_UNIT;

        /** 69:軟水機入口圧 **/
        this.waterSoftenerInletPressure = new MonitorDataItem();
        this.waterSoftenerInletPressure.value = this.getJsonValueByKey(jsonNode, "69");
        this.waterSoftenerInletPressure.Unit = PRESSURE_UNIT;

        /** 70:軟水機出口圧 **/
        this.waterSoftenerOutletPressure = new MonitorDataItem();
        this.waterSoftenerOutletPressure.value = this.getJsonValueByKey(jsonNode, "70");
        this.waterSoftenerOutletPressure.Unit = PRESSURE_UNIT;

        /** 71:減圧弁出口圧 **/
        this.reducingValveOutletPressure = new MonitorDataItem();
        this.reducingValveOutletPressure.value = this.getJsonValueByKey(jsonNode, "71");
        this.reducingValveOutletPressure.Unit = PRESSURE_UNIT;

        /** 72:給湯圧 **/
        this.waterHeaterPressure = new MonitorDataItem();
        this.waterHeaterPressure.value = this.getJsonValueByKey(jsonNode, "72");
        this.waterHeaterPressure.Unit = PRESSURE_UNIT;

        /** 73:給湯減圧弁出口圧 **/
        this.waterheaterReducingValveOutletPressure = new MonitorDataItem();
        this.waterheaterReducingValveOutletPressure.value = this.getJsonValueByKey(jsonNode, "73");
        this.waterheaterReducingValveOutletPressure.Unit = PRESSURE_UNIT;

        /** 74:混合弁出口圧 **/
        this.mixingValveOutletPressure = new MonitorDataItem();
        this.mixingValveOutletPressure.value = this.getJsonValueByKey(jsonNode, "74");
        this.mixingValveOutletPressure.Unit = PRESSURE_UNIT;

        /** 75:原水流量 **/
        this.rawWaterFlow = new MonitorDataItem();
        this.rawWaterFlow.value = this.getJsonValueByKey(jsonNode, "75");
        this.rawWaterFlow.Unit = FLOW_UNIT;

        /** 76:洗浄排水量 **/
        this.flushingDrainingFlow = new MonitorDataItem();
        this.flushingDrainingFlow.value = this.getJsonValueByKey(jsonNode, "76");
        this.flushingDrainingFlow.Unit = FLOW_UNIT;

        /** 77:システム回収率 **/
        this.systemRecoveryRate = new MonitorDataItem();
        this.systemRecoveryRate.value = this.getJsonValueByKey(jsonNode, "77");
        this.systemRecoveryRate.Unit = RATE_UNIT;

        /** 78:NO.1RO回収率 **/
        this.roRecoveryRateNo1 = new MonitorDataItem();
        this.roRecoveryRateNo1.value = this.getJsonValueByKey(jsonNode, "78");
        this.roRecoveryRateNo1.Unit = RATE_UNIT;

        /** 79:NO.2RO回収率 **/
        this.roRecoveryRateNo2 = new MonitorDataItem();
        this.roRecoveryRateNo2.value = this.getJsonValueByKey(jsonNode, "79");
        this.roRecoveryRateNo2.Unit = RATE_UNIT;

        /** 80:RO阻止率 **/
        this.roBlockingRate = new MonitorDataItem();
        this.roBlockingRate.value = this.getJsonValueByKey(jsonNode, "80");
        this.roBlockingRate.Unit = RATE_UNIT;

        /** 81:NO.1RO排水戻りMV開度 **/
        this.roDrainingReturnFlowMVPositionNo1 = new MonitorDataItem();
        this.roDrainingReturnFlowMVPositionNo1.value = this.getJsonValueByKey(jsonNode, "81");
        this.roDrainingReturnFlowMVPositionNo1.Unit = RATE_UNIT;

        /** 82:NO.2RO排水戻りMV開度 **/
        this.roDrainingReturnFlowMVPositionNo2 = new MonitorDataItem();
        this.roDrainingReturnFlowMVPositionNo2.value = this.getJsonValueByKey(jsonNode, "82");
        this.roDrainingReturnFlowMVPositionNo2.Unit = RATE_UNIT;

      } catch (IOException e) {
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
   * 運転状態コードから運転状態名称を取得する
   * @param cd 運転状態コード(0～5)
   * @return 運転状態名称
   */
  private String getProcessName(int cd) {
    String rtn;
    switch (cd) {
    case 0:
      rtn = "通常運転";
      break;
    case 1:
      rtn = "夜間運転";
      break;
    case 2:
      rtn = "熱水消毒運転";
      break;
    case 3:
      rtn = "薬剤消毒運転";
      break;
    case 4:
      rtn = "強制冷却待機中";
      break;
    case 5:
      rtn = "強制洗出し待機中";
      break;
    default:
      rtn = null;
    }

    return rtn;
  }

}
