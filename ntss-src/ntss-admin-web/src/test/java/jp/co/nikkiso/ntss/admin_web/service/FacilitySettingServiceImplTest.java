package jp.co.nikkiso.ntss.admin_web.service;

import static org.assertj.core.api.Assertions.assertThat;

import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.exception.NotExistException;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.junit4.SpringRunner;

import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

/**
 * FacilitySettingServiceImplのテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
public class FacilitySettingServiceImplTest {

  /**
   * テスト対象クラス.
   */
  @Autowired
  private FacilitySettingService target;

  /**
   * 施設設定DaoのMockBean.
   */
  @MockitoBean
  private MstFacilitySettingDao mstFacilitySettingDao;

  /**
   * getFacilitySettingValueメソッドの検証
   *
   * 条件：データあり
   * 結果：設定した値を返すこと
   */
  @Test
  public void test_getFacilitySettingValue_正常_データあり() {
    // arrange
    final String facilityCd = "0001";
    final String facilitySettingNo = "1003";
    final FacilitySettingInfo FacilitySettingInfo = new FacilitySettingInfo();
    FacilitySettingInfo.setValue("35");
    given(mstFacilitySettingDao.getBySettingNoAndCd(anyString(), anyString())).willReturn((FacilitySettingInfo));

    // action
    final String result = target.getFacilitySettingValue(facilityCd,facilitySettingNo);

    // assert
    assertThat(result).isEqualTo("35");
    verify(mstFacilitySettingDao, times(1)).getBySettingNoAndCd(facilityCd,facilitySettingNo);
  }

  /**
   * getFacilitySettingValueメソッドの検証
   *
   * 条件：データなし
   * 結果：NotExistExceptionが発生すること
   */
  @Test(expected = NotExistException.class)
  public void test_getFacilitySettingValue_正常_データなし() {
    // arrange
    final String facilityCd = "0001";
    final String facilitySettingNo = "1003";
    given(mstFacilitySettingDao.getBySettingNoAndCd(anyString(), anyString())).willReturn(null);

    // action
    final String result = target.getFacilitySettingValue(facilityCd,facilitySettingNo);

  }






}
