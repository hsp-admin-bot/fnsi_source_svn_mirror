package jp.co.nikkiso.ntss.admin_web.service;

import jp.co.nikkiso.ntss.admin_web.response.personalUser.NameWithHasEmailResponse;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlConfig;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static jp.co.nikkiso.ntss.core.constant.CoreConstant.DataSourceName.PERSONAL;
import static org.assertj.core.api.Assertions.assertThat;

@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql(value = "classpath:resource.service/PersonalUserServiceImplTest.before.sql", config = @SqlConfig(dataSource = PERSONAL, transactionManager = CoreConstant.TransactionManagerName.PERSONAL))
public class PersonalUserServiceImplTest {

  /**
   * テスト対象クラス
   */
  @Autowired
  private PersonalUserService personalUserService;

  /**
   * getNameAndHasEmailByFacilityCdメソッドの検証
   *
   * 条件：指定施設に利用者あり
   * 結果：利用者の名前とメールアドレスの登録有無を返すこと
   */
  @Test
  public void  利用者IDと利用者名とメールアドレスの登録有無を返すこと() {
    // arrange
    final String facilityCd = "0001";

    // action
    final NameWithHasEmailResponse result = personalUserService.getNameAndHasEmailByFacilityCd(facilityCd);

    // assert
    final List<NameWithHasEmailResponse.NameWithHasEmail> personalUsers = result.getPersonalUsers();
    assertThat(personalUsers).hasSize(3);

    final NameWithHasEmailResponse.NameWithHasEmail nameWithHasEmail1 = personalUsers.get(0);
    assertThat(nameWithHasEmail1.getUserId()).isEqualTo(1L);
    assertThat(nameWithHasEmail1.getLastName()).isEqualTo("last_name_1");
    assertThat(nameWithHasEmail1.getFirstName()).isEqualTo("first_name_1");
    assertThat(nameWithHasEmail1.hasEmailAddress1()).isTrue();
    assertThat(nameWithHasEmail1.hasEmailAddress2()).isFalse();

    final NameWithHasEmailResponse.NameWithHasEmail nameWithHasEmail2 = personalUsers.get(1);
    assertThat(nameWithHasEmail2.getUserId()).isEqualTo(2L);
    assertThat(nameWithHasEmail2.getLastName()).isEqualTo("last_name_2");
    assertThat(nameWithHasEmail2.getFirstName()).isEqualTo("first_name_2");
    assertThat(nameWithHasEmail2.hasEmailAddress1()).isTrue();
    assertThat(nameWithHasEmail2.hasEmailAddress2()).isTrue();

    final NameWithHasEmailResponse.NameWithHasEmail nameWithHasEmail3 = personalUsers.get(2);
    assertThat(nameWithHasEmail3.getUserId()).isEqualTo(3L);
    assertThat(nameWithHasEmail3.getLastName()).isEqualTo("last_name_3");
    assertThat(nameWithHasEmail3.getFirstName()).isEqualTo("first_name_3");
    assertThat(nameWithHasEmail3.hasEmailAddress1()).isTrue();
    assertThat(nameWithHasEmail3.hasEmailAddress2()).isFalse();
  }

  /**
   * getNameAndHasEmailByFacilityCdメソッドの検証
   *
   * 条件：指定施設に利用者なし
   * 結果：空のリストを返すこと
   */
  @Test
  public void 指定した施設に利用者が登録されていない場合は空のリストを返すこと() {
    // arrange
    final String facilityCd = "0002";

    // action
    final NameWithHasEmailResponse result = personalUserService.getNameAndHasEmailByFacilityCd(facilityCd);

    // assert
    final List<NameWithHasEmailResponse.NameWithHasEmail> personalUsers = result.getPersonalUsers();
    assertThat(personalUsers).hasSize(0);
  }
}
