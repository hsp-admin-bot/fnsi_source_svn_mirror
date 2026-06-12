package jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.mergeHandler.impl;

import tools.jackson.databind.JsonNode;
import jp.co.nikkiso.ntss.admin_web.service.checkList.CheckListService;
import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.mergeHandler.TreatmentRecordMergeChainHandler;
import jp.co.nikkiso.ntss.admin_web.service.utils.ApplicationContextUtil;
import jp.co.nikkiso.ntss.api.service.ordChecklistService.CheckListMakeService;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.entity.OrdChecklist;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForCheckListSchedule;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import org.apache.commons.lang3.StringUtils;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Checklistの新規生成Handler
 *
 * @author Tao.zhou
 * @since 2024-04-08
 */
public class UpdateOrdChecklistChainHandler extends TreatmentRecordMergeChainHandler {

  private final CheckListService checkListService;

  private final OrdMainDao ordMainDao;

  /** 画面にマージデータ「削除する」を選べ */
  protected final boolean delFlag;

  private final boolean ordClMergeFlag;

  // add #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 start
  private final CheckListMakeService checkListMakeService;
  // add #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 end

  /** Checklistの新規生成Handler */
  public UpdateOrdChecklistChainHandler(boolean delFlag, boolean ordClMergeFlag) {
    this.delFlag = delFlag;
    this.ordClMergeFlag = ordClMergeFlag;

    this.ordMainDao = ApplicationContextUtil.getBean(OrdMainDao.class);
    this.checkListService = ApplicationContextUtil.getBean(CheckListService.class);
    // add #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 start
    this.checkListMakeService = ApplicationContextUtil.getBean(CheckListMakeService.class);
    // add #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 end
  }

  @Override
  public void execute() {
    /* Copy form the issue #9324 Start */
    try {
      // 取得？？？患者のord_checklistデータ
      List<OrdChecklist> checklistsQuestion = checkListService.getOrdCheckListByOrdNO(mergeOrdMainData.getOrdNo());
      // mergeされた患者のord_mainに対応するord_checklistデータを取得する
      List<OrdChecklist> checklistsMargeOld = checkListService.getOrdCheckListByOrdNO(baseOrdMainData.getOrdNo());

      // add 10592 実績マージのチェックリスト部分でフリーワードマージ出てきていない gjn srart
      List<OrdChecklist> checklistsMargeList = new ArrayList<>();
      if (ordClMergeFlag) { // 実績マージのチェックリストチェックしました
        checklistsMargeList.addAll(checklistsQuestion);
      } else { // 実績マージのチェックリストチェックされていません
        checklistsMargeList.addAll(checklistsMargeOld);
      }
      // によって患者のchecklistsは、当時のmst_checklistのデータを逆生成し、JsonNodeフォーマットを作成して返す
      Map<String, JsonNode> jsonNodeMap = checkListService.makeMstChecklistByOrdChecklist(checklistsMargeList);
      // add 10592 実績マージのチェックリスト部分でフリーワードマージ出てきていない gjn end

      String checklistCd = jsonNodeMap.keySet().size() == 1 ? jsonNodeMap.keySet().iterator().next() : null;
      // マージ後の治療情報を取得する
      OrdMainForCheckListSchedule ordMains = ordMainDao.selectByOrdNoChecklist(baseOrdMainData.getOrdNo());
      // マージ後のord_mainデータと逆プッシュされたmst_checklistのデータに基づいて、共通を呼び出し、新しいord_checklistデータを生成する
      //mod 10963 チェックリストのデータ件数が0件の場合実績マージができない zhao start
//      List<OrdChecklist> newMakeList =
//        checkListService.getRegisterChecklistRst(
//          ordMains, jsonNodeMap.get(checklistCd)
//          , StringUtils.isNotEmpty(checklistCd) ? Long.parseLong(checklistCd) : null
//          , true);
      // mod #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 start
      List<OrdChecklist> newMakeList =
        checkListMakeService.getRegisterChecklistRst(
          ordMains, jsonNodeMap.get(checklistCd)
          , StringUtils.isNotEmpty(checklistCd) && canBeLong(checklistCd) ? Long.parseLong(checklistCd) : null
          , true);
      //mod 10963 チェックリストのデータ件数が0件の場合実績マージができない zhao end

      // マージ患者のord_checklistと新しく生成されたord_checklistにmargeされ、checklistsMargeOldがbaseとして
      checkListMakeService.margeOrdCheckListInsCheckLeft(checklistsMargeOld, newMakeList);
      // mod #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 end
      // また？？？患者はcheckされた状態margeがchecklistsMargeOldに与えた後のデータを持っている
      // 最新ord_checklistを設定する
      List<OrdChecklist> checklistsMargeAfter = checkListService.getOrdCheckListByOrdNO(baseOrdMainData.getOrdNo());
      checkListService.margeOrdCheckListInsCheckRight(checklistsQuestion, checklistsMargeAfter, this.delFlag);
    } catch (IOException ioException) {
      throw new NtssException("Checklistの新規生成時に異常が発生しました。", ioException);
    }
    /* Copy form the issue #9324 End */

    // 現在、後続の処理があるかどうかを判断し、処理があれば後続の処理を行う。
    if (getSuccessor() != null) {
      getSuccessor().execute();
    }
  }
  //add 10963 チェックリストのデータ件数が0件の場合実績マージができない zhao start
  public static boolean canBeLong(String str) {
    try {
      Long.parseLong(str);
      return true;
    } catch (NumberFormatException e) {
      return false;
    }
  }
  //add 10963 チェックリストのデータ件数が0件の場合実績マージができない zhao end
}
