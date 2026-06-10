package jp.co.nikkiso.ntss.coop_api.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.fail;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.doReturn;

import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.junit.Assert;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.SpyBean;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.response.JournalConvertResult.ResultMap;
import jp.co.nikkiso.ntss.core.dao.MstCoopLayoutDao;
import jp.co.nikkiso.ntss.core.dao.SysCoopJournalDao;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import lombok.extern.slf4j.Slf4j;

@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:resource.script/ConvertTextServiceImplTest/ConvertServiceImplTest.db5.before.sql")
@Sql("classpath:resource.script/ConvertTextServiceImplTest/ConvertServiceImplTest2.db5.before.sql")
@Sql("classpath:resource.script/ConvertTextServiceImplTest/repeat.sql")
@Slf4j
public class ConvertTextServiceImplTest {

  @SpyBean
  ConvertTextServiceImpl convertTextServiceImpl;

  @SpyBean
  SysCoopJournalDao sysCoopJournalDao;

  @SpyBean
  MstCoopLayoutDao mstCoopLayoutDao;

  @Test
  public void 正常系_text電文_ジャーナルが正常に変換される() {
    SysCoopJournal journal = sysCoopJournalDao.select("1", "1", "1", "C", "R");
    byte[] telegram = journal.getDump();

    try {
      ResultMap keyResult = new ResultMap();
      ResultMap result = convertTextServiceImpl.convert("1", "R", "1", "1", "pre","","", telegram,
        keyResult);
      ResultMap expected = createExpectation("C", "22", "11");
      expected.remove("table_3.column_3");
      expected.put("table_4.column_1", "11");

      assertThat(result).isEqualTo(expected);
    } catch (UnsupportedEncodingException e) {
      fail("");
    }
  }

  @Test
  public void 正常系_text電文_ジャーナル変換サービスでは変換ステータスを変更しない() {
    try {
      // ジャーナルの変換前状態確認
      // 変換ステータス='0'であること
      SysCoopJournal journal = sysCoopJournalDao.select("1", "1", "1", "C", "R");
      assertThat(journal).isNotNull();
      assertThat(journal.getAnaResult()).isEqualTo("0");

      byte[] telegram = journal.getDump();

      // 変換結果確認
      ResultMap keyResult = new ResultMap();
      ResultMap result = convertTextServiceImpl.convert("1", "R", "1", "1", "pre", "","",telegram,
        keyResult);
      ResultMap expected = createExpectation("C", "22", "11");
      expected.remove("table_3.column_3");
      expected.put("table_4.column_1", "11");

      assertThat(result).isEqualTo(expected);

      // ジャーナルの変換後状態確認
      // 変換ステータス='0'であること
      // （変換ステータスの更新はJournalConvertReceiveResouceに移動した。
      // そのため、変換サービスの呼び出しでは変換状態は変化しない。
      // 状態確認はResourceテストで実施する。
      // ここでは変換状態が変化しないことを確認する。）
      journal = sysCoopJournalDao.select("1", "1", "1", "C", "R");
      assertThat(journal).isNotNull();
      assertThat(journal.getAnaResult()).isEqualTo("0");
    } catch (UnsupportedEncodingException e) {
      fail("");
    }
  }

  @Test
  public void 正常系_text電文_const変換が適用される() {
    try {
      SysCoopJournal journal = sysCoopJournalDao.select("11", "11", "11", "C", "R");
      byte[] telegram = journal.getDump();

      ResultMap keyResult = new ResultMap();
      ResultMap result = convertTextServiceImpl.convert("11", "R", "11", "11", "pre","","", telegram,
        keyResult);
      ResultMap expected = createExpectation("C", "22", "PPPPP");

      assertThat(result).isEqualTo(expected);
    } catch (UnsupportedEncodingException e) {
      fail("");
    }
  }

