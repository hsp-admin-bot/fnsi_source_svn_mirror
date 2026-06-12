package jp.co.nikkiso.ntss.coop_api.web.rest;

import jp.co.nikkiso.ntss.coop_api.service.IfEdgeService;
import jp.co.nikkiso.ntss.coop_api.service.JournalConvertSendService;
import jp.co.nikkiso.ntss.coop_api.service.LogService;
import jp.co.nikkiso.ntss.coop_api.service.externalCoopOper.CoopSendServiceImpl;
import jp.co.nikkiso.ntss.coop_api.utils.NotificationApiCallUtil;
import jp.co.nikkiso.ntss.coop_api.web.rest.JournalConvertReceiveResource;
import jp.co.nikkiso.ntss.core.dao.SysCoopJournalDao;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.coop_api.request.JournalConvertReceiveRequest;
import jp.co.nikkiso.ntss.coop_api.request.JournalConvertSendRequest;

@RestController
@RequestMapping("/journal/convert")
public class JournalConvertSendResource {

  // mod 2020-11-16 各API間の呼び出しフローの修正（エッジ主体からAWS主体へ）→負荷増加回避策が必要 孫 start
//  @Autowired
//  private ConvertCommonService convertCommonService;
//
//  @Autowired
//  private ConvertSendCommonService convertSendService;
//
//  @Autowired
//  private ConvertSendByFormatService convertSendTextServiceImpl;
//
//  @Autowired
//  private ConvertSendByFormatService convertSendXmlServiceImpl;
//
//  @Autowired
//  private ConvertSendByFormatService convertSendPdfServiceImpl;
//
//  @Autowired
//  private LogService logService;
//
//  @Autowired
//  private CallApiService callApiService;

  @Autowired
  private JournalConvertSendService journalConvertSendService;
  // mod 2020-11-16 各API間の呼び出しフローの修正（エッジ主体からAWS主体へ）→負荷増加回避策が必要 孫 end

  // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
  @Autowired
  private NotificationApiCallUtil notificationApiCallUtil;
  // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end

  // add 2021-09-07 #4358:ステータス変更保存時に再処理apiがコールされないの対応 孫 start
  @Autowired
  IfEdgeService ifEdgeService;

  @Autowired
  private LogService logService;
  // add 2021-09-07 #4358:ステータス変更保存時に再処理apiがコールされないの対応 孫 end

  // add #7969 profile連携のスキップ処理のメッセージが処理の仕方によって異なるものが記録される 王永吉 start
  @Autowired
  private SysCoopJournalDao sysCoopJournalDao;
  // add #7969 profile連携のスキップ処理のメッセージが処理の仕方によって異なるものが記録される 王永吉 end
  // add #9406  外部連携稼働ビューア API呼び出しに失敗する 20231016 孟堅 start
  @Autowired
  private CoopSendServiceImpl coopSendServiceImpl;
  // add #9406  外部連携稼働ビューア API呼び出しに失敗する 20231016 孟堅 end
  @Autowired
  private JournalConvertReceiveResource journalConvertReceiveResource;
  // mod #9406  外部連携稼働ビューア API呼び出しに失敗する 20231016 孟堅 start
  /**
   * 変換処理(/journal/convert)
   * @param request : {@link JournalConvertSendRequest}
   * @return {@link ResponseEntity}
   */
  @PostMapping("/send")
  public ResponseEntity<?> convert(@RequestBody JournalConvertSendRequest request) {
    return coopSendServiceImpl.sendLogic(request);
  }
  // mod #9406  外部連携稼働ビューア API呼び出しに失敗する 20231016 孟堅 end

  // add #9406  外部連携稼働ビューア API呼び出しに失敗する 20231016 孟堅 start
  @PostMapping("/externalCoopOperViwersend")
  public  ResponseEntity<?> externalCoopOperViwersend(@RequestBody JournalConvertSendRequest request){
    coopSendServiceImpl.externalCoopOperViwersend(request);
    return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
  }

