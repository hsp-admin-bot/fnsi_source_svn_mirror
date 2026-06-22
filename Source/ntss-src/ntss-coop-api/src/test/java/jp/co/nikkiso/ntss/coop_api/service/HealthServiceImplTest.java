package jp.co.nikkiso.ntss.coop_api.service;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.junit.Assert.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.anyInt;
import static org.mockito.BDDMockito.anyString;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;

import java.util.HashMap;
import java.util.Map;

import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.bean.override.mockito.MockitoSpyBean;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.coop_api.mapping.HealthmonFacility;
import jp.co.nikkiso.ntss.coop_api.mapping.HealthmonServer;
import jp.co.nikkiso.ntss.coop_api.request.HealthUpdateRequest;
import jp.co.nikkiso.ntss.coop_api.request.JournalCreateRequest;
import jp.co.nikkiso.ntss.coop_api.request.JournalDeliveryRequest;
import jp.co.nikkiso.ntss.coop_api.request.JournalUpdateRequest;
import jp.co.nikkiso.ntss.coop_api.utils.ClockWrapper;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants.AnaResult;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants.CoopResult;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants.IFHealthMonitorStatus;
import jp.co.nikkiso.ntss.core.dao.MntIfEdgeHealthmonDao;
import jp.co.nikkiso.ntss.core.dao.SysCoopJournalDao;
import jp.co.nikkiso.ntss.core.entity.MntIfEdgeHealthmon;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import jp.co.nikkiso.ntss.core.exception.NtssException;

