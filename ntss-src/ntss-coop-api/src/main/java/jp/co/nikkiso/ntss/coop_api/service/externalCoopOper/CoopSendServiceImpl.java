package jp.co.nikkiso.ntss.coop_api.service.externalCoopOper;

import jp.co.nikkiso.ntss.coop_api.request.JournalConvertSendRequest;
import jp.co.nikkiso.ntss.coop_api.request.JournalDeliveryRequest;
import jp.co.nikkiso.ntss.coop_api.response.JournalConvertResult;
import jp.co.nikkiso.ntss.coop_api.service.FacilityStatusService;
import jp.co.nikkiso.ntss.coop_api.service.IfEdgeService;
import jp.co.nikkiso.ntss.coop_api.service.JournalConvertSendService;
import jp.co.nikkiso.ntss.coop_api.service.LogService;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConstant;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertLogUtil;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.util.List;
// add #9406  外部連携稼働ビューア API呼び出しに失敗する 20231016 孟堅 start
@Service
public class CoopSendServiceImpl implements CoopSendService {

  @Autowired
  private JournalConvertSendService journalConvertSendService;

  @Autowired
  private LogService logService;

  @Autowired
  private IfEdgeService ifEdgeService;

  @Autowired
  private FacilityStatusService facilityStatusService;

