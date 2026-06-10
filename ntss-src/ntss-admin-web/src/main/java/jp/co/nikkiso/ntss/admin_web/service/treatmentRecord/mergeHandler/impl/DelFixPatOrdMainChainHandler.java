package jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.mergeHandler.impl;

import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.TreatmentRecordDeleteService;
import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.mergeHandler.TreatmentRecordMergeChainHandler;
import jp.co.nikkiso.ntss.core.utils.AppContextUtils;

/**
 * マージ後消去マージデータ
 *
 * @author Tao.zhou
 * @since 2024-04-09
 */
public class DelFixPatOrdMainChainHandler extends TreatmentRecordMergeChainHandler {

  private final boolean delFlag;

  private final TreatmentRecordDeleteService treatmentRecordDeleteService;

  public DelFixPatOrdMainChainHandler(boolean delFlag) {
    this.delFlag = delFlag;
    this.treatmentRecordDeleteService = AppContextUtils.getBean(TreatmentRecordDeleteService.class);
  }

  /** マージ後消去マージデータ -> 治療実績削除 + 治療予定の中止処理 */
  @Override
  public void execute() {

    if (delFlag) {
      this.treatmentRecordDeleteService
        .deleteTreatmentRecordByOrdNo(mergeOrdMainData.getOrdNo(), mergeOrdMainData.getFacilityCd());
    }

    // 現在、後続の処理があるかどうかを判断し、処理があれば後続の処理を行う。
    if (getSuccessor() != null) {
      getSuccessor().execute();
    }
  }
}
