package jp.co.nikkiso.ntss.device_edge.service;

import java.util.ArrayList;
import java.util.List;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import tools.jackson.core.JacksonException;
import tools.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.device_edge.response.mstMachine.MachineOptionDTO;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * 装置マスタサービス
 */
@Service
public class MstMachineServiceImpl implements MstMachineService {

  @Autowired
  private MstMachineDao mstMachineDao;

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
  @Autowired
  private LogService logService;
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end

  @Override
  public List<MstMachine> selectAll() {
    List<MstMachine> mstMachineList = mstMachineDao.selectAll();
    return mstMachineList;
  }

  @Override
  public List<MstMachine> findByFacility(String facility_cd) {
    List<MstMachine> mstMachineList = mstMachineDao.selectByFacility(facility_cd);
    return mstMachineList;
  }

  @Override
  @Transactional
  public MstMachine create(MstMachine mstMachine) {
    mstMachineDao.insert(mstMachine);
    return mstMachine;
  }

  @Override
  public MstMachine findByCd(String machine_type_cd, String machine_serial, String facility_cd) {
    return mstMachineDao.selectByCd(machine_type_cd, machine_serial, facility_cd);
  }

  /**
   * デバイスエッジ別の装置マスタ固定長文字列取得
   * @param 施設コード
   * @param デバイスエッジ番号
   * @return 固定長文字列化した装置マスタのリスト
   */
  @Override
  public List<String> findByDeviceEdge(String facility_cd, int device_edge_no) {
    List<MstMachine> mstMachineList = mstMachineDao.selectByFacilityAndDeviceEdgeNoAndNullIpAddress(facility_cd, device_edge_no);
    List<String> machineStrings = new ArrayList<String>();

    // mstMachineListの中身を取得
    for (int looper = 0; looper < mstMachineList.size(); looper++) {
      MstMachine mstMachine = mstMachineList.get(looper);

      // 装置情報
      String machineNo = this.getZeroRightPaddingString(Long.toHexString(mstMachine.getMachineNo()), 8);
      String machineTypeCd = this.getFixLengthString(mstMachine.getMachineTypeCd(), 3);
      String comFormatCd = this.getFixLengthString(mstMachine.getComFormatCd(), 1);
      String machineSerial = "";
      if (StringUtils.isEmpty(mstMachine.getMachineSerial())) {
        machineSerial = "        ";
      }
      else {
        machineSerial = this.getFixLengthString(mstMachine.getMachineSerial(), 8);
      }
      String ipAddress = "";
      if (StringUtils.isEmpty(mstMachine.getIpAddress())) {
        ipAddress = "               ";
      }
      else {
        ipAddress = this.getFixLengthString(mstMachine.getIpAddress(), 15);
      }
      String port = "00000";
      if (StringUtils.isEmpty(mstMachine.getPort())) {
        port = "00000";
      }
      else {
        //port = this.getFixLengthString(mstMachine.getPort(), 5);
        port = this.getZeroRightPaddingString(mstMachine.getPort(), 5);
      }
      String comType = this.getFixLengthString(mstMachine.getComType().toString(), 1);
      String isFtp = this.getFixLengthString(mstMachine.getIsFtp(), 1);
      String isVa = this.getFixLengthString(mstMachine.getIsVa(), 1);

      // 装置オプション
      ObjectMapper mapper = new ObjectMapper();
      String options = "";
      // #12200 2025.09.18 add 装置オプションのHEX変換に失敗した場合は初期値を返す TDC米沢 start
      // if (StringUtils.isEmpty(mstMachine.getMachineOption())) {
      //   // 装置オプションがnullまたは空の場合、0埋めのデータとする
      //   options = "0000" + "0000" + "0000" + "0000" + "0000";
      // } else {
      //   try {
      //     MachineOptionDTO machineOption = mapper.readValue(mstMachine.getMachineOption(), MachineOptionDTO.class);
      //     options = machineOption.createOptionHexString();
      //
      //   } catch (JacksonException e) {
      //     e.printStackTrace();
      //   } catch (JsonMappingException e) {
      //     e.printStackTrace();
      //   } catch (IOException e) {
      //     e.printStackTrace();
      //   }
      // }
      // 装置オプションがnullまたは空以外の場合、HEX変換を行う
      if (!StringUtils.isEmpty(mstMachine.getMachineOption())) {
        try {
          MachineOptionDTO machineOption = mapper.readValue(mstMachine.getMachineOption(), MachineOptionDTO.class);
          options = machineOption.createOptionHexString();
        } catch (JacksonException e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          if (facility_cd != null) {
            eventLogMessage.setFacilityCd(facility_cd);
          }
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
        }
      }
      // 装置オプションの初期値設定
      final String init_options = "0000" + "0000" + "0000" + "0000" + "0000";
      // 装置オプションの長さが想定外の場合は初期値とする
      if(options.length() != init_options.length()){
        options = init_options;
      }
      // #12200 2025.09.18 add 装置オプションのHEX変換に失敗した場合は初期値を返す TDC米沢 end
      String machineString = "";
      machineString += machineNo;
      machineString += machineTypeCd;
      machineString += comFormatCd;
      machineString += machineSerial;
      machineString += ipAddress;
      machineString += port;
      machineString += comType;
      machineString += isFtp;
      machineString += isVa;
      machineString += options;

      machineStrings.add(machineString);
    }

    return machineStrings;
  }

  /*
   * 右詰めスペース埋め固定長文字列を返す
   */
  private String getFixLengthString(String string, int length) {
    for (int looper = 0; looper < length; looper++) {
      string += " ";
    }
    String rtn = string.substring(0, length);
    return rtn;
  }

  /**
   * 左詰め0埋め固定長文字列を返す
   */
  private String getZeroRightPaddingString(String string, int length) {
    for (int looper = 0; looper < length; looper++) {
      string = "0" + string;
    }
    String rtn = string.substring(string.length() - length, string.length());
    return rtn;
  }

  @Override
  @Transactional
  public void delete(String machine_type_cd, String machine_serial, String facility_cd) {
    MstMachine mstMachine = mstMachineDao.selectByCd(machine_type_cd, machine_serial, facility_cd);
    if (mstMachine != null) {
      mstMachineDao.delete(mstMachine);
    }
  }

  @Override
  @Transactional
  public MstMachine update(MstMachine mstMachine) {
    mstMachineDao.update(mstMachine);
    return mstMachine;
  }

  @Override
  @Transactional
  public int updateMachineOption(MstMachine param) {
    return mstMachineDao.updateMachineOption(param);
  }
}
