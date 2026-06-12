package jp.co.nikkiso.ntss.coop_api.service;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.hamcrest.Matchers.nullValue;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.doNothing;
import static org.mockito.BDDMockito.doThrow;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.mock;

import java.io.File;
import java.io.IOException;
import java.net.UnknownHostException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.stream.Stream;

import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.bean.override.mockito.MockitoSpyBean;
import org.springframework.http.HttpStatus;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.socket.WebSocketSession;

import jp.co.nikkiso.ntss.coop_api.config.IfEdgeConfigulation;
import jp.co.nikkiso.ntss.coop_api.request.IfEdgeWebsocketRequest;
import jp.co.nikkiso.ntss.coop_api.response.IfEdgeRestResult;
import jp.co.nikkiso.ntss.coop_api.utils.ClockWrapper;
import jp.co.nikkiso.ntss.coop_api.utils.IfEdgeConstants;
import jp.co.nikkiso.ntss.coop_api.utils.IfEdgeConstants.IfedgeFixedResult;
import jp.co.nikkiso.ntss.coop_api.utils.IfEdgeConstants.ResponseStatus;
import jp.co.nikkiso.ntss.coop_api.utils.IfEdgeConstants.ResultStatus;
import jp.co.nikkiso.ntss.coop_api.web.websocket.IfEdgeMntMessageHandler;
import jp.co.nikkiso.ntss.coop_api.web.websocket.IfEdgeMntSessionManager;
import jp.co.nikkiso.ntss.coop_api.web.websocket.WebSocketConfig;
import jp.co.nikkiso.ntss.core.dao.MntIfEdgeClientConnectDao;
import jp.co.nikkiso.ntss.core.dao.MntIfEdgeManageDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopFacilityDao;
import jp.co.nikkiso.ntss.core.entity.MntIfEdgeClientConnect;
import jp.co.nikkiso.ntss.core.entity.MntIfEdgeManage;
import jp.co.nikkiso.ntss.core.entity.MstCoopFacility;

@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:resource.script/IfEdgeServiceImplTest/IfEdgeServiceImplTest.db5.before.sql")
public class IfEdgeServiceImplTest {
  //
  @MockitoBean
  private IfEdgeMntMessageHandler handler;

  @MockitoSpyBean
  IfEdgeMntSessionManager ifEdgeMntSessionManager;

  @MockitoBean
  WebSocketSession session;

  @MockitoBean
  WebSocketConfig config;

  @MockitoSpyBean
  IfEdgeConfigulation ifEdgeConfigulation;

  @MockitoSpyBean
  IfEdgeServiceImpl service;

  /** 連携エッジクライアント接続状態のDao */
  @Autowired
  MntIfEdgeClientConnectDao mntIfEdgeClientConnectDao;

  /** 連携エッジ制御指示管理のDao */
  @Autowired
  MntIfEdgeManageDao mntIfEdgeManageDao;

  @Autowired
  MstCoopFacilityDao mstCoopFacilityDao;

  @Autowired
  ClockWrapper clockWrapper;

  @Rule
  public TemporaryFolder tempFolder = new TemporaryFolder();

//  @Test
//  public void 正常系() {
//    ※service.execute呼び出し中に連携エッジ制御指示管理が登録されるが、
//      同じservice.execute呼び出し内で応答ステータスを完了待ちしている。間に応答ステータスの更新を入れられないので
//      REST起動で正常パターンは確認すること
//
//  }

  @Test
  public void 異常系_websocket接続なし_DB接続データなし() throws UnknownHostException {

    String facilityCd = "001";
    IfEdgeWebsocketRequest request = new IfEdgeWebsocketRequest();
    request.setFacilityCd(facilityCd);
    IfEdgeRestResult result = service.devide(request);
    assertThat(result.getStatus(), is(String.valueOf(HttpStatus.OK.value())));
    assertThat(result.getResult().getFacilityCd(), is(facilityCd));
    assertThat(result.getResult().getStatus(), is(ResultStatus.RESULT.getReceiveName()));
    assertThat(result.getResult().getSystem(), is(IfEdgeConstants.IF_EDGE_CONNECT_SYSTEM_NAME));
    assertThat(result.getResult().getResult().getCtlNo(), nullValue());
    assertThat(result.getResult().getResult().getStatus(), is(IfedgeFixedResult.DISCONNECT.getStatus()));
    assertThat(result.getResult().getResult().getMessage(), is(IfedgeFixedResult.DISCONNECT.getMessage()));
  }

