package jp.co.nikkiso.ntss.core.dao;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.hasSize;
import static org.junit.Assert.assertThat;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.entity.MstCompTreatment;

/**
 * 処置マスタのDaoテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql( "classpath:dao.script/MstCompTreatmentDaoTest.before.sql")
public class MstCompTreatmentDaoTest {

  /**
   * テスト対象Dao.
   */
  @Autowired
  MstCompTreatmentDao target;

  /**
   * selectAllByFacilityCdの検証.
   *
   * 条件：データが存在する施設コードを指定
   * 結果：結果が取得できること
   */
  @Test
  public void test_selectAllByFacilityCd_正常_該当データあり() {
    // arrange
    final String facilityCd = "1001";

    // action
    final List<MstCompTreatment> result = target.selectAllByFacilityCd(facilityCd);

    // assert
    assertThat(result).hasSize(5);

    MstCompTreatment compTreatment1 = result.get(0);
    assertThat(compTreatment1.getCompTreatmentCd()).isEqualTo(1);
    assertThat(compTreatment1.getFacilityCd()).isEqualTo(facilityCd);
    assertThat(compTreatment1.getTreatment()).isEqualTo("name1");
    assertThat(compTreatment1.getTreatClass()).isEqualTo("2");
    assertThat(compTreatment1.getTreatMedicineCd()).isNull();
    assertThat(compTreatment1.getAmount()).isNull();
    assertThat(compTreatment1.getProcedureCd()).isNull();
    assertThat(compTreatment1.getTakeMedicineCd()).isNull();
    assertThat(compTreatment1.getIsDisp()).isEqualTo("1");
    assertThat(compTreatment1.getIsDel()).isEqualTo("0");
    assertThat(compTreatment1.getRegDate()).isEqualTo(Timestamp.valueOf("2019-07-08 13:00:00"));
    assertThat(compTreatment1.getUpDate()).isEqualTo(Timestamp.valueOf("2019-07-08 14:00:00"));

    MstCompTreatment compTreatment2 = result.get(1);
    assertThat(compTreatment2.getCompTreatmentCd()).isEqualTo(2);
    assertThat(compTreatment2.getFacilityCd()).isEqualTo(facilityCd);
    assertThat(compTreatment2.getTreatment()).isEqualTo("name2");
    assertThat(compTreatment2.getTreatClass()).isEqualTo("2");
    assertThat(compTreatment2.getTreatMedicineCd()).isNull();
    assertThat(compTreatment2.getAmount()).isNull();
    assertThat(compTreatment2.getProcedureCd()).isNull();
    assertThat(compTreatment2.getTakeMedicineCd()).isNull();
    assertThat(compTreatment2.getIsDisp()).isEqualTo("0");
    assertThat(compTreatment2.getIsDel()).isEqualTo("0");
    assertThat(compTreatment2.getRegDate()).isEqualTo(Timestamp.valueOf("2019-07-08 13:00:00"));
    assertThat(compTreatment2.getUpDate()).isEqualTo(Timestamp.valueOf("2019-07-08 14:00:00"));

    MstCompTreatment compTreatment3 = result.get(2);
    assertThat(compTreatment3.getCompTreatmentCd()).isEqualTo(3);
    assertThat(compTreatment3.getFacilityCd()).isEqualTo(facilityCd);
    assertThat(compTreatment3.getTreatment()).isEqualTo("name3");
    assertThat(compTreatment3.getTreatClass()).isEqualTo("2");
    assertThat(compTreatment3.getTreatMedicineCd()).isNull();
    assertThat(compTreatment3.getAmount()).isNull();
    assertThat(compTreatment3.getProcedureCd()).isNull();
    assertThat(compTreatment3.getTakeMedicineCd()).isNull();
    assertThat(compTreatment3.getIsDisp()).isEqualTo("0");
    assertThat(compTreatment3.getIsDel()).isEqualTo("0");
    assertThat(compTreatment3.getRegDate()).isEqualTo(Timestamp.valueOf("2019-07-08 13:00:00"));
    assertThat(compTreatment3.getUpDate()).isEqualTo(Timestamp.valueOf("2019-07-08 14:00:00"));

    MstCompTreatment compTreatment4 = result.get(3);
    assertThat(compTreatment4.getCompTreatmentCd()).isEqualTo(4);
    assertThat(compTreatment4.getFacilityCd()).isEqualTo(facilityCd);
    assertThat(compTreatment4.getTreatment()).isEqualTo("name4");
    assertThat(compTreatment4.getTreatClass()).isEqualTo("1");
    assertThat(compTreatment4.getTreatMedicineCd()).isEqualTo(2);
    assertThat(compTreatment4.getAmount()).isEqualTo(new BigDecimal("3.12"));
    assertThat(compTreatment4.getProcedureCd()).isEqualTo(4);
    assertThat(compTreatment4.getTakeMedicineCd()).isEqualTo(5);
    assertThat(compTreatment4.getIsDisp()).isEqualTo("1");
    assertThat(compTreatment4.getIsDel()).isEqualTo("0");
    assertThat(compTreatment4.getRegDate()).isEqualTo(Timestamp.valueOf("2019-07-08 13:00:00"));
    assertThat(compTreatment4.getUpDate()).isEqualTo(Timestamp.valueOf("2019-07-08 14:00:00"));

    MstCompTreatment compTreatment5 = result.get(4);
    assertThat(compTreatment5.getCompTreatmentCd()).isEqualTo(5);
    assertThat(compTreatment5.getFacilityCd()).isEqualTo(facilityCd);
    assertThat(compTreatment5.getTreatment()).isEqualTo("name5");
    assertThat(compTreatment5.getTreatClass()).isEqualTo("0");
    assertThat(compTreatment5.getTreatMedicineCd()).isEqualTo(12);
    assertThat(compTreatment5.getAmount()).isEqualTo(new BigDecimal("13.12"));
    assertThat(compTreatment5.getProcedureCd()).isEqualTo(14);
    assertThat(compTreatment5.getTakeMedicineCd()).isEqualTo(15);
    assertThat(compTreatment5.getIsDisp()).isEqualTo("1");
    assertThat(compTreatment5.getIsDel()).isEqualTo("0");
    assertThat(compTreatment5.getRegDate()).isEqualTo(Timestamp.valueOf("2019-07-08 13:00:00"));
    assertThat(compTreatment5.getUpDate()).isEqualTo(Timestamp.valueOf("2019-07-08 14:00:00"));
  }

  /**
   * selectAllByFacilityCdの検証.
   *
   * 条件：データが存在しない施設コードを指定
   * 結果：空のリストを取得できること
   */
  @Test
  public void test_selectAllByFacilityCd_正常_該当データなし() {
    // arrange
    final String facilityCd = "9999";

    // action
    final List<MstCompTreatment> result = target.selectAllByFacilityCd(facilityCd);

    // assert
    assertThat(result).hasSize(0);
  }

  /**
   * insertCompTreatment()の検証
   * <p>
   * 条件：なし
   * 結果：追加されたレコード件数（１件）が返却されること
   * </p>
   */
  @Test
  public void test_insertCompTreatment_正常() {
    // 事前準備
    String facilityCd = "1001";
    MstCompTreatment entity = new MstCompTreatment() {{
      setCompTreatmentCd(8);
      setFacilityCd(facilityCd);
      setTreatment("name8");
      setTreatClass(1);
      setTreatMedicineCd(82);
      setAmount(new BigDecimal("23.12"));
      setProcedureCd(83);
      setTakeMedicineCd(84);
      setIsDel("0");
      setIsDisp("1");
    }};

    // 実行
    int result = target.insertCompTreatment(entity);

    // 検証
    assertThat(result, is(1));

    // 更新データの検証
    List<MstCompTreatment> resultEntities = target.selectAllByFacilityCd(facilityCd);
    // 検証のためコード順に並び替え
    List<MstCompTreatment> sortedResultEntities = resultEntities.stream()
        .sorted(Comparator.comparing(MstCompTreatment::getCompTreatmentCd))
        .collect(Collectors.toList());
    assertThat(sortedResultEntities, hasSize(6));
    assertThat(sortedResultEntities.get(5).getCompTreatmentCd(), equalTo(8));
    assertThat(sortedResultEntities.get(5).getTreatment(), equalTo("name8"));
    assertThat(sortedResultEntities.get(5).getFacilityCd(), equalTo(facilityCd));
    assertThat(sortedResultEntities.get(5).getTreatClass(), equalTo("1"));
    assertThat(sortedResultEntities.get(5).getTreatMedicineCd(), equalTo(82));
    assertThat(sortedResultEntities.get(5).getAmount(), equalTo(new BigDecimal("23.12")));
    assertThat(sortedResultEntities.get(5).getProcedureCd(), equalTo(83));
    assertThat(sortedResultEntities.get(5).getTakeMedicineCd(), equalTo(84));
    assertThat(sortedResultEntities.get(5).getIsDel(), equalTo("0"));
    assertThat(sortedResultEntities.get(5).getIsDisp(), equalTo("1"));
  }

  /**
   * updateComplaint()の検証
   * <p>
   * 条件：なし
   * 結果：追加されたレコード件数（１件）が返却されること
   * </p>
   */
  @Test
  public void test_updateComplaint_正常() {
    // 事前準備
    String facilityCd = "1001";
    MstCompTreatment entity = new MstCompTreatment() {{
      setCompTreatmentCd(1);
      setFacilityCd(facilityCd);
      setTreatment("rename1");
      setTreatClass(1);
      setTreatMedicineCd(101);
      setAmount(new BigDecimal("11.12"));
      setProcedureCd(102);
      setTakeMedicineCd(103);
      setIsDel("0");
      setIsDisp("1");
    }};

    // 実行
    int result = target.updateCompTreatment(entity);

    // 検証
    assertThat(result, is(1));

    // 更新データの検証
    List<MstCompTreatment> resultEntities = target.selectAllByFacilityCd(facilityCd);
    // 検証のためコード順に並び替え
    List<MstCompTreatment> sortedResultEntities = resultEntities.stream()
      .sorted(Comparator.comparing(MstCompTreatment::getCompTreatmentCd))
      .collect(Collectors.toList());
    assertThat(sortedResultEntities.get(0).getCompTreatmentCd(), equalTo(1));
    assertThat(sortedResultEntities.get(0).getTreatment(), equalTo("rename1"));
    assertThat(sortedResultEntities.get(0).getFacilityCd(), equalTo(facilityCd));
    assertThat(sortedResultEntities.get(0).getTreatClass(), equalTo("1"));
    assertThat(sortedResultEntities.get(0).getTreatMedicineCd(), equalTo(101));
    assertThat(sortedResultEntities.get(0).getAmount(), equalTo(new BigDecimal("11.12")));
    assertThat(sortedResultEntities.get(0).getProcedureCd(), equalTo(102));
    assertThat(sortedResultEntities.get(0).getTakeMedicineCd(), equalTo(103));
    assertThat(sortedResultEntities.get(0).getIsDel(), equalTo("0"));
    assertThat(sortedResultEntities.get(0).getIsDisp(), equalTo("1"));
  }

  /**
   * updateComplaint()の検証.
   * <p>
   * 条件：該当データなし
   * 結果：更新結果が0件となること
   * </p>
   */
  @Test
  public void test_updateComplaint_異常_該当データなし() {
 // 事前準備
    String facilityCd = "1001";
    MstCompTreatment entity = new MstCompTreatment() {{
      setCompTreatmentCd(99);
      setFacilityCd(facilityCd);
      setTreatment("rename99");
      setTreatClass(1);
      setTreatMedicineCd(101);
      setAmount(new BigDecimal("11.12"));
      setProcedureCd(102);
      setTakeMedicineCd(103);
      setIsDel("0");
      setIsDisp("1");
    }};

    // 実行
    int result = target.updateCompTreatment(entity);

    // 検証
    assertThat(result, is(0));
  }

}
