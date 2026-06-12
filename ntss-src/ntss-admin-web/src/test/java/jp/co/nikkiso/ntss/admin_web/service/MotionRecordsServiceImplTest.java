package jp.co.nikkiso.ntss.admin_web.service;

import jp.co.nikkiso.ntss.admin_web.response.GatheringStatusResponse;
import jp.co.nikkiso.ntss.admin_web.response.MotionRecordsResponse;
import jp.co.nikkiso.ntss.admin_web.response.details.GatheringDetailResponse;
import jp.co.nikkiso.ntss.admin_web.response.details.MNoticeDetailResponse;
import jp.co.nikkiso.ntss.admin_web.response.details.PreventiveDetailResponse;
import jp.co.nikkiso.ntss.admin_web.service.motionRecords.MotionRecordsService;
import jp.co.nikkiso.ntss.admin_web.service.utils.DateTimeUtils;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.dao.MntGatheringManageDao;
import jp.co.nikkiso.ntss.core.dao.MntMotionRecordDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.entity.custom.GatheringDetail;
import jp.co.nikkiso.ntss.core.entity.custom.MNoticeDetail;
import jp.co.nikkiso.ntss.core.entity.custom.MotionRecord;
import jp.co.nikkiso.ntss.core.entity.custom.PreventiveDetail;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.junit4.SpringRunner;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import static org.hamcrest.CoreMatchers.equalTo;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.hamcrest.Matchers.nullValue;
import static org.mockito.BDDMockito.anyLong;
import static org.mockito.BDDMockito.anyString;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;

