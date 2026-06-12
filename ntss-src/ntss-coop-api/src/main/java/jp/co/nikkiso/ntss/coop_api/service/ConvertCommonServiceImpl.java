package jp.co.nikkiso.ntss.coop_api.service;

import static jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants.AUX_CODE_ALL;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

import java.io.UnsupportedEncodingException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

import jp.co.nikkiso.ntss.coop_api.request.CallApiJournalRequest;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertUtil;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstCoopFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopIniDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopLayoutDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopLayoutDetailDao;
import jp.co.nikkiso.ntss.core.dao.SysCoopJournalDao;
import jp.co.nikkiso.ntss.core.entity.MstCoopFacility;
import jp.co.nikkiso.ntss.core.entity.MstCoopIni;
import jp.co.nikkiso.ntss.core.entity.MstCoopLayout;
import jp.co.nikkiso.ntss.core.entity.MstCoopLayoutDetail;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import jp.co.nikkiso.ntss.core.entity.custom.SysCoopJournalParam;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import org.seasar.doma.jdbc.Config;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import jp.co.nikkiso.ntss.coop_api.utils.ClockWrapper;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants.AnaResult;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants.CoopResult;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.config.DefaultDb;

@Service
public class ConvertCommonServiceImpl implements ConvertCommonService {

  /* add by chamaojia 2023-05-22 検査結果1 file多患者受信時のデータ分割処理とIFedgeファイル移動処理の競合  --start */
  // 下面定义的常量是从JournalConvertReceiveResource迁移过来
  /** 特殊値: CR */
  private static final String TELEGRAM_DELIM_CR = "CR";

  /** CR指定に対応する区切り文字 */
  private static final String TELEGRAM_DELIM_CR_VALUE = "\r";

  /** 特殊値: LF */
  private static final String TELEGRAM_DELIM_LF = "LF";

  /** LF指定に対応する区切り文字 */
  private static final String TELEGRAM_DELIM_LF_VALUE = "\n";

  // 正規表現文字列
  /** レイアウト中のmulti指定の引数を分割する正規表現 */
  private static final String LAYOUT_MULTI_DELIM = "[:/]";

  /** グループ開始 */
  private static final String REGEXP_GROUP_START = "(";

  /** グループ終了 */
  private static final String REGEXP_GROUP_END = ")";

  /** グループ内選択 */
  private static final String REGEXP_GROUP_OR = "|";
  /* add by chamaojia 2023-05-22 検査結果1 file多患者受信時のデータ分割処理とIFedgeファイル移動処理の競合  --end */

  @Autowired
  private SysCoopJournalDao sysCoopJournalDao;

  @Autowired
  private MstCoopLayoutDao mstCoopLayoutDao;

  // add 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
  @Autowired
  private MstCoopLayoutDetailDao mstCoopLayoutDetailDao;
  // add 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end

  @Autowired
  private ClockWrapper clockWrapper;

  @Autowired
  private LogService logService;

  // add 2020-12-21 FNSI-改修内容 変換処理中の処理スキップ機能を追加 商 start
  @Autowired
  private MstCoopFacilityDao mstCoopFacilityDao;
  // add 2020-12-21 FNSI-改修内容 変換処理中の処理スキップ機能を追加 商 end

  // DB更新ログ出力ロジック wangzuo Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;
  // DB更新ログ出力ロジック wangzuo End

  // add 2021-04-06 課題No.1:API連動設定:動作条件「処理完了時、処理エラー時、処理スキップ時」を追加 孫 start
  @Autowired
  private CallApiService callApiService;
  // add 2021-04-06 課題No.1:API連動設定:動作条件「処理完了時、処理エラー時、処理スキップ時」を追加 孫 end

  // add 2021-09-16 #5897:CSI連携ができないの対応 孫 start
  /**
   * 連携設定マスタ
   */
  @Autowired
  private MstCoopIniDao mstCoopIniDao;

  @Autowired
  @DefaultDb
  private Config defaultDbConfig;

  /**
   * 連携設定マスタを取得.
   * @param facilityCd 施設コード
   * @return 連携エッジマスタ情報
   */
  @Override
  public List<MstCoopIni> getMstCoopIniByFacilityCd(String facilityCd){
    return mstCoopIniDao.selectByFacilityCd(facilityCd);
  }
  // add 2021-09-16 #5897:CSI連携ができないの対応 孫 end

  /**
   * 変換対象ジャーナルを取得する。
   *
   * @param facilityCd 施設コード
   * @param direction  向き（送受信）
   * @param coopResult 通信ステータス
   * @param ctlNoList  管理番号リスト
   * @param ordNo      （次世代FN)オーダ番号
   * @param patId      患者番号（システム）
   * @return ジャーナルのリスト
   * @see jp.co.nikkiso.ntss.coop_api.service.ConvertCommonService#getJournalList(String, String)
   */
  /* modify by chamaojia 2023-02-01 [7050] インタフェースパラメータの追加ordNo、patId  --start */
  /* modify by chamaojia 2023-01-10 [7050] インタフェースパラメータの追加ctlNoList  --start */
  public List<SysCoopJournal> getJournalList(String facilityCd, String direction, String coopResult, List<Long> ctlNoList, Long ordNo, Long patId) {
  /* modify by chamaojia 2023-01-10 [7050] インタフェースパラメータの追加ctlNoList  --end */
  /* modify by chamaojia 2023-02-01 [7050] インタフェースパラメータの追加ordNo、patId  --end */
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("[" + this.getClass().getSimpleName() + "]#getJournalList: facility_cd:[" + facilityCd + "], direction:[" + direction + "]");
    eventLogMessage.setFacilityCd(facilityCd);
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    return sysCoopJournalDao.selectToConvert(facilityCd, direction,
      NtssCoopApiConstants.AnaResult.UNPROCESS.getResult(),
      /* modify by chamaojia 2023-02-01 [7050] インタフェースパラメータの追加ordNo、patId  --start */
      /* modify by chamaojia 2023-01-10 [7050] インタフェースパラメータの追加ctlNoList  --start */
      // null値を入力できません、sqlは集合null値を判断できません
      coopResult, ctlNoList == null ? new ArrayList<>() : ctlNoList, ordNo, patId);
      /* modify by chamaojia 2023-01-10 [7050] インタフェースパラメータの追加ctlNoList  --end */
      /* modify by chamaojia 2023-02-01 [7050] インタフェースパラメータの追加ordNo、patId  --end */
  }

//#8350  mod ini_dial連携受信時のprofile連携（要求）が処理されず患者属性の更新ができないことがある 卓 2023-04-26 start
  /**
   * 変換対象のジャーナル数量統計。
   *
   * @param facilityCd 施設コード
   * @param direction  向き（送受信）
   * @param coopResult 通信ステータス
   * @param ctlNoList  管理番号リスト
   * @param ordNo      （次世代FN)オーダ番号
   * @param patId      患者番号（システム）
   * @return ジャーナルのリスト
   */
  @Override
  public Long getJournalListCount(String facilityCd, String direction, String coopResult, List<Long> ctlNoList, Long ordNo, Long patId) {
    return sysCoopJournalDao.selectToConvertCount(facilityCd, direction,
      NtssCoopApiConstants.AnaResult.UNPROCESS.getResult(),
      coopResult, ctlNoList == null ? new ArrayList<>() : ctlNoList, ordNo, patId);
  }
//#8350  mod ini_dial連携受信時のprofile連携（要求）が処理されず患者属性の更新ができないことがある 卓 2023-04-26 end