  @Test
  public void 正常系_text電文_json変換が適用される() {
    try {
      SysCoopJournal journal = sysCoopJournalDao.select("12", "12", "12", "C", "R");
      byte[] telegram = journal.getDump();

      ResultMap keyResult = new ResultMap();
      ResultMap result = convertTextServiceImpl.convert("12", "R", "12", "12", "pre", "","",telegram,
        keyResult);
      ResultMap expected = createExpectation("C", "22", "99999");

      assertThat(result).isEqualTo(expected);
    } catch (UnsupportedEncodingException e) {
      fail("");
    }
  }

  @Test
  public void 正常系_text電文_dataset変換が適用される() {

    try {
      doDatasetMock();

      SysCoopJournal journal = sysCoopJournalDao.select("13", "13", "13", "C", "R");
      byte[] telegram = journal.getDump();

      ResultMap keyResult = new ResultMap();
      ResultMap result = convertTextServiceImpl.convert("13", "R", "13", "13", "pre", "","",telegram,
        keyResult);
      ResultMap expected = createExpectation("C", "22", "7");

      assertThat(result).isEqualTo(expected);
    } catch (UnsupportedEncodingException e) {
      fail("");
    }
  }

  @Test
  public void 正常系_繰り返し回数が電文で与えられる場合_正常に変換される() {
    // レイアウトでocc要素のrepeat属性が指定されていない場合（len属性は0でない）
    // →電文から繰り返し回数を取得する。

    try {
      SysCoopJournal journal = sysCoopJournalDao.select("31", "22", "22", "C", "R");
      byte[] telegram = journal.getDump();

      ResultMap keyResult = new ResultMap();

      ResultMap result = convertTextServiceImpl.convert("31", "R", "22", "22", "pre", "","",telegram,
        keyResult);
      ResultMap expected = createExpectationOnRepeat2();

      assertThat(result).isEqualTo(expected);
    } catch (UnsupportedEncodingException e) {
      fail("");
    }
  }

  @Test
  public void 正常系_繰り返し回数が固定の場合_正常に変換される_1() {
    // レイアウトでocc要素のrepeat属性が指定されており、len属性が0の場合
    // 繰り返し回数はrepeat属性値であり固定。

    try {
      SysCoopJournal journal = sysCoopJournalDao.select("32", "22", "22", "C", "R");
      byte[] telegram = journal.getDump();

      ResultMap keyResult = new ResultMap();

      ResultMap result = convertTextServiceImpl.convert("32", "R", "22", "22", "pre", "","",telegram,
        keyResult);
      ResultMap expected = createExpectationOnRepeat5();

      assertThat(result).isEqualTo(expected);
    } catch (UnsupportedEncodingException e) {
      fail("");
    }
  }

  @Test
  public void 正常系_繰り返し回数が固定の場合_正常に変換される_2() {
    // レイアウトでocc要素のrepeat属性が指定されており、len属性が0でない場合
    // 繰り返し回数はrepeat属性値であり固定。
    // ただし、電文中の要素はlen属性の長さだけ読み飛ばされる。

    try {
      SysCoopJournal journal = sysCoopJournalDao.select("33", "22", "22", "C", "R");
      byte[] telegram = journal.getDump();

      ResultMap keyResult = new ResultMap();

      ResultMap result = convertTextServiceImpl.convert("33", "R", "22", "22", "pre", "","",telegram,
        keyResult);
      ResultMap expected = createExpectationOnRepeat5();

      assertThat(result).isEqualTo(expected);
    } catch (UnsupportedEncodingException e) {
      fail("");
    }
  }