  @Test
  public void 異常系_websocket接続なし_DB接続データありWebsocketセッションクライアント情報なし() throws UnknownHostException {

    String facilityCd = "007";
    IfEdgeWebsocketRequest request = new IfEdgeWebsocketRequest();
    request.setFacilityCd(facilityCd);
    IfEdgeRestResult result = service.devide(request);
    assertThat(result.getStatus(), is(String.valueOf(HttpStatus.OK.value())));
    assertThat(result.getResult().getFacilityCd(), is(facilityCd));
    assertThat(result.getResult().getStatus(), is(ResultStatus.RESULT.getReceiveName()));
    assertThat(result.getResult().getSystem(), is(IfEdgeConstants.IF_EDGE_CONNECT_SYSTEM_NAME));
    assertThat(result.getResult().getResult().getCtlNo(), nullValue());
    assertThat(result.getResult().getResult().getStatus(), is(IfedgeFixedResult.DISCONNECT.getStatus()));
    assertThat(result.getResult().getResult().getMessage(), is(IfedgeFixedResult.DISCONNECT.getMessage()));
  }

  @Test
  public void 異常系_連携エッジ制御指示管理データが依頼中() {
    String facilityCd = "002";
    IfEdgeWebsocketRequest request = new IfEdgeWebsocketRequest();
    request.setFacilityCd(facilityCd);
    // とりあえずクライアントを登録
    WebSocketSession session = mock(WebSocketSession.class);
    given(session.getId()).willReturn("1");
    ifEdgeMntSessionManager.addClient(session, null);
    // 連携エッジ制御指示管理データ作成
    MntIfEdgeManage insMntIfEdgeManage = new MntIfEdgeManage();
    insMntIfEdgeManage.setFacilityCd(facilityCd);
    insMntIfEdgeManage.setResponseStatus(ResponseStatus.RUNNING.getStatus());
    insMntIfEdgeManage.setEdgeResult(null);
    insMntIfEdgeManage.setIsDel(IfEdgeConstants.FLAG_FALSE);
    mntIfEdgeManageDao.insert(insMntIfEdgeManage);

    IfEdgeRestResult result = service.devide(request);
    assertThat(result.getStatus(), is(String.valueOf(HttpStatus.OK.value())));
    assertThat(result.getResult().getFacilityCd(), is(facilityCd));
    assertThat(result.getResult().getStatus(), is(ResultStatus.RESULT.getReceiveName()));
    assertThat(result.getResult().getSystem(), is(IfEdgeConstants.IF_EDGE_CONNECT_SYSTEM_NAME));
    assertThat(result.getResult().getResult().getStatus(), is(IfedgeFixedResult.BUSY.getStatus()));
    assertThat(result.getResult().getResult().getMessage(), is(IfedgeFixedResult.BUSY.getMessage()));
  }

  @Test
  public void 異常系_指示種別がコマンドの場合指定のコマンドが取得できない() throws Throwable {

    String facilityCd = "003";

    WebSocketSession session = mock(WebSocketSession.class);
    given(session.getId()).willReturn("2");
    doNothing().when(session).sendMessage(any());

    // とりあえずクライアントを登録
    ifEdgeMntSessionManager.addClient(session, null);

    IfEdgeWebsocketRequest request = new IfEdgeWebsocketRequest();
    request.setFacilityCd(facilityCd);
    request.setType(IfEdgeConstants.ExeType.COMMAND.getType());
    request.setCommand("dummy");
    IfEdgeRestResult result = service.devide(request);
    assertThat(result.getStatus(), is(String.valueOf(HttpStatus.OK.value())));
    assertThat(result.getResult().getFacilityCd(), is(facilityCd));
    assertThat(result.getResult().getStatus(), is(ResultStatus.RESULT.getReceiveName()));
    assertThat(result.getResult().getSystem(), is(IfEdgeConstants.IF_EDGE_CONNECT_SYSTEM_NAME));
    assertThat(result.getResult().getResult().getStatus(), is(IfedgeFixedResult.COMMANDNOTFOUND.getStatus()));
    assertThat(result.getResult().getResult().getMessage(), is(IfedgeFixedResult.COMMANDNOTFOUND.getMessage()));

  }