  /**
   * 変換対象ジャーナルを1件取得する。
   *
   * @param facilityCd 施設コード
   * @param direction  向き（送受信）
   * @param coopResult 通信ステータス
   * @param ctlNoList  管理番号リスト
   * @param ordNo      （次世代FN)オーダ番号
   * @param patId      患者番号（システム）
   * @return ジャーナルのリスト
   * @see jp.co.nikkiso.ntss.coop_api.service.ConvertCommonService#getJournalListOne(String, String)
   */
  public List<SysCoopJournal> getJournalListOne(String facilityCd, String direction, String coopResult, List<Long> ctlNoList, Long ordNo, Long patId) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("[" + this.getClass().getSimpleName() + "]#getJournalList: facility_cd:[" + facilityCd + "], direction:[" + direction + "]");
    eventLogMessage.setFacilityCd(facilityCd);
    eventLogMessage.setInvokeClass(this.getClass().getName());
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    return sysCoopJournalDao.selectToConvertOne(facilityCd, direction,
      NtssCoopApiConstants.AnaResult.UNPROCESS.getResult(),
      coopResult, ctlNoList == null ? new ArrayList<>() : ctlNoList, ordNo, patId);
  }

  /**
   * 変換処理中/送信処理中のジャーナルの取得
   *
   * @param facilityCd 施設コード
   * @param direction  向き（送受信）
   * @param ordNo      オーダ番号
   * @param patId      患者ID
   * @return 変換処理中ジャーナルリスト {@link SysCoopJournal}
   */
  @Override
  public List<SysCoopJournal> getProcessingJournalList(String facilityCd, String direction, Long ordNo, Long patId) {
    SysCoopJournalParam param = new SysCoopJournalParam();
    param.setFacilityCd(facilityCd);
    param.setDirection(direction);
    param.setOrdNo(ordNo);
    param.setPatId(patId);
    param.setAnaResult(Arrays.asList(AnaResult.PROCESSING.getResult(), AnaResult.DONE.getResult()));
    param.setCoopResult(Arrays.asList(CoopResult.UNPROCESS.getResult(), CoopResult.PROCESSING.getResult(), CoopResult.WAITING.getResult(), CoopResult.RETRY.getResult()));

    return sysCoopJournalDao.selectJournals(param);
  }

  /**
   * 変換レイアウトを取得する。
   *
   * @param facilityCd  施設コード
   * @param direction   向き（送受信）
   * @param coopCd      電文種別
   * @param coopCdIndex 付帯情報（電文）
   * @param coopVersion 連携版番号
   * @param coopCdSub   電文種別補足コード
   * @return 変換レイアウトマスタ（{@link MstCoopLayout}）のエンティティ
   * @see jp.co.nikkiso.ntss.coop_api.service.ConvertCommonService#getMstCoopLayout(String, String, String, String)
   */
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  public MstCoopLayout getMstCoopLayout(String facilityCd, String direction, String coopCd, String coopCdIndex, String coopCdSub) {
  public MstCoopLayout getMstCoopLayout(String facilityCd, String direction, String coopCd, String coopCdIndex,
                                        String coopVersion, String coopCdSub) {
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    EventLogMessage eventLogMessage = new EventLogMessage();
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////    MstCoopLayout mcl = mstCoopLayoutDao.selectWithAll(facilityCd, coopCd, coopCdIndex, direction, coopCdSub, AUX_CODE_ALL);
//    MstCoopLayout mcl = mstCoopLayoutDao.selectWithAll(facilityCd, coopCd, coopCdIndex, coopVersion, direction, coopCdSub, AUX_CODE_ALL);
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//
//    if (mcl == null) {
//// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////      String errMsg = String.format("電文変換レイアウトが設定されていません。施設コード:[%s], 送受信向き:[%s], 電文種別:[%s], 電文付帯情報:[%s], 電文種別補足コード:[%s]",
////        facilityCd, direction, coopCd, coopCdIndex, coopCdSub);
//      String errMsg = String.format("電文変換レイアウトが設定されていません。施設コード:[%s], 連携版番号:[%s], 送受信向き:[%s], 電文種別:[%s], 電文付帯情報:[%s], 電文種別補足コード:[%s]",
//        facilityCd, coopVersion, direction, coopCd, coopCdIndex, coopCdSub);
//// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//      eventLogMessage.setLogMessage(errMsg);
//      eventLogMessage.setFacilityCd(facilityCd);
//      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
//      eventLogMessage.setInvokeClass(this.getClass().getName());
//      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
//      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//      throw new NtssException(errMsg);
//    }
//
//    String telegramFormat = mcl.getCoopFormat().trim();
//    mcl.setCoopFormat(telegramFormat);
//
//    if (StringUtils.isEmpty(telegramFormat)) {
//      // フォーマット指定がブランクの場合
//// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////      String errMsg = String.format("電文フォーマットが設定されていません。電文種別:[%s]", coopCdSub);
//      String errMsg = String.format("電文フォーマットが設定されていません。連携版番号:[%s], 電文種別:[%s]", coopVersion, coopCdSub);
//// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//      eventLogMessage.setLogMessage(errMsg);
//      eventLogMessage.setFacilityCd(facilityCd);
//      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
//      eventLogMessage.setInvokeClass(this.getClass().getName());
//      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
//      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//      throw new NtssException(errMsg);
//    }
//
//    return mcl;
    List<MstCoopLayout> mclList = mstCoopLayoutDao.selectWithAll(facilityCd, coopCd, coopCdIndex, coopVersion,
      direction, coopCdSub, AUX_CODE_ALL);
    if (mclList == null || mclList.size() == 0) {
      String errMsg = String.format("対象レイアウトファイルが存在しません。施設コード:[%s], 連携版番号:[%s], 送受信向き:[%s], 電文種別:[%s], 電文付帯情報:[%s], 電文種別補足コード:[%s,%s]",
        facilityCd, coopVersion, direction, coopCd, coopCdIndex, coopCdSub, AUX_CODE_ALL);
      eventLogMessage.setLogMessage(errMsg);
      eventLogMessage.setFacilityCd(facilityCd);
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new NtssException(errMsg);
    } else {
      MstCoopLayout mcl = mclList.get(0);
      if (mclList.size() > 1) {
        MstCoopLayout mclCheck = mclList.get(1);
        String coopCdSub0 = mcl.getCoopCdSub();
        String coopCdSub1 = mclCheck.getCoopCdSub();
        if (coopCdSub0.equals(coopCdSub1)) {
          String errMsg = String.format("対象レイアウトファイルが複数存在します。施設コード:[%s], 連携版番号:[%s], 送受信向き:[%s], 電文種別:[%s], 電文付帯情報:[%s], 電文種別補足コード:[%s]",
            facilityCd, coopVersion, direction, coopCd, coopCdIndex, coopCdSub0);
          eventLogMessage.setLogMessage(errMsg);
          eventLogMessage.setFacilityCd(facilityCd);
          eventLogMessage.setInvokeClass(this.getClass().getName());
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          throw new NtssException(errMsg);
        }
      }

      String telegramFormat = StringUtils.isEmpty(mcl.getCoopFormat())? "":mcl.getCoopFormat().trim();
      mcl.setCoopFormat(telegramFormat);
      if (StringUtils.isEmpty(telegramFormat)) {
        // フォーマット指定がブランクの場合
        String coopCdSub0 = mcl.getCoopCdSub();
        String errMsg = String.format("対象レイアウトファイルの電文フォーマットが不正です。施設コード:[%s], 連携版番号:[%s], 送受信向き:[%s], 電文種別:[%s], 電文付帯情報:[%s], 電文種別補足コード:[%s]",
          facilityCd, coopVersion, direction, coopCd, coopCdIndex, coopCdSub0);
        eventLogMessage.setLogMessage(errMsg);
        eventLogMessage.setFacilityCd(facilityCd);
        eventLogMessage.setInvokeClass(this.getClass().getName());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        throw new NtssException(errMsg);
      }
      return mcl;
    }
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end
  }

// add 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
  /**
   * 電文種別補足コードで変換レイアウトマスタを取得する。
   *
   * @param facilityCd  施設コード
   * @param direction   向き（送受信）
   * @param coopCd      電文種別
   * @param coopCdIndex 付帯情報（電文）
   * @param coopVersion 連携版番号
   * @param coopCdSub   電文種別補足コード
   * @return 変換レイアウトマスタ（{@link MstCoopLayout}）のエンティティ
   */
  public MstCoopLayout getMstCoopLayoutBySub(String facilityCd, String direction, String coopCd, String coopCdIndex,
                                             String coopVersion, String coopCdSub) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    List<MstCoopLayout> layoutList = mstCoopLayoutDao.selectList(facilityCd, coopCd, coopCdIndex, coopVersion,
      direction, coopCdSub);

    if (layoutList == null || layoutList.size() == 0) {
      String errMsg = String.format("対象レイアウトファイルが存在しません。施設コード:[%s], 連携版番号:[%s], 送受信向き:[%s], 電文種別:[%s], 電文付帯情報:[%s], 電文種別補足コード:[%s]",
        facilityCd, coopVersion, direction, coopCd, coopCdIndex, coopCdSub);
      eventLogMessage.setLogMessage(errMsg);
      eventLogMessage.setFacilityCd(facilityCd);
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new NtssException(errMsg);
    } else if (layoutList.size() > 1) {
      String errMsg = String.format("対象レイアウトファイルが複数存在します。施設コード:[%s], 連携版番号:[%s], 送受信向き:[%s], 電文種別:[%s], 電文付帯情報:[%s], 電文種別補足コード:[%s]",
        facilityCd, coopVersion, direction, coopCd, coopCdIndex, coopCdSub);
      eventLogMessage.setLogMessage(errMsg);
      eventLogMessage.setFacilityCd(facilityCd);
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new NtssException(errMsg);
    } else {
      MstCoopLayout mcl = layoutList.get(0);
      String telegramFormat = StringUtils.isEmpty(mcl.getCoopFormat())? "":mcl.getCoopFormat().trim();
      mcl.setCoopFormat(telegramFormat);
      if (StringUtils.isEmpty(telegramFormat)) {
        // フォーマット指定がブランクの場合
        String errMsg = String.format("対象レイアウトファイルの電文フォーマットが不正です。施設コード:[%s], 連携版番号:[%s], 送受信向き:[%s], 電文種別:[%s], 電文付帯情報:[%s], 電文種別補足コード:[%s]",
          facilityCd, coopVersion, direction, coopCd, coopCdIndex, coopCdSub);
        eventLogMessage.setLogMessage(errMsg);
        eventLogMessage.setFacilityCd(facilityCd);
        eventLogMessage.setInvokeClass(this.getClass().getName());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        throw new NtssException(errMsg);
      }
      return mcl;
    }
  }

  /**
   * 電文種別詳細補足コードで変換レイアウト詳細マスタを取得する。
   *
   * @param facilityCd 施設コード
   * @param direction 向き（送受信）
   * @param coopCd 電文種別
   * @param coopVersion 連携版番号
   * @param coopCdDetail 電文種別詳細コード
   * @param coopCdDetailSub 電文種別詳細補足コード
   * @return 変換レイアウト詳細マスタ（{@link MstCoopLayoutDetail}）のエンティティ
   */
  public MstCoopLayoutDetail getMstCoopLayoutDetailBySub(String facilityCd, String direction, String coopCd,
                                                         String coopVersion, String coopCdDetail, String coopCdDetailSub) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    List<MstCoopLayoutDetail> layoutDetailList = mstCoopLayoutDetailDao.selectList(facilityCd, coopCd, coopVersion,
      direction, coopCdDetail, coopCdDetailSub);

    if (layoutDetailList == null || layoutDetailList.size() == 0) {
      String errMsg = String.format("対象レイアウト詳細ファイルが存在しません。施設コード:[%s], 連携版番号:[%s], 送受信向き:[%s], 電文種別:[%s], 電文種別詳細コード:[%s], 電文種別詳細補足コード:[%s]",
        facilityCd, coopVersion, direction, coopCd, coopCdDetail, coopCdDetailSub);
      eventLogMessage.setLogMessage(errMsg);
      eventLogMessage.setFacilityCd(facilityCd);
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new NtssException(errMsg);
    } else if (layoutDetailList.size() > 1) {
      String errMsg = String.format("対象レイアウト詳細ファイルが複数存在します。施設コード:[%s], 連携版番号:[%s], 送受信向き:[%s], 電文種別:[%s], 電文種別詳細コード:[%s], 電文種別詳細補足コード:[%s]",
        facilityCd, coopVersion, direction, coopCd, coopCdDetail, coopCdDetailSub);
      eventLogMessage.setLogMessage(errMsg);
      eventLogMessage.setFacilityCd(facilityCd);
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new NtssException(errMsg);
    } else {
      MstCoopLayoutDetail layoutDetail = layoutDetailList.get(0);
      return layoutDetail;
    }
  }

  /**
   * 電文種別詳細補足コードが引数に一致するレコードがなく、preのレコードがある場合は後者を取得する。
   *
   * @param facilityCd 施設コード
   * @param direction 向き（送受信）
   * @param coopCd 電文種別
   * @param coopVersion 連携版番号
   * @param coopCdDetail 電文種別詳細コード
   * @param coopCdDetailSub 電文種別詳細補足コード
   * @param preConst 電文種別詳細補足コードpreに対応する定数
   * @param allConst 電文種別詳細補足コードallに対応する定数
   * @return 変換レイアウト詳細マスタ（{@link MstCoopLayoutDetail}）のエンティティ
   */
  public MstCoopLayoutDetail getMstCoopLayoutDetailWithPre(String facilityCd, String direction, String coopCd,
            String coopVersion, String coopCdDetail, String coopCdDetailSub, String preConst, String allConst) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    List<MstCoopLayoutDetail> mcldList = mstCoopLayoutDetailDao.selectWithPre(facilityCd, coopCd, coopVersion,
      direction, coopCdDetail, coopCdDetailSub, preConst, allConst);

    if (mcldList == null || mcldList.size() == 0) {
      String errMsg = String.format("対象レイアウト詳細ファイルが存在しません。施設コード:[%s], 連携版番号:[%s], 送受信向き:[%s], 電文種別:[%s], 電文種別詳細コード:[%s], 電文種別詳細補足コード:[%s,%s,%s]",
        facilityCd, coopVersion, direction, coopCd, coopCdDetail, coopCdDetailSub, preConst, allConst);
      eventLogMessage.setLogMessage(errMsg);
      eventLogMessage.setFacilityCd(facilityCd);
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new NtssException(errMsg);
    } else {
      MstCoopLayoutDetail mcld = mcldList.get(0);
      if (mcldList.size() > 1) {
        MstCoopLayoutDetail mcldCheck = mcldList.get(1);
        String coopCdDetailSub0 = mcld.getCoopCdDetailSub();
        String coopCdDetailSub1 = mcldCheck.getCoopCdDetailSub();
        if (coopCdDetailSub0.equals(coopCdDetailSub1)) {
          String errMsg = String.format("対象レイアウト詳細ファイルが複数存在します。施設コード:[%s], 連携版番号:[%s], 送受信向き:[%s], 電文種別:[%s], 電文種別詳細コード:[%s], 電文種別詳細補足コード:[%s]",
            facilityCd, coopVersion, direction, coopCd, coopCdDetail, coopCdDetailSub0);
          eventLogMessage.setLogMessage(errMsg);
          eventLogMessage.setFacilityCd(facilityCd);
          eventLogMessage.setInvokeClass(this.getClass().getName());
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          throw new NtssException(errMsg);
        }
      }
      return mcld;
    }
  }
