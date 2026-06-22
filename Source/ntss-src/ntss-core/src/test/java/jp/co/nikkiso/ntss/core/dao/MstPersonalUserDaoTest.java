package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.constant.CoreConstant.DataSourceName;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.TransactionManagerName;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlConfig;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.not;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.junit.Assert.assertThat;

/**
 * {@link MstPersonalUserDao} のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional(TransactionManagerName.PERSONAL)
@Sql(value = "classpath:dao.script/MstPersonalUserDaoTest.before.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
public class MstPersonalUserDaoTest {

    /**
     * テスト対象Dao.
     */
    @Autowired
    private MstPersonalUserDao target;

    /**
     * selectById()の検証.
     * <p>
     *   条件：該当データあり
     *   結果：レコードが取得できること
     * </p>
     */
    @Test
    public void test_selectById_正常_該当データあり() {

        // 事前準備
        Long userId = 11L;

        // 実行
        MstPersonalUser result = target.selectById(userId);

        // 検証
        assertThat(result, notNullValue());
        assertThat(result.getUserId(), is(11L));
        assertThat(result.getFacilityCd(), is("test"));
        assertThat(result.getUserType(), is(0));
        assertThat(result.getUserLastName(), is("lastName"));
        assertThat(result.getUserFirstName(), is("firstName"));
        assertThat(result.getUserLastNameKana(), is("lastNameKana"));
        assertThat(result.getUserFirstNameKana(), is("firstNameKana"));
        assertThat(result.getUserLastNameAlpha(), is("lastNameAlpha"));
        assertThat(result.getUserFirstNameAlpha(), is("firstNameAlpha"));
        assertThat(result.getUserEmailAddress1(), is("emailAddress1@abc.jp"));
        assertThat(result.getUserEmailAddress2(), is("emailAddress2@xxx.org"));
        assertThat(result.getExtensionNo(), is("extensionNo"));
        assertThat(result.getHomeNo(), is("homeNo"));
        assertThat(result.getMobilePhoneNo(), is("mobilePhoneNo"));
        assertThat(result.getFaxNo(), is("faxNo"));
        assertThat(result.getZipcd3(), is("001"));
        assertThat(result.getZipcd4(), is("0001"));
        assertThat(result.getAddress(), is("address"));
        assertThat(result.getAddressKana(), is("addressKana"));
        assertThat(result.getJobCd(), is("01"));
        assertThat(result.getRegDate(), is(Timestamp.valueOf("2018-05-25 17:16:55")));
        assertThat(result.getUpDate(), is(Timestamp.valueOf("2018-08-22 17:19:19.405")));
    }

    /**
     * selectById()の検証.
     * <p>
     *   条件：該当データなし
     *   結果：レコードが取得できないこと
     * </p>
     */
    @Test
    public void test_selectById_正常_該当データなし() {

        // 事前準備
        Long userId = 0L;

        // 実行
        MstPersonalUser result = target.selectById(userId);

        // 検証
        assertThat(result, nullValue());
    }

    /**
     * selectUserNameById()の検証.
     * <p>
     *   条件：該当データあり
     *   結果：レコードが取得できること
     * </p>
     */
    @Test
    public void test_selectUserNameById_正常_該当データあり() {

        // 事前準備
        Long userId = 7L;

        // 実行
        String result = target.selectUserNameById(userId);

        // 検証
        assertThat(result, is("テスト　太郎"));

    }

    /**
     * selectUserNameById()の検証.
     * <p>
     *   条件：該当データなし
     *   結果：レコードが取得できないこと
     * </p>
     */
    @Test
    public void test_selectUserNameById_正常_該当データなし() {

        // 事前準備
        Long userId = 1L;

        // 実行
        String result = target.selectUserNameById(userId);

        // 検証
        assertThat(result, nullValue());

    }

    /**
     * update()の検証.
     * <p>
     *   条件: 該当データあり.
     *   結果: レコード更新件数１件であること.　設定内容で更新されていること.
     * </p>
     */
    @Test
    public void test_update_正常_該当データあり() {
        // 事前準備
        MstPersonalUser entity = target.selectById(12L);
        entity.setFacilityCd("919191");
        entity.setUserType(99);
        entity.setUserLastName("01");
        entity.setUserFirstName("02");
        entity.setUserLastNameKana("03");
        entity.setUserFirstNameKana("04");
        entity.setUserLastNameAlpha("05");
        entity.setUserFirstNameAlpha("06");
        entity.setUserEmailAddress1("07");
        entity.setUserEmailAddress2("08");
        entity.setExtensionNo("09");
        entity.setHomeNo("10");
        entity.setMobilePhoneNo("11");
        entity.setFaxNo("12");
        entity.setZipcd3("13");
        entity.setZipcd4("14");
        entity.setAddress("15");
        entity.setAddressKana("16");
        entity.setJobCd("17");
        entity.setAdministrator(99);

        // 実行
        int count = target.update(entity);

        // 検証(更新件数)
        assertThat(count, is(1));

        // 検証(更新内容)
        MstPersonalUser after = target.selectById(12L);
        assertThat(after, notNullValue());
        assertThat(after.getUserId(), is(12L));
        assertThat(after.getFacilityCd(), is("909090")); // 更新されてないこと
        assertThat(after.getUserType(), is(1));  // 更新されてないこと
        assertThat(after.getUserLastName(), is("01"));
        assertThat(after.getUserFirstName(), is("02"));
        assertThat(after.getUserLastNameKana(), is("03"));
        assertThat(after.getUserFirstNameKana(), is("04"));
        assertThat(after.getUserLastNameAlpha(), is("05"));
        assertThat(after.getUserFirstNameAlpha(), is("06"));
        assertThat(after.getUserEmailAddress1(), is("07"));
        assertThat(after.getUserEmailAddress2(), is("08"));
        assertThat(after.getExtensionNo(), is("09"));
        assertThat(after.getHomeNo(), is("10"));
        assertThat(after.getMobilePhoneNo(), is("11"));
        assertThat(after.getFaxNo(), is("12"));
        assertThat(after.getZipcd3(), is("13"));
        assertThat(after.getZipcd4(), is("14"));
        assertThat(after.getAddress(), is("15"));
        assertThat(after.getAddressKana(), is("16"));
        assertThat(after.getJobCd(), is("17"));
        assertThat(after.getRegDate(), is(Timestamp.valueOf("2000-01-01 00:00:00"))); // 更新されてないこと
        assertThat(after.getUpDate(), not(Timestamp.valueOf("2000-01-01 00:00:00")));
        assertThat(after.getAdministrator(), is(1));  // 更新されてないこと
    }

    /**
     * update()の検証.
     * <p>
     *   条件: 該当データなし.
     *   結果: レコード更新件数０件であること.
     * </p>
     */
    @Test
    public void test_update_正常_該当データなし() {
        // 事前準備
        Long userId = 99L;

        // 実行
        MstPersonalUser entity = new MstPersonalUser() {{
            setUserId(userId);
            setUserLastName("99");
            setUserFirstName("99");
            setUserLastNameKana("99");
            setUserFirstNameKana("99");
            setUserLastNameAlpha("99");
            setUserFirstNameAlpha("99");
            setUserEmailAddress1("99");
            setUserEmailAddress2("99");
            setExtensionNo("99");
            setHomeNo("99");
            setMobilePhoneNo("99");
            setFaxNo("99");
            setZipcd3("99");
            setZipcd4("99");
            setAddress("99");
            setAddressKana("99");
            setJobCd("99");
            setUpDate(Timestamp.valueOf("2000-01-01 10:10:10"));
            setAdministrator(99);
        }};
        int count = target.update(entity);

        // 検証
        assertThat(count, is(0));
    }
}
