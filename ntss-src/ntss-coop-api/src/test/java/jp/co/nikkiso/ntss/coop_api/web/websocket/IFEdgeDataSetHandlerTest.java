package jp.co.nikkiso.ntss.coop_api.web.websocket;

import static org.assertj.core.api.Assertions.fail;
import static org.mockito.Mockito.any;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.boot.test.mock.mockito.SpyBean;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;

import com.fasterxml.jackson.core.type.TypeReference;

import jp.co.nikkiso.ntss.api.service.SysDataSetService;
import jp.co.nikkiso.ntss.api.service.SysDataSetServiceImpl.UseApplication;
import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.response.SysDataSetResult;
import jp.co.nikkiso.ntss.core.exception.NtssException;

@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:resource.script/IFEdgeDataSetHandlerTest/IFEdgeDataSetHandlerTest.db5.before.sql")
public class IFEdgeDataSetHandlerTest {
  @SpyBean
  private IFEdgeDataSetHandler handler;

  @MockBean
  WebSocketSession session;

  @SpyBean
  SysDataSetService sysDataSetService;

  @Value("${websocket.split.size}")
  private Integer splitSize;

  /**
   * 上限値チェック
   *
   * 条件 : facility_cdがmst_coop_facilityに存在しない
   * 結果 : 上限値にデフォルトの1000が設定される
   * */
  @Test
  public void setDataSetLimit_facilityCdがmst_coop_facilityなしの場合() {
    final String requestStr = "{\"sqlCode\":1, \"dataKey\": {\"ordNo\":1, \"facility_cd\": \"000000\"}}";

    Map<String, Object> expect = new HashMap<>();
    expect.put("ordNo", 1);
    expect.put("facility_cd", "000000");
    expect.put("limit", 1000);  // 上限値

    try {
      TextMessage message = new TextMessage(requestStr);
      handler.handleTextMessage(session, message);

      // 呼出時の引数チェック
      verify(sysDataSetService, times(1)).getDataList(1L, expect, UseApplication.SHARE_VIEW);

    } catch (IOException e) {
      fail("想定外エラー");
    }
  }

  /**
   * 上限値チェック
   *
   * 条件 : facility_cdがmst_coop_facility.common_settingが未設定の場合
   * 結果 : 上限値にデフォルトの1000が設定される
   * */
  @Test
  public void setDataSetLimit_facilityCdありでmst_coop_facilityの共通設定なしの場合() {
    String requestStr = "{\"sqlCode\":1, \"dataKey\": {\"ordNo\":1, \"facility_cd\": \"000001\"}}";

    Map<String, Object> expect = new HashMap<>();
    expect.put("ordNo", 1);
    expect.put("facility_cd", "000001");
    expect.put("limit", 1000);     // 検索上限

    try {
      TextMessage message = new TextMessage(requestStr);
      handler.handleTextMessage(session, message);

      // 呼出時の引数チェック
      verify(sysDataSetService, times(1)).getDataList(1L, expect, UseApplication.SHARE_VIEW);

    } catch (IOException e) {
      fail("想定外エラー");
    }
  }

  /**
   * 上限値チェック
   *
   * 条件 : facility_cdがmst_coop_facility.common_settingが上限値が未設定の場合
   * 結果 : 上限値にデフォルトの1000が設定される
   * */
  @Test
  public void setDataSetLimit_facilityCdありでmst_coop_facilityの共通設定に上限値なしの場合() {
    String requestStr = "{\"sqlCode\":1, \"dataKey\": {\"ordNo\":1, \"facility_cd\": \"000002\"}}";

    Map<String, Object> expect = new HashMap<>();
    expect.put("ordNo", 1);
    expect.put("facility_cd", "000002");
    expect.put("limit", 1000);     // 検索上限

    try {
      TextMessage message = new TextMessage(requestStr);
      handler.handleTextMessage(session, message);

      // 呼出時の引数チェック
      verify(sysDataSetService, times(1)).getDataList(1L, expect, UseApplication.SHARE_VIEW);

    } catch (IOException e) {
      fail("想定外エラー");
    }
  }

  /**
   * 上限値チェック
   *
   * 条件 : facility_cdがmst_coop_facility.common_settingが上限値が未設定の場合
   * 結果 : 上限値にcommon_settingの10が設定される
   * */
  @Test
  public void setDataSetLimit_facilityCdありでmst_coop_facilityの共通設定に上限値ありの場合() {
    String requestStr = "{\"sqlCode\":1, \"dataKey\": {\"ordNo\":1, \"facility_cd\": \"000003\"}}";

    Map<String, Object> expect = new HashMap<>();
    expect.put("ordNo", 1);
    expect.put("facility_cd", "000003");
    expect.put("limit", 10);     // 検索上限

    try {
      TextMessage message = new TextMessage(requestStr);
      handler.handleTextMessage(session, message);

      // 呼出時の引数チェック
      verify(sysDataSetService, times(1)).getDataList(1L, expect, UseApplication.SHARE_VIEW);

    } catch (IOException e) {
      fail("想定外エラー");
    }
  }