// add 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end

  /* modify by chamaojia 2023-06-20 入力パラメータを追加します, 方向を区別する, 成功したレコードを返す  --start */
  /**
   * 対象ジャーナルの変換ステータスを「処理中」に更新する。
   *
   * @param journalCtlNoList ジャーナルの管理番号のリスト
   * @param statusCode       更新後の変換ステータス
   * @return 更新されたレコード数
   */
  @Override
  public List<Long> updateConvStatus(List<Long> journalCtlNoList, String statusCode, String direction) {

    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "sys_coop_journal";
    // SQL検索条件
    String inStr = getInStr("ctl_no IN ", journalCtlNoList);
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(inStr + "\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    Timestamp now = new Timestamp(clockWrapper.getClockMillis());
    // #8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 周 mod start
//    int updateCount = sysCoopJournalDao.updateConvStatusConverting(journalCtlNoList, statusCode, now);
    //#8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230406 mod start
//    int updateCount = 0;
//    try {
//      String testStr = "";
//      for(Long e : journalCtlNoList) {
//        testStr = testStr + e.toString() + ",";
//      }
//      testStr = testStr.substring(0, testStr.lastIndexOf(","));
//      updateCount = sysCoopJournalDao.updateConvStatusConverting(testStr, statusCode, now);
//    } catch (Exception e) {
//      e.printStackTrace();
//    }

    int updateCount = 0;
    List<Long> successCtlNoList = new ArrayList<>();
    for (long ctlNo : journalCtlNoList) {
      int count = sysCoopJournalDao.updateConvStatusConvertingToOne(ctlNo, statusCode, now
              , NtssCoopApiConstants.AnaResult.UNPROCESS.getResult());
      if (count > 0) {
        updateCount ++;
        successCtlNoList.add(ctlNo);
      }
    }
    //#8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230406 mod end
    // #8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 周 mod end

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End

    // add 2021-04-06 課題No.1:API連動設定:動作条件「処理完了時、処理エラー時、処理スキップ時」を追加 孫 start
    // 事後APIキック機能を呼び出し
    if (updateCount > 0
      && (NtssCoopApiConstants.AnaResult.DONE.getResult().equals(statusCode)
        || NtssCoopApiConstants.AnaResult.SKIP.getResult().equals(statusCode)
        || NtssCoopApiConstants.AnaResult.INTERNAL_ERROR.getResult().equals(statusCode)
        || NtssCoopApiConstants.AnaResult.INTERNAL_ERROR_BY_CARTE.getResult().equals(statusCode))) {

      for (Long ctlNo : successCtlNoList) {
        SysCoopJournal journal = sysCoopJournalDao.selectByPK(ctlNo);

        CallApiJournalRequest callApiJournalRequest = new CallApiJournalRequest();
        BeanUtils.copyProperties(journal, callApiJournalRequest);
        // mod 2021-06-09 #5278 API連動処理の判定が正しくない wangchen start
        if (NtssCoopApiConstants.AnaResult.DONE.getResult().equals(statusCode)) {
          callApiJournalRequest.setApiTimingIo(NtssCoopApiConstants.ApiTimingIoStatus.ANA_DONE.getStatus());
        } else if (NtssCoopApiConstants.AnaResult.SKIP.getResult().equals(statusCode)) {
          callApiJournalRequest.setApiTimingIo(NtssCoopApiConstants.ApiTimingIoStatus.ANA_SKIP.getStatus());
        } else if (NtssCoopApiConstants.AnaResult.INTERNAL_ERROR.getResult().equals(statusCode)
          || NtssCoopApiConstants.AnaResult.INTERNAL_ERROR_BY_CARTE.getResult().equals(statusCode)) {
          callApiJournalRequest.setApiTimingIo(NtssCoopApiConstants.ApiTimingIoStatus.ANA_ERROR.getStatus());
        }
        // mod 2021-06-09 #5278 API連動処理の判定が正しくない wangchen end
        callApiJournalRequest.setApiTimingBa(NtssCoopApiConstants.ApiTimingBaStatus.AFTER.getStatus());
        boolean callResult = callApiService.callApiJournal(callApiJournalRequest, journal, null);
        if (!callResult) {
          break;
        }
      }
    }
    // add 2021-04-06 課題No.1:API連動設定:動作条件「処理完了時、処理エラー時、処理スキップ時」を追加 孫 end

    return successCtlNoList;
  }
  /* modify by chamaojia 2023-06-20 入力パラメータを追加します, 方向を区別する, 成功したレコードを返す  --end */

  // add 2021-06-10 #5279:API連動の処理順番が正しくない 孫 start
  /**
   * 対象ジャーナルの変換ステータスを更新する(API連動処理が無し)
   *
   * @param journalCtlNo
   * @param message      メッセージ
   * @param statusCode   更新後の変換ステータス
   * @return 更新されたレコード数
   */
  @Override
  public int updateAnaResultNotCallApi(Long journalCtlNo, String message, String statusCode) {

    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "sys_coop_journal";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" ctl_no = " + journalCtlNo + "\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    Timestamp now = new Timestamp(clockWrapper.getClockMillis());
    int updateCount = sysCoopJournalDao.updateAnaResult(journalCtlNo, statusCode, message, now);

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End

    return updateCount;
  }
  // add 2021-06-10 #5279:API連動の処理順番が正しくない 孫 end

  /**
   * 対象ジャーナルの変換ステータスを更新する
   *
   * @param journalCtlNo
   * @param message      メッセージ
   * @param statusCode   更新後の変換ステータス
   * @return 更新されたレコード数
   */
  @Override
  public int updateAnaResult(Long journalCtlNo, String message, String statusCode) {

    // mod 2021-06-10 #5279:API連動の処理順番が正しくない 孫 start
//    // DB更新ログ出力ロジック wangzuo Start
//    String tableName = "sys_coop_journal";
//    // SQL検索条件
//    StringBuffer wheres = new StringBuffer("");
//    wheres.append(" WHERE\n");
//    wheres.append(" ctl_no = " + journalCtlNo + "\n");
//    // logCommon設定
//    DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
//    // ログ出力カラム情報及び更新前データ情報取得
//    boolean setResult = logCommon.setInfo();
//    // DB更新ログ出力ロジック wangzuo End
//
//    Timestamp now = new Timestamp(clockWrapper.getClockMillis());
//    int updateCount = sysCoopJournalDao.updateAnaResult(journalCtlNo, statusCode, message, now);
//
//    // DB更新ログ出力ロジック wangzuo Start
//    // 更新後データ取得、差分あれば、log出力
//    if (setResult && updateCount > 0) {
//      logCommon.updateLog();
//    }
//    // DB更新ログ出力ロジック wangzuo End

    // 「対象ジャーナルの変換ステータスを更新する」処理はupdateAnaResultNotCallApiを移動する。

    // 対象ジャーナルの変換ステータスを更新する(API連動処理が無し)を呼び出し
    int updateCount = updateAnaResultNotCallApi(journalCtlNo, message, statusCode);
    // mod 2021-06-10 #5279:API連動の処理順番が正しくない 孫 end

    // add 2021-04-06 課題No.1:API連動設定:動作条件「処理完了時、処理エラー時、処理スキップ時」を追加 孫 start
    // 事後APIキック機能を呼び出し
    if (updateCount > 0
      && (NtssCoopApiConstants.AnaResult.DONE.getResult().equals(statusCode)
      || NtssCoopApiConstants.AnaResult.SKIP.getResult().equals(statusCode)
      || NtssCoopApiConstants.AnaResult.INTERNAL_ERROR.getResult().equals(statusCode)
      || NtssCoopApiConstants.AnaResult.INTERNAL_ERROR_BY_CARTE.getResult().equals(statusCode))) {

      SysCoopJournal journal = sysCoopJournalDao.selectByPK(journalCtlNo);

      CallApiJournalRequest callApiJournalRequest = new CallApiJournalRequest();
      BeanUtils.copyProperties(journal, callApiJournalRequest);
      // mod 2021-06-09 #5278 API連動処理の判定が正しくない wangchen start
      if (NtssCoopApiConstants.AnaResult.DONE.getResult().equals(statusCode)) {
        callApiJournalRequest.setApiTimingIo(NtssCoopApiConstants.ApiTimingIoStatus.ANA_DONE.getStatus());
      } else if (NtssCoopApiConstants.AnaResult.SKIP.getResult().equals(statusCode)) {
        callApiJournalRequest.setApiTimingIo(NtssCoopApiConstants.ApiTimingIoStatus.ANA_SKIP.getStatus());
      } else if (NtssCoopApiConstants.AnaResult.INTERNAL_ERROR.getResult().equals(statusCode)
        || NtssCoopApiConstants.AnaResult.INTERNAL_ERROR_BY_CARTE.getResult().equals(statusCode)) {
        callApiJournalRequest.setApiTimingIo(NtssCoopApiConstants.ApiTimingIoStatus.ANA_ERROR.getStatus());
      }
      // mod 2021-06-09 #5278 API連動処理の判定が正しくない wangchen end
      callApiJournalRequest.setApiTimingBa(NtssCoopApiConstants.ApiTimingBaStatus.AFTER.getStatus());
      boolean callResult = callApiService.callApiJournal(callApiJournalRequest, journal, null);
//      if (!callResult) {
//        break;
//      }
    }
    // add 2021-04-06 課題No.1:API連動設定:動作条件「処理完了時、処理エラー時、処理スキップ時」を追加 孫 end

    return updateCount;
  }

  // add 2020-12-21 FNSI-改修内容 変換処理中の処理スキップ機能を追加 商 start

  /**
   * 連携対象の電文種別を取得する。
   *
   * @param facilityCd 施設コード
   * @return 連携対象の電文種別リスト
   * @see jp.co.nikkiso.ntss.coop_api.service.ConvertCommonService#getCoopOrdCdList(String)
   */
  public List<MstCoopFacility.CoopOrdCd> getCoopOrdCdList(String facilityCd) {
    List<MstCoopFacility.CoopOrdCd> coopOrdCdList = new ArrayList<>();
    MstCoopFacility mstCoopFacility = mstCoopFacilityDao.select(facilityCd);
    if (mstCoopFacility != null) {
      if (mstCoopFacility.getCommonSetting().getCoopOrdCds() != null &&
        mstCoopFacility.getCommonSetting().getCoopOrdCds().size() > 0) {
        return mstCoopFacility.getCommonSetting().getCoopOrdCds();
      }
    }
    return coopOrdCdList;
  }
  // add 2020-12-21 FNSI-改修内容 変換処理中の処理スキップ機能を追加 商 end

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
  private DataUpdateLogCommonNew getLogCommon(String tableName, StringBuffer whereStr, EventLogMessage eventLogMessage) {
    DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
    logCommon.setEventLoggerFactory(eventLoggerFactory);
    logCommon.setLogServiceCore(logServiceCore);
    logCommon.setConfig(defaultDbConfig);
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

  // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 start
  /**
   * 対象ジャーナルのtempContentを更新する
   *
   * @param journalCtlNo
   * @param tempContent
   * @param crud
   * @return 更新されたレコード数
   */
  @Override
// mod 2021-08-25 受信時、電文内容を解析した後、sys_coop_journalのcrudを更新するの対応 孫 start
//  public int updateTempContent(Long journalCtlNo, String tempContent) {
  public int updateTempContent(Long journalCtlNo, String tempContent, String crud) {
// mod 2021-08-25 受信時、電文内容を解析した後、sys_coop_journalのcrudを更新するの対応 孫 end

    String tableName = "sys_coop_journal";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" ctl_no = " + journalCtlNo + "\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();

    Timestamp now = new Timestamp(clockWrapper.getClockMillis());
// mod 2021-08-25 受信時、電文内容を解析した後、sys_coop_journalのcrudを更新するの対応 孫 start
//    int updateCount = sysCoopJournalDao.updateTempContent(journalCtlNo, tempContent, now);
    int updateCount = sysCoopJournalDao.updateTempContent(journalCtlNo, tempContent, crud, now);
// mod 2021-08-25 受信時、電文内容を解析した後、sys_coop_journalのcrudを更新するの対応 孫 end
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.updateLog();
    }

    return updateCount;
  }

  /**
   * 対象ジャーナルのcoopOrdNoを更新する
   *
   * @param journalCtlNo
   * @param coopOrdNo
   * @param idMap
   * @return 更新されたレコード数
   */
  @Override
  public int updateCoopOrdNo(Long journalCtlNo, String coopOrdNo, Map<String,Object> idMap) {
    String hospPatId = null;
    Long patId = null;
    Long ordNo = 0L;
    String tableName = "sys_coop_journal";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" ctl_no = " + journalCtlNo + "\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();

    for (String key : idMap.keySet()) {
      switch (key) {
        case "@hospPatId":
          hospPatId = (String)idMap.get(key);
          break;
        case "@patId":
          patId = (Long)idMap.get(key);
          break;
        case "@ordNo":
          ordNo = (Long)idMap.get(key);
          if (ordNo == null) {
            ordNo = 0L;
          }
          break;
      }
    }
    Timestamp now = new Timestamp(clockWrapper.getClockMillis());
    int updateCount = sysCoopJournalDao.updateCoopOrdNo(journalCtlNo, hospPatId, patId, ordNo, coopOrdNo, now);

    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.updateLog();
    }

    return updateCount;
  }

  @Override
  public void updateCoopOrdNo(SysCoopJournal journal) {
    int updateCount = sysCoopJournalDao.updateCoopOrdNoByCtlNo(journal.getCtlNo(), journal.getCoopOrdNo());

  }
  // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 end
