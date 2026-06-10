package jp.co.nikkiso.ntss.coop_api.service;

import java.io.IOException;
import java.util.List;

import jp.co.nikkiso.ntss.coop_api.request.JournalCreateRequest;
import jp.co.nikkiso.ntss.coop_api.request.JournalDeliveryRequest;
import jp.co.nikkiso.ntss.coop_api.request.JournalUpdateRequest;
import jp.co.nikkiso.ntss.coop_api.request.MntIfEdgeClientConnectRequest;
import jp.co.nikkiso.ntss.coop_api.response.ErrorMessage;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants;
import jp.co.nikkiso.ntss.core.entity.OrdCoopNo;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;

/**
 * journal service
 */
public interface JournalService {
  //#7239 2022-11-19 add  処理保留イベントの最適化処理が行われない start
  /**
   * ジャーナル
   *
   * @return {@link SysCoopJournal}
   */
  List<SysCoopJournal> listJournalsUnprocess(SysCoopJournal journal);
/** 2023-02-07 #7781 mod 卓 start */
//  /**
//   * ジャーナル
//   * @param crud    {@link NtssCoopApiConstants.Crud}
//   * @return {@link SysCoopJournal}
//   */
//  List<SysCoopJournal> listCoopResultUnprocessSkipError(SysCoopJournal journal, String crud) ;
//  /**
//   * ジャーナル
//   * @param crud    {@link NtssCoopApiConstants.Crud}
//   * @return {@link SysCoopJournal}
//   */
//  List<SysCoopJournal> listByCrudCoopCdCoopCdIndex(SysCoopJournal journal, String crud, String coopCd, String coopCdIndex);

  /**
   * 以前のJournal を検索
   *
   * @param crud    {@link NtssCoopApiConstants.Crud}
   * @param journal {@link SysCoopJournal}
   */
  List<SysCoopJournal> findSameJournalList(SysCoopJournal journal, String crud,Boolean last);
/** 2023-02-07 #7781 mod 卓 end */
  /**
   * Repが完全かどうかを比較
   * @param crud1    {@link NtssCoopApiConstants.Crud}
   * @param crud2    {@link NtssCoopApiConstants.Crud}
   */
  Boolean checkJournalRep(SysCoopJournal journal,String crud1,String crud2);

  /**
   * ジャーナル
   *
   * @param facilityCd -
   * @param ordNo （次世代FN)オーダ番号
   * @param patId 患者番号（システム）
   * @return {@link SysCoopJournal}
   */
  /* modify by chamaojia 2023-02-01 [7050] インタフェースパラメータの追加ordNo、patId  --start */
  List<SysCoopJournal> listJournalsUnDelivery(SysCoopJournal sysCoopJournal,String crud ,List<String> toSkipAnaStatus);
  /* modify by chamaojia 2023-02-01 [7050] インタフェースパラメータの追加ordNo、patId  --end */
  /**
   * ジャーナル
   *
   * @param journal - {@link SysCoopJournal}
   * @return {@link SysCoopJournal}
   */
  List<SysCoopJournal> listJournalsByOrderNo(SysCoopJournal journal,List<String> coopResultList,String ordCoopNo);
//#7239 2022-11-19 add  処理保留イベントの最適化処理が行われない end

  /**
   * ジャーナル
   *
   * @param crudDeleteJournal - {@link SysCoopJournal}
   * @return {@link SysCoopJournal}
   */
  List<SysCoopJournal> listJournalsRepDialByOrderNo(SysCoopJournal crudDeleteJournal, List<String> coopResultList, String coopCd);


  /**
   * ジャーナル作成
   *
   * @param request - {@link JournalCreateRequest}
   * @return {@link SysCoopJournal}
   */
  public List<SysCoopJournal> insert(JournalCreateRequest request);

  /**
   * ジャーナル更新
   *
   * @param request - {@link JournalUpdateRequest}
   * @return {@link SysCoopJournal}
   */
  public SysCoopJournal update(JournalUpdateRequest request);

  public SysCoopJournal update(SysCoopJournal request);

//#7239 2022-11-19 add  処理保留イベントの最適化処理が行われない start
  /**
   * ジャーナルスキップの設定
   *
   * @param journal - {@link SysCoopJournal}
   */
  public Integer updateJournalSkip(SysCoopJournal journal,String skipMessage);
  /**
   * ジャーナル更新AnaResult,coopResult,and dates
   *
   * @param journal - {@link SysCoopJournal}
   */
  public Integer updateJournalSkipWithDate(SysCoopJournal journal);
  /**
   * ジャーナルスキップの設定
   *
   * @param journalList - {@link SysCoopJournal}
   */
  public Integer  updateJournalListSkip(List<SysCoopJournal> journalList,String skipMessage) ;
  /**
   * ジャーナル更新CoopResult
   *
   * @param journal - {@link SysCoopJournal}
   */
  public Integer updateJournalCoopResult(SysCoopJournal journal,String skipMessage);

