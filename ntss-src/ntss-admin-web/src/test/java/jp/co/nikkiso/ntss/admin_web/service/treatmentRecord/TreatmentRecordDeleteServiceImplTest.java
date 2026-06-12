package jp.co.nikkiso.ntss.admin_web.service.treatmentRecord;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.request.deviceEdgeOrder.DeviceEdgeOrderRequest;
import jp.co.nikkiso.ntss.admin_web.response.deviceEdgeOrder.DeviceEdgeOrderResponse;
import jp.co.nikkiso.ntss.admin_web.service.deviceEdgeOrder.DeviceEdgeOrderService;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.PayloadBuilder;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.WebSocketNotifyService;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.junit4.SpringRunner;

import java.lang.reflect.Method;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.Arrays;
import java.util.List;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.nullValue;
import static org.mockito.BDDMockito.any;
import static org.mockito.BDDMockito.anyLong;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;

/**
 * {@link TreatmentRecordDeleteService}のテストクラス
 */
@RunWith(SpringRunner.class)
@SpringBootTest
public class TreatmentRecordDeleteServiceImplTest {

  /**
   * テスト対象クラス.
   */
  @Autowired
  private TreatmentRecordDeleteService target;

  /**
   * {@link OrdMainDao} のMockBean
   */
  @MockitoBean
  private OrdMainDao ordMainDao;

  /**
   * {@link PatMainDao} のMockBean
   */
  @MockitoBean
  private PatMainDao patMainDao;

  /**
   * {@link MntMachineStateDao} のMockBean
   */
  @MockitoBean
  private MntMachineStateDao mntMachineStateDao;

  /**
   * {@link DeviceEdgeOrderService} のMockBean
   */
  @MockitoBean
  private DeviceEdgeOrderService deviceEdgeOrderService;

  /**
   * {@link WebSocketNotifyService} のMockBean
   */
  @MockitoBean
  private WebSocketNotifyService webSocketNotifyService;

  /**
   * 例外の発生をテストするためのルール
   */
  @Rule
  public ExpectedException expectedException = ExpectedException.none();

  /**
   * {@link TreatmentRecordDeleteService#deleteTreatmentRecordByOrdNo(Long)}の検証.
   * <p>
   *   条件：存在しないオーダ番号を指定する.
   *   結果:{@link jp.co.nikkiso.ntss.core.exception.NotExistException}が発生する事.
   * </p>
   */
  @Test
  public void test_deleteTreatmentRecordByOrdNo_異常_該当するオーダ番号がない場合に例外が発生する事() {
    // 事前準備
    Long ordNo = 1L;
    // Mock
    given(ordMainDao.selectByOrdNo(anyLong())).willReturn(null);

    // 実行
    expectedException.expect(NotExistException.class);
    expectedException.expectMessage(String.format("オーダ番号に該当する情報が存在しません。オーダ番号[%d]", ordNo));
    target.deleteTreatmentRecordByOrdNo(ordNo);

    // 検証
    verify(ordMainDao, times(0)).insert(new OrdMain());
    verify(ordMainDao, times(0)).update(new OrdMain());
    verify(mntMachineStateDao, times(0)).selectByOrdNo(any(String.class), any(Long.class));
    verify(deviceEdgeOrderService, times(0)).findMissingData(any());
    verify(webSocketNotifyService, times(0)).sendMsg(any(), any(String.class), any(Integer.class), any(String.class), any(String.class));
    verify(patMainDao, times(0)).updateResetAcceptanceStatus(anyLong(), any(Timestamp.class));
  }

