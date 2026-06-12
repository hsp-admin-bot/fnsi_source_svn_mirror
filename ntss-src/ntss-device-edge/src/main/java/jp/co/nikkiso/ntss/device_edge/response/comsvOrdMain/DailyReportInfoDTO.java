package jp.co.nikkiso.ntss.device_edge.response.comsvOrdMain;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Timestamp;
import java.util.List;

import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import com.google.common.base.Objects;

import jp.co.nikkiso.ntss.device_edge.constant.Constant.DailyReportDispItemCd;
import jp.co.nikkiso.ntss.device_edge.util.Utilities;
import jp.co.nikkiso.ntss.device_edge.util.CondInfo.CondInfo;
import jp.co.nikkiso.ntss.device_edge.util.EquipmentInfo.EquipmentInfo;
import jp.co.nikkiso.ntss.device_edge.util.MedicineInfo.MedicineInfo;
import jp.co.nikkiso.ntss.device_edge.util.VitalInfo.VitalInfo;
import jp.co.nikkiso.ntss.device_edge.util.WeightInfo.WeightInfo;
import lombok.Getter;

/**
 *  通信サーバ仮想端末 透析日報のDTO.
 */
@Getter
public class DailyReportInfoDTO {

  /** 01:透析開始時刻*/
  private LcdResponseStruct treatSartTime;
  /** 02:透析終了時刻*/
  private LcdResponseStruct treatEndDate;
  /** 03:目標体重*/
  private LcdResponseStruct weightTarget;
  /** 04:前体重*/
  private LcdResponseStruct weightBefore;
  /** 05:前最高血圧*/
  private LcdResponseStruct bpMaxBefore;
  /** 06:前最低血圧*/
  private LcdResponseStruct bpMinBefore;
  /** 07:前平均血圧*/
  private LcdResponseStruct bpAveBefore;
  /** 08:前脈拍*/
  private LcdResponseStruct pulseBefore;
  /** 09:後体重*/
  private LcdResponseStruct weightAfter;
  /** 10:後最高血圧*/
  private LcdResponseStruct bpMaxAfter;
  /** 11:後最低血圧*/
  private LcdResponseStruct bpMinAfter;
  /** 12:後平均血圧*/
  private LcdResponseStruct bpAveAfter;
  /** 13:後脈拍*/
  private LcdResponseStruct pulseAfter;
  /** 14:除水速度制限*/
  private LcdResponseStruct ufrLimit;
  /** 15:除水量制限*/
  private LcdResponseStruct removalLimit;
  /** 16:透析時間*/
  private LcdResponseStruct treatTime;
  /** 17:目標除水量*/
  private LcdResponseStruct removalTarget;
  /** 18:血流量*/
  private LcdResponseStruct bv;
  /** 19:IP速度*/
  private LcdResponseStruct ipSpeed;
  /** 20:透析回数*/
  private LcdResponseStruct dialysisCnt;
  /** 21:実績除水量*/
  private LcdResponseStruct rstRemoval;
  /** 22:実績血液循環量*/
  private LcdResponseStruct rstBvCirculate;
  /** 23:治療法*/
  private LcdResponseStruct treatName;
  /** 24:DW*/
  private LcdResponseStruct dw;
  /** 25:CTR*/
  private LcdResponseStruct ctr;
  /** 26:血液型*/
  private LcdResponseStruct bloodTypeAbo;
  /** 27:RH*/
  private LcdResponseStruct bloodTypeRh;
  /** 28:VA*/
  private LcdResponseStruct va;
  /** 29:ダイアライザ*/
  private LcdResponseStruct dialyzer;
  /** 30:透析液*/
  private LcdResponseStruct dialysisFluid;
  /** 31:抗凝固剤*/
  private LcdResponseStruct anticoagulant;
  /** 32:(凝)初回注入量*/
  private LcdResponseStruct antInputOneShot;
  /** 33:(凝)持続注入量*/
  private LcdResponseStruct antInputCont;
  /** 34:(凝)持続総量*/
  private LcdResponseStruct antInputContTotal;
  /** 35:(凝)合計注入量*/
  private LcdResponseStruct antInputTotal;
  /** 36:前回後体重*/
  private LcdResponseStruct lastWeightAfter;
  /** 37:除水速度*/
  private LcdResponseStruct ufr;
  /** 38:補液速度*/
  private LcdResponseStruct fluidReplacementRate;
  /** 39:補液温度設定値*/
  private LcdResponseStruct fluidReplacementTemperature;
  /** 40:補液量設定値*/
  private LcdResponseStruct fluidReplacementVolumeSetting;
  /** 41:補液速度限界値*/
  private LcdResponseStruct fluidReplacementRateLimit;
  /** 42:補液量設定値制限*/
  private LcdResponseStruct fluidReplacementVolumeSettingLimit;
  /** 43:入外区分*/
  private LcdResponseStruct inOut;
  /** 44:前体重ーDW*/
  private LcdResponseStruct beforeWeightMinusDw;
  /** 45:前体重ー前回後体重*/
  private LcdResponseStruct beforeWeightMinusLastAfterWeight;
  /** 46:前回後体重ー前体重*/
  private LcdResponseStruct lastAfterWeightMinusBeforeWeight;
  /** 47:前体重ー後体重*/
  private LcdResponseStruct beforeWeightMinusAfterWeight;
  /** 48:後体重ー前体重*/
  private LcdResponseStruct afterWeightMinusBeforeWeight;
  /** 49:除水補正値合計g*/
  private LcdResponseStruct ufrAmendTotal_g;
  /** 50:除水補正値合計L*/
  private LcdResponseStruct ufrAmendTotal_L;
  /** 51:クール名*/
  private LcdResponseStruct kurName;
  /** 52:ベッド名*/
  private LcdResponseStruct bedName;
  /** 53:穿刺者*/
  private LcdResponseStruct punctureName;
  /** 54:回収者*/
  private LcdResponseStruct returnName;
  /** 55:病棟名*/
  private LcdResponseStruct wardName;
  /** 56:ダイアライザ膜面積*/
  private LcdResponseStruct dialyzerArea;
  /** 57:消耗品01*/
  private LcdResponseStruct equip01;
  /** 58:消耗品02*/
  private LcdResponseStruct equip02;
  /** 59:消耗品03*/
  private LcdResponseStruct equip03;
  /** 60:消耗品04*/
  private LcdResponseStruct equip04;
  /** 61:消耗品05*/
  private LcdResponseStruct equip05;
  /** 62:消耗品06*/
  private LcdResponseStruct equip06;
  /** 63:消耗品07*/
  private LcdResponseStruct equip07;
  /** 64:消耗品08*/
  private LcdResponseStruct equip08;
  /** 65:消耗品09*/
  private LcdResponseStruct equip09;
  /** 66:消耗品10*/
  private LcdResponseStruct equip10;
  /** 67:薬剤01*/
  private LcdResponseStruct medi01;
  /** 68:薬剤02*/
  private LcdResponseStruct medi02;
  /** 69:薬剤03*/
  private LcdResponseStruct medi03;
  /** 70:薬剤04*/
  private LcdResponseStruct medi04;
  /** 71:薬剤05*/
  private LcdResponseStruct medi05;
  /** 72:薬剤06*/
  private LcdResponseStruct medi06;
  /** 73:薬剤07*/
  private LcdResponseStruct medi07;
  /** 74:薬剤08*/
  private LcdResponseStruct medi08;
  /** 75:薬剤09*/
  private LcdResponseStruct medi09;
  /** 76:薬剤10*/
  private LcdResponseStruct medi10;
  /** 77:薬剤11*/
  private LcdResponseStruct medi11;
  /** 78:薬剤12*/
  private LcdResponseStruct medi12;
  /** 79:薬剤13*/
  private LcdResponseStruct medi13;
  /** 80:薬剤14*/
  private LcdResponseStruct medi14;
  /** 81:薬剤15*/
  private LcdResponseStruct medi15;
  /** 82:薬剤16*/
  private LcdResponseStruct medi16;
  /** 83:薬剤17*/
  private LcdResponseStruct medi17;
  /** 84:薬剤18*/
  private LcdResponseStruct medi18;
  /** 85:薬剤19*/
  private LcdResponseStruct medi19;
  /** 86:薬剤20*/
  private LcdResponseStruct medi20;
  // add FNSI-バグ 通信サーバ #8009 高 start
  /** 87:血液回路*/
  private LcdResponseStruct bloodCircuit;
  /** 88:吸着カラム*/
  private LcdResponseStruct adsorbent;
  /** 89:補液*/
  private LcdResponseStruct fluidReplacement;
  // add FNSI-バグ 通信サーバ #8009 高 end

