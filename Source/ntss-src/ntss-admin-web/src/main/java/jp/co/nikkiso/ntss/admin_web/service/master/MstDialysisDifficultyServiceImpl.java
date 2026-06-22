package jp.co.nikkiso.ntss.admin_web.service.master;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.dao.MstDialysisDifficultyDao;
import jp.co.nikkiso.ntss.core.entity.MstDialysisDifficulty;

/**
 * 透析困難フィルターに表示する透析困難一覧を取得するクラス.
 *
 * @author Masahiro Ito
 */
@Service
public class MstDialysisDifficultyServiceImpl implements MstDialysisDifficultyService {

  @Autowired
  MstDialysisDifficultyDao mstDao;

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstDialysisDifficulty> selectAll(String facilityCd) {
//    final MstDialysisDifficulty params = new MstDialysisDifficulty();
//    params.setFacilityCd(facilityCd);
//    return mstDao.selectDisp(params);
    return mstDao.selectDisp(facilityCd);
  }

}
