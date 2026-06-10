package jp.co.nikkiso.ntss.admin_web.service;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.junit4.SpringRunner;

import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterListResponse;
import jp.co.nikkiso.ntss.admin_web.service.master.MasterListService;
import jp.co.nikkiso.ntss.core.dao.SysMasterDefineDao;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * MasterListServiceImplのテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
public class MasterListServiceImplTest {

  /**
   * テスト対象クラス.
   */
  @Autowired
  private MasterListService target;

  /**
   * マスタ定義のMockBean.
   */
  @MockBean
  private SysMasterDefineDao sysMasterDefineDao;
  
  /**
   * 検証用のマスタ定義データ
   */
  private List<SysMasterDefine> getMasterDefineList() {
    List<SysMasterDefine> masterDefineList = new ArrayList<>();
    for (int i = 1; i <= 2; i++) {
      SysMasterDefine mst = new SysMasterDefine();
      mst.setMasterPhysicalName(String.format("%06d", i));
      mst.setMasterName(String.format("マスタ名称%d", i));
      mst.setMode(Integer.toString(i));
      
      masterDefineList.add(mst);
    }
    return masterDefineList;
  }

  /**
   * getMasterList()の検証.
   *
   * 条件：マスタ一覧が複数件取得、userTypeあり
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_getMasterList_正常_ユーザータイプあり_複数データ取得() {

    // 事前準備
    List<SysMasterDefine> masterList = getMasterDefineList();

    // Mock化
    given(sysMasterDefineDao.selectByUserType(CoreConstant.UserType.NIKKISO)).willReturn(masterList);

    // 実行
    MasterListResponse result = target.getMasterList(Integer.parseInt(CoreConstant.UserType.NIKKISO));

    // 検証
    verify(sysMasterDefineDao, times(1)).selectByUserType(CoreConstant.UserType.NIKKISO);
    assertThat(result, notNullValue());
    assertThat(result.masterList.size(), is(masterList.size()));
    for (int i = 0; i < result.masterList.size(); i++) {
      assertThat(result.masterList.get(i).masterPhysicalName, is(masterList.get(i).getMasterPhysicalName()));
      assertThat(result.masterList.get(i).masterName, is(masterList.get(i).getMasterName()));
      assertThat(result.masterList.get(i).mode, is(masterList.get(i).getMode()));
      assertThat(result.masterList.get(i).editLevel, is(masterList.get(i).getEditLevel()));
    }
    
  }
  
  /**
   * getMasterList()の検証.
   *
   * 条件：マスタ一覧がゼロ件取得、userTypeあり
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_getMasterList_正常_ユーザータイプあり_ゼロ件取得() {

    // 事前準備
    List<SysMasterDefine> masterList = Collections.emptyList();

    // Mock化
    given(sysMasterDefineDao.selectByUserType(CoreConstant.UserType.NIKKISO)).willReturn(masterList);

    // 実行
    MasterListResponse result = target.getMasterList(Integer.parseInt(CoreConstant.UserType.NIKKISO));

    // 検証
    verify(sysMasterDefineDao, times(1)).selectByUserType(CoreConstant.UserType.NIKKISO);
    assertThat(result, notNullValue());
    assertThat(result.masterList.size(), is(0));
  }

  /**
   * getMasterList()の検証.
   *
   * 条件：マスタ一覧が複数件取得、userTypeがNULL値
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_getMasterList_正常_ユーザータイプNull_複数データ取得() {

    // 事前準備
    List<SysMasterDefine> masterList = getMasterDefineList();

    // Mock化
    given(sysMasterDefineDao.selectByUserType(null)).willReturn(masterList);

    // 実行
    MasterListResponse result = target.getMasterList(null);

    // 検証
    verify(sysMasterDefineDao, times(1)).selectByUserType(null);
    assertThat(result, notNullValue());
    assertThat(result.masterList.size(), is(masterList.size()));
    for (int i = 0; i < result.masterList.size(); i++) {
      assertThat(result.masterList.get(i).masterPhysicalName, is(masterList.get(i).getMasterPhysicalName()));
      assertThat(result.masterList.get(i).masterName, is(masterList.get(i).getMasterName()));
      assertThat(result.masterList.get(i).mode, is(masterList.get(i).getMode()));
      assertThat(result.masterList.get(i).editLevel, is(masterList.get(i).getEditLevel()));
    }

  }

  /**
   * getMasterList()の検証.
   *
   * 条件：マスタ一覧がゼロ件取得、userTypeがNULL値
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_getMasterList_正常_ユーザータイプNull_ゼロ件取得() {

    // 事前準備
    List<SysMasterDefine> masterList = Collections.emptyList();

    // Mock化
    given(sysMasterDefineDao.selectByUserType(null)).willReturn(masterList);

    // 実行(•
    MasterListResponse result = target.getMasterList(null);

    // 検証
    verify(sysMasterDefineDao, times(1)).selectByUserType(null);
    assertThat(result, notNullValue());
    assertThat(result.masterList.size(), is(0));
  }

}