  /**
   * {@link TreatmentRecordDeleteService#deleteTreatmentRecordByOrdNo(Long)}の検証.
   * <p>
   *   条件：存在しないオーダ番号を指定する.
   *   結果:{@link jp.co.nikkiso.ntss.core.exception.NotExistException}が発生する事.
   * </p>
   */
  @Test
  public void test_deleteTreatmentRecordByOrdNo_成功() {
    // 事前準備
    Long ordNo = 1L;
    String facilityCd = "009999";
    Integer deviceEdgeNo = 1;
    Long machineNo = 100L;

    Timestamp timestamp = new Timestamp(System.currentTimeMillis());
    OrdMain ordMain = createTestData();

    // デバイスエッジ番号を取得する為のリクエスト情報を作成
    DeviceEdgeOrderRequest deviceEdgeOrderRequest = new DeviceEdgeOrderRequest();
    deviceEdgeOrderRequest.setDeviceEdgeNo(null);
    deviceEdgeOrderRequest.setOrdNo(ordNo);
    deviceEdgeOrderRequest.setMachineNo(null);
    deviceEdgeOrderRequest.setFacilityCd(facilityCd);

    // デバイスエッジ番号を取得する為の処理実行後の結果
    DeviceEdgeOrderRequest resultDeviceEdgeOrderRequest = new DeviceEdgeOrderRequest();
    resultDeviceEdgeOrderRequest.setDeviceEdgeNo(deviceEdgeNo);
    resultDeviceEdgeOrderRequest.setOrdNo(ordNo);
    resultDeviceEdgeOrderRequest.setMachineNo(machineNo);
    resultDeviceEdgeOrderRequest.setFacilityCd(facilityCd);

    // 装置状態管理
    MntMachineState mntMachineState = new MntMachineState();
    mntMachineState.setOrdNo(ordNo);
    mntMachineState.setFacilityCd(facilityCd);
    List<MntMachineState> mntMachineStateList = Arrays.asList(mntMachineState);

    // orderAfterWeight実行結果
    DeviceEdgeOrderResponse response1 = new DeviceEdgeOrderResponse();
    response1.isSuccess = true;
    response1.errorMessage = "";

    // orderCheckStatusの実行結果
    DeviceEdgeOrderResponse response2 = new DeviceEdgeOrderResponse();
    response2.isSuccess = true;
    response2.errorMessage = "";

    // Mock
    given(ordMainDao.selectByOrdNo(anyLong())).willReturn(ordMain);
    given(ordMainDao.insert(ordMain)).willReturn(1);
    given(ordMainDao.update(ordMain)).willReturn(1);
    given(mntMachineStateDao.selectByOrdNo(facilityCd, ordNo)).willReturn(mntMachineStateList);
    given(deviceEdgeOrderService.findMissingData(deviceEdgeOrderRequest)).willReturn(resultDeviceEdgeOrderRequest);
    given(deviceEdgeOrderService.orderAfterWeight(facilityCd, deviceEdgeNo, machineNo)).willReturn(response1);
    given(deviceEdgeOrderService.orderCheckStatus(facilityCd, deviceEdgeNo, machineNo)).willReturn(response2);
    given(patMainDao.updateResetAcceptanceStatus(ordMain.getPatId(), timestamp)).willReturn(1);

    // 治療状況確認指示のTopic
    String topic1 = PayloadBuilder.BuildTopic(AdminWebConstant.WebSocketTopic.ComSv.AFTER_WEIGHT, facilityCd, 1);
    // 治療状況確認指示のTopic
    String topic2 = PayloadBuilder.BuildTopic(AdminWebConstant.WebSocketTopic.ComSv.CHECK_STATUS, facilityCd, 1);

    // 実行
    target.deleteTreatmentRecordByOrdNo(ordNo);
    // 検証
    verify(ordMainDao, times(1)).insert(any(OrdMain.class));
    verify(ordMainDao, times(1)).update(ordMain);
    verify(mntMachineStateDao, times(1)).selectByOrdNo(facilityCd, ordNo);
    verify(deviceEdgeOrderService, times(1)).findMissingData(deviceEdgeOrderRequest);
    verify(deviceEdgeOrderService, times(1)).orderAfterWeight(facilityCd, deviceEdgeNo, machineNo);
    verify(deviceEdgeOrderService, times(1)).orderCheckStatus(facilityCd, deviceEdgeNo, machineNo);
  }

