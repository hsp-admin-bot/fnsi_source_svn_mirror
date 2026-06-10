package jp.co.nikkiso.ntss.core.dao;

import java.sql.Timestamp;
import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.OrdChecklist;

@ConfigAutowireable
@Dao
public interface OrdChecklistDao {

  @Select
  List<OrdChecklist> selectAll(SelectOptions options);

  @Select
  List<OrdChecklist> selectByOrdNo(SelectOptions options, Long ordNo);

  @Select
  List<OrdChecklist> selectByOrdNoListCd(SelectOptions options, Long ordNo, Short listCd);

  // add FNSI-横展開 マスタ削除_チェックリスト機能分 周 start
  @Select
  List<OrdChecklist> selectByOrdNoListCdMasterExist(SelectOptions options, Long ordNo, Short listCd);
  // add FNSI-横展開 マスタ削除_チェックリスト機能分 周 end

  @Select
  OrdChecklist selectUpdateInfo(OrdChecklist param);

  //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
  @Select
  OrdChecklist selectUpdateInfoForFuncClass0(OrdChecklist param);
  //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

  @Insert
  int insert(OrdChecklist param);

  @Update
  int update(OrdChecklist param);

  // mod #8344 【デグレ】チェックリストマスタの保存までが長い dou start
////  add 8344【デグレ】チェックリストマスタの保存までが長い zhao start
//  @Update(sqlFile = true)
//  int updateDeleteByRstClassByFacilityCd(String facilityCd);
////  add 8344【デグレ】チェックリストマスタの保存までが長い zhao end
  @Select
  List<OrdChecklist> selectIsChecked(String facilityCd,  String listCd, String itemNumber);

  @Insert(sqlFile = true)
  int insertByList(List<OrdChecklist> list);

  @Delete(sqlFile = true)
  // mod #9539 チェックリストマスタの設定を変更して保存しても保存できない dengshen start
  // int deleteByCheckListCtlNoList(List<Long> checklistCtlNoList);
  int deleteByCheckListCtlNoList(String facilityCd,  String listCd, String itemNumber, List<Long> ordNoList);
  // mod #9539 チェックリストマスタの設定を変更して保存しても保存できない dengshen end
  // mod #8344 【デグレ】チェックリストマスタの保存までが長い dou end

  @Delete
  int delete(OrdChecklist param);

  @Update(sqlFile = true)
  int updateSendConditionByRstClass(Long ordNo);

  @Update(sqlFile = true)
  int updateClearOrdNo(Long ordNo, Timestamp upDate);

  // FNSI-add 対応401 孫灝 20201203
  @Delete(sqlFile = true)
  int deleteByOrdNo(long ordNo, String facilityCd);

  //upd by ztc 2023-03-02 [Optimize runtime No.6968] --start /
  @Delete(sqlFile = true)
  int deleteByOrdNoAndFacilityCdBatch(List<Long> delOrdNoList, String facilityCd);
  //upd by ztc 2023-03-02 [Optimize runtime No.6968] --end /

  //add 9324 治療情報を異なる状態で変更した後のord_checklistの再編成共通方法 gjn start
  @Update(sqlFile = true)
  int deleteChecklistByCtlNo(List<Long> checklistCtlNo);
  //add 9324 治療情報を異なる状態で変更した後のord_checklistの再編成共通方法 gjn end

  // add FNSI-改修内容追加ordChecklist処理 付 start
  @Update(sqlFile = true)
  int updateRstClass(Long ordNo);
  // add FNSI-改修内容追加ordChecklist処理 付 end

  // add チェックリストマスタ 指示変更、実績変更に伴うチェックリストの反映 孔 start
  @Delete(sqlFile = true)
  int deleteByOrdChecklist(OrdChecklist param);
  // add チェックリストマスタ 指示変更、実績変更に伴うチェックリストの反映 孔 end

  //add 9324 治療情報を異なる状態で変更した後のord_checklistの再編成共通方法 gjn start
  @Delete(sqlFile = true)
  int deleteByIsCheck(long ordNo, String facilityCd);
  //add 9324 治療情報を異なる状態で変更した後のord_checklistの再編成共通方法 gjn end

  //add FNSI改修401対応 房 start
  @Delete(sqlFile = true)
  int deleteByCheckListCtlNo(long checklistCtlNo);
  //add FNSI改修401対応 房 end

  // add FNSI-チェックリスト仕様変更対応#401、#439_患者経過総合ビューア機能分。 周 start
  @Update(sqlFile = true)
  int updateCheckState(long ordNo, String facilityCd, String originalCheck);
  // add FNSI-チェックリスト仕様変更対応#401、#439_患者経過総合ビューア機能分。 周 end

  //mod #9324 ???患者marge使用 gjn start
  @Update(sqlFile = true)
  int updateIscheckByOrdNo(String isCheck, String regStaffInfo, Timestamp occurDate, Timestamp regDate, Long ctlNo);
  //mod #9324 ???患者marge使用 gjn end


  @Update(sqlFile = true)
  int updateAmount(Long ctlNo, String amount);

  @Update(sqlFile = true)
  int updateOrdNo(Long ordNo, Long baseordNo, Timestamp upDate);

  @Delete(sqlFile = true)
  int deleteByOrdNoRstClass(Long ordNo);
  // add FNSI-？？？？患者割り当て 陳 end

  // add FNSI-障害票一覧_患者経過総合ビューアNo.29 李 start
  @Insert(sqlFile = true)
  int insertOrdChecklistByOrdNo(String latestOrdNo, String oldOrdNo);
  // add FNSI-障害票一覧_患者経過総合ビューアNo.29 李 end

  @Select
  List<OrdChecklist> selectByOrdNoListCdMasterExistAll(SelectOptions options, List<Long> ordNos);

  @Select
  List<OrdChecklist> selectByOrdNoListCdAll(SelectOptions options, List<Long> ordNos);

  // add 9664 by kangjie 20231208 start
  @Delete(sqlFile = true)
  int delOrdCheckListByOrdNos(List<Long> ordNos);
  // add 9664 by kangjie 20231208 end

  //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない。 関 start
  @Delete(sqlFile = true)
  int deleteByMedicineTypeAndCodeAndFuncClass(List<Integer> funcClassList, Long code, Integer medicineType, String facilityCd, List<Long> ordNos);

  @Delete(sqlFile = true)
  int deleteByEquipTypeAndCodeAndFuncClass(List<Integer> funcClassList, Long code, Integer equipType, String facilityCd, List<Long> ordNos);
  //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない。 関 end

  // add #12249 治療条件変更の高速化 zkm start
  @Select
  List<OrdChecklist> bulkUpdateByOrdNoList(String facilityCd, List<Long> ordNoList);
  // add #12249 治療条件変更の高速化 zkm end

}
