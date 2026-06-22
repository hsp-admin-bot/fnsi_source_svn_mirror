package jp.co.nikkiso.ntss.admin_web.service.observeRecord;

import java.util.List;

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.dao.MstObsKindDao;
import jp.co.nikkiso.ntss.core.entity.MstObsKind;

@Service
public class MstObsKindServiceImpl implements MstObsKindService {

  @Autowired
  MstObsKindDao mstObsKindDao;

  @Autowired
  private LogService logService;

  public List<MstObsKind> selectAll(String facilityCd) {
    return mstObsKindDao.selectAll(facilityCd);
  }

  @Override
  public List<MstObsKind> selectByKindNo(Long kindNo) {
    return mstObsKindDao.selectByKindNo(kindNo);
  }

  @Override
  public int insert(MstObsKind param) {

    return mstObsKindDao.insert(param);
  }

  @Override
  public int delete(MstObsKind param) {
    return mstObsKindDao.delete(param);
  }

  @Override
  public int update(MstObsKind param) {
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(param,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    return mstObsKindDao.update(param);
  }
}
