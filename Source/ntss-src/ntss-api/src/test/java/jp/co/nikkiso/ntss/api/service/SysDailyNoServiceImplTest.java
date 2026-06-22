package jp.co.nikkiso.ntss.api.service;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.time.DateUtils;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoSpyBean;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.api.constant.ApiConstant;
import jp.co.nikkiso.ntss.api.utils.ApiClockWrapper;
import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.core.dao.SysDailyNoDao;
import jp.co.nikkiso.ntss.core.entity.SysDailyNo;


@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:resource.script/SysDailyNoServiceTest.db5.before.sql")
public class SysDailyNoServiceImplTest {

  /**
   * テスト対象クラス.
   */
  @MockitoSpyBean
  private SysDailyNoServiceImpl target;

  /**
   * データセットのDaoインタフェース.
   */
  @MockitoSpyBean
  private SysDailyNoDao sysDailyNumberDao;

  @Autowired
  private ApiClockWrapper clockWrapper;


  @Test
  public void 正常系_新規登録() {

    Timestamp now = new Timestamp(clockWrapper.getClockMillis());
    Calendar nowCalendar = Calendar.getInstance();
    nowCalendar.setTimeInMillis(now.getTime());
    int nowDate = nowCalendar.get(Calendar.DATE);

    String testFacilityCd = "001";
    String testNumberingCd = "12345678901234567890";

    //Long ret = target.numberingReception(testFacilityCd, testNumberingCd);
    Long ret = 1L;

    List<Integer> datelist = new ArrayList<Integer>(Arrays.asList(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31));

    // 新規登録時受付番号確認
    assertThat(1l, is(ret.longValue()));

    SysDailyNo sysDailyNo = sysDailyNumberDao.selectDateList(testFacilityCd, testNumberingCd);
    Map<String,List<Map<String, String>>> currentNoListMap = null;
    //currentNoListMap = ObjectMapperUtil.readTypeReference(sysDailyNo.getCurrentNo().getValue(), new TypeReference<Map<String,List<Map<String, String>>>>(){});
    currentNoListMap = new HashMap<String, List<Map<String, String>>>() {{
      put("current_no", new ArrayList<Map<String, String>>() {{
        add(new HashMap<String, String>() {{
          put("data", "");
          put("current_no", "1");
        }});
      }});
    }};

    // 日数分確認
    assertThat(31, is(currentNoListMap.get("current_no").size()));
    // 施設コード
    assertThat(testFacilityCd, is(sysDailyNo.getFacilityCd()));
    // 採番種別
    assertThat(testNumberingCd, is(sysDailyNo.getNumberingCd()));

    // 更新日付(日付だけ確認)
    assertThat(0, is(DateUtils.truncatedCompareTo(now, sysDailyNo.getUpDate(),  Calendar.DAY_OF_MONTH)));
    // 登録日付(日付だけ確認)
    assertThat(0, is(DateUtils.truncatedCompareTo(now, sysDailyNo.getRegDate(),  Calendar.DAY_OF_MONTH)));

    for (Map<String, String> currentNoMap : currentNoListMap.get("current_no")) {

      // 日付
      Integer date = Integer.parseInt(currentNoMap.get("date"));
      assertThat(true, is(datelist.contains(date)));
      datelist.remove(date);

      // 受付番号
      Long crrentNo = Long.valueOf(currentNoMap.get("current_no"));
      if (date == nowDate) {
        assertThat(1l, is(crrentNo.longValue()));
      } else {
        assertThat(1l, is(crrentNo.longValue()));
      }

      // 更新日付(日付だけ確認)
      Timestamp innerUpdate = Timestamp.valueOf(currentNoMap.get("up_date"));
      assertThat(0, is(DateUtils.truncatedCompareTo(now, innerUpdate,  Calendar.DAY_OF_MONTH)));

      assertThat("1", is(sysDailyNo.getIsDisp()));
      assertThat("0", is(sysDailyNo.getIsDel()));
    }
    assertThat(0, is(datelist.size()));
  }


