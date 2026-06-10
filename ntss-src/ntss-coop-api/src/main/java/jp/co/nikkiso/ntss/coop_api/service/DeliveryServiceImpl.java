package jp.co.nikkiso.ntss.coop_api.service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.stream.Collectors;

import jp.co.nikkiso.ntss.api.service.SysDataSetService;
import jp.co.nikkiso.ntss.coop_api.request.CallApiJournalRequest;
import jp.co.nikkiso.ntss.coop_api.request.JournalDeliveryRequest;
import jp.co.nikkiso.ntss.coop_api.response.DeliverSendResult;
import jp.co.nikkiso.ntss.coop_api.utils.*;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.*;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import org.seasar.doma.jdbc.Config;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.mapping.DeliveryResult;
import jp.co.nikkiso.ntss.coop_api.mapping.JournalInfo;
import jp.co.nikkiso.ntss.coop_api.mapping.ProtocolInfoWrapper;
import jp.co.nikkiso.ntss.coop_api.mapping.TelegramMetaData;
import jp.co.nikkiso.ntss.coop_api.response.DeliveryResults;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants.CoopResult;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.custom.JournalDistribute;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;

@Service
public class DeliveryServiceImpl implements DeliveryService {
  /**
   * DI
   */
  @Autowired
  private ClockWrapper clockWrapper;
  @Autowired
  private SysCoopJournalWithMstCoopDistributeDao sysCoopJournalWithMstCoopDistributeDao;
  @Autowired
  private SysCoopJournalDao sysCoopJournalDao;
  @Autowired
  private OrdMainDao ordMainDao;
  @Autowired
  private PatPersonalMainDao patPersonalMainDao;
  @Autowired
  private OrdCoopNoDao ordCoopNoDao;
  @Autowired
  private SysDataSetService sysDataSetService;

  @Autowired
  private LogService logService;

  // add 2021-04-02 課題No.1:API連動設定:動作条件「処理完了時、処理エラー時、処理スキップ時」を追加 孫 start
  @Autowired
  private CallApiService callApiService;
  // add 2021-04-02 課題No.1:API連動設定:動作条件「処理完了時、処理エラー時、処理スキップ時」を追加 孫 end

  // DB更新ログ出力ロジック wangzuo Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;
  // DB更新ログ出力ロジック wangzuo End

  // 配信ファイル一時保存フォルダパス取得
  @Autowired
  private FileUtil fileUtil;

  @Autowired
  private DeliveryServiceImpl deliveryServiceImpl;

  // mod 2022-11-02 bug #8028 応答待ちのジャーナルがあると、送信処理が実施されない 孫 start
//  @Override
//  public List<JournalDistribute> getDeliveryList(String facilityCd) {
//    return sysCoopJournalWithMstCoopDistributeDao.getDeliveryJournal(facilityCd);
//  }
//
//  // add 2021-07-08 #5266:レポート再送信時の送信済みファイル取得方法について 孫 start
//  @Override
//  public List<JournalDistribute> getRetryDeliveryList(String facilityCd) {
//    return sysCoopJournalWithMstCoopDistributeDao.getRetryDeliveryJournal(facilityCd);
//  }
//  // add 2021-07-08 #5266:レポート再送信時の送信済みファイル取得方法について 孫 end

  // add #10061、SQLパフォーマンス改善、 20231221 xugj start
  @Override
  public int getStoppedCoopResultCount(String facilityCd) {
    return sysCoopJournalWithMstCoopDistributeDao.getStoppedCoopResult(facilityCd);
  }
  // add #10061、SQLパフォーマンス改善、 20231221 xugj end

  @Override
  public List<JournalDistribute> getDeliveryList(String facilityCd, List<String> stopCoopCdList) {
    return sysCoopJournalWithMstCoopDistributeDao.getDeliveryJournal(facilityCd, stopCoopCdList);
  }

  @Override
  public List<JournalDistribute> getRetryDeliveryList(String facilityCd, List<String> stopCoopCdList) {
    return sysCoopJournalWithMstCoopDistributeDao.getRetryDeliveryJournal(facilityCd, stopCoopCdList);
  }
  // mod 2022-11-02 bug #8028 応答待ちのジャーナルがあると、送信処理が実施されない 孫 end

  @Override
  /* modify by chamaojia 2024-09-26 [10574] add the return value of the interface, of type [int] --start */
  public int updateProcessingByCoopResult(List<JournalDistribute> journalDistributeList) {
    int updateCount = this.updateByCoopResult(journalDistributeList, CoopResult.PROCESSING.getResult());
    //#8551 mod 処理対象となるbackupフォルダの日付が古い 2023-06-05 卓 start
    for (JournalDistribute journalDistribute : journalDistributeList) {
      journalDistribute.setInRegDate(new Timestamp(clockWrapper.getClockMillis()));
    }
    //#8551 mod 処理対象となるbackupフォルダの日付が古い 2023-06-05 卓 end

    return updateCount;
  }
  /* modify by chamaojia 2024-09-26 [10574] add the return value of the interface, of type [int] --end */

  @Override
  public void updateWaitingByCoopResult(List<JournalDistribute> journalDistributeList) {
    this.updateByCoopResult(journalDistributeList, CoopResult.WAITING.getResult());
  }

