package jp.co.nikkiso.ntss.core.dao;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.junit.Assert.assertThat;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.entity.MstCoopFacility;

@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:dao.script/MstCoopFacilityDaoTest.before.sql")
public class MstCoopFacilityDaoTest {
  @Autowired
  MstCoopFacilityDao dao;

  @Test
  public void 正常系_select_データあり() {
    String facilityCd = "TEST01";
    MstCoopFacility mstCoopFacility = dao.select(facilityCd);
    assertThat(mstCoopFacility, is(notNullValue()));
    assertThat(mstCoopFacility.getFacilityCd(), is(facilityCd));
    assertThat(mstCoopFacility.getIfEdgeSetting(), is("{\"receive\": {\"pat\": {\"data\": \"C:\\\\work\\\\tmpDir\\\\data\", \"watch\": \"C:\\\\work\\\\tmpDir\\\\watch\", \"protocol\": \"file\"}}, \"facility_cd\": \"1\"}"));
    assertThat(mstCoopFacility.getCommonSetting(), is(notNullValue()));
    assertThat(mstCoopFacility.getRegDate(), is(notNullValue()));
    assertThat(mstCoopFacility.getUpDate(), is(notNullValue()));
  }

  @Test
  public void 正常系_select_データなし() {
    String facilityCd = "TEST02";
    MstCoopFacility mstCoopFacility = dao.select(facilityCd);
    assertThat(mstCoopFacility, is(nullValue()));
  }


}
