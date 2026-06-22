package jp.co.nikkiso.ntss.admin_web.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.admin_web.response.destinationGroup.DestinationGroupNameResponse;
import jp.co.nikkiso.ntss.core.dao.MstDestinationGroupDao;
import jp.co.nikkiso.ntss.core.entity.MstDestinationGroup;

/**
 * 送信先グループのService実装クラス.
 */
@Service
public class DestinationGroupServiceImpl implements DestinationGroupService {

  /**
   * 送信先グループのDaoインターフェース.
   */
  @Autowired
  private MstDestinationGroupDao mstDestinationGroupDao;

  /**
   * {@inheritDoc}
   */
  @Override
  public DestinationGroupNameResponse createDestinationGroupNameResponse(Long destinationGroupCd) {
    final MstDestinationGroup mstDestinationGroup = mstDestinationGroupDao
        .selectByDestinationGroupCd(destinationGroupCd);

    if (mstDestinationGroup == null) {
      return new DestinationGroupNameResponse();
    }

    return new DestinationGroupNameResponse(mstDestinationGroup.getDestinationGroupName());
  }

}
