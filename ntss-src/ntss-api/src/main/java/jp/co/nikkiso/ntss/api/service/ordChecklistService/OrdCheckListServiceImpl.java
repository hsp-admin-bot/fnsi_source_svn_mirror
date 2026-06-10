package jp.co.nikkiso.ntss.api.service.ordChecklistService;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.core.dao.MstChecklistDao;
import jp.co.nikkiso.ntss.core.dao.OrdChecklistDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.entity.MstChecklist;
import jp.co.nikkiso.ntss.core.entity.OrdChecklist;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForCheckListSchedule;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.List;

@Service
public class OrdCheckListServiceImpl implements OrdCheckListService{

  @Autowired
  private OrdMainDao ordMainDao;

  @Autowired
  private OrdChecklistDao ordChecklistDao;

  @Autowired
  CheckListMakeService checkListMakeService;

  @Autowired
  private MstChecklistDao mstChecklistDao;

  /**
   * 患者経過総合ビューア用、チェックリスト実績同期処理「条件送信場合」
   *
   * @param insOrdNoList 更新対象番号「治療情報」
   */
  public void syncOrdChecklistForResult(List<Long> insOrdNoList) throws IOException {

    // 治療情報を取得
    List<OrdMainForCheckListSchedule> ordMainList = ordMainDao.selectByOrdNoListChecklist(insOrdNoList);
    if (ordMainList.size() == 0) {
      return;
    }
    // 最新のチェックリストマスタを取得
    List<MstChecklist> mstChecklist = mstChecklistDao.selectByFacilityCd(SelectOptions.get(), ordMainList.get(0).getFacilityCd(), "0");
    for (OrdMainForCheckListSchedule ordMain : ordMainList) {
      MstChecklist nowMstChecklist = mstChecklist.get(0);
      String strSetting = nowMstChecklist.getChecklistSettings();
      ObjectMapper map = new ObjectMapper();
      JsonNode node = map.readTree(strSetting);

      // 登録用チェックリストデータを作成
      List<OrdChecklist> regList = checkListMakeService.getRegisterChecklistRst(ordMain, node, (long) nowMstChecklist.getChecklistCd(), true);

      // チェックリスト実績情報を取得（治療情報別）
      List<OrdChecklist> ordCheckListJisseki = ordChecklistDao.selectByOrdNo(SelectOptions.get(), ordMain.getOrdNo());

      checkListMakeService.margeOrdCheckListInsCheckLeft(ordCheckListJisseki, regList);

    }
  }
}
