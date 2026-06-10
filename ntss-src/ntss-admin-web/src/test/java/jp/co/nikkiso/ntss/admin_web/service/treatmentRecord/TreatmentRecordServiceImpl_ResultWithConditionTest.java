package jp.co.nikkiso.ntss.admin_web.service.treatmentRecord;

import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.TreatmentRecordDao;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordCondition;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordResult;
import org.json.JSONException;
import org.junit.Ignore;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.junit4.SpringRunner;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Map;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;

/**
 * {@link TreatmentRecordServiceImpl#updateTreatmentRecordResultWithCondition(Long, TreatmentRecordResult, int, Long)} に関するテストクラス
 */
@RunWith(SpringRunner.class)
@SpringBootTest
public class TreatmentRecordServiceImpl_ResultWithConditionTest {

  /**
   * テスト対象クラス
   */
  @Autowired
  private TreatmentRecordService target;

  /**
   * {@link MstPersonalUserDao}のMockBean.
   */
  @MockBean
  private MstPersonalUserDao mstPersonalUserDao;

  /**
   * {@link TreatmentRecordDao}のMockBean.
   */
  @MockBean
  private TreatmentRecordDao treatmentRecordDao;

  /**
   * {@link MstTreatmentDao}のMockBean.
   */
  @MockBean
  private MstTreatmentDao mstTreatmentDao;

  /**
   * 例外の発生をテストするためのルール
   */
  @Rule
  public ExpectedException expectedException = ExpectedException.none();

  /**
   * getMstPersonalUser(privateメソッド)をinvokeする.
   *
   * @param userId 利用者ID
   * @return 利用者マスタエンティティ
   * @throws Throwable
   */
  private MstPersonalUser invokeGetMstPersonalUser(Long userId) throws Throwable {
    try {
      Method method = TreatmentRecordServiceImpl.class.getDeclaredMethod("getMstPersonalUser", Long.class);
      method.setAccessible(true);
      return (MstPersonalUser) method.invoke(target, userId);
    } catch (InvocationTargetException e) {
      throw e.getCause();
    } catch (NoSuchMethodException | IllegalAccessException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
    }
    return null;
  }

  /**
   * getMstPersonalUser(Long)の検証
   * <p>
   *   条件:存在する利用者IDを指定する
   *   結果:利用者IDに該当する{@link MstPersonalUser}が返却される事
   * </p>
   */
  @Test
  public void test_getMstPersonalUser_正常_存在する利用者IDを指定() throws Throwable {
    // テストする利用者ID
    Long userId = 1L;
    // 戻り値
    MstPersonalUser expected = new MstPersonalUser();
    // Mock
    given(mstPersonalUserDao.selectById(userId)).willReturn(expected);
    // 実行
    MstPersonalUser result = invokeGetMstPersonalUser(userId);
    // 検証
    verify(mstPersonalUserDao, times(1)).selectById(userId);
    assertThat(result, is(expected));
  }

  /**
   * getMstPersonalUser(Long)の検証
   * <p>
   *   条件:存在しない利用者IDを指定する
   *   結果:nullが返却される事
   * </p>
   */
  @Test
  public void test_getMstPersonalUser_異常_存在しない利用者IDを指定() throws Throwable {
    // テストする利用者ID
    Long userId = 2L;
    // 戻り値
    MstPersonalUser expected = new MstPersonalUser();
    // Mock
    given(mstPersonalUserDao.selectById(userId)).willReturn(null);
    // 実行
    MstPersonalUser result = invokeGetMstPersonalUser(userId);
    // 検証
    verify(mstPersonalUserDao, times(1)).selectById(userId);
    assertNull(result);
  }

  /**
   * getRstCondInfoMap(privateメソッド)をinvokeする.
   *
   * @param rstCondInfo 治療条件のJSON文字列
   * @return 治療条件のJSON文字列を治療条件項目番号をキーに格納したマップ
   */
  private Map<String, TreatmentRecordServiceImpl.RstCondInfo> invokeGetRstCondInfoMap(String rstCondInfo) throws Throwable {
    try{
      Method method = TreatmentRecordServiceImpl.class.getDeclaredMethod("getRstCondInfoMap", String.class);
      method.setAccessible(true);
      return (Map<String, TreatmentRecordServiceImpl.RstCondInfo>) method.invoke(target, rstCondInfo);
    } catch (NoSuchMethodException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
    }
    return null;
  }

  /**
   * getRstCondInfo(String)の検証.
   * <p>
   *   条件:治療条件のJSON文字列を指定する.
   *   結果:治療条件のJSON文字列を治療条件項目番号毎に格納されたMapが返却される事
   * </p>
   */
  @Test
  public void test_getRstCondInfoMap_正常_治療条件の正しいJSON文字列を指定() throws Throwable {
    // テストで使用する治療条件のJSON文字列
    String condInfo = "{\"1\": {\"unit\": \"組\", \"value\": 100, \"ind_user_id\": 1, \"input_class\": \"1\", \"is_editable\": \"0\", \"upd_user_id\": 2, \"cop_order_no\": 999, \"value_name_1\": \"テスト1\", \"value_name_2\": \"テスト2\", \"medicine_type\": 1, \"ind_user_last_name\": \"日機装\", \"upd_user_last_name\": \"永和\", \"ind_user_first_name\": \"太郎\", \"upd_user_first_name\": \"花子\"}, \"2\": {\"unit\": \"錠\", \"value\": 101, \"ind_user_id\": 4, \"input_class\": null, \"is_editable\": \"1\", \"upd_user_id\": 5, \"cop_order_no\": null, \"value_name_1\": null, \"value_name_2\": null, \"medicine_type\": null, \"ind_user_last_name\": \"永和\", \"upd_user_last_name\": \"日機装\", \"ind_user_first_name\": \"花子\", \"upd_user_first_name\": \"太郎\"}}";
    // 実行
    Map<String, TreatmentRecordServiceImpl.RstCondInfo> result = invokeGetRstCondInfoMap(condInfo);
    // 検証
    assertThat(result.size(), is(2));
    // 1件目
    TreatmentRecordServiceImpl.RstCondInfo first = result.get("1");
    assertThat(first.getUnit(), is("組"));
    assertThat(first.getValue(), is(100));
    assertThat(first.getInd_user_id(), is(1L));
    assertThat(first.getInput_class(), is("1"));
    assertThat(first.getIs_editable(), is("0"));
    assertThat(first.getUpd_user_id(), is(2L));
    assertThat(first.getCop_order_no(), is(999L));
    assertThat(first.getValue_name_1(), is("テスト1"));
    assertThat(first.getValue_name_2(), is("テスト2"));
    assertThat(first.getMedicine_type(), is(1));
    assertThat(first.getInd_user_last_name(), is("日機装"));
    assertThat(first.getInd_user_first_name(), is("太郎"));
    assertThat(first.getUpd_user_last_name(), is("永和"));
    assertThat(first.getUpd_user_first_name(), is("花子"));
    // 2件目
    TreatmentRecordServiceImpl.RstCondInfo second = result.get("2");
    assertThat(second.getUnit(), is("錠"));
    assertThat(second.getValue(), is(101));
    assertThat(second.getInd_user_id(), is(4L));
    assertNull(second.getInput_class());
    assertThat(second.getIs_editable(), is("1"));
    assertThat(second.getUpd_user_id(), is(5L));
    assertNull(second.getCop_order_no());
    assertNull(second.getValue_name_1());
    assertNull(second.getValue_name_2());
    assertNull(second.getMedicine_type());
    assertThat(second.getInd_user_last_name(), is("永和"));
    assertThat(second.getInd_user_first_name(), is("花子"));
    assertThat(second.getUpd_user_last_name(), is("日機装"));
    assertThat(second.getUpd_user_first_name(), is("太郎"));
  }

