package jp.co.nikkiso.ntss.device_edge.response.comsvOrdMain;

import java.math.BigDecimal;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

import com.google.common.base.Strings;
import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.MstEquipment;
import jp.co.nikkiso.ntss.core.entity.MstMedicine;
import jp.co.nikkiso.ntss.core.entity.MstMedicineMix;
import jp.co.nikkiso.ntss.device_edge.constant.Constant.NextPatMemoItemCd;
import jp.co.nikkiso.ntss.device_edge.util.Utilities;
import jp.co.nikkiso.ntss.device_edge.util.CondInfo.CondInfo;
import jp.co.nikkiso.ntss.device_edge.util.MedicalCareInfo.MedicalCareInfo;
import jp.co.nikkiso.ntss.device_edge.util.PhysicalInfo.PhysicalInfo;
import lombok.Getter;
import tools.jackson.core.JacksonException;

/**
 *  通信サーバ用次患者情報のDTO.
 */
@Getter
public class NextPatMemoDTO {

  /** 抗凝固剤*/
  private LcdResponseStruct anticoagulant;
  /** (凝)持続注入量*/
  private LcdResponseStruct antInputCont;
  /** (凝)持続総量*/
  private LcdResponseStruct antInputContTotal;
  /** (凝)初回注入量*/
  private LcdResponseStruct antInputOneShot;
  /** (凝)合計注入量*/
  private LcdResponseStruct antInputTotal;
  /** 診療科名*/
  private LcdResponseStruct courseName;
  /** 透析液*/
  private LcdResponseStruct dialysisFluid;
  /** ダイアライザ*/
  private LcdResponseStruct dialyzer;
  /** 主治医*/
  private LcdResponseStruct doctorName;
  /** DW*/
  private LcdResponseStruct dw;
  /** 消耗品01 */
  private LcdResponseStruct equip01;
  /** 消耗品02 */
  private LcdResponseStruct equip02;
  /** 消耗品03 */
  private LcdResponseStruct equip03;
  /** 消耗品04 */
  private LcdResponseStruct equip04;
  /** 消耗品05 */
  private LcdResponseStruct equip05;
  /** 消耗品06 */
  private LcdResponseStruct equip06;
  /** 消耗品07 */
  private LcdResponseStruct equip07;
  /** 消耗品08 */
  private LcdResponseStruct equip08;
  /** 消耗品09 */
  private LcdResponseStruct equip09;
  /** 消耗品10 */
  private LcdResponseStruct equip10;
  /** 入外区分*/
  private LcdResponseStruct inOut;
  /** 薬剤01*/
  private LcdResponseStruct medi01;
  /** 薬剤02*/
  private LcdResponseStruct medi02;
  /** 薬剤03*/
  private LcdResponseStruct medi03;
  /** 薬剤04*/
  private LcdResponseStruct medi04;
  /** 薬剤05*/
  private LcdResponseStruct medi05;
  /** 薬剤06*/
  private LcdResponseStruct medi06;
  /** 薬剤07*/
  private LcdResponseStruct medi07;
  /** 薬剤08*/
  private LcdResponseStruct medi08;
  /** 薬剤09*/
  private LcdResponseStruct medi09;
  /** 薬剤10*/
  private LcdResponseStruct medi10;
  /** 薬剤11*/
  private LcdResponseStruct medi11;
  /** 薬剤12*/
  private LcdResponseStruct medi12;
  /** 薬剤13*/
  private LcdResponseStruct medi13;
  /** 薬剤14*/
  private LcdResponseStruct medi14;
  /** 薬剤15*/
  private LcdResponseStruct medi15;
  /** 薬剤16*/
  private LcdResponseStruct medi16;
  /** 薬剤17*/
  private LcdResponseStruct medi17;
  /** 薬剤18*/
  private LcdResponseStruct medi18;
  /** 薬剤19*/
  private LcdResponseStruct medi19;
  /** 薬剤20*/
  private LcdResponseStruct medi20;
  /** A針*/
  private LcdResponseStruct needle_A;
  /** V針*/
  private LcdResponseStruct needle_V;
  /** 患者ID*/
  private LcdResponseStruct patId;
  /** 表示用患者ID**/
  private LcdResponseStruct dispPatId;
  /** 患者名フリガナ*/
  private LcdResponseStruct patNameKana;
  /** 性別・年齢*/
  private LcdResponseStruct patSexAge;
  /** 治療モード*/
  private LcdResponseStruct treatMode;
  /** 治療法*/
  private LcdResponseStruct treatName;
  /** 透析開始時刻*/
  private LcdResponseStruct treatStartTime;
  /** 透析時間*/
  private LcdResponseStruct treatTime;
  /** VA*/
  private LcdResponseStruct va;
  /** 病棟名*/
  private LcdResponseStruct wardName;
  // add FNSI-バグ 通信サーバ #8009 高 start
  /** 目標体重*/
  private LcdResponseStruct targetWeight;
  /** 血流量*/
  private LcdResponseStruct bv;
  /** IP速度*/
  private LcdResponseStruct ipSpeed;
  /** IPワンショット量*/
  private LcdResponseStruct ipOneshot;
  /** IP自動切時間*/
  private LcdResponseStruct ipAutoPowerOffTime;
  /** 補液選択*/
  private LcdResponseStruct fluidReplacementSelect;
  /** 補液量*/
  private LcdResponseStruct fluidReplacementVolume;
  /** 補液速度*/
  private LcdResponseStruct fluidReplacementRate;
  /** 一次膜*/
  private LcdResponseStruct oneceMembrane;
  // add FNSI-バグ 通信サーバ #8009 高 end

