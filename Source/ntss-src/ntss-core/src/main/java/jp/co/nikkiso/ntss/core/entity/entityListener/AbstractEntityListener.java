package jp.co.nikkiso.ntss.core.entity.entityListener;

import jp.co.nikkiso.ntss.core.dao.BaseEntityDao;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogEventUtil;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.seasar.doma.jdbc.entity.EntityListener;
import org.seasar.doma.jdbc.entity.PostUpdateContext;
import org.seasar.doma.jdbc.entity.PreUpdateContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;


import java.time.Clock;

//#8353 外部連携稼働ビューアからのAPI呼び出しに失敗する 卓 2023-03-11 start
/**
 * エンティティリスナークラス
 */
@Component
@NoArgsConstructor
public abstract class AbstractEntityListener<BaseEntity> implements EntityListener<BaseEntity> {

  // DB更新ログ出力ロジック xie start
  @Autowired
  protected EventLoggerFactory eventLoggerFactory;
  @Autowired
  protected LogServiceCore logServiceCore;

  @Autowired
  protected BaseEntityDao baseEntityDao;

  protected static ThreadLocal<DataUpdateLogCommonNew> threadLocalLogCommon = new ThreadLocal<DataUpdateLogCommonNew>();
  // DB更新ログ出力ロジック xie end
  @Setter
  @Getter
  @Autowired
  private Clock time;


  /**
   * DB更新ログ出力ロジック
   */
  @Override
  public void preUpdate(BaseEntity entity, PreUpdateContext<BaseEntity> context) {
    try {
      DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
      boolean hasData = LogEventUtil.setLogCommon(logCommon, eventLoggerFactory, logServiceCore, baseEntityDao, entity, context.getConfig());
      logCommon.setHasData(hasData);
      threadLocalLogCommon.set(logCommon);
    } catch (Exception e) {
      init();
      LogEventUtil.outputErrorLog(eventLoggerFactory, e, this.getClass().getName());
    }
  }

  /**
   * DB更新ログ出力ロジック
   */
  @Override
  public void postUpdate(BaseEntity base, PostUpdateContext<BaseEntity> context) {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260331 del yangxuewang start
//    try {
//      DataUpdateLogCommonNew logCommon = threadLocalLogCommon.get();
//      if (logCommon.getHasData()) {
//        logCommon.updateLog();
//      }
////      init();
//      threadLocalLogCommon.remove();
//    } catch (Exception e) {
////      init();
//      LogEventUtil.outputErrorLog(eventLoggerFactory, e, this.getClass().getName());
//    }
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260331 del yangxuewang end
  }

  /**
   * 変数初期化処理
   */
  public void init() {
    DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
    logCommon.setHasData(false);
    threadLocalLogCommon.set(logCommon);
  }
}
//#8353 外部連携稼働ビューアからのAPI呼び出しに失敗する 卓 2023-03-11 end
