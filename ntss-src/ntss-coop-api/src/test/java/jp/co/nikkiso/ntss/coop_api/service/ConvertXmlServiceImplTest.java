package jp.co.nikkiso.ntss.coop_api.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.fail;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.SpyBean;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.coop_api.response.JournalConvertResult.ResultMap;
import jp.co.nikkiso.ntss.core.dao.SysCoopJournalDao;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;

@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
public class ConvertXmlServiceImplTest {

  @SpyBean
  ConvertXmlServiceImpl convertXmlServiceImpl;

  @SpyBean
  SysCoopJournalDao sysCoopJournalDao;

  // 動作確認（各電文より項目を抜粋）
  // 解析処理が電文スキーマに依存せず、レイアウト定義により任意のXML電文に対応できることを検証する。

  // 患者属性連携
  @Sql("classpath:resource.script/ConvertXmlServiceImplTest/s000/masters_layout_000.sql")
  @Sql("classpath:resource.script/ConvertXmlServiceImplTest/s000/journal_000.sql")
  @Test
  public void 正常系_XML電文解析_抜粋_1_患者属性連携() {
    final String FACILITY_CD = "XML000";
    SysCoopJournal journal = sysCoopJournalDao.select(FACILITY_CD, "ini_dial", "1", "C", "R");
    byte[] telegram = journal.getDump();

    try {
      ResultMap keyResult = new ResultMap();
      ResultMap result = convertXmlServiceImpl.convert(FACILITY_CD, "R", "ini_dial", "1", "pre", "","",telegram,
        keyResult);

      assertThat(result).isNotNull();
      assertThat(result.size()).isEqualTo(2);

      ResultMap expected = new ResultMap();

      expected.put("pat_personal_main.pat_id", "12345678");

      Map<String, Object> doctorMap = new TreeMap<>();
      List<Map<String, Object>> doctorMapList = Collections.singletonList(doctorMap);
      expected.put("pat_personal_main.doctor", doctorMapList);
      doctorMap.put("doctor_cd", "D001");
      doctorMap.put("dialysis_doctor_cd", "D002");
      doctorMap.put("dialysis_nurse_cd", "NU0010");

      assertThat(result).isEqualTo(expected);

    } catch (Exception e) {
      fail("", e);
    }
  }

  // 透析予約連携
  @Sql("classpath:resource.script/ConvertXmlServiceImplTest/s001/masters_layout_001.sql")
  @Sql("classpath:resource.script/ConvertXmlServiceImplTest/s001/journal_001.sql")
  @Test
  public void 正常系_XML電文解析_抜粋_2_透析予約連携() {
    final String FACILITY_CD = "XML001";
    SysCoopJournal journal = sysCoopJournalDao.select(FACILITY_CD, "ini_dial", "1", "C", "R");
    byte[] telegram = journal.getDump();

    try {
      ResultMap keyResult = new ResultMap();
      ResultMap result = convertXmlServiceImpl.convert(FACILITY_CD, "R", "ini_dial", "1", "pre", "","",telegram,
        keyResult);

      assertThat(result).isNotNull();
      assertThat(result.size()).isEqualTo(5);

      ResultMap expected = new ResultMap();

      expected.put("pat_personal_main.pat_id", "12345678");
      expected.put("pat_exam_main.reg_exam_date", "20200417");
      expected.put("pat_exam_main.cop_order_no1", "0");
      expected.put("pat_exam_main.cop_order_no2", "180");

      Map<String, Object> examOrderInfoMap = new TreeMap<>();
      List<Map<String, Object>> examOrderInfoMapList = Collections.singletonList(examOrderInfoMap);
      expected.put("pat_exam_main.exam_order_info", examOrderInfoMapList);
      examOrderInfoMap.put("ctl_no", "1234");
      examOrderInfoMap.put("dialysis_item_name", "血圧管理");
      examOrderInfoMap.put("value", "80");
      examOrderInfoMap.put("value_name", "最低血圧");
      examOrderInfoMap.put("unit", "mmHg");

      assertThat(result).isEqualTo(expected);

    } catch (Exception e) {
      fail("", e);
    }
  }

