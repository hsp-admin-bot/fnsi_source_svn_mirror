package jp.co.nikkiso.ntss.core.service.ordMaterialSaveService;

import tools.jackson.core.JacksonException;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import tools.jackson.databind.node.ArrayNode;
import jp.co.nikkiso.ntss.core.dao.OrdMaterialSaveDao;
import jp.co.nikkiso.ntss.core.dao.OrdPrescriptionDao;
import jp.co.nikkiso.ntss.core.dto.ordMaterialSave.OrdMaterialSaveCommon;
import jp.co.nikkiso.ntss.core.dto.ordMaterialSave.OrdMaterialSaveDto;
import jp.co.nikkiso.ntss.core.entity.MstMedicine;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.OrdMaterialSave;
import jp.co.nikkiso.ntss.core.entity.OrdPrescription;
import jp.co.nikkiso.ntss.core.entity.custom.EquipCodeAndType;
import jp.co.nikkiso.ntss.core.utils.BeanBuilderUtils;
import jp.co.nikkiso.ntss.core.utils.MaterialSaveCacheHandler;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.CollectionUtils;

import java.sql.Timestamp;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.StringJoiner;
import java.util.stream.Collectors;

/**
 * 計算材料保持サービス
 */
@Service
public class OrdMaterialSaveServiceImpl implements OrdMaterialSaveService {
  // mod #9845 愁訴処置に入力した薬剤がord_material_saveに登録されない start

  private static final int BATCH_INSERT_MAX_LIMIT_NUM = 1000;
  private final OrdMaterialSaveDao ordMaterialSaveDao;
  private final OrdPrescriptionDao ordPrescriptionDao;
  private final ObjectMapper objectMapper;
  // del #11905  器材準備リスト"の内容が正しく抽出されない場合がある by shiyw 20250528 start
//  private final Map<Integer, MstEquipment> mstEquipmentIncludeDelMap = new ConcurrentHashMap<>();
//  private final Map<Integer, MstMedicineMix> mstMedicineMixIncludeDelMap = new ConcurrentHashMap<>();
//  private final Map<Integer, MstMedicine> mstMedicineIncludeDelMap = new ConcurrentHashMap<>();
//  private final Map<Integer, MstDialyzer> mstDialyzerMap = new ConcurrentHashMap<>();
// del #11905  器材準備リスト"の内容が正しく抽出されない場合がある by shiyw 20250528 end

  /**
   * Autowired Constructor
   *
   * @param ordMaterialSaveDao 計算材料保持テーブルクラスDao
//   * @param mstMedicineDao     薬剤クラスDao
//   * @param ordMainDao         透析情報クラスDao
//   * @param mstMedicineMixDao  調製薬剤マスタクラスDao
   * @param objectMapper       jackson ObjectMapper
   */
  @Autowired
  public OrdMaterialSaveServiceImpl(OrdMaterialSaveDao ordMaterialSaveDao
    , OrdPrescriptionDao ordPrescriptionDao, ObjectMapper objectMapper) {
    this.ordMaterialSaveDao = ordMaterialSaveDao;
    this.ordPrescriptionDao = ordPrescriptionDao;
    this.objectMapper = objectMapper;
  }

  // add #12250 ord_material_saveの処理を2回重複実行している zkm start
  /**
   * 計算材料保持の新規追加共通(サンポールオーダ番号の治療条件、投薬、医材からord_material_save新規追加)
   * (展開対象：オーダ番号リスト)
   *
   * @param ordNoTemp サンポールオーダ番号
   * @param ordNoList オーダ番号リスト
   */
  @Override
  public void bulkCreateByOrdNoInCondMediEquip(Long ordNoTemp, List<Long> ordNoList) {
    if (!CollectionUtils.isEmpty(ordNoList)) {
      ordMaterialSaveDao.bulkCreateByOrdNoInCondMediEquip(ordNoTemp, ordNoList);
    }
  }

