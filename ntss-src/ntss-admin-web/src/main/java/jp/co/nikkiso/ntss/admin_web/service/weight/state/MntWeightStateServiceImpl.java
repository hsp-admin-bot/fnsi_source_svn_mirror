package jp.co.nikkiso.ntss.admin_web.service.weight.state;

import java.math.BigDecimal;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.dao.MntWeightStateDao;
import jp.co.nikkiso.ntss.core.dao.OrdWeightScaleDao;
import jp.co.nikkiso.ntss.core.entity.MntWeightState;
import jp.co.nikkiso.ntss.core.entity.OrdWeightScale;

@Service
public class MntWeightStateServiceImpl implements MntWeightStateService {

  @Autowired
  MntWeightStateDao mntWeightStateDao;
  @Autowired
  OrdWeightScaleDao ordWeightScaleDao;

  @Autowired
  private LogService logService;

  @Override
  public MntWeightState selectByScaleCd(Long scaleCd) {
    return mntWeightStateDao.selectByWeightCd(scaleCd);
  }

  @Override
  @Transactional
  public int insert(MntWeightState param) {
    return mntWeightStateDao.insert(param);
  }

  @Override
  @Transactional
  public int update(MntWeightState param) {
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(param,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    return mntWeightStateDao.update(param);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public int syncMaster(String facilityCd) {
    return mntWeightStateDao.insertNewWeightCd(facilityCd);
  }
  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public int updateIsConnect(Long scaleCd, String isConnect) {
    MntWeightState state = mntWeightStateDao.selectByWeightCd(scaleCd);
    state.setIsConnect(isConnect);
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(state,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    return mntWeightStateDao.update(state);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public int updateScaleValue(Long scaleCd, BigDecimal scaleValue) {
    MntWeightState state = mntWeightStateDao.selectByWeightCd(scaleCd);
    state.setScaleValue(scaleValue);
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(state,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    return mntWeightStateDao.update(state);
  }

  // add FNSI-田中衡機の追加 徐 start
  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public int updateScaleValueList(Long scaleCd, String scaleValueList) {
    MntWeightState state = mntWeightStateDao.selectByWeightCd(scaleCd);
    state.setScaleValueList(scaleValueList);
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(state,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    return mntWeightStateDao.update(state);
  }
  // add FNSI-田中衡機の追加 徐 end

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public int updateBarcodeValue(Long scaleCd, String barcodeValue) {
    MntWeightState state = mntWeightStateDao.selectByWeightCd(scaleCd);
    state.setBarcodeValue(barcodeValue);
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(state,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    return mntWeightStateDao.update(state);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public int updateCardReadValue(Long scaleCd, String cardReadValue) {
    MntWeightState state = mntWeightStateDao.selectByWeightCd(scaleCd);
    state.setCardReadValue(cardReadValue);
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(state,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    return mntWeightStateDao.update(state);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public int updateCardWriteValue(Long scaleCd, String cardWriteValue) {
    MntWeightState state = mntWeightStateDao.selectByWeightCd(scaleCd);
    state.setCardWriteValue(cardWriteValue);
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(state,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    return mntWeightStateDao.update(state);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public int updateWriteResult(Long scaleCd, int writeResult) {
    MntWeightState state = mntWeightStateDao.selectByWeightCd(scaleCd);
    state.setWriteResult(writeResult);
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(state,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    return mntWeightStateDao.update(state);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public String selectPrintContent(Long weightScaleNo) {
    OrdWeightScale ord = ordWeightScaleDao.selectByCd(weightScaleNo);
    if (ord == null) {
      return "";
    }
    return ord.getPrintContent();
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public int updatePrintStatus(Long weightScaleNo, Integer status, String errorMessage) {
    OrdWeightScale ord = new OrdWeightScale();
    ord.setWeightScaleNo(weightScaleNo);
    ord.setPrintStatus(status);
    ord.setPrintErrorMessage(errorMessage);
//    add 8074 【デグレ】ログに誤った利用者が記録される 関 start
    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    ord.setLogUserId(user.getUserId().toString());
//    add 8074 【デグレ】ログに誤った利用者が記録される 関  end
    return ordWeightScaleDao.updatePrintStatus(ord);
  }
}
