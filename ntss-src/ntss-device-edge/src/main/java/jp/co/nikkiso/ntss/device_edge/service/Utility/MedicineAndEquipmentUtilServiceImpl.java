package jp.co.nikkiso.ntss.device_edge.service.Utility;

import tools.jackson.core.JacksonException;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import tools.jackson.databind.node.ArrayNode;
import tools.jackson.databind.node.ObjectNode;
import com.google.common.base.Strings;
import jp.co.nikkiso.ntss.core.dao.MstDialyzerDao;
import jp.co.nikkiso.ntss.core.dao.MstEquipmentDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineMixDao;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.MstEquipment;
import jp.co.nikkiso.ntss.core.entity.MstMedicine;
import jp.co.nikkiso.ntss.core.entity.MstMedicineMix;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import static jp.co.nikkiso.ntss.core.constant.CoreConstant.FacilitySettingNo.EQUIP_DISPLAY_ORDER;
import static jp.co.nikkiso.ntss.core.constant.CoreConstant.FacilitySettingNo.MEDICINE_DISPLAY_ORDER;

// #11339 2024.12.04 add 次患者情報の投与薬剤、医療材料の並び順を設定合わせてソート TDC片口
@Service
public class MedicineAndEquipmentUtilServiceImpl implements MedicineAndEquipmentUtilService {

  @Autowired
  private MstSelectorDao mstSelectorDao;
  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;
  @Autowired
  private MstEquipmentDao mstEquipmentDao;
  @Autowired
  private MstDialyzerDao mstDialyzerDao;
  @Autowired
  private MstMedicineDao mstMedicineDao;
  @Autowired
  private MstMedicineMixDao mstMedicineMixDao;

  /**
   * 医材のソート順設定値定数
   */
  private static class EquipSortKeyNames {
    /**
     * 登録順
     */
    static final class JsonIdx {
      static final String CODE = "0";
      static final String KEY = "json_idx";
    }

    /**
     * 医療材料分類マスタ表示順
     */
    static final class EquipClassOrder {
      static final String CODE = "1";
      static final String KEY = "equip_class_order";
      static final String MST_PHYSICAL_NAME = "mst_equipment_class";
    }

    /**
     * 医療材料マスタ表示順
     */
    static final class EquipOrder {
      static final String CODE = "2";
      static final String KEY = "equip_order";
      static final String MST_PHYSICAL_NAME_EQ = "mst_equipment";
      static final String MST_PHYSICAL_NAME_DZ = "mst_dialyzer";
    }
  }

  /**
   * 薬剤のソート順設定値定数
   */
  private static class MedicineSortKeyNames {
    /**
     * 登録順
     */
    static final class JsonIdx {
      static final String CODE = "0";
      static final String KEY = "json_idx";
    }

    /**
     * 薬剤分類マスタ表示順
     */
    static final class MedicineClassOrder {
      static final String CODE = "1";
      static final String KEY = "medicine_class_order";
      static final String MST_PHYSICAL_NAME = "mst_medicine_class";
    }

    /**
     * 薬剤区分（通常薬剤->調整薬剤）
     */
    static final class MedicineType {
      static final String CODE = "2";
      static final String KEY = "medicine_type";
    }

    /**
     * 調整薬剤マスタ表示順(薬剤マスタ→調整薬剤の順なのでコード同じ)
     */
    static final class MedicineOrder {
      static final String CODE = "3";
      static final String KEY_DEFAULT = "medicine_order";
      static final String KEY_MIX = "medicine_mix_order";
      static final String MST_PHYSICAL_NAME_DEF = "mst_medicine";
      static final String MST_PHYSICAL_NAME_MIX = "mst_medicine_mix";
    }

    /**
     * 投与タイミングマスタ表示順
     */
    static final class TimingOrder {
      static final String CODE = "4";
      static final String KEY = "timing_order";
      static final String MST_PHYSICAL_NAME = "mst_medicate_timing";
    }

    /**
     * 手技マスタ表示順
     */
    static final class ProcedureOrder {
      static final String CODE = "5";
      static final String KEY = "procedure_order";
      static final String MST_PHYSICAL_NAME = "mst_procedure";
    }

    /**
     * 投与感覚（間隔が短い順）
     */
    static final class DateInterval {
      static final String CODE = "6";
      static final String KEY = "date_interval";
    }
  }