  /**
   * 計算材料保持の更新共通(ord_mainの治療条件、投薬、医材からord_material_save更新)
   *
   * @param ordNoList オーダ番号
   */
  @Override
  public void bulkUpdateByOrdNoInCondMediEquip(List<Long> ordNoList) {
    if (!CollectionUtils.isEmpty(ordNoList)) {
      ordMaterialSaveDao.bulkUpdateByOrdNoInCondMediEquip(ordNoList);
    }
  }

  /**
   * 計算材料保持の更新共通(ord_mainの治療条件からord_material_save更新)
   *
   * @param ordNoList オーダ番号
   */
  @Override
  public void bulkUpdateByOrdNoInCond(List<Long> ordNoList) {
    if (!CollectionUtils.isEmpty(ordNoList)) {
      ordMaterialSaveDao.bulkUpdateByOrdNoInCond(ordNoList);
    }
  }

  /**
   * 計算材料保持の更新共通(ord_mainの投薬からord_material_save更新)
   *
   * @param ordNoList オーダ番号
   */
  @Override
  public void bulkUpdateByOrdNoInMedi(List<Long> ordNoList) {
    if (!CollectionUtils.isEmpty(ordNoList)) {
      ordMaterialSaveDao.bulkUpdateByOrdNoInMedi(ordNoList);
    }
  }

  /**
   * 計算材料保持の更新共通(ord_mainの医材からord_material_save更新)
   *
   * @param ordNoList オーダ番号
   */
  @Override
  public void bulkUpdateByOrdNoInEquip(List<Long> ordNoList) {
    if (!CollectionUtils.isEmpty(ordNoList)) {
      ordMaterialSaveDao.bulkUpdateByOrdNoInEquip(ordNoList);
    }
  }
  /**
   * 計算材料保持の更新共通(ord_mainの愁訴処置からord_material_save更新)
   *
   * @param ordNo オーダ番号
   */
  @Override
  public void bulkUpdateByOrdNoInTreatment(Long ordNo) {
    ordMaterialSaveDao.bulkUpdateByOrdNoInTreatment(ordNo);
  }
  /**
   * 計算材料保持の更新共通(ord_mainの愁訴処置からord_material_save更新)
   *
   * @param ordNoList オーダ番号
   */
  @Override
  public void bulkUpdateByOrdNoInCondMediEquipTreatment(List<Long> ordNoList) {
    if (!CollectionUtils.isEmpty(ordNoList)) {
      ordMaterialSaveDao.bulkUpdateByOrdNoInCondMediEquipTreatment(ordNoList);
    }
  }
  // add #12250 ord_material_saveの処理を2回重複実行している zkm end

  /**
   * add no.396 処方箋を削除する 張岩
   *
   * @param ordPrescriptionNo
   * @return
   */
  @Override
  public void deleteOrdMaterialSave(Long ordPrescriptionNo) {
    ordMaterialSaveDao.deleteOrdMaterialSaveBySuppliesBaseNo(ordPrescriptionNo);
  }

  /**
   * 計算材料情報を取得
   *
   * @param facilityCd
   * @param patId
   * @param suppliesBaseDateBegin
   * @param suppliesBaseDateEnd
   * @return
   */
  @Override
  public List<OrdMaterialSave> getOrdMaterialSave(String facilityCd, Long patId, String suppliesBaseDateBegin, String suppliesBaseDateEnd) {
    return ordMaterialSaveDao.getOrdMaterialSave(facilityCd, patId, suppliesBaseDateBegin, suppliesBaseDateEnd);
  }

  @Override
  public int updateIsConfirm(Long ordNo, Long patId) {
    return this.ordMaterialSaveDao.updateIsConfirm(ordNo, patId);
  }

  @Override
  public int insertBatch(List<OrdMaterialSave> ordMaterialSaveList) {
    int successCount = 0;
    int loopCount = ordMaterialSaveList.size() / BATCH_INSERT_MAX_LIMIT_NUM;
    for (int i = 0; i <= loopCount; i++) {
      List<OrdMaterialSave> saveList;
      if (i == loopCount) {
        saveList = ordMaterialSaveList
          .subList(i * BATCH_INSERT_MAX_LIMIT_NUM
            , ordMaterialSaveList.size());
      } else {
        saveList = ordMaterialSaveList
          .subList(i * BATCH_INSERT_MAX_LIMIT_NUM
            , (i + 1) * BATCH_INSERT_MAX_LIMIT_NUM);
      }
      if (!saveList.isEmpty()) {
        successCount += ordMaterialSaveDao.insertBatch(saveList);
      }
    }
    return successCount;
  }

