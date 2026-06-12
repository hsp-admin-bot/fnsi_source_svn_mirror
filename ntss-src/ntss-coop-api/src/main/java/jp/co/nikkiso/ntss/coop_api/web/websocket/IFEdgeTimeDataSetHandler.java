package jp.co.nikkiso.ntss.coop_api.web.websocket;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.StringWriter;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;
import java.util.Arrays;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import jakarta.annotation.Resource;

import org.apache.commons.codec.binary.Hex;
import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVPrinter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.util.StringUtils;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import jp.co.nikkiso.ntss.api.service.SysDataSetService;
import jp.co.nikkiso.ntss.api.service.SysDataSetServiceImpl.UseApplication;
import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.request.WebSocketTimeDataSetRequest;
import jp.co.nikkiso.ntss.coop_api.response.SysDataSetResult;
import jp.co.nikkiso.ntss.coop_api.service.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MstCoopFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstIfEdgeDao;
import jp.co.nikkiso.ntss.core.entity.MstIfEdge;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import lombok.AllArgsConstructor;
import lombok.Getter;


public class IFEdgeTimeDataSetHandler extends TextWebSocketHandler {

  private final String NODE_KEY_VALUE = "NTSS-NKK-ESM-TDC-YSK-NODE";

  /**
   * データセットService.
   */
  @Autowired
  private SysDataSetService sysDataSetService;

  /**
   * ロギングのServiceインタフェース.
   */
  @Autowired
  private LogService logService;

  // add 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 start
  /**
   * 連携エッジマスタDao
   */
  @Resource
  private MstIfEdgeDao mstIfEdgeDao;
  // add 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 end

  // add 2021-08-02 定時の外部viewのタイムアウト処理の対応 孫 start
  /**
   * 連携エッジマスタDao
   */
  @Resource
  MstCoopFacilityDao mstCoopFacilityDao;

  /**
   * テキスト分割の最大バイト数(KByte)
   */
  @Value("${websocket.split.size}")
  private Integer splitSize;

  /* del by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  // // Update 差分機能追加 sichengbo start
  // boolean isFirst;
  // // Update 差分機能追加 sichengbo end
  /* del by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

  /**
   * DataKeyの定数定義
   */
  @Getter
  @AllArgsConstructor
  private enum ConstDataKey {
    /**
     * 施設コード(facilityCd)
     */
    FACILITY_CD("facilityCd"),
    // add 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 start
    /**
     * シリアル番号(serial_no)
     */
    SERIAL_NO("serialNo"),
    // add 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 end

    SSECCAYEK("SSECCAYEK"),

    NODERED_TIME_OUT("noderedTimeOut");

    // フィールド変数
    private final String key;
  }

  /**
   * 接続完了時
   *
   * @param session Websocketセッション
   * @throws Exception
   */
  @Override
  public void afterConnectionEstablished(WebSocketSession session) throws Exception {
    EventLogMessage eventLogMessage = new EventLogMessage();
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    eventLogMessage.setLogMessage("connected. [LocalAddress:" + session.getLocalAddress() + "][sessionId: " + session.getId() + "][url:" + session.getUri() + "]");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
  }

