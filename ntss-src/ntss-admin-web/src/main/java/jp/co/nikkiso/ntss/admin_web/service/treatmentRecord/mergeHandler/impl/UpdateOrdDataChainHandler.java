package jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.mergeHandler.impl;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.mergeHandler.TreatmentRecordMergeChainHandler;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dto.ordMaterialSave.OrdMaterialSaveDto;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.service.ordMaterialSaveService.OrdMaterialSaveService;
import jp.co.nikkiso.ntss.core.utils.AppContextUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.util.CollectionUtils;

import java.sql.Timestamp;
import java.time.Instant;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 治療記録更新Handler
 *
 * @author Tao.zhou
 * @since 2024-04-03
 */
public class UpdateOrdDataChainHandler extends TreatmentRecordMergeChainHandler {

  /** 投薬識別番号 */
  private final long maxMedicNo;

  private final boolean delFlag;

  private final String mergeRstMediInfo;

  /** 空のJsonObject文字列 */
  private static final String JSON_OBJECT_EMPTY = "{}";
  /** 空のJsonArray文字列 */
  private static final String JSON_ARRAY_EMPTY = "[]";
  /** 転記区分:1「当日のみ」 */
//  private static final String TODAY_ONLY = "1";

  private final ObjectMapper objectMapper;

  private final OrdMainDao ordMainDao;
  private final MstMachineDao mstMachineDao;
//  private final PatMainDao patMainDao;

  private final OrdMaterialSaveService ordMaterialSaveService;

  /** コンストラクタ */
  public UpdateOrdDataChainHandler(long maxMedicNo, boolean delFlag, String mergeRstMediInfo) {
    this.maxMedicNo = maxMedicNo;
    this.delFlag = delFlag;
    this.mergeRstMediInfo = mergeRstMediInfo;

    this.ordMainDao = AppContextUtils.getBean(OrdMainDao.class);
    this.mstMachineDao = AppContextUtils.getBean(MstMachineDao.class);
//    this.patMainDao = AppContextUtils.getBean(PatMainDao.class);
    this.ordMaterialSaveService = AppContextUtils.getBean(OrdMaterialSaveService.class);
    this.objectMapper = AppContextUtils.getBean(ObjectMapper.class);

  }

  public Long getMaxMedicNo() { return maxMedicNo; }