  /**
   * 対象キー名のリストと必要なマスタセレクタの対象リスト
   *
   * @param displayOrderKeys      ソート対象のキー名と順序
   * @param orderMstPhysicalNames ソートキーの情報元になるマスタ物理名
   */
  private record DisplayOrderReturnValue(List<String> displayOrderKeys, List<String> orderMstPhysicalNames) {}

  /**
   * 薬剤のコード、種別と区分マスタのコードの対応
   * @param cd
   * @param medicineType
   * @param classCd
   */
  private record MedicineClassMap(Integer cd, int medicineType, Integer classCd) {}

  /**
   * 医材のコード、種別と区分マスタのコードの対応
   * @param cd
   * @param equipType
   * @param classCd
   */
  private record EquipmentClassMap(Integer cd, int equipType, Integer classCd) {}

  /**
   * {@inheritDoc}
   */
  @Override
  public String getSortedEquipInfo(String facilityCd, String equipInfo) {
    if (Strings.isNullOrEmpty(equipInfo)) {
      return equipInfo;
    }
    // ソート設定取得
    DisplayOrderReturnValue displayOrder = equipDisplayOrder(facilityCd);
    List<MstSelector> selectors = mstSelectorDao.selectByNameList(facilityCd, displayOrder.orderMstPhysicalNames);
    List<EquipmentClassMap> equipClasses = null;

    ObjectMapper mapper = new ObjectMapper();
    try {
      JsonNode jsonNodeArray = mapper.readTree(equipInfo);
      List<ObjectNode> objNodeList = new ArrayList<>();
      for (int i = 0; i < jsonNodeArray.size(); i++) {
        JsonNode jsonNode = jsonNodeArray.get(i);
        // jsonNodeは読み取り専用のため、ObjectNodeに変換
        ObjectNode objectNode = jsonNode.deepCopy().asObject();
        // ソートに必要な項目のセット
        objectNode.put(EquipSortKeyNames.JsonIdx.KEY, i);

        for (MstSelector selector : selectors) {
          // ソート用キー配列
          List<Long> sortedCodes = selector.getOrderSettings().getItems().stream().map(MstSelector.Item::getCode).toList();
          // ソートに必要な項目のセット
          switch (selector.getMasterPhysicalName()) {
            case EquipSortKeyNames.EquipClassOrder.MST_PHYSICAL_NAME:
              if (!jsonNode.has("class_cd")){
                // 条件送信前はclass_cdがない
                if (equipClasses == null) {
                  equipClasses = getEquipClasses(equipInfo);
                }
                int targetEquipType;
                if ("0".equals(jsonNode.get("equip_type").asText())) {
                  // 医療材料
                  targetEquipType = 0;
                  List<EquipmentClassMap> eqMap = equipClasses.stream().filter(x -> x.cd.equals(jsonNode.get("cd").asInt()) && x.equipType == targetEquipType).toList();
                  // class_cd を設定
                  if (eqMap.isEmpty()) {
                    objectNode.put("class_cd", -1);
                  } else {
                    objectNode.put("class_cd", eqMap.get(0).classCd);
                  }
                  objectNode.put(EquipSortKeyNames.EquipClassOrder.KEY, getSortIndex(objectNode, "class_cd", sortedCodes));
                } else {
                  // ダイアライザ
                  objectNode.put(EquipSortKeyNames.EquipClassOrder.KEY, 999999 + 1);
                }
              }
              break;
            case EquipSortKeyNames.EquipOrder.MST_PHYSICAL_NAME_EQ:
              if ("0".equals(jsonNode.get("equip_type").asText())) {
                // 医療材料
                objectNode.put(EquipSortKeyNames.EquipOrder.KEY, getSortIndex(objectNode, "cd", sortedCodes));
              }
              break;
            case EquipSortKeyNames.EquipOrder.MST_PHYSICAL_NAME_DZ:
              if ("1".equals(jsonNode.get("equip_type").asText())) {
                // ダイアライザ
                objectNode.put(EquipSortKeyNames.EquipOrder.KEY, getSortIndex(objectNode, "cd", sortedCodes) + 999999);
              }
              break;
            default:
              break;
          }
        }
        objNodeList.add(objectNode);
      }
      // 施設設定マスタNo.106に設定された順番で医材をソートする
      objNodeList.sort((o1, o2) -> compareByOrderKeys(o1, o2, displayOrder.displayOrderKeys));

      // JSON文字列化
      ArrayNode arrayNode = mapper.createArrayNode();
      for (ObjectNode node : objNodeList) {
        arrayNode.add(node);
      }
      return mapper.writeValueAsString(arrayNode);

    } catch (JacksonException e) {
      throw new RuntimeException(e);
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public String getSortedMedicineInfo(String facilityCd, String mediInfo) {
    if (Strings.isNullOrEmpty(mediInfo)) {
      return mediInfo;
    }
    // ソート設定取得
    DisplayOrderReturnValue displayOrder = medicineDisplayOrder(facilityCd);
    List<MstSelector> selectors = displayOrder.orderMstPhysicalNames.isEmpty() ?
      Collections.emptyList() :
      mstSelectorDao.selectByNameList(facilityCd, displayOrder.orderMstPhysicalNames);
    List<MedicineClassMap> medClasses = null;

    ObjectMapper mapper = new ObjectMapper();
    try {
      JsonNode jsonNodeArray = mapper.readTree(mediInfo);
      List<ObjectNode> objNodeList = new ArrayList<>();
      for (int i = 0; i < jsonNodeArray.size(); i++) {
        JsonNode jsonNode = jsonNodeArray.get(i);
        // jsonNodeは読み取り専用のため、ObjectNodeに変換
        ObjectNode objectNode = jsonNode.deepCopy().asObject();
        // ソートに必要な項目のセット
        objectNode.put(MedicineSortKeyNames.JsonIdx.KEY, i);

        for (MstSelector selector : selectors) {
          // ソート用キー配列
          List<Long> sortedCodes = selector.getOrderSettings().getItems().stream().map(MstSelector.Item::getCode).toList();
          // ソートに必要な項目のセット
          switch (selector.getMasterPhysicalName()) {
            case MedicineSortKeyNames.MedicineClassOrder.MST_PHYSICAL_NAME:
              if (!jsonNode.has("class_cd")){
                // 条件送信前はclass_cdがない
                if (medClasses == null) {
                  medClasses = getMedClasses(mediInfo);
                }
                int targetMedicineType;
                if ("2".equals(jsonNode.get(MedicineSortKeyNames.MedicineType.KEY).asText())) {
                  // 調製薬剤
                  targetMedicineType = 2;
                } else {
                  // 薬剤
                  targetMedicineType = 1;
                }
                List<MedicineClassMap> medMap = medClasses.stream().filter(x -> x.cd.equals(jsonNode.get("cd").asInt()) && x.medicineType == targetMedicineType).toList();
                // class_cd を設定
                if (medMap.isEmpty()) {
                  objectNode.put("class_cd", -1);
                } else {
                  objectNode.put("class_cd", medMap.get(0).classCd);
                }
              }
              objectNode.put(MedicineSortKeyNames.MedicineClassOrder.KEY,
                getSortIndex(objectNode, "class_cd", sortedCodes));
              break;
            case MedicineSortKeyNames.MedicineOrder.MST_PHYSICAL_NAME_DEF:
              if ("1".equals(jsonNode.get(MedicineSortKeyNames.MedicineType.KEY).asText())) {
                objectNode.put(MedicineSortKeyNames.MedicineOrder.KEY_DEFAULT,
                  getSortIndex(objectNode, "cd", sortedCodes));
              } else {
                objectNode.put(MedicineSortKeyNames.MedicineOrder.KEY_DEFAULT, "");
              }
              break;
            case MedicineSortKeyNames.MedicineOrder.MST_PHYSICAL_NAME_MIX:
              if ("2".equals(jsonNode.get(MedicineSortKeyNames.MedicineType.KEY).asText())) {
                objectNode.put(MedicineSortKeyNames.MedicineOrder.KEY_MIX,
                  getSortIndex(objectNode, "cd", sortedCodes));
              } else {
                objectNode.put(MedicineSortKeyNames.MedicineOrder.KEY_MIX, "");
              }
              break;
            case MedicineSortKeyNames.TimingOrder.MST_PHYSICAL_NAME:
              objectNode.put(MedicineSortKeyNames.TimingOrder.KEY,
                getSortIndex(objectNode, "timing_cd", sortedCodes));
              break;
            case MedicineSortKeyNames.ProcedureOrder.MST_PHYSICAL_NAME:
              objectNode.put(MedicineSortKeyNames.ProcedureOrder.KEY,
                getSortIndex(objectNode, "procedure_cd", sortedCodes));
              break;
            default:
              break;
          }
        }
        objNodeList.add(objectNode);
      }
      // 施設設定マスタNo.107に設定された順番で薬剤をソートする
      objNodeList.sort((o1, o2) -> compareByOrderKeys(o1, o2, displayOrder.displayOrderKeys));

      // JSON文字列化
      ArrayNode arrayNode = mapper.createArrayNode();
      for (ObjectNode node : objNodeList) {
        arrayNode.add(node);
      }
      return mapper.writeValueAsString(arrayNode);

    } catch (JacksonException e) {
      throw new RuntimeException(e);
    }
  }
  /** {@inheritDoc} */
  @Override
  public MstEquipAndDialyzer getMstEquipAndDialyzers(String equipInfo){
    List<Integer> equipCdList = new ArrayList<>();
    List<Integer> dialyzerCdList = new ArrayList<>();
    ObjectMapper mapper = new ObjectMapper();
    try {
      JsonNode equipInfoNodeArray = mapper.readTree(equipInfo);
      for (int i = 0; i < equipInfoNodeArray.size(); i++) {
        JsonNode jsonNode = equipInfoNodeArray.get(i);
        Integer cd = jsonNode.get("cd").asInt();
        if ("0".equals(jsonNode.get("equip_type").asText())) {
          equipCdList.add(cd);
        } else if ("1".equals(jsonNode.get("equip_type").asText())) {
          dialyzerCdList.add(cd);
        }
      }
      List<MstEquipment> equipments = mstEquipmentDao.selectByCdList(SelectOptions.get(), equipCdList);
      List<MstDialyzer> dialyzerList = mstDialyzerDao.selectAllByCdList(SelectOptions.get(), dialyzerCdList);

      return new MstEquipAndDialyzer(equipments, dialyzerList);

    } catch (JacksonException e) {
      throw new RuntimeException(e);
    }
  }

  /** {@inheritDoc} */
  @Override
  public MstMedicineAndMix getMstMedicineAndMixes(String mediInfo){
    List<Integer> mediCdList = new ArrayList<>();
    List<Integer> mediMixCdList = new ArrayList<>();
    ObjectMapper mapper = new ObjectMapper();
    try {
      JsonNode mediInfoNodeArray = mapper.readTree(mediInfo);
      for (int i = 0; i < mediInfoNodeArray.size(); i++) {
        JsonNode jsonNode = mediInfoNodeArray.get(i);
        Integer cd = jsonNode.get("cd").asInt();
        if ("1".equals(jsonNode.get(MedicineSortKeyNames.MedicineType.KEY).asText())) {
          mediCdList.add(cd);
        } else if ("2".equals(jsonNode.get(MedicineSortKeyNames.MedicineType.KEY).asText())) {
          mediMixCdList.add(cd);
        }
      }
      List<MstMedicine> medicines = mstMedicineDao.selectAllByCdList(SelectOptions.get(), mediCdList);
      List<MstMedicineMix> medicineMixes = mstMedicineMixDao.selectByMedicineMixCdList2(mediMixCdList);

      return new MstMedicineAndMix(medicines, medicineMixes);

    } catch (JacksonException e) {
      throw new RuntimeException(e);
    }
  }


  /**
   * 医療材料のソート順設定内容項目を取得
   *
   * @param facilityCd 施設コード
   * @return 対象キー名のリストと必要なマスタセレクタの対象リスト
   */
  private DisplayOrderReturnValue equipDisplayOrder(String facilityCd) {
    List<FacilitySettingInfo> displayOrders = mstFacilitySettingDao.selectFacilitySetting(facilityCd, EQUIP_DISPLAY_ORDER);
    if (displayOrders.isEmpty() || displayOrders.get(0).getValue() == null) {
      return new DisplayOrderReturnValue(Collections.emptyList(), Collections.emptyList());
    }
    String[] keys = displayOrders.get(0).getValue().replace("[", "").replace("]", "").replace("\"", "").split(",");
    List<String> orderKeys = new ArrayList<>();
    List<String> physicalNames = new ArrayList<>();
    for (String equipSortKey : keys) {
      switch (equipSortKey) {
        // 登録順
        case EquipSortKeyNames.JsonIdx.CODE:
          orderKeys.add(EquipSortKeyNames.JsonIdx.KEY);
          break;
        // 医材分類順
        case EquipSortKeyNames.EquipClassOrder.CODE:
          orderKeys.add(EquipSortKeyNames.EquipClassOrder.KEY);
          physicalNames.add(EquipSortKeyNames.EquipClassOrder.MST_PHYSICAL_NAME);
          break;
        // 医材マスタ表示順
        case EquipSortKeyNames.EquipOrder.CODE:
          orderKeys.add(EquipSortKeyNames.EquipOrder.KEY);
          physicalNames.add(EquipSortKeyNames.EquipOrder.MST_PHYSICAL_NAME_EQ);
          physicalNames.add(EquipSortKeyNames.EquipOrder.MST_PHYSICAL_NAME_DZ);
          break;
        default:
          break;
      }
    }
    if (!orderKeys.contains(EquipSortKeyNames.EquipOrder.KEY)){
      // 医材マスタ順がソート順に含まれていない場合、末尾に追加する
      orderKeys.add(EquipSortKeyNames.EquipOrder.KEY);
      physicalNames.add(EquipSortKeyNames.EquipOrder.MST_PHYSICAL_NAME_EQ);
      physicalNames.add(EquipSortKeyNames.EquipOrder.MST_PHYSICAL_NAME_DZ);
    }
    return new DisplayOrderReturnValue(orderKeys, physicalNames);
  }

  /**
   * 投与薬剤のソート順設定内容項目を取得
   *
   * @param facilityCd 施設コード
   * @return 対象キー名のリストと必要なマスタセレクタの対象リスト
   */
  private DisplayOrderReturnValue medicineDisplayOrder(String facilityCd) {
    List<FacilitySettingInfo> displayOrders = mstFacilitySettingDao.selectFacilitySetting(facilityCd, MEDICINE_DISPLAY_ORDER);
    if (displayOrders.isEmpty() || displayOrders.get(0).getValue() == null) {
      return new DisplayOrderReturnValue(Collections.emptyList(), Collections.emptyList());
    }
    String[] keys = displayOrders.get(0).getValue().replace("[", "").replace("]", "").replace("\"", "").split(",");
    List<String> orderKeys = new ArrayList<>();
    List<String> physicalNames = new ArrayList<>();
    for (String medicSortKey : keys) {
      switch (medicSortKey) {
        // 登録順
        case MedicineSortKeyNames.JsonIdx.CODE:
          orderKeys.add(MedicineSortKeyNames.JsonIdx.KEY);
          break;
        // 薬剤分類順
        case MedicineSortKeyNames.MedicineClassOrder.CODE:
          orderKeys.add(MedicineSortKeyNames.MedicineClassOrder.KEY);
          physicalNames.add(MedicineSortKeyNames.MedicineClassOrder.MST_PHYSICAL_NAME);
          break;
        // 薬剤区分
        case MedicineSortKeyNames.MedicineType.CODE:
          orderKeys.add(MedicineSortKeyNames.MedicineType.KEY);
          break;
        // 薬剤マスタ表示順
        case MedicineSortKeyNames.MedicineOrder.CODE:
          orderKeys.add(MedicineSortKeyNames.MedicineOrder.KEY_DEFAULT);
          orderKeys.add(MedicineSortKeyNames.MedicineOrder.KEY_MIX);
          physicalNames.add(MedicineSortKeyNames.MedicineOrder.MST_PHYSICAL_NAME_DEF);
          physicalNames.add(MedicineSortKeyNames.MedicineOrder.MST_PHYSICAL_NAME_MIX);
          break;
        // 投与時間帯
        case MedicineSortKeyNames.TimingOrder.CODE:
          orderKeys.add(MedicineSortKeyNames.TimingOrder.KEY);
          physicalNames.add(MedicineSortKeyNames.TimingOrder.MST_PHYSICAL_NAME);
          break;
        // 手技
        case MedicineSortKeyNames.ProcedureOrder.CODE:
          orderKeys.add(MedicineSortKeyNames.ProcedureOrder.KEY);
          physicalNames.add(MedicineSortKeyNames.ProcedureOrder.MST_PHYSICAL_NAME);
          break;
        // 投薬パターンコード
        case MedicineSortKeyNames.DateInterval.CODE:
          orderKeys.add(MedicineSortKeyNames.DateInterval.KEY);
          break;
        default:
          break;
      }
    }
    if (!orderKeys.contains(EquipSortKeyNames.EquipOrder.KEY)){
      // 薬剤マスタ順がソート順に含まれていない場合、末尾に追加する
      orderKeys.add(MedicineSortKeyNames.MedicineOrder.KEY_DEFAULT);
      orderKeys.add(MedicineSortKeyNames.MedicineOrder.KEY_MIX);
      physicalNames.add(MedicineSortKeyNames.MedicineOrder.MST_PHYSICAL_NAME_DEF);
      physicalNames.add(MedicineSortKeyNames.MedicineOrder.MST_PHYSICAL_NAME_MIX);
    }
    return new DisplayOrderReturnValue(orderKeys, physicalNames);
  }

  /**
   * 医材コード・ダイアライザコードから分類マスタのコードを取得
   * @param equipInfo equip_info
   * @return 医材・ダイアライザの分類とコード、それと医材分類マスタのコードの組み合わせ
   */
  private List<EquipmentClassMap> getEquipClasses(String equipInfo) {
    MstEquipAndDialyzer r = getMstEquipAndDialyzers(equipInfo);
    List<MstEquipment> equipments = r.mstEquipments();
    List<MstDialyzer> dialyzerList = r.mstDialyzers();
    List<EquipmentClassMap> retValue = new ArrayList<>();

    for (MstEquipment equipment : equipments) {
      retValue.add(new EquipmentClassMap(equipment.getEquipmentCd(), 0, equipment.getClassCd()));
    }
    for (MstDialyzer dialyzer : dialyzerList) {
      retValue.add(new EquipmentClassMap(dialyzer.getDialyzerCd(), 1, 5000));
    }
    return retValue;
  }

  /**
   * 薬剤コード・調整薬剤コードから薬剤分類マスタのコードを取得
   * @param mediInfo medi_info
   * @return 薬剤・調整薬剤の分類とコード、それと薬剤分類マスタのコードの組み合わせ
   */
  private List<MedicineClassMap> getMedClasses(String mediInfo) {
    MstMedicineAndMix r = getMstMedicineAndMixes(mediInfo);
    List<MstMedicine> medicines = r.mstMedicines();
    List<MstMedicineMix> medicineMixes = r.mstMedicineMixes();
    List<MedicineClassMap> retValue = new ArrayList<>();

    for (MstMedicine medicine : medicines) {
      retValue.add(new MedicineClassMap(medicine.getMedicineCd(), 1, medicine.getClassCd()));
    }
    for (MstMedicineMix medicineMix : medicineMixes) {
      retValue.add(new MedicineClassMap(medicineMix.getMedicineMixCd(), 2, medicineMix.getClassCd()));
    }
    return retValue;
}

  /**
   * Json ObjectNode の任意のキーの値が ソート順の何番目になっているかを取得
   *
   * @param jsonNode    対象ノード
   * @param nodeReadKey 読取対象キー
   * @param sortedCodes 参照するソート順所
   * @return 変更されたobjectNode
   */
  private static int getSortIndex(ObjectNode jsonNode, String nodeReadKey, List<Long> sortedCodes) {
    Long cd = jsonNode.get(nodeReadKey).asLong(-1);
    return sortedCodes.indexOf(cd);
  }

  /**
   * ObjectNodeの項目をorderKeysに記録されたキーの値の順番でソートするための比較関数
   *
   * @param o1        比較対象１
   * @param o2        比較対象２
   * @param orderKeys キーセット
   * @return 比較結果 -1 / 0 / 1
   */
  private static int compareByOrderKeys(ObjectNode o1, ObjectNode o2, List<String> orderKeys) {
    final int maxOrder = 999999;
    for (String key : orderKeys) {
      int v1 = (o1.get(key) == null || o1.get(key).asText().isEmpty()) ? maxOrder : Integer.parseInt(o1.get(key).toString());
      int v2 = (o2.get(key) == null || o2.get(key).asText().isEmpty()) ? maxOrder : Integer.parseInt(o2.get(key).toString());
      Integer v01 = v1 < 0 ? maxOrder : v1;
      Integer v02 = v2 < 0 ? maxOrder : v2;
      int compareResult = v01.compareTo(v02);
      if (compareResult != 0) {
        return compareResult;
      }
    }
    return 0;
  }
}
