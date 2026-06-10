package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.constant.CoreConstant.DataSourceName;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.TransactionManagerName;
import jp.co.nikkiso.ntss.core.entity.MstUserAuthentication;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlConfig;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;
import java.util.Arrays;
import java.util.List;

import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.notNullValue;
import static org.hamcrest.Matchers.nullValue;
import static org.junit.Assert.assertThat;

/**
 * {@link MstUserAuthenticationDao} のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional(TransactionManagerName.AUTH)
@Sql(value = "classpath:dao.script/MstUserAuthenticationDaoTest.before.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
public class MstUserAuthenticationDaoTest {

    /**
     * テスト対象Dao.
     */
    @Autowired
    private MstUserAuthenticationDao target;

    /**
     * selectById()の検証.
     * <p>
     *   条件：該当データあり
     *   結果：利用者マスタデータが取得できること
     * </p>
     */
    @Test
    public void test_selectById_正常_該当データあり() {
        // 事前準備
        Long userId = 1L;
        String dispUserId = "userAccount";
        String facilityCd = "test";
        Integer failureCnt = 2;

        // 実行
        MstUserAuthentication result = target.selectById(userId);

        // 検証
        assertThat(result, notNullValue());
        assertThat(result.getDispUserId(), is(dispUserId));
        assertThat(result.getFacilityCd(), is(facilityCd));
        assertThat(result.getFailureCnt(), is(failureCnt));
    }

    /**
     * selectById()の検証.
     * <p>
     *   条件：該当データなし
     *   結果：利用者マスタデータが取得できること
     * </p>
     */
    @Test
    public void test_selectById_正常_該当データなし() {
        // 事前準備
        Long userId = 3L;

        // 実行
        MstUserAuthentication result = target.selectById(userId);

        // 検証
        assertThat(result, nullValue());
    }

    /**
     * selectForLogin()の検証.
     * <p>
     *   条件：該当データあり
     *   結果：利用者マスタデータが取得できること
     * </p>
     */
    @Test
    public void test_selectForLogin_正常_該当データあり() {
        // 事前準備
        String dispUserId = "userAccount";
        String facilityCd = "test";
        Integer failureCnt = 2;

        // 実行
        MstUserAuthentication result = target.selectForLogin(dispUserId, facilityCd);

        // 検証
        assertThat(result, notNullValue());
        assertThat(result.getDispUserId(), is(dispUserId));
        assertThat(result.getFacilityCd(), is(facilityCd));
        assertThat(result.getFailureCnt(), is(failureCnt));
    }

    /**
     * selectForLogin()の検証.
     * <p>
     *   条件：該当データなし
     *   結果：利用者マスタデータが取得できること
     * </p>
     */
    @Test
    public void test_selectForLogin_正常_該当データなし() {
        // 事前準備
        String dispUserId = "userAccount";
        String facilityCd = "test2";

        // 実行
        MstUserAuthentication result = target.selectForLogin(dispUserId, facilityCd);

        // 検証
        assertThat(result, nullValue());
    }

    /**
     * updateFailureCnt()の検証.
     * <p>
     *   条件：該当データあり
     *   結果：サインイン失敗回数が更新されること
     * </p>
     */
    @Test
    public void test_updateFailureCnt_正常_更新成功() {
        // 事前準備
        Long userId = 1L;
        MstUserAuthentication beforeUser = target.selectById(userId);
        Integer lastFailureCnt = beforeUser.getFailureCnt();

        // 実行
        beforeUser.setFailureCnt(lastFailureCnt + 1);
        int result = target.updateFailureCnt(beforeUser);

        // 更新レコードを取得
        MstUserAuthentication updatedUser = target.selectById(userId);

        // 検証
        assertThat(result, is(1));
        assertThat(updatedUser.getFailureCnt(), is(lastFailureCnt + 1));
    }

    /**
     * updateFailureCnt()の検証.
     * <p>
     *   条件：該当データなし
     *   結果：更新件数が0件であること
     * </p>
     */
    @Test
    public void test_updateFailureCnt_正常_該当データなし() {

        // 事前準備
        MstUserAuthentication mstUser = new MstUserAuthentication() {
            {
                setUserId(0L);
                setFailureCnt(0);
                setUpDate(Timestamp.valueOf("2019-01-01 10:10:10"));
            }
        };

        // 実行
        int result = target.updateFailureCnt(mstUser);

        // 検証
        assertThat(result, is(0));

    }

    /**
     * updateDispUserIdAndUserPassword()の検証.
     * <p>
     *   条件：更新成功
     *   結果：正常に更新されること
     * </p>
     */
    @Test
    public void test_updateDispUserIdAndUserPassword_正常_更新成功() {

        // 事前準備
        Long userId = 1L;
        String dispUserId = "id_updated!!";
        String userPassword = "pw_updated!!";
        MstUserAuthentication userAuthentication = new MstUserAuthentication() {
            {
                setUserId(userId);
                setDispUserId("id_updated!!");
                setUserPassword("pw_updated!!");
                setUpDate(Timestamp.valueOf("2019-01-01 10:10:10"));
            }
        };

        // 実行
        int result = target.updateDispUserIdAndUserPassword(userAuthentication);
        // 更新レコードを取得
        MstUserAuthentication updatedUser = target.selectById(userId);

        // 検証
        assertThat(result, is(1));
        assertThat(updatedUser.getUserId(), is(userId));
        assertThat(updatedUser.getDispUserId(), is(dispUserId));
        assertThat(updatedUser.getUserPassword(), is(userPassword));

    }

    /**
     * updateDispUserIdAndUserPassword()の検証.
     * <p>
     *   条件：更新成功
     *   結果：正常に更新されること
     *         パスワードは更新されないこと
     * </p>
     */
    @Test
    public void test_updateDispUserIdAndUserPassword_正常_更新成功_パスワード未設定() {

        // 事前準備
        Long userId = 1L;
        String dispUserId = "id_updated!!";
        MstUserAuthentication userAuthentication = new MstUserAuthentication() {
            {
                setUserId(userId);
                setDispUserId(dispUserId);
                setUserPassword(null);
                setUpDate(Timestamp.valueOf("2019-01-01 10:10:10"));
            }
        };

        // 実行
        int result = target.updateDispUserIdAndUserPassword(userAuthentication);
        // 更新レコードを取得
        MstUserAuthentication updatedUser = target.selectById(userId);

        // 検証
        assertThat(result, is(1));
        assertThat(updatedUser.getUserId(), is(userId));
        assertThat(updatedUser.getDispUserId(), is(dispUserId));
        assertThat(updatedUser.getUserPassword(), is("password"));

    }

    /**
     * updateDispUserIdAndUserPassword()の検証.
     * <p>
     *   条件：該当データなし
     *   結果：更新件数が0件であること
     * </p>
     */
    @Test
    public void test_updateDispUserIdAndUserPassword_正常_該当データなし() {

        // 事前準備
        MstUserAuthentication userAuthentication = new MstUserAuthentication() {
            {
                setUserId(0L);
                setDispUserId("noAnyone");
                setUserPassword("newPassword");
                setUpDate(Timestamp.valueOf("2019-01-01 10:10:10"));
            }
        };

        // 実行
        int result = target.updateDispUserIdAndUserPassword(userAuthentication);

        // 検証
        assertThat(result, is(0));

    }

    /**
     * selectDispUserId()の検証.
     * <p>
     *   条件：該当データなし
     *   結果：取得結果0件であること
     * </p>
     */
    @Test
    public void test_selectDispUserId_正常_該当データなし() {

      // 事前準備
      String dispUserId = "noAnyone";

      // 実行
      List<MstUserAuthentication> result = target.selectDispUserId(dispUserId,"");

      // 検証
      assertThat(result, notNullValue());
      assertThat(result, hasSize(0));

    }


    /**
     * selectDispUserId()の検証.
     * <p>
     *   条件：該当データ1件
     *   結果：該当するユーザー情報が取得できること
     * </p>
     */
    @Test
    public void test_selectDispUserId_正常_該当データあり() {

      // 事前準備
      String dispUserId = "userAccount";

      // 実行
      List<MstUserAuthentication> result = target.selectDispUserId(dispUserId,"");

      // 検証
      assertThat(result, notNullValue());
      assertThat(result, hasSize(1));
      assertThat(result.get(0).getDispUserId(), is(dispUserId));
      assertThat(result.get(0).getUserId(), is(1L));

    }

    /**
     * selectFacilityCdByUserId()の検証.
     * <p>
     *   条件：該当データなし
     *   結果：取得結果0件であること
     * </p>
     */
    @Test
    public void test_selectFacilityCdByUserId_正常_該当データなし() {
      // 事前準備
      List<Long> userIds = Arrays.asList(10L, 20L);

      // 実行
      List<String> result = target.selectFacilityCdByUserId(userIds);

      // 検証
      assertThat(result, notNullValue());
      assertThat(result, hasSize(0));
    }

    /**
     * selectFacilityCdByUserId()の検証.
     * <p>
     *   条件：該当データなし
     *   結果：該当する施設コードが取得できること
     * </p>
     */
    @Test
    public void test_selectFacilityCdByUserId_正常_該当データあり() {
      // 事前準備
      List<Long> userIds = Arrays.asList(1L, 9L);

      // 実行
      List<String> result = target.selectFacilityCdByUserId(userIds);

      // 検証
      assertThat(result, notNullValue());
      assertThat(result, hasSize(2));
      assertThat(result.get(0), is("test"));
      assertThat(result.get(1), is("test9"));
    }

}
