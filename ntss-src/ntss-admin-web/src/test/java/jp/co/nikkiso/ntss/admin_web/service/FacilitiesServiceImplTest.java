package jp.co.nikkiso.ntss.admin_web.service;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage;
import jp.co.nikkiso.ntss.admin_web.response.StaffFacilitySettingsResponse;
import jp.co.nikkiso.ntss.admin_web.response.facilities.FacilitiesResponse;
import jp.co.nikkiso.ntss.admin_web.response.facilities.StaffFacility;
import jp.co.nikkiso.ntss.admin_web.response.facilities.StaffFacilityResponse;
import jp.co.nikkiso.ntss.admin_web.service.facilities.FacilitiesService;
import jp.co.nikkiso.ntss.core.dao.FacilityDao;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstStaffFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstUserDao;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstStaffFacility;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.entity.custom.ChargeStaffFacility;
import jp.co.nikkiso.ntss.core.entity.custom.NoticeCounts;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.junit4.SpringRunner;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.hamcrest.Matchers.nullValue;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.anyList;
import static org.mockito.Mockito.anyLong;
import static org.mockito.Mockito.anyString;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

/**
 * FacilitiesServiceImplのテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
public class FacilitiesServiceImplTest {

  /**
   * テスト対象クラス.
   */
  @Autowired
  private FacilitiesService target;

  /**
   * 担当施設マスタDaoのMockBean.
   */
  @MockitoBean
  private MstStaffFacilityDao mstStaffFacilityDao;

  /**
   * 装置状態管理DaoのMockBean.
   */
  @MockitoBean
  private MntMachineStateDao mntMachineStateDao;

  /**
   * 利用者マスタDaoのMockBean.
   */
  @MockitoBean
  private MstUserDao mstUserDao;

  /**
   * 施設マスタDaoのMockBean.
   */
  @MockitoBean
  private MstFacilityDao mstFacilityDao;

  /**
   * 施設マスタ（ユーザメニュー系）DaoのMockBean.
   */
  @MockitoBean
  private FacilityDao facilityDao;

  /**
   * createFacilitiesResponseの検証.
   *
   * 条件：ユーザーに紐づく施設なし
   * 結果：それぞれ空のリストが設定されたResponseが返却されること
   */
  @Test
  public void test_createFacilitiesResponse_正常_該当施設なし() {

    // Mock化
    given(mstStaffFacilityDao.selectStaffFacilities(anyLong())).willReturn(Collections.emptyList());

    // 実行
    FacilitiesResponse result = target.createFacilitiesResponse(9999L, false);

    // 検証
    verify(mstStaffFacilityDao, times(1)).selectStaffFacilities(9999L);
    verify(mntMachineStateDao, times(0)).selectNoticeCounts(anyString());
    assertThat(result, notNullValue());
    assertThat(result.departmentCds, is(Collections.emptyList()));
    assertThat(result.prefectures, is(Collections.emptyList()));
    assertThat(result.facilities, is(Collections.emptyList()));

  }

  /**
   * createFacilitiesResponseの検証.
   *
   * 条件：各項目の通知件数0件
   * 結果：通知0件の施設が取得できること
   */
  @Test
  public void test_createFacilitiesResponse_正常_施設１件_通知件数0() {

    // 事前準備
    ChargeStaffFacility f = new ChargeStaffFacility() {
      {
        setFacilityCd("facCd");
        setFacilityName("facName");
        setFacilityNameKana("facNameKana");
        setDepartmentCd("depCd");
        setPrefecturesCd("prefCd");
        setPrefecturesName("prefName");
      }
    };
    List<ChargeStaffFacility> staffFacilities = Arrays.asList(f);

    // Mock化
    given(mstStaffFacilityDao.selectStaffFacilities(anyLong())).willReturn(staffFacilities);
    // 通知件数取得でnullを返させる
    given(mntMachineStateDao.selectNoticeCounts(anyString())).willReturn(null);

    // 実行
    FacilitiesResponse result = target.createFacilitiesResponse(1L, false);

    // 検証
    verify(mstStaffFacilityDao, times(1)).selectStaffFacilities(1L);
    verify(mntMachineStateDao, times(1)).selectNoticeCounts("facCd");
    assertThat(result, notNullValue());
    assertThat(result.facilities, hasSize(1));
    assertThat(result.facilities.get(0).facilityCd, is("facCd"));
    assertThat(result.facilities.get(0).facilityName, is("facName"));
    assertThat(result.facilities.get(0).facilityNameKana, is("facNameKana"));
    assertThat(result.facilities.get(0).prefecturesCd, is("prefCd"));
    assertThat(result.facilities.get(0).prefecuturesName, is("prefName"));
    assertThat(result.facilities.get(0).comProblemCnt, is(0));
    assertThat(result.facilities.get(0).mNoticeCnt, is(0));
    assertThat(result.facilities.get(0).preventiveCnt, is(0));
    assertThat(result.facilities.get(0).serviceSupportCnt, is(0));
    assertThat(result.departmentCds, hasSize(1));
    assertThat(result.departmentCds.get(0), is("depCd"));
    assertThat(result.prefectures, hasSize(1));
    assertThat(result.prefectures.get(0), is(Arrays.asList("prefCd", "prefName")));

  }

  /**
   * createFacilitiesResponseの検証.
   *
   * 条件：部署符号・都道府県に重複なし、通知あり
   * 結果：重複を除外した部署符号・都道府県のリストが返却されること、通知件数が取得できること
   */
  @Test
  public void test_createFacilitiesResponse_正常_部署符号と都道府県の重複なし() {

    // 事前準備
    ChargeStaffFacility f1 = new ChargeStaffFacility() {
      {
        setFacilityCd("facCd1");
        setDepartmentCd("depCd1");
        setPrefecturesCd("prefCd1");
        setPrefecturesName("prefName1");
      }
    };
    ChargeStaffFacility f2 = new ChargeStaffFacility() {
      {
        setFacilityCd("facCd2");
        setDepartmentCd("depCd2");
        setPrefecturesCd("prefCd2");
        setPrefecturesName("prefName2");
      }
    };
    NoticeCounts count = new NoticeCounts() {
      {
        setComProblemCnt(3);
        setMNoticeCnt(2);
        setPreventiveCnt(1);
        setServiceSupportCnt(10);
      }
    };

    // Mock化
    given(mstStaffFacilityDao.selectStaffFacilities(anyLong())).willReturn(Arrays.asList(f1, f2));
    given(mntMachineStateDao.selectNoticeCounts("facCd1")).willReturn(count);
    given(mntMachineStateDao.selectNoticeCounts("facCd2")).willReturn(null);

    // 実行
    FacilitiesResponse result = target.createFacilitiesResponse(1L, false);

    // 検証
    verify(mntMachineStateDao, times(1)).selectNoticeCounts("facCd1");
    verify(mntMachineStateDao, times(1)).selectNoticeCounts("facCd2");
    assertThat(result.facilities, notNullValue());
    assertThat(result.facilities, hasSize(2));
    assertThat(result.facilities.get(0).facilityCd, is("facCd1"));
    assertThat(result.facilities.get(0).comProblemCnt, is(3));
    assertThat(result.facilities.get(0).mNoticeCnt, is(2));
    assertThat(result.facilities.get(0).preventiveCnt, is(1));
    assertThat(result.facilities.get(0).serviceSupportCnt, is(10));
    assertThat(result.facilities.get(1).facilityCd, is("facCd2"));
    assertThat(result.facilities.get(1).comProblemCnt, is(0));
    assertThat(result.facilities.get(1).mNoticeCnt, is(0));
    assertThat(result.facilities.get(1).preventiveCnt, is(0));
    assertThat(result.departmentCds, hasSize(2));
    assertThat(result.departmentCds.get(0), is("depCd1"));
    assertThat(result.departmentCds.get(1), is("depCd2"));
    assertThat(result.prefectures, hasSize(2));
    assertThat(result.prefectures.get(0), is(Arrays.asList("prefCd1", "prefName1")));
    assertThat(result.prefectures.get(1), is(Arrays.asList("prefCd2", "prefName2")));

  }

  /**
   * createFacilitiesResponseの検証.
   *
   * 条件：部署符号・都道府県の重複あり
   * 結果：部署符号と都道府県は重複が除外されやリストが返却されること
   */
  @Test
  public void test_createFacilitiesResponse_正常_部署符号と都道府県の重複あり() {

    // 事前準備
    ChargeStaffFacility f1 = new ChargeStaffFacility() {
      {
        setFacilityCd("facCd1");
        setDepartmentCd("depCd1");
        setPrefecturesCd("prefCd1");
        setPrefecturesName("prefName1");
      }
    };
    ChargeStaffFacility f2 = new ChargeStaffFacility() {
      {
        setFacilityCd("facCd2");
        setDepartmentCd("depCd2");
        setPrefecturesCd("prefCd2");
        setPrefecturesName("prefName2");
      }
    };
    ChargeStaffFacility f3 = new ChargeStaffFacility() {
      {
        setFacilityCd("facCd3");
        // f1と重複する値
        setDepartmentCd("depCd1");
        setPrefecturesCd("prefCd1");
        setPrefecturesName("prefName1");
      }
    };

    // Mock化
    given(mstStaffFacilityDao.selectStaffFacilities(anyLong())).willReturn(Arrays.asList(f1, f2, f3));
    given(mntMachineStateDao.selectNoticeCounts(anyString())).willReturn(null);

    // 実行
    FacilitiesResponse result = target.createFacilitiesResponse(1L, false);

    // 検証
    assertThat(result.facilities, notNullValue());
    assertThat(result.facilities, hasSize(3));
    assertThat(result.departmentCds, hasSize(2));
    assertThat(result.departmentCds.get(0), is("depCd1"));
    assertThat(result.departmentCds.get(1), is("depCd2"));
    assertThat(result.prefectures, hasSize(2));
    assertThat(result.prefectures.get(0), is(Arrays.asList("prefCd1", "prefName1")));
    assertThat(result.prefectures.get(1), is(Arrays.asList("prefCd2", "prefName2")));

  }

  /**
   * getStaffFacilityの検証.
   *
   * 条件：ユーザーに紐づく施設なし
   * 結果：空のリストが設定されたResponseが返却されること
   */
  @Test
  public void test_getStaffFacility_正常_件数0件() {
    // Mock化
    given(mstStaffFacilityDao.selectChargeStaffFacilities(anyLong())).willReturn(Collections.emptyList());

    // 実行
    StaffFacilityResponse result = target.getStaffFacility(1L);

    // 検証
    verify(mstStaffFacilityDao, times(1)).selectChargeStaffFacilities(1L);
    assertThat(result, notNullValue());
    assertThat(result.staffFacilities, is(Collections.emptyList()));
  }

  /**
   * getStaffFacilityの検証.
   *
   * 条件：ユーザーに紐づく施設が2件存在
   * 結果：担当施設2件のリストが設定されたResponseが返却されること
   */
  @Test
  public void test_getStaffFacility_正常_件数2件() {
    List<ChargeStaffFacility> list = Arrays.asList(
      new ChargeStaffFacility() {
        {
          setIsCharge(true);
          setFacilityCd("facilityCd1");
          setFacilityName("facilityName1");
          setFacilityNameKana("facilityNameKana1");
          setDepartmentCd("departmentCd1");
          setPrefecturesCd("prefecturesCd1");
          setPrefecturesName("prefName1");
        }
      },
     new ChargeStaffFacility() {
        {
          setIsCharge(false);
          setFacilityCd("facilityCd2");
          setFacilityName("facilityName2");
          setFacilityNameKana("facilityNameKana2");
          setDepartmentCd("departmentCd2");
          setPrefecturesCd("prefecturesCd2");
          setPrefecturesName("prefName2");
        }
      }
     );
    // Mock化
    given(mstStaffFacilityDao.selectChargeStaffFacilities(anyLong())).willReturn(list);

    // 実行
    StaffFacilityResponse result = target.getStaffFacility(1L);

    // 検証
    verify(mstStaffFacilityDao, times(1)).selectChargeStaffFacilities(1L);
    assertThat(result, notNullValue());
    assertThat(result.staffFacilities.size(), is(list.size()));
    for (int i = 0; i < list.size(); i++) {
      StaffFacility sf = result.staffFacilities.get(i);
      assertThat(sf.isCharge, is(list.get(i).getIsCharge()));
      assertThat(sf.facilityCd, is(list.get(i).getFacilityCd()));
      assertThat(sf.facilityName, is(list.get(i).getFacilityName()));
      assertThat(sf.facilityNameKana, is(list.get(i).getFacilityNameKana()));
      assertThat(sf.departmentCd, is(list.get(i).getDepartmentCd()));
      assertThat(sf.prefecturesCd, is(list.get(i).getPrefecturesCd()));
      assertThat(sf.prefecturesName, is(list.get(i).getPrefecturesName()));
    }
  }

  /**
   * updateStaffFacilityの検証.
   *
   * 条件：ユーザーに紐づく施設を1件登録
   * 結果：正常なResponseが返ってくること
   */
  @SuppressWarnings("unchecked")
  @Test
  public void test_updateStaffFacility_正常_登録件数1件() {
    Long userId = 1L;
    List<String> facilityCds = Arrays.asList("001");

    List<MstFacility> mstFacilityList = Arrays.asList(getMstFacility("001"));
    ArgumentCaptor<List<MstStaffFacility>> args = ArgumentCaptor.forClass(List.class);
    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(new MstUser());
    given(mstFacilityDao.selectAll()).willReturn(mstFacilityList);
    given(mstStaffFacilityDao.deleteByUserId(anyLong())).willReturn(1);
    given(mstStaffFacilityDao.insert(args.capture())).willReturn(new int[]{1});

    // 実行
    StaffFacilitySettingsResponse result = target.updateStaffFacility(userId, facilityCds);

    // 検証
    verify(mstUserDao, times(1)).selectById(userId);
    verify(mstFacilityDao, times(1)).selectAll();
    verify(mstStaffFacilityDao, times(1)).deleteByUserId(userId);
    verify(mstStaffFacilityDao, times(1)).insert(anyList());
    assertThat(args.getValue().size(), is(1));
    assertThat(args.getValue().get(0).getUserId(), is(userId));
    assertThat(args.getValue().get(0).getFacilityCd(), is(facilityCds.get(0)));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(true));
    assertThat(result.errorMessage, is(nullValue()));
  }

  /**
   * updateStaffFacilityの検証.
   *
   * 条件：ユーザーに紐づく施設を2件登録(施設コードの重複あり)
   * 結果：Daoから正常なResponseが返ってくること
   */
  @SuppressWarnings("unchecked")
  @Test
  public void test_updateStaffFacility_正常_登録件数2件_重複あり() {
    Long userId = 1L;
    List<String> facilityCds = Arrays.asList("001", "002", "002");

    List<MstFacility> mstFacilityList = Arrays.asList(
      getMstFacility("001"),
      getMstFacility("002")
    );
    ArgumentCaptor<List<MstStaffFacility>> args = ArgumentCaptor.forClass(List.class);
    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(new MstUser());
    given(mstFacilityDao.selectAll()).willReturn(mstFacilityList);
    given(mstStaffFacilityDao.deleteByUserId(anyLong())).willReturn(1);
    given(mstStaffFacilityDao.insert(args.capture())).willReturn(new int[]{1, 1});

    // 実行
    StaffFacilitySettingsResponse result = target.updateStaffFacility(userId, facilityCds);

    // 検証
    verify(mstUserDao, times(1)).selectById(userId);
    verify(mstFacilityDao, times(1)).selectAll();
    verify(mstStaffFacilityDao, times(1)).deleteByUserId(userId);
    verify(mstStaffFacilityDao, times(1)).insert(anyList());
    assertThat(args.getValue().size(), is(2));
    assertThat(args.getValue().get(0).getUserId(), is(userId));
    assertThat(args.getValue().get(0).getFacilityCd(), is("001"));
    assertThat(args.getValue().get(1).getUserId(), is(userId));
    assertThat(args.getValue().get(1).getFacilityCd(), is("002"));
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(true));
    assertThat(result.errorMessage, is(nullValue()));
  }

  /**
   * updateStaffFacilityの検証.
   *
   * 条件：登録施設0件
   * 結果：正常なResponseが返ってくること
   */
  @Test
  public void test_updateStaffFacility_正常_登録件数0件() {
    Long userId = 1L;
    List<String> facilityCds = Collections.emptyList();

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(new MstUser());
    given(mstStaffFacilityDao.deleteByUserId(anyLong())).willReturn(1);

    // 実行
    StaffFacilitySettingsResponse result = target.updateStaffFacility(userId, facilityCds);

    // 検証
    verify(mstUserDao, times(1)).selectById(userId);
    verify(mstFacilityDao, never()).selectAll();
    verify(mstStaffFacilityDao, times(1)).deleteByUserId(userId);
    verify(mstStaffFacilityDao, never()).insert(anyList());
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(true));
    assertThat(result.errorMessage, is(nullValue()));
  }

  /**
   * updateStaffFacilityの検証.
   *
   * 条件：該当ユーザーIDなし
   * 結果：失敗レスポンスが返ってくること
   */
  @Test
  public void test_updateStaffFacility_異常_ユーザーIDなし() {
    Long userId = 1L;
    List<String> facilityCds = Collections.emptyList();

    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(null);

    // 実行
    StaffFacilitySettingsResponse result = target.updateStaffFacility(userId, facilityCds);

    // 検証
    verify(mstUserDao, times(1)).selectById(userId);
    verify(mstFacilityDao, never()).selectAll();
    verify(mstStaffFacilityDao, never()).deleteByUserId(anyLong());
    verify(mstStaffFacilityDao, never()).insert(anyList());
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(false));
    assertThat(result.errorMessage, is(AdminWebMessage.Error.USER_ID_NOT_FOUND.getMessage()));
  }

  /**
   * updateStaffFacilityの検証.
   *
   * 条件：該当施設コードなし
   * 結果：失敗レスポンスが返ってくること
   */
  @Test
  public void test_updateStaffFacility_異常_施設コードなし() {
    Long userId = 1L;
    List<String> facilityCds = Arrays.asList("001", "002", "901");

    List<MstFacility> mstFacilityList = Arrays.asList(
      getMstFacility("001"),
      getMstFacility("002")
    );
    // Mock化
    given(mstUserDao.selectById(anyLong())).willReturn(new MstUser());
    given(mstFacilityDao.selectAll()).willReturn(mstFacilityList);

    // 実行
    StaffFacilitySettingsResponse result = target.updateStaffFacility(userId, facilityCds);

    // 検証
    verify(mstUserDao, times(1)).selectById(userId);
    verify(mstFacilityDao, times(1)).selectAll();
    verify(mstStaffFacilityDao, never()).deleteByUserId(anyLong());
    verify(mstStaffFacilityDao, never()).insert(anyList());
    assertThat(result, notNullValue());
    assertThat(result.isSuccess, is(false));
    assertThat(result.errorMessage, is(AdminWebMessage.Error.FACILITY_CD_NOT_FOUND.getMessage()));
  }

  /**
   * getUseFunctionsの検証.
   *
   * 条件：データあり
   * 結果：使用可能機能リストが返ってくること
   */
  @Test
  public void test_getUseFunctions_正常_データあり() {
    // arrange
    final String facilityCd = "001";
    given(facilityDao.selectUseFunctionByFacilityCd(anyString())).willReturn(Arrays.asList("00a", "00b", "00c"));

    // action
    final List<String> result = target.getUseFunctions(facilityCd);

    // assert
    assertThat(result, hasSize(3));
    assertThat(result.get(0), is("00a"));
    assertThat(result.get(1), is("00b"));
    assertThat(result.get(2), is("00c"));
    verify(facilityDao, times(1)).selectUseFunctionByFacilityCd(facilityCd);
  }

  /**
   * getUseFunctionsの検証.
   *
   * 条件：データなし
   * 結果：空のリストが返ってくること
   */
  @Test
  public void test_getUseFunctions_正常_データなし_空配列() {
    // arrange
    final String facilityCd = "001";
    given(facilityDao.selectUseFunctionByFacilityCd(anyString())).willReturn(Collections.emptyList());

    // action
    final List<String> result = target.getUseFunctions(facilityCd);

    // assert
    assertThat(result, hasSize(0));
    verify(facilityDao, times(1)).selectUseFunctionByFacilityCd(facilityCd);
  }

  /**
   * 施設コードを設定したMstFacilityエンティティを返す.
   *
   * @param facilityCd 施設コード
   * @return MstFacility
   */
  private MstFacility getMstFacility(String facilityCd) {
    return new MstFacility(){
      {
        setFacilityCd(facilityCd);
      }
    };
  }
}