  /**
   * clearInstructionsPart(privateメソッド)をinvokeする.
   *
   * @param ordMain オーダ
   * @return 予定情報をクリアした{@link OrdMain}
   * @throws Throwable
   */
  private OrdMain invokeClearInstructionsPart(OrdMain ordMain) throws Throwable {
    try {
      Method method = TreatmentRecordDeleteServiceImpl.class.getDeclaredMethod("clearInstructionsPart", OrdMain.class);
      method.setAccessible(true);
      return (OrdMain) method.invoke(target, ordMain);
    } catch (Exception ex) {
      ex.printStackTrace();
      throw ex;
    }
  }

  /**
   * clearInstructionsPart(privateメソッド)の検証.
   * @throws Throwable
   */
  @Test
  public void test_clearInstructionsPart_成功() throws Throwable {
    // 事前準備
    OrdMain ordMain = createTestData();
    // 実行
    OrdMain result = invokeClearInstructionsPart(ordMain);
    // 検証
    assertThat(result.getOrdNo(), nullValue());
    assertThat(result.getIndVaCd(), nullValue());
    assertThat(result.getIndTreatmentCd(), nullValue());
    assertThat(result.getIndTreatmentName(), nullValue());
    assertThat(result.getIndKurCd(), nullValue());
    assertThat(result.getIndKurName(), nullValue());
    assertThat(result.getIndTreatStartTime(), nullValue());
    assertThat(result.getIndBedCd(), nullValue());
    assertThat(result.getIndBedName(), nullValue());
    assertThat(result.getIndScheduleUserInfo(), is("{}"));
    assertThat(result.getIndCondInfo(), is("{}"));
    assertThat(result.getIndMediInfo(), is("[]"));
    assertThat(result.getIndEquipInfo(), is("[]"));
    assertThat(result.getIndIndCommentInfo(), is("[]"));
    assertThat(result.getIndTareInfo(), is("{}"));
    assertThat(result.getIndOffWaterInfo(), is("{}"));
    assertThat(result.getIndDeviceSetInfo(), is("{}"));
    assertThat(result.getTreatType(), nullValue());
    assertThat(result.getIndDw(), nullValue());
    assertThat(result.getIsDel(), is(AdminWebConstant.FlagType.FLAG_ON));
    assertThat(result.getRstFnDialysisNo(), is(2L));
    assertThat(result.getRstRelationDialysisNo(), is(3L));
    assertThat(result.getRstEdition(), is(10));
    assertThat(result.getRstIsUpdateEdition(), is("1"));
    assertThat(result.getRstInputClass(), is(Short.parseShort("100")));
    assertThat(result.getRstDialysisState(), is(AdminWebConstant.OrdMainConst.DialysisState.DIALYSIS));
    assertThat(result.getRstTreatmentCd(), is(102));
    assertThat(result.getRstTreatmentName(), is("テスト実績治療方法"));
    assertThat(result.getRstKurCd(), is(2));
    assertThat(result.getRstKurName(), is("テスト実績クール"));
    assertThat(result.getRstBedCd(), is(3));
    assertThat(result.getRstBedName(), is("テスト実績ベッド"));
    assertThat(result.getRstMachineNo(), is(1000L));
    assertThat(result.getRstMachineName(), is("テスト実績装置"));
    assertThat(result.getRstCondSendDate(), is(Timestamp.valueOf("2020-04-05 12:01:00")));
    assertThat(result.getRstAcceptDate(), is(Timestamp.valueOf("2020-04-05 12:02:00")));
    assertThat(result.getRstStartDate(), is(Timestamp.valueOf("2020-04-05 12:03:00")));
    assertThat(result.getRstEndDate(), is(Timestamp.valueOf("2020-04-05 12:04:00")));
    assertThat(result.getRstReturnHomeDate(), is(Timestamp.valueOf("2020-04-05 12:05:00")));
    assertThat(result.getRstInOutClass(), is(Short.parseShort("1")));
    assertThat(result.getRstDialysisCnt(), is(15));
    assertThat(result.getRstWardCd(), is(20));
    assertThat(result.getRstWardName(), is("テスト実績病棟"));
    assertThat(result.getRstCourseCd(), is(30));
    assertThat(result.getRstCourseName(), is("テスト実績診療科"));
    assertThat(result.getRstDw(), is(new BigDecimal("65.4")));
    assertThat(result.getRstPunctureUserInfo(), is("テスト実績穿刺者情報"));
    assertThat(result.getRstReturnUserInfo(), is("テスト実績返血者情報"));
    assertThat(result.getRstChargeUserInfo(), is("テスト実績担当者情報"));
    assertThat(result.getRstBloodCirculateTotal(), is(Double.valueOf(2)));
    assertThat(result.getRstRunningTime(), is(Short.parseShort("102")));
    assertThat(result.getRstKtV(), is(Double.valueOf(3)));
    assertThat(result.getRecSetDate(), is(Timestamp.valueOf("2020-04-05 12:06:00")));
    assertThat(result.getSendCtlNo(), is(2L));
    assertThat(result.getBloodPurifierName(), is("テスト血液浄化装置"));
    assertThat(result.getPullLeaveAmount(), is(Double.valueOf(10)));
    assertThat(result.getRstCondInfo(), is("テスト実績治療条件情報"));
    assertThat(result.getRstMediInfo(), is("テスト実績投与薬剤情報"));
    assertThat(result.getRstEquipInfo(), is("テスト実績医療材料情報"));
    assertThat(result.getRstIndCommentInfo(), is("テスト実績指示コメント情報"));
    assertThat(result.getRstTareInfo(), is("テスト実績風袋補正情報"));
    assertThat(result.getRstOffWaterInfo(), is("テスト実績除水補正情報"));
//    assertThat(result.getRstDeviceSetInfo(), is("テスト実績装置設定情報")); // del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正
    assertThat(result.getWeightScaleNo(), is(4L));
    assertThat(result.getRstWeightInfo(), is("56.7"));
//    assertThat(result.getRstVitalInfo(), is("テスト実績バイタル情報"));
    assertThat(result.getRstComplaintInfo(), is("テスト実績愁訴情報"));
    assertThat(result.getRstTreatmentInfo(), is("テスト実績愁訴処置情報"));
    assertThat(result.getRstTreatStaffInfo(), is("テスト実績愁訴処置者情報"));
    assertThat(result.getRstRoundsInfo(), is("テスト実績回診記録情報"));
    assertThat(result.getIsConfirm(), is(AdminWebConstant.FlagType.FLAG_ON));
    assertThat(result.getRstPurificationCnt(), is(5));
  }

