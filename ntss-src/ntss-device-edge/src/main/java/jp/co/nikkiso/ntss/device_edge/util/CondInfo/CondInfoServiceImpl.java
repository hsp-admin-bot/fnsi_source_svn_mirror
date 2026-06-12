package jp.co.nikkiso.ntss.device_edge.util.CondInfo;

import java.util.HashMap;
import java.util.Objects;

import com.google.common.base.Strings;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.device_edge.service.LogService;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.dao.MstDialyzerDao;
import jp.co.nikkiso.ntss.core.dao.MstEquipmentDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineMixDao;
import jp.co.nikkiso.ntss.core.dao.MstVaDao;
import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.MstEquipment;
import jp.co.nikkiso.ntss.core.entity.MstMedicine;
import jp.co.nikkiso.ntss.core.entity.MstMedicineMix;
import jp.co.nikkiso.ntss.core.entity.MstVa;
import jp.co.nikkiso.ntss.device_edge.constant.Constant.CondItemCd;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 *  治療条件情報処理サービスの実装クラス.
 */
@Service
public class CondInfoServiceImpl implements CondInfoService {
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
  @Autowired
  private LogService logService;
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end

  /**
   * 治療条件情報のJSON文字列から治療条件情報クラスに展開します。
   * 【注意】指示の治療条件情報には各項目の名前や単位がないため、
   * 本クラスの各findメソッドを使用してマスタから引き当てて下さい。
   * @param condInfoJsonString
   */
  @Override
  public CondInfo createCondInfo(String condInfoJsonString) {
    CondInfo condInfo = new CondInfo();
    if (condInfoJsonString != null) {
      ObjectMapper mapper = new ObjectMapper();
      try {
        JsonNode jsonNode_parent = mapper.readTree(condInfoJsonString);
        condInfo = this.setItems(jsonNode_parent);

      } catch (tools.jackson.core.JacksonException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      }
    }
    return condInfo;
  }

  @Autowired
  MstDialyzerDao mstDialyzerDao;

  /**
   * 格納されているダイアライザコードをもとにダイアライザマスタからモデル番号を検索し返します
   */
  @Override
  public String findDialyzerName(CondInfo condInfo) {
    String ret = "";
    if( condInfo.dialyzer.getValue() != null ) {
      // 格納されているダイアライザコードを数値化
      int dialyzerCd = Integer.parseInt(condInfo.dialyzer.getValue());
      // マスタ情報取得
      MstDialyzer mstDialyzer = mstDialyzerDao.selectByDialyzerCd(SelectOptions.get(), dialyzerCd);
      // 名称を返す
      ret = mstDialyzer.getModelNumber();
    }
    return ret;
  }

  @Autowired
  MstVaDao mstVaDao;

  /**
   * 格納されているVAコードをもとにVAマスタからVA名を検索し返します。
   */
  @Override
  public String findVaName(CondInfo condInfo) {
    String ret = "";
    if( condInfo.va.getValue() != null) {
      // 格納されているVAコードを数値化
      int vaCd = Integer.parseInt(condInfo.va.getValue());
      // マスタ情報取得
      MstVa mstVa = mstVaDao.selectByCd(vaCd);
      // 名称を返す
      ret = mstVa.getVaName();
    }
    return ret;
  }

  @Autowired
  MstEquipmentDao mstEquipDao;

  /**
   * 格納されているA針コードをもとに医療材料マスタから医療材料名、単位を検索し、返します。
   * 戻り値のキー：name, unit
   * @param condInfo
   */
  @Override
  public HashMap<String, String> findNeedleAName(CondInfo condInfo) {
    // 戻り値格納用
    HashMap<String, String> rtn = new HashMap<String, String>();
    if (condInfo.needleA.getValue() != null) {
      // 格納されているA針コードを数値化
      int needleCd_A = Integer.parseInt(condInfo.needleA.getValue());
      // マスタ情報取得
      MstEquipment mstEquip = mstEquipDao.selectByEquipmentCd(needleCd_A);
      if( mstEquip != null ) {
        // 名称を格納
        rtn.put("name", mstEquip.getEquipmentName());
        // 単位を格納
        rtn.put("unit", mstEquip.getUnit());
      }
    }

    return rtn;
  }

