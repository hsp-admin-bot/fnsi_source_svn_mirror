package jp.co.nikkiso.ntss.coop_api.service;

import java.io.IOException;
import java.io.Reader;
import java.io.StringReader;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import jp.co.nikkiso.ntss.coop_api.response.JournalConvertResult.ResultMap;
import jp.co.nikkiso.ntss.coop_api.utils.ConverterConf;
import jp.co.nikkiso.ntss.coop_api.utils.EvaluatorDatasetUtil;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants;
import jp.co.nikkiso.ntss.coop_api.utils.LayoutExtSettingUtil;
import jp.co.nikkiso.ntss.coop_api.utils.ValueEvaluatorUtil;
import jp.co.nikkiso.ntss.coop_api.validator.ConvertValidator;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MstCoopLayoutDao;
import jp.co.nikkiso.ntss.core.entity.MstCoopLayout;
import jp.co.nikkiso.ntss.core.entity.json.LayoutExtSetting;
import jp.co.nikkiso.ntss.core.entity.xml.Item;
import jp.co.nikkiso.ntss.core.entity.xml.Root;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;

/**
 * CSV形式文字列をJSON形式に変換するサービスクラス。
 */
@Service
public class ConvertCsvServiceImpl implements ConvertByFormatService {
  /**
   * 拡張設定中のCSV指定キー（第1階層）
   */
  private static final String KEY_CSV = "csv";

  /**
   * 拡張設定中のデリミタ指定キー（第2階層）
   */
  private static final String KEY_DELIM = "delim";

  /**
   * 拡張設定中のCSV項目デリミタ指定キー（第3階層）
   */
  private static final String KEY_ITEM = "item";

  /**
   * 拡張設定でデリミタが指定されていない場合の値（カンマ）
   */
  private static final String CSV_DELIM_DEFAULT = ",";

  @Autowired
  private ConverterConf settings;

  @Autowired
  private MstCoopLayoutDao mstCoopLayoutDao;

  @Autowired
  private LogService logService;

  @Autowired
  private ValueEvaluatorUtil valueEvaluatorUtil;

  @Autowired
  private LayoutExtSettingUtil layoutExtSettingUtil;

  // mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
  @Autowired
  private ConvertCommonService convertCommonService;
  // mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end