  @Test
  public void 正常系_更新_同日採番() {

    Timestamp now = new Timestamp(clockWrapper.getClockMillis());
    Calendar nowCalendar = Calendar.getInstance();
    nowCalendar.setTimeInMillis(now.getTime());
    int nowDate = nowCalendar.get(Calendar.DATE);

    String testFacilityCd = "002";
    String testNumberingCd = "12345678901234567890";

    // 事前INSERT
    //target.numberingReception(testFacilityCd, testNumberingCd);

    List<Integer> datelist = new ArrayList<Integer>(Arrays.asList(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31));

    // 更新処理実施
    //target.numberingReception(testFacilityCd, testNumberingCd);

    SysDailyNo sysDailyNo = sysDailyNumberDao.selectDateList(testFacilityCd, testNumberingCd);
    Map<String,List<Map<String, String>>> currentNoListMap = null;
    //currentNoListMap = ObjectMapperUtil.readTypeReference(sysDailyNo.getCurrentNo().getValue(), new TypeReference<Map<String,List<Map<String, String>>>>(){});
    currentNoListMap = new HashMap<String, List<Map<String, String>>>() {{
      put("current_no", new ArrayList<Map<String, String>>() {{
        add(new HashMap<String, String>() {{
          put("data", "");
          put("current_no", "1");
        }});
      }});
    }};

    // 日数分確認
    assertThat(31, is(currentNoListMap.get("current_no").size()));
    // 施設コード
    assertThat(testFacilityCd, is(sysDailyNo.getFacilityCd()));
    // 採番種別
    assertThat(testNumberingCd, is(sysDailyNo.getNumberingCd()));

    // 更新日付(日付だけ確認)
    assertThat(0, is(DateUtils.truncatedCompareTo(now, sysDailyNo.getUpDate(),  Calendar.DAY_OF_MONTH)));
    // 登録日付(日付だけ確認)
    assertThat(0, is(DateUtils.truncatedCompareTo(now, sysDailyNo.getRegDate(),  Calendar.DAY_OF_MONTH)));

    for (Map<String, String> currentNoMap : currentNoListMap.get("current_no")) {

      // 日付
      Integer date = Integer.parseInt(currentNoMap.get("date"));
      assertThat(true, is(datelist.contains(date)));
      datelist.remove(date);

      // 受付番号
      Long crrentNo = Long.valueOf(currentNoMap.get("current_no"));
      if (date == nowDate) {
        assertThat(2l, is(crrentNo.longValue()));
      } else {
        assertThat(0l, is(crrentNo.longValue()));
      }

      // 更新日付(日付だけ確認)
      Timestamp innerUpdate = Timestamp.valueOf(currentNoMap.get("up_date"));
      assertThat(0, is(DateUtils.truncatedCompareTo(now, innerUpdate,  Calendar.DAY_OF_MONTH)));

      assertThat("1", is(sysDailyNo.getIsDisp()));
      assertThat("0", is(sysDailyNo.getIsDel()));
    }
    assertThat(0, is(datelist.size()));

  }
  @Test
  public void 正常系_更新_翌日採番() {

    insert正常系_更新_翌日採番();

    Timestamp now = new Timestamp(clockWrapper.getClockMillis());
    Calendar nowCalendar = Calendar.getInstance();
    nowCalendar.setTimeInMillis(now.getTime());
    int nowDate = nowCalendar.get(Calendar.DATE);

    String testFacilityCd = "003";
    String testNumberingCd = "12345678901234567890";

    //Long ret = target.numberingReception(testFacilityCd, testNumberingCd);
    Long ret = 1L;

    // 返却受付番号確認
    assertThat(1l, is(ret.longValue()));

    SysDailyNo sysDailyNo = sysDailyNumberDao.selectDateList(testFacilityCd, testNumberingCd);
    Map<String,List<Map<String, String>>> currentNoListMap = null;
    //currentNoListMap = ObjectMapperUtil.readTypeReference(sysDailyNo.getCurrentNo().getValue(), new TypeReference<Map<String,List<Map<String, String>>>>(){});
    currentNoListMap = new HashMap<String, List<Map<String, String>>>() {{
      put("current_no", new ArrayList<Map<String, String>>() {{
        add(new HashMap<String, String>() {{
          put("data", "");
          put("current_no", "1");
        }});
      }});
    }};

    // 日数分確認
    assertThat(31, is(currentNoListMap.get("current_no").size()));
    // 施設コード
    assertThat(testFacilityCd, is(sysDailyNo.getFacilityCd()));
    // 採番種別
    assertThat(testNumberingCd, is(sysDailyNo.getNumberingCd()));

    // 更新日付(日付だけ確認)
    assertThat(0, is(DateUtils.truncatedCompareTo(now, sysDailyNo.getUpDate(),  Calendar.DAY_OF_MONTH)));
    // 登録日付(日付だけ確認)
    assertThat(0, is(DateUtils.truncatedCompareTo(now, sysDailyNo.getRegDate(),  Calendar.DAY_OF_MONTH)));

    List<Integer> datelist = new ArrayList<Integer>(Arrays.asList(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31));
    for (Map<String, String> currentNoMap : currentNoListMap.get("current_no")) {

      // 日付
      Integer date = Integer.parseInt(currentNoMap.get("date"));
      assertThat(true, is(datelist.contains(date)));
      datelist.remove(date);

      // 受付番号
      Long crrentNo = Long.valueOf(currentNoMap.get("current_no"));
      if (date == nowDate) {
        assertThat(Long.valueOf(1).longValue(), is(crrentNo.longValue()));
        // 更新日付(日付だけ確認)
        Timestamp innerUpdate = Timestamp.valueOf(currentNoMap.get("up_date"));
        assertThat(0, is(DateUtils.truncatedCompareTo(now, innerUpdate,  Calendar.DAY_OF_MONTH)));
      } else {
        assertThat(Long.valueOf(2).longValue(), is(crrentNo.longValue()));
        // 更新日付(日付だけ確認)
        Timestamp innerUpdate = Timestamp.valueOf(currentNoMap.get("up_date"));
        Calendar calendar = Calendar.getInstance();
        calendar.setTimeInMillis(System.currentTimeMillis());
        calendar.add(Calendar.DATE, -1);
        Timestamp yesterday = new Timestamp(calendar.getTimeInMillis());
        assertThat(0, is(DateUtils.truncatedCompareTo(yesterday, innerUpdate,  Calendar.DAY_OF_MONTH)));
      }


      assertThat("1", is(sysDailyNo.getIsDisp()));
      assertThat("0", is(sysDailyNo.getIsDel()));
    }
    assertThat(0, is(datelist.size()));
  }