  // カルテ記載連携
  @Sql("classpath:resource.script/ConvertXmlServiceImplTest/s002/masters_layout_002.sql")
  @Sql("classpath:resource.script/ConvertXmlServiceImplTest/s002/journal_002.sql")
  @Test
  public void 正常系_XML電文解析_抜粋_3_カルテ記載連携() {
    final String FACILITY_CD = "XML002";
    SysCoopJournal journal = sysCoopJournalDao.select(FACILITY_CD, "ini_dial", "1", "C", "R");
    byte[] telegram = journal.getDump();

    try {
      ResultMap keyResult = new ResultMap();
      ResultMap result = convertXmlServiceImpl.convert(FACILITY_CD, "R", "ini_dial", "1", "pre", "","",telegram,
        keyResult);

      assertThat(result).isNotNull();
      assertThat(result.size()).isEqualTo(5);

      ResultMap expected = new ResultMap();
      expected.put("pat_personal_main.pat_id", "12345678");
      expected.put("pat_obs_rec.bbs_ctl_no", "000000000001");
      expected.put("pat_obs_rec.rec_date", "20200417");

      Map<String, Object> kindInfoMap = new TreeMap<>();
      List<Map<String, Object>> kindInfoMapList = Collections.singletonList(kindInfoMap);
      expected.put("pat_obs_rec.kind_info", kindInfoMapList);

      kindInfoMap.put("kind_name", "NW");
      kindInfoMap.put("class", "CA01");

      Map<String, Object> obsRecInfoMap = new TreeMap<>();
      List<Map<String, Object>> obsRecInfoMapList = Collections.singletonList(obsRecInfoMap);
      expected.put("pat_obs_rec.obs_rec_info", obsRecInfoMapList);

      obsRecInfoMap.put("detail", "$PAT_BASIC_INFO/DISP_PATID$");

      assertThat(result).isEqualTo(expected);

    } catch (Exception e) {
      fail("", e);
    }
  }

  // 透析実績連携
  @Sql("classpath:resource.script/ConvertXmlServiceImplTest/s003/masters_layout_003.sql")
  @Sql("classpath:resource.script/ConvertXmlServiceImplTest/s003/journal_003.sql")
  @Test
  public void 正常系_XML電文解析_抜粋_4_透析実績連携() {
    final String FACILITY_CD = "XML003";
    SysCoopJournal journal = sysCoopJournalDao.select(FACILITY_CD, "ini_dial", "1", "C", "R");
    byte[] telegram = journal.getDump();

    try {
      ResultMap keyResult = new ResultMap();
      ResultMap result = convertXmlServiceImpl.convert(FACILITY_CD, "R", "ini_dial", "1", "pre", "","",telegram,
        keyResult);

      assertThat(result).isNotNull();
      assertThat(result.size()).isEqualTo(5);

      ResultMap expected = new ResultMap();

      expected.put("pat_personal_main.pat_id", "12345678");

      Map<String, Object> save1Map = new TreeMap<>();
      List<Map<String, Object>> save1MapList = Collections.singletonList(save1Map);
      expected.put("pat_coop_detail.save_1", save1MapList);
      save1Map.put("dialysis_date", "20200417");
      save1Map.put("dialysis_no", "112233");

      Map<String, Object> save2Map = new TreeMap<>();
      List<Map<String, Object>> save2MapList = Collections.singletonList(save2Map);
      expected.put("pat_coop_detail.save_2", save2MapList);
      save2Map.put("weight_before", "72.3");
      save2Map.put("weight_after", "71.0");

      Map<String, Object> save3Map = new TreeMap<>();
      List<Map<String, Object>> save3MapList = Collections.singletonList(save3Map);
      expected.put("pat_coop_detail.save_3", save3MapList);
      save3Map.put("ctl_no", "9988");
      save3Map.put("ten_cd", "753");
      save3Map.put("tkjnam", "TKJNAM");
      save3Map.put("amount", "12");
      save3Map.put("unit", "個");

      Map<String, Object> save4Map = new TreeMap<>();
      List<Map<String, Object>> save4MapList = Collections.singletonList(save4Map);
      expected.put("pat_coop_detail.save_4", save4MapList);
      save4Map.put("ctl_no", "7777");
      save4Map.put("medicine_cd", "1111");
      save4Map.put("medicine_name", "アスピリンダイアルミネート");
      save4Map.put("medi_class_name", "NSAIDs");

      assertThat(result).isEqualTo(expected);

    } catch (Exception e) {
      fail("", e);
    }
  }

