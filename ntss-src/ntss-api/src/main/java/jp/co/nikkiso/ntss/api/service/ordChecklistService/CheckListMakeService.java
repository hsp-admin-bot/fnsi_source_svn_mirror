package jp.co.nikkiso.ntss.api.service.ordChecklistService;

import java.io.IOException;
import java.util.List;


import jp.co.nikkiso.ntss.core.entity.OrdChecklist;
import com.fasterxml.jackson.databind.JsonNode;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForCheckListSchedule;

public interface CheckListMakeService {

  /**
   * 登録用チェックリストデータを作成
   * @param ordMain
   * @param mstChecklist
   * @param checklistCd
   * @param hasDummyData
   * @return
   */
  List<OrdChecklist> getRegisterChecklistRst(OrdMainForCheckListSchedule ordMain,
                                             JsonNode mstChecklist,
                                             Long checklistCd,
                                             boolean hasDummyData) throws IOException;

  /**
   * marge OrdCheckList left
   *
   * @param ordChecklistListOfMarge
   * @param ordChecklistListForMarge
   * @return
   */
  void margeOrdCheckListInsCheckLeft(List<OrdChecklist> ordChecklistListOfMarge, List<OrdChecklist> ordChecklistListForMarge);

}