  /**
   * レイアウトXMLでcol属性が指定された項目の値を取得する。
   *
   * @param facilityCd 施設コード
   * @param direction 向き（送受信）
   * @param coopCd 電文種別
   * @param coopCdIndex 付帯情報（電文）
   * @param coopVersion 連携版番号
   * @param key0 電子カルテ種別
   * @param coopCdSub 電文種別補足コード
   * @param message 変換対象文字列
   * @param keyResult key属性が指定された項目の値
   * @return col属性収集結果
   * @throws UnsupportedEncodingException SJISエンコーディングが使用できない場合
   * @see ConvertByFormatService#convert(String, String, String, String, byte[], Root, LayoutExtSetting, ResultMap)
   */
  @Override
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  public ResultMap convert(String facilityCd, String direction, String coopCd, String coopCdIndex, String coopCdSub, byte[] message,
//                           ResultMap keyResult)
//    throws UnsupportedEncodingException {
  public ResultMap convert(String facilityCd, String direction, String coopCd, String coopCdIndex, String coopVersion,
                           String key0, String coopCdSub, byte[] message, ResultMap keyResult) throws UnsupportedEncodingException {
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    EvaluatorDatasetUtil.setConf(settings);

    ResultMap colResult = new ResultMap();
    if (keyResult == null) {
      keyResult = new ResultMap();
    }

    // レイアウトを取得する。
    // （テキスト形式電文では先に電文をSJISに変換しているのに対し、順序が逆である。
    // これは、CSV項目のデリミタをレイアウトから取得することによる。）

// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////    MstCoopLayout mcl = mstCoopLayoutDao.select(facilityCd, coopCd, coopCdIndex, direction,
////      JournalConvertConstants.AUX_CODE_PRELOGIC);
//    MstCoopLayout mcl = mstCoopLayoutDao.select(facilityCd, coopCd, coopCdIndex, coopVersion, direction,
//      JournalConvertConstants.AUX_CODE_PRELOGIC);
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//    // add 2021-12-06 #5888:NEC連携ができない(スタッフマスタ連携) 孫 start
//    if (mcl == null) {
//// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////      String errMsg = String.format("電文変換レイアウトが設定されていません。施設コード:[%s], 送受信向き:[%s], 電文種別:[%s], 電文付帯情報:[%s], 電文種別補足コード:[%s]",
////        facilityCd, direction, coopCd, coopCdIndex, coopCdSub);
//      String errMsg = String.format("電文変換レイアウトが設定されていません。施設コード:[%s], 送受信向き:[%s], 電文種別:[%s], 連携版番号:[%s], 電文付帯情報:[%s], 電文種別補足コード:[%s]",
//        facilityCd, direction, coopCd, coopVersion, coopCdIndex, coopCdSub);
//// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//      throw new NtssException(errMsg);
//    }
//    // add 2021-12-06 #5888:NEC連携ができない(スタッフマスタ連携) 孫 end
    MstCoopLayout mcl = convertCommonService.getMstCoopLayoutBySub(facilityCd, direction,
      coopCd, coopCdIndex, coopVersion, JournalConvertConstants.AUX_CODE_PRELOGIC);
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end

    Root root = mcl.getCoopSettingRoot();
    LayoutExtSetting preLayoutExtSetting = mcl.getCoopExtSetting();
    // add 2021-12-06 #5888:NEC連携ができない(スタッフマスタ連携) 孫 start
    if (root == null || preLayoutExtSetting == null ) {
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//      String errMsg = String.format("電文変換レイアウトの「連携設定、拡張設定」が設定されていません。施設コード:[%s], 送受信向き:[%s], 電文種別:[%s], 電文付帯情報:[%s], 電文種別補足コード:[%s]",
//        facilityCd, direction, coopCd, coopCdIndex, coopCdSub);
      String errMsg = String.format("電文変換レイアウトの「連携設定、拡張設定」が設定されていません。施設コード:[%s], 送受信向き:[%s], 電文種別:[%s], 連携版番号:[%s], 電文付帯情報:[%s], 電文種別補足コード:[%s]",
        facilityCd, direction, coopCd, coopVersion, coopCdIndex, coopCdSub);
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
      throw new NtssException(errMsg);
    }
    // add 2021-12-06 #5888:NEC連携ができない(スタッフマスタ連携) 孫 end
    // 電文の文字列をCSV項目に分割する。
    //add 7713 富士通指摘：PC上で使用している文字で判読不能になるものがある。張 start
//    String sjisStr = new String(message, JournalConvertConstants.TELEGRAM_ENCODING_BY_SJIS);
    String sjisStr = new String(message, JournalConvertConstants.TELEGRAM_ENCODING_BY_MS932);
    //add 7713 富士通指摘：PC上で使用している文字で判読不能になるものがある。張 end
    List<String> csvItemList = getCSVItemList(sjisStr, getDelim(preLayoutExtSetting));

    // 1パス目（電文種別補足コード=pre）
    // col属性は指定されていない想定である。（指定されていても読み飛ばす。）
    ResultMap rm = new ResultMap();
    List<Item> itemList = root.getItemList();

// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    parseByLayout(facilityCd, direction, coopCd, coopCdIndex, coopCdSub, csvItemList, 0, itemList, preLayoutExtSetting, rm,
//      keyResult);
    parseByLayout(facilityCd, direction, coopCd, coopCdIndex, coopVersion, coopCdSub, csvItemList, 0, itemList, preLayoutExtSetting, rm,
        keyResult);
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

    // add 2021-12-06 #5888:NEC連携ができない(スタッフマスタ連携) 孫 start
    // 処理区分項目(shori_kbn)が無し場合、col属性収集結果(rm)をを返す
    if (!keyResult.containsKey(JournalConvertConstants.KEY_SHORI_KUBUN)) {
      return rm;
    }
    // add 2021-12-06 #5888:NEC連携ができない(スタッフマスタ連携) 孫 end

    // 2パス目
    // 1パス目で抽出したshori_kbnキーに沿ってレイアウトを取得する。
    coopCdSub = (String) keyResult.get(JournalConvertConstants.KEY_SHORI_KUBUN);
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////    MstCoopLayout creLayout = mstCoopLayoutDao.select(facilityCd, coopCd, coopCdIndex, direction, coopCdSub);
//    MstCoopLayout creLayout = mstCoopLayoutDao.select(facilityCd, coopCd, coopCdIndex, coopVersion, direction, coopCdSub);
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//    // add 2021-12-06 #5888:NEC連携ができない(スタッフマスタ連携) 孫 start
//    if (creLayout == null) {
//// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////      String errMsg = String.format("電文変換レイアウトが設定されていません。施設コード:[%s], 送受信向き:[%s], 電文種別:[%s], 電文付帯情報:[%s], 電文種別補足コード:[%s]",
////        facilityCd, direction, coopCd, coopCdIndex, coopCdSub);
//      String errMsg = String.format("電文変換レイアウトが設定されていません。施設コード:[%s], 送受信向き:[%s], 電文種別:[%s], 連携版番号:[%s], 電文付帯情報:[%s], 電文種別補足コード:[%s]",
//        facilityCd, direction, coopCd, coopVersion, coopCdIndex, coopCdSub);
//// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//      throw new NtssException(errMsg);
//    }
    MstCoopLayout creLayout = convertCommonService.getMstCoopLayoutBySub(facilityCd, direction, coopCd, coopCdIndex,
      coopVersion, coopCdSub);
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end
    // add 2021-12-06 #5888:NEC連携ができない(スタッフマスタ連携) 孫 end
    itemList = creLayout.getCoopSettingRoot().getItemList();
    LayoutExtSetting creLayoutExtSetting = creLayout.getCoopExtSetting();

    // 2パス目抽出
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    parseByLayout(facilityCd, direction, coopCd, coopCdIndex, coopCdSub, csvItemList, 0, itemList, creLayoutExtSetting, colResult,
//        keyResult);
    parseByLayout(facilityCd, direction, coopCd, coopCdIndex, coopVersion, coopCdSub, csvItemList, 0, itemList, creLayoutExtSetting, colResult,
        keyResult);
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

    return colResult;
  }

  /**
   * CSV 1行を項目に分割する。
   *
   * @param line CSV 1行の文字列
   * @param delimChar デリミタ文字
   */
  private List<String> getCSVItemList(String line, char delimChar) {
    Reader reader = new StringReader(line);

    try {
      CSVFormat format = CSVFormat.DEFAULT.withDelimiter(delimChar);
      CSVParser parser = format.parse(reader);
      CSVRecord record = parser.iterator().next();
      return itrToList(record.iterator());

    } catch (IOException e) {
      throw new NtssException("CSV電文から項目を切り出す処理でエラーが発生しました。", e);
    }
  }

  /**
   * レイアウトに沿って文字列を切り出す。<br/>
   * レイアウト項目でcol属性が指定されている場合は、切り出した値をJSON形式に出力する。
   *
   * @param facilityCd 施設コード
   * @param direction 向き（送受信）
   * @param coopCd 電文種別
   * @param coopCdIndex 付帯情報（電文）
   * @param coopVersion 連携版番号
   * @param coopCdSub 電文種別補足コード
   * @param csvItemList 変換対象電文をCSV分割した結果
   * @param telCharIndex 電文のうち、処理中の位置
   * @param itemList 変換レイアウト
   * @param extSetting 変換レイアウト補助
   * @param colResult col属性の抽出結果
   * @param keyResult key属性の抽出結果
   * @return 処理が完了した後の電文中の位置
   */
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  private int parseByLayout(String facilityCd, String direction, String coopCd, String coopCdIndex, String coopCdSub,
//  List<String> csvItemList,
  private int parseByLayout(String facilityCd, String direction, String coopCd, String coopCdIndex, String coopVersion,
      String coopCdSub, List<String> csvItemList,
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
      int telCharIndex, List<Item> itemList, LayoutExtSetting extSetting, ResultMap colResult, ResultMap keyResult) {

    EventLogMessage eventLogMessage = new EventLogMessage();
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    eventLogMessage.setLogMessage("[" + getClass().getSimpleName() + "]:convertSub:facility_cd:[" + facilityCd + "], direction:[" + direction + "],"
//        + " coop_cd:[" + coopCd + "], coop_cd_sub:[" + coopCdSub + "], telCharIndex:[" + telCharIndex + "]");
    eventLogMessage.setLogMessage("[" + getClass().getSimpleName() + "]:convertSub:facility_cd:[" + facilityCd + "], direction:[" + direction + "],"
      + " coop_cd:[" + coopCd + "], coop_version:[" + coopVersion + "], coop_cd_sub:[" + coopCdSub + "], telCharIndex:[" + telCharIndex + "]");
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
        eventLogMessage.setFacilityCd(facilityCd);
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    if (CollectionUtils.isEmpty(csvItemList) || CollectionUtils.isEmpty(itemList)) {
      return telCharIndex;
    }

    // レイアウト項目に沿って項目を取り出す。
    for (Item item : itemList) {

      String value = csvItemList.get(telCharIndex);
      ++telCharIndex;
      eventLogMessage.setLogMessage("抽出値=[" + value + "]");
      eventLogMessage.setFacilityCd(facilityCd);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // CSV電文の場合、occ要素は使用しないものとする。
      // （必要になった場合は過去リビジョンを基に再度検討する。）

      // key属性が指定されている場合（1パス目のみ）
      // マスタ照合を実施する。合致しない値の場合は変換エラーとする。
      String key = item.getKey();

      if (!StringUtils.isEmpty(key)) {
// mod 2021-12-06 #5888:NEC連携ができない(スタッフマスタ連携) 孫 start
//        if (extSetting != null) {
//
//          Map<String, Map<String, String>> m = ObjectMapperUtil.castToDualStringKeyMap(extSetting.get("key"));
//          Map<String, String> m2 = m.get(key);
//
//          String v = m2.get(value);
//          if (v == null) {
//            String errMsg = String.format("項目[%s]の値[%s]は、キー[%s]で指定された候補と一致しません。", item.getName(), value, key);
//            throw new NtssException(errMsg);
//          }
//          keyResult.putAppend(key, v);
//          eventLogMessage.setLogMessage("key属性値=[" + key + "], 置換値=[" + v + "]");
//          eventLogMessage.setFacilityCd(facilityCd);
//          // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
//          eventLogMessage.setInvokeClass(this.getClass().getName());
//          // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
//          logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//        } else {
//          String errMsg = String.format("キー[%s]が指定されていますが、対応する設定がcoop_ext_settingカラムに存在しません。", key);
//          throw new NtssException(errMsg);
//        }

        String v = layoutExtSettingUtil.lookupExtSetting(extSetting, key, value);
        keyResult.putAppend(key, v);
        eventLogMessage.setLogMessage("key属性値=[" + key + "], 置換値=[" + v + "]");
        eventLogMessage.setFacilityCd(facilityCd);
        eventLogMessage.setInvokeClass(this.getClass().getName());
        logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
// mod 2021-12-06 #5888:NEC連携ができない(スタッフマスタ連携) 孫 end
      }

      // value属性が指定されている場合
      // 切り出した項目と施設コードを引数として、値置換処理を呼ぶ。
      String valueReplace = item.getValue();

      if (!StringUtils.isEmpty(valueReplace)) {
        value = valueEvaluatorUtil.eval(value, valueReplace, facilityCd, extSetting, true);
      }

      // 整合性チェック
      ConvertValidator.validateCsv(value, csvItemList, telCharIndex, item);

      // col属性が指定されている場合
      // 属性値をキー、切り出した文字列を値とするkey-valueペアを出力する。
      // 複数の項目が同じcol属性値を持つ場合、同じキーに対する項目の配列として出力する。
      String col = item.getCol();
      eventLogMessage.setLogMessage("col属性値=[" + col + "]");
      eventLogMessage.setFacilityCd(facilityCd);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      if (!StringUtils.isEmpty(col)) {
        // append=trueが指定されている場合
        // 出現順に文字列結合する。
        if (item.getAppend()) {
          colResult.merge(col, value);
        } else {
          // append未指定ないしappend=falseの場合
          // リストとして結合する。
          colResult.putAppend(col, value);
        }
      }
    }

    // del 2021-12-06 #5888:NEC連携ができない(スタッフマスタ連携) 孫 start
    // Mapを返す(Listに変換しません)
//    ResultMap rm = JsonMapUtil.collectJsonMapByKey(colResult);
//    JsonMapUtil.makeListOnSingleMap(rm);
//    colResult.clear();
//    colResult.putAll(rm);
    // del 2021-12-06 #5888:NEC連携ができない(スタッフマスタ連携) 孫 end

    return telCharIndex;
  }

  /**
   * イテレータからリストを作成する。
   *
   * @param itr イテレータ
   * @return リスト
   */
  private <T> List<T> itrToList(Iterator<T> itr) {
    List<T> l = new ArrayList<>();
    while (itr.hasNext()) {
      l.add(itr.next());
    }
    return l;
  }

  /**
   * CSVの項目区切り文字を取得する。
   * 設定されていない場合はデフォルトはカンマ(,)とする。
   *
   * @param layoutExtSetting 拡張設定
   * @return CSVの項目区切り文字
   */
  private char getDelim(LayoutExtSetting layoutExtSetting) {
    String s = layoutExtSettingUtil.lookupExtSettingWithDefault(layoutExtSetting, KEY_DELIM, KEY_ITEM, KEY_CSV,
        CSV_DELIM_DEFAULT);
    return s.charAt(0);
  }
}
