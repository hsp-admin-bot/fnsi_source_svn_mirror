package jp.co.nikkiso.ntss.core.dao;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.tuple;

import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.entity.MstMachineRecord;

/**
 * {@link SysMasterDefineDao} のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
public class MstMachineRecordDaoTest {

  /**
   * テスト対象Dao.
   */
  @Autowired
  private MstMachineRecordDao target;

  /**
   * selectAll()の検証.
   * <p>
   * 条件：データあり
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/MstMachineRecordDaoTest.before.sql")
  public void test_selectAll_正常_データあり() {
    // arrange

    // action
    final List<MstMachineRecord> result = target.selectAll();

    // assert
    assertThat(result).hasSize(3);
    assertThat(result)
      .extracting(
        MstMachineRecord::getMachineRecordCd,
        MstMachineRecord::getMachineRecordMessage,
        MstMachineRecord::getIsDefault,
        MstMachineRecord::getLogClass,
        MstMachineRecord::getTargetModel
      )
      .containsExactlyInAnyOrder(
          tuple("0001", null, "0", "1", "1"),
          tuple("0002", null, "0", "3", "4"),
          tuple("FFFF", null, "1", "6", "6")
       )
     ;
  }


  /**
   * selectAll()の検証.
   * <p>
   * 条件：データなし
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/MstMachineRecordDaoTestNoRecord.before.sql")
  public void test_selectAll_正常_データなし() {
    // arrange

    // action
    final List<MstMachineRecord> result = target.selectAll();

    // assert
    assertThat(result).isEmpty();
  }
}