  /**
   * 格納されているV針コードをもとに医療材料マスタから医療材料名、単位を検索し、返します。
   * 戻り値のキー：name, unit
   * @param condInfo
   */
  @Override
  public HashMap<String, String> findNeedleVName(CondInfo condInfo) {
    // 戻り値格納用
    HashMap<String, String> rtn = new HashMap<String, String>();
    if ( condInfo.needleV.getValue() != null) {
      // 格納されているV針コードを数値化
      int needleCd_V = Integer.parseInt(condInfo.needleV.getValue());
      // マスタ情報取得
      MstEquipment mstEquip = mstEquipDao.selectByEquipmentCd(needleCd_V);
      if ( mstEquip != null ) {
        // 名称を格納
        rtn.put("name", mstEquip.getEquipmentName());
        // 単位を格納
        rtn.put("unit", mstEquip.getUnit());
      }
    }

    return rtn;
  }

  // #9147 2024.01.25 add 次患者整形 A針だがSN使用の場合はSNの情報をセット TDC山崎 start
  /**
   * 格納されているSN針コードをもとに医療材料マスタから医療材料名、単位を検索し、返します。
   * 戻り値のキー：name, unit
   * @param condInfo
   */
  @Override
  public HashMap<String, String> findNeedleSnName(CondInfo condInfo) {
    // 戻り値格納用
    HashMap<String, String> rtn = new HashMap<>();

    if (condInfo.needleS.getValue() != null) {
      int needleCd_SN = Integer.parseInt(condInfo.needleS.getValue());
      MstEquipment mstEquip = mstEquipDao.selectByEquipmentCd(needleCd_SN);
      if (mstEquip != null) {
        rtn.put("name", mstEquip.getEquipmentName());
        rtn.put("unit", mstEquip.getUnit());
      }
    }

    return rtn;
  }
  // #9147 2024.01.25 add 次患者整形 A針だがSN使用の場合はSNの情報をセット TDC山崎 end

  //add redmine bug#5525 劉 start
  /**
   * 格納されている医療材料コードをもとにダイアライザマスタからモデル番号を検索し返します
   * 戻り値のキー：name, unit
   * @param condInfoItem  治療条件項目クラス
   */
  @Override
  public String findEquipmentName(CondInfoItem condInfoItem) {
    String ret = "";
    if (!Strings.isNullOrEmpty(condInfoItem.getValue())) {
      // 格納されている医療材料コードを数値化
      int equipmentCd = Integer.parseInt(condInfoItem.getValue());
      // マスタ情報取得
      MstEquipment mstEquip = mstEquipDao.selectByEquipmentCd(equipmentCd);
      if( mstEquip != null ) {
        // 名称を返す
        ret = mstEquip.getEquipmentName();
      }
    }

    return ret;
  }
  //add redmine bug#5525 劉 end

  @Autowired
  MstMedicineDao mstMedicineDao;
  @Autowired
  MstMedicineMixDao mstMedicineMixDao;

  /**
   * 格納されている透析液コードをもとに薬剤マスタから薬剤名、単位を検索し、返します。
   * 戻り値のキー：name, unit
   * @param condInfo
   */
  @Override
  public HashMap<String, String> findDialysisFluidName(CondInfo condInfo) {
    // 戻り値格納用
    HashMap<String, String> rtn = new HashMap<String, String>();
    if (condInfo.dialysisFluid.getValue() != null) {
      // 格納されている透析液コードを数値化
      Integer dialysisFluidCd = Integer.parseInt(condInfo.dialysisFluid.getValue());
      // 薬剤区分
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //String dialysisFluidMediType = condInfo.dialysisFluid.getMedicineType();
      //if ( Objects.equals( dialysisFluidMediType, "2")) {
      Integer dialysisFluidMediType = condInfo.dialysisFluid.getMedicineType();
      if ( Objects.equals( dialysisFluidMediType, 2)) {
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
        // 調整薬剤
        // マスタ情報取得
        MstMedicineMix mstMedicineMix = mstMedicineMixDao.selectByMedicineMixCd(dialysisFluidCd);
        if( mstMedicineMix != null ) {
          // 名称を格納
          rtn.put("name", mstMedicineMix.getMedicineMixName());
          // 単位を格納
          rtn.put("unit", mstMedicineMix.getUnit());
          // 小数点以下桁数を格納
          rtn.put("decimal_point", mstMedicineMix.getUnitDecimalPoint() == null ? "": mstMedicineMix.getUnitDecimalPoint().toString());
        }
      } else {
        // 薬剤
        // マスタ情報取得
        MstMedicine mstMedicine = mstMedicineDao.selectByMediCd(dialysisFluidCd);
        if( mstMedicine != null ) {
          // 名称を格納
          rtn.put("name", mstMedicine.getMedicineName());
          // 単位を格納
          rtn.put("unit", mstMedicine.getUnit());
          // 小数点以下桁数を格納
          rtn.put("decimal_point", mstMedicine.getUnitDecimalPoint() == null ? "": mstMedicine.getUnitDecimalPoint().toString());
        }
      }
    }
    return rtn;
  }

