package jp.co.nikkiso.ntss.coop_api.service;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;
import java.util.stream.Collectors;

import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import jp.co.nikkiso.ntss.coop_api.request.CallApiJournalRequest;
import jp.co.nikkiso.ntss.coop_api.request.JournalConvertSendRequest;
import jp.co.nikkiso.ntss.coop_api.response.JournalConvertResult;
import jp.co.nikkiso.ntss.coop_api.response.JournalConvertResult.ResultKey;
import jp.co.nikkiso.ntss.coop_api.response.JournalConvertResult.ResultMap;
import jp.co.nikkiso.ntss.coop_api.utils.CoopCdConstant;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants;
import jp.co.nikkiso.ntss.coop_api.utils.JournalLogUtil;
import jp.co.nikkiso.ntss.coop_api.utils.JournalSendSkipConstant;
import jp.co.nikkiso.ntss.coop_api.utils.Key0Constant;
import jp.co.nikkiso.ntss.coop_api.utils.NotificationApiCallUtil;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants.AnaResult;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants.ApiTimingBaStatus;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants.ApiTimingIoStatus;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants.CoopResult;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants.Crud;
import jp.co.nikkiso.ntss.coop_api.utils.OrdCoopNoConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MstCoopFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopIniDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatCoopDetailDao;
import jp.co.nikkiso.ntss.core.dao.PatExamMainDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.SysCoopJournalDao;
import jp.co.nikkiso.ntss.core.entity.MstCoopFacility;
import jp.co.nikkiso.ntss.core.entity.MstCoopLayout;
import jp.co.nikkiso.ntss.core.entity.OrdCoopNo;
import jp.co.nikkiso.ntss.core.entity.PatCoopDetail;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;

@Service
public class JournalConvertSendServiceImpl implements JournalConvertSendService {

  @Autowired
  private ConvertCommonService convertCommonService;

  @Autowired
  private ConvertSendCommonService convertSendService;

  @Autowired
  private ConvertSendByFormatService convertSendTextServiceImpl;

  @Autowired
  private ConvertSendByFormatService convertSendXmlServiceImpl;

  @Autowired
  private ConvertSendByFormatService convertSendPdfServiceImpl;

  @Autowired
  private ConvertSendByFormatService convertSendCsvServiceImpl;

  @Autowired
  private LogService logService;

  @Autowired
  private CallApiService callApiService;

  // add 2020-12-09 FNSI-改修 外部連携727 夏 start
  @Autowired
  private JournalService journalService;
  // add 2020-12-09 FNSI-改修 外部連携727 夏 end

  // add 2020-12-21 FNSI-改修内容 変換処理中の処理スキップ機能を追加 商 start
  @Autowired
  private MstCoopFacilityDao mstCoopFacilityDao;
  // add 2020-12-21 FNSI-改修内容 変換処理中の処理スキップ機能を追加 商 end
  @Autowired
  private SysCoopJournalDao sysCoopJournalDao;

  // add 2021-03-24 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
  @Autowired
  private NotificationApiCallUtil notificationApiCallUtil;
  // add 2021-03-24 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end
  @Autowired
  private OrdCoopNoService ordCoopNoService;
  @Autowired
  private MstCoopIniService mstCoopIniService;
  // add #7717 浄化申込の削除を受信した患者の動作について 王永吉 start
  @Autowired
  private PatCoopDetailDao patCoopDetailDao;
  @Autowired
  private MstCoopIniDao mstCoopIniDao;
  // add #7717 浄化申込の削除を受信した患者の動作について 王永吉 end

  // #8180-ind_dial連携で出力するファイルの命名が行われない 周 add start
  // @Autowired
  // private MstCoopLayoutDao mstCoopLayoutDao;
  @Autowired
  private ConvertSendCommonService convertSendCommonService;
  // del 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
  // @Autowired
  // private MstCoopLayoutService mstCoopLayoutService;
  // del 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end
  @Autowired PatMainDao patMainDao;
  @Autowired OrdMainDao ordMainDao;
  // #8180-ind_dial連携で出力するファイルの命名が行われない 周 add end

  // add 7712 富士通指摘：患者プロファイルの登録数が大量の患者の連携について 王永吉 start
  // @Autowired
  // private JournalConvertReceiveResource journalConvertReceiveResource;
  // add 7712 富士通指摘：患者プロファイルの登録数が大量の患者の連携について 王永吉 end

  // add 8208 検査依頼一覧で検査予定を作成した際のjournal登録が正しく行われない 20230210 zhaoqi start
  @Autowired
  private PatExamMainDao patExamMainDao;
  // add 8208 検査依頼一覧で検査予定を作成した際のjournal登録が正しく行われない 20230210 zhaoqi end

  // add 9583 by kangjie 20240401 start 通知一覧の連携エラー通知の遷移不正
  @Autowired
  private CoopJournalErrorComponent coopJournalErrorComponent;
  // add 9583 by kangjie 20240401 end 通知一覧の連携エラー通知の遷移不正