/**
 * {@link HealthServiceImpl} のテスト
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:resource.script/HealthServiceImplTest/HealthServiceImplTest.db5.before.sql")
public class HealthServiceImplTest extends BaseServiceTest {
  /**
   * 例外の内容をテストするためのルール
   */
  @Rule
  public ExpectedException expectedException = ExpectedException.none();

  @MockitoSpyBean
  HealthServiceImpl service;

  @MockitoSpyBean
  MntIfEdgeHealthmonDao mntIfEdgeHealthmonDao;

  @MockitoBean
  ClockWrapper clockWrapper;

  @Autowired
  SysCoopJournalDao sysCoopJournalDao;

  @Test
  public void 正常系_ヘルスモニタ更新_ヘルスモニタ更新リクエスト_更新対象なしのためNULLが返る() {
    HealthUpdateRequest request = ヘルスモニタ更新リクエストテストデータ作成(null, null, null);
    request.setFacilityCd("000099");

    MntIfEdgeHealthmon actual = service.update(request);
    assertThat(actual, is(nullValue()));
  }

  @Test
  public void 異常系_ヘルスモニタ更新_ヘルスモニタ更新リクエスト_電文種別なしのためthrowする() {
    Long ctlNo = 999999L;
    String facilityStatus = IFHealthMonitorStatus.FACILITY_ERROR.getValue();

    expectedException.expect(NtssException.class);
    expectedException.expectMessage("マスタデータに更新対象の電文種別が存在しません。");

    HealthUpdateRequest request = ヘルスモニタ更新リクエストテストデータ作成(ctlNo, facilityStatus, null);
    service.update(request);
  }

  @Test
  public void 正常系_ヘルスモニタ更新_ヘルスモニタ更新リクエスト_エッジステータスが指定されないためNULLがセットされる() {
    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());

    Long ctlNo = 999999L;
    String serverStatus = IFHealthMonitorStatus.SERVER_INACTIVE.getValue();
    HealthUpdateRequest request = ヘルスモニタ更新リクエストテストデータ作成(ctlNo, null, serverStatus);
    MntIfEdgeHealthmon actual = service.update(request);
    assertThat(actual, is(notNullValue()));
    assertThat(actual.getCtlNo(), is(1L));
    assertThat(actual.getFacilityCd(), is(request.getFacilityCd()));
    assertThat(actual.getIfEdgeNo(), is(request.getIfEdgeNo()));
    assertThat(actual.getHealthmonServerConn(), is(notNullValue()));
    assertThat(actual.getHealthmonServerConn(), is("{"
      + "\"status\":\"" + serverStatus + "\","
      + "\"moni_time\":\"" + formatDate(getMockClockMillis(), "yyyy-MM-dd hh:mm:ss") + "\"}"));
    assertThat(actual.getHealthmonFacilityConn(), is(nullValue()));
  }

  @Test
  public void 正常系_ヘルスモニタ更新_ヘルスモニタ更新リクエスト_サーバテータスが指定されないためNULLがセットされる() {
    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());

    Long ctlNo = 9999999L;
    String facilityStatus = IFHealthMonitorStatus.FACILITY_INACTIVE.getValue();
    HealthUpdateRequest request = ヘルスモニタ更新リクエストテストデータ作成(ctlNo, facilityStatus, null);
    MntIfEdgeHealthmon actual = service.update(request);
    assertThat(actual, is(notNullValue()));
    assertThat(actual.getCtlNo(), is(1L));
    assertThat(actual.getFacilityCd(), is(request.getFacilityCd()));
    assertThat(actual.getIfEdgeNo(), is(request.getIfEdgeNo()));
    assertThat(actual.getHealthmonServerConn(), is(nullValue()));
    assertThat(actual.getHealthmonFacilityConn(), is(notNullValue()));
    assertThat(actual.getHealthmonFacilityConn(), is("{\"ini_dial\":{"
      + "\"status\":\"" + facilityStatus + "\",\"type\":\"receive\","
      + "\"moni_time\":\"" + formatDate(getMockClockMillis(), "yyyy-MM-dd hh:mm:ss") + "\"}}"));
  }

  @Test
  public void 異常系_ヘルスモニタ更新_ヘルスモニタ更新リクエスト_JSONデータ不正のためthrowする() {
    // ヘルスモニタの検索結果をエラーになるデータに差し替え
    MntIfEdgeHealthmon returnValue = new MntIfEdgeHealthmon();
    returnValue.setHealthmonFacilityConn("{ \"test\":\"value\", \"test2\":\"value2\" }");
    given(mntIfEdgeHealthmonDao.selectByFacilityAndIfEdgeNo(anyString(), anyInt())).willReturn((MntIfEdgeHealthmon) returnValue);

    Long ctlNo = 9999999L;
    String facilityStatus = IFHealthMonitorStatus.FACILITY_ERROR.getValue();
    HealthUpdateRequest request = ヘルスモニタ更新リクエストテストデータ作成(ctlNo, facilityStatus, null);

    expectedException.expect(NtssException.class);
    expectedException.expectMessage("JSONとしてのデータ変換でエラーが発生しました。");

    service.update(request);
  }

  @Test
  public void 正常系_ヘルスモニタ更新_ジャーナル更新リクエスト_変換ステータスが処理完了_変換ステータスが処理完了のため更新する() {
    String anaResult = AnaResult.DONE.getResult();
    String coopResult = CoopResult.DONE.getResult();

    JournalUpdateRequest request = ジャーナル更新リクエストテストデータ作成(anaResult, coopResult);
    service.update(request);

    // どちらもステータス正常で更新
    HealthUpdateRequest expect = ヘルスモニタ更新リクエストテストデータ作成(request.getCtlNo(),
      IFHealthMonitorStatus.FACILITY_ACTIVE.getValue(), IFHealthMonitorStatus.SERVER_ACTIVE.getValue());
    verify(service, times(1)).update(expect);
  }

  @Test
  public void 正常系_ヘルスモニタ更新_ジャーナル更新リクエスト_変換ステータスが処理完了_変換ステータスが内部エラーのため更新する() {
    String anaResult = AnaResult.DONE.getResult();
    String coopResult = CoopResult.INTERNAL_ERROR_BY_NTSS.getResult();

    JournalUpdateRequest request = ジャーナル更新リクエストテストデータ作成(anaResult, coopResult);
    service.update(request);

    // エッジステータスのみ異常で更新
    Long ctlNo = 9999999L;
    HealthUpdateRequest expect = ヘルスモニタ更新リクエストテストデータ作成(ctlNo,
      IFHealthMonitorStatus.FACILITY_ERROR.getValue(), IFHealthMonitorStatus.SERVER_ACTIVE.getValue());
    verify(service, times(1)).update(expect);
  }

  @Test
  public void 正常系_ヘルスモニタ更新_ジャーナル更新リクエスト_変換ステータスが処理完了_通信ステータスが外部エラーのため更新する() {
    String anaResult = AnaResult.DONE.getResult();
    String coopResult = CoopResult.INTERNAL_ERROR_BY_CARTE.getResult();

    JournalUpdateRequest request = ジャーナル更新リクエストテストデータ作成(anaResult, coopResult);
    service.update(request);

    // エッジステータスのみ異常で更新
    Long ctlNo = 9999999L;
    HealthUpdateRequest expect = ヘルスモニタ更新リクエストテストデータ作成(ctlNo,
      IFHealthMonitorStatus.FACILITY_ERROR.getValue(), IFHealthMonitorStatus.SERVER_ACTIVE.getValue());
    verify(service, times(1)).update(expect);
  }

  @Test
  public void 正常系_ヘルスモニタ更新_ジャーナル更新リクエスト_変換ステータスが処理完了_通信ステータスが処理中のため更新しない() {
    String anaResult = AnaResult.DONE.getResult();
    String coopResult = CoopResult.PROCESSING.getResult();

    JournalUpdateRequest request = ジャーナル更新リクエストテストデータ作成(anaResult, coopResult);
    service.update(request);

    verify(service, times(0)).update(any(HealthUpdateRequest.class));
  }

  @Test
  public void 正常系_ヘルスモニタ更新_ジャーナル更新リクエスト_変換ステータスが処理中_通信ステータスが内部エラーのため更新しない() {
    String anaResult = AnaResult.PROCESSING.getResult();
    String coopResult = CoopResult.INTERNAL_ERROR_BY_NTSS.getResult();

    JournalUpdateRequest request = ジャーナル更新リクエストテストデータ作成(anaResult, coopResult);
    service.update(request);

    verify(service, times(0)).update(any(HealthUpdateRequest.class));
  }

  @Test
  public void 正常系_ヘルスモニタ更新_ジャーナル更新リクエスト_変換ステータスが処理中_通信ステータスが処理中のため更新しない() {
    String anaResult = AnaResult.PROCESSING.getResult();
    String coopResult = CoopResult.PROCESSING.getResult();

    JournalUpdateRequest request = ジャーナル更新リクエストテストデータ作成(anaResult, coopResult);
    service.update(request);

    verify(service, times(0)).update(any(HealthUpdateRequest.class));
  }

  @Test
  public void 正常系_ヘルスモニタ更新_ジャーナル作成リクエスト_変換ステータスが未処理_通信ステータスが処理完了のため更新する_() {
    String anaResult = AnaResult.UNPROCESS.getResult();
    String coopResult = CoopResult.DONE.getResult();

    JournalCreateRequest request = ジャーナル作成リクエストテストデータ作成(anaResult, coopResult);
    service.update(request);

    // どちらもステータス正常で更新
    Long ctlNo = 9999999L;
    HealthUpdateRequest expect = ヘルスモニタ更新リクエストテストデータ作成(ctlNo,
      IFHealthMonitorStatus.FACILITY_ACTIVE.getValue(), IFHealthMonitorStatus.SERVER_ACTIVE.getValue());
    verify(service, times(1)).update(expect);
  }

  @Test
  public void 正常系_ヘルスモニタ更新_ジャーナル作成リクエスト_変換ステータスが未処理_通信ステータスが内部エラーのため更新する_() {
    String anaResult = AnaResult.UNPROCESS.getResult();
    String coopResult = CoopResult.INTERNAL_ERROR_BY_NTSS.getResult();

    JournalCreateRequest request = ジャーナル作成リクエストテストデータ作成(anaResult, coopResult);
    service.update(request);

    // エッジステータスのみ異常で更新
    Long ctlNo = 9999999L;
    HealthUpdateRequest expect = ヘルスモニタ更新リクエストテストデータ作成(ctlNo,
      IFHealthMonitorStatus.FACILITY_ERROR.getValue(), IFHealthMonitorStatus.SERVER_ACTIVE.getValue());
    verify(service, times(1)).update(expect);
  }

  @Test
  public void 正常系_ヘルスモニタ更新_ジャーナル作成リクエスト_変換ステータスが未処理_通信ステータスが外部エラーのため更新する_() {
    String anaResult = AnaResult.UNPROCESS.getResult();
    String coopResult = CoopResult.INTERNAL_ERROR_BY_CARTE.getResult();

    JournalCreateRequest request = ジャーナル作成リクエストテストデータ作成(anaResult, coopResult);
    service.update(request);

    // エッジステータスのみ異常で更新
    Long ctlNo = 9999999L;
    HealthUpdateRequest expect = ヘルスモニタ更新リクエストテストデータ作成(ctlNo,
      IFHealthMonitorStatus.FACILITY_ERROR.getValue(), IFHealthMonitorStatus.SERVER_ACTIVE.getValue());
    verify(service, times(1)).update(expect);
  }

  @Test
  public void 正常系_ヘルスモニタ更新_ジャーナル作成リクエスト_変換ステータスが未処理_通信ステータスが未処理のため更新しない_() {
    String anaResult = AnaResult.UNPROCESS.getResult();
    String coopResult = CoopResult.UNPROCESS.getResult();

    JournalCreateRequest request = ジャーナル作成リクエストテストデータ作成(anaResult, coopResult);
    service.update(request);

    verify(service, times(0)).update(any(HealthUpdateRequest.class));
  }

  @Test
  public void 正常系_ヘルスモニタ更新_ジャーナル作成リクエスト_変換ステータスが処理完了_通信ステータスが処理完了のため更新しない_() {
    String anaResult = AnaResult.DONE.getResult();
    String coopResult = CoopResult.DONE.getResult();

    JournalCreateRequest request = ジャーナル作成リクエストテストデータ作成(anaResult, coopResult);
    service.update(request);

    verify(service, times(0)).update(any(HealthUpdateRequest.class));
  }

  @Test
  public void 正常系_ヘルスモニタ更新_ジャーナル作成リクエスト_変換ステータスが処理中_通信ステータスが処理中のため更新しない_() {
    String anaResult = AnaResult.PROCESSING.getResult();
    String coopResult = CoopResult.PROCESSING.getResult();

    JournalCreateRequest request = ジャーナル作成リクエストテストデータ作成(anaResult, coopResult);
    service.update(request);

    verify(service, times(0)).update(any(HealthUpdateRequest.class));
  }

  @Test
  public void 正常系_ヘルスモニタ更新_ジャーナル配信リクエスト_すべての条件で更新する() {
    JournalDeliveryRequest request = new JournalDeliveryRequest();
    request.setFacilityCd("000001");

    service.update(request);

    // サーバステータスのみ更新
    Long ctlNo = 9999999L;
    HealthUpdateRequest expect = ヘルスモニタ更新リクエストテストデータ作成(ctlNo, null, IFHealthMonitorStatus.SERVER_ACTIVE.getValue());
    verify(service, times(1)).update(expect);
  }

  private HealthUpdateRequest ヘルスモニタ更新リクエストテストデータ作成(Long ctlNo, String facilityStatus, String serverStatus) {
    SysCoopJournal journal = sysCoopJournalDao.selectByPK(ctlNo);
    HealthUpdateRequest request = new HealthUpdateRequest();
    request.setFacilityCd("000001");
    request.setIfEdgeNo(1);

    if (journal == null) return request;

    if (journal.getCoopCd() != null && facilityStatus != null) {
      Map<String, HealthmonFacility> healthmonFacilityConn = new HashMap<>();
      HealthmonFacility healthmonFacility = new HealthmonFacility();
      healthmonFacility.setStatus(facilityStatus);
      healthmonFacilityConn.put(journal.getCoopCd(), healthmonFacility);
      request.setHealthmonFacilityConn(healthmonFacilityConn);
    }

    if (serverStatus != null) {
      HealthmonServer healthmonServerConn = new HealthmonServer();
      healthmonServerConn.setStatus(serverStatus);
      request.setHealthmonServerConn(healthmonServerConn);
    }

    return request;
  }

  private JournalUpdateRequest ジャーナル更新リクエストテストデータ作成(String anaResult, String coopResult) {
    JournalUpdateRequest request = new JournalUpdateRequest();
    request.setCtlNo(9999999L);

    request.setAnaResult(anaResult);
    request.setCoopResult(coopResult);

    return request;
  }

  private JournalCreateRequest ジャーナル作成リクエストテストデータ作成(String anaResult, String coopResult) {
    JournalCreateRequest request = new JournalCreateRequest();
    request.setFacilityCd("000001");
    request.setCoopCd("ini_dial");

    request.setAnaResult(anaResult);
    request.setCoopResult(coopResult);

    return request;
  }
}