  /**
   * Batch deletion based on conditions
   *
   * @param facilityCd  施設コード
   * @param patId       患者ID
   * @param suppliesBaseNos データ基準番号
   * @param suppliesSourceClass データ発生元区分
   * @param indRstClassList 指示・実績区分
   * @param editEquipCodeList 医療材料コード & タープ
   * @return the deletion result
   */
  public int deleteBatchByCondition(String facilityCd,
                                    String patId,
                                    List<Long> suppliesBaseNos,
                                    String suppliesSourceClass,
                                    List<String> indRstClassList,
                                    List<EquipCodeAndType> editEquipCodeList) {
    return this.ordMaterialSaveDao.deleteBatchByCondition(facilityCd
      , patId
      , suppliesBaseNos
      , suppliesSourceClass
      , indRstClassList
      , editEquipCodeList
    );
  }

  /**
   *
   */
  public int getBatchModifiedMode(
    boolean treatCondition,
    boolean medicament,
    boolean equipment,
    boolean complaint,
    String rstClass
  ) {
    return (treatCondition ? 1 : 0)
      | (medicament ? 1 << 1 : 0)
      | (equipment ? 1 << 2 : 0)
      | (complaint ? 1 << 3 : 0)
      | (StringUtils.equals(OrdMaterialSaveDto.RST_CLASS, rstClass) ? 1 << 4 : 0);
  }

  /* ================== 2024/06/11 処方情報対応追加 START ================== */
  /**
   * Batch updates Rp
   *
   * @param ordRpCds Rp codes
   * @return  updated status
   */
  @Override
  @Transactional
  public int savePrescriptionOrdMaterialSaveByPks(List<Long> ordRpCds) {
    if (!CollectionUtils.isEmpty(ordRpCds)) {

      List<OrdPrescription> ordRps = ordPrescriptionDao.selectOrdRpByPks(ordRpCds);

      return this.savePrescriptionOrdMaterialSave(ordRps);
    }

    return 0;
  }

  // add #12462 患者情報共有->患者経過総合ビューア fang start
  /**
   *  計算材料情報を取得
   * @param facilityCd
   * @param patId
   * @param suppliesBaseDateBegin
   * @param suppliesBaseDateEnd
   * @return
   */
  @Override
  public List<OrdMaterialSaveCommon> getOrdMaterialSaveForCommon(String facilityCd, Long patId, String suppliesBaseDateBegin, String suppliesBaseDateEnd) {
    return ordMaterialSaveDao.getOrdMaterialSaveForCommon(facilityCd, patId, suppliesBaseDateBegin, suppliesBaseDateEnd);
  }
  // add #12462 患者情報共有->患者経過総合ビューア fang end