  /**
   * getRstCondInfo(String)の検証.
   * <p>
   *   条件:不正な治療条件のJSON文字列を指定する.
   *   結果:nullが返却される事.
   * </p>
   */
  @Test
  public void test_getRstCondInfoMap_異常_治療条件ではないJSON文字列を指定() throws Throwable {
    // テストで使用する治療条件のJSON文字列
    String condInfo = "{\"1\": {\"aaa\": \"bbb\", \"ccc\": \"ddd\"}}";
    // 実行
    Map<String, TreatmentRecordServiceImpl.RstCondInfo> result = invokeGetRstCondInfoMap(condInfo);
    // 検証
    assertNull(result);
  }

  /**
   * clearRstCondInfoByKey(privateメソッド)をinvokeする.
   *
   * @param rstCondInfoMap 治療条件のJSON文字列を治療条件項目番号をキーに格納したマップ
   * @param targetCondInfoKey クリアするキーの配列
   * @param userId クリアした際に設定する利用者ID
   * @return クリア後のマップ
   */
  private Map<String, TreatmentRecordServiceImpl.RstCondInfo> invokeClearRstCondInfoByKey(
      Map<String, TreatmentRecordServiceImpl.RstCondInfo> rstCondInfoMap,
      String[] targetCondInfoKey,
      Long userId) throws Throwable {
    try{
      Method method = TreatmentRecordServiceImpl.class.getDeclaredMethod("clearRstCondInfoByKey", Map.class, String[].class, Long.class);
      method.setAccessible(true);
      return (Map<String, TreatmentRecordServiceImpl.RstCondInfo>) method.invoke(target, rstCondInfoMap, targetCondInfoKey, userId);
    } catch (NoSuchMethodException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
    }
    return null;
  }

  /**
   * clearRestCondInfoByKeyの検証.
   * <p>
   *   条件:クリア対象に存在するキーを指定
   *   結果:クリア対象に指定したキーの治療条件の各項目がnullである事
   * </p>
   */
  @Test
  public void test_clearRstCondInfoByKey_正常_クリア対象に存在するキーを指定() throws Throwable {
    // 事前準備
    Long userId = 10L;
    String condInfo = "{\"1\": {\"unit\": \"組\", \"value\": 100, \"ind_user_id\": 1, \"input_class\": \"1\", \"is_editable\": \"0\", \"upd_user_id\": 2, \"cop_order_no\": 999, \"value_name_1\": \"テスト1\", \"value_name_2\": \"テスト2\", \"medicine_type\": 1, \"ind_user_last_name\": \"日機装\", \"upd_user_last_name\": \"永和\", \"ind_user_first_name\": \"太郎\", \"upd_user_first_name\": \"花子\"}, \"2\": {\"unit\": \"錠\", \"value\": 101, \"ind_user_id\": 4, \"input_class\": null, \"is_editable\": \"1\", \"upd_user_id\": 5, \"cop_order_no\": null, \"value_name_1\": null, \"value_name_2\": null, \"medicine_type\": null, \"ind_user_last_name\": \"永和\", \"upd_user_last_name\": \"日機装\", \"ind_user_first_name\": \"花子\", \"upd_user_first_name\": \"太郎\"}}";
    // マップ生成
    Map<String, TreatmentRecordServiceImpl.RstCondInfo> targetRstCondInfoMap = invokeGetRstCondInfoMap(condInfo);
    // クリア対象のキー
    String[] targetKey = new String[]{"2"};
    // 戻り値
    MstPersonalUser expected = new MstPersonalUser();
    expected.setUserId(userId);
    expected.setUserLastName("テスト");
    expected.setUserFirstName("次郎");
    // Mock
    given(mstPersonalUserDao.selectById(userId)).willReturn(expected);
    // 実行
    Map<String, TreatmentRecordServiceImpl.RstCondInfo> result = invokeClearRstCondInfoByKey(targetRstCondInfoMap, targetKey, userId);

    // 検証
    verify(mstPersonalUserDao, times(1)).selectById(userId);
    assertThat(result.size(), is(2));
    // 1件目
    TreatmentRecordServiceImpl.RstCondInfo first = result.get("1");
    assertThat(first.getUnit(), is("組"));
    assertThat(first.getValue(), is(100));
    assertThat(first.getInd_user_id(), is(1L));
    assertThat(first.getInput_class(), is("1"));
    assertThat(first.getIs_editable(), is("0"));
    assertThat(first.getUpd_user_id(), is(2L));
    assertThat(first.getCop_order_no(), is(999L));
    assertThat(first.getValue_name_1(), is("テスト1"));
    assertThat(first.getValue_name_2(), is("テスト2"));
    assertThat(first.getMedicine_type(), is(1));
    assertThat(first.getInd_user_last_name(), is("日機装"));
    assertThat(first.getInd_user_first_name(), is("太郎"));
    assertThat(first.getUpd_user_last_name(), is("永和"));
    assertThat(first.getUpd_user_first_name(), is("花子"));
    // 2件目
    TreatmentRecordServiceImpl.RstCondInfo second = result.get("2");
    assertNull(second.getUnit());
    assertNull(second.getValue());
    assertThat(second.getInd_user_id(), is(4L));
    assertNull(second.getInput_class());
    assertThat(second.getIs_editable(), is("1"));
    assertThat(second.getUpd_user_id(), is(10L));
    assertNull(second.getCop_order_no());
    assertNull(second.getValue_name_1());
    assertNull(second.getValue_name_2());
    assertNull(second.getMedicine_type());
    assertThat(second.getInd_user_last_name(), is("永和"));
    assertThat(second.getInd_user_first_name(), is("花子"));
    assertThat(second.getUpd_user_last_name(), is("テスト"));
    assertThat(second.getUpd_user_first_name(), is("次郎"));
  }