  /**
   * 配信処理
   * もらった配信ジャーナルから配信プロトコル(JSON)をパースし、ジャーナル情報と電文情報を含めて合体しレスポンスします
   *
   * @param journalList : 配信ジャーナルのList
   * @throws IOException
   */
  @Override
  public DeliveryResults execute(List<JournalDistribute> journalList) {
    DeliveryResults results = new DeliveryResults();
    List<DeliveryResult> deliveryResultList = new ArrayList<>();
    Iterator<JournalDistribute> iterator = journalList.iterator();

    List<Long> errorCtlNoList = new ArrayList<>();
    EventLogMessage eventLogMessage = new EventLogMessage();
    String deliveryJournalTmp = fileUtil.getDistFolderPath();
    while (iterator.hasNext()) {
      JournalDistribute journalDistribute = iterator.next();
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//      eventLogMessage.setLogMessage("[START]DeliveryServiceImpl#execute facility_cd:[" + journalDistribute.getFacilityCd() + "], "
//        + "coop_cd:[" + journalDistribute.getCoopCd() + "], coop_cd_index:[" + journalDistribute.getCoopCdIndex() + "]");
      String coopVersion = StringUtils.isEmpty(journalDistribute.getCoopVersion()) ? "" : journalDistribute.getCoopVersion();
      eventLogMessage.setLogMessage("[START]DeliveryServiceImpl#execute facility_cd:[" + journalDistribute.getFacilityCd() + "], "
        + "coop_cd:[" + journalDistribute.getCoopCd() + "], coop_version:[" + coopVersion + "], coop_cd_index:[" + journalDistribute.getCoopCdIndex() + "]");
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
      eventLogMessage.setFacilityCd(journalDistribute.getFacilityCd());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      // 配信設定(JSON) Parse
      try {

        // 配信設定の置換
        String distributeSetting = replaceDistributeSetting(journalDistribute);
        ProtocolInfoWrapper protocolInfoWrapper = ObjectMapperUtil.read(distributeSetting, ProtocolInfoWrapper.class);
        // mod bug 7351 ope_cd 追加 chen start
        // mod FNSI-7053 劉全航 start
//        JournalInfo journalInfo = new JournalInfo(journalDistribute.getCtlNo(), journalDistribute.getCoopCd(), journalDistribute.getCoopCdIndex(), journalDistribute.getOpeCd());
// mod 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//        JournalInfo journalInfo = new JournalInfo(journalDistribute.getCtlNo(), journalDistribute.getCoopCd(), journalDistribute.getCoopCdIndex(), journalDistribute.getOpeCd(), journalDistribute.getRegDate());
// mod 2023-04-13 bug #8550と#8551と#8553の対応 孫 start
//        JournalInfo journalInfo = new JournalInfo(journalDistribute.getCtlNo(), journalDistribute.getCoopCd()
//          , journalDistribute.getCoopCdIndex(), journalDistribute.getOpeCd(), journalDistribute.getRegDate()
//          , journalDistribute.getCoopVersion());
        //#8551 mod 処理対象となるbackupフォルダの日付が古い 2023-06-05 卓 start
        Timestamp regDate = journalDistribute.getRegDate();
        Timestamp inRegDate = journalDistribute.getInRegDate();
        Timestamp outRegDate = journalDistribute.getOutRegDate();
        String regDateStr = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(regDate);
        String inRegDateStr = "";
        if (inRegDate != null) {
          inRegDateStr = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(inRegDate);
        }
        String outRegDateStr = "";
        if (outRegDate != null) {
          outRegDateStr = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(outRegDate);
        }
        JournalInfo journalInfo = new JournalInfo(
          journalDistribute.getCtlNo()
          , journalDistribute.getCoopCd()
          , journalDistribute.getCoopCdIndex()
          , journalDistribute.getOpeCd()
          , regDateStr
          , inRegDateStr
          , outRegDateStr
          , journalDistribute.getCoopVersion());
        //#8551 mod 処理対象となるbackupフォルダの日付が古い 2023-06-05 卓 end
// mod 2023-04-13 bug #8550と#8551と#8553の対応 孫 end

// mod 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
        // mod FNSI-7053 劉全航 end
        // mod bug 7351 ope_cd 追加 chen end

        // DBにダンプデータがない場合は、配信ファイル保持フォルダからファイルを取得しレスポンスに含める
        TelegramMetaData data;
        if (journalDistribute.getDump() == null) {
          // 配信ファイル一時保存フォルダから、ctlNo_ + ファイル名のファイルを取得する
          Path path = Paths.get(deliveryJournalTmp + "/" + journalDistribute.getCtlNo() + "_" + journalDistribute.getDumpPath());
          if (Files.exists(path)) {
            // 配信ファイル保持フォルダ内に該当ファイルが存在する場合は、取得して配信データに含める
            data = new TelegramMetaData(journalDistribute.getDumpPath(), Files.readAllBytes(path));
          } else {
            // 既存動作として、ファイル取得が出来なかった場合は空のデータが入るようになっており、連携エッジ側でも「dump がなければ空のファイルを作成」との記載が存在する為、処理を崩さないようにする
            data = new TelegramMetaData(journalDistribute.getDumpPath(), new byte[0]);
          }
        } else {
          data = new TelegramMetaData(journalDistribute.getDumpPath(), journalDistribute.getDump());
        }

        DeliveryResult result = new DeliveryResult(journalInfo, protocolInfoWrapper.getProtocolInfo(), data);
        deliveryResultList.add(result);
      } catch (IOException e) {
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//        eventLogMessage.setLogMessage("配信設定のJSONパース処理に失敗しました。該当ジャーナルデータの配信ステータスをE1に更新します facility_cd : " + journalDistribute.getFacilityCd() + ", "
//          + "coop_cd:[" + journalDistribute.getCoopCd() + "], coop_cd_index:[" + journalDistribute.getCoopCdIndex() + "]");
        eventLogMessage.setLogMessage("配信設定のJSONパース処理に失敗しました。該当ジャーナルデータの配信ステータスをE1に更新します facility_cd : "
          + journalDistribute.getFacilityCd() + ", coop_cd:[" + journalDistribute.getCoopCd() + "], coop_version:[" + coopVersion +
          "], coop_cd_index:[" + journalDistribute.getCoopCdIndex() + "]");
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
        eventLogMessage.setFacilityCd(journalDistribute.getFacilityCd());
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
        eventLogMessage.setInvokeClass(this.getClass().getName());
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        // 失敗したジャーナルの ctlNo を退避する
        errorCtlNoList.add(journalDistribute.getCtlNo());
        // レスポンスには含めない
        iterator.remove();
        // 配信設定などが破損しているため、後続の処理はできない。よって次のジャーナルに処理を移す。
        continue;
      } catch (NtssException e) {
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//        eventLogMessage.setLogMessage(String.format("該当ジャーナルデータの配信ステータスをE1に更新します facility_cd:[%s], coop_cd:[%s], coop_cd_index:[%s]",
//          journalDistribute.getFacilityCd(), journalDistribute.getCoopCd(), journalDistribute.getCoopCdIndex()));
        eventLogMessage.setLogMessage(String.format("該当ジャーナルデータの配信ステータスをE1に更新します facility_cd:[%s], coop_cd:[%s], coop_version:[%s], coop_cd_index:[%s]",
          journalDistribute.getFacilityCd(), journalDistribute.getCoopCd(), coopVersion, journalDistribute.getCoopCdIndex()));
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
        eventLogMessage.setFacilityCd(journalDistribute.getFacilityCd());
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
        eventLogMessage.setInvokeClass(this.getClass().getName());
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        // 失敗したジャーナルの ctlNo を退避する
        errorCtlNoList.add(journalDistribute.getCtlNo());
        // レスポンスには含めない
        iterator.remove();
        // 配信設定などが破損しているため、後続の処理はできない。よって次のジャーナルに処理を移す。
        continue;
      }

// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//      eventLogMessage.setLogMessage("[END]DeliveryServiceImpl#execute facility_cd:[" + journalDistribute.getFacilityCd() + "], coop_cd:[" + journalDistribute.getCoopCd() + "], "
//        + "coop_cd_index:[" + journalDistribute.getCoopCdIndex() + "]");
      eventLogMessage.setLogMessage("[END]DeliveryServiceImpl#execute facility_cd:[" + journalDistribute.getFacilityCd()
        + "], coop_cd:[" + journalDistribute.getCoopCd() + "], coop_version:[" + coopVersion + "], "
        + "coop_cd_index:[" + journalDistribute.getCoopCdIndex() + "]");
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
      eventLogMessage.setFacilityCd(journalDistribute.getFacilityCd());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }
    results.setResult(deliveryResultList);
    // 失敗したジャーナルの配信結果をE1に更新する。
    updateE1ByCoopResult(errorCtlNoList);

    results.setStatus(HttpStatus.OK.value());
    return results;
  }


