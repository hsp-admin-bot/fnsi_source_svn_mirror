package jp.co.nikkiso.ntss.core.dao;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.entity.MntIfEdgeManage;

@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:dao.script/MntIfEdgeManageDaoTest.before.sql")
public class MntIfEdgeManageDaoTest {
  @Autowired
  MntIfEdgeManageDao dao;

  @Test
  public void 正常系_selectByFacilityCdAndStatus() {

    // SELECT
    MntIfEdgeManage mntIfEdgeManage = dao.selectByFacilityCdAndStatus("001", 0);

    assertThat(mntIfEdgeManage.getFacilityCd(), is("001"));
    assertThat(mntIfEdgeManage.getResponseStatus(), is(0));
    assertThat(mntIfEdgeManage.getEdgeResult().getValue(), is("{\"system\":\"NTSS\",\"status\":\"result\",\"facility_cd\":\"99999\",\"result\":{\"ctl_no\":18,\"status\":200,\"message\":\"OK\"}}"));
    assertThat(mntIfEdgeManage.getIsDel(), is("0"));
  }

  @Test
  public void 正常系_selectByCtlNo() {

    // SELECT
    MntIfEdgeManage mntIfEdgeManage = dao.selectByFacilityCdAndStatus("002", 0);

    // SELECT
    MntIfEdgeManage result = dao.selectByCtlNo(mntIfEdgeManage.getCtlNo());

    assertThat(result.getFacilityCd(), is("002"));
    assertThat(result.getResponseStatus(), is(0));
    assertThat(result.getEdgeResult().getValue(), is("{\"system\":\"NTSS\",\"status\":\"result\",\"facility_cd\":\"99999\",\"result\":{\"ctl_no\":19,\"status\":200,\"message\":\"OK\"}}"));
    assertThat(result.getIsDel(), is("0"));
  }

  @Test
  public void 正常系_insert() {
    MntIfEdgeManage mntIfEdgeManage = new MntIfEdgeManage();
    mntIfEdgeManage.setFacilityCd("003");
    mntIfEdgeManage.setResponseStatus(3);
    MntIfEdgeManage.EdgeResult edgeResult= new MntIfEdgeManage.EdgeResult("{\"system\":\"NTSS\",\"status\":\"result\",\"facility_cd\":\"99999\",\"result\":{\"ctl_no\":19,\"status\":200,\"message\":\"OK\"}}");
    mntIfEdgeManage.setEdgeResult(edgeResult);
    mntIfEdgeManage.setIsDel("0");
    int ret = dao.insert(mntIfEdgeManage);

    assertThat(ret, is(1));

    // INSERTしたのをSELECT
    MntIfEdgeManage result = dao.selectByFacilityCdAndStatus("003", 3);

    assertThat(result.getFacilityCd(), is("003"));
    assertThat(result.getResponseStatus(), is(3));
    assertThat(result.getEdgeResult().getValue(), is("{\"system\":\"NTSS\",\"status\":\"result\",\"facility_cd\":\"99999\",\"result\":{\"ctl_no\":19,\"status\":200,\"message\":\"OK\"}}"));
    assertThat(result.getIsDel(), is("0"));
  }

  @Test
  public void 正常系_update() {
    // UPDATEの元ネタをセレクト
    MntIfEdgeManage mntIfEdgeManage = dao.selectByFacilityCdAndStatus("004", 0);
    mntIfEdgeManage.setResponseStatus(6);
    MntIfEdgeManage.EdgeResult edgeResult= new MntIfEdgeManage.EdgeResult("{\"system\":\"A\",\"status\":\"A\",\"facility_cd\":\"A\",\"result\":{\"ctl_no\":19,\"status\":5,\"message\":\"E\"}}");
    mntIfEdgeManage.setEdgeResult(edgeResult);
    int ret = dao.update(mntIfEdgeManage);
    assertThat(ret, is(1));

    // UPDATEしたのをSELECT
    MntIfEdgeManage result = dao.selectByCtlNo(mntIfEdgeManage.getCtlNo());

    assertThat(result.getFacilityCd(), is("004"));
    assertThat(result.getResponseStatus(), is(6));
    assertThat(result.getEdgeResult().getValue(), is("{\"system\":\"A\",\"status\":\"A\",\"facility_cd\":\"A\",\"result\":{\"ctl_no\":19,\"status\":5,\"message\":\"E\"}}"));
    assertThat(result.getIsDel(), is("0"));
  }
}