  /**
   * 処方情報計算材料保持
   *
   * @param prescriptionList  処方情報
   * @return  更新件数
   */
  @Override
  public int savePrescriptionOrdMaterialSave(List<OrdPrescription> prescriptionList) {
    int result = 0;

    if (!CollectionUtils.isEmpty(prescriptionList)) {

      Instant now = Instant.now();
      // init result
      List<OrdMaterialSave> materialSaveList = new ArrayList<>();

      try {
        for (OrdPrescription prescriptionInfo : prescriptionList) {
          // IssueDate needs fix.
          if (StringUtils.isNotEmpty(prescriptionInfo.getIssueDate())
            && prescriptionInfo.getIssueDate().matches("\\d{4}/[0-1]\\d/[0-3]\\d"))
            prescriptionInfo.setIssueDate(StringUtils.remove(prescriptionInfo.getIssueDate(), "/"));


          // read the prescription JSON
          JsonNode prescriptionDetailNode = this.objectMapper.readTree(prescriptionInfo.getPrescriptionDetail());

          if (!prescriptionDetailNode.isNull() && !prescriptionDetailNode.isEmpty()) {
            // Base Entity
            OrdMaterialSave baseElement = BeanBuilderUtils
              .of(OrdMaterialSave::new)
              .with(OrdMaterialSave::setFacilityCd, prescriptionInfo.getFacilityCd())             // 施設コード
              .with(OrdMaterialSave::setPatId, prescriptionInfo.getPatId())                       // 患者ID
              .with(OrdMaterialSave::setSuppliesBaseDate, prescriptionInfo.getIssueDate())        // データ基準日
              .with(OrdMaterialSave::setSuppliesBaseNo, prescriptionInfo.getOrdPrescriptionNo())  // データ基準番号
              .with(OrdMaterialSave::setSuppliesSourceClass, "4")                             // データ発生元区分
              .with(OrdMaterialSave::setIndRstClass, StringUtils.equals("0", prescriptionInfo.getIssueState()) ? "3" : "4") // 指示・実績区分
              .with(OrdMaterialSave::setIsConfirm, prescriptionInfo.getIssueState())              // 確定フラグ
              .with(OrdMaterialSave::setRegDate, Timestamp.from(now))
              .with(OrdMaterialSave::setUpDate, Timestamp.from(now))
              .build();

            if (prescriptionDetailNode.isArray() && prescriptionDetailNode.size() > 0) {
              // transform arrayNode to arrayList, for grouping the list later.
              ArrayNode rpNodes = (ArrayNode) prescriptionDetailNode;
              List<JsonNode> prescriptionJsonList = new ArrayList<>(rpNodes.size());
              rpNodes.forEach(prescriptionJsonList::add);

              // Grouping Rp List
              Map<String, List<JsonNode>> rpContainer = prescriptionJsonList
                .stream()
                .collect(Collectors.groupingBy(
                  // record extend JsonNode, and we believed column 'Rp' existed all the time.
                  record -> record.get("Rp").asText()
                  , Collectors.toList()
                ));

              // Container Loop Start
              for (Map.Entry<String, List<JsonNode>> rpEntity : rpContainer.entrySet()) {
                // 最終行除外
                if (StringUtils.isNotEmpty(rpEntity.getKey()) && !CollectionUtils.isEmpty(rpEntity.getValue())) {

                  // build elements
                  materialSaveList.addAll(
                    this.buildPrescriptionMaterial(baseElement, rpEntity.getKey(), rpEntity.getValue() )
                  );

                }
              } // Container Loop End

              // baseElement = null;
              // prescriptionDetailNode = null;
            }

          }

        } // END prescriptionList List

      } catch (JacksonException e) {
        // TODO Please write some log
        throw new RuntimeException(e);
      }

      if (!CollectionUtils.isEmpty(materialSaveList)) {
        // delete first & insert new record later -> there's no needs to update original records
        this.ordMaterialSaveDao
          .deleteOrdMaterialSave(prescriptionList.stream().map(OrdPrescription::getOrdPrescriptionNo).toList());
        result = this.insertBatch(materialSaveList);
      }

    }
    return result;
  }

  /**
   * 処方情報交付状態更新
   *
   * @param ordPrescriptionNos  処方オーダー番号
   * @param facilityCd  施設コード
   * @return  更新状況
   */
  @Override
  public int updatePrescriptionIssueState(List<Long> ordPrescriptionNos, String facilityCd) {

    return ordMaterialSaveDao.updatePrescriptionIssueState(ordPrescriptionNos, facilityCd);
  }