  /**
   * もらった配信ジャーナルの配信結果を指定した配信結果に更新します
   *
   * @param journalDistributeList : 配信ジャーナルのList
   * @param coopResult            : 配信結果
   */
  /* modify by chamaojia 2024-09-26 [10574] add the return value of the interface, of type [int] --start */
  // #8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230406 mod start
  //private void updateByCoopResult(List<JournalDistribute> journalDistributeList, String coopResult) {
  public int updateByCoopResult(List<JournalDistribute> journalDistributeList, String coopResult) {
    // #8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230406 mod end
    // 対象がない場合は、処理しない
    if (journalDistributeList.isEmpty()) return 0;

    List<Long> ctlNoList = journalDistributeList.stream().map(e -> e.getCtlNo()).collect(Collectors.toList());

    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "sys_coop_journal";
    // SQL検索条件
    String inStr = getInStr("ctl_no in ", ctlNoList);
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(inStr + "\n");
    if (CoopResult.PROCESSING.getResult().equals(coopResult)) {
      wheres.append(" and coop_result in ('0', 'R') ");
    }
    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(sysCoopJournalDao, tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    //#8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230406 mod start
    //int updateCount = sysCoopJournalDao.updateByCoopResult(ctlNoList, coopResult, new Timestamp(clockWrapper.getClockMillis()));
    int updateCount = sysCoopJournalDao.updateByCoopResult(JournalConvertUtil.ctlNoListToString(ctlNoList),
      coopResult, new Timestamp(clockWrapper.getClockMillis()));
    //#8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230406 mod end

    if (updateCount > 0) {
      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult) {
        logCommon.updateLog();
      }
      // DB更新ログ出力ロジック wangzuo End

      if (CoopResult.PROCESSING.getResult().equals(coopResult)) {
        //mod #7627 #7239 2023-03-14 卓  start
        Timestamp now = new Timestamp(clockWrapper.getClockMillis());
        for (JournalDistribute journal : journalDistributeList) {
          String coopVersion = StringUtils.isEmpty(journal.getCoopVersion()) ? "" : journal.getCoopVersion();
          ordCoopNoDao.updateIsStatus(journal.getFacilityCd(), journal.getPatId(), journal.getHospPatId(), journal.getOrdNo(),
            journal.getCoopCd(), coopVersion, journal.getCoopOrdNo(), now);
        }
        //mod #7627 #7239 2023-03-14 卓  end
      }
      // add 2021-04-02 課題No.1:API連動設定:動作条件「処理完了時、処理エラー時、処理スキップ時」を追加 孫 start
      // 事後APIキック機能を呼び出し
      if (CoopResult.DONE.getResult().equals(coopResult)
        || CoopResult.SKIP.getResult().equals(coopResult)
        || CoopResult.INTERNAL_ERROR_BY_NTSS.getResult().equals(coopResult)
        || CoopResult.INTERNAL_ERROR_BY_CARTE.getResult().equals(coopResult)) {

        for (JournalDistribute journalDistribute : journalDistributeList) {
          SysCoopJournal journal = new SysCoopJournal();
          BeanUtils.copyProperties(journalDistribute, journal);

          CallApiJournalRequest callApiJournalRequest = new CallApiJournalRequest();
          BeanUtils.copyProperties(journalDistribute, callApiJournalRequest);
          // mod 2021-06-09 #5278 API連動処理の判定が正しくない wangchen start
          if (CoopResult.DONE.getResult().equals(coopResult)) {
            callApiJournalRequest.setApiTimingIo(NtssCoopApiConstants.ApiTimingIoStatus.COOP_DONE.getStatus());
          } else if (CoopResult.SKIP.getResult().equals(coopResult)) {
            callApiJournalRequest.setApiTimingIo(NtssCoopApiConstants.ApiTimingIoStatus.COOP_SKIP.getStatus());
          } else if (CoopResult.INTERNAL_ERROR_BY_NTSS.getResult().equals(coopResult)
            || CoopResult.INTERNAL_ERROR_BY_CARTE.getResult().equals(coopResult)) {
            callApiJournalRequest.setApiTimingIo(NtssCoopApiConstants.ApiTimingIoStatus.COOP_ERROR.getStatus());
          }
          // mod 2021-06-09 #5278 API連動処理の判定が正しくない wangchen end
          callApiJournalRequest.setApiTimingBa(NtssCoopApiConstants.ApiTimingBaStatus.AFTER.getStatus());
          boolean callResult = callApiService.callApiJournal(callApiJournalRequest, journal, null);
          if (!callResult) {
            break;
          }
        }
      }
    }
    // add 2021-04-02 課題No.1:API連動設定:動作条件「処理完了時、処理エラー時、処理スキップ時」を追加 孫 end

    return updateCount;
  }
  /* modify by chamaojia 2024-09-26 [10574] add the return value of the interface, of type [int] --end */

