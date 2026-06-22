package jp.co.nikkiso.ntss.monitoring.service;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.custom.MniMonitorSelected;
import jp.co.nikkiso.ntss.monitoring.web.dto.MonitorParameterDto;
import jp.co.nikkiso.ntss.monitoring.web.dto.MonitorParameterDtoEx;

/**
 * モニタリングサービス
 */
public interface MniMonitorService {

  List<MniMonitor> selectAll();
  List<MniMonitorSelected> selectPickupByMachine(MonitorParameterDto dto, List<String> keys);
  List<MniMonitorSelected> selectPickupByMachineEx(MonitorParameterDtoEx dto, List<String> keys);
  List<MniMonitorSelected> selectPickupByMachineExDiff(MonitorParameterDto dto, List<String> keys);
}
