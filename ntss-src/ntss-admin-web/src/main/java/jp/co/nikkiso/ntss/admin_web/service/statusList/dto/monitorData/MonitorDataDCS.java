package jp.co.nikkiso.ntss.admin_web.service.statusList.dto.monitorData;

import java.io.IOException;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.Getter;

/**
 *  モニタデータ(DAD)クラス.
 */
@Getter
//@Setter
public class MonitorDataDCS implements MonitorData {
  /** 0:工程 **/
  MonitorDataItem stateName;
  /** 1:経過時間 **/
  MonitorDataItem elapsedTime;
  /** 2:経過時間（ＥＣＵＭ） **/
  MonitorDataItem elapsedTime_ECUM;
  /** 3:残り時間（除水完了） **/
  MonitorDataItem remainTime_WaterRemoval;
  /** 4:残り時間（透析完了） **/
  MonitorDataItem remainTime_Dialysis;
  /** 5:除水積算値 **/
  MonitorDataItem waterRemovalIntegrated;
  /** 6:除水速度 **/
  MonitorDataItem waterRemovalSpeed;
  /** 7:血液循環量 **/
  MonitorDataItem bloodCirculationVolume;
  /** 8:血流量 **/
  MonitorDataItem bloodVolume;
  /** 9:ＩＰ総量 **/
  MonitorDataItem ipTotal;
  /** 10:ＩＰ速度 **/
  MonitorDataItem ipSpeed;
  /** 11:静脈圧 **/
  MonitorDataItem venousPressure;
  /** 12:透析液圧 **/
  MonitorDataItem dialysatePressure;
  /** 13:ＴＭＰ **/
  MonitorDataItem tmp;
  /** 14:ダイアライザー入口圧 **/
  MonitorDataItem dialyzerInletPressure;
  /** 15:ダイアライザー差圧 **/
  MonitorDataItem dialyzerDiffPressure;
  /** 16:血液入口～静脈平均圧 **/
  MonitorDataItem bloodInletVenousPressure;
  /** 17:ΔBV **/
  MonitorDataItem deltaBv;
  /** 18:バイカーボ濃度 **/
  MonitorDataItem hco3Conc;
  /** 19:透析液濃度 **/
  MonitorDataItem dialysateConc;
  /** 20:Ｎａ濃度 **/
  MonitorDataItem sodiumConc;
  /** 21:透析液温度 **/
  MonitorDataItem dialysateTEMP;
  /** 22:透析液流量 **/
  MonitorDataItem dialysateFlow;
  /** 23:漏血量 **/
  MonitorDataItem bloodLeakage;
  /** 24:給液圧（上限） **/
  MonitorDataItem supplyPressure_Upper;
  /** 25:給液圧（下限） **/
  MonitorDataItem supplyPressure_Lower;
  /** 26:ＵＦＲ **/
  MonitorDataItem ufr;
  /** 27:ＵＦＲ低下率 **/
  MonitorDataItem ufrDeclineRate;
  /** 28:初期ＵＦＲ測定値 **/
  MonitorDataItem initialUfr;
  /** 29:ＴＭＰ補正値 **/
  MonitorDataItem tmpCorrection;
  /** 30:透析運転時間 **/
  MonitorDataItem runningTime;
  /** 31:治療モード **/
  MonitorDataItem treatMode;
  /** 32:除水目標値 **/
  MonitorDataItem waterRemovalTarget;
  /** 33:除水速度設定値 **/
  MonitorDataItem waterRemovalSpeedSetting;
  /** 34:透析液温度設定値 **/
  MonitorDataItem dialysateTempSetting;
  /** 35:透析液流量設定値 **/
  MonitorDataItem dialysateFlowSetting;
  /** 36:血流量設定値 **/
  MonitorDataItem bvSetting;
  /** 37:ＩＰ速度設定 **/
  MonitorDataItem ipSpeedSetting;
  /** 38:Kt/V（測定値） **/
  MonitorDataItem ktOverV_Measure;
  /** 39:静脈圧警報点（上限） **/
  MonitorDataItem venousPressureAlertPoint_Upper;
  /** 40:静脈圧警報点（下限） **/
  MonitorDataItem venousPressureAlertPoint_Lower;
  /** 41:透析液圧警報点（上限） **/
  MonitorDataItem dialysatePressureAlertPoint_Upper;
  /** 42:透析液圧警報点（下限） **/
  MonitorDataItem dialysatePressureAlertPoint_Lower;
  /** 43:ＴＭＰ警報点（上限） **/
  MonitorDataItem tmpAlertPoint_Upper;
  /** 44:ＴＭＰ警報点（下限） **/
  MonitorDataItem tmpAlertPoint_Lower;
  /** 45:ダイアライザー入口圧警報点（上限） **/
  MonitorDataItem dialyzerInletPressureAlertPoint_Upper;
  /** 46:ダイアライザー入口圧警報点（下限） **/
  MonitorDataItem dialyzerInletPressureAlertPoint_Lower;
  /** 47:ダイアライザー差圧警報点（上限） **/
  MonitorDataItem dialyzerDiffPressureAlertPoint_Upper;
  /** 48:ダイアライザー差圧警報点（下限） **/
  MonitorDataItem dialyzerDiffPressureAlertPoint_Lower;
  /** 49:ΔＢＶ低下警報点1 **/
  MonitorDataItem deltaBvDeclineAlertPoint1;
  /** 50:ΔＢＶ低下警報点2 **/
  MonitorDataItem deltaBvDeclineAlertPoint2;
  /** 51:ΔBV変化率警報点 **/
  MonitorDataItem deltaBvChangeRateAlertPoint;
  /** 52:ＢＰＭ関連データ９ **/
  MonitorDataItem bpmData9;
  /** 53:ＢＰＭ関連データ１０ **/
  MonitorDataItem bpmData10;
  /** 54:バイカーボ濃度警報点（上限） **/
  MonitorDataItem hco3ConcAlertPoint_Upper;
  /** 55:バイカーボ濃度警報点（下限） **/
  MonitorDataItem hco3ConcAlertPoint_Lower;
  /** 56:透析液濃度警報点（上限） **/
  MonitorDataItem dialysateConcAlertPoint_Upper;
  /** 57:透析液濃度警報点（下限） **/
  MonitorDataItem dialysateConcAlertPoint_Lower;
  /** 58:Ｎａ濃度警報点（上限） **/
  MonitorDataItem sodiumConcAlertPoint_Upper;
  /** 59:Ｎａ濃度警報点（下限） **/
  MonitorDataItem sodiumConcAlertPoint_Lower;
  /** 60:透析液温度警報点（上限） **/
  MonitorDataItem dialysateTempAlertPoint_Upper;
  /** 61:透析液温度警報点（下限） **/
  MonitorDataItem dialysateTempAlertPoint_Lower;
  /** 62:漏血量警報 **/
  MonitorDataItem bloodLeakageAlertPoint;
  /** 63:給水圧警報点（上限） **/
  MonitorDataItem supplyPressureAlertPoint_Upper;
  /** 64:給水圧警報点（下限） **/
  MonitorDataItem supplyPressureAlertPoint_Lower;
  /** 65:初期ＵＦＲ警報点（上限） **/
  MonitorDataItem initialUfrAlertPoint_Upper;
  /** 66:初期ＵＦＲ警報点（下限） **/
  MonitorDataItem initialUfrAlertPoint_Lower;
  /** 67:ＵＦＲ低下率警報 **/
  MonitorDataItem ufrDeclineRateAlertPoint;
  /** 68:Kt/V **/
  MonitorDataItem ktOverV;
  /** 69:運転中の血流量積算値 **/
  MonitorDataItem bloodVolumeIntegrated;
  /** 70:補液量設定値 **/
  MonitorDataItem replaceVolumeSetting;
  /** 71:補液速度 **/
  MonitorDataItem replaceSpeed;
  /** 72:補液量現在値 **/
  MonitorDataItem replaceVolumeNow;
  /** 73:補液速度設定値 **/
  MonitorDataItem replaceSpeedSetting;
  /** 74:補液温度 **/
  MonitorDataItem replaceTEMP;
  /** 75:補液温度設定値 **/
  MonitorDataItem replaceTEMPSetting;
  /** 76:濾液速度 **/
  MonitorDataItem filtrateSpeed;
  /** 77:荷重計 **/
  MonitorDataItem loadCell;
  /** 78:残り時間（補液完了） **/
  MonitorDataItem remainTime_Replace;
  /** 79:ＵＲＲ **/
  MonitorDataItem urr;
  /** 80:ΔＢＶ変化率 **/
  MonitorDataItem deltaBvChangeRate;
  /** 81:ＰＷＩ **/
  MonitorDataItem pwi;
  /** 82:ＢＰＭ関連データ１ **/
  MonitorDataItem bpmData1;
  /** 83:ＢＰＭ関連データ２ **/
  MonitorDataItem bpmData2;
  /** 84:ＢＰＭ関連データ３ **/
  MonitorDataItem bpmData3;
  /** 85:ΔBVリファレンスエリア上限 **/
  MonitorDataItem deltaBvReferenceArea_Upper;
  /** 86:ΔBVリファレンスエリア下限 **/
  MonitorDataItem deltaBvReferenceArea_Lower;
  /** 87:ＢＰＭ関連データ６ **/
  MonitorDataItem bpmData6;
  /** 88:ＰＲＲ **/
  MonitorDataItem prr;
  /** 89:再循環率測定結果（BVMS連携用） **/
  MonitorDataItem reCircurate;
  /** 90:最高血圧 **/
  MonitorDataItem bpMax;
  /** 91:最低血圧 **/
  MonitorDataItem bpMin;
  /** 92:平均血圧 **/
  MonitorDataItem bpAve;
  /** 93:脈拍 **/
  MonitorDataItem pulse;
  /** 94:体温 **/
  MonitorDataItem bodyTEMP;
  /** 95:ΔＢＶ 5分平均値 **/
  MonitorDataItem deltaBv5MinuteAve;
  /** 96:ΔＢＶ 最大最小を除いた5分平均値 **/
  MonitorDataItem deltaBv5MinuteAve_Trim;
  /** 97:推定血流量 **/
  MonitorDataItem estimateBloodVolume;
  /** 98:血流量不足率 **/
  MonitorDataItem bloodVolumeShortage;
  /** 99:予約 **/
  /** 100:ΔBV(BVplus) **/
  MonitorDataItem deltaBvPlus;
  /** 101:Ｈｔ **/
  MonitorDataItem ht;
  /** 102:ＬＤＱｂ　　 **/
  MonitorDataItem ldqb;

