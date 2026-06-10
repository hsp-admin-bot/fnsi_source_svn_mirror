package jp.co.nikkiso.ntss.admin_web.service;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.core.IsNull.notNullValue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.junit4.SpringRunner;

import jp.co.nikkiso.ntss.admin_web.response.destinationGroup.DestinationGroupNameResponse;
import jp.co.nikkiso.ntss.core.dao.MstDestinationGroupDao;
import jp.co.nikkiso.ntss.core.entity.MstDestinationGroup;

@RunWith(SpringRunner.class)
@SpringBootTest
public class DestinationGroupServiceImplTest {

  /**
   * テスト対象クラス.
   */
  @Autowired
  private DestinationGroupService destinationGroupService;

  /**
   * 送信先グループDaoのMockBean.
   */
  @MockBean
  private MstDestinationGroupDao destinationGroupDao;

  /**
   * createDestinationGroupNameResponseの検証.
   *
   * 条件：送信先グループに該当のデータがある
   * 結果：送信先グループコードに該当する送信先グループが取得できること
   */
  @Test
  public void test_createDestinationGroupNameResponse_正常_送信先グループに該当のデータがある() {
    Long destinationGroupCd = 1L;
    String destinationGroupName = "Group1";

    MstDestinationGroup mstDestinationGroup = new MstDestinationGroup();
    mstDestinationGroup.setDestinationGroupCd(destinationGroupCd);
    mstDestinationGroup.setDestinationGroupName(destinationGroupName);
    mstDestinationGroup.setFacilityCd("000001");
    mstDestinationGroup.setIsDel("0");
    mstDestinationGroup.setIsDisp("1");

    // Mock化
    given(destinationGroupDao.selectByDestinationGroupCd(any())).willReturn(mstDestinationGroup);

    // 実行
    DestinationGroupNameResponse result = destinationGroupService.createDestinationGroupNameResponse(destinationGroupCd);

    // 検証
    verify(destinationGroupDao, times(1)).selectByDestinationGroupCd(destinationGroupCd);
    assertThat(result, notNullValue());
    assertThat(result.getName(), is(destinationGroupName));
  }

  /**
   * createDestinationGroupNameResponseの検証.
   *
   * 条件：送信先グループに該当のデータがない
   * 結果：空のリストが取得できること
   */
  @Test
  public void test_createDestinationGroupNameResponse_正常_送信先グループに該当のデータがない() {
    Long destinationGroupCd = 1L;

    // Mock化
    given(destinationGroupDao.selectByDestinationGroupCd(any())).willReturn(null);

    // 実行
    DestinationGroupNameResponse result = destinationGroupService.createDestinationGroupNameResponse(destinationGroupCd);

    // 検証
    verify(destinationGroupDao, times(1)).selectByDestinationGroupCd(destinationGroupCd);
    assertThat(result, notNullValue());
    assertThat(result.getName(), is(""));
  }
}
