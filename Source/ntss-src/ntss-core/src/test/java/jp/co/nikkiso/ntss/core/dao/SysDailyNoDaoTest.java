package jp.co.nikkiso.ntss.core.dao;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;

import java.sql.Timestamp;
import java.util.Calendar;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.entity.SysDailyNo;

@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:dao.script/SysDailyNoDaoTest.before.sql")
public class SysDailyNoDaoTest {
  @Autowired
  SysDailyNoDao dao;

  @Test
  public void 正常系_insertAndselectDateList() {
    Calendar nowCal = Calendar.getInstance();
    nowCal.setTimeInMillis(System.currentTimeMillis());

    // INSERT
    Timestamp nowTimestamp = new Timestamp(nowCal.getTimeInMillis());
    SysDailyNo sysDailyNo = new SysDailyNo();
    sysDailyNo.setFacilityCd("001");
    sysDailyNo.setNumberingCd("12345678901234567890");
//    sysDailyNo.setCurrentNo(new SysDailyNo.CurrentNo("{\"current_no\":[{\"date\": 1, \"up_date\": \"2020-04-10 10:03:44.459\", \"current_no\": 0}]}"));
    sysDailyNo.setIsDisp("1");
    sysDailyNo.setIsDel("0");
    sysDailyNo.setUpDate(nowTimestamp);
    sysDailyNo.setRegDate(nowTimestamp);
    dao.insert(sysDailyNo);

    // SELECT確認
    SysDailyNo retList = dao.selectDateList("001", "12345678901234567890");

    Calendar upDateCal = Calendar.getInstance();
    upDateCal.setTimeInMillis(retList.getUpDate().getTime());
    Calendar regDateCal = Calendar.getInstance();
    regDateCal.setTimeInMillis(retList.getRegDate().getTime());

    assertThat(retList.getFacilityCd(), is("001"));
    assertThat(retList.getNumberingCd(), is("12345678901234567890"));
//    assertThat(retList.getCurrentNo().getValue(), is(notNullValue()));// 順番が入れ替わるのでNULLでなければOK
    assertThat(retList.getIsDisp(), is("1"));
    assertThat(retList.getIsDel(), is("0"));

    // とりあえず日付まで
    assertThat(nowCal.get(Calendar.YEAR), is(upDateCal.get(Calendar.YEAR)));
    assertThat(nowCal.get(Calendar.MONTH), is(upDateCal.get(Calendar.MONTH)));
    assertThat(nowCal.get(Calendar.DATE), is(upDateCal.get(Calendar.DATE)));
    assertThat(nowCal.get(Calendar.YEAR), is(regDateCal.get(Calendar.YEAR)));
    assertThat(nowCal.get(Calendar.MONTH), is(regDateCal.get(Calendar.MONTH)));
    assertThat(nowCal.get(Calendar.DATE), is(regDateCal.get(Calendar.DATE)));
  }

  @Test
  public void 正常系_update() {
    Calendar nowCal = Calendar.getInstance();
    nowCal.setTimeInMillis(System.currentTimeMillis());

    SysDailyNo sysDailyNo = dao.selectDateList("003", "12345678901234567890");
//    sysDailyNo.setCurrentNo(new SysDailyNo.CurrentNo("{\"current_no\":[{\"date\": 1, \"up_date\": \"2020-04-10 10:03:44.459\", \"current_no\": 0}]}"));
    sysDailyNo.setIsDisp("2");
    sysDailyNo.setIsDel("0");
    dao.updateByCtlNo(sysDailyNo, sysDailyNo.getUpDate());

    SysDailyNo retSysDailyNoUpdate = dao.selectDateList("003", "12345678901234567890");

    Calendar upDateCalafterUpdate = Calendar.getInstance();
    upDateCalafterUpdate.setTimeInMillis(retSysDailyNoUpdate.getUpDate().getTime());
    Calendar regDateCalafterUpdate = Calendar.getInstance();
    regDateCalafterUpdate.setTimeInMillis(retSysDailyNoUpdate.getRegDate().getTime());

    assertThat(retSysDailyNoUpdate.getFacilityCd(), is("003"));
    assertThat(retSysDailyNoUpdate.getNumberingCd(), is("12345678901234567890"));
    assertThat(retSysDailyNoUpdate.getIsDisp(), is("2"));
    assertThat(retSysDailyNoUpdate.getIsDel(), is("0"));
  }
}