  /**
   * コンストラクタ.
   * 各フィールドをNextPatMemoStructで初期化します.
   */
  public NextPatMemoDTO() {
    this.anticoagulant = new LcdResponseStruct();
    this.antInputCont = new LcdResponseStruct();
    this.antInputContTotal = new LcdResponseStruct();
    this.antInputOneShot = new LcdResponseStruct();
    this.antInputTotal = new LcdResponseStruct();
    this.courseName = new LcdResponseStruct();
    this.dialysisFluid = new LcdResponseStruct();
    this.dialyzer = new LcdResponseStruct();
    this.doctorName = new LcdResponseStruct();
    this.dw = new LcdResponseStruct();
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
    this.inOut = new LcdResponseStruct();
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
    this.needle_A = new LcdResponseStruct();
    this.needle_V = new LcdResponseStruct();
    this.patId = new LcdResponseStruct();
    this.dispPatId = new LcdResponseStruct();
    this.patNameKana = new LcdResponseStruct();
    this.patSexAge = new LcdResponseStruct();
    this.treatMode = new LcdResponseStruct();
    this.treatName = new LcdResponseStruct();
    this.treatStartTime = new LcdResponseStruct();
    this.treatTime = new LcdResponseStruct();
    this.va = new LcdResponseStruct();
    this.wardName = new LcdResponseStruct();
    // add FNSI-バグ 通信サーバ #8009 高 start
    this.targetWeight = new LcdResponseStruct();
    this.bv = new LcdResponseStruct();
    this.ipSpeed = new LcdResponseStruct();
    this.ipOneshot = new LcdResponseStruct();
    this.ipAutoPowerOffTime = new LcdResponseStruct();
    this.fluidReplacementSelect = new LcdResponseStruct();
    this.fluidReplacementVolume = new LcdResponseStruct();
    this.fluidReplacementRate = new LcdResponseStruct();
    this.oneceMembrane = new LcdResponseStruct();
    // add FNSI-バグ 通信サーバ #8009 高 end

  }

  /**
   * 入外区分(メモ項目名：状態)をセットします。
   * 引数の入外区分コードを該当する名称に変換して格納します。
   * 入外区分コード：0'：外来、'1'：入院、'2'：死亡、'3'：-(不在)
   * @param inOutCd 入外区分コード
   */
  public void setInOut(Integer inOutCd) {
    String inOutName = Utilities.inOutCdToName(inOutCd);
    this.inOut.setCd(NextPatMemoItemCd.inOutClass);
    this.inOut.setValue(String.valueOf(inOutCd));
    this.inOut.setName(inOutName);
  }

  /**
   * 治療モードをセットします。
   * @param treatModeCd
   */
  public void setTreatMode(int treatModeCd) {
    // 治療モードコードから治療モード名称を取得
    String treatModeName = Utilities.treatCdToName(treatModeCd);
    // クラスフィールドにセット
    this.treatMode.setCd(NextPatMemoItemCd.treatMode);
    this.treatMode.setValue(String.valueOf(treatModeCd));
    this.treatMode.setName(treatModeName);
  }

  /**
   * 治療項目名をセットします。
   * @param treatName
   */
  public void setTreatName(String treatName) {
    this.treatName.setCd(NextPatMemoItemCd.treatName);
    this.treatName.setName(treatName);
  }

  /**
   * 性別・年齢をセットします。
   * 引数の文字列をそのまま格納します。
   * @param string 性別・年齢文字列
   */
  public void setPatSexAge(String string) {
    this.patSexAge.setCd(NextPatMemoItemCd.patSexAge);
    this.patSexAge.setValue(string);
  }

  /**
   * 性別・年齢をセットします。
   * 引数の性別コードを該当する名称に変換、生年月日から年齢を算出し格納します。
   * 性別コード：0：不明、1：男性、2：女性
   * @param patSexCd 性別コード
   * @param patBirthDay 生年月日文字列(YYYYMMDD)
   */
  public void setPatSexAge(int patSexCd, String patBirthDay) {
    // 性別
    String sex = Utilities.sexCdToName(patSexCd);

    // 年齢
    int age = Utilities.calcAge(patBirthDay, new Date());
    /// 文字列化
    String age_str = Integer.toString(age);

    // セットする文字列
    String str = sex + " (" + age_str + ")";

    this.patSexAge.setCd(NextPatMemoItemCd.patSexAge);
    this.patSexAge.setValue(str);
  }

  /**
   * 開始時刻をセットします。
   * @param treatStartTime
   */
  public void setTreatSartTime(String treatStartTime) {
    this.treatStartTime.setCd(NextPatMemoItemCd.treatStartTime);
    this.treatStartTime.setValue(treatStartTime);
  }

  /**
   * 患者IDをセットします。
   * @param patId
   */
  public void setPatId(Long patId) {
    this.patId.setCd(NextPatMemoItemCd.patId);
    this.patId.setValue(patId.toString());
  }

  /**
   * 表示用患者IDをセット
   * @param dispPatId
   */
  public void setDispPatId( String dispPatId ) {
    this.dispPatId.setCd(NextPatMemoItemCd.patId);
    this.dispPatId.setValue(dispPatId);
  }

  /**
   * 患者フリガナをセットします。
   * @param kanaName
   */
  public void setPatNameKana(String kanaName) {
    this.patNameKana.setCd(NextPatMemoItemCd.patNameKana);
    this.patNameKana.setValue(kanaName);
  }

  /**
   * 担当医名をセットします。
   * @param doctorName
   */
  public void setDoctorName(String doctorName) {
    this.doctorName.setCd(NextPatMemoItemCd.doctorName);
    this.doctorName.setName(doctorName);
  }

  /**
   * 共通診療情報から病棟名と診療科名をセットします。
   */
  public void setMediCares(MedicalCareInfo medicalCareInfo) {
    // 病棟名をセット
    this.wardName.setCd(NextPatMemoItemCd.wardName);
    this.wardName.setValue(String.valueOf(medicalCareInfo.getWardCd()));
    this.wardName.setName(medicalCareInfo.getWardName());

    // 診療科名をセット
    this.courseName.setCd(NextPatMemoItemCd.courseName);
    this.courseName.setValue(String.valueOf(medicalCareInfo.getMainCourseCd()));
    this.courseName.setName(medicalCareInfo.getMainCourseName());

  }

  /**
   * 医療材料情報のJSONからコードのリストを取得する
   * @param jsonString JSON文字列
   * @return コードのリスト
   */
  //mod #10412 次患者更新関連全体見直し対応 朴 start
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
  public List<Integer> extractCodeList(String jsonString, Integer equipType) throws JacksonException {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
  //mod #10412 次患者更新関連全体見直し対応 朴 end
    List<Integer> codeList = new ArrayList<Integer>();

    ObjectMapper mapper = new ObjectMapper();
    try {
      // 医療材料情報のJSON文字列は配列
      JsonNode jsonNodeArray = mapper.readTree(jsonString);
      for (int lop = 0; lop < jsonNodeArray.size(); lop++) {
        JsonNode jsonNode = jsonNodeArray.get(lop);
        // コードのノード
        JsonNode code_node = jsonNode.get("cd");
        //mod #10412 次患者更新関連全体見直し対応 朴 start
        JsonNode equipTypeNode = jsonNode.get("equip_type");
        if (equipTypeNode != null && equipType.toString().equals(equipTypeNode.asText())) {
        // コード
        int code = code_node.asInt();
        codeList.add(code);
      }
        //mod #10412 次患者更新関連全体見直し対応 朴 end
      }
    } catch (tools.jackson.core.JacksonException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//        e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang start
      throw e;
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang end
    }

    return codeList;
  }