  /**
   * コンストラクタ
   */
  public DailyReportInfoDTO() {
    // インスタンス変数を初期化
    this.initialize();
    // 通信サーバで値をセットする項目にコードをセットする
    this.setNoValueItemsCd();
  }

  /***********
   * Setter
   ***********/
  /** 01:透析開始時刻
   * @param treatStartDate */
  public void setTreatSartDate(Timestamp treatStartDate) {
    // インスタンス変数にセット
    this.treatSartTime.setCd(DailyReportDispItemCd.START_TIME);
    if (treatStartDate != null) {
      this.treatSartTime.setValue(treatStartDate.toString());
    }
  }

  /** 02:透析終了時刻
   * @param treatEndDate */
  public void setTreatEndDate(Timestamp treatEndDate) {
    // インスタンス変数にセット
    this.treatEndDate.setCd(DailyReportDispItemCd.END_DATE);
    if (treatEndDate != null) {
      this.treatEndDate.setValue(treatEndDate.toString());
    }
  }

  /** 16:透析時間
   * @param treatTime */
  public void setTreatTime(Short treatTime) {
    // インスタンス変数にセット
    this.treatTime.setCd(DailyReportDispItemCd.TREAT_TIME);
    if (treatTime != null) {
      this.treatTime.setValue(treatTime.toString());
    } else {
      this.treatTime.setValue(null);
    }
  }

  /** 20:透析回数
   * @param dialysisCnt */
  public void setDialysisCnt(Integer dialysisCnt) {
    // インスタンス変数にセット
    this.dialysisCnt.setCd(DailyReportDispItemCd.DIALYSIS_CNT);
    if (dialysisCnt != null) {
      this.dialysisCnt.setValue(dialysisCnt.toString());
    } else {
      this.dialysisCnt.setValue(null);
    }
  }

  /** 22:実績血液循環量
   * @param bvCirculate */
  public void setRstBvCirculate(Double bvCirculate) {
    // インスタンス変数にセット
    this.rstBvCirculate.setCd(DailyReportDispItemCd.RST_BV_CIRCULATE);
    if (bvCirculate != null) {
      this.rstBvCirculate.setValue(bvCirculate.toString());
    } else {
      this.rstBvCirculate.setValue(null);
    }
  }

  /** 23:治療法
   * @param treatName */
  public void setTreatName(String treatName) {
    // インスタンス変数にセット
    this.treatName.setCd(DailyReportDispItemCd.TREAT_NAME);
    this.treatName.setName(treatName);
  }

  /** 24:DW
   * @param dw */
  public void setDw(BigDecimal dw) {
    // インスタンス変数にセット
    this.dw.setCd(DailyReportDispItemCd.DW);
    if (dw != null) {
      this.dw.setValue(dw.toString());
    } else {
      this.dw.setValue(null);
    }
  }

  /** 26:血液型(ABO) */
  public void setBloodTypeAbo(Integer bloodTypeCd_ABO) {
    // コードから血液型名称を取得
    String bloodTypeName = Utilities.bloodTypeValueToName_ABO(bloodTypeCd_ABO);
    // インスタンス変数にセット
    this.bloodTypeAbo.setCd(DailyReportDispItemCd.BLOOD_TYPE_ABO);
    this.bloodTypeAbo.setName(bloodTypeName);
    this.bloodTypeAbo.setValue(String.valueOf(bloodTypeCd_ABO));
  }

  /** 27:血液型(RH) */
  public void setBloodTypeRh(Integer bloodTypeCd_RH) {
    // コードから血液型名称を取得
    String bloodTypeName = Utilities.bloodTypeValueToName_RH(bloodTypeCd_RH);
    // インスタンス変数にセット
    this.bloodTypeRh.setCd(DailyReportDispItemCd.BLOOD_TYPE_RH);
    this.bloodTypeRh.setName(bloodTypeName);
    this.bloodTypeRh.setValue(String.valueOf(bloodTypeCd_RH));
  }

  /** 36:前回後体重
   * @param lastWeightInfo */
  public void setLastWeightAfter(WeightInfo lastWeightInfo) {
    // インスタンス変数にセット
    this.lastWeightAfter.setCd(DailyReportDispItemCd.LAST_WEIGHT_AFTER);
    if (lastWeightInfo != null) {
      this.lastWeightAfter.setValue(lastWeightInfo.getWeightAfter());
    } else {
      this.lastWeightAfter.setValue(null);
    }
  }

  /** 43:入外区分
   * @param inOutClass */
  public void setInOut(Short inOutClass) {
    // インスタンス変数にセット
    this.inOut.setCd(DailyReportDispItemCd.IN_OUT);
    if (inOutClass != null) {
      this.inOut.setValue(inOutClass.toString());
      this.inOut.setName(Utilities.inOutCdToName(Integer.valueOf(inOutClass)));
    } else {
      this.inOut.setValue(null);
      this.inOut.setName(null);
    }
  }

