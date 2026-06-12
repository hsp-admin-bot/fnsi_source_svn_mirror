package jp.co.nikkiso.ntss.coop_api.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.fail;

import java.io.UnsupportedEncodingException;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoSpyBean;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.coop_api.response.JournalConvertResult.ResultMap;
import jp.co.nikkiso.ntss.core.dao.MstCoopLayoutDao;
import jp.co.nikkiso.ntss.core.dao.SysCoopJournalDao;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import lombok.extern.slf4j.Slf4j;

@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:resource.script/ConvertCsvServiceImplTest/ConvertServiceImplTest.db5.before.sql")
@Sql("classpath:resource.script/ConvertCsvServiceImplTest/repeat.sql")
@Slf4j
public class ConvertCsvServiceImplTest {

  @MockitoSpyBean
  ConvertCsvServiceImpl convertCsvServiceImpl;

  @MockitoSpyBean
  SysCoopJournalDao sysCoopJournalDao;

  @MockitoSpyBean
  MstCoopLayoutDao mstCoopLayoutDao;

  @Test
  public void 正常系_csv電文_ジャーナルが正常に変換される() {

    try {
      SysCoopJournal journal = sysCoopJournalDao.select("21", "21", "21", "C", "R");
      byte[] telegram = journal.getDump();
      log.debug("telegram=[{}]", telegram);

      ResultMap keyResult = new ResultMap();

      ResultMap result = convertCsvServiceImpl.convert("21", "R", "21", "21", "pre","","", telegram,
        keyResult);
      ResultMap expected = createExpectation("C", "22", "00000");

      assertThat(result).isEqualTo(expected);
    } catch (UnsupportedEncodingException e) {
      fail("");
    }
  }

  @Test
  public void 正常系_csv電文_項目がクォートされている場合でもジャーナルが正常に変換される() {

    try {
      SysCoopJournal journal = sysCoopJournalDao.select("22", "22", "22", "U", "R");
      byte[] telegram = journal.getDump();

      ResultMap keyResult = new ResultMap();

      ResultMap result = convertCsvServiceImpl.convert("22", "R", "22", "22", "pre","","", telegram,
        keyResult);
      ResultMap expected = createExpectation("U", "33", "00001");

      assertThat(result).isEqualTo(expected);
    } catch (UnsupportedEncodingException e) {
      fail("");
    }
  }

  private ResultMap createExpectation(String s1, String s2, String s3) {
    ResultMap rm = new ResultMap();
    rm.put("table_1.column_1", s1);
    rm.put("table_2.column_2", s2);
    rm.put("table_3.column_3", s3);

    return rm;
  }
}
