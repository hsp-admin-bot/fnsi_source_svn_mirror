package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.logevent.commentinfo.UpdateLogInfo;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class DataUpdateLogInfoEntity {

  private EventLogMessage eventLogMessage;

  private UpdateLogInfo outputInfo;

  private String tableName;
}
