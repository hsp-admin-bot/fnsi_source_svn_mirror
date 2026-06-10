package jp.co.nikkiso.ntss.web_api.service;

import jp.co.nikkiso.ntss.web_api.request.JournalCreateRequestPayload;

import java.util.List;

/**
 * 検査依頼/放射線検査依頼 スケジュール更新処理のServiceインタフェース.
 */
public abstract interface ExamRequestScheduleExtendUtilService {
  /**
   * 期間内に当てはまる検査パターンを登録
   * @param patId 患者ID
   * @param facilityCd 施設コード
   * @param fromDt 期間開始日(yyyy-mm-dd形式)
   * @param toDt 期間終了日(yyyy-mm-dd形式)
   * @param defaultDoctor デフォルト医師
   */
  void createPatExamMain(Long patId, String facilityCd, String fromDt, String toDt, String defaultDoctor, List<JournalCreateRequestPayload> payloads) throws Exception;

  /**
   * 期間内に当てはまる放射線検査パターンを登録
   * @param patId 患者ID
   * @param facilityCd 施設コード
   * @param fromDt 期間開始日(yyyy-mm-dd形式)
   * @param toDt 期間終了日(yyyy-mm-dd形式)
   * @param defaultDoctor デフォルト医師
   */
  void createPatRadMain(Long patId, String facilityCd, String fromDt, String toDt, String defaultDoctor, List<JournalCreateRequestPayload> payloads) throws Exception;

}