  /**
   * 除水補正値合計を算出しインスタンス変数にセットします。
   * 対象：除水補正値合計(g)、除水補正値合計(L)
   * @param offWaterInfo
   */
  public void setUfrAmendTotal(String offWaterInfo) {
    this.ufrAmendTotal_g.setCd(DailyReportDispItemCd.UFR_AMEND_TOTAL_G);
    this.ufrAmendTotal_g.setUnit("g");
    this.ufrAmendTotal_L.setCd(DailyReportDispItemCd.UFR_AMEND_TOTAL_L);
    this.ufrAmendTotal_L.setUnit("L");

    /** off_water_infoに格納されている値の単位はグラムである) **/

    // JSON文字列を展開
    ObjectMapper mapper = new ObjectMapper();
    try {
      // 親ノード
      JsonNode jsonNode = mapper.readTree(offWaterInfo);
      // 各値のノード
      JsonNode weight1Node = jsonNode.get("weight_1");
      JsonNode weight2Node = jsonNode.get("weight_2");
      JsonNode weight3Node = jsonNode.get("weight_3");
      JsonNode weight4Node = jsonNode.get("weight_4");
      JsonNode weight5Node = jsonNode.get("weight_5");

      // 各値の取得
      BigDecimal weight1 = new BigDecimal(weight1Node.asText());
      BigDecimal weight2 = new BigDecimal(weight2Node.asText());
      BigDecimal weight3 = new BigDecimal(weight3Node.asText());
      BigDecimal weight4 = new BigDecimal(weight4Node.asText());
      BigDecimal weight5 = new BigDecimal(weight5Node.asText());

      // 合計値(g)
      BigDecimal total_g = BigDecimal.ZERO;
      total_g = total_g.add(weight1);
      total_g = total_g.add(weight2);
      total_g = total_g.add(weight3);
      total_g = total_g.add(weight4);
      total_g = total_g.add(weight5);

      // 合計値(L)
      // 除算の結果は小数点以下2桁とし、丸め処理は3桁目を切り上げる
      BigDecimal divisor = BigDecimal.valueOf(1000);
      int scale = 2;
      BigDecimal total_L = total_g.divide(divisor, scale, RoundingMode.UP);

      // インスタンス変数にセット
      this.ufrAmendTotal_g.setValue(total_g.toString());
      this.ufrAmendTotal_L.setValue(total_L.toString());

    } catch (Exception e) {
      // 例外が発生した場合は値を空文字列とする
      this.ufrAmendTotal_g.setValue("");
      this.ufrAmendTotal_L.setValue("");
    }
  }

  /** 51:クール名
   * @param kurName */
  public void setKurName(String kurName) {
    // インスタンス変数にセット
    this.kurName.setCd(DailyReportDispItemCd.KUR_NAME);
    this.kurName.setName(kurName);
  }

  /** 52:ベッド名
   * @param bedName */
  public void setBedName(String bedName) {
    // インスタンス変数にセット
    this.bedName.setCd(DailyReportDispItemCd.BED_NAME);
    this.bedName.setName(bedName);
  }

  /** 53:穿刺者
   * @param puncUserName
   * @param puncUserId */
  public void setPunctureName(Long puncUserId, String puncUserName) {
    // インスタンス変数にセット
    this.punctureName.setCd(DailyReportDispItemCd.PUNCTURE_NAME);
    if (puncUserId != null) {
      this.punctureName.setValue(puncUserId.toString());
    } else {
      this.punctureName.setValue(null);
    }
    this.punctureName.setName(puncUserName);
  }

  /** 54:回収者
   * @param returnUserName
   * @param returnUserId */
  public void setReturnName(Long returnUserId, String returnUserName) {
    // インスタンス変数にセット
    this.returnName.setCd(DailyReportDispItemCd.RETURN_NAME);
    if (returnUserId != null) {
      this.returnName.setValue(returnUserId.toString());
    } else {
      this.returnName.setValue(null);
    }
    this.returnName.setName(returnUserName);
  }

  /** 55:病棟名
   * @param wardName */
  public void setWardName(String wardName) {
    // インスタンス変数にセット
    this.wardName.setCd(DailyReportDispItemCd.WARD_NAME);
    this.wardName.setName(wardName);
  }

  /** 56:ダイアライザ膜面積
   * @param dialyzerArea
   */
  public void setDialyzerArea(Double dialyzerArea) {
    // インスタンス変数にセット
    this.dialyzerArea.setCd(DailyReportDispItemCd.DIALYZER_AREA);
    if (dialyzerArea != null) {
      this.dialyzerArea.setValue(dialyzerArea.toString());
    } else {
      this.dialyzerArea.setValue(null);
    }
  }

  /**
   * 消耗品情報をフィールドへセットする。
   * 引数のリストの先頭から10件が格納対象。
   * @param 消耗品情報
   */
  public void setEquips(List<EquipmentInfo> equipmentInfoList) {
    if (equipmentInfoList != null) {
      for (int lop = 0; lop < equipmentInfoList.size(); lop++) {
        EquipmentInfo buf = equipmentInfoList.get(lop);
        switch (lop) {
        case 0:
          /** 57:消耗品01*/
          this.equip01.setCd(DailyReportDispItemCd.EQUIP01);
          this.equip01.setName(buf.getName());
          this.equip01.setValue(buf.getAmount());
          this.equip01.setUnit(buf.getUnit());
          break;

        case 1:
          /** 58:消耗品02*/
          this.equip02.setCd(DailyReportDispItemCd.EQUIP02);
          this.equip02.setName(buf.getName());
          this.equip02.setValue(buf.getAmount());
          this.equip02.setUnit(buf.getUnit());
          break;
        case 2:
          /** 59:消耗品03*/
          this.equip03.setCd(DailyReportDispItemCd.EQUIP03);
          this.equip03.setName(buf.getName());
          this.equip03.setValue(buf.getAmount());
          this.equip03.setUnit(buf.getUnit());
          break;
        case 3:
          /** 60:消耗品04*/
          this.equip04.setCd(DailyReportDispItemCd.EQUIP04);
          this.equip04.setName(buf.getName());
          this.equip04.setValue(buf.getAmount());
          this.equip04.setUnit(buf.getUnit());
          break;
        case 4:
          /** 61:消耗品05*/
          this.equip05.setCd(DailyReportDispItemCd.EQUIP05);
          this.equip05.setName(buf.getName());
          this.equip05.setValue(buf.getAmount());
          this.equip05.setUnit(buf.getUnit());
          break;
        case 5:
          /** 62:消耗品06*/
          this.equip06.setCd(DailyReportDispItemCd.EQUIP06);
          this.equip06.setName(buf.getName());
          this.equip06.setValue(buf.getAmount());
          this.equip06.setUnit(buf.getUnit());
          break;
        case 6:
          /** 63:消耗品07*/
          this.equip07.setCd(DailyReportDispItemCd.EQUIP07);
          this.equip07.setName(buf.getName());
          this.equip07.setValue(buf.getAmount());
          this.equip07.setUnit(buf.getUnit());
          break;
        case 7:
          /** 64:消耗品08*/
          this.equip08.setCd(DailyReportDispItemCd.EQUIP08);
          this.equip08.setName(buf.getName());
          this.equip08.setValue(buf.getAmount());
          this.equip08.setUnit(buf.getUnit());
          break;
        case 8:
          /** 65:消耗品09*/
          this.equip09.setCd(DailyReportDispItemCd.EQUIP09);
          this.equip09.setName(buf.getName());
          this.equip09.setValue(buf.getAmount());
          this.equip09.setUnit(buf.getUnit());
          break;
        case 9:
          /** 66:消耗品10*/
          this.equip10.setCd(DailyReportDispItemCd.EQUIP10);
          this.equip10.setName(buf.getName());
          this.equip10.setValue(buf.getAmount());
          this.equip10.setUnit(buf.getUnit());
          break;
        }
      }
    }
  }