  @Test
  public void 異常系_指示種別がコマンドの場合コマンドファイルの作成がIOE例外() throws Throwable {

    String facilityCd = "006";

    given(ifEdgeConfigulation.getResourcePath()).willReturn("");
    given(ifEdgeConfigulation.getCommandSaveDir()).willReturn(":");

    WebSocketSession session = mock(WebSocketSession.class);
    given(session.getId()).willReturn("3");

    // とりあえずクライアントを登録
    ifEdgeMntSessionManager.addClient(session, null);
    IfEdgeWebsocketRequest request = new IfEdgeWebsocketRequest();
    request.setFacilityCd(facilityCd);
    request.setType(IfEdgeConstants.ExeType.COMMAND.getType());
    request.setCommand("test");
    IfEdgeRestResult result = service.devide(request);
    assertThat(result.getStatus(), is(String.valueOf(HttpStatus.OK.value())));
    assertThat(result.getResult().getFacilityCd(), is(facilityCd));
    assertThat(result.getResult().getStatus(), is(ResultStatus.RESULT.getReceiveName()));
    assertThat(result.getResult().getSystem(), is(IfEdgeConstants.IF_EDGE_CONNECT_SYSTEM_NAME));
    assertThat(result.getResult().getResult().getMessage(), is(IfedgeFixedResult.COMMAND_FILE_ERR.getMessage()));
    assertThat(result.getResult().getResult().getStatus(), is(IfedgeFixedResult.COMMAND_FILE_ERR.getStatus()));

  }

  @Test
  public void 異常系_管理NOファイルの作成がIOE例外() throws Throwable {

    String facilityCd = "009";

    given(ifEdgeConfigulation.getResourcePath()).willReturn("\\RESOURCEPATH");

    // とりあえずクライアントを登録
    WebSocketSession session = mock(WebSocketSession.class);
    given(session.getId()).willReturn("4");
    ifEdgeMntSessionManager.addClient(session, null);

    IfEdgeWebsocketRequest request = new IfEdgeWebsocketRequest();
    request.setFacilityCd(facilityCd);
    request.setType(IfEdgeConstants.ExeType.FILE.getType());
    request.setCommand("");
    request.setDirPath("");
    IfEdgeRestResult result = service.devide(request);

    assertThat(result.getStatus(), is(String.valueOf(HttpStatus.OK.value())));
    assertThat(result.getResult().getFacilityCd(), is(facilityCd));
    assertThat(result.getResult().getStatus(), is(ResultStatus.RESULT.getReceiveName()));
    assertThat(result.getResult().getSystem(), is(IfEdgeConstants.IF_EDGE_CONNECT_SYSTEM_NAME));
    assertThat(result.getResult().getResult().getStatus(), is(IfedgeFixedResult.CTLNO_FILE_ERR.getStatus()));
    assertThat(result.getResult().getResult().getMessage(), is(IfedgeFixedResult.CTLNO_FILE_ERR.getMessage()));

  }