  private List<OrdMaterialSave> buildPrescriptionMaterial(OrdMaterialSave baseMaterialSave
    , String rpCode, List<JsonNode> rpDetailNodes) {
    List<OrdMaterialSave> resultList = new ArrayList<>();

    if (!CollectionUtils.isEmpty(rpDetailNodes)) {

      // 薬剤ノード有りませんの場合、return
      if (rpDetailNodes.stream().noneMatch(r ->
        r.hasNonNull("type")
          && ("1".equals(r.get("type").asText()))
      )) return resultList;

      // 処方調剤単位
      String frequencyFlg = null;
      // 処方調剤量
      String frequencyNum = null;

      // 使用法ノードは共通であるため、最初に取得した使用法ノード
      Optional<JsonNode> firstUsage = rpDetailNodes
        .stream()
        .filter(r ->
          r.hasNonNull("type")
            // 2:内服 3:外用 4:頓服内服 5:頓服外用
            && (List.of("2", "3", "4", "5").contains(r.get("type").asText()))
        )
        .findFirst();

      if (firstUsage.isPresent()) {
        JsonNode firstUsageNode = firstUsage.get();
        String orgFreFlg = firstUsageNode.hasNonNull("F6") ? firstUsageNode.get("F6").asText() : null;
        frequencyNum = firstUsageNode.hasNonNull("F5") ? firstUsageNode.get("F5").asText() : null;

        if (orgFreFlg != null) {
          switch (orgFreFlg) {
            case "日分" -> frequencyFlg = "0";
            case "回分" -> frequencyFlg = "1";
            default -> {}
          }
        }
      }

      // find medic nodes
      List<JsonNode> medicInfoNodes = rpDetailNodes
        .stream()
        .filter(r ->
          r.hasNonNull("type")
            && ("1".equals(r.get("type").asText()))
        )
        .toList();

      if (!CollectionUtils.isEmpty(medicInfoNodes)) {

        for (int idx = 1; idx <= medicInfoNodes.size(); idx++) {

          JsonNode medicInfoNode = medicInfoNodes.get(idx - 1);
          // copy this base entity
          OrdMaterialSave opMs = OrdMaterialSave.deepCopy(baseMaterialSave);

          String medicineCd = medicInfoNode.hasNonNull("medicine_cd")
            ? medicInfoNode.get("medicine_cd").asText() : null;
          String medicineType = medicInfoNode.hasNonNull("medicine_type")
            ? medicInfoNode.get("medicine_type").asText() : null;

          // Empty medic Rp can be saved, so charge effects Rp form here
          if (StringUtils.isEmpty(medicineCd)
            || StringUtils.isEmpty(medicineType) ) continue;

          String classCd = null;
          // 薬剤マスタ
          if (StringUtils.isNotEmpty(medicineCd)
            && "1".equals(medicineType)
            && medicineCd.matches("\\d+")) {
            MstMedicine medicine = this.getMstMedicineIncludeDelByCd(Integer.parseInt(medicineCd));
            if (medicine != null) classCd = String.valueOf(medicine.getClassCd());
          }
          // 一般名処方 or otherwise -> classCd set null

          // 物品区分
          opMs.setSuppliesClass("1".equals(medicineType) ? "23" : ("4".equals(medicineType) ? "24" : null));
          // 物品コード -> medicineCd
          opMs.setSuppliesCd(medicineCd);
          // 分類コード -> classCd
          opMs.setClassCd(classCd);
          // 薬剤識別番号
          StringJoiner medicNoJoiner = new StringJoiner(",", "{", "}");
          opMs.setMedicineNo(
            medicNoJoiner
              .add("\"Rp\" : " + rpCode)
              .add("\"no\" : " + idx)
              .toString()
          );
          // 指示・実績値
          opMs.setIndRstValue(medicInfoNode.hasNonNull("F5") ? medicInfoNode.get("F5").asText() : null);
          // 処方薬剤単位
          opMs.setPrescriptionUnit(medicInfoNode.hasNonNull("F6") ? medicInfoNode.get("F6").asText() : null);
          // 処方調剤単位
          opMs.setFrequencyFlg(frequencyFlg);
          // 処方調剤量
          opMs.setFrequencyNum(frequencyNum);

          resultList.add(opMs);
        }   // END loop Medicine Nodes
      }

    }

    return resultList;
  }

  /* ================== 2024/06/11 処方情報対応追加 END ================== */