  /**
   * 薬剤名称をフィールドへセットする
   * 引数のリストの先頭から20件が格納対象。
   * @param 薬剤情報
   */
  public void setMedis(List<MedicineInfo> medicineInfoList) {
    if (medicineInfoList != null) {
      for (int lop = 0; lop < medicineInfoList.size(); lop++) {
        MedicineInfo buf = medicineInfoList.get(lop);
        switch (lop) {
        case 0:
          /** 67:薬剤01*/
          this.medi01.setCd(DailyReportDispItemCd.MEDI01);
          this.medi01.setName(buf.getName());
          this.medi01.setValue(buf.getAmount());
          this.medi01.setUnit(buf.getUnit());
          break;
        case 1:
          /** 68:薬剤02*/
          this.medi02.setCd(DailyReportDispItemCd.MEDI02);
          this.medi02.setName(buf.getName());
          this.medi02.setValue(buf.getAmount());
          this.medi02.setUnit(buf.getUnit());
          break;
        case 2:
          /** 69:薬剤03*/
          this.medi03.setCd(DailyReportDispItemCd.MEDI03);
          this.medi03.setName(buf.getName());
          this.medi03.setValue(buf.getAmount());
          this.medi03.setUnit(buf.getUnit());
          break;
        case 3:
          /** 70:薬剤04*/
          this.medi04.setCd(DailyReportDispItemCd.MEDI04);
          this.medi04.setName(buf.getName());
          this.medi04.setValue(buf.getAmount());
          this.medi04.setUnit(buf.getUnit());
          break;
        case 4:
          /** 71:薬剤05*/
          this.medi05.setCd(DailyReportDispItemCd.MEDI05);
          this.medi05.setName(buf.getName());
          this.medi05.setValue(buf.getAmount());
          this.medi05.setUnit(buf.getUnit());
          break;
        case 5:
          /** 72:薬剤06*/
          this.medi06.setCd(DailyReportDispItemCd.MEDI06);
          this.medi06.setName(buf.getName());
          this.medi06.setValue(buf.getAmount());
          this.medi06.setUnit(buf.getUnit());
          break;
        case 6:
          /** 73:薬剤07*/
          this.medi07.setCd(DailyReportDispItemCd.MEDI07);
          this.medi07.setName(buf.getName());
          this.medi07.setValue(buf.getAmount());
          this.medi07.setUnit(buf.getUnit());
          break;
        case 7:
          /** 74:薬剤08*/
          this.medi08.setCd(DailyReportDispItemCd.MEDI08);
          this.medi08.setName(buf.getName());
          this.medi08.setValue(buf.getAmount());
          this.medi08.setUnit(buf.getUnit());
          break;
        case 8:
          /** 75:薬剤09*/
          this.medi09.setCd(DailyReportDispItemCd.MEDI09);
          this.medi09.setName(buf.getName());
          this.medi09.setValue(buf.getAmount());
          this.medi09.setUnit(buf.getUnit());
          break;
        case 9:
          /** 76:薬剤10*/
          this.medi10.setCd(DailyReportDispItemCd.MEDI10);
          this.medi10.setName(buf.getName());
          this.medi10.setValue(buf.getAmount());
          this.medi10.setUnit(buf.getUnit());
          break;
        case 10:
          /** 77:薬剤11*/
          this.medi11.setCd(DailyReportDispItemCd.MEDI11);
          this.medi11.setName(buf.getName());
          this.medi11.setValue(buf.getAmount());
          this.medi11.setUnit(buf.getUnit());
          break;
        case 11:
          /** 78:薬剤12*/
          this.medi12.setCd(DailyReportDispItemCd.MEDI12);
          this.medi12.setName(buf.getName());
          this.medi12.setValue(buf.getAmount());
          this.medi12.setUnit(buf.getUnit());
          break;
        case 12:
          /** 79:薬剤13*/
          this.medi13.setCd(DailyReportDispItemCd.MEDI13);
          this.medi13.setName(buf.getName());
          this.medi13.setValue(buf.getAmount());
          this.medi13.setUnit(buf.getUnit());
          break;
        case 13:
          /** 80:薬剤14*/
          this.medi14.setCd(DailyReportDispItemCd.MEDI14);
          this.medi14.setName(buf.getName());
          this.medi14.setValue(buf.getAmount());
          this.medi14.setUnit(buf.getUnit());
          break;
        case 14:
          /** 81:薬剤15*/
          this.medi15.setCd(DailyReportDispItemCd.MEDI15);
          this.medi15.setName(buf.getName());
          this.medi15.setValue(buf.getAmount());
          this.medi15.setUnit(buf.getUnit());
          break;
        case 15:
          /** 82:薬剤16*/
          this.medi16.setCd(DailyReportDispItemCd.MEDI16);
          this.medi16.setName(buf.getName());
          this.medi16.setValue(buf.getAmount());
          this.medi16.setUnit(buf.getUnit());
          break;
        case 16:
          /** 83:薬剤17*/
          this.medi17.setCd(DailyReportDispItemCd.MEDI17);
          this.medi17.setName(buf.getName());
          this.medi17.setValue(buf.getAmount());
          this.medi17.setUnit(buf.getUnit());
          break;
        case 17:
          /** 84:薬剤18*/
          this.medi18.setCd(DailyReportDispItemCd.MEDI18);
          this.medi18.setName(buf.getName());
          this.medi18.setValue(buf.getAmount());
          this.medi18.setUnit(buf.getUnit());
          break;
        case 18:
          /** 85:薬剤19*/
          this.medi19.setCd(DailyReportDispItemCd.MEDI19);
          this.medi19.setName(buf.getName());
          this.medi19.setValue(buf.getAmount());
          this.medi19.setUnit(buf.getUnit());
          break;
        case 19:
          /** 86:薬剤20*/
          this.medi20.setCd(DailyReportDispItemCd.MEDI20);
          this.medi20.setName(buf.getName());
          this.medi20.setValue(buf.getAmount());
          this.medi20.setUnit(buf.getUnit());
          break;
        }
      }
    }
  }

