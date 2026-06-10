package jp.co.nikkiso.ntss.admin_web.service.mente;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.dao.MstMenteCategoryDao;
import jp.co.nikkiso.ntss.core.entity.custom.CusMenteCategoryResponse;

/**
 * 検査カテゴリのService実装クラス.
 */
@Service
public class MstMenteCategoryServiceImpl implements MstMenteCategoryService {

  /**
   * 検査カテゴリDaoインタフェース.
   */
  @Autowired
  MstMenteCategoryDao mstMenteCategoryDao;

  /**
   * {@inheritDoc}
   */
  @Override
  public List<CusMenteCategoryResponse> getAll(String facilityCd) {
    return mstMenteCategoryDao.selectAllByFacility(facilityCd, null);
  }

}
