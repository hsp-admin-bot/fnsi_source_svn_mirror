package jp.co.nikkiso.ntss.admin_web.service;

import jp.co.nikkiso.ntss.core.dao.MstPatViewerLayoutDao;
import jp.co.nikkiso.ntss.core.entity.custom.MstPatViewerLayoutMonitorItem;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.junit4.SpringRunner;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.junit.Assert.assertThat;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

/**
 * {@link MstInfoServiceImpl} のテストクラス
 */
@RunWith(SpringRunner.class)
@SpringBootTest
public class MstInfoServiceImplTest {

  /**
   * テストクラス.
   */
  @Autowired
  private MstInfoService target;

  /**
   * {@link jp.co.nikkiso.ntss.core.dao.MstPatViewerLayoutDao}のMockBean.
   */
  @MockitoBean
  private MstPatViewerLayoutDao mstPatViewerLayoutDao;

  /**
   * {@link MstInfoService#selectMonitorItemForMstPatViewerLayout(String)} の検証.
   *
   * <p>
   * 条件：データなし
   * 結果：空のリストが返却される事
   * <p>
   */
  @Test
  public void test_selectMonitorItemForMstPatViewerLayout_正常_データなし() {
    // 事前準備
    String facilityCd = "1001";
    List<MstPatViewerLayoutMonitorItem> mstPatViewerLayoutMonitorItemList = Collections.emptyList();
    // Mock化
    given(mstPatViewerLayoutDao.selectMonitorItem(facilityCd,null,null)).willReturn(mstPatViewerLayoutMonitorItemList);
    // 実行
    List<MstPatViewerLayoutMonitorItem> result = target.selectMonitorItemForMstPatViewerLayout(facilityCd,null,null);
    // 検証
    verify(mstPatViewerLayoutDao, times(1)).selectMonitorItem(facilityCd,null,null);
    assertThat(result, notNullValue());
    assertThat(result, is(Collections.emptyList()));
  }

  /**
   * {@link MstInfoService#selectMonitorItemForMstPatViewerLayout(String)} の検証.
   *
   * <p>
   * 条件：データあり
   * 結果：リストが返却される事
   * <p>
   */
  @Test
  public void test_selectMonitorItemForMstPatViewerLayout_正常_データあり() {
    // 事前準備
    String facilityCd = "1001";
    List<MstPatViewerLayoutMonitorItem> mstPatViewerLayoutMonitorItemList = createTestData();
    // Mock化
    given(mstPatViewerLayoutDao.selectMonitorItem(facilityCd,null,null)).willReturn(mstPatViewerLayoutMonitorItemList);
    // 実行
    List<MstPatViewerLayoutMonitorItem> result = target.selectMonitorItemForMstPatViewerLayout(facilityCd,null,null);
    // 検証
    verify(mstPatViewerLayoutDao, times(1)).selectMonitorItem(facilityCd,null,null);
    assertThat(result, notNullValue());
    assertThat(result.size(), is(10));
    for (int index = 0; index < result.size(); index++) {
      assertThat(result.get(index).getTableType(), is(1));
      assertThat(result.get(index).getMoniDataNo(), is(String.valueOf(index)));
      assertThat(result.get(index).getVitalMonitorClass(), is("1"));
      assertThat(result.get(index).getVitalMonitorItemName(), is("テストバイタルモニタ項目_" + index));
    }
  }

  /**
   * {@link MstInfoService#selectMonitorItemForMstPatViewerLayout(String)} の検証用データを作成する.
   * ※テストデータは10件作成する.
   * ※設定されるテスト用データの値は下記の通り
   *   tableType : 1(固定)
   *   moniDataNo : 0 ~ 9
   *   vitalMonitorClass : "1"(固定)
   *   vitalMonitorItemName : "テストバイタルモニタ項目_" + 0 ~ 9
   *
   * @return 作成したテストデータ
   */
  private List<MstPatViewerLayoutMonitorItem> createTestData() {
    List<MstPatViewerLayoutMonitorItem> testDate = new ArrayList<>();
    for (int index = 0; index < 10; index++) {
      MstPatViewerLayoutMonitorItem item = new MstPatViewerLayoutMonitorItem();
      item.setTableType(1);
      item.setMoniDataNo(String.valueOf(index));
      item.setVitalMonitorClass("1");
      item.setVitalMonitorItemName("テストバイタルモニタ項目_" + index);
      testDate.add(item);
    }
    return testDate;
  }
}
