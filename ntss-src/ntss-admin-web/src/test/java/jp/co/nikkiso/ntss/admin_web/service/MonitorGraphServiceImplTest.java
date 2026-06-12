package jp.co.nikkiso.ntss.admin_web.service;

import tools.jackson.core.JacksonException;
import jp.co.nikkiso.ntss.admin_web.response.monitor.MonitorGraphDefineResponse;
import jp.co.nikkiso.ntss.core.dao.MstMonitorGraphDao;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.entity.MstMonitorGraph;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.MstSelector.Item;
import jp.co.nikkiso.ntss.core.entity.MstSelector.OrderSettings;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.List;

import static java.util.Collections.emptyList;
import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;

@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
public class MonitorGraphServiceImplTest {

  /**
   * モニタグラフマスタサービス.
   */
  @Autowired
  private MonitorGraphService monitorGraphService;

  /**
   * モニタグラフマスタDaoのMockBean.
   */
  @MockitoBean
  private MstMonitorGraphDao mstMonitorGraphDao;

  /**
   * MstSelectorのMockBean.
   */
  @MockitoBean
  private MstSelectorDao mstSelectorDao;

  /**
   * モニタグラフマスタEntityの初期化.
   * @return モニタグラフマスタのEntity
   */
  private List<MstMonitorGraph> createMonitorGraphEntity() {
    return Arrays.asList(
      new MstMonitorGraph() {{
        setMonitorGraphCd(1);
        setMonitorGraphName("name1");
        setFacilityCd("1001");
        setLeftDataIndex("11");
        setLeftColor("#ff0001");
        setLeftDataIndex("21");
        setLeftColor("#ff0011");
        setIsDel("0");
        setIsDisp("1");
      }},
      new MstMonitorGraph() {{
        setMonitorGraphCd(2);
        setMonitorGraphName("name2");
        setFacilityCd("1001");
        setLeftDataIndex("12");
        setLeftColor("#ff0002");
        setLeftDataIndex("22");
        setLeftColor("#ff0012");
        setIsDel("0");
        setIsDisp("0");
      }},
      new MstMonitorGraph() {{
        setMonitorGraphCd(3);
        setMonitorGraphName("name3");
        setFacilityCd("1001");
        setLeftDataIndex("13");
        setLeftColor("#ff0003");
        setLeftDataIndex("23");
        setLeftColor("#ff0013");
        setIsDel("0");
        setIsDisp("0");
      }},
      new MstMonitorGraph() {{
        setMonitorGraphCd(4);
        setMonitorGraphName("name4");
        setFacilityCd("1001");
        setLeftDataIndex("14");
        setLeftColor("#ff0004");
        setLeftDataIndex("24");
        setLeftColor("#ff0014");
        setIsDel("0");
        setIsDisp("1");
      }},
      new MstMonitorGraph() {{
        setMonitorGraphCd(5);
        setMonitorGraphName("name5");
        setFacilityCd("1001");
        setLeftDataIndex("15");
        setLeftColor("#ff0005");
        setLeftDataIndex("25");
        setLeftColor("#ff0015");
        setIsDel("0");
        setIsDisp("1");
      }}
    );
  }

  /**
   * MstSelectorの初期化（データあり）.
   * @param tableName テーブル物理名
   * @return
   * @throws JacksonException
   */
  private MstSelector createMstSelectorContainsSelector(String tableName) throws JacksonException {
   List<Item> items = Arrays.asList(
       new Item() {{
         setCode(1L);
         setName("name1");
       }},
       new Item() {{
         setCode(5L);
         setName("name5");
       }},
       new Item() {{
         setCode(4L);
         setName("name4");
       }}
   );

   OrderSettings orderSettings = new OrderSettings();
   orderSettings.setItems(items);

    MstSelector mstSelector = new MstSelector();
    mstSelector.setFacilityCd("1001");
    mstSelector.setMasterPhysicalName(tableName);
    mstSelector.setOrderSettings(orderSettings);

    return mstSelector;
  }