  /**
   * 治療条件をフィールドへセットする
   * @param condInfo 治療条件情報クラス
   */
  public void setConds(CondInfo condInfo) {
    if (condInfo != null) {
      /** 03:目標体重*/
      this.weightTarget.setCd(DailyReportDispItemCd.WEIGHT_TARGET);
      if (condInfo.getTargetWeight() != null) {
        this.weightTarget.setValue(condInfo.getTargetWeight().getValue());
        this.weightTarget.setUnit(condInfo.getTargetWeight().getUnit());
      }
      /** 15:除水量制限*/
      this.removalLimit.setCd(DailyReportDispItemCd.REMOVAL_LIMIT);
      if (condInfo.getUfrLimit() != null) {
        this.removalLimit.setValue(condInfo.getUfrLimit().getValue());
        this.removalLimit.setUnit(condInfo.getUfrLimit().getUnit());
      }
      /** 18:血流量*/
      this.bv.setCd(DailyReportDispItemCd.BV);
      if (condInfo.getBv() != null) {
        this.bv.setValue(condInfo.getBv().getValue());
        this.bv.setUnit(condInfo.getBv().getUnit());
      }
      /** 19:IP速度*/
      this.ipSpeed.setCd(DailyReportDispItemCd.IP_SPEED);
      if (condInfo.getIpSpeed() != null) {
        this.ipSpeed.setValue(condInfo.getIpSpeed().getValue());
        this.ipSpeed.setUnit(condInfo.getIpSpeed().getUnit());
      }
      /** 28:VA*/
      this.va.setCd(DailyReportDispItemCd.VA);
      if (condInfo.getVa() != null) {
        this.va.setName(condInfo.getVa().getName());
      }
      /** 29:ダイアライザ*/
      this.dialyzer.setCd(DailyReportDispItemCd.DIALYZER);
      if (condInfo.getDialyzer() != null) {
        this.dialyzer.setName(condInfo.getDialyzer().getName());
      }
      /** 30:透析液*/
      this.dialysisFluid.setCd(DailyReportDispItemCd.DIALYSIS_FLUID);
      if (condInfo.getDialysisFluid() != null) {
        this.dialysisFluid.setName(condInfo.getDialysisFluid().getName());
      }
      /** 31:抗凝固剤*/
      this.anticoagulant.setCd(DailyReportDispItemCd.ANTICOAGULANT);
      if (condInfo.getAnticoagulant() != null) {
        this.anticoagulant.setName(condInfo.getAnticoagulant().getName());
      }
      /** 32:(凝)初回注入量*/
      this.antInputOneShot.setCd(DailyReportDispItemCd.ANT_INPUT_ONESHOT);
      if (condInfo.getAntInputOneshot() != null) {
        this.antInputOneShot.setValue(condInfo.getAntInputOneshot().getValue());
        this.antInputOneShot.setUnit(condInfo.getAntInputOneshot().getUnit());
      }
      /** 33:(凝)持続注入量*/
      this.antInputCont.setCd(DailyReportDispItemCd.ANT_INPUT_CONT);
      if (condInfo.getAntInputCont() != null) {
        this.antInputCont.setValue(condInfo.getAntInputCont().getValue());
        this.antInputCont.setUnit(condInfo.getAntInputCont().getUnit());
      }
      /** 34:(凝)持続総量*/
      this.antInputContTotal.setCd(DailyReportDispItemCd.ANT_INPUT_CONT_TOTAL);
      if (condInfo.getAntInputContTotal() != null) {
        this.antInputContTotal.setValue(condInfo.getAntInputContTotal().getValue());
        this.antInputContTotal.setUnit(condInfo.getAntInputContTotal().getUnit());
      }
      /** 38:補液速度*/
      this.fluidReplacementRate.setCd(DailyReportDispItemCd.FLUID_REPLACEMENT_RATE);
      if (condInfo.getFluidReplacementRate() != null) {
        this.fluidReplacementRate.setValue(condInfo.getFluidReplacementRate().getValue());
        this.fluidReplacementRate.setUnit(condInfo.getFluidReplacementRate().getUnit());
      }
      /** 39:補液温度設定値*/
      this.fluidReplacementTemperature.setCd(DailyReportDispItemCd.FLUID_REPLACEMENT_TEMPERATURE);
      if (condInfo.getFluidReplacementTemperature() != null) {
        this.fluidReplacementTemperature.setValue(condInfo.getFluidReplacementTemperature().getValue());
        this.fluidReplacementTemperature.setUnit(condInfo.getFluidReplacementTemperature().getUnit());
      }
      /** 40:補液量設定値*/
      this.fluidReplacementVolumeSetting.setCd(DailyReportDispItemCd.FLUID_REPLACEMENT_VOLUME_SETTING);
      if (condInfo.getFluidReplacementVolume() != null) {
        this.fluidReplacementVolumeSetting.setValue(condInfo.getFluidReplacementVolume().getValue());
        this.fluidReplacementVolumeSetting.setUnit(condInfo.getFluidReplacementVolume().getUnit());
      }
      // add FNSI-バグ 通信サーバ #8009 高 start
      /** 87:血液回路*/
      this.bloodCircuit.setCd(DailyReportDispItemCd.BLOOD_CIRCUIT);
      if (condInfo.getBloodCircuit() != null) {
        this.bloodCircuit.setName(condInfo.getBloodCircuit().getName());
      }
      /** 88:吸着カラム*/
      this.adsorbent.setCd(DailyReportDispItemCd.ADSORBENT);
      if (condInfo.getAdsorbent() != null) {
        this.adsorbent.setName(condInfo.getAdsorbent().getName());
      }
      /** 89:補液*/
      this.fluidReplacement.setCd(DailyReportDispItemCd.FLUID_REPLACEMENT);
      if (condInfo.getFluidReplacement() != null) {
        this.fluidReplacement.setName(condInfo.getFluidReplacement().getName());
      }
      // add FNSI-バグ 通信サーバ #8009 高 end
    }
  }

  /**
   * バイタル情報をフィールドへセットする
   * @param vitalInfo バイタル情報クラス
   */
  public void setVitals(VitalInfo vitalInfo) {
    if (vitalInfo != null) {
      /** 05:前最高血圧*/
      this.bpMaxBefore.setCd(DailyReportDispItemCd.BP_MAX_BEFORE);
      this.bpMaxBefore.setValue(vitalInfo.getBpMaxBefore());

      /** 06:前最低血圧*/
      this.bpMinBefore.setCd(DailyReportDispItemCd.BP_MIN_BEFORE);
      this.bpMinBefore.setValue(vitalInfo.getBpMinBefore());

      /** 07:前平均血圧*/
      this.bpAveBefore.setCd(DailyReportDispItemCd.BP_AVE_BEFORE);
      this.bpAveBefore.setValue(vitalInfo.getBpAveBefore());

      /** 07:前脈拍*/
      this.pulseBefore.setCd(DailyReportDispItemCd.PULSE_BEFORE);
      this.pulseBefore.setValue(vitalInfo.getPulseBefore());

      /** 10:後最高血圧*/
      this.bpMaxAfter.setCd(DailyReportDispItemCd.BP_MAX_AFTER);
      this.bpMaxAfter.setValue(vitalInfo.getBpMaxAfter());

      /** 11:後最低血圧*/
      this.bpMinAfter.setCd(DailyReportDispItemCd.BP_MIN_AFTER);
      this.bpMinAfter.setValue(vitalInfo.getBpMinAfter());

      /** 12:後平均血圧*/
      this.bpAveAfter.setCd(DailyReportDispItemCd.BP_AVE_AFTER);
      this.bpAveAfter.setValue(vitalInfo.getBpAveAfter());

      /** 13:後脈拍*/
      this.pulseAfter.setCd(DailyReportDispItemCd.PULSE_AFTER);
      this.pulseAfter.setValue(vitalInfo.getPulseAfter());
    }
  }

  /**
   * 体重情報をフィールドへセットする
   * @param weightInfo
   */
  public void setWeights(WeightInfo weightInfo) {
    if (weightInfo != null) {
      /** 04:前体重*/
      this.weightBefore.setCd(DailyReportDispItemCd.WEIGHT_BEFORE);
      this.weightBefore.setValue(weightInfo.getWeightBefore());

      /** 09:後体重*/
      this.weightAfter.setCd(DailyReportDispItemCd.WEIGHT_AFTER);
      this.weightAfter.setValue(weightInfo.getWeightAfter());

      /** 17:目標除水量*/
      this.removalTarget.setCd(DailyReportDispItemCd.REMOVAL_TARGET);
      this.removalTarget.setValue(weightInfo.getWaterRemovalTarget());

      /** 21:実績除水量*/
      this.rstRemoval.setCd(DailyReportDispItemCd.RST_REMOVAL);
      this.rstRemoval.setValue(weightInfo.getWaterRemovalRst());

      /** 25:CTR*/
      this.ctr.setCd(DailyReportDispItemCd.CTR);
      this.ctr.setValue(weightInfo.getCtr());
    }
  }