  /**
   * 薬剤情報のJSONからコードのリストを取得する
   * @param jsonString JSON文字列
   * @return コードのリスト
   */
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
  public List<List<Integer>> extractMediCodeList(String jsonString) throws JacksonException {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    List<Integer> codeList1 = new ArrayList<Integer>();
    List<Integer> codeList2 = new ArrayList<Integer>();
    List<List<Integer>> ret = new ArrayList<List<Integer>>();

    ObjectMapper mapper = new ObjectMapper();
    try {
      // 薬剤情報のJSON文字列は配列
      JsonNode jsonNodeArray = mapper.readTree(jsonString);
      for (int lop = 0; lop < jsonNodeArray.size(); lop++) {
        JsonNode jsonNode = jsonNodeArray.get(lop);
        // コードのノード
        JsonNode code_node = jsonNode.get("cd");
        // コード
        int code = code_node.asInt();
        // 薬剤区分
        String type = "1";
        if( jsonNode.has("medicine_type") ) {
          JsonNode type_node = jsonNode.get("medicine_type");
          // コード
          type = type_node.asText();
        }
        if( type.equals("2")) {
          codeList2.add(code);
        } else {
          codeList1.add(code);
        }
      }
    } catch (tools.jackson.core.JacksonException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//        e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang start
      throw e;
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang end
    }
    ret.add(codeList1);
    ret.add(codeList2);

    return ret;
  }

  /**
   * 医療材料情報をJSONからフィールドへセットする
   * @param indEquipInfo 医療材料情報のJSON文字列
   */
  //mod #10412 次患者更新関連全体見直し対応 朴 start
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
  public void setEquips(String indEquipInfo, List<MstEquipment> mstEquipmentList, List<MstDialyzer> mstDialyzerList) throws JacksonException {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    //mod #10412 次患者更新関連全体見直し対応 朴 end
    // ord_mainのind_equip_infoのJSON配列を展開
    // 最大10件の医療材料情報を取り出し、equip01~10へ格納する。
    // ind_equip_infoの医療材料名や単位は条件送信後にセットされるため、条件送信前である
    // 次患者の場合はマスタから参照する必要がある。
    // ind_equip_infoから：数量(amount)
    // マスタから：医療材料名(equipment_name)、単位(unit)
    // 10件未満の場合残りのフィールドには空文字列をセットする。

    if (indEquipInfo != null && indEquipInfo.length() != 0) {

      //add #10412 次患者更新関連全体見直し対応 朴 start
      Map<Integer, MstEquipment> mstEquipmentListMap = mstEquipmentList.stream().collect(Collectors.toMap(o -> ((MstEquipment)o).getEquipmentCd(), o -> (MstEquipment)o));
      Map<Integer, MstDialyzer> mstDialyzerListMap = mstDialyzerList.stream().collect(Collectors.toMap(o -> ((MstDialyzer)o).getDialyzerCd(), o -> (MstDialyzer)o));
      //add #10412 次患者更新関連全体見直し対応 朴 end

      List<LcdResponseStruct> memoStructList = new ArrayList<LcdResponseStruct>();
      // JSONのパースに失敗してもフィールドに空文字列が入るよう、あらかじめ空文字列で初期化する
      for (int initlop = 0; initlop < 10; initlop++) {
        memoStructList.add(new LcdResponseStruct());
      }

      // JSON文字列からの展開開始
      ObjectMapper mapper = new ObjectMapper();
      try {
        JsonNode jsonNode = mapper.readTree(indEquipInfo);
        // 10件固定でループ
        int readCnt = 0;
        for (int readlop = 0; readlop < 10; readlop++) {
          if (readCnt < jsonNode.size()) {
            JsonNode equip = jsonNode.get(readlop);
            // コード
            JsonNode equipCd_node = equip.get("cd");
            int equipCd = equipCd_node.asInt();

            //add #10412 次患者更新関連全体見直し対応 朴 start
            // 医療材料区分
            JsonNode equipType_node = equip.get("equip_type");
            String equipType = equipType_node.isNull() ? "" : equipType_node.asText();
            //add #10412 次患者更新関連全体見直し対応 朴 end

            // 数量
            JsonNode equipValue_node = equip.get("amount");
            String equipValue = equipValue_node.isNull() ? null :  equipValue_node.asText();

            // #9290 2023.10.16 mod Nameが存在する場合は新たに取得しない TDC片口 start
            /*
            String equipName = "";
            String equipUnit = "";
            // マスタの情報と突合せ
            for (int mstLop = 0; mstLop < mstEquipmentList.size(); mstLop++) {
              MstEquipment mstEquipment = mstEquipmentList.get(mstLop);
              if (Objects.equals(mstEquipment.getEquipmentCd(), equipCd)) {
                equipName = mstEquipment.getEquipmentName();
                equipUnit = mstEquipment.getUnit();
              }
            }
             */
            // 名称
            JsonNode equipName_node = equip.get("name");
            /* mod by shiyw 2024-02-08 [#10196]ord_mainのデータ定義の修正 --start */
            //String equipName = equipName_node.isNull() ? null :  equipName_node.asText();
            String equipName = null;
            if(equipName_node != null){
              equipName = equipName_node.isNull() ? null :  equipName_node.asText();
            }
            /* mod by shiyw 2024-02-08 [#10196]ord_mainのデータ定義の修正 --end */
            // 単位
            JsonNode equipUnit_node = equip.get("unit");
            /* mod by shiyw 2024-02-08 [#10196]ord_mainのデータ定義の修正 --start */
            //String equipUnit = equipUnit_node.isNull() ? null :  equipUnit_node.asText();
            String equipUnit = null;
            if(equipUnit_node != null){
              equipUnit = equipUnit_node.isNull() ? null :  equipUnit_node.asText();
            }
            /* mod by shiyw 2024-02-08 [#10196]ord_mainのデータ定義の修正 --end */
            if (equipName == null) {
              //mod #10412 次患者更新関連全体見直し対応 朴 start
              // マスタの情報と突合せ
//              for (MstEquipment mstEquipment : mstEquipmentList) {
//                if (Objects.equals(mstEquipment.getEquipmentCd(), equipCd)) {
//                  equipName = mstEquipment.getEquipmentName();
//                  equipUnit = mstEquipment.getUnit();
//                }
//              }
              if ("0".equals(equipType)) {
                MstEquipment mstEquipment = mstEquipmentListMap.get(equipCd);
                if(mstEquipment != null){
                  equipName = mstEquipment.getEquipmentName();
                  equipUnit = mstEquipment.getUnit();
                }
              } else if ("1".equals(equipType)) {
                MstDialyzer mstDialyzer = mstDialyzerListMap.get(equipCd);
                if(mstDialyzer != null){
                  equipName = mstDialyzer.getModelNumber();
                  equipUnit = "本";
              }
              }
              //mod #10412 次患者更新関連全体見直し対応 朴 end
            }
            // #9290 2023.10.16 mod Nameが存在する場合は新たに取得しない TDC片口 end

            // 構造体に格納
            LcdResponseStruct memoStruct = new LcdResponseStruct();
            memoStruct.setName(equipName);
            memoStruct.setUnit(equipUnit);
            memoStruct.setValue(equipValue);
            // リストに格納
            memoStructList.set(readlop, memoStruct);
          }
          readCnt++;
        }
      } catch (tools.jackson.core.JacksonException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//        e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang start
        throw e;
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang end
      }

      // 自クラスの消耗品フィールドに値をセット
      this.equip01 = memoStructList.get(0);
      this.equip01.setCd(NextPatMemoItemCd.equip01);
      this.equip02 = memoStructList.get(1);
      this.equip02.setCd(NextPatMemoItemCd.equip02);
      this.equip03 = memoStructList.get(2);
      this.equip03.setCd(NextPatMemoItemCd.equip03);
      this.equip04 = memoStructList.get(3);
      this.equip04.setCd(NextPatMemoItemCd.equip04);
      this.equip05 = memoStructList.get(4);
      this.equip05.setCd(NextPatMemoItemCd.equip05);
      this.equip06 = memoStructList.get(5);
      this.equip06.setCd(NextPatMemoItemCd.equip06);
      this.equip07 = memoStructList.get(6);
      this.equip07.setCd(NextPatMemoItemCd.equip07);
      this.equip08 = memoStructList.get(7);
      this.equip08.setCd(NextPatMemoItemCd.equip08);
      this.equip09 = memoStructList.get(8);
      this.equip09.setCd(NextPatMemoItemCd.equip09);
      this.equip10 = memoStructList.get(9);
      this.equip10.setCd(NextPatMemoItemCd.equip10);

    }
  }

