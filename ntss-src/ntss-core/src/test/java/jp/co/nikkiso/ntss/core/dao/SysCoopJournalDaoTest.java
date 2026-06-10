package jp.co.nikkiso.ntss.core.dao;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.not;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.junit.Assert.assertThat;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Base64;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;

@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:dao.script/SysCoopJournalDaoTest.before.sql")
public class SysCoopJournalDaoTest {
  @Autowired
  private SysCoopJournalDao dao;

  @Test
  public void 正常系_insert_データ登録される() {
    SysCoopJournal expect = 登録用テストデータ作成();
    dao.insert(expect);
    SysCoopJournal actual = dao.select(expect.getFacilityCd(), expect.getCoopCd(), expect.getCoopCdIndex(),
        expect.getCrud(), expect.getDirection());

    assertThat(actual, is(notNullValue()));
  }

  @Test
  public void 正常系_insert_データ登録される_NULLの項目は指定されない() {
    SysCoopJournal expect = 登録用テストデータ作成();
    // default指定のあるカラム
    expect.setCoopResult(null);
    // default指定のないカラム
    expect.setDump(null);

    dao.insert(expect);
    SysCoopJournal actual = dao.select(expect.getFacilityCd(), expect.getCoopCd(), expect.getCoopCdIndex(),
        expect.getCrud(), expect.getDirection());

    assertThat(actual, is(notNullValue()));
    assertThat(actual.getCoopResult(), is("0"));
    assertThat(actual.getDump(), is(nullValue()));
  }

  @Test
  public void 正常系_updateByCoopResult_配信ステータスが処理中のため配信ステータスと配信開始日時と更新日時が更新される() {
    SysCoopJournal expect = 更新用テストデータ作成();
    String expectByCoopResult = "1";
    Timestamp expectByDate = Timestamp.valueOf("2019-11-29 11:00:00");

    dao.updateByCoopResult(Arrays.asList(expect.getCtlNo()).toString(), expectByCoopResult, expectByDate);
    SysCoopJournal actual = dao.select(expect.getFacilityCd(), expect.getCoopCd(), expect.getCoopCdIndex(),
        expect.getCrud(), expect.getDirection());

    assertThat(actual, is(notNullValue()));
    assertThat(actual.getCoopResult(), is(expectByCoopResult));
    assertThat(actual.getInRegDate(), is(expectByDate));
    assertThat(actual.getOutRegDate(), is(Timestamp.valueOf("2019-11-12 15:00:00")));
    assertThat(actual.getUpDate(), is(expectByDate));
  }

  @Test
  public void 正常系_updateByCoopResult_配信ステータスが処理中でないため配信ステータスと更新日時が更新される() {
    SysCoopJournal expect = 更新用テストデータ作成();
    String expectByCoopResult = "8";
    Timestamp expectByDate = Timestamp.valueOf("2019-11-29 11:00:00");

    dao.updateByCoopResult(Arrays.asList(expect.getCtlNo()).toString(), expectByCoopResult, expectByDate);
    SysCoopJournal actual = dao.select(expect.getFacilityCd(), expect.getCoopCd(), expect.getCoopCdIndex(),
        expect.getCrud(), expect.getDirection());

    assertThat(actual, is(notNullValue()));
    assertThat(actual.getCoopResult(), is(expectByCoopResult));
    assertThat(actual.getInRegDate(), is(Timestamp.valueOf("2019-11-12 15:00:00")));
    assertThat(actual.getOutRegDate(), is(Timestamp.valueOf("2019-11-12 15:00:00")));
    assertThat(actual.getUpDate(), is(expectByDate));
  }

