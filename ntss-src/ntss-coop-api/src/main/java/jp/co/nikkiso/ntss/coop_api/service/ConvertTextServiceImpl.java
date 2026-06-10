package jp.co.nikkiso.ntss.coop_api.service;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.codec.binary.Hex;
import org.apache.commons.collections.MapUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import com.fasterxml.jackson.databind.SerializationFeature;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.response.JournalConvertResult.ResultMap;
import jp.co.nikkiso.ntss.coop_api.utils.CoopCdConstant;
import jp.co.nikkiso.ntss.coop_api.utils.DateUtil;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants;
import jp.co.nikkiso.ntss.coop_api.utils.JsonMapUtil;
import jp.co.nikkiso.ntss.coop_api.utils.Key0Constant;
import jp.co.nikkiso.ntss.coop_api.utils.LayoutExtSettingUtil;
import jp.co.nikkiso.ntss.coop_api.utils.ValueEvaluatorUtil;
import jp.co.nikkiso.ntss.coop_api.validator.ConvertValidator;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MstCoopIniDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopLayoutDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopLayoutDetailDao;
import jp.co.nikkiso.ntss.core.entity.MstCoopIniKey;
import jp.co.nikkiso.ntss.core.entity.MstCoopLayout;
import jp.co.nikkiso.ntss.core.entity.MstCoopLayoutDetail;
import jp.co.nikkiso.ntss.core.entity.detailCol;
import jp.co.nikkiso.ntss.core.entity.json.LayoutExtSetting;
import jp.co.nikkiso.ntss.core.entity.xml.Item;
import jp.co.nikkiso.ntss.core.entity.xml.Occ;
import jp.co.nikkiso.ntss.core.entity.xml.Root;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import lombok.AllArgsConstructor;
import lombok.Data;

import static jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants.AUX_CODE_ALL;
import static jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants.AUX_CODE_PRELOGIC;
import static jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants.KEY_SHORI_KUBUN;
import static jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants.TELEGRAM_ENCODING_BY_JIS;
import static jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants.TELEGRAM_ENCODING_BY_MS932;

/**
 * フォーマット済み固定長テキストをJSON形式に変換するサービスクラス。
 *
 * @see jp.co.nikkiso.ntss.coop_api.service.ConvertByFormatService
 */
@Service
public class ConvertTextServiceImpl implements ConvertByFormatService {

  @Autowired
  private MstCoopLayoutDao mstCoopLayoutDao;

  @Autowired
  private MstCoopLayoutDetailDao mstCoopLayoutDetailDao;
  @Autowired
  private MstCoopIniDao mstCoopIniDao;

  @Autowired
  private LogService logService;

  @Autowired
  private LayoutExtSettingUtil layoutExtSettingUtil;

  @Autowired
  private ValueEvaluatorUtil valueEvaluatorUtil;

  // mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
  @Autowired
  private ConvertCommonService convertCommonService;
  // mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end

  //  @Autowired
  //  private ValueEvaluatorUtil valueEvaluatorUtil;