  /**
   * 格納されている抗凝固剤コードをもとに薬剤マスタから薬剤名、単位を検索し、返します。
   * 戻り値のキー：name, unit
   * @param condInfo
   */
  @Override
  public HashMap<String, String> findAnticoagulantName(CondInfo condInfo) {
    // 戻り値格納用
    HashMap<String, String> rtn = new HashMap<String, String>();
    if (condInfo.anticoagulant.getValue() != null) {
      // 格納されている抗凝固剤コードを数値化
      Integer anticoagulantCd = Integer.parseInt(condInfo.anticoagulant.getValue());
      // 薬剤区分
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //String anticoagulantMediType = condInfo.anticoagulant.getMedicineType();
      //if ( Objects.equals( anticoagulantMediType, "2")) {
      Integer anticoagulantMediType = condInfo.anticoagulant.getMedicineType();
      if ( Objects.equals( anticoagulantMediType, 2)) {
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
        // 調整薬剤
        // マスタ情報取得
        MstMedicineMix mstMedicineMix = mstMedicineMixDao.selectByMedicineMixCd(anticoagulantCd);
        if( mstMedicineMix != null ) {
          // 名称を格納
          rtn.put("name", mstMedicineMix.getMedicineMixName());
          // 単位を格納
          rtn.put("unit", mstMedicineMix.getUnit());
          // 小数点以下桁数を格納
          rtn.put("decimal_point", mstMedicineMix.getUnitDecimalPoint() == null ? "": mstMedicineMix.getUnitDecimalPoint().toString());
        }
      } else {
        // 薬剤
        // マスタ情報取得
        MstMedicine mstMedicine = mstMedicineDao.selectByMediCd(anticoagulantCd);
        if( mstMedicine != null ) {
          // 名称を格納
          rtn.put("name", mstMedicine.getMedicineName());
          // 単位を格納
          rtn.put("unit", mstMedicine.getUnit());
          // 小数点以下桁数を格納
          rtn.put("decimal_point", mstMedicine.getUnitDecimalPoint() == null ? "": mstMedicine.getUnitDecimalPoint().toString());
        }
      }
    }
    return rtn;
  }

  /****** プライベートメソッド *********/

