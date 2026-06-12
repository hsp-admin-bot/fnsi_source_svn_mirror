package jp.co.nikkiso.ntss.coop_api.service;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Objects;
import java.util.Set;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import jp.co.nikkiso.ntss.coop_api.utils.ClockWrapper;
import jp.co.nikkiso.ntss.coop_api.utils.CoopCdConstant;
import jp.co.nikkiso.ntss.coop_api.utils.CoopLayoutConstant;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants;
import jp.co.nikkiso.ntss.core.dao.MstBedDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopIniDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopLayoutDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopLayoutDetailDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainRestoreDao;
import jp.co.nikkiso.ntss.core.dao.SysCoopJournalDao;
import jp.co.nikkiso.ntss.core.entity.MstBed;
import jp.co.nikkiso.ntss.core.entity.MstCoopIni;
import jp.co.nikkiso.ntss.core.entity.MstCoopLayout;
import jp.co.nikkiso.ntss.core.entity.MstCoopLayoutDetail;
import jp.co.nikkiso.ntss.core.entity.OrdMainRestore;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import jp.co.nikkiso.ntss.core.entity.json.LayoutExtSetting;
import org.apache.commons.collections4.CollectionUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants.ElementsValue;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.entity.xml.Item;
import jp.co.nikkiso.ntss.core.entity.xml.Occ;
import jp.co.nikkiso.ntss.core.entity.xml.Root;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Service
public class ConvertSendTextServiceImpl implements ConvertSendByFormatService {
  /** DI */
  @Autowired
  MstCoopLayoutDao mstCoopLayoutDao;
  @Autowired
  MstCoopLayoutDetailDao mstCoopLayoutDetailDao;
  @Autowired
  SysCoopJournalDao sysCoopJournalDao;
  @Autowired
  MstBedDao mstBedDao;
  @Autowired
  ClockWrapper clockWrapper;
  @Autowired
  ConvertSendCommonService convertSendCommonService;
  @Autowired
  private OrdMainDao ordMainDao;

  //mod #10901 #10902 mst_coop_apilinkの動作について 20241004 zhaoqi start
  @Autowired
  private OrdMainRestoreDao ordMainRestoreDao;
  //mod #10901 #10902 mst_coop_apilinkの動作について 20241004 zhaoqi end

  @Autowired
  private MstCoopIniDao mstCoopIniDao;
  @Autowired
  private LogService logService;
  // mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
//  @Autowired
//  private MstCoopLayoutService mstCoopLayoutService;
  @Autowired
  private ConvertCommonService convertCommonService;
  // mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end

  //mod 7713 富士通指摘：PC上で使用している文字で判読不能になるものがある。張 start
//  /** バイト長計算に必要な標準文字コード(Shift-JIS) */
//  private static final String DEFAULT_ENCODE = JournalConvertConstants.TELEGRAM_ENCODING_BY_SJIS;
  /** バイト長計算に必要な標準文字コード(MS932) */
  private static final String DEFAULT_ENCODE = JournalConvertConstants.TELEGRAM_ENCODING_BY_MS932;
  //mod 7713 富士通指摘：PC上で使用している文字で判読不能になるものがある。張 end
  /* del by chamaojia 2026-04-27 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  // private int head=1;
  //
  // // add 2020-12-30 No.724:電文内データ文字列結合 商 start
  // private List<Map<String, Object>> itemSuffixList = new ArrayList<>();
  // private List<Map<String, Object>> itemSuffixDetailList = new ArrayList<>();
  // // add 2020-12-30 No.724:電文内データ文字列結合 商 end
  /* del by chamaojia 2026-04-27 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

  @Override
  public void createTelegram(SysCoopJournal journal) {
    String facilityCd = journal.getFacilityCd();
// add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    String coopVersion  = StringUtils.isEmpty(journal.getCoopVersion())?"":journal.getCoopVersion();
// add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

    // ジャーナルから変換したいレイアウトを取得する
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
////    MstCoopLayout layout = mstCoopLayoutDao.select(facilityCd, journal.getCoopCd(), journal.getCoopCdIndex(), JournalConvertConstants.DIRECTION_SEND, getCoopCdSub(journal.getCrud()));
////    MstCoopLayout layout=mstCoopLayoutService.getMstCoopLayoutByMstCoopIni(journal);
//    // 7525 rst_dial連携（拡張）ヘッダON/OFF切り替え  卓 2023-2-2 start
////    MstCoopLayout layout=mstCoopLayoutService.getMstCoopLayoutByMstCoopIni(journal);
//    MstCoopLayout layout=mstCoopLayoutService.getMstCoopLayout(journal, JournalConvertConstants.DIRECTION_SEND);
//    // 7525 rst_dial連携（拡張）ヘッダON/OFF切り替え  卓 2023-2-2 end
//
//    // レイアウトがない場合はジャーナルをエラーにして、次のジャーナル変換に移る
//    if (layout == null) {
//      throw new NtssException("対象ジャーナルの送信用変換レイアウトが存在しません。 "
//        + "facility_cd:[" + journal.getFacilityCd() + "], "
//        + "coop_cd:[" + journal.getCoopCd() + "], "
//// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//        + "coop_version:[" + coopVersion + "], "
//// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//        + "coop_cd_sub:[" + getCoopCdSub(journal.getCrud()) + "]");
//    }
    String direction = journal.getDirection();
    String coopCd = journal.getCoopCd();
    String coopCdIndex = journal.getCoopCdIndex();
    String coopCdSub = convertSendCommonService.getCoopCdSub(journal.getCrud());
    MstCoopLayout layout = convertCommonService.getMstCoopLayoutBySub(facilityCd, direction, coopCd, coopCdIndex,
      coopVersion, coopCdSub);
    /* add by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
    List<MstCoopIni> coopIniList = convertCommonService.getMstCoopIniByFacilityCd(facilityCd);
    MstCoopIni coopIni = CollectionUtils.isEmpty(coopIniList) ? null : coopIniList.get(0);
    /* add by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end

    // add 2020-12-30 No.724:電文内データ文字列結合 商 start
    /* upd by chamaojia 2026-04-27 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
    // itemSuffixList = getItemSuffixList(layout.getCoopExtSetting());
    TextTelegramContext textTelegramContext = new TextTelegramContext();
    textTelegramContext.setItemSuffixList(getItemSuffixList(layout.getCoopExtSetting()));
    /* upd by chamaojia 2026-04-27 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
    // add 2020-12-30 No.724:電文内データ文字列結合 商 end

    // data-setを利用した出力がある場合に限り、あらかじめdata-setをリクエストしておく
    /* upd by chamaojia 2026-04-24 [10959] add param coopIni、textTelegramContext --start */
    Map<String, List<Map<String, Object>>> dataSetResultMap = convertSendCommonService.createRequestAndRequestByDataSetApi(journal, layout.getCoopExtSetting(), null, coopIni);