  /**
   * 抗凝固剤合計注入量を計算してインスタンス変数にセットする
   */
  public void setAntInputTotal() {
    // 抗凝固剤ワンショット量と抗凝固剤持続総量の和を求める
    BigDecimal oneShot;
    if (this.antInputOneShot.getValue() != null) {
      oneShot = new BigDecimal(this.antInputOneShot.getValue());
    } else {
      oneShot = BigDecimal.ZERO;
    }
    BigDecimal contTotal;
    if (this.antInputContTotal.getValue() != null) {
      contTotal = new BigDecimal(this.antInputContTotal.getValue());
    } else {
      contTotal = BigDecimal.ZERO;
    }
    // 合計値
    BigDecimal buf = oneShot.add(contTotal);
    BigDecimal total = buf.setScale(2, RoundingMode.UP);
    // インスタンス変数にセット
    this.antInputTotal.setCd(DailyReportDispItemCd.ANT_INPUT_TOTAL);
    this.antInputTotal.setValue(total.toString());

  }

  /**
   * 体重値の算出項目を計算しインスタンス変数にセットする
   * 対象：前体重ーDW、前体重ー前回後体重、前回後体重ー前体重、前体重ー後体重、後体重ー前体重
  */
  public void setWeightCalculationValue() {
    // DW
    BigDecimal dw;
    if (this.dw.getValue() != null && !Objects.equal(this.dw.getValue(), "null")) {
      dw = new BigDecimal(this.dw.getValue());
    } else {
      dw = BigDecimal.ZERO;
    }
    // 前体重
    BigDecimal weightBefore;
    if (this.weightBefore.getValue() != null && !Objects.equal(this.weightBefore.getValue(), "null")) {
      weightBefore = new BigDecimal(this.weightBefore.getValue());
    } else {
      weightBefore = BigDecimal.ZERO;
    }
    // 後体重
    BigDecimal weightAfter;
    if (this.weightAfter.getValue() != null && !Objects.equal(this.weightAfter.getValue(), "null")) {
      weightAfter = new BigDecimal(this.weightAfter.getValue());
    } else {
      weightAfter = BigDecimal.ZERO;
    }
    // 前回後体重
    BigDecimal lastWeightAfter;
    if (this.lastWeightAfter.getValue() != null && !Objects.equal(this.lastWeightAfter.getValue(), "null")) {
      lastWeightAfter = new BigDecimal(this.lastWeightAfter.getValue());
    } else {
      lastWeightAfter = BigDecimal.ZERO;
    }

    // 前体重ーDW
    BigDecimal buf1 = weightBefore.subtract(dw);
    BigDecimal beforeWeight_Dw = buf1.setScale(2, RoundingMode.DOWN);
    // 前体重ー前回後体重
    BigDecimal buf2 = weightBefore.subtract(lastWeightAfter);
    BigDecimal beforeWeight_lastAfterWeight = buf2.setScale(2, RoundingMode.DOWN);
    // 前回後体重ー前体重
    BigDecimal buf3 = lastWeightAfter.subtract(weightBefore);
    BigDecimal lastAfterWeight_beforeWeight = buf3.setScale(2, RoundingMode.DOWN);
    // 前体重ー後体重
    BigDecimal buf4 = weightBefore.subtract(weightAfter);
    BigDecimal beforeWeight_afterWeight = buf4.setScale(2, RoundingMode.DOWN);
    // 後体重ー前体重
    BigDecimal buf5 = weightAfter.subtract(weightBefore);
    BigDecimal afterWeight_beforeWeight = buf5.setScale(2, RoundingMode.DOWN);

    // インスタンス変数にセット
    /** 44:前体重ーDW*/
    this.beforeWeightMinusDw.setCd(DailyReportDispItemCd.BEFORE_WEIGHT_MINUS_DW);
    this.beforeWeightMinusDw.setValue(beforeWeight_Dw.toString());

    /** 45:前体重ー前回後体重*/
    this.beforeWeightMinusLastAfterWeight.setCd(DailyReportDispItemCd.BEFORE_WEIGHT_MINUS_LAST_AFTER_WEIGHT);
    this.beforeWeightMinusLastAfterWeight.setValue(beforeWeight_lastAfterWeight.toString());

    /** 46:前回後体重ー前体重*/
    this.lastAfterWeightMinusBeforeWeight.setCd(DailyReportDispItemCd.LAST_AFTER_WEIGHT_MINUS_BEFORE_WEIGHT);
    this.lastAfterWeightMinusBeforeWeight.setValue(lastAfterWeight_beforeWeight.toString());

    /** 47:前体重ー後体重*/
    this.beforeWeightMinusAfterWeight.setCd(DailyReportDispItemCd.BEFORE_WEIGHT_MINUS_AFTER_WEIGHT);
    this.beforeWeightMinusAfterWeight.setValue(beforeWeight_afterWeight.toString());

    /** 48:後体重ー前体重*/
    this.afterWeightMinusBeforeWeight.setCd(DailyReportDispItemCd.AFTER_WEIGHT_MINUS_BEFORE_WEIGHT);
    this.afterWeightMinusBeforeWeight.setValue(afterWeight_beforeWeight.toString());

  }

  /**
   * 算出項目を計算しインスタンス変数にセットする
   * 対象：抗凝固剤合計注入量、前体重ーDW、前体重ー前回後体重、前回後体重ー前体重、前体重ー後体重、後体重ー前体重
  */
  public void setAllCalculationValue() {
    /** 35:(凝)合計注入量*/
    this.setAntInputTotal();

    // 体重関連算出値をセット
    this.setWeightCalculationValue();
  }

