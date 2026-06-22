package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.MstRoundType;
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
 * 種別マスタのDaoテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql( "classpath:dao.script/MstRoundTypeDaoTest.before.sql")
public class MstRoundTypeDaoTest {

  /**
   * テスト対象Dao.
   */
  @Autowired
  MstRoundTypeDao target;

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
    final List<MstRoundType> result = target.selectByFacilityCd(facilityCd);

    // assert
    assertThat(result).hasSize(3);

    MstRoundType roundType1 = result.get(0);
    assertThat(roundType1.getRoundTypeCd()).isEqualTo(1L);
    assertThat(roundType1.getFacilityCd()).isEqualTo(facilityCd);
    assertThat(roundType1.getRoundTypeName()).isEqualTo("name1");
    assertThat(roundType1.getContent()).isEqualTo("content1");
    assertThat(roundType1.getIsContentOmission()).isEqualTo("0");
    assertThat(roundType1.getCommentPostDefault()).isEqualTo("0");
    assertThat(roundType1.getPostingClassDefault()).isEqualTo("1");
    assertThat(roundType1.getIsDisp()).isEqualTo("0");
    assertThat(roundType1.getIsDel()).isEqualTo("0");

    MstRoundType roundType2 = result.get(1);
    assertThat(roundType2.getRoundTypeCd()).isEqualTo(2L);
    assertThat(roundType2.getFacilityCd()).isEqualTo(facilityCd);
    assertThat(roundType2.getRoundTypeName()).isEqualTo("name2");
    assertThat(roundType2.getContent()).isEqualTo("content2");
    assertThat(roundType2.getIsContentOmission()).isEqualTo("0");
    assertThat(roundType2.getCommentPostDefault()).isEqualTo("0");
    assertThat(roundType2.getPostingClassDefault()).isEqualTo("1");
    assertThat(roundType2.getIsDisp()).isEqualTo("1");
    assertThat(roundType2.getIsDel()).isEqualTo("0");

    MstRoundType roundType3 = result.get(2);
    assertThat(roundType3.getRoundTypeCd()).isEqualTo(3L);
    assertThat(roundType3.getFacilityCd()).isEqualTo(facilityCd);
    assertThat(roundType3.getRoundTypeName()).isEqualTo("name3");
    assertThat(roundType3.getContent()).isEqualTo("content3");
    assertThat(roundType3.getIsContentOmission()).isEqualTo("0");
    assertThat(roundType3.getCommentPostDefault()).isEqualTo("1");
    assertThat(roundType3.getPostingClassDefault()).isEqualTo("0");
    assertThat(roundType3.getIsDisp()).isEqualTo("0");
    assertThat(roundType3.getIsDel()).isEqualTo("1");
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
    final List<MstRoundType> result = target.selectByFacilityCd(facilityCd);

    // assert
    assertThat(result).hasSize(0);
  }

}