  /**
   * MstSelectorの初期化（データなし）.
   * @param tableName テーブル物理名
   * @return
   * @throws JacksonException
   */
  private MstSelector createMstSelectorNotContainsSelector(String tableName) throws JacksonException {
    List<Item> items = emptyList();

    OrderSettings orderSettings = new OrderSettings();
    orderSettings.setItems(items);

     MstSelector mstSelector = new MstSelector();
     mstSelector.setFacilityCd("1001");
     mstSelector.setMasterPhysicalName(tableName);
     mstSelector.setOrderSettings(orderSettings);

     return mstSelector;
   }

  /**
   * createMonitorGraphDefineResponse()の検証.
   *
   * 条件：モニタグラフマスタと並び順管理マスタに該当のデータがある
   * 結果：施設コードに該当するモニタグラフマスタが取得できること（mst_selector登録順+未登録データ）
   * @throws JacksonException
   */
  @Test
  public void test_createMonitorGraphDefineResponse_正常_モニタグラフマスタと並び順管理マスタに該当のデータがある() throws JacksonException {
    // arrange
    List<MstMonitorGraph> mstMonitorGraphs = createMonitorGraphEntity();

    final String facilityCd = "1001";
    given(mstMonitorGraphDao.selectByFacilityCd(facilityCd))
      .willReturn(mstMonitorGraphs);

    given(mstSelectorDao.selectByName(facilityCd, "mst_monitor_graph"))
      .willReturn(createMstSelectorContainsSelector("mst_monitor_graph"));

    // action
    final List<MonitorGraphDefineResponse> result = monitorGraphService.createMonitorGraphDefineResponse(facilityCd);

    // assert
    assertThat(result).isNotNull();
    assertThat(result).hasSize(3);
    assertThat(result.get(0).getMonitorGraphCd()).isEqualTo(mstMonitorGraphs.get(0).getMonitorGraphCd());
    assertThat(result.get(0).getMonitorGraphName()).isEqualTo(mstMonitorGraphs.get(0).getMonitorGraphName());
    assertThat(result.get(0).getLeftDataIndex()).isEqualTo(mstMonitorGraphs.get(0).getLeftDataIndex());
    assertThat(result.get(0).getLeftColor()).isEqualTo(mstMonitorGraphs.get(0).getLeftColor());
    assertThat(result.get(0).getRightDataIndex()).isEqualTo(mstMonitorGraphs.get(0).getRightDataIndex());
    assertThat(result.get(0).getRightColor()).isEqualTo(mstMonitorGraphs.get(0).getRightColor());

    assertThat(result.get(1).getMonitorGraphCd()).isEqualTo(mstMonitorGraphs.get(4).getMonitorGraphCd());
    assertThat(result.get(1).getMonitorGraphName()).isEqualTo(mstMonitorGraphs.get(4).getMonitorGraphName());
    assertThat(result.get(1).getLeftDataIndex()).isEqualTo(mstMonitorGraphs.get(4).getLeftDataIndex());
    assertThat(result.get(1).getLeftColor()).isEqualTo(mstMonitorGraphs.get(4).getLeftColor());
    assertThat(result.get(1).getRightDataIndex()).isEqualTo(mstMonitorGraphs.get(4).getRightDataIndex());
    assertThat(result.get(1).getRightColor()).isEqualTo(mstMonitorGraphs.get(4).getRightColor());

    assertThat(result.get(2).getMonitorGraphCd()).isEqualTo(mstMonitorGraphs.get(3).getMonitorGraphCd());
    assertThat(result.get(2).getMonitorGraphName()).isEqualTo(mstMonitorGraphs.get(3).getMonitorGraphName());
    assertThat(result.get(2).getLeftDataIndex()).isEqualTo(mstMonitorGraphs.get(3).getLeftDataIndex());
    assertThat(result.get(2).getLeftColor()).isEqualTo(mstMonitorGraphs.get(3).getLeftColor());
    assertThat(result.get(2).getRightDataIndex()).isEqualTo(mstMonitorGraphs.get(3).getRightDataIndex());
    assertThat(result.get(2).getRightColor()).isEqualTo(mstMonitorGraphs.get(3).getRightColor());

    verify(mstMonitorGraphDao, times(1)).selectByFacilityCd(facilityCd);
    verify(mstSelectorDao, times(1)).selectByName(facilityCd, "mst_monitor_graph");
  }

