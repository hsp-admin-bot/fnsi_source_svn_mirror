package jp.co.nikkiso.ntss.core.dao;

import static org.hamcrest.CoreMatchers.is;
import static org.junit.Assert.assertThat;

import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.entity.MstMNotice;

/**
 * {@link MstMNoticeDao} のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:dao.script/MstMNoticeDaoTest.before.sql")
public class MstMNoticeDaoTest {

  /**
   * テスト対象Dao.
   */
  @Autowired
  private MstMNoticeDao target;

  /**
   * deleteByFacilityCd()の検証.
   *
   * <p>
   * 条件：該当する施設コードのレコードを指定 結果：該当の施設コードレコードが削除されること
   * </p>
   */
  @Test
  public void test_deleteByFacilityCd_正常_削除対象あり() {
    int beforeSize = target.selectAll().size();

    // 実行
    int deleteSize = target.deleteByFacilityCd("000001");
    List<MstMNotice> mmn = target.selectAll();

    // 検証
    assertThat(beforeSize, is(8));
    assertThat(deleteSize, is(6));
    assertThat(mmn.size(), is(2));
    assertThat(mmn.get(0).getFacilityCd(), is("000002"));
    assertThat(mmn.get(0).getMachineRecordCd(), is("F00A"));
    assertThat(mmn.get(1).getFacilityCd(), is("999900"));
    assertThat(mmn.get(1).getMachineRecordCd(), is("958A"));
  }

  /**
   * deleteByFacilityCd()の検証.
   *
   * <p>
   * 条件：該当しない施設コードのレコードを指定 結果：レコードが削除されないこと
   * </p>
   */
  @Test
  public void test_deleteByFacilityCd_正常_削除対象なし() {
    int beforeSize = target.selectAll().size();

    // 実行
    int deleteSize = target.deleteByFacilityCd("000009");
    List<MstMNotice> mmn = target.selectAll();

    // 検証
    assertThat(beforeSize, is(8));
    assertThat(deleteSize, is(0));
    assertThat(mmn.size(), is(8));
  }
}