  @Test
  public void 正常系_既存管理Noファイル削除確認() throws Throwable {

    String facilityCd = "201";

    File testDir = tempFolder.newFolder();
    given(ifEdgeConfigulation.getResourcePath()).willReturn(testDir.getPath());
    File testFile = new File(testDir.getAbsolutePath() + File.separator + "ctlno_111");
    testFile.createNewFile();
    assertThat(true, is(testFile.exists()));

    WebSocketSession session = mock(WebSocketSession.class);
    given(session.getId()).willReturn("5");
    doNothing().when(session).sendMessage(any());

    // とりあえずクライアントを登録
    ifEdgeMntSessionManager.addClient(session, null);

    IfEdgeWebsocketRequest request = new IfEdgeWebsocketRequest();
    request.setFacilityCd(facilityCd);
    request.setType(IfEdgeConstants.ExeType.FILE.getType());
    request.setCommand("");
    request.setDirPath("");
    IfEdgeRestResult result = service.devide(request);
    assertThat(false, is(testFile.exists()));

  }

//  @Test
//  public void 異常系_ZIPファイルの作成がIOE例外() {

//    given(ifEdgeConfigulation.getResourcePath()).willReturn("");
//
//    IfEdgeWebsocketRequest request = new IfEdgeWebsocketRequest();
//    request.setFacilityCd("003");
//    request.setType(IfEdgeConstants.ExeType.FILE.getType());
//    request.setCommand("");
//    IfEdgeRestResult result = service.execute(request);
//    assertThat(result.getStatus(), is(String.valueOf(HttpStatus.OK.value())));
//    assertThat(result.getResult().getFacilityCd(), is("003"));
//    assertThat(result.getResult().getStatus(), is(ResultStatus.RESULT.name()));
//    assertThat(result.getResult().getSystem(), is(IfEdgeConstants.IF_EDGE_CONNECT_SYSTEM_NAME));
//    assertThat(result.getResult().getResult().getStatus(), is(ResultDefaultResult.CREATE_FILE_ERR.getStatus()));
//    assertThat(result.getResult().getResult().getMessage(), is(ResultDefaultResult.CREATE_FILE_ERR.getMessage()));

  // ※モック化できる隙がないのでREST起動で正常パターンは確認すること

//  }

  @Test
  public void 異常系_連携ファイル送信IOE例外() throws Throwable {

    String facilityCd = "010";

    File testDir = tempFolder.newFolder();
    given(ifEdgeConfigulation.getResourcePath()).willReturn(testDir.getPath());

    WebSocketSession session = mock(WebSocketSession.class);
    given(session.getId()).willReturn("6");

    // とりあえずクライアントを登録
    ifEdgeMntSessionManager.addClient(session, null);

    doThrow(IOException.class).when(session).sendMessage(any());

    IfEdgeWebsocketRequest request = new IfEdgeWebsocketRequest();
    request.setFacilityCd(facilityCd);
    request.setType(IfEdgeConstants.ExeType.FILE.getType());
    request.setCommand("");
    request.setDirPath("");
    IfEdgeRestResult result = service.devide(request);
    assertThat(result.getStatus(), is(String.valueOf(HttpStatus.OK.value())));
    assertThat(result.getResult().getFacilityCd(), is(facilityCd));
    assertThat(result.getResult().getStatus(), is(ResultStatus.RESULT.getReceiveName()));
    assertThat(result.getResult().getSystem(), is(IfEdgeConstants.IF_EDGE_CONNECT_SYSTEM_NAME));
    assertThat(result.getResult().getResult().getMessage(), is(IfedgeFixedResult.SEND_FILE_ERR.getMessage()));
    assertThat(result.getResult().getResult().getStatus(), is(IfedgeFixedResult.SEND_FILE_ERR.getStatus()));
  }

  @Test
  public void 異常系_連携ファイル送信結果待機タイムアウト() throws Throwable {

    String facilityCd = "008";

    File testDir = tempFolder.newFolder();
    given(ifEdgeConfigulation.getResourcePath()).willReturn(testDir.getPath());

    WebSocketSession session = mock(WebSocketSession.class);
    given(session.getId()).willReturn("7");
    doNothing().when(session).sendMessage(any());

    // とりあえずクライアントを登録
    ifEdgeMntSessionManager.addClient(session, null);

    IfEdgeWebsocketRequest request = new IfEdgeWebsocketRequest();
    request.setFacilityCd(facilityCd);
    request.setType(IfEdgeConstants.ExeType.FILE.getType());
    request.setCommand("");
    request.setDirPath("");
    IfEdgeRestResult result = service.devide(request);
    assertThat(result.getStatus(), is(String.valueOf(HttpStatus.OK.value())));
    assertThat(result.getResult().getFacilityCd(), is(facilityCd));
    assertThat(result.getResult().getStatus(), is(ResultStatus.RESULT.getReceiveName()));
    assertThat(result.getResult().getSystem(), is(IfEdgeConstants.IF_EDGE_CONNECT_SYSTEM_NAME));
    assertThat(result.getResult().getResult().getMessage(), is(IfedgeFixedResult.TIMEOUT.getMessage()));
    assertThat(result.getResult().getResult().getStatus(), is(IfedgeFixedResult.TIMEOUT.getStatus()));

  }

