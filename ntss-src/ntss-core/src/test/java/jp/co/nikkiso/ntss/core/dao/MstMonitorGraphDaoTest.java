package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.MstMonitorGraph;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * モニタグラフマスタのDaoテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql( "classpath:dao.script/MstMonitorGraphDaoTest.before.sql")
public class MstMonitorGraphDaoTest {

  /**
   * テスト対象Dao.
   */
  @Autowired
  MstMonitorGraphDao target;

  /**
   * selectByFacilityCdの検証.
   *
   * 条件：データが存在する施設コードを指定
   * 結果：結果が取得できること
   */
  @Test
  public void test_selectByFacility_正常_該当データあり() {
    // arrange
    final String facilityCd = "1001";

    // action
    final List<MstMonitorGraph> result = target.selectByFacilityCd(facilityCd);

    // assert
    assertThat(result).hasSize(3);

    {
      MstMonitorGraph mstMonitorGraph = result.get(0);
      assertThat(mstMonitorGraph.getMonitorGraphCd()).isEqualTo(1);
      assertThat(mstMonitorGraph.getMonitorGraphName()).isEqualTo("name1");
      assertThat(mstMonitorGraph.getFacilityCd()).isEqualTo(facilityCd);
      assertThat(mstMonitorGraph.getLeftDataIndex()).isEqualTo("11");
      assertThat(mstMonitorGraph.getLeftColor()).isEqualTo("#ff0001");
      assertThat(mstMonitorGraph.getRightDataIndex()).isEqualTo("21");
      assertThat(mstMonitorGraph.getRightColor()).isEqualTo("#ff0011");
      assertThat(mstMonitorGraph.getIsDisp()).isEqualTo("1");
      assertThat(mstMonitorGraph.getIsDel()).isEqualTo("0");
    }
    {
      MstMonitorGraph mstMonitorGraph = result.get(1);
      assertThat(mstMonitorGraph.getMonitorGraphCd()).isEqualTo(2);
      assertThat(mstMonitorGraph.getMonitorGraphName()).isEqualTo("name2");
      assertThat(mstMonitorGraph.getFacilityCd()).isEqualTo(facilityCd);
      assertThat(mstMonitorGraph.getLeftDataIndex()).isEqualTo("12");
      assertThat(mstMonitorGraph.getLeftColor()).isEqualTo("#ff0002");
      assertThat(mstMonitorGraph.getRightDataIndex()).isEqualTo("22");
      assertThat(mstMonitorGraph.getRightColor()).isEqualTo("#ff0012");
      assertThat(mstMonitorGraph.getIsDisp()).isEqualTo("1");
      assertThat(mstMonitorGraph.getIsDel()).isEqualTo("0");
    }
    {
      MstMonitorGraph mstMonitorGraph = result.get(2);
      assertThat(mstMonitorGraph.getMonitorGraphCd()).isEqualTo(3);
      assertThat(mstMonitorGraph.getMonitorGraphName()).isEqualTo("name3");
      assertThat(mstMonitorGraph.getFacilityCd()).isEqualTo(facilityCd);
      assertThat(mstMonitorGraph.getLeftDataIndex()).isEqualTo("13");
      assertThat(mstMonitorGraph.getLeftColor()).isEqualTo("#ff0003");
      assertThat(mstMonitorGraph.getRightDataIndex()).isEqualTo("23");
      assertThat(mstMonitorGraph.getRightColor()).isEqualTo("#ff0013");
      assertThat(mstMonitorGraph.getIsDisp()).isEqualTo("0");
      assertThat(mstMonitorGraph.getIsDel()).isEqualTo("0");
    }
  }

  /**
   * selectByFacilityCdの検証.
   *
   * 条件：データが存在しない施設コードを指定
   * 結果：空のリストを取得できること
   */
  @Test
  public void test_selectByFacility_正常_該当データなし() {
    // arrange
    final String facilityCd = "9999";

    // action
    final List<MstMonitorGraph> result = target.selectByFacilityCd(facilityCd);

    // assert
    assertThat(result).hasSize(0);
  }

}