  /**
   *
   * @param crudDeleteJournal - {@link SysCoopJournal}
   * @param ordCoopNo - {@link OrdCoopNo}
   */
  public List<SysCoopJournal> filterToSetSkipJournalList(SysCoopJournal crudDeleteJournal, OrdCoopNo ordCoopNo,List<String> coopResultList);

  /**
   *
   * @param journalList - {@link SysCoopJournal}
   */
  public void updateSkipJournalList(List<SysCoopJournal> journalList);


  /**
   * ジャーナル更新Crud
   *
   * @param journal - {@link SysCoopJournal}
   */
  public Integer updateJournalCrud(SysCoopJournal journal);
//  #7239 2022-11-19 add  処理保留イベントの最適化処理が行われない end

  // add 2020-12-09 FNSI-改修 外部連携727 夏 star
  /**
   * 連携オーダ番号取得
   *
   * @param journal - {@link SysCoopJournal}
   * @return error message
   */
  public String executeCoopOrdNoProc(SysCoopJournal journal);
  // add 2020-12-09 FNSI-改修 外部連携727 夏 end

  // add 2021-08-27 #5887:富士通連携設定の構築の対応 孫 start

  /**
   * 種別が「ini_dial」「profile」のレコードが存在するのチェック
   *
   * @param journal - {@link SysCoopJournal}
   * @return 処理結果
   */
  public String checkCoopExisted(SysCoopJournal journal);
  // add 2021-08-27 #5887:富士通連携設定の構築の対応 孫 end

  // add 2022-11-02 bug #8028 応答待ちのジャーナルがあると、送信処理が実施されない 孫 start

  /**
   * 応答待ちのジャーナル更新
   *
   * @param facilityCd 施設コード
   * @return 更新件数
   */
//  public int updateWaitingStatus(String facilityCd);
  // add 2022-11-02 bug #8028 応答待ちのジャーナルがあると、送信処理が実施されない 孫 end

  // add 2022-11-08 bug #7113 rep_dial連携の処理タイミングがずれる 孫 start

  /* modify by zhangruixue 2023-01-30 [Transaction,CodeOptimization] --start */
  /**
   * 応答待ちのジャーナル更新
   *
   * @param facilityCd 施設コード
   * @return 更新件数
   */
  public int updateWaitingStatus(String facilityCd);
  /* modify by zhangruixue 2023-01-30 [Transaction,CodeOptimization] --end */

  /**
   * 帳票作成待ちデータの場合、帳票データを作成する
   *
   * @param journal 外部連携用ジャーナル
   * @return {@link SysCoopJournal}
   */
  public SysCoopJournal createJournalReportDump(SysCoopJournal journal);

  // add 2022-11-08 bug #7113 rep_dial連携の処理タイミングがずれる 孫 end


  /* modify by zhangruixue 2023-02-01 [Transaction,CodeOptimization] --start */
  /**
   * 応答待ちのジャーナル更新  Transactional
   *
   * @param facilityCd 施設コード
   * @return 更新件数
   */
  public ErrorMessage updateWaiting(String facilityCd, JournalDeliveryRequest request);
  /* modify by zhangruixue 2023-02-01 [Transaction,CodeOptimization] --end */
  // add #8255 ini_dial連携で正常応答を行っているにもかかわらずバックアップデータがNGフォルダに格納される 20230204 孫健 start
  List<SysCoopJournal> listJournalsUnDeliveryAsSkip(String facilityCd, Long ordNo, Long patId);

  // add #8255 ini_dial連携で正常応答を行っているにもかかわらずバックアップデータがNGフォルダに格納される 20230204 孫健 end

  // #6993-profile連携で受信した生存の有無登録 周 20230204 add start
  public int upExamOrdJournalToSkip(JournalCreateRequest request);
  // #6993-profile連携で受信した生存の有無登録 周 20230204 add end
  
  public void upReportDialJournalToSkip(JournalCreateRequest request);

  /**
   * オーダ受け連携ベッド入れ替え処理
   *
   * @param request
   */
  public void ordDialBedReplace(JournalUpdateRequest request);

  // 連携負荷分散対応 20230714 add 卓 start
  /**
   * websocket送信
   * request {@link MntIfEdgeClientConnectRequest}
   */
  Boolean wsClientSend(MntIfEdgeClientConnectRequest request) throws IOException;
  // 連携負荷分散対応 20230714 add 卓 end

}