    // 送信用の電文を作成
    String telegram = createTelegram(layout.getCoopSettingRoot(), journal, layout, new StringBuilder(), dataSetResultMap, coopIni, textTelegramContext);
    /* upd by chamaojia 2026-04-24 [10959] add param coopIni、textTelegramContext --end */
    journal.setDumpPath(convertSendCommonService.getDumpFileName(layout, journal));
    try {
      journal.setDump(telegram.getBytes(DEFAULT_ENCODE));
    } catch (UnsupportedEncodingException e) {
      throw new NtssException("電文のエンコーディングがサポートされていない形式です。", e);
    }
    EventLogMessage eventLogMessage = new EventLogMessage();
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    eventLogMessage.setLogMessage("ConvertSendServiceImpl#createTelegram 電文内容 facility_cd:[" + facilityCd + "], coop_cd:[" + journal.getCoopCd() + "], telegram:[" + telegram + "]");
    eventLogMessage.setLogMessage("ConvertSendServiceImpl#createTelegram 電文内容 facility_cd:[" + facilityCd
      + "], coop_cd:[" + journal.getCoopCd() + "], coop_version:[" + coopVersion + "], telegram:[" + telegram + "]");
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    eventLogMessage.setFacilityCd(facilityCd);
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
  }

  /**
   * 電文作成
   *
   * @param root - {@link Root}
   * @param journal - {@link SysCoopJournal}
   * @param builder - 電文用StringBuilder
   * @param dataSetResultMap - data-setの結果Map
   * @return 電文
   */
  /* upd by chamaojia 2026-04-24 [10959] add param coopIni、textTelegramContext --start */
  private String createTelegram(Root root, SysCoopJournal journal, MstCoopLayout mstCoopLayout, StringBuilder builder,
      Map<String, List<Map<String, Object>>> dataSetResultMap, MstCoopIni coopIni, TextTelegramContext textTelegramContext) {
    TelegramLengthCalculator telegramLengthCalculator = new TelegramLengthCalculator();
    String telegram = createTelegram(root, journal, mstCoopLayout, telegramLengthCalculator, builder, dataSetResultMap, coopIni, textTelegramContext);
    return telegramLengthCalculator.transformCaliculateTelegramLength(telegram);
  }
  /* upd by chamaojia 2026-04-24 [10959] add param coopIni、textTelegramContext --end */

  /**
   * 電文作成
   * @param root - {@link Root}
   * @param journal - {@link SysCoopJournal}
   * @param calculator - {@link TelegramLengthCalculator}
   * @param builder - 電文用StringBuilder
   * @param dataSetResultMap - mst_coop_layoutからのdataset結果Map
   * @return 電文
   */
  /* upd by chamaojia 2026-04-24 [10959] add param coopIni、textTelegramContext --start */
  private String createTelegram(Root root, SysCoopJournal journal, MstCoopLayout mstCoopLayout, TelegramLengthCalculator calculator,
      StringBuilder builder, Map<String, List<Map<String, Object>>> dataSetResultMap, MstCoopIni coopIni, TextTelegramContext textTelegramContext) {
  /* upd by chamaojia 2026-04-24 [10959] add param coopIni、textTelegramContext --end */
    EventLogMessage eventLogMessage = new EventLogMessage();
    // add 2021-10-08 #5247:繰り返し回数越えのデータ対応 孫 start
    // 5247を追加したソース、のみ移動する
    Map<String,Boolean> flagMap=new HashMap<>();
    Map<String,List<Map<String, Object>>> dataMap=new HashMap<>();
    String delimiter="";
    if(!Objects.isNull(root.getMulti())&&root.getMulti().contains("true")){
      delimiter=root.getMulti().substring(5);
      switch(delimiter){
        case "CR" :
          delimiter="\r";
          break;
        case "CRLF" :
          delimiter="\r\n";
          break;
        case "LFCR" :
          delimiter="\n\r";
          break;
        default :
          break;
      }
    }
    // add 2021-10-08 #5247:繰り返し回数越えのデータ対応 孫 end

// add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    String coopVersion = StringUtils.isEmpty(journal.getCoopVersion())?"":journal.getCoopVersion();
// add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

    // add 2021-10-08 #5247:繰り返し回数越えのデータ対応 孫 start
    if (StringUtils.isEmpty(delimiter)) {
      // add 2021-10-08 #5247:繰り返し回数越えのデータ対応 孫 end
      // 5247前のソースを復元します
      for (Item item : root.getItemList()) {
        // 繰り返しの場合は繰り返し用のXMLを取得して再帰
        if (item.isOcc()) {
          Occ occ = (Occ) item;
          List<Map<String, Object>> dataSetList = dataSetResultMap.get(occ.getSqlCode());
          if (occ.getLen() > 0) {
            // datasetの要素数を電文に含める
            calculator.addTotalLength(occ.getLen());
            builder.append(padding(occ, String.valueOf(dataSetList.size())));
          }
          for (Map<String, Object> dataSetMap : dataSetList) {
            if (!dataSetMap.containsKey("detail_id")) {
              throw new NtssException("対象datasetに必須なキーである[detail_id]が存在しません。"
                + "facility_cd:[" + journal.getFacilityCd() + "], "
                + "coop_cd:[" + journal.getCoopCd() + "], "
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
                + "coop_version:[" + coopVersion + "], "
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
                + "coop_cd_sub:[" + getCoopCdSub(journal.getCrud()) + "]");
            }

// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////            MstCoopLayoutDetail layoutDetail = mstCoopLayoutDetailDao.select(journal.getFacilityCd(), journal.getCoopCd(), JournalConvertConstants.DIRECTION_SEND, occ.getDetail(), String.valueOf(dataSetMap.get("detail_id")));
//            MstCoopLayoutDetail layoutDetail = mstCoopLayoutDetailDao.select(journal.getFacilityCd(),
//              journal.getCoopCd(), coopVersion, JournalConvertConstants.DIRECTION_SEND,
//              occ.getDetail(), String.valueOf(dataSetMap.get("detail_id")));
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//            // レイアウトがない場合はジャーナルをエラーにして、次のジャーナル変換に移る
//            if (layoutDetail == null) {
//              throw new NtssException("対象ジャーナルの送信用変換レイアウトDetailが存在しません。 "
//                + "facility_cd:[" + journal.getFacilityCd() + "], "
//                + "coop_cd:[" + journal.getCoopCd() + "], "
//// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//                + "coop_version:[" + coopVersion + "], "
//// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//                + "coop_cd_sub:[" + getCoopCdSub(journal.getCrud()) + "], "
//                + "coop_cd_detail:[" + occ.getDetail() + "], "
//                + "coop_cd_detail_sub:[" + String.valueOf(dataSetMap.get("detail_id")) + "]");
//            }
            MstCoopLayoutDetail layoutDetail = convertCommonService.getMstCoopLayoutDetailBySub(journal.getFacilityCd(),
              JournalConvertConstants.DIRECTION_SEND, journal.getCoopCd(), coopVersion, occ.getDetail(),
              String.valueOf(dataSetMap.get("detail_id")));
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end
            /* upd by chamaojia 2026-04-24 [10959] add param coopIni、textTelegramContext --start */
            // add 2020-12-30 No.724:電文内データ文字列結合 商 start
            textTelegramContext.setItemSuffixDetailList(getItemSuffixList(layoutDetail.getCoopExtSetting()));
            // add 2020-12-30 No.724:電文内データ文字列結合 商 end
            builder.append(createDetailTelegram(layoutDetail, journal, mstCoopLayout, calculator, new StringBuilder(), dataSetMap, occ.getSqlCode(), coopIni, textTelegramContext));
            /* upd by chamaojia 2026-04-24 [10959] add param coopIni、textTelegramContext --end */
          }

          // オカレンス内のrepeat属性に記載されているループ回数分回らなかった場合はブランク用のレイアウトを取得し強制的にパディングをかける
          // またrepeat属性が指定されている場合。len属性は0(もしくは未定義によるデフォルト0)であることが必須である
          int repeat = StringUtils.isEmpty(occ.getRepeat()) ? 0 : Integer.parseInt(occ.getRepeat());
          if (occ.getLen() == 0 && dataSetList.size() < repeat) {
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////            MstCoopLayoutDetail layoutDetail = mstCoopLayoutDetailDao.select(journal.getFacilityCd(), journal.getCoopCd(), JournalConvertConstants.DIRECTION_SEND, occ.getDetail(), "blank");
//            MstCoopLayoutDetail layoutDetail = mstCoopLayoutDetailDao.select(journal.getFacilityCd(),
//              journal.getCoopCd(), coopVersion, JournalConvertConstants.DIRECTION_SEND, occ.getDetail(), "blank");
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//            // add 2021-05-13 課題7：送信にて繰返し回数が固定の電文作成時、繰り返し回数を超えたデータ量があった場合エラーになる 孫 start
//            if (layoutDetail == null) {
//              throw new NtssException("対象ジャーナルの送信用変換ブランクレイアウトDetailが存在しません。 "
//                + "facility_cd:[" + journal.getFacilityCd() + "], "
//                + "coop_cd:[" + journal.getCoopCd() + "], "
//// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//                + "coop_version:[" + coopVersion + "], "
//// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//                + "coop_cd_sub:[" + getCoopCdSub(journal.getCrud()) + "], "
//                + "coop_cd_detail:[" + occ.getDetail() + "], "
//                + "coop_cd_detail_sub:[blank]");
//            }
            MstCoopLayoutDetail layoutDetail = convertCommonService.getMstCoopLayoutDetailBySub(journal.getFacilityCd(),
              JournalConvertConstants.DIRECTION_SEND, journal.getCoopCd(), coopVersion, occ.getDetail(), "blank");
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end
            // add 2021-05-13 課題7：送信にて繰返し回数が固定の電文作成時、繰り返し回数を超えたデータ量があった場合エラーになる 孫 end
            int limit = repeat - dataSetList.size();
            for (int i = 0; i < limit; i++) {
              /* upd by chamaojia 2026-04-24 [10959] add param coopIni、textTelegramContext --start */
              builder.append(createDetailTelegram(layoutDetail, journal, mstCoopLayout, calculator, new StringBuilder(), null, occ.getSqlCode(), coopIni, textTelegramContext));
              /* upd by chamaojia 2026-04-24 [10959] add param coopIni、textTelegramContext --end */
            }
          }
        } else {
          // itemだったらそのままvalue属性を参照して電文作成をする
          try {
            calculator.addTotalLength(item.getLen());
            /* upd by chamaojia 2026-04-24 [10959] add param coopIni、textTelegramContext --start */
            builder.append(createTelegramFragment(item, calculator, dataSetResultMap, null, journal, mstCoopLayout, null, null, coopIni, textTelegramContext));
            /* upd by chamaojia 2026-04-24 [10959] add param coopIni、textTelegramContext --end */
          } catch (NtssException | UnsupportedEncodingException e) {
            eventLogMessage.setLogMessage("配信電文の作成に失敗しました。facility_cd:[" + journal.getFacilityCd() + "]"
              + ",  coop_cd:[" + journal.getCoopCd() + "]"
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
              + ", coop_version:[" + coopVersion + "]"
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
              + ", coop_cd_sub:[" + getCoopCdSub(journal.getCrud()) + "]"
              + ", item name:[" + item.getName() + "]");
            eventLogMessage.setFacilityCd(journal.getFacilityCd());
            // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
            eventLogMessage.setInvokeClass(this.getClass().getName());
            // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
            logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            throw new NtssException(e);
          }
        }
      }
      // add 2021-10-08 #5247:繰り返し回数越えのデータ対応 孫 start
    } else {
      // add 2021-10-08 #5247:繰り返し回数越えのデータ対応 孫 end
      // 以下ソース、5247を追加したソース。
      do {
        for (Item item : root.getItemList()) {
          // 繰り返しの場合は繰り返し用のXMLを取得して再帰
          if (item.isOcc()) {
            Occ occ = (Occ) item;
            int repeat = StringUtils.isEmpty(occ.getRepeat()) ? 0 : Integer.parseInt(occ.getRepeat());
            List<Map<String, Object>> dataSetList = dataMap.containsKey(occ.getName()) ? dataMap.get(occ.getName()) : dataSetResultMap.get(occ.getSqlCode());
            if (repeat < dataSetList.size()) {
             // mod #9327 NKK連携 ind_dial 電文の末尾にCRLFがない  20230809 孟堅　start
              // if (!Objects.isNull(root.getMulti()) && root.getMulti().contains("true") && "true".equals(occ.getMulti())) {
              if (!Objects.isNull(root.getMulti()) && root.getMulti().contains("true")) {
              // mod #9327 NKK連携 ind_dial 電文の末尾にCRLFがない 20230809　孟堅　end
                flagMap.put(occ.getName(), true);
                dataMap.put(occ.getName(), dataSetList.stream().skip(repeat).collect(Collectors.toList()));
              } else {
                flagMap.put(occ.getName(), false);
                dataMap.put(occ.getName(), new ArrayList<Map<String, Object>>());
              }
              for (Map<String, Object> dataSetMap : dataSetList.subList(0, repeat)) {
                if (!dataSetMap.containsKey("detail_id")) {
                  throw new NtssException("対象datasetに必須なキーである[detail_id]が存在しません。"
                    + "facility_cd:[" + journal.getFacilityCd() + "], "
                    + "coop_cd:[" + journal.getCoopCd() + "], "
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
                    + "coop_version:[" + coopVersion + "], "
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
                    + "coop_cd_sub:[" + getCoopCdSub(journal.getCrud()) + "]");
                }

// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////                MstCoopLayoutDetail layoutDetail = mstCoopLayoutDetailDao.select(journal.getFacilityCd(), journal.getCoopCd(), JournalConvertConstants.DIRECTION_SEND, occ.getDetail(), String.valueOf(dataSetMap.get("detail_id")));
//                MstCoopLayoutDetail layoutDetail = mstCoopLayoutDetailDao.select(journal.getFacilityCd(),
//                  journal.getCoopCd(), coopVersion, JournalConvertConstants.DIRECTION_SEND, occ.getDetail(),
//                  String.valueOf(dataSetMap.get("detail_id")));
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//                // レイアウトがない場合はジャーナルをエラーにして、次のジャーナル変換に移る
//                if (layoutDetail == null) {
//                  throw new NtssException("対象ジャーナルの送信用変換レイアウトDetailが存在しません。 "
//                    + "facility_cd:[" + journal.getFacilityCd() + "], "
//                    + "coop_cd:[" + journal.getCoopCd() + "], "
//// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//                    + "coop_version:[" + coopVersion + "], "
//// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//                    + "coop_cd_sub:[" + getCoopCdSub(journal.getCrud()) + "], "
//                    + "coop_cd_detail:[" + occ.getDetail() + "], "
//                    + "coop_cd_detail_sub:[" + String.valueOf(dataSetMap.get("detail_id")) + "]");
//                }
                MstCoopLayoutDetail layoutDetail = convertCommonService.getMstCoopLayoutDetailBySub(journal.getFacilityCd(),
                  JournalConvertConstants.DIRECTION_SEND, journal.getCoopCd(), coopVersion, occ.getDetail(),
                    String.valueOf(dataSetMap.get("detail_id")));
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end
                /* upd by chamaojia 2026-04-24 [10959] add param coopIni、textTelegramContext --start */
                // add 2020-12-30 No.724:電文内データ文字列結合 商 start
                textTelegramContext.setItemSuffixDetailList(getItemSuffixList(layoutDetail.getCoopExtSetting()));
                // add 2020-12-30 No.724:電文内データ文字列結合 商 end
                builder.append(createDetailTelegram(layoutDetail, journal, mstCoopLayout, calculator, new StringBuilder(), dataSetMap, occ.getSqlCode(), coopIni, textTelegramContext));
                /* upd by chamaojia 2026-04-24 [10959] add param coopIni、textTelegramContext --end */
              }
            } else {
              flagMap.put(occ.getName(), false);
              dataMap.put(occ.getName(), new ArrayList<Map<String, Object>>());
              for (Map<String, Object> dataSetMap : dataSetList) {
                if (!dataSetMap.containsKey("detail_id")) {
                  throw new NtssException("対象datasetに必須なキーである[detail_id]が存在しません。"
                    + "facility_cd:[" + journal.getFacilityCd() + "], "
                    + "coop_cd:[" + journal.getCoopCd() + "], "
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
                    + "coop_version:[" + coopVersion + "], "
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
                    + "coop_cd_sub:[" + getCoopCdSub(journal.getCrud()) + "]");
                }

// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////                MstCoopLayoutDetail layoutDetail = mstCoopLayoutDetailDao.select(journal.getFacilityCd(), journal.getCoopCd(), JournalConvertConstants.DIRECTION_SEND, occ.getDetail(), String.valueOf(dataSetMap.get("detail_id")));
//                MstCoopLayoutDetail layoutDetail = mstCoopLayoutDetailDao.select(journal.getFacilityCd(),
//                  journal.getCoopCd(), coopVersion, JournalConvertConstants.DIRECTION_SEND, occ.getDetail(),
//                  String.valueOf(dataSetMap.get("detail_id")));
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//                // レイアウトがない場合はジャーナルをエラーにして、次のジャーナル変換に移る
//                if (layoutDetail == null) {
//                  throw new NtssException("対象ジャーナルの送信用変換レイアウトDetailが存在しません。 "
//                    + "facility_cd:[" + journal.getFacilityCd() + "], "
//                    + "coop_cd:[" + journal.getCoopCd() + "], "
//// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//                    + "coop_version:[" + coopVersion + "], "
//// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//                    + "coop_cd_sub:[" + getCoopCdSub(journal.getCrud()) + "], "
//                    + "coop_cd_detail:[" + occ.getDetail() + "], "
//                    + "coop_cd_detail_sub:[" + String.valueOf(dataSetMap.get("detail_id")) + "]");
//                }
                MstCoopLayoutDetail layoutDetail = convertCommonService.getMstCoopLayoutDetailBySub(journal.getFacilityCd(),
                  JournalConvertConstants.DIRECTION_SEND, journal.getCoopCd(), coopVersion, occ.getDetail(),
                    String.valueOf(dataSetMap.get("detail_id")));
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end
                // add 2020-12-30 No.724:電文内データ文字列結合 商 start
                /* upd by chamaojia 2026-04-24 [10959] add param coopIni、textTelegramContext --start */
                textTelegramContext.setItemSuffixDetailList(getItemSuffixList(layoutDetail.getCoopExtSetting()));
                // add 2020-12-30 No.724:電文内データ文字列結合 商 end
                builder.append(createDetailTelegram(layoutDetail, journal, mstCoopLayout, calculator, new StringBuilder(), dataSetMap, occ.getSqlCode(), coopIni, textTelegramContext));
                /* upd by chamaojia 2026-04-24 [10959] add param coopIni、textTelegramContext --end */
              }
              // オカレンス内のrepeat属性に記載されているループ回数分回らなかった場合はブランク用のレイアウトを取得し強制的にパディングをかける
              // またrepeat属性が指定されている場合。len属性は0(もしくは未定義によるデフォルト0)であることが必須である
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////              MstCoopLayoutDetail layoutDetail = mstCoopLayoutDetailDao.select(journal.getFacilityCd(), journal.getCoopCd(), JournalConvertConstants.DIRECTION_SEND, occ.getDetail(), "blank");
//              MstCoopLayoutDetail layoutDetail = mstCoopLayoutDetailDao.select(journal.getFacilityCd(),
//                journal.getCoopCd(), coopVersion, JournalConvertConstants.DIRECTION_SEND, occ.getDetail(), "blank");
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//              // add 2021-05-13 課題7：送信にて繰返し回数が固定の電文作成時、繰り返し回数を超えたデータ量があった場合エラーになる 孫 start
//              if (layoutDetail == null) {
//                throw new NtssException("対象ジャーナルの送信用変換ブランクレイアウトDetailが存在しません。 "
//                  + "facility_cd:[" + journal.getFacilityCd() + "], "
//                  + "coop_cd:[" + journal.getCoopCd() + "], "
//// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//                  + "coop_version:[" + coopVersion + "], "
//// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//                  + "coop_cd_sub:[" + getCoopCdSub(journal.getCrud()) + "], "
//                  + "coop_cd_detail:[" + occ.getDetail() + "], "
//                  + "coop_cd_detail_sub:[blank]");
//              }
              MstCoopLayoutDetail layoutDetail = convertCommonService.getMstCoopLayoutDetailBySub(journal.getFacilityCd(),
                JournalConvertConstants.DIRECTION_SEND, journal.getCoopCd(), coopVersion, occ.getDetail(), "blank");
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end
              // add 2021-05-13 課題7：送信にて繰返し回数が固定の電文作成時、繰り返し回数を超えたデータ量があった場合エラーになる 孫 end
              int limit = repeat - dataSetList.size();
              for (int i = 0; i < limit; i++) {
                /* upd by chamaojia 2026-04-24 [10959] add param coopIni、textTelegramContext --start */
                builder.append(createDetailTelegram(layoutDetail, journal, mstCoopLayout, calculator, new StringBuilder(), null, occ.getSqlCode(), coopIni, textTelegramContext));
                /* upd by chamaojia 2026-04-24 [10959] add param coopIni、textTelegramContext --end */
              }
            }

          } else {
            // itemだったらそのままvalue属性を参照して電文作成をする
            try {
              calculator.addTotalLength(item.getLen());
              /* upd by chamaojia 2026-04-24 [10959] add param coopIni、textTelegramContext --start */
              builder.append(createTelegramFragment(item, calculator, dataSetResultMap, null, journal, mstCoopLayout, null, null, coopIni, textTelegramContext));
              /* upd by chamaojia 2026-04-24 [10959] add param coopIni、textTelegramContext --end */
            } catch (NtssException | UnsupportedEncodingException e) {
              eventLogMessage.setLogMessage("配信電文の作成に失敗しました。facility_cd:[" + journal.getFacilityCd() + "]"
                + ",  coop_cd:[" + journal.getCoopCd() + "]"
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
                + ", coop_version:[" + coopVersion + "]"
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
                + ", coop_cd_sub:[" + getCoopCdSub(journal.getCrud()) + "]"
                + ", item name:[" + item.getName() + "]");
              eventLogMessage.setFacilityCd(journal.getFacilityCd());
              // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
              eventLogMessage.setInvokeClass(this.getClass().getName());
              // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
              logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
              throw new NtssException(e);
            }
          }
        }
// mod 2021-11-10 #5904:日機装連携ができない(透析実績) 孫 start
//        if (flagMap.containsValue(true)) {
        if (flagMap.containsValue(true) && builder.length()>0 && !builder.toString().endsWith(delimiter)) {
// mod 2021-11-10 #5904:日機装連携ができない(透析実績) 孫 end
          builder.append(delimiter);
        }
      } while (flagMap.containsValue(true));
      /* upd by chamaojia 2026-04-27 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
      // head = 1;
      textTelegramContext.resetHead();
      /* upd by chamaojia 2026-04-27 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
      // add 2021-10-08 #5247:繰り返し回数越えのデータ対応 孫 start
    }
    // add 2021-10-08 #5247:繰り返し回数越えのデータ対応 孫 end
    return builder.toString();
  }

  /**
   * mst_coop_layout_detail配下の電文作成
   *
   * @param parentLayoutDetail - 親detailレイアウト
   * @param journal - {@link SysCoopJournal}
   * @param calculator - {@link TelegramLengthCalculator}
   * @param builder - 電文用StringBuilder
   * @param dataSetResult - detailレイアウトからループしているdatasetの1要素
   * @param sqlCode - 親detailレイアウトのoccから受け取ったSQLCODE
   * @return 電文
   */
   // #7525 mod rst_dial連携（拡張）ヘッダON/OFF切り替え start 2023-1-5
  /* upd by chamaojia 2026-04-24 [10959] add param coopIni、textTelegramContext --start */
  private String createDetailTelegram(MstCoopLayoutDetail parentLayoutDetail, SysCoopJournal journal, MstCoopLayout mstCoopLayout,TelegramLengthCalculator calculator,
                                      StringBuilder builder, Map<String, Object> dataSetResult, String sqlCode, MstCoopIni coopIni,
                                      TextTelegramContext textTelegramContext) {
  /* upd by chamaojia 2026-04-24 [10959] add param coopIni、textTelegramContext --end */
    // #7525 mod rst_dial連携（拡張）ヘッダON/OFF切り替え end 2023-1-5

    EventLogMessage eventLogMessage = new EventLogMessage();
// add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    String coopVersion = StringUtils.isEmpty(journal.getCoopVersion())?"":journal.getCoopVersion();
// add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    for (Item item : parentLayoutDetail.getCoopSettingRoot().getItemList()) {
      if (item.isOcc()) {
        Occ occ = (Occ)item;

        // ここまでくるとdetailレイアウトからsqlCodeがないと後続の処理はできないのでオカレンス内のsqlCode属性をチェックしておく
        if (StringUtils.isEmpty(occ.getSqlCode())) {
          throw new NtssException("送信用レイアウトに記載されているオカレンスにsqlCode属性が存在しません。"
              + "facility_cd:[" + journal.getFacilityCd() + "], "
              + "coop_cd:[" + journal.getCoopCd() + "], "
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
              + "coop_version:[" + coopVersion + "], "
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
              + "coop_cd_sub:[" + getCoopCdSub(journal.getCrud()) + "]"
              + "coop_cd_detail:[" + parentLayoutDetail.getCoopCdDetail() + "],"
              + "coop_cd_detail_sub:[" + parentLayoutDetail.getCoopCdDetailSub() + "]"
              + "occ.name:[" + occ.getName() + "]"
              );
        }

        // blankが前提のレイアウトで、occが来てもdatasetの取得ができないためエラーにする
        if ("blank".equals(parentLayoutDetail.getCoopCdDetailSub())) {
          throw new NtssException("対象ジャーナルの送信用ブランクレイアウトにオカレンスが存在したため。このジャーナルに対する変換処理を中止します。 "
              + "facility_cd:[" + journal.getFacilityCd() + "], "
              + "coop_cd:[" + journal.getCoopCd() + "], "
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
              + "coop_version:[" + coopVersion + "], "
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
              + "coop_cd_sub:[" + getCoopCdSub(journal.getCrud()) + "]");
        }

        // data-setを利用した出力がある場合に限り、あらかじめdata-setをリクエストしておく
        /* upd by chamaojia 2026-04-24 [10959] add param coopIni --start */
        Map<String, List<Map<String, Object>>> dataSetResultMap = convertSendCommonService.createRequestAndRequestByDataSetApi(journal,
          parentLayoutDetail.getCoopExtSetting(), dataSetResult, coopIni);
        /* upd by chamaojia 2026-04-24 [10959] add param coopIni --end */
        List<Map<String, Object>> dataSetList = dataSetResultMap.get(occ.getSqlCode());
        if (occ.getLen() > 0) {
          // datasetの要素数を電文に含める
          calculator.addTotalLength(occ.getLen());
          builder.append(padding(occ, String.valueOf(dataSetList.size())));
        }

        for (Map<String, Object> dataSetMap : dataSetList) {
          if (!dataSetMap.containsKey("detail_id")) {
            throw new NtssException("対象datasetに必須なキーである[detail_id]が存在しません。"
                + "facility_cd:[" + journal.getFacilityCd() + "], "
                + "coop_cd:[" + journal.getCoopCd() + "], "
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
                + "coop_version:[" + coopVersion + "], "
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
                + "coop_cd_sub:[" + getCoopCdSub(journal.getCrud()) + "],"
                + "coop_cd_detail:[" + parentLayoutDetail.getCoopCdDetail() + "],"
                + "coop_cd_detail_sub : [" + parentLayoutDetail.getCoopCdDetailSub() + "]");
          }
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////          MstCoopLayoutDetail layoutDetail = mstCoopLayoutDetailDao.select(journal.getFacilityCd(), journal.getCoopCd(), JournalConvertConstants.DIRECTION_SEND, occ.getDetail(), String.valueOf(dataSetMap.get("detail_id")));
//          MstCoopLayoutDetail layoutDetail = mstCoopLayoutDetailDao.select(journal.getFacilityCd(), journal.getCoopCd(),
//            coopVersion, JournalConvertConstants.DIRECTION_SEND, occ.getDetail(),
//            String.valueOf(dataSetMap.get("detail_id")));
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//          // レイアウトがない場合はジャーナルをエラーにして、次のジャーナル変換に移る
//          if (layoutDetail == null) {
//            throw new NtssException("対象ジャーナルの送信用変換レイアウトDetailが存在しません。 "
//              + "facility_cd:[" + journal.getFacilityCd() + "], "
//              + "coop_cd:[" + journal.getCoopCd() + "], "
//// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//              + "coop_version:[" + coopVersion + "], "
//// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//              + "coop_cd_sub:[" + getCoopCdSub(journal.getCrud()) + "], "
//              + "coop_cd_detail:[" + occ.getDetail() + "]"
//                );
//          }
          MstCoopLayoutDetail layoutDetail = convertCommonService.getMstCoopLayoutDetailBySub(journal.getFacilityCd(),
            JournalConvertConstants.DIRECTION_SEND, journal.getCoopCd(), coopVersion, occ.getDetail(),
            String.valueOf(dataSetMap.get("detail_id")));
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end

          /* upd by chamaojia 2026-04-24 [10959] add param coopIni、textTelegramContext --start */
          builder.append(createDetailTelegram(layoutDetail, journal, mstCoopLayout, calculator, new StringBuilder(), dataSetMap, occ.getSqlCode(), coopIni, textTelegramContext));
          /* upd by chamaojia 2026-04-24 [10959] add param coopIni、textTelegramContext --end */
        }

        // オカレンス内のrepeat属性に記載されているループ回数分回らなかった場合はブランク用のレイアウトを取得し強制的にパディングをかける
        // またrepeat属性が指定されている場合。len属性は0(もしくは未定義によるデフォルト0)であることが必須である
        int repeat = StringUtils.isEmpty(occ.getRepeat()) ? 0 : Integer.parseInt(occ.getRepeat());
        if (occ.getLen() == 0 && dataSetList.size() < repeat) {
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////          MstCoopLayoutDetail layoutDetail = mstCoopLayoutDetailDao.select(journal.getFacilityCd(), journal.getCoopCd(), JournalConvertConstants.DIRECTION_SEND, occ.getDetail(), "blank");
//          MstCoopLayoutDetail layoutDetail = mstCoopLayoutDetailDao.select(journal.getFacilityCd(), journal.getCoopCd(),
//            coopVersion, JournalConvertConstants.DIRECTION_SEND, occ.getDetail(), "blank");
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//          if (layoutDetail == null) {
//            throw new NtssException("対象ジャーナルの送信用変換ブランクレイアウトDetailが存在しません。 "
//              + "facility_cd:[" + journal.getFacilityCd() + "], "
//              + "coop_cd:[" + journal.getCoopCd() + "], "
//// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//              + "coop_version:[" + coopVersion + "], "
//// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//              + "coop_cd_sub:[" + getCoopCdSub(journal.getCrud()) + "], "
//              // mod 2021-05-13 課題7：送信にて繰返し回数が固定の電文作成時、繰り返し回数を超えたデータ量があった場合エラーになる 孫 start
////              + "coop_cd_detail:[" + occ.getDetail() + "]");
//              + "coop_cd_detail:[" + occ.getDetail() + "], "
//              + "coop_cd_detail_sub:[blank]");
//              // mod 2021-05-13 課題7：送信にて繰返し回数が固定の電文作成時、繰り返し回数を超えたデータ量があった場合エラーになる 孫 end
//          }
          MstCoopLayoutDetail layoutDetail = convertCommonService.getMstCoopLayoutDetailBySub(journal.getFacilityCd(),
            JournalConvertConstants.DIRECTION_SEND, journal.getCoopCd(), coopVersion, occ.getDetail(), "blank");
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end
          int limit = repeat - dataSetList.size();
          for (int i = 0; i < limit; i++) {
            /* upd by chamaojia 2026-04-24 [10959] add param coopIni、textTelegramContext --start */
            builder.append(createDetailTelegram(layoutDetail, journal, mstCoopLayout, calculator, new StringBuilder(), null, occ.getSqlCode(), coopIni, textTelegramContext));
            /* upd by chamaojia 2026-04-24 [10959] add param coopIni、textTelegramContext --end */
          }
        }
      } else {
        try {
        // itemだったらそのままvalue属性を参照して電文作成をする
        calculator.addTotalLength(item.getLen());
        /* upd by chamaojia 2026-04-24 [10959] add param coopIni、textTelegramContext --start */
        builder.append(createTelegramFragment(item, calculator, null, sqlCode, journal, mstCoopLayout, parentLayoutDetail, dataSetResult, coopIni, textTelegramContext));
        /* upd by chamaojia 2026-04-24 [10959] add param coopIni、textTelegramContext --end */
        } catch(NtssException | UnsupportedEncodingException e) {
          eventLogMessage.setLogMessage("配信電文の作成に失敗しました。facility_cd:[" + journal.getFacilityCd() + "]"
              + ",  coop_cd:[" + journal.getCoopCd() + "]"
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
              + ", coop_version:[" + coopVersion + "]"
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
              + ", coop_cd_sub:[" + getCoopCdSub(journal.getCrud()) + "]"
              + ", item name:[" + item.getName() + "]"
              + ", coop_cd_detail : [" + parentLayoutDetail.getCoopCdDetail() + "]"
              + ", coop_cd_detail_sub : [" + parentLayoutDetail.getCoopCdDetailSub() + "]");
          eventLogMessage.setFacilityCd(journal.getFacilityCd());
          // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
          eventLogMessage.setInvokeClass(this.getClass().getName());
          // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
          logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          throw new NtssException(e);
        }
      }
    }
    return builder.toString();
  }

  /**
   * 1つのXML要素(レイアウト)に対する電文作成
   *
   * @param item - {@link Item}
   * @param calculator - {@link TelegramLengthCalculator}
   * @param dataSetResultMap - mst_coop_layoutのdataset結果Map
   * @param sqlCode - 親detailレイアウトのoccから受け取ったSQLCODE
   * @param journal - {@link SysCoopJournal}
   * @param detailLayout - 親detailレイアウト
   * @param dataSetResult - detailレイアウトからループしているdatasetの1要素
   * @return 1つのXML要素(レイアウト)に対する電文
   * @throws UnsupportedEncodingException - エスケープ文字をデコードする際、サポートしていない文字コードだった場合にthrow
   */
  // #7525 mod rst_dial連携（拡張）ヘッダON/OFF切り替え start 2023-1-5
  /* upd by chamaojia 2026-04-24 [10959] add param coopIni、textTelegramContext --start */
  private String createTelegramFragment(Item item, TelegramLengthCalculator calculator, Map<String,
      List<Map<String, Object>>> dataSetResultMap, String sqlCode, SysCoopJournal journal,MstCoopLayout layout,
      MstCoopLayoutDetail detailLayout, Map<String, Object> dataSetResult, MstCoopIni coopIni,
      TextTelegramContext textTelegramContext) throws UnsupportedEncodingException {
  /* upd by chamaojia 2026-04-24 [10959] add param coopIni、textTelegramContext --end */
    StringBuilder telegramFragment = new StringBuilder();
    // #7525 mod rst_dial連携（拡張）ヘッダON/OFF切り替え end 2023-1-5


    // パディング専用のレイアウトが来たら、後続処理である出力のロジックを介さずパディングする
    if (detailLayout != null && detailLayout.getCoopCdDetailSub().equals("blank")) return padding(item, "");

    String replaceEscape =  URLDecoder.decode(item.getValue(), DEFAULT_ENCODE);
// mod 2021-11-19 #5888:NEC連携ができない(バイタル連携) 孫 start
//    if (replaceEscape.equals("$SYSDATE")) {
    if (replaceEscape.startsWith("$SYSDATE")) {
// mod 2021-11-19 #5888:NEC連携ができない(バイタル連携) 孫 end
        // システム日付(yyyyMMdd)
      // mod 2021-10-19 #5890:Medicom連携ができない(検査オーダ(exam_ord)) 孫 start
//        return concatSYSDATE();
      return concatSYSDATE(item);
      // mod 2021-10-19 #5890:Medicom連携ができない(検査オーダ(exam_ord)) 孫 end
// mod 2021-11-19 #5888:NEC連携ができない(バイタル連携) 孫 start
//    } else if (replaceEscape.equals("$SYSTIME")) {
    } else if (replaceEscape.startsWith("$SYSTIME")) {
// mod 2021-11-19 #5888:NEC連携ができない(バイタル連携) 孫 end
        // システム時刻(HHmmss)
      // mod 2021-10-19 #5890:Medicom連携ができない(検査オーダ(exam_ord)) 孫 start
//        return concatSYSTIME();
      return concatSYSTIME(item);
      // mod 2021-10-19 #5890:Medicom連携ができない(検査オーダ(exam_ord)) 孫 end
    } else if (replaceEscape.equals("$LENGTH")) {
      calculator.addTelegramLengthItem(item);
      return "";
    } else if (replaceEscape.startsWith("$LENGTH")) {
      calculator.addTelegramLengthItem(item);
      calculator.subTelegramLengthItem(item);
      return "";
    } else if (replaceEscape.equals("$BLANK")) {
      return concatConstValue(" ", item);
    } else if (replaceEscape.equals("$CR")) {
      return concatConstValue("\r", item);
    } else if (replaceEscape.equals("$LF")) {
      return concatConstValue("\n", item);
// add 2021-11-10 #5904:日機装連携ができない(透析実績) 孫 start
    } else if (replaceEscape.equals("$LFCR")) {
      return concatConstValue("\n\r", item);
    } else if (replaceEscape.equals("$CRLF")) {
      return concatConstValue("\r\n", item);
// add 2021-11-10 #5904:日機装連携ができない(透析実績) 孫 end
    } else if (replaceEscape.equals("$STX")) {
      return concatConstValue("\u0002", item);
    } else if (replaceEscape.equals("$ETX")) {
      return concatConstValue("\u0003", item);
    } else if (replaceEscape.equals("$EOT")) {
      return concatConstValue("\u0004", item);
    } else if (replaceEscape.startsWith("$HEX")) {
      //HEX値を取得
      String hexInput = replaceEscape.replace("$HEX", "");
      //正規表現宣言
      String regex = "^[0-9a-fA-F]{2}$";
      Pattern pattern = Pattern.compile(regex);
      //HEX値のフォーマットチェック
      if (!pattern.matcher(hexInput).matches()) {
        throw new NtssException("HEX値が正しくありません。対象データ:[" + replaceEscape + "]");
      }
      //コードポイント作成
      int codePoint = Integer.parseInt(hexInput, 16);
      if (codePoint > 32 || codePoint < 0) {
        throw new NtssException("対応範囲外のHex値です。対象データ:[" + replaceEscape + "]");
      }
      int[] codePoints = new int[] {codePoint};
      return concatConstValue(new String(codePoints, 0, codePoints.length), item);
    } else if (replaceEscape.startsWith("$JOURNAL")) {
      //ジャーナルテーブルのデータを取得する
      // mod 2022-01-19 [富士通連携ができない]再対応→放射線検査オーダの対応 孫 start
//      return concatConstValue(convertSendCommonService.getJournalReplaceData(replaceEscape, journal), item);
      String newValue = concatConstValue(convertSendCommonService.getJournalReplaceData(replaceEscape, journal), item);
      if (newValue.length() > item.getLen()) {
        if (StringUtils.isEmpty(item.getSubMode()) && "L".equals(item.getSubMode())) {
          // 切り取り方式が"L"と設定しないの場合
          newValue = newValue.substring(0, item.getLen());
        } else {
          // 切り取り方式が"R"の場合
          newValue = newValue.substring(newValue.length() - item.getLen(), newValue.length());
        }
      }
      return newValue;
      // mod 2022-01-19 [富士通連携ができない]再対応→放射線検査オーダの対応 孫 end
    }

    // コロンを分割して、「どの出力で行うか, 出力方法に基づいた出力値」にした配列にする
    if (replaceEscape.indexOf(":") == -1) {
      throw new NtssException("電文変換に必要なフォーマットであるコロンがありません。対象データ:[" + replaceEscape + "]");
    }
    String[] keyValueArray = replaceEscape.split(":");
    String key = keyValueArray[0];

    if (keyValueArray.length <= 1)  return padding(item, "");

    // add FNSI7616-rep_dial連携（HTML）で送信するレポート情報に出力するPDF名 周 start
    // #7525 mod rst_dial連携（拡張）ヘッダON/OFF切り替え start 2023-1-5
//    MstCoopLayout layout = mstCoopLayoutDao.select(journal.getFacilityCd(), journal.getCoopCd(),
//      journal.getCoopCdIndex(), JournalConvertConstants.DIRECTION_SEND, getCoopCdSub(journal.getCrud()));
//    MstCoopLayout layout=mstCoopLayoutService.getMstCoopLayoutByMstCoopIni(journal);
    // #7525 mod  rst_dial連携（拡張）ヘッダON/OFF切り替え end 2023-1-5
    // add FNSI7616-rep_dial連携（HTML）で送信するレポート情報に出力するPDF名 周 end

    // 出力方法別
    ElementsValue elementVal = ElementsValue.getElement(key);
    switch(elementVal) {
      // 固定値
      case CONST:
        if (Pattern.compile("\\\\r").matcher(keyValueArray[1]).find()) {
          // XMLパース時に\をエスケープしているため\\となっているので、正規表現での判定では更にエスケープして\\\\となっている
          // 改行(XMLレイアウトの終端もしくは区切りを意味している)
          return "\r";
        }
        telegramFragment.append(concatConstValue(keyValueArray[1], item));
        break;
      // dataset結果から抽出
      case DATASET:   // datasetから値を取得
      case AUTH_ID:   // 利用者マスタから取得
// add 2021-12-22 #5888:NEC-iS連携ができない(透析実績(rst_dial)) 孫 start
      case IN_HOSPITAL_CD_1:   // 利用者マスタから院内コード1取得
      case IN_HOSPITAL_CD_2:   // 利用者マスタから院内コード2取得
// add 2021-12-22 #5888:NEC-iS連携ができない(透析実績(rst_dial)) 孫 end
// add 2021-10-14 CSIの「【検査予定送信】のスタッフマスタ.職種コード」の対応 孫 start
      case JOB_CD:   // 利用者マスタから職種コード取得
// add 2021-10-14 CSIの「【検査予定送信】のスタッフマスタ.職種コード」の対応 孫 end
// add 2021-10-28 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 start
      case STAFF_NAME:   // 利用者マスタから利用者名取得
// add 2021-10-28 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 end
        if (!StringUtils.isEmpty(sqlCode) && detailLayout != null && dataSetResult != null && !dataSetResult.isEmpty()) {
          // String#splitはpatternで分割するため、ドット単体だと分割できない(matchせず空配列で返却される)のでPattern化する
          String[] dataSetArray = keyValueArray[1].split(Pattern.quote("."));
          String dataSetSqlCode = dataSetArray[0];
          String extractColumnName = dataSetArray[1];

          // 再帰的にもらった親detailレイアウトからのSQLCODEとitemタグからもらったdatasetのSQLCODEに差異がある場合は、itemタグのSQLCODEを優先しdatasetの取得を行う。
          if (!sqlCode.equals(dataSetSqlCode)) {
            /* upd by chamaojia 2026-04-24 [10959] add param coopIni --start */
            Map<String, List<Map<String, Object>>> dataSetMap = convertSendCommonService.createRequestAndRequestByDataSetApi(journal,
              detailLayout.getCoopExtSetting(), dataSetResult, coopIni);
            /* upd by chamaojia 2026-04-24 [10959] add param coopIni --end */
            if (dataSetMap != null && !dataSetMap.isEmpty()) {
              // 単発想定のため、決め打ち
              List<Map<String, Object>> dataSetList = dataSetMap.get(dataSetSqlCode);
              String dataSetSqlCodeValue = "";
              if (!CollectionUtils.isEmpty(dataSetList) && !StringUtils.isEmpty(dataSetList.get(0).get(extractColumnName))) {
                dataSetSqlCodeValue = String.valueOf(dataSetList.get(0).get(extractColumnName));
              }
              telegramFragment.append(convertValue(elementVal, dataSetSqlCodeValue, item));
            }
          } else {
            // 親オカレンスのsqlCodeとvalue="dataset:~~~"のsqlCodeが合致した場合はフォーマットに基づきカラムを抽出し電文に載せる
            String dataSetSqlCodeValue = dataSetResult.get(extractColumnName) == null ? "" : String.valueOf(dataSetResult.get(extractColumnName));
            telegramFragment.append(convertValue(elementVal, dataSetSqlCodeValue, item));
          }
        } else {
          // もしdatasetの結果が空だった場合は、空文字にしてパディングを入れる
          if (dataSetResultMap.isEmpty()) {
            return padding(item, "");
          }
          // mod FNSI7012-ind_dial連携で送信する予約枠コード 周 start
          //telegramFragment.append(convertValue(elementVal, dataSetResultMap, keyValueArray[1], item));
          // del FNSI7616-rep_dial連携（HTML）で送信するレポート情報に出力するPDF名 周 start
//          MstCoopLayout layout = mstCoopLayoutDao.select(journal.getFacilityCd(), journal.getCoopCd(),
//            journal.getCoopCdIndex(), JournalConvertConstants.DIRECTION_SEND, getCoopCdSub(journal.getCrud()));
          // del FNSI7616-rep_dial連携（HTML）で送信するレポート情報に出力するPDF名 周 end
          String tmpVal = convertValue(elementVal, dataSetResultMap, keyValueArray[1], item);
          if (this.validateFujitsuOrderBedInHospitalCd(journal,layout,tmpVal,item)){
            throw new NtssException("連携コードなし（ベッド）");
          }
//          if("fujitsu".equals(layout.getCoopVender())
//            && "ind_dial".equals(journal.getCoopCd())
//            && "予約情報.予約枠コード".equals(item.getName())
//            && StringUtils.isEmpty(tmpVal.trim())) {
//            throw new NtssException("連携コードなし（ベッド）");
//          }
          telegramFragment.append(tmpVal);
          // mod FNSI7012-ind_dial連携で送信する予約枠コード 周 end
        }
        break;
      //自己増加する
      case AUTO:
        /* upd by chamaojia 2026-04-27 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
        // telegramFragment.append(head++);
        telegramFragment.append(textTelegramContext.nextHead());
        /* upd by chamaojia 2026-04-27 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
        break;
      default:
        // 上記以外は処理なし
        break;
    }

    // add 2021-10-22 #5890:Medicom連携ができない(受付情報(accept)) 孫 start
//    if (telegramFragment.toString().getBytes(DEFAULT_ENCODE).length > item.getLen()) {
//      // mod redmain #5166 「データの長さによりエラーになってしまう」 鄧シン start
//      // // mod 2021-04-15 外部連携:log内容を改善 孫 start
//      // // throw new NtssException("データ長がオーバーしています。データ内容:[" + telegramFragment.toString() + "]" );
//      // throw new NtssException("データ長がオーバーしています。データ内容:[" + telegramFragment.toString() + "]"
//      // + ",連携電文設定内容：項目名=[" + item.getName() + "]"
//      // + " 項目の長さ=[" + item.getLen() + "]"
//      // + " 特殊値指定=[" + item.getValue() + "]");
//      // // mod 2021-04-15 外部連携:log内容を改善 孫 end
//      if ("R".equals(item.getSubMode())) {
//        // 切り取り方式が"R"の場合
//        telegramFragment = new StringBuilder(telegramFragment.substring(
//          telegramFragment.toString().getBytes(DEFAULT_ENCODE).length - item.getLen(),
//            telegramFragment.toString().getBytes(DEFAULT_ENCODE).length));
//      } else if ("N".equals(item.getSubMode())) {
//        // 切り取り方式が"N"の場合
//         throw new NtssException("データ長がオーバーしています。データ内容:[" + telegramFragment.toString() + "]"
//           + ",連携電文設定内容：項目名=[" + item.getName() + "]"
//           + " 項目の長さ=[" + item.getLen() + "]"
//           + " 特殊値指定=[" + item.getValue() + "]");
//      } else if (item.getSubMode() == null || "L".equals(item.getSubMode()) || "".equals(item.getSubMode())) {
//        // 切り取り方式が"L"と設定しないの場合
//        telegramFragment = new StringBuilder(telegramFragment.substring(0, item.getLen()));
//      }
//      // mod redmain #5166 「データの長さによりエラーになってしまう」 鄧シン end
//    }
    // #5166 「データの長さによりエラーになってしまう」
    int lengthByte = telegramFragment.toString().getBytes(DEFAULT_ENCODE).length;
    int lengthItem = item.getLen();
    if (lengthByte > lengthItem) {
      String subMode = item.getSubMode();
      byte[] valueByte = telegramFragment.toString().getBytes(DEFAULT_ENCODE);
      int from = 0;
      int to = 0;
      // 切り取り方式が"L"と設定しないの場合
      if (StringUtils.isEmpty(subMode) || "L".equals(subMode) ) {
        from = 0;
        to = lengthItem;
        // 切り取りした後文字列末尾の半バイトを切り捨する
        // byte->int
        //del 7611 rst_dial連携で送信する項目情報部（実施コメント） 20230112 zhaoqi start
//        int endBytes = valueByte[to - 1] & 0xff;
//        // 半バイトが全角文字の上位8ビット？
//        // 0x81～0x9f -> 129～1599 と 0xe0～0xef -> 224～239
//        if ((endBytes >= 129 && endBytes <= 159) || (endBytes >= 224 && endBytes <= 239)) {
//          to = to - 2;
//        }
        //del 7611 rst_dial連携で送信する項目情報部（実施コメント） 20230112 zhaoqi end
        //add 7611 rst_dial連携で送信する項目情報部（実施コメント） 20230112 zhaoqi start
        int newLength = new String(valueByte, from, to, DEFAULT_ENCODE).length();
        telegramFragment = new StringBuilder(telegramFragment.toString().substring(0, newLength));

        if(telegramFragment.toString().getBytes(DEFAULT_ENCODE).length > lengthItem){
          telegramFragment = new StringBuilder(telegramFragment.substring(0, newLength - 1));
        }
        //add 7611 rst_dial連携で送信する項目情報部（実施コメント） 20230112 zhaoqi end
      } else if ("R".equals(subMode)) {
        // 切り取り方式が"R"の場合
        from = lengthByte - lengthItem;
        to = lengthByte;
        // 文字列先頭の半バイトを切り捨する
        // byte->int
        int endBytes = valueByte[from - 1] & 0xff;
        // 半バイトが全角文字の上位8ビット？
        // 0x81～0x9f -> 129～1599 と 0xe0～0xef -> 224～239
        if ((endBytes >= 129 && endBytes <= 159) || (endBytes >= 224 && endBytes <= 239)) {
          from = from + 1;
        }
        //add 7611 rst_dial連携で送信する項目情報部（実施コメント） 20230112 zhaoqi start
        byte[]  valueCuted = Arrays.copyOfRange(valueByte, from, to);
        telegramFragment = new StringBuilder(new String(valueCuted, DEFAULT_ENCODE).trim());
        //add 7611 rst_dial連携で送信する項目情報部（実施コメント） 20230112 zhaoqi end
      } else {
        // 切り取り方式不正の場合
         throw new NtssException("切り取り方式不正。連携電文設定内容：項目名=[" + item.getName() + "]"
           + " 項目の長さ=[" + item.getLen() + "]"
           + " 切り取り方式=[" + item.getSubMode() + "]"
           + " 項目の値=[" + item.getValue() + "]");
      }

      //del 7611 rst_dial連携で送信する項目情報部（実施コメント） 20230112 zhaoqi start
//      byte[]  valueCuted = Arrays.copyOfRange(valueByte, from, to);
//      telegramFragment = new StringBuilder(new String(valueCuted, DEFAULT_ENCODE).trim());
      //del 7611 rst_dial連携で送信する項目情報部（実施コメント） 20230112 zhaoqi end

      if (telegramFragment.toString().getBytes(DEFAULT_ENCODE).length < item.getLen()) {
        telegramFragment.append(" ");
      }
    }
    // add 2021-10-22 #5890:Medicom連携ができない(受付情報(accept)) 孫 end

    // add 2020-12-30 No.724:電文内データ文字列結合 商 start
    if (telegramFragment.length() > 0) {
      String preChar = "";
      String aftChar = "";
      if (detailLayout == null) {
        /* add by chamaojia 2026-04-27 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
        List<Map<String, Object>> itemSuffixList = textTelegramContext.getItemSuffixList();
        /* add by chamaojia 2026-04-27 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
        for (int i = 0; i < itemSuffixList.size(); i++) {
          if(itemSuffixList.get(i).containsKey("name")) {
            if(item.getName().equals(itemSuffixList.get(i).get("name"))) {
              if(itemSuffixList.get(i).containsKey("pre_char")) {
                preChar = String.valueOf(itemSuffixList.get(i).get("pre_char"));
              }
              if(itemSuffixList.get(i).containsKey("aft_char")) {
                aftChar = String.valueOf(itemSuffixList.get(i).get("aft_char"));
              }
              break;
            }
          }
        }
      } else {
        /* add by chamaojia 2026-04-27 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
        List<Map<String, Object>> itemSuffixDetailList = textTelegramContext.getItemSuffixDetailList();
        /* add by chamaojia 2026-04-27 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
        for (int i = 0; i < itemSuffixDetailList.size(); i++) {
          if(itemSuffixDetailList.get(i).containsKey("name")) {
            if(item.getName().equals(itemSuffixDetailList.get(i).get("name"))) {
              if(itemSuffixDetailList.get(i).containsKey("pre_char")) {
                preChar = String.valueOf(itemSuffixDetailList.get(i).get("pre_char"));
              }
              if(itemSuffixDetailList.get(i).containsKey("aft_char")) {
                aftChar = String.valueOf(itemSuffixDetailList.get(i).get("aft_char"));
              }
              break;
            }
          }
        }
      }

      telegramFragment = telegramFragment.insert(0,preChar);
      telegramFragment.append(aftChar);
    }
    // add 2020-12-30 No.724:電文内データ文字列結合 商 end

    // add FNSI7616-rep_dial連携（HTML）で送信するレポート情報に出力するPDF名 周 start
//    if("fujitsu".equals(layout.getCoopVender())
//      && "rep_dial".equals(journal.getCoopCd())
    if (CoopLayoutConstant.COOP_VENDER_FUJITSU.equals(layout.getCoopVender()) &&
      CoopCdConstant.REP_DIAL.equals(journal.getCoopCd()) &&
      "レポート情報".equals(item.getName()) &&
      elementVal.equals(ElementsValue.DATASET)) {
      return telegramFragment.toString().trim();

    }
    // add FNSI7616-rep_dial連携（HTML）で送信するレポート情報に出力するPDF名 周 end

    return telegramFragment.toString();
  }

  //mod #10901 #10902 mst_coop_apilinkの動作について 20241004 zhaoqi start
  private boolean validateFujitsuOrderBedInHospitalCd(SysCoopJournal journal, MstCoopLayout layout, String tmpVal, Item item) {
    if (CoopLayoutConstant.COOP_VENDER_FUJITSU.equals(layout.getCoopVender()) &&
      CoopCdConstant.IND_DIAL.equals(journal.getCoopCd()) &&
      "予約情報.予約枠コード".equals(item.getName()) &&
      StringUtils.isEmpty(tmpVal.trim())) {

      if (NtssCoopApiConstants.Crud.DELETE.isSameResult(journal.getCrud())) {
        OrdMainRestore ordMainRestore = ordMainRestoreDao.selectByOrdNo(journal.getOrdNo());
        if(ordMainRestore == null) {
          return false;
        }
        if (ordMainRestore.getIndBedCd() == null || 0 == ordMainRestore.getIndBedCd()) {
          return false;
        } else {
          MstBed mstBed = mstBedDao.selectByBedCd(Long.valueOf(ordMainRestore.getIndBedCd()), "1", "0");
          if (null == mstBed) {
            return false;
          } else {
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//            Map<String, Object> map = mstCoopIniDao.selectBedCodeByFacilityCd(journal.getFacilityCd());
            String key0 = StringUtils.isEmpty(journal.getKey0())?"":journal.getKey0();
            Map<String, Object> map = mstCoopIniDao.selectBedCodeByFacilityCd(journal.getFacilityCd(), key0);
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
            if (null == map) {
              return true;
            } else {
              if (!map.containsKey("bed_code_kbn")) {
                return false;
              } else {
                String bedCode = (String)map.get("bed_code_kbn");
                if ("1".equals(bedCode)) {
                  return null == mstBed.getInHospitalCd_1();
                } else if ("2".equals(bedCode)) {
                  return null == mstBed.getInHospitalCd_2();
                }else{
                  return false;
                }
              }
            }

          }
        }
      }
    }
    return false;
  }
  //mod #10901 #10902 mst_coop_apilinkの動作について 20241004 zhaoqi end

  /**
   * 固定値での電文作成
   *
   * @param constValue - 固定値
   * @param item - {@link Item}
   * @return Paddingされた固定値
   */
  private String concatConstValue(String constValue, Item item) {
    return padding(item, constValue);
  }

  /**
   * data-setでの電文作成
   *
   * @param dataSetResultMap - data-setの結果Map
   * @param dataSetValue - data-setの結果Mapから抽出したいキー
   * @param item - {@link Item}
   * @return Paddingされたdata-setの値
   */
  private String concatDatasetValue(Map<String, List<Map<String, Object>>> dataSetResultMap, String dataSetValue, Item item) {
    String telegramFragment = "";
    // ドットで区切られているため、区切り文字がない場合はエラー
    if (dataSetValue.indexOf(".") == -1) {
      throw new NtssException("データセットから電文変換に必要なドット区切りが存在しません。 対象データ:[" + dataSetValue + "]");
    }

    // String#splitはpatternで分割するため、ドット単体だと分割できない(matchせず空配列で返却される)のでPattern化する
    String[] datasetArray = dataSetValue.split(Pattern.quote("."));
    String sqlCode = datasetArray[0];
    String extractColumnName = datasetArray[1];

    if (!dataSetResultMap.containsKey(sqlCode)) {
      throw new NtssException("SQLCODEに対するデータセットが存在しません。 SQLCODE:[" + sqlCode + "]");
    }

    List<Map<String, Object>> dataSetResultList = dataSetResultMap.get(sqlCode);
    for (Map<String, Object> dataSetResult : dataSetResultList) {
      telegramFragment = telegramFragment.concat(String.valueOf(dataSetResult.get(extractColumnName)));
    }

    // mod FNSI7018-ind_dial連携で送信する文書番号 周 start
    if("-64".equals(sqlCode) && (2 == telegramFragment.trim().length() || telegramFragment.trim().length() > 10)) {
      //連携オーダー番号がnullまたは8桁以上の場合、エラーとする
      throw new NtssException("連携オーダー番号の長さが不正");
    }
    // mod FNSI7018-ind_dial連携で送信する文書番号 周 end

    return padding(item, telegramFragment);
  }

  /**
   * auth_Idでの電文作成
   *
   * @param dataSetResultMap - data-setの結果Map
   * @param dataSetValue - data-setの結果Mapから抽出したいキー
   * @param item - {@link Item}
   * @return Paddingされたdata-setの値
   */
  private String concatAuthValue(Map<String, List<Map<String, Object>>> dataSetResultMap, String dataSetValue, Item item) {

    // ドットで区切られているため、区切り文字がない場合はエラー
    if (dataSetValue.indexOf(".") == -1) {
      throw new NtssException("データセットから電文変換に必要なドット区切りが存在しません。対象データ:[" + dataSetValue + "]");
    }

    // String#splitはpatternで分割するため、ドット単体だと分割できない(matchせず空配列で返却される)のでPattern化する
    String[] datasetArray = dataSetValue.split(Pattern.quote("."));
    String sqlCode = datasetArray[0];
    String extractColumnName = datasetArray[1];

    if (!dataSetResultMap.containsKey(sqlCode)) {
      throw new NtssException("SQLCODEに対するデータセットが存在しません。SQLCODE:[" + sqlCode + "]");
    }

    String telegramFragment = "";
    for (Map<String, Object> dataSetResult : dataSetResultMap.get(sqlCode)) {
      // 検索値の取得
      String value = String.valueOf(dataSetResult.get(extractColumnName));
      // 利用者マスタから検索し設定
      telegramFragment = telegramFragment.concat(convertSendCommonService.getAuthId(value));
    }
    return padding(item, telegramFragment);
  }

// add 2021-12-22 #5888:NEC-iS連携ができない(透析実績(rst_dial)) 孫 start
  /**
   * in_hospital_cd_1/in_hospital_cd_2での電文作成
   *
   * @param dataSetResultMap - data-setの結果Map
   * @param dataSetValue - data-setの結果Mapから抽出したいキー
   * @param item - {@link Item}
   * @param flag - 1：院内コード1、2:院内コード2
   * @return Paddingされたdata-setの値
   */
  private String concatInHospitalCdValue(Map<String, List<Map<String, Object>>> dataSetResultMap, String dataSetValue, Item item, int flag) {

    // ドットで区切られているため、区切り文字がない場合はエラー
    if (dataSetValue.indexOf(".") == -1) {
      throw new NtssException("データセットから電文変換に必要なドット区切りが存在しません。対象データ:[" + dataSetValue + "]");
    }

    // String#splitはpatternで分割するため、ドット単体だと分割できない(matchせず空配列で返却される)のでPattern化する
    String[] datasetArray = dataSetValue.split(Pattern.quote("."));
    String sqlCode = datasetArray[0];
    String extractColumnName = datasetArray[1];

    if (!dataSetResultMap.containsKey(sqlCode)) {
      throw new NtssException("SQLCODEに対するデータセットが存在しません。SQLCODE:[" + sqlCode + "]");
    }

    String telegramFragment = "";
    for (Map<String, Object> dataSetResult : dataSetResultMap.get(sqlCode)) {
      // 検索値の取得
      String value = String.valueOf(dataSetResult.get(extractColumnName));
      if (1 == flag) {
        // 利用者マスタから院内コード1(in_hospital_cd_1)検索し設定
        telegramFragment = telegramFragment.concat(convertSendCommonService.getInHospitalCd1(value));
      } else {
        // 利用者マスタから院内コード2(in_hospital_cd_2)検索し設定
        telegramFragment = telegramFragment.concat(convertSendCommonService.getInHospitalCd2(value));
      }
    }
    return padding(item, telegramFragment);
  }
// add 2021-12-22 #5888:NEC-iS連携ができない(透析実績(rst_dial)) 孫 end

// add 2021-10-14 CSIの「【検査予定送信】のスタッフマスタ.職種コード」の対応 孫 start
  /**
   * job_cdでの電文作成
   *
   * @param dataSetResultMap - data-setの結果Map
   * @param dataSetValue - data-setの結果Mapから抽出したいキー
   * @param item - {@link Item}
   * @return Paddingされたdata-setの値
   */
  private String concatJobCdValue(Map<String, List<Map<String, Object>>> dataSetResultMap, String dataSetValue, Item item) {

    // ドットで区切られているため、区切り文字がない場合はエラー
    if (dataSetValue.indexOf(".") == -1) {
      throw new NtssException("データセットから電文変換に必要なドット区切りが存在しません。対象データ:[" + dataSetValue + "]");
    }

    // String#splitはpatternで分割するため、ドット単体だと分割できない(matchせず空配列で返却される)のでPattern化する
    String[] datasetArray = dataSetValue.split(Pattern.quote("."));
    String sqlCode = datasetArray[0];
    String extractColumnName = datasetArray[1];

    if (!dataSetResultMap.containsKey(sqlCode)) {
      throw new NtssException("SQLCODEに対するデータセットが存在しません。SQLCODE:[" + sqlCode + "]");
    }

    String telegramFragment = "";
    for (Map<String, Object> dataSetResult : dataSetResultMap.get(sqlCode)) {
      // 検索値の取得
      String value = String.valueOf(dataSetResult.get(extractColumnName));
      // 利用者マスタから職種コード(JOB_CD)検索し設定
      telegramFragment = telegramFragment.concat(convertSendCommonService.getJobCd(value));
    }
    return padding(item, telegramFragment);
  }
// add 2021-10-14 CSIの「【検査予定送信】のスタッフマスタ.職種コード」の対応 孫 end

// add 2021-10-28 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 start
  /**
   * staff_nameでの電文作成
   *
   * @param dataSetResultMap - data-setの結果Map
   * @param dataSetValue - data-setの結果Mapから抽出したいキー
   * @param item - {@link Item}
   * @return Paddingされたdata-setの値
   */
  private String concatStaffNameValue(Map<String, List<Map<String, Object>>> dataSetResultMap, String dataSetValue, Item item) {

    // ドットで区切られているため、区切り文字がない場合はエラー
    if (dataSetValue.indexOf(".") == -1) {
      throw new NtssException("データセットから電文変換に必要なドット区切りが存在しません。対象データ:[" + dataSetValue + "]");
    }

    // String#splitはpatternで分割するため、ドット単体だと分割できない(matchせず空配列で返却される)のでPattern化する
    String[] datasetArray = dataSetValue.split(Pattern.quote("."));
    String sqlCode = datasetArray[0];
    String extractColumnName = datasetArray[1];

    if (!dataSetResultMap.containsKey(sqlCode)) {
      throw new NtssException("SQLCODEに対するデータセットが存在しません。SQLCODE:[" + sqlCode + "]");
    }

    String telegramFragment = "";
    for (Map<String, Object> dataSetResult : dataSetResultMap.get(sqlCode)) {
      // 検索値の取得
      String value = String.valueOf(dataSetResult.get(extractColumnName));
      // 利用者マスタから利用者名(STAFF_NAME)検索し設定
      telegramFragment = telegramFragment.concat(convertSendCommonService.getStaffName(value));
    }
    return padding(item, telegramFragment);
  }
// add 2021-10-28 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 end

// mod 2021-10-19 #5890:Medicom連携ができない(検査オーダ(exam_ord)) 孫 start
//  /**
//   * 現在日(yyyyMMdd)での電文作成
//   *
//   * @return 現在日(yyyyMMdd)
//   */
//  private String concatSYSDATE() {
//    DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern("yyyyMMdd");
//    return dateFormat.format(LocalDateTime.now(clockWrapper.getClock()));
//  }
//
//  /**
//   * 現在時刻(HHmmss)での電文作成
//   *
//   * @return 現在時刻(HHmmss)
//   */
//  private String concatSYSTIME() {
//    DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern("HHmmss");
//    return dateFormat.format(LocalDateTime.now(clockWrapper.getClock()));
//  }

  /**
   * 現在日(yyyyMMdd)での電文作成
   *
   * @param item - {@link Item}
   * @return 現在日(yyyyMMdd)
   */
  private String concatSYSDATE(Item item) {
// mod 2021-11-19 #5888:NEC連携ができない(バイタル連携) 孫 start
//    DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern("yyyyMMdd");
//    String dateTmp = dateFormat.format(LocalDateTime.now(clockWrapper.getClock()));
    String attributeValue = "";
    String dateTmp = "";
    try {
      attributeValue =  URLDecoder.decode(item.getValue(), DEFAULT_ENCODE);
      // format[yyyyMMdd,yyyy/MM/dd,yyyy-MM-dd]
      String format = attributeValue.replace("$SYSDATE", "");
      if (StringUtils.isEmpty(format)) {
        format = "yyyyMMdd";
      }
      DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern(format.trim());
      dateTmp = dateFormat.format(LocalDateTime.now(clockWrapper.getClock()));
    } catch (Exception e) {
      throw new NtssException("現在日のフォーマット[" + attributeValue + "]不正。[" + e.getMessage() + "]");
    }
// mod 2021-11-19 #5888:NEC連携ができない(バイタル連携) 孫 end
    if (dateTmp.length() > item.getLen()) {
      if (StringUtils.isEmpty(item.getSubMode()) && "L".equals(item.getSubMode())) {
        // 切り取り方式が"L"と設定しないの場合
        dateTmp = dateTmp.substring(0, item.getLen());
      } else {
        // 切り取り方式が"R"の場合
        dateTmp = dateTmp.substring(dateTmp.length() - item.getLen(), dateTmp.length());
      }
      return dateTmp;
    } else {
      return padding(item, dateTmp);
    }
  }

  /**
   * 現在時刻(HHmmss)での電文作成
   *
   * @param item - {@link Item}
   * @return 現在時刻(HHmmss)
   */
  private String concatSYSTIME(Item item) {
// mod 2021-11-19 #5888:NEC連携ができない(バイタル連携) 孫 start
//    DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern("HHmmss");
//    String timeTmp =  dateFormat.format(LocalDateTime.now(clockWrapper.getClock()));
    String attributeValue = "";
    String timeTmp = "";
    try {
      attributeValue =  URLDecoder.decode(item.getValue(), DEFAULT_ENCODE);
      // format[HHmmssSSS,HHmmss,HH:mm:ss.SSS,HH:mm:ss]
      String format = attributeValue.replace("$SYSTIME", "");
      if (StringUtils.isEmpty(format)) {
        format = "HHmmss";
      }
      DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern(format.trim());
      timeTmp = dateFormat.format(LocalDateTime.now(clockWrapper.getClock()));
    } catch (Exception e) {
      throw new NtssException("現在時刻のフォーマット[" + attributeValue + "]不正。[" + e.getMessage() + "]");
    }
// mod 2021-11-19 #5888:NEC連携ができない(バイタル連携) 孫 end
    if (timeTmp.length() > item.getLen()) {
      if (StringUtils.isEmpty(item.getSubMode()) && "L".equals(item.getSubMode())) {
        // 切り取り方式が"L"と設定しないの場合
        timeTmp = timeTmp.substring(0, item.getLen());
      } else {
        // 切り取り方式が"R"の場合
        timeTmp = timeTmp.substring(timeTmp.length() - item.getLen(), timeTmp.length());
      }
      return timeTmp;
    } else {
      return padding(item, timeTmp);
    }
  }
// mod 2021-10-19 #5890:Medicom連携ができない(検査オーダ(exam_ord)) 孫 end

  /**
   * mst_coop_layoutおよびmst_coop_layout_detailのcoop_cd_subを求めます
   *
   * @param crud - sys_coop_journal.crud
   * @return coop_cd_sub
   */
  private String getCoopCdSub(String crud) {
    // 共通処理を呼び出す
    return convertSendCommonService.getCoopCdSub(crud);
  }

  /**
   * XML要素に定義されたPaddingを行います。未指定は右スペースでlen属性分Paddingします
   *
   * @param item - {@link Item}
   * @param target - Padding対象
   * @return Paddingされた文字列
   */
  private String padding(Item item, String target) {
    // 長さ不足の場合はデフォルト左スペース埋め。padding_format, padding_positionがあればそちらを優先して埋める
    if (!StringUtils.isEmpty(item.getPaddingFormat()) && !StringUtils.isEmpty(item.getPaddingPosition())) {
      return paddingByFormat(target, item.getLen(), item.getPaddingFormat(), item.getPaddingPosition());
    }

    return paddingByDefault(target, item.getLen());
  }

  /**
   * Paddingデフォルト対応(右スペース埋め)
   *
   * @param target - Padding対象
   * @param itemLength - Paddingする桁数
   * @return Paddingされた文字列
   */
  private String paddingByDefault(String target, int itemLength) {
    try {
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("item : " + itemLength + ", target : " + target.getBytes(DEFAULT_ENCODE).length);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      int length = itemLength - target.getBytes(DEFAULT_ENCODE).length;
      if (length <= 0) return target;

      // String#Formatだと文字長でのパディングとなってしまうため、byte長でのパディングにするべく
      // パディングしたい長さまでスペースを作り、くっつける対象と結合する
      String padding = String.format("%" + length + "s", "");
      return target.concat(padding);
    } catch (UnsupportedEncodingException e) {
      throw new NtssException(e);
    }
  }

  /**
   * padding_format の値
   */
  @Getter
  @AllArgsConstructor
  private enum PaddingFormat {
    /** 0埋め */
    ZERO("zero"),
    /** 半角スペース埋め */
    SPACE("blank"),
    /** 全角スペース埋め */
    FSPACE("fblank");

    private String value;

    /**
     * 指定した {@code value} と同じ値を持つ PaddingFormat を返す
     *
     * @param value [NULL] {@code padding_format} の値
     * @return [NULL] 指定した {@code value} を持つ PaddingFormat の値、
     * 指定した {@code value} を持つ値が存在しない場合は {@code null} を返す
     */
    public static PaddingFormat fromValue(String value) {
      for (PaddingFormat e : values()) {
        if (e.value.equals(value)) {
          return e;
        }
      }

      return null;
    }
  }

  /**
   * Paddingフォーマット対応(左/右、ゼロ埋め/半角スペース埋め/全角スペース埋め)
   *
   * @param target - Padding対象
   * @param itemLength - Paddingする桁数
   * @param format - {@link Item#getPaddingFormat()}
   * @param position - {@link Item#getPaddingPosition()}
   * @return Paddingされた文字列
   */
  private static String paddingByFormat(String target, int itemLength, String format, String position) {
    try {
      int formatedLength = itemLength - target.getBytes(DEFAULT_ENCODE).length;
      // add 2021-10-22 #5890:Medicom連携ができない(受付情報(accept)) 孫 start
      if (formatedLength <= 0) {
        return target;
      }
      // add 2021-10-22 #5890:Medicom連携ができない(受付情報(accept)) 孫 end
      // ゼロ埋めの場合、数値じゃないとformatをかけれないのでゼロ埋め/スペース埋め指定問わず、一旦スペース埋めにする
      String paddingByBlankFormat = "%".concat(String.valueOf(formatedLength)).concat("s");
      String paddingByBlank = String.format(paddingByBlankFormat, "");

      String paddingOnly;
      PaddingFormat paddingFormat = PaddingFormat.fromValue(format);
      if(paddingFormat == null) {
        throw new NtssException("対応するフォーマットではありません。padding_format:[" + format + "]");
      }

      switch(paddingFormat) {
        case SPACE:
          // そのまま
          paddingOnly = paddingByBlank;
          break;

        case ZERO:
          // ゼロ埋め指定だったら、スペース埋めにした文字列を0にリプレイスする
          paddingOnly = paddingByBlank.replace(" ", "0");
          break;

        case FSPACE:
          // パディングする文字長が 2バイトで割り切れない場合は対象外
          if((formatedLength % 2) != 0) {
            throw new NtssException("2バイトで割り切れないため全角スペースで処理出来ません。");
          }
          paddingOnly = paddingByBlank.replace("  ", "　");
          break;

        default:
          throw new NtssException("対応するフォーマットではありません。padding_format:[" + format + "]");
      }
      return position.equals("left") ? paddingOnly.concat(target) : target.concat(paddingOnly);
    } catch (UnsupportedEncodingException e) {
      throw new NtssException(e);
    }
  }

  /* add by chamaojia 2026-04-27 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  /**
   * テキスト電文作成中の一時状態.
   */
  private static class TextTelegramContext {
    private int head = 1;
    private List<Map<String, Object>> itemSuffixList = new ArrayList<>();
    private List<Map<String, Object>> itemSuffixDetailList = new ArrayList<>();

    private int nextHead() {
      return head++;
    }

    private void resetHead() {
      head = 1;
    }

    private List<Map<String, Object>> getItemSuffixList() {
      return itemSuffixList;
    }

    private void setItemSuffixList(List<Map<String, Object>> itemSuffixList) {
      this.itemSuffixList = itemSuffixList;
    }

    private List<Map<String, Object>> getItemSuffixDetailList() {
      return itemSuffixDetailList;
    }

    private void setItemSuffixDetailList(List<Map<String, Object>> itemSuffixDetailList) {
      this.itemSuffixDetailList = itemSuffixDetailList;
    }
  }
  /* add by chamaojia 2026-04-27 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

  /**
   * 電文長計算class
   *
   */
  private class TelegramLengthCalculator {
    /** 電文長計算のトリガーを持っているXML要素List(Map<XML要素、電文長挿入位置>) */
    private List<Map<Item, Integer>> calculatorList = new ArrayList<>();
    /** 挿入する電文長の値 */
    private int totalLength;
    /** 電文長加算減算の位置と数値List(Map<電文長挿入位置、減算値>) */
    private List<Map<Integer, Integer>> subCalculatorList = new ArrayList<>();

    /**
     * 電文長計算のトリガー(value="$LENGTH")を持っているXML要素をListに追加します
     *
     * @param item - 電文長計算のトリガーを持っている {@link Item}
     */
    private void addTelegramLengthItem(Item item) {
      // 電文長計算の順番が不同となると、電文をsubstringする時に座標が壊れてStringIndexOutOfBoundsExceptionが発生しかねないので
      // HashMapをListに入れて電文長計算する順番を保管する
      Map<Item, Integer> telegramAndStartIndexMap = new HashMap<>();
      telegramAndStartIndexMap.put(item, totalLength - item.getLen());
      calculatorList.add(telegramAndStartIndexMap);
    }

    /**
     * 電文長計算のトリガー(value="$LENGTH n")を持っているXML要素の位置と加算減算数をListに追加します
     *
     * @param item - 電文長計算のトリガーを持っている {@link Item}
     */
    private void subTelegramLengthItem(Item item) throws UnsupportedEncodingException {
      Map<Integer, Integer> subLengthMap = new HashMap<>();
      String attributeValue = "";
      int subLength = 0;
      attributeValue =  URLDecoder.decode(item.getValue(), DEFAULT_ENCODE);
      String value = attributeValue.replace("$LENGTH", "");
      if (!StringUtils.isEmpty(value.trim())) {
        try {
          subLength = Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
          subLength = 0;
        }
      }
      if (subLength != 0) {
        subLengthMap.put(totalLength - item.getLen(), subLength);
        subCalculatorList.add(subLengthMap);
      }
    }

    /**
     * 電文長を加算します
     *
     * @param target - 加算値
     */
    private void addTotalLength(int target) {
      this.totalLength = this.totalLength + target;
    }

    /**
     * 加算された電文長を電文に挿入します
     *
     * @param target - 電文
     * @return 電文長が挿入された電文
     */
    private String transformCaliculateTelegramLength(String target) {
      String result = target;
      EventLogMessage eventLogMessage = new EventLogMessage();
      for (Map<Item, Integer> telegramAndStartIndexMap : calculatorList) {
        Set<Entry<Item, Integer>> keyset = telegramAndStartIndexMap.entrySet();
        for (Entry<Item, Integer> entry : keyset) {
          // 電文長を入れる座標の接頭、接尾として分解。
          String insertTargetPrefix = result.substring(0, entry.getValue());
          String insertTargetSuffix = result.substring(entry.getValue());
          // パディングを入れた電文長結果と分解した接頭、接尾を合体
// mod 2022-02-10 #7000:ind_dial連携で送信する電文長 孫 start
//          result = insertTargetPrefix.concat(padding(entry.getKey(), String.valueOf(this.totalLength))).concat(insertTargetSuffix);
          //subCalcilatorListのkeyとの一致を見て一致したら加算減算数を取得
          int subLength = 0;
          for (Map<Integer, Integer> subLengthMap : subCalculatorList){
            Set<Entry<Integer, Integer>> subKeyset = subLengthMap.entrySet();
            for (Entry<Integer, Integer> subEntry : subKeyset) {
              if (subEntry.getKey().equals(entry.getValue())) {
                subLength = subEntry.getValue();
              }
            }
          }
          String totalLengthString = paddingByFormat(String.valueOf(this.totalLength + subLength), entry.getKey().getLen(), "zero", "left");
          result = insertTargetPrefix.concat(totalLengthString).concat(insertTargetSuffix);
// mod 2022-02-10 #7000:ind_dial連携で送信する電文長 孫 end
          eventLogMessage.setLogMessage("開始位置 : [" + entry.getValue() + "], 長さ : [" + entry.getKey() + "], "
              + "挿入対象の接頭 : [" + insertTargetPrefix + "], 挿入対象の接尾 : [" + insertTargetSuffix + "], 挿入結果 : [" + result + "]");
          // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
          eventLogMessage.setInvokeClass(this.getClass().getName());
          // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
          logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        }
      }
      return result;
    }
  }

  /**
   * 値の変換処理
   *
   * @param elementVal 属性のvalue値
   * @param value 変換対象の値
   * @param item {@link - item}
   * @return 変換後の値
   * */
  private String convertValue(ElementsValue elementVal, String value, Item item) {

    String convValue;
    switch (elementVal) {
      case DATASET:   // dataset
        // 変換なし
        convValue = value;
        break;
      case AUTH_ID:   // auth_id
        // 引数をもとに利用者マスタの検索
        convValue = convertSendCommonService.getAuthId(value);
        break;
// add 2021-12-22 #5888:NEC-iS連携ができない(透析実績(rst_dial)) 孫 start
      case IN_HOSPITAL_CD_1:   // in_hospital_cd_1
        // 引数をもとに利用者マスタの検索
        convValue = convertSendCommonService.getInHospitalCd1(value);
        break;
      case IN_HOSPITAL_CD_2:   // in_hospital_cd_2
        // 引数をもとに利用者マスタの検索
        convValue = convertSendCommonService.getInHospitalCd2(value);
        break;
// add 2021-12-22 #5888:NEC-iS連携ができない(透析実績(rst_dial)) 孫 end
// add 2021-10-14 CSIの「【検査予定送信】のスタッフマスタ.職種コード」の対応 孫 start
      case JOB_CD:   // job_cd
        // 引数をもとに利用者マスタの検索
        convValue = convertSendCommonService.getJobCd(value);
        break;
// add 2021-10-14 CSIの「【検査予定送信】のスタッフマスタ.職種コード」の対応 孫 end
// add 2021-10-28 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 start
      case STAFF_NAME:   //staff_name
        // 引数をもとに利用者マスタの利用者名検索
        convValue = convertSendCommonService.getStaffName(value);
        break;
// add 2021-10-28 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 end
      default:
        // それ以外はそのままの値を返却
        return value;
    }
    // パティングした結果を返却
    return padding(item, convValue);
  }

  /**
   * 値の変換処理
   *
   * @param elementVal 属性のvalue値
   * @param dataSetResultMap 変換対象の値
   * @param keyValue 検索値
   * @param item {@link - item}
   * @return 変換後の値
   * */
  private String convertValue(ElementsValue elementVal, Map<String,List<Map<String, Object>>> dataSetResultMap, String keyValue, Item item) {

    switch (elementVal) {
      case DATASET:   // dataset
        // 変換なし
        return concatDatasetValue(dataSetResultMap, keyValue, item);
      case AUTH_ID:   // auth_id
        // 利用者マスタから取得
        return concatAuthValue(dataSetResultMap, keyValue, item);
// add 2021-12-22 #5888:NEC-iS連携ができない(透析実績(rst_dial)) 孫 start
      case IN_HOSPITAL_CD_1:   // in_hospital_cd_1
        // 利用者マスタから取得
        return concatInHospitalCdValue(dataSetResultMap, keyValue, item, 1);
      case IN_HOSPITAL_CD_2:   // in_hospital_cd_2
        // 利用者マスタから取得
        return concatInHospitalCdValue(dataSetResultMap, keyValue, item, 2);
// add 2021-12-22 #5888:NEC-iS連携ができない(透析実績(rst_dial)) 孫 end
// add 2021-10-14 CSIの「【検査予定送信】のスタッフマスタ.職種コード」の対応 孫 start
      case JOB_CD:   // job_cd
        // 利用者マスタから職種コード取得
        return concatJobCdValue(dataSetResultMap, keyValue, item);
// add 2021-10-14 CSIの「【検査予定送信】のスタッフマスタ.職種コード」の対応 孫 end
// add 2021-10-28 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 start
      case STAFF_NAME:   //staff_name
        // 利用者マスタから利用者名取得
        return concatStaffNameValue(dataSetResultMap, keyValue, item);
// add 2021-10-28 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 end

      default:
        // それ以外は変換対象外なのでエラーとする
        throw new NtssException("未定義の値が指定されているため、変換できません。出力方法:[" + elementVal.getKey() + "]");
    }
  }

  // add 2020-12-30 No.724:電文内データ文字列結合 商 start
  /**
   * 接頭語、接尾語取得
   *
   * @param layoutExtSetting 拡張設定値
   * @return 接頭語、接尾語リスト
   * */
  private List<Map<String, Object>> getItemSuffixList(LayoutExtSetting layoutExtSetting) {
    List<Map<String, Object>> list = new ArrayList<>();
    if (layoutExtSetting == null || !layoutExtSetting.containsKey("item_suffix")) {
      return list;
    } else {
      for (Entry<String, Object> keyValue : layoutExtSetting.entrySet()) {
        if (!keyValue.getKey().equals("item_suffix")) continue;
        list = cast(keyValue.getValue());
      }
    }
    return list;
  }

  /**
   * 未検査キャスト用メソッド
   *
   * @param target - キャスト対象
   * @return T
   */
  @SuppressWarnings("unchecked")
  private <T> T cast(Object target) {
    T castTarget = (T)target;
    return castTarget;
  }
  // add 2020-12-30 No.724:電文内データ文字列結合 商 end
}