  /**
   * 薬剤名称をJSONからフィールドへセットする
   * @param indMediInfo 薬剤情報のJSON文字列
   */
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
  public void setMedis(String indMediInfo, List<MstMedicine> mstMedicineList, List<MstMedicineMix> mstMedicineMixList) throws JacksonException {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    // ord_mainのind_medi_infoのJSON配列を展開
    // 最大20件の薬剤情報を取り出し、medi01~20へ格納する。
    // ind_medi_infoの薬剤名や単位は条件送信後にセットされるため、条件送信前である
    // 次患者の場合はマスタから参照する必要がある。
    // ind_medi_infoから：数量(amount)
    // マスタから：薬剤名(medicine_name)、単位(unit)
    // 20件未満の場合残りのフィールドには空文字列をセットする。

    if (indMediInfo != null && indMediInfo.length() != 0) {

      List<LcdResponseStruct> memoStructList = new ArrayList<LcdResponseStruct>();
      // JSONのパースに失敗してもフィールドに空文字列が入るよう、あらかじめ空文字列で初期化する
      for (int initlop = 0; initlop < 20; initlop++) {
        memoStructList.add(new LcdResponseStruct());
      }

      // JSON文字列からの展開開始
      ObjectMapper mapper = new ObjectMapper();
      try {
        JsonNode jsonNode = mapper.readTree(indMediInfo);
        // 20件固定でループ
        int readCnt = 0;
        for (int readlop = 0; readlop < 20; readlop++) {
          if (readCnt < jsonNode.size()) {
            JsonNode medi = jsonNode.get(readlop);
            // コード
            JsonNode mediCd_node = medi.get("cd");
            int mediCd = mediCd_node.asInt();
            // 数量
            JsonNode mediValue_node = medi.get("amount");
            String mediValue = mediValue_node.isNull() ? null : mediValue_node.asText();
            // 薬剤区分
            JsonNode mediType_node = medi.get("medicine_type");
            String mediType = mediType_node.isNull() ? "" : mediType_node.asText();

            // #9290 2023.10.16 mod Nameが存在する場合は新たに取得しない TDC片口 start
            /*
            String mediName = "";
            String mediUnit = "";
            Integer mediDecimalPoint = null;
            // マスタの情報と突合せ
            if ( mediType.equals("2") ) {
              // 調整薬剤
              for (int mstLop = 0; mstLop < mstMedicineMixList.size(); mstLop++) {
                MstMedicineMix mstMediMix = mstMedicineMixList.get(mstLop);
                if (Objects.equals(mstMediMix.getMedicineMixCd(), mediCd)) {
                  mediName = mstMediMix.getMedicineMixName();
                  mediUnit = mstMediMix.getUnit();
                  mediDecimalPoint = mstMediMix.getUnitDecimalPoint();
                  break;
                }
              }
            } else {
              // 薬剤
              for (int mstLop = 0; mstLop < mstMedicineList.size(); mstLop++) {
                MstMedicine mstMedi = mstMedicineList.get(mstLop);
                if (Objects.equals(mstMedi.getMedicineCd(), mediCd)) {
                  mediName = mstMedi.getMedicineName();
                  mediUnit = mstMedi.getUnit();
                  mediDecimalPoint = mstMedi.getUnitDecimalPoint();
                  break;
                }
              }
            }
             */
            JsonNode mediName_node = medi.get("name");
            /* mod by shiyw 2024-02-08 [#10196]ord_mainのデータ定義の修正 --start */
            //String mediName = mediName_node.isNull() ? null : mediName_node.asText();
            String mediName = null;
            if(mediName_node != null){
              mediName = mediName_node.isNull() ? null : mediName_node.asText();
            }
            //JsonNode mediUnit_node = medi.get("name");
            JsonNode mediUnit_node = medi.get("unit");
            //String mediUnit = mediUnit_node.isNull() ? null : mediUnit_node.asText();
            String mediUnit = null;
            if(mediUnit_node != null){
              mediUnit = mediUnit_node.isNull() ? null : mediUnit_node.asText();
            }
            /* mod by shiyw 2024-02-08 [#10196]ord_mainのデータ定義の修正 --end */
            Integer mediDecimalPoint = null;

            // マスタの情報と突合せ
            if (mediType.equals("2")) {
              // 調整薬剤
              for (MstMedicineMix mstMediMix : mstMedicineMixList) {
                if (Objects.equals(mstMediMix.getMedicineMixCd(), mediCd)) {
                  if (mediName == null) {
                    mediName = mstMediMix.getMedicineMixName();
                    mediUnit = mstMediMix.getUnit();
                  }
                  mediDecimalPoint = mstMediMix.getUnitDecimalPoint();
                  break;
                }
              }
            } else {
              // 薬剤
              for (MstMedicine mstMedi : mstMedicineList) {
                if (Objects.equals(mstMedi.getMedicineCd(), mediCd)) {
                  if (mediName == null) {
                    mediName = mstMedi.getMedicineName();
                    mediUnit = mstMedi.getUnit();
                  }
                  mediDecimalPoint = mstMedi.getUnitDecimalPoint();
                  break;
                }
              }
            }
            // #9290 2023.10.16 mod Nameが存在する場合は新たに取得しない TDC片口 end

            // 構造体に格納
            LcdResponseStruct memoStruct = new LcdResponseStruct();
            memoStruct.setName(mediName);
            memoStruct.setUnit(mediUnit);
            // 値を指定書式で整形
            memoStruct.setValue(Utilities.getFormattedNumber(mediValue, mediDecimalPoint));
            // リストに格納
            memoStructList.set(readlop, memoStruct);
          }
          readCnt++;
        }
      } catch (tools.jackson.core.JacksonException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//        e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang start
        throw e;
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang end
      }

      // 自クラスの薬剤フィールドに値をセット
      this.medi01 = memoStructList.get(0);
      this.medi01.setCd(NextPatMemoItemCd.medi01);
      this.medi02 = memoStructList.get(1);
      this.medi02.setCd(NextPatMemoItemCd.medi02);
      this.medi03 = memoStructList.get(2);
      this.medi03.setCd(NextPatMemoItemCd.medi03);
      this.medi04 = memoStructList.get(3);
      this.medi04.setCd(NextPatMemoItemCd.medi04);
      this.medi05 = memoStructList.get(4);
      this.medi05.setCd(NextPatMemoItemCd.medi05);
      this.medi06 = memoStructList.get(5);
      this.medi06.setCd(NextPatMemoItemCd.medi06);
      this.medi07 = memoStructList.get(6);
      this.medi07.setCd(NextPatMemoItemCd.medi07);
      this.medi08 = memoStructList.get(7);
      this.medi08.setCd(NextPatMemoItemCd.medi08);
      this.medi09 = memoStructList.get(8);
      this.medi09.setCd(NextPatMemoItemCd.medi09);
      this.medi10 = memoStructList.get(9);
      this.medi10.setCd(NextPatMemoItemCd.medi10);
      this.medi11 = memoStructList.get(10);
      this.medi11.setCd(NextPatMemoItemCd.medi11);
      this.medi12 = memoStructList.get(11);
      this.medi12.setCd(NextPatMemoItemCd.medi12);
      this.medi13 = memoStructList.get(12);
      this.medi13.setCd(NextPatMemoItemCd.medi13);
      this.medi14 = memoStructList.get(13);
      this.medi14.setCd(NextPatMemoItemCd.medi14);
      this.medi15 = memoStructList.get(14);
      this.medi15.setCd(NextPatMemoItemCd.medi15);
      this.medi16 = memoStructList.get(15);
      this.medi16.setCd(NextPatMemoItemCd.medi16);
      this.medi17 = memoStructList.get(16);
      this.medi17.setCd(NextPatMemoItemCd.medi17);
      this.medi18 = memoStructList.get(17);
      this.medi18.setCd(NextPatMemoItemCd.medi18);
      this.medi19 = memoStructList.get(18);
      this.medi19.setCd(NextPatMemoItemCd.medi19);
      this.medi20 = memoStructList.get(19);
      this.medi20.setCd(NextPatMemoItemCd.medi20);

    }
  }