  /**
   * もらった配信ジャーナルの ctl_no のリストを条件に 配信結果をE1("内部エラー")に更新します
   *
   * @param errorCtlNoList : [NOT NULL] {@link JournalDistribute#getCtlNo()} のリスト
   */
  @Transactional
  // #8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230406 mod start
  //private void updateE1ByCoopResult(List<Long> errorCtlNoList) {
  public void updateE1ByCoopResult(List<Long> errorCtlNoList) {
    // #8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230406 mod end
    // 対象がない場合は、処理しない
    if (errorCtlNoList.isEmpty()) return;

    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "sys_coop_journal";
    // SQL検索条件
    String inStr = getInStr("ctl_no in ", errorCtlNoList);
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(inStr + "\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(sysCoopJournalDao, tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    // 更新
    //#8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230406 mod start
//    int updateCount = sysCoopJournalDao.updateByCoopResult(
//      errorCtlNoList, CoopResult.INTERNAL_ERROR_BY_NTSS.getResult(), new Timestamp(clockWrapper.getClockMillis()));
    int updateCount = sysCoopJournalDao.updateByCoopResult(JournalConvertUtil.ctlNoListToString(errorCtlNoList),
      CoopResult.INTERNAL_ERROR_BY_NTSS.getResult(), new Timestamp(clockWrapper.getClockMillis()));
    //#8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230406 mod end

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End

    // add 2021-04-02 課題No.1:API連動設定:動作条件「処理完了時、処理エラー時、処理スキップ時」を追加 孫 start
    // 事後APIキック機能を呼び出し
    if (updateCount > 0) {

      for (Long ctlNo : errorCtlNoList) {
        SysCoopJournal journal = sysCoopJournalDao.selectByPK(ctlNo);

        CallApiJournalRequest callApiJournalRequest = new CallApiJournalRequest();
        BeanUtils.copyProperties(journal, callApiJournalRequest);
        // mod 2021-06-09 #5278 API連動処理の判定が正しくない wangchen start
        callApiJournalRequest.setApiTimingIo(NtssCoopApiConstants.ApiTimingIoStatus.COOP_ERROR.getStatus());
        // mod 2021-06-09 #5278 API連動処理の判定が正しくない wangchen end
        callApiJournalRequest.setApiTimingBa(NtssCoopApiConstants.ApiTimingBaStatus.AFTER.getStatus());
        boolean callResult = callApiService.callApiJournal(callApiJournalRequest, journal, null);
        if (!callResult) {
          break;
        }
      }
    }
    // add 2021-04-02 課題No.1:API連動設定:動作条件「処理完了時、処理エラー時、処理スキップ時」を追加 孫 end
  }

  // #8031 add 2022-10-25  journalの検知タイミングによって同じ電文が2回送信されてしまう。卓 start
  /* del by chamaojia 2023-05-11 [8229] トランザクションのシリアル処理範囲が大きすぎて、トランザクション範囲を縮小する必要があります  --start */
//  @Transactional(isolation = Isolation.SERIALIZABLE, rollbackFor = {Exception.class})
  /* del by chamaojia 2023-05-11 [8229] トランザクションのシリアル処理範囲が大きすぎて、トランザクション範囲を縮小する必要があります  --end */
  @Override
  public DeliverSendResult delivery(JournalDeliveryRequest request) {
    List<JournalDistribute> journalDistributeList = new ArrayList<>();
    /* modify by chamaojia 2023-05-11 [8229] コンテンツの一部を新しいメソッドに移行  --start */

    // add 2022-11-02 bug #8028 応答待ちのジャーナルがあると、送信処理が実施されない 孫 start
    // 配信停止の電文種別を取得する
    List<String> stopCoopCdList = new ArrayList<>();
    // del #10061、SQLパフォーマンス改善、 20231221 xugj start
    // stopCoopCdList.add("");
    // del #10061、SQLパフォーマンス改善、 20231221 xugj end
    if (!StringUtils.isEmpty(request.getStopCoopCdList())) {
      String stopCoopCds = request.getStopCoopCdList();
      String[] splitResult = stopCoopCds.split(",");
      for (int idx = 0; idx < splitResult.length; idx++) {
        stopCoopCdList.add(splitResult[idx]);
      }
    }
    // add 2022-11-02 bug #8028 応答待ちのジャーナルがあると、送信処理が実施されない 孫 end
    DeliverSendResult deliverSendResult = deliveryServiceImpl.deliveryToUpdateProcessing(request, stopCoopCdList);
    if (deliverSendResult.isReturnFlag()) {
      return deliverSendResult;
    } else {
      journalDistributeList = deliverSendResult.getJournalDistributeList();
    }
    /* modify by chamaojia 2023-05-11 [8229] コンテンツの一部を新しいメソッドに移行  --end */
    // upd 2022-10-25  journalの検知タイミングによって同じ電文が2回送信されてしまう。卓 end

    /* modify by chamaojia 2024-09-26 [10574] add exception handling logic --start */
    try {
      DeliveryResults deliveryResults = this.execute(journalDistributeList);

      // 事後APIキック機能
      for (JournalDistribute journalDistribute : journalDistributeList) {
        CallApiJournalRequest callApiJournalRequest = new CallApiJournalRequest();
        BeanUtils.copyProperties(journalDistribute, callApiJournalRequest);
        callApiJournalRequest.setApiTimingIo(NtssCoopApiConstants.ApiTimingIoStatus.DELIVERY.getStatus());
        callApiJournalRequest.setApiTimingBa(NtssCoopApiConstants.ApiTimingBaStatus.AFTER.getStatus());
        // mod 2021-04-07 課題No.1:SQL呼び出しを追加 孫 start
//        boolean callResult = callApiService.callApiJournal(callApiJournalRequest, null, null);
        SysCoopJournal journalForApi = new SysCoopJournal();
        BeanUtils.copyProperties(journalDistribute, journalForApi);
        boolean callResult = callApiService.callApiJournal(callApiJournalRequest, journalForApi, null);
        // mod 2021-04-07 課題No.1:SQL呼び出しを追加 孫 end
        if (!callResult) {
          break;
        }
      }

      // 正常に返されました
      deliverSendResult.setJournalDistributeList(journalDistributeList);
      deliverSendResult.setDeliveryResults(deliveryResults);
    } catch (Exception e) {
      List<Long> ctlNoList = journalDistributeList.stream().map(j -> j.getCtlNo()).collect(Collectors.toList());
      updateE1ByCoopResult(ctlNoList);

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(String.format("該当ジャーナルデータの配信ステータスをE1に更新します facility_cd:[%s], ctl_no_list:[%s]",
              request.getFacilityCd(), ctlNoList));
      eventLogMessage.setFacilityCd(request.getFacilityCd());
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      throw e;
    }

    // もらったジャーナルの配信ステータスを全て"8"(応答待ち)に更新する
    this.updateWaitingByCoopResult(journalDistributeList);
    /* modify by chamaojia 2024-09-26 [10574] add exception handling logic --end */

    return deliverSendResult;

  }
  // #8031 add 2022-10-25  journalの検知タイミングによって同じ電文が2回送信されてしまう。卓 end

  /* add by chamaojia 2023-05-11 [8229] クエリーと変更のみを保持するシリアル・トランザクション用の新規メソッド  --start */
  /* delete by chamaojia 2024-09-26 [10574] delete transaction annotation --start */
  //  @Transactional(isolation = Isolation.SERIALIZABLE, rollbackFor = {Exception.class})
  /* delete by chamaojia 2024-09-26 [10574] delete transaction annotation --end */
  @Transactional
  public DeliverSendResult deliveryToUpdateProcessing(JournalDeliveryRequest request, List<String> stopCoopCdList) {
    List<JournalDistribute> journalDistributeList = new ArrayList<>();
    DeliverSendResult deliverSendResult = new DeliverSendResult();
    deliverSendResult.setReturnFlag(false);

    DeliveryResults deliveryResultsEmpty = new DeliveryResults();
    deliveryResultsEmpty.setResult(new ArrayList<>());
    deliveryResultsEmpty.setStatus(HttpStatus.OK.value());

    try {
      if (!StringUtils.isEmpty(request.getSendType()) && "retry".equals(request.getSendType())) {
        // リトライ配信場合
        // mod 2022-11-02 bug #8028 応答待ちのジャーナルがあると、送信処理が実施されない 孫 start
  //      journalDistributeList = this.getRetryDeliveryList(request.getFacilityCd());
        journalDistributeList = this.getRetryDeliveryList(request.getFacilityCd(), stopCoopCdList);
        // mod 2022-11-02 bug #8028 応答待ちのジャーナルがあると、送信処理が実施されない 孫 end
      } else {
        // mod 2022-11-02 bug #8028 応答待ちのジャーナルがあると、送信処理が実施されない 孫 start
  //      journalDistributeList = this.getDeliveryList(request.getFacilityCd());
        // mod #10061、SQLパフォーマンス改善、 20231221 xugj start
        int count = this.getStoppedCoopResultCount(request.getFacilityCd());
        if (count == 0) {
          journalDistributeList = this.getDeliveryList(request.getFacilityCd(), stopCoopCdList);
        }
        // mod #10061、SQLパフォーマンス改善、 20231221 xugj end
        // mod 2022-11-02 bug #8028 応答待ちのジャーナルがあると、送信処理が実施されない 孫 end
      }
    } catch (RuntimeException e) {
      // 並行処理にてジャーナルロック済みのため配信ジャーナルを取得しない
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(String.format("配信ジャーナル取得時エラー"));
      eventLogMessage.setFacilityCd(request.getFacilityCd());
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      eventLogMessage.setLogMessage(e.getClass().getName() + ":" + e.getMessage());
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }

    // 対象ジャーナルが0件あるいは取得しない場合
    if (journalDistributeList == null || journalDistributeList.size() == 0) {
      deliverSendResult.setJournalDistributeList(journalDistributeList);
      deliverSendResult.setDeliveryResults(deliveryResultsEmpty);
      deliverSendResult.setReturnFlag(true);

      return deliverSendResult;
    }

    // もらったジャーナルの配信ステータスを全て"1"(処理中)に更新する
    // upd 2022-10-25  journalの検知タイミングによって同じ電文が2回送信されてしまう。卓 start
    try {
      /* modify by chamaojia 2024-09-26 [10574] processing with 0 successful modifications added --start */
      int updateCount = this.updateProcessingByCoopResult(journalDistributeList);
      if (updateCount == 0) {
        deliverSendResult.setJournalDistributeList(new ArrayList<>());
        deliverSendResult.setDeliveryResults(deliveryResultsEmpty);
        deliverSendResult.setReturnFlag(true);

        return deliverSendResult;
      }
      /* modify by chamaojia 2024-09-26 [10574] processing with 0 successful modifications added --end */
    } catch (Exception e) {
      //並列トランザクションの競合が発生しました,
      EventLogMessage eventLogMessage = new EventLogMessage();
      JournalDistribute journalExcept = journalDistributeList.get(0);
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//      String message=String.format("並列トランザクションの競合が 発生しました。facility_cd:[%s],coop_cd:[%s],coop_ord_no:[%s]",
//        journalExcept.getFacilityCd(),journalExcept.getCoopCd(),journalExcept.getCoopOrdNo());
      String coopVersion = StringUtils.isEmpty(journalExcept.getCoopVersion()) ? "" : journalExcept.getCoopVersion();
      String message = String.format("並列トランザクションの競合が 発生しました。facility_cd:[%s],coop_cd:[%s],coop_version:[%s],coop_ord_no:[%s]",
              journalExcept.getFacilityCd(), journalExcept.getCoopCd(), coopVersion, journalExcept.getCoopOrdNo());
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
      eventLogMessage.setLogMessage(message);
      eventLogMessage.setFacilityCd(request.getFacilityCd());
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      eventLogMessage.setLogMessage(e.getClass().getName() + ":" + e.getMessage());
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      throw e;
    }

    deliverSendResult.setJournalDistributeList(journalDistributeList);
    return deliverSendResult;
  }
  /* add by chamaojia 2023-05-11 [8229] クエリーと変更のみを保持するシリアル・トランザクション用の新規メソッド  --end */

  /**
   * 配信設定の特定文字列を置換
   *
   * @param journalDistribute - 連携配信設定マスタ.配信設定
   * @return 置換結果文字列
   */
  private String replaceDistributeSetting(JournalDistribute journalDistribute) {

    // 患者番号(連携用)
    String hospPatId = journalDistribute.getHospPatId();
    if (StringUtils.isEmpty(hospPatId)) {
      // 患者番号(連携用)が設定されていない場合
      // 患者番号(システム)を取得
      Long patId = journalDistribute.getPatId();
      if (patId == null) {
        // 患者番号(システム)が設定されていない場合
        // 治療情報(ord_main)から患者IDを取得
        OrdMain om = ordMainDao.selectByOrdNo(journalDistribute.getOrdNo());
        if (om == null) {
          String error = String.format("治療情報の取得に失敗しました。ord_no:[%s]"
            , journalDistribute.getOrdNo(), journalDistribute.getPatId());
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setFacilityCd(journalDistribute.getFacilityCd());
          eventLogMessage.setLogMessage(error);
          // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
          eventLogMessage.setInvokeClass(this.getClass().getName());
          // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          sysCoopJournalDao.updateMessage(journalDistribute.getCtlNo(), error);
          throw new NtssException(error);
        }
        patId = om.getPatId();
      }
      // 患者基本情報を取得
      PatPersonalMain ppm = patPersonalMainDao.selectById(patId);
      if (ppm == null) {
        String error = String.format("患者基本情報の取得に失敗しました。pat_id:[%s]", journalDistribute.getPatId());
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setFacilityCd(journalDistribute.getFacilityCd());
        eventLogMessage.setLogMessage(error);
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
        eventLogMessage.setInvokeClass(this.getClass().getName());
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        sysCoopJournalDao.updateMessage(journalDistribute.getCtlNo(), error);
        throw new NtssException(error);
      }
      // 患者基本情報.院内表示用の患者IDを取得
      hospPatId = ppm.getHosp_pat_id();
    }
    // 固定値を患者番号(連携用)に置換
    // mod 2021-07-19 #5429:患者番号の前ゼロの扱いについて 孫 start
//    // mod 2021-03-17 問題確認：NODEJS側に確認JAVA側のPDFファイルを送付しました。 孫 start
////    return journalDistribute.getDistributeSetting().replace("$HOSP_PAT_ID", hospPatId);
//    return journalDistribute.getDistributeSetting().replace("$HOSP_PAT_ID", LeftPadZero(hospPatId, 12));
//    // mod 2021-03-17 問題確認：NODEJS側に確認JAVA側のPDFファイルを送付しました。 孫 end
    String distributeSetting = journalDistribute.getDistributeSetting();
    String hospPatIdLenString = "";
    try {
      ProtocolInfoWrapper protocolInfoWrapper = ObjectMapperUtil.read(distributeSetting, ProtocolInfoWrapper.class);
      ProtocolInfoWrapper.ProtocolInfo protocolInfo = protocolInfoWrapper.getProtocolInfo();
      // 表示用患者IDの最大長さを取得する
      hospPatIdLenString = protocolInfo.getHospPatIdLen();
    } catch (Exception e) {
      String error = "配信設定が取得できませんでした。" + e.getMessage();
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setFacilityCd(journalDistribute.getFacilityCd());
      eventLogMessage.setLogMessage(error);
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      sysCoopJournalDao.updateMessage(journalDistribute.getCtlNo(), error);
      throw new NtssException(error);
    }

    int hospPatIdLen = 0;
    if (!StringUtils.isEmpty(hospPatIdLenString)) {
      hospPatIdLen = Integer.parseInt(hospPatIdLenString);
    }

    // add 2021-10-26 #5890:Medicom連携ができない 孫 start
    // 透析経過データ連携のフォルダ($MEDICOM3_HOSP_PAT_ID)を作成する
    // 患者コードフォルダは患者IDの先頭0削除を行った後、先頭より3桁ずつ区切り、全角英数でフォルダ名を生成します。
    if (distributeSetting.contains("$MEDICOM3_HOSP_PAT_ID")) {
      String hospPatIdMedicom = StringConvert.ToSBC(LeftTrimZero(hospPatId));
      List<String> pathList = new ArrayList<>();
      while (hospPatIdMedicom.length() > 0) {
        String tmpId = "";
        if (hospPatIdMedicom.length() <= 3) {
          tmpId = hospPatIdMedicom;
          hospPatIdMedicom = "";
        } else {
          tmpId = hospPatIdMedicom.substring(0, 3);
          hospPatIdMedicom = hospPatIdMedicom.substring(3);
        }
        pathList.add(tmpId);
      }

      hospPatIdMedicom = "";
      for (String path : pathList) {
        if (StringUtils.isEmpty(hospPatIdMedicom)) {
          hospPatIdMedicom = path;
        } else {
          hospPatIdMedicom = hospPatIdMedicom + "/" + path;
        }
      }
      distributeSetting = distributeSetting.replace("$MEDICOM3_HOSP_PAT_ID", hospPatIdMedicom);
    }
    // add 2021-10-26 #5890:Medicom連携ができない 孫 end

// mod 2022-03-21 #7104:rep_dial連携で送信するFTPフォルダ名 孫 start
//    return distributeSetting.replace("$HOSP_PAT_ID", LeftPadZero(LeftTrimZero(hospPatId), hospPatIdLen));
    String newDistributeSetting = distributeSetting.replace("$HOSP_PAT_ID", LeftPadZero(LeftTrimZero(hospPatId), hospPatIdLen));
    // DATASET項目が有りか
    // [/home/ntss/tmp/$DATASET,-100001,hosp_pat_id$]
    String itemStartFlag = "$DATASET";
    String itemEndFlag = "$";
    if (newDistributeSetting.contains(itemStartFlag)) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setFacilityCd(journalDistribute.getFacilityCd());
      eventLogMessage.setInvokeClass(this.getClass().getName());

      // ①配信設定の特定文字列を取得する
      List<String> itemList = new ArrayList<>();
      int startIndex = newDistributeSetting.indexOf(itemStartFlag, 0);
      // 特定文字列の設定項目を取得する
      do {
        int endIndex = newDistributeSetting.indexOf(itemEndFlag, startIndex + itemStartFlag.length());
        if (endIndex == -1) {
          // 終止符が無し
          String error = String.format("連携配信設定[%s]不正。特定文字列項目を設定しました場合、開始記号[%s]が有り場合、終了記号[%s]が無し。",
            newDistributeSetting, itemStartFlag, itemEndFlag);
          eventLogMessage.setLogMessage(error);
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          sysCoopJournalDao.updateMessage(journalDistribute.getCtlNo(), error);
          throw new NtssException(error);
        }
        // itemを追加
        String itemTemp = newDistributeSetting.substring(startIndex, endIndex + 1);
        itemList.add(itemTemp);
        startIndex = newDistributeSetting.indexOf(itemStartFlag, endIndex + 1);
      } while (startIndex != -1);

      // ②特定文字列の値を取得する
      Map<String, Object> dataKey = new HashMap<>();
      dataKey.put("facilityCd", journalDistribute.getFacilityCd());
      dataKey.put("ctlNo", journalDistribute.getCtlNo());
      dataKey.put("coopCd", journalDistribute.getCoopCd());
      dataKey.put("coopCdIndex", journalDistribute.getCoopCdIndex());
      dataKey.put("crud", journalDistribute.getCrud());
      dataKey.put("ordNo", journalDistribute.getOrdNo());
      dataKey.put("coopOrdNo", journalDistribute.getCoopOrdNo());
      dataKey.put("hospPatId", journalDistribute.getHospPatId());
      dataKey.put("patId", journalDistribute.getPatId());
      dataKey.put("dumpPath", journalDistribute.getDumpPath());
      dataKey.put("baseDate", journalDistribute.getBaseDate());
      Map<Long, List<Map<String, Object>>> sqlDataList = new HashMap<>();
      for (String itemOne : itemList) {
        String[] sqlSetting = itemOne.replace(itemEndFlag, "").split(",");
        if (sqlSetting.length != 3 || StringUtils.isEmpty(sqlSetting[1]) || StringUtils.isEmpty(sqlSetting[2])) {
          // フォーマットが不正
          String error = String.format("連携配信設定不正。特定文字列項目[%s]のフォーマット不正。正しく設定した例:[$DATASET,-100001,hosp_pat_id$]",
            itemOne);
          eventLogMessage.setLogMessage(error);
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          sysCoopJournalDao.updateMessage(journalDistribute.getCtlNo(), error);
          throw new NtssException(error);
        }

        // sqlCodeと置換項目を取得する
        Long sqlCode = 0L;
        String itemName = sqlSetting[2];
        try {
          sqlCode = Long.parseLong(sqlSetting[1]);
        } catch (NumberFormatException e) {
          String error = String.format("連携配信設定不正。特定文字列項目[%s]のsqlCode[%s]は数値ではない。",
            itemOne, sqlSetting[1]);
          eventLogMessage.setLogMessage(error);
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          sysCoopJournalDao.updateMessage(journalDistribute.getCtlNo(), error);
          throw new NtssException(error);
        }

        // SQLの結果が有りか
        if (!sqlDataList.containsKey(sqlCode)) {
          List<Map<String, Object>> dataList = sysDataSetService.getDataListContainsError(sqlCode, dataKey, null);
          if (dataList == null || dataList.size() == 0) {
            String error = String.format("特定文字列項目[%s]のsqlCode[%s]はデータを取得していません。",
              itemOne, sqlSetting[1]);
            eventLogMessage.setLogMessage(error);
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            sysCoopJournalDao.updateMessage(journalDistribute.getCtlNo(), error);
            throw new NtssException(error);
          }

          // SQLにエラーが有りか
          if (dataList.get(0).containsKey("error")) {
            String error = String.format("特定文字列項目[%s]のsqlCode[%s]エラー発生。[%s]",
              itemOne, sqlSetting[1], dataList.get(0).get("error"));
            eventLogMessage.setLogMessage(error);
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            sysCoopJournalDao.updateMessage(journalDistribute.getCtlNo(), error);
            throw new NtssException(error);
          }
          sqlDataList.put(sqlCode, dataList);
        }

        // SQLの結果を取得する
        List<Map<String, Object>> dataList = sqlDataList.get(sqlCode);
        Map<String, Object> map = dataList.get(0);
        // SQLの取得結果に置換項目が有りか
        if (!map.containsKey(itemName)) {
          String error = String.format("連携配信設定不正。特定文字列項目[%s]のsqlCode[%s]の取得結果に項目[%s]はありません。",
            itemOne, sqlSetting[1], sqlSetting[2]);
          eventLogMessage.setLogMessage(error);
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          sysCoopJournalDao.updateMessage(journalDistribute.getCtlNo(), error);
          throw new NtssException(error);
        }

        // 置換の内容がNULLですか
        Object itemValue = map.get(itemName);
        if (StringUtils.isEmpty(itemValue)) {
          String error = String.format("特定文字列項目[%s]のsqlCode[%s]を取得した項目[%s]の値が空です。",
            itemOne, sqlSetting[1], sqlSetting[2]);
          eventLogMessage.setLogMessage(error);
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          sysCoopJournalDao.updateMessage(journalDistribute.getCtlNo(), error);
          throw new NtssException(error);
        }

        // ③空の文字列識別子「[|NULL|]」か
        if ("|NULL|".equals(itemValue.toString())) {
          itemValue = "";
        }

        // ④特定文字列の値を置換する
        newDistributeSetting = newDistributeSetting.replace(itemOne, itemValue.toString());
      }
    }
    return newDistributeSetting;
// mod 2022-03-21 #7104:rep_dial連携で送信するFTPフォルダ名 孫 end
    // mod 2021-07-19 #5429:患者番号の前ゼロの扱いについて 孫 end
  }