/**
 * MotionRecordsServiceImplのテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
public class MotionRecordsServiceImplTest {

  /**
   * テスト対象.
   */
  @Autowired
  private MotionRecordsService target;

  /**
   * 装置動作記録DaoのMockBean.
   */
  @MockitoBean
  private MntMotionRecordDao mntMotionRecordDao;

  /**
   * データ収集管理DaoのMockBean.
   */
  @MockitoBean
  private MntGatheringManageDao mntGatheringManageDao;

  /**
   * 利用者マスタ(個人情報DB)DaoのMockBean.
   */
  @MockitoBean
  private MstPersonalUserDao mstPersonalUserDao;

  /**
   * createMotionRecordsResponse()の検証.
   * <p>
   * 条件: 正常、NKKユーザ、日付リスト7以上<br>
   * 結果: データ収集記録が取得できること
   * </p>
   */
  @Test
  public void test_createMotionRecordsResponse_正常_NKKユーザ_日付リスト7以上() {

    // 事前準備
    List<String> dates = Arrays.asList("20180401", "20180331", "20180328", "20180325", "20180320", "20180319", "20180318");
    MotionRecord mockMotionRecord1 = createMockMotionRecord("1");
    MotionRecord mockMotionRecord2 = createMockMotionRecord("2");
    MotionRecord mockMotionRecord3 = createMockMotionRecord("3");
    // // データ種別:データ収集記録は除外されるはず
    mockMotionRecord3.setDataType(6);
    List<MotionRecord> motionRecords = Arrays.asList(mockMotionRecord1, mockMotionRecord2, mockMotionRecord3);
    ArgumentCaptor<String> args = ArgumentCaptor.forClass(String.class);

    // Mock化
    given(mntMotionRecordDao.selectEventRegDates(args.capture(), args.capture(), args.capture(), args.capture())).willReturn(dates);
    given(mntMotionRecordDao.selectByMachinesInfo(args.capture(), args.capture(), args.capture(), args.capture(), args.capture())).willReturn(motionRecords);
    given(mstPersonalUserDao.selectUserNameById(1L)).willReturn("ユーザ名1");
    given(mstPersonalUserDao.selectUserNameById(2L)).willReturn("ユーザ名2");
    given(mstPersonalUserDao.selectUserNameById(3L)).willReturn("ユーザ名3");

    // 実行
    MotionRecordsResponse result = target.createMotionRecordsResponse("123456", "001", "111122223333", "NKK", "20180401");

    //　検証
    verify(mntMotionRecordDao, times(1)).selectEventRegDates(anyString(), anyString(), anyString(), anyString());
    verify(mntMotionRecordDao, times(1)).selectByMachinesInfo(anyString(), anyString(), anyString(), anyString(), anyString());
    List<String> expected = Arrays.asList("20180401", "123456", "001", "111122223333", "123456", "001", "111122223333", "20180318", "20180401");
    assertThat(args.getAllValues(), is(expected));
    assertThat(result, notNullValue());
    assertThat(result.baseDate, is("20180318"));
    assertThat(result.motionRecords.size(), equalTo(2));
    assertThat(result.motionRecords.get(0).getMotionRecordNo(), equalTo(1L));
    assertThat(result.motionRecords.get(0).getEventRegDate(), is("2018/01/01"));
    assertThat(result.motionRecords.get(0).getEventRegTime(), is("00:00:01"));
    assertThat(result.motionRecords.get(0).getDataType(), equalTo(1));
    assertThat(result.motionRecords.get(0).getTestType(), equalTo(1));
    //assertThat(result.motionRecords.get(0).contents, is("contents1"));
    assertThat(result.motionRecords.get(0).getIsCorrection(), is("isCorrection1"));
    assertThat(result.motionRecords.get(0).getUserId(), is(1L));
    assertThat(result.motionRecords.get(0).getUserName(), is("ユーザ名1"));
    assertThat(result.motionRecords.get(0), is(mockMotionRecord1));
    assertThat(result.motionRecords.get(1).getMotionRecordNo(), equalTo(2L));
    assertThat(result.motionRecords.get(1).getEventRegDate(), is("2018/01/02"));
    assertThat(result.motionRecords.get(1).getEventRegTime(), is("00:00:02"));
    assertThat(result.motionRecords.get(1).getDataType(), equalTo(1));
    assertThat(result.motionRecords.get(1).getTestType(), equalTo(1));
    //assertThat(result.motionRecords.get(1).contents, is("contents2"));
    assertThat(result.motionRecords.get(1).getIsCorrection(), is("isCorrection2"));
    assertThat(result.motionRecords.get(1).getUserId(), is(2L));
    assertThat(result.motionRecords.get(1).getUserName(), is("ユーザ名2"));
    assertThat(result.motionRecords.get(1), is(mockMotionRecord2));
  }

  /**
   * createMotionRecordsResponse()の検証.
   * <p>
   * 条件: 正常、NKKユーザ以外、日付リストが7未満<br>
   * 結果: データ収取記録が除外されること、Responseの基準日に日付リストの最小値が設定されること
   * </p>
   */
  @Test
  public void test_createMotionRecordsResponse_正常_NKKユーザ以外_日付リストが7未満() {

    // 事前準備
    List<String> dates = Arrays.asList("20180406", "20180405", "20180404", "20180403", "20180402", "20180401");
    MotionRecord mockMotionRecord1 = createMockMotionRecord("1");
    MotionRecord mockMotionRecord2 = createMockMotionRecord("2");
    MotionRecord mockMotionRecord3 = createMockMotionRecord("3");
    mockMotionRecord3.setDataType(6);
    List<MotionRecord> motionRecords = Arrays.asList(mockMotionRecord1, mockMotionRecord2, mockMotionRecord3);

    // Mock化
    given(mntMotionRecordDao.selectEventRegDates(anyString(), anyString(), anyString(), anyString())).willReturn(dates);
    given(mntMotionRecordDao.selectByMachinesInfo(anyString(), anyString(), anyString(), anyString(), anyString())).willReturn(motionRecords);

    // 実行
    MotionRecordsResponse result = target.createMotionRecordsResponse("123456", "001", "111122223333", "NOT_NKK", "20180407");

    // 検証
    assertThat(result, notNullValue());
    assertThat(result.baseDate, is("20180401"));
    assertThat(result.motionRecords.size(), equalTo(2));
    assertThat(result.motionRecords.get(0).getDataType(), equalTo(1));
    assertThat(result.motionRecords.get(0).getTestType(), equalTo(1));
    assertThat(result.motionRecords.get(0), is(mockMotionRecord1));
    assertThat(result.motionRecords.get(1).getDataType(), equalTo(1));
    assertThat(result.motionRecords.get(1).getTestType(), equalTo(1));
    assertThat(result.motionRecords.get(1), is(mockMotionRecord2));

  }

  /**
   * createMotionRecordsResponse()の検証.
   * <p>
   * 条件: 基準日となる日付以前のデータが存在しない<br>
   * 結果: 取得件数0件
   * </p>
   */
  @Test
  public void test_createMotionRecordsResponse_取得結果0件_基準日以前のデータなし() {

    // Mock化
    given(mntMotionRecordDao.selectEventRegDates(anyString(), anyString(), anyString(), anyString())).willReturn(Collections.emptyList());

    // 実行
    MotionRecordsResponse result = target.createMotionRecordsResponse("facilityCd", "machineTypeCd", "machineSerial", "userTypeCd", "baseDate");

    // 検証
    verify(mntMotionRecordDao, times(1)).selectEventRegDates(anyString(), anyString(), anyString(), anyString());
    verify(mntMotionRecordDao, times(0)).selectByMachinesInfo(anyString(), anyString(), anyString(), anyString(), anyString());
    assertThat(result.baseDate, is(""));
    assertThat(result.motionRecords, is(Collections.emptyList()));

  }

  /**
   * createMotionRecordsResponse()の検証.
   * <p>
   * 条件: 対象期間内のデータが存在しない<br>
   * 結果: 取得件数0件、基準日のみ設定されること
   * </p>
   */
  @Test
  public void test_createMotionRecordsResponse_取得結果0件_対象期間内のデータなし() {

    // 事前準備
    List<String> dates = Arrays.asList("20180501");
    ArgumentCaptor<String> args = ArgumentCaptor.forClass(String.class);

    // Mock化
    given(mntMotionRecordDao.selectEventRegDates(anyString(), anyString(), anyString(), anyString())).willReturn(dates);
    given(mntMotionRecordDao.selectByMachinesInfo(anyString(), anyString(), anyString(), args.capture(), args.capture())).willReturn(Collections.emptyList());

    // 実行
    MotionRecordsResponse result = target.createMotionRecordsResponse("000001", "001", "000000000001", "NKK", "00000001");

    // 検証
    assertThat(args.getAllValues(), is(Arrays.asList("20180501", "20180501")));
    assertThat(result.baseDate, is("20180501"));
    assertThat(result.motionRecords, is(Collections.emptyList()));

  }

  /**
   * createMotionRecordsResponse()の検証.
   * <p>
   * 条件: 一般ユーザーかつ、データ収集記録のみ<br>
   * 結果: 取得件数0件、基準日のみ設定されること
   * </p>
   */
  @Test
  public void test_createMotionRecordsResponse_取得結果0件_NKKユーザー以外_データ収集記録のみ() {

    // 事前準備
    List<String> dates = Arrays.asList("20180409", "20180406", "20180405", "20180404", "20180403", "20180402", "20180401");
    MotionRecord mockMotionRecord1 = createMockMotionRecord("1");
    MotionRecord mockMotionRecord2 = createMockMotionRecord("2");
    MotionRecord mockMotionRecord3 = createMockMotionRecord("3");
    mockMotionRecord1.setDataType(6);
    mockMotionRecord2.setDataType(6);
    mockMotionRecord3.setDataType(6);
    List<MotionRecord> motionRecords = Arrays.asList(mockMotionRecord1, mockMotionRecord2, mockMotionRecord3);

    // Mock化
    given(mntMotionRecordDao.selectEventRegDates(anyString(), anyString(), anyString(), anyString())).willReturn(dates);
    given(mntMotionRecordDao.selectByMachinesInfo(anyString(), anyString(), anyString(), anyString(), anyString())).willReturn(motionRecords);

    // 実行
    MotionRecordsResponse result = target.createMotionRecordsResponse("000001", "001", "000000000001", "0", "00000001");

    // 検証
    assertThat(result.baseDate, is("20180401"));
    assertThat(result.motionRecords, is(Collections.emptyList()));

  }

  /**
   * Mock用motionRecordを作成.
   *
   * @param intValue 識別用の数値文字列
   * @return Mock用MotionRecord
   */
  private MotionRecord createMockMotionRecord(String intValue) {

    MotionRecord mockMotionRecord = new MotionRecord();
    mockMotionRecord.setMotionRecordNo(Long.valueOf(intValue));
    mockMotionRecord.setEventRegDate("2018/01/0" + intValue);
    mockMotionRecord.setEventRegTime("00:00:0" + intValue);
    mockMotionRecord.setDataType(1);
    mockMotionRecord.setTestType(1);
    mockMotionRecord.setMachineRecordMessage("message" + intValue);
    mockMotionRecord.setUserId(Long.valueOf(intValue));
    mockMotionRecord.setIsCorrection("isCorrection" + intValue);
    return mockMotionRecord;

  }

  /**
   * getGatheringStatus()の検証.
   * <p>
   * 条件: 正常、対象レコードが存在する<br>
   * 結果: データ収集ステータスが取得されること
   * </p>
   */
  @Test
  public void test_getGatheringStatus_正常_データあり() {
    // 事前準備
    Long userId = 1L;
    String facilityCd = "900001";
    String sysDate = DateTimeUtils.getSysDate();
    Integer gatheringStatus = 2;

    // Mock化
    given(mntGatheringManageDao.selectByUserIdAndFacilityCdAndDate(anyLong(), anyString(), anyString())).willReturn(gatheringStatus);

    // 実行
    GatheringStatusResponse result = target.getGatheringStatus(userId, facilityCd);

    // 検証
    verify(mntGatheringManageDao, times(1)).selectByUserIdAndFacilityCdAndDate(userId, facilityCd, sysDate);
    assertThat(result, notNullValue());
    assertThat(result.gatheringStatus, is(gatheringStatus));
  }

  /**
   * getGatheringStatus()の検証.
   * <p>
   * 条件: 正常、対象レコードが存在しない<br>
   * 結果: データ収集ステータスがnullで返されること
   * </p>
   */
  @Test
  public void test_getGatheringStatus_正常_データなし() {
    // 事前準備
    Long userId = 1L;
    String facilityCd = "900001";
    String sysDate = DateTimeUtils.getSysDate();
    Integer gatheringStatus = null;

    // Mock化
    given(mntGatheringManageDao.selectByUserIdAndFacilityCdAndDate(anyLong(), anyString(), anyString())).willReturn(gatheringStatus);

    // 実行
    GatheringStatusResponse result = target.getGatheringStatus(userId, facilityCd);

    // 検証
    verify(mntGatheringManageDao, times(1)).selectByUserIdAndFacilityCdAndDate(userId, facilityCd, sysDate);
    assertThat(result, notNullValue());
    assertThat(result.gatheringStatus, nullValue());
  }

  /**
   * createDetailResponse()の検証.
   * <p>
   * 条件: 正常、(データ種別:緊急発報記録)対象レコードが存在しない
   * 結果: Responseの 装置動作記録詳細_緊急発報記録取得用Entity に{@code null}が設定されること
   * </p>
   */
  @Test
  public void test_createDetailResponse_データ種別_緊急発報記録_データなし() throws IOException {

    // 事前準備
    MNoticeDetail daoResult = null;
    ArgumentCaptor<Long> args = ArgumentCaptor.forClass(Long.class);

    // Mock化
    given(mntMotionRecordDao.selectMNoticeDetail(args.capture())).willReturn(daoResult);
    given(mstPersonalUserDao.selectUserNameById(args.capture())).willReturn(null);

    // 実行
    ResponseEntity<?> response =
      target.createDetailResponse(
        1L,
        CoreConstant.MotionRecordDataType.M_NOTICE,
        "0001", "001","1", "20200101", 0);

    // 検証
    verify(mntMotionRecordDao, times(1)).selectMNoticeDetail(anyLong());
    verify(mstPersonalUserDao, times(0)).selectUserNameById(anyLong());
    List<Long> expected = Arrays.asList(1L);
    assertThat(args.getAllValues(), is(expected));

    assertThat(response, notNullValue());

    MNoticeDetailResponse detail = (MNoticeDetailResponse)response.getBody();
    assertThat(detail, notNullValue());
    assertThat(detail.mNoticeDetail, nullValue());
  }

  /**
   * createDetailResponse()の検証.
   * <p>
   * 条件: 正常、(データ種別:緊急発報記録)対象レコードが存在する
   * 結果: Responseの 装置動作記録詳細_緊急発報記録取得用Entity に当該レコードが設定されること
   * </p>
   */
  @Test
  public void test_createDetailResponse_データ種別_緊急発報記録_データあり() throws IOException {

    // 事前準備
    MNoticeDetail daoResult = new MNoticeDetail() {{
      setMachineRecordCd("1");
      setDetailInfo("AUX_DATA");
      setDestinationName("EMAIL_NAME");
      setEmailText("EMAIL_TEXT");
      setCorrectedUserId(99L);
      setUserName(null);
      setIsCorrection("1");
      setServiceSupportType("2");
      setServiceSupportUserId(100L);
      setServiceSupportUpDate(new Timestamp(System.currentTimeMillis()));
      setIsCorrectionUpDate(new Timestamp(System.currentTimeMillis()));
    }};
    ArgumentCaptor<Long> args = ArgumentCaptor.forClass(Long.class);

    // Mock化
    given(mntMotionRecordDao.selectMNoticeDetail(args.capture())).willReturn(daoResult);
    given(mstPersonalUserDao.selectUserNameById(99L)).willReturn("ユーザ名");
    given(mstPersonalUserDao.selectUserNameById(100L)).willReturn("テスト太郎");

    // 実行
    ResponseEntity<?> response =
      target.createDetailResponse(
        1L,
        CoreConstant.MotionRecordDataType.M_NOTICE,
        "0001", "001","1", "20200101", 0);

    // 検証
    verify(mntMotionRecordDao, times(1)).selectMNoticeDetail(anyLong());
    verify(mstPersonalUserDao, times(2)).selectUserNameById(anyLong());
    List<Long> expected = Arrays.asList(1L);
    assertThat(args.getAllValues(), is(expected));

    assertThat(response, notNullValue());
    MNoticeDetailResponse detail = (MNoticeDetailResponse)response.getBody();
    assertThat(detail, notNullValue());
    assertThat(detail.mNoticeDetail, notNullValue());
    assertThat(detail.mNoticeDetail.getMachineRecordCd(), is("1"));
    assertThat(detail.mNoticeDetail.getDetailInfo(), is("AUX_DATA"));
    assertThat(detail.mNoticeDetail.getDestinationName(), is("EMAIL_NAME"));
    assertThat(detail.mNoticeDetail.getEmailText(), is("EMAIL_TEXT"));
    assertThat(detail.mNoticeDetail.getCorrectedUserId(), is(99L));
    assertThat(detail.mNoticeDetail.getUserName(), is("ユーザ名"));
    assertThat(detail.mNoticeDetail.getIsCorrection(), is("1"));
    assertThat(detail.mNoticeDetail.getServiceSupportType(), is("2"));
    assertThat(detail.mNoticeDetail.getServiceSupportUserName(), is("テスト太郎"));
    assertThat(detail.mNoticeDetail.getServiceSupportUserId(), is(100L));
  }

  /**
   * createDetailResponse()の検証.
   * <p>
   * 条件: 正常、(データ種別:予防保全/故障予知記録)対象レコードが存在しない
   * 結果: Responseの 装置動作記録詳細_予防保全/故障予知取得用Entity に{@code null}が設定されること
   * </p>
   */
  @Test
  public void test_createDetailResponse_データ種別_予防保全故障予知記録_データなし() throws IOException {

    // 事前準備
    PreventiveDetail daoResult = null;
    ArgumentCaptor<Long> args = ArgumentCaptor.forClass(Long.class);

    // Mock化
    given(mntMotionRecordDao.selectPreventiveDetail(args.capture())).willReturn(daoResult);
    given(mstPersonalUserDao.selectUserNameById(args.capture())).willReturn(null);

    // 実行
    ResponseEntity<?> response =
      target.createDetailResponse(
        9876L,
        CoreConstant.MotionRecordDataType.PREVENTIVE,
        "0001", "001","1", "20200101", 0);

    // 検証
    verify(mntMotionRecordDao, times(1)).selectPreventiveDetail(anyLong());
    verify(mstPersonalUserDao, times(0)).selectUserNameById(anyLong());
    List<Long> expected = Arrays.asList(9876L);
    assertThat(args.getAllValues(), is(expected));

    assertThat(response, notNullValue());

    PreventiveDetailResponse detail = (PreventiveDetailResponse)response.getBody();
    assertThat(detail, notNullValue());
    assertThat(detail.preventiveDetail, nullValue());
  }

  /**
   * createDetailResponse()の検証.
   * <p>
   * 条件: 正常、(データ種別:予防保全/故障予知記録)対象レコードが存在する
   * 結果: Responseの 装置動作記録詳細_予防保全/故障予知取得用Entity に当該レコードが設定されること
   * </p>
   */
  @Test
  public void test_createDetailResponse_データ種別_予防保全故障予知記録_データあり() throws IOException {

    // 事前準備
    PreventiveDetail daoResult = new PreventiveDetail() {{
      setMachineRecordCd("901");
      setDetailInfo("MACHINE_RECORD_AUX_DATA");
      setCorrectedUserId(99L);
      setUserName(null);
      setIsCorrection("1");
    }};
    ArgumentCaptor<Long> args = ArgumentCaptor.forClass(Long.class);

    // Mock化
    given(mntMotionRecordDao.selectPreventiveDetail(args.capture())).willReturn(daoResult);
    given(mstPersonalUserDao.selectUserNameById(args.capture())).willReturn("ユーザ名");

    // 実行
    ResponseEntity<?> response =
      target.createDetailResponse(
        9L,
        CoreConstant.MotionRecordDataType.PREVENTIVE,
        "0001", "001","1", "20200101", 0);

    // 検証
    verify(mntMotionRecordDao, times(1)).selectPreventiveDetail(anyLong());
    verify(mstPersonalUserDao, times(1)).selectUserNameById(anyLong());
    List<Long> expected = Arrays.asList(9L, 99L);
    assertThat(args.getAllValues(), is(expected));

    assertThat(response, notNullValue());

    PreventiveDetailResponse detail = (PreventiveDetailResponse)response.getBody();
    assertThat(detail, notNullValue());
    assertThat(detail.preventiveDetail, notNullValue());
    assertThat(detail.preventiveDetail.getMachineRecordCd(), is("901"));
    assertThat(detail.preventiveDetail.getDetailInfo(), is("MACHINE_RECORD_AUX_DATA"));
    assertThat(detail.preventiveDetail.getCorrectedUserId(), is(99L));
    assertThat(detail.preventiveDetail.getUserName(), is("ユーザ名"));
    assertThat(detail.preventiveDetail.getIsCorrection(), is("1"));
  }

  /**
   * createDetailResponse()の検証.
   * <p>
   * 条件: 正常、(データ種別:データ収集記録)対象レコードが存在しない
   * 結果: Responseの 各フィールド に{@code null}が設定されること
   * </p>
   */
  @Test
  public void test_createDetailResponse_データ種別_データ収集記録_データなし() throws IOException {

    // 事前準備
    GatheringDetail daoResult = null;
    ArgumentCaptor<Long> args = ArgumentCaptor.forClass(Long.class);

    // Mock化
    given(mntMotionRecordDao.selectGatheringDetail(args.capture())).willReturn(daoResult);
    given(mstPersonalUserDao.selectUserNameById(args.capture())).willReturn(null);

    // 実行
    ResponseEntity<?> response =
      target.createDetailResponse(
        1234L,
        CoreConstant.MotionRecordDataType.GATHERINNG,
        "0001", "001","1", "20200101", 0);

    // 検証
    verify(mntMotionRecordDao, times(1)).selectGatheringDetail(anyLong());
    verify(mstPersonalUserDao, times(0)).selectUserNameById(anyLong());
    List<Long> expected = Arrays.asList(1234L);
    assertThat(args.getAllValues(), is(expected));

    assertThat(response, notNullValue());

    GatheringDetailResponse detail = (GatheringDetailResponse)response.getBody();
    assertThat(detail, notNullValue());
    assertThat(detail.machineRecordMessage, is(""));
    assertThat(detail.gatheringUserId, nullValue());
    assertThat(detail.userName, is(""));
    assertThat(detail.fileData, nullValue());
  }

  /**
   * createDetailResponse()の検証.
   * <p>
   * 条件: 正常、(データ種別:データ収集記録)対象レコードが存在する
   * 結果: Responseの 各フィールド に当該データが設定されること
   * </p>
   */
  @Test
  public void test_createDetailResponse_データ種別_データ収集記録_データあり() throws IOException {

    // 事前準備
    GatheringDetail daoResult = new GatheringDetail() {{
      setMachineRecordMessage("");
      setGatheredUserId(8L);
      setFileData("{\"filename\":\"test\", \"path\": \"/tmp/test\"}");
      setUserName(null);
    }};
    ArgumentCaptor<Long> args = ArgumentCaptor.forClass(Long.class);

    // Mock化
    given(mntMotionRecordDao.selectGatheringDetail(args.capture())).willReturn(daoResult);
    given(mstPersonalUserDao.selectUserNameById(args.capture())).willReturn("ユーザ名");

    // 実行
    ResponseEntity<?> response =
      target.createDetailResponse(
        1234L,
        CoreConstant.MotionRecordDataType.GATHERINNG,
        "0001", "001","1", "20200101", 0);

    // 検証
    verify(mntMotionRecordDao, times(1)).selectGatheringDetail(anyLong());
    verify(mstPersonalUserDao, times(1)).selectUserNameById(anyLong());
    List<Long> expected = Arrays.asList(1234L, 8L);
    assertThat(args.getAllValues(), is(expected));

    assertThat(response, notNullValue());

    GatheringDetailResponse detail = (GatheringDetailResponse)response.getBody();
    assertThat(detail, notNullValue());
    assertThat(detail.machineRecordMessage, is(""));
    assertThat(detail.gatheringUserId, is(8L));
    assertThat(detail.userName, is("ユーザ名"));
    assertThat(detail.fileData, notNullValue());
    assertThat(detail.fileData.getPath(), is("/tmp/test"));
    assertThat(detail.fileData.getFilename(), is("test"));
  }

  /**
   * {@link MotionRecordsService#updateServiceSupport(Long, String, Long)}の検証
   *
   * <p>
   *   条件:更新対象のデータが存在する事.
   *   結果:<code>true</code>が返却される事.
   * </p>
   */
  @Test
  public void test_updateServiceSupport_正常_更新対象のデータが存在する場合() {
    // Mock化
    given(mntMotionRecordDao.updateServiceSupport(null)).willReturn(1);
    // 実行
    boolean result =
      target.updateServiceSupport(1L, "2", 10L);
    // 検証
    verify(mntMotionRecordDao, times(1)).updateServiceSupport(null);
    assertThat(result, is(true));
  }

  /**
   * {@link MotionRecordsService#updateServiceSupport(Long, String, Long)}の検証
   *
   * <p>
   *   条件:更新対象のデータが存在しない事.
   *   結果:<code>false</code>が返却される事.
   * </p>
   */
  @Test
  public void test_updateServiceSupport_異常_更新対象のデータが存在しない場合() {
    // Mock化
    given(mntMotionRecordDao.updateServiceSupport(null)).willReturn(0);
    // 実行
    boolean result =
      target.updateServiceSupport(1L, "2", 10L);
    // 検証
    verify(mntMotionRecordDao, times(1)).updateServiceSupport(null);
    assertThat(result, is(false));
  }

  /**
   * {@link MotionRecordsService#updateAllServiceSupport(String, String, String, Long)}の検証
   *
   * <p>
   *   条件:更新対象のデータが存在する事.
   *   結果:<code>true</code>が返却される事.
   * </p>
   */
  @Test
  public void test_updateAllServiceSupport_正常_更新対象のデータが存在する場合() {
    // Mock化
    given(mntMotionRecordDao.updateServiceSupportAll(null)).willReturn(10);
    // 実行
    boolean result =
      target.updateAllServiceSupport("TEST_FACILITY", "1", "2", 10L,null);
    // 検証
    verify(mntMotionRecordDao, times(1)).updateServiceSupportAll(null);
    assertThat(result, is(true));
  }

  /**
   * {@link MotionRecordsService#updateAllServiceSupport(String, String, String, Long)}の検証
   *
   * <p>
   *   条件:更新対象のデータが存在しない事.
   *   結果:<code>false</code>が返却される事.
   * </p>
   */
  @Test
  public void test_updateAllServiceSupport_異常_更新対象のデータが存在しない場合() {
    // Mock化
    given(mntMotionRecordDao.updateServiceSupportAll(null)).willReturn(0);
    // 実行
    boolean result =
      target.updateAllServiceSupport("TEST_FACILITY", "1", "2", 10L,null);
    // 検証
    verify(mntMotionRecordDao, times(1)).updateServiceSupportAll(null);
    assertThat(result, is(false));
  }



}
