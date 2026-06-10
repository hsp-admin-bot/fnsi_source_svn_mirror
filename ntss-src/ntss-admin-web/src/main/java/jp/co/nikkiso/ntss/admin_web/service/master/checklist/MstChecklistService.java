package jp.co.nikkiso.ntss.admin_web.service.master.checklist;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.core.entity.MstChecklist;
import jp.co.nikkiso.ntss.core.entity.custom.MstEquipmentClassForChecklist;

public interface MstChecklistService {

  List<MstChecklist> mstChecklistSelectByFacility(String facilityCd);
  /**
   * 施設コードから医療材料分類マスタの一覧を取得する
   * @param facilityCd
   * @return
   */
  List<MstEquipmentClassForChecklist> getMstEquipClassList(String facilityCd);


  int mstChecklistInsert(MstChecklist param);
  // mod #8344 【デグレ】チェックリストマスタの保存までが長い dou start
  // int mstChecklistUpdate(MstChecklist param);
  int mstChecklistUpdate(Map<String, Object> param);
  // mod #8344 【デグレ】チェックリストマスタの保存までが長い dou end

}