  // mod 2021-07-19 #5429:患者番号の前ゼロの扱いについて 孫 start

  /**
   * 文字列の左の0を削除します
   *
   * @return String
   */
  private String LeftTrimZero(String before) {
    String after = before;
    if (before == null) {
      after = "";
    }

    int length = before.length();
    for (int i = 0; i < length; i++) {
      if (before.charAt(i) != '0') {
        after = before.substring(i);
        break;
      }
    }
    return after;
  }
  // mod 2021-07-19 #5429:患者番号の前ゼロの扱いについて 孫 end

  // add 2021-03-17 問題確認：NODEJS側に確認JAVA側のPDFファイルを送付しました。 孫 start

  /**
   * 文字列左補0
   *
   * @return String
   */
  private String LeftPadZero(String before, int length) {
    if (before != null && before.length() >= length) {
      return before;
    }

    if (before == null) {
      before = "";
    }

    String format = String.format("%s%d%s", "%0", (length - before.length()), "d");
    String padString = String.format(format, 0);
    String after = padString.concat(before);

    return after;
  }
  // add 2021-03-17 問題確認：NODEJS側に確認JAVA側のPDFファイルを送付しました。 孫 end

  // DB更新ログ出力ロジック wangzuo Start

  /**
   * ログ情報設定
   *
   * @return eventLogMessage
   */
  private EventLogMessage getEventLogMessage() {
    EventLogMessage eventLogMessage = new EventLogMessage();
    // サービス名
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.NTSS_COOP_API + "," + SERVICE_NAME.FNSI);
    return eventLogMessage;
  }

  /**
   * ログ出力共通クラス設定、取得
   *
   * @return logCommon ログ出力共通クラス
   */
  private DataUpdateLogCommonNew getLogCommon(Object dao, String tableName, StringBuffer whereStr, EventLogMessage eventLogMessage) {
    DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
    logCommon.setEventLoggerFactory(eventLoggerFactory);
    logCommon.setLogServiceCore(logServiceCore);
    logCommon.setConfig(Config.get(dao));
    logCommon.setTableName(tableName);
    logCommon.setWhereStr(whereStr);
    logCommon.setCommonEventLogMessage(eventLogMessage);
    return logCommon;
  }

  /**
   * 検索条件 IN情報
   *
   * @param fieldInfo カラム情報
   * @param inList    IN値リスト
   * @return inStr
   */
  public String getInStr(String fieldInfo, List<Long> inList) {
    StringBuffer inStr = new StringBuffer("");
    inStr.append(fieldInfo);
    inStr.append(" ( ");
    for (Long obj : inList) {
      inStr.append(obj);
      inStr.append(" ,");
    }
    inStr.deleteCharAt(inStr.length() - 1);
    inStr.append(" ) ");
    return String.valueOf(inStr);
  }
  // DB更新ログ出力ロジック wangzuo End


}