  // 繰返し確認
  @Sql("classpath:resource.script/ConvertXmlServiceImplTest/s010/masters_layout_010.sql")
  @Sql("classpath:resource.script/ConvertXmlServiceImplTest/s010/journal_010.sql")
  @Test
  public void 正常系_XML電文解析_繰返し_1() {
    final String FACILITY_CD = "XML010";
    SysCoopJournal journal = sysCoopJournalDao.select(FACILITY_CD, "ini_dial", "1", "C", "R");
    byte[] telegram = journal.getDump();

    try {
      ResultMap keyResult = new ResultMap();
      ResultMap result = convertXmlServiceImpl.convert(FACILITY_CD, "R", "ini_dial", "1", "pre", "","",telegram,
        keyResult);

      assertThat(result).isNotNull();

      ResultMap expected = new ResultMap();

      expected.put("pat_personal_main.pat_id", "12345678");

      Map<String, Object> save1Map = new TreeMap<>();
      List<Map<String, Object>> save1MapList = Collections.singletonList(save1Map);
      expected.put("pat_coop_detail.save_1", save1MapList);
      save1Map.put("dialysis_date", "20200417");
      save1Map.put("dialysis_no", "112233");

      Map<String, Object> save2Map = new TreeMap<>();
      List<Map<String, Object>> save2MapList = Collections.singletonList(save2Map);
      expected.put("pat_coop_detail.save_2", save2MapList);
      save2Map.put("weight_before", "72.3");
      save2Map.put("weight_after", "71.0");

      List<Map<String, Object>> dialysisMediList = new ArrayList<>();
      expected.put("pat_coop_detail.save_4", dialysisMediList);

      Map<String, Object> medi1 = new TreeMap<>();
      dialysisMediList.add(medi1);
      medi1.put("ctl_no", "001");
      medi1.put("medicine_cd", "1001");
      medi1.put("medicine_name", "エリスロポエチン製剤");
      medi1.put("medi_class_name", "KIDF");

      Map<String, Object> medi2 = new TreeMap<>();
      dialysisMediList.add(medi2);
      medi2.put("ctl_no", "002");
      medi2.put("medicine_cd", "2001");
      medi2.put("medicine_name", "抗ヒスタミン製剤");
      medi2.put("medi_class_name", "ITCH");

      Map<String, Object> medi3 = new TreeMap<>();
      dialysisMediList.add(medi3);
      medi3.put("ctl_no", "003");
      medi3.put("medicine_cd", "3001");
      medi3.put("medicine_name", "ファモチジン製剤");
      medi3.put("medi_class_name", "GAST");

      assertThat(result).isEqualTo(expected);

    } catch (Exception e) {
      fail("", e);
    }
  }

