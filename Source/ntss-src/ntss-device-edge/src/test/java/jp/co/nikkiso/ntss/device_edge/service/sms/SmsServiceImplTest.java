package jp.co.nikkiso.ntss.device_edge.service.sms;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.core.IsNull.notNullValue;
import static org.mockito.BDDMockito.any;
import static org.mockito.BDDMockito.anyString;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;

import java.util.ArrayList;
import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.junit4.SpringRunner;

import jp.co.nikkiso.ntss.core.dao.Db6FunctionDao;
import jp.co.nikkiso.ntss.core.dao.MstAlarmNotificationDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.entity.MstAlarmNotification;
import jp.co.nikkiso.ntss.core.entity.MstAlarmNotification.TargetMachineRecord;
import jp.co.nikkiso.ntss.core.entity.MstAlarmNotification.TargetMachineRecordCd;

@RunWith(SpringRunner.class)
@SpringBootTest
public class SmsServiceImplTest {

  /**
   * テスト対象クラス.
   */
  @Autowired
  SmsService smsService;

  /**
   * 警報通知マスタDaoのMockBean.
   */
  @MockitoBean
  private MstAlarmNotificationDao mstAlarmNotificationDao;
  @MockitoBean
  private Db6FunctionDao db6FunctionDao;
  @MockitoBean
  private MstFacilityDao mstFacilityDao;

  @Test
  public void test_buildNotificationCdList_OK_主キーの一覧がLF区切りで取得できること() {
    String destinationFacilityCd = "test00";
    String separetor = "\n";
    Long[] alarmNotificationCd = {1L, 10L, 100L, 1000L};
    List<MstAlarmNotification> listMstAlmNotify = new ArrayList<MstAlarmNotification>();
    MstAlarmNotification mst0 = new MstAlarmNotification();
    MstAlarmNotification mst1 = new MstAlarmNotification();
    MstAlarmNotification mst2 = new MstAlarmNotification();
    MstAlarmNotification mst3 = new MstAlarmNotification();
    mst0.setAlarmNotificationCd(alarmNotificationCd[0]);
    mst0.setSmsTel("606060");
    mst1.setAlarmNotificationCd(alarmNotificationCd[1]);
    mst1.setSmsTel("606060");
    mst2.setAlarmNotificationCd(alarmNotificationCd[2]);
    mst2.setSmsTel("606060");
    mst3.setAlarmNotificationCd(alarmNotificationCd[3]);
    listMstAlmNotify.add(mst0);
    listMstAlmNotify.add(mst1);
    listMstAlmNotify.add(mst2);
    listMstAlmNotify.add(mst3);

    // Mock化
    given(mstAlarmNotificationDao.selectByDestinationFacilityCd(any())).willReturn(listMstAlmNotify);

    String result = smsService.buildNotificationCdList(destinationFacilityCd, separetor);

    // 検証
    verify(mstAlarmNotificationDao, times(1)).selectByDestinationFacilityCd(destinationFacilityCd);
    assertThat(result, notNullValue());
    assertThat(result, is("1\n10\n100"));
  }

  @Test
  public void test_buildNotificationConfig_OK_設定項目を返すこと() {
    Long alarmNotificationCd = 1L;
    MstAlarmNotification mst = new MstAlarmNotification();
    mst.setFacilityCd("test00");
    mst.setAlarmNotificationCd(alarmNotificationCd);
    mst.setDestinationFacilityCd("dest00");
    mst.setSmsTel("60626466686a6c6e7072");
    mst.setIsNoticeSun("1");
    mst.setIsNextDaySun("0");
    mst.setStartTimeSun("00:00");
    mst.setEndTimeSun("12:00");
    mst.setIsNoticeMon("1");
    mst.setIsNextDayMon("0");
    mst.setIsNoticeTue("1");
    mst.setIsNextDayTue("0");
    mst.setIsNoticeWed("1");
    mst.setIsNextDayWed("0");
    mst.setIsNoticeThu("1");
    mst.setIsNextDayThu("0");
    mst.setIsNoticeFri("1");
    mst.setIsNextDayFri("0");
    mst.setIsNoticeSat("1");
    mst.setIsNextDaySat("0");
    TargetMachineRecord rcd = new TargetMachineRecord();
    List<TargetMachineRecordCd> rcds = new ArrayList<>();
    TargetMachineRecordCd cd = new TargetMachineRecordCd();
    cd.setMachineRecordCd("AAAA");
    rcds.add(cd);
    TargetMachineRecordCd cd2 = new TargetMachineRecordCd();
    cd2.setMachineRecordCd("BBBB");
    rcds.add(cd2);
    rcd.setCds(rcds);
    mst.setTargetMachineRecord(rcd);

    // Mock化
    given(mstAlarmNotificationDao.selectByAlarmNotificationCd(any())).willReturn(mst);
    given(db6FunctionDao.personalInfoDecrypto(anyString())).willReturn("0123456789");
    given(mstFacilityDao.selectNameByCd(anyString())).willReturn("１２３４５６７８９０\n1234567890\r\nABCDEFGHIJKLMN");

    String result = smsService.buildNotificationConfig(alarmNotificationCd);

    // 検証
    verify(mstAlarmNotificationDao, times(1)).selectByAlarmNotificationCd(alarmNotificationCd);
    assertThat(result, notNullValue());
    assertThat(result, is("test00１２３４５６７８９０1234567890ABCDEFGHIJK…\n100000120010        10        10        10        10        10        81123456789\nAAAA\nBBBB\n"));

  }
}
