package jp.co.nikkiso.ntss.admin_web.service.statusList;

import java.sql.Timestamp;
import java.util.List;

import jp.co.nikkiso.ntss.admin_web.response.statusList.AlarmRecordResponse;
import jp.co.nikkiso.ntss.core.entity.MstMachineType;
import jp.co.nikkiso.ntss.core.entity.MstMoniItem;
import jp.co.nikkiso.ntss.core.entity.custom.TreatmentStatusListAlarmRecord;

public interface AlarmRecordService {
  List<AlarmRecordResponse> selectByOccurDate(String facilityCd, Timestamp occurDateStart, Timestamp occurDateEnd);

  int insert(TreatmentStatusListAlarmRecord mntAlarmRecord);

  int update(TreatmentStatusListAlarmRecord mntAlarmRecord);

  MstMachineType machineTypeSelectByTypeCd(String machineTypeCd);

  List<MstMoniItem> moniItemSelect(String facility_cd, String model, String moni_no);
}