  /**
   * コンストラクタ
   * モニタデータのJSON文字列から各値がクラスフィールドに展開されます。
   * @param moniData モニタデータのJSON文字列
   */
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
  public MonitorDataDCS(String moniData) throws IOException{
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
    if (moniData != null && !moniData.equals("")) {
      // 引数を展開
      this.setItems(moniData);
    }
  }

  /**
   * 項目コード(1～24)を指定して、値を取得します。
   * @param itemCd DCSモニタデータ項目番号(アドレス)
   * @return
   */
  public MonitorDataItem getByItemCd(int itemCd) {
    MonitorDataItem rtn = null;

    if (itemCd == 0) {
      rtn = this.stateName;
    }
    if (itemCd == 1) {
      rtn = this.elapsedTime;
    }
    if (itemCd == 2) {
      rtn = this.elapsedTime_ECUM;
    }
    if (itemCd == 3) {
      rtn = this.remainTime_WaterRemoval;
    }
    if (itemCd == 4) {
      rtn = this.remainTime_Dialysis;
    }
    if (itemCd == 5) {
      rtn = this.waterRemovalIntegrated;
    }
    if (itemCd == 6) {
      rtn = this.waterRemovalSpeed;
    }
    if (itemCd == 7) {
      rtn = this.bloodCirculationVolume;
    }
    if (itemCd == 8) {
      rtn = this.bloodVolume;
    }
    if (itemCd == 9) {
      rtn = this.ipTotal;
    }
    if (itemCd == 10) {
      rtn = this.ipSpeed;
    }
    if (itemCd == 11) {
      rtn = this.venousPressure;
    }
    if (itemCd == 12) {
      rtn = this.dialysatePressure;
    }
    if (itemCd == 13) {
      rtn = this.tmp;
    }
    if (itemCd == 14) {
      rtn = this.dialyzerInletPressure;
    }
    if (itemCd == 15) {
      rtn = this.dialyzerDiffPressure;
    }
    if (itemCd == 16) {
      rtn = this.bloodInletVenousPressure;
    }
    if (itemCd == 17) {
      rtn = this.deltaBv;
    }
    if (itemCd == 18) {
      rtn = this.hco3Conc;
    }
    if (itemCd == 19) {
      rtn = this.dialysateConc;
    }
    if (itemCd == 20) {
      rtn = this.sodiumConc;
    }
    if (itemCd == 21) {
      rtn = this.dialysateTEMP;
    }
    if (itemCd == 22) {
      rtn = this.dialysateFlow;
    }
    if (itemCd == 23) {
      rtn = this.bloodLeakage;
    }
    if (itemCd == 24) {
      rtn = this.supplyPressure_Upper;
    }
    if (itemCd == 25) {
      rtn = this.supplyPressure_Lower;
    }
    if (itemCd == 26) {
      rtn = this.ufr;
    }
    if (itemCd == 27) {
      rtn = this.ufrDeclineRate;
    }
    if (itemCd == 28) {
      rtn = this.initialUfr;
    }
    if (itemCd == 29) {
      rtn = this.tmpCorrection;
    }
    if (itemCd == 30) {
      rtn = this.runningTime;
    }
    if (itemCd == 31) {
      rtn = this.treatMode;
    }
    if (itemCd == 32) {
      rtn = this.waterRemovalTarget;
    }
    if (itemCd == 33) {
      rtn = this.waterRemovalSpeedSetting;
    }
    if (itemCd == 34) {
      rtn = this.dialysateTempSetting;
    }
    if (itemCd == 35) {
      rtn = this.dialysateFlowSetting;
    }
    if (itemCd == 36) {
      rtn = this.bvSetting;
    }
    if (itemCd == 37) {
      rtn = this.ipSpeedSetting;
    }
    if (itemCd == 38) {
      rtn = this.ktOverV_Measure;
    }
    if (itemCd == 39) {
      rtn = this.venousPressureAlertPoint_Upper;
    }
    if (itemCd == 40) {
      rtn = this.venousPressureAlertPoint_Lower;
    }
    if (itemCd == 41) {
      rtn = this.dialysatePressureAlertPoint_Upper;
    }
    if (itemCd == 42) {
      rtn = this.dialysatePressureAlertPoint_Lower;
    }
    if (itemCd == 43) {
      rtn = this.tmpAlertPoint_Upper;
    }
    if (itemCd == 44) {
      rtn = this.tmpAlertPoint_Lower;
    }
    if (itemCd == 45) {
      rtn = this.dialyzerInletPressureAlertPoint_Upper;
    }
    if (itemCd == 46) {
      rtn = this.dialyzerInletPressureAlertPoint_Lower;
    }
    if (itemCd == 47) {
      rtn = this.dialyzerDiffPressureAlertPoint_Upper;
    }
    if (itemCd == 48) {
      rtn = this.dialyzerDiffPressureAlertPoint_Lower;
    }
    if (itemCd == 49) {
      rtn = this.deltaBvDeclineAlertPoint1;
    }
    if (itemCd == 50) {
      rtn = this.deltaBvDeclineAlertPoint2;
    }
    if (itemCd == 51) {
      rtn = this.deltaBvChangeRateAlertPoint;
    }
    if (itemCd == 52) {
      rtn = this.bpmData9;
    }
    if (itemCd == 53) {
      rtn = this.bpmData10;
    }
    if (itemCd == 54) {
      rtn = this.hco3ConcAlertPoint_Upper;
    }
    if (itemCd == 55) {
      rtn = this.hco3ConcAlertPoint_Lower;
    }
    if (itemCd == 56) {
      rtn = this.dialysateConcAlertPoint_Upper;
    }
    if (itemCd == 57) {
      rtn = this.dialysateConcAlertPoint_Lower;
    }
    if (itemCd == 58) {
      rtn = this.sodiumConcAlertPoint_Upper;
    }
    if (itemCd == 59) {
      rtn = this.sodiumConcAlertPoint_Lower;
    }
    if (itemCd == 60) {
      rtn = this.dialysateTempAlertPoint_Upper;
    }
    if (itemCd == 61) {
      rtn = this.dialysateTempAlertPoint_Lower;
    }
    if (itemCd == 62) {
      rtn = this.bloodLeakageAlertPoint;
    }
    if (itemCd == 63) {
      rtn = this.supplyPressureAlertPoint_Upper;
    }
    if (itemCd == 64) {
      rtn = this.supplyPressureAlertPoint_Lower;
    }
    if (itemCd == 65) {
      rtn = this.initialUfrAlertPoint_Upper;
    }
    if (itemCd == 66) {
      rtn = this.initialUfrAlertPoint_Lower;
    }
    if (itemCd == 67) {
      rtn = this.ufrDeclineRateAlertPoint;
    }
    if (itemCd == 68) {
      rtn = this.ktOverV;
    }
    if (itemCd == 69) {
      rtn = this.bloodVolumeIntegrated;
    }
    if (itemCd == 70) {
      rtn = this.replaceVolumeSetting;
    }
    if (itemCd == 71) {
      rtn = this.replaceSpeed;
    }
    if (itemCd == 72) {
      rtn = this.replaceVolumeNow;
    }
    if (itemCd == 73) {
      rtn = this.replaceSpeedSetting;
    }
    if (itemCd == 74) {
      rtn = this.replaceTEMP;
    }
    if (itemCd == 75) {
      rtn = this.replaceTEMPSetting;
    }
    if (itemCd == 76) {
      rtn = this.filtrateSpeed;
    }
    if (itemCd == 77) {
      rtn = this.loadCell;
    }
    if (itemCd == 78) {
      rtn = this.remainTime_Replace;
    }
    if (itemCd == 79) {
      rtn = this.urr;
    }
    if (itemCd == 80) {
      rtn = this.deltaBvChangeRate;
    }
    if (itemCd == 81) {
      rtn = this.pwi;
    }
    if (itemCd == 82) {
      rtn = this.bpmData1;
    }
    if (itemCd == 83) {
      rtn = this.bpmData2;
    }
    if (itemCd == 84) {
      rtn = this.bpmData3;
    }
    if (itemCd == 85) {
      rtn = this.deltaBvReferenceArea_Upper;
    }
    if (itemCd == 86) {
      rtn = this.deltaBvReferenceArea_Lower;
    }
    if (itemCd == 87) {
      rtn = this.bpmData6;
    }
    if (itemCd == 88) {
      rtn = this.prr;
    }
    if (itemCd == 89) {
      rtn = this.reCircurate;
    }
    if (itemCd == 90) {
      rtn = this.bpMax;
    }
    if (itemCd == 91) {
      rtn = this.bpMin;
    }
    if (itemCd == 92) {
      rtn = this.bpAve;
    }
    if (itemCd == 93) {
      rtn = this.pulse;
    }
    if (itemCd == 94) {
      rtn = this.bodyTEMP;
    }
    if (itemCd == 95) {
      rtn = this.deltaBv5MinuteAve;
    }
    if (itemCd == 96) {
      rtn = this.deltaBv5MinuteAve_Trim;
    }
    if (itemCd == 97) {
      rtn = this.estimateBloodVolume;
    }
    if (itemCd == 98) {
      rtn = this.bloodVolumeShortage;
    }
    if (itemCd == 100) {
      rtn = this.deltaBvPlus;
    }
    if (itemCd == 101) {
      rtn = this.ht;
    }
    if (itemCd == 102) {
      rtn = this.ldqb;
    }

    return rtn;
  }