  /**
   * 治療条件をJSONからフィールドへセットする
   * @param condInfo 治療条件のJSON文字列
   */
  public void setConds(CondInfo condInfo) {
    // 透析時間
    this.treatTime.setCd(NextPatMemoItemCd.treatTime);
    this.treatTime.setName(condInfo.getTreatTime().getName());
    String time = condInfo.getTreatTime().getValue();
    Long times = Utilities.isNumber(time) ? Long.parseLong(time): null;
    this.treatTime.setValue(Utilities.AccumulatedMinutesToHHMM(times));
    this.treatTime.setUnit(condInfo.getTreatTime().getUnit());

    // VA
    this.va.setCd(NextPatMemoItemCd.va);
    this.va.setName(condInfo.getVa().getName());
    this.va.setValue(condInfo.getVa().getValue());
    this.va.setUnit(condInfo.getVa().getUnit());

    // ダイアライザー・吸着カラム・1次膜・2次膜
    this.dialyzer.setCd(NextPatMemoItemCd.dialyzer);
    //mod redmine bug#5525 劉 start
    //this.dialyzer.setName(condInfo.getDialyzer().getName());
    String nameTmp = condInfo.getDialyzer().getName();
    String name = nameTmp;
    nameTmp = condInfo.getAdsorbent().getName();
    if (!Strings.isNullOrEmpty(nameTmp)) {
      if (!Strings.isNullOrEmpty(name)) {
        name = name + "・";
      }
      name = name + nameTmp;
    }
    nameTmp = condInfo.getOneceMembrane().getName();
    if (!Strings.isNullOrEmpty(nameTmp)) {
      if (!Strings.isNullOrEmpty(name)) {
        name = name + "・";
      }
      name = name + nameTmp;
    }
    nameTmp = condInfo.getSecondaryMembrane().getName();
    if (!Strings.isNullOrEmpty(nameTmp)) {
      if (!Strings.isNullOrEmpty(name)) {
        name = name + "・";
      }
      name = name + nameTmp;
    }
    this.dialyzer.setName(name);
    //mod redmine bug#5525 劉 end
    this.dialyzer.setValue(condInfo.getDialyzer().getValue());
    this.dialyzer.setUnit(condInfo.getDialyzer().getUnit());

    // 穿刺針(A針 or SN針(※SN使用ありの場合))
    this.needle_A.setCd(NextPatMemoItemCd.needle_A);
    this.needle_A.setName(condInfo.getNeedleA().getName());
    this.needle_A.setValue(condInfo.getNeedleA().getValue());
    this.needle_A.setUnit(condInfo.getNeedleA().getUnit());

    // 穿刺針(V針)
    this.needle_V.setCd(NextPatMemoItemCd.needle_V);
    this.needle_V.setName(condInfo.getNeedleV().getName());
    this.needle_V.setValue(condInfo.getNeedleV().getValue());
    this.needle_V.setUnit(condInfo.getNeedleV().getUnit());

    // 透析液
    this.dialysisFluid.setCd(NextPatMemoItemCd.dialysisFluid);
    this.dialysisFluid.setName(condInfo.getDialysisFluid().getName());
    this.dialysisFluid.setValue(condInfo.getDialysisFluid().getValue());
    this.dialysisFluid.setUnit(condInfo.getDialysisFluid().getUnit());

    // 抗凝固剤
    this.anticoagulant.setCd(NextPatMemoItemCd.anticoagulant);
    this.anticoagulant.setName(condInfo.getAnticoagulant().getName());
    this.anticoagulant.setValue(condInfo.getAnticoagulant().getValue());
    this.anticoagulant.setUnit(condInfo.getAnticoagulant().getUnit());

    // 抗凝固剤初回注入量
    this.antInputOneShot.setCd(NextPatMemoItemCd.antInputOneShot);
    this.antInputOneShot.setName(condInfo.getAntInputOneshot().getName());
    this.antInputOneShot.setValue(Utilities.getFormattedNumber(condInfo.getAntInputOneshot().getValue(), condInfo.getAnticoagulant().getDecimalPoint()));
    this.antInputOneShot.setUnit(condInfo.getAnticoagulant().getUnit());

    // 抗凝固剤持続注入量
    this.antInputCont.setCd(NextPatMemoItemCd.antInputCont);
    this.antInputCont.setName(condInfo.getAntInputCont().getName());
    this.antInputCont.setValue(Utilities.getFormattedNumber(condInfo.getAntInputCont().getValue(), condInfo.getAnticoagulant().getDecimalPoint()));
    this.antInputCont.setUnit(condInfo.getAnticoagulant().getUnit() + "/h");

    // 抗凝固剤持続総量
    this.antInputContTotal.setCd(NextPatMemoItemCd.antInputContTotal);
    this.antInputContTotal.setName(condInfo.getAntInputContTotal().getName());
    this.antInputContTotal.setValue(Utilities.getFormattedNumber(condInfo.getAntInputContTotal().getValue(), condInfo.getAnticoagulant().getDecimalPoint()));
    this.antInputContTotal.setUnit(condInfo.getAnticoagulant().getUnit());

    // 抗凝固剤合計注入量
    this.antInputTotal.setCd(NextPatMemoItemCd.antInputTotal);
    this.antInputTotal.setName("");
    try {
      //mod 11340 仮想端末の次患者情報の抗凝固剤総量の数量単位が表示しない start
//      BigDecimal antOneshot = new BigDecimal(this.antInputOneShot.getValue());
//      BigDecimal antContTotal = new BigDecimal(this.antInputContTotal.getValue());
      BigDecimal antOneshot = new BigDecimal(condInfo.getAntInputOneshot().getValue());
      BigDecimal antContTotal = new BigDecimal(condInfo.getAntInputContTotal().getValue());
      //mod 11340 仮想端末の次患者情報の抗凝固剤総量の数量単位が表示しない end
      antOneshot = antOneshot == null ? BigDecimal.valueOf(0) : antOneshot;
      antContTotal = antContTotal == null ? BigDecimal.valueOf(0) : antContTotal;
      BigDecimal inputTotal = antOneshot.add(antContTotal);
      this.antInputTotal.setValue(Utilities.getFormattedNumber(inputTotal.toString(), condInfo.getAnticoagulant().getDecimalPoint()));
      this.antInputTotal.setUnit(condInfo.getAnticoagulant().getUnit());
    } catch( Exception e) {

    }
    // add FNSI-バグ 通信サーバ #8009 高 start
    // 目標体重
    this.targetWeight.setCd(NextPatMemoItemCd.targetWeight);
    this.targetWeight.setName("目標体重");
    if("-1".equals(condInfo.getTargetWeight().getValue()) || Strings.isNullOrEmpty(condInfo.getTargetWeight().getValue()))
      this.targetWeight.setValue(this.dw.getValue());
    else
      this.targetWeight.setValue(condInfo.getTargetWeight().getValue());
    this.targetWeight.setUnit("kg");

    // 血流量
    this.bv.setCd(NextPatMemoItemCd.bv);
    this.bv.setName("血流量");
    this.bv.setValue(condInfo.getBv().getValue());
    this.bv.setUnit("mL/min");

    // IP速度
    this.ipSpeed.setCd(NextPatMemoItemCd.ipSpeed);
    this.ipSpeed.setName("IP速度");
    this.ipSpeed.setValue(condInfo.getIpSpeed().getValue());
    this.ipSpeed.setUnit("mL/h");

    // IPワンショット量
    this.ipOneshot.setCd(NextPatMemoItemCd.ipOneshot);
    this.ipOneshot.setName("IPワンショット量");
    this.ipOneshot.setValue(condInfo.getIpOneshot().getValue());
    this.ipOneshot.setUnit("mL");

    // #9147 2024.01.17 chg 次患者整形 IP自動切時間データ内にIP電源自動切りのON/OFFデータを含ませる TDC山崎 start
//    // IP自動切時間
//    this.ipAutoPowerOffTime.setCd(NextPatMemoItemCd.ipAutoPowerOffTime);
//    this.ipAutoPowerOffTime.setName("IP自動切時間");
//    this.ipAutoPowerOffTime.setValue(condInfo.getIpAutoPowerOffTime().getValue());
//    this.ipAutoPowerOffTime.setUnit("分前");

    // IP自動切時間＋IP電源自動切りのON/OFF
    this.ipAutoPowerOffTime.setCd(NextPatMemoItemCd.ipAutoPowerOffTime);
    this.ipAutoPowerOffTime.setName(condInfo.getIpAutoPowerOff().getValue()); // 特別に「IP電源自動切りのON/OFF」データをココに格納
    this.ipAutoPowerOffTime.setValue(condInfo.getIpAutoPowerOffTime().getValue());
    this.ipAutoPowerOffTime.setUnit("分前");
    // #9147 2024.01.17 chg 次患者整形 IP自動切時間データ内にIP電源自動切りのON/OFFデータを含ませる TDC山崎 end

    // 補液選択
    this.fluidReplacementSelect.setCd(NextPatMemoItemCd.fluidReplacementSelect);
    this.fluidReplacementSelect.setName("補液選択");
    this.fluidReplacementSelect.setValue(condInfo.getFluidReplacementSelect().getValue());

    // 補液量
    this.fluidReplacementVolume.setCd(NextPatMemoItemCd.fluidReplacementVolume);
    this.fluidReplacementVolume.setName("補液量");
    this.fluidReplacementVolume.setValue(condInfo.getFluidReplacementVolume().getValue());
    this.fluidReplacementVolume.setUnit("L");

    // 補液速度
    this.fluidReplacementRate.setCd(NextPatMemoItemCd.fluidReplacementRate);
    this.fluidReplacementRate.setName("補液速度");
    this.fluidReplacementRate.setValue(condInfo.getFluidReplacementRate().getValue());
    this.fluidReplacementRate.setUnit("L/h");

    // 一次膜
    this.oneceMembrane.setCd(NextPatMemoItemCd.oneceMembrane);
    this.oneceMembrane.setName(condInfo.getOneceMembrane().getName());
    this.oneceMembrane.setValue(condInfo.getOneceMembrane().getValue());
    // add FNSI-バグ 通信サーバ #8009 高 end
  }

