package jp.co.nikkiso.ntss.coop_api.web.websocket;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.core.dao.MstIfEdgeDao;
import jp.co.nikkiso.ntss.core.entity.MstIfEdge;
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
import jp.co.nikkiso.ntss.coop_api.request.WebSocketDataSetRequest;
import jp.co.nikkiso.ntss.coop_api.response.SysDataSetResult;
import jp.co.nikkiso.ntss.coop_api.service.LogService;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MstCoopFacilityDao;
import jp.co.nikkiso.ntss.core.entity.MstCoopFacility;
import jp.co.nikkiso.ntss.core.entity.MstCoopFacility.CommonSetting;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import lombok.AllArgsConstructor;
import lombok.Getter;


public class IFEdgeDataSetHandler extends TextWebSocketHandler {

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

  /**
   * 連携設定マスタDAO
   */
  @Autowired
  private MstCoopFacilityDao mstCoopFacilityDao;

  // add 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 start
  /**
   * 連携エッジマスタDao
   */
  @Autowired
  private MstIfEdgeDao mstIfEdgeDao;
  // add 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 end

  /**
   * テキスト分割の最大バイト数(KByte)
   */
  @Value("${websocket.split.size}")
  private Integer splitSize;

  /** デフォルトの上限値 */
  private final Integer DEFAULT_LIMIT = 1000;

  /**
   * DataKeyの定数定義
   * */
  @Getter
  @AllArgsConstructor
  private enum ConstDataKey {
    /** 施設コード(facility_cd) */
    FACILITY_CD("facility_cd"),
    /** 上限値(limit) */
    LIMIT("limit"),
    // add 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 start
    /** シリアル番号(serial_no) */
    SERIAL_NO("serial_no"),
    // add 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 end

    SSECCAYEK("SSECCAYEK");
    
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
    eventLogMessage.setLogMessage("connected. [LocalAddress:"+ session.getLocalAddress() +"][sessionId: " +  session.getId() + "][url:" + session.getUri() + "]");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
  }

