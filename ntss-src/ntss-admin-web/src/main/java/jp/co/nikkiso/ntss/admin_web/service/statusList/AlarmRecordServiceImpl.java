package jp.co.nikkiso.ntss.admin_web.service.statusList;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.admin_web.response.statusList.AlarmRecordResponse;
import jp.co.nikkiso.ntss.admin_web.service.utils.StrUtils;
import jp.co.nikkiso.ntss.core.dao.MntAlarmRecordDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineTypeDao;
import jp.co.nikkiso.ntss.core.dao.MstMoniItemDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.entity.MstMachineType;
import jp.co.nikkiso.ntss.core.entity.MstMoniItem;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.custom.TreatmentStatusListAlarmRecord;

@Service
public class AlarmRecordServiceImpl implements AlarmRecordService {

  @Autowired
  MntAlarmRecordDao mntAlarmRecordDao;

  @Autowired
  MstMachineTypeDao mstMachineTypeDao;

  @Autowired
  MstMoniItemDao mstMoniItemDao;

  @Autowired
  PatPersonalMainDao patPersonalMainDao;

  @Autowired
  LogService logService;

  @Override
  public List<AlarmRecordResponse> selectByOccurDate(String facilityCd, Timestamp occurDateStart,
      Timestamp occurDateEnd) {

    long begin = System.currentTimeMillis();
    List<TreatmentStatusListAlarmRecord> tmp = mntAlarmRecordDao.selectByOccurDate(facilityCd, occurDateStart,
        occurDateEnd);
    long past = System.currentTimeMillis() - begin;

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(String.format("=== #8986 === SelectByOccurDate use %d ms load %d rows. === #8986 ===", past, tmp.size()));
    logService.log(LogLevel.INFO, eventLogMessage,"", LoggingConstant.SERVICE_NAME.FNSI, null);

    List<Long> patIdList = new ArrayList<Long>();
    // 警報・一覧のレスポンス
    List<AlarmRecordResponse> alarmRecordResponse = new ArrayList<AlarmRecordResponse>();

    for (int idx = 0; idx < tmp.size(); idx++) {
      // 患者リスト格納
      if (tmp.get(idx).getPatId() != null) {
        patIdList.add(tmp.get(idx).getPatId());
      }
    }
    patIdList = patIdList.stream().distinct().collect(Collectors.toList());

    List<PatPersonalMain> patPersonalList = new ArrayList<PatPersonalMain>();
    if (patIdList.size() > 0) {
      begin = System.currentTimeMillis();
      patPersonalList = patPersonalMainDao.selectByIdListFacilityCd(patIdList, facilityCd);
      past = System.currentTimeMillis() - begin;

      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(String.format("=== #8986 === SelectByIdListFacilityCd use %d ms load %d rows. === #8986 ===", past, patPersonalList.size()));
      logService.log(LogLevel.INFO, eventLogMessage,"", LoggingConstant.SERVICE_NAME.FNSI, null);
    }

    for (int idx = 0; idx < tmp.size(); idx++) {

      AlarmRecordResponse response = new AlarmRecordResponse();
      response.bedName = tmp.get(idx).getBedName();
      response.contents = tmp.get(idx).getMachineRecordMessage();
      response.occurDate = tmp.get(idx).getEventRegDate();
      // add FNSI-警報・報知追加 付 start
      response.machineTypeCd = tmp.get(idx).getMachineTypeCd();
      response.machineSerial = tmp.get(idx).getMachineSerial();
      // add FNSI-警報・報知追加 付 end

      if (tmp.get(idx).getPatId() != null) {
        // #9485 mod 患者名の姓または名に連携からnullが登録された場合に、各画面の患者名表示に「null」と表示してしまう。2024-04-25 卓 start
        String pat_last_name = "";
        String pat_first_name = "";
        PatPersonalMain patPersonal=null;
        // #9485 mod 患者名の姓または名に連携からnullが登録された場合に、各画面の患者名表示に「null」と表示してしまう。2024-04-25 卓 end

        for (int jdx = 0; jdx < patPersonalList.size(); jdx++) {
          if (Objects.equals(tmp.get(idx).getPatId(), patPersonalList.get(jdx).getPat_id())) {
            StringBuilder buf = new StringBuilder();
            // #9485 mod 患者名の姓または名に連携からnullが登録された場合に、各画面の患者名表示に「null」と表示してしまう。2024-04-25 卓 start
            patPersonal = patPersonalList.get(jdx);
            pat_last_name = patPersonal.getPat_last_name() == null ? "" : patPersonal.getPat_last_name();
            pat_first_name = patPersonal.getPat_first_name() == null ? "" : patPersonal.getPat_first_name();
            buf.append(pat_last_name);
            buf.append(pat_first_name);
            //buf.append(patPersonalList.get(jdx).getPat_last_name());
            //buf.append(patPersonalList.get(jdx).getPat_first_name());
            // #9485 mod 患者名の姓または名に連携からnullが登録された場合に、各画面の患者名表示に「null」と表示してしまう。2024-04-25 卓 end

            response.patName = buf.toString();
            break;
          }
        }
      // add #7158 2022/11/26 治療状況リストの警報報知一覧で？？？？患者のデータの場合空欄になる。 dou start
      } else if(tmp.get(idx).getOrdNo() != null){
        response.patName = "？？？？患者";
      } else {
        response.patName = "";
      }
      // add #7158 2022/11/26 治療状況リストの警報報知一覧で？？？？患者のデータの場合空欄になる。 dou end

      // 警報・報知の判断
      String value = tmp.get(idx).getMachineRecordCd().substring(0, 1);
      /* mod #9211 by zhangruixue 2023-08-02 --start */
//      switch (value) {
//      case "4":
//        response.historyType = "1";
//        break;
//      case "5":
//        response.historyType = "1";
//        break;
//      case "8":
//        response.historyType = "3";
//        break;
//      case "9":
//        response.historyType = "3";
//        break;
//      default:
//        response.historyType = "0";
//      }
      response.historyType = switch (value) {
        case "4", "5", "6", "7" -> "1";
        case "8", "9", "A", "B" -> "3";
        default -> "0";
      };
      if("1".equals(response.historyType) || "3".equals(response.historyType)){
        alarmRecordResponse.add(response);
      }
      /* mod #9211 by zhangruixue 2023-08-02 --end */
    }
    return alarmRecordResponse;
  }

  @Override
  @Transactional
  public int insert(TreatmentStatusListAlarmRecord treatmentStatusListAlarmRecord) {
    return mntAlarmRecordDao.insert(treatmentStatusListAlarmRecord);
  }

  @Override
  @Transactional
  public int update(TreatmentStatusListAlarmRecord treatmentStatusListAlarmRecord) {
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(treatmentStatusListAlarmRecord,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    return mntAlarmRecordDao.update(treatmentStatusListAlarmRecord);
  }

  @Override
  public MstMachineType machineTypeSelectByTypeCd(String machineTypeCd) {
    return mstMachineTypeDao.selectByTypeCd(machineTypeCd);
  }

  @Override
  public List<MstMoniItem> moniItemSelect(String facility_cd, String model, String moni_no) {

    if (moni_no != null && StrUtils.isNumber(moni_no)) {
      return mstMoniItemDao.selectByFacilityModelMoniNo(facility_cd, model, Integer.parseInt(moni_no));
    } else if (model != null) {
      return mstMoniItemDao.selectByFacilityModel(facility_cd, model);
    }

    return mstMoniItemDao.selectByFacility(facility_cd);
  }

}
