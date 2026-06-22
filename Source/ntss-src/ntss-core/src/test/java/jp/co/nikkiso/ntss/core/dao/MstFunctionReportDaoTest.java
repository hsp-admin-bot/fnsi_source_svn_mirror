package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.MstFunctionReport;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * {@link MstFunctionReportDao} のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:dao.script/MstFunctionReportDaoTest.before.sql")
public class MstFunctionReportDaoTest {

  /**
   * テスト対象Dao.
   */
  @Autowired
  private MstFunctionReportDao target;

  /**
   * selectByFunctionCdAndFacilityCd()の検証.
   *
   * 条件：機能コード、施設コードに該当する機能帳票マスタが登録されている(かつ、表示する、有効なデータ)
   * 結果：条件に該当する機能帳票マスタが取得できること
   */
  @Test
  public void test_selectByFunctionCdAndFacilityCd_正常_条件に該当するデータあり_表示する_有効なデータ() {
    // 事前準備
    final String funcCd = "001";
    final String facilityCd = "000001";

    // 実行
    List<MstFunctionReport> results = target.selectByFunctionCdAndFacilityCd(funcCd, facilityCd,null);

    // 検証
    assertThat(results).isNotNull();
    assertThat(results).hasSize(2);
    assertThat(results.get(0).getFunctionReportCd()).isEqualTo(1);
    assertThat(results.get(0).getFunctionCd()).isEqualTo("001");
    assertThat(results.get(0).getFacilityCd()).isEqualTo("000001");
    assertThat(results.get(0).getReportCd()).isEqualTo(101L);
    assertThat(results.get(0).getIsDisp()).isEqualTo("1");
    assertThat(results.get(0).getIsDel()).isEqualTo("0");
    assertThat(results.get(0).getRegDate()).isEqualTo(Timestamp.valueOf("2019-08-14 12:00:00"));
    assertThat(results.get(0).getUpDate()).isEqualTo(Timestamp.valueOf("2019-08-14 13:00:00"));
    assertThat(results.get(1).getFunctionReportCd()).isEqualTo(2);
    assertThat(results.get(1).getFunctionCd()).isEqualTo("001");
    assertThat(results.get(1).getFacilityCd()).isEqualTo("000001");
    assertThat(results.get(1).getReportCd()).isEqualTo(102L);
    assertThat(results.get(1).getIsDisp()).isEqualTo("1");
    assertThat(results.get(1).getIsDel()).isEqualTo("0");
    assertThat(results.get(1).getRegDate()).isEqualTo(Timestamp.valueOf("2019-08-14 12:00:00"));
    assertThat(results.get(1).getUpDate()).isEqualTo(Timestamp.valueOf("2019-08-14 13:00:00"));
  }

  /**
   * selectByFunctionCdAndFacilityCd()の検証.
   *
   * 条件：機能コード、施設コードに該当する機能帳票マスタが登録されている(かつ、表示しない、有効なデータ)
   * 結果：空のリストが取得できること
   *
   */
  @Test
  public void test_selectByFunctionCdAndFacilityCd_異常_条件に該当するデータあり_表示しない_有効なデータ() {
    // 事前準備
    final String funcCd = "002";
    final String facilityCd = "000002";

    // 実行
    List<MstFunctionReport> results = target.selectByFunctionCdAndFacilityCd(funcCd, facilityCd,null);

    // 検証
    assertThat(results).isNotNull();
    assertThat(results).hasSize(0);
  }

  /**
   * selectByFunctionCdAndFacilityCd()の検証.
   *
   * 条件：機能コード、施設コードに該当する機能帳票マスタが登録されている(かつ、表示する、削除データ)
   * 結果：空のリストが取得できること
   *
   */
  @Test
  public void test_selectByFunctionCdAndFacilityCd_異常_条件に該当するデータあり_表示する_削除データ() {
    // 事前準備
    final String funcCd = "003";
    final String facilityCd = "000003";

    // 実行
    List<MstFunctionReport> results = target.selectByFunctionCdAndFacilityCd(funcCd, facilityCd,null);

    // 検証
    assertThat(results).isNotNull();
    assertThat(results).hasSize(0);
  }

}