  /**
   * JSON文字列から指定したキーの値を取得する.
   * 【注意】与えるJSON文字列が1次でない場合は期待する結果が得られない.
   * @param jsonString 1次のJSON文字列
   * @param key 値を取得したいキー名
   * @return キーに対応する値(文字列)
   * @throws IOException
   */
  public String getJsonValueByKeyName(String jsonString, String key) throws IOException {
    ObjectMapper mapper = new ObjectMapper();
    JsonNode jsonNode = mapper.readTree(jsonString);
    JsonNode value_node = jsonNode.get(key);
    String value = value_node.asText();

    return value;
  }

  /**
   * 担当スタッフ情報のJSONから主治医のスタッフコードを取得する
   * @param jsonString 担当スタッフ情報JSON文字列
   * @return 主治医のスタッフコード
   * @throws IOException
   */
  public Long getStaffCdOfMainDoctor(String jsonString) throws IOException {
    ObjectMapper mapper = new ObjectMapper();
    JsonNode jsonNode = mapper.readTree(jsonString);
    Long staffCd = 0L;

    for (int lop = 0; lop < jsonNode.size(); lop++) {
      JsonNode child = jsonNode.get(lop);
      int isMain = child.get("is_main").asInt();

      if (isMain == 1) {
        staffCd = child.get("staff_cd").asLong();
        return staffCd;
      }
    }

    return staffCd;
  }

