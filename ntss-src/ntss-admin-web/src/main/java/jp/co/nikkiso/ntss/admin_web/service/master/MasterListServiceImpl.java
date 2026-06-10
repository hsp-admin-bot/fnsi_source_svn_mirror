package jp.co.nikkiso.ntss.admin_web.service.master;

import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterInfo;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterListResponse;
import jp.co.nikkiso.ntss.core.dao.SysMasterDefineDao;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

/**
 * マスタ一覧画面のService実装クラス.
 */
@Service
public class MasterListServiceImpl implements MasterListService {
  
  /**
   * マスタ定義のDaoインタフェース.
   */
  @Autowired
  private SysMasterDefineDao sysMasterDefineDao;
  
  /**
   * {@inheritDoc}
   */
  @Override
  public MasterListResponse getMasterList(Integer userType) {
    // マスタ一覧の取得
    List<MasterInfo> masterList = sysMasterDefineDao.selectByUserType(Objects.isNull(userType) ? null: userType.toString())
        .stream()
        .map(e -> new MasterInfo(
            e.getMasterPhysicalName(),
            e.getMasterName(),
            e.getMode(),
            e.getEditLevel(),
            e.getDispOrder(),
            e.getSystemUseDisp()))
        .collect(Collectors.toList());

    // 成功レスポンス返却
    return new MasterListResponse(masterList);
  }

}
