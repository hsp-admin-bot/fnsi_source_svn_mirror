package jp.co.nikkiso.ntss.coop_api.service;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.junit.Assert.assertThat;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.SpyBean;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.coop_api.request.CallApiJournalRequest;
import jp.co.nikkiso.ntss.coop_api.utils.ClockWrapper;
import jp.co.nikkiso.ntss.core.dao.SysCoopJournalDao;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;

@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:resource.script/CallApiServiceImplTest/CallApiServiceImplTest.db5.before.sql")
public class CallApiServiceImplTest extends BaseServiceTest {

  @SpyBean
  CallApiServiceImpl service;

  @Autowired
  ClockWrapper clockWrapper;

  @Autowired
  SysCoopJournalDao sysCoopJournalDao;

  @Test
  public void 正常系_連携API関連付けなし() {

    CallApiJournalRequest request = new CallApiJournalRequest();
    String facilityCd="TEST01";
    request.setFacilityCd(facilityCd);
    request.setCoopCd("0");
    request.setCoopCdIndex("aaaaaa");
    request.setCrud("C");
    request.setDirection("S");
    request.setApiTimingIo("I");
    request.setApiTimingBa("B");


    boolean result = service.callApiJournal(request, null, null);

    assertThat(result, is(true));

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.select(request.getFacilityCd(), request.getCoopCd(), request.getCoopCdIndex(), request.getCrud(), request.getDirection());

    assertThat(sysCoopJournal, is(nullValue()));

  }
}