  @PostMapping("/externalCoopOperViwerReceive")
  public ResponseEntity<?> externalCoopOperViwerReceive(@RequestBody JournalConvertReceiveRequest request){
    journalConvertReceiveResource.reconvert(request);
    return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
  }
  // add #9406  外部連携稼働ビューア API呼び出しに失敗する 20231016 孟堅 end
  // del 2020-11-16 各API間の呼び出しフローの修正（エッジ主体からAWS主体へ）→負荷増加回避策が必要 孫 start
//  /**
//   * ジャーナルの変換ステータスを更新する。
//   *
//   * @param journalList ジャーナルのリスト
//   * @param status 変換ステータス
//   * @return 更新件数
//   */
//  private int updateConvStatus(List<SysCoopJournal> journalList, AnaResult status) {
//    // ジャーナルリストの変換ステータスを変更
//    journalList.forEach(e -> e.setAnaResult(status.getResult()));
//    List<Long> ctlNoList = journalList.stream().map(e -> e.getCtlNo()).collect(Collectors.toList());
//    return convertCommonService.updateConvStatus(ctlNoList, status.getResult());
//  }
//
//  /**
//   * ジャーナルの変換ステータスを更新する
//   * ※レコード単位での更新
//   *
//   * @param journal 更新対象のジャーナル
//   * @param message メッセージ
//   * @param status 更新する変換ステータス
//   * @return 更新件数
//   * */
//  private int updateAnaResult(SysCoopJournal journal, String message, AnaResult status) {
//    journal.setAnaResult(status.getResult());
//    journal.setMessage(message);
//    return convertCommonService.updateAnaResult(journal.getCtlNo(), message, status.getResult());
//  }
//
//  /**
//   * 電文作成
//   *
//   * @param journal 変換対象のsys_coop_journal
//   * */
//  private void createTelegramByFormat(SysCoopJournal journal) {
//    String facilityCd = journal.getFacilityCd();
//    String coopCd = journal.getCoopCd();
//    String coopCdIndex = journal.getCoopCdIndex();
//    String direction = journal.getDirection();
//
//    MstCoopLayout mcl = convertCommonService.getMstCoopLayout(facilityCd, direction, coopCd, coopCdIndex, getCoopCdSub(journal.getCrud()));
//
//    String coopCdSub = mcl.getCoopCdSub();
//    String format = mcl.getCoopFormat();
//
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage("[" + this.getClass().getSimpleName() + "]#convertByFormat: facility_cd:[" + facilityCd + "], "
//        + "direction:[" + direction + "], coop_cd:[" + coopCd + "], coop_cd_sub:[" + coopCdSub + "], coop_format:[" + format + "]");
//    eventLogMessage.setFacilityCd(facilityCd);
//    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//
//    switch (format) {
//      case JournalConvertConstants.FORMAT_TEXT:
//        convertSendTextServiceImpl.createTelegram(journal);
//      break;
//
//      case JournalConvertConstants.FORMAT_XML:
//        convertSendXmlServiceImpl.createTelegram(journal);
//        break;
//
//      case JournalConvertConstants.FORMAT_PDF:
//        convertSendPdfServiceImpl.createTelegram(journal);
//        break;
//
//      default:
//        String errMsg = String.format("未対応の電文フォーマットです。フォーマット:[%s]", format);
//        eventLogMessage.setLogMessage(errMsg);
//        eventLogMessage.setFacilityCd(facilityCd);
//        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//        throw new NtssException(errMsg);
//    }
//  }
//
//  /**
//   * mst_coop_layoutおよびmst_coop_layout_detailのcoop_cd_subを求めます
//   *
//   * @param crud - sys_coop_journal.crud
//   * @return coop_cd_sub
//   */
//  private String getCoopCdSub(String crud) {
//    return convertSendService.getCoopCdSub(crud);
//  }
  // del 2020-11-16 各API間の呼び出しフローの修正（エッジ主体からAWS主体へ）→負荷増加回避策が必要 孫 end
}
