package jp.co.nikkiso.ntss.core.entity.utils;

import jp.co.nikkiso.ntss.core.entity.BaseEntity;
import lombok.Getter;
import lombok.Setter;
import org.junit.Test;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import static org.hamcrest.Matchers.is;
import static org.junit.Assert.assertThat;

/**
 * {@link BaseEntityUtils}のテストクラス.
 */
public class BaseEntityUtilsTest {

  /**
   * {@link BaseEntityUtils#getTableName(BaseEntity)} の検証.
   * <p>
   *   条件 : テーブル名が指定されているエンティティである事
   *   結果 : テーブル名が返却される事.
   * </p>
   */
  @Test
  public void test_getTableName_正常() {
    // 事前準備
    TestEntity1 testEntity1 = new TestEntity1();
    // 実行
    String result = BaseEntityUtils.getTableName(testEntity1);
    // 検証
    assertThat(result, is("test_entity"));
  }

  /**
   * {@link BaseEntityUtils#getTableName(BaseEntity)} の検証.
   * <p>
   *   条件 : テーブル名が指定されていないエンティティである事
   *   結果 : 空文字が返却される事.
   * </p>
   */
  @Test
  public void test_getTableName_異常_テーブルアノテーションが付与されていない() {
    // 事前準備
    TestEntity2 testEntity2 = new TestEntity2();
    // 実行
    String result = BaseEntityUtils.getTableName(testEntity2);
    // 検証
    assertThat(result, is(""));
  }

  /**
   * {@link BaseEntityUtils#getFacilityCd(BaseEntity)} の検証.
   * <p>
   *   条件 : "facilityCd"の変数がある事
   *   結果 : facilityCdに設定されている施設コードが返却される事.
   * </p>
   */
  @Test
  public void test_getFacilityCd_正常() {
    // 事前準備
    TestEntity1 testEntity1 = new TestEntity1();
    testEntity1.setFacilityCd("009999");
    // 実行
    String result = BaseEntityUtils.getFacilityCd(testEntity1);
    // 検証
    assertThat(result, is("009999"));
  }

  /**
   * {@link BaseEntityUtils#getFacilityCd(BaseEntity)} の検証.
   * <p>
   *   条件 : "facilityCd"の変数がない事
   *   結果 : targetFacilityCdに設定されている施設コードが返却される事.
   * </p>
   */
  @Test
  public void test_getFacilityCd_異常_facilityCd変数がない() {
    // 事前準備
    TestEntity2 testEntity2 = new TestEntity2();
    testEntity2.setTargetFacilityCd("009999");
    // 実行
    String result = BaseEntityUtils.getFacilityCd(testEntity2);
    // 検証
    assertThat(result, is("009999"));
  }
}

/**
 * テスト用のエンティティクラス
 */
@Entity(naming= NamingType.SNAKE_LOWER_CASE)
@Table(name = "test_entity")
@Getter
@Setter
class TestEntity1 extends BaseEntity {

  /**
   * 管理番号
   */
  @Id
  private Long id;

  /**
   * 施設コード
   */
  private String facilityCd;
}

/**
 * テスト用のエンティティクラス
 * ※@Tableが付与されていない.
 */
@Entity(naming= NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
class TestEntity2 extends BaseEntity {

}