  /** 治療記録更新操作 */
  @Override
  public void execute() {

    Timestamp updTs = Timestamp.from(Instant.now());

    // 投薬最新識別番号の整合合わせ
    String rstMediInfo = baseOrdMainData.getRstMediInfo();
    // 指示コメント番号の整合合わせ
    String rstIndComment = baseOrdMainData.getRstIndCommentInfo();
    // 回診記録は指示コメントに転記、指示コメント整合合わせ後、指示コメント番号不整合の場合、回診記録の指示コメントに転記設定しない。
    // is_ind_comment_post -> '0' & ind_comment_no -> null
    String rstRoundInfo = baseOrdMainData.getRstRoundsInfo();

    try {
      // ベットを変更の場合、装置番号と装置名変更
      List<MstMachine> machineInfos =
        mstMachineDao.selectByBedCd(baseOrdMainData.getFacilityCd(), baseOrdMainData.getRstBedCd());
      if (!CollectionUtils.isEmpty(machineInfos)) {
        baseOrdMainData.setRstMachineNo(machineInfos.get(0).getMachineNo());
        baseOrdMainData.setRstMachineName(machineInfos.get(0).getMachineName());
      }

//      // 患者基本情報の透析回数か浄化治療回数を更新
//      PatMain patMain = patMainDao.selectById(baseOrdMainData.getPatId());
//
//      JsonNode nodeMedicalCareInfo =
//        objectMapper.readTree(patMain.getMedical_care_info() == null
//          ? JSON_OBJECT_EMPTY : patMain.getMedical_care_info());
//
//      // 「透析回数」と「特殊浄化回数」を確認
//      boolean purifyDialysis = StringUtils.equals(
//        WebAPICheckConditionSend.CommonIndConst.DEVICE_MODE_PURIFICATION.get()
//        , baseOrdMainData.getIndDeviceMode().toString()
//      );
//      String strFieldName = purifyDialysis ? "purification_count" : "dialysis_count";
//      ObjectNode medicalCareInfoObjNode = (ObjectNode) nodeMedicalCareInfo;
//      // 「透析回数」と「特殊浄化回数」の更新
//      if (!nodeMedicalCareInfo.isNull()
//        && nodeMedicalCareInfo.hasNonNull(strFieldName)) {
//        Integer dialysisCnt = purifyDialysis
//          ? baseOrdMainData.getRstPurificationCnt() : baseOrdMainData.getRstDialysisCnt();
//        medicalCareInfoObjNode.put(strFieldName, dialysisCnt);
//      }
//      patMain.setMedical_care_info(nodeMedicalCareInfo.toPrettyString());
//      this.patMainDao.update(patMain);

      // baseData後体重測定済を変更するには合、baseDataに後体重情報をテックする、
      // 後体重情報ありませんの時、マージデータに後体重情報を設定する
      if (StringUtils.equals(AdminWebConstant.OrdMainConst.DialysisState.AFTER_WEIGHT
        , baseOrdMainData.getRstDialysisState())) {
        JsonNode weightInfo = objectMapper.readTree(
          StringUtils.isEmpty(baseOrdMainData.getRstWeightInfo())
          ? JSON_OBJECT_EMPTY : baseOrdMainData.getRstWeightInfo()
        );

        if (!weightInfo.isNull()
          && !weightInfo.hasNonNull("weight_after")) {
          ObjectNode baseWeightObjInfo = (ObjectNode) weightInfo;

          // マージデータの後体重情報を設定する
          JsonNode mergeWeightInfo = objectMapper.readTree(
            StringUtils.isEmpty(mergeOrdMainData.getRstWeightInfo())
            ? JSON_OBJECT_EMPTY : mergeOrdMainData.getRstWeightInfo()
          );
          if (!mergeWeightInfo.isNull()
            && mergeWeightInfo.hasNonNull("weight_after")) {
            baseWeightObjInfo.put("weight_after", mergeWeightInfo.get("weight_after").asText());
            baseWeightObjInfo.put("weight_after_date", mergeWeightInfo.get("weight_after_date").asText());
          }
        }
      }


      // 投薬最新識別番号の整合合わせ
      JsonNode rstMediJsonNode = this.mediCtlNoReintegration(rstMediInfo, this.mergeRstMediInfo);
      // 投与薬剤情報再割り当て
      baseOrdMainData.setRstMediInfo(rstMediJsonNode.toString());

      // 医材の同一番号は加算する必要があります
      JsonNode rstEquipJsonNode = this.equipmentReintegration(baseOrdMainData.getRstEquipInfo());
      // 医療材料情報再割り当て
      baseOrdMainData.setRstEquipInfo(rstEquipJsonNode.toString());

      // 回診記録、指示コメントに転記
      if (StringUtils.isNotEmpty(rstRoundInfo)) {
        JsonNode rstRoundInfoJsonNode = this.roundInfoReintegration(rstRoundInfo
          , rstIndComment);
        // 回診記録再割り当て
        baseOrdMainData.setRstRoundsInfo(rstRoundInfoJsonNode.toString());
      }

    } catch (JsonProcessingException e) {
      throw new NtssException("マージデータのJSON書式不整合、マージ処理できない。", e);
    }

    // ベースデータを更新する
    baseOrdMainData.setUpDate(updTs);
    this.ordMainDao.update(baseOrdMainData);
    // 計算材料保持マージ処理
    // mod #12250 ord_material_saveの処理を2回重複実行している zkm start
//    this.ordMaterialSaveService.updateOrdMaterialSaveByDiff(
//      new OrdMaterialSaveDto(baseOrdMainData.getOrdNo()
//        , true, true, true, true
//        , OrdMaterialSaveDto.RST_CLASS, baseOrdMainData)
//    );
    ordMaterialSaveService.bulkUpdateByOrdNoInCondMediEquipTreatment(Collections.singletonList(baseOrdMainData.getOrdNo()));
    // mod #12250 ord_material_saveの処理を2回重複実行している zkm end

    // マージデータ消去しないの場合、データの治療状況を更新する
    if (!delFlag) {
      this.ordMainDao.updateRstDialysisStateAndEndDate(
        mergeOrdMainData.getOrdNo()
        , mergeOrdMainData.getRstDialysisState()
        , mergeOrdMainData.getRstEndDate()
      );
    }

    // 現在、後続の処理があるかどうかを判断し、処理があれば後続の処理を行う。
    if (getSuccessor() != null) {
      getSuccessor().execute();
    }
  }

  /**
   * 投薬最新識別番号の整合合わせ
   *
   * @param rstMediInfo ベースデータの投与薬剤情報
   * @param megMediInfo マージデータの投与薬剤情報
   * @return  番号整合後の投与薬剤情報
   */
  private JsonNode mediCtlNoReintegration(String rstMediInfo, String megMediInfo) throws JsonProcessingException {

    rstMediInfo = StringUtils.isNotEmpty(rstMediInfo) ? rstMediInfo : JSON_ARRAY_EMPTY;
    megMediInfo = StringUtils.isNotEmpty(megMediInfo) ? megMediInfo : JSON_ARRAY_EMPTY;
    // 投薬最新識別番号の整合合わせ
    JsonNode rstMediJsonNode = objectMapper.readTree(rstMediInfo);
    JsonNode megMediJsonNode = objectMapper.readTree(megMediInfo);

    if (rstMediJsonNode.isArray() && megMediJsonNode.isArray()) {
      // ArrayNodeに変更
      ArrayNode rstMediArrayNode = (ArrayNode) rstMediJsonNode;
      ArrayNode megMediArrayNode = (ArrayNode) megMediJsonNode;

      Long lpmNo = this.getMaxMedicNo();
      // 順序を逆にして循環し、番号を1回1ずつ減算すれば使用できます
      for (int i = megMediArrayNode.size() - 1; i >= 0; i--) {
        ObjectNode mergeMediObjNode = (ObjectNode) megMediArrayNode.get(i);
        mergeMediObjNode.put("no", lpmNo);
        lpmNo--;
      }
      // 元の番号は変更しない、投与薬剤情報整合合わせ
      return rstMediArrayNode.addAll(megMediArrayNode);
    }
    return rstMediJsonNode;
  }