  // レイアウト切替確認
  @Sql("classpath:resource.script/ConvertXmlServiceImplTest/s011/masters_layout_011.sql")
  @Sql("classpath:resource.script/ConvertXmlServiceImplTest/s011/masters_layout_detail_011.sql")
  @Sql("classpath:resource.script/ConvertXmlServiceImplTest/s011/journal_011.sql")
  @Test
  public void 正常系_XML電文解析_レイアウト切替_1() {
    final String FACILITY_CD = "XML011";
    List<SysCoopJournal> journalList = sysCoopJournalDao.selectToConvert(FACILITY_CD, "R", "0", "9", null,0L,0L);

    try {
      List<Map<String, Object>> expectedList = Arrays.asList(
        createXML011_1(), createXML011_2(), createXML011_3(), createXML011_4());

      // このシナリオは対象ジャーナルが4つあり、それぞれについて解析結果を検証する。
      int i = 0;
      for (SysCoopJournal journal : journalList) {
        byte[] telegram = journal.getDump();
        ResultMap keyResult = new ResultMap();
        ResultMap result = convertXmlServiceImpl.convert(FACILITY_CD, "R", "ini_dial", "1", "pre", "","",telegram,
          keyResult);

        assertThat(result).isNotNull();
        assertThat(result).isEqualTo(expectedList.get(i));
        ++i;
      }
    } catch (Exception e) {
      fail("", e);
    }
  }

  private Map<String, Object> createXML011_1() {
    Map<String, Object> m = createXML011_common();

    Map<String, Object> save4Map = new TreeMap<>();
    List<Map<String, Object>> l = Collections.singletonList(save4Map);

    m.put("pat_coop_detail.save_4", l);
    save4Map.put("ctl_no", "001");
    save4Map.put("medicine_cd", "1001");
    save4Map.put("medicine_name", "エリスロポエチン製剤");
    save4Map.put("medi_class_name", "KIDF");

    return m;
  }

  private Map<String, Object> createXML011_2() {
    Map<String, Object> m = createXML011_common();

    Map<String, Object> save4Map = new TreeMap<>();
    List<Map<String, Object>> l = Collections.singletonList(save4Map);

    m.put("pat_coop_detail.save_4", l);
    save4Map.put("ctl_no", "002");
    save4Map.put("medicine_cd", "1002");
    save4Map.put("medicine_name", "リン吸着薬");
    save4Map.put("medi_class_name", "KIDF");

    return m;
  }

  private Map<String, Object> createXML011_3() {
    Map<String, Object> m = createXML011_common();

    Map<String, Object> save4Map = new TreeMap<>();
    List<Map<String, Object>> l4 = Collections.singletonList(save4Map);
    m.put("pat_coop_detail.save_4", l4);
    save4Map.put("ctl_no", "003");
    save4Map.put("medicine_cd", "2001");
    save4Map.put("medicine_name", "抗ヒスタミン外用薬");
    save4Map.put("medi_class_name", "ITCH");

    Map<String, Object> save5Map = new TreeMap<>();
    List<Map<String, Object>> l5 = Collections.singletonList(save5Map);
    m.put("pat_coop_detail.save_5", l5);
    save5Map.put("medi_appli_cd", "5010");
    save5Map.put("medi_appli_desc", "夜間掻痒時");

    return m;
  }

  private Map<String, Object> createXML011_4() {
    Map<String, Object> m = createXML011_common();

    Map<String, Object> save4Map = new TreeMap<>();
    List<Map<String, Object>> l4 = Collections.singletonList(save4Map);
    m.put("pat_coop_detail.save_4", l4);
    save4Map.put("ctl_no", "004");
    save4Map.put("medicine_cd", "3005");
    save4Map.put("medicine_name", "ファモチジン製剤");

    Map<String, Object> save6Map = new TreeMap<>();
    List<Map<String, Object>> l6 = Collections.singletonList(save6Map);
    m.put("pat_coop_detail.save_6", l6);
    save6Map.put("findings", "胃酸過多を認めたため");

    return m;
  }

  private Map<String, Object> createXML011_common() {
    Map<String, Object> m = new TreeMap<>();
    m.put("pat_personal_main.pat_id", "12345678");

    Map<String, Object> save1 = new TreeMap<>();
    List<Map<String, Object>> l1 = Collections.singletonList(save1);
    m.put("pat_coop_detail.save_1", l1);
    save1.put("dialysis_date", "20200417");
    save1.put("dialysis_no", "112233");

    Map<String, Object> save2 = new TreeMap<>();
    List<Map<String, Object>> l2 = Collections.singletonList(save2);
    m.put("pat_coop_detail.save_2", l2);
    save2.put("weight_before", "72.3");
    save2.put("weight_after", "71.0");

    return m;
  }

