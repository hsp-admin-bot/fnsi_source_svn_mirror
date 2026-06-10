package jp.co.nikkiso.ntss.core.dao;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.entity.MstDestinationGroup;

@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:dao.script/MstDestinationGroupDaoTest.before.sql")
public class MstDestinationGroupDaoTest {

  /**
   * テスト対象DAO
   */
  @Autowired
  private MstDestinationGroupDao target;

  /**
   * selectByFacilityCdの検証.
   *
   * 条件：データが存在する施設コードを指定 結果：結果が取得できること
   */
  @Test
  public void 施設コードに一致する送信先グループを取得できること() {
    // arrange
    final String facilityCd = "0001";

    // action
    final List<MstDestinationGroup> result = target.selectByFacilityCd(facilityCd);

    // assert
    assertThat(result).hasSize(4);

    MstDestinationGroup group1 = result.get(0);
    assertThat(group1.getDestinationGroupCd()).isEqualTo(1L);
    assertThat(group1.getDestinationGroupName()).isEqualTo("group1");
    assertThat(group1.getFacilityCd()).isEqualTo(facilityCd);
    final MstDestinationGroup.DestinationTarget target1 = group1.getDestinationTarget();
    assertThat(target1).isNotNull();
    assertThat(target1.getUsers()).extracting(MstDestinationGroup.User::getUserId,
        MstDestinationGroup.User::isAddress1Send, MstDestinationGroup.User::isAddress2Send)
        .containsOnly(tuple(1000L, true, true), tuple(1500L, true, false));

    MstDestinationGroup group2 = result.get(1);
    assertThat(group2.getDestinationGroupCd()).isEqualTo(2L);
    assertThat(group2.getDestinationGroupName()).isEqualTo("group2");
    assertThat(group2.getFacilityCd()).isEqualTo(facilityCd);
    final MstDestinationGroup.DestinationTarget target2 = group2.getDestinationTarget();
    assertThat(target2).isNotNull();
    assertThat(target2.getUsers())
        .extracting(MstDestinationGroup.User::getUserId, MstDestinationGroup.User::isAddress1Send,
            MstDestinationGroup.User::isAddress2Send)
        .containsOnly(tuple(1000L, true, false), tuple(2000L, true, false));

    MstDestinationGroup group3 = result.get(2);
    assertThat(group3.getDestinationGroupCd()).isEqualTo(3L);
    assertThat(group3.getDestinationGroupName()).isEqualTo("group3");
    assertThat(group3.getFacilityCd()).isEqualTo(facilityCd);
    final MstDestinationGroup.DestinationTarget target3 = group3.getDestinationTarget();
    assertThat(target3).isNotNull();
    assertThat(target3.getUsers()).isEmpty();

    MstDestinationGroup group4 = result.get(3);
    assertThat(group4.getDestinationGroupCd()).isEqualTo(4L);
    assertThat(group4.getDestinationGroupName()).isEqualTo("group4");
    assertThat(group4.getFacilityCd()).isEqualTo(facilityCd);
    final MstDestinationGroup.DestinationTarget target4 = group4.getDestinationTarget();
    assertThat(target4).isNotNull();
    assertThat(target4.getUsers()).isEmpty();
  }

  /**
   * selectByFacilityCdの検証.
   *
   * 条件：データが存在しない施設コードを指定 結果：空のリストを取得できること
   */
  @Test
  public void 施設コードに一致する送信先グループがない場合_空のリストを取得できること() {
    // arrange
    final String facilityCd = "9999";

    // action
    final List<MstDestinationGroup> result = target.selectByFacilityCd(facilityCd);

    // assert
    assertThat(result).hasSize(0);
  }

  /**
   * selectAll()の検証.
   * <p>
   * 条件：なし 結果：取得結果5件であること
   * </p>
   */
  @Test
  public void test_selectAll_正常() {
    // 実行
    List<MstDestinationGroup> result = target.selectAll();

    // 検証
    assertThat(result).hasSize(5);
    MstDestinationGroup group1 = result.get(0);
    assertThat(group1.getDestinationGroupCd()).isEqualTo(1L);
    assertThat(group1.getDestinationGroupName()).isEqualTo("group1");
    assertThat(group1.getFacilityCd()).isEqualTo("0001");
    final MstDestinationGroup.DestinationTarget target1 = group1.getDestinationTarget();
    assertThat(target1).isNotNull();
    assertThat(target1.getUsers())
      .extracting(
        MstDestinationGroup.User::getUserId
        ,MstDestinationGroup.User::isAddress1Send
        , MstDestinationGroup.User::isAddress2Send
      )
      .containsOnly(
        tuple(1000L, true, true)
        , tuple(1500L, true, false)
      )
    ;

    assertThat(result)
      .extracting(
        MstDestinationGroup::getDestinationGroupCd,
        MstDestinationGroup::getDestinationGroupName
      )
      .containsExactlyInAnyOrder(
        tuple(1L, "group1")
        , tuple(2L, "group2")
        , tuple(3L, "group3")
        , tuple(4L, "group4")
        , tuple(5L, "group1")
      )
    ;
  }

  /**
   * selectByDestinationGroupCdの検証.
   *
   * 条件：データが存在する送信先グループコードを指定 結果：結果が取得できること
   */
  @Test
  public void 送信先グループコードに一致する送信先グループを取得できること() {
    // arrange
    final Long destinationGroupCd = 1L;

    // action
    final MstDestinationGroup result = target.selectByDestinationGroupCd(destinationGroupCd);

    assertThat(result.getDestinationGroupCd()).isEqualTo(1L);
    assertThat(result.getDestinationGroupName()).isEqualTo("group1");
    assertThat(result.getFacilityCd()).isEqualTo("0001");
    final MstDestinationGroup.DestinationTarget target1 = result.getDestinationTarget();
    assertThat(target1).isNotNull();
    assertThat(target1.getUsers()).extracting(MstDestinationGroup.User::getUserId,
        MstDestinationGroup.User::isAddress1Send, MstDestinationGroup.User::isAddress2Send)
        .containsOnly(tuple(1000L, true, true), tuple(1500L, true, false));
  }

  /**
   * selectByDestinationGroupCdの検証.
   *
   * 条件：データが存在しない送信先グループコードを指定 結果：Nullが返ること
   */
  @Test
  public void 送信先グループコードに一致する送信先グループがない場合_Nullが返ること() {
    // arrange
    final Long destinationGroupCd = 9999L;

    // action
    final MstDestinationGroup result = target.selectByDestinationGroupCd(destinationGroupCd);

    // assert
    assertThat(result).isNull();
  }
}
