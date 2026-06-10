package jp.co.nikkiso.ntss.admin_web.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.core.dao.MstPersonalTabDefineDao;
import jp.co.nikkiso.ntss.core.dao.SysPersonalSettingsDefineDao;
import jp.co.nikkiso.ntss.core.entity.SysPersonalSettingsDefine;
import jp.co.nikkiso.ntss.core.entity.TabDisplayNameAndContentsId;

import static java.util.stream.Collectors.toList;
import static java.util.stream.Collectors.toMap;

/**
 * 個人設定タブ定義のService実装クラス.
 */
@Service
public class PersonalTabDefineServiceImpl implements PersonalTabDefineService {

  @Autowired
  private MstPersonalTabDefineDao mstPersonalTabDefineDao;

  @Autowired
  private SysPersonalSettingsDefineDao sysPersonalSettingsDefineDao;

  /**
   * {@inheritDoc}
   */
  @Override
  public List<TabDisplayNameAndContentsId> getDisplayNameAndContentsIdByFacilityCd(NtssUser ntssUser) {
    final List<TabDisplayNameAndContentsId> tabDisplayNameAndContentsIds
      = mstPersonalTabDefineDao.selectDisplayNameAndContentsIdByFacilityCd(ntssUser.getFacilityCd());
    final List<Integer> tabDefineCds = tabDisplayNameAndContentsIds.stream()
      .map(TabDisplayNameAndContentsId::getTabDefineCd)
      .collect(toList());

    final Map<Integer, SysPersonalSettingsDefine> personalSettingsDefineMap
      = sysPersonalSettingsDefineDao.selectByTabDefineCds(tabDefineCds).stream()
        .collect(toMap(SysPersonalSettingsDefine::getTabDefineCd, d -> d));

    return tabDisplayNameAndContentsIds.stream()
      .filter(tabDisplayNameAndContentsId -> {
        final SysPersonalSettingsDefine d = personalSettingsDefineMap.get(tabDisplayNameAndContentsId.getTabDefineCd());
        return d.canShow(ntssUser.getUserType(), ntssUser.getAdministrator());
      })
      .collect(toList());
  }
}