  /**
   * JSONノードからCondInfoクラスに展開して返します。
   * @param jsonNode
   * @return
   */
  private CondInfo setItems(JsonNode jsonNode) {
    CondInfo condInfo = new CondInfo();

    // 透析時間
    condInfo.treatTime = buildCondInfoItem(jsonNode, CondItemCd.TREAT_TIME);
    // VA
    condInfo.va = buildCondInfoItem(jsonNode, CondItemCd.VA);
    // 目標体重
    condInfo.targetWeight = buildCondInfoItem(jsonNode, CondItemCd.WEIGHT_TARGET);
    // 除水量制限
    condInfo.ufrLimit = buildCondInfoItem(jsonNode, CondItemCd.REMOVAL_LIMIT);
    // ダイアライザ
    condInfo.dialyzer = buildCondInfoItem(jsonNode, CondItemCd.DIALIZER);
    // 吸着カラム
    condInfo.adsorbent = buildCondInfoItem(jsonNode, CondItemCd.ADSORBENT);
    // 1次膜
    condInfo.oneceMembrane = buildCondInfoItem(jsonNode, CondItemCd.ONECE_MEMBRANE);
    // 2次膜
    condInfo.secondaryMembrane = buildCondInfoItem(jsonNode, CondItemCd.SECONDARY_MEMBRANE);
    // 穿刺針(A針)
    condInfo.needleA = buildCondInfoItem(jsonNode, CondItemCd.NEEDLE_A);
    // 穿刺針(V針)
    condInfo.needleV = buildCondInfoItem(jsonNode, CondItemCd.NEEDLE_V);
    // 穿刺針(S針)
    condInfo.needleS = buildCondInfoItem(jsonNode, CondItemCd.NEEDLE_S);
    // シングルニードル使用
    condInfo.useSingleNeedle = buildCondInfoItem(jsonNode, CondItemCd.USE_SINGLE_NEEDLE);
    // 血液回路
    condInfo.bloodCircuit = buildCondInfoItem(jsonNode, CondItemCd.BLOOD_CIRCUIT);
    // 血流量
    condInfo.bv = buildCondInfoItem(jsonNode, CondItemCd.BV);
    // 透析液
    condInfo.dialysisFluid = buildCondInfoItem(jsonNode, CondItemCd.DIALYSIS_FLUID);
    // 透析液流量
    condInfo.dialysisFlowRate = buildCondInfoItem(jsonNode, CondItemCd.DIALYSIS_FLOW_RATE);
    // 透析液量
    condInfo.dialysisFluidVolume = buildCondInfoItem(jsonNode, CondItemCd.DIALYSIS_FLUID_VOLUME);
    // 透析液温度
    condInfo.dialysisFluidTemperature = buildCondInfoItem(jsonNode, CondItemCd.DIALYSIS_FLUID_TEMPERATURE);
    // 補液
    condInfo.fluidReplacement = buildCondInfoItem(jsonNode, CondItemCd.FLUID_REPLACEMENT);
    // 補液量
    condInfo.fluidReplacementVolume = buildCondInfoItem(jsonNode, CondItemCd.FLUID_REPLACEMENT_VOLUME);
    // 補液選択
    condInfo.fluidReplacementSelect = buildCondInfoItem(jsonNode, CondItemCd.FLUID_REPLACEMENT_SELECT);
    // 補液使用数
    condInfo.fluidReplacementUseCnt = buildCondInfoItem(jsonNode, CondItemCd.FLUID_REPLACEMENT_USE_CNT);
    // 補液温度
    condInfo.fluidReplacementTemperature = buildCondInfoItem(jsonNode, CondItemCd.FLUID_REPLACEMENT_TEMPERATURE);
    // 補液速度
    condInfo.fluidReplacementRate = buildCondInfoItem(jsonNode, CondItemCd.FLUID_REPLACEMENT_RATE);
    // 抗凝固剤
    condInfo.anticoagulant = buildCondInfoItem(jsonNode, CondItemCd.ANTICOAGULANT);
    // 抗凝固剤初回注入量
    condInfo.antInputOneshot = buildCondInfoItem(jsonNode, CondItemCd.ANT_INPUT_ONESHOT);
    // 抗凝固剤持続注入量
    condInfo.antInputCont = buildCondInfoItem(jsonNode, CondItemCd.ANT_INPUT_CONT);
    // 抗凝固剤持続総量
    condInfo.antInputContTotal = buildCondInfoItem(jsonNode, CondItemCd.ANT_INPUT_CONT_TOTAL);
    // IP使用選択
    condInfo.ipUseSelect = buildCondInfoItem(jsonNode, CondItemCd.IP_USE_SELECT);
    // IPスタート
    condInfo.ipStart = buildCondInfoItem(jsonNode, CondItemCd.IP_START);
    // IPワンショット量
    condInfo.ipOneshot = buildCondInfoItem(jsonNode, CondItemCd.IP_ONESHOT);
    // IP速度
    condInfo.ipSpeed = buildCondInfoItem(jsonNode, CondItemCd.IP_SPEED);
    // IP速度最大値
    condInfo.ipSpeedMax = buildCondInfoItem(jsonNode, CondItemCd.IP_SPEED_MAX);
    // 自動ワンショット
    condInfo.autoOneshot = buildCondInfoItem(jsonNode, CondItemCd.AUTO_ONESHOT);
    // IP電源自動切り
    condInfo.ipAutoPowerOff = buildCondInfoItem(jsonNode, CondItemCd.IP_AUTO_POWER_OFF);
    // IP電源自動切り時間
    condInfo.ipAutoPowerOffTime = buildCondInfoItem(jsonNode, CondItemCd.IP_AUTO_POWER_OFF_TIME);
    // IP電源OKモニタ切り
    condInfo.ipOkMonitorOff = buildCondInfoItem(jsonNode, CondItemCd.IP_OK_MONITOR_OFF);
    // IP電源OKモニタ切り時間
    condInfo.ipOkMonitorOffTime = buildCondInfoItem(jsonNode, CondItemCd.IP_OK_MONITOR_OFF_TIME);

    return condInfo;
  }