  /**
   * clearRestCondInfoByKeyの検証.
   * <p>
   *   条件:クリア対象に存在しないキーを指定
   *   結果:引数で与えた治療条件と同じである事（間違った治療条件項目番号がクリアされない事)
   * </p>
   */
  @Test
  public void test_clearRstCondInfoByKey_正常_クリア対象に存在しないキーを指定() throws Throwable {
    // 事前準備
    Long userId = 10L;
    String condInfo = "{\"1\": {\"unit\": \"組\", \"value\": 100, \"ind_user_id\": 1, \"input_class\": \"1\", \"is_editable\": \"0\", \"upd_user_id\": 2, \"cop_order_no\": 999, \"value_name_1\": \"テスト1\", \"value_name_2\": \"テスト2\", \"medicine_type\": 1, \"ind_user_last_name\": \"日機装\", \"upd_user_last_name\": \"永和\", \"ind_user_first_name\": \"太郎\", \"upd_user_first_name\": \"花子\"}, \"2\": {\"unit\": \"錠\", \"value\": 101, \"ind_user_id\": 4, \"input_class\": null, \"is_editable\": \"1\", \"upd_user_id\": 5, \"cop_order_no\": null, \"value_name_1\": null, \"value_name_2\": null, \"medicine_type\": null, \"ind_user_last_name\": \"永和\", \"upd_user_last_name\": \"日機装\", \"ind_user_first_name\": \"花子\", \"upd_user_first_name\": \"太郎\"}}";
    // マップ生成
    Map<String, TreatmentRecordServiceImpl.RstCondInfo> targetRstCondInfoMap = invokeGetRstCondInfoMap(condInfo);
    // クリア対象のキー
    String[] targetKey = new String[]{"3"};
    // 戻り値
    MstPersonalUser expected = new MstPersonalUser();
    expected.setUserId(userId);
    expected.setUserLastName("テスト");
    expected.setUserFirstName("次郎");
    // Mock
    given(mstPersonalUserDao.selectById(userId)).willReturn(expected);
    // 実行
    Map<String, TreatmentRecordServiceImpl.RstCondInfo> result = invokeClearRstCondInfoByKey(targetRstCondInfoMap, targetKey, userId);

    // 検証
    verify(mstPersonalUserDao, times(1)).selectById(userId);
    assertThat(result.size(), is(2));
    // 1件目
    TreatmentRecordServiceImpl.RstCondInfo first = result.get("1");
    assertThat(first.getUnit(), is("組"));
    assertThat(first.getValue(), is(100));
    assertThat(first.getInd_user_id(), is(1L));
    assertThat(first.getInput_class(), is("1"));
    assertThat(first.getIs_editable(), is("0"));
    assertThat(first.getUpd_user_id(), is(2L));
    assertThat(first.getCop_order_no(), is(999L));
    assertThat(first.getValue_name_1(), is("テスト1"));
    assertThat(first.getValue_name_2(), is("テスト2"));
    assertThat(first.getMedicine_type(), is(1));
    assertThat(first.getInd_user_last_name(), is("日機装"));
    assertThat(first.getInd_user_first_name(), is("太郎"));
    assertThat(first.getUpd_user_last_name(), is("永和"));
    assertThat(first.getUpd_user_first_name(), is("花子"));
    // 2件目
    TreatmentRecordServiceImpl.RstCondInfo second = result.get("2");
    assertThat(second.getUnit(), is("錠"));
    assertThat(second.getValue(), is(101));
    assertThat(second.getInd_user_id(), is(4L));
    assertNull(second.getInput_class());
    assertThat(second.getIs_editable(), is("1"));
    assertThat(second.getUpd_user_id(), is(5L));
    assertNull(second.getCop_order_no());
    assertNull(second.getValue_name_1());
    assertNull(second.getValue_name_2());
    assertNull(second.getMedicine_type());
    assertThat(second.getInd_user_last_name(), is("永和"));
    assertThat(second.getInd_user_first_name(), is("花子"));
    assertThat(second.getUpd_user_last_name(), is("日機装"));
    assertThat(second.getUpd_user_first_name(), is("太郎"));
  }

  /**
   * clearRestCondInfoByKeyの検証.
   * <p>
   *   条件:利用者IDに存在する利用者IDを指定
   *   結果:クリア対象の治療条件の更新者ID及び更新者姓名が設定される事
   * </p>
   */
  @Test
  @Ignore
  public void test_clearRstCondInfoByKey_正常_利用者IDに存在する利用者IDを指定() {
    // test_clearRstCondInfoByKey_正常_クリア対象に存在するキーを指定 で検証済
  }

  /**
   * clearRestCondInfoByKeyの検証.
   * <p>
   *   条件:利用者IDに存在しない利用者IDを指定
   *   結果:クリア対象の治療条件の更新者IDが設定され、更新者姓名はnullである事
   * </p>
   */
  @Test
  public void test_clearRstCondInfoByKey_正常_利用者IDに存在しない利用者IDを指定() throws Throwable {
    // 事前準備
    Long userId = 11L;
    String condInfo = "{\"1\": {\"unit\": \"組\", \"value\": 100, \"ind_user_id\": 1, \"input_class\": \"1\", \"is_editable\": \"0\", \"upd_user_id\": 2, \"cop_order_no\": 999, \"value_name_1\": \"テスト1\", \"value_name_2\": \"テスト2\", \"medicine_type\": 1, \"ind_user_last_name\": \"日機装\", \"upd_user_last_name\": \"永和\", \"ind_user_first_name\": \"太郎\", \"upd_user_first_name\": \"花子\"}, \"2\": {\"unit\": \"錠\", \"value\": 101, \"ind_user_id\": 4, \"input_class\": null, \"is_editable\": \"1\", \"upd_user_id\": 5, \"cop_order_no\": null, \"value_name_1\": null, \"value_name_2\": null, \"medicine_type\": null, \"ind_user_last_name\": \"永和\", \"upd_user_last_name\": \"日機装\", \"ind_user_first_name\": \"花子\", \"upd_user_first_name\": \"太郎\"}}";
    // マップ生成
    Map<String, TreatmentRecordServiceImpl.RstCondInfo> targetRstCondInfoMap = invokeGetRstCondInfoMap(condInfo);
    // クリア対象のキー
    String[] targetKey = new String[]{"2"};
    // Mock
    given(mstPersonalUserDao.selectById(userId)).willReturn(null);
    // 実行
    Map<String, TreatmentRecordServiceImpl.RstCondInfo> result = invokeClearRstCondInfoByKey(targetRstCondInfoMap, targetKey, userId);

    // 検証
    verify(mstPersonalUserDao, times(1)).selectById(userId);
    assertThat(result.size(), is(2));
    // 1件目
    TreatmentRecordServiceImpl.RstCondInfo first = result.get("1");
    assertThat(first.getUnit(), is("組"));
    assertThat(first.getValue(), is(100));
    assertThat(first.getInd_user_id(), is(1L));
    assertThat(first.getInput_class(), is("1"));
    assertThat(first.getIs_editable(), is("0"));
    assertThat(first.getUpd_user_id(), is(2L));
    assertThat(first.getCop_order_no(), is(999L));
    assertThat(first.getValue_name_1(), is("テスト1"));
    assertThat(first.getValue_name_2(), is("テスト2"));
    assertThat(first.getMedicine_type(), is(1));
    assertThat(first.getInd_user_last_name(), is("日機装"));
    assertThat(first.getInd_user_first_name(), is("太郎"));
    assertThat(first.getUpd_user_last_name(), is("永和"));
    assertThat(first.getUpd_user_first_name(), is("花子"));
    // 2件目
    TreatmentRecordServiceImpl.RstCondInfo second = result.get("2");
    assertNull(second.getUnit());
    assertNull(second.getValue());
    assertThat(second.getInd_user_id(), is(4L));
    assertNull(second.getInput_class());
    assertThat(second.getIs_editable(), is("1"));
    assertThat(second.getUpd_user_id(), is(11L));
    assertNull(second.getCop_order_no());
    assertNull(second.getValue_name_1());
    assertNull(second.getValue_name_2());
    assertNull(second.getMedicine_type());
    assertThat(second.getInd_user_last_name(), is("永和"));
    assertThat(second.getInd_user_first_name(), is("花子"));
    assertNull(second.getUpd_user_last_name());
    assertNull(second.getUpd_user_first_name());
  }

  /**
   * getMstTreatmentCondInfo(privateメソッド)をinvokeする.
   *
   * @param condInfo 治療方法マスタの治療条件設定のJSON文字列
   * @return 治療方法マスタに登録された知慮条件設定を保持するマップ
   * @throws Throwable
   */
  private Map<String, String> invokeGetMstTreatmentCondInfo(String condInfo) throws Throwable {
    try {
      Method method = TreatmentRecordServiceImpl.class.getDeclaredMethod("getMstTreatmentCondInfo", String.class);
      method.setAccessible(true);
      return (Map<String, String>) method.invoke(target, condInfo);
    } catch (InvocationTargetException e) {
      throw e.getCause();
    } catch (NoSuchMethodException | IllegalAccessException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
    }
    return null;
  }