  @Test
  public void 正常系_繰り返しフェッチ要素() {
    try {
      SysCoopJournal journal = sysCoopJournalDao.select("5031", "22", "22", "C", "R");
      byte[] telegram = journal.getDump();

      ResultMap keyResult = new ResultMap();

      ResultMap result = convertTextServiceImpl.convert("5031", "R", "22", "22", "pre", "","",telegram,
        keyResult);

      ResultMap expected = new ResultMap();

      List<ResultMap> contactList = new ArrayList<>();
      expected.put("table1.column1", contactList);

      ResultMap r1 = new ResultMap();
      r1.put("address", "住所０１２３４５６１");
      r1.put("name", "名前０１２３４５６１");
      r1.put("phone", "phone0123456781");
      contactList.add(r1);

      ResultMap r2 = new ResultMap();
      r2.put("address", "住所０１２３４５６２");
      r2.put("name", "名前０１２３４５６２");
      r2.put("phone", "phone0123456782");
      contactList.add(r2);

      ResultMap r3 = new ResultMap();
      r3.put("address", "住所０１２３４５６３");
      r3.put("name", "名前０１２３４５６３");
      r3.put("phone", "phone0123456783");
      contactList.add(r3);

      ResultMap r4 = new ResultMap();
      r4.put("address", "住所０１２３４５６４");
      r4.put("name", "名前０１２３４５６４");
      r4.put("phone", "phone0123456784");
      contactList.add(r4);

      ResultMap r5 = new ResultMap();
      r5.put("address", "住所０１２３４５６５");
      r5.put("name", "名前０１２３４５６５");
      r5.put("phone", "phone0123456785");
      contactList.add(r5);

      assertThat(result).isEqualTo(expected);
    } catch (UnsupportedEncodingException e) {
      fail("");
    }
  }

  @Test
  public void 正常系_保険情報の繰り返し要素をフェッチする() {
    try {
      SysCoopJournal journal = sysCoopJournalDao.select("6001", "6001", "6001", "C", "R");
      byte[] telegram = journal.getDump();

      ResultMap keyResult = new ResultMap();

      ResultMap result = convertTextServiceImpl.convert("6001", "R", "6001", "6001", "pre", "","",telegram,
        keyResult);
      // FIXME resultの内容を検証する。
    } catch(UnsupportedEncodingException e) {
      fail("");
    }
  }

  @Test
  public void 繰返し要素_occ配下の場合はマップのリストとして抽出する_繰返し5回_detail指定() {
    try {
      SysCoopJournal journal = sysCoopJournalDao.select("7001", "7001", "7001", "C", "R");
      byte[] telegram = journal.getDump();

      ResultMap keyResult = new ResultMap();

      ResultMap result = convertTextServiceImpl.convert("7001", "R", "7001", "7001", "pre", "","",telegram,
        keyResult);

      log.debug("{}:{}", 7001, result);

      assertThat(result.containsKey("pat_insurance.TMP_INS"));

      Object obj = result.get("pat_insurance.TMP_INS");
      List<Map<String, Object>> m1 = ObjectMapperUtil.castToStringObjectMapList(obj);
      Assert.assertThat(m1, notNullValue());
      Assert.assertThat(m1.size(), is(5));

      Map<String, Object> expected = createExpectedPatInsurance();

      m1.forEach(e -> {
        Assert.assertThat(e, is(expected));
      });

    } catch (UnsupportedEncodingException e) {
      fail("");
    }
  }

  @Test
  public void 繰返し要素_occ配下の場合はマップのリストとして抽出する_繰返し5回_detailなし() {
    try {
      SysCoopJournal journal = sysCoopJournalDao.select("7002", "7002", "7002", "C", "R");
      byte[] telegram = journal.getDump();

      ResultMap keyResult = new ResultMap();

      ResultMap result = convertTextServiceImpl.convert("7002", "R", "7002", "7002", "pre", "","",telegram,
        keyResult);

      log.debug("{}:{}", 7002, result);

      assertThat(result.containsKey("pat_insurance.TMP_INS"));

      Object obj = result.get("pat_insurance.TMP_INS");
      List<Map<String, Object>> m1 = ObjectMapperUtil.castToStringObjectMapList(obj);
      Assert.assertThat(m1, notNullValue());
      Assert.assertThat(m1.size(), is(5));

      Map<String, Object> expected = createExpectedPatInsurance();

      m1.forEach(e -> {
        Assert.assertThat(e, is(expected));
      });

    } catch (UnsupportedEncodingException e) {
      fail("");
    }
  }