  @Test
  public void 正常系_updateByCoopResult_ctlNoが複数指定されているため複数更新される() {
    List<SysCoopJournal> expectList = 複数更新用テストデータ作成();
    String expectByCoopResult = "8";
    Timestamp expectByDate = Timestamp.valueOf("2019-11-29 11:00:00");
    List<Long> ctlNoList = expectList.stream().map(expect -> expect.getCtlNo()).collect(Collectors.toList());

    dao.updateByCoopResult(ctlNoList.toString(), expectByCoopResult, expectByDate);

    for (SysCoopJournal expect : expectList) {
      SysCoopJournal actual = dao.select(expect.getFacilityCd(), expect.getCoopCd(), expect.getCoopCdIndex(),
          expect.getCrud(), expect.getDirection());

      assertThat(actual, is(notNullValue()));
      assertThat(actual.getCoopResult(), is(expectByCoopResult));
      assertThat(actual.getInRegDate(), is(Timestamp.valueOf("2019-11-12 15:00:00")));
      assertThat(actual.getOutRegDate(), is(Timestamp.valueOf("2019-11-12 15:00:00")));
      assertThat(actual.getUpDate(), is(expectByDate));
    }
  }

  @Test
  public void 正常系_updateByCoopResult_ctlNoが複数指定されているが対象があるものだけ更新される() {
    SysCoopJournal expect = 更新用テストデータ作成();
    String expectByCoopResult = "8";
    Timestamp expectByDate = Timestamp.valueOf("2019-11-29 11:00:00");
    // レコードのない値
    Long dummyCtlNo = 99L;
    List<Long> ctlNoList = Arrays.asList(expect.getCtlNo(), dummyCtlNo);

    dao.updateByCoopResult(ctlNoList.toString(), expectByCoopResult, expectByDate);

    SysCoopJournal actual = dao.select(expect.getFacilityCd(), expect.getCoopCd(), expect.getCoopCdIndex(),
        expect.getCrud(), expect.getDirection());

    assertThat(actual, is(notNullValue()));
    assertThat(actual.getCoopResult(), is(expectByCoopResult));
    assertThat(actual.getInRegDate(), is(Timestamp.valueOf("2019-11-12 15:00:00")));
    assertThat(actual.getOutRegDate(), is(Timestamp.valueOf("2019-11-12 15:00:00")));
    assertThat(actual.getUpDate(), is(expectByDate));

    // レコードがないので更新されない
    actual = dao.selectByPK(dummyCtlNo);
    assertThat(actual, is(nullValue()));
  }

  @Test
  public void 正常系_update_更新する項目がない場合は更新日時だけがアップデートされる() {
    SysCoopJournal expect = 更新用テストデータ作成();

    dao.update(更新用テストデータ作成());
    SysCoopJournal actual = dao.select(expect.getFacilityCd(), expect.getCoopCd(), expect.getCoopCdIndex(),
        expect.getCrud(), expect.getDirection());

    assertThat(actual, is(notNullValue()));
    // 更新日時は切り替わっているため、期待値とは別であること
    assertThat(actual.getUpDate().toString(), not(expect.getUpDate().toString()));
    assertThat(actual.getFacilityCd(), is(expect.getFacilityCd()));
    assertThat(actual.getCtlNo(), is(expect.getCtlNo()));
    assertThat(actual.getCoopCd(), is(expect.getCoopCd()));
    assertThat(actual.getCoopCdIndex(), is(expect.getCoopCdIndex()));
    assertThat(actual.getCrud(), is(expect.getCrud()));
    assertThat(actual.getDirection(), is(expect.getDirection()));
    assertThat(actual.getOrdNo(), is(expect.getOrdNo()));
    assertThat(actual.getCoopOrdNo(), is(expect.getCoopOrdNo()));
    assertThat(actual.getPatId(), is(expect.getPatId()));
    assertThat(actual.getHospPatId(), is(expect.getHospPatId()));
    assertThat(actual.getAnaResult(), is(expect.getAnaResult()));
    assertThat(actual.getCoopResult(), is(expect.getCoopResult()));
    assertThat(actual.getInAnaDate(), is(expect.getInAnaDate()));
    assertThat(actual.getInRegDate(), is(expect.getInRegDate()));
    assertThat(actual.getOutAnaDate(), is(expect.getOutAnaDate()));
    assertThat(actual.getOutRegDate(), is(expect.getOutRegDate()));
    assertThat(actual.getDump(), is(expect.getDump()));
    assertThat(actual.getDumpPath(), is(expect.getDumpPath()));
    assertThat(actual.getRegDate(), is(expect.getRegDate()));
    assertThat(actual.getIsDel(), is(expect.getIsDel()));
    assertThat(actual.getIsEditable(), is(expect.getIsEditable()));
    assertThat(actual.getUserId(), is(expect.getUserId()));
  }

