package jp.co.nikkiso.ntss.coop_api.service;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Optional;
import java.util.Set;
import java.util.regex.Pattern;

import org.seasar.doma.jdbc.Config;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import tools.jackson.core.type.TypeReference;

import jp.co.nikkiso.ntss.api.service.SysDataSetService;
import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.mapping.PdfName;
import jp.co.nikkiso.ntss.coop_api.request.JournalConvertSendDataSetRequest;
import jp.co.nikkiso.ntss.coop_api.utils.ClockWrapper;
import jp.co.nikkiso.ntss.coop_api.utils.CoopIniConvUtil;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants.AnaResult;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants.Crud;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MstCoopFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopFilenameDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopLayoutDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstUserAuthenticationDao;
import jp.co.nikkiso.ntss.core.dao.SysCoopJournalDao;
import jp.co.nikkiso.ntss.core.dao.SysDataSetDao;
import jp.co.nikkiso.ntss.core.entity.MstCoopFacility;
import jp.co.nikkiso.ntss.core.entity.MstCoopFacility.CommonSetting;
import jp.co.nikkiso.ntss.core.entity.MstCoopFacility.CoopOrdCd;
import jp.co.nikkiso.ntss.core.entity.MstCoopFilename;
import jp.co.nikkiso.ntss.core.entity.MstCoopIni;
import jp.co.nikkiso.ntss.core.entity.MstCoopLayout;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstUserAuthentication;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import jp.co.nikkiso.ntss.core.entity.json.LayoutExtSetting;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import lombok.AllArgsConstructor;
import lombok.Getter;
import jp.co.nikkiso.ntss.core.config.DefaultDb;

@Service
public class ConvertSendCommonServiceImpl implements ConvertSendCommonService {
  /** DI */
  @Autowired
  SysCoopJournalDao sysCoopJournalDao;
  @Autowired
  MstCoopLayoutDao mstCoopLayoutDao;
  @Autowired
  SysDataSetDao sysDataSetDao;
  @Autowired
  private MstCoopFacilityDao mstCoopFacilityDao;
  @Autowired
  MstCoopFilenameDao mstCoopFilenameDao;
  @Autowired
  ClockWrapper clockWrapper;
  @Autowired
  MstUserAuthenticationDao mstUserAuthenticationDao;

  // add 2021-10-14 CSIの「【検査予定送信】のスタッフマスタ.職種コード」の対応 孫 start
  @Autowired
  MstPersonalUserDao mstPersonalUserDao;
  // add 2021-10-14 CSIの「【検査予定送信】のスタッフマスタ.職種コード」の対応 孫 end

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

  /**
   * データセットService.
   */
  @Autowired
  private SysDataSetService sysDataSetService;

  @Autowired
  private LogService logService;

  @Autowired
  @DefaultDb
  private Config defaultDbConfig;

  /** sys_coop_journal.pat_id */
  private static final String SYS_COOP_JOURNAL_COLUMN_BY_PAT_ID = "patId";
  private static final String SYS_COOP_JOURNAL_COLUMN_BY_PAT_ID_SNAKE = "pat_id";

  /** sys_coop_journal.ord_no */
  private static final String SYS_COOP_JOURNAL_COLUMN_BY_ORD_NO = "ordNo";
  private static final String SYS_COOP_JOURNAL_COLUMN_BY_ORD_NO_SNAKE = "ord_no";

  // add 2021-03-19 外部連携：定時一括送信機能の複数データの対応。 孫 start
  /** sys_coop_journal.facility_cd */
  private static final String SYS_COOP_JOURNAL_COLUMN_BY_FACILITY_CD = "facilityCd";
  private static final String SYS_COOP_JOURNAL_COLUMN_BY_FACILITY_CD_SNAKE = "facility_cd";
  // add 2021-03-19 外部連携：定時一括送信機能の複数データの対応。 孫 end
  // add 2021-06-25 #5227:ファイル名生成用の引数が不足している 孫 start
  private static final String SYS_COOP_JOURNAL_COLUMN_BY_CTL_NO = "ctlNo";
  private static final String SYS_COOP_JOURNAL_COLUMN_BY_CTL_NO_SNAKE = "ctl_no";
  // add 2021-06-25 #5227:ファイル名生成用の引数が不足している 孫 end
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  private static final String SYS_COOP_JOURNAL_COLUMN_BY_KEY0 = "key0";
  private static final String SYS_COOP_JOURNAL_COLUMN_BY_COOP_VERSION = "coopVersion";
  private static final String SYS_COOP_JOURNAL_COLUMN_BY_COOP_VERSION_SNAKE = "coop_version";
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

  /** ファイル名関連キー */
  @AllArgsConstructor
  @Getter
  public static enum FileNames {
    /** PDFファイル名 */
    PDF_NAME("pdfName"),
    /** 電文パス名 */
    DUMP_NAME("dumpName"),
    /** 圧縮ファイル名 */
    COMPRESSION_NAME("compressionName");
    // フィールド変数
    private final String key;
  }

