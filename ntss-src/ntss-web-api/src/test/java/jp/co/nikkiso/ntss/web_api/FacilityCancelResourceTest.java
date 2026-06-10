package jp.co.nikkiso.ntss.web_api;

import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PATH_PARAM_DATE;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PATH_PARAM_DB_NAME;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PATH_PARAM_FACILITY_CD;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PATH_PARAM_TABLE_NAME;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PROC_CLASS_CANCEL;
import static org.assertj.core.api.Assertions.fail;
import static org.hamcrest.CoreMatchers.not;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.junit.Assert.assertThat;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.doThrow;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Date;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.SpyBean;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlConfig;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.DataSourceName;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.TransactionManagerName;
import jp.co.nikkiso.ntss.core.dao.MntFacilityCancelManageDao;
import jp.co.nikkiso.ntss.core.dao.MstPatHashDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.entity.MntFacilityCancelManage;
import jp.co.nikkiso.ntss.core.entity.MstPatHash;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.web_api.config.FacilityCancelConfig;
import jp.co.nikkiso.ntss.web_api.request.FacilityCancelRequest;
import jp.co.nikkiso.ntss.web_api.service.component.ProcStatusComponent;
import jp.co.nikkiso.ntss.web_api.service.component.SubTransactionComponent;
import jp.co.nikkiso.ntss.web_api.util.ClockWrapper;
import jp.co.nikkiso.ntss.web_api.util.FacilityCancelStatUtil;

