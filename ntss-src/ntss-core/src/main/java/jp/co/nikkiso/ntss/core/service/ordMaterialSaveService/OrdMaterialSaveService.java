package jp.co.nikkiso.ntss.core.service.ordMaterialSaveService;

import jp.co.nikkiso.ntss.core.dto.ordMaterialSave.OrdMaterialSaveCommon;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.OrdMaterialSave;
import jp.co.nikkiso.ntss.core.entity.OrdPrescription;
import jp.co.nikkiso.ntss.core.entity.custom.EquipCodeAndType;

import java.util.List;

public interface OrdMaterialSaveService {

  // add #12250 ord_material_saveの処理を2回重複実行している zkm start
  /**
   * 計算材料保持の新規追加共通(サンポールオーダ番号の治療条件、投薬、医材からord_material_save新規追加)
   * (展開対象：オーダ番号リスト)
   *
   * @param ordNoTemp サンポールオーダ番号
   * @param ordNoList オーダ番号リスト
   */
  void bulkCreateByOrdNoInCondMediEquip(Long ordNoTemp, List<Long> ordNoList);
  /**
   * 計算材料保持の更新共通(ord_mainの治療条件、投薬、医材からord_material_save更新)
   *
   * @param ordNoList オーダ番号
   */
  void bulkUpdateByOrdNoInCondMediEquip(List<Long> ordNoList);
  /**
   * 計算材料保持の更新共通(ord_mainの治療条件からord_material_save更新)
   *
   * @param ordNoList オーダ番号
   */
  void bulkUpdateByOrdNoInCond(List<Long> ordNoList);
  /**
   * 計算材料保持の更新共通(ord_mainの投薬からord_material_save更新)
   *
   * @param ordNoList オーダ番号
   */
  void bulkUpdateByOrdNoInMedi(List<Long> ordNoList);
  /**
   * 計算材料保持の更新共通(ord_mainの医材からord_material_save更新)
   *
   * @param ordNoList オーダ番号
   */
  void bulkUpdateByOrdNoInEquip(List<Long> ordNoList);
  /**
   * 計算材料保持の更新共通(ord_mainの愁訴処置からord_material_save更新)
   *
   * @param ordNo オーダ番号
   */
  void bulkUpdateByOrdNoInTreatment(Long ordNo);
  /**
   * 計算材料保持の更新共通(ord_main実績の治療条件、投薬、医材、愁訴処置からord_material_save更新)
   *
   * @param ordNoList オーダ番号
   */
  void bulkUpdateByOrdNoInCondMediEquipTreatment(List<Long> ordNoList);
  // add #12250 ord_material_saveの処理を2回重複実行している zkm end

  int updateIsConfirm(Long ordNo, Long patId);

  void deleteOrdMaterialSave(Long ordPrescriptionNo);

  // 計算材料情報を取得
  List<OrdMaterialSave> getOrdMaterialSave(String facilityCd, Long patId, String suppliesBaseDateBegin, String suppliesBaseDateEnd);

  int insertBatch(List<OrdMaterialSave> ordMaterialSaveList);

  int deleteBatchByCondition(String facilityCd,
                             String patId,
                             List<Long> suppliesBaseNos,
                             String suppliesSourceClass,
                             List<String> indRstClassList,
                             List<EquipCodeAndType> editEquipCodeList);

  /**
   * Batch update treatDate
   *
   * @param ordMainList conditions
   * @return updated cnt
   */
  int updMaterialSaveBaseDateByOrdMain(List<OrdMain> ordMainList);

  int deleteMaterialSaveByBaseNo(Long baseNo);

  /* ================== 2024/06/11 処方情報対応追加 START ================== */
  /**
   * 処方情報計算材料保持
   *
   * @param prescriptionList  処方情報
   * @return  更新件数
   */
  int savePrescriptionOrdMaterialSave(List<OrdPrescription> prescriptionList);

  /**
   * 処方情報交付状態更新
   *
   * @param ordPrescriptionNos  処方オーダー番号
   * @param facilityCd  施設コード
   * @return  更新状況
   */
  int updatePrescriptionIssueState(List<Long> ordPrescriptionNos, String facilityCd);

  /**
   * Batch updates Rp
   *
   * @param ordRpCds Rp codes
   * @return  updated status
   */
  int savePrescriptionOrdMaterialSaveByPks(List<Long> ordRpCds);
  /* ================== 2024/06/11 処方情報対応追加 END ================== */

  // add #12462 患者情報共有->患者経過総合ビューア fang start
  /**
   *  計算材料情報を取得
   * @param facilityCd
   * @param patId
   * @param suppliesBaseDateBegin
   * @param suppliesBaseDateEnd
   * @return
   */
  List<OrdMaterialSaveCommon> getOrdMaterialSaveForCommon(String facilityCd, Long patId, String suppliesBaseDateBegin, String suppliesBaseDateEnd);
  // add #12462 患者情報共有->患者経過総合ビューア fang end
}