  /**
   * 医材の同一番号は加算する必要があります
   *
   * @param baseEquipInfo 医材情報
   * @return  マージ後の医材情報
   */
  private JsonNode equipmentReintegration(String baseEquipInfo) throws JsonProcessingException {
    baseEquipInfo = StringUtils.isNotEmpty(baseEquipInfo) ? baseEquipInfo : JSON_ARRAY_EMPTY;

    JsonNode rstEquipJsonNode = objectMapper.readTree(baseEquipInfo);

    if (rstEquipJsonNode.isArray()) {
      ArrayNode rstEquipArrayNode = (ArrayNode) rstEquipJsonNode;

      // 医材cdとtypeに基づいてその数を集計する
      Map<String, ObjectNode> mergeDataMap = new LinkedHashMap<>();
      rstEquipArrayNode.forEach(
        equipNode -> {
          // 同じ医材cdとtypeを区別する
          String key = equipNode.get("cd").asText() + "_" + equipNode.get("equip_type").asText();
          if (mergeDataMap.containsKey(key)) {
            mergeDataMap.get(key).put("amount"
              // amountを文字列に変更する
              , String.valueOf(mergeDataMap.get(key).get("amount").asInt() + equipNode.get("amount").asInt()));
          } else {
            mergeDataMap.put(key, (ObjectNode) equipNode);
          }
        }
      );

      // マージ後の結果を新しいArrayNodeに組み込み
      ArrayNode result = objectMapper.createArrayNode();
      mergeDataMap.forEach((key, value) -> result.add(value));

      return result;
    }

    return rstEquipJsonNode;
  }

  /**
   * 回診記録整合、指示コメントに転記
   *
   * @param rstRoundInfo  回診記録文字列
   * @param rstIndComment  指示コメント
   * @return  整合後の回診記録
   */
  private JsonNode roundInfoReintegration(String rstRoundInfo
    , String rstIndComment) throws JsonProcessingException {

    rstRoundInfo = StringUtils.isNotEmpty(rstRoundInfo) ? rstRoundInfo : JSON_OBJECT_EMPTY;

    JsonNode rstRoundInfoJsonNode = objectMapper.readTree(rstRoundInfo);
    if (StringUtils.isEmpty(rstIndComment)) return rstRoundInfoJsonNode;

    JsonNode rstIndCommentJsonNode = objectMapper.readTree(rstIndComment);

    // TODO Why not to use jsonPath to deal with this problem? May achieve an excellent effect.

    boolean foundPostIndComment = false;
    // 回診記録は指示コメントに転記の場合、指示コメントに該当番号を探して
    if (rstRoundInfoJsonNode.hasNonNull("is_ind_comment_post")
      && rstRoundInfoJsonNode.hasNonNull("ind_comment_no")
      && StringUtils.equals(AdminWebConstant.FlagType.FLAG_ON, rstRoundInfoJsonNode.get("is_ind_comment_post").asText())) {

      Integer indCommentNo = rstRoundInfoJsonNode.get("ind_comment_no").asInt();
      String content = rstRoundInfoJsonNode.get("content").asText();

      if (rstIndCommentJsonNode.isNull() && rstIndCommentJsonNode.isArray()) {
        for (JsonNode indCommentNode : rstIndCommentJsonNode) {

          if (
            indCommentNo.compareTo(indCommentNode.get("no").asInt()) == 0
              && StringUtils.equals(content, indCommentNode.get("content").asText())
          ) {
            foundPostIndComment = true;
            break;
          }
        }
      }
    }

    ObjectNode rstRoundInfoObjNode = (ObjectNode) rstRoundInfoJsonNode;
    // マージ後の実績回診記録の転記区分は「当日のみ」を固定設定する
//    rstRoundInfoObjNode.put("posting_class", TODAY_ONLY);
    // マージ後の実績指示コメント情報に該当番号見つかりません、reset指示コメントに転記表示と指示コメント番号
    if (!foundPostIndComment) {
      rstRoundInfoObjNode.put("is_ind_comment_post", AdminWebConstant.FlagType.FLAG_OFF);
//      rstRoundInfoObjNode.putNull("ind_comment_no");
    }

    return rstRoundInfoJsonNode;
  }
}
