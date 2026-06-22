package jp.co.nikkiso.ntss.core.dao;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.not;
import static org.hamcrest.Matchers.nullValue;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.entity.MntIfEdgeClientConnect;

@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:dao.script/MntIfEdgeClientConnectDaoTest.before.sql")
public class MntIfEdgeClientConnectDaoTest {
  @Autowired
  MntIfEdgeClientConnectDao dao;

  @Test
  public void 正常系_selectByFacilityCd() {

    // SELECT
    MntIfEdgeClientConnect mntIfEdgeClientConnect = dao.selectByFacilityCd("001");

    assertThat(mntIfEdgeClientConnect.getFacilityCd(), is("001"));
  }

  @Test
  public void 正常系_insert() {
    MntIfEdgeClientConnect mntIfEdgeClientConnect = new MntIfEdgeClientConnect();
    mntIfEdgeClientConnect.setFacilityCd("002");
    mntIfEdgeClientConnect.setIpAddress("127.0.0.1");
    int ret = dao.insert(mntIfEdgeClientConnect);

    assertThat(ret, is(1));

    // INSERTしたのをSELECT
    MntIfEdgeClientConnect result = dao.selectByFacilityCd("002");

    assertThat(result.getFacilityCd(), is("002"));
    assertThat(result.getIpAddress(), is("127.0.0.1"));
  }

  @Test
  public void 正常系_delete() {

    // SELECT
    MntIfEdgeClientConnect mntIfEdgeClientConnect = dao.selectByFacilityCd("003");
    dao.delete(mntIfEdgeClientConnect);

    // SELECT
    MntIfEdgeClientConnect result = dao.selectByFacilityCd("003");

    assertThat(result, nullValue());

  }

  @Test
  public void 正常系_update() {

    // SELECT
    MntIfEdgeClientConnect beforeMntIfEdgeClientConnect = dao.selectByFacilityCd("004");
    beforeMntIfEdgeClientConnect.setIpAddress("111.111.111.111");
    dao.update(beforeMntIfEdgeClientConnect);

    // SELECT
    MntIfEdgeClientConnect result = dao.selectByFacilityCd("004");

    assertThat(result.getUpDate(), not(beforeMntIfEdgeClientConnect.getUpDate()));
    assertThat(result.getIpAddress(), is("111.111.111.111"));

  }
}