  /**
   * createMonitorGraphDefineResponse()の検証.
   *
   * 条件：モニタグラフマスタに該当のデータがあり並び順管理マスタに該当のデータがない
   * 結果：施設コードに該当するモニタグラフマスタが取得できること（mst_selector未登録データ）
   * @throws JacksonException
   */
  @Test
  public void test_createMonitorGraphDefineResponse_正常_モニタグラフマスタに該当のデータがあり並び順管理マスタに該当のデータがない() throws JacksonException {
    // arrange
    List<MstMonitorGraph> mstMonitorGraphs = createMonitorGraphEntity();

    final String facilityCd = "1001";
    given(mstMonitorGraphDao.selectByFacilityCd(facilityCd))
      .willReturn(mstMonitorGraphs);

    given(mstSelectorDao.selectByName(facilityCd, "mst_monitor_graph"))
      .willReturn(createMstSelectorNotContainsSelector("mst_monitor_graph"));

    // action
    final List<MonitorGraphDefineResponse> result = monitorGraphService.createMonitorGraphDefineResponse(facilityCd);

    // assert
    assertThat(result).isNotNull();
    assertThat(result).hasSize(0);

    verify(mstMonitorGraphDao, times(1)).selectByFacilityCd(facilityCd);
    verify(mstSelectorDao, times(1)).selectByName(facilityCd, "mst_monitor_graph");
  }

  /**
   * createMonitorGraphDefineResponse()の検証.
   *
   * 条件：モニタグラフマスタに該当のデータがなく並び順管理マスタにデータがある
   * 結果：空のリストが取得できること
   * @throws JacksonException
   */
  @Test
  public void test_createMonitorGraphDefineResponse_正常_モニタグラフマスタに該当のデータがなく並び順管理マスタにデータがある() throws JacksonException {
    // arrange
    final String facilityCd = "1001";
    given(mstMonitorGraphDao.selectByFacilityCd(facilityCd))
      .willReturn(emptyList());

    given(mstSelectorDao.selectByName(facilityCd, "mst_monitor_graph"))
      .willReturn(createMstSelectorContainsSelector("mst_monitor_graph"));

    // action
    final List<MonitorGraphDefineResponse> result = monitorGraphService.createMonitorGraphDefineResponse(facilityCd);

    // assert
    assertThat(result).isNotNull();
    assertThat(result).hasSize(0);

    verify(mstMonitorGraphDao, times(1)).selectByFacilityCd(facilityCd);
    verify(mstSelectorDao, times(0)).selectByName(facilityCd, "mst_monitor_graph");
  }

  /**
   * createMonitorGraphDefineResponse()の検証.
   *
   * 条件：モニタグラフマスタに該当のデータがない
   * 結果：空のリストが取得できること
   * @throws JacksonException
   */
  @Test
  public void test_createMonitorGraphDefineResponse_正常_モニタグラフマスタに該当のデータがない() throws JacksonException {
    // arrange
    final String facilityCd = "9999";
    given(mstMonitorGraphDao.selectByFacilityCd(facilityCd))
      .willReturn(emptyList());

    given(mstSelectorDao.selectByName(facilityCd, "mst_monitor_graph"))
      .willReturn(createMstSelectorNotContainsSelector("mst_monitor_graph"));

    // action
    final List<MonitorGraphDefineResponse> result = monitorGraphService.createMonitorGraphDefineResponse(facilityCd);

    // assert
    assertThat(result).isNotNull();
    assertThat(result).hasSize(0);

    verify(mstMonitorGraphDao, times(1)).selectByFacilityCd(facilityCd);
    verify(mstSelectorDao, times(0)).selectByName(facilityCd, "mst_monitor_graph");
  }
}