// add 2022-11-08 bug #7113 rep_dial連携の処理タイミングがずれる 孫 start
  /**
   * 帳票データを更新する。
   *
   * @param journal 外部連携用ジャーナル
   */
  @Override
  public void updateReportData(SysCoopJournal journal) {
    String coopCd = journal.getCoopCd();
    String coopCdIndex = journal.getCoopCdIndex();
    Long reportCd = journal.getReportCd();
    String dumpPath = journal.getDumpPath();

    if ( (!StringUtils.isEmpty(coopCd) && coopCd.equals("rep_dial"))
      && (!StringUtils.isEmpty(coopCdIndex) && coopCdIndex.contains("pdf"))
      && (reportCd != null && !StringUtils.isEmpty(dumpPath)) ) {
        try {
          sysCoopJournalDao.updateReportDataByCtlNo(journal.getCtlNo(), dumpPath, reportCd);
        } catch (Exception ex) {
          EventLogMessage eventLogMessage = new EventLogMessage();
          String errMsg = String.format("%s %s", StringUtils.isEmpty(ex.getMessage()) ? "帳票生成データの更新に失敗しました。" : ex.getMessage(), getAddExceptionError(ex));
          eventLogMessage.setLogMessage(errMsg);
          eventLogMessage.setFacilityCd(journal.getFacilityCd());
          eventLogMessage.setInvokeClass(this.getClass().getName());
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);

          throw new NtssException(errMsg);
        }
    }
  }

  private String getAddExceptionError(Exception e) {
    StackTraceElement[]  list = null;
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
    return errAdd;
  }
