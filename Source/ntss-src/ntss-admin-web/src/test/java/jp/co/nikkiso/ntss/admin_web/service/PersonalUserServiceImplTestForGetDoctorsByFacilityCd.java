package jp.co.nikkiso.ntss.admin_web.service;

import jp.co.nikkiso.ntss.admin_web.response.personalUser.UserIdAndUserName;
import jp.co.nikkiso.ntss.core.dao.MstJobDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.entity.MstJob;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.junit4.SpringRunner;

import java.util.Arrays;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.tuple;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

@RunWith(SpringRunner.class)
@SpringBootTest
public class PersonalUserServiceImplTestForGetDoctorsByFacilityCd {

  /**
   * テスト対象クラス
   */
  @Autowired
  private PersonalUserService personalUserService;

  /**
   * 利用者マスタ(個人情報DB)のMockBean.
   */
  @MockitoBean
  private MstPersonalUserDao mstPersonalUserDao;

  /**
   * 職種マスタのMockBean.
   */
  @MockitoBean
  private MstJobDao mstJobDao;

  /**
   * getDoctorsByFacilityCdメソッドの検証
   *
   * 条件：指定施設に医者が存在
   * 結果：医者の利用者IDと名前のリストを返すこと
   */
  @Test
  public void test_getDoctorsByFacilityCd_正常_データあり() {
    // arrange
    final String facilityCd = "009999";

    given(mstPersonalUserDao.selectAll(anyString(), anyString()))
      .willReturn(Arrays.asList(
        new MstPersonalUser() {
          {
            setUserId(13L);
            setFacilityCd(facilityCd);
            setUserLastName("lastName13");
            setUserFirstName("firstName13");
            setJobCd("1");
          }
        },
        new MstPersonalUser() {
          {
            setUserId(11L);
            setFacilityCd(facilityCd);
            setUserLastName("lastName11");
            setUserFirstName("firstName11");
            setJobCd("1");
          }
        },
        new MstPersonalUser() {
          {
            setUserId(12L);
            setFacilityCd(facilityCd);
            setUserLastName("lastName12");
            setUserFirstName("firstName12");
            setJobCd("2");
          }
        },
        new MstPersonalUser() {
          {
            setUserId(14L);
            setFacilityCd(facilityCd);
            setUserLastName("lastName14");
            setUserFirstName("firstName14");
            setJobCd("");
          }
        },
        new MstPersonalUser() {
          {
            setUserId(15L);
            setFacilityCd(facilityCd);
            setUserLastName("lastName15");
            setUserFirstName("firstName15");
            setJobCd(null);
          }
        }
      )
    );

    given(mstJobDao.selectByFacilityCd(anyString(), any()))
      .willReturn(Arrays.asList(
        new MstJob() {
          {
            setJobCd(1L);
            setFacilityCd(facilityCd);
            setIsDoctor("1");
            setIsDisp("1");
            setIsDel("0");
          }
        },
        new MstJob() {
          {
            setJobCd(1L);
            setFacilityCd(facilityCd);
            setIsDoctor("1");
            setIsDisp("0");
            setIsDel("0");
          }
        },
        new MstJob() {
          {
            setJobCd(1L);
            setFacilityCd(facilityCd);
            setIsDoctor("1");
            setIsDisp("1");
            setIsDel("1");
          }
        },
        new MstJob() {
          {
            setJobCd(1L);
            setFacilityCd(facilityCd);
            setIsDoctor("1");
            setIsDisp("0");
            setIsDel("1");
          }
        },
        new MstJob() {
          {
            setJobCd(5L);
            setFacilityCd(facilityCd);
            setIsDoctor("1");
            setIsDisp("1");
            setIsDel("0");
          }
        },
        new MstJob() {
          {
            setJobCd(2L);
            setFacilityCd(facilityCd);
            setIsDoctor("0");
            setIsDisp("1");
            setIsDel("0");
          }
        }
      )
    );

    // action
    final List<UserIdAndUserName> result = personalUserService.getDoctorsByFacilityCd(facilityCd);

    // assert
    assertThat(result)
      .hasSize(2)
      .extracting(
        UserIdAndUserName::getUserId
        , UserIdAndUserName::getUserLastName
        , UserIdAndUserName::getUserFirstName
      )
      .containsExactly(
        tuple(
          11L
          , "lastName11"
          , "firstName11"
        )
        , tuple(
          13L
          , "lastName13"
          , "firstName13"
        )
      )
    ;
    verify(mstPersonalUserDao, times(1)).selectAll(facilityCd, "0");
    verify(mstJobDao, times(1)).selectByFacilityCd(eq(facilityCd), any());
  }

  /**
   * getDoctorsByFacilityCdメソッドの検証
   *
   * 条件：指定施設に医者が存在しない
   * 結果：空のリストを返すこと
   */
  @Test
  public void test_getDoctorsByFacilityCd_正常_データなし() {
    // arrange
    final String facilityCd = "0002";

    given(mstPersonalUserDao.selectAll(anyString(), anyString()))
      .willReturn(Arrays.asList(
        new MstPersonalUser() {
          {
            setUserId(13L);
            setFacilityCd(facilityCd);
            setUserLastName("lastName13");
            setUserFirstName("firstName13");
            setJobCd("1");
          }
        }
      )
    );

    given(mstJobDao.selectByFacilityCd(anyString(), any()))
      .willReturn(Arrays.asList(
        new MstJob() {
          {
            setJobCd(1L);
            setFacilityCd(facilityCd);
            setIsDoctor("0");
            setIsDisp("1");
            setIsDel("0");
          }
        }
      )
    );

    // action
    final List<UserIdAndUserName> result = personalUserService.getDoctorsByFacilityCd(facilityCd);

    // assert
    assertThat(result).hasSize(0);
    verify(mstPersonalUserDao, times(1)).selectAll(facilityCd, "0");
    verify(mstJobDao, times(1)).selectByFacilityCd(eq(facilityCd), any());
  }
}
