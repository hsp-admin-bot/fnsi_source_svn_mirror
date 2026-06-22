package jp.co.nikkiso.ntss.admin_web.service;

import jp.co.nikkiso.ntss.admin_web.response.roundType.RoundTypeNameAndContentResponse;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:resource.service/RoundTypeServiceImplTest.before.sql")
public class RoundTypeServiceImplTest {

  /**
   * テスト対象クラス.
   */
  @Autowired
  private RoundTypeService target;

  /**
   * createRoundTypeNameAndContentResponseの検証.
   *
   * 条件：種別マスタと並び順管理マスタに該当のデータがある
   * 結果：施設コードに該当する種別マスタが取得できること
   */
  @Test
  public void test_createRoundTypeNameAndContentResponse_正常_種別マスタと並び順管理マスタに該当のデータがある() {
    // arrange
    final String facilityCd = "1001";

    // action
    List<RoundTypeNameAndContentResponse> list = target.createRoundTypeNameAndContentResponse(facilityCd);

    // assert
    assertThat(list).hasSize(3);

    RoundTypeNameAndContentResponse roundType1 = list.get(0);
    assertThat(roundType1.getRoundTypeCd()).isEqualTo(1L);
    assertThat(roundType1.getRoundTypeName()).isEqualTo("name1");
    assertThat(roundType1.getContent()).isEqualTo("content1");
    assertThat(roundType1.getIsContentOmission()).isEqualTo("0");
    assertThat(roundType1.getCommentPostDefault()).isEqualTo("0");
    assertThat(roundType1.getPostingClassDefault()).isEqualTo("1");

    RoundTypeNameAndContentResponse roundType2 = list.get(1);
    assertThat(roundType2.getRoundTypeCd()).isEqualTo(5L);
    assertThat(roundType2.getRoundTypeName()).isEqualTo("name5");
    assertThat(roundType2.getContent()).isEqualTo("content5");
    assertThat(roundType2.getIsContentOmission()).isEqualTo("1");
    assertThat(roundType2.getCommentPostDefault()).isEqualTo("0");
    assertThat(roundType2.getPostingClassDefault()).isEqualTo("1");

    RoundTypeNameAndContentResponse roundType3 = list.get(2);
    assertThat(roundType3.getRoundTypeCd()).isEqualTo(4L);
    assertThat(roundType3.getRoundTypeName()).isEqualTo("name4");
    assertThat(roundType3.getContent()).isEqualTo("content4");
    assertThat(roundType3.getIsContentOmission()).isEqualTo("0");
    assertThat(roundType3.getCommentPostDefault()).isEqualTo("1");
    assertThat(roundType3.getPostingClassDefault()).isEqualTo("0");
  }

  /**
   * createRoundTypeNameAndContentResponseの検証.
   *
   * 条件：種別マスタに該当のデータがあり並び順管理マスタに該当のデータがない
   * 結果：空のリストが取得できること
   */
  @Test
  public void test_createRoundTypeNameAndContentResponse_正常_種別マスタに該当のデータがあり並び順管理マスタに該当のデータがない() {
    // arrange
    final String facilityCd = "1003";

    // action
    List<RoundTypeNameAndContentResponse> list = target.createRoundTypeNameAndContentResponse(facilityCd);

    // assert
    assertThat(list).hasSize(0);
  }

  /**
   * createRoundTypeNameAndContentResponseの検証.
   *
   * 条件：種別マスタに該当のデータがない
   * 結果：空のリストが取得できること
   */
  @Test
  public void test_createRoundTypeNameAndContentResponse_正常_種別マスタに該当のデータがない() {
    // arrange
    final String facilityCd = "9999";

    // action
    List<RoundTypeNameAndContentResponse> list = target.createRoundTypeNameAndContentResponse(facilityCd);

    // assert
    assertThat(list).hasSize(0);
  }
}
