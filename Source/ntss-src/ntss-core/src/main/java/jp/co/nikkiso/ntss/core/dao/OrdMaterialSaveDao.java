package jp.co.nikkiso.ntss.core.dao;
import jp.co.nikkiso.ntss.core.dto.ordMaterialSave.OrdMaterialSaveCommon;
import jp.co.nikkiso.ntss.core.entity.OrdMaterialSave;
import jp.co.nikkiso.ntss.core.entity.custom.EquipCodeAndType;
import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import java.util.List;

@ConfigAutowireable
@Dao
public interface OrdMaterialSaveDao {

  // add FNSI-No.396 使用物品の指示、レセ換算結果の保持に対応 李 start
  @Update(sqlFile = true)
  int updateOrdMaterialSave(List<OrdMaterialSave> updateOrdMaterialSaveList);

  @Delete(sqlFile = true)
  int deleteOrdMaterialSave(List<Long> conditions);
  // add FNSI-No.396 使用物品の指示、レセ換算結果の保持に対応 李 end

  // add FNSI-確定フラグを”1”に更新 徐 start
  @Update(sqlFile = true)
  int updateIsConfirm(Long ordNo,Long patId);
  // add FNSI-確定フラグを”1”に更新 徐 end

  // del 11613 by shiyw 20250307 start
//  /**
//   * add FNSI - No.396 条件送信破棄 is_confirm 1 -> 0 -- Sanjingye Sun 20210118
//   * @param suppliesBaseNo
//   * @return
//   */
//  @Update(sqlFile = true)
//  int updateOrdMaterialSaveIsConfirm0(Long suppliesBaseNo);
  // del 11613 by shiyw 20250307 end

  /**
   * add FNSI - No.396 治療記録 実績確定 -- Sanjingye 20210125
   * @param omsList
   * @return
   */
  @Insert(sqlFile = true)
  int insertBatch(List<OrdMaterialSave> omsList);

  /**
   * add no.396 処方箋アイテムの保存 張岩
   * @param conditions
   * @return`
   */
  @Insert(sqlFile = true)
  int insert(OrdMaterialSave conditions);
  /**
   * add no.396 処方箋アイテムの保存 張岩
   * @param conditions
   * @return
   */
  @Update(sqlFile = true)
  int update(OrdMaterialSave conditions);
  //mod FNSI修正治療記録外結バッグ76 房 start
  /**
   * add no.396 処方薬をチェックする 張岩
   *
   * @param suppliesBaseNo
   * @param facilityCd
   * @return
   */
  @Select
  //mod FNSI redmine 7150 劉祥霖 start
//  List<OrdMaterialSave> selectOrdMaterialSaveBySuppliesBaseNo(Long suppliesBaseNo);
  List<OrdMaterialSave> selectOrdMaterialSaveBySuppliesBaseNo(Long suppliesBaseNo, String facilityCd);
  //mod FNSI redmine 7150 劉祥霖 end
  //mod FNSI修正治療記録外結バッグ76 房 end
  /**
   * add no.396 処方箋を削除する 張岩
   * @param suppliesBaseNo
   * @return
   */
  @Update(sqlFile = true)
  int deleteOrdMaterialSaveBySuppliesBaseNo(Long suppliesBaseNo);
  // add FNSI-計算材料保持テーブルから長期グラフ表示データを取得「235」「236」「660」「661」 周 start
  /**
   * 計算材料情報を取得
   * @param facilityCd
   * @param patId
   * @param suppliesBaseDateBegin
   * @param suppliesBaseDateEnd
   * @return
   */
  @Select
  List<OrdMaterialSave> getOrdMaterialSave(String facilityCd,
                                           Long patId,
                                           String suppliesBaseDateBegin,
                                           String suppliesBaseDateEnd);
  // add FNSI-計算材料保持テーブルから長期グラフ表示データを取得「235」「236」「660」「661」 周 end

  //add FNSI修正治療記録外結バッグ76 房 start
  /**
   * 実績確認と版確定
   * param: ord_material_save_no 管理番号リスト
   * @return
   */
  @Delete(sqlFile = true)
  int deleteOrdMaterialSaveByOrdMaterialSaveNo(List<Long> ordNoList,List<String> suppliesClassList);

  //add FNSI修正治療記録外結バッグ76 房 end

  /**
   *
   *
   * @param ordNoList
   * @param facilityCd
   * @return
   */
  @Select
  List<OrdMaterialSave> selectOrdMaterialSaveBySBNos(List<Long> ordNoList, String facilityCd);

  @Delete(sqlFile = true)
  int deleteBatchByCondition(String facilityCd,
                             String patId,
                             List<Long> suppliesBaseNos,
                             String suppliesSourceClass,
                             List<String> indRstClassList,
                             List<EquipCodeAndType> editEquipCodeList);

  /* ================== 2024/06/11 処方情報対応追加 START ================== */
  /**
   * 処方情報交付状態更新
   *
   * @param ordPrescriptionNos
   * @param facilityCd
   * @return
   */
  @Update(sqlFile = true)
  int updatePrescriptionIssueState(List<Long> ordPrescriptionNos, String facilityCd);
  /* ================== 2024/06/11 処方情報対応追加 END ================== */

  // add 11613 by shiyw 20250303 start
  @Update(sqlFile = true)
  int updateEffectFlgByMedicineNo(Long suppliesBaseNo, List<String> medicineNoList,String effectFlg);
  // add 11613 by shiyw 20250303 end

  // add #12250 ord_material_saveの処理を2回重複実行している zkm start
  @Insert(sqlFile = true)
  int bulkUpdateByOrdNoInMedi(List<Long> ordNoList);
  @Insert(sqlFile = true)
  int bulkUpdateByOrdNoInCond(List<Long> ordNoList);
  @Insert(sqlFile = true)
  int bulkUpdateByOrdNoInEquip(List<Long> ordNoList);
  @Insert(sqlFile = true)
  int bulkUpdateByOrdNoInTreatment(Long ordNo);
  @Insert(sqlFile = true)
  int bulkCreateByOrdNoInCondMediEquip(Long ordNoTemp, List<Long> ordNoList);
  @Insert(sqlFile = true)
  int bulkUpdateByOrdNoInCondMediEquip(List<Long> ordNoList);
  @Insert(sqlFile = true)
  int bulkUpdateByOrdNoInCondMediEquipTreatment(List<Long> ordNoList);
  // add #12250 ord_material_saveの処理を2回重複実行している zkm end

  // add #12462 患者情報共有->患者経過総合ビューア fang start
  /**
   * 計算材料情報を取得
   * @param facilityCd
   * @param patId
   * @param suppliesBaseDateBegin
   * @param suppliesBaseDateEnd
   * @return
   */
  @Select
  List<OrdMaterialSaveCommon> getOrdMaterialSaveForCommon(String facilityCd,
                                                          Long patId,
                                                          String suppliesBaseDateBegin,
                                                          String suppliesBaseDateEnd);
  // add #12462 患者情報共有->患者経過総合ビューア fang end

}