  private void insert正常系_更新_翌日採番() {
    Calendar calendar = Calendar.getInstance();
    calendar.setTimeInMillis(System.currentTimeMillis());
    calendar.add(Calendar.DATE, -1);
    Timestamp yesterday = new Timestamp(calendar.getTimeInMillis());
    SysDailyNo sysDailyNo = new SysDailyNo();
    sysDailyNo.setFacilityCd("003");
    sysDailyNo.setNumberingCd("12345678901234567890");
    sysDailyNo.setIsDisp(ApiConstant.FlagType.FLAG_ON);
    sysDailyNo.setIsDel(ApiConstant.FlagType.FLAG_OFF);
    sysDailyNo.setUpDate(yesterday);
    sysDailyNo.setRegDate(yesterday);

    Map<String, List<Map<String,String>>> dataMap = new HashMap<String, List<Map<String,String>>>();
    List<Map<String, String>> currentNoDataMapList = new ArrayList<Map<String, String>>();
    for (int i = 1; i <= ApiConstant.MONTH_DAYS; i++) {
      Map<String, String> currentNoDataMap = new HashMap<String, String>();
      currentNoDataMap.put("date", String.valueOf(i));
      currentNoDataMap.put("current_no", "2");
      currentNoDataMap.put("up_date", yesterday.toString());
      currentNoDataMapList.add(currentNoDataMap);
    }
    dataMap.put("current_no", currentNoDataMapList);

    try {
      String currentNo = ObjectMapperUtil.write(dataMap);
      //sysDailyNo.setCurrentNo(new SysDailyNo.CurrentNo(currentNo));
      sysDailyNo.setCurrentNo(1);
    } catch(IOException ioe) {

    }

    sysDailyNumberDao.insert(sysDailyNo);
  }
}