  /**
   * 接続終了時
   *
   * @param session Websocketセッション
   * @param status クローズステータス
   * @throws Exception
   */
  @Override
  public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("disconnected. [LocalAddress:"+ session.getLocalAddress() +"][sessionId: " +  session.getId() + "][url:" + session.getUri() + "]");
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
    eventLogMessage.setLogMessage("received message. [LocalAddress:"+ session.getLocalAddress() +"][sessionId: " +  session.getId() + "][url:" + session.getUri() + "]");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    eventLogMessage.setLogMessage("message[" +  message.getPayload() + "]");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    CloseStatus status = CloseStatus.NORMAL;
    SysDataSetResult resultMessage = null;
    try {
      // data-set処理
      WebSocketDataSetRequest dataSetRequest = ObjectMapperUtil.read(message.getPayload(),
          WebSocketDataSetRequest.class);
      if (dataSetRequest.getSqlCode() == null || dataSetRequest.getDataKey() == null) {
        throw new NtssException(String.format("引数が不正です。sqlCode:[%s],dataKey:[%s]", dataSetRequest.getSqlCode(), dataSetRequest.getDataKey()));
      }

      // add 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 start
      Map<String, Object> dataKey = dataSetRequest.getDataKey();
      // facility_cdを取得
      String facilityCd = "";
      // serial_noを取得
      String serialNo = "";

      /* modify by chamaojia 2024-06-24 [10574] communication security related additions --start */
      String seccayek = "";
      if (dataKey != null && !dataKey.isEmpty() && dataKey.size() != 0) {
        facilityCd = (String)dataKey.get(ConstDataKey.FACILITY_CD.getKey());
        serialNo = (String)dataKey.get(ConstDataKey.SERIAL_NO.getKey());
        seccayek = (String)dataKey.get(ConstDataKey.SSECCAYEK.getKey());
      }

      // マスタ（mst_if_edge）から、施設と使用するエッジとの紐づけはマスタ（mst_if_edge）がありか？
      MstIfEdge mstIfEdge = mstIfEdgeDao.selectByFacilityCdSerialNo(facilityCd, serialNo);
      if (mstIfEdge == null || !NODE_KEY_VALUE.equals(seccayek)) {
        throw new NtssException(String.format("施設と使用するエッジとの紐づけはマスタ（mst_if_edge）に存在しません。施設コード:[%s],シリアル番号:[%s]", facilityCd, serialNo));
      }
      /* modify by chamaojia 2024-06-24 [10574] communication security related additions --end */
      // add 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 end

      // 制限値の取得
      setDataSetLimit(dataSetRequest.getDataKey());

      // sys_data_setの検索
      List<Map<String, Object>> dataSetResponse = sysDataSetService.getDataList(dataSetRequest.getSqlCode(),
          dataSetRequest.getDataKey(), UseApplication.SHARE_VIEW);

      // 結果を成型
      resultMessage = resultMessage(HttpStatus.OK, "正常終了", dataSetResponse);

    } catch (NtssException e) {
      String error = StringUtils.isEmpty(e.getMessage()) ? "データセットの取得に失敗しました。" : e.getMessage();
      resultMessage = resultMessage(HttpStatus.INTERNAL_SERVER_ERROR, error);
      status = CloseStatus.SERVER_ERROR;
    } catch (Exception e) {
      String error = String.format("予期せぬエラーが発生しました。[%s]", e.toString());
      resultMessage = resultMessage(HttpStatus.INTERNAL_SERVER_ERROR, error);
      status = CloseStatus.SERVER_ERROR;
    } finally {
      // 結果を送信
      List<TextMessage> list = createResponse(resultMessage);
      for (TextMessage text : list) {
        session.sendMessage(text);
      }
      // セッションクローズ
      session.close(status);
    }
  }

  /**
   * datasetの検索時の上限値を設定
   *
   * @param dataKey データキー
   * */
  private void setDataSetLimit(Map<String, Object> dataKey) {

    int limit = 0;
    // facility_cdを取得
    String facilityCd = (String)dataKey.get(ConstDataKey.FACILITY_CD.getKey());
    if (StringUtils.isEmpty(facilityCd)) {
      // datakeyに施設コードが設定されていない場合はデフォルトを設定
      limit = DEFAULT_LIMIT;
    } else {
      // 連携設定マスタから取得
      limit = getMstCoopFacilityDatasetLimit(facilityCd);
    }
    // 検索時の上限値を設定
    dataKey.put(ConstDataKey.LIMIT.getKey(), limit);
  }

  /**
   * 連携設定マスタよりsys_data_set検索時の上限値を取得
   *
   * @param facilityCd 施設コード
   * @return 検索時の上限値
   */
  private Integer getMstCoopFacilityDatasetLimit(String facilityCd) {
    // 連携設定マスタ検索
    MstCoopFacility coopFacility = mstCoopFacilityDao.select(facilityCd);
    if (coopFacility == null) {
      // 連携設定マスタが設定されていない場合はデフォルトを設定
      return DEFAULT_LIMIT;
    } else {
      // 施設別共通設定から上限値を取得する
      CommonSetting cs = coopFacility.getCommonSetting();
      if (cs == null || cs.getDatasetLimit() == null) {
        // 上限値が取得できない場合はデフォルトを設定
        return DEFAULT_LIMIT;
      } else {
        // 設定されている場合、上限値を取得
        return cs.getDatasetLimit();
      }
    }
  }

  /**
   * 返却用形式に変換
   *
   * @param status HttpStatus
   * @param message メッセージ
   * @param datasetList データセットリスト
   * @return Response形式のMap
   * */
  private SysDataSetResult resultMessage(HttpStatus status, String message, List<Map<String, Object>> datasetList) {
    SysDataSetResult result = new SysDataSetResult(status.value(), message, datasetList);
    return result;
  }

  /**
   * 返却用形式に変換
   *
   * @param status HttpStatus
   * @param message メッセージ
   * @return  Response形式のMap
   * */
  private SysDataSetResult resultMessage(HttpStatus status, String message) {
    List<Map<String, Object>> datasetList = new ArrayList<>();
    return resultMessage(status, message, datasetList);
  }

  /**
   * JSON形式でWebSocketのTextMessageに変更
   *
   * @param map Response形式のMap
   * @return websocket用TextMessage
   * */
  private List<TextMessage> createResponse(SysDataSetResult map) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    List<TextMessage> list = new ArrayList<>();
    try {
      // JSON形式に変更
      String response = ObjectMapperUtil.write(map);
      // サイズの計算 [KByte → splitSize * 1024]
      int byteSize = splitSize * 1024;
      // 指定サイズでTextMessageに変換
      for (String value : substringByte(response, byteSize, JournalConvertConstants.ENCODING_BY_UTF8)) {
        list.add(new TextMessage(value, false));
      }
      // メッセージの終了レコード
      list.add(new TextMessage(""));
    } catch (Exception e) {
      eventLogMessage.setLogMessage(String.format("websocketへの送信テキストの作成に失敗しました。%s", e));
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      SysDataSetResult error = resultMessage(HttpStatus.INTERNAL_SERVER_ERROR, "websocketへの送信テキストの作成に失敗しました。");
      try {
        // JSON形式に変換
        String response = ObjectMapperUtil.write(error);
        list.add(new TextMessage(response));
      } catch (IOException e1) {
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
   * @param size 切り出し最大サイズ
   * @param charset 文字コード
   * @return List<String> 最大サイズ単位で切り出した文字列リスト
   * */
  private List<String> substringByte(String targetStr, int size, String charset) {

    List<String> msgList = new ArrayList<>();
    StringBuffer sb = new StringBuffer();
    int cnt = 0;

    try {
      for (int i=0; i<targetStr.length(); i++) {
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
    } catch (UnsupportedEncodingException e) {
      throw new NtssException("テキスト分割に失敗しました。", e);
    }
    return msgList;
  }
}