  // 繰返し+レイアウト切替複合
  @Sql("classpath:resource.script/ConvertXmlServiceImplTest/s012/masters_layout_012.sql")
  @Sql("classpath:resource.script/ConvertXmlServiceImplTest/s012/masters_layout_detail_012.sql")
  @Sql("classpath:resource.script/ConvertXmlServiceImplTest/s012/journal_012.sql")
  @Test
  public void 正常系_XML電文解析_繰返し_レイアウト切替_複合_1() {
    final String FACILITY_CD = "XML012";
    SysCoopJournal journal = sysCoopJournalDao.select(FACILITY_CD, "ini_dial", "1", "C", "R");
    byte[] telegram = journal.getDump();

    try {
      ResultMap keyResult = new ResultMap();
      ResultMap result = convertXmlServiceImpl.convert(FACILITY_CD, "R", "ini_dial", "1", "pre", "","",telegram,
        keyResult);

      assertThat(result).isNotNull();

      Map<String, Object> expected = new TreeMap<>();
      expected.put("pat_personal_main.pat_id", "12345678");
      expected.put("pat_coop_detail.save_1", createXML012_save1());
      expected.put("pat_coop_detail.save_2", createXML012_save2());
      expected.put("pat_coop_detail.save_4", createXML012_save4());
      expected.put("pat_coop_detail.save_5", createXML012_save5());
      expected.put("pat_coop_detail.save_6", createXML012_save6());

      assertThat(result).isEqualTo(expected);

    } catch (Exception e) {
      fail("", e);
    }
  }

  private List<Map<String, Object>> createXML012_save1() {
    Map<String, Object> m = new TreeMap<>();
    List<Map<String, Object>> l = Collections.singletonList(m);
    m.put("dialysis_date", "20200417");
    m.put("dialysis_no", "112233");

    return l;
  }

  private List<Map<String, Object>> createXML012_save2() {
    Map<String, Object> m = new TreeMap<>();
    List<Map<String, Object>> l = Collections.singletonList(m);
    m.put("weight_before", "72.3");
    m.put("weight_after", "71.0");

    return l;
  }

  private List<Map<String, Object>> createXML012_save4() {
    List<Map<String, Object>> l = new ArrayList<>();

    Map<String, Object> m1 = new TreeMap<>();
    l.add(m1);
    m1.put("ctl_no", "001");
    m1.put("medicine_cd", "1001");
    m1.put("medicine_name", "エリスロポエチン製剤");
    m1.put("medi_class_name", "KIDF");

    Map<String, Object> m2 = new TreeMap<>();
    l.add(m2);
    m2.put("ctl_no", "002");
    m2.put("medicine_cd", "1002");
    m2.put("medicine_name", "リン吸着薬");
    m2.put("medi_class_name", "KIDF");

    Map<String, Object> m3 = new TreeMap<>();
    l.add(m3);
    m3.put("ctl_no", "003");
    m3.put("medicine_cd", "2001");
    m3.put("medicine_name", "抗ヒスタミン外用薬");
    m3.put("medi_class_name", "ITCH");

    Map<String, Object> m4 = new TreeMap<>();
    l.add(m4);
    m4.put("ctl_no", "004");
    m4.put("medicine_cd", "3005");
    m4.put("medicine_name", "ファモチジン製剤");

    return l;
  }

  private List<Map<String, Object>> createXML012_save5() {
    Map<String, Object> m = new TreeMap<>();
    List<Map<String, Object>> l = Collections.singletonList(m);
    m.put("medi_appli_cd", "5010");
    m.put("medi_appli_desc", "夜間掻痒時");

    return l;
  }

  private List<Map<String, Object>> createXML012_save6() {
    Map<String, Object> m = new TreeMap<>();
    List<Map<String, Object>> l = Collections.singletonList(m);
    m.put("findings", "胃酸過多を認めたため");

    return l;
  }
}
