package jp.co.nikkiso.ntss.core.dao;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.nullValue;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.entity.MstIfEdgeCommand;

@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:dao.script/MstIfEdgeCommandDaoTest.before.sql")
public class MstIfEdgeCommandDaoTest {
  @Autowired
  MstIfEdgeCommandDao dao;

  @Test
  public void 正常系_selectByKey_データあり() {

    // SELECT
    MstIfEdgeCommand mstIfEdgeCommand = dao.selectByKey("start");

    assertThat(mstIfEdgeCommand.getCommandKey(), is("start"));
    assertThat(mstIfEdgeCommand.getCommand(), is("commandtest"));
    assertThat(mstIfEdgeCommand.getIsDel(), is("0"));
  }
  @Test
  public void 正常系_selectByKey_データなし() {

    // SELECT
    MstIfEdgeCommand mstIfEdgeCommand = dao.selectByKey("end");

    assertThat(mstIfEdgeCommand, is(nullValue()));
  }
}