  /**
   * getMstTreatmentCondInfo(String)の検証
   * <p>
   *   条件:正しい治療条件項目設定のJSON文字列を指定
   *   結果:key:治療条件項目番号、value:使用有無が設定されたMapが返却される事
   * </p>
   */
  @Test
  public void test_getMstTreatmentCondInfo_正常_正しい治療条件項目設定のJSON文字列を指定() throws Throwable {
    // テストデータ
    String condInfo = "[{\"items\": [{\"ctl_no\": \"2\", \"is_use\": \"0\"}, {\"ctl_no\": \"5\", \"is_use\": \"1\"}, {\"ctl_no\": \"6\", \"is_use\": \"1\"}, {\"ctl_no\": \"7\", \"is_use\": \"1\"}, {\"ctl_no\": \"8\", \"is_use\": \"1\"}, {\"ctl_no\": \"13\", \"is_use\": \"1\"}, {\"ctl_no\": \"14\", \"is_use\": \"1\"}], \"category_no\": 1}, {\"items\": [{\"ctl_no\": \"4\", \"is_use\": \"0\"}, {\"ctl_no\": \"3\", \"is_use\": \"1\"}], \"category_no\": 2}]";
    // 実行
    Map<String, String> result = invokeGetMstTreatmentCondInfo(condInfo);
    // 検証
    assertThat(result.size(), is(9));
    // 全データの検証
    assertThat(result.get("2"), is("0"));
    assertThat(result.get("5"), is("1"));
    assertThat(result.get("6"), is("1"));
    assertThat(result.get("7"), is("1"));
    assertThat(result.get("8"), is("1"));
    assertThat(result.get("13"), is("1"));
    assertThat(result.get("14"), is("1"));
    assertThat(result.get("4"), is("0"));
    assertThat(result.get("3"), is("1"));
  }

  /**
   * getMstTreatmentCondInfo(String)の検証.
   * <p>
   *   条件:正しくない治療条件項目設定（配列ではない）のJSON文字列を指定
   *   結果:例外が発生する事
   * </p>
   */
  @Test(expected = JSONException.class)
  public void test_getMstTreatmentCondInfo_異常_正しくない治療条件項目設定のJSON文字列を指定() throws Throwable {
    // テストで使用する治療条件のJSON文字列
    String condInfo = "{\"1\": {\"aaa\": \"bbb\", \"ccc\": \"ddd\"}}";
    // 実行
    Map<String, String> result = invokeGetMstTreatmentCondInfo(condInfo);
  }

  /**
   * getMstTreatmentCondInfo(String)の検証.
   * <p>
   *   条件:正しくない治療条件項目設定(配列)のJSON文字列を指定
   *   結果:例外が発生する事
   * </p>
   */
  @Test(expected = JSONException.class)
  public void test_getMstTreatmentCondInfo_異常_正しくない配列の治療条件項目設定のJSON文字列を指定() throws Throwable {
    // テストで使用する治療条件のJSON文字列
    String condInfo = "[{\"1\": {\"aaa\": \"bbb\", \"ccc\": \"ddd\"}}]";
    // 実行
    Map<String, String> result = invokeGetMstTreatmentCondInfo(condInfo);
    // 検証
    assertTrue(result.isEmpty());
  }

