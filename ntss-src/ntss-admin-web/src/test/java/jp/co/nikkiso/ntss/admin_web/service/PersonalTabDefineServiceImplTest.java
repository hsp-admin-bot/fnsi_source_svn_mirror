package jp.co.nikkiso.ntss.admin_web.service;

import static java.util.Arrays.asList;
import static java.util.Collections.emptyList;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.groups.Tuple.tuple;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.junit4.SpringRunner;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.core.dao.MstPersonalTabDefineDao;
import jp.co.nikkiso.ntss.core.dao.SysPersonalSettingsDefineDao;
import jp.co.nikkiso.ntss.core.entity.SysPersonalSettingsDefine;
import jp.co.nikkiso.ntss.core.entity.TabDisplayNameAndContentsId;

/**
 * PersonalTabDefineServiceImplのテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
public class PersonalTabDefineServiceImplTest {

  @Autowired
  private PersonalTabDefineService target;

  @MockBean
  private MstPersonalTabDefineDao mstPersonalTabDefineDao;

  @MockBean
  private SysPersonalSettingsDefineDao sysPersonalSettingsDefineDao;

  /**
   * getDisplayNameAndContentsIdByFacilityCd()の検証.
   *
   * <p>
   * 条件：データあり
   * 結果：結果が取得できること
   * </p>
   */
  @Test
  public void test_getDisplayNameAndContentsIdByFacilityCd_正常_データあり() {
    // arrange
    final String facilityCd = "000001";
    final NtssUser ntssUser = geneNtssUser(facilityCd, 1, 0);
    final List<TabDisplayNameAndContentsId> fixture = asList(
      new TabDisplayNameAndContentsId(1, "tabA", "idA", "1")
      , new TabDisplayNameAndContentsId(2, "tabB", "idB", "1")
      , new TabDisplayNameAndContentsId(3, "tabC", "idC", "0")
    );
    given(mstPersonalTabDefineDao.selectDisplayNameAndContentsIdByFacilityCd(anyString())).willReturn(fixture);

    ArgumentCaptor<List<Integer>> tabDefinedCdsCaptor = ArgumentCaptor.forClass(List.class);
    given(sysPersonalSettingsDefineDao.selectByTabDefineCds(tabDefinedCdsCaptor.capture()))
      .willReturn(asList(
        geneSysPersonalSettingsDefine(1, "1"),
        geneSysPersonalSettingsDefine(2, "3"),
        geneSysPersonalSettingsDefine(3, "4")
      ));

    // action
    final List<TabDisplayNameAndContentsId> result
      = target.getDisplayNameAndContentsIdByFacilityCd(ntssUser);

    // assert
    verify(mstPersonalTabDefineDao, times(1)).selectDisplayNameAndContentsIdByFacilityCd(facilityCd);
    assertThat(tabDefinedCdsCaptor.getValue()).isEqualTo(asList(1, 2, 3));

    assertThat(result)
      .hasSize(2)
      .extracting(
        TabDisplayNameAndContentsId::getTabDefineCd
        , TabDisplayNameAndContentsId::getDisplayName
        , TabDisplayNameAndContentsId::getContentsId
        , TabDisplayNameAndContentsId::getMode
      )
      .containsExactly(
        tuple(1, "tabA", "idA", "1")
        , tuple(2, "tabB", "idB", "1")
      );
  }

  /**
   * getDisplayNameAndContentsIdByFacilityCd()の検証.
   *
   * <p>
   * 条件：データなし
   * 結果：空のリストを取得できること
   * </p>
   */
  @Test
  public void test_getDisplayNameAndContentsIdByFacilityCd_正常_データなし() {
    // arrange
    final String facilityCd = "000001";
    final NtssUser ntssUser = geneNtssUser(facilityCd, 1, 0);
    final List<TabDisplayNameAndContentsId> fixture = emptyList();
    given(mstPersonalTabDefineDao.selectDisplayNameAndContentsIdByFacilityCd(anyString())).willReturn(fixture);

    ArgumentCaptor<List<Integer>> tabDefinedCdsCaptor = ArgumentCaptor.forClass(List.class);
    given(sysPersonalSettingsDefineDao.selectByTabDefineCds(tabDefinedCdsCaptor.capture()))
      .willReturn(emptyList());

    // action
    final List<TabDisplayNameAndContentsId> result
      = target.getDisplayNameAndContentsIdByFacilityCd(ntssUser);

    // assert
    verify(mstPersonalTabDefineDao, times(1)).selectDisplayNameAndContentsIdByFacilityCd(facilityCd);
    assertThat(tabDefinedCdsCaptor.getValue()).isEmpty();

    assertThat(result).isEmpty();
  }

  private SysPersonalSettingsDefine geneSysPersonalSettingsDefine(Integer tabDefineCd, String editLevel) {
    return new SysPersonalSettingsDefine(
      null,
      tabDefineCd,
      editLevel,
      null,
      null,
      null
    );
  }

  private NtssUser geneNtssUser(String facilityCd, Integer userType, Integer isAdministrator) {
    return new NtssUser(facilityCd, "username", "password", 0L, userType, isAdministrator, 0, emptyList());
  }
}
