package jp.co.nikkiso.ntss.admin_web.service.partsRunning;

import java.io.IOException;
import java.util.Optional;

import jp.co.nikkiso.ntss.admin_web.response.partsRunning.dto.DabPartsRunningDto;
import jp.co.nikkiso.ntss.admin_web.response.partsRunning.dto.DadPartsRunningDto;
import jp.co.nikkiso.ntss.admin_web.response.partsRunning.dto.DroPartsRunningDto;
import jp.co.nikkiso.ntss.admin_web.response.partsRunning.dto.DryPartsRunningDto;
import jp.co.nikkiso.ntss.admin_web.response.partsRunning.dto.MachinePartsRunningDto;
import jp.co.nikkiso.ntss.admin_web.response.partsRunning.dto.V4PartsRunningDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import tools.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.admin_web.response.partsRunning.PartsRunningResponse;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.ComFormat;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.entity.custom.PartsRunning;

/**
 * 部品の運転/交換時間のService実装クラス.
 */
@Service
public class PartsRunningServiceImpl implements PartsRunningService {

  /**
   * 装置状態管理Dao.
   */
  @Autowired
  private MntMachineStateDao mntMachineStateDao;

  /**
   * ObjectMapper.
   */
  @Autowired
  private ObjectMapper mapper;

  /**
   * JSON文字列をDTOに変換する.
   *
   * @param useTimeJson　JSON文字列
   * @param clazz 変換対象DTO Class
   * @return DTO
   */
  private <D> D convertJsonStringToDto(String useTimeJson, Class<D> clazz) {
    try {
      return (useTimeJson == null) ? clazz.newInstance() : mapper.readValue(useTimeJson, clazz);
    } catch(InstantiationException | IllegalAccessException | tools.jackson.core.JacksonException e) {
      throw new RuntimeException(e);
    }
  }

  @Override
  public PartsRunningResponse createPartsRunningResponse(String facilityCd, String machineTypeCd, String machineSerial)
      throws IOException {

    // 引数に紐づく装置の部品運転時間を取得
    PartsRunning partsRunning = mntMachineStateDao.selectUseTimeByKey(facilityCd, machineTypeCd, machineSerial);
    if (partsRunning == null) {
      return new PartsRunningResponse();
    }
    final int comType = Optional.ofNullable(partsRunning.getComType()).orElse(0);
    final String comFormatCd = Optional.ofNullable(partsRunning.getComFormatCd()).orElse("");
    final String useTimeJson = partsRunning.getUseTime();

    if (comType == 1) {
      // 通信種別 = 1(新通信)
      switch (comFormatCd) {
      case ComFormat.DCS3:
      case ComFormat.DBB3:
      case ComFormat.DCG2:
      case ComFormat.DBG2:
      case ComFormat.DCS100NX2018:
      case ComFormat.DBB100NX2018:
        // JSON → 透析装置運転時間Object
        MachinePartsRunningDto machinePartsRunning = convertJsonStringToDto(useTimeJson, MachinePartsRunningDto.class);
        return new PartsRunningResponse(comType, comFormatCd, machinePartsRunning);
      }

    } else if (comType == 2) {
      // 通信種別 = 2(NX通信)
      switch (comFormatCd) {
      case ComFormat.DAB:
        // JSON → DAB運転時間Object
        DabPartsRunningDto dabPartsRunning = convertJsonStringToDto(useTimeJson, DabPartsRunningDto.class);
        return new PartsRunningResponse(comType, comFormatCd, dabPartsRunning);

      case ComFormat.DAD:
        // JSON → DAD運転時間Object
        DadPartsRunningDto dadPartsRunning = convertJsonStringToDto(useTimeJson, DadPartsRunningDto.class);
        return new PartsRunningResponse(comType, comFormatCd, dadPartsRunning);

      case ComFormat.DRO:
        // JSON → DRO運転時間Object
        DroPartsRunningDto droPartsRunning = convertJsonStringToDto(useTimeJson, DroPartsRunningDto.class);
        return new PartsRunningResponse(comType, comFormatCd, droPartsRunning);

      case ComFormat.DRY50A:
      case ComFormat.DRY50B:
        // JSON → DRY50A、DRY50B運転時間Object
        DryPartsRunningDto dryPartsRunning = convertJsonStringToDto(useTimeJson, DryPartsRunningDto.class);
        return new PartsRunningResponse(comType, comFormatCd, dryPartsRunning);

      default:
        break;
      }
    } else if (comType == 3) {
      // 通信種別 = 2(NX通信)
      switch (comFormatCd) {
        case ComFormat.V4COMMON:
          // JSON → DAB運転時間Object
          V4PartsRunningDto v4PartsRunning = convertJsonStringToDto(useTimeJson, V4PartsRunningDto.class);
          return new PartsRunningResponse(comType, comFormatCd, v4PartsRunning);

        default:
          break;
      }
    }
    // 上記以外
    return new PartsRunningResponse();

  }

}