  /* ================ Old version method start here ================ */
  /* I don't want to fix or remove those methods, cause of considering the possibility of dependency on hosting codes.*/
  // del #11905  器材準備リスト"の内容が正しく抽出されない場合がある by shiyw 20250528 start
//  private MstDialyzer getDialyzerByCd(Integer dialyzerCd) {
//    MstDialyzerDao dialyzerDao = AppContextUtils.getBean(MstDialyzerDao.class);
//    if (!mstDialyzerMap.containsKey(dialyzerCd)) {
//      MstDialyzer dialyzerParams = new MstDialyzer();
//      dialyzerParams.setDialyzerCd(dialyzerCd);
//      List<MstDialyzer> mstDialyzer = dialyzerDao.selectIncludeDeleted(SelectOptions.get(), dialyzerParams);
//      if (!CollectionUtils.isEmpty(mstDialyzer)) {
//        mstDialyzerMap.put(mstDialyzer.get(0).getDialyzerCd(), mstDialyzer.get(0));
//      } else {
//        return null;
//      }
//    }
//    return mstDialyzerMap.get(dialyzerCd);
//  }
  // del #11905  器材準備リスト"の内容が正しく抽出されない場合がある by shiyw 20250528 end

  private MstMedicine getMstMedicineIncludeDelByCd(Integer medicineCd){
    // mod #11905  器材準備リスト"の内容が正しく抽出されない場合がある by shiyw 20250528 start
    return MaterialSaveCacheHandler.get().getMstMedicineIncludeDelByCd(medicineCd);
//    MstMedicineDao mstMedicineDao = AppContextUtils.getBean(MstMedicineDao.class);
//    if(!mstMedicineIncludeDelMap.containsKey(medicineCd)){
//      MstMedicine obj = mstMedicineDao.selectIncludeDelByMediCd(medicineCd);
//      if (obj != null) {
//        mstMedicineIncludeDelMap.put(medicineCd,obj);
//      } else {
//        return null;
//      }
//    }
//    return mstMedicineIncludeDelMap.get(medicineCd);
    // mod #11905  器材準備リスト"の内容が正しく抽出されない場合がある by shiyw 20250528 end
  }

  // del #11905  器材準備リスト"の内容が正しく抽出されない場合がある by shiyw 20250528 start
//  private void cleanCache() {
//    if (!CollectionUtils.isEmpty(mstEquipmentIncludeDelMap)) mstEquipmentIncludeDelMap.clear();
//    if (!CollectionUtils.isEmpty(mstMedicineMixIncludeDelMap)) mstMedicineMixIncludeDelMap.clear();
//    if (!CollectionUtils.isEmpty(mstMedicineIncludeDelMap)) mstMedicineIncludeDelMap.clear();
//    if (!CollectionUtils.isEmpty(mstDialyzerMap)) mstDialyzerMap.clear();
//  }
  // del #11905  器材準備リスト"の内容が正しく抽出されない場合がある by shiyw 20250528 end

  /**
   * Batch update treatDate
   *
   * @param ordMainList conditions
   * @return updated cnt
   */
  public int updMaterialSaveBaseDateByOrdMain(List<OrdMain> ordMainList) {

    int result = 0;
    if (!CollectionUtils.isEmpty(ordMainList)) {

      // fill up conditions
      List<OrdMaterialSave> ordMaterialSaveList =
        ordMainList.stream().map(
          ordMain -> {
            OrdMaterialSave conditions = new OrdMaterialSave();
            conditions.setSuppliesBaseNo(ordMain.getOrdNo());
            conditions.setSuppliesBaseDate(ordMain.getTreatDate());
            return conditions;
          }
        ).toList();

      // Batch update
      final int updateLimitSize = BATCH_INSERT_MAX_LIMIT_NUM / 4;
      int loopCount = ordMaterialSaveList.size() / updateLimitSize;
      for (int i = 0; i <= loopCount; i++) {
        List<OrdMaterialSave> saveList;
        if (i == loopCount) {
          saveList = ordMaterialSaveList
            .subList(i * updateLimitSize
              , ordMaterialSaveList.size());
        } else {
          saveList = ordMaterialSaveList
            .subList(i * updateLimitSize
              , (i + 1) * updateLimitSize);
        }
        if (!saveList.isEmpty()) {
          result += ordMaterialSaveDao.updateOrdMaterialSave(saveList);
        }
      }
    }

    return result;
  }


  public int deleteMaterialSaveByBaseNo(Long baseNo) {
    return ordMaterialSaveDao.deleteOrdMaterialSaveBySuppliesBaseNo(baseNo);
  }

}
