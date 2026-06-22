package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.MstUser;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.junit.Assert.assertThat;

/**
 * {@link MstUserDao} のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql( "classpath:dao.script/MstUserDaoTest.before.sql")
public class MstUserDaoTest {

    /**
     * テスト対象Dao.
     */
    @Autowired
    private MstUserDao target;

    /**
     * selectById()の検証.
     * <p>
     *   条件：該当データなし
     *   結果：取得結果nullであること
     * </p>
     */
    @Test
    public void test_selectById_正常_該当データなし() {

        // 事前準備
        Long userId = 3L;

        // 実行
        MstUser result = target.selectById(userId);

        // 検証
        assertThat(result, nullValue());
    }

    /**
     * selectById()の検証.
     * <p>
     *   条件：該当データあり
     *   結果：該当データを取得できること
     * </p>
     */
    @Test
    public void test_selectById_正常_該当データあり() {

        // 事前準備
        Long userId = 1L;

        // 実行
        MstUser result = target.selectById(userId);

        // 検証
        assertThat(result, notNullValue());
        assertThat(result.getIsProvisional(), is(1));
        assertThat(result.getUserSettings().getTheme(), is(0));
        assertThat(result.getUserSettings().getFontSize(), is(3));
        assertThat(result.getUserSettings().getIsDispMenu(), is(1));
        assertThat(result.getUserSettings().getUseFunctions().size(), is(5));
        assertThat(result.getUserSettings().getUseFunctions().get(0), is("005"));
        assertThat(result.getUserSettings().getUseFunctions().get(1), is("004"));
        assertThat(result.getUserSettings().getUseFunctions().get(2), is("003"));
        assertThat(result.getUserSettings().getUseFunctions().get(3), is("002"));
        assertThat(result.getUserSettings().getUseFunctions().get(4), is("001"));
        assertThat(result.getUserSettings().getAuthorizedAuthorities().get(0), is("011"));
        assertThat(result.getUserSettings().getAuthorizedAuthorities().get(1), is("012"));
        assertThat(result.getUserSettings().getAuthorizedAuthorities().get(2), is("013"));
        assertThat(result.getUserSettings().getIndRstPattern(), is(2));
        assertThat(result.getUserSettings().getPersonalSettings(), is(notNullValue()));
        assertThat(result.getUserSettings().getPersonalSettings().size(), is(1));
        assertThat(result.getUserSettings().getPersonalSettings().get(0).getTabDefineCd(), is(1));
        assertThat(result.getUserSettings().getPersonalSettings().get(0).getValues(), is(notNullValue()));
        assertThat(result.getUserSettings().getPersonalSettings().get(0).getValues().size(), is(3));
        assertThat(result.getUserSettings().getPersonalSettings().get(0).getValues().get(0).getSettingId(), is("1"));
        assertThat(result.getUserSettings().getPersonalSettings().get(0).getValues().get(0).getSettingValue(), is("val1"));
        assertThat(result.getUserSettings().getPersonalSettings().get(0).getValues().get(1).getSettingId(), is("2"));
        assertThat(result.getUserSettings().getPersonalSettings().get(0).getValues().get(1).getSettingValue(), is(2));
        assertThat(result.getUserSettings().getPersonalSettings().get(0).getValues().get(2).getSettingId(), is("3"));
        assertThat(result.getUserSettings().getPersonalSettings().get(0).getValues().get(2).getSettingValue(), is(1.45));
        assertThat(result.getUserSettings().getIsSplitFrame(), is(0));
    }

  /**
   * selectById()の検証.
   * <p>
   *   条件：該当データあり（個人設定情報なし）
   *   結果：デフォルト（空）の個人設定が取得できること
   * </p>
   */
  @Test
  public void test_selectById_正常_該当データあり_個人設定なし() {

    // 事前準備
    Long userId = 2L;

    // 実行
    MstUser result = target.selectById(userId);

    // 検証
    assertThat(result, notNullValue());
    assertThat(result.getUserSettings().getPersonalSettings(), is(notNullValue()));
    assertThat(result.getUserSettings().getPersonalSettings().size(), is(0));
  }

    /**
     * updateIsProvisional()の検証.
     * <p>
     *   条件：更新成功
     *   結果：正常に更新されること
     * </p>
     */
    @Test
    public void test_updateIsProvisional_正常_更新成功() {

        // 事前準備
        Long userId = 1L;
        MstUser mstUser = new MstUser() {
            {
                setUserId(userId);
                setIsProvisional(0);
                setUpDate(Timestamp.valueOf("2019-01-01 10:10:10"));
            }
        };

        // 実行
        int result = target.updateIsProvisional(mstUser);
        // 更新レコードを取得
        MstUser updatedUser = target.selectById(userId);

        // 検証
        assertThat(result, is(1));
        assertThat(updatedUser.getUserId(), is(userId));
        assertThat(updatedUser.getIsProvisional(), is(0));

    }

    /**
     * updateIsProvisional()の検証.
     * <p>
     *   条件：該当データなし
     *   結果：更新件数が0件であること
     * </p>
     */
    @Test
    public void test_updateIsProvisional_正常_該当データなし() {

        // 事前準備
        MstUser mstUser = new MstUser() {
            {
                setUserId(0L);
                setIsProvisional(0);
                setUpDate(Timestamp.valueOf("2019-01-01 10:10:10"));
            }
        };

        // 実行
        int result = target.updateIsProvisional(mstUser);

        // 検証
        assertThat(result, is(0));

    }
}