// add 2022-11-08 bug #7113 rep_dial連携の処理タイミングがずれる 孫 end

  /* add by chamaojia 2023-05-22 検査結果1 file多患者受信時のデータ分割処理とIFedgeファイル移動処理の競合  --start */
  // 次の4つのインタフェースは、JournalConvertReceiveResourceから移行してきました
  //　add #5607 連動機能の実装確認 20221205 孟堅　strat

  /***
   * 電文フォーマットがmultiの場合、1電文に複数患者の検査結果があります。
   *    * 1行１ジャーナルで処理する  from : 明石　
   * @param facilityCd  施設コード
   */
  public List<SysCoopJournal> updateJournalListExamRst(String facilityCd, List<Long> ctlNoList) {
// del 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    List<MstCoopIni> values = mstCoopIniDao.selectByFacilityCd(facilityCd);
//    if (null != values) {
//      MstCoopIni value = values.get(0);
//      String memo = value.getCoopIniMemo();
//      if (CoopCdConstant.CoopIniMemo.NKKNKK.isSameResult(memo)) {
// del 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    // mod #8103 GX連携で実装されていない機能（利用者情報）limf start
    // upd #8567 （#8179问题调查结果）外部連携全般に必要な機能が制限されている改正 ztc 0508 start
//    List<SysCoopJournal> coopCdsAndKey0s =new ArrayList<>();
//    SysCoopJournal sysCoopJournal = new SysCoopJournal();
//    sysCoopJournal.setCoopCd(CoopCdConstant.EXAM_RST);
//    sysCoopJournal.setKey0(Key0Constant.NKK);
//    coopCdsAndKey0s.add(sysCoopJournal);
//    sysCoopJournal = new SysCoopJournal();
//    sysCoopJournal.setCoopCd(CoopCdConstant.STAFF_MST);
//    sysCoopJournal.setKey0(Key0Constant.GX);
//    coopCdsAndKey0s.add(sysCoopJournal);
//    List<SysCoopJournal> sysCoopJournals = sysCoopJournalDao.selectCoopByCoopCdKey0s(facilityCd,JournalConvertConstants.DIRECTION_RECEIVE,
//      NtssCoopApiConstants.CoopResult.UNPROCESS.getResult(),NtssCoopApiConstants.CoopResult.DONE.getResult(),
//      coopCdsAndKey0s);
    List<SysCoopJournal> sysCoopJournalListToResult = new ArrayList<>();
    List<SysCoopJournal> sysCoopJournals = sysCoopJournalDao.selectCoopByCoopCdKey0s(facilityCd,JournalConvertConstants.DIRECTION_RECEIVE,
            NtssCoopApiConstants.CoopResult.UNPROCESS.getResult(),NtssCoopApiConstants.CoopResult.DONE.getResult()
            , ctlNoList == null ? new ArrayList<>() : ctlNoList);
    // upd #8567 （#8179问题调查结果）外部連携全般に必要な機能が制限されている改正 ztc 0508 end
//    List<SysCoopJournal> exam_rst = sysCoopJournalDao.selectCoop(
//// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////          facilityCd, JournalConvertConstants.DIRECTION_RECEIVE,
//          facilityCd, Key0Constant.NKK, JournalConvertConstants.DIRECTION_RECEIVE,
//// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//          NtssCoopApiConstants.CoopResult.UNPROCESS.getResult(),
//          NtssCoopApiConstants.CoopResult.DONE.getResult(),
//          CoopCdConstant.EXAM_RST);
    if (sysCoopJournals != null) {
      for (SysCoopJournal item : sysCoopJournals) {
//            splitMultJournal(item);
        sysCoopJournalListToResult.addAll(splitMultJournal(item));
      }
      // mod #8103 GX連携で実装されていない機能（利用者情報）limf end

    }
// del 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//      }
//    }
// del 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    return sysCoopJournalListToResult;
  }

  /**
   * ジャーナルの複数のデータの分割
   *
   * @param journal ジャーナル
   */
  private List<SysCoopJournal> splitMultJournal(SysCoopJournal journal) {
    List<SysCoopJournal> sysCoopJournals = new ArrayList<>();
    if (journal != null) {
// add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
      // 電子カルテ種別
      String key0 = StringUtils.isEmpty(journal.getKey0())?"":journal.getKey0();
      // 連携版番号
      String coopVersion = StringUtils.isEmpty(journal.getCoopVersion())?"":journal.getCoopVersion();
// add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
      // 電文本体
      byte[] telegram = journal.getDump();
      // 患者単位の電文
      List<byte[]> telegramByPatientList = Collections.singletonList(telegram);
      try {
        // 1電文に複数の患者が含まれる場合
        // 区切り文字で分割した電文を処理対象とする。
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//        String[] multiSetting = getMultiSetting(journal.getFacilityCd(), journal.getDirection(), journal.getCoopCd(), journal.getCoopCdIndex());
        String[] multiSetting = getMultiSetting(journal.getFacilityCd(), journal.getDirection(), journal.getCoopCd(),
                journal.getCoopCdIndex(), coopVersion);
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
        if (Boolean.valueOf(multiSetting[0])) {
          String[] delimStrs = Arrays.copyOfRange(multiSetting, 1, multiSetting.length);
          telegramByPatientList = splitTelegram(telegram, delimStrs);
          if (telegramByPatientList.size() == 1) {
            return sysCoopJournals;
          }
          // mod #8103 GX連携で実装されていない機能（利用者情報）limf start
          for (byte[] b : telegramByPatientList) {
            SysCoopJournal newJournal = new SysCoopJournal() {
            };
            newJournal.setFacilityCd(journal.getFacilityCd());
            Long ctlNo = sysCoopJournalDao.selectNextSeqCtlNo();
            newJournal.setCtlNo(ctlNo);
            newJournal.setCoopCd(journal.getCoopCd());
            newJournal.setCoopCdIndex(journal.getCoopCdIndex());
// add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
            newJournal.setKey0(key0);
            newJournal.setCoopVersion(coopVersion);
// add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
            newJournal.setCrud(journal.getCrud());
            newJournal.setDirection(journal.getDirection());
            newJournal.setAnaResult(journal.getAnaResult());
            newJournal.setCoopResult(journal.getCoopResult());
            newJournal.setCrud(journal.getCrud());
            newJournal.setDump(b);
            newJournal.setOpeCd(journal.getOpeCd());
            newJournal.setBaseDate(journal.getBaseDate());
            newJournal.setUserId(journal.getUserId());
            newJournal.setAcceptNo(journal.getAcceptNo());
            sysCoopJournals.add(newJournal);
//            sysCoopJournalDao.insert(newJournal);
          }
          int[] insert = sysCoopJournalDao.insert(sysCoopJournals);
          // mod #8103 GX連携で実装されていない機能（利用者情報）limf end
          sysCoopJournalDao.deleteSysCoopJournalByCtlNo(journal.getCtlNo());
        }

      } catch (UnsupportedEncodingException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        if (journal != null && journal.getFacilityCd() != null) {
          eventLogMessage.setFacilityCd(journal.getFacilityCd());
        }
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      } catch (Exception ex) {
      }
    }
    return sysCoopJournals;
  }
  //　add #5607 連動機能の実装確認 20221205 孟堅　end

  /**
   * 複数患者指定を取得する。
   *
   * @param facilityCd 施設コード
   * @param direction 向き（送受信）
   * @param coopCd 電文種別
   * @param coopCdIndex 付帯情報（電文）
   * @param coopVersion 連携版番号
   * @return 先頭が複数患者対応可否文字列（"true"/"false"）、残りが区切り文字を表す文字列配列
   */
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  private String[] getMultiSetting(String facilityCd, String direction, String coopCd, String coopCdIndex) {
//    MstCoopLayout mcl = convertCommonService.getMstCoopLayout(facilityCd, direction, coopCd, coopCdIndex,
//      JournalConvertConstants.AUX_CODE_PRELOGIC);
  public String[] getMultiSetting(String facilityCd, String direction, String coopCd, String coopCdIndex,
                                   String coopVersion) {
    MstCoopLayout mcl = getMstCoopLayout(facilityCd, direction, coopCd, coopCdIndex, coopVersion,
            JournalConvertConstants.AUX_CODE_PRELOGIC);
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    String multi = mcl.getCoopSettingRoot().getMulti();
    EventLogMessage eventLogMessage = new EventLogMessage();

    if (StringUtils.isEmpty(multi)) {
      return new String[] { Boolean.FALSE.toString(), null };
    }

    String[] sp = multi.split(LAYOUT_MULTI_DELIM);
    if (sp.length == 1) {
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//      String errMsg = String.format("1電文複数患者指定で、区切り文字が指定されていません。 施設コード=[%s], 電文種別=[%s]", facilityCd, coopCd);
      String errMsg = String.format("1電文複数患者指定で、区切り文字が指定されていません。 施設コード=[%s], 電文種別=[%s], 連携版番号=[%s]",
              facilityCd, coopCd, coopVersion);
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      eventLogMessage.setLogMessage(errMsg);
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new NtssException(errMsg);
    }

    return Arrays.asList(sp).stream().map(e -> e.replaceAll(TELEGRAM_DELIM_CR, TELEGRAM_DELIM_CR_VALUE)
            .replaceAll(TELEGRAM_DELIM_LF, TELEGRAM_DELIM_LF_VALUE)).toArray(String[]::new);
  }

  /**
   * 電文を区切り文字で分割する。
   *
   * @param telegram 電文
   * @param delimStrs 電文区切り文字列（複数）
   * @return 分割された電文
   * @throws UnsupportedEncodingException
   */
  public List<byte[]> splitTelegram(byte[] telegram, String[] delimStrs) throws UnsupportedEncodingException {
    // 分割用の正規表現
    String s = REGEXP_GROUP_START + String.join(REGEXP_GROUP_OR, delimStrs) + REGEXP_GROUP_END;
    Pattern p = Pattern.compile(s);

    // 一旦文字列に変換してから分割する。
    // byte配列のまま複数の区切り文字で分割すると、処理が非常に複雑になる。
    // この後に項目を抽出して文字列に変換しており冗長だが、処理の読解性・保守性を優先した。
    //mod 7713 富士通指摘：PC上で使用している文字で判読不能になるものがある。張 start
//    String telegramStr = new String(telegram, JournalConvertConstants.TELEGRAM_ENCODING_BY_SJIS);
    String telegramStr = new String(telegram, JournalConvertConstants.TELEGRAM_ENCODING_BY_MS932);
    //mod 7713 富士通指摘：PC上で使用している文字で判読不能になるものがある。張 end
    String[] telegramParts = p.split(telegramStr);

    // 分割した電文文字列をbyte配列に変換する。
    // （Streamで変換したいところだが、明示的にループで処理する方法を採った。
    // Streamのmapやcollect処理では検査例外を処理できないことによる。
    // 検査例外: 下記の処理ではString.getBytes()で発生するUnsupportedEncodingException）
    List<byte[]> result = new ArrayList<>();
    for (String t : telegramParts) {
      //mod 7713 富士通指摘：PC上で使用している文字で判読不能になるものがある。張 start
//      result.add(t.getBytes(JournalConvertConstants.TELEGRAM_ENCODING_BY_SJIS));
      result.add(t.getBytes(JournalConvertConstants.TELEGRAM_ENCODING_BY_MS932));
      //mod 7713 富士通指摘：PC上で使用している文字で判読不能になるものがある。張 end
    }

    return result;
  }
  /* add by chamaojia 2023-05-22 検査結果1 file多患者受信時のデータ分割処理とIFedgeファイル移動処理の競合  --end */

  /**
   * 対象ジャーナルの変換ステータスを「未処理」に更新する。
   *
   * @param ctlNo ジャーナルの管理番号
   * @return 更新されたレコード数
   */
  @Transactional
  public int updateAnaResultUnprocess(Long ctlNo) {

    String tableName = "sys_coop_journal";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" ctl_no = " + ctlNo + "\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();

    //update
    SysCoopJournal journal = sysCoopJournalDao.selectByPK(ctlNo);
    journal.setAnaResult(AnaResult.UNPROCESS.getResult());
    journal.setInAnaDate(null);
    journal.setOutAnaDate(null);

    int updateCount = sysCoopJournalDao.update(journal);

    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.updateLog();
    }

    return updateCount;
  }
}