  /**
   * レイアウトXMLでkey属性およびcol属性が指定された項目の値を取得する。
   *
   * @param facilityCd 施設コード
   * @param direction 向き（送受信）
   * @param coopCd 電文種別
   * @param coopCdIndex 付帯情報（電文）
   * @param coopVersion 連携版番号
   * @param key0 電子カルテ種別
   * @param coopCdSub 電文種別補足コード
   * @param telegram 電文
   * @param keyResult key属性収集結果
   * @return col属性収集結果
   * @throws UnsupportedEncodingException SJISエンコーディングが使用できない場合
   * @see ConvertByFormatService#convert(String, String, String, String, byte[], Root, LayoutExtSetting, ResultMap)
   */
  @Override
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  public ResultMap convert(String facilityCd, String direction, String coopCd, String coopCdIndex, String coopCdSub, byte[] telegram,
//                           ResultMap keyResult)
//    throws UnsupportedEncodingException,NtssException {
  public ResultMap convert(String facilityCd, String direction, String coopCd, String coopCdIndex, String coopVersion,
                           String key0, String coopCdSub, byte[] telegram, ResultMap keyResult)
    throws UnsupportedEncodingException,NtssException {
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    ResultMap colResult = new ResultMap();
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    parseTelegram(facilityCd, direction, coopCd, coopCdIndex, telegram, colResult, keyResult);
    parseTelegram(facilityCd, direction, coopCd, coopCdIndex, coopVersion, key0, telegram, colResult, keyResult);
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

    return colResult;
  }

  /**
   * 電文を解析し、レイアウト項目に対応する値を抽出する。
   *
   * @param facilityCd 施設コード
   * @param direction 向き（送受信）
   * @param coopCd 電文種別
   * @param coopCdIndex 付帯情報（電文）
   * @param coopVersion 連携版番号
   * @param key0 電子カルテ種別
   * @param telegram 電文
   * @param colResult col属性の抽出結果
   * @param keyResult key属性の抽出結果
   * @return 項目抽出後の、電文の処理中の位置
   * @throws UnsupportedEncodingException SJISエンコーティングが使用できない場合
   */
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  private int parseTelegram(String facilityCd, String direction, String coopCd, String coopCdIndex, byte[] telegram, ResultMap colResult,
//                            ResultMap keyResult)
//    throws UnsupportedEncodingException,NtssException {
  private int parseTelegram(String facilityCd, String direction, String coopCd, String coopCdIndex, String coopVersion,
                            String key0, byte[] telegram, ResultMap colResult, ResultMap keyResult)
    throws UnsupportedEncodingException,NtssException {
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    // 1パス目（電文種別補足コード=pre）
    // ・key属性を抽出してkeyResultに設定する。
    // ・電文ブロックの開始位置と電文種別補足コードの対応をblockMapに作成する。
    Map<Integer, String> blockMap = new HashMap<>();
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    int length=pass1(facilityCd, direction, coopCd, coopCdIndex, telegram, 0, keyResult, blockMap, null, null, null);
    int length=pass1(facilityCd, direction, coopCd, coopCdIndex, coopVersion, key0, telegram, 0, keyResult,
      blockMap, null, null, null);
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    // add 2021-06-09 #5325 電文長のチェックについて wangchen start
    // if(length!=telegram.length){
    //   throw new NtssException(String.format("電文の長さが不正,元の長さは%d,解析後の長さは%d",telegram.length,length));
    // }
    // add 2021-06-09 #5325 電文長のチェックについて wangchen end
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("★★blockMap=" + blockMap);
    eventLogMessage.setFacilityCd(facilityCd);
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    // 2パス目（電文種別補足コード=cre、電文抽出値（障害者加算等））
    // ・col属性を抽出してcolResultに設定する。
    //add 6981 掲示板・患者メモ・観察記録等への登録 ljg start
    List<detailCol> detailCols = new LinkedList<detailCol>();
    int setailColcode = 0;
    //add 6981 掲示板・患者メモ・観察記録等への登録 ljg end
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    int ret = pass2(facilityCd, direction, coopCd, coopCdIndex, telegram, 0, colResult, blockMap, null, null, null, -1, -1,detailCols,setailColcode);
    int ret = pass2(facilityCd, direction, coopCd, coopCdIndex, coopVersion, telegram, 0, colResult, blockMap,
      null, null, null, -1, -1,detailCols,setailColcode);
    // 電文長チェック
    if (ret != telegram.length) {
      throw new NtssException(String.format("電文の長さが不正,元の長さは%d,解析後の長さは%d", telegram.length, ret));
    }
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    // mod 2021-11-29 #5888:NEC連携ができない(初回指示連携) 孫 start
    // colResultデータにdetail項目がList以外の場合、Listにを再設定する
    ResultMap rm = collectJsonMapByKey(colResult);
    makeListOnSingleMap(rm);
    colResult.clear();
    colResult.putAll(rm);
    //add 6981 掲示板・患者メモ・観察記録等への登録 ljg start
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    List<MstCoopIniKey> mstCoopIniKey1 = mstCoopIniDao.selectCoopExtsettinginidial(facilityCd);
    List<MstCoopIniKey> mstCoopIniKey1 = mstCoopIniDao.selectCoopExtsettinginidial(facilityCd, key0);
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    for( int i = 0;i<detailCols.size(); i++ ) {
      if (detailCols.get(i).getKey2() == null || "".equals(detailCols.get(i).getKey2())
      ) {
        detailCols.remove(i);
      }
      if(detailCols.get(i).getKey1().equals("VDW")){
        String aa = String.format("%.2f",Float.valueOf(detailCols.get(i).getKey2()))+ " kg";
        detailCols.get(i).setKey2(aa) ;
      }
    }
    for( int i = 0;i<detailCols.size(); i++ ) {
      for(int j=0;j<mstCoopIniKey1.size();j++){
        if(detailCols.get(i).getKey1().equals(mstCoopIniKey1.get(j).getKey2())){
          detailCols.get(i).setKey1(mstCoopIniKey1.get(j).getKeyvalue());
        }
      }
    }
    String colResultvalue ="";
    for( int i = detailCols.size()-1;i>=0; i-- ) {
      colResultvalue =colResultvalue + "【" + detailCols.get(i).getKey1() + "】"+ detailCols.get(i).getKey2()+" ";
    }
    Set<String> keySet = colResult.keySet();
    Object value=null;
    for (String key : keySet) {
      if (key.startsWith("$journal.detail.")) {
        if (key.equals("$journal.detail.pat_main_3.pat_memo_info.content")) {
          value = colResultvalue;
        }else if (key.equals("$journal.detail.pat_main_3.pat_memo_info.title")) {
          value = "血液浄化申込情報 であること";
          //add 6981 掲示板・患者メモ・観察記録等への登録 ljg end
        }else{
           value = colResult.get(key);
        }
        if (!(value instanceof List)) {
          List<Object> listTmp = new ArrayList<>();
          listTmp.add(value);
          colResult.put(key, listTmp);
        }
      }
    }
    // mod 2021-11-29 #5888:NEC連携ができない(初回指示連携) 孫 end
    return ret;
  }

  /**
   * 電文種別補足コード=preで解析し、key属性を取得する。
   *
   * @param facilityCd 施設コード
   * @param direction 向き（送受信）
   * @param coopCd 電文種別
   * @param coopCdIndex 付帯情報（電文）
   * @param coopVersion 連携版番号
   * @param key0 電子カルテ種別
   * @param telegram 電文
   * @param telCharIndex 電文のうち、処理中の位置
   * @param keyResult key属性の抽出結果
   * @param blockMap 電文中の位置から処理区分を取得するためのマップ
   * @param detailName occ要素で指定されるレイアウト詳細名
   * @param itemList 親レイアウトのレイアウト項目リスト
   * @param layoutExtSetting 親レイアウトの拡張設定
   * @return 電文中の解析後の位置
   * @throws UnsupportedEncodingException SJISエンコーティングが使用できない場合
   */
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  int pass1(String facilityCd, String direction, String coopCd, String coopCdIndex, byte[] telegram, int telCharIndex,
//            ResultMap keyResult, Map<Integer, String> blockMap, String detailName,
//            List<Item> itemList, LayoutExtSetting layoutExtSetting)
//    throws UnsupportedEncodingException {
  int pass1(String facilityCd, String direction, String coopCd, String coopCdIndex, String coopVersion, String key0,
            byte[] telegram, int telCharIndex, ResultMap keyResult, Map<Integer, String> blockMap, String detailName,
            List<Item> itemList, LayoutExtSetting layoutExtSetting)
    throws UnsupportedEncodingException {
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    EventLogMessage eventLogMessage = new EventLogMessage();
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    eventLogMessage.setLogMessage("[" + getClass().getSimpleName() + "]#pass1: facility_cd:[" + facilityCd + "], "
//        + "direction:[" + direction + "], coop_cd:[" + coopCd + "], tel_char_index:[" + telCharIndex + "]");
    eventLogMessage.setLogMessage("[" + getClass().getSimpleName() + "]#pass1: facility_cd:[" + facilityCd + "], "
      + "direction:[" + direction + "], coop_cd:[" + coopCd + "], coop_version:[" + coopVersion
      + "], tel_char_index:[" + telCharIndex + "]");
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    eventLogMessage.setFacilityCd(facilityCd);
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    int startIndex = telCharIndex;

    // 再帰でdetail属性が指定された場合 or トップレベルレイアウトの場合はレイアウトを取得する。
    // （再帰でdetail属性が指定されていない場合（occ直下にitem）は、渡されたレイアウトを使用する。）
    if (detailName != null || itemList == null) {
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//      TelegramLayout l = getLayout(facilityCd, direction, coopCd, coopCdIndex, AUX_CODE_PRELOGIC, detailName);
      TelegramLayout l = getLayout(facilityCd, direction, coopCd, coopCdIndex, coopVersion, AUX_CODE_PRELOGIC, detailName);
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
      itemList = l.getRoot().getItemList();
      layoutExtSetting = l.getLayoutExtSetting();
      //add 7282 項目属性の場合 連携設定 PROFILE_RECEIVE_COOPEXTSETING CoopExtsetting  取得 ljg start
      String layoutRootname = l.getRoot().getName();
      if((direction != null && coopCd != null && detailName != null && layoutRootname != null ) && direction.equals("R") && coopCd.equals("profile")
      && detailName.equals("患者プロファイル詳細") && layoutRootname.equals("患者プロファイル詳細(pre)")
      ){
        if(((LinkedHashMap)((LinkedHashMap) ((LinkedHashMap) layoutExtSetting.get("key")).get("項目属性"))).get("all")!=null &&
          ((LinkedHashMap)((LinkedHashMap) ((LinkedHashMap) layoutExtSetting.get("key")).get("項目属性"))).get("all").equals("項目属性詳細")){
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//          List<MstCoopIniKey> mstCoopIniKey = mstCoopIniDao.selectCoopExtsetting(facilityCd);
          List<MstCoopIniKey> mstCoopIniKey = mstCoopIniDao.selectCoopExtsetting(facilityCd, key0);
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
          ((LinkedHashMap) ((LinkedHashMap) layoutExtSetting.get("key")).get("項目属性")).clear();
          for (int i = 0; i < mstCoopIniKey.size(); i++) {
            ((LinkedHashMap) ((LinkedHashMap) layoutExtSetting.get("key")).get("項目属性")).put(mstCoopIniKey.get(i).getKey2(), mstCoopIniKey.get(i).getKeyvalue());
          }
        }
      }
      //add 7282 項目属性の場合 連携設定 PROFILE_RECEIVE_COOPEXTSETING CoopExtsetting  取得 ljg end
      //add 6981 連携設定（GX ORDER_RECV_TAKING_TITLE 受信した属性コードと一致 ljg start
      if((direction != null && coopCd != null && detailName != null && layoutRootname != null
        && layoutExtSetting.size()!=0) && direction.equals("R") && coopCd.equals("ini_dial")
        && detailName.equals("ini_dial_meisai") && layoutRootname.equals("透析申込詳細(pre)")
      ){
        if(((LinkedHashMap)((LinkedHashMap) ((LinkedHashMap) layoutExtSetting.get("key")).get("項目属性"))).get("all")!=null &&
          ((LinkedHashMap)((LinkedHashMap) ((LinkedHashMap) layoutExtSetting.get("key")).get("項目属性"))).get("all").equals("ini_dial詳細")){
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//          List<MstCoopIniKey> mstCoopIniKey1 = mstCoopIniDao.selectCoopExtsettinginidial(facilityCd);
          List<MstCoopIniKey> mstCoopIniKey1 = mstCoopIniDao.selectCoopExtsettinginidial(facilityCd, key0);
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
          ((LinkedHashMap) ((LinkedHashMap) layoutExtSetting.get("key")).get("項目属性")).clear();
          for (int i = 0; i < mstCoopIniKey1.size(); i++) {
            ((LinkedHashMap) ((LinkedHashMap) layoutExtSetting.get("key")).get("項目属性")).put(mstCoopIniKey1.get(i).getKey2(), mstCoopIniKey1.get(i).getKeyvalue());
          }
        }
      }
      //add 6981 連携設定（GX ORDER_RECV_TAKING_TITLE 受信した属性コードと一致 ljg end
      }
    int dataLength = 0;
    for (Item item : itemList) {
      int len = item.getLen();
      // データ長使用項目は直前に設定されたデータ長を使用する
      if(dataLength != 0 && item.getDataLengthUse() != null){
    	  len = dataLength;
      }
      eventLogMessage.setLogMessage("pass1:切出し中の位置=[" + telCharIndex + "], 項目の長さ=[" + len + "]");
      eventLogMessage.setFacilityCd(facilityCd);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      String value = null;
      if (len > 0) {
// add 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
        if(telegram != null && telegram.length < (telCharIndex + len)) {
          String errMsg = String.format("電文の長さが不正。電文の長さは[%d]、レイアウトより解析中エラー発生位置[%d]～[%d]。",
            telegram.length, telCharIndex, (telCharIndex + len));
          eventLogMessage.setLogMessage(errMsg);
          eventLogMessage.setFacilityCd(facilityCd);
          eventLogMessage.setInvokeClass(this.getClass().getName());
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          throw new NtssException(errMsg);
        }
// add 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end
        //mod 7713 富士通指摘：PC上で使用している文字で判読不能になるものがある。張 start
//        value = new String(Arrays.copyOfRange(telegram, telCharIndex, telCharIndex + len), TELEGRAM_ENCODING_BY_SJIS)

//        value = new String(Arrays.copyOfRange(telegram, telCharIndex, telCharIndex + len), TELEGRAM_ENCODING_BY_MS932)
//        //mod 7713 富士通指摘：PC上で使用している文字で判読不能になるものがある。張 end
//            .trim();

        // JISか？
        boolean isJis = false;
        //Medicom連携 送信/受信のうち受信 連携種別がprofile
        if(Key0Constant.MED.contains(key0) && "R".equals(direction)
            && CoopCdConstant.PROFILE.contains(coopCd) && len >= 4) {
          byte[] valueBytes = Arrays.copyOfRange(telegram, telCharIndex, telCharIndex + 2);
          // 先頭2バイトが1badの場合JISコード変換
          if("1bad".equals(new String(Hex.encodeHex(valueBytes)))){
            isJis = true;
          }
        }

        if(isJis) {
          //先頭2バイトの1badと末尾2バイトの1baeを除去
          value = new String(Arrays.copyOfRange(telegram, telCharIndex +2, telCharIndex + len -2), TELEGRAM_ENCODING_BY_JIS).trim();
        }else {
          value = new String(Arrays.copyOfRange(telegram, telCharIndex, telCharIndex + len), TELEGRAM_ENCODING_BY_MS932).trim();
        }
        telCharIndex += len;

        // データ長項目の場合データ長を設定する
        if(item.getDataLength() != null){
        	dataLength = Integer.parseInt(value);
        }
      }
      // add 2021-02-09 電文確認：受信->pre->(len="0",key有り,value="const:xxx")場合、valueの取得。 孫 start
      else {
        // <item  name="振分用" len="0" key="all" type="string" value="const:all"/>から、valueを取得する
        String valueReplace = item.getValue();
// mod 2021-12-03 #5888:NEC連携ができない(処方情報連携) 孫 start
//        if (!StringUtils.isEmpty(valueReplace)) {
        // サブ詳細データの場合、特殊値を置換しません。
        // ※サブ詳細データ：変換レイアウトの項目に特殊値指定項目(value)の内容がレコード番号「%%record_no%%」と上位レコード番号「%%upper_record_no%%」です。
        if (!StringUtils.isEmpty(valueReplace) && !JournalConvertConstants.RECORD_NO.equals(valueReplace)
          && !JournalConvertConstants.UPPER_RECORD_NO.equals(valueReplace)) {
// mod 2021-12-03 #5888:NEC連携ができない(処方情報連携) 孫 end
          value = evalReplace(facilityCd, value, valueReplace, layoutExtSetting);
        }
      }
      // add 2021-02-09 電文確認：受信->pre->(len="0",key有り,value="const:xxx")場合、valueの取得。 孫 end

      // occ要素の場合は再帰的に処理する。
      if (item.isOcc()) {
        eventLogMessage.setLogMessage("pass1:==繰返し開始");
        eventLogMessage.setFacilityCd(facilityCd);
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
        eventLogMessage.setInvokeClass(this.getClass().getName());
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
        logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        Occ occ = (Occ) item;

        // 繰り返し回数を取得する。
        int repCount = getRepetitionCount(value, occ);
        eventLogMessage.setLogMessage("pass1:繰返し要素(occ), 繰返し回数=[" + repCount + "]");
        eventLogMessage.setFacilityCd(facilityCd);
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
        eventLogMessage.setInvokeClass(this.getClass().getName());
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
        logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

        // 再帰的に切り出す。
        for (int i = 0; i < repCount; ++i) {
          // keyResultを渡すと上位レイアウトのshori_kbnキーを上書きしてしまう。
          // 別のオブジェクトを渡して収集し、blockMapに登録する。
          // （keyResultで返すのは最上位レイアウトのshori_kbnのみとする。）
          ResultMap kr = new ResultMap();
          int blockStartIndex = telCharIndex;
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//          telCharIndex = pass1(facilityCd, direction, coopCd, coopCdIndex, telegram, telCharIndex, kr, blockMap,
//            occ.getDetail(), occ.getItemList(), layoutExtSetting);
          telCharIndex = pass1(facilityCd, direction, coopCd, coopCdIndex, coopVersion, key0, telegram, telCharIndex,
            kr, blockMap, occ.getDetail(), occ.getItemList(), layoutExtSetting);
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

          String shoriKbn = (String) kr.get(KEY_SHORI_KUBUN);
          if (!StringUtils.isEmpty(shoriKbn)) {
            blockMap.put(blockStartIndex, shoriKbn);
          }

          // shori_kbn以外のキー属性はkeyResultに集約する。
          kr.remove(KEY_SHORI_KUBUN);
          keyResult.putAll(kr);
        }

        eventLogMessage.setLogMessage("pass1:==繰返し終了");
        eventLogMessage.setFacilityCd(facilityCd);
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
        eventLogMessage.setInvokeClass(this.getClass().getName());
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
        logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        continue;
      }

      // key属性が指定されている場合
      // マスタ照合を実施する。合致しない値の場合は変換エラーとする。
      String key = item.getKey();

      if (keyResult != null && !StringUtils.isEmpty(key)) {
        eventLogMessage.setLogMessage("pass1:value=[" + value + "]");
        eventLogMessage.setFacilityCd(facilityCd);
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
        eventLogMessage.setInvokeClass(this.getClass().getName());
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
        logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        //add 7279 detail取得   ljg start
        String v = "";
         if (itemList!=null && itemList.size()==10 && coopCd !=null && coopCd.equals("ini_dial")
          && detailName!= null && detailName.equals("ini_dial_meisai")){
          v=value;
        }else {
           v = layoutExtSettingUtil.lookupExtSetting(layoutExtSetting, key, value);
        }
        //add 7279 detail取得   ljg end
        keyResult.putAppend(key, v);
        eventLogMessage.setLogMessage("pass1:key=[" + key + "] => v=[" + v + "]");
        eventLogMessage.setFacilityCd(facilityCd);
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
        eventLogMessage.setInvokeClass(this.getClass().getName());
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
        logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

        eventLogMessage.setLogMessage("pass1:keyResult=[" + keyResult + "]");
        eventLogMessage.setFacilityCd(facilityCd);
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
        eventLogMessage.setInvokeClass(this.getClass().getName());
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
        logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

        // add 2021-02-10 電文確認：key属性が指定されている場合、keyResultにKEY_SHORI_KUBUNを追加する。 孫 start
        // [keyResult key属性の抽出結果]にデータを追加する
        if (!KEY_SHORI_KUBUN.equals(key)) {
          keyResult.putAppend(KEY_SHORI_KUBUN, v);
        }
        // add 2021-02-10 電文確認：key属性が指定されている場合、keyResultにKEY_SHORI_KUBUNを追加する。 孫 end
      }
    }

    String shoriKbn = (String) keyResult.get(KEY_SHORI_KUBUN);
    eventLogMessage.setLogMessage("処理区分=" + shoriKbn);
    eventLogMessage.setFacilityCd(facilityCd);
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    blockMap.put(startIndex, shoriKbn);

    return telCharIndex;
  }

  /**
   * 電文種別補足コード!=preで解析し、col属性を取得する。
   *
   * @param facilityCd 施設コード
   * @param direction 向き（送受信）
   * @param coopCd 電文種別
   * @param coopCdIndex 付帯情報（電文）
   * @param coopVersion 連携版番号
   * @param telegram 電文
   * @param telCharIndex 電文のうち、処理中の位置
   * @param colResult col属性の抽出結果
   * @param blockMap 電文中の位置から処理区分を取得するためのマップ
   * @param detailName occ要素で指定されるレイアウト詳細名
   * @param itemList 親レイアウトのレイアウト項目リスト
   * @param layoutExtSetting 親レイアウトの拡張設定
   * @param upperRecordNo 上位レコード番号
   * @param recordNo レコード番号
   * @return 電文中の解析後の位置
   * @throws UnsupportedEncodingException SJISエンコーティングが使用できない場合
   */
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  int pass2(String facilityCd, String direction, String coopCd, String coopCdIndex, byte[] telegram, int telCharIndex,
//            ResultMap colResult, Map<Integer, String> blockMap, String detailName, List<Item> itemList,
//            LayoutExtSetting layoutExtSetting, int upperRecordNo, int recordNo,List<detailCol> detailCols,int setailColcode)
//    throws UnsupportedEncodingException {
  int pass2(String facilityCd, String direction, String coopCd, String coopCdIndex, String coopVersion, byte[] telegram,
            int telCharIndex, ResultMap colResult, Map<Integer, String> blockMap, String detailName, List<Item> itemList,
            LayoutExtSetting layoutExtSetting, int upperRecordNo, int recordNo,List<detailCol> detailCols,int setailColcode)
    throws UnsupportedEncodingException {
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    // 解析中の位置に対する電文種別補足コードを取得する。
    // （pass1で計算済み）
    String coopCdSub = blockMap.get(telCharIndex);

    EventLogMessage eventLogMessage = new EventLogMessage();
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    eventLogMessage.setLogMessage("[" + getClass().getSimpleName() + "]#pass2: facility_cd:[" + facilityCd + "], "
//        + "direction:[" + direction + "], coop_cd:[" + coopCd + "], coop_cd_sub:[" + coopCdSub + "], tel_char_index:[" + telCharIndex + "]");
    eventLogMessage.setLogMessage("[" + getClass().getSimpleName() + "]#pass2: facility_cd:[" + facilityCd + "], "
      + "direction:[" + direction + "], coop_cd:[" + coopCd + "], coop_version:[" + coopVersion + "], coop_cd_sub:[" + coopCdSub
      + "], tel_char_index:[" + telCharIndex + "]");
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    eventLogMessage.setFacilityCd(facilityCd);
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    if (detailName != null || itemList == null) {
      //update 7279 detail取得   ljg start
      TelegramLayout l = null;
      if(detailName != null && "ini_dial_meisai".equals(detailName) && coopCd !=null && "ini_dial".equals(coopCd)
        && coopCdSub != null && !("pre".equals(coopCdSub))
      ){
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////        MstCoopLayoutDetail mstCoopLayoutDetail = mstCoopLayoutDetailDao.selectWithPrecopy(facilityCd, coopCd,direction, detailName,coopCdSub);
//        MstCoopLayoutDetail mstCoopLayoutDetail = mstCoopLayoutDetailDao.selectWithPrecopy(facilityCd, coopCd,
//          coopVersion, direction, detailName, coopCdSub);
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
        List<MstCoopLayoutDetail> mstCoopLayoutDetailList = mstCoopLayoutDetailDao.selectWithPrecopy(facilityCd, coopCd,
          coopVersion, direction, detailName, coopCdSub);
        if (mstCoopLayoutDetailList == null || mstCoopLayoutDetailList.size() == 0) {
          String errMsg = String.format("対象レイアウト詳細ファイルが存在しません。施設コード:[%s], 連携版番号:[%s], 送受信向き:[%s], 電文種別:[%s], 電文種別詳細コード:[%s], 拡張設定->keys:[%s]",
            facilityCd, coopVersion, direction, coopCd, detailName, coopCdSub);
          eventLogMessage.setLogMessage(errMsg);
          eventLogMessage.setFacilityCd(facilityCd);
          eventLogMessage.setInvokeClass(this.getClass().getName());
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          throw new NtssException(errMsg);
        } else if (mstCoopLayoutDetailList.size() > 1) {
          String errMsg = String.format("対象レイアウト詳細ファイルが複数存在します。施設コード:[%s], 連携版番号:[%s], 送受信向き:[%s], 電文種別:[%s], 電文種別詳細コード:[%s],拡張設定->keys:[%s]",
            facilityCd, coopVersion, direction, coopCd, detailName, coopCdSub);
          eventLogMessage.setLogMessage(errMsg);
          eventLogMessage.setFacilityCd(facilityCd);
          eventLogMessage.setInvokeClass(this.getClass().getName());
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          throw new NtssException(errMsg);
        }
        MstCoopLayoutDetail mstCoopLayoutDetail = mstCoopLayoutDetailList.get(0);
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end
         if(mstCoopLayoutDetail !=null){
           l= new TelegramLayout(mstCoopLayoutDetail.getCoopSettingRoot(), mstCoopLayoutDetail.getCoopExtSetting());
         }
      }else{
        //古いバージョンです
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//        l = getLayout(facilityCd, direction, coopCd, coopCdIndex, coopCdSub, detailName);
        l = getLayout(facilityCd, direction, coopCd, coopCdIndex, coopVersion, coopCdSub, detailName);
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
      }
      //update 7279 detail取得   ljg end
      itemList = l.getRoot().getItemList();
      layoutExtSetting = l.getLayoutExtSetting();
    }
    int dataLength = 0;
    for (Item item : itemList) {
      int len = item.getLen();
      // データ長使用項目は直前に設定されたデータ長を使用する
      if(dataLength != 0 && item.getDataLengthUse() != null){
    	  len = dataLength;
      }
      eventLogMessage.setLogMessage("pass2:切出し中の位置=[" + telCharIndex + "], 項目の長さ=[" + len + "]");
      eventLogMessage.setFacilityCd(facilityCd);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      String value = null;
      if (len > 0) {
        // mod 2021-09-28 #5779:半バイト制御がない 孫 start
//        value = new String(Arrays.copyOfRange(telegram, telCharIndex, telCharIndex + len), TELEGRAM_ENCODING_BY_SJIS)
//            .trim();
// add 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
        if(telegram != null && telegram.length < (telCharIndex + len)) {
          String errMsg = String.format("電文の長さが不正。電文の長さは[%d]、レイアウトより解析中エラー発生位置[%d]～[%d]。",
            telegram.length, telCharIndex, (telCharIndex + len));
          eventLogMessage.setLogMessage(errMsg);
          eventLogMessage.setFacilityCd(facilityCd);
          eventLogMessage.setInvokeClass(this.getClass().getName());
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          throw new NtssException(errMsg);
        }
// add 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end
        // 文字列末尾の半バイトを切り捨する
        byte[] valueByte = Arrays.copyOfRange(telegram, telCharIndex, telCharIndex + len);
        byte[] valueCuted = Arrays.copyOfRange(valueByte, 0, valueByte.length);
        if (valueByte != null && valueByte.length > 1) {
          // byte->int
          int endBytes = valueByte[valueByte.length-1] & 0xff;
          int endBytes2 = valueByte[valueByte.length-2] & 0xff;
          // 半バイトが全角文字の上位8ビット？
          // 0x81～0x9f -> 129～1599 と 0xe0～0xef -> 224～239
          if ((endBytes >= 129 && endBytes <= 159) || (endBytes >= 224 && endBytes <= 239)) {
            //最後から2番目は、全角でない場合
            if (!(endBytes2 >= 129 && endBytes2 <= 159) && !(endBytes2 >= 224 && endBytes2 <= 239)) {
              valueCuted = Arrays.copyOfRange(valueByte, 0, valueByte.length-1);
            }
          }
        }
        //mod 7713 富士通指摘：PC上で使用している文字で判読不能になるものがある。張 start
//        value = new String(valueCuted, TELEGRAM_ENCODING_BY_SJIS).trim();
        // JISか？
        boolean isJis = false;
        //送信/受信のうち受信 連携種別がprofile
        if("R".equals(direction)
            && CoopCdConstant.PROFILE.contains(coopCd) && len >= 4) {
          byte[] valueBytes = Arrays.copyOfRange(telegram, telCharIndex, telCharIndex + 2);
          // 先頭2バイトが1badの場合JISコード変換
          if("1bad".equals(new String(Hex.encodeHex(valueBytes)))){
            isJis = true;
          }
        }

        if(isJis) {
          //先頭2バイトの1badと末尾2バイトの1baeを除去
          value = new String(Arrays.copyOfRange(valueCuted, 2, len -2), TELEGRAM_ENCODING_BY_JIS).trim();
        } else {
          value = new String(valueCuted, TELEGRAM_ENCODING_BY_MS932).trim();
        }
        //mod 7713 富士通指摘：PC上で使用している文字で判読不能になるものがある。張 end
        // mod 2021-09-28 #5779:半バイト制御がない 孫 end
      	value = value.replaceAll(JournalConvertConstants.FORBIDDEN_CHAR, "");
        value = formatValue(item, value);
        //add 6981 掲示板・患者メモ・観察記録等への登録 ljg start
        if(detailName != null && "ini_dial_meisai".equals(detailName) && coopCd !=null && "ini_dial".equals(coopCd)
                && coopCdSub != null && !("pre".equals(coopCdSub)) && !coopCdSub.equals("正常") && ((len == 50 &&
                !"VDW".equals(coopCdSub))
        || (len == 11 && "VDW".equals(coopCdSub) && item.getName()!=null && "明細.数量".equals(item.getName()))
        )){
          detailCol detailColcopy =new detailCol();
          int code = 0;
          for( int i =0;i<detailCols.size();i++){
            if(coopCdSub.equals(detailCols.get(i).getKey1())
             && (value != null && ! "" .equals(value))
            ){
              detailColcopy.setKey1(detailCols.get(i).getKey1());
              if("VA7".equals(coopCdSub)){
                detailColcopy.setKey2(detailCols.get(i).getKey2() + "~" + value);
              }else{
                detailColcopy.setKey2(detailCols.get(i).getKey2() + " " + value);
              }
              detailCols.set(i, detailColcopy);
              code =1;
            }
          }

          if(code == 0) {
            detailColcopy.setKey1(coopCdSub);
            detailColcopy.setKey2(value);
            detailCols.add(setailColcode, detailColcopy);
            setailColcode += 1;
          }
        }
        //add 6981 掲示板・患者メモ・観察記録等への登録 ljg end
        telCharIndex += len;

        // データ長項目の場合データ長を設定する
        if(item.getDataLength() != null){
        	dataLength = Integer.parseInt(value);
        }
      }
      // mod 2021-02-09 電文確認：受信->pre->(len="0",key有り,value="const:xxx")場合、valueの取得。 孫 start
      else {
        // <item  name="振分用" len="0" key="all" type="string" value="const:all"/>から、valueを取得する
        String valueReplace = item.getValue();
        if (!StringUtils.isEmpty(valueReplace)) {
// mod 2021-12-03 #5888:NEC連携ができない(処方情報連携) 孫 start
//          value = evalReplace(facilityCd, value, valueReplace, layoutExtSetting);
          if (JournalConvertConstants.RECORD_NO.equals(valueReplace)) {
            // 特殊値指定項目(value)の内容がレコード番号「%%record_no%%」の場合、レコード番号を取得する
            value = String.valueOf(recordNo);
          } else if (JournalConvertConstants.UPPER_RECORD_NO.equals(valueReplace)) {
            // 特殊値指定項目(value)の内容が上位レコード番号「%%upper_record_no%%」の場合、上位レコード番号を取得する
            value = String.valueOf(upperRecordNo);
          } else {
            value = evalReplace(facilityCd, value, valueReplace, layoutExtSetting);
          }
// mod 2021-12-03 #5888:NEC連携ができない(処方情報連携) 孫 end
        }
      }
      // add 2021-02-09 電文確認：受信->pre->(len="0",key有り,value="const:xxx")場合、valueの取得。 孫 end

      // occ要素の場合は再帰的に処理する。
      if (item.isOcc()) {
        eventLogMessage.setLogMessage("pass2:==繰返し開始");
        eventLogMessage.setFacilityCd(facilityCd);
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
        eventLogMessage.setInvokeClass(this.getClass().getName());
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
        logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        Occ occ = (Occ) item;

        // 繰り返し回数を取得する。
        int repCount = getRepetitionCount(value, occ);
        eventLogMessage.setLogMessage("pass2:繰返し要素(occ), 繰返し回数=[" + repCount + "]");
        eventLogMessage.setFacilityCd(facilityCd);
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
        eventLogMessage.setInvokeClass(this.getClass().getName());
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
        logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

        // add 2021-11-30 #5888:NEC連携ができない(検査結果) 孫 start
        // occ要素の場合、col属性が指定されている場合、詳細数を取得する。
        String colOcc = item.getCol();
        colOcc = JsonMapUtil.normalizeKey(colOcc);
        if (!StringUtils.isEmpty(colOcc)) {
          colResult.putAppend(colOcc, String.valueOf(repCount));
        }
        // add 2021-11-30 #5888:NEC連携ができない(検査結果) 孫 end

        // 再帰的に切り出す。
        for (int i = 0; i < repCount; ++i) {
          ResultMap cr = new ResultMap();
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//          telCharIndex = pass2(facilityCd, direction, coopCd, coopCdIndex, telegram, telCharIndex, cr, blockMap,
//            occ.getDetail(), occ.getItemList(), layoutExtSetting, recordNo, (i+1),detailCols,setailColcode);
          telCharIndex = pass2(facilityCd, direction, coopCd, coopCdIndex, coopVersion, telegram, telCharIndex, cr,
            blockMap, occ.getDetail(), occ.getItemList(), layoutExtSetting, recordNo, (i+1),detailCols,setailColcode);
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

          // キーがカラム下のJSONキーの場合、カラム単位キー別にマップ構造にまとめる。
          ResultMap rr = collectJsonMapByKey(cr);
          colResult.putAppendAll(rr);

          try {
            ObjectMapperUtil.getObjectMapper().enable(SerializationFeature.INDENT_OUTPUT);
            eventLogMessage.setLogMessage(facilityCd + ":collectJsonMapByKey before=" + ObjectMapperUtil.write(cr));
            eventLogMessage.setFacilityCd(facilityCd);
            // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
            eventLogMessage.setInvokeClass(this.getClass().getName());
            // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
            logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

            eventLogMessage.setLogMessage(facilityCd + ":collectJsonMapByKey after =" + ObjectMapperUtil.write(rr));
            eventLogMessage.setFacilityCd(facilityCd);
            // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
            eventLogMessage.setInvokeClass(this.getClass().getName());
            // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
            logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          } catch (IOException e) {
          } finally {
            ObjectMapperUtil.getObjectMapper().disable(SerializationFeature.INDENT_OUTPUT);
          }
        }

        eventLogMessage.setLogMessage("pass2:==繰返し終了");
        eventLogMessage.setFacilityCd(facilityCd);
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
        eventLogMessage.setInvokeClass(this.getClass().getName());
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
        logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        continue;
      }

      // value属性が指定されている場合
      // 切り出した項目と施設コードを引数として、値置換処理を呼ぶ。
      String valueReplace = item.getValue();
      eventLogMessage.setLogMessage("レイアウト項目:[" + item.getName() + "], 抽出値:[" + value + "], col指定:[" + item.getCol() + "], 置換値:[" + valueReplace + "]");
      eventLogMessage.setFacilityCd(facilityCd);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      if (!StringUtils.isEmpty(valueReplace)) {
// mod 2021-12-03 #5888:NEC連携ができない(処方情報連携) 孫 start
//        value = evalReplace(facilityCd, value, valueReplace, layoutExtSetting);
        if (JournalConvertConstants.RECORD_NO.equals(valueReplace)) {
          // 特殊値指定項目(value)の内容がレコード番号「%%record_no%%」の場合、レコード番号を取得する
          value = String.valueOf(recordNo);
        } else if (JournalConvertConstants.UPPER_RECORD_NO.equals(valueReplace)) {
          // 特殊値指定項目(value)の内容が上位レコード番号「%%upper_record_no%%」の場合、上位レコード番号を取得する
          value = String.valueOf(upperRecordNo);
        } else {
          value = evalReplace(facilityCd, value, valueReplace, layoutExtSetting);
        }
// mod 2021-12-03 #5888:NEC連携ができない(処方情報連携) 孫 end
      }

      // 整合性チェック
      //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      //ConvertValidator.validateText(value, telegram, telCharIndex, item);
      ConvertValidator.validateText(value, telegram, telCharIndex, item, logService);
      //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end

      // col属性が指定されている場合
      // 属性値をキー、切り出した文字列を値とするkey-valueペアを出力する。
      // 複数の項目が同じcol属性値を持つ場合、同じキーに対する項目の配列として出力する。
      String col = item.getCol();
      col = JsonMapUtil.normalizeKey(col);

      if (!StringUtils.isEmpty(col)) {
        // appendフラグ=onの場合は文字列結合
        if (item.getAppend()) {
          colResult.merge(col, value);
        } else {
          // offの場合はリスト結合
          colResult.putAppend(col, value);
        }
      }
    }

    return telCharIndex;
  }

  // collectJsonMapByKeyInOcc()とnormalizeKey()は、かなり似た処理を実行している。
  // 本質はnormalizeKey()だが、normalizeKey()だけではocc要素下のitem要素が同じcol属性を持つ場合、1段上にマップを
  // 設けてリスト化するのは不可能である。
  // そのため現状の処理となっている。

  /**
   * 抽出したデータをカラム単位でまとめる。
   * （{table1.column1.key1=abcde, table1.column1.key2=あいう} -> table.column1={key1=abcde, key2=あいう}
   *
   * @param rm 抽出したデータ
   * @return カラム単位でまとめたマップ
   */
  private ResultMap collectJsonMapByKey(ResultMap rm) {
    if (MapUtils.isEmpty(rm)) {
      return rm;
    }

    Set<String> keySet = rm.keySet();
    ResultMap collected = new ResultMap();

    for (String key : keySet) {
      // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 start
      if (key.startsWith("$journal.")) {
        Object value = rm.get(key);
        // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 end
        String[] keyArr = key.split("\\.");
        // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 start
        int len = 0;
        int kbn = 0;
        if ("detail".equals(keyArr[1])) {
          len = keyArr.length - 2;
        } else {
          len = keyArr.length - 1;
        }
        // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 end
        // mod 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 start
        //switch (keyArr.length) {
        switch (len) {
          // mod 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 end
          case 1:
            // mod 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 start
            //add1(collected, key, rm.get(key));
            add1(collected, key, value);
            // mod 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 end
            break;

          case 2:
            // mod 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 start
            //add2(collected, key, rm.get(key));
            add2(collected, key, value);
            // mod 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 end
            break;

          case 3:
            // mod 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 start
            //String keyColumn = String.join(".", keyArr[0], keyArr[1]);
            //add3(collected, keyColumn, keyArr[2], rm.get(key));
            add2(collected, key, value);
            // mod 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 end
            break;

          // add 2021-01-19 No.739:新規マスタを含むオーダ受信時に該当するマスタを新規登録する機能の実装 商 start
          case 4:
            // mod 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 start
            //String keyColumns = String.join(".", keyArr[0], keyArr[1z], keyArr[2]);
            //add4(collected, keyColumns, keyArr[3], rm.get(key));
            add2(collected, key, value);
            // mod 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 end
            break;
          // add 2021-01-19 No.739:新規マスタを含むオーダ受信時に該当するマスタを新規登録する機能の実装 商 end

          default:
            break;
        }
      }
    }

    return collected;
  }

  /**
   * キーがテーブル名のみの場合の処理。
   *
   * @param rm 電文データ
   * @param key キー
   * @param obj キーに対応する値
   */
  private void add1(ResultMap rm, String key, Object obj) {
    Object target = rm.get(key);
    if (target == null) {
      rm.put(key, obj);
    }
  }

  /**
   * キーが「テーブル名.カラム名」の場合の処理。
   *
   * @param rm 電文データ
   * @param key キー
   * @param obj キーに対応する値
   */
  private void add2(ResultMap rm, String key, Object obj) {
    Object target = rm.get(key);
    if (target == null) {
      rm.put(key, obj);
      return;
    }

    if (target instanceof Map) {
      Map<String, Object> t = ObjectMapperUtil.castToStringObjectMap(target);
      rm.put(key, t);

      if (obj instanceof Map) {
        Map<String, Object> m = ObjectMapperUtil.castToStringObjectMap(obj);
        t.putAll(m);
      }

      return;
    }

    if (target instanceof List) {
      List<Object> t = ObjectMapperUtil.castToObjectList(target);
      rm.put(key, t);
      t.add(obj);
    }
  }

  /**
   * キーが「テーブル名.カラム名.JSONキー名」の場合の処理。
   *
   * @param rm 電文データ
   * @param key12 キーのうち「テーブル名.カラム名」の部分
   * @param key3 キーのうち「JSONキー名」の部分
   * @param obj キーに対応する値
   */
  private void add3(ResultMap rm, String key12, String key3, Object obj) {
    Object target = rm.get(key12);
    if (target == null) {
      Map<String, Object> m = new HashMap<>();
      rm.put(key12, m);
      m.put(key3, obj);
      return;
    }

    if (target instanceof Map) {
      Map<String, Object> m = ObjectMapperUtil.castToStringObjectMap(target);
      rm.put(key12, m);

      if (obj instanceof Map) {
        Map<String, Object> m2 = ObjectMapperUtil.castToStringObjectMap(obj);
        m.putAll(m2);
        return;
      }

      m.put(key3, obj);
      return;
    }

    if (target instanceof List) {
      List<Object> t = ObjectMapperUtil.castToObjectList(target);
      rm.put(key12, t);

      if (obj instanceof List) {
        List<Object> o = ObjectMapperUtil.castToObjectList(obj);
        t.addAll(o);
        return;
      }

      Map<String, Object> m = new HashMap<>();
      t.add(m);
      m.put(key3, obj);
    }
  }

  // add 2021-01-19 No.739:新規マスタを含むオーダ受信時に該当するマスタを新規登録する機能の実装 商 start
  /**
   * キーが「テーブル名.カラム名.JSONキー名」の場合の処理。
   *
   * @param rm 電文データ
   * @param key123 キーのうち「テーブル名.カラム名」の部分
   * @param key4 キーのうち「JSONキー名」の部分
   * @param obj キーに対応する値
   */
  private void add4(ResultMap rm, String key123, String key4, Object obj) {
    Object target = rm.get(key123);
    if (target == null) {
      Map<String, Object> m = new HashMap<>();
      rm.put(key123, m);
      m.put(key4, obj);
      return;
    }

    if (target instanceof Map) {
      Map<String, Object> m = ObjectMapperUtil.castToStringObjectMap(target);
      rm.put(key123, m);

      if (obj instanceof Map) {
        Map<String, Object> m2 = ObjectMapperUtil.castToStringObjectMap(obj);
        m.putAll(m2);
        return;
      }

      m.put(key4, obj);
      return;
    }

    if (target instanceof List) {
      List<Object> t = ObjectMapperUtil.castToObjectList(target);
      rm.put(key123, t);

      if (obj instanceof List) {
        List<Object> o = ObjectMapperUtil.castToObjectList(obj);
        t.addAll(o);
        return;
      }

      Map<String, Object> m = new HashMap<>();
      t.add(m);
      m.put(key4, obj);
    }
  }
  // add 2021-01-19 No.739:新規マスタを含むオーダ受信時に該当するマスタを新規登録する機能の実装 商 end

  /**
   * テーブル.カラムに対する値が単一のマップの時、マップのリストに変換する。
   * @param rm マップ
   */
  private void makeListOnSingleMap(ResultMap rm) {
    if (MapUtils.isEmpty(rm)) {
      return;
    }

    Set<Map.Entry<String, Object>> entrySet = rm.entrySet();
    for (Map.Entry<String, Object> entry : entrySet) {
      Object obj = entry.getValue();
      if (!(obj instanceof Map)) {
        continue;
      }

      rm.put(entry.getKey(), new ArrayList<>(Arrays.asList(obj)));
    }
  }

  /**
   * 繰り返し要素の繰り返し回数を取得する。<br/>
   * occ要素のlen属性に0より大きい値が設定されていれば、その値の桁数分を電文から切り出し、整数に変換して取得する。<br/>
   * len属性が未指定ないし0の場合は、レイアウト定義のrepeat属性の値を取得する。
   *
   * @param occ Occオブジェクト
   * @return 繰り返し回数
   */
  private int getRepetitionCount(String value, Occ occ) {
    // ・repeat属性が指定されており、値がブランクでない場合
    // repeat属性値を繰り返し回数とする。
    String repeatStr = occ.getRepeat();
    if (!StringUtils.isEmpty(repeatStr)) {
      return Integer.parseInt(repeatStr);
    }

    // ・上記以外の場合
    // 電文から繰り返し回数を取得する。
    if (StringUtils.isEmpty(value)) {
      return 0;
    }

    return Integer.parseInt(value);
  }

  /**
   * 電文レイアウト情報を取得する。
   * detailName引数がnullの場合はmst_coop_layoutから、nullでない場合はmst_coop_layout_detailから取得する。
   *
   * @param facilityCd 施設コード
   * @param direction 向き（送受信）
   * @param coopCd 電文種別
   * @param coopCdIndex 付帯情報（電文）
   * @param coopVersion 連携版番号
   * @param coopCdSub 電文種別補足コード
   * @param detailName occ要素で指定されるレイアウト詳細名
   * @return 電文レイアウト情報
   */
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  private TelegramLayout getLayout(String facilityCd, String direction, String coopCd,String coopCdIndex, String coopCdSub,
//      String detailName) {
  private TelegramLayout getLayout(String facilityCd, String direction, String coopCd, String coopCdIndex,
                                   String coopVersion, String coopCdSub, String detailName) {
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    if (detailName == null) {
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////      MstCoopLayout mcl = mstCoopLayoutDao.selectWithAll(facilityCd, coopCd, coopCdIndex, direction, coopCdSub, AUX_CODE_ALL);
//      MstCoopLayout mcl = mstCoopLayoutDao.selectWithAll(facilityCd, coopCd, coopCdIndex, coopVersion, direction,
//        coopCdSub, AUX_CODE_ALL);
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
      MstCoopLayout mcl = convertCommonService.getMstCoopLayout(facilityCd, direction, coopCd, coopCdIndex, coopVersion, coopCdSub);
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end
      return new TelegramLayout(mcl.getCoopSettingRoot(), mcl.getCoopExtSetting());
    }
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////      MstCoopLayoutDetail mcld = mstCoopLayoutDetailDao.selectWithPre(facilityCd, coopCd, direction, detailName,
////        coopCdSub, AUX_CODE_PRELOGIC, AUX_CODE_ALL);
//    MstCoopLayoutDetail mcld = mstCoopLayoutDetailDao.selectWithPre(facilityCd, coopCd, coopVersion, direction, detailName,
//      coopCdSub, AUX_CODE_PRELOGIC, AUX_CODE_ALL);
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    MstCoopLayoutDetail mcld = convertCommonService.getMstCoopLayoutDetailWithPre(facilityCd, direction, coopCd,
      coopVersion, detailName, coopCdSub, AUX_CODE_PRELOGIC, AUX_CODE_ALL);
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end
      return new TelegramLayout(mcld.getCoopSettingRoot(), mcld.getCoopExtSetting());
  }

  /**
   * 特殊値を置換する。
   *
   * @param facilityCd 施設コード
   * @param value 電文から切り出した値
   * @param valueReplace 変換レイアウト項目
   * @param layoutExtSetting レイアウトの拡張設定
   * @return 置換結果
   */
  String evalReplace(String facilityCd, String value, String valueReplace, LayoutExtSetting layoutExtSetting) {
    return valueEvaluatorUtil.eval(value, valueReplace, facilityCd, layoutExtSetting,true);
  }

  /**
   * 電文レイアウト情報
   * （mst_coop_layoutとmst_coop_layout_detail共用）
   */
  @Data
  @AllArgsConstructor
  private static class TelegramLayout {
    /**
     * 連携設定（XML）
     */
    private Root root;

    /**
     * 拡張設定（JSON）
     */
    private LayoutExtSetting layoutExtSetting;
  }

  /**
   * Typeよる文字列変換
   *
   * @param item 変換レイアウトの項目
   * @param value 文字列
   * @return 変換後の文字列
   * */
  private String formatValue(Item item, String value) {

    if (StringUtils.isEmpty(item.getType())) {
      // タイプが未設定の場合
      return value;
    }
    String result = null;
    switch (item.getType()) {
    case JournalConvertConstants.TYPE_DATE:
      // TypeがDateの場合
      result = DateUtil.convertDateToStringFormat(value);
      break;
    default:
      result = value;
      break;
    }
    return result;
  }

}