  @Test
  public void 繰返し要素_occ配下の場合はマップのリストとして抽出する_繰返し1回() {
    try {
      SysCoopJournal journal = sysCoopJournalDao.select("7011", "7011", "7011", "C", "R");
      byte[] telegram = journal.getDump();

      ResultMap keyResult = new ResultMap();

      ResultMap result = convertTextServiceImpl.convert("7011", "R", "7011", "7011", "pre", "","",telegram,
        keyResult);

      log.debug("{}:{}", 7011, result);
    }catch(UnsupportedEncodingException e) {
      fail("");
    }
  }

  @Test
  public void 繰返し要素_occ配下の場合はマップのリストとして抽出する_繰返し1回_detailなし() {
    try {
      SysCoopJournal journal = sysCoopJournalDao.select("7012", "7012", "7012", "C", "R");
      byte[] telegram = journal.getDump();

      ResultMap keyResult = new ResultMap();

      ResultMap result = convertTextServiceImpl.convert("7012", "R", "7012", "7012", "pre", "","",telegram,
        keyResult);

      log.debug("{}:{}", 7012, result);

      assertThat(result.containsKey("pat_insurance.TMP_INS"));

      Object obj = result.get("pat_insurance.TMP_INS");
      log.debug("{}:obj={}", 7012, obj);
      List<Map<String, Object>> m1 = ObjectMapperUtil.castToStringObjectMapList(obj);
      Assert.assertThat(m1, notNullValue());
      Assert.assertThat(m1.size(), is(6));

      Map<String, Object> expected = createExpectedPatInsurance();

      Assert.assertThat(m1.get(0), is(expected));

    } catch (UnsupportedEncodingException e) {
      fail("");
    }
  }

  @Test
  public void 繰返し要素_混在() {
    try {
      SysCoopJournal journal = sysCoopJournalDao.select("10000", "10000", "10000", "C", "R");
      byte[] telegram = journal.getDump();

      ResultMap keyResult = new ResultMap();

      ResultMap result = convertTextServiceImpl.convert("10000", "R", "10000", "10000", "pre", "","",telegram,
        keyResult);

      log.debug("{}:{}", 10000, result);
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

  private ResultMap createExpectationOnRepeat2() {
    ResultMap r = new ResultMap();

    ResultMap m1 = new ResultMap();
    m1.put("key", "ABC");
    m1.put("value", "12345");

    ResultMap m2 = new ResultMap();
    m2.put("key", "DEF");
    m2.put("value", "67890");

    List<ResultMap> l = new ArrayList<>();
    l.add(m1);
    l.add(m2);

    r.put("table1.column1", l);

    return r;
  }

  private ResultMap createExpectationOnRepeat5() {
    ResultMap r = new ResultMap();

    ResultMap m1 = new ResultMap();
    m1.put("key", "ABC");
    m1.put("value", "12345");

    ResultMap m2 = new ResultMap();
    m2.put("key", "DEF");
    m2.put("value", "67890");

    List<ResultMap> l = new ArrayList<>();
    l.add(m1);
    l.add(m2);
    l.add(m1);
    l.add(m2);
    l.add(m1);

    r.put("table1.column1", l);

    return r;
  }

  private void doDatasetMock() {
    doReturn("7").when(convertTextServiceImpl).evalReplace(anyString(), anyString(), any(), any());
  }

  private Map<String, Object> createExpectedPatInsurance() {
    Map<String, Object> m = new HashMap<>();

    m.put("PATTERN", "1234567");
    m.put("PATTERNSEQ", "abcdefg");
    m.put("STDATE", "2020/02/19 12:00:00");
    m.put("EDDATE", "9999/12/31 23:59:59");
    m.put("INS_NO", "123456789012");
    m.put("KOHI_1", "0");
    m.put("KOHI_2", "0");
    m.put("KOHI_3", "0");
    m.put("KOHI_4", "0");
    m.put("PER_FAM_CLASS", "0");
    m.put("BURDEN_RATIO GAIRAI", "0");
    m.put("BURDEN_RATIO NYUIN", "0");
    m.put("INS_NAME", "xxxxxxx");

    return m;
  }
}
