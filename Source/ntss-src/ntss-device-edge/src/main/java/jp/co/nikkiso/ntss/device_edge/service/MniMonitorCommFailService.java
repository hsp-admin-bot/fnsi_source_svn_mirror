package jp.co.nikkiso.ntss.device_edge.service;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.TmpCommFailureRecovery;

public interface MniMonitorCommFailService {

  int insertMonitor(MniMonitor param, TmpCommFailureRecovery state);

  int insertMonitorDyalysisStart(MniMonitor param, TmpCommFailureRecovery state);

  int insertMonitorDyalysisFinish(MniMonitor param, TmpCommFailureRecovery state);

  List<MniMonitor> selectByOrdNoVital(Long ordNo);

}