/**
 * 施設解約のUTクラス。
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
public class FacilityCancelResourceTest extends AbstractResourceTest {

  @SpyBean
  private MntFacilityCancelManageDao mntFacilityCancelManageDao;

  @SpyBean
  private MstPatHashDao mstPatHashDao;

  @SpyBean
  private PatMainDao patMainDao;

  @Autowired
  private JdbcTemplate jdbcTemplateAuth;

  @Autowired
  private JdbcTemplate jdbcTemplate;

  @Autowired
  private JdbcTemplate jdbcTemplatePersonal;

  // トランザクション制御コンポーネント
  /** サブトランザクション処理 */
  @SpyBean
  private SubTransactionComponent subTransactionComponent;

  /** 処理ステータス更新 */
  @SpyBean
  private ProcStatusComponent procStatusComponent;

  @Autowired
  private ClockWrapper clockWrapper;

  @SpyBean
  private FacilityCancelConfig config;

  @Rule
  public TemporaryFolder tempFolder = new TemporaryFolder();

  @Sql("classpath:resource.script/FacilityCancelResourceTest/s112200/db5.sql")
  @Test
  public void 施設解約_正常系_登録_1_管理レコードが登録される() {
    final String FACILITY_CD = "112200";

    // 施設コード別名カラムのスタブ
    getIncludeTableList();

    try {
      // 登録前のDB内容検証
      // 施設コードに対応するレコードが存在しない。
      MntFacilityCancelManage mfcm1 = mntFacilityCancelManageDao.selectByFacilityCd(FACILITY_CD, PROC_CLASS_CANCEL);
      assertThat(mfcm1, nullValue());

      ResultActions response = requestConversionByFacilityCd("register", FACILITY_CD,
          LocalDate.now().format(DateTimeFormatter.ofPattern("uuuuMMdd")), null, null);
      response.andExpect(status().isOk());
      response.andExpect(content().string(String.format("施設解約を登録しました。 施設コード:[%s]", FACILITY_CD)));

      // 登録後のDB内容検証
      // 施設コードに対応するレコードが登録される。
      MntFacilityCancelManage mfcm2 = mntFacilityCancelManageDao.selectByFacilityCd(FACILITY_CD, PROC_CLASS_CANCEL);
      assertThat(mfcm2, notNullValue());
      // 処理区分=1（施設解約）
      assertThat(mfcm2.getProcClass(), is("1"));
      assertThat(mfcm2.getProcStatus(), is("0"));

      // 統計情報の登録確認
      List<Map<String, Object>> list = getStatsList(mfcm2.getStats());
      // exclude_table_listの確認
      // 施設解約管理は設定されていないこと
      Map<String, Object> mfcm = FacilityCancelStatUtil.findStat(list, "db5", "mnt_facility_cancel_manage");
      assertThat(mfcm, nullValue());
      // exclude_table_listに設定されていても、除外されないこと
      Map<String, Object> mua = FacilityCancelStatUtil.findStat(list, "db4", "mst_user_authentication");
      assertRegisterStats(mua);
      // exclude_table_listに設定されていても、除外されないこと
      Map<String, Object> muh = FacilityCancelStatUtil.findStat(list, "db4", "mst_facility_hash");
      assertRegisterStats(muh);

      // スキーマ設定から取得 ※抜粋
      Map<String, Object> mph = FacilityCancelStatUtil.findStat(list, "db4", "mst_pat_hash");
      assertRegisterStats(mph);
      Map<String, Object> ppm = FacilityCancelStatUtil.findStat(list, "db6", "pat_personal_main");
      assertRegisterStats(ppm);

      // 別名カラム設定確認
      Map<String, Object> alias = FacilityCancelStatUtil.findStat(list, "db5", "test_table");
      assertThat(alias, notNullValue());
      assertThat((Integer)alias.get("db_class"), is(2));
      assertThat((String)alias.get("db_name"), is("db5"));
      assertThat((String)alias.get("table_name"), is("test_table"));
      assertThat(alias.get("time_column_name"), nullValue());
      assertThat((String)alias.get("alias_column_name"), is("facility_cd_2"));

    } catch (Exception e) {
      fail("", e);
    }
  }

  @Test
  public void 施設解約_異常系_登録_E1_施設コードを指定していない時はBAD_REQUESTが返される() {
    try {
      ResultActions response = requestConversionByFacilityCd("register", null,
          LocalDate.now().format(DateTimeFormatter.ofPattern("uuuu/MM/dd")), null, null);
      response.andExpect(status().isBadRequest());
      response.andExpect(content().string("施設コードが指定されていません。"));
    } catch (Exception e) {
      fail("", e);
    }
  }

  @Test
  public void 施設解約_異常系_登録_E2_解約基準日を指定していない時はBAD_REQUESTが返される() {
    final String FACILITY_CD = "112292";

    try {
      ResultActions response = requestConversionByFacilityCd("register", FACILITY_CD,
          null, null, null);
      response.andExpect(status().isBadRequest());
      response.andExpect(content().string("解約基準日が指定されていません。"));
    } catch (Exception e) {
      fail("", e);
    }
  }

  @Sql("classpath:resource.script/FacilityCancelResourceTest/s112213/db5.sql")
  @Test
  public void 施設解約_異常系_登録_E3_登録済の施設コードを指定した時はINTERNAL_SERVER_ERRORが返される() {
    final String FACILITY_CD = "112213";

    try {
      // 施設解約を登録する。（これは成功する。）
      ResultActions response1 = requestConversionByFacilityCd("register", FACILITY_CD,
          LocalDate.now().format(DateTimeFormatter.ofPattern("uuuu-MM-dd")), null, null);
      response1.andExpect(status().isOk());

      // 同じ施設コードで施設解約を登録する。
      ResultActions response2 = requestConversionByFacilityCd("register", FACILITY_CD,
          LocalDate.now().format(DateTimeFormatter.ofPattern("uuuuMMdd")), null, null);
      response2.andExpect(status().isInternalServerError());
      response2.andExpect(content().string("指定された施設コードはすでに解約登録されています。 施設コード:[" + FACILITY_CD + "]"));
    } catch (Exception e) {
      fail("", e);
    }
  }

  @Test
  public void 施設解約_異常系_登録_E4_DBエラーが発生した時はINTERNAL_SERVER_ERRORが返される() {
    final String FACILITY_CD = "112214";

    doInsertError();

    try {
      // 施設解約を登録する。
      ResultActions response1 = requestConversionByFacilityCd("register", FACILITY_CD,
          LocalDate.now().format(DateTimeFormatter.ofPattern("uuuuMMdd")), null, null);
      response1.andExpect(status().isInternalServerError());
    } catch (Exception e) {
      fail("", e);
    }
  }

  @Sql("classpath:resource.script/FacilityCancelResourceTest/s112300/db5.sql")
  @Test
  public void 施設解約_正常系_バックアップ_1_バックアップファイルが作成される() {
    final String FACILITY_CD = "112300";

    // 作成されるバックアップファイルのパスをUTシナリオごとに分ける。
    setBackupPath(FACILITY_CD);

    try {
      // 施設解約を登録する。
      ResultActions response1 = requestConversionByFacilityCd("register", FACILITY_CD,
          LocalDate.now().format(DateTimeFormatter.ofPattern("uuuuMMdd")), null, null);
      response1.andExpect(status().isOk());

      // バックアップファイルを作成する。
      ResultActions response2 = requestConversionByFacilityCd("backup", null,
          null, null, 120L);
      response2.andExpect(status().isOk());

      // DB内容検証
      // (1) mnt_facility_cancel_manage
      MntFacilityCancelManage mfcm1 = mntFacilityCancelManageDao.selectByFacilityCd(FACILITY_CD, PROC_CLASS_CANCEL);
      assertThat(mfcm1, notNullValue());
      assertThat(mfcm1.getProcStatus(), is("2"));

      // 統計情報の検証
      List<Map<String, Object>> list = getStatsList(mfcm1.getStats());
      // バックアップ作成した場合
      Map<String, Object> m = FacilityCancelStatUtil.findStat(list, "db5", "pat_main");
      assertBackupStats(m, 10);
      // データなしの場合(バックアップ未作成)
      m = FacilityCancelStatUtil.findStat(list, "db5", "mst_coop_facility");
      assertBackupStats(m, 0);

      // (2) pat_main
      final String COUNT_QUERY = "SELECT COUNT(*) FROM %s WHERE facility_cd = ?";
      int patMainCount1 = jdbcTemplate.queryForObject(
          String.format(COUNT_QUERY, "pat_main"), Integer.class, FACILITY_CD);
      assertThat(patMainCount1, is(10));

      // バックアップファイル検証
      // レコードはctidの昇順で出力されるため順不同である。
      // ファイルの存在と行数のみチェックする。
      String backupFilePath = getBackupFileName(FACILITY_CD, "ntsstest_db5", "pat_main");
      assertFile(backupFilePath, 11L);
    } catch (Exception e) {
      fail("", e);
    }
  }

  @Sql("classpath:resource.script/FacilityCancelResourceTest/s112301/db5.sql")
  @Test
  public void 施設解約_異常系_バックアップ_E1_エラーが発生した場合処理ステータスにEが設定される() {
    final String FACILITY_CD = "112301";

    setBackupPath(FACILITY_CD);
    doBackupError();

    try {
      // 施設解約を登録する。
      ResultActions response1 = requestConversionByFacilityCd("register", FACILITY_CD,
          LocalDate.now().format(DateTimeFormatter.ofPattern("uuuuMMdd")), null, null);
      response1.andExpect(status().isOk());

      // バックアップファイルを作成する。
      ResultActions response2 = requestConversionByFacilityCd("backup", null,
          null, null, 120L);
      response2.andExpect(status().isInternalServerError());

      // DB内容検証
      // mnt_facility_cancel_manage
      MntFacilityCancelManage mfcm1 = mntFacilityCancelManageDao.selectByFacilityCd(FACILITY_CD, PROC_CLASS_CANCEL);
      assertThat(mfcm1, notNullValue());
      assertThat(mfcm1.getProcStatus(), is("E"));
    } catch (Exception e) {
      fail("", e);
    }
  }

  @Sql(value = "classpath:resource.script/FacilityCancelResourceTest/s113300/db4.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/FacilityCancelResourceTest/s113300/db5.sql")
  @Sql(value = "classpath:resource.script/FacilityCancelResourceTest/s113300/db6.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Test
  public void 施設解約_正常系_実行_1_対象レコードが物理削除される() {
    final String FACILITY_CD = "113300";

    // 作成されるバックアップファイルのパスをUTシナリオごとに分ける。
    setBackupPath(FACILITY_CD);

    try {
      // 施設解約登録
      ResultActions response1 = requestConversionByFacilityCd("register", FACILITY_CD,
          LocalDate.now().format(DateTimeFormatter.ofPattern("uuuuMMdd")), null, null);
      response1.andExpect(status().isOk());

      // 解約実行前のDB内容検証
      // 削除対象テーブルにレコードが1件以上存在する。
      MstPatHash mstPatHash1 = mstPatHashDao.selectByFacilityCd(FACILITY_CD);
      assertThat(mstPatHash1, notNullValue());

      List<PatMain> patMainList1 = patMainDao.selectByCdList(Arrays.asList(FACILITY_CD));
      assertThat(patMainList1, notNullValue());
      assertThat(patMainList1.size(), is(5));

      // pat_insuranceは施設コードのみで横断的に取得するクエリが存在しないため、JdbcTemplate経由でレコード件数を取得する。
      final String COUNT_QUERY = "SELECT COUNT(*) FROM %s WHERE facility_cd = ?";

      int patInsuranceCount1 = jdbcTemplatePersonal.queryForObject(
          String.format(COUNT_QUERY, "pat_insurance"), Integer.class, FACILITY_CD);
      assertThat(patInsuranceCount1, is(6));

      // バックアップ
      ResultActions response2 = requestConversionByFacilityCd("backup", null,
          null, null, 120L);
      response2.andExpect(status().isOk());

      // バックアップファイル検証
      String pathPatHash = getBackupFileName(FACILITY_CD, "ntsstest_db4", "mst_pat_hash");
      assertFile(pathPatHash, 2L);

      String pathPatMain = getBackupFileName(FACILITY_CD, "ntsstest_db5", "pat_main");
      assertFile(pathPatMain, 6L);

      String pathPatInsurance = getBackupFileName(FACILITY_CD, "ntsstest_db6", "pat_insurance");
      assertFile(pathPatInsurance, 7L);

      // 施設解約実行
      // 注: 施設解約実行は登録されているすべての施設にまたがって実行される。
      // そのため、Rollback(false)、かつ、施設解約を実行するシナリオが後で実行されると、他のシナリオで登録した
      // 施設解約も実行され、処理ステータスも9に更新される。
      // 結果として、UTシナリオで処理ステータスを検証している場合、検証結果とUT終了後のDB内容が異なることがある。
      ResultActions response3 = requestConversionByFacilityCd("execute", null, null, null, 5L);
      response3.andExpect(status().isOk());

      // 解約実行後のDB内容検証
      // DAO経由では物理削除と論理削除を区別できないため、すべてJdbcTemplate経由でレコード件数を取得する。
      int mstPatHashCount3 = jdbcTemplateAuth.queryForObject(
          String.format(COUNT_QUERY, "mst_pat_hash"), Integer.class, FACILITY_CD);
      assertThat(mstPatHashCount3, is(0));

      int patMainCount3 = jdbcTemplate.queryForObject(
          String.format(COUNT_QUERY, "pat_main"), Integer.class, FACILITY_CD);
      assertThat(patMainCount3, is(0));

      int patInsuranceCount3 = jdbcTemplatePersonal.queryForObject(
          String.format(COUNT_QUERY, "pat_insurance"), Integer.class, FACILITY_CD);
      assertThat(patInsuranceCount3, is(0));

    } catch (Exception e) {
      fail("", e);
    }
  }

  @Sql(value = "classpath:resource.script/FacilityCancelResourceTest/s113301/db4.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/FacilityCancelResourceTest/s113301/db5.sql")
  @Sql(value = "classpath:resource.script/FacilityCancelResourceTest/s113301/db6.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Test
  public void 施設解約_正常系_実行_2_処理ステータスが9に更新される() {
    final String FACILITY_CD = "113301";

    setBackupPath(FACILITY_CD);

    try {
      // 施設解約登録
      ResultActions response1 = requestConversionByFacilityCd("register", FACILITY_CD,
          LocalDate.now().format(DateTimeFormatter.ofPattern("uuuuMMdd")), null, null);
      response1.andExpect(status().isOk());

      // 解約実行前のDB内容検証
      // 管理レコードが登録されており、処理ステータスが"0"である。
      MntFacilityCancelManage mfcm1 = mntFacilityCancelManageDao.selectByFacilityCd(FACILITY_CD, PROC_CLASS_CANCEL);
      assertThat(mfcm1, notNullValue());
      assertThat(mfcm1.getProcStatus(), is("0"));

      // バックアップ
      ResultActions response2 = requestConversionByFacilityCd("backup", null, null, null, 120L);
      response2.andExpect(status().isOk());

      // バックアップ後のDB内容検証
      MntFacilityCancelManage mfcm2 = mntFacilityCancelManageDao.selectByFacilityCd(FACILITY_CD, PROC_CLASS_CANCEL);
      assertThat(mfcm2, notNullValue());
      assertThat(mfcm2.getProcStatus(), is("2"));

      // 施設解約実行
      ResultActions response3 = requestConversionByFacilityCd("execute", null, null, null, 5L);
      response3.andExpect(status().isOk());

      // 解約実行後のDB内容検証
      // 処理ステータスが"9"に更新される。
      MntFacilityCancelManage mfcm3 = mntFacilityCancelManageDao.selectByFacilityCd(FACILITY_CD, PROC_CLASS_CANCEL);
      assertThat(mfcm3, notNullValue());
      assertThat(mfcm3.getProcStatus(), is("9"));

      // 統計情報の検証
      List<Map<String, Object>> list = getStatsList(mfcm3.getStats());
      Map<String, Object> mph = FacilityCancelStatUtil.findStat(list, "db4", "mst_pat_hash");
      Map<String, Object> pm = FacilityCancelStatUtil.findStat(list, "db5", "pat_main");
      Map<String, Object> pi = FacilityCancelStatUtil.findStat(list, "db6", "pat_insurance");
      assertExecuteStats(mph, 1);
      assertExecuteStats(pm, 5);
      assertExecuteStats(pi, 6);

    } catch (Exception e) {
      fail("", e);
    }
  }

  @Sql(value = "classpath:resource.script/FacilityCancelResourceTest/s113302/db4.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/FacilityCancelResourceTest/s113302/db5.sql")
  @Sql(value = "classpath:resource.script/FacilityCancelResourceTest/s113302/db6.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/FacilityCancelResourceTest/s113303/db4.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/FacilityCancelResourceTest/s113303/db5.sql")
  @Sql(value = "classpath:resource.script/FacilityCancelResourceTest/s113303/db6.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Test
  public void 施設解約_正常系_実行_3_解約基準日を迎えていない施設は削除されない() {
    // このシナリオは2つの施設コードを使用する。
    // シナリオ追加時には施設コードやプライマリキーが衝突しないよう注意すること。
    final String FACILITY_CD_1 = "113302";
    final String FACILITY_CD_2 = "113303";

    // シナリオ番号は113302とする。
    setBackupPath(FACILITY_CD_1);

    // レコード件数取得クエリ
    final String COUNT_QUERY = "SELECT COUNT(*) FROM %s WHERE facility_cd = ?";

    try {
      // 施設解約登録

      // 施設1; 1週間後を指定して解約予約
      ResultActions response1 = requestConversionByFacilityCd("register", FACILITY_CD_1,
          LocalDate.now().plusWeeks(1).format(DateTimeFormatter.ofPattern("uuuuMMdd")), null, null);
      response1.andExpect(status().isOk());

      // 施設2; 即時
      ResultActions response2 = requestConversionByFacilityCd("register", FACILITY_CD_2,
          LocalDate.now().format(DateTimeFormatter.ofPattern("uuuuMMdd")), null, null);
      response2.andExpect(status().isOk());

      // バックアップ
      ResultActions response3 = requestConversionByFacilityCd("backup", null, null, null, 120L);
      response3.andExpect(status().isOk());

      // 施設解約実行
      ResultActions response4 = requestConversionByFacilityCd("execute", null, null, null, 5L);
      response4.andExpect(status().isOk());

      // 施設1の結果確認
      // mnt_facility_cancel_manage: 解約基準日に到達していないため、解約は実行されない。（処理ステータス=処理待機）
      MntFacilityCancelManage mfcm1 = mntFacilityCancelManageDao.selectByFacilityCd(FACILITY_CD_1, PROC_CLASS_CANCEL);
      assertThat(mfcm1, notNullValue());
      assertThat(mfcm1.getProcStatus(), is("0"));

      // 削除対象テーブルの内容の検証
      // 削除が実行されていない。
      int mstPatHashCount1 = jdbcTemplateAuth.queryForObject(
          String.format(COUNT_QUERY, "mst_pat_hash"), Integer.class, FACILITY_CD_1);
      assertThat(mstPatHashCount1, is(1));

      int patMainCount1 = jdbcTemplate.queryForObject(
          String.format(COUNT_QUERY, "pat_main"), Integer.class, FACILITY_CD_1);
      assertThat(patMainCount1, is(5));

      int patInsuranceCount1 = jdbcTemplatePersonal.queryForObject(
          String.format(COUNT_QUERY, "pat_insurance"), Integer.class, FACILITY_CD_1);
      assertThat(patInsuranceCount1, is(6));

      // 施設2の結果確認
      // mnt_facility_cancel_manage: 解約が実行される。（処理ステータス=完了）
      MntFacilityCancelManage mfcm2 = mntFacilityCancelManageDao.selectByFacilityCd(FACILITY_CD_2, PROC_CLASS_CANCEL);
      assertThat(mfcm2, notNullValue());
      assertThat(mfcm2.getProcStatus(), is("9"));

      // 削除対象テーブルの内容の検証
      // すべて削除済であり、0件となる。
      int mstPatHashCount2 = jdbcTemplateAuth.queryForObject(
          String.format(COUNT_QUERY, "mst_pat_hash"), Integer.class, FACILITY_CD_2);
      assertThat(mstPatHashCount2, is(0));

      int patMainCount2 = jdbcTemplate.queryForObject(
          String.format(COUNT_QUERY, "pat_main"), Integer.class, FACILITY_CD_2);
      assertThat(patMainCount2, is(0));

      int patInsuranceCount2 = jdbcTemplatePersonal.queryForObject(
          String.format(COUNT_QUERY, "pat_insurance"), Integer.class, FACILITY_CD_2);
      assertThat(patInsuranceCount2, is(0));

    } catch (Exception e) {
      fail("", e);
    }
  }

  @Sql("classpath:resource.script/FacilityCancelResourceTest/s113490/db5.sql")
  @Test
  public void 施設解約_正常系_実行_4_削除対象レコードの順序考慮がされていること() {
    final String FACILITY_CD = "113490";

    setBackupPath(FACILITY_CD);
    // 優先順位のスタブ
    getPriorityTableList();

    try {
      // 施設解約登録
      ResultActions response1 = requestConversionByFacilityCd("register", FACILITY_CD,
          LocalDate.now().format(DateTimeFormatter.ofPattern("uuuuMMdd")), null, null);
      response1.andExpect(status().isOk());

      // 解約実行前のDB内容検証
      // 管理レコードが登録されており、処理ステータスが"0"である。
      MntFacilityCancelManage mfcm1 = mntFacilityCancelManageDao.selectByFacilityCd(FACILITY_CD, PROC_CLASS_CANCEL);
      assertThat(mfcm1, notNullValue());
      assertThat(mfcm1.getProcStatus(), is("0"));

      // バックアップ
      ResultActions response2 = requestConversionByFacilityCd("backup", null, null, null, 120L);
      response2.andExpect(status().isOk());

      // バックアップ後のDB内容検証
      MntFacilityCancelManage mfcm2 = mntFacilityCancelManageDao.selectByFacilityCd(FACILITY_CD, PROC_CLASS_CANCEL);
      assertThat(mfcm2, notNullValue());
      assertThat(mfcm2.getProcStatus(), is("2"));

      // 施設解約実行
      ResultActions response3 = requestConversionByFacilityCd("execute", null, null, null, 5L);
      response3.andExpect(status().isOk());

      // 解約実行後のDB内容検証
      // 処理ステータスが"9"に更新される。
      MntFacilityCancelManage mfcm3 = mntFacilityCancelManageDao.selectByFacilityCd(FACILITY_CD, PROC_CLASS_CANCEL);
      assertThat(mfcm3, notNullValue());
      assertThat(mfcm3.getProcStatus(), is("9"));

      // 統計情報の検証
      List<Map<String, Object>> list = getStatsList(mfcm3.getStats());
      Map<String, Object> mr = FacilityCancelStatUtil.findStat(list, "db5", "mst_report");
      assertExecuteStats(mr, 2);

    } catch (Exception e) {
      fail("", e);
    }
  }

  // 実行時間上限は必須としない。未指定の場合はシステムデフォルト値を使用する。
  // そのため、実行時間上限指定なしのUTは実施しない。

  @Test
  public void 施設解約_異常系_実行_E1_実行時間上限が0の時はBAD_REQUESTが返される() {
    try {
      ResultActions response = requestConversionByFacilityCd("execute", null, null, null, 0L);
      response.andExpect(status().isBadRequest());
    } catch (Exception e) {
      fail("", e);
    }
  }

  @Test
  public void 施設解約_異常系_実行_E2_実行時間上限がマイナスの時はBAD_REQUESTが返される() {
    try {
      ResultActions response = requestConversionByFacilityCd("execute", null, null, null, -60L);
      response.andExpect(status().isBadRequest());
    } catch (Exception e) {
      fail("", e);
    }
  }

  @Sql("classpath:resource.script/FacilityCancelResourceTest/s113491/db5.sql")
  @Test
  public void 施設解約_異常系_実行_E3_レコード物理削除でDBエラーが発生した時はINTERNAL_SERVER_ERRORが返される() {
    final String FACILITY_CD = "113491";

    setBackupPath(FACILITY_CD);
    doDeleteError();

    try {
      // 施設解約登録
      ResultActions response1 = requestConversionByFacilityCd("register", FACILITY_CD,
          LocalDate.now().format(DateTimeFormatter.ofPattern("uuuuMMdd")), null, null);
      response1.andExpect(status().isOk());

      // バックアップファイルを作成する。
      ResultActions response2 = requestConversionByFacilityCd("backup", null, null, null, 120L);
      response2.andExpect(status().isOk());

      // 施設解約実行（解約施設の削除時にDBエラーが発生する）
      ResultActions response3 = requestConversionByFacilityCd("execute", null, null, null, 120L);
      response3.andExpect(status().isInternalServerError());

      // バックアップ後のDB内容検証
      MntFacilityCancelManage mfcm3 = mntFacilityCancelManageDao.selectByFacilityCd(FACILITY_CD, PROC_CLASS_CANCEL);
      assertThat(mfcm3, notNullValue());
      assertThat(mfcm3.getProcStatus(), is("E"));
    } catch (Exception e) {
      fail("", e);
    }
  }

  // 施設解約の実行はリクエストパラメータを持たない。
  // そのため、実行のBAD REQUEST試験は存在しない。

  @Sql("classpath:resource.script/FacilityCancelResourceTest/s114400/db5.sql")
  @Test
  public void 施設解約_正常系_キャンセル_1_処理ステータスがCに更新される() {
    final String FACILITY_CD = "114400";

    try {
      // 施設解約登録
      ResultActions response1 = requestConversionByFacilityCd("register", FACILITY_CD,
          LocalDate.now().format(DateTimeFormatter.ofPattern("uuuuMMdd")), null, null);
      response1.andExpect(status().isOk());

      // 登録されたmnt_facility_cancel_manageレコードを取得する
      MntFacilityCancelManage mfcm1 = mntFacilityCancelManageDao.selectByFacilityCd(FACILITY_CD, PROC_CLASS_CANCEL);
      Long ctlNo1 = mfcm1.getCtlNo();
      assertThat(ctlNo1, notNullValue());

      // 施設解約キャンセル
      ResultActions response2 = requestConversionByFacilityCd("cancel", FACILITY_CD, null, null, null);
      response2.andExpect(status().isOk());

      // キャンセルによりmnt_facility_cancel_manageレコードのproc_statusが"C"、is_delが"1"に設定される。
      List<Map<String, Object>> mfcmList = jdbcTemplate
          .queryForList("SELECT * FROM mnt_facility_cancel_manage WHERE facility_cd = ?", FACILITY_CD);
      assertThat(mfcmList, notNullValue());
      assertThat(mfcmList.size(), is(1));

      Map<String, Object> mfcm2 = mfcmList.get(0);
      Long ctlNo2 = (Long) mfcm2.get("ctl_no");
      assertThat(ctlNo2, notNullValue());
      assertThat(ctlNo2, is(ctlNo1));
      assertThat(mfcm2.get("proc_status"), is("C"));
      assertThat(mfcm2.get("is_del"), is("1"));
    } catch (Exception e) {
      fail("", e);
    }
  }

  @Sql("classpath:resource.script/FacilityCancelResourceTest/s114401/db5.sql")
  @Test
  public void 施設解約_正常系_キャンセル_2_キャンセル後に再登録すると正常に実行される() {
    final String FACILITY_CD = "114401";

    try {
      // 施設解約登録
      ResultActions response1 = requestConversionByFacilityCd("register", FACILITY_CD,
          LocalDate.now().format(DateTimeFormatter.ofPattern("uuuuMMdd")), null, null);
      response1.andExpect(status().isOk());

      // 施設解約キャンセル
      MntFacilityCancelManage mfcm1 = mntFacilityCancelManageDao.selectByFacilityCd(FACILITY_CD, PROC_CLASS_CANCEL);
      Long ctlNo1 = mfcm1.getCtlNo();
      assertThat(ctlNo1, notNullValue());

      ResultActions response2 = requestConversionByFacilityCd("cancel", FACILITY_CD, null, null, null);
      response2.andExpect(status().isOk());

      // 施設解約登録（再登録）
      ResultActions response3 = requestConversionByFacilityCd("register", FACILITY_CD,
          LocalDate.now().format(DateTimeFormatter.ofPattern("uuuuMMdd")), null, null);
      response3.andExpect(status().isOk());

      // キャンセルにより処理ステータスがCに変更されている。
      // そのため最初の登録とは重複とならず、正常に登録される。

      // 最新の管理レコード
      // （施設コードに対して、管理レコードは最新の1件のみを取得することに注意）
      MntFacilityCancelManage mfcm3 = mntFacilityCancelManageDao.selectByFacilityCd(FACILITY_CD, PROC_CLASS_CANCEL);
      Long ctlNo3 = mfcm3.getCtlNo();
      assertThat(ctlNo3, notNullValue());
      assertThat(ctlNo3, not(is(ctlNo1)));

      // 全管理レコード
      List<Map<String, Object>> mfcmList = jdbcTemplate
          .queryForList("SELECT * FROM mnt_facility_cancel_manage WHERE facility_cd = ? ORDER BY ctl_no", FACILITY_CD);
      assertThat(mfcmList, notNullValue());
      assertThat(mfcmList.size(), is(2));

      // 最初に登録したものは処理ステータスがCに更新される。
      Map<String, Object> m1 = mfcmList.get(0);
      assertThat(m1.get("ctl_no"), is(ctlNo1));
      assertThat(m1.get("facility_cd"), is(FACILITY_CD));
      assertThat(m1.get("proc_status"), is("C"));

      // 再登録したものは処理ステータスが0である。
      Map<String, Object> m2 = mfcmList.get(1);
      assertThat(m2.get("ctl_no"), is(ctlNo3));
      assertThat(m2.get("facility_cd"), is(FACILITY_CD));
      assertThat(m2.get("proc_status"), is("0"));

    } catch (Exception e) {
      fail("", e);
    }
  }

  @Test
  public void 施設解約_異常系_キャンセル_E1_施設コードを指定していない時はBAD_REQUESTが返される() {
    try {
      ResultActions response = requestConversionByFacilityCd("cancel", null, null, null, null);
      response.andExpect(status().isBadRequest());
      response.andExpect(content().string("施設コードが指定されていません。"));
    } catch (Exception e) {
      fail("", e);
    }
  }

  @Test
  public void 施設解約_異常系_キャンセル_E2_施設コードに対応する管理レコードが存在しない時はINTERNAL_SERVER_ERRORが返される() {
    final String FACILITY_CD = "000000";
    try {
      ResultActions response = requestConversionByFacilityCd("cancel", FACILITY_CD, null, null, null);
      response.andExpect(status().isInternalServerError());
      response.andExpect(content().string(String.format("指定された施設コードの管理レコードは存在しません。 施設コード:[%s]", FACILITY_CD)));
    } catch (Exception e) {
      fail("", e);
    }
  }

  @Test
  public void 施設解約_異常系_キャンセル_E3_DBエラーが発生した時はINTERNAL_SERVER_ERRORが返される() {
    final String FACILITY_CD = "000000";
    doCancelError();

    try {
      ResultActions response = requestConversionByFacilityCd("cancel", FACILITY_CD, null, null, null);
      response.andExpect(status().isInternalServerError());
    } catch (Exception e) {
      fail("", e);
    }
  }

  @Test
  public void 施設解約_異常系_キャンセル_E4_既に解約処理が開始されている場合はキャンセル不可() {
    final String FACILITY_CD = "114401";

    try {
      // 施設解約登録
      ResultActions response1 = requestConversionByFacilityCd("register", FACILITY_CD,
          LocalDate.now().format(DateTimeFormatter.ofPattern("uuuuMMdd")), null, null);
      response1.andExpect(status().isOk());

      // 登録結果取得
      MntFacilityCancelManage mfcm1 = mntFacilityCancelManageDao.selectByFacilityCd(FACILITY_CD, PROC_CLASS_CANCEL);
      Long ctlNo1 = mfcm1.getCtlNo();
      assertThat(ctlNo1, notNullValue());

      // バックアップ処理実行
      ResultActions response2 = requestConversionByFacilityCd("backup", FACILITY_CD,
          LocalDate.now().format(DateTimeFormatter.ofPattern("uuuuMMdd")), null, null);
      response2.andExpect(status().isOk());

      // キャンセル処理実行
      ResultActions response3 = requestConversionByFacilityCd("cancel", FACILITY_CD, null, null, null);
      response3.andExpect(status().isInternalServerError());
      response3.andExpect(content().string(String.format("解約処理が実行済のためキャンセルできません。施設コード:[%s]", FACILITY_CD)));

      // 全管理レコード
      List<Map<String, Object>> mfcmList = jdbcTemplate
          .queryForList("SELECT * FROM mnt_facility_cancel_manage WHERE facility_cd = ? ORDER BY ctl_no", FACILITY_CD);
      assertThat(mfcmList, notNullValue());
      assertThat(mfcmList.size(), is(1));

      // キャンセルに更新されていないことを確認
      Map<String, Object> m1 = mfcmList.get(0);
      assertThat(m1.get("ctl_no"), is(ctlNo1));
      assertThat(m1.get("facility_cd"), is(FACILITY_CD));
      assertThat(m1.get("proc_status"), is("2"));

    } catch (Exception e) {
      fail("", e);
    }
  }

  @Test
  public void 施設解約ダウンロード_パラメータ施設コードなし() {
    try {
      // 施設解約ダウンロード
      ResultActions response = requestConversionByFacilityCd("download", "",
          "20200828", null, null);

      response.andExpect(status().is(HttpStatus.BAD_REQUEST.value()));
      response.andExpect(jsonPath("$.message").value("施設コードが指定されていません。"));

    } catch (Exception e) {
      fail("", e);
    }
  }

  @Sql("classpath:resource.script/FacilityCancelResourceTest/s115500/db5.sql")
  @Test
  public void 施設解約ダウンロード_パラメータ解約基準日なし() {
    final String FACILITY_CD = "115500";
    try {
      // 施設解約ダウンロード
      ResultActions response = requestConversionByFacilityCd("download", FACILITY_CD,
          "", null, null);

      response.andExpect(status().is(HttpStatus.BAD_REQUEST.value()));
      response.andExpect(jsonPath("$.message").value("解約基準日が指定されていません。"));

    } catch (Exception e) {
      fail("", e);
    }
  }

  @Sql("classpath:resource.script/FacilityCancelResourceTest/s115500/db5.sql")
  @Test
  public void 施設解約ダウンロード_正常() {
    final String FACILITY_CD = "115500";

    try {

      File testDir = tempFolder.newFolder();
      File testFile = new File(testDir.getAbsolutePath() + File.separator + "test.csv");
      testFile.createNewFile();
      String filepath = testFile.getAbsolutePath().replace("\\", "\\\\");

      MntFacilityCancelManage manage = new MntFacilityCancelManage();
      manage.setFacilityCd(FACILITY_CD);
      manage.setProcClass("1");
      manage.setProcPeriod(1);
      manage.setStDate(Timestamp.valueOf("2020-08-28 00:22:11"));
      manage.setStats("[{\"amount\": 1, \"db_name\": \"ntss_db5\", \"db_class\": 2, \"backup_end\": \"2020-08-26T16:31:04.901+09:00\", \"table_name\": \"mst_report\", \"backup_path\": \""+filepath+"\", \"backup_start\": \"2020-08-26T16:31:04.892+09:00\", \"time_column_name\": null, \"alias_column_name\": null}]");
      manage.setProcStatus("9");
      manage.setIsDisp("1");
      manage.setIsDel("0");
      manage.setRegDate(new Timestamp(clockWrapper.getClockMillis()));
      manage.setUpDate(new Timestamp(clockWrapper.getClockMillis()));

      mntFacilityCancelManageDao.insert(manage);


      // 施設解約ダウンロード
      ResultActions response = requestConversionByFacilityCd("download", FACILITY_CD,
          "20200828", null, null);

      response.andExpect(status().isOk());
      assertThat(content(), notNullValue());
      response.andExpect(content().contentType("application/octet-stream"));

    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
      fail("", e);
    }
  }

  @Test
  public void 施設解約ダウンロード_ダウンロード対象なし() {
    final String FACILITY_CD = "115501";

    try {
      // 施設解約ダウンロード
      ResultActions response = requestConversionByFacilityCd("download", FACILITY_CD,
          "20200828", null, null);

      response.andExpect(status().isOk());
      response.andExpect(jsonPath("$.message").value("ダウンロード対象が存在しません。"));

    } catch (Exception e) {
      fail("", e);
    }

  }

  /**
   * リクエストを発行する。
   *
   * @param command 処理
   * @param facilityCd 施設コード
   * @param baseDate 解約基準日
   * @param ctlNo 管理番号
   * @param expiration 実行時間上限
   * @return 処理応答結果
   * @throws Exception
   */
  private ResultActions requestConversionByFacilityCd(String command, String facilityCd, String baseDate,
      Long ctlNo, Long expiration)
      throws Exception {
    FacilityCancelRequest req = new FacilityCancelRequest();
    req.setFacilityCd(facilityCd);
    req.setBaseDate(baseDate);
    req.setExpiration(expiration);
    req.setCtlNo(ctlNo);
    req.setProcClass(PROC_CLASS_CANCEL);

    String reqStr = ObjectMapperUtil.write(req);
    return mockMvc.perform(post("/facility/cancel/" + command)
        .content(reqStr).contentType(MediaType.APPLICATION_JSON));
  }

  private String getBackupFileName(String facilityCd, String dbName, String tableName) {
    String pathTemplate = config.getBackupPathTemplate("1");
    Long startTime = clockWrapper.getClockMillis();

    return pathTemplate.replace(PATH_PARAM_DATE, getBackupDateTimeStr(startTime))
        .replace(PATH_PARAM_FACILITY_CD, facilityCd)
        .replace(PATH_PARAM_DB_NAME, dbName)
        .replace(PATH_PARAM_TABLE_NAME, tableName);
  }

  private String getBackupDateTimeStr(Long startTime) {
    String format = config.getBackupPathDateFormat();
    SimpleDateFormat sdf = new SimpleDateFormat(format);

    Date d = new Date(startTime);
    return sdf.format(d);
  }

  private void assertFile(String filePath, Long lineCount) throws IOException {
    Path p = Paths.get(filePath);
    assertTrue(Files.exists(p));

    assertThat(Files.lines(p).count(), is(lineCount));
  }

  // モック処理
  private void doInsertError() {
    doThrow(new NtssException("例外テスト"))
        .when(subTransactionComponent)
        .insert(any());
  }

  private void doBackupError() {
    doThrow(new NtssException("例外テスト"))
        .when(subTransactionComponent)
        .backupTableRecord(any(), any(), any(), any(), any());
  }

  private void doDeleteError() {
    doThrow(new NtssException("例外テスト"))
        .when(subTransactionComponent)
        .delete(any(), any(), any(), any(), any(), any(), any());
  }

  private void doCancelError() {
    doThrow(new NtssException("例外テスト"))
        .when(procStatusComponent)
        .updateProcStatus(any(), any());
  }

  private void setBackupPath(String scenarioId) {
    String template = "/tmp/s%SCENARIO_ID%/NTSS_backup_%DATE%/%FACILITY_CD%/%DB_NAME%_%TABLE_NAME%.csv";
    String path = template.replace("%SCENARIO_ID%", scenarioId);
    doReturn(path)
        .when(config)
        .getBackupPathTemplate("1");
  }

  private void getIncludeTableList() {
    List<Map<String, Object>> list = new ArrayList<>();
    Map<String, Object> obj = new HashMap<>();
    obj.put("db_class", 2);
    obj.put("table_name", "test_table");
    obj.put("alias_column_name", "facility_cd_2");
    list.add(obj);
    doReturn(list).when(config).getIncludeTableList();
  }

  private void getPriorityTableList() {
    List<Map<String, Object>> list = new ArrayList<>();
    Map<String, Object> obj = new HashMap<>();
    obj.put("order", 1);
    obj.put("table_name", "mst_report");
    list.add(obj);
    doReturn(list).when(config).getPriorityTableList();
  }


  // 統計情報をリスト化
  private List<Map<String, Object>> getStatsList(String stats) {
    String statsStr = stats;
    List<Map<String, Object>> statsListAll = null;
    try {
      statsListAll = ObjectMapperUtil.readListOfMap(statsStr);
    } catch (IOException e) {
      fail("JSON変換失敗", e);
    }
    return statsListAll;
  }

  /** 登録時の統計情報 */
  private void assertRegisterStats(Map<String, Object> stat) {
    assertThat(stat.get("db_name"), notNullValue());
    assertThat(stat.get("db_class"), notNullValue());
    assertThat(stat.get("table_name"), notNullValue());
    assertThat(stat.get("time_column_name"), nullValue());
    assertThat(stat.get("alias_column_name"), nullValue());
  }

  /** バックアップ実行後の統計情報 */
  private void assertBackupStats(Map<String, Object> stat, int amount) {

    // 取得件数、削除件数のチェック
    assertThat((int)stat.get("amount"), is(amount));

    if (amount != 0) {
      // バックアップ開始、終了
      assertThat(stat.get("backup_start"), notNullValue());
      assertThat(stat.get("backup_end"), notNullValue());
      assertThat(stat.get("backup_path"), notNullValue());
    }
  }

  /** 施設解約実行後の統計情報 */
  private void assertExecuteStats(Map<String, Object> stat, int amount) {

    // 取得件数、削除件数のチェック
    assertThat((int)stat.get("amount"), is(amount));
    assertThat((int)stat.get("deleted"), is(amount));

    if (amount != 0) {
      // バックアップ開始、終了
      assertThat(stat.get("backup_start"), notNullValue());
      assertThat(stat.get("backup_end"), notNullValue());
      assertThat(stat.get("backup_path"), notNullValue());
      // 開始、終了
      assertThat(stat.get("start"), notNullValue());
      assertThat(stat.get("end"), notNullValue());
    }
  }
}
