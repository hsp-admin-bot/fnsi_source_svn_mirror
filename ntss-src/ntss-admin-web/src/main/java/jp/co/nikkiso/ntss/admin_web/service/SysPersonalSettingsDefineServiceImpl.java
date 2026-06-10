package jp.co.nikkiso.ntss.admin_web.service;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.admin_web.response.PersonalSettingsDefine;
import jp.co.nikkiso.ntss.admin_web.service.master.ReferenceComboService;
import jp.co.nikkiso.ntss.core.dao.SysPersonalSettingsDefineDao;
import jp.co.nikkiso.ntss.core.entity.SysPersonalSettingsDefine;
import jp.co.nikkiso.ntss.core.exception.NotExistException;

import static java.util.stream.Collectors.toList;

/**
 * 個人設定の共通画面用設定のService実装クラス
 */
@Service
public class SysPersonalSettingsDefineServiceImpl implements SysPersonalSettingsDefineService {

  @Autowired
  private SysPersonalSettingsDefineDao sysPersonalSettingsDefineDao;

  @Autowired
  private ReferenceComboService referenceComboService;

  /**
   * {@inheritDoc}
   */
  @Override
  public PersonalSettingsDefine getPersonalSettingsDefine(String facilityCd, Integer tabDefineCd) {
    try {
      // 共通タブ用の設定を取得
      final SysPersonalSettingsDefine sysPersonalSettingsDefine
        = sysPersonalSettingsDefineDao.selectByTabDefineCd(tabDefineCd);

      // コンボの値を取得
      List<SysPersonalSettingsDefine.StaticCombo> staticCombos = new ArrayList<>();

      // 定義が存在する場合だけ、staticCombosに連結する。
      if(sysPersonalSettingsDefine.getComboData() != null) {
        staticCombos.addAll(sysPersonalSettingsDefine.getComboData().getCombos());
      }

      // 定義が存在する場合だけ、他マスタから値を取得してstaticCombosに連結する。
      final SysPersonalSettingsDefine.ReferenceComboDef referenceComboDef = sysPersonalSettingsDefine.getReferenceComboDef();
      if(referenceComboDef != null) {
        final List<SysPersonalSettingsDefine.StaticCombo> comboFromReferenceComboDef = referenceComboDef.getCombos().stream()
          .map(comboDef -> {
            final String settingIdentifier = comboDef.getSettingIdentifier();
            final List<SysPersonalSettingsDefine.StaticComboValue> comboValues = referenceComboService.build(
              facilityCd,
              comboDef.getTargetTable().convertToReferenceComboTargetTable()
            ).stream()
              .map(rc -> new SysPersonalSettingsDefine.StaticComboValue(rc.getDisplayValue(), rc.getReferencedValue()))
              .collect(toList());

            return new SysPersonalSettingsDefine.StaticCombo(settingIdentifier, comboValues);
          })
          .collect(toList());

        staticCombos.addAll(comboFromReferenceComboDef);
      }


      // エンティティ組み立て
      return new PersonalSettingsDefine(
        tabDefineCd
        , sysPersonalSettingsDefine.getEditLevel()
        , sysPersonalSettingsDefine.getItemInfo().getItemInfoDetail()
        , staticCombos
      );
    } catch(EmptyResultDataAccessException e) {
      throw new NotExistException("存在しないタブ定義コードを指定しています。");
    }
  }
}
