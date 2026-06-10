package jp.co.nikkiso.ntss.coop_api.web.rest;

import static org.assertj.core.api.Assertions.fail;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.junit.Assert.assertThat;
import static org.junit.Assert.assertTrue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;

import org.apache.commons.beanutils.BeanUtils;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.SpyBean;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.annotation.Rollback;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlConfig;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.request.JournalConvertReceiveRequest;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.DataSourceName;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.TransactionManagerName;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstUserAuthenticationDao;
import jp.co.nikkiso.ntss.core.dao.MstUserDao;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.entity.MstUserAuthentication;
import lombok.extern.slf4j.Slf4j;

@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
@Rollback(false)
@Slf4j
public class JournalConvertReceiveResourceUserTest extends AbstractResourceTest {

  @SpyBean
  private MstPersonalUserDao mstPersonalUserDao;

  @SpyBean
  private MstUserAuthenticationDao mstUserAuthenticationDao;

  @SpyBean
  private MstUserDao mstUserDao;

  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ00/clean_db4_Q00.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ00/clean_db5_Q00.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ00/clean_db6_Q00.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ00/masters_layout_Q00.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ00/journal_Q00.sql")
  @Test
  public void ユーザ登録テスト_1_mst_personal_userのみ() {
    final String FACILITY_CD = "F_hQ00";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // DB登録内容検証

      // mst_personal_user
      List<MstPersonalUser> mpuList = mstPersonalUserDao.selectAll(FACILITY_CD, "0");
      assertThat(mpuList, notNullValue());
      assertThat(mpuList.size(), is(1));

      MstPersonalUser mpuResult = mpuList.get(0);
      assertThat(mpuResult, notNullValue());

      assertMstPersonalUser(mpuResult, FACILITY_CD, 11,
        "ああああ", "いいいい",
        "アアアア", "イイイイ",
        "AAAA", "IIII",
        "mail1@example.com", "mail2@example.com",
        "1020", "033-AAAA-AAAA",
        "090-XXXX-XXXX", "033-YYYY-YYYY",
        "001", "0011",
        "東京都千代田区霞が関", "トウキョウトチヨダクカスミガセキ",
        "JJ", 12,
        "1", "0",
        "1234", "5678",
        "1", "311-46-2210");

    } catch (Exception e) {
      log.error("", e);
      fail("", e);
    }
  }

  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ01/clean_db4_Q01.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ01/clean_db5_Q01.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ01/clean_db6_Q01.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ01/masters_layout_Q01.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ01/journal_Q01.sql")
  @Test
  public void ユーザ登録テスト_2_全テーブル() {
    final String FACILITY_CD = "F_hQ01";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // DB登録内容検証

      // mst_personal_user
      List<MstPersonalUser> mpuList = mstPersonalUserDao.selectAll(FACILITY_CD, "0");
      assertThat(mpuList, notNullValue());
      assertThat(mpuList.size(), is(1));

      MstPersonalUser mpuResult = mpuList.get(0);
      assertThat(mpuResult, notNullValue());

      assertMstPersonalUser(mpuResult, FACILITY_CD, 11,
        "ああああ", "いいいい",
        "アアアア", "イイイイ",
        "AAAA", "IIII",
        "mail1@example.com", "mail2@example.com",
        "1020", "033-AAAA-AAAA",
        "090-XXXX-XXXX", "033-YYYY-YYYY",
        "001", "0011",
        "東京都千代田区霞が関", "トウキョウトチヨダクカスミガセキ",
        "KK", 13,
        "1", "0",
        "TEX-ENG_001", "5678",
        "1", "311-46-2210");

      // mst_user_authentication
      Long userId = mpuResult.getUserId();
      log.debug("userId={}", userId);
      MstUserAuthentication mua = mstUserAuthenticationDao.selectById(userId);
      assertThat(mua, notNullValue());

      assertMstUserAuthentication(mua, "TEX-ENG_001", "ppaasssswwoorrddd", 2);
      // FIXME パスワードはJava側で暗号化する。

      // mst_user
      MstUser mu = mstUserDao.selectById(userId);
      assertThat(mu, notNullValue());

      assertMstUser(mu, 5, 14, 88, 1,
        1, "1", "0",
        "101", "検索条件1", "{\"userId\":[{\"cd\":123,\"name\":\"NNNNN\",\"cdType\":732}]}",
        "T1ERC3E2S8", "1", "TE3124901", 1, "2020-06-04 00:00:00");
      // 個人情報取扱い同意日時は時分秒ミリ秒が追加されて登録される。

      // FIXME pat_idが正しく反映されていない。

    } catch (Exception e) {
      fail("", e);
    }
  }

  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ02/clean_db4_Q02.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ02/clean_db5_Q02.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ02/clean_db6_Q02.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ02/masters_layout_Q02.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ02/journal_Q02.sql")
  @Test
  public void ユーザ登録テスト_3_全テーブル_複数ユーザ() {
    final String FACILITY_CD = "F_hQ02";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // DB登録内容検証

      // mst_personal_user
      List<MstPersonalUser> mpuList = mstPersonalUserDao.selectAll(FACILITY_CD, "0");
      assertThat(mpuList, notNullValue());
      assertThat(mpuList.size(), is(3));

      // mst_personal_userのselectAll()はORDER BYが指定されておらず、取得は順不同である。
      // 検証のためソートする。
      Comparator<MstPersonalUser> comp = new Comparator<MstPersonalUser>() {
        @Override
        public int compare(MstPersonalUser o1, MstPersonalUser o2) {
          return o1.getUserId().compareTo(o2.getUserId());
        }
      };
      Collections.sort(mpuList, comp);

      {
        Map<String, String> d = BeanUtils.describe(mpuList.get(0));
        log.debug("Q02={}", d);
      }

      assertMstPersonalUser(mpuList.get(0), FACILITY_CD, 11,
        "ああああ", "いいいい",
        "アアアア", "イイイイ",
        "AAAA", "IIII",
        "mail1@example.com", "mail2@example.com",
        "1020", "033-AAAA-AAAA",
        "090-XXXX-XXXX", "033-YYYY-YYYY",
        "001", "0011",
        "東京都千代田区霞が関", "トウキョウトチヨダクカスミガセキ",
        "JJ", 12,
        "1", "0",
        "TEX-ENG_001", "5678",
        "1", "311-46-2210");

      assertMstPersonalUser(mpuList.get(1), FACILITY_CD, 11,
        "ああああ", "いいいい",
        "アアアア", "イイイイ",
        "AAAA", "IIII",
        "mail1@example.com", "mail2@example.com",
        "1020", "033-AAAA-AAAA",
        "090-XXXX-XXXX", "033-YYYY-YYYY",
        "001", "0011",
        "東京都千代田区霞が関", "トウキョウトチヨダクカスミガセキ",
        "KK", 13,
        "1", "0",
        "TEX-ENG_002", "5678",
        "1", "311-46-2210");

      // このデータのみ、氏名が小文字。
      assertMstPersonalUser(mpuList.get(2), FACILITY_CD, 11,
        "ぁぁぁぁ", "ぃぃぃぃ",
        "アアアア", "イイイイ",
        "AAAA", "IIII",
        "mail1@example.com", "mail2@example.com",
        "1020", "033-AAAA-AAAA",
        "090-XXXX-XXXX", "033-YYYY-YYYY",
        "001", "0011",
        "東京都千代田区霞が関", "トウキョウトチヨダクカスミガセキ",
        "LL", 14,
        "1", "0",
        "TEX-ENG_003", "5678",
        "1", "311-46-2210");

      // mst_user_authentication
      List<MstUserAuthentication> muaList = mstUserAuthenticationDao.selectByFacility(FACILITY_CD);

      // mst_user_authenticationのselectByFacility()はORDER BY user_idであるのでソート不要。

      // user_idの一致を検証する。
      int len = muaList.size();
      for (int i = 0; i < len; ++i) {
        assertThat(muaList.get(i).getUserId(), is(mpuList.get(i).getUserId()));
      }

      assertMstUserAuthentication(muaList.get(0), "TEX-ENG_001", "ppaasssswwoorrddd", 2);
      assertMstUserAuthentication(muaList.get(1), "TEX-ENG_002", "ppaasssswwoorrddd", 5);
      assertMstUserAuthentication(muaList.get(2), "TEX-ENG_003", "ppaasssswwoorrddd", 1);

      // mst_user
      // mst_userは複数件を取得するAPIが存在しない。
      MstUser mu1 = mstUserDao.selectById(mpuList.get(0).getUserId());
      assertThat(mu1, notNullValue());
      MstUser mu2 = mstUserDao.selectById(mpuList.get(1).getUserId());
      assertThat(mu2, notNullValue());
      MstUser mu3 = mstUserDao.selectById(mpuList.get(2).getUserId());
      assertThat(mu3, notNullValue());

      assertMstUser(mu1, 5, 14, 88, 1,
        1, "1", "0",
        "101", "検索条件1", "{\"userId\":[{\"cd\":123,\"name\":\"NNNNN\",\"cdType\":732}]}",
        "T1ERC3E2S8", "1", "TE3124901", 1, "2020-06-04 00:00:00");

      assertMstUser(mu2, 3, 12, 88, 1,
        1, "1", "0",
        "101", "検索条件2", "{\"userId\":[{\"cd\":127,\"name\":\"NNNNN\",\"cdType\":732}]}",
        "T1ERC3E2S8", "1", "TE3124901", 1, "2020-06-04 00:00:00");

      assertMstUser(mu3, 8, 16, 88, 1,
        1, "1", "0",
        "101", "検索条件1", "{\"userId\":[{\"cd\":129,\"name\":\"NNNNN\",\"cdType\":732}]}",
        "T1ERC3E2S8", "1", "TE3124906", 1, "2020-06-04 00:00:00");

    } catch (Exception e) {
      fail("", e);
    }
  }

  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ03/clean_db4_Q03.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ03/clean_db5_Q03.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ03/clean_db6_Q03.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ03/masters_layout_Q03.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ03/journal_Q03_cre.sql")
  @Test
  public void ユーザ更新テスト_更新処理_01_新規() {
    final String FACILITY_CD = "F_hQ03";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // DB内容検証

      // mst_personal_user
      List<MstPersonalUser> mpuList = mstPersonalUserDao.selectAll(FACILITY_CD, "0");
      assertThat(mpuList, notNullValue());
      assertThat(mpuList.size(), is(1));

      MstPersonalUser mpuResult = mpuList.get(0);
      assertThat(mpuResult, notNullValue());

      assertMstPersonalUser(mpuResult, FACILITY_CD, 11,
        "ああああ", "いいいい",
        "アアアア", "イイイイ",
        "AAAA", "IIII",
        "mail1@example.com", "mail2@example.com",
        "1020", "033-AAAA-AAAA",
        "090-XXXX-XXXX", "033-YYYY-YYYY",
        "001", "0011",
        "東京都千代田区霞が関", "トウキョウトチヨダクカスミガセキ",
        "KK", 13,
        "1", "0",
        "TEX-ENG_001", "5678",
        "1", "311-46-2210");

      // mst_user_authentication
      Long userId = mpuResult.getUserId();
      MstUserAuthentication mua = mstUserAuthenticationDao.selectById(userId);
      assertThat(mua, notNullValue());

      assertMstUserAuthentication(mua, "TEX-ENG_001", "ppaasssswwoorrddd", 2);

      // mst_user
      MstUser mu = mstUserDao.selectById(userId);
      assertThat(mu, notNullValue());

      assertMstUser(mu, 5, 14, 88, 1,
        1, "1", "0",
        "101", "検索条件1", "{\"userId\":[{\"cd\":123,\"name\":\"NNNNN\",\"cdType\":732}]}",
        "T1ERC3E2S8", "1", "TE3124901", 1, "2020-06-04 00:00:00");

    } catch (Exception e) {
      fail("想定外エラー", e);
    }
  }

  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ03/init_db4_Q03.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ03/init_db5_Q03.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ03/init_db6_Q03.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ03/masters_layout_Q03.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ03/journal_Q03_upd.sql")
  @Test
  public void ユーザ更新テスト_更新処理_02_更新() {
    final String FACILITY_CD = "F_hQ03";

    try {

      // 更新前の値
      MstPersonalUser beforeMpu = mstPersonalUserDao.selectByInHospitalCd1(FACILITY_CD, "TEX-ENG_001");
      MstUserAuthentication beforeMua = mstUserAuthenticationDao.selectById(beforeMpu.getUserId());
      MstUser beforeMu = mstUserDao.selectById(beforeMpu.getUserId());

      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // DB内容検証

      // mst_personal_user
      List<MstPersonalUser> mpuList = mstPersonalUserDao.selectAll(FACILITY_CD, "0");
      assertThat(mpuList, notNullValue());
      assertThat(mpuList.size(), is(1));

      MstPersonalUser mpu = mpuList.get(0);
      assertThat(mpu, notNullValue());

      // 更新日付が更新されていることを確認
      assertThat((mpu.getUpDate().equals(beforeMpu.getUpDate())), is(false));
      assertMstPersonalUser(mpu, FACILITY_CD, 0,
        "あああ１", "いいい１",
        "アアア１", "イイイ１",
        "AAA1", "III1",
        "mail11@example.com", "mail22@example.com",
        "1021", "033-AAAA-AAA1",
        "090-XXXX-XXX1", "033-YYYY-YYY1",
        "101", "1011",
        "東京都千代田区霞が関１", "トウキョウトチヨダクカスミガセキ１",
        "K1", 0,
        "0", "0",
        "TEX-ENG_001", "0123",
        "0", "311-46-2200");

      // mst_user_authentication
      Long userId = mpu.getUserId();
      MstUserAuthentication mua = mstUserAuthenticationDao.selectById(userId);
      assertThat(mua, notNullValue());

      // 更新日付が更新されていることを確認
      assertThat((mua.getUpDate().equals(beforeMua.getUpDate())), is(false));
      assertMstUserAuthentication(mua, "TEX-ENG_001", "ppaasssswwoorrd01", 0);

      // mst_user
      MstUser mu = mstUserDao.selectById(userId);
      assertThat(mu, notNullValue());

      // 更新日付が更新されていることを確認
      assertThat((mu.getUpDate().equals(beforeMu.getUpDate())), is(false));
      assertMstUser(mu, 4, 12, 68, 0,
        0, "1", "0",
        "103", "検索条件2", "{\"userId\":[{\"cd\":123,\"name\":\"NNNN1\",\"cdType\":730}]}",
        "T1ERC3E0S8", "0", "TE31249D1", 0, "2020-08-03 00:00:00");
    } catch (Exception e) {
      fail("想定外エラー", e);
    }
  }

  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ03/init_db4_Q03.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ03/init_db5_Q03.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ03/init_db6_Q03.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ03/masters_layout_Q03.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ03/journal_Q03_upd2.sql")
  @Test
  public void ユーザ更新テスト_更新処理_03_更新() {
    final String FACILITY_CD = "F_hQ03";

    try {

      // 更新前の値
      MstPersonalUser beforeMpu = mstPersonalUserDao.selectByInHospitalCd1(FACILITY_CD, "TEX-ENG_001");
      MstUserAuthentication beforeMua = mstUserAuthenticationDao.selectById(beforeMpu.getUserId());
      MstUser beforeMu = mstUserDao.selectById(beforeMpu.getUserId());

      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // DB内容検証

      // mst_personal_user
      List<MstPersonalUser> mpuList = mstPersonalUserDao.selectAll(FACILITY_CD, "0");
      assertThat(mpuList, notNullValue());
      assertThat(mpuList.size(), is(1));

      MstPersonalUser mpu = mpuList.get(0);
      assertThat(mpu, notNullValue());
      // 更新日付が更新されていることを確認
      assertThat((mpu.getUpDate().equals(beforeMpu.getUpDate())), is(false));
      // 暗号化対象のカラムが電文に設定されていない場合、更新前後で変更なし
      assertMstPersonalUser(mpu, FACILITY_CD, 0,
        "ああああ", "いいいい",
        beforeMpu.getUserLastNameKana(), beforeMpu.getUserFirstNameKana(),
        beforeMpu.getUserLastNameAlpha(), beforeMpu.getUserFirstNameAlpha(),
        beforeMpu.getUserEmailAddress1(), beforeMpu.getUserEmailAddress2(),
        beforeMpu.getExtensionNo(), beforeMpu.getHomeNo(),
        "090-XXXX-XXX0", beforeMpu.getFaxNo(),
        beforeMpu.getZipcd3(), beforeMpu.getZipcd4(),
        "東京都千代田区霞が関３", "トウキョウトチヨダクカスミガセキ３",
        beforeMpu.getJobCd(), 0,
        "1", "0",
        "TEX-ENG_001", beforeMpu.getInHospitalCd_2(),
        "0", beforeMpu.getAnesthesiologistLicenseNo());

      // mst_user_authentication
      Long userId = mpu.getUserId();
      MstUserAuthentication mua = mstUserAuthenticationDao.selectById(userId);
      assertThat(mua, notNullValue());
      // 更新日付が更新されていることを確認
      assertThat((mua.getUpDate().equals(beforeMua.getUpDate())), is(false));
      assertMstUserAuthentication(mua, "TEX-ENG_001", "ppaasssswwoorrddd", 1);

      // mst_user
      MstUser mu = mstUserDao.selectById(userId);
      assertThat(mu, notNullValue());
      // 更新日付が更新されていることを確認
      assertThat((mu.getUpDate().equals(beforeMu.getUpDate())), is(false));
      assertMstUser(mu,
        null, 15,
        null, null,
        0, "1", "0",
        "", "", "",
        "",
        "0", "",
        1, "2020-08-01 00:00:00");

    } catch (Exception e) {
      fail("想定外エラー", e);
    }
  }

  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ03/init_db4_Q03.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ03/init_db5_Q03.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ03/init_db6_Q03.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ03/masters_layout_Q03.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ03/journal_Q03_upd_del.sql")
  @Test
  public void ユーザ更新テスト_更新処理_04_削除更新() {
    final String FACILITY_CD = "F_hQ03";

    try {

      // 更新前の値
      MstPersonalUser beforeMpu = mstPersonalUserDao.selectByInHospitalCd1(FACILITY_CD, "TEX-ENG_001");
      MstUserAuthentication beforeMua = mstUserAuthenticationDao.selectById(beforeMpu.getUserId());
      MstUser beforeMu = mstUserDao.selectById(beforeMpu.getUserId());

      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // DB内容検証

      // mst_personal_user
      List<MstPersonalUser> mpuList = mstPersonalUserDao.selectAll(FACILITY_CD, "1");
      assertThat(mpuList, notNullValue());
      assertThat(mpuList.size(), is(1));

      MstPersonalUser mpu = mpuList.get(0);
      assertThat(mpu, notNullValue());

      // 更新日付が更新されていることを確認
      assertThat((mpu.getUpDate().equals(beforeMpu.getUpDate())), is(false));
      assertMstPersonalUser(mpu, FACILITY_CD, beforeMpu.getUserType(),
        beforeMpu.getUserLastName(), beforeMpu.getUserFirstName(),
        beforeMpu.getUserLastNameKana(), beforeMpu.getUserFirstNameKana(),
        beforeMpu.getUserLastNameAlpha(), beforeMpu.getUserFirstNameAlpha(),
        beforeMpu.getUserEmailAddress1(), beforeMpu.getUserEmailAddress2(),
        beforeMpu.getExtensionNo(), beforeMpu.getHomeNo(),
        beforeMpu.getMobilePhoneNo(), beforeMpu.getFaxNo(),
        beforeMpu.getZipcd3(), beforeMpu.getZipcd4(),
        beforeMpu.getAddress(), beforeMpu.getAddressKana(),
        beforeMpu.getJobCd(), beforeMpu.getAdministrator(),
        beforeMpu.getIsDisp(), "1",
        beforeMpu.getInHospitalCd_1(), beforeMpu.getInHospitalCd_2(),
        beforeMpu.getInfoDispToAdmin(), beforeMpu.getAnesthesiologistLicenseNo());

      // mst_user_authentication
      Long userId = mpu.getUserId();
      MstUserAuthentication mua = mstUserAuthenticationDao.selectById(userId);
      assertThat(mua, notNullValue());
      // カラムにis_delを持っていないので必ず更新扱いになる
      assertThat((mua.getUpDate().equals(beforeMua.getUpDate())), is(false));
      assertMstUserAuthentication(mua, "TEX-ENG_001", "ppaasssswwoorrddd", 0);

      // mst_user
      MstUser mu = mstUserDao.selectById(userId);
      assertThat(mu, notNullValue());

      // 更新日付が更新されていることを確認
      assertThat((mu.getUpDate().equals(beforeMu.getUpDate())), is(false));
      String tmpLogSearchCondition = beforeMu.getTmpLogSearchCondition();
      Map<String, Object> m = ObjectMapperUtil.readListOfMap(tmpLogSearchCondition).get(0);
      assertMstUser(mu,
        beforeMu.getUserSettings().getIsDispMenu(), beforeMu.getUserSettings().getFontSize(),
        beforeMu.getUserSettings().getTheme(), beforeMu.getUserSettings().getIsSplitFrame(),
        beforeMu.getIsProvisional(), beforeMu.getIsDisp(), "1",
        (String)m.get("idFilter"), (String)m.get("nameFilter"), (String)m.get("condition"),
        beforeMu.getSecretKey(),
        String.valueOf(beforeMu.getIsSetQrCode()), null,
        beforeMu.getIsConsent(), "2020-08-03 00:00:00");

    } catch (Exception e) {
      fail("想定外エラー", e);
    }
  }

  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ03/init_db4_Q03.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ03/init_db5_Q03.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ03/init_db6_Q03.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ03/masters_layout_Q03.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ03/journal_Q03_del.sql")
  @Test
  public void ユーザ更新テスト_削除更新() {
    final String FACILITY_CD = "F_hQ03";

    try {

      // 更新前の値
      MstPersonalUser beforeMpu = mstPersonalUserDao.selectByInHospitalCd1(FACILITY_CD, "TEX-ENG_001");
      MstUserAuthentication beforeMua = mstUserAuthenticationDao.selectById(beforeMpu.getUserId());
      MstUser beforeMu = mstUserDao.selectById(beforeMpu.getUserId());

      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // DB内容検証

      // mst_personal_user
      List<MstPersonalUser> mpuList = mstPersonalUserDao.selectAll(FACILITY_CD, "1");
      assertThat(mpuList, notNullValue());
      assertThat(mpuList.size(), is(1));

      MstPersonalUser mpu = mpuList.get(0);
      assertThat(mpu, notNullValue());

      // 更新日付が更新されていることを確認
      assertThat((mpu.getUpDate().equals(beforeMpu.getUpDate())), is(false));
      // 削除フラグ以外は更新されていないこと
      assertMstPersonalUser(mpu, FACILITY_CD, beforeMpu.getUserType(),
        beforeMpu.getUserLastName(), beforeMpu.getUserFirstName(),
        beforeMpu.getUserLastNameKana(), beforeMpu.getUserFirstNameKana(),
        beforeMpu.getUserLastNameAlpha(), beforeMpu.getUserFirstNameAlpha(),
        beforeMpu.getUserEmailAddress1(), beforeMpu.getUserEmailAddress2(),
        beforeMpu.getExtensionNo(), beforeMpu.getHomeNo(),
        beforeMpu.getMobilePhoneNo(), beforeMpu.getFaxNo(),
        beforeMpu.getZipcd3(), beforeMpu.getZipcd4(),
        beforeMpu.getAddress(), beforeMpu.getAddressKana(),
        beforeMpu.getJobCd(), beforeMpu.getAdministrator(),
        beforeMpu.getIsDisp(), "1",
        beforeMpu.getInHospitalCd_1(), beforeMpu.getInHospitalCd_2(),
        beforeMpu.getInfoDispToAdmin(), beforeMpu.getAnesthesiologistLicenseNo());

      // mst_user_authentication
      Long userId = mpu.getUserId();
      MstUserAuthentication mua = mstUserAuthenticationDao.selectById(userId);
      assertThat(mua, notNullValue());
      // tableにis_delを持っていないので、電文上は設定されていても更新されないことを確認
      assertThat((mua.getUpDate().equals(beforeMua.getUpDate())), is(true));

      // mst_user
      MstUser mu = mstUserDao.selectById(userId);
      assertThat(mu, notNullValue());

      // 更新日付が更新されていることを確認
      assertThat((mu.getUpDate().equals(beforeMu.getUpDate())), is(false));
      String tmpLogSearchCondition = beforeMu.getTmpLogSearchCondition();
      Map<String, Object> m = ObjectMapperUtil.readListOfMap(tmpLogSearchCondition).get(0);
      // 削除フラグ以外は変更されていないこと
      assertMstUser(mu,
        beforeMu.getUserSettings().getIsDispMenu(), beforeMu.getUserSettings().getFontSize(),
        beforeMu.getUserSettings().getTheme(), beforeMu.getUserSettings().getIsSplitFrame(),
        beforeMu.getIsProvisional(), beforeMu.getIsDisp(), "1",
        (String)m.get("idFilter"), (String)m.get("nameFilter"), (String)m.get("condition"),
        beforeMu.getSecretKey(),
        String.valueOf(beforeMu.getIsSetQrCode()), null,
        beforeMu.getIsConsent(), "2020-08-03 00:00:00");

    } catch (Exception e) {
      fail("想定外エラー", e);
    }
  }

  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ04/init_db4_Q04.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ04/init_db5_Q04.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ04/init_db6_Q04.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ04/masters_layout_Q04.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceUserTest/sQ04/journal_Q04_upd.sql")
  @Test
  public void ユーザ更新テスト_レイアウトにない項目は更新対象外であること() {
    final String FACILITY_CD = "F_hQ04";

    try {

      // 更新前の値
      MstPersonalUser beforeMpu = mstPersonalUserDao.selectByInHospitalCd1(FACILITY_CD, "TEX-ENG_001");
      MstUserAuthentication beforeMua = mstUserAuthenticationDao.selectById(beforeMpu.getUserId());
      MstUser beforeMu = mstUserDao.selectById(beforeMpu.getUserId());

      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // DB内容検証

      // mst_personal_user
      List<MstPersonalUser> mpuList = mstPersonalUserDao.selectAll(FACILITY_CD, "0");
      assertThat(mpuList, notNullValue());
      assertThat(mpuList.size(), is(1));

      MstPersonalUser mpu = mpuList.get(0);
      assertThat(mpu, notNullValue());

      // 更新日付が更新されていることを確認
      assertThat((mpu.getUpDate().equals(beforeMpu.getUpDate())), is(false));
      assertMstPersonalUser(mpu, FACILITY_CD, beforeMpu.getUserType(),
        "ああああ", "いいいい",
        beforeMpu.getUserLastNameKana(), beforeMpu.getUserFirstNameKana(),
        beforeMpu.getUserLastNameAlpha(), beforeMpu.getUserFirstNameAlpha(),
        beforeMpu.getUserEmailAddress1(), beforeMpu.getUserEmailAddress2(),
        beforeMpu.getExtensionNo(), beforeMpu.getHomeNo(),
        beforeMpu.getMobilePhoneNo(), beforeMpu.getFaxNo(),
        beforeMpu.getZipcd3(), beforeMpu.getZipcd4(),
        beforeMpu.getAddress(), beforeMpu.getAddressKana(),
        beforeMpu.getJobCd(), beforeMpu.getAdministrator(),
        beforeMpu.getIsDisp(), "0",
        "TEX-ENG_001", "000000",
        beforeMpu.getInfoDispToAdmin(), beforeMpu.getAnesthesiologistLicenseNo());

      // mst_user_authentication
      Long userId = mpu.getUserId();
      MstUserAuthentication mua = mstUserAuthenticationDao.selectById(userId);
      assertThat(mua, notNullValue());
      // 更新日付が更新されていることを確認
      assertThat((mua.getUpDate().equals(beforeMua.getUpDate())), is(false));
      assertMstUserAuthentication(mua, "TEX-ENG_001", "ppaasssswwoorrd01", beforeMua.getFailureCnt());

      // mst_user
      MstUser mu = mstUserDao.selectById(userId);
      assertThat(mu, notNullValue());

      // 更新日付が更新されていることを確認
      assertThat((mu.getUpDate().equals(beforeMu.getUpDate())), is(false));
      String tmpLogSearchCondition = beforeMu.getTmpLogSearchCondition();
      Map<String, Object> m = ObjectMapperUtil.readListOfMap(tmpLogSearchCondition).get(0);
      //
      assertMstUser(mu,
        beforeMu.getUserSettings().getIsDispMenu(), beforeMu.getUserSettings().getFontSize(),
        beforeMu.getUserSettings().getTheme(), beforeMu.getUserSettings().getIsSplitFrame(),
        1, beforeMu.getIsDisp(), "0",
        (String)m.get("idFilter"), (String)m.get("nameFilter"), (String)m.get("condition"),
        beforeMu.getSecretKey(),
        String.valueOf(beforeMu.getIsSetQrCode()), null,
        1, "2020-08-20 00:00:00");

    } catch (Exception e) {
      fail("想定外エラー", e);
    }
  }

  /**
   * リクエストを発行する。
   *
   * @param facilityCd 施設コード
   * @return
   * @throws Exception
   */
  private ResultActions requestConversionByFacilityCd(String facilityCd) throws Exception {
    JournalConvertReceiveRequest req = new JournalConvertReceiveRequest();
    req.setFacilityCd(facilityCd);
    return mockMvc.perform(post("/journal/convert/receive")
      .content(ObjectMapperUtil.write(req)).contentType(MediaType.APPLICATION_JSON));
  }

  private void assertMstPersonalUser(MstPersonalUser mpu,
                                     String facilityCd, Integer userType,
                                     String lastName, String firstName,
                                     String lastNameKana, String firstNameKana,
                                     String lastNameAlpha, String firstNameAlpha,
                                     String email1, String email2,
                                     String extensionNo, String homeNo,
                                     String mobilePhoneNo, String faxNo,
                                     String zipCd3, String zipCd4,
                                     String address, String addressKana,
                                     String jobCd, Integer administrator,
                                     String isDisp, String isDel,
                                     String hospCd1, String hospCd2,
                                     String infoDispToAdmin, String anesthesiologistNo) {
    assertThat(mpu.getFacilityCd(), is(facilityCd));

    assertThat(mpu.getUserType(), is(userType));

    assertThat(mpu.getUserLastName(), is(lastName));
    assertThat(mpu.getUserFirstName(), is(firstName));

    assertThat(mpu.getUserLastNameKana(), is(lastNameKana));
    assertThat(mpu.getUserFirstNameKana(), is(firstNameKana));

    assertThat(mpu.getUserLastNameAlpha(), is(lastNameAlpha));
    assertThat(mpu.getUserFirstNameAlpha(), is(firstNameAlpha));

    assertThat(mpu.getUserEmailAddress1(), is(email1));
    assertThat(mpu.getUserEmailAddress2(), is(email2));

    assertThat(mpu.getExtensionNo(), is(extensionNo));
    assertThat(mpu.getHomeNo(), is(homeNo));
    assertThat(mpu.getMobilePhoneNo(), is(mobilePhoneNo));
    assertThat(mpu.getFaxNo(), is(faxNo));

    assertThat(mpu.getZipcd3(), is(zipCd3));
    assertThat(mpu.getZipcd4(), is(zipCd4));

    assertThat(mpu.getAddress(), is(address));
    assertThat(mpu.getAddressKana(), is(addressKana));

    assertThat(mpu.getJobCd(), is(jobCd));
    assertThat(mpu.getAdministrator(), is(administrator));

    assertThat(mpu.getIsDisp(), is(isDisp));
    assertThat(mpu.getIsDel(), is(isDel));

    assertThat(mpu.getInHospitalCd_1(), is(hospCd1));
    assertThat(mpu.getInHospitalCd_2(), is(hospCd2));

    assertThat(mpu.getInfoDispToAdmin(), is(infoDispToAdmin));
    assertThat(mpu.getAnesthesiologistLicenseNo(), is(anesthesiologistNo));
  }

  private void assertMstUserAuthentication(MstUserAuthentication mua,
                                           String dispUserId, String password, Integer failureCnt) {
    assertThat(mua.getDispUserId(), is(dispUserId));

    // BCryptPasswordEncoder#encode()はハッシュ化であり、同じ引数に対して常に同じ値を返すとは限らない。
    // （パスワードの「暗号化」（復号可能）ではない。）
    // そのため、nullでない、
    assertTrue(isRight(password, mua.getUserPassword()));
    assertThat(mua.getFailureCnt(), is(failureCnt));
  }

  private void assertMstUser(MstUser mu,
                             Integer isDispMenu, Integer fontSize,
                             Integer theme, Integer isSplitFrame,
                             int isProvisional, String isDisp, String isDel,
                             String idFilter, String nameFilter, String condition,
                             String secretKey,
                             String isSetQrCode, String cardIdm,
                             int isConsent, String consentDate) throws IOException {
    MstUser.UserSettings userSettings = mu.getUserSettings();
    assertThat(userSettings.getIsDispMenu(), is(isDispMenu));
    assertThat(userSettings.getFontSize(), is(fontSize));
    assertThat(userSettings.getTheme(), is(theme));
    assertThat(userSettings.getIsSplitFrame(), is(isSplitFrame));

    assertThat(mu.getIsProvisional(), is(isProvisional));
    assertThat(mu.getIsDisp(), is(isDisp));
    assertThat(mu.getIsDel(), is(isDel));

    String tmpLogSearchCondition = mu.getTmpLogSearchCondition();

    List<Map<String, Object>> l = ObjectMapperUtil.readListOfMap(tmpLogSearchCondition);
    Map<String, Object> m = l.get(0);

    assertThat(m.get("idFilter"), is(idFilter));
    assertThat(m.get("nameFilter"), is(nameFilter));
    assertThat(m.get("condition"), is(condition));

    assertThat(mu.getSecretKey(), is(secretKey));
    assertThat(null, is(cardIdm));
    assertThat(mu.getIsConsent(), is(isConsent));
    assertThat(mu.getConsentDate(), is(Timestamp.valueOf(consentDate)));

  }

  private boolean isRight(String password, String encoded) {
    PasswordEncoder encoder = new BCryptPasswordEncoder();
    return encoder.matches(password, encoded);
  }

}