  @Test
  public void 連携エッジ接続管理のIPアドレスが自アドレス() throws Throwable {

    given(ifEdgeMntSessionManager.getLocalIp()).willReturn("127.0.0.1");

    // 正常終了は無理なのでとりあえず、ResultDefaultResult.COMMANDNOTFOUNDまでたどり着けばOK
    String facilityCd = "004";
    // とりあえずクライアントを登録
    WebSocketSession session = mock(WebSocketSession.class);
    given(session.getId()).willReturn("8");
    ifEdgeMntSessionManager.addClient(session, null);

    IfEdgeWebsocketRequest request = new IfEdgeWebsocketRequest();
    request.setFacilityCd(facilityCd);
    request.setType(IfEdgeConstants.ExeType.COMMAND.getType());
    request.setCommand("dummy");
    IfEdgeRestResult result = service.devide(request);
    assertThat(result.getStatus(), is(String.valueOf(HttpStatus.OK.value())));
    assertThat(result.getResult().getFacilityCd(), is(facilityCd));
    assertThat(result.getResult().getStatus(), is(ResultStatus.RESULT.getReceiveName()));
    assertThat(result.getResult().getSystem(), is(IfEdgeConstants.IF_EDGE_CONNECT_SYSTEM_NAME));
    assertThat(result.getResult().getResult().getStatus(), is(IfedgeFixedResult.COMMANDNOTFOUND.getStatus()));
    assertThat(result.getResult().getResult().getMessage(), is(IfedgeFixedResult.COMMANDNOTFOUND.getMessage()));

  }

  @Test
  public void 連携エッジ接続管理のIPアドレスが他アドレス() throws Throwable {

    given(ifEdgeMntSessionManager.getLocalIp()).willReturn("192.0.2.0");
    String facilityCd = "004";
    IfEdgeWebsocketRequest request = new IfEdgeWebsocketRequest();
    request.setFacilityCd(facilityCd);
    request.setType(IfEdgeConstants.ExeType.COMMAND.getType());
    request.setCommand("dummy");
    try {
      IfEdgeRestResult result = service.devide(request);
    } catch(ResourceAccessException re) {
      // とりあえずorg.springframework.web.client.ResourceAccessExceptionが出ればOK
      assertTrue(true);
    }
  }

  @Test
  public void 他サーバURI生成エラー() throws Throwable {

    given(ifEdgeConfigulation.getRequestHTTP()).willReturn("");

    String facilityCd = "005";
    // とりあえずクライアントを登録
    WebSocketSession session = mock(WebSocketSession.class);
    given(session.getId()).willReturn("9");
    ifEdgeMntSessionManager.addClient(session, null);
    // IPアドレスだけ変更
    MntIfEdgeClientConnect mntIfEdgeClientConnect = mntIfEdgeClientConnectDao.selectByFacilityCd(facilityCd);
    mntIfEdgeClientConnect.setIpAddress("000.000.000.0000");
    mntIfEdgeClientConnectDao.update(mntIfEdgeClientConnect);

    IfEdgeWebsocketRequest request = new IfEdgeWebsocketRequest();
    request.setFacilityCd(facilityCd);
    request.setType(IfEdgeConstants.ExeType.COMMAND.getType());
    request.setCommand("start");
    IfEdgeRestResult result = service.devide(request);

    assertThat(result.getStatus(), is(String.valueOf(HttpStatus.OK.value())));
    assertThat(result.getResult().getFacilityCd(), is(facilityCd));
    assertThat(result.getResult().getStatus(), is(ResultStatus.RESULT.getReceiveName()));
    assertThat(result.getResult().getSystem(), is(IfEdgeConstants.IF_EDGE_CONNECT_SYSTEM_NAME));
    assertThat(result.getResult().getResult().getStatus(), is(IfedgeFixedResult.URI_SYNTAX_ERR.getStatus()));
    assertThat(result.getResult().getResult().getMessage(), is(IfedgeFixedResult.URI_SYNTAX_ERR.getMessage()));
  }