  @Test
  public void 正常系_メッセージ受信時_パラメータが正しいのでdataSetの結果を返す() throws Exception {
    String requestStr = "{\"sqlCode\":2,\"dataKey\":{\"ordNo\":7}}";

    // 呼び出し結果を差し替える
    String responseStr = "["
        + "{\"medi_class_cd\":\"1\",\"medi_class_type\":\"1\",\"medi_cd\":\"1\",\"medi_name\":\"テスト抗凝固剤１\",\"medi_amount\":\"2\",\"medi_timing_name\":\"透析中\",\"medi_unit\":\"抗\",\"medi_cd1\":\"12\",\"medi_cd2\":\"13\"},"
        + "{\"medi_class_cd\":\"2\",\"medi_class_type\":\"2\",\"medi_cd\":\"2\",\"medi_name\":\"テスト透析液１\",\"medi_amount\":\"3\",\"medi_timing_name\":\"透析後\",\"medi_unit\":\"L\",\"medi_cd1\":null,\"medi_cd2\":null},"
        + "{\"medi_class_cd\":\"3\",\"medi_class_type\":\"3\",\"medi_cd\":\"3\",\"medi_name\":\"テスト補液１\",\"medi_amount\":\"1\",\"medi_timing_name\":\"透析後\",\"medi_unit\":\"袋\",\"medi_cd1\":null,\"medi_cd2\":null}"
        + "]";
    List<Map<String, Object>> response = ObjectMapperUtil.readTypeReference(
        responseStr, new TypeReference<List<Map<String, Object>>>() {});
    Map<String, Object> dataKey = new HashMap<>();
    dataKey.put("ordNo", 7);
    dataKey.put("limit", 1000);     // 検索上限
    doReturn(response).when(sysDataSetService).getDataList(any(), any(), any());

    TextMessage message = new TextMessage(requestStr);
    handler.handleTextMessage(session, message);

    // 返却結果
    String expect = ObjectMapperUtil.write(new SysDataSetResult(200, "正常終了", response));

    // 呼び出し確認
    verify(sysDataSetService, times(1)).getDataList(any(), any(), any());
    verify(sysDataSetService, times(1)).getDataList(2L, dataKey, UseApplication.SHARE_VIEW);
    verify(session, times(1)).sendMessage(new TextMessage(expect));
    verify(session, times(1)).close(CloseStatus.NORMAL);
  }

  @Test
  public void 正常系_メッセージ受信時_分割チェック() throws Exception {
    String requestStr = "{\"sqlCode\":2,\"dataKey\":{\"ordNo\":7}}";

    // 呼び出し結果を差し替える
    String responseStr = "["
        + "{\"record1\":\"abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstu*\"},"
        + "{\"record2\":\"abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstu*\"},"
        + "{\"record3\":\"abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstu*\"}"
        + "]";
    List<Map<String, Object>> response = ObjectMapperUtil.readTypeReference(
        responseStr, new TypeReference<List<Map<String, Object>>>() {});
    Map<String, Object> dataKey = new HashMap<>();
    dataKey.put("ordNo", 7);
    dataKey.put("limit", 1000);     // 検索上限
    doReturn(response).when(sysDataSetService).getDataList(any(), any(), any());

    TextMessage message = new TextMessage(requestStr);
    handler.handleTextMessage(session, message);

    // 返却結果
    String expect = ObjectMapperUtil.write(new SysDataSetResult(200, "正常終了", response));

    // 呼び出し確認
    verify(sysDataSetService, times(1)).getDataList(2L, dataKey, UseApplication.SHARE_VIEW);

    // 分割チェック
    int count=0;
    // KByte計算で分割
    for (TextMessage tm : substringByte(expect, splitSize*1024)) {
      verify(session, times(1)).sendMessage(tm);
      count++;
    }
    // 呼出回数の確認
    verify(session, times(count)).sendMessage(any());

    verify(session, times(1)).close(CloseStatus.NORMAL);
  }

  @Test
  public void 正常系_メッセージ受信時_処理中にエラーが発生したためエラー切断する() throws Exception {
    String requestStr = "{\"sqlCode\":2,\"dataKey\":{\"ordNo\":7}}";

    // エラーを発生させる
    doThrow(new NtssException()).when(sysDataSetService).getDataList(any(), any(), any());

    TextMessage message = new TextMessage(requestStr);
    handler.handleTextMessage(session, message);

    // 返却結果
    List<Map<String, Object>> response = new ArrayList<>();
    String expect = ObjectMapperUtil.write(new SysDataSetResult(500, "データセットの取得に失敗しました。", response));

    // 呼び出し確認
    verify(sysDataSetService, times(1)).getDataList(any(), any(), any());
    verify(session, times(1)).sendMessage(new TextMessage(expect));
    verify(session, times(1)).close(CloseStatus.SERVER_ERROR);
  }

  /** バイト分割 */
  private List<TextMessage> substringByte(String targetStr, int size) {
    List<TextMessage> msgList = new ArrayList<>();
    StringBuffer sb = new StringBuffer();
    int cnt = 0;

    try {
      for (int i=0; i<targetStr.length(); i++) {
        String c = targetStr.substring(i, i + 1);
        byte[] bytes = c.getBytes("UTF-8");
        if (cnt + bytes.length > size) {
          msgList.add(new TextMessage(sb.toString(), false));
          sb.setLength(0);
          sb.append(c);
          cnt = bytes.length;
        } else {
          sb.append(c);
          cnt += bytes.length;
        }
      }
      msgList.add(new TextMessage(sb.toString(), false));
    } catch (UnsupportedEncodingException e) {
    }
    msgList.add(new TextMessage(""));
    return msgList;
  }
}