  /**
   * モニタデータをクラスフィールドに展開します。
   * @param moniDataJsonString バイタル情報のJSON文字列
   */
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
  private void setItems(String moniDataJsonString)throws IOException{
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end

    if (moniDataJsonString != null) {
      ObjectMapper mapper = new ObjectMapper();
      try {
        JsonNode jsonNode = mapper.readTree(moniDataJsonString);

        // インスタンス変数に各値をセット
        /** 0:工程 **/
        this.stateName = new MonitorDataItem();
        try {
          this.stateName.value = this.getProcessName(Integer.parseInt(this.getJsonValueByKey(jsonNode, "0")));
        } catch (NumberFormatException e) {
          this.stateName.value = null;
        }

        /** 1:経過時間 **/
        this.elapsedTime = new MonitorDataItem();
        this.elapsedTime.value = this.getJsonValueByKey(jsonNode, "1");
        this.elapsedTime.Unit = "分";

        /** 2:経過時間（ＥＣＵＭ） **/
        this.elapsedTime_ECUM = new MonitorDataItem();
        this.elapsedTime_ECUM.value = this.getJsonValueByKey(jsonNode, "2");
        this.elapsedTime_ECUM.Unit = "分";

        /** 3:残り時間（除水完了） **/
        this.remainTime_WaterRemoval = new MonitorDataItem();
        this.remainTime_WaterRemoval.value = this.getJsonValueByKey(jsonNode, "3");
        this.remainTime_WaterRemoval.Unit = "分";

        /** 4:残り時間（透析完了） **/
        this.remainTime_Dialysis = new MonitorDataItem();
        this.remainTime_Dialysis.value = this.getJsonValueByKey(jsonNode, "4");
        this.remainTime_Dialysis.Unit = "分";

        /** 5:除水積算値 **/
        this.waterRemovalIntegrated = new MonitorDataItem();
        this.waterRemovalIntegrated.value = this.getJsonValueByKey(jsonNode, "5");
        this.waterRemovalIntegrated.Unit = "L";

        /** 6:除水速度 **/
        this.waterRemovalSpeed = new MonitorDataItem();
        this.waterRemovalSpeed.value = this.getJsonValueByKey(jsonNode, "6");
        this.waterRemovalSpeed.Unit = "L/h";

        /** 7:血液循環量 **/
        this.bloodCirculationVolume = new MonitorDataItem();
        this.bloodCirculationVolume.value = this.getJsonValueByKey(jsonNode, "7");
        this.bloodCirculationVolume.Unit = "L";

        /** 8:血流量 **/
        this.bloodVolume = new MonitorDataItem();
        this.bloodVolume.value = this.getJsonValueByKey(jsonNode, "8");
        this.bloodVolume.Unit = "mL/min";

        /** 9:ＩＰ総量 **/
        this.ipTotal = new MonitorDataItem();
        this.ipTotal.value = this.getJsonValueByKey(jsonNode, "9");
        this.ipTotal.Unit = "mL";

        /** 10:ＩＰ速度 **/
        this.ipSpeed = new MonitorDataItem();
        this.ipSpeed.value = this.getJsonValueByKey(jsonNode, "10");
        this.ipSpeed.Unit = "mL/h";

        /** 11:静脈圧 **/
        this.venousPressure = new MonitorDataItem();
        this.venousPressure.value = this.getJsonValueByKey(jsonNode, "11");
        this.venousPressure.Unit = "mmHg";

        /** 12:透析液圧 **/
        this.dialysatePressure = new MonitorDataItem();
        this.dialysatePressure.value = this.getJsonValueByKey(jsonNode, "12");
        this.dialysatePressure.Unit = "mmHg";

        /** 13:ＴＭＰ **/
        this.tmp = new MonitorDataItem();
        this.tmp.value = this.getJsonValueByKey(jsonNode, "13");
        this.tmp.Unit = "mmHg";

        /** 14:ダイアライザー入口圧 **/
        this.dialyzerInletPressure = new MonitorDataItem();
        this.dialyzerInletPressure.value = this.getJsonValueByKey(jsonNode, "14");
        this.dialyzerInletPressure.Unit = "mmHg";

        /** 15:ダイアライザー差圧 **/
        this.dialyzerDiffPressure = new MonitorDataItem();
        this.dialyzerDiffPressure.value = this.getJsonValueByKey(jsonNode, "15");
        this.dialyzerDiffPressure.Unit = "mmHg";

        /** 16:血液入口～静脈平均圧 **/
        this.bloodInletVenousPressure = new MonitorDataItem();
        this.bloodInletVenousPressure.value = this.getJsonValueByKey(jsonNode, "16");
        this.bloodInletVenousPressure.Unit = "mmHg";

        /** 17:ΔBV **/
        this.deltaBv = new MonitorDataItem();
        this.deltaBv.value = this.getJsonValueByKey(jsonNode, "17");
        this.deltaBv.Unit = "%";

        /** 18:バイカーボ濃度 **/
        this.hco3Conc = new MonitorDataItem();
        this.hco3Conc.value = this.getJsonValueByKey(jsonNode, "18");
        this.hco3Conc.Unit = "mS/cm";

        /** 19:透析液濃度 **/
        this.dialysateConc = new MonitorDataItem();
        this.dialysateConc.value = this.getJsonValueByKey(jsonNode, "19");
        this.dialysateConc.Unit = "mS/cm";

        /** 20:Ｎａ濃度 **/
        this.sodiumConc = new MonitorDataItem();
        this.sodiumConc.value = this.getJsonValueByKey(jsonNode, "20");
        this.sodiumConc.Unit = "mEq/L";

        /** 21:透析液温度 **/
        this.dialysateTEMP = new MonitorDataItem();
        this.dialysateTEMP.value = this.getJsonValueByKey(jsonNode, "21");
        this.dialysateTEMP.Unit = "℃";

        /** 22:透析液流量 **/
        this.dialysateFlow = new MonitorDataItem();
        this.dialysateFlow.value = this.getJsonValueByKey(jsonNode, "22");
        this.dialysateFlow.Unit = "mL/min";

        /** 23:漏血量 **/
        this.bloodLeakage = new MonitorDataItem();
        this.bloodLeakage.value = this.getJsonValueByKey(jsonNode, "23");
        this.bloodLeakage.Unit = "mL/L";

        /** 24:給液圧（上限） **/
        this.supplyPressure_Upper = new MonitorDataItem();
        this.supplyPressure_Upper.value = this.getJsonValueByKey(jsonNode, "24");
        this.supplyPressure_Upper.Unit = "kPa";

        /** 25:給液圧（下限） **/
        this.supplyPressure_Lower = new MonitorDataItem();
        this.supplyPressure_Lower.value = this.getJsonValueByKey(jsonNode, "25");
        this.supplyPressure_Lower.Unit = "kPa";

        /** 26:ＵＦＲ **/
        this.ufr = new MonitorDataItem();
        this.ufr.value = this.getJsonValueByKey(jsonNode, "26");
        this.ufr.Unit = "mL/h/mmHg";

        /** 27:ＵＦＲ低下率 **/
        this.ufrDeclineRate = new MonitorDataItem();
        this.ufrDeclineRate.value = this.getJsonValueByKey(jsonNode, "27");
        this.ufrDeclineRate.Unit = "%";

        /** 28:初期ＵＦＲ測定値 **/
        this.initialUfr = new MonitorDataItem();
        this.initialUfr.value = this.getJsonValueByKey(jsonNode, "28");
        this.initialUfr.Unit = "mL/h/mmHg";

        /** 29:ＴＭＰ補正値 **/
        this.tmpCorrection = new MonitorDataItem();
        this.tmpCorrection.value = this.getJsonValueByKey(jsonNode, "29");
        this.tmpCorrection.Unit = "mmHg";

        /** 30:透析運転時間 **/
        this.runningTime = new MonitorDataItem();
        this.runningTime.value = this.getJsonValueByKey(jsonNode, "30");
        this.runningTime.Unit = "分";

        /** 31:治療モード **/
        this.treatMode = new MonitorDataItem();
        try {
          this.treatMode.value = this.getTreatModeName(Integer.parseInt(this.getJsonValueByKey(jsonNode, "31")));
        } catch (NumberFormatException e) {
          this.treatMode.value = null;
        }

        /** 32:除水目標値 **/
        this.waterRemovalTarget = new MonitorDataItem();
        this.waterRemovalTarget.value = this.getJsonValueByKey(jsonNode, "32");
        this.waterRemovalTarget.Unit = "L";

        /** 33:除水速度設定値 **/
        this.waterRemovalSpeedSetting = new MonitorDataItem();
        this.waterRemovalSpeedSetting.value = this.getJsonValueByKey(jsonNode, "33");
        this.waterRemovalSpeedSetting.Unit = "L/h";

        /** 34:透析液温度設定値 **/
        this.dialysateTempSetting = new MonitorDataItem();
        this.dialysateTempSetting.value = this.getJsonValueByKey(jsonNode, "34");
        this.dialysateTempSetting.Unit = "℃";

        /** 35:透析液流量設定値 **/
        this.dialysateFlowSetting = new MonitorDataItem();
        this.dialysateFlowSetting.value = this.getJsonValueByKey(jsonNode, "35");
        this.dialysateFlowSetting.Unit = "mL/min";

        /** 36:血流量設定値 **/
        this.bvSetting = new MonitorDataItem();
        this.bvSetting.value = this.getJsonValueByKey(jsonNode, "36");
        this.bvSetting.Unit = "mL/min";

        /** 37:ＩＰ速度設定 **/
        this.ipSpeedSetting = new MonitorDataItem();
        this.ipSpeedSetting.value = this.getJsonValueByKey(jsonNode, "37");
        this.ipSpeedSetting.Unit = "mL/h";

        /** 38:Kt/V（測定値） **/
        this.ktOverV_Measure = new MonitorDataItem();
        this.ktOverV_Measure.value = this.getJsonValueByKey(jsonNode, "38");
        this.ktOverV_Measure.Unit = "";

        /** 39:静脈圧警報点（上限） **/
        this.venousPressureAlertPoint_Upper = new MonitorDataItem();
        this.venousPressureAlertPoint_Upper.value = this.getJsonValueByKey(jsonNode, "39");
        this.venousPressureAlertPoint_Upper.Unit = "mmHg";

        /** 40:静脈圧警報点（下限） **/
        this.venousPressureAlertPoint_Lower = new MonitorDataItem();
        this.venousPressureAlertPoint_Lower.value = this.getJsonValueByKey(jsonNode, "40");
        this.venousPressureAlertPoint_Lower.Unit = "mmHg";

        /** 41:透析液圧警報点（上限） **/
        this.dialysatePressureAlertPoint_Upper = new MonitorDataItem();
        this.dialysatePressureAlertPoint_Upper.value = this.getJsonValueByKey(jsonNode, "41");
        this.dialysatePressureAlertPoint_Upper.Unit = "mmHg";

        /** 42:透析液圧警報点（下限） **/
        this.dialysatePressureAlertPoint_Lower = new MonitorDataItem();
        this.dialysatePressureAlertPoint_Lower.value = this.getJsonValueByKey(jsonNode, "42");
        this.dialysatePressureAlertPoint_Lower.Unit = "mmHg";

        /** 43:ＴＭＰ警報点（上限） **/
        this.tmpAlertPoint_Upper = new MonitorDataItem();
        this.tmpAlertPoint_Upper.value = this.getJsonValueByKey(jsonNode, "43");
        this.tmpAlertPoint_Upper.Unit = "mmHg";

        /** 44:ＴＭＰ警報点（下限） **/
        this.tmpAlertPoint_Lower = new MonitorDataItem();
        this.tmpAlertPoint_Lower.value = this.getJsonValueByKey(jsonNode, "44");
        this.tmpAlertPoint_Lower.Unit = "mmHg";

        /** 45:ダイアライザー入口圧警報点（上限） **/
        this.dialyzerInletPressureAlertPoint_Upper = new MonitorDataItem();
        this.dialyzerInletPressureAlertPoint_Upper.value = this.getJsonValueByKey(jsonNode, "45");
        this.dialyzerInletPressureAlertPoint_Upper.Unit = "mmHg";

        /** 46:ダイアライザー入口圧警報点（下限） **/
        this.dialyzerInletPressureAlertPoint_Lower = new MonitorDataItem();
        this.dialyzerInletPressureAlertPoint_Lower.value = this.getJsonValueByKey(jsonNode, "46");
        this.dialyzerInletPressureAlertPoint_Lower.Unit = "mmHg";

        /** 47:ダイアライザー差圧警報点（上限） **/
        this.dialyzerDiffPressureAlertPoint_Upper = new MonitorDataItem();
        this.dialyzerDiffPressureAlertPoint_Upper.value = this.getJsonValueByKey(jsonNode, "47");
        this.dialyzerDiffPressureAlertPoint_Upper.Unit = "mmHg";

        /** 48:ダイアライザー差圧警報点（下限） **/
        this.dialyzerDiffPressureAlertPoint_Lower = new MonitorDataItem();
        this.dialyzerDiffPressureAlertPoint_Lower.value = this.getJsonValueByKey(jsonNode, "48");
        this.dialyzerDiffPressureAlertPoint_Lower.Unit = "mmHg";

        /** 49:ΔＢＶ低下警報点1 **/
        this.deltaBvDeclineAlertPoint1 = new MonitorDataItem();
        this.deltaBvDeclineAlertPoint1.value = this.getJsonValueByKey(jsonNode, "49");
        this.deltaBvDeclineAlertPoint1.Unit = "%";

        /** 50:ΔＢＶ低下警報点2 **/
        this.deltaBvDeclineAlertPoint2 = new MonitorDataItem();
        this.deltaBvDeclineAlertPoint2.value = this.getJsonValueByKey(jsonNode, "50");
        this.deltaBvDeclineAlertPoint2.Unit = "%";

        /** 51:ΔBV変化率警報点 **/
        this.deltaBvChangeRateAlertPoint = new MonitorDataItem();
        this.deltaBvChangeRateAlertPoint.value = this.getJsonValueByKey(jsonNode, "51");
        this.deltaBvChangeRateAlertPoint.Unit = "%/min";

        /** 52:ＢＰＭ関連データ９ **/
        this.bpmData9 = new MonitorDataItem();
        this.bpmData9.value = this.getJsonValueByKey(jsonNode, "52");
        this.bpmData9.Unit = "";

        /** 53:ＢＰＭ関連データ１０ **/
        this.bpmData10 = new MonitorDataItem();
        this.bpmData10.value = this.getJsonValueByKey(jsonNode, "53");
        this.bpmData10.Unit = "";

        /** 54:バイカーボ濃度警報点（上限） **/
        this.hco3ConcAlertPoint_Upper = new MonitorDataItem();
        this.hco3ConcAlertPoint_Upper.value = this.getJsonValueByKey(jsonNode, "54");
        this.hco3ConcAlertPoint_Upper.Unit = "mS/cm";

        /** 55:バイカーボ濃度警報点（下限） **/
        this.hco3ConcAlertPoint_Lower = new MonitorDataItem();
        this.hco3ConcAlertPoint_Lower.value = this.getJsonValueByKey(jsonNode, "55");
        this.hco3ConcAlertPoint_Lower.Unit = "mS/cm";

        /** 56:透析液濃度警報点（上限） **/
        this.dialysateConcAlertPoint_Upper = new MonitorDataItem();
        this.dialysateConcAlertPoint_Upper.value = this.getJsonValueByKey(jsonNode, "56");
        this.dialysateConcAlertPoint_Upper.Unit = "mS/cm";

        /** 57:透析液濃度警報点（下限） **/
        this.dialysateConcAlertPoint_Lower = new MonitorDataItem();
        this.dialysateConcAlertPoint_Lower.value = this.getJsonValueByKey(jsonNode, "57");
        this.dialysateConcAlertPoint_Lower.Unit = "mS/cm";

        /** 58:Ｎａ濃度警報点（上限） **/
        this.sodiumConcAlertPoint_Upper = new MonitorDataItem();
        this.sodiumConcAlertPoint_Upper.value = this.getJsonValueByKey(jsonNode, "58");
        this.sodiumConcAlertPoint_Upper.Unit = "mEq/L";

        /** 59:Ｎａ濃度警報点（下限） **/
        this.sodiumConcAlertPoint_Lower = new MonitorDataItem();
        this.sodiumConcAlertPoint_Lower.value = this.getJsonValueByKey(jsonNode, "59");
        this.sodiumConcAlertPoint_Lower.Unit = "mEq/L";

        /** 60:透析液温度警報点（上限） **/
        this.dialysateTempAlertPoint_Upper = new MonitorDataItem();
        this.dialysateTempAlertPoint_Upper.value = this.getJsonValueByKey(jsonNode, "60");
        this.dialysateTempAlertPoint_Upper.Unit = "℃";

        /** 61:透析液温度警報点（下限） **/
        this.dialysateTempAlertPoint_Lower = new MonitorDataItem();
        this.dialysateTempAlertPoint_Lower.value = this.getJsonValueByKey(jsonNode, "61");
        this.dialysateTempAlertPoint_Lower.Unit = "℃";

        /** 62:漏血量警報 **/
        this.bloodLeakageAlertPoint = new MonitorDataItem();
        this.bloodLeakageAlertPoint.value = this.getJsonValueByKey(jsonNode, "62");
        this.bloodLeakageAlertPoint.Unit = "mL/L";

        /** 63:給水圧警報点（上限） **/
        this.supplyPressureAlertPoint_Upper = new MonitorDataItem();
        this.supplyPressureAlertPoint_Upper.value = this.getJsonValueByKey(jsonNode, "63");
        this.supplyPressureAlertPoint_Upper.Unit = "kPa";

        /** 64:給水圧警報点（下限） **/
        this.supplyPressureAlertPoint_Lower = new MonitorDataItem();
        this.supplyPressureAlertPoint_Lower.value = this.getJsonValueByKey(jsonNode, "64");
        this.supplyPressureAlertPoint_Lower.Unit = "kPa";

        /** 65:初期ＵＦＲ警報点（上限） **/
        this.initialUfrAlertPoint_Upper = new MonitorDataItem();
        this.initialUfrAlertPoint_Upper.value = this.getJsonValueByKey(jsonNode, "65");
        this.initialUfrAlertPoint_Upper.Unit = "mL/h/mmHg";

        /** 66:初期ＵＦＲ警報点（下限） **/
        this.initialUfrAlertPoint_Lower = new MonitorDataItem();
        this.initialUfrAlertPoint_Lower.value = this.getJsonValueByKey(jsonNode, "66");
        this.initialUfrAlertPoint_Lower.Unit = "mL/h/mmHg";

        /** 67:ＵＦＲ低下率警報 **/
        this.ufrDeclineRateAlertPoint = new MonitorDataItem();
        this.ufrDeclineRateAlertPoint.value = this.getJsonValueByKey(jsonNode, "67");
        this.ufrDeclineRateAlertPoint.Unit = "%";

        /** 68:Kt/V **/
        this.ktOverV = new MonitorDataItem();
        this.ktOverV.value = this.getJsonValueByKey(jsonNode, "68");
        this.ktOverV.Unit = "";

        /** 69:運転中の血流量積算値 **/
        this.bloodVolumeIntegrated = new MonitorDataItem();
        this.bloodVolumeIntegrated.value = this.getJsonValueByKey(jsonNode, "69");
        this.bloodVolumeIntegrated.Unit = "L";

        /** 70:補液量設定値 **/
        this.replaceVolumeSetting = new MonitorDataItem();
        this.replaceVolumeSetting.value = this.getJsonValueByKey(jsonNode, "70");
        this.replaceVolumeSetting.Unit = "L";

        /** 71:補液速度 **/
        this.replaceSpeed = new MonitorDataItem();
        this.replaceSpeed.value = this.getJsonValueByKey(jsonNode, "71");
        this.replaceSpeed.Unit = "L/h";

        /** 72:補液量現在値 **/
        this.replaceVolumeNow = new MonitorDataItem();
        this.replaceVolumeNow.value = this.getJsonValueByKey(jsonNode, "72");
        this.replaceVolumeNow.Unit = "L";

        /** 73:補液速度設定値 **/
        this.replaceSpeedSetting = new MonitorDataItem();
        this.replaceSpeedSetting.value = this.getJsonValueByKey(jsonNode, "73");
        this.replaceSpeedSetting.Unit = "L/h";

        /** 74:補液温度 **/
        this.replaceTEMP = new MonitorDataItem();
        this.replaceTEMP.value = this.getJsonValueByKey(jsonNode, "74");
        this.replaceTEMP.Unit = "℃";

        /** 75:補液温度設定値 **/
        this.replaceTEMPSetting = new MonitorDataItem();
        this.replaceTEMPSetting.value = this.getJsonValueByKey(jsonNode, "75");
        this.replaceTEMPSetting.Unit = "℃";

        /** 76:濾液速度 **/
        this.filtrateSpeed = new MonitorDataItem();
        this.filtrateSpeed.value = this.getJsonValueByKey(jsonNode, "76");
        this.filtrateSpeed.Unit = "L/h";

        /** 77:荷重計 **/
        this.loadCell = new MonitorDataItem();
        this.loadCell.value = this.getJsonValueByKey(jsonNode, "77");
        this.loadCell.Unit = "kg";

        /** 78:残り時間（補液完了） **/
        this.remainTime_Replace = new MonitorDataItem();
        this.remainTime_Replace.value = this.getJsonValueByKey(jsonNode, "78");
        this.remainTime_Replace.Unit = "分";

        /** 79:ＵＲＲ **/
        this.urr = new MonitorDataItem();
        this.urr.value = this.getJsonValueByKey(jsonNode, "79");
        this.urr.Unit = "%";

        /** 80:ΔＢＶ変化率 **/
        this.deltaBvChangeRate = new MonitorDataItem();
        this.deltaBvChangeRate.value = this.getJsonValueByKey(jsonNode, "80");
        this.deltaBvChangeRate.Unit = "%/min";

        /** 81:ＰＷＩ **/
        this.pwi = new MonitorDataItem();
        this.pwi.value = this.getJsonValueByKey(jsonNode, "81");
        this.pwi.Unit = "";

        /** 82:ＢＰＭ関連データ１ **/
        this.bpmData1 = new MonitorDataItem();
        this.bpmData1.value = this.getJsonValueByKey(jsonNode, "82");
        this.bpmData1.Unit = "";

        /** 83:ＢＰＭ関連データ２ **/
        this.bpmData2 = new MonitorDataItem();
        this.bpmData2.value = this.getJsonValueByKey(jsonNode, "83");
        this.bpmData2.Unit = "";

        /** 84:ＢＰＭ関連データ３ **/
        this.bpmData3 = new MonitorDataItem();
        this.bpmData3.value = this.getJsonValueByKey(jsonNode, "84");
        this.bpmData3.Unit = "";

        /** 85:ΔBVリファレンスエリア上限 **/
        this.deltaBvReferenceArea_Upper = new MonitorDataItem();
        this.deltaBvReferenceArea_Upper.value = this.getJsonValueByKey(jsonNode, "85");
        this.deltaBvReferenceArea_Upper.Unit = "";

        /** 86:ΔBVリファレンスエリア下限 **/
        this.deltaBvReferenceArea_Lower = new MonitorDataItem();
        this.deltaBvReferenceArea_Lower.value = this.getJsonValueByKey(jsonNode, "86");
        this.deltaBvReferenceArea_Lower.Unit = "";

        /** 87:ＢＰＭ関連データ６ **/
        this.bpmData6 = new MonitorDataItem();
        this.bpmData6.value = this.getJsonValueByKey(jsonNode, "87");
        this.bpmData6.Unit = "";

        /** 88:ＰＲＲ **/
        this.prr = new MonitorDataItem();
        this.prr.value = this.getJsonValueByKey(jsonNode, "88");
        this.prr.Unit = "";

        /** 89:再循環率測定結果（BVMS連携用） **/
        this.reCircurate = new MonitorDataItem();
        this.reCircurate.value = this.getJsonValueByKey(jsonNode, "89");
        this.reCircurate.Unit = "%";

        /** 90:最高血圧 **/
        this.bpMax = new MonitorDataItem();
        this.bpMax.value = this.getJsonValueByKey(jsonNode, "90");
        this.bpMax.Unit = "mmHg";

        /** 91:最低血圧 **/
        this.bpMin = new MonitorDataItem();
        this.bpMin.value = this.getJsonValueByKey(jsonNode, "91");
        this.bpMin.Unit = "mmHg";

        /** 92:平均血圧 **/
        this.bpAve = new MonitorDataItem();
        this.bpAve.value = this.getJsonValueByKey(jsonNode, "92");
        this.bpAve.Unit = "mmHg";

        /** 93:脈拍 **/
        this.pulse = new MonitorDataItem();
        this.pulse.value = this.getJsonValueByKey(jsonNode, "93");
        this.pulse.Unit = "bpm";

        /** 94:体温 **/
        this.bodyTEMP = new MonitorDataItem();
        this.bodyTEMP.value = this.getJsonValueByKey(jsonNode, "94");
        this.bodyTEMP.Unit = "℃";

        /** 95:ΔＢＶ 5分平均値 **/
        this.deltaBv5MinuteAve = new MonitorDataItem();
        this.deltaBv5MinuteAve.value = this.getJsonValueByKey(jsonNode, "95");
        this.deltaBv5MinuteAve.Unit = "%";

        /** 96:ΔＢＶ 最大最小を除いた5分平均値 **/
        this.deltaBv5MinuteAve_Trim = new MonitorDataItem();
        this.deltaBv5MinuteAve_Trim.value = this.getJsonValueByKey(jsonNode, "96");
        this.deltaBv5MinuteAve_Trim.Unit = "%";

        /** 97:推定血流量 **/
        this.estimateBloodVolume = new MonitorDataItem();
        this.estimateBloodVolume.value = this.getJsonValueByKey(jsonNode, "97");
        this.estimateBloodVolume.Unit = "mL/min";

        /** 98:血流量不足率 **/
        this.bloodVolumeShortage = new MonitorDataItem();
        this.bloodVolumeShortage.value = this.getJsonValueByKey(jsonNode, "98");
        this.bloodVolumeShortage.Unit = "%";

        /** 99:予約 **/

        /** 100:ΔBV(BVplus) **/
        this.deltaBvPlus = new MonitorDataItem();
        this.deltaBvPlus.value = this.getJsonValueByKey(jsonNode, "100");
        this.deltaBvPlus.Unit = "%";

        /** 101:Ｈｔ **/
        this.ht = new MonitorDataItem();
        this.ht.value = this.getJsonValueByKey(jsonNode, "101");
        this.ht.Unit = "%";

        /** 102:ＬＤＱｂ **/
        this.ldqb = new MonitorDataItem();
        this.ldqb.value = this.getJsonValueByKey(jsonNode, "102");
        this.ldqb.Unit = "mL/min";

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
   * 工程コードから工程名称を取得する
   * @param cd 工程コード(1～11)
   * @return 工程名称
   */
  private String getProcessName(int cd) {
    String rtn;
    switch (cd) {
    case 1:
      rtn = "プリセット";
      break;
    case 2:
      rtn = "洗浄";
      break;
    case 3:
      rtn = "酸洗";
      break;
    case 4:
      rtn = "消毒";
      break;
    case 5:
      rtn = "滞留";
      break;
    case 6:
      rtn = "液置換";
      break;
    case 7:
      rtn = "透析準備";
      break;
    case 8:
      rtn = "ガスパージ";
      break;
    case 9:
      rtn = "排液";
      break;
    case 10:
      rtn = "停止";
      break;
    case 11:
      rtn = "運転";
      break;
    default:
      rtn = null;
    }

    return rtn;
  }

  /**
   * 治療モードコードから治療モード名称を取得する
   * @param cd 治療モードコード(0～10)
   * @return 治療モード名称
   */
  private String getTreatModeName(int cd) {
    String rtn;
    switch (cd) {
    case 0:
      rtn = "HD";
      break;
    case 1:
      rtn = "ECUM";
      break;
    case 2:
      rtn = "HDF";
      break;
    case 3:
      rtn = "HF";
      break;
    case 4:
      rtn = "HD+補液";
      break;
    case 5:
      rtn = "予約";
      break;
    case 6:
      rtn = "AFBF";
      break;
    case 7:
      rtn = "OHDF";
      break;
    case 8:
      rtn = "OHF";
      break;
    case 9:
      rtn = "予約";
      break;
    case 10:
      rtn = "I-HDF";
      break;
    default:
      rtn = null;
    }

    return rtn;
  }

}