  @Test
  public void clearData_データクリア必要なし() {
    String facilityCd = "100";
    WebSocketSession session = mock(WebSocketSession.class);
    given(session.getId()).willReturn("10");

    // とりあえずクライアントを登録
    ifEdgeMntSessionManager.addClient(session, null);

    IfEdgeRestResult result = new IfEdgeRestResult();
    result.setStatus(String.valueOf(HttpStatus.OK.value()));
    MntIfEdgeManage.EdgeResult ifEdgeResult = new MntIfEdgeManage.EdgeResult();
    ifEdgeResult.setSystem(IfEdgeConstants.IF_EDGE_CONNECT_SYSTEM_NAME);
    ifEdgeResult.setStatus(ResultStatus.RESULT.getReceiveName());
    ifEdgeResult.setFacilityCd(facilityCd);
    MntIfEdgeManage.InnerEdgeResult innerResult = new MntIfEdgeManage.InnerEdgeResult();
    innerResult.setStatus(IfedgeFixedResult.TIMEOUT.getStatus());
    innerResult.setMessage(IfedgeFixedResult.TIMEOUT.getMessage());
    ifEdgeResult.setResult(innerResult);
    result.setResult(ifEdgeResult);

    service.clearData(facilityCd, result);

    // データ確認
    MntIfEdgeManage mntIfEdgeManage = mntIfEdgeManageDao.selectByFacilityCdAndStatus(facilityCd, ResponseStatus.RUNNING.getStatus());
    assertThat(mntIfEdgeManage, is(notNullValue()));

    MntIfEdgeClientConnect mntIfEdgeClientConnect = mntIfEdgeClientConnectDao.selectByFacilityCd(facilityCd);
    assertThat(mntIfEdgeClientConnect, is(notNullValue()));
  }

  @Test
  public void clearData_連携エッジ制御指示管理のみデータクリア() {
    String facilityCd = "101";
    WebSocketSession session = mock(WebSocketSession.class);
    given(session.getId()).willReturn("11");

    // とりあえずクライアントを登録
    ifEdgeMntSessionManager.addClient(session, null);

    IfEdgeRestResult result = new IfEdgeRestResult();
    result.setStatus(String.valueOf(HttpStatus.OK.value()));
    MntIfEdgeManage.EdgeResult ifEdgeResult = new MntIfEdgeManage.EdgeResult();
    ifEdgeResult.setSystem(IfEdgeConstants.IF_EDGE_CONNECT_SYSTEM_NAME);
    ifEdgeResult.setStatus(ResultStatus.RESULT.getReceiveName());
    ifEdgeResult.setFacilityCd(facilityCd);
    MntIfEdgeManage.InnerEdgeResult innerResult = new MntIfEdgeManage.InnerEdgeResult();
    innerResult.setStatus(IfedgeFixedResult.CTLNO_FILE_ERR.getStatus());
    innerResult.setMessage(IfedgeFixedResult.CTLNO_FILE_ERR.getMessage());
    ifEdgeResult.setResult(innerResult);
    result.setResult(ifEdgeResult);

    service.clearData(facilityCd, result);

    // データ確認
    MntIfEdgeManage mntIfEdgeManage = mntIfEdgeManageDao.selectByFacilityCdAndStatus(facilityCd, ResponseStatus.RUNNING.getStatus());
    assertThat(mntIfEdgeManage, is(nullValue()));

    MntIfEdgeClientConnect mntIfEdgeClientConnect = mntIfEdgeClientConnectDao.selectByFacilityCd(facilityCd);
    assertThat(mntIfEdgeClientConnect, is(notNullValue()));

  }

