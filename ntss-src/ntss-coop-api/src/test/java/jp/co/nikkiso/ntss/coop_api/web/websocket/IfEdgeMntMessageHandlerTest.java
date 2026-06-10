package jp.co.nikkiso.ntss.coop_api.web.websocket;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.hamcrest.Matchers.nullValue;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.mock;

import java.lang.reflect.Field;
import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.boot.test.mock.mockito.SpyBean;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;

import jp.co.nikkiso.ntss.coop_api.config.IfEdgeConfigulation;
import jp.co.nikkiso.ntss.coop_api.utils.ClockWrapper;
import jp.co.nikkiso.ntss.coop_api.utils.IfEdgeConstants.ResponseStatus;
import jp.co.nikkiso.ntss.coop_api.web.websocket.IfEdgeMntSessionManager.WSClientInfo;
import jp.co.nikkiso.ntss.core.dao.MntIfEdgeClientConnectDao;
import jp.co.nikkiso.ntss.core.dao.MntIfEdgeManageDao;
import jp.co.nikkiso.ntss.core.entity.MntIfEdgeClientConnect;
import jp.co.nikkiso.ntss.core.entity.MntIfEdgeManage;
import jp.co.nikkiso.ntss.core.entity.MntIfEdgeManage.EdgeResult;
import jp.co.nikkiso.ntss.core.entity.MntIfEdgeManage.InnerEdgeResult;

@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:resource.script/IfEdgeMntMessageHandlerTest/IfEdgeMntMessageHandlerTest.db5.before.sql")
public class IfEdgeMntMessageHandlerTest {
  //
  @SpyBean
  private IfEdgeMntMessageHandler handler;

  @SpyBean
  IfEdgeMntSessionManager ifEdgeMntSessionManager;

  @MockBean
  WebSocketConfig config;

  @Autowired
  ClockWrapper clockWrapper;

  @SpyBean
  IfEdgeConfigulation ifEdgeConfigulation;

  @Autowired
  MntIfEdgeManageDao mntIfEdgeManageDao;

  @Autowired
  MntIfEdgeClientConnectDao mntIfEdgeClientConnectDao;

  @Test
  public void afterConnectionClosed() throws Exception {
    String facilityCd = "001";
    WebSocketSession session = mock(WebSocketSession.class);
    given(session.getId()).willReturn("1");

    // まずクライアントを作成
    ifEdgeMntSessionManager.addClient(session,  null);

    // 切断
    handler.afterConnectionClosed(session, new CloseStatus(CloseStatus.BAD_DATA.getCode()));

    // クライアント情報がちゃんと削除されてるか確認
    MntIfEdgeClientConnect resultMntIfEdgeClientConnect = mntIfEdgeClientConnectDao.selectByFacilityCd(facilityCd);
    assertThat(resultMntIfEdgeClientConnect, is(nullValue()));
    Field resultClientListField = IfEdgeMntSessionManager.class.getDeclaredField("clientList");
    resultClientListField.setAccessible(true);
    List<WSClientInfo> resultClientList =  (List<WSClientInfo>)resultClientListField.get(ifEdgeMntSessionManager);
    boolean resultExist = true;
    for(WSClientInfo clientInfo : resultClientList) {
      if (facilityCd.equals(clientInfo.getFacilityCd())) {
        resultExist = false;
      }
    }
    assertThat(resultExist, is(true));
  }

  @Test
  public void handleTextMessage_正常系接続要求() throws Exception {
    String facilityCd = "002";
    WebSocketSession session = mock(WebSocketSession.class);
    given(session.getId()).willReturn("2");

    EdgeResult edgeResult = new EdgeResult();
    edgeResult.setSystem("NTSS");
    edgeResult.setStatus("connect");
    edgeResult.setFacilityCd(facilityCd);
    InnerEdgeResult innerEdgeResult = new InnerEdgeResult();
    innerEdgeResult.setMessage("connect");
    innerEdgeResult.setStatus(200);
    edgeResult.setResult(innerEdgeResult);

    handler.handleTextMessage(session, new TextMessage(edgeResult.getValue()));

    // クライアント登録されているか確認
    MntIfEdgeClientConnect resultMntIfEdgeClientConnect = mntIfEdgeClientConnectDao.selectByFacilityCd(facilityCd);
    assertThat(resultMntIfEdgeClientConnect, is(notNullValue()));
    Field resultClientListField = IfEdgeMntSessionManager.class.getDeclaredField("clientList");
    resultClientListField.setAccessible(true);
    List<WSClientInfo> resultClientList =  (List<WSClientInfo>)resultClientListField.get(ifEdgeMntSessionManager);
    boolean resultExist = false;
    for(WSClientInfo clientInfo : resultClientList) {
      if (facilityCd.equals(clientInfo.getFacilityCd())) {
        resultExist = true;
      }
    }
    assertThat(resultExist, is(true));

  }

  @Test
  public void handleTextMessage_正常系結果通知() throws Exception {
    String facilityCd = "003";
    WebSocketSession session = mock(WebSocketSession.class);
    given(session.getId()).willReturn("3");

    // まずクライアントを作成
    ifEdgeMntSessionManager.addClient(session, null);

    MntIfEdgeManage mntIfEdgeManage =  mntIfEdgeManageDao.selectByFacilityCdAndStatus(facilityCd, 0);

    EdgeResult edgeResult = new EdgeResult();
    edgeResult.setSystem("NTSS");
    edgeResult.setStatus("result");
    edgeResult.setFacilityCd(facilityCd);
    InnerEdgeResult innerEdgeResult = new InnerEdgeResult();
    innerEdgeResult.setCtlNo(mntIfEdgeManage.getCtlNo());
    innerEdgeResult.setMessage("OK");
    innerEdgeResult.setStatus(200);
    edgeResult.setResult(innerEdgeResult);

    handler.handleTextMessage(session, new TextMessage(edgeResult.getValue()));

    // 一応更新してるか確認
    MntIfEdgeManage retManage = mntIfEdgeManageDao.selectByCtlNo(mntIfEdgeManage.getCtlNo());
    assertThat(retManage, is(notNullValue()));
    assertThat(retManage.getResponseStatus(), is(2));
  }

  @Test
  public void handleTextMessage_異常系() throws Exception {

    String facilityCd = "004";
    WebSocketSession session = mock(WebSocketSession.class);
    given(session.getId()).willReturn("4");

    // まずクライアントを作成
    ifEdgeMntSessionManager.addClient(session, null);

    MntIfEdgeManage mntIfEdgeManage =  mntIfEdgeManageDao.selectByFacilityCdAndStatus(facilityCd, 0);

    handler.handleTextMessage(session, new TextMessage("{\"result\": {\"ctl_no\": "+ mntIfEdgeManage.getCtlNo() +",\"status\": 200, \", \"status\": \"result\", \"system\": \"NTSS\", \"facility_cd\": \"99999\"}"));

    // エラーとして更新されていることを確認
    MntIfEdgeManage retManage = mntIfEdgeManageDao.selectByCtlNo(mntIfEdgeManage.getCtlNo());
    assertThat(retManage, is(notNullValue()));
    assertThat(retManage.getResponseStatus(), is(ResponseStatus.ERROR.getStatus()));
  }
}