  @Test
  public void 正常系_update_オーダ番号と更新日時だけがアップデートされる() {
    SysCoopJournal expect = 更新用テストデータ作成();
    expect.setOrdNo(1L);
    SysCoopJournal clone = 更新用テストデータ作成();
    dao.update(expect);
    SysCoopJournal actual = dao.select(expect.getFacilityCd(), expect.getCoopCd(), expect.getCoopCdIndex(),
        expect.getCrud(), expect.getDirection());

    assertThat(actual, is(notNullValue()));
    // 更新日時は切り替わっているため、期待値とは別であること
    assertThat(actual.getUpDate().toString(), not(clone.getUpDate().toString()));
    assertThat(actual.getUpDate(), is(expect.getUpDate()));
    assertThat(actual.getFacilityCd(), is(expect.getFacilityCd()));
    assertThat(actual.getCtlNo(), is(expect.getCtlNo()));
    assertThat(actual.getCoopCd(), is(expect.getCoopCd()));
    assertThat(actual.getCoopCdIndex(), is(expect.getCoopCdIndex()));
    assertThat(actual.getCrud(), is(expect.getCrud()));
    assertThat(actual.getDirection(), is(expect.getDirection()));
    assertThat(actual.getOrdNo(), is(expect.getOrdNo()));
    assertThat(actual.getCoopOrdNo(), is(expect.getCoopOrdNo()));
    assertThat(actual.getPatId(), is(expect.getPatId()));
    assertThat(actual.getHospPatId(), is(expect.getHospPatId()));
    assertThat(actual.getAnaResult(), is(expect.getAnaResult()));
    assertThat(actual.getCoopResult(), is(expect.getCoopResult()));
    assertThat(actual.getInAnaDate(), is(expect.getInAnaDate()));
    assertThat(actual.getInRegDate(), is(expect.getInRegDate()));
    assertThat(actual.getOutAnaDate(), is(expect.getOutAnaDate()));
    assertThat(actual.getOutRegDate(), is(expect.getOutRegDate()));
    assertThat(actual.getDump(), is(expect.getDump()));
    assertThat(actual.getDumpPath(), is(expect.getDumpPath()));
    assertThat(actual.getRegDate(), is(expect.getRegDate()));
    assertThat(actual.getIsDel(), is(expect.getIsDel()));
    assertThat(actual.getIsEditable(), is(expect.getIsEditable()));
    assertThat(actual.getUserId(), is(expect.getUserId()));
  }

  @Test
  public void 正常系_select_データあり() {
    String facilityCd = "TEST01";
    String coopCd = "1";
    String coopCdIndex = "";
    String crud = "C";
    String direction = "S";
    SysCoopJournal journal = dao.select(facilityCd, coopCd, coopCdIndex, crud, direction);

    assertThat(journal, is(notNullValue()));
  }

  @Test
  public void 正常系_select_データなし() {
    String facilityCd = "TEST02";
    String coopCd = "1";
    String coopCdIndex = "";
    String crud = "C";
    String direction = "S";
    SysCoopJournal journal = dao.select(facilityCd, coopCd, coopCdIndex, crud, direction);

    assertThat(journal, is(nullValue()));
  }

  @Test
  public void 正常系_updateConvStatusConverting_変換ステータスが変更される() {
    SysCoopJournal expect = 更新用テストデータ作成();
    Timestamp expectTime = Timestamp.valueOf("2019-11-29 18:00:00");

    SysCoopJournal entity = dao.select("TEST01", "1", "", "C", "S");
    Long ctlNo = entity.getCtlNo();
    assertThat(ctlNo, notNullValue());

    List<Long> ctlNoList = Collections.singletonList(ctlNo);
    dao.updateConvStatusConverting(ctlNoList.toString(), "1", expectTime);

    SysCoopJournal actual = dao.select(expect.getFacilityCd(), expect.getCoopCd(), expect.getCoopCdIndex(),
        expect.getCrud(), expect.getDirection());

    assertThat(actual, is(notNullValue()));
    assertThat(actual.getUpDate(), is(expectTime));
    assertThat(actual.getAnaResult(), is("1"));
    assertThat(actual.getCoopResult(), is(expect.getCoopResult()));
    assertThat(actual.getInAnaDate(), is(expectTime));
  }