  @Test
  public void clearData_全データクリア() {
    String facilityCd = "102";
    WebSocketSession session = mock(WebSocketSession.class);
    given(session.getId()).willReturn("12");

    // とりあえずクライアントを登録
    ifEdgeMntSessionManager.addClient(session, null);

    IfEdgeRestResult result = new IfEdgeRestResult();
    result.setStatus(String.valueOf(HttpStatus.OK.value()));
    MntIfEdgeManage.EdgeResult ifEdgeResult = new MntIfEdgeManage.EdgeResult();
    ifEdgeResult.setSystem(IfEdgeConstants.IF_EDGE_CONNECT_SYSTEM_NAME);
    ifEdgeResult.setStatus(ResultStatus.RESULT.getReceiveName());
    ifEdgeResult.setFacilityCd(facilityCd);
    MntIfEdgeManage.InnerEdgeResult innerResult = new MntIfEdgeManage.InnerEdgeResult();
    innerResult.setStatus(IfedgeFixedResult.SEND_FILE_ERR.getStatus());
    innerResult.setMessage(IfedgeFixedResult.SEND_FILE_ERR.getMessage());
    ifEdgeResult.setResult(innerResult);
    result.setResult(ifEdgeResult);

    service.clearData(facilityCd, result);

    // データ確認
    MntIfEdgeManage mntIfEdgeManage = mntIfEdgeManageDao.selectByFacilityCdAndStatus(facilityCd, ResponseStatus.RUNNING.getStatus());
    assertThat(mntIfEdgeManage, is(nullValue()));

    MntIfEdgeClientConnect mntIfEdgeClientConnect = mntIfEdgeClientConnectDao.selectByFacilityCd(facilityCd);
    assertThat(mntIfEdgeClientConnect, is(nullValue()));

  }

  @Test
  public void 正常系_DirPathの先頭がセパレータなくてもOK() throws Throwable {

    String facilityCd = "003";

    File testDir = tempFolder.newFolder();
    given(ifEdgeConfigulation.getResourcePath()).willReturn(testDir.getPath());

    File dir = new File(testDir.getAbsolutePath() + File.separator + "save");
    dir.mkdir();

    WebSocketSession session = mock(WebSocketSession.class);
    given(session.getId()).willReturn("13");
    doNothing().when(session).sendMessage(any());

    // とりあえずクライアントを登録
    ifEdgeMntSessionManager.addClient(session, null);

    IfEdgeWebsocketRequest request = new IfEdgeWebsocketRequest();
    request.setFacilityCd(facilityCd);
    request.setType(IfEdgeConstants.ExeType.FILE.getType());
    request.setCommand("");
    request.setDirPath("save");
    service.devide(request);

    boolean ret = false;
    File[] resultFiles = dir.listFiles();
    for (File resultFile : resultFiles) {
      if (resultFile.getName().startsWith("ctlno_")) {
        ret = true;
      }
    }
    assertThat(true, is(ret));
  }

  @Test
  public void 正常系_DirPathの先頭がセパレータあってもOK() throws Throwable {

    String facilityCd = "003";

    File testDir = tempFolder.newFolder();
    given(ifEdgeConfigulation.getResourcePath()).willReturn(testDir.getPath());

    File dir = new File(testDir.getAbsolutePath() + File.separator + "save");
    dir.mkdir();

    WebSocketSession session = mock(WebSocketSession.class);
    given(session.getId()).willReturn("14");
    doNothing().when(session).sendMessage(any());

    // とりあえずクライアントを登録
    ifEdgeMntSessionManager.addClient(session, null);

    IfEdgeWebsocketRequest request = new IfEdgeWebsocketRequest();
    request.setFacilityCd(facilityCd);
    request.setType(IfEdgeConstants.ExeType.FILE.getType());
    request.setCommand("");
    request.setDirPath(File.separator + "save");
    service.devide(request);

    boolean ret = false;
    File[] resultFiles = dir.listFiles();
    for (File resultFile : resultFiles) {
      if (resultFile.getName().startsWith("ctlno_")) {
        ret = true;
      }
    }
    assertThat(true, is(ret));
  }