  /**
   * {@link TreatmentRecordServiceImpl#updateTreatmentRecordResultWithCondition(Long, TreatmentRecordResult, int, Long)}の検証
   * <p>
   *   条件:治療条件に対する処理区分で「0:何もしない」を与える
   *   結果:治療条件取得処理が行われない事
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordResultWithCondition_正常_治療条件を更新しない処理区分の場合に治療条件取得の処理が行われない事() {
    // 事前準備
    Long ordNo = 1L;
    Long userId = 100L;
    // 実績情報
    TreatmentRecordResult expectTreatmentRecordResult = new TreatmentRecordResult();
    // 治療条件
    TreatmentRecordCondition expectTreatmentRecordCondition = new TreatmentRecordCondition();


    // Mock
    given(treatmentRecordDao.updateTreatmentRecordForResult(ordNo, expectTreatmentRecordResult)).willReturn(1);
    given(treatmentRecordDao.selectTreatmentRecordConditionByOrdNo(ordNo)).willReturn(expectTreatmentRecordCondition);
    // 実行
    target.updateTreatmentRecordResultWithCondition(ordNo, expectTreatmentRecordResult, 0, userId);
    // 検証
    verify(treatmentRecordDao, times(1)).updateTreatmentRecordForResult(ordNo, expectTreatmentRecordResult);
    verify(treatmentRecordDao, times(0)).selectTreatmentRecordConditionByOrdNo(ordNo);
  }

  /**
   * {@link TreatmentRecordServiceImpl#updateTreatmentRecordResultWithCondition(Long, TreatmentRecordResult, int, Long)}の検証
   * <p>
   *   条件:治療条件に対する処理区分で「1:補液に透析液を設定」を与え、オーダ番号に該当するオーダが存在しない
   *   結果:治療条件が更新されない事
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordResultWithCondition_正常_治療条件を更新する処理区分の場合で該当のオーダ番号が存在しない場合に更新が行われない事() {
    // 事前準備
    Long ordNo = 1L;
    Long userId = 100L;
    // 実績情報
    TreatmentRecordResult expectTreatmentRecordResult = new TreatmentRecordResult();

    // Mock
    given(treatmentRecordDao.updateTreatmentRecordForResult(ordNo, expectTreatmentRecordResult)).willReturn(1);
    given(treatmentRecordDao.selectTreatmentRecordConditionByOrdNo(ordNo)).willReturn(null);
    // 実行
    target.updateTreatmentRecordResultWithCondition(ordNo, expectTreatmentRecordResult, 1, userId);
    // 検証
    verify(treatmentRecordDao, times(1)).updateTreatmentRecordForResult(ordNo, expectTreatmentRecordResult);
    verify(treatmentRecordDao, times(1)).selectTreatmentRecordConditionByOrdNo(ordNo);
    verify(treatmentRecordDao, times(0)).updateTreatmentRecordForCondition(ordNo, new TreatmentRecordCondition());
  }

  /**
   * {@link TreatmentRecordServiceImpl#updateTreatmentRecordResultWithCondition(Long, TreatmentRecordResult, int, Long)}の検証
   * <p>
   *   条件:治療条件に対する処理区分で「1:補液に透析液を設定」を与え、オーダ番号に該当する治療条件がnull
   *   結果:治療条件が更新されない事
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordResultWithCondition_正常_治療条件を更新する処理区分の場合に治療条件がnulｌの場合に更新が行われない事() {
    // 事前準備
    Long ordNo = 1L;
    Long userId = 100L;
    // 実績情報
    TreatmentRecordResult expectTreatmentRecordResult = new TreatmentRecordResult();
    // 治療条件
    TreatmentRecordCondition expectTreatmentRecordCondition = new TreatmentRecordCondition();

    // Mock
    given(treatmentRecordDao.updateTreatmentRecordForResult(ordNo, expectTreatmentRecordResult)).willReturn(1);
    given(treatmentRecordDao.selectTreatmentRecordConditionByOrdNo(ordNo)).willReturn(expectTreatmentRecordCondition);
    // 実行
    target.updateTreatmentRecordResultWithCondition(ordNo, expectTreatmentRecordResult, 1, userId);
    // 検証
    verify(treatmentRecordDao, times(1)).updateTreatmentRecordForResult(ordNo, expectTreatmentRecordResult);
    verify(treatmentRecordDao, times(1)).selectTreatmentRecordConditionByOrdNo(ordNo);
    verify(treatmentRecordDao, times(0)).updateTreatmentRecordForCondition(ordNo, new TreatmentRecordCondition());
  }

  /**
   * {@link TreatmentRecordServiceImpl#updateTreatmentRecordResultWithCondition(Long, TreatmentRecordResult, int, Long)}の検証
   * <p>
   *   条件:治療条件に対する処理区分で「1:補液に透析液を設定」を与える
   *   結果:補液に透析液が設定される事
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordResultWithCondition_正常_補液に透析液が設定される事() throws Throwable {
    // 事前準備
    Long ordNo = 1L;
    Long userId = 100L;
    // 実績情報
    TreatmentRecordResult expectTreatmentRecordResult = new TreatmentRecordResult();
    // 治療条件（更新前）
    TreatmentRecordCondition beforeTreatmentRecordCondition = new TreatmentRecordCondition();
    String condInfo = "{\"15\": {\"unit\": null, \"value\": 6, \"ind_user_id\": 10, \"input_class\": \"1\", \"is_editable\": \"1\", \"upd_user_id\": 10, \"cop_order_no\": null, \"value_name_1\": \"Ｄドライ透析剤２．５Ｓ\", \"value_name_2\": null, \"medicine_type\": null, \"ind_user_last_name\": \"テス４\", \"upd_user_last_name\": \"テス４\", \"ind_user_first_name\": \"太郎４\", \"upd_user_first_name\": \"太郎４\"},\"19\": {\"unit\": \"袋\", \"value\": 11, \"ind_user_id\": 10, \"input_class\": null, \"is_editable\": \"1\", \"upd_user_id\": 10, \"cop_order_no\": null, \"value_name_1\": \"ネスプ2\", \"value_name_2\": null, \"medicine_type\": null, \"ind_user_last_name\": \"テス４\", \"upd_user_last_name\": \"テス４\", \"ind_user_first_name\": \"太郎４\", \"upd_user_first_name\": \"太郎４\"}, \"20\": {\"unit\": null, \"value\": null, \"ind_user_id\": 10, \"input_class\": null, \"is_editable\": \"1\", \"upd_user_id\": 10, \"cop_order_no\": null, \"value_name_1\": null, \"value_name_2\": null, \"medicine_type\": null, \"ind_user_last_name\": \"テス４\", \"upd_user_last_name\": \"テス４\", \"ind_user_first_name\": \"太郎４\", \"upd_user_first_name\": \"太郎４\"}}";
    beforeTreatmentRecordCondition.setRstCondInfo(condInfo);
    // 治療条件(更新後)
    String afterCondInfo = "{\"15\": {\"unit\": null, \"value\": 6, \"ind_user_id\": 10, \"input_class\": \"1\", \"is_editable\": \"1\", \"upd_user_id\": 10, \"cop_order_no\": null, \"value_name_1\": \"Ｄドライ透析剤２．５Ｓ\", \"value_name_2\": null, \"medicine_type\": null, \"ind_user_last_name\": \"テス４\", \"upd_user_last_name\": \"テス４\", \"ind_user_first_name\": \"太郎４\", \"upd_user_first_name\": \"太郎４\"},\"19\":  {\"unit\": null, \"value\": 6, \"ind_user_id\": 10, \"input_class\": \"1\", \"is_editable\": \"1\", \"upd_user_id\": 100, \"cop_order_no\": null, \"value_name_1\": \"Ｄドライ透析剤２．５Ｓ\", \"value_name_2\": null, \"medicine_type\": null, \"ind_user_last_name\": \"テス４\", \"upd_user_last_name\": \"テスト\", \"ind_user_first_name\": \"太郎４\", \"upd_user_first_name\": \"次郎\"}, \"20\": {\"unit\": null, \"value\": null, \"ind_user_id\": 10, \"input_class\": null, \"is_editable\": \"1\", \"upd_user_id\": 10, \"cop_order_no\": null, \"value_name_1\": null, \"value_name_2\": null, \"medicine_type\": null, \"ind_user_last_name\": \"テス４\", \"upd_user_last_name\": \"テス４\", \"ind_user_first_name\": \"太郎４\", \"upd_user_first_name\": \"太郎４\"}}";
    final TreatmentRecordCondition afterTreatmentRecordCondition = beforeTreatmentRecordCondition;
    afterTreatmentRecordCondition.setRstCondInfo(afterCondInfo);
    // 利用者
    MstPersonalUser expected = new MstPersonalUser();
    expected.setUserId(userId);
    expected.setUserLastName("テスト");
    expected.setUserFirstName("次郎");

    // Mock
    given(treatmentRecordDao.updateTreatmentRecordForResult(ordNo, expectTreatmentRecordResult)).willReturn(1);
    given(treatmentRecordDao.selectTreatmentRecordConditionByOrdNo(ordNo)).willReturn(beforeTreatmentRecordCondition);
    given(mstPersonalUserDao.selectById(userId)).willReturn(expected);

    final ArgumentCaptor<Long> ordNoCaptor = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<TreatmentRecordCondition> updateCaptor = ArgumentCaptor.forClass(TreatmentRecordCondition.class);
    given(treatmentRecordDao.updateTreatmentRecordForCondition(ordNoCaptor.capture(), updateCaptor.capture())).willReturn(1);

    // 実行
    target.updateTreatmentRecordResultWithCondition(ordNo, expectTreatmentRecordResult, 1, userId);
    // 検証
    verify(treatmentRecordDao, times(1)).updateTreatmentRecordForResult(ordNo, expectTreatmentRecordResult);
    verify(treatmentRecordDao, times(1)).selectTreatmentRecordConditionByOrdNo(ordNo);
    verify(treatmentRecordDao, times(1)).updateTreatmentRecordForCondition(ordNo, afterTreatmentRecordCondition);

    final Long updateOrdNo = ordNoCaptor.getValue();
    assertThat(updateOrdNo, is(ordNo));
    final TreatmentRecordCondition updated = updateCaptor.getValue();
    assertThat(invokeGetRstCondInfoMap(updated.getRstCondInfo()), is(invokeGetRstCondInfoMap(afterCondInfo)));
  }

  /**
   * {@link TreatmentRecordServiceImpl#updateTreatmentRecordResultWithCondition(Long, TreatmentRecordResult, int, Long)}の検証
   * <p>
   *   条件:透析液が存在しない
   *   結果:治療条件の更新処理が行われない事
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordResultWithCondition_正常_透析液がない場合に治療条件の更新処理が行われない事() throws Throwable {
    // 事前準備
    Long ordNo = 1L;
    Long userId = 100L;
    // 実績情報
    TreatmentRecordResult expectTreatmentRecordResult = new TreatmentRecordResult();
    // 治療条件（更新前）
    TreatmentRecordCondition beforeTreatmentRecordCondition = new TreatmentRecordCondition();
    String condInfo = "{\"19\": {\"unit\": \"袋\", \"value\": 11, \"ind_user_id\": 10, \"input_class\": null, \"is_editable\": \"1\", \"upd_user_id\": 10, \"cop_order_no\": null, \"value_name_1\": \"ネスプ2\", \"value_name_2\": null, \"medicine_type\": null, \"ind_user_last_name\": \"テス４\", \"upd_user_last_name\": \"テス４\", \"ind_user_first_name\": \"太郎４\", \"upd_user_first_name\": \"太郎４\"}, \"20\": {\"unit\": null, \"value\": null, \"ind_user_id\": 10, \"input_class\": null, \"is_editable\": \"1\", \"upd_user_id\": 10, \"cop_order_no\": null, \"value_name_1\": null, \"value_name_2\": null, \"medicine_type\": null, \"ind_user_last_name\": \"テス４\", \"upd_user_last_name\": \"テス４\", \"ind_user_first_name\": \"太郎４\", \"upd_user_first_name\": \"太郎４\"}}";
    beforeTreatmentRecordCondition.setRstCondInfo(condInfo);

    // Mock
    given(treatmentRecordDao.updateTreatmentRecordForResult(ordNo, expectTreatmentRecordResult)).willReturn(1);
    given(treatmentRecordDao.selectTreatmentRecordConditionByOrdNo(ordNo)).willReturn(beforeTreatmentRecordCondition);

    // 実行
    target.updateTreatmentRecordResultWithCondition(ordNo, expectTreatmentRecordResult, 1, userId);
    // 検証
    verify(treatmentRecordDao, times(1)).updateTreatmentRecordForResult(ordNo, expectTreatmentRecordResult);
    verify(treatmentRecordDao, times(1)).selectTreatmentRecordConditionByOrdNo(ordNo);
    verify(treatmentRecordDao, times(0)).updateTreatmentRecordForCondition(ordNo, new TreatmentRecordCondition());
  }

  /**
   * {@link TreatmentRecordServiceImpl#updateTreatmentRecordResultWithCondition(Long, TreatmentRecordResult, int, Long)}の検証
   * <p>
   *   条件:補液が存在しない
   *   結果:補液に透析液が設定される事
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordResultWithCondition_正常_補液がない場合に治療条件の更新処理が行わなれる事() throws Throwable {
    // 事前準備
    Long ordNo = 1L;
    Long userId = 100L;
    // 実績情報
    TreatmentRecordResult expectTreatmentRecordResult = new TreatmentRecordResult();
    // 治療条件（更新前）
    TreatmentRecordCondition beforeTreatmentRecordCondition = new TreatmentRecordCondition();
    String condInfo = "{\"15\": {\"unit\": null, \"value\": 6, \"ind_user_id\": 10, \"input_class\": \"1\", \"is_editable\": \"1\", \"upd_user_id\": 10, \"cop_order_no\": null, \"value_name_1\": \"Ｄドライ透析剤２．５Ｓ\", \"value_name_2\": null, \"medicine_type\": null, \"ind_user_last_name\": \"テス４\", \"upd_user_last_name\": \"テス４\", \"ind_user_first_name\": \"太郎４\", \"upd_user_first_name\": \"太郎４\"}, \"20\": {\"unit\": null, \"value\": null, \"ind_user_id\": 10, \"input_class\": null, \"is_editable\": \"1\", \"upd_user_id\": 10, \"cop_order_no\": null, \"value_name_1\": null, \"value_name_2\": null, \"medicine_type\": null, \"ind_user_last_name\": \"テス４\", \"upd_user_last_name\": \"テス４\", \"ind_user_first_name\": \"太郎４\", \"upd_user_first_name\": \"太郎４\"}}";
    beforeTreatmentRecordCondition.setRstCondInfo(condInfo);
    // 治療条件(更新後)
    String afterCondInfo = "{\"15\": {\"unit\": null, \"value\": 6, \"ind_user_id\": 10, \"input_class\": \"1\", \"is_editable\": \"1\", \"upd_user_id\": 10, \"cop_order_no\": null, \"value_name_1\": \"Ｄドライ透析剤２．５Ｓ\", \"value_name_2\": null, \"medicine_type\": null, \"ind_user_last_name\": \"テス４\", \"upd_user_last_name\": \"テス４\", \"ind_user_first_name\": \"太郎４\", \"upd_user_first_name\": \"太郎４\"},\"19\":  {\"unit\": null, \"value\": 6, \"ind_user_id\": 10, \"input_class\": \"1\", \"is_editable\": \"1\", \"upd_user_id\": 100, \"cop_order_no\": null, \"value_name_1\": \"Ｄドライ透析剤２．５Ｓ\", \"value_name_2\": null, \"medicine_type\": null, \"ind_user_last_name\": \"テス４\", \"upd_user_last_name\": \"テスト\", \"ind_user_first_name\": \"太郎４\", \"upd_user_first_name\": \"次郎\"}, \"20\": {\"unit\": null, \"value\": null, \"ind_user_id\": 10, \"input_class\": null, \"is_editable\": \"1\", \"upd_user_id\": 10, \"cop_order_no\": null, \"value_name_1\": null, \"value_name_2\": null, \"medicine_type\": null, \"ind_user_last_name\": \"テス４\", \"upd_user_last_name\": \"テス４\", \"ind_user_first_name\": \"太郎４\", \"upd_user_first_name\": \"太郎４\"}}";
    final TreatmentRecordCondition afterTreatmentRecordCondition = beforeTreatmentRecordCondition;
    afterTreatmentRecordCondition.setRstCondInfo(afterCondInfo);
    // 利用者
    MstPersonalUser expected = new MstPersonalUser();
    expected.setUserId(userId);
    expected.setUserLastName("テスト");
    expected.setUserFirstName("次郎");

    // Mock
    given(treatmentRecordDao.updateTreatmentRecordForResult(ordNo, expectTreatmentRecordResult)).willReturn(1);
    given(treatmentRecordDao.selectTreatmentRecordConditionByOrdNo(ordNo)).willReturn(beforeTreatmentRecordCondition);
    given(mstPersonalUserDao.selectById(userId)).willReturn(expected);

    final ArgumentCaptor<Long> ordNoCaptor = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<TreatmentRecordCondition> updateCaptor = ArgumentCaptor.forClass(TreatmentRecordCondition.class);
    given(treatmentRecordDao.updateTreatmentRecordForCondition(ordNoCaptor.capture(), updateCaptor.capture())).willReturn(1);

    // 実行
    target.updateTreatmentRecordResultWithCondition(ordNo, expectTreatmentRecordResult, 1, userId);
    // 検証
    verify(treatmentRecordDao, times(1)).updateTreatmentRecordForResult(ordNo, expectTreatmentRecordResult);
    verify(treatmentRecordDao, times(1)).selectTreatmentRecordConditionByOrdNo(ordNo);
    verify(treatmentRecordDao, times(1)).updateTreatmentRecordForCondition(ordNo, afterTreatmentRecordCondition);

    final Long updateOrdNo = ordNoCaptor.getValue();
    assertThat(updateOrdNo, is(ordNo));
    final TreatmentRecordCondition updated = updateCaptor.getValue();
    assertThat(invokeGetRstCondInfoMap(updated.getRstCondInfo()), is(invokeGetRstCondInfoMap(afterCondInfo)));
  }

  /**
   * {@link TreatmentRecordServiceImpl#updateTreatmentRecordResultWithCondition(Long, TreatmentRecordResult, int, Long)}の検証
   * <p>
   *   条件:存在しない利用者IDを指定
   *   結果:補液の更新者姓名がnulｌである事
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordResultWithCondition_正常_存在しない利用者IDを指定した場合に補液に更新者姓名にnullが設定される事() throws Throwable {
    // 事前準備
    Long ordNo = 1L;
    Long userId = 100L;
    // 実績情報
    TreatmentRecordResult expectTreatmentRecordResult = new TreatmentRecordResult();
    // 治療条件（更新前）
    TreatmentRecordCondition beforeTreatmentRecordCondition = new TreatmentRecordCondition();
    String condInfo = "{\"15\": {\"unit\": null, \"value\": 6, \"ind_user_id\": 10, \"input_class\": \"1\", \"is_editable\": \"1\", \"upd_user_id\": 10, \"cop_order_no\": null, \"value_name_1\": \"Ｄドライ透析剤２．５Ｓ\", \"value_name_2\": null, \"medicine_type\": null, \"ind_user_last_name\": \"テス４\", \"upd_user_last_name\": \"テス４\", \"ind_user_first_name\": \"太郎４\", \"upd_user_first_name\": \"太郎４\"},\"19\": {\"unit\": \"袋\", \"value\": 11, \"ind_user_id\": 10, \"input_class\": null, \"is_editable\": \"1\", \"upd_user_id\": 10, \"cop_order_no\": null, \"value_name_1\": \"ネスプ2\", \"value_name_2\": null, \"medicine_type\": null, \"ind_user_last_name\": \"テス４\", \"upd_user_last_name\": \"テス４\", \"ind_user_first_name\": \"太郎４\", \"upd_user_first_name\": \"太郎４\"}, \"20\": {\"unit\": null, \"value\": null, \"ind_user_id\": 10, \"input_class\": null, \"is_editable\": \"1\", \"upd_user_id\": 10, \"cop_order_no\": null, \"value_name_1\": null, \"value_name_2\": null, \"medicine_type\": null, \"ind_user_last_name\": \"テス４\", \"upd_user_last_name\": \"テス４\", \"ind_user_first_name\": \"太郎４\", \"upd_user_first_name\": \"太郎４\"}}";
    beforeTreatmentRecordCondition.setRstCondInfo(condInfo);
    // 治療条件(更新後)
    String afterCondInfo = "{\"15\": {\"unit\": null, \"value\": 6, \"ind_user_id\": 10, \"input_class\": \"1\", \"is_editable\": \"1\", \"upd_user_id\": 10, \"cop_order_no\": null, \"value_name_1\": \"Ｄドライ透析剤２．５Ｓ\", \"value_name_2\": null, \"medicine_type\": null, \"ind_user_last_name\": \"テス４\", \"upd_user_last_name\": \"テス４\", \"ind_user_first_name\": \"太郎４\", \"upd_user_first_name\": \"太郎４\"},\"19\":  {\"unit\": null, \"value\": 6, \"ind_user_id\": 10, \"input_class\": \"1\", \"is_editable\": \"1\", \"upd_user_id\": 100, \"cop_order_no\": null, \"value_name_1\": \"Ｄドライ透析剤２．５Ｓ\", \"value_name_2\": null, \"medicine_type\": null, \"ind_user_last_name\": \"テス４\", \"upd_user_last_name\": null, \"ind_user_first_name\": \"太郎４\", \"upd_user_first_name\": null}, \"20\": {\"unit\": null, \"value\": null, \"ind_user_id\": 10, \"input_class\": null, \"is_editable\": \"1\", \"upd_user_id\": 10, \"cop_order_no\": null, \"value_name_1\": null, \"value_name_2\": null, \"medicine_type\": null, \"ind_user_last_name\": \"テス４\", \"upd_user_last_name\": \"テス４\", \"ind_user_first_name\": \"太郎４\", \"upd_user_first_name\": \"太郎４\"}}";
    final TreatmentRecordCondition afterTreatmentRecordCondition = beforeTreatmentRecordCondition;
    afterTreatmentRecordCondition.setRstCondInfo(afterCondInfo);

    // Mock
    given(treatmentRecordDao.updateTreatmentRecordForResult(ordNo, expectTreatmentRecordResult)).willReturn(1);
    given(treatmentRecordDao.selectTreatmentRecordConditionByOrdNo(ordNo)).willReturn(beforeTreatmentRecordCondition);
    given(mstPersonalUserDao.selectById(userId)).willReturn(null);

    final ArgumentCaptor<Long> ordNoCaptor = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<TreatmentRecordCondition> updateCaptor = ArgumentCaptor.forClass(TreatmentRecordCondition.class);
    given(treatmentRecordDao.updateTreatmentRecordForCondition(ordNoCaptor.capture(), updateCaptor.capture())).willReturn(1);

    // 実行
    target.updateTreatmentRecordResultWithCondition(ordNo, expectTreatmentRecordResult, 1, userId);
    // 検証
    verify(treatmentRecordDao, times(1)).updateTreatmentRecordForResult(ordNo, expectTreatmentRecordResult);
    verify(treatmentRecordDao, times(1)).selectTreatmentRecordConditionByOrdNo(ordNo);
    verify(treatmentRecordDao, times(1)).updateTreatmentRecordForCondition(ordNo, afterTreatmentRecordCondition);

    final Long updateOrdNo = ordNoCaptor.getValue();
    assertThat(updateOrdNo, is(ordNo));
    final TreatmentRecordCondition updated = updateCaptor.getValue();
    assertThat(invokeGetRstCondInfoMap(updated.getRstCondInfo()), is(invokeGetRstCondInfoMap(afterCondInfo)));
  }

  /**
   * {@link TreatmentRecordServiceImpl#updateTreatmentRecordResultWithCondition(Long, TreatmentRecordResult, int, Long)}の検証
   * <p>
   *   条件:処理区分に「2:治療方法マスタの条件設定に応じて対象外の項目をnullにする」を指定し、治療方法コードが未設定
   *   結果:更新処理が行われない事
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordResultWithCondition_異常_治療方法コードが設定されていない場合に更新処理が行われない事() {
    // 事前準備
    Long ordNo = 1L;
    Long userId = 100L;
    // 実績情報
    TreatmentRecordResult expectTreatmentRecordResult = new TreatmentRecordResult();
    // 治療方法コードにnullを指定
    expectTreatmentRecordResult.setRstTreatmentCd(null);
    // 治療条件（更新前）
    TreatmentRecordCondition beforeTreatmentRecordCondition = new TreatmentRecordCondition();
    String condInfo = "{\"15\": {\"unit\": null, \"value\": 6, \"ind_user_id\": 10, \"input_class\": \"1\", \"is_editable\": \"1\", \"upd_user_id\": 10, \"cop_order_no\": null, \"value_name_1\": \"Ｄドライ透析剤２．５Ｓ\", \"value_name_2\": null, \"medicine_type\": null, \"ind_user_last_name\": \"テス４\", \"upd_user_last_name\": \"テス４\", \"ind_user_first_name\": \"太郎４\", \"upd_user_first_name\": \"太郎４\"},\"19\": {\"unit\": \"袋\", \"value\": 11, \"ind_user_id\": 10, \"input_class\": null, \"is_editable\": \"1\", \"upd_user_id\": 10, \"cop_order_no\": null, \"value_name_1\": \"ネスプ2\", \"value_name_2\": null, \"medicine_type\": null, \"ind_user_last_name\": \"テス４\", \"upd_user_last_name\": \"テス４\", \"ind_user_first_name\": \"太郎４\", \"upd_user_first_name\": \"太郎４\"}, \"20\": {\"unit\": null, \"value\": null, \"ind_user_id\": 10, \"input_class\": null, \"is_editable\": \"1\", \"upd_user_id\": 10, \"cop_order_no\": null, \"value_name_1\": null, \"value_name_2\": null, \"medicine_type\": null, \"ind_user_last_name\": \"テス４\", \"upd_user_last_name\": \"テス４\", \"ind_user_first_name\": \"太郎４\", \"upd_user_first_name\": \"太郎４\"}}";
    beforeTreatmentRecordCondition.setRstCondInfo(condInfo);
    // Mock
    given(treatmentRecordDao.updateTreatmentRecordForResult(ordNo, expectTreatmentRecordResult)).willReturn(1);
    given(treatmentRecordDao.selectTreatmentRecordConditionByOrdNo(ordNo)).willReturn(beforeTreatmentRecordCondition);
    // 実行
    target.updateTreatmentRecordResultWithCondition(ordNo, expectTreatmentRecordResult, 2, userId);
    // 検証
    verify(treatmentRecordDao, times(1)).updateTreatmentRecordForResult(ordNo, expectTreatmentRecordResult);
    verify(treatmentRecordDao, times(1)).selectTreatmentRecordConditionByOrdNo(ordNo);
    verify(mstTreatmentDao, times(0)).selectByCd(1);
    verify(treatmentRecordDao, times(0)).updateTreatmentRecordForCondition(ordNo, new TreatmentRecordCondition());
  }

  /**
   * {@link TreatmentRecordServiceImpl#updateTreatmentRecordResultWithCondition(Long, TreatmentRecordResult, int, Long)}の検証
   * <p>
   *   条件:処理区分に「2:治療方法マスタの条件設定に応じて対象外の項目をnullにする」を指定し、治療方法コードに該当する治療方法マスタが存在しない
   *   結果:更新処理が行われない事
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordResultWithCondition_異常_治療方法コードに該当する治療方法マスタが存在しない場合に更新処理が行われない事() {
    // 事前準備
    Long ordNo = 1L;
    Long userId = 100L;
    Integer treatmentCd = 1;
    // 実績情報
    TreatmentRecordResult expectTreatmentRecordResult = new TreatmentRecordResult();
    // 治療方法コードを指定
    expectTreatmentRecordResult.setRstTreatmentCd(treatmentCd);
    // 治療条件（更新前）
    TreatmentRecordCondition beforeTreatmentRecordCondition = new TreatmentRecordCondition();
    String condInfo = "{\"15\": {\"unit\": null, \"value\": 6, \"ind_user_id\": 10, \"input_class\": \"1\", \"is_editable\": \"1\", \"upd_user_id\": 10, \"cop_order_no\": null, \"value_name_1\": \"Ｄドライ透析剤２．５Ｓ\", \"value_name_2\": null, \"medicine_type\": null, \"ind_user_last_name\": \"テス４\", \"upd_user_last_name\": \"テス４\", \"ind_user_first_name\": \"太郎４\", \"upd_user_first_name\": \"太郎４\"},\"19\": {\"unit\": \"袋\", \"value\": 11, \"ind_user_id\": 10, \"input_class\": null, \"is_editable\": \"1\", \"upd_user_id\": 10, \"cop_order_no\": null, \"value_name_1\": \"ネスプ2\", \"value_name_2\": null, \"medicine_type\": null, \"ind_user_last_name\": \"テス４\", \"upd_user_last_name\": \"テス４\", \"ind_user_first_name\": \"太郎４\", \"upd_user_first_name\": \"太郎４\"}, \"20\": {\"unit\": null, \"value\": null, \"ind_user_id\": 10, \"input_class\": null, \"is_editable\": \"1\", \"upd_user_id\": 10, \"cop_order_no\": null, \"value_name_1\": null, \"value_name_2\": null, \"medicine_type\": null, \"ind_user_last_name\": \"テス４\", \"upd_user_last_name\": \"テス４\", \"ind_user_first_name\": \"太郎４\", \"upd_user_first_name\": \"太郎４\"}}";
    beforeTreatmentRecordCondition.setRstCondInfo(condInfo);
    // Mock
    given(treatmentRecordDao.updateTreatmentRecordForResult(ordNo, expectTreatmentRecordResult)).willReturn(1);
    given(treatmentRecordDao.selectTreatmentRecordConditionByOrdNo(ordNo)).willReturn(beforeTreatmentRecordCondition);
    given(mstTreatmentDao.selectByCd(treatmentCd.intValue())).willReturn(null);
    // 実行
    target.updateTreatmentRecordResultWithCondition(ordNo, expectTreatmentRecordResult, 2, userId);
    // 検証
    verify(treatmentRecordDao, times(1)).updateTreatmentRecordForResult(ordNo, expectTreatmentRecordResult);
    verify(treatmentRecordDao, times(1)).selectTreatmentRecordConditionByOrdNo(ordNo);
    verify(mstTreatmentDao, times(1)).selectByCd(treatmentCd.intValue());
    verify(treatmentRecordDao, times(0)).updateTreatmentRecordForCondition(ordNo, new TreatmentRecordCondition());
  }

  /**
   * {@link TreatmentRecordServiceImpl#updateTreatmentRecordResultWithCondition(Long, TreatmentRecordResult, int, Long)}の検証
   * <p>
   *   条件:処理区分に「2:治療方法マスタの条件設定に応じて対象外の項目をnullにする」を指定し、治療方法コードに該当する治療方法マスタの治療条件設定が未設定
   *   結果:更新処理が行われない事
   * </p>
   */
  @Test
  public void test_updateTreatmentRecordResultWithCondition_異常_治療方法コードに該当する治療方法マスタの治療条件設定が未設定の場合に更新処理が行われない事() {
    // 事前準備
    Long ordNo = 1L;
    Long userId = 100L;
    Integer treatmentCd = 1;
    // 実績情報
    TreatmentRecordResult expectTreatmentRecordResult = new TreatmentRecordResult();
    // 治療方法コードを指定
    expectTreatmentRecordResult.setRstTreatmentCd(treatmentCd);
    // 治療条件（更新前）
    TreatmentRecordCondition beforeTreatmentRecordCondition = new TreatmentRecordCondition();
    String condInfo = "{\"15\": {\"unit\": null, \"value\": 6, \"ind_user_id\": 10, \"input_class\": \"1\", \"is_editable\": \"1\", \"upd_user_id\": 10, \"cop_order_no\": null, \"value_name_1\": \"Ｄドライ透析剤２．５Ｓ\", \"value_name_2\": null, \"medicine_type\": null, \"ind_user_last_name\": \"テス４\", \"upd_user_last_name\": \"テス４\", \"ind_user_first_name\": \"太郎４\", \"upd_user_first_name\": \"太郎４\"},\"19\": {\"unit\": \"袋\", \"value\": 11, \"ind_user_id\": 10, \"input_class\": null, \"is_editable\": \"1\", \"upd_user_id\": 10, \"cop_order_no\": null, \"value_name_1\": \"ネスプ2\", \"value_name_2\": null, \"medicine_type\": null, \"ind_user_last_name\": \"テス４\", \"upd_user_last_name\": \"テス４\", \"ind_user_first_name\": \"太郎４\", \"upd_user_first_name\": \"太郎４\"}, \"20\": {\"unit\": null, \"value\": null, \"ind_user_id\": 10, \"input_class\": null, \"is_editable\": \"1\", \"upd_user_id\": 10, \"cop_order_no\": null, \"value_name_1\": null, \"value_name_2\": null, \"medicine_type\": null, \"ind_user_last_name\": \"テス４\", \"upd_user_last_name\": \"テス４\", \"ind_user_first_name\": \"太郎４\", \"upd_user_first_name\": \"太郎４\"}}";
    beforeTreatmentRecordCondition.setRstCondInfo(condInfo);
    // 治療方法マスタ
    MstTreatment mstTreatment = new MstTreatment();
    mstTreatment.setTreatmentCd(treatmentCd);
    mstTreatment.setTreatmentConditionSetting(null);
    // Mock
    given(treatmentRecordDao.updateTreatmentRecordForResult(ordNo, expectTreatmentRecordResult)).willReturn(1);
    given(treatmentRecordDao.selectTreatmentRecordConditionByOrdNo(ordNo)).willReturn(beforeTreatmentRecordCondition);
    given(mstTreatmentDao.selectByCd(treatmentCd.intValue())).willReturn(mstTreatment);
    // 実行
    target.updateTreatmentRecordResultWithCondition(ordNo, expectTreatmentRecordResult, 2, userId);
    // 検証
    verify(treatmentRecordDao, times(1)).updateTreatmentRecordForResult(ordNo, expectTreatmentRecordResult);
    verify(treatmentRecordDao, times(1)).selectTreatmentRecordConditionByOrdNo(ordNo);
    verify(mstTreatmentDao, times(1)).selectByCd(treatmentCd.intValue());
    verify(treatmentRecordDao, times(0)).updateTreatmentRecordForCondition(ordNo, new TreatmentRecordCondition());
  }
}
