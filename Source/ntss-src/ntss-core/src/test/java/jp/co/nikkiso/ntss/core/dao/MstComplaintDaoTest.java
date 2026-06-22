package jp.co.nikkiso.ntss.core.dao;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.junit.Assert.assertThat;

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

import jp.co.nikkiso.ntss.core.entity.MstComplaint;

/**
 * 愁訴マスタのDaoテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql( "classpath:dao.script/MstComplaintDaoTest.before.sql")
public class MstComplaintDaoTest {

  /**
   * テスト対象Dao.
   */
  @Autowired
  MstComplaintDao target;

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
    final List<MstComplaint> result = target.selectAllByFacilityCd(facilityCd);

    // assert
    assertThat(result).hasSize(5);

    MstComplaint complaint1 = result.get(0);
    assertThat(complaint1.getComplaintCd()).isEqualTo(1);
    assertThat(complaint1.getFacilityCd()).isEqualTo(facilityCd);
    assertThat(complaint1.getComplaintName()).isEqualTo("name1");
    assertThat(complaint1.getIsDisp()).isEqualTo("1");
    assertThat(complaint1.getIsDel()).isEqualTo("0");
    assertThat(complaint1.getRegDate()).isEqualTo(Timestamp.valueOf("2019-07-08 13:00:00"));
    assertThat(complaint1.getUpDate()).isEqualTo(Timestamp.valueOf("2019-07-08 14:00:00"));

    MstComplaint complaint2 = result.get(1);
    assertThat(complaint2.getComplaintCd()).isEqualTo(2);
    assertThat(complaint2.getFacilityCd()).isEqualTo(facilityCd);
    assertThat(complaint2.getComplaintName()).isEqualTo("name2");
    assertThat(complaint2.getIsDisp()).isEqualTo("0");
    assertThat(complaint2.getIsDel()).isEqualTo("0");
    assertThat(complaint2.getRegDate()).isEqualTo(Timestamp.valueOf("2019-07-08 13:00:00"));
    assertThat(complaint2.getUpDate()).isEqualTo(Timestamp.valueOf("2019-07-08 14:00:00"));

    MstComplaint complaint3 = result.get(2);
    assertThat(complaint3.getComplaintCd()).isEqualTo(3);
    assertThat(complaint3.getFacilityCd()).isEqualTo(facilityCd);
    assertThat(complaint3.getComplaintName()).isEqualTo("name3");
    assertThat(complaint3.getIsDisp()).isEqualTo("0");
    assertThat(complaint3.getIsDel()).isEqualTo("0");
    assertThat(complaint3.getRegDate()).isEqualTo(Timestamp.valueOf("2019-07-08 13:00:00"));
    assertThat(complaint3.getUpDate()).isEqualTo(Timestamp.valueOf("2019-07-08 14:00:00"));

    MstComplaint complaint4 = result.get(3);
    assertThat(complaint4.getComplaintCd()).isEqualTo(4);
    assertThat(complaint4.getFacilityCd()).isEqualTo(facilityCd);
    assertThat(complaint4.getComplaintName()).isEqualTo("name4");
    assertThat(complaint4.getIsDisp()).isEqualTo("1");
    assertThat(complaint4.getIsDel()).isEqualTo("0");
    assertThat(complaint4.getRegDate()).isEqualTo(Timestamp.valueOf("2019-07-08 13:00:00"));
    assertThat(complaint4.getUpDate()).isEqualTo(Timestamp.valueOf("2019-07-08 14:00:00"));

    MstComplaint complaint5 = result.get(4);
    assertThat(complaint5.getComplaintCd()).isEqualTo(5);
    assertThat(complaint5.getFacilityCd()).isEqualTo(facilityCd);
    assertThat(complaint5.getComplaintName()).isEqualTo("name5");
    assertThat(complaint5.getIsDisp()).isEqualTo("1");
    assertThat(complaint5.getIsDel()).isEqualTo("0");
    assertThat(complaint5.getRegDate()).isEqualTo(Timestamp.valueOf("2019-07-08 13:00:00"));
    assertThat(complaint5.getUpDate()).isEqualTo(Timestamp.valueOf("2019-07-08 14:00:00"));
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
    final List<MstComplaint> result = target.selectAllByFacilityCd(facilityCd);

    // assert
    assertThat(result).hasSize(0);
  }

  /**
   * insertComplaint()の検証
   * <p>
   * 条件：なし
   * 結果：追加されたレコード件数（１件）が返却されること
   * </p>
   */
  @Test
  public void test_insertComplaint_正常() {
    // 事前準備
    String facilityCd = "1001";
    MstComplaint entity = new MstComplaint() {{
      setComplaintCd(8);
      setComplaintName("name8");
      setFacilityCd(facilityCd);
      setIsDel("0");
      setIsDisp("1");
    }};

    // 実行
    int result = target.insertComplaint(entity);

    // 検証
    assertThat(result, is(1));

    // 更新データの検証
    List<MstComplaint> resultEntities = target.selectAllByFacilityCd(facilityCd);
    // 検証のためコード順に並び替え
    List<MstComplaint> sortedResultEntities = resultEntities.stream()
        .sorted(Comparator.comparing(MstComplaint::getComplaintCd))
        .collect(Collectors.toList());
    assertThat(sortedResultEntities, hasSize(6));
    assertThat(sortedResultEntities.get(5).getComplaintCd(), equalTo(8));
    assertThat(sortedResultEntities.get(5).getComplaintName(), equalTo("name8"));
    assertThat(sortedResultEntities.get(5).getFacilityCd(), equalTo(facilityCd));
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
    MstComplaint entity = new MstComplaint() {{
      setComplaintCd(1);
      setComplaintName("rename1");
      setFacilityCd(facilityCd);
      setIsDel("0");
      setIsDisp("1");
      setRegDate(Timestamp.valueOf("2019-07-08 13:00:00"));
    }};

    // 実行
    int result = target.updateComplaint(entity);

    // 検証
    assertThat(result, is(1));

    // 更新データの検証
    List<MstComplaint> resultEntities = target.selectAllByFacilityCd(facilityCd);
    // 検証のためコード順に並び替え
    List<MstComplaint> sortedResultEntities = resultEntities.stream()
        .sorted(Comparator.comparing(MstComplaint::getComplaintCd))
        .collect(Collectors.toList());
    assertThat(sortedResultEntities, hasSize(5));
    assertThat(sortedResultEntities.get(0).getComplaintCd(), equalTo(1));
    assertThat(sortedResultEntities.get(0).getComplaintName(), equalTo("rename1"));
    assertThat(sortedResultEntities.get(0).getFacilityCd(), equalTo(facilityCd));
    assertThat(sortedResultEntities.get(0).getIsDel(), equalTo("0"));
    assertThat(sortedResultEntities.get(0).getIsDisp(), equalTo("1"));
    assertThat(sortedResultEntities.get(0).getRegDate(), equalTo(Timestamp.valueOf("2019-07-08 13:00:00")));
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
    MstComplaint entity = new MstComplaint() {{
      setComplaintCd(99);
      setComplaintName("rename99");
      setFacilityCd(facilityCd);
      setIsDel("0");
      setIsDisp("1");
      setRegDate(Timestamp.valueOf("2019-07-08 13:00:00"));
    }};

    // 実行
    int result = target.updateComplaint(entity);

    // 検証
    assertThat(result, is(0));
  }

}
