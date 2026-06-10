package jp.co.nikkiso.ntss.web_api;

import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PROC_CLASS_CANCEL;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PROC_CLASS_EXPIRE;
import static org.assertj.core.api.Assertions.fail;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.junit.Assert.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.SpyBean;
import org.springframework.http.MediaType;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.core.dao.MntFacilityCancelManageDao;
import jp.co.nikkiso.ntss.core.entity.MntFacilityCancelManage;
import jp.co.nikkiso.ntss.web_api.request.FacilityCancelRequest;

/**
 * 施設解約と期間外削除が混在する場合のUTクラス。
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
public class FacilityCancelExpireMixTest extends AbstractResourceTest {

  @SpyBean
  private MntFacilityCancelManageDao mntFacilityCancelManageDao;

  @Sql("classpath:resource.script/FacilityCancelExpireMixTest/s312200/db5.sql")
  @Test
  public void 混在_正常系_登録_1_同一施設の施設解約_期間外削除_の順に実行してもエラーにならない() {
    final String FACILITY_CD = "312200";

    try {
      // 登録前のDB内容検証
      // 施設コードに対応するレコードが存在しない。
      MntFacilityCancelManage mfcm11 = mntFacilityCancelManageDao.selectByFacilityCd(FACILITY_CD, PROC_CLASS_CANCEL);
      assertThat(mfcm11, nullValue());

      MntFacilityCancelManage mfcm12 = mntFacilityCancelManageDao.selectByFacilityCd(FACILITY_CD, PROC_CLASS_EXPIRE);
      assertThat(mfcm12, nullValue());

      // 施設解約を登録
      ResultActions response1 = requestConversionByFacilityCd("cancel", "register", FACILITY_CD,
          LocalDate.now().format(DateTimeFormatter.ofPattern("uuuuMMdd")), null, null);
      response1.andExpect(status().isOk());

      // 施設解約登録後の管理レコードの検証
      // 施設解約のレコードが作成される。
      MntFacilityCancelManage mfcm21 = mntFacilityCancelManageDao.selectByFacilityCd(FACILITY_CD, PROC_CLASS_CANCEL);
      assertThat(mfcm21, notNullValue());

      // 期間外削除のレコードは存在しない。
      MntFacilityCancelManage mfcm22 = mntFacilityCancelManageDao.selectByFacilityCd(FACILITY_CD, PROC_CLASS_EXPIRE);
      assertThat(mfcm22, nullValue());

    } catch (Exception e) {
      fail("", e);
    }
  }

  @Sql("classpath:resource.script/FacilityCancelExpireMixTest/s312201/db5.sql")
  @Test
  public void 混在_正常系_登録_2_同一施設の期間外削除_施設解約の順に実行してもエラーにならない() {
    final String FACILITY_CD = "312201";

    try {
      // 登録前のDB内容検証
      // 施設コードに対応するレコードが存在しない。
      MntFacilityCancelManage mfcm11 = mntFacilityCancelManageDao.selectByFacilityCd(FACILITY_CD, PROC_CLASS_CANCEL);
      assertThat(mfcm11, nullValue());

      MntFacilityCancelManage mfcm12 = mntFacilityCancelManageDao.selectByFacilityCd(FACILITY_CD, PROC_CLASS_EXPIRE);
      assertThat(mfcm12, nullValue());

      // 施設解約を登録
      ResultActions response2 = requestConversionByFacilityCd("cancel", "register", FACILITY_CD,
          LocalDate.now().format(DateTimeFormatter.ofPattern("uuuuMMdd")), null, null);
      response2.andExpect(status().isOk());

      // 施設解約登録後の管理レコードの検証
      // 施設解約のレコードが作成される。
      MntFacilityCancelManage mfcm31 = mntFacilityCancelManageDao.selectByFacilityCd(FACILITY_CD, PROC_CLASS_CANCEL);
      assertThat(mfcm31, notNullValue());

      MntFacilityCancelManage mfcm32 = mntFacilityCancelManageDao.selectByFacilityCd(FACILITY_CD, PROC_CLASS_EXPIRE);
      assertThat(mfcm32, nullValue());

    } catch (Exception e) {
      fail("", e);
    }
  }

  /**
   * リクエストを発行する。
   *
   * @param function 機能（施設解約=cancel、期間外削除=expire）
   * @param command 処理
   * @param facilityCd 施設コード
   * @param baseDate 解約基準日
   * @param ctlNo 管理番号
   * @param expiration 実行時間上限
   * @return 処理応答結果
   * @throws Exception
   */
  private ResultActions requestConversionByFacilityCd(String function, String command, String facilityCd,
      String baseDate, Long ctlNo, Long expiration)
      throws Exception {
    FacilityCancelRequest req = new FacilityCancelRequest();
    req.setFacilityCd(facilityCd);
    req.setBaseDate(baseDate);
    req.setExpiration(expiration);
    req.setCtlNo(ctlNo);
    req.setProcClass(PROC_CLASS_CANCEL);

    String requestPath = String.format("/facility/%s/%s/", function, command);
    String reqStr = ObjectMapperUtil.write(req);
    return mockMvc.perform(post(requestPath)
        .content(reqStr).contentType(MediaType.APPLICATION_JSON));
  }
}
