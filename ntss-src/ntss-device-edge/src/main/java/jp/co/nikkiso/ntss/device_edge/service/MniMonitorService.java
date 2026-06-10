package jp.co.nikkiso.ntss.device_edge.service;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;

public interface MniMonitorService {

  int insertMonitor(MniMonitor param, MntMachineState state);

  int insertMonitorDyalysisStart(MniMonitor param, MntMachineState state);

  int insertMonitorDyalysisFinish(MniMonitor param, MntMachineState state);

  List<MniMonitor> selectByOrdNoVital(Long ordNo);

}