  /**
   * 項目コードに対応した値を返す
   * @param itemCd 仮想端末透析日報項目コード
   * @return
   */
  public LcdResponseStruct getReportItemByCd(int itemCd) {
    LcdResponseStruct rtn = new LcdResponseStruct();

    switch (itemCd) {
    case DailyReportDispItemCd.START_TIME:
      rtn = this.treatSartTime;
      break;
    case DailyReportDispItemCd.END_DATE:
      rtn = this.treatEndDate;
      break;
    case DailyReportDispItemCd.WEIGHT_TARGET:
      rtn = this.weightTarget;
      break;
    case DailyReportDispItemCd.WEIGHT_BEFORE:
      rtn = this.weightBefore;
      break;
    case DailyReportDispItemCd.BP_MAX_BEFORE:
      rtn = this.bpMaxBefore;
      break;
    case DailyReportDispItemCd.BP_MIN_BEFORE:
      rtn = this.bpMinBefore;
      break;
    case DailyReportDispItemCd.BP_AVE_BEFORE:
      rtn = this.bpAveBefore;
      break;
    case DailyReportDispItemCd.PULSE_BEFORE:
      rtn = this.pulseBefore;
      break;
    case DailyReportDispItemCd.WEIGHT_AFTER:
      rtn = this.weightAfter;
      break;
    case DailyReportDispItemCd.BP_MAX_AFTER:
      rtn = this.bpMaxAfter;
      break;
    case DailyReportDispItemCd.BP_MIN_AFTER:
      rtn = this.bpMinAfter;
      break;
    case DailyReportDispItemCd.BP_AVE_AFTER:
      rtn = this.bpAveAfter;
      break;
    case DailyReportDispItemCd.PULSE_AFTER:
      rtn = this.pulseAfter;
      break;
    case DailyReportDispItemCd.UFR_LIMIT:
      rtn = this.ufrLimit;
      break;
    case DailyReportDispItemCd.REMOVAL_LIMIT:
      rtn = this.removalLimit;
      break;
    case DailyReportDispItemCd.TREAT_TIME:
      rtn = this.treatTime;
      break;
    case DailyReportDispItemCd.REMOVAL_TARGET:
      rtn = this.removalTarget;
      break;
    case DailyReportDispItemCd.BV:
      rtn = this.bv;
      break;
    case DailyReportDispItemCd.IP_SPEED:
      rtn = this.ipSpeed;
      break;
    case DailyReportDispItemCd.DIALYSIS_CNT:
      rtn = this.dialysisCnt;
      break;
    case DailyReportDispItemCd.RST_REMOVAL:
      rtn = this.rstRemoval;
      break;
    case DailyReportDispItemCd.RST_BV_CIRCULATE:
      rtn = this.rstBvCirculate;
      break;
    case DailyReportDispItemCd.TREAT_NAME:
      rtn = this.treatName;
      break;
    case DailyReportDispItemCd.DW:
      rtn = this.dw;
      break;
    case DailyReportDispItemCd.CTR:
      rtn = this.ctr;
      break;
    case DailyReportDispItemCd.BLOOD_TYPE_ABO:
      rtn = this.bloodTypeAbo;
      break;
    case DailyReportDispItemCd.BLOOD_TYPE_RH:
      rtn = this.bloodTypeRh;
      break;
    case DailyReportDispItemCd.VA:
      rtn = this.va;
      break;
    case DailyReportDispItemCd.DIALYZER:
      rtn = this.dialyzer;
      break;
    case DailyReportDispItemCd.DIALYSIS_FLUID:
      rtn = this.dialysisFluid;
      break;
    case DailyReportDispItemCd.ANTICOAGULANT:
      rtn = this.anticoagulant;
      break;
    case DailyReportDispItemCd.ANT_INPUT_ONESHOT:
      rtn = this.antInputOneShot;
      break;
    case DailyReportDispItemCd.ANT_INPUT_CONT:
      rtn = this.antInputCont;
      break;
    case DailyReportDispItemCd.ANT_INPUT_CONT_TOTAL:
      rtn = this.antInputContTotal;
      break;
    case DailyReportDispItemCd.ANT_INPUT_TOTAL:
      rtn = this.antInputTotal;
      break;
    case DailyReportDispItemCd.LAST_WEIGHT_AFTER:
      rtn = this.lastWeightAfter;
      break;
    case DailyReportDispItemCd.UFR:
      rtn = this.ufr;
      break;
    case DailyReportDispItemCd.FLUID_REPLACEMENT_RATE:
      rtn = this.fluidReplacementRate;
      break;
    case DailyReportDispItemCd.FLUID_REPLACEMENT_TEMPERATURE:
      rtn = this.fluidReplacementTemperature;
      break;
    case DailyReportDispItemCd.FLUID_REPLACEMENT_VOLUME_SETTING:
      rtn = this.fluidReplacementVolumeSetting;
      break;
    case DailyReportDispItemCd.FLUID_REPLACEMENT_RATE_LIMIT:
      rtn = this.fluidReplacementRateLimit;
      break;
    case DailyReportDispItemCd.FLUID_REPLACEMENT_VOLUME_SETTING_LIMIT:
      rtn = this.fluidReplacementVolumeSettingLimit;
      break;
    case DailyReportDispItemCd.IN_OUT:
      rtn = this.inOut;
      break;
    case DailyReportDispItemCd.BEFORE_WEIGHT_MINUS_DW:
      rtn = this.beforeWeightMinusDw;
      break;
    case DailyReportDispItemCd.BEFORE_WEIGHT_MINUS_LAST_AFTER_WEIGHT:
      rtn = this.beforeWeightMinusLastAfterWeight;
      break;
    case DailyReportDispItemCd.LAST_AFTER_WEIGHT_MINUS_BEFORE_WEIGHT:
      rtn = this.lastAfterWeightMinusBeforeWeight;
      break;
    case DailyReportDispItemCd.BEFORE_WEIGHT_MINUS_AFTER_WEIGHT:
      rtn = this.beforeWeightMinusAfterWeight;
      break;
    case DailyReportDispItemCd.AFTER_WEIGHT_MINUS_BEFORE_WEIGHT:
      rtn = this.afterWeightMinusBeforeWeight;
      break;
    case DailyReportDispItemCd.UFR_AMEND_TOTAL_G:
      rtn = this.ufrAmendTotal_g;
      break;
    case DailyReportDispItemCd.UFR_AMEND_TOTAL_L:
      rtn = this.ufrAmendTotal_L;
      break;
    case DailyReportDispItemCd.KUR_NAME:
      rtn = this.kurName;
      break;
    case DailyReportDispItemCd.BED_NAME:
      rtn = this.bedName;
      break;
    case DailyReportDispItemCd.PUNCTURE_NAME:
      rtn = this.punctureName;
      break;
    case DailyReportDispItemCd.RETURN_NAME:
      rtn = this.returnName;
      break;
    case DailyReportDispItemCd.WARD_NAME:
      rtn = this.wardName;
      break;
    case DailyReportDispItemCd.DIALYZER_AREA:
      rtn = this.dialyzerArea;
      break;
    case DailyReportDispItemCd.EQUIP01:
      rtn = this.equip01;
      break;
    case DailyReportDispItemCd.EQUIP02:
      rtn = this.equip02;
      break;
    case DailyReportDispItemCd.EQUIP03:
      rtn = this.equip03;
      break;
    case DailyReportDispItemCd.EQUIP04:
      rtn = this.equip04;
      break;
    case DailyReportDispItemCd.EQUIP05:
      rtn = this.equip05;
      break;
    case DailyReportDispItemCd.EQUIP06:
      rtn = this.equip06;
      break;
    case DailyReportDispItemCd.EQUIP07:
      rtn = this.equip07;
      break;
    case DailyReportDispItemCd.EQUIP08:
      rtn = this.equip08;
      break;
    case DailyReportDispItemCd.EQUIP09:
      rtn = this.equip09;
      break;
    case DailyReportDispItemCd.EQUIP10:
      rtn = this.equip10;
      break;
    case DailyReportDispItemCd.MEDI01:
      rtn = this.medi01;
      break;
    case DailyReportDispItemCd.MEDI02:
      rtn = this.medi02;
      break;
    case DailyReportDispItemCd.MEDI03:
      rtn = this.medi03;
      break;
    case DailyReportDispItemCd.MEDI04:
      rtn = this.medi04;
      break;
    case DailyReportDispItemCd.MEDI05:
      rtn = this.medi05;
      break;
    case DailyReportDispItemCd.MEDI06:
      rtn = this.medi06;
      break;
    case DailyReportDispItemCd.MEDI07:
      rtn = this.medi07;
      break;
    case DailyReportDispItemCd.MEDI08:
      rtn = this.medi08;
      break;
    case DailyReportDispItemCd.MEDI09:
      rtn = this.medi09;
      break;
    case DailyReportDispItemCd.MEDI10:
      rtn = this.medi10;
      break;
    case DailyReportDispItemCd.MEDI11:
      rtn = this.medi11;
      break;
    case DailyReportDispItemCd.MEDI12:
      rtn = this.medi12;
      break;
    case DailyReportDispItemCd.MEDI13:
      rtn = this.medi13;
      break;
    case DailyReportDispItemCd.MEDI14:
      rtn = this.medi14;
      break;
    case DailyReportDispItemCd.MEDI15:
      rtn = this.medi15;
      break;
    case DailyReportDispItemCd.MEDI16:
      rtn = this.medi16;
      break;
    case DailyReportDispItemCd.MEDI17:
      rtn = this.medi17;
      break;
    case DailyReportDispItemCd.MEDI18:
      rtn = this.medi18;
      break;
    case DailyReportDispItemCd.MEDI19:
      rtn = this.medi19;
      break;
    case DailyReportDispItemCd.MEDI20:
      rtn = this.medi20;
      break;
    // add FNSI-バグ 通信サーバ #8009 高 start
    case DailyReportDispItemCd.BLOOD_CIRCUIT:
      rtn = this.bloodCircuit;
      break;
    case DailyReportDispItemCd.ADSORBENT:
      rtn = this.adsorbent;
      break;
    case DailyReportDispItemCd.FLUID_REPLACEMENT:
      rtn = this.fluidReplacement;
      break;
    // add FNSI-バグ 通信サーバ #8009 高 end
    default:
    }
    return rtn;
  }

