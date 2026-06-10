package jp.co.nikkiso.ntss.core.dao;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.junit.Assert.assertThat;

/**
 * {@link MntGatheringManageDao} のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:dao.script/MntGatheringManageDaoTest.before.sql")
public class MntGatheringManageDaoTest {

    /**
     * テスト対象Dao.
     */
    @Autowired
    private MntGatheringManageDao target;

    /**
     * selectByUserIdAndFacilityCdAndDate()の検証.
     * <p>
     *   条件：該当データなし
     *   結果：取得結果 nullであること
     * </p>
     */
    @Test
    public void test_selectByUserIdAndFacilityCdAndDate_正常_該当データなし() {

        // 事前準備
        Long userId = 0L;
        String facilityCd = "test";

        // 実行
        Integer result = target.selectByUserIdAndFacilityCdAndDate(userId, facilityCd, "20171204");

        // 検証
        assertThat(result, nullValue());
    }

    /**
     * selectByUserIdAndFacilityCdAndDate()の検証.
     * <p>
     *   条件：該当データあり
     *   結果：該当データを取得できること
     * </p>
     */
    @Test
    public void test_selectByUserIdAndFacilityCdAndDate_正常_該当データあり() {

        // 事前準備
        Long userId = 1L;
        String facilityCd = "000001";

        // 実行
        Integer result = target.selectByUserIdAndFacilityCdAndDate(userId, facilityCd, "20171206");

        // 検証
        assertThat(result, is(1));
    }
}