  /**
   * clearResultPart(privateメソッド)をinvokeする.
   *
   * @param ordMain オーダ
   * @return 実績情報をクリアした{@link OrdMain}
   * @throws Throwable
   */
  private OrdMain invokeClearResultPart(OrdMain ordMain) throws Throwable {
    try {
      Method method = TreatmentRecordDeleteServiceImpl.class.getDeclaredMethod("clearResultPart", OrdMain.class);
      method.setAccessible(true);
      return (OrdMain) method.invoke(target, ordMain);
    } catch (Exception ex) {
      ex.printStackTrace();
      throw ex;
    }
  }

  /**
   * clearResultPart(privateメソッド)の検証.
   * @throws Throwable
   */
  @Test
  public void test_clearResultPart_成功() throws Throwable {
    // 事前準備
    OrdMain ordMain = createTestData();
    // 実行
    OrdMain result = invokeClearResultPart(ordMain);
    // 検証
    assertThat(result.getOrdNo(), is(1L));
    // 指示部分
    assertThat(result.getIndVaCd(), is(100));
    assertThat(result.getIndTreatmentCd(), is(101));
    assertThat(result.getIndTreatmentName(), is("テスト治療方法"));
    assertThat(result.getIndKurCd(), is(1));
    assertThat(result.getIndKurName(), is("テストクール"));
    assertThat(result.getIndTreatStartTime(), is("20200405"));
    assertThat(result.getIndBedCd(), is(2));
    assertThat(result.getIndBedName(), is("テストベッド"));
    assertThat(result.getIndScheduleUserInfo(), is("テスト指示治療予定指示者情報"));
    assertThat(result.getIndCondInfo(), is("テスト治療条件情報"));
    assertThat(result.getIndMediInfo(), is("テスト指示投与薬剤情報"));
    assertThat(result.getIndEquipInfo(), is("テスト指示医療材料情報"));
    assertThat(result.getIndIndCommentInfo(), is("テスト指示指示コメント情報"));
    assertThat(result.getIndTareInfo(), is("テスト指示風袋補正情報"));
    assertThat(result.getIndOffWaterInfo(), is("テスト指示除水補正情報"));
    assertThat(result.getIndDeviceSetInfo(), is("テスト指示装置設定情報"));
    assertThat(result.getTreatType(), is(Double.valueOf(1)));
    assertThat(result.getIndDw(), is(new BigDecimal(56.3)));
    assertThat(result.getIsDel(), is(AdminWebConstant.FlagType.FLAG_OFF));
    // 実績部分
    assertThat(result.getRstFnDialysisNo(), nullValue());
    assertThat(result.getRstRelationDialysisNo(), nullValue());
    assertThat(result.getRstEdition(), is(0));
    assertThat(result.getRstIsUpdateEdition(), nullValue());
    assertThat(result.getRstInputClass(), nullValue());
    assertThat(result.getRstDialysisState(), is(AdminWebConstant.OrdMainConst.DialysisState.BEFORE_SEND));
    assertThat(result.getRstTreatmentCd(), nullValue());
    assertThat(result.getRstTreatmentName(), nullValue());
    assertThat(result.getRstKurCd(), nullValue());
    assertThat(result.getRstKurName(), nullValue());
    assertThat(result.getRstBedCd(), nullValue());
    assertThat(result.getRstBedName(), nullValue());
    assertThat(result.getRstMachineNo(), nullValue());
    assertThat(result.getRstMachineName(), nullValue());
    assertThat(result.getRstCondSendDate(), nullValue());
    assertThat(result.getRstAcceptDate(), nullValue());
    assertThat(result.getRstStartDate(), nullValue());
    assertThat(result.getRstEndDate(), nullValue());
    assertThat(result.getRstReturnHomeDate(), nullValue());
    assertThat(result.getRstInOutClass(), nullValue());
    assertThat(result.getRstDialysisCnt(), nullValue());
    assertThat(result.getRstWardCd(), nullValue());
    assertThat(result.getRstWardName(), nullValue());
    assertThat(result.getRstCourseCd(), nullValue());
    assertThat(result.getRstCourseName(), nullValue());
    assertThat(result.getRstDw(), nullValue());
    assertThat(result.getRstPunctureUserInfo(), nullValue());
    assertThat(result.getRstReturnUserInfo(), nullValue());
    assertThat(result.getRstChargeUserInfo(), nullValue());
    assertThat(result.getRstBloodCirculateTotal(), nullValue());
    assertThat(result.getRstRunningTime(), nullValue());
    assertThat(result.getRstKtV(), nullValue());
    assertThat(result.getRecSetDate(), nullValue());
    assertThat(result.getSendCtlNo(), nullValue());
    assertThat(result.getBloodPurifierName(), nullValue());
    assertThat(result.getPullLeaveAmount(), nullValue());
    assertThat(result.getRstCondInfo(), nullValue());
    assertThat(result.getRstMediInfo(), nullValue());
    assertThat(result.getRstEquipInfo(), nullValue());
    assertThat(result.getRstIndCommentInfo(), nullValue());
    assertThat(result.getRstTareInfo(), nullValue());
    assertThat(result.getRstOffWaterInfo(), nullValue());
//    assertThat(result.getRstDeviceSetInfo(), nullValue()); // del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正
    assertThat(result.getWeightScaleNo(), nullValue());
    assertThat(result.getRstWeightInfo(), nullValue());
//    assertThat(result.getRstVitalInfo(), nullValue());
    assertThat(result.getRstComplaintInfo(), nullValue());
    assertThat(result.getRstTreatmentInfo(), nullValue());
    assertThat(result.getRstTreatStaffInfo(), nullValue());
    assertThat(result.getRstRoundsInfo(), nullValue());
    assertThat(result.getIsConfirm(), is(AdminWebConstant.FlagType.FLAG_OFF));
    assertThat(result.getRstPurificationCnt(), nullValue());
  }