  @Override
  public void storeTelegram(SysCoopJournal journal) {

    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "sys_coop_journal";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" ctl_no = " + journal.getCtlNo() + "\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    // mod 2020-12-09 FNSI-改修 外部連携727 夏 start
    //sysCoopJournalDao.updateAnaResultAndStoreDump(journal.getCtlNo(), AnaResult.DONE.getResult(), journal.getDumpPath(), journal.getDump(), new Timestamp(clockWrapper.getClockMillis()));
    // mod 2020-12-17 FNSI-改修 外部連携721(前回処理結果による処理変更) 夏 start
    //sysCoopJournalDao.updateAnaResultAndStoreDump(journal.getCoopOrdNo(),journal.getCtlNo(), AnaResult.DONE.getResult(), journal.getDumpPath(), journal.getDump(), new Timestamp(clockWrapper.getClockMillis()));
    int updateCount = sysCoopJournalDao.updateAnaResultAndStoreDump(journal.getCrud(),journal.getCoopOrdNo(),journal.getCtlNo(), AnaResult.DONE.getResult(), journal.getDumpPath(), journal.getDump(), new Timestamp(clockWrapper.getClockMillis()));
    // mod 2020-12-17 FNSI-改修 外部連携721(前回処理結果による処理変更) 夏 end
    // mod 2020-12-09 FNSI-改修 外部連携727 夏 end

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End

    // del 2021-06-10 #5279:API連動の処理順番が正しくない 孫 start
//    // add 2021-04-06 課題No.1:API連動設定:動作条件「処理完了時、処理エラー時、処理スキップ時」を追加 孫 start
//    // 事後APIキック機能を呼び出し
//    if (updateCount > 0) {
//      CallApiJournalRequest callApiJournalRequest = new CallApiJournalRequest();
//      BeanUtils.copyProperties(journal, callApiJournalRequest);
//      // mod 2021-06-09 #5278 API連動処理の判定が正しくない wangchen start
//      callApiJournalRequest.setApiTimingIo(NtssCoopApiConstants.ApiTimingIoStatus.ANA_DONE.getStatus());
//      // mod 2021-06-09 #5278 API連動処理の判定が正しくない wangchen end
//      callApiJournalRequest.setApiTimingBa(NtssCoopApiConstants.ApiTimingBaStatus.AFTER.getStatus());
//      boolean callResult = callApiService.callApiJournal(callApiJournalRequest, journal, null);
////      if (!callResult) {
////        break;
////      }
//    }
//    // add 2021-04-06 課題No.1:API連動設定:動作条件「処理完了時、処理エラー時、処理スキップ時」を追加 孫 end
    // del 2021-06-10 #5279:API連動の処理順番が正しくない 孫 end
  }
  @Override
  /* upd by chamaojia 2026-04-24 [10959] add param coopIni --start */
  public Map<String, List<Map<String, Object>>> createRequestAndRequestByDataSetApi(SysCoopJournal journal, LayoutExtSetting layoutExtSetting,
      Map<String, Object> detailDataSetMap, MstCoopIni coopIni) {
  /* upd by chamaojia 2026-04-24 [10959] add param coopIni --end */
    // datasetのデータを予め取得する
    Map<String, List<Map<String, Object>>> dataSetResult = new HashMap<>();

    // 拡張設定がなかったり、datasetのプロパティがない場合は空で返却する
    // (拡張設定はdataset情報以外も入る可能性があるので、datasetのキーがあるかをあらかじめ確認する必要がある)
    if (layoutExtSetting == null ||  !layoutExtSetting.containsKey("dataset")) return dataSetResult;

// add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    String key0 = StringUtils.isEmpty(journal.getKey0())?"":journal.getKey0();
    String coopVersion = StringUtils.isEmpty(journal.getCoopVersion())?"":journal.getCoopVersion();
// add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

    for (Entry<String, Object> keyValue : layoutExtSetting.entrySet()) {
      // dataset情報じゃなかったらスキップ
      if (!keyValue.getKey().equals("dataset")) continue;

      // 本当であればmapping用クラスを作成し読み込みたいが、layoutExtSettingがHashMapで分離されていることから一番コストが少ない未検査キャストで行う
      List<Map<String, Object>> dataSetList = cast(keyValue.getValue());
      for (Map<String, Object> dataSetMap : dataSetList) {

        //datasetのKEY値のnullチェックを行う
        checkDatasetValue(dataSetMap);

        JournalConvertSendDataSetRequest request;
        if (detailDataSetMap == null) {
          // リクエストパラメータに患者番号、オーダ番号の指定がある場合はジャーナル情報を流用する
          if (dataSetMap.containsKey(SYS_COOP_JOURNAL_COLUMN_BY_PAT_ID)) {
            dataSetMap.replace(SYS_COOP_JOURNAL_COLUMN_BY_PAT_ID, String.valueOf(journal.getPatId()));
          }
          if (dataSetMap.containsKey(SYS_COOP_JOURNAL_COLUMN_BY_ORD_NO)) {
            dataSetMap.replace(SYS_COOP_JOURNAL_COLUMN_BY_ORD_NO, String.valueOf(journal.getOrdNo()));
          }
          // add 2021-03-19 外部連携：定時一括送信機能の複数データの対応。 孫 start
          if (dataSetMap.containsKey(SYS_COOP_JOURNAL_COLUMN_BY_FACILITY_CD)) {
            dataSetMap.replace(SYS_COOP_JOURNAL_COLUMN_BY_FACILITY_CD, String.valueOf(journal.getFacilityCd()));
          }
          // add 2021-03-19 外部連携：定時一括送信機能の複数データの対応。 孫 end
          // add 2021-10-19 #5890:Medicom連携ができない(検査オーダ(exam_ord)) 孫 start
          if (dataSetMap.containsKey(SYS_COOP_JOURNAL_COLUMN_BY_CTL_NO)) {
            dataSetMap.replace(SYS_COOP_JOURNAL_COLUMN_BY_CTL_NO, String.valueOf(journal.getCtlNo()));
          }
          // add 2021-10-19 #5890:Medicom連携ができない(検査オーダ(exam_ord)) 孫 end
// add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
          if (dataSetMap.containsKey(SYS_COOP_JOURNAL_COLUMN_BY_KEY0)) {
            dataSetMap.replace(SYS_COOP_JOURNAL_COLUMN_BY_KEY0, key0);
          }
          if (dataSetMap.containsKey(SYS_COOP_JOURNAL_COLUMN_BY_COOP_VERSION)) {
            dataSetMap.replace(SYS_COOP_JOURNAL_COLUMN_BY_COOP_VERSION, coopVersion);
          }
// add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
          // JSONにdatakeyのプロパティを付与するため、ラップする
          request = new JournalConvertSendDataSetRequest(dataSetMap);
        } else {
          // detailレイアウトからdatasetのアクセスを行う場合はフォーマットが異なるため別ロジックを踏んでmapを生成する
          Map<String, Object> dataSetRequest = createDetailDatasetRequestParametor(dataSetMap, detailDataSetMap, journal);
          // JSONにdatakeyのプロパティを付与するため、ラップする
          request = new JournalConvertSendDataSetRequest(dataSetRequest);
        }
// mod 2022-03-14 #7208:電文作成処理をスキップする機能がない 孫 start
//        dataSetResult.put(request.getSqlCode(), requestNtssApi(request));
        List<Map<String, Object>> resultList = requestNtssApi(request);
// #7208 mod 2022-11-29 電文作成処理をスキップする機能がない 卓 start
        if (dataSetMap.containsKey("is_zero_end")) {

          Object isZeroEnd = dataSetMap.get("is_zero_end");
          if (!StringUtils.isEmpty(isZeroEnd) && "true".equals(isZeroEnd.toString().toLowerCase())) {
            // upd #8567 患者情報の常勤医設定なしの場合 ztc 0529 start
            boolean emptyFlag = false;
            if(resultList.size()>0) {
              for (Map<String, Object> resultMap : resultList) {
                //del #9256 is_zero_end取得できなかった項目 ljg start
//              if (resultMap.containsKey("disp_user_id")) {
//                Object dispUserId = resultMap.get("disp_user_id");
//                if (dispUserId == null || dispUserId.toString().isEmpty()) {
//                  emptyFlag = true;
//                  break;
//                }
//              }
                //del #9256 is_zero_end取得できなかった項目 ljg end
                //add #9256 is_zero_end取得できなかった項目 ljg start
                emptyFlag = resultMap.entrySet().stream().anyMatch(obj->obj.getValue().equals(""));
                if(emptyFlag){
                  break;
                }
                //add #9256 is_zero_end取得できなかった項目 ljg end
              }
            }
            // upd #8567 患者情報の常勤医設定なしの場合 ztc 0529 end
            if (resultList.size() == 0 || emptyFlag) {
              //add #9256 is_zero_end取得できなかった項目 ljg start
              String layoutCrud = journal.getCrud();
              if(layoutCrud!=null){
                if(layoutCrud.equals("C")){
                  layoutCrud = "cre";
                }else if(layoutCrud.equals("U")){
                  layoutCrud = "upd";
                }else if(layoutCrud.equals("D")){
                  layoutCrud = "del";
                }
              }
              String mstcooplayoutname = mstCoopLayoutDao.selectLayoutname(journal.getFacilityCd(),journal.getCoopCd(),
                      layoutCrud,journal.getDirection(),journal.getCoopVersion(),request.getSqlCode(),journal.getCoopCdIndex());
              //add #9256 is_zero_end取得できなかった項目 ljg end
              //upd #9256 is_zero_end取得できなかった項目 ljg start
              String errorMessage = String.format("ERROR[IS_ZERO_END]:[%s]不明:sqlCode[%s]にデータが無し。", mstcooplayoutname,request.getSqlCode());
              //upd #9256 is_zero_end取得できなかった項目 ljg end
              throw  new NtssException(errorMessage);

            } else {
              for (Map<String, Object> stringObjectMap : resultList) {
                if (!stringObjectMap.containsKey("has_not_in_hospital_cd")) {
                  continue;
                }

                Boolean has_not_in_hospital_cd = (Boolean) stringObjectMap.get("has_not_in_hospital_cd");
                if ( has_not_in_hospital_cd && (Crud.CREATE.isSameResult(journal.getCrud()))) {
                  throw  new NtssException(String.format("ERROR[IS_ZERO_END]:院内コードが無し。オーダ番号[%s]",journal.getOrdNo()));
                }
              }
            }
          }
        }
        dataSetResult.put(request.getSqlCode(), resultList);
// #7208 mod 2022-11-29 電文作成処理をスキップする機能がない 卓 end
// mod 2022-03-14 #7208:電文作成処理をスキップする機能がない 孫 end
      }
      // dataset要素以外は不必要なので取れた段階でbreakを入れる
      break;
    }
    // add 2021-09-26 #5897:CSI連携ができないの対応 孫 start
    if (dataSetResult != null && dataSetResult.size() > 0) {
      // 本システムコード→外部連携のコード変換の初期化処理
      // 施設コード
      String facilityCd = String.valueOf(journal.getFacilityCd());
      // ①変換項目を取得する
      // コード変換項目設定が有りか
      Map<String, String> coopIniConvItem = null;
      if (layoutExtSetting.containsKey("CoopIniConvUtil")) {
        try {
          coopIniConvItem = ObjectMapperUtil.castToStringStringMap(layoutExtSetting.get("CoopIniConvUtil"));
        } catch (Exception ex) {
          String message = String.format("連携電文設定マスタの拡張設定の[CoopIniConvUtil]はjson形式のデータではありません。施設コード:[%s] 内容:[%s]",
            facilityCd, ex.getMessage());
          throw new NtssException(message);
        }
      }
      if (coopIniConvItem == null || coopIniConvItem.size() == 0) {
        return dataSetResult;
      }

      // ②KEYマッピングを取得する
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//      Map<String, String> keyMappingData = CoopIniConvUtil.GetKeyMapping(facilityCd, "S");
      /* upd by chamaojia 2026-04-24 [10959] param facilityCd -> coopIni --start */
      Map<String, String> keyMappingData = CoopIniConvUtil.GetKeyMapping(coopIni, key0, "S");
      /* upd by chamaojia 2026-04-24 [10959] param facilityCd -> coopIni --end */
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
      // コード変換項目が有りか
      if (coopIniConvItem != null  && coopIniConvItem.size() > 0
        && keyMappingData!=null && keyMappingData.size() > 0){
        // ③変換項目とKEYマッピングをマッピングする
        for (String key : coopIniConvItem.keySet()) {
          String convKey = coopIniConvItem.get(key);
          if (StringUtils.isEmpty(convKey)) {
            convKey = key;
          }
          if (keyMappingData.containsKey(convKey)) {
            String mappingKey = keyMappingData.get(convKey);
            if (!StringUtils.isEmpty(mappingKey)) {
              coopIniConvItem.put(key, mappingKey);
            }
          }
        }
      }
      // ④連携設定情報を取得する
      /* upd by chamaojia 2026-04-24 [10959] param facilityCd -> coopIni --start */
      Map<String, String> convertData = CoopIniConvUtil.GetCoopIniInfo(coopIni);
      /* upd by chamaojia 2026-04-24 [10959] param facilityCd -> coopIni --end */
      if (convertData == null || convertData.size() == 0) {
        return dataSetResult;
      }

      // ⑤本システムコード→外部連携のコードを変換します
      Set<String> dateKeySql = dataSetResult.keySet();
      for (String keySql : dateKeySql) {
        List<Map<String, Object>> dataSetList = dataSetResult.get(keySql);
        if (dataSetList != null && dataSetList.size() > 0) {
          Set<String> dateKeyTbl = dataSetList.get(0).keySet();
          int dataCount = dataSetList.size();
          for (int index = 0; index < dataCount; index++) {
            Map<String, Object> convData = dataSetList.get(index);
            for (String keyTbl : dateKeyTbl) {
              String checkKey = keySql + "." + keyTbl;
              // 変換項目が有りかString
              if (coopIniConvItem.containsKey(checkKey)) {
                // データがListか
                if (convData.get(keyTbl) instanceof List) {
                  // List
                  List<Object> valueList =  (List)convData.get(keyTbl);
                  for (int i=0; i<valueList.size(); i++) {
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//                    String convKey = coopIniConvItem.get(checkKey) + CoopIniConvUtil.MARK + valueList.get(i).toString();
                    String convKey = key0 + CoopIniConvUtil.MARK + coopIniConvItem.get(checkKey) + CoopIniConvUtil.MARK + valueList.get(i).toString();
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
                    if (convertData.containsKey(convKey)) {
                      valueList.set(i, convertData.get(convKey));
                    }
                  }
                } else {
                  // List以外
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//                  String convKey = coopIniConvItem.get(checkKey) + CoopIniConvUtil.MARK + convData.get(keyTbl).toString();
                  String convKey =  key0 + CoopIniConvUtil.MARK + coopIniConvItem.get(checkKey) + CoopIniConvUtil.MARK + convData.get(keyTbl).toString();
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
                  if (convertData.containsKey(convKey)) {
                    convData.put(keyTbl, convertData.get(convKey));
                  }
                }
              }
            }
          }
        }
      }
    }
    // add 2021-09-26 #5897:CSI連携ができないの対応 孫 end
    return dataSetResult;
  }
  /**
   * datasetのKEY値のnullチェックを行う
   * @param dataSetMap
   */
  private void checkDatasetValue(Map<String, Object> dataSetMap) {
    for (Entry<String, Object> entrySet : dataSetMap.entrySet()) {
      if (StringUtils.isEmpty(entrySet.getValue())) {
        throw new NtssException("datasetのKEY値がnullです。 KEY:[" + entrySet.getKey() + "]");
      }
    }
  }