  /**
   * ジャーナル変換処理
   *
   * @param request : {@link JournalConvertSendRequest}
   * @param ordNo   （次世代FN)オーダ番号
   * @param patId   患者番号（システム）
   * @return {@link boolean}
   */
  // del 2023-02-06 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  // @Transactional
  // del 2023-02-06 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  @Override
  /* modify by chamaojia 2023-02-01 [7050] インタフェースパラメータの追加ordNo、patId --start */
  public JournalConvertResult convert(JournalConvertSendRequest request, Long ordNo, Long patId) {
    /* modify by chamaojia 2023-02-01 [7050] インタフェースパラメータの追加ordNo、patId --end */
    if (!request.validate()) {
      String error = String.format("リクエストパラメータが不正または不足しています。facility_cd:[%s]", request.getFacilityCd());
      JournalConvertResult result = new JournalConvertResult(HttpStatus.BAD_REQUEST.value(), error);

      // メッセージのみ設定
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(error);
      eventLogMessage.setFacilityCd(request.getFacilityCd());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return result;
    }

    String facilityCd = request.getFacilityCd();

    // 変換対象ジャーナル取得
    List<SysCoopJournal> journalList = convertCommonService.getJournalList(facilityCd
      , JournalConvertConstants.DIRECTION_SEND
      , NtssCoopApiConstants.CoopResult.UNPROCESS.getResult()
        /* modify by chamaojia 2023-02-01 [7050] インタフェースパラメータの追加ordNo、patId --start */
        /* add by chamaojia 2023-01-10 [7050] インタフェースパラメータの追加 --start */
        // なしはnull値を入力します
        , null, ordNo, patId);
    /* add by chamaojia 2023-01-10 [7050] インタフェースパラメータの追加 --end */
    /* modify by chamaojia 2023-02-01 [7050] インタフェースパラメータの追加ordNo、patId --end */
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(String.format("%s:convert:journalList=%s", request.getFacilityCd(), journalList));
    eventLogMessage.setFacilityCd(facilityCd);
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    // 対象ジャーナルが1件も存在しない場合
    if (CollectionUtils.isEmpty(journalList)) {
      // 準正常応答とするが、NO_CONTENTを返す。
      String message = String.format("送信対象の電文変換ジャーナルが存在しません。facility_cd:[%s]", facilityCd);
      // メッセージのみ設定
      // mod 2021-05-19 [JSON parse error:データ無し場合、NOT_FOUNDを返す]の対応 孫 start

//      JournalConvertResult result = new JournalConvertResult(HttpStatus.NO_CONTENT.value(), message);
      // #8353 外部連携稼働ビューアからのAPI呼び出しに失敗する 卓 2023-02-21 start
//      JournalConvertResult result = new JournalConvertResult(HttpStatus.NOT_FOUND.value(), message);
      JournalConvertResult result = new JournalConvertResult(HttpStatus.OK.value(), message);
      // #8353 外部連携稼働ビューアからのAPI呼び出しに失敗する 卓 2023-02-21 end
      // mod 2021-05-19 [JSON parse error:データ無し場合、NOT_FOUNDを返す]の対応 孫 end

      // メッセージのみ設定
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(message);
      eventLogMessage.setFacilityCd(facilityCd);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return result;
    }

    // 同ord_noのジャーナル解析は直列化対応する
    // 処理中ジャーナル取得
    List<SysCoopJournal> processingJournalList = convertCommonService.getProcessingJournalList(facilityCd
      , JournalConvertConstants.DIRECTION_SEND
      , ordNo, patId);

    // 対象ジャーナルに処理中ジャーナルと同じord_no, pat_id, coop_versionのジャーナルがあれば除く
    for (SysCoopJournal processingJournal : processingJournalList) {
      journalList = journalList.stream().filter(journal ->
          !journal.getOrdNo().equals(processingJournal.getOrdNo())
          || !journal.getPatId().equals(processingJournal.getPatId())
          || !journal.getCoopVersion().equals(processingJournal.getCoopVersion()))
        .collect(Collectors.toList());
    }

    // 対象ジャーナルがいずれも処理中ジャーナルと同じord_no, pat_id, coop_versionで対象ジャーナルが残らなかった場合
    if (CollectionUtils.isEmpty(journalList)) {
      JournalConvertResult result = new JournalConvertResult(HttpStatus.OK.value(), "");

      String message = String.format("同ord_noのジャーナルが変換処理中のため処理しません。facility_cd:[%s]", facilityCd);
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(message);
      eventLogMessage.setFacilityCd(facilityCd);
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return result;
    }

    try {
      /* modify by chamaojia 2023-06-20 プロセスを続行するために成功したレコードを返す --start */
      // 対象ジャーナルの変換状態を「変換中」に更新する。
      List<SysCoopJournal> successJournalList = updateConvStatus(journalList, AnaResult.PROCESSING);
      /* modify by chamaojia 2023-06-20 プロセスを続行するために成功したレコードを返す --end */

      /* del by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
      // // add 2021-09-16 #5897:CSI連携ができないの対応 孫 start
      // // 連携設定マスタを取得する
      // List<MstCoopIni> coopIniList = convertCommonService.getMstCoopIniByFacilityCd(facilityCd);
      // // 連携設定情報を設定する
      // CoopIniConvUtil.SetData(facilityCd, coopIniList);
      // // add 2021-09-16 #5897:CSI連携ができないの対応 孫 end
      /* del by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

      List<ResultMap> resultList = new ArrayList<>();

      // add 2020-12-21 FNSI-改修内容 変換処理中の処理スキップ機能を追加 商 start
      List<MstCoopFacility.CoopOrdCd> coopOrdCdList = new ArrayList<>();
      MstCoopFacility mstCoopFacility = mstCoopFacilityDao.select(facilityCd);
      if (mstCoopFacility != null) {
        if (mstCoopFacility.getCommonSetting().getCoopOrdCds() != null &&
            mstCoopFacility.getCommonSetting().getCoopOrdCds().size() > 0) {
          coopOrdCdList = mstCoopFacility.getCommonSetting().getCoopOrdCds();
        }
      }
      // add 2020-12-21 FNSI-改修内容 変換処理中の処理スキップ機能を追加 商 end

      for (SysCoopJournal journal : successJournalList) {
        // 結果格納用ResultMap
        ResultMap rm = new ResultMap();
        String message = "";
        // add 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
        String coopVersion = StringUtils.isEmpty(journal.getCoopVersion()) ? "" : journal.getCoopVersion();
        // add 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

        // add #7717 浄化申込の削除を受信した患者の動作について 王永吉 start
        // mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
        // // ini設定を取得する
        // List<MstCoopIni> values = mstCoopIniDao.selectByFacilityCd(facilityCd);
        // if (null != values) {
        // MstCoopIni value = values.get(0);
        // String memo = value.getCoopIniMemo();
        // // GXの場合、そして新しい患者じゃないの場合
//          if ("富士通GX".equals(memo) && journal.getPatId() != null && journal.getPatId() != 0) {
        String key0 = StringUtils.isEmpty(journal.getKey0()) ? "" : journal.getKey0();
        // GXの場合、そして新しい患者じゃないの場合
        if (Key0Constant.GX.equals(key0) && journal.getPatId() != null && journal.getPatId() != 0) {
          // mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
          // mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//            PatCoopDetail chekPatCoopDetailIn = patCoopDetailDao.selectByPatId(journal.getPatId(), facilityCd);
          // del 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//            String coopVersion = StringUtils.isEmpty(journal.getCoopVersion()) ? "" : journal.getCoopVersion();
          // del 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
          PatCoopDetail chekPatCoopDetailIn = patCoopDetailDao.selectByPatId(journal.getPatId(), facilityCd, coopVersion);
          // mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
          // 送信種別コードが"患者プロファイル"、"透析予約"、"透析実績"、"透析レポート"、"検査オーダ"、"放射線検査オーダ"、"心電図検査オーダ"の場合、患者の浄化申込をしたかどうかの判定
          List<String> coopCdEnums = Arrays.asList("profile", "ind_dial", "rst_dial", "rep_dial", "exam_ord", "rad_ord", "phy_ord");
          if (chekPatCoopDetailIn == null && (coopCdEnums.contains(journal.getCoopCd()))) {
//            if (chekPatCoopDetailIn == null && ("profile".equals(journal.getCoopCd()) || "ind_dial".equals(journal.getCoopCd()) ||
//                    "rst_dial".equals(journal.getCoopCd()) || "rep_dial".equals(journal.getCoopCd()) || "exam_ord".equals(journal.getCoopCd()) ||
//                    "rad_ord".equals(journal.getCoopCd()) || "phy_ord".equals(journal.getCoopCd()))) {
            // mod #7717 浄化申込の削除を受信した患者の動作について 王永吉 start
            // message = "[患者連携情報]データが無し。この患者[" + journal.getHospPatId() + "]は連携したことがない。";
            message = "[浄化申し込み・初回指示]データが無し。この患者[" + journal.getHospPatId() + "]は連携したことがない。";
            // mod #7717 浄化申込の削除を受信した患者の動作について 王永吉 end
            // 電文登録
            // #8348 profile連携の定時処理で作成されたjournalが処理されない 2023-03-31 卓 ---start
            // add #7969 profile連携のスキップ処理のメッセージが処理の仕方によって異なるものが記録される 王永吉 start
            // updateAnaResultNotCallApi(journal, message, AnaResult.PROCESSING);
            // add #7969 profile連携のスキップ処理のメッセージが処理の仕方によって異なるものが記録される 王永吉 end
            // updateAnaResultNotCallApi(journal, message, AnaResult.SKIP);
            journal.setMessage(message);
            journal.setAnaResult(AnaResult.SKIP.getResult());
            journal.setCoopResult(CoopResult.SKIP.getResult());
            journalService.updateJournalSkipWithDate(journal);
            // #8348 profile連携の定時処理で作成されたjournalが処理されない 2023-03-31 卓 ---start
            // 処理結果を設定
            rm.put(ResultKey.CTL_NO.getKey(), journal.getCtlNo());
            rm.put(ResultKey.MESSAGE.getKey(), journal.getMessage());
            rm.put(ResultKey.ANA_RESULT.getKey(), journal.getAnaResult());
            resultList.add(rm);
            continue;
          }
        }
        // del 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
        // }
        // del 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
        // add #7717 浄化申込の削除を受信した患者の動作について 王永吉 end

        // 最新の状態を取得後、スキップされていないかチェック
        SysCoopJournal ckeckJournal = sysCoopJournalDao.selectByPK(journal.getCtlNo());
        if (CoopResult.SKIP.isSameResult(ckeckJournal.getCoopResult())) {
          // convert待機中にスキップされたので解析処理しない。ana_result=Sに更新
          journal.setMessage(ckeckJournal.getMessage());
          journal.setAnaResult(AnaResult.SKIP.getResult());
          journal.setCoopResult(CoopResult.SKIP.getResult());
          journalService.updateJournalSkipWithDate(journal);
          // 処理結果を設定
          rm.put(ResultKey.CTL_NO.getKey(), ckeckJournal.getCtlNo());
          rm.put(ResultKey.MESSAGE.getKey(), ckeckJournal.getMessage());
          rm.put(ResultKey.ANA_RESULT.getKey(), ckeckJournal.getAnaResult());
          resultList.add(rm);
          continue;
        }

        // #7239 2022-12-5 add 処理保留イベントの最適化処理が行われない 卓 start
        String errorCoopOrdNo = journalService.executeCoopOrdNoProc(journal);
        // #7239 2022-12-5 add 処理保留イベントの最適化処理が行われない 卓 end

        try {
          // add 2020-12-21 FNSI-改修内容 変換処理中の処理スキップ機能を追加 商 start
          boolean timeOutFlg = false;
          ExecutorService executor = Executors.newFixedThreadPool(1);
          Callable myCallable = new Callable() {
            @Override
            public String call() {
              // 電文作成
              createTelegramByFormat(journal);
              return "Success";
            }
          };
          Future<String> future = executor.submit(myCallable);
          try {
            // mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//            String result = future.get(getTimeOutSecond(journal.getCoopCd(), coopOrdCdList), TimeUnit.SECONDS);
            String coopVersionForTimeout = StringUtils.isEmpty(journal.getCoopVersion()) ? "" : journal.getCoopVersion();
            String result = future.get(getTimeOutSecond(journal.getCoopCd(), coopVersionForTimeout, coopOrdCdList), TimeUnit.SECONDS);
            // mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
            // mod 2021/04/20 bug #4267　エラーのはずがスキップになる 対応 start
            // } catch (InterruptedException |ExecutionException | TimeoutException e) {
          } catch (TimeoutException e) {
            // add #12299 【因島】NKK連携 rep_dial pdfのana_resuletがタイムアウトによりE1でエラーとなりPDFの送信ができないことがある 吉 start
            TimeoutException ex = e;
            if("rep_dial".equals(journal.getCoopCd()) && "pdf".equals(journal.getCoopCdIndex()) && "NKK".equals(journal.getKey0())){
              future.cancel(true);
              executor.shutdown();
              ExecutorService executor1 = Executors.newFixedThreadPool(1);
              try {
                Callable myCallable1 = new Callable() {
                  @Override
                  public String call() {
                    // 電文作成
                    createTelegramByFormat(journal);
                    return "Success";
                  }
                };
                Future<String> future1 = executor1.submit(myCallable1);
                String coopVersionForTimeout = StringUtils.isEmpty(journal.getCoopVersion()) ? "" : journal.getCoopVersion();
                future1.get(getTimeOutSecond(journal.getCoopCd(), coopVersionForTimeout, coopOrdCdList), TimeUnit.SECONDS);
              } catch (TimeoutException e1) {
                ex = e1;
                timeOutFlg = true;
                executor1.shutdown();
                future.cancel(true);
              }
            } else {
              timeOutFlg = true;
            }
            e = ex;
            if (timeOutFlg) {
              // add #12299 【因島】NKK連携 rep_dial pdfのana_resuletがタイムアウトによりE1でエラーとなりPDFの送信ができないことがある 吉 end
              // mod 2021/04/20 bug #4267　エラーのはずがスキップになる 対応 end
              future.cancel(true);
              // mod bug 7558 修正 chen start
              // String error = "送信用電文の作成に失敗しました。該当ジャーナルデータの変換ステータスをSに更新し次の電文変換に移ります。";
              // #8086-電文作成処理タイムアウトの変換ステータスがエラーではなくスキップになっている 周 mod start
            //String error = "電文作成処理タイムアウトのため送信用電文の作成に失敗しました。該当ジャーナルデータの変換ステータスをSに更新し次の電文変換に移ります。";
              String error = "電文作成処理タイムアウトのため送信用電文の作成に失敗しました。該当ジャーナルデータの変換ステータスをE1に更新し次の電文変換に移ります。";
              // #8086-電文作成処理タイムアウトの変換ステータスがエラーではなくスキップになっている 周 mod end
              // mod bug 7558 修正 chen end
              eventLogMessage = new EventLogMessage();
              // mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//            eventLogMessage.setLogMessage(error + " ctl_no:[" + journal.getCtlNo() + "], facility_cd:[" + facilityCd + "], coop_cd:[" + journal.getCoopCd() + "]");
              eventLogMessage.setLogMessage(error + " ctl_no:[" + journal.getCtlNo() + "], facility_cd:[" + facilityCd
                  + "], coop_cd:[" + journal.getCoopCd() + "], coop_version:[" + coopVersion + "]");
              // mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
              eventLogMessage.setFacilityCd(facilityCd);
              eventLogMessage.setInvokeClass(this.getClass().getName());
              logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
              // 下位メソッドからthrowされたメッセージを取得
              // ※メッセージを設定してthrowされる前提。念のためデフォルトメッセージを設定
              message = StringUtils.isEmpty(e.getMessage()) ? error : e.getMessage();
              // ジャーナルの変換ステータスを変更
              // mod 2021-06-10 #5279:API連動の処理順番が正しくない 孫 start
              // updateAnaResult(journal, message, AnaResult.SKIP);
              // #8086-電文作成処理タイムアウトの変換ステータスがエラーではなくスキップになっている 周 mod start
              // updateAnaResultNotCallApi(journal, message, AnaResult.SKIP);
              updateAnaResultNotCallApi(journal, message, AnaResult.INTERNAL_ERROR);
              // #8086-電文作成処理タイムアウトの変換ステータスがエラーではなくスキップになっている 周 mod end
              // mod 2021-06-10 #5279:API連動の処理順番が正しくない 孫 end

              // add 2021-03-24 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
              // modify 9583 by kangjie 20240401 start 通知一覧の連携エラー通知の遷移不正
//            notificationApiCallUtil.registerNotification(journal.getFacilityCd(), journal.getCoopCd(),
              // journal.getHospPatId(), journal.getBaseDate());
              coopJournalErrorComponent.sendCoopJournalError(journal);
              // modify 9583 by kangjie 20240401 end 通知一覧の連携エラー通知の遷移不正
              // add 2021-03-24 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end
            }
          } finally {
            executor.shutdown();
          }
          // add 2020-12-21 FNSI-改修内容 変換処理中の処理スキップ機能を追加 商 end
          // del 2020-12-21 FNSI-改修内容 変換処理中の処理スキップ機能を追加 商 start
          // 電文作成
          // createTelegramByFormat(journal);
          // del 2020-12-21 FNSI-改修内容 変換処理中の処理スキップ機能を追加 商 end

          // mod 2020-12-21 FNSI-改修内容 変換処理中の処理スキップ機能を追加 商 start
          // 電文登録
          // convertSendService.storeTelegram(journal);
          // 変換ステータスを「処理完了」に変更
          // journal.setAnaResult(AnaResult.DONE.getResult());
          // journal.setMessage(message);
          if (!timeOutFlg) {
            // add 2022-11-08 bug #7113 rep_dial連携の処理タイミングがずれる 孫 start
            // 帳票データを更新する。
            convertCommonService.updateReportData(journal);
            // add 2022-11-08 bug #7113 rep_dial連携の処理タイミングがずれる 孫 end
            // #8216-rst_dial連携で不要なファイル命名が行われる 周 add start
            String coopCd = journal.getCoopCd();
            String dumpPath = journal.getDumpPath();
            if ((!"rep_dial".equals(coopCd) && StringUtils.isEmpty(dumpPath)) || ("rep_dial".equals(coopCd) && StringUtils.isEmpty(dumpPath))) {
              // #8216-rst_dial連携で不要なファイル命名が行われる 周 add end
              // #8180-ind_dial連携で出力するファイルの命名が行われない 周 add start
              // #7525 rst_dial連携（拡張）ヘッダON/OFF切り替え start
//            MstCoopLayout layout = mstCoopLayoutDao.select(facilityCd, journal.getCoopCd(), journal.getCoopCdIndex(), JournalConvertConstants.DIRECTION_SEND, getCoopCdSub(journal.getCrud()));
              // mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
              // // 7525 rst_dial連携（拡張）ヘッダON/OFF切り替え 卓 2023-2-2 start
////    MstCoopLayout layout=mstCoopLayoutService.getMstCoopLayoutByMstCoopIni(journal);
//              MstCoopLayout layout = mstCoopLayoutService.getMstCoopLayout(journal, JournalConvertConstants.DIRECTION_SEND);
              // // 7525 rst_dial連携（拡張）ヘッダON/OFF切り替え 卓 2023-2-2 end
              String direction = journal.getDirection();
              String coopCdIndex = journal.getCoopCdIndex();
              String coopCdSub = convertSendCommonService.getCoopCdSub(journal.getCrud());
              MstCoopLayout layout = convertCommonService.getMstCoopLayoutBySub(facilityCd, direction, coopCd,
                  coopCdIndex, coopVersion, coopCdSub);
              // mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end
              journal.setDumpPath(convertSendCommonService.getDumpFileName(layout, journal));
              // #7525 rst_dial連携（拡張）ヘッダON/OFF切り替え end
              // #8180-ind_dial連携で出力するファイルの命名が行われない 周 add end
              // #8216-rst_dial連携で不要なファイル命名が行われる 周 add start
            }
            // #8216-rst_dial連携で不要なファイル命名が行われる 周 add end
            // 電文登録
            convertSendService.storeTelegram(journal);
            // 変換ステータスを「処理完了」に変更
            journal.setAnaResult(AnaResult.DONE.getResult());
            journal.setMessage(message);
          }
          // mod 2020-12-21 FNSI-改修内容 変換処理中の処理スキップ機能を追加 商 end
          // mod 2021/04/20 bug #4267　エラーのはずがスキップになる 対応 start
          // } catch (NtssException e) {
          // upd #8567 （#8179问题调查结果）外部連携全般に必要な機能が制限されている改正 ztc 0508 start
          // updateJournalcheckdoctor(journal);
          // upd #8567 （#8179问题调查结果）外部連携全般に必要な機能が制限されている改正 ztc 0508 end
        } catch (InterruptedException | ExecutionException | NtssException e) {
          // mod 2021/04/20 bug #4267　エラーのはずがスキップになる 対応 end
          String error = "送信用電文の作成に失敗しました。該当ジャーナルデータの変換ステータスをE1に更新し次の電文変換に移ります。";
          eventLogMessage = new EventLogMessage();
          // mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//          eventLogMessage.setLogMessage(error + " ctl_no:[" + journal.getCtlNo() + "], facility_cd:[" + facilityCd + "], coop_cd:[" + journal.getCoopCd() + "]");
          eventLogMessage.setLogMessage(error + " ctl_no:[" + journal.getCtlNo() + "], facility_cd:[" + facilityCd
              + "], coop_cd:[" + journal.getCoopCd() + "], coop_version:[" + coopVersion + "]");
          // mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
          eventLogMessage.setFacilityCd(facilityCd);
          // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
          eventLogMessage.setInvokeClass(this.getClass().getName());
          // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
          logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          // 下位メソッドからthrowされたメッセージを取得
          // ※メッセージを設定してthrowされる前提。念のためデフォルトメッセージを設定
          message = StringUtils.isEmpty(e.getMessage()) ? error : e.getMessage();
          // add 2021-11-19 #5888:NEC連携ができない(バイタル連携) 孫 start
          StackTraceElement[] list = null;
          String errAdd = "";
          if (e.getCause() != null && e.getCause().getStackTrace() != null
              && e.getCause().getStackTrace().length > 0) {
            list = e.getCause().getStackTrace();
            for (StackTraceElement err : list) {
              if (err != null && err.toString().startsWith("jp.co.")) {
                errAdd = errAdd + "\r\n" + err.toString();
              }
            }
          }
          if (StringUtils.isEmpty(errAdd)) {
            list = e.getStackTrace();
            for (StackTraceElement err : list) {
              if (err != null && err.toString().startsWith("jp.co.")) {
                errAdd = errAdd + "\r\n" + err.toString();
              }
            }
          }
          message = message + "[" + errAdd + "]";
          // add 2021-11-19 #5888:NEC連携ができない(バイタル連携) 孫 end
          // ジャーナルの変換ステータスを変更
          // mod 2022-03-14 #7208:電文作成処理をスキップする機能がない 孫 start
          // // mod 2021-06-10 #5279:API連動の処理順番が正しくない 孫 start
          //// updateAnaResult(journal, message, AnaResult.INTERNAL_ERROR);
          // updateAnaResultNotCallApi(journal, message, AnaResult.INTERNAL_ERROR);
          // // mod 2021-06-10 #5279:API連動の処理順番が正しくない 孫 end
          if (!StringUtils.isEmpty(e.getMessage()) && e.getMessage().contains("ERROR[IS_ZERO_END]")) {
            updateAnaResultNotCallApi(journal, message, AnaResult.SKIP);
          } else {
            updateAnaResultNotCallApi(journal, message, AnaResult.INTERNAL_ERROR);
          }
          // mod 2022-03-14 #7208:電文作成処理をスキップする機能がない 孫 end

          // add 2021-03-24 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
          // modify 9583 by kangjie 20240401 start 通知一覧の連携エラー通知の遷移不正
//          notificationApiCallUtil.registerNotification(journal.getFacilityCd(), journal.getCoopCd(),
          // journal.getHospPatId(), journal.getBaseDate());
          coopJournalErrorComponent.sendCoopJournalError(journal);
          // modify 9583 by kangjie 20240401 end 通知一覧の連携エラー通知の遷移不正
          // add 2021-03-24 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end
        }

        // 処理結果を設定
        rm.put(ResultKey.CTL_NO.getKey(), journal.getCtlNo());
        rm.put(ResultKey.MESSAGE.getKey(), journal.getMessage());
        rm.put(ResultKey.ANA_RESULT.getKey(), journal.getAnaResult());
        resultList.add(rm);
      }

      // 事後APIキック機能
      for (SysCoopJournal SysCoopJournal : successJournalList) {
        CallApiJournalRequest callApiJournalRequest = new CallApiJournalRequest();
        BeanUtils.copyProperties(SysCoopJournal, callApiJournalRequest);
        callApiJournalRequest.setApiTimingIo(ApiTimingIoStatus.CONVERT.getStatus());
        callApiJournalRequest.setApiTimingBa(ApiTimingBaStatus.AFTER.getStatus());
        boolean callResult = callApiService.callApiJournal(callApiJournalRequest, SysCoopJournal, null);
        if (!callResult) {
          break;
        }
      }

      // add 2021-06-10 #5279:API連動の処理順番が正しくない 孫 start
      // 変換処理api呼び出し完了時(事後APIキック機能)、処理結果が「処理完了時、処理エラー時、処理スキップ時」のAPIキック機能を呼び出し
      for (SysCoopJournal SysCoopJournal : successJournalList) {
        CallApiJournalRequest callApiJournalRequest = new CallApiJournalRequest();
        BeanUtils.copyProperties(SysCoopJournal, callApiJournalRequest);
        String statusCode = SysCoopJournal.getAnaResult();
        if (NtssCoopApiConstants.AnaResult.DONE.getResult().equals(statusCode)) {
          callApiJournalRequest.setApiTimingIo(NtssCoopApiConstants.ApiTimingIoStatus.ANA_DONE.getStatus());
        } else if (NtssCoopApiConstants.AnaResult.SKIP.getResult().equals(statusCode)) {
          callApiJournalRequest.setApiTimingIo(NtssCoopApiConstants.ApiTimingIoStatus.ANA_SKIP.getStatus());
        } else if (NtssCoopApiConstants.AnaResult.INTERNAL_ERROR.getResult().equals(statusCode)
            || NtssCoopApiConstants.AnaResult.INTERNAL_ERROR_BY_CARTE.getResult().equals(statusCode)) {
          callApiJournalRequest.setApiTimingIo(NtssCoopApiConstants.ApiTimingIoStatus.ANA_ERROR.getStatus());
        }
        callApiJournalRequest.setApiTimingBa(ApiTimingBaStatus.AFTER.getStatus());
        boolean callResult = callApiService.callApiJournal(callApiJournalRequest, SysCoopJournal, null);
        if (!callResult) {
          break;
        }
      }
      // add 2021-06-10 #5279:API連動の処理順番が正しくない 孫 end

      // add 8208 検査依頼一覧で検査予定を作成した際のjournal登録が正しく行われない 20230210 zhaoqi start
      for (SysCoopJournal SysCoopJournal : successJournalList) {
        if (!"D".equals(SysCoopJournal.getCrud()) && ("exam_ord".equals(SysCoopJournal.getCoopCd()) || "phy_ord".equals(SysCoopJournal.getCoopCd()))) {
          String value = mstCoopIniDao.selectCoopIniInfoValue(request.getFacilityCd(), SysCoopJournal.getKey0(), "EXAMIN_INFO", "IND_SEND_MODE");
          if (!"1".equals(value)) {
            Long ordNoForCheck = SysCoopJournal.getOrdNo();
            int counts = patExamMainDao.checkRegOrderClassForJournal(ordNoForCheck);
            if (counts == 0) {
              Long patIdForCheck = SysCoopJournal.getPatId();
              String baseDate = SysCoopJournal.getBaseDate();
              int ordCount = ordMainDao.checkExistKurCdByPatIdBaseDate(patIdForCheck, request.getFacilityCd(), baseDate);
              if (ordCount == 0) {
                updateAnaResultNotCallApi(SysCoopJournal, "クール設定された治療予定が存在しないためスキップする", AnaResult.SKIP);
              }
            }
          }
        }
      }
      // add 8208 検査依頼一覧で検査予定を作成した際のjournal登録が正しく行われない 20230210 zhaoqi end

      JournalConvertResult result = new JournalConvertResult(HttpStatus.OK.value(), resultList);
      return result;
    } catch (Exception e) {
      String error = String.format("変換処理(送信)で予期せぬエラーが発生しました。[%s]", e);
      eventLogMessage.setLogMessage(error);
      eventLogMessage.setFacilityCd(facilityCd);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // 変換ステータスが「処理中」のレコードをすべて「内部エラー」に更新
      // ※未処理のジャーナルのみ更新対象とする
      journalList.parallelStream()
          .filter(journal -> AnaResult.PROCESSING.getResult().equals(journal.getAnaResult()))
          .forEach(journal -> updateAnaResult(journal, error, AnaResult.INTERNAL_ERROR));

      // add 2021-03-24 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
      // 通知機能APIを呼び出し
      for (SysCoopJournal journal : journalList) {
        if (AnaResult.INTERNAL_ERROR.getResult().equals(journal.getAnaResult())) {
          // modify 9583 by kangjie 20240401 start 通知一覧の連携エラー通知の遷移不正
//          notificationApiCallUtil.registerNotification(journal.getFacilityCd(), journal.getCoopCd(),
          // journal.getHospPatId(), journal.getBaseDate());
          coopJournalErrorComponent.sendCoopJournalError(journal);
          // modify 9583 by kangjie 20240401 end 通知一覧の連携エラー通知の遷移不正
        }
      }
      // add 2021-03-24 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end
      JournalConvertResult result = new JournalConvertResult(HttpStatus.INTERNAL_SERVER_ERROR.value(), error);
      return result;
    }
  }

  /* modify by chamaojia 2023-06-20 プロセスを続行するために成功したレコードを返す --start */
  /**
   * ジャーナルの変換ステータスを更新する。
   *
   * @param journalList ジャーナルのリスト
   * @param status      変換ステータス
   * @return 更新件数
   */
  private List<SysCoopJournal> updateConvStatus(List<SysCoopJournal> journalList, AnaResult status) {
    // ジャーナルリストの変換ステータスを変更
    journalList.forEach(e -> e.setAnaResult(status.getResult()));
    List<Long> ctlNoList = journalList.stream().map(e -> e.getCtlNo()).collect(Collectors.toList());
    List<Long> successCtlNoList = convertCommonService.updateConvStatus(ctlNoList, status.getResult(), JournalConvertConstants.DIRECTION_SEND);
    return journalList.stream().filter(t -> successCtlNoList.contains(t.getCtlNo())).collect(Collectors.toList());
  }
  /* modify by chamaojia 2023-06-20 プロセスを続行するために成功したレコードを返す --end */

  /**
   * ジャーナルの変換ステータスを更新する
   * ※レコード単位での更新
   *
   * @param journal 更新対象のジャーナル
   * @param message メッセージ
   * @param status  更新する変換ステータス
   * @return 更新件数
   */
  private int updateAnaResult(SysCoopJournal journal, String message, AnaResult status) {
    journal.setAnaResult(status.getResult());
    journal.setMessage(message);
    return convertCommonService.updateAnaResult(journal.getCtlNo(), message, status.getResult());
  }

  // add 2021-06-10 #5279:API連動の処理順番が正しくない 孫 start

  /**
   * ジャーナルの変換ステータスを更新する(API連動処理が無し)
   * ※レコード単位での更新
   *
   * @param journal 更新対象のジャーナル
   * @param message メッセージ
   * @param status  更新する変換ステータス
   * @return 更新件数
   */
  private int updateAnaResultNotCallApi(SysCoopJournal journal, String message, AnaResult status) {
    journal.setAnaResult(status.getResult());
    journal.setMessage(message);
    return convertCommonService.updateAnaResultNotCallApi(journal.getCtlNo(), message, status.getResult());
  }
  // add 2021-06-10 #5279:API連動の処理順番が正しくない 孫 end

  // 8179GX-常勤医空白の場合点検
  // upd #8567 （#8179问题调查结果）外部連携全般に必要な機能が制限されている改正 ztc 0508 start
  // private void updateJournalcheckdoctor(SysCoopJournal journal) {
  //// add 8179+8011 GX-常勤医空白の場合はミスを返します ljg start
  // if ("S".equals(journal.getDirection())) {
  // //mod 2022-10-14 #7781 【デグレ】削除電文の連携オーダ番号が取得できず内部エラーになる 卓 end
  // if (Key0Constant.NKK.equals(journal.getKey0())) {
  // if ("ind_dial".equals(journal.getCoopCd())) {
  // // mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//          //      String CoopIniCdByFacilityCd = mstCoopIniDao.selectByCoopIniCdByFacilityCd(journal.getFacilityCd());
  // // mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  // String selectStaff = patMainDao.selectStaff(journal.getPatId());
  // // mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//          //      String selectDefaultStaff = mstCoopIniDao.selectByCoopIniDefaultByFacilityCd(journal.getFacilityCd());
//          String selectDefaultStaff = mstCoopIniDao.selectByCoopIniDefaultByFacilityCd(journal.getFacilityCd(), journal.getKey0());
  // // mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//          if (mstCoopIniDao.selectByCoopIniCdBycoop(journal.getFacilityCd(), journal.getKey0(), "ind_dial") != null
//                  && "1".equals(mstCoopIniDao.selectByCoopIniCdBycoop(journal.getFacilityCd(), journal.getKey0(), "ind_dial"))
  // && ("".equals(selectStaff) || selectStaff == null)
  // && ("".equals(selectDefaultStaff) || selectDefaultStaff == null)
  // ) {
  // journal.setMessage("患者情報の主治医が空の場合のデフォルト主治医設定なし");
  // journal.setAnaResult("E1");
  // sysCoopJournalDao.updateCtlnodump(journal.getCtlNo(), journal.getAnaResult(),
  // "0", null, journal.getMessage(), null, null);
  // }
//          if (mstCoopIniDao.selectByCoopIniCdBycoop(journal.getFacilityCd(), journal.getKey0(), "ind_dial") != null
//                  && "3".equals(mstCoopIniDao.selectByCoopIniCdBycoop(journal.getFacilityCd(), journal.getKey0(), "ind_dial"))
  // ) {
//            if (ordMainDao.selectDocterblank(journal.getFacilityCd(), journal.getOrdNo(), "ind_dial", journal.getCrud()) == null ||
//                    "".equals(ordMainDao.selectDocterblank(journal.getFacilityCd(), journal.getOrdNo(), "ind_dial", journal.getCrud()))
//                    || "0".equals(ordMainDao.selectDocterblank(journal.getFacilityCd(), journal.getOrdNo(), "ind_dial", journal.getCrud()))
  // ) {
//              if (mstCoopIniDao.selectDefaultcoop(journal.getFacilityCd(), journal.getKey0(), "ind_dial") == null
//                      || "".equals(mstCoopIniDao.selectDefaultcoop(journal.getFacilityCd(), journal.getKey0(), "ind_dial"))) {
  // journal.setMessage("患者情報の常勤医設定なし");
  // journal.setAnaResult("E1");
  // sysCoopJournalDao.updateCtlnodump(journal.getCtlNo(), journal.getAnaResult(),
  // "0", null, journal.getMessage(), null, null);
  // }
  // }
  // }
//        } else if (("rst_dial".equals(journal.getCoopCd())) && mstCoopIniDao.selectByCoopIniCdBycoop(journal.getFacilityCd(), journal.getKey0(), "rst_dial") != null
//                && "2".equals(mstCoopIniDao.selectByCoopIniCdBycoop(journal.getFacilityCd(), journal.getKey0(), "rst_dial"))) {
//          if ("0".equals(ordMainDao.selectDocterblank(journal.getFacilityCd(), journal.getOrdNo(), "rst_dial", journal.getCrud())) ||
//                  ordMainDao.selectDocterblank(journal.getFacilityCd(), journal.getOrdNo(), "rst_dial", journal.getCrud()) == null ||
//                  "".equals(ordMainDao.selectDocterblank(journal.getFacilityCd(), journal.getOrdNo(), "rst_dial", journal.getCrud()))
  // ) {
//            if (mstCoopIniDao.selectDefaultcoop(journal.getFacilityCd(), journal.getKey0(), "rst_dial") == null
//                    || "".equals(mstCoopIniDao.selectDefaultcoop(journal.getFacilityCd(), journal.getKey0(), "rst_dial"))
  // ) {
  // journal.setMessage("患者情報の常勤医設定なし");
  // journal.setAnaResult("E1");
  // sysCoopJournalDao.updateCtlnodump(journal.getCtlNo(), journal.getAnaResult(),
  // "0", null, journal.getMessage(), null, null);
  // }
  // }
//        } else if ("exam_ord".equals(journal.getCoopCd()) && mstCoopIniDao.selectByCoopIniCdBycoop(journal.getFacilityCd(), journal.getKey0(), "exam_ord") != null
//                && "2".equals(mstCoopIniDao.selectByCoopIniCdBycoop(journal.getFacilityCd(), journal.getKey0(), "exam_ord"))) {
//          if ("0".equals(ordMainDao.selectExamdoctor(journal.getFacilityCd(), journal.getOrdNo(), journal.getCrud())) ||
//                  ordMainDao.selectExamdoctor(journal.getFacilityCd(), journal.getOrdNo(), journal.getCrud()) == null ||
//                  "".equals(ordMainDao.selectExamdoctor(journal.getFacilityCd(), journal.getOrdNo(), journal.getCrud()))
  // ) {
//            if (mstCoopIniDao.selectDefaultcoop(journal.getFacilityCd(), journal.getKey0(), "exam_ord") == null
//                    || "".equals(mstCoopIniDao.selectDefaultcoop(journal.getFacilityCd(), journal.getKey0(), "exam_ord"))
  // ) {
  // journal.setMessage("患者情報の常勤医設定なし");
  // journal.setAnaResult("E1");
  // sysCoopJournalDao.updateCtlnodump(journal.getCtlNo(), journal.getAnaResult(),
  // "0", null, journal.getMessage(), null, null);
  // }
  // }
  // }
  // } else if (Key0Constant.GX.equals(journal.getKey0())) {
//        if ("ind_dial".equals(journal.getCoopCd()) && mstCoopIniDao.selectByCoopIniCdBycoop(journal.getFacilityCd(), journal.getKey0(), "ind_dial") != null
//                && "6".equals(mstCoopIniDao.selectByCoopIniCdBycoop(journal.getFacilityCd(), journal.getKey0(), "ind_dial"))
  // ) {
//          if (ordMainDao.selectDocterblank(journal.getFacilityCd(), journal.getOrdNo(), "ind_dial", journal.getCrud()) == null ||
//                  "".equals(ordMainDao.selectDocterblank(journal.getFacilityCd(), journal.getOrdNo(), "ind_dial", journal.getCrud()))
//                  || "0".equals(ordMainDao.selectDocterblank(journal.getFacilityCd(), journal.getOrdNo(), "ind_dial", journal.getCrud()))
  // ) {
//            if (mstCoopIniDao.selectDefaultcoop(journal.getFacilityCd(), journal.getKey0(), "ind_dial") == null
//                    || "".equals(mstCoopIniDao.selectDefaultcoop(journal.getFacilityCd(), journal.getKey0(), "ind_dial"))) {
  // journal.setMessage("患者情報の常勤医設定なし");
  // journal.setAnaResult("E1");
  // sysCoopJournalDao.updateCtlnodump(journal.getCtlNo(), journal.getAnaResult(),
  // "0", null, journal.getMessage(), null, null);
  // }
  // }
//        } else if (("rst_dial".equals(journal.getCoopCd()) || "rep_dial".equals(journal.getCoopCd())
//        ) && mstCoopIniDao.selectByCoopIniCdBycoop(journal.getFacilityCd(), journal.getKey0(), "rst_dial/repdial") != null
//                && "5".equals(mstCoopIniDao.selectByCoopIniCdBycoop(journal.getFacilityCd(), journal.getKey0(), "rst_dial/repdial"))) {
//          if ("0".equals(ordMainDao.selectDocterblank(journal.getFacilityCd(), journal.getOrdNo(), "rst_dial/repdial", journal.getCrud())) ||
//                  ordMainDao.selectDocterblank(journal.getFacilityCd(), journal.getOrdNo(), "rst_dial/repdial", journal.getCrud()) == null ||
//                  "".equals(ordMainDao.selectDocterblank(journal.getFacilityCd(), journal.getOrdNo(), "rst_dial/repdial", journal.getCrud()))
  // ) {
//            if (mstCoopIniDao.selectDefaultcoop(journal.getFacilityCd(), journal.getKey0(), "rst_dial/repdial") == null
//                    || "".equals(mstCoopIniDao.selectDefaultcoop(journal.getFacilityCd(), journal.getKey0(), "rst_dial/repdial"))
  // ) {
  // journal.setMessage("患者情報の常勤医設定なし");
  // journal.setAnaResult("E1");
  // sysCoopJournalDao.updateCtlnodump(journal.getCtlNo(), journal.getAnaResult(),
  // "0", null, journal.getMessage(), null, null);
  // }
  // }
//        } else if ("exam_ord".equals(journal.getCoopCd()) && mstCoopIniDao.selectByCoopIniCdBycoop(journal.getFacilityCd(), journal.getKey0(), "exam_ord") != null
//                && "6".equals(mstCoopIniDao.selectByCoopIniCdBycoop(journal.getFacilityCd(), journal.getKey0(), "exam_ord"))) {
//          if ("0".equals(ordMainDao.selectExamdoctor(journal.getFacilityCd(), journal.getOrdNo(), journal.getCrud())) ||
//                  ordMainDao.selectExamdoctor(journal.getFacilityCd(), journal.getOrdNo(), journal.getCrud()) == null ||
//                  "".equals(ordMainDao.selectExamdoctor(journal.getFacilityCd(), journal.getOrdNo(), journal.getCrud()))
  // ) {
//            if (mstCoopIniDao.selectDefaultcoop(journal.getFacilityCd(), journal.getKey0(), "exam_ord") == null
//                    || "".equals(mstCoopIniDao.selectDefaultcoop(journal.getFacilityCd(), journal.getKey0(), "exam_ord"))
  // ) {
  // journal.setMessage("患者情報の常勤医設定なし");
  // journal.setAnaResult("E1");
  // sysCoopJournalDao.updateCtlnodump(journal.getCtlNo(), journal.getAnaResult(),
  // "0", null, journal.getMessage(), null, null);
  // }
  // }
//        } else if ("rad_ord".equals(journal.getCoopCd()) && mstCoopIniDao.selectByCoopIniCdBycoop(journal.getFacilityCd(), journal.getKey0(), "rad_ord") != null
//                && "6".equals(mstCoopIniDao.selectByCoopIniCdBycoop(journal.getFacilityCd(), journal.getKey0(), "rad_ord"))) {
  //
//          if ("0".equals(ordMainDao.selectDocterblank(journal.getFacilityCd(), journal.getOrdNo(), "rad_ord", journal.getCrud())) ||
//                  ordMainDao.selectDocterblank(journal.getFacilityCd(), journal.getOrdNo(), "rad_ord", journal.getCrud()) == null ||
//                  "".equals(ordMainDao.selectDocterblank(journal.getFacilityCd(), journal.getOrdNo(), "rad_ord", journal.getCrud()))
  // ) {
//            if (mstCoopIniDao.selectDefaultcoop(journal.getFacilityCd(), journal.getKey0(), "rad_ord") == null
//                    || "".equals(mstCoopIniDao.selectDefaultcoop(journal.getFacilityCd(), journal.getKey0(), "rad_ord"))
  // ) {
  // journal.setMessage("患者情報の常勤医設定なし");
  // journal.setAnaResult("E1");
  // sysCoopJournalDao.updateCtlnodump(journal.getCtlNo(), journal.getAnaResult(),
  // "0", null, journal.getMessage(), null, null);
  // }
  // }
  // }
  // }
  // }
  // }
  // upd #8567 （#8179问题调查结果）外部連携全般に必要な機能が制限されている改正 ztc 0508 end
  // add 8179+8011 GX-常勤医空白の場合はミスを返します ljg end
  /**
   * 電文作成
   *
   * @param journal 変換対象のsys_coop_journal
   */
  private void createTelegramByFormat(SysCoopJournal journal) {
    if (CoopResult.SKIP.isSameResult(journal.getCoopOrdNo())) {
      return;
    }
    String facilityCd = journal.getFacilityCd();
    String coopCd = journal.getCoopCd();
    String coopCdIndex = journal.getCoopCdIndex();
    String direction = journal.getDirection();

    // mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    MstCoopLayout mcl = convertCommonService.getMstCoopLayout(facilityCd, direction, coopCd, coopCdIndex, getCoopCdSub(journal.getCrud()));
    String coopVersion = StringUtils.isEmpty(journal.getCoopVersion()) ? "" : journal.getCoopVersion();
    MstCoopLayout mcl = convertCommonService.getMstCoopLayout(facilityCd, direction, coopCd, coopCdIndex, coopVersion,
        getCoopCdSub(journal.getCrud()));
    // mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

    String coopCdSub = mcl.getCoopCdSub();
    String format = mcl.getCoopFormat();
    // add 2020-12-09 FNSI-改修 外部連携727 夏 start
    // #7239 2022-12-5 処理保留イベントの最適化処理が行われない 卓 start
    // if(JournalConvertConstants.DIRECTION_SEND.equals(journal.getDirection())) {
    // String error = journalService.executeCoopOrdNoProc(journal);
    // if (!StringUtils.isEmpty(error)) {
    // throw new NtssException(error);
    // }
    // }
    // #7239 2022-12-5 処理保留イベントの最適化処理が行われない 卓 end
    // add 2020-12-09 FNSI-改修 外部連携727 夏 end

    EventLogMessage eventLogMessage = new EventLogMessage();
    // mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    eventLogMessage.setLogMessage("[" + this.getClass().getSimpleName() + "]#convertByFormat: facility_cd:[" + facilityCd + "], "
//      + "direction:[" + direction + "], coop_cd:[" + coopCd + "], coop_cd_sub:[" + coopCdSub + "], coop_format:[" + format + "]");
    eventLogMessage.setLogMessage("[" + this.getClass().getSimpleName() + "]#convertByFormat: facility_cd:[" + facilityCd + "], "
            + "direction:[" + direction + "], coop_cd:[" + coopCd + "], coop_version:[" + coopVersion
            + "], coop_cd_sub:[" + coopCdSub + "], coop_format:[" + format + "]");
    // mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    eventLogMessage.setFacilityCd(facilityCd);
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    switch (format) {
      case JournalConvertConstants.FORMAT_TEXT:
        convertSendTextServiceImpl.createTelegram(journal);
        break;

      case JournalConvertConstants.FORMAT_XML:
        convertSendXmlServiceImpl.createTelegram(journal);
        break;

      case JournalConvertConstants.FORMAT_PDF:
        convertSendPdfServiceImpl.createTelegram(journal);
        break;

      case JournalConvertConstants.FORMAT_CSV:
        convertSendCsvServiceImpl.createTelegram(journal);
        break;

      default:
        String errMsg = String.format("未対応の電文フォーマットです。フォーマット:[%s]", format);
        eventLogMessage.setLogMessage(errMsg);
        eventLogMessage.setFacilityCd(facilityCd);
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
        eventLogMessage.setInvokeClass(this.getClass().getName());
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        throw new NtssException(errMsg);
    }
  }

  /**
   * mst_coop_layoutおよびmst_coop_layout_detailのcoop_cd_subを求めます
   *
   * @param crud - sys_coop_journal.crud
   * @return coop_cd_sub
   */
  private String getCoopCdSub(String crud) {
    return convertSendService.getCoopCdSub(crud);
  }

  // add 2020-12-21 FNSI-改修内容 変換処理中の処理スキップ機能を追加 商 start

  /**
   * タイムアウト時間取得
   *
   * @param coopCd        電文種別
   * @param coopVersion   連携版番号
   * @param coopOrdCdList 各機能共通設定
   * @return timeOutSecond タイムアウト時間
   */
  // mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  private int getTimeOutSecond(String coopCd, List<MstCoopFacility.CoopOrdCd> coopOrdCdList) {
  private int getTimeOutSecond(String coopCd, String coopVersion, List<MstCoopFacility.CoopOrdCd> coopOrdCdList) {
    // mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    int defaultTimeOut = 20;
    if (coopOrdCdList != null && coopOrdCdList.size() > 0) {
      for (int i = 0; i < coopOrdCdList.size(); i++) {
        // #8086-電文作成処理タイムアウトの変換ステータスがエラーではなくスキップになっている 周 20221208 mod start
        // if (coopCd.equals(coopOrdCdList.get(i).getCoopCd())) {
        // mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
        // if (coopCd.equals(coopOrdCdList.get(i).getCoopCd())
        String coopVersionDef = StringUtils.isEmpty(coopOrdCdList.get(i).getCoopVersion()) ? "" : coopOrdCdList.get(i).getCoopVersion();
        if (coopCd.equals(coopOrdCdList.get(i).getCoopCd()) && coopVersion.equals(coopVersionDef)
        // mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
            && 0 == JournalConvertConstants.DIRECTION_SEND.compareTo(coopOrdCdList.get(i).getDirection())) {
          // #8086-電文作成処理タイムアウトの変換ステータスがエラーではなくスキップになっている 周 20221208 mod end
          if (!StringUtils.isEmpty(coopOrdCdList.get(i).getTimeOutSecond())) {
            return Integer.parseInt(coopOrdCdList.get(i).getTimeOutSecond());
          }
        }
      }
    }
    return defaultTimeOut;
  }
  // add 2020-12-21 FNSI-改修内容 変換処理中の処理スキップ機能を追加 商 end

  /**
   * 送信しない設定
   */
  /* modify by chamaojia 2023-02-01 [7050] インタフェースパラメータの追加ordNo、patId --start */
  // #7781 add 2022年11-22 削除電文の連携オーダ番号が取得できず内部エラーになる 卓 start
  @Transactional
  @Override
  public Boolean updateToSkip(SysCoopJournal sysCoopJournal) {
    // 未送信journalの取得
    // Crud.DELETE の処理
    List<String> toSkipAnaResult = Arrays.asList(AnaResult.UNPROCESS.getResult(),
        AnaResult.PROCESSING.getResult(),
        // del #10336 #10397 DBが高負荷になる（外部連携由来）2 start
        // AnaResult.SKIP.getResult(),
        // AnaResult.INTERNAL_ERROR.getResult(),
        // AnaResult.INTERNAL_ERROR_BY_CARTE.getResult(),
        // del #10336 #10397 DBが高負荷になる（外部連携由来）2 end
        AnaResult.DONE.getResult());
    // mod #10336 #10397 DBが高負荷になる（外部連携由来）2 start
    //List<SysCoopJournal> journalList = journalService.listJournalsUnDelivery(sysCoopJournal, Crud.DELETE.getResult(),toSkipAnaResult);
    List<SysCoopJournal> journalList = journalService.listJournalsUnDelivery(sysCoopJournal, null, toSkipAnaResult);
    // mod #10336 DBが高負荷になる（外部連携由来）2 end
    this.updateToSkipDelete(journalList);

    // Crud.Updateを濾過したjournal
    // mod #8255 ini_dial連携で正常応答を行っているにもかかわらずバックアップデータがNGフォルダに格納される 20230204 孫健 start
//    List<SysCoopJournal> journalListUpdate = journalService.listJournalsUnDeliveryAsSkip(facilityCd, ordNo, patId);
    // mod #10336 DBが高負荷になる（外部連携由来）2 start
    // toSkipAnaResult=Arrays.asList(AnaResult.DONE.getResult(),AnaResult.UNPROCESS.getResult());
//    List<SysCoopJournal> journalListUpdate = journalService.listJournalsUnDelivery(sysCoopJournal,  null,toSkipAnaResult);
    List<SysCoopJournal> journalListUpdate = journalList.stream().filter(c -> !AnaResult.PROCESSING.getResult().equals(c.getAnaResult())).collect(Collectors.toList());
    // mod #10336 DBが高負荷になる（外部連携由来）2 end
    this.updateToSkipUpdate(journalListUpdate, sysCoopJournal.getFacilityCd());
    //mod #8255 ini_dial連携で正常応答を行っているにもかかわらずバックアップデータがNGフォルダに格納される 20230204 孫健　end
    // mod #10336 DBが高負荷になる（外部連携由来）2 start
    // toSkipAnaResult=Arrays.asList(AnaResult.UNPROCESS.getResult());
//    List<SysCoopJournal> crudCreateList = journalService.listJournalsUnDelivery(sysCoopJournal, Crud.CREATE.getResult(),toSkipAnaResult);
    List<SysCoopJournal> crudCreateList = journalList.stream()
      .filter(journal -> Crud.CREATE.getResult().equals(journal.getCrud()))
        .collect(Collectors.groupingBy(
            journal -> Arrays.asList(journal.getOrdNo(), journal.getPatId()),
            Collectors.collectingAndThen(
                Collectors.toList(),
          list -> (List<SysCoopJournal>) new ArrayList<>(list.size() >= 2 ? list : new ArrayList<>())
        )
      ))
        .values().stream()
        .filter(list -> !list.isEmpty())
        .flatMap(Collection::stream).filter(journal -> AnaResult.UNPROCESS.getResult().equals(journal.getAnaResult()))
        .toList();
    // mod #10336 DBが高負荷になる（外部連携由来）2 end
    this.updateToSkipCreate(crudCreateList);

    return true;
  }

  @Transactional
  public Boolean updateToSkipCreate(List<SysCoopJournal> crudCreateList) {
    if (crudCreateList.size() <= 0) {
      return false;
    }
    List<SysCoopJournal> crudCreateJournalList = null;
    for (SysCoopJournal journal : crudCreateList) {
      // mod 2023-02-06 7781 start
      crudCreateJournalList = journalService.findSameJournalList(journal, Crud.CREATE.getResult(), false);
      // if (journal.getCoopCd().equals(CoopCdConstant.REP_DIAL)) {
      //        crudCreateJournalList = journalService.listByCrudCoopCdCoopCdIndex(journal, Crud.CREATE.getResult(), CoopCdConstant.REP_DIAL, journal.getCoopCdIndex());
      // } else {
      //        crudCreateJournalList = journalService.listCoopResultUnprocessSkipError(journal, Crud.CREATE.getResult());
      // }
      // mod 2023-02-06 7781 end
      // #8102-GX連携で実装されていない機能（処方情報連携） 周 add start
      if (CoopCdConstant.PRE_ORD.equals(journal.getCoopCd())) {
        crudCreateJournalList = crudCreateJournalList.stream().filter(creJ ->
          (creJ.getBaseDate().equals(journal.getBaseDate())
            && !creJ.getCtlNo().equals(journal.getCtlNo()))).collect(Collectors.toList());
        if (crudCreateJournalList.size() > 0) {
          // mod #10336 DBが高負荷になる（外部連携由来）2 start
          // SysCoopJournal crudCreJournal = crudCreateJournalList.get(0);
          // journalService.updateJournalSkip(crudCreJournal,
          // JournalSendSkipConstant.SKIP_MESSAGE_UPDATE);
          journalService.updateJournalListSkip(crudCreateJournalList,
              JournalSendSkipConstant.SKIP_MESSAGE_LATEST_TELEGRAM);
          // mod #10336 DBが高負荷になる（外部連携由来）2 end
        }
      } else {
        // #8102-GX連携で実装されていない機能（処方情報連携） 周 add end
      crudCreateJournalList = crudCreateJournalList.stream().filter(creJ -> (!creJ.getCtlNo().equals(journal.getCtlNo()))).collect(Collectors.toList());
        if (crudCreateJournalList != null && crudCreateJournalList.size() > 0) {
          // mod #10336 DBが高負荷になる（外部連携由来）2 start
          // SysCoopJournal crudCreJournal = crudCreateJournalList.get(0);
          // journalService.updateJournalSkip(crudCreJournal,
          // JournalSendSkipConstant.SKIP_MESSAGE_UPDATE);
          journalService.updateJournalListSkip(crudCreateJournalList,
              JournalSendSkipConstant.SKIP_MESSAGE_LATEST_TELEGRAM);
          // mod #10336 DBが高負荷になる（外部連携由来）2 end

        }
        // #8102-GX連携で実装されていない機能（処方情報連携） 周 add start
      }
      // #8102-GX連携で実装されていない機能（処方情報連携） 周 add end
    }
    return true;
  }

  /* modify by chamaojia 2023-02-01 [7050] インタフェースパラメータの追加ordNo、patId --end */

  /**
   * Crud.DELETE の処理
   */
  @Transactional
  public Boolean updateToSkipDelete(List<SysCoopJournal> journalList) {
    // Crud.DELETEを濾過したjournal
    ArrayList<SysCoopJournal> crudDeleteJournalList = journalList.stream().filter(journal -> Crud.DELETE.isSameResult(journal.getCrud()))
        .collect(Collectors.toCollection(ArrayList::new));
    if (crudDeleteJournalList.size() <= 0) {
      return false;
    }
    for (SysCoopJournal crudDeleteJournal : crudDeleteJournalList) {
      OrdCoopNo ordCoopNo = ordCoopNoService.getOrdCoopNoByJournal(crudDeleteJournal);
      if (ordCoopNo == null) {
        JournalLogUtil.eventMessageDebug("updateToSkipDelete:ordCoopNo == null", crudDeleteJournal,
              this.getClass().getName(), SERVICE_NAME.FNSI);
        List<SysCoopJournal> toSetSkipJournalList = journalService.listJournalsUnprocess(crudDeleteJournal);
        if (Key0Constant.NKK.equals(crudDeleteJournal.getKey0())
            && CoopCdConstant.EXAM_ORD.equals(crudDeleteJournal.getCoopCd())
            && JournalConvertConstants.DIRECTION_SEND.equals(crudDeleteJournal.getDirection())) {
          if (null == toSetSkipJournalList || toSetSkipJournalList.size() <= 1) {
            continue;
          }
        }
        // ana_result=1かつordCoopNo削除後でcoop_ord_no割り振り済みのDジャーナルはスキップしない
        toSetSkipJournalList = toSetSkipJournalList.stream().filter(journal -> journal.getCoopOrdNo() == null).collect(Collectors.toList());
        // スキップメッセージ割り振り
        Map<Boolean, List<SysCoopJournal>> pattitionMap = toSetSkipJournalList
          .stream().collect(Collectors.partitioningBy(journal -> Crud.DELETE.isSameResult(journal.getCrud())));
        List<SysCoopJournal> toSetSkipJournalCrudNotDList = pattitionMap.get(false);
        if(toSetSkipJournalCrudNotDList.size() > 0) {
          journalService.updateJournalListSkip(toSetSkipJournalCrudNotDList, JournalSendSkipConstant.SKIP_MESSAGE_DELETE_TELEGRAM);
        }
        List<SysCoopJournal> toSetSkipJournalCrudDList = pattitionMap.get(true);
        if(toSetSkipJournalCrudDList.size() > 0) {
          journalService.updateJournalListSkip(toSetSkipJournalCrudDList, JournalSendSkipConstant.SKIP_MESSAGE_DELETE_FOR_INCOMPLETE);
        }
        continue;
      } else {
        // D電文設定coop _ord_no、削除、D電文が間違ったcoop _ord_noはすべてスキップ
        if (crudDeleteJournal.getCoopOrdNo() == null) {
          JournalLogUtil.eventMessageDebug("updateToSkipDelete:ordCoopNo != null && crudDeleteJournal.getCoopOrdNo() == null", crudDeleteJournal,
              this.getClass().getName(), SERVICE_NAME.FNSI);
          // DCDCの間のCDジャーナルスキップ処理
          List<SysCoopJournal> unprocessJournalList = journalService.listJournalsUnprocess(crudDeleteJournal);
          unprocessJournalList = unprocessJournalList.stream()
            .sorted(Comparator.comparingLong(SysCoopJournal::getCtlNo).reversed())
            .dropWhile(j -> !Crud.DELETE.isSameResult(j.getCrud()))
            .sorted(Comparator.comparingLong(SysCoopJournal::getCtlNo))
            .dropWhile(j -> !Crud.DELETE.isSameResult(j.getCrud()))
            .skip(1)
            .collect(Collectors.toList());

          if(unprocessJournalList.size() > 0) {
            // スキップする
            JournalLogUtil.eventMessageDebug("updateToSkipDelete:unprocessJournalList.size() > 0", crudDeleteJournal,
              this.getClass().getName(), SERVICE_NAME.FNSI);

            Map<Boolean, List<SysCoopJournal>> pattitionMap = unprocessJournalList
              .stream().collect(Collectors.partitioningBy(journal -> Crud.DELETE.isSameResult(journal.getCrud())));
            List<SysCoopJournal> toSetSkipJournalCrudNotDList = pattitionMap.get(false);
            if(toSetSkipJournalCrudNotDList.size() > 0) {
              journalService.updateJournalListSkip(toSetSkipJournalCrudNotDList, JournalSendSkipConstant.SKIP_MESSAGE_DELETE_TELEGRAM);
            }
            List<SysCoopJournal> toSetSkipJournalCrudDList = pattitionMap.get(true);
            if(toSetSkipJournalCrudDList.size() > 0) {
              journalService.updateJournalListSkip(toSetSkipJournalCrudDList, JournalSendSkipConstant.SKIP_MESSAGE_DELETE_FOR_INCOMPLETE);
            }
            continue;
          }

          crudDeleteJournal.setCoopOrdNo(ordCoopNo.getCoopOrdNo());
          if (Key0Constant.NKK.equals(crudDeleteJournal.getKey0())
              && CoopCdConstant.EXAM_ORD.equals(crudDeleteJournal.getCoopCd())
              && JournalConvertConstants.DIRECTION_SEND.equals(crudDeleteJournal.getDirection())) {
            List<SysCoopJournal> toSetSkipJournalList = journalService.listJournalsUnprocess(crudDeleteJournal);
            if (null == toSetSkipJournalList || toSetSkipJournalList.size() <= 1) {
              continue;
            }
            crudDeleteJournal.setCoopResult(CoopResult.SKIP.getResult());
          }
          journalService.update(crudDeleteJournal);
        } else {
          if (!crudDeleteJournal.getCoopOrdNo().equals(ordCoopNo.getCoopOrdNo())) {
            List<SysCoopJournal> toSetSkipJournalList = journalService.listJournalsUnprocess(crudDeleteJournal);
            journalService.updateJournalListSkip(toSetSkipJournalList,
                JournalSendSkipConstant.SKIP_MESSAGE_DELETE_TELEGRAM);
          }
        }
        // 已经送信的D,送信处理
        if (OrdCoopNoConstant.Status.DONE.isSameResult(ordCoopNo.getStatus())) {
          JournalLogUtil.eventMessageDebug("coopOrderが既に送信されている場合は、処理する", crudDeleteJournal,
              this.getClass().getName(), SERVICE_NAME.FNSI);

          // Deleteのjournalが新規に作成された場合,
          // Create送信、update未送信のJournalはskipに設定され.
          List<SysCoopJournal> toSetSkipJournalList = journalService.listJournalsByOrderNo(crudDeleteJournal,
              NtssCoopApiConstants.coopResultSkipList, ordCoopNo.getCoopOrdNo());
          toSetSkipJournalList = toSetSkipJournalList.stream()
              .filter(journal -> Crud.UPDATE.getResult().equals(journal.getCrud())).collect(Collectors.toList());
          journalService.updateJournalListSkip(toSetSkipJournalList,
              JournalSendSkipConstant.SKIP_MESSAGE_DELETE_TELEGRAM);
          continue;
        }
      }

      if (null != crudDeleteJournal.getCoopOrdNo() && !crudDeleteJournal.getCoopOrdNo().equals(ordCoopNo.getCoopOrdNo())) {
        continue;
      }
      // スキップするjournalをフィルタ
      else {
        // 同じOrdNoのjournalを検索
        List<String> coopResultList = Arrays.asList(
          CoopResult.UNPROCESS.getResult()
          ,CoopResult.RETRY.getResult()
          ,CoopResult.INTERNAL_ERROR_BY_NTSS.getResult()
          ,CoopResult.INTERNAL_ERROR_BY_CARTE.getResult());
        List<SysCoopJournal> toSetSkipJournalList = journalService.filterToSetSkipJournalList(crudDeleteJournal, ordCoopNo,coopResultList);
        JournalLogUtil.eventMessageDebug("coopOrderが送信されていない場合は、未送信のjournal、coopResultをskipに設定", crudDeleteJournal,
            this.getClass().getName(), SERVICE_NAME.FNSI);
        toSetSkipJournalList = sortedByCrud(toSetSkipJournalList);
        journalService.updateSkipJournalList(toSetSkipJournalList);
      }
    }
    return true;
  }

  // #7781 mod 【デグレ】削-除電文の連携オーダ番号が取得できず内部エラーになる 2023-03-03 卓 start
  private List<SysCoopJournal> sortedByCrud(List<SysCoopJournal> journalList) {
    List<String> definedOrder = Arrays.asList("C", "U", "D");
    Comparator<SysCoopJournal> comparator = new Comparator<SysCoopJournal>() {
      @Override
      public int compare(final SysCoopJournal a1, final SysCoopJournal a2) {
        return Integer.valueOf(definedOrder.indexOf(a1.getCrud())).compareTo(Integer.valueOf(
            definedOrder.indexOf(a2.getCrud())));
      }
    };
    return journalList.stream().sorted(comparator).collect(Collectors.toList());
  }

  // #7781 mod【デグレ】削除電文の連携オーダ番号が取得できず内部エラーになる 2023-03-03 卓 end
  /**
   * Crud.Updateを濾過したjournal
   */
  @Transactional
  public void updateToSkipUpdate(List<SysCoopJournal> journalList, String faciltiyCd) {
    ArrayList<SysCoopJournal> crudUpdateJournalList = journalList.stream().filter(journal -> Crud.UPDATE.isSameResult(journal.getCrud()))
        .collect(Collectors.toCollection(ArrayList::new));
    // #7781 mod 【デグレ】削-除電文の連携オーダ番号が取得できず内部エラーになる 2023-03-03 卓 start
    Collections.reverse(crudUpdateJournalList);
    HashSet<Long> visited = new HashSet<>();
    // #7781 mod【デグレ】削除電文の連携オーダ番号が取得できず内部エラーになる 2023-03-03 卓 end
    List<OrdCoopNo> ordCoopNoList = ordCoopNoService.getOrdCoopNoListByJournalList(crudUpdateJournalList, faciltiyCd);

    for (SysCoopJournal crudUpdateJournal : crudUpdateJournalList) {
      /*OrdCoopNo ordCoopNo = ordCoopNoService.getOrdCoopNoByJournal(crudUpdateJournal);*/
      OrdCoopNo ordCoopNo = null;
      SysCoopJournal freshUpdateJournal = sysCoopJournalDao.selectByPK(crudUpdateJournal.getCtlNo());
      if (CoopResult.SKIP.isSameResult(freshUpdateJournal.getAnaResult())
          || CoopResult.SKIP.isSameResult(freshUpdateJournal.getCoopResult())) {
        continue;
      }
      for (OrdCoopNo ocn : ordCoopNoList) {
        if (ocn.getPatId().equals(crudUpdateJournal.getPatId())
            && ocn.getOrdNo().equals(crudUpdateJournal.getOrdNo())
            && crudUpdateJournal.getCoopVersion().equals(ocn.getCoopVersion())) {
          ordCoopNo = ocn;
          break;
        }
      }
      if (ordCoopNo == null) {
        List<SysCoopJournal> toSetSkipJournalList = new ArrayList<>();
        for (SysCoopJournal crudCreatejournal : journalList) {
          Boolean is = Crud.CREATE.isSameResult(crudCreatejournal.getCrud())
              && crudUpdateJournal.getOrdNo().equals(crudCreatejournal.getOrdNo())
              && crudUpdateJournal.getPatId().equals(crudCreatejournal.getPatId())
              && crudUpdateJournal.getHospPatId().equals(crudCreatejournal.getHospPatId())
              && crudUpdateJournal.getFacilityCd().equals(crudCreatejournal.getFacilityCd())
              && crudUpdateJournal.getCoopCd().equals(crudCreatejournal.getCoopCd())
              && crudUpdateJournal.getCoopVersion().equals(crudCreatejournal.getCoopVersion());

          if (CoopCdConstant.REP_DIAL.equals(crudUpdateJournal.getCoopCd())) {
            if (is && crudUpdateJournal.getCoopCdIndex().equals(crudCreatejournal.getCoopCdIndex())) {
              toSetSkipJournalList.add(crudCreatejournal);
            }
          } else if (is) {
            toSetSkipJournalList.add(crudCreatejournal);
          }
        }
        // #7781 mod 【デグレ】削-除電文の連携オーダ番号が取得できず内部エラーになる 2023-03-03 卓 start
        journalService.updateJournalListSkip(toSetSkipJournalList,
            JournalSendSkipConstant.SKIP_MESSAGE_LATEST_TELEGRAM);
        // for (SysCoopJournal skipjournal : toSetSkipJournalList) {
//          journalService.updateJournalSkip(skipjournal, JournalSendSkipConstant.SKIP_MESSAGE_UPDATE);
        // }
        // #7781 mod【デグレ】削除電文の連携オーダ番号が取得できず内部エラーになる 2023-03-03 卓 end
        crudUpdateJournal.setCrud(Crud.CREATE.getResult());
        journalService.updateJournalCrud(crudUpdateJournal);
      } else {
        // 以前のJournal Uを検索
        // #7781 mod 【デグレ】削-除電文の連携オーダ番号が取得できず内部エラーになる 2023-03-03 卓 start
        List<SysCoopJournal> cuJList = null;
        if (!visited.contains(crudUpdateJournal.getCtlNo())) {
          cuJList = journalService.findSameJournalList(crudUpdateJournal, Crud.UPDATE.getResult(), false);
          cuJList = cuJList.stream().filter(creJ -> (!creJ.getCtlNo().equals(crudUpdateJournal.getCtlNo()))).collect(Collectors.toList());
        }

        if (cuJList != null && cuJList.size() > 0) {
          // SysCoopJournal crudCreJournal = cuJList.get(0);
//          journalService.updateJournalSkip(crudCreJournal, JournalSendSkipConstant.SKIP_MESSAGE_UPDATE);
          visited.addAll(cuJList.stream().map(SysCoopJournal::getCtlNo).collect(Collectors.toList()));
          journalService.updateJournalListSkip(cuJList, JournalSendSkipConstant.SKIP_MESSAGE_LATEST_TELEGRAM);
        }
        // #7781 mod【デグレ】削除電文の連携オーダ番号が取得できず内部エラーになる 2023-03-03 卓 end
      }
    }
  }

  /**
   * スキップするjournalをフィルタ
   */
//  private List<SysCoopJournal> filterToSetSkipJournalList(SysCoopJournal crudDeleteJournal, OrdCoopNo ordCoopNo) {
  // //同じOrdNoのjournalを検索
  // List<String> coopResultList = Arrays.asList(
  // CoopResult.UNPROCESS.getResult()
  // ,CoopResult.RETRY.getResult()
  // ,CoopResult.INTERNAL_ERROR_BY_NTSS.getResult()
  // ,CoopResult.INTERNAL_ERROR_BY_CARTE.getResult());
  //
  // List<SysCoopJournal> skipJournalList = null;
  // if (CoopCdConstant.REP_DIAL.equals(crudDeleteJournal.getCoopCd())) {
//      skipJournalList = journalService.listJournalsRepDialByOrderNo(crudDeleteJournal, coopResultList, CoopCdConstant.REP_DIAL);
  // } else {
//      skipJournalList = journalService.listJournalsByOrderNo(crudDeleteJournal, coopResultList, ordCoopNo.getCoopOrdNo());
  // }
  // if (CollectionUtils.isEmpty(skipJournalList)) {
  // return new ArrayList<>();
  // }
  //
  // //REP_DIAL filter
  // Boolean repDialToSetSkip = true;
  // if (CoopCdConstant.REP_DIAL.equals(crudDeleteJournal.getCoopCd())) {
  // List<SysCoopJournal> createJournalList = skipJournalList.stream().
//        filter(creJ -> (Crud.CREATE.isSameResult(creJ.getCrud()) && CoopCdConstant.REP_DIAL.equals(creJ.getCoopCd())))
  // .collect(Collectors.toList());
  //
  // List<SysCoopJournal> deleteJournalList = skipJournalList.stream().
//        filter(delJ -> (Crud.DELETE.isSameResult(delJ.getCrud()) && CoopCdConstant.REP_DIAL.equals(delJ.getCoopCd())))
  // .collect(Collectors.toList());
  //
  // for (SysCoopJournal creJ : createJournalList) {
//        long coopCdIndexExitCount = deleteJournalList.stream().filter(delJ -> (delJ.getCoopCdIndex().equals(creJ.getCoopCdIndex())))
  // .count();
  //
  // if (coopCdIndexExitCount == 0l) {
  // repDialToSetSkip = false;
  // break;
  // }
  // }
  // }
  // if (!repDialToSetSkip) {
  // return new ArrayList<>();
  // }
  //
//    long deleteCount = skipJournalList.stream().filter(journal -> journal.getCtlNo().equals(crudDeleteJournal.getCtlNo())).count();
  // if (deleteCount <= 0) {
  // skipJournalList.add(crudDeleteJournal);
  // }
  //
  // return skipJournalList;
  // }
  // #7781 add 2022年11-22 削除電文の連携オーダ番号が取得できず内部エラーになる 卓 end
}