  /**
   * テスト用の{@link OrdMain}を生成する.
   *
   * @return テスト用のオーダ
   */
  private OrdMain createTestData() {
    OrdMain ordMain = new OrdMain();
    // オーダ番号
    ordMain.setOrdNo(1L);
    // 施設コード
    ordMain.setFacilityCd("009999");
    // 患者番号
    ordMain.setPatId(1001L);
    // 指示：VAコード
    ordMain.setIndVaCd(100);
    // 指示：治療方法コード
    ordMain.setIndTreatmentCd(101);
    // 指示：治療方法名
    ordMain.setIndTreatmentName("テスト治療方法");
    // 指示：クールコード
    ordMain.setIndKurCd(1);
    // 指示：クール名
    ordMain.setIndKurName("テストクール");
    // 指示：治療開始時刻
    ordMain.setIndTreatStartTime("20200405");
    // 指示：ベッドコード
    ordMain.setIndBedCd(2);
    // 指示：ベッド名
    ordMain.setIndBedName("テストベッド");
    // 指示：治療予定指示者情報
    ordMain.setIndScheduleUserInfo("テスト指示治療予定指示者情報");
    // 指示：治療条件情報
    ordMain.setIndCondInfo("テスト治療条件情報");
    // 指示：投与薬剤情報
    ordMain.setIndMediInfo("テスト指示投与薬剤情報");
    // 指示：医療材料情報
    ordMain.setIndEquipInfo("テスト指示医療材料情報");
    // 指示：指示コメント情報
    ordMain.setIndIndCommentInfo("テスト指示指示コメント情報");
    // 指示：風袋補正
    ordMain.setIndTareInfo("テスト指示風袋補正情報");
    // 指示：除水補正
    ordMain.setIndOffWaterInfo("テスト指示除水補正情報");
    // 指示：装置設定情報
    ordMain.setIndDeviceSetInfo("テスト指示装置設定情報");
    // 治療種別
    ordMain.setTreatType(Double.valueOf(1));
    // 指示：DW
    ordMain.setIndDw(new BigDecimal(56.3));
    // 削除フラグ
    ordMain.setIsDel(AdminWebConstant.FlagType.FLAG_OFF);
    // --------------------------------
    // 実績部
    // --------------------------------
    // 実績：FNW+透析番号
    ordMain.setRstFnDialysisNo(2L);
    // 実績：関連透析番号
    ordMain.setRstRelationDialysisNo(3L);
    // 実績：版番号
    ordMain.setRstEdition(10);
    // 実績：版番号更新フラグ
    ordMain.setRstIsUpdateEdition("1");
    // 実績：登録区分
    ordMain.setRstInputClass(Short.parseShort("100"));
    // 実績：治療状況
    ordMain.setRstDialysisState(AdminWebConstant.OrdMainConst.DialysisState.DIALYSIS);
    // 実績：治療方法コード
    ordMain.setRstTreatmentCd(102);
    // 実績：治療方法名
    ordMain.setRstTreatmentName("テスト実績治療方法");
    // 実績：クールコード
    ordMain.setRstKurCd(2);
    // 実績：クール名
    ordMain.setRstKurName("テスト実績クール");
    // 実績：ベッドコード
    ordMain.setRstBedCd(3L);
    // 実績：ベッド名
    ordMain.setRstBedName("テスト実績ベッド");
    // 実績：装置番号
    ordMain.setRstMachineNo(1000L);
    // 実績：装置名
    ordMain.setRstMachineName("テスト実績装置");
    // 実績：条件送信日時
    ordMain.setRstCondSendDate(Timestamp.valueOf("2020-04-05 12:01:00"));
    // 実績：受付日時
    ordMain.setRstAcceptDate(Timestamp.valueOf("2020-04-05 12:02:00"));
    // 実績：治療開始日時
    ordMain.setRstStartDate(Timestamp.valueOf("2020-04-05 12:03:00"));
    // 実績：治療終了日時
    ordMain.setRstEndDate(Timestamp.valueOf("2020-04-05 12:04:00"));
    // 実績：帰宅日時
    ordMain.setRstReturnHomeDate(Timestamp.valueOf("2020-04-05 12:05:00"));
    // 実績：入外区分
    ordMain.setRstInOutClass(Short.parseShort("1"));
    // 実績：透析回数
    ordMain.setRstDialysisCnt(15);
    // 実績：病棟コード
    ordMain.setRstWardCd(20);
    // 実績：病棟名
    ordMain.setRstWardName("テスト実績病棟");
    // 実績：診療科コード
    ordMain.setRstCourseCd(30);
    // 実績：診療科名
    ordMain.setRstCourseName("テスト実績診療科");
    // 実績：DW
    ordMain.setRstDw(new BigDecimal("65.4"));
    // 実績：穿刺者情報
    ordMain.setRstPunctureUserInfo("テスト実績穿刺者情報");
    // 実績：返血者情報
    ordMain.setRstReturnUserInfo("テスト実績返血者情報");
    // 実績：担当者情報
    ordMain.setRstChargeUserInfo("テスト実績担当者情報");
    // 実績：血液循環積算値
    ordMain.setRstBloodCirculateTotal(Double.valueOf(2));
    // 実績：透析運転時間
    ordMain.setRstRunningTime(Short.parseShort("102"));
    // 実績：Kt/V
    ordMain.setRstKtV(Double.valueOf(3));
    // 実績：透析記録確認日時
    ordMain.setRecSetDate(Timestamp.valueOf("2020-04-05 12:06:00"));
    // 実績：送信管理番号
    ordMain.setSendCtlNo(2L);
    // 実績：血液浄化装置名称
    ordMain.setBloodPurifierName("テスト血液浄化装置");
    // 実績：プログラム補液引き残し量
    ordMain.setPullLeaveAmount(Double.valueOf(10));
    // 実績：治療条件情報
    ordMain.setRstCondInfo("テスト実績治療条件情報");
    // 実績：投与薬剤情報
    ordMain.setRstMediInfo("テスト実績投与薬剤情報");
    // 実績：医療材料情報
    ordMain.setRstEquipInfo("テスト実績医療材料情報");
    // 実績：指示コメント情報
    ordMain.setRstIndCommentInfo("テスト実績指示コメント情報");
    // 実績：風袋補正
    ordMain.setRstTareInfo("テスト実績風袋補正情報");
    // 実績：除水補正
    ordMain.setRstOffWaterInfo("テスト実績除水補正情報");
    /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --start */
//    // 実績：装置設定情報
//    ordMain.setRstDeviceSetInfo("テスト実績装置設定情報");
    /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --end */
    // 実績：体重測定記録番号
    ordMain.setWeightScaleNo(4L);
    // 実績：体重情報
    ordMain.setRstWeightInfo("56.7");
    // 実績：バイタル情報
//    ordMain.setRstVitalInfo("テスト実績バイタル情報");
    // 実績：愁訴情報
    ordMain.setRstComplaintInfo("テスト実績愁訴情報");
    // 実績：愁訴処置情報
    ordMain.setRstTreatmentInfo("テスト実績愁訴処置情報");
    // 実績：愁訴処置者情報
    ordMain.setRstTreatStaffInfo("テスト実績愁訴処置者情報");
    // 実績：回診記録情報
    ordMain.setRstRoundsInfo("テスト実績回診記録情報");
    // 実績：確定フラグ
    ordMain.setIsConfirm(AdminWebConstant.FlagType.FLAG_ON);
    // 実績：特殊浄化回数
    ordMain.setRstPurificationCnt(5);

    return ordMain;
  }


}