  /**
   * 接続終了時
   *
   * @param session Websocketセッション
   * @param status  クローズステータス
   * @throws Exception
   */
  @Override
  public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
    EventLogMessage eventLogMessage = new EventLogMessage();
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    eventLogMessage.setLogMessage("disconnected. [LocalAddress:" + session.getLocalAddress() + "][sessionId: " + session.getId() + "][url:" + session.getUri() + "]");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
  }

  /**
   * テキスト受信時<br>
   * 受信したテキストを元に data-set処理を呼び出し、結果をテキストにして返す
   *
   * @param session セッション
   * @param message IFEdgeから送信されたdata-setリクエスト（JSON形式の文字列）
   * @throws IOException
   */
  @Override
  protected void handleTextMessage(WebSocketSession session, TextMessage message) throws IOException {

    EventLogMessage eventLogMessage = new EventLogMessage();
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    eventLogMessage.setLogMessage("received message. [LocalAddress:" + session.getLocalAddress() + "][sessionId: " + session.getId() + "][url:" + session.getUri() + "]");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    eventLogMessage.setLogMessage("message[" + message.getPayload() + "]");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    CloseStatus status = CloseStatus.NORMAL;
    SysDataSetResult resultMessage = null;

    Long noderedTimeOut = 0L;
    try {
      WebSocketTimeDataSetRequest dataSetRequestNoderedTimeOut = ObjectMapperUtil.read(message.getPayload(),WebSocketTimeDataSetRequest.class);
      Map<String, Object> dataKeyNoderedTimeOut = dataSetRequestNoderedTimeOut.getDataKey();
      // add 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 end
      if (dataKeyNoderedTimeOut != null && !dataKeyNoderedTimeOut.isEmpty() && dataKeyNoderedTimeOut.size() != 0) {

        noderedTimeOut = Long.valueOf((String) dataKeyNoderedTimeOut.get(ConstDataKey.NODERED_TIME_OUT.getKey()));
      }
    } catch (Exception e) {
      eventLogMessage.setLogMessage(e.toString());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }

    // data-set処理
    ExecutorService executor = Executors.newFixedThreadPool(1);
    Callable myCallable = new Callable() {
      @Override
      public SysDataSetResult call() throws NtssException, Exception {

        try {
          // data-set処理
          WebSocketTimeDataSetRequest dataSetRequest = ObjectMapperUtil.read(message.getPayload(),
            WebSocketTimeDataSetRequest.class);
          // mod 2021-01-28 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 start
    //      if (dataSetRequest.getSqlCode() == null || dataSetRequest.getDataKey() == null) {
          List<WebSocketTimeDataSetRequest.Table> tables = dataSetRequest.getTables();
          /* del by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
          // // Update 差分機能追加 sichengbo start
          // isFirst = dataSetRequest.getTables().get(0).isFirst();
          // // Update 差分機能追加 sichengbo end
          /* del by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
          Map<String, Object> dataKey = dataSetRequest.getDataKey();
          // facility_cdを取得
          String facilityCd = "";
          // add 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 start
          // serial_noを取得
          String serialNo = "";
          // add 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 end
          Long noderedTimeOut = 0L;

          /* modify by chamaojia 2024-06-24 [10574] communication security related additions --start */
          String seccayek = "";
          if (dataKey != null && !dataKey.isEmpty() && dataKey.size() != 0) {
            facilityCd = (String) dataKey.get(ConstDataKey.FACILITY_CD.getKey());
            serialNo = (String) dataKey.get(ConstDataKey.SERIAL_NO.getKey());
            noderedTimeOut = Long.valueOf((String) dataKey.get(ConstDataKey.NODERED_TIME_OUT.getKey()));
            seccayek = (String)dataKey.get(ConstDataKey.SSECCAYEK.getKey());
          }
          if (tables == null || tables.size() == 0
            || dataKey == null || dataKey.isEmpty() || dataKey.size() == 0
            || StringUtils.isEmpty(facilityCd)) {
            // mod 2021-01-28 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 end
            // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
            // ログメッセージ出力
            // mod 2021-01-28 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 start
    //        eventLogMessage.setLogMessage(String.format("引数が不正です。sqlCode:[%s],dataKey:[%s]", dataSetRequest.getSqlCode(), dataSetRequest.getDataKey()));
            eventLogMessage.setLogMessage(String.format("引数が不正です。tables:[%s],dataKey:[%s]", tables, dataKey));
            // mod 2021-01-28 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 end
            eventLogMessage.setInvokeClass(this.getClass().getName());
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
            // mod 2021-01-28 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 start
    //        throw new NtssException(String.format("引数が不正です。sqlCode:[%s],dataKey:[%s]", dataSetRequest.getSqlCode(), dataSetRequest.getDataKey()));
            throw new NtssException(String.format("引数が不正です。tables:[%s],dataKey:[%s]", tables, dataKey));
            // mod 2021-01-28 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 end
          }

          // add 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 start
          // マスタ（mst_if_edge）から、施設と使用するエッジとの紐づけはマスタ（mst_if_edge）がありか？
          MstIfEdge mstIfEdge = mstIfEdgeDao.selectByFacilityCdSerialNo(facilityCd, serialNo);
          if (mstIfEdge == null || !NODE_KEY_VALUE.equals(seccayek)) {
            throw new NtssException(String.format("施設と使用するエッジとの紐づけはマスタ（mst_if_edge）に存在しません。施設コード:[%s],シリアル番号:[%s]", facilityCd, serialNo));
          }
          /* modify by chamaojia 2024-06-24 [10574] communication security related additions --end */
          // add 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 end

          // add 2021-08-02 定時の外部viewのタイムアウト処理の対応 孫 start

          // Zipファイル名を作成する
          //String fileTime = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmssSSS"));
          String fileTime = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmssSSS"));
          String zipFileName = "View_" + Thread.currentThread().getId() + "_" + fileTime;

          // ZIPファイルの準備
          File zipFile = null;
          String zipFilePath = null;
          FileOutputStream fos = null;
          ZipOutputStream zos = null;

          try {
            // Zip圧縮ファイルを作成
            zipFile = File.createTempFile(zipFileName, ".zip");
            zipFilePath = zipFile.getPath();

            fos = new FileOutputStream(zipFile);
            zos = new ZipOutputStream(fos);
            // #7431 ローカルDBへの削除処理がない start
            Map<String, Object> tblDataKeyTemp = new HashMap<>();
    //        boolean isDelete = false;
            // #7431 ローカルDBへの削除処理がない end
            for (int index = 0; index < tables.size(); index++) {
              // 一つ更新Table
              WebSocketTimeDataSetRequest.Table oneTable = tables.get(index);
              // テーブル名
              String tblName = oneTable.getTblName();
              // SQLCD のリスト
              List<Long> sqlcds = oneTable.getSqlCds();
              // 日付.(fromDateとtoDate)
              Map<String, Object> tblDataKey = oneTable.getDataKey();
              tblDataKey.put(ConstDataKey.FACILITY_CD.getKey(), facilityCd);
              // #7431 ローカルDBへの削除処理がない start
              tblDataKeyTemp = tblDataKey;
              // #7431 ローカルDBへの削除処理がない end
              List<Map<String, Object>> dataSetResponse = new ArrayList<Map<String, Object>>();

              // データ取得失敗テーブル情報
              Map<String, Object> errorTable = new HashMap<String, Object>();
              // #7431 ローカルDBへの削除処理がない start
    //          if ("V_RST_DIALYSIS".equals(tblName) || "V_RST_DIALYSIS_COND".equals(tblName) || "V_RST_DIALYSIS_EQUIP".equals(tblName)||
    //            "V_RST_DIALYSIS_MEDI".equals(tblName) || "V_RST_DIALYSIS_ADD".equals(tblName) || "V_RST_RECEIPT_MEMO".equals(tblName)||
    //            "V_SCH_DIALYSIS_PLAN".equals(tblName) || "V_IND_DIALYSIS_COND".equals(tblName) || "V_IND_DIALYSIS_EQUIP".equals(tblName)||
    //            "V_IND_DIALYSIS_MEDI".equals(tblName) || "V_IND_DIALYSIS_ADD".equals(tblName)){
    //            isDelete = true;
    //          }
    //          if ("V_RST_DIALYSIS".equals(tblName)
    //            || "V_RST_DIALYSIS_COND".equals(tblName)
    //            || "V_RST_DIALYSIS_EQUIP".equals(tblName)
    //            || "V_RST_DIALYSIS_MEDI".equals(tblName)
    //            || "V_RST_DIALYSIS_ADD".equals(tblName)
    //            || "V_RST_RECEIPT_MEMO".equals(tblName)){
    //            isDelete = true;
    //          }
              // #7431 ローカルDBへの削除処理がない end

              // SQLCDが無し
              if (sqlcds == null || sqlcds.size() == 0 || StringUtils.isEmpty(tblName)) {
                String error = String.format("引数が不正です。tblName:[%s],sqlcds:[%s]", tblName, sqlcds.toString());
                // データ取得失敗テーブル情報を追加
                errorTable.put("table", tblName);
                errorTable.put("message", error);
                dataSetResponse.clear();
                dataSetResponse.add(errorTable);
              } else {

                dataSetResponse = dataConvert(sqlcds, tblDataKey, tblName, noderedTimeOut);
                // テーブル名
                String keyName = oneTable.getKeyName();

                // ZIPファイルに一時ファイルを追加する。
                String fileName = keyName + "_" + fileTime + ".csv";
                zos.putNextEntry(new ZipEntry(fileName));

                eventLogMessage.setLogMessage("VIEW連携レスポンスデータ CSV変換処理開始" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmssSSS")));
                logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
                // データをCSV化する
                String response = generateCSVString(dataSetResponse);
                eventLogMessage.setLogMessage("VIEW連携レスポンスデータ CSV変換処理終了" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmssSSS")));
                logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

                eventLogMessage.setLogMessage("VIEW連携レスポンスデータ byte配列変換処理開始");
                logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
                // データをbyte[]する
                byte[] bytes = response.getBytes(Charset.forName("sjis"));
                eventLogMessage.setLogMessage("VIEW連携レスポンスデータ byte配列変換処理終了");
                logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

                eventLogMessage.setLogMessage("VIEW連携レスポンスデータ zip書き込み処理開始");
                logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
                zos.write(bytes, 0, bytes.length);
                eventLogMessage.setLogMessage("VIEW連携レスポンスデータ zip書き込み処理終了");
                logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
              }
              //#dev 6304 ローカルDBへの登録に失敗する sichengbo end
            }

            // #7431 ローカルDBへの削除処理がない start
    //        if (isDelete){ //削除機能
    //          String fileName = "DeleteByDialysisNo" + "_" + fileTime + ".dat";
    //          zos.putNextEntry(new ZipEntry(fileName));
    //          this.createDeleteResultData(zos,tblDataKeyTemp);
    //        }
            // #7431 ローカルDBへの削除処理がない end

          } catch (Exception ex) {
            eventLogMessage.setLogMessage(ex.toString());
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            throw ex;
          } catch (Throwable t) {
            eventLogMessage.setLogMessage(t.toString());
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            throw t;
          } finally {
            try {
              if (null != zos) {
                zos.close();
              }

              if (null != fos) {
                fos.close();
              }
            } catch (Exception e4) {
              eventLogMessage.setLogMessage(e4.toString());
              logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            }
          }

          eventLogMessage.setLogMessage("VIEW連携レスポンスデータ 結果データセットリスト作成処理開始");
          logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          // 結果データセットリストを作成する
          List<Map<String, Object>> zipData = GetResultDataSetList(zipFilePath, zipFileName);
          eventLogMessage.setLogMessage("VIEW連携レスポンスデータ 結果データセットリスト作成処理終了");
          logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

          // 結果を成型
          return resultMessage(HttpStatus.OK, "正常終了", zipData);
        } catch (NtssException e) {
          eventLogMessage.setLogMessage(Arrays.toString(e.getStackTrace()));
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          return resultMessage(HttpStatus.INTERNAL_SERVER_ERROR, "データセットの取得に失敗しました。");
        } catch (Exception e) {
          eventLogMessage.setLogMessage(Arrays.toString(e.getStackTrace()));
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          return resultMessage(HttpStatus.INTERNAL_SERVER_ERROR, "予期せぬエラーが発生しました。");
        }
      }
    };

    Future<SysDataSetResult> future = executor.submit(myCallable);
    try {
      if(noderedTimeOut == 0L){
        resultMessage = future.get();
      }else{
        resultMessage = future.get(noderedTimeOut, TimeUnit.MILLISECONDS);
      }
    } catch (TimeoutException e) {
      future.cancel(true);

      eventLogMessage.setLogMessage(Arrays.toString(e.getStackTrace()));
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      String error = String.format("連携エッジタイムアウト時間%dミリ秒を超えました。", noderedTimeOut);
      resultMessage = resultMessage(HttpStatus.GATEWAY_TIMEOUT, error);
    } catch (Exception e) {
      eventLogMessage.setLogMessage(Arrays.toString(e.getStackTrace()));
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      status = CloseStatus.SERVER_ERROR;
    } finally {
      executor.shutdown();

      if(resultMessage.getStatus() != HttpStatus.OK.value()){
        status = CloseStatus.SERVER_ERROR;
      eventLogMessage.setInvokeClass(this.getClass().getName());
      eventLogMessage.setLogMessage(resultMessage.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }else{
        eventLogMessage.setInvokeClass(this.getClass().getName());
        eventLogMessage.setLogMessage(resultMessage.getMessage());
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }
      eventLogMessage.setLogMessage("VIEW連携レスポンスデータ JSON形式のWebSocketのTextMessageに変換処理開始");
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // 結果を送信
      List<TextMessage> list = createResponse(resultMessage);
      eventLogMessage.setLogMessage("VIEW連携レスポンスデータ JSON形式のWebSocketのTextMessageに変換処理処理終了");
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      for (TextMessage text : list) {
        session.sendMessage(text);
      }
      // セッションクローズ
      session.close(status);
    }
  }

//  /**
//   *
//   * @param zos ファイルフロー
//   * @param tblDataKey 日付.(fromDateとtoDate)
//   * @throws IOException
//   */
//  private void createDeleteResultData(ZipOutputStream zos,Map<String, Object> tblDataKey) throws IOException {
//    List<Map<String, Object>> deleteDataList = sysDataSetService.getDataListSpecialTreatment(-2499L, tblDataKey,
//      UseApplication.SHARE_VIEW, 0, 0);
//    List<Long> list = new ArrayList<>();
//    String ordNoString = "";
//
//    if (deleteDataList.size()>0){
//      for (int i = 0; i<deleteDataList.size(); i++){
//        list.add(Long.valueOf(String.valueOf(deleteDataList.get(i).get("ord_no"))));
//      }
//      list = list.stream().distinct().collect(Collectors.toList());
//      ordNoString = list.toString().replace("[","").replace("]","");
//    }
//
//    List dataList = new ArrayList();
//    Map dataMap = new HashMap();
//    dataMap.put("DIALYSIS_NO",ordNoString);
//    dataList.add(dataMap);
//
//    String response = ObjectMapperUtil.write(dataList);
//    byte[] bytes = response.getBytes();
//    zos.write(bytes, 0, bytes.length);
//  }

  /**
   * データコンバート
   *
   * @param sqlcds SQLCDのリスト
   * @param tblDataKey 日付.(fromDateとtoDate)
   * @param tblName テーブル名
   * @return コンバートしたデータ
   */
  private List<Map<String, Object>> dataConvert(List<Long> sqlcds, Map<String, Object> tblDataKey, String tblName,Long noderedTimeOut) throws Exception{
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setInvokeClass(this.getClass().getName());

    List<Map<String, Object>> dataSetResponse = new ArrayList<Map<String, Object>>();

    // データ取得失敗テーブル情報
    Map<String, Object> errorTable = new HashMap<String, Object>();

    try {

      // SQLCDが有り場合
      for (int indexSql = 0; indexSql < sqlcds.size(); indexSql++) {
        Long sqlcd = sqlcds.get(indexSql);
        List<Map<String, Object>> dataSetResponseTmp = new ArrayList<Map<String, Object>>();
        dataSetResponseTmp = sysDataSetService.getDataListContainsError(sqlcd,tblDataKey, UseApplication.SHARE_VIEW, ((int) noderedTimeOut.longValue())/1000);

        if (dataSetResponseTmp != null && dataSetResponseTmp.size() == 1) {
          Map<String, Object> map = dataSetResponseTmp.get(0);
          if (map.containsKey("error")) {
            throw new NtssException(String.valueOf(map.get("error")));
          }
        }

        // 主SqlCdで、データが無し場合、ループを終了
        if (0 == indexSql && dataSetResponseTmp.size() == 0) {
          break;
        }

        // データマージ
        String mergeKey = sysDataSetService.getMergeKeyForSqlCode(sqlcd);
        dataSetResponse = mergeSlaveToMaster(dataSetResponse, dataSetResponseTmp, mergeKey,
          sqlcds.get(0), sqlcds.get(indexSql));
        /* del by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
        // for (Map map : dataSetResponse) {
        //   map.put("isFirst", isFirst);
        // }
        /* del by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
      }
    } catch (NtssException e) {
      eventLogMessage.setLogMessage(e.toString());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // String error = StringUtils.isEmpty(e.getMessage()) ? "データセットの取得に失敗しました。" : e.getMessage();
      String error = "データセットの実行時にエラーが発生しました。";
      throw new NtssException(error);
    } catch (Exception e) {
      eventLogMessage.setLogMessage(e.toString());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      String error = "データセットの実行時にエラーが発生しました。";
      // throw new Exception(e);
      throw new Exception(error);
    }

    return dataSetResponse;
  }

  public static <T> List<List<T>> partition(List<T> list, int batchSize) {
    if (batchSize <= 0) {
      throw new IllegalArgumentException("batchSize must be greater than 0");
    }
    int size = list.size();
    int numBatches = (size + batchSize - 1) / batchSize;
    List<List<T>> batches = new ArrayList<>(numBatches);
    for (int i = 0; i < size; i += batchSize) {
      int end = Math.min(size, i + batchSize);
      List<T> batch = list.subList(i, end);
      batches.add(batch);
    }
    return batches;
  }

  // add 2021-01-28 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 start

  /**
   * データマージ
   *
   * @param masterMapList 主データ
   * @param slaveMapList  従データ
   * @param mergeKey      マージキー
   * @param masterSqlCode 主SqlCode
   * @param slaveSqlCode  従SqlCode
   * @return マージしたデータ
   */
  private List<Map<String, Object>> mergeSlaveToMaster(
    List<Map<String, Object>> masterMapList, List<Map<String, Object>> slaveMapList,
    String mergeKey, Long masterSqlCode, Long slaveSqlCode) throws NtssException {

    // 主データがNULL場合、従データを戻る
    if (masterMapList.size() == 0) {
      return slaveMapList;
    }

    // 従データがNULL場合、主データを戻る
    if (slaveMapList.size() == 0) {
      return masterMapList;
    }

    // マージキーが無し
    String[] keyList = mergeKey.replace("\"", "").replace(" ", "").split(",");
    if (keyList.length == 0) {
      throw new NtssException("指定されたsqlCodeにマージキー(memo)が不正。sqlCd:" + slaveSqlCode + ",memoのMergeKey[" + mergeKey + "]");
    }

    /* add by chamaojia 2022-12-22 [6714] リスト集合データは事前にmapに変換され、後で取得するのに便利である  --start */
    Map<Map<String, Object>, Map<String, Object>> slaveAllMap = new HashMap<>();
    for (Map<String, Object> slaveMap : slaveMapList) {
      Map<String, Object> slaveKeyValue = new HashMap<>();
      for (String key : keyList) {
        if (slaveMap.containsKey(key)) {
          slaveKeyValue.put(key, slaveMap.get(key));
        } else {
          throw new NtssException("指定されたsqlCodeのSQLの項目にマージキー(memoのMergeKey)が無し。sqlCd[" + slaveSqlCode + "],MergeKey[" + key + "]");
        }
      }
      slaveAllMap.put(slaveKeyValue, slaveMap);
    }
    /* add by chamaojia 2022-12-22 [6714] リスト集合データは事前にmapに変換され、後で取得するのに便利である  --end */

    // マージ後データ
    List<Map<String, Object>> mergedMapList = new ArrayList<Map<String, Object>>();

    // 主データをループ
    for (int i = masterMapList.size() - 1; i >= 0; i--) {
      // 一つ主データを取得する
      Map<String, Object> masterMap = masterMapList.get(i);

      // 主データより、マージキーの値を取得する
      Map<String, Object> masterKeyValue = new HashMap<String, Object>();
      for (int k = 0; k < keyList.length; k++) {
        String tmpKey = keyList[k];
        if (masterMap.containsKey(tmpKey)) {
          masterKeyValue.put(tmpKey, masterMap.get(tmpKey));
        } else {
          throw new NtssException("指定されたsqlCodeのSQLの項目にマージキー(memoのMergeKey)が無し。sqlCd[" + masterSqlCode + "],MergeKey[" + tmpKey + "]");
        }
      }

      /* modify by chamaojia 2022-12-22 [6714] データをmapから取得するように変更  --start */
      Map<String, Object> mateMap = slaveAllMap.get(masterKeyValue);
      if (mateMap != null) {
        Map<String, Object> mapMerged = new LinkedHashMap<>();
        mapMerged.putAll(masterMap);

        // 一つ従データをループ
        for (String key : mateMap.keySet()) {
          // キー：従データと主データが一致の場合、値をマージ
          if (masterMap.containsKey(key)) {
            mapMerged.put(key, mateMap.get(key));
          } else {
            // ログメッセージ出力
            String error = String.format("sqlCode[%d]のSQLの項目[%s]はsqlCode[%d]のSQLの項目に存在しない", slaveSqlCode, key, masterSqlCode);
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setInvokeClass(this.getClass().getName());
            eventLogMessage.setLogMessage(error);
            logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          }
        }

        // マージ後データを追加する
        mergedMapList.add(mapMerged);
      } else {
        mergedMapList.add(masterMap);
      }

//      // 従データをループ
//      boolean slaveExists = false;
//      for (int j=slaveMapList.size()-1; j>=0; j--) {
//        // 一つ従データを取得する
//        Map<String, Object> slaveMap = slaveMapList.get(j);
//
//        // 従データより、マージキーの値を取得する
//        Map<String, Object> slaveKeyValue = new HashMap<String, Object>();
//        for (int k=0; k<keyList.length; k++){
//          String tmpKey = keyList[k];
//          if (slaveMap.containsKey(tmpKey)) {
//            slaveKeyValue.put(tmpKey, slaveMap.get(keyList[k]));
//          } else {
//            throw new NtssException("指定されたsqlCodeのSQLの項目にマージキー(memoのMergeKey)が無し。sqlCd[" + slaveSqlCode + "],MergeKey[" + tmpKey + "]");
//          }
//        }
//
//        // マージキーの値が一致の場合、主／従データをマージする
//        if (slaveKeyValue.equals(masterKeyValue)) {
//          Map<String, Object>  mapMerged = new LinkedHashMap<String, Object>();
//          mapMerged.putAll(masterMap);
//
//          // 一つ従データをループ
//          for(String key : slaveMap.keySet()){
//            // キー：従データと主データが一致の場合、値をマージ
//            if (masterMap.containsKey(key)) {
//              mapMerged.put(key, slaveMap.get(key));
//            } else {
//              // ログメッセージ出力
//              String error = String.format("sqlCode[{0}]のSQLの項目[{1}]はsqlCode[{2}]のSQLの項目に存在しない", slaveSqlCode, key, masterSqlCode);
//              EventLogMessage eventLogMessage = new EventLogMessage();
//              eventLogMessage.setInvokeClass(this.getClass().getName());
//              eventLogMessage.setLogMessage(error);
//              logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//            }
//          }
//
//          // マージ後データを追加する
//          mergedMapList.add(mapMerged);
//
//          slaveExists = true;
//          break;
//
////          // 従データから、一致データを削除する
////          slaveMapList.remove(j);
//        }
//      }
//
//      // 従データにデータが無しの場合、主データを追加する
//      if (!slaveExists) {
//        mergedMapList.add(masterMap);
//      }
      /* modify by chamaojia 2022-12-22 [6714] データをmapから取得するように変更  --end */
    }
    return mergedMapList;
  }

  /**
   * 結果データセットリストを作成する
   *
   * @param zipFilePath ZIPファイル
   * @param zipFileName ZIPファイル名
   * @return 結果データセットリスト
   */
  private List<Map<String, Object>> GetResultDataSetList(String zipFilePath, String zipFileName) throws IOException {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setInvokeClass(this.getClass().getName());
    List<Map<String, Object>> zipData = new ArrayList<Map<String, Object>>();

    // ZIPデータを作成する
    Map<String, Object> map = new HashMap<String, Object>();
    map.put("filename", zipFileName + ".zip");

    File outFile = null;
    FileInputStream fin = null;
    BufferedInputStream bis = null;
    try {
      outFile = new File(zipFilePath);
      fin = new FileInputStream(outFile);
      bis = new BufferedInputStream(fin);

      // ZIPデータが無し
      if (!outFile.exists()) {
        String error = "ZIPデータが無し。";
        throw new NtssException(error);
      }

      byte[] buffer = null;
      long fileLength = outFile.length();
      if (fileLength > Integer.MAX_VALUE) {
        buffer = new byte[Integer.MAX_VALUE];
      } else {
        buffer = new byte[(int) fileLength];
      }

      int cndDump = 0;
      int readLength = 0;
      while ((readLength = bis.read(buffer)) > 0) {
        byte[] bufferTmp = new byte[readLength];
        for (int i = 0; i < readLength; i++) {
          bufferTmp[i] = buffer[i];
        }
        map.put("dump" + String.format("%d", cndDump), new String(Hex.encodeHex(bufferTmp)));
        cndDump++;
      }
    } catch (Exception ex) {
      throw ex;
    } finally {
      try {
        if (null != bis) {
          bis.close();
        }
        if (null != fin) {
          fin.close();
        }
      } catch (Exception e4) {
        eventLogMessage.setLogMessage(e4.toString());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }

      // Zipファイルを削除する
      if (null != outFile) {
        outFile.delete();
      }
    }

    zipData.add(map);

    return zipData;
  }

  // add 2021-01-28 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 end

  /**
   * 返却用形式に変換
   *
   * @param status      HttpStatus
   * @param message     メッセージ
   * @param datasetList データセットリスト
   * @return Response形式のMap
   */
  private SysDataSetResult resultMessage(HttpStatus status, String message, List<Map<String, Object>> datasetList) {
    SysDataSetResult result = new SysDataSetResult(status.value(), message, datasetList);
    return result;
  }

  /**
   * 返却用形式に変換
   *
   * @param status  HttpStatus
   * @param message メッセージ
   * @return Response形式のMap
   */
  private SysDataSetResult resultMessage(HttpStatus status, String message) {
    List<Map<String, Object>> datasetList = new ArrayList<>();
    return resultMessage(status, message, datasetList);
  }

  /**
   * JSON形式でWebSocketのTextMessageに変更
   *
   * @param map Response形式のMap
   * @return websocket用TextMessage
   */
  private List<TextMessage> createResponse(SysDataSetResult map) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    List<TextMessage> list = new ArrayList<>();
    try {
      // JSON形式に変更
      String response = ObjectMapperUtil.write(map);
      // サイズの計算 [KByte → splitSize * 1024]
      int byteSize = splitSize * 1024;
      // 指定サイズでTextMessageに変換
      for (String value : substringByte(response, byteSize, Charset.forName("sjis"))) {
        list.add(new TextMessage(value, false));
      }
      // メッセージの終了レコード
      list.add(new TextMessage(""));
    } catch (Exception e) {
      eventLogMessage.setLogMessage(String.format("websocketへの送信テキストの作成に失敗しました。%s", e));
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      SysDataSetResult error = resultMessage(HttpStatus.INTERNAL_SERVER_ERROR, "websocketへの送信テキストの作成に失敗しました。");
      try {
        // JSON形式に変換
        String response = ObjectMapperUtil.write(error);
        list.add(new TextMessage(response));
      } catch (IOException e1) {
        eventLogMessage.setLogMessage(e1.toString());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        // 作成できない場合は空を返す
        list.add(new TextMessage(""));
      }
    }
    return list;
  }

  /**
   * 指定バイト数で文字列を切り出す
   *
   * @param targetStr 分割対象文字列
   * @param size      切り出し最大サイズ
   * @param charset   文字コード
   * @return List<String> 最大サイズ単位で切り出した文字列リスト
   */
  private List<String> substringByte(String targetStr, int size, Charset charset) {

    List<String> msgList = new ArrayList<>();
    StringBuffer sb = new StringBuffer();
    int cnt = 0;

      for (int i = 0; i < targetStr.length(); i++) {
        // 1文字切り出し
        String tmp = targetStr.substring(i, i + 1);
        // バイト変換
        byte[] bytes = tmp.getBytes(charset);
        if (cnt + bytes.length > size) {
          // 指定サイズを超えた場合
          // 文字列を設定
          msgList.add(sb.toString());

          // 初期化
          sb.setLength(0);
          sb.append(tmp);
          cnt = bytes.length;
        } else {
          sb.append(tmp);
          cnt += bytes.length;
        }
      }
      // 残りの文字列を追加
      msgList.add(sb.toString());

    return msgList;
  }


  public static String generateCSVString(List<Map<String, Object>> dataList) throws IOException {
      StringWriter stringWriter = new StringWriter();
      try (CSVPrinter printer = new CSVPrinter(stringWriter, CSVFormat.ORACLE)) {

      	String str =">゛j^q-(";

          // Write header
          if (!dataList.isEmpty()) {
              Map<String, Object> firstRow = dataList.get(0);

              for (String header:firstRow.keySet()) {

              	if(header != null) {
              		printer.print(header);
              	}
              }
              printer.print(str);
              printer.println();
          }

          // Write data
          for (Map<String, Object> row : dataList) {
              for (Map.Entry<String, Object> entry : row.entrySet()) {
                  Object value = entry.getValue();

                  if (value != null) {

                  	 printer.print(value.toString());
                  } else {
                      printer.print(""); // Handle null value
                  }
              }
              printer.print(str);
              printer.println();
          }
      }

      return stringWriter.toString();
  }

}