  private SysCoopJournal 登録用テストデータ作成() {
    SysCoopJournal journal = new SysCoopJournal();
    journal.setFacilityCd("DUMMY");
    journal.setCtlNo(2L);
    journal.setCoopCd("TEST");
    journal.setCoopCdIndex("INDEX");
    journal.setCrud("C");
    journal.setDirection("S");
    journal.setOrdNo(1L);
    journal.setCoopOrdNo("1");
    journal.setHospPatId("1");
    journal.setPatId(1L);
    journal.setAnaResult("0");
    journal.setCoopResult("1");
    journal.setInAnaDate(Timestamp.valueOf("2019-11-29 12:00:00"));
    journal.setOutAnaDate(Timestamp.valueOf("2019-11-29 12:00:00"));
    journal.setInRegDate(Timestamp.valueOf("2019-11-29 12:00:00"));
    journal.setOutRegDate(Timestamp.valueOf("2019-11-29 12:00:00"));
    journal.setDumpPath("TEST.txt");
    journal.setDump(Base64.getEncoder().encode(new String("TEST_DUMP").getBytes()));
    journal.setIsEditable("0");
    journal.setIsDel("0");
    journal.setUserId(999L);

    return journal;
  }

  private SysCoopJournal 更新用テストデータ作成() {
    SysCoopJournal journal = new SysCoopJournal();
    journal.setFacilityCd("TEST01");
    journal.setCtlNo(1L);
    journal.setCoopCd("1");
    journal.setCoopCdIndex("");
    journal.setCrud("C");
    journal.setDirection("S");
    journal.setAnaResult("9");
    journal.setCoopResult("0");
    journal.setInAnaDate(Timestamp.valueOf("2019-11-12 15:00:00"));
    journal.setOutAnaDate(Timestamp.valueOf("2019-11-12 15:00:00"));
    journal.setInRegDate(Timestamp.valueOf("2019-11-12 15:00:00"));
    journal.setOutRegDate(Timestamp.valueOf("2019-11-12 15:00:00"));
    journal.setDumpPath("TEST.txt");
    journal.setIsEditable("1");
    journal.setIsDel("0");
    journal.setRegDate(Timestamp.valueOf("2019-11-12 15:00:00"));
    journal.setUpDate(Timestamp.valueOf("2019-11-12 15:00:00"));
    return journal;
  }

  private List<SysCoopJournal> 複数更新用テストデータ作成() {
    List<SysCoopJournal> result = new ArrayList<>();

    result.add(更新用テストデータ作成());

    SysCoopJournal journal = new SysCoopJournal();
    journal.setFacilityCd("TEST01");
    journal.setCtlNo(3L);
    journal.setCoopCd("1");
    journal.setCoopCdIndex("");
    journal.setCrud("R");
    journal.setDirection("R");
    journal.setAnaResult("0");
    journal.setCoopResult("0");
    journal.setInAnaDate(Timestamp.valueOf("2019-11-12 15:00:00"));
    journal.setOutAnaDate(Timestamp.valueOf("2019-11-12 15:00:00"));
    journal.setInRegDate(Timestamp.valueOf("2019-11-12 15:00:00"));
    journal.setOutRegDate(Timestamp.valueOf("2019-11-12 15:00:00"));
    journal.setDumpPath("TEST3.txt");
    journal.setIsEditable("1");
    journal.setIsDel("0");
    journal.setRegDate(Timestamp.valueOf("2019-11-12 15:00:00"));
    journal.setUpDate(Timestamp.valueOf("2019-11-12 15:00:00"));
    result.add(journal);

    return result;
  }
}