  @Test
  public void 正常系_コマンド実行時設定ファイルaddsettingが１の時ファイル作成確認() throws Throwable {

    String facilityCd = "202";

    File testDir = tempFolder.newFolder();
    given(ifEdgeConfigulation.getResourcePath()).willReturn(testDir.getPath());

    WebSocketSession session = mock(WebSocketSession.class);
    given(session.getId()).willReturn("15");
    doNothing().when(session).sendMessage(any());

    // とりあえずクライアントを登録
    ifEdgeMntSessionManager.addClient(session, null);

    IfEdgeWebsocketRequest request = new IfEdgeWebsocketRequest();
    request.setFacilityCd(facilityCd);
    request.setType(IfEdgeConstants.ExeType.COMMAND.getType());
    request.setCommand("testsetting");
    service.devide(request);
    StringBuilder commandSaveDir = new StringBuilder(testDir.getAbsolutePath());
    commandSaveDir.append(IfEdgeConstants.FILE_SEPARATOR).append(IfEdgeConstants.FILE_SEPARATOR).append(facilityCd).append(ifEdgeConfigulation.getCommandSaveDir());
    Path commandSaveDirPath = Paths.get(commandSaveDir.toString());
    File commandSaveDirFile = commandSaveDirPath.toFile();

    //　commandSaveDir下には日時ディレクトリしかない想定
    File[] files = commandSaveDirFile.listFiles();
    String dateDir = files[0].getAbsolutePath();
    Path settingfile = Paths.get(dateDir + IfEdgeConstants.FILE_SEPARATOR + ifEdgeConfigulation.getCommandSettingDir(), ifEdgeConfigulation.getCommandSettingFile());

    assertThat(Files.exists(settingfile), is(true));
    Stream<String> stream = Files.lines(settingfile);
    StringBuilder fileContent = new StringBuilder();
    stream.forEach(line -> {
      fileContent.append(line);
    });
    stream.close();
    MstCoopFacility mstCoopFacility = mstCoopFacilityDao.select(facilityCd);
    assertThat(fileContent.toString(), is(mstCoopFacility.getIfEdgeSetting()));
  }

  @Test
  public void 正常系_コマンド実行時設定ファイルaddsettingが設定なし時ファイル未作成確認() throws Throwable {

    String facilityCd = "202";

    File testDir = tempFolder.newFolder();
    given(ifEdgeConfigulation.getResourcePath()).willReturn(testDir.getPath());

    WebSocketSession session = mock(WebSocketSession.class);
    given(session.getId()).willReturn("16");
    doNothing().when(session).sendMessage(any());

    // とりあえずクライアントを登録
    ifEdgeMntSessionManager.addClient(session, null);

    IfEdgeWebsocketRequest request = new IfEdgeWebsocketRequest();
    request.setFacilityCd(facilityCd);
    request.setType(IfEdgeConstants.ExeType.COMMAND.getType());
    request.setCommand("test");
    service.devide(request);
    StringBuilder commandSaveDir = new StringBuilder(testDir.getAbsolutePath());
    commandSaveDir.append(IfEdgeConstants.FILE_SEPARATOR).append(IfEdgeConstants.FILE_SEPARATOR).append(facilityCd).append(ifEdgeConfigulation.getCommandSaveDir());
    Path commandSaveDirPath = Paths.get(commandSaveDir.toString());
    File commandSaveDirFile = commandSaveDirPath.toFile();

    //　commandSaveDir下には日時ディレクトリしかない想定
    File[] files = commandSaveDirFile.listFiles();
    String dateDir = files[0].getAbsolutePath();
    Path settingfile = Paths.get(dateDir + IfEdgeConstants.FILE_SEPARATOR + ifEdgeConfigulation.getCommandSettingDir(), ifEdgeConfigulation.getCommandSettingFile());

    assertThat(Files.exists(settingfile), is(false));
  }
}