  @Override
  public List<Map<String, Object>> requestNtssApi(JournalConvertSendDataSetRequest request) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    try  {

      // datasetのリクエストパラメータをJSON化する
      String datasetRequestJson = ObjectMapperUtil.write(request);
      eventLogMessage.setLogMessage("ConvertSendServiceImpl#requestDataSetApi request json:[" + datasetRequestJson + "]-");
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      List<Map<String, Object>> dataSetList = new ArrayList<Map<String, Object>>();

      if (request.getDataKey().containsKey("dsMerge")) {
        List<String> dsMergeList = ObjectMapperUtil.castToStringList(request.getDataKey().get("dsMerge"));
        request.getDataKey().remove("dsMerge");
        for (String dsSqlCode : dsMergeList) {
          dataSetList.addAll(sysDataSetService.getDataList(Long.valueOf(dsSqlCode), request.getDataKey()));
        }
      } else {
        dataSetList.addAll(sysDataSetService.getDataList(Long.valueOf(request.getSqlCode()), request.getDataKey()));
      }
      //add FNSI-7529 劉全航 start
      if(request.getSqlCode().equals("-108")){
        if (!CollectionUtils.isEmpty(dataSetList)) {
          Map<String, Object> resultMap = dataSetList.get(0);
          String settingValue = resultMap.get("setting_value").toString();
          Optional<Object> ordNo = Optional.ofNullable(resultMap.get("ord_no"));
          if(settingValue.equals("0") && !ordNo.isPresent()){
            throw new NtssException("GX連携ini_dial未受信患者");
          }
        }
      }
      //add FNSI-7529 劉全航 end

      // null値を排除する
      if (!CollectionUtils.isEmpty(dataSetList)) {
        for (Map<String, Object> dataSetMap: dataSetList) {
          Set<String> keySets = dataSetMap.keySet();
          for (String key: keySets) {
            dataSetMap.putIfAbsent(key, "");
          }
        }
      }

      return dataSetList;

    } catch (IOException e) {
      eventLogMessage.setLogMessage("送信版変換APIにてdataset APIをリクエストしたところI/Oエラーが発生しました。");
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new NtssException(e);
    }
  }

  /**
   * detailレイアウトの中でさらに子供のdetailレイアウトがあった場合のdatasetリクエストパラメータを作成します
   * datasetのリクエスト用のフォーマットが「sqlCode.column」になっているのでsplitが必要となるところが違いとなります。
   *
   * @param layoutExtSettingMap - mst_coop_layout_detail.layout_ext_setting
   * @param detailDataSetMap - detailレイアウトからループしているdatasetの1要素
   * @param journal - {@link SysCoopJournal}
   * @return dataset結果
   */
  private Map<String, Object> createDetailDatasetRequestParametor(Map<String, Object> layoutExtSettingMap, Map<String, Object> detailDataSetMap, SysCoopJournal journal) {
    Map<String, Object> requestParameterMap = new HashMap<>();
    for (Entry<String, Object> entry : layoutExtSettingMap.entrySet()) {
      // SQLCODEはそのままmapに放り投げて次のリクエストパラメータ整形に移る
      if ("sqlCode".equals(entry.getKey())) {
        requestParameterMap.put(entry.getKey(), entry.getValue());
        if (layoutExtSettingMap.containsKey("dsMerge")) {
          requestParameterMap.put("dsMerge", layoutExtSettingMap.get("dsMerge"));
        }
        continue;
      }

      // 親レイアウトからもらってきたdatasetの結果からさらにdatasetを呼ぶために「sqlCode.column」のフォーマットで定義しているため
      // ドットがない場合はそのままの値をmapにputする
      if (String.valueOf(entry.getValue()).indexOf(".") == -1) {
        requestParameterMap.put(entry.getKey(), entry.getValue());
        continue;
      }

      String[] requestParameterArray = String.valueOf(entry.getValue()).split(Pattern.quote("."));
      String requestParameterKey = requestParameterArray[1];
      // そのままreplaceをすると参照渡しをしてしまいもし次の要素があった場合に参照渡しの結果で処理をしてしまうので、新しくmapに放り込んで疑似的にコピーする
      requestParameterMap.put(entry.getKey(), String.valueOf(detailDataSetMap.get(requestParameterKey)));
    }

    // リクエストパラメータに患者番号、オーダ番号の指定がある場合はジャーナル情報を流用する
    if (layoutExtSettingMap.containsKey(SYS_COOP_JOURNAL_COLUMN_BY_PAT_ID)
      && (SYS_COOP_JOURNAL_COLUMN_BY_PAT_ID.equals(layoutExtSettingMap.get(SYS_COOP_JOURNAL_COLUMN_BY_PAT_ID))
        || SYS_COOP_JOURNAL_COLUMN_BY_PAT_ID_SNAKE.equals(layoutExtSettingMap.get(SYS_COOP_JOURNAL_COLUMN_BY_PAT_ID)))) {
      requestParameterMap.put(SYS_COOP_JOURNAL_COLUMN_BY_PAT_ID, String.valueOf(journal.getPatId()));
    }
    if (layoutExtSettingMap.containsKey(SYS_COOP_JOURNAL_COLUMN_BY_ORD_NO)
      && (SYS_COOP_JOURNAL_COLUMN_BY_ORD_NO.equals(layoutExtSettingMap.get(SYS_COOP_JOURNAL_COLUMN_BY_ORD_NO))
        || SYS_COOP_JOURNAL_COLUMN_BY_ORD_NO_SNAKE.equals(layoutExtSettingMap.get(SYS_COOP_JOURNAL_COLUMN_BY_ORD_NO)))) {
      requestParameterMap.put(SYS_COOP_JOURNAL_COLUMN_BY_ORD_NO, String.valueOf(journal.getOrdNo()));
    }
    // add 2021-03-19 外部連携：定時一括送信機能の複数データの対応。 孫 start
    if (layoutExtSettingMap.containsKey(SYS_COOP_JOURNAL_COLUMN_BY_FACILITY_CD)
      && (SYS_COOP_JOURNAL_COLUMN_BY_FACILITY_CD.equals(layoutExtSettingMap.get(SYS_COOP_JOURNAL_COLUMN_BY_FACILITY_CD))
        || SYS_COOP_JOURNAL_COLUMN_BY_FACILITY_CD_SNAKE.equals(layoutExtSettingMap.get(SYS_COOP_JOURNAL_COLUMN_BY_FACILITY_CD)))) {
      requestParameterMap.replace(SYS_COOP_JOURNAL_COLUMN_BY_FACILITY_CD, String.valueOf(journal.getFacilityCd()));
    }
    // add 2021-03-19 外部連携：定時一括送信機能の複数データの対応。 孫 end
    // add 2021-10-19 #5890:Medicom連携ができない(検査オーダ(exam_ord)) 孫 start
    if (layoutExtSettingMap.containsKey(SYS_COOP_JOURNAL_COLUMN_BY_CTL_NO)
      && (SYS_COOP_JOURNAL_COLUMN_BY_CTL_NO.equals(layoutExtSettingMap.get(SYS_COOP_JOURNAL_COLUMN_BY_CTL_NO))
        || SYS_COOP_JOURNAL_COLUMN_BY_CTL_NO_SNAKE.equals(layoutExtSettingMap.get(SYS_COOP_JOURNAL_COLUMN_BY_CTL_NO)))) {
      requestParameterMap.replace(SYS_COOP_JOURNAL_COLUMN_BY_CTL_NO, String.valueOf(journal.getCtlNo()));
    }
    // add 2021-10-19 #5890:Medicom連携ができない(検査オーダ(exam_ord)) 孫 end
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    if (layoutExtSettingMap.containsKey(SYS_COOP_JOURNAL_COLUMN_BY_KEY0)
      && (SYS_COOP_JOURNAL_COLUMN_BY_KEY0.equals(layoutExtSettingMap.get(SYS_COOP_JOURNAL_COLUMN_BY_KEY0)))) {
      requestParameterMap.replace(SYS_COOP_JOURNAL_COLUMN_BY_KEY0, String.valueOf(journal.getKey0()));
    }
    if (layoutExtSettingMap.containsKey(SYS_COOP_JOURNAL_COLUMN_BY_COOP_VERSION)
      && (SYS_COOP_JOURNAL_COLUMN_BY_COOP_VERSION.equals(layoutExtSettingMap.get(SYS_COOP_JOURNAL_COLUMN_BY_COOP_VERSION))
        || SYS_COOP_JOURNAL_COLUMN_BY_COOP_VERSION_SNAKE.equals(layoutExtSettingMap.get(SYS_COOP_JOURNAL_COLUMN_BY_COOP_VERSION)))) {
      requestParameterMap.replace(SYS_COOP_JOURNAL_COLUMN_BY_COOP_VERSION, String.valueOf(journal.getCoopVersion()));
    }
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    return requestParameterMap;
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
  /**
   * 作成した電文のファイル名を取得します.
   * ベンダーごとにフォーマットが異なるためdatasetから取得を行います
   *
   * @param layout - {@link MstCoopLayout}
   * @param journal - {@link SysCoopJournal journal}
   * @return 電文ファイル名
   */
  public String getDumpFileName(MstCoopLayout layout, SysCoopJournal journal) {
    // 拡張設定がなかったり、dumpFileNameのプロパティがない場合は空で返却する
    // (拡張設定はdumpFileName情報以外も入る可能性があるので、dumpFileNameのキーがあるかをあらかじめ確認する必要がある)
    if (layout == null || layout.getCoopExtSetting() == null ||  !layout.getCoopExtSetting().containsKey("dumpFileName")) return null;

      Map<String, Object> dataSetMap = cast(layout.getCoopExtSetting().get("dumpFileName"));
      // リクエストパラメータに患者番号、オーダ番号の指定がある場合はジャーナル情報を流用する
      if (dataSetMap.containsKey(SYS_COOP_JOURNAL_COLUMN_BY_PAT_ID)) {
        dataSetMap.replace(SYS_COOP_JOURNAL_COLUMN_BY_PAT_ID, String.valueOf(journal.getPatId()));
      }
      if (dataSetMap.containsKey(SYS_COOP_JOURNAL_COLUMN_BY_ORD_NO)) {
        dataSetMap.replace(SYS_COOP_JOURNAL_COLUMN_BY_ORD_NO, String.valueOf(journal.getOrdNo()));
      }
      // add 2021-03-19 外部連携：定時一括送信機能の複数データの対応。 孫 start
      if (dataSetMap.containsKey(SYS_COOP_JOURNAL_COLUMN_BY_FACILITY_CD)) {
        dataSetMap.replace(SYS_COOP_JOURNAL_COLUMN_BY_FACILITY_CD, String.valueOf(journal.getFacilityCd()));
      }
      // add 2021-03-19 外部連携：定時一括送信機能の複数データの対応。 孫 end
      // add 2021-06-25 #5227:ファイル名生成用の引数が不足している 孫 start
      if (dataSetMap.containsKey(SYS_COOP_JOURNAL_COLUMN_BY_CTL_NO)) {
        dataSetMap.replace(SYS_COOP_JOURNAL_COLUMN_BY_CTL_NO, String.valueOf(journal.getCtlNo()));
      }
      // add 2021-06-25 #5227:ファイル名生成用の引数が不足している 孫 end
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    if (dataSetMap.containsKey(SYS_COOP_JOURNAL_COLUMN_BY_KEY0)) {
      dataSetMap.replace(SYS_COOP_JOURNAL_COLUMN_BY_KEY0, String.valueOf(journal.getKey0()));
    }
    if (dataSetMap.containsKey(SYS_COOP_JOURNAL_COLUMN_BY_COOP_VERSION)) {
      dataSetMap.replace(SYS_COOP_JOURNAL_COLUMN_BY_COOP_VERSION, String.valueOf(journal.getCoopVersion()));
    }
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

      // dataset要素以外は不必要なので取れた段階でbreakを入れる
      JournalConvertSendDataSetRequest request = new JournalConvertSendDataSetRequest(dataSetMap);
      List<Map<String, Object>> dataSetResultList = requestNtssApi(request);

      if (dataSetResultList.isEmpty() || !dataSetResultList.get(0).containsKey("filename")) return null;

      return String.valueOf(dataSetResultList.get(0).get("filename"));
  }

  /**
   * mst_coop_layoutおよびmst_coop_layout_detailのcoop_cd_subを求めます
   *
   * @param crud - sys_coop_journal.crud
   * @return coop_cd_sub
   */
  public String getCoopCdSub(String crud) {
    switch(crud) {
      case "C":
        return "cre";
      case "U":
        return "upd";
      case "D":
        return "del";
    }

    throw new NtssException("不正なcrud値が入力されました。対象データ:[" + crud + "]");
  }

  /**
   * ジャーナルテーブルのデータを取得する
   * @param replaceEscape 変換文字列
   * @param journal - {@link SysCoopJournal journal}
   * @return 変換した値
   */
  public String getJournalReplaceData(String replaceEscape, SysCoopJournal journal) {
    //カラム名を取得
    String colName = replaceEscape.replace("$JOURNAL.", "").toLowerCase();
    String value = "";
    if ("ord_no".equals(colName)) {
      //（次世代FN)オーダ番号
      value = journal.getOrdNo() == null ? "" : String.valueOf(journal.getOrdNo());
    } else if ("coop_ord_no".equals(colName)) {
      //（連携先)オーダ番号
      value = journal.getCoopOrdNo() == null ? "" : journal.getCoopOrdNo();
    } else if ("hosp_pat_id".equals(colName)) {
      //患者番号（連携用)
      value = journal.getHospPatId() == null ? "" : journal.getHospPatId();
    } else if ("pat_id".equals(colName)) {
      //患者番号（システム）
      value = journal.getPatId() == null ? "" : String.valueOf(journal.getPatId());
    } else if ("base_date".equals(colName)) {
      //基準日
      // mod 2020-10-13 FNSI-改修 外部連携276 夏 start
      //SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
      //value = journal.getBaseDate() == null ? "" : sdf.format(journal.getBaseDate());
      value = journal.getBaseDate() == null ? "" : journal.getBaseDate();
      // mod 2020-10-13 FNSI-改修 外部連携276 夏 end
// add 2021-09-07 #5897:CSI連携ができないの対応 孫 start
    } else if ("facility_cd".equals(colName)) {
      //施設コード
      value = journal.getFacilityCd() == null ? "" : journal.getFacilityCd();
    } else if ("coop_cd".equals(colName)) {
      //電文種別
      value = journal.getCoopCd() == null ? "" : journal.getCoopCd();
    } else if ("coop_cd_index".equals(colName)) {
      //付帯情報（電文）
      value = journal.getCoopCdIndex() == null ? "" : journal.getCoopCdIndex();
    } else if ("crud".equals(colName)) {
      //作成更新区分
      value = journal.getCrud() == null ? "" : journal.getCrud();
    } else if ("direction".equals(colName)) {
      //向き（送受信）
      value = journal.getDirection() == null ? "" : journal.getDirection();
    } else if ("accept_no".equals(colName)) {
      //受付番号
      value = journal.getAcceptNo() == null ? "" : String.valueOf(journal.getAcceptNo());
    } else if ("user_id".equals(colName)) {
      //操作者ID
      value = journal.getUserId() == null ? "" : String.valueOf(journal.getUserId());
    } else if ("ope_cd".equals(colName)) {
      //操作番号
      value = journal.getOpeCd() == null ? "" : journal.getOpeCd();
// add 2021-09-07 #5897:CSI連携ができないの対応 孫 end
    } else {
      throw new NtssException("ジャーナルテーブルのデータ取得に失敗しました。対象データ:[" + replaceEscape + "]");
    }
    return value;
  }

  // add 2021-10-14 CSIの「【検査予定送信】のスタッフマスタ.職種コード」の対応 孫 start
  /**
   * 利用者マスタ(mst_personal_user)より職種コードを取得
   *
   * @param value 文字列
   * @return 職種コード
   * */
  @Override
  public String getJobCd(String value) {
    if (StringUtils.isEmpty(value)) {
      return "";
    }
// add 2022-03-14 #7037:exam_ord連携で送信する利用者番号 孫 start
    // 利用者のデフォルト値の処理
    String[] userIdAndDefaultId = value.split("%%%");
    String sysCode = userIdAndDefaultId[0];
    String defaultCode = "";
    if (userIdAndDefaultId.length >= 2) {
      // デフォルト値が有り場合、再設定する
      defaultCode= userIdAndDefaultId[1];
    }
    if (StringUtils.isEmpty(sysCode)) {
      return defaultCode;
    }
// add 2022-03-14 #7037:exam_ord連携で送信する利用者番号 孫 end
    Long userId = parseStringToLong(sysCode);

    // 利用者マスタ(mst_personal_user)の検索
    MstPersonalUser personalUser = mstPersonalUserDao.selectById(userId);
    if (personalUser == null) {
      if (StringUtils.isEmpty(defaultCode)) {
        throw new NtssException("利用者マスタ(mst_personal_user)のデータ取得に失敗しました。user_id:[" + userId + "]");
      } else {
        return defaultCode;
      }
    }

    // 職種コードを取得
    String jobCd = personalUser.getJobCd();
    return StringUtils.isEmpty(jobCd) ? defaultCode : jobCd;
  }
  // add 2021-10-14 CSIの「【検査予定送信】のスタッフマスタ.職種コード」の対応 孫 end

  // add 2021-10-28 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 start
  /**
   * 利用者マスタ(mst_personal_user)より利用者名を取得
   *
   * @param value 文字列
   * @return 利用者名
   * */
  @Override
  public String getStaffName(String value) {
    if (StringUtils.isEmpty(value)) {
      return "";
    }
// add 2022-03-14 #7037:exam_ord連携で送信する利用者番号 孫 start
    // 利用者のデフォルト値の処理
    String[] userIdAndDefaultId = value.split("%%%");
    String sysCode = userIdAndDefaultId[0];
    String defaultCode = "";
    if (userIdAndDefaultId.length >= 2) {
      // デフォルト値が有り場合、再設定する
      defaultCode= userIdAndDefaultId[1];
    }
    if (StringUtils.isEmpty(sysCode)) {
      return defaultCode;
    }
// add 2022-03-14 #7037:exam_ord連携で送信する利用者番号 孫 end

    //add 8078 【デグレ】rep_dial連携でエラーが発生し電文送信することができない 20221115 zhaoqi start
    String userName = "";
    if (sysCode.matches("[0-9]+")) {
      Long userId = parseStringToLong(sysCode);
      userName = mstPersonalUserDao.selectUserNameById(userId);
      if (userName == null) {
        throw new NtssException("利用者マスタ(mst_personal_user)の利用者名取得に失敗しました。user_id:[" + userId + "]");
      }
    }
    //add 8078 【デグレ】rep_dial連携でエラーが発生し電文送信することができない 20221115 zhaoqi end

    //del 8078 【デグレ】rep_dial連携でエラーが発生し電文送信することができない 20221115 zhaoqi start
//    Long userId = parseStringToLong(sysCode);
//
//    // 利用者マスタ(mst_personal_user)の検索
//    String userName = mstPersonalUserDao.selectUserNameById(userId);
//    if (userName == null) {
//      throw new NtssException("利用者マスタ(mst_personal_user)の利用者名取得に失敗しました。user_id:[" + userId + "]");
//    }
    //del 8078 【デグレ】rep_dial連携でエラーが発生し電文送信することができない 20221115 zhaoqi end

    // 利用者名を取得
    return StringUtils.isEmpty(userName) ? defaultCode : userName;
  }
  // add 2021-10-28 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 end

  // add 2021-12-22 #5888:NEC-iS連携ができない(透析実績(rst_dial)) 孫 start
  /**
   * 利用者マスタ(mst_personal_user)より院内コード1を取得
   *
   * @param value 文字列
   * @return 院内コード1
   * */
  @Override
  public String getInHospitalCd1(String value) {
    return getInHospitalCd(value, 1);
  }

  /**
   * 利用者マスタ(mst_personal_user)より院内コード2を取得
   *
   * @param value 文字列
   * @return 院内コード2
   * */
  @Override
  public String getInHospitalCd2(String value) {
    return getInHospitalCd(value, 2);
  }

  /**
   * 利用者マスタ(mst_personal_user)より院内コード1/院内コード2を取得
   *
   * @param value 文字列
   * @param flag 1：院内コード1、2:院内コード2
   * @return 院内コード1/院内コード2
   * */
  private String getInHospitalCd(String value, int flag) {
    if (StringUtils.isEmpty(value)) {
      return "";
    }
// add 2022-03-11 #7037:exam_ord連携で送信する利用者番号 孫 start
    // 利用者のデフォルト値の処理
    String[] userIdAndDefaultId = value.split("%%%");
    String sysCode = userIdAndDefaultId[0];
    String defaultCode = "";
    if (userIdAndDefaultId.length >= 2) {
      // デフォルト値が有り場合、再設定する
      defaultCode= userIdAndDefaultId[1];
    }
    if (StringUtils.isEmpty(sysCode)) {
      return defaultCode;
    }
// add 2022-03-11 #7037:exam_ord連携で送信する利用者番号 孫 end
    Long userId = parseStringToLong(sysCode);

    // 利用者マスタ(mst_personal_user)の検索
    MstPersonalUser personalUser = mstPersonalUserDao.selectById(userId);
    if (personalUser == null) {
      if (StringUtils.isEmpty(defaultCode)) {
        throw new NtssException("利用者マスタ(mst_personal_user)のデータ取得に失敗しました。user_id:[" + userId + "]");
      } else {
        return defaultCode;
      }
    }

    // 院内コードを取得
    String inHospitalCd = "";
    if (1 == flag) {
      inHospitalCd = personalUser.getInHospitalCd_1();
    } else {
      inHospitalCd = personalUser.getInHospitalCd_2();
    }
    return StringUtils.isEmpty(inHospitalCd) ? defaultCode : inHospitalCd;
  }
  // add 2021-12-22 #5888:NEC-iS連携ができない(透析実績(rst_dial)) 孫 end

//  /**
//   * 利用者マスタ(mst_user_authentication)よりデータを取得する
//   *
//   * @param userId 利用者ID
//   * @return 表示用利用者ID
//   * */
//  private String getDispUserId(Long userId) {
//    // 利用者マスタの検索
//    MstUserAuthentication userAuth = mstUserAuthenticationDao.selectById(userId);
//    if (userAuth == null) {
//      throw new NtssException("利用者マスタのデータ取得に失敗しました。user_id:[" + userId + "]");
//    }
//    return userAuth.getDispUserId();
//  }

  /**
   * 利用者マスタより表示用利用者IDを取得
   *
   * @param value 文字列
   * @return 表示用利用者ID
   * */
  @Override
  public String getAuthId(String value) {
    if (StringUtils.isEmpty(value)) {
      return "";
    }
// add 2022-03-14 #7037:exam_ord連携で送信する利用者番号 孫 start
    // 利用者のデフォルト値の処理
    String[] userIdAndDefaultId = value.split("%%%");
    String sysCode = userIdAndDefaultId[0];
    String defaultCode = "";
    if (userIdAndDefaultId.length >= 2) {
      // デフォルト値が有り場合、再設定する
      defaultCode= userIdAndDefaultId[1];
    }
    if (StringUtils.isEmpty(sysCode)) {
      return defaultCode;
    }
// add 2022-03-14 #7037:exam_ord連携で送信する利用者番号 孫 end
    Long userId = parseStringToLong(sysCode);
//    // 利用者マスタからデータを取得
//    String authId = getDispUserId(userId);

    // 利用者マスタの検索
    MstUserAuthentication userAuth = mstUserAuthenticationDao.selectById(userId);
    if (userAuth == null) {
      if (StringUtils.isEmpty(defaultCode)) {
        throw new NtssException("利用者マスタ(mst_user_authentication)のデータ取得に失敗しました。user_id:[" + userId + "]");
      } else {
        return defaultCode;
      }
    }
    String authId = userAuth.getDispUserId();

    return StringUtils.isEmpty(authId) ? defaultCode : authId;
  }

  /**
   * String→Longへ変換
   * @param value 変換する文字列
   * @return Long型に変換した値
   * */
  private Long parseStringToLong(String value) {
    try {
      return Long.parseLong(value);
    } catch (NumberFormatException e) {
      throw new NtssException(String.format("UserId:Long型への変換に失敗しました。value:[%s]", value));
    }
  }

  @Override
  public boolean isReport(SysCoopJournal journal) {
    // 連携設定マスタの取得
    MstCoopFacility mstCoopFacility =  mstCoopFacilityDao.select(journal.getFacilityCd());
    if (mstCoopFacility == null) {
      String error = "施設連携設定が存在しません。";
      throw new NtssException(error);
    }
    CommonSetting commonSetting = mstCoopFacility.getCommonSetting();
    if (commonSetting == null) {
      String error = "施設連携設定内の各機能共通設定が存在しません。";
      throw new NtssException(error);
    }
    List<CoopOrdCd> coopOrdCds = commonSetting.getCoopOrdCds();
    if (coopOrdCds == null) {
      String error = "オーダー種別設定が存在しません。";
      throw new NtssException(error);
    }

// add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    String coopVersionJournal = StringUtils.isEmpty(journal.getCoopVersion())?"":journal.getCoopVersion();
// add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

    boolean isReport = false;
    // 電文種別の設定を取得
    for(CoopOrdCd coopOrdCd : coopOrdCds){
// mod 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
//      if (journal.getCoopCd().equals(coopOrdCd.getOrdCd())) {
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//      if (journal.getCoopCd().equals(coopOrdCd.getCoopCd())) {
      String coopVersionSetting = StringUtils.isEmpty(coopOrdCd.getCoopVersion())?"":coopOrdCd.getCoopVersion();
      if (journal.getCoopCd().equals(coopOrdCd.getCoopCd()) && coopVersionSetting.equals(coopVersionJournal)) {
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
// mod 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end
        isReport = coopOrdCd.isReport();
        break;
      }
    }
    return isReport;
  }

  @Override
  public Map<String, String> getFileNames(SysCoopJournal journal) {

    // 外部連携用ファイル名マスタを取得
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    MstCoopFilename mstCoopFiletname = mstCoopFilenameDao.select(journal.getFacilityCd(), journal.getCoopCd(), journal.getCoopCdIndex());
    // 連携版番号
    String coopVersion = StringUtils.isEmpty(journal.getCoopVersion())?"":journal.getCoopVersion();
    MstCoopFilename mstCoopFiletname = mstCoopFilenameDao.select(journal.getFacilityCd(), journal.getCoopCd(),
      journal.getCoopCdIndex(), coopVersion);
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    if (mstCoopFiletname == null) {
      String error = "外部連携用ファイル名が取得できません。";
      throw new NtssException(error);
    }

    Map<String, String> reportFile = new HashMap<>();
    // PDFファイル名を取得
    try {
      PdfName[] tmp = ObjectMapperUtil.read(mstCoopFiletname.getPdfName(), PdfName[].class);
      List<PdfName> pdfNameList = Arrays.asList(tmp);

      for (PdfName pdfName :  pdfNameList) {
        // mod 2021-03-09 問題確認：NODEJS側に確認JAVA側のPDFファイルを送付しました。 孫 start
//        if (journal.getReportCd() != null && pdfName.getReportCd() == journal.getReportCd()) {
        if (journal.getReportCd() != null && journal.getReportCd().equals(pdfName.getReportCd())) {
          // mod 2021-03-09 問題確認：NODEJS側に確認JAVA側のPDFファイルを送付しました。 孫 end
          // レポートコードが一致した場合
          // KEY値nullチェック
          checkDatasetValue(pdfName.getName());
          // PDFファイル名を取得
          reportFile.put(FileNames.PDF_NAME.getKey(), getFileName(journal, pdfName.getName()));
          break;
        }
      }

      // add 2021-05-11 redmine #4473：治療方法ごとのレポート出力ができない 孫 start
      // 外部連携用ジャーナルのレポートコードが有り、かつ、外部連携用ファイル名管理のデータが有り、レポートコードが一致したデータが無し場合、
      // 外部連携用ファイル名管理の最初のデータにデフォルトPDFファイル名を設定する
      if(journal.getReportCd() != null && pdfNameList.size() > 0&& !reportFile.containsKey(FileNames.PDF_NAME.getKey())){
        PdfName pdfNameFirst = pdfNameList.get(0);
        // KEY値nullチェック
        checkDatasetValue(pdfNameFirst.getName());
        // PDFファイル名を取得
        reportFile.put(FileNames.PDF_NAME.getKey(), getFileName(journal, pdfNameFirst.getName()));
      }
      // add 2021-05-11 redmine #4473：治療方法ごとのレポート出力ができない 孫 end

    } catch (IOException e) {
      outputDebugLog(journal.getFacilityCd(), "parse error pdf_name: " + mstCoopFiletname.getPdfName());
      throw new NtssException("PDFファイル名のパースに失敗しました。");
    }

    // 電文パス名を取得
    try {
      //
      Map<String, Map<String, Object>> dumpName = ObjectMapperUtil.readTypeReference(mstCoopFiletname.getDumpName(),
          new TypeReference<Map<String, Map<String, Object>>>(){});
      if (dumpName.containsKey("name")) {
        // KEY値nullチェック
        checkDatasetValue(dumpName.get("name"));
        // 電文パス名を取得
        reportFile.put(FileNames.DUMP_NAME.getKey(), getFileName(journal, dumpName.get("name")));
      }
    } catch (IOException e) {
      outputDebugLog(journal.getFacilityCd(), "parse error dump_name: " + mstCoopFiletname.getDumpName());
      throw new NtssException("電文パス名の取得に失敗しました。");
    }

    // 圧縮ファイル名を取得
    try {
      //
      Map<String, Map<String, Object>> compressionName = ObjectMapperUtil.readTypeReference(mstCoopFiletname.getCompressionName(),
          new TypeReference<Map<String, Map<String, Object>>>(){});
      if (compressionName.containsKey("name")) {
        // KEY値nullチェック
        checkDatasetValue(compressionName.get("name"));
        // 圧縮ファイル名を取得
        reportFile.put(FileNames.COMPRESSION_NAME.getKey(), getFileName(journal, compressionName.get("name")));
      }
    } catch (IOException e) {
      outputDebugLog(journal.getFacilityCd(), "parse error dump_name: " + mstCoopFiletname.getDumpName());
      throw new NtssException("圧縮ファイル名の取得に失敗しました。");
    }

    return reportFile;
  }

  /**
   * sys_data_setからファイル名を取得
   *
   * @param journal {@link SysCoopJournal} 外部連携用ジャーナル
   * @param dataSetMap 検索条件
   * @return ファイル名
   */
  private String getFileName(SysCoopJournal journal,  Map<String, Object> dataSetMap) {

    // リクエストパラメータに患者番号、オーダ番号の指定がある場合はジャーナル情報を流用する
    if (dataSetMap.containsKey(SYS_COOP_JOURNAL_COLUMN_BY_PAT_ID)) {
      dataSetMap.replace(SYS_COOP_JOURNAL_COLUMN_BY_PAT_ID, String.valueOf(journal.getPatId()));
    }
    if (dataSetMap.containsKey(SYS_COOP_JOURNAL_COLUMN_BY_ORD_NO)) {
      dataSetMap.replace(SYS_COOP_JOURNAL_COLUMN_BY_ORD_NO, String.valueOf(journal.getOrdNo()));
    }
    // add 2021-03-19 外部連携：定時一括送信機能の複数データの対応。 孫 start
    if (dataSetMap.containsKey(SYS_COOP_JOURNAL_COLUMN_BY_FACILITY_CD)) {
      dataSetMap.replace(SYS_COOP_JOURNAL_COLUMN_BY_FACILITY_CD, String.valueOf(journal.getFacilityCd()));
    }
    // add 2021-03-19 外部連携：定時一括送信機能の複数データの対応。 孫 end
    // add 2021-10-19 #5890:Medicom連携ができない(検査オーダ(exam_ord)) 孫 start
    if (dataSetMap.containsKey(SYS_COOP_JOURNAL_COLUMN_BY_CTL_NO)) {
      dataSetMap.replace(SYS_COOP_JOURNAL_COLUMN_BY_CTL_NO, String.valueOf(journal.getCtlNo()));
    }
    // add 2021-10-19 #5890:Medicom連携ができない(検査オーダ(exam_ord)) 孫 end
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    if (dataSetMap.containsKey(SYS_COOP_JOURNAL_COLUMN_BY_KEY0)) {
      dataSetMap.replace(SYS_COOP_JOURNAL_COLUMN_BY_KEY0, String.valueOf(journal.getKey0()));
    }
    if (dataSetMap.containsKey(SYS_COOP_JOURNAL_COLUMN_BY_COOP_VERSION)) {
      dataSetMap.replace(SYS_COOP_JOURNAL_COLUMN_BY_COOP_VERSION, String.valueOf(journal.getCoopVersion()));
    }
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    // apiを使用してsys_data_setを取得
    JournalConvertSendDataSetRequest request = new JournalConvertSendDataSetRequest(dataSetMap);
    List<Map<String, Object>> dataSetResultList = requestNtssApi(request);

    // filenameがない場合はnullを返す
    if (dataSetResultList.isEmpty() || !dataSetResultList.get(0).containsKey("filename")) {
      return null;
    }

    return String.valueOf(dataSetResultList.get(0).get("filename"));
  }

  /**
   * ログ出力
   *
   * @param level {@link LogLevel} ログレベル
   * @param facilityCd 施設コード
   * @param message ログメッセージ
   */
  private void outputLog(LogLevel level, String facilityCd, String message) {
    EventLogMessage elm = new EventLogMessage();
    elm.setFacilityCd(facilityCd);
    elm.setLogMessage(message);
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    elm.setInvokeClass(this.getClass().getName());
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    logService.log(level, elm, null, SERVICE_NAME.FNSI, null);
  }

  /**
   * エラーログ出力
   *
   * @param facilityCd 施設コード
   * @param message ログメッセージ
   */
  private void outputDebugLog(String facilityCd, String message) {
    outputLog(LogLevel.DEBUG, facilityCd, message);
  }

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
  // DB更新ログ出力ロジック wangzuo End
}
