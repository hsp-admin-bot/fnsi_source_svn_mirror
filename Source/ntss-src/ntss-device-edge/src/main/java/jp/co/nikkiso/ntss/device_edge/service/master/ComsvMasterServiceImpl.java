package jp.co.nikkiso.ntss.device_edge.service.master;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.dao.MstChecklistDao;
import jp.co.nikkiso.ntss.core.dao.MstExamItemDao;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvMstCheckList;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvMstExamItem;

/**
 * 通信サーバ用チェックリストマスタサービス
 */
@Service
public class ComsvMasterServiceImpl implements ComsvMasterService {

  @Autowired
  MstChecklistDao comsvMstCheckListDao;

  @Autowired
  MstExamItemDao comsvMstExamItemDao;

  /**
   * {@inheritDoc}
   * @param facilityCd
   * @return
   */
  @Override
  public List<ComsvMstCheckList> fetchCheckList(String facilityCd) {
    List<ComsvMstCheckList> comsvMstCheckList = comsvMstCheckListDao.selectByFacilityCdComSv(facilityCd);
    return comsvMstCheckList;
  }

  /**
   * {@inheritDoc}
   * @param facilityCd
   * @return
   */
  @Override
  public List<ComsvMstExamItem> fetchExamItem(String facilityCd) {
    List<ComsvMstExamItem> comsvMstExamItem = comsvMstExamItemDao.selectByFacilityCdComSv(facilityCd);
    return comsvMstExamItem;
  }
}
