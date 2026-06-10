package jp.co.nikkiso.ntss.api.service.journal;

import jp.co.nikkiso.ntss.api.model.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.core.dto.OrdMain.JournalEventLinkByPat;
import jp.co.nikkiso.ntss.core.entity.OrdPrescription;

import java.util.List;
import java.util.Map;

public interface JournalCreatePayloadService {

  /**
   * @param facilityCd                                     施設コード
   * @param resultAllChangedDataInfoList                   変更後データ
   * @param resultAllChangeBeforeDataInfoList              変更前データ
   * @param patIdList                                      患者IDリスト
   * @param updId                                          更新者
   * @param actionMode
   * @return
   */
  public List<JournalCreateRequestPayload> createJournalPayload(String facilityCd,
                                                                Map<String, List<Object>> resultAllChangedDataInfoList,
                                                                Map<String, List<Object>> resultAllChangeBeforeDataInfoList,
                                                                List<Long> patIdList,
                                                                Long updId,
                                                                String actionMode);

  // add #10553 処方連携 piao start
  /**
   * @param facilityCd                                     施設コード
   * @param ordRps                                         変更後データ
//   * @param resultAllChangeBeforeDataInfoList              変更前データ
   * @param patIdList                                      患者IDリスト
   * @param updId                                          更新者
   * @param actionMode
   * @return
   */
  public List<JournalCreateRequestPayload> createJournalPayloadForOrdPrescription(String facilityCd,
                                                                                  List<OrdPrescription> ordRps,
                                                                                  List<OrdPrescription> ordRpsBeforeData,
                                                                                  List<Long> patIdList, Long updId, String actionMode);
  // add #10553 処方連携 piao end

  /**
   * @param map         戻り値
   * @param key         テーブル名
   * @param value
   */
  public void addToMapList(Map<String, List<Object>> map, String key, Object value);

  /**
   * @param journalEventLinkByPatListMap
   * @param updId
   * @param actionMode
   */
  public List<JournalCreateRequestPayload> createJournalPayloadForToBeEventTreatDate(Map<String, JournalEventLinkByPat> journalEventLinkByPatListMap, Long updId, String actionMode);

  /**
   * @param journalEventLinkByPatListMap
   * @param facilityCd
   * @param patId
   * @param hospPatId
   * @param treatDate
   */
  public void addToBeDEventTreatDate(Map<String, JournalEventLinkByPat> journalEventLinkByPatListMap,
                                     String facilityCd, Long patId, String hospPatId, String treatDate, Integer indKurCd);

  /**
   * @param journalEventLinkByPatListMap
   * @param facilityCd
   * @param patId
   * @param hospPatId
   * @param examMainCd
   */
  public void addToBeDEventExcludeExamKey(Map<String, JournalEventLinkByPat> journalEventLinkByPatListMap,
                                          String facilityCd, Long patId, String hospPatId, Long examMainCd);
  /**
   * @param journalEventLinkByPatListMap
   * @param facilityCd
   * @param patId
   * @param hospPatId
   * @param radResultCd
   */
  public void addToBeDEventExcludeRadKey(Map<String, JournalEventLinkByPat> journalEventLinkByPatListMap,
                                         String facilityCd, Long patId, String hospPatId, Long radResultCd);
  /**
   * @param journalEventLinkByPatListMap
   * @param facilityCd
   * @param patId
   * @param hospPatId
   * @param treatDate
   */
  public void addToBeCEventTreatDate(Map<String, JournalEventLinkByPat> journalEventLinkByPatListMap,
                                     String facilityCd, Long patId, String hospPatId, String treatDate, Integer indKurCd);

  /**
   * @param journalEventLinkByPatListMap
   * @param facilityCd
   * @param patId
   * @param hospPatId
   * @param examMainCd
   */
  public void addToBeCEventExcludeExamKey(Map<String, JournalEventLinkByPat> journalEventLinkByPatListMap,
                                          String facilityCd, Long patId, String hospPatId, Long examMainCd);

  /**
   * @param journalEventLinkByPatListMap
   * @param facilityCd
   * @param patId
   * @param hospPatId
   * @param radResultCd
   */
  public void addToBeCEventExcludeRadKey(Map<String, JournalEventLinkByPat> journalEventLinkByPatListMap,
                                         String facilityCd, Long patId, String hospPatId, Long radResultCd);
  /**
   * @param journalEventLinkByPatListMap
   * @param facilityCd
   * @param patId
   * @param hospPatId
   * @param treatDate
   */
  public void addToBeUEventTreatDate(Map<String, JournalEventLinkByPat> journalEventLinkByPatListMap,
                                     String facilityCd, Long patId, String hospPatId, String treatDate, Integer indKurCd);

  /**
   * @param journalEventLinkByPatListMap
   * @param facilityCd
   * @param patId
   * @param hospPatId
   * @param examMainCd
   */
  public void addToBeUEventExcludeExamKey(Map<String, JournalEventLinkByPat> journalEventLinkByPatListMap,
                                          String facilityCd, Long patId, String hospPatId, Long examMainCd);

  /**
   * @param journalEventLinkByPatListMap
   * @param facilityCd
   * @param patId
   * @param hospPatId
   * @param radResultCd
   */
  public void addToBeUEventExcludeRadKey(Map<String, JournalEventLinkByPat> journalEventLinkByPatListMap,
                                         String facilityCd, Long patId, String hospPatId, Long radResultCd);
}