  // #9147 2023.12.22 chg メモリストを20件にし、次患者情報2段組表示ON/OFFで[20件有効/10件有効で後半10件null]を切り替え TDC山崎 start
//  public int[] getDispOrderList(String jsonString) throws IOException {
//    int[] intArray = new int[10];
//    ObjectMapper mapper = new ObjectMapper();
//    JsonNode jsonNode = mapper.readTree(jsonString);
//    JsonNode nPatItem_node = jsonNode.get("npat_item");
//
//    for (int lop = 0; lop < nPatItem_node.size() && lop < intArray.length; lop++) {
//      JsonNode child = nPatItem_node.get(lop);
//      int no = child.get("no").asInt() - 1;
//      int code = child.get("code").asInt();
//
//      intArray[no] = code;
//
//    }
//
//    return intArray;
//  }

  public int[] getDispOrderList(String jsonString, int memoCount) throws IOException {
    var intArray = new int[memoCount];

    ObjectMapper mapper = new ObjectMapper();
    JsonNode jsonNode = mapper.readTree(jsonString);
    JsonNode nPatItem_node = jsonNode.get("npat_item");

    for (int i = 0; i < nPatItem_node.size() && i < memoCount; i++) {
      JsonNode child = nPatItem_node.get(i);
      int no = child.get("no").asInt() - 1;
      int code = child.get("code").asInt();

      intArray[no] = code;
    }

    return intArray;
  }
  // #9147 2023.12.22 chg メモリストを20件にし、次患者情報2段組表示ON/OFFで[20件有効/10件有効で後半10件null]を切り替え TDC山崎 end

  /**
   * 「DW」を取得します。
   * @return DWの文字列。患者基本情報がnullの場合空文字列を返す。
   */
  public String getDW(String physicalInfoStr, String treatDateYYYYMMDD) {
    String rtn = "";
    try {
      if (physicalInfoStr != null && physicalInfoStr.length() != 0) {
        // 患者基本情報から身体情報を取得する
        PhysicalInfo physicalInfo = new PhysicalInfo(physicalInfoStr, treatDateYYYYMMDD);
        // 身体情報からDWを取得し戻り値にセット
        rtn = physicalInfo.getDw();
      }
    } catch (Exception e) {
      rtn = "";
    }
    return rtn;
  }

  /**
   * 患者情報のJSONからDWをフィールドへセットする
   * @param physicalInfo
   */
  // #9147 2024.06.26 chg 次患者整形 指示DW→無ければpat_uniqueの透析日以前の最新DW TDC山崎 start
//  public void setPhysicals(String physicalInfo) {
//    // DW
//    String dw = getDW(physicalInfo);
//    this.dw.setCd(NextPatMemoItemCd.dw);
//    this.dw.setValue(Utilities.getFormattedNumber(dw, 2));
//    this.dw.setUnit("kg");
//  }
  public void setPhysicals(String physicalInfo, BigDecimal indDw, String treatDateYYYYMMDD) {
    // DW
    String strDw;
    if (indDw != null) {
      strDw = indDw.toPlainString();
    } else {
      // pat_unique.physical_infoの全レコード の中の 透析日から見た最新DWデータ
      strDw = getDW(physicalInfo, treatDateYYYYMMDD);
    }

    this.dw.setCd(NextPatMemoItemCd.dw);
    this.dw.setValue(Utilities.getFormattedNumber(strDw, 2));
    this.dw.setUnit("kg");
  }
  // #9147 2024.06.26 chg 次患者整形 指示DW→無ければpat_uniqueの透析日以前の最新DW TDC山崎 end