  @Override
  public ResponseEntity<?> sendLogic(JournalConvertSendRequest request) {
    // mod 2020-11-16 各API間の呼び出しフローの修正（エッジ主体からAWS主体へ）→負荷増加回避策が必要 孫 start
//    if (!request.validate()) {
//      String error = String.format("リクエストパラメータが不正または不足しています。facility_cd:[%s]", request.getFacilityCd());
//      JournalConvertResult result = new JournalConvertResult(HttpStatus.BAD_REQUEST.value(), error);
//      return new ResponseEntity<>(result, HttpStatus.BAD_REQUEST);
//    }
//
//    String facilityCd = request.getFacilityCd();
//
//    // 変換対象ジャーナル取得
//    List<SysCoopJournal> journalList = convertCommonService.getJournalList(facilityCd
//        , JournalConvertConstants.DIRECTION_SEND
//        , NtssCoopApiConstants.CoopResult.UNPROCESS.getResult());
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage(String.format("%s:convert:journalList=%s", request.getFacilityCd(), journalList));
//    eventLogMessage.setFacilityCd(facilityCd);
//    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//
//    // 対象ジャーナルが1件も存在しない場合
//    if (CollectionUtils.isEmpty(journalList)) {
//      // 準正常応答とするが、HTTPステータスコードはNO_CONTENTを返す。
//      String message = String.format("送信対象の電文変換ジャーナルが存在しません。facility_cd:[%s]", facilityCd);
//      // メッセージのみ設定
//      JournalConvertResult result = new JournalConvertResult(HttpStatus.NO_CONTENT.value(), message);
//      return new ResponseEntity<>(result, HttpStatus.NO_CONTENT);
//    }
//
//    try {
//      // 対象ジャーナルの変換状態を「変換中」に更新する。
//      updateConvStatus(journalList, AnaResult.PROCESSING);
//
//      List<ResultMap> resultList = new ArrayList<>();
//      for (SysCoopJournal journal : journalList) {
//        // 結果格納用ResultMap
//        ResultMap rm = new ResultMap();
//        String message = "";
//        try {
//          // 電文作成
//          createTelegramByFormat(journal);
//
//          // 電文登録
//          convertSendService.storeTelegram(journal);
//          // 変換ステータスを「処理完了」に変更
//          journal.setAnaResult(AnaResult.DONE.getResult());
//          journal.setMessage(message);
//
//        } catch (NtssException e) {
//          String error = "送信用電文の作成に失敗しました。該当ジャーナルデータの変換ステータスをE1に更新し次の電文変換に移ります。";
//          eventLogMessage.setLogMessage(error + " ctl_no:[" + journal.getCtlNo() + "], facility_cd:[" + facilityCd + "], coop_cd:[" + journal.getCoopCd() + "]");
//          eventLogMessage.setFacilityCd(facilityCd);
//          logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//          // 下位メソッドからthrowされたメッセージを取得
//          // ※メッセージを設定してthrowされる前提。念のためデフォルトメッセージを設定
//          message = StringUtils.isEmpty(e.getMessage()) ? error : e.getMessage();
//          // ジャーナルの変換ステータスを変更
//          updateAnaResult(journal, message, AnaResult.INTERNAL_ERROR);
//        }
//
//        // 処理結果を設定
//        rm.put(ResultKey.CTL_NO.getKey(), journal.getCtlNo());
//        rm.put(ResultKey.MESSAGE.getKey(), journal.getMessage());
//        rm.put(ResultKey.ANA_RESULT.getKey(), journal.getAnaResult());
//        resultList.add(rm);
//      }
//
//      // 事後APIキック機能
//      for (SysCoopJournal SysCoopJournal : journalList) {
//        CallApiJournalRequest callApiJournalRequest = new CallApiJournalRequest();
//        BeanUtils.copyProperties(SysCoopJournal, callApiJournalRequest);
//        callApiJournalRequest.setApiTimingIo(ApiTimingIoStatus.CONVERT.getStatus());
//        callApiJournalRequest.setApiTimingBa(ApiTimingBaStatus.AFTER.getStatus());
//        boolean callResult = callApiService.callApiJournal(callApiJournalRequest, SysCoopJournal, null);
//        if (!callResult) {
//          break;
//        }
//      }
//
//      JournalConvertResult result = new JournalConvertResult(HttpStatus.OK.value(), resultList);
//      return new ResponseEntity<>(result, HttpStatus.OK);
//
//    } catch (Exception e) {
//      String error = String.format("変換処理(送信)で予期せぬエラーが発生しました。[%s]", e);
//      eventLogMessage.setLogMessage(error);
//      eventLogMessage.setFacilityCd(facilityCd);
//      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//      // 変換ステータスが「処理中」のレコードをすべて「内部エラー」に更新
//      // ※未処理のジャーナルのみ更新対象とする
//      journalList.stream()
//        .filter(journal -> AnaResult.PROCESSING.getResult().equals(journal.getAnaResult()))
//        .forEach(journal -> updateAnaResult(journal, error, AnaResult.INTERNAL_ERROR));
//      JournalConvertResult result = new JournalConvertResult(HttpStatus.INTERNAL_SERVER_ERROR.value(), error);
//      return new ResponseEntity<>(result, HttpStatus.INTERNAL_SERVER_ERROR);
//    }

    // 機能JournalConvertSendResourceの内容にJournalConvertSendServiceを移動する。
    // JournalConvertSendServiceのみにJournalConvertSendServiceを呼び出い。

    /* modify by chamaojia 2023-02-01 [7050] インタフェースパラメータの追加ordNo、patId, 入力値をnullに設定  --start */
    //#7239 mod 処理保留イベントの最適化処理が行われない 卓 start
    //送信しない設定
    SysCoopJournal skipSysCoopJournal = new SysCoopJournal();
    skipSysCoopJournal.setFacilityCd(request.getFacilityCd());
    skipSysCoopJournal.setOrdNo(null);
    skipSysCoopJournal.setPatId(null);
    skipSysCoopJournal.setHospPatId(null);
    journalConvertSendService.updateToSkip(skipSysCoopJournal);
    //#7781 mod 処理保留イベントの最適化処理が行われない 卓 end

    JournalConvertResult resultConvert = new JournalConvertResult(HttpStatus.OK.value(), "他スレッドにて変換処理が実行中");

    //　施設ステータスの処理中チェックと更新
    if (facilityStatusService.checkAndPutStatus(request.getFacilityCd())) {
      try {
        // ジャーナル変換処理のサービスを呼び出し
        resultConvert = journalConvertSendService.convert(request, null, null);
        /* modify by chamaojia 2023-02-01 [7050] インタフェースパラメータの追加ordNo、patId, 入力値をnullに設定  --end */
        // mod 2021-09-07 #4358:ステータス変更保存時に再処理apiがコールされないの対応 孫 start
        //    // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
        //    if (resultConvert.getStatus() == HttpStatus.OK.value()) {
        //
        //      // 成功の場合、異常データをチェックする
        //      List<ResultMap> resultListNG = new ArrayList<>();
        //      resultListNG = resultConvert.getResult();
        //      for (ResultMap resultNG : resultListNG) {
        //        if (AnaResult.INTERNAL_ERROR.getResult().equals(resultNG.get(ResultKey.ANA_RESULT.getKey()))
        //          || AnaResult.SKIP.getResult().equals(resultNG.get(ResultKey.ANA_RESULT.getKey()))) {
        //
        //          // 通知機能APIを呼び出し
        //          JSONObject replaceData = new JSONObject();
        //          replaceData.put("COOP_CD", "");
        //          Long notificationNo =  CoreConstant.NotificationDefinition.COOP_JOURNAL_SEND_TIME;
        //          notificationApiCallUtil.registerNotification(notificationNo, request.getFacilityCd(), replaceData);
        //
        //          String message = (String) resultNG.ceilingEntry(ResultKey.MESSAGE.getKey()).getValue();
        //          ErrorMessage error = new ErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR, message);
        //          return new ResponseEntity<>(error, HttpStatus.INTERNAL_SERVER_ERROR);
        //        }
        //      }
        //    } else {
        //
        //      // 失敗の場合
        //      // 通知機能APIを呼び出し
        //      JSONObject replaceData = new JSONObject();
        //      replaceData.put("COOP_CD", "");
        //
        //      Long notificationNo =  CoreConstant.NotificationDefinition.COOP_JOURNAL_SEND_TIME;
        //      notificationApiCallUtil.registerNotification(notificationNo, request.getFacilityCd(), replaceData);
        //    }
        //    // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end
        // del #7969 profile連携のスキップ処理のメッセージが処理の仕方によって異なるものが記録される 王永吉 start
        // add #7969 profile連携のスキップ処理のメッセージが処理の仕方によって異なるものが記録される 王永吉 start
        //    if (resultConvert.getResult().size() > 0){
        //      List<ResultMap> resultList = resultConvert.getResult();
        //      for (int i = 0; i < resultList.size(); i++){
        //        if ("S".equals(resultList.get(i).get("ana_result"))){
        //          if (resultList.get(i).get("ana_result") != null){
        //            String masg = resultList.get(i).get("message").toString();
        //            if (masg.startsWith("[浄化申し込み・初回指示]データが無し。")){
        //              Long journalCtlNo = Long.parseLong(resultList.get(i).get("ctl_no").toString());
        //              sysCoopJournalDao.updateInAnaResultToNull(journalCtlNo);
        //            }
        //          }
        //        }
        //      }
        //    }
        // add #7969 profile連携のスキップ処理のメッセージが処理の仕方によって異なるものが記録される 王永吉 end
        // del #7969 profile連携のスキップ処理のメッセージが処理の仕方によって異なるものが記録される 王永吉 end

        if (resultConvert.getStatus() == HttpStatus.OK.value()) {
          // 成功、かつ、正常データがあり場合
          List<JournalConvertResult.ResultMap> resultList = resultConvert.getResult();
          //     #8353 外部連携稼働ビューアからのAPI呼び出しに失敗する 卓 2023-02-21 start
          if (resultList.size() == 1) {
            String msg = (String) resultConvert.getResult().get(0).get("message");
            if (msg.contains(JournalConstant.JOURNAL_EMPTY)) {
              JournalConvertLogUtil.eventMessageError("ジャナル変換API:電文変換失敗。", request.getFacilityCd(), this.getClass().getName());
              return new ResponseEntity<>(resultConvert, HttpStatus.valueOf(resultConvert.getStatus()));
            }
          }
          //     #8353 外部連携稼働ビューアからのAPI呼び出しに失敗する 卓 2023-02-21 end
          for (JournalConvertResult.ResultMap resultTmp : resultList) {
            if (NtssCoopApiConstants.AnaResult.DONE.getResult().equals(resultTmp.get(JournalConvertResult.ResultKey.ANA_RESULT.getKey()))) {
              // WebSocketでIFedgeを連携する
              // ジャナル変換APIからIFエッジ(サーバへの電文リクエスト)に通知。
              JournalDeliveryRequest requestDelivery = new JournalDeliveryRequest();
              requestDelivery.setFacilityCd(request.getFacilityCd());
              requestDelivery.setSendType("delivery");
              if (!ifEdgeService.SendJournal(requestDelivery)) {
                EventLogMessage eventLogMessage = new EventLogMessage();
                eventLogMessage.setInvokeClass(this.getClass().getName());
                eventLogMessage.setLogMessage("ジャナル変換API：IFエッジ(サーバへの電文リクエスト)に通知失敗。");
                eventLogMessage.setFacilityCd(request.getFacilityCd());
                logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
              }
              break;
            }
          }
        }
        //     #8353 外部連携稼働ビューアからのAPI呼び出しに失敗する 卓 2023-02-21 start
        //    else if (resultConvert.getStatus() != HttpStatus.NOT_FOUND.value()) {
        //      // 失敗の場合
        //      eventLogMessage.setInvokeClass(this.getClass().getName());
        //      eventLogMessage.setLogMessage("ジャナル変換API:電文変換失敗。");
        //      eventLogMessage.setFacilityCd(request.getFacilityCd());
        //      logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
        //    }
        //     #8353 外部連携稼働ビューアからのAPI呼び出しに失敗する 卓 2023-02-21 end
        // mod 2021-09-07 #4358:ステータス変更保存時に再処理apiがコールされないの対応 孫 end
      } catch (Exception e) {
        // ジャーナル作成としては 正常として処理するため、何もしない
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setUserId((request.getUserId() == null ? "" : request.getUserId().toString()));
        eventLogMessage.setPatId((request.getPatId() == null ? "" : request.getPatId().toString()));
        eventLogMessage.setInvokeClass(this.getClass().getName());
        eventLogMessage.setLogMessage("ジャーナル変換処理の呼び出しでエラーが発生しました。Message:" + e.getMessage());
        eventLogMessage.setFacilityCd(request.getFacilityCd());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      } finally {
        // 施設ステータスに「停止(stop)」を設定する
        facilityStatusService.replace(request.getFacilityCd(), JournalConvertConstants.STATUS_STOP);
      }
    }

    return new ResponseEntity<>(resultConvert, HttpStatus.valueOf(resultConvert.getStatus()));
    // mod 2020-11-16 各API間の呼び出しフローの修正（エッジ主体からAWS主体へ）→負荷増加回避策が必要 孫 end

  }

  @Async
  public void externalCoopOperViwersend(JournalConvertSendRequest request) {
    sendLogic(request);
  }
}
// add #9406  外部連携稼働ビューア API呼び出しに失敗する 20231016 孟堅 end