  /**
   * 治療指示ＪＳＯＮから目的のキーの値を取得
   * @param jsonNode
   * @param key
   * @return
   */
  private CondInfoItem buildCondInfoItem(JsonNode jsonNode, short key) {
    CondInfoItem ret = new CondInfoItem();
    String index = String.valueOf(key);

    if (!jsonNode.has(index)) {
      // 当該の項目が存在しない
      return ret;
    }

    // 子ノード取得
    JsonNode childNode = jsonNode.get(index);

    // 各項目のノード取得
    JsonNode valueNode = childNode.has("value") ? childNode.get("value") : null;
    JsonNode nameNode = childNode.has("value_name_1") ? childNode.get("value_name_1") : null;
    JsonNode unitNode = childNode.has("unit") ? childNode.get("unit") : null;
    JsonNode indUserIdNode = childNode.has("ind_user_id") ? childNode.get("ind_user_id") : null;
    JsonNode updUserIdNode = childNode.has("upd_user_id") ? childNode.get("upd_user_id") : null;
    JsonNode medicineTypeNode = childNode.has("medicine_type") ? childNode.get("medicine_type") : null;
    JsonNode inputClassNode = childNode.has("input_class") ? childNode.get("input_class") : null;
    JsonNode isEditableNode = childNode.has("is_editable") ? childNode.get("is_editable") : null;
    JsonNode copOrderNoNode = childNode.has("cop_order_no") ? childNode.get("cop_order_no") : null;
    // 各値取得
    String value = Objects.isNull(valueNode) || valueNode.isNull() ? null : valueNode.asText();
    String name = Objects.isNull(nameNode) || nameNode.isNull() ? null : nameNode.asText();
    String unit = Objects.isNull(unitNode) || unitNode.isNull() ? null : unitNode.asText();
    String indUserId = Objects.isNull(indUserIdNode) || indUserIdNode.isNull() ? null : indUserIdNode.asText();
    String updUserId = Objects.isNull(updUserIdNode) || updUserIdNode.isNull() ? null : updUserIdNode.asText();
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
    //String medicineType = Objects.isNull(medicineTypeNode) || medicineTypeNode.isNull() ? null : medicineTypeNode.asText();
    //String inputClass = Objects.isNull(inputClassNode) || inputClassNode.isNull() ? null : inputClassNode.asText();
    Integer medicineType = Objects.isNull(medicineTypeNode) || medicineTypeNode.isNull() ? null : medicineTypeNode.asInt();
    Integer inputClass = Objects.isNull(inputClassNode) || inputClassNode.isNull() ? null : inputClassNode.asInt();
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    String isEditable = Objects.isNull(isEditableNode) || isEditableNode.isNull() ? null : isEditableNode.asText();
    String copOrderNo = Objects.isNull(copOrderNoNode) || copOrderNoNode.isNull() ? null : copOrderNoNode.asText();

    ret.setCd((int)key);
    ret.setValue(value);
    ret.setName(name);
    ret.setUnit(unit);
    ret.setIndUserId(indUserId);
    ret.setUpdUserId(updUserId);
    ret.setMedicineType(medicineType);
    ret.setInputClass(inputClass);
    ret.setIsEditable(isEditable);
    ret.setCopOrderNo(copOrderNo);

    return ret;
  }

}