  /**
   * 項目コードに対応した値を返す
   * @param itemCd 次患者情報転送メモ項目コード
   * @return
   */
  public LcdResponseStruct getMemoItemByCd(int itemCd) {
    //    String rtn = "";
    LcdResponseStruct rtn = new LcdResponseStruct();

    switch (itemCd) {
    case NextPatMemoItemCd.patId:
      //rtn = this.patId;
      rtn = this.dispPatId;
      break;
    case NextPatMemoItemCd.patNameKana:
      rtn = this.patNameKana;
      break;
    case NextPatMemoItemCd.patSexAge:
      rtn = this.patSexAge;
      break;
    case NextPatMemoItemCd.inOutClass:
      rtn = this.inOut;
      break;
    case NextPatMemoItemCd.wardName:
      rtn = this.wardName;
      break;
    case NextPatMemoItemCd.courseName:
      rtn = this.courseName;
      break;
    case NextPatMemoItemCd.doctorName:
      rtn = this.doctorName;
      break;
    case NextPatMemoItemCd.dw:
      rtn = this.dw;
      break;
    case NextPatMemoItemCd.va:
      rtn = this.va;
      break;
    case NextPatMemoItemCd.treatName:
      rtn = this.treatName;
      break;
    case NextPatMemoItemCd.treatStartTime:
      rtn = this.treatStartTime;
      break;
    case NextPatMemoItemCd.treatTime:
      rtn = this.treatTime;
      break;
    case NextPatMemoItemCd.treatMode:
      rtn = this.treatMode;
      break;
    case NextPatMemoItemCd.dialyzer:
      rtn = this.dialyzer;
      break;
    case NextPatMemoItemCd.needle_A:
      rtn = this.needle_A;
      break;
    case NextPatMemoItemCd.needle_V:
      rtn = this.needle_V;
      break;
    case NextPatMemoItemCd.anticoagulant:
      rtn = this.anticoagulant;
      break;
    case NextPatMemoItemCd.antInputOneShot:
      rtn = this.antInputOneShot;
      break;
    case NextPatMemoItemCd.antInputCont:
      rtn = this.antInputCont;
      break;
    case NextPatMemoItemCd.antInputContTotal:
      rtn = this.antInputContTotal;
      break;
    case NextPatMemoItemCd.antInputTotal:
      rtn = this.antInputTotal;
      break;
    case NextPatMemoItemCd.equip01:
      rtn = this.equip01;
      break;
    case NextPatMemoItemCd.equip02:
      rtn = this.equip02;
      break;
    case NextPatMemoItemCd.equip03:
      rtn = this.equip03;
      break;
    case NextPatMemoItemCd.equip04:
      rtn = this.equip04;
      break;
    case NextPatMemoItemCd.equip05:
      rtn = this.equip05;
      break;
    case NextPatMemoItemCd.equip06:
      rtn = this.equip06;
      break;
    case NextPatMemoItemCd.equip07:
      rtn = this.equip07;
      break;
    case NextPatMemoItemCd.equip08:
      rtn = this.equip08;
      break;
    case NextPatMemoItemCd.equip09:
      rtn = this.equip09;
      break;
    case NextPatMemoItemCd.equip10:
      rtn = this.equip10;
      break;
    case NextPatMemoItemCd.dialysisFluid:
      rtn = this.dialysisFluid;
      break;
    case NextPatMemoItemCd.medi01:
      rtn = this.medi01;
      break;
    case NextPatMemoItemCd.medi02:
      rtn = this.medi02;
      break;
    case NextPatMemoItemCd.medi03:
      rtn = this.medi03;
      break;
    case NextPatMemoItemCd.medi04:
      rtn = this.medi04;
      break;
    case NextPatMemoItemCd.medi05:
      rtn = this.medi05;
      break;
    case NextPatMemoItemCd.medi06:
      rtn = this.medi06;
      break;
    case NextPatMemoItemCd.medi07:
      rtn = this.medi07;
      break;
    case NextPatMemoItemCd.medi08:
      rtn = this.medi08;
      break;
    case NextPatMemoItemCd.medi09:
      rtn = this.medi09;
      break;
    case NextPatMemoItemCd.medi10:
      rtn = this.medi10;
      break;
    case NextPatMemoItemCd.medi11:
      rtn = this.medi11;
      break;
    case NextPatMemoItemCd.medi12:
      rtn = this.medi12;
      break;
    case NextPatMemoItemCd.medi13:
      rtn = this.medi13;
      break;
    case NextPatMemoItemCd.medi14:
      rtn = this.medi14;
      break;
    case NextPatMemoItemCd.medi15:
      rtn = this.medi15;
      break;
    case NextPatMemoItemCd.medi16:
      rtn = this.medi16;
      break;
    case NextPatMemoItemCd.medi17:
      rtn = this.medi17;
      break;
    case NextPatMemoItemCd.medi18:
      rtn = this.medi18;
      break;
    case NextPatMemoItemCd.medi19:
      rtn = this.medi19;
      break;
    case NextPatMemoItemCd.medi20:
      rtn = this.medi20;
      break;
    // add FNSI-バグ 通信サーバ #8009 高 start
    case NextPatMemoItemCd.targetWeight:
      rtn = this.targetWeight;
      break;
    case NextPatMemoItemCd.bv:
      rtn = this.bv;
      break;
    case NextPatMemoItemCd.ipSpeed:
      rtn = this.ipSpeed;
      break;
    case NextPatMemoItemCd.ipOneshot:
      rtn = this.ipOneshot;
      break;
    case NextPatMemoItemCd.ipAutoPowerOffTime:
      rtn = this.ipAutoPowerOffTime;
      break;
    case NextPatMemoItemCd.fluidReplacementSelect:
      rtn = this.fluidReplacementSelect;
      break;
    case NextPatMemoItemCd.fluidReplacementVolume:
      rtn = this.fluidReplacementVolume;
      break;
    case NextPatMemoItemCd.fluidReplacementRate:
      rtn = this.fluidReplacementRate;
      break;
    case NextPatMemoItemCd.oneceMembrane:
      rtn = this.oneceMembrane;
      break;
    // add FNSI-バグ 通信サーバ #8009 高 end
    default:
      //      rtn =  "";
    }
    return rtn;
  }
}