  /**
   * 通信サーバ仮想端末透析日報表示設定から表示する項目コードの一覧を取得する.
   * @param jsonString
   * @return
   */
  public int[] getDispOrderList(String jsonString) {
    int[] intArray = new int[8];
    ObjectMapper mapper = new ObjectMapper();
    try {
      JsonNode jsonNode = mapper.readTree(jsonString);
      JsonNode reportItem_node = jsonNode.get("report_item");

      for (int lop = 0; lop < reportItem_node.size(); lop++) {
        JsonNode child = reportItem_node.get(lop);
        int no = child.get("no").asInt() - 1;
        int code = child.get("code").asInt();

        intArray[no] = code;
      }

    } catch (Exception e) {

    }

    return intArray;
  }

  /****** プライベートメソッド *********/

  /**
   * インスタンス変数を初期化します。
   */
  private void initialize() {
    this.treatSartTime = new LcdResponseStruct();
    this.treatEndDate = new LcdResponseStruct();
    this.weightTarget = new LcdResponseStruct();
    this.weightBefore = new LcdResponseStruct();
    this.bpMaxBefore = new LcdResponseStruct();
    this.bpMinBefore = new LcdResponseStruct();
    this.bpAveBefore = new LcdResponseStruct();
    this.pulseBefore = new LcdResponseStruct();
    this.weightAfter = new LcdResponseStruct();
    this.bpMaxAfter = new LcdResponseStruct();
    this.bpMinAfter = new LcdResponseStruct();
    this.bpAveAfter = new LcdResponseStruct();
    this.pulseAfter = new LcdResponseStruct();
    this.ufrLimit = new LcdResponseStruct();
    this.removalLimit = new LcdResponseStruct();
    this.treatTime = new LcdResponseStruct();
    this.removalTarget = new LcdResponseStruct();
    this.bv = new LcdResponseStruct();
    this.ipSpeed = new LcdResponseStruct();
    this.dialysisCnt = new LcdResponseStruct();
    this.rstRemoval = new LcdResponseStruct();
    this.rstBvCirculate = new LcdResponseStruct();
    this.treatName = new LcdResponseStruct();
    this.dw = new LcdResponseStruct();
    this.ctr = new LcdResponseStruct();
    this.bloodTypeAbo = new LcdResponseStruct();
    this.bloodTypeRh = new LcdResponseStruct();
    this.va = new LcdResponseStruct();
    this.dialyzer = new LcdResponseStruct();
    this.dialysisFluid = new LcdResponseStruct();
    this.anticoagulant = new LcdResponseStruct();
    this.antInputOneShot = new LcdResponseStruct();
    this.antInputCont = new LcdResponseStruct();
    this.antInputContTotal = new LcdResponseStruct();
    this.antInputTotal = new LcdResponseStruct();
    this.lastWeightAfter = new LcdResponseStruct();
    this.ufr = new LcdResponseStruct();
    this.fluidReplacementRate = new LcdResponseStruct();
    this.fluidReplacementTemperature = new LcdResponseStruct();
    this.fluidReplacementVolumeSetting = new LcdResponseStruct();
    this.fluidReplacementRateLimit = new LcdResponseStruct();
    this.fluidReplacementVolumeSettingLimit = new LcdResponseStruct();
    this.inOut = new LcdResponseStruct();
    this.beforeWeightMinusDw = new LcdResponseStruct();
    this.beforeWeightMinusLastAfterWeight = new LcdResponseStruct();
    this.lastAfterWeightMinusBeforeWeight = new LcdResponseStruct();
    this.beforeWeightMinusAfterWeight = new LcdResponseStruct();
    this.afterWeightMinusBeforeWeight = new LcdResponseStruct();
    this.ufrAmendTotal_g = new LcdResponseStruct();
    this.ufrAmendTotal_L = new LcdResponseStruct();
    this.kurName = new LcdResponseStruct();
    this.bedName = new LcdResponseStruct();
    this.punctureName = new LcdResponseStruct();
    this.returnName = new LcdResponseStruct();
    this.wardName = new LcdResponseStruct();
    this.dialyzerArea = new LcdResponseStruct();
    this.equip01 = new LcdResponseStruct();
    this.equip02 = new LcdResponseStruct();
    this.equip03 = new LcdResponseStruct();
    this.equip04 = new LcdResponseStruct();
    this.equip05 = new LcdResponseStruct();
    this.equip06 = new LcdResponseStruct();
    this.equip07 = new LcdResponseStruct();
    this.equip08 = new LcdResponseStruct();
    this.equip09 = new LcdResponseStruct();
    this.equip10 = new LcdResponseStruct();
    this.medi01 = new LcdResponseStruct();
    this.medi02 = new LcdResponseStruct();
    this.medi03 = new LcdResponseStruct();
    this.medi04 = new LcdResponseStruct();
    this.medi05 = new LcdResponseStruct();
    this.medi06 = new LcdResponseStruct();
    this.medi07 = new LcdResponseStruct();
    this.medi08 = new LcdResponseStruct();
    this.medi09 = new LcdResponseStruct();
    this.medi10 = new LcdResponseStruct();
    this.medi11 = new LcdResponseStruct();
    this.medi12 = new LcdResponseStruct();
    this.medi13 = new LcdResponseStruct();
    this.medi14 = new LcdResponseStruct();
    this.medi15 = new LcdResponseStruct();
    this.medi16 = new LcdResponseStruct();
    this.medi17 = new LcdResponseStruct();
    this.medi18 = new LcdResponseStruct();
    this.medi19 = new LcdResponseStruct();
    this.medi20 = new LcdResponseStruct();
    // add FNSI-バグ 通信サーバ #8009 高 start
    this.bloodCircuit = new LcdResponseStruct();
    this.adsorbent = new LcdResponseStruct();
    this.fluidReplacement = new LcdResponseStruct();
    // add FNSI-バグ 通信サーバ #8009 高 end
  }

  /**
   * 通信サーバ側で保持している値を用いる項目に項目コードをセットする。
   * 対象：除水速度制限、除水速度、補液速度限界値、補液量設定制限
   */
  private void setNoValueItemsCd() {
    /** 14:除水速度制限*/
    this.ufrLimit.setCd(DailyReportDispItemCd.UFR_LIMIT);
    /** 37:除水速度*/
    this.ufr.setCd(DailyReportDispItemCd.UFR);
    /** 41:補液速度限界値*/
    this.fluidReplacementRateLimit.setCd(DailyReportDispItemCd.FLUID_REPLACEMENT_RATE_LIMIT);
    /** 42:補液量設定値制限*/
    this.fluidReplacementVolumeSettingLimit.setCd(DailyReportDispItemCd.FLUID_REPLACEMENT_VOLUME_SETTING_LIMIT);

  }
}
