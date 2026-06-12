package jp.co.nikkiso.ntss.admin_web.service.nextpat;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import jp.co.nikkiso.ntss.admin_web.response.deviceEdgeOrder.DeviceEdgeOrderResponse;
import jp.co.nikkiso.ntss.admin_web.response.sendConditionCancel.SendConditionCancelResponse;
import jp.co.nikkiso.ntss.admin_web.service.deviceEdgeOrder.DeviceEdgeOrderService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.nextpat.dto.ChargeStaffDiffInfo;
import jp.co.nikkiso.ntss.admin_web.service.nextpat.dto.IndMediEquipDiffInfo;
import jp.co.nikkiso.ntss.admin_web.service.nextpat.dto.PatPhysicalInfo;
import jp.co.nikkiso.ntss.admin_web.service.sendConditionCancel.SendConditionCancelService;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.api.utils.DateTimeFormatUtil;
import jp.co.nikkiso.ntss.core.config.DefaultDb;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.BaseEntityDao;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.MstBedDao;
import jp.co.nikkiso.ntss.core.dao.MstComsvSettingDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.NextPatDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatUniqueDao;
import jp.co.nikkiso.ntss.core.dto.nextpat.NextPatByBedInfo;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.MstBed;
import jp.co.nikkiso.ntss.core.entity.MstComsvSetting;
import jp.co.nikkiso.ntss.core.entity.MstCourse;
import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.MstEquipment;
import jp.co.nikkiso.ntss.core.entity.MstKur;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.MstMedicine;
import jp.co.nikkiso.ntss.core.entity.MstMedicineMix;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.MstVa;
import jp.co.nikkiso.ntss.core.entity.MstWard;
import jp.co.nikkiso.ntss.core.entity.NpatItem;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatUnique;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.apache.commons.lang3.StringUtils;
import org.json.JSONObject;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.builder.SelectBuilder;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.lang.reflect.Type;
import java.net.URISyntaxException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class NextPatServiceImpl  implements NextPatService {

  /**
   * ロギングのServiceインタフェース.
   */
  @Autowired
  private LogService logService;

  @Autowired
  private SendConditionCancelService sendConditionCancelService;

  @Autowired
  DeviceEdgeOrderService deviceEdgeOrderService;

  @Autowired
  private WebApiCallCommonUtil webApiCallCommonUtil;

  @Autowired
  private NextPatDao nextPatDao;

  @Autowired
  private PatMainDao patMainDao;

  @Autowired
  private PatUniqueDao patUniqueDao;

  @Autowired
  private OrdMainDao ordMainDao;

  @Autowired
  private MstMachineDao mstMachineDao;

  @Autowired
  private MstBedDao mstBedDao;

  @Autowired
  private MntMachineStateDao mntMachineStateDao;

  @Autowired
  private MstComsvSettingDao mstComsvSettingDao;

  @Autowired
  @DefaultDb
  private Config defaultDbConfig;

  /**
   * 次患者更新判定処理（マスタ変更）
   *
   * @param facilityCd
   * @param masterPhysicalName
   * @param beforeMstList 変更前Mst
   * @param afterMstList 変更後Mst
   * @return List<OrdMain>
   * @description 注意：マスタデータのデータ物理削除は存在しない前提での処理
   */
  @Override
  public List<OrdMain> FilterNextPatInfo1or2ChangedForMst(String facilityCd, String masterPhysicalName, List<Object> beforeMstList, List<Object> afterMstList){

    // 送信対象ordMainList
    List<OrdMain> nextPatInfo1or2ChangedOrdMainList = new ArrayList<>();

    // 変更がない場合は、そのままretrun
    if(Objects.equals(beforeMstList, afterMstList)){
      return nextPatInfo1or2ChangedOrdMainList;
    }

    if(beforeMstList == null){
      beforeMstList = new ArrayList<>();
    }
    if(afterMstList == null){
      afterMstList = this.getTableDataBymasterPhysicalName(facilityCd, masterPhysicalName);
    }

    // 名称変更により、影響を及ぼす患者Idリスト
    List<Long> patIdForMemoList = new ArrayList<>();

    // 送信対象VACdリスト
    List<Integer> vaCdForMemoList = new ArrayList<>();

    // 送信対象治療方法Cdリスト
    List<Integer> treatmenCdList = new ArrayList<>();

    // 送信対象治療方法CdリストForメモ（メモが設定されている治療方法Cdリスト）
    List<Integer> treatmenCdForMemoList = new ArrayList<>();

    // 送信対象クールCdリスト
    List<Integer> kurCdList = new ArrayList<>();

    // 送信対象ベッドCdリスト ベッドマスタ変更時
    List<Long> bedCdList = new ArrayList<>();
    // 送信対象ベッドCdリスト（メモが設定されているベッドCdリスト）
    List<Long> bedCdForMemoList = new ArrayList<>(); // 汎用
    List<Long> bedCdForMemoForEquipmentList = new ArrayList<>(); // ダイアライザ名
    List<Long> bedCdForMemoForDialyzerList = new ArrayList<>(); // ダイアライザ名(吸着カラム,一次膜,二次膜含む)
    List<Long> bedCdForMemoForPrimaryMembraneList = new ArrayList<>(); // 一次膜
    List<Long> bedCdForMemoForANeedleMembraneList = new ArrayList<>(); // A針名(SN含む)
    List<Long> bedCdForMemoForVNeedleMembraneList = new ArrayList<>(); // V針名
    List<Long> bedCdForMemoForDialysateList = new ArrayList<>(); // 透析液
    List<Long> bedCdForMemoForAnticoagulantList = new ArrayList<>(); // 抗凝固剤名

    // 送信対象ダイアライザCdリスト 指示：治療条件情報(ind_cond_info)->ダイアライザ(5)->value(String)
    // ・指示：医療材料情報(ind_equip_info)->get(i)->医療材料コード(cd)&&医療材料区分(equip_type)==医療材料(1)
    List<Integer> dialyzerCdList = new ArrayList<>();
    List<Integer> dialyzerCdForMemoList = new ArrayList<>();

    // 送信対象医療材料Cdリスト
    // ・指示：治療条件情報(ind_cond_info)->吸着カラム(6)->value(String)
    // ・指示：治療条件情報(ind_cond_info)->1次膜(7)or2次膜(8)->value(String)
    // ・指示：治療条件情報(ind_cond_info)->穿刺針(A9,V10,SN11)->value(String)
    // ・指示：治療条件情報(ind_cond_info)->血液回路(13)->value(String) ←※ここは未使用
    // ・指示：医療材料情報(ind_equip_info)->get(i)->医療材料コード(cd)&&医療材料区分(equip_type)==医療材料(0)
    List<Integer> mstEquipmentCdForMemoList = new ArrayList<>();

    // 送信対象薬剤Cdリスト
    // ・指示：治療条件情報(ind_cond_info)->透析液(15)->value(String)&&薬剤区分(medicine_type)==通常薬剤(1)
    // ・指示：治療条件情報(ind_cond_info)->補液(19)->value(String)&&薬剤区分(medicine_type)==通常薬剤(1) ←※ここは未使用
    // ・指示：治療条件情報(ind_cond_info)->抗凝固剤(25)->value(String)&&薬剤区分(medicine_type)==通常薬剤(1)
    // ・指示：投与薬剤情報(ind_medi_info)->get(i)->薬剤(調製薬剤)コード(cd)&&薬剤区分(medicine_type)==通常薬剤(1)
    List<Integer> mstMedicineCdForMemoList = new ArrayList<>();

    // 送信対象調製薬剤Cdリスト
    // ・指示：治療条件情報(ind_cond_info)->透析液(15)->value(String)&&薬剤区分(medicine_type)==調製薬剤(2)
    // ・指示：治療条件情報(ind_cond_info)->補液(19)->value(String)&&薬剤区分(medicine_type)==調製薬剤(2) ←※ここは未使用
    // ・指示：治療条件情報(ind_cond_info)->抗凝固剤(25)->value(String)&&薬剤区分(medicine_type)==調製薬剤(2)
    // ・指示：投与薬剤情報(ind_medi_info)->get(i)->薬剤(調製薬剤)コード(cd)&&薬剤区分(medicine_type)==通常薬剤(2)
    List<Integer> mstMedicineMixCdForMemoList = new ArrayList<>();

    // マシンナンバーリスト
    List<Long> machineNoList = new ArrayList<>();

    List<MstComsvSetting> mstComsvSettings = new ArrayList<>();
    List<MstComsvSetting> mstComsvSettingsForAnticoagulant = new ArrayList<>();
    List<MstComsvSetting> mstComsvSettingsForDialysate = new ArrayList<>();

    List<Integer> arrayListForMedicineMemo = new ArrayList<>(Arrays.asList(36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55));

    List<Integer> arrayListForEquipmentMemo = new ArrayList<>(Arrays.asList(25, 26, 27, 28, 29, 30, 31, 32, 33, 34));

    switch (masterPhysicalName){
      case "mst_kur":
        // クールマスタ key:クールコード(kur_cd) 特殊項目:削除フラグ(is_del)
        Map<Integer, MstKur> beforeMstKurListMap = beforeMstList.stream().collect(Collectors.toMap(o -> ((MstKur)o).getKurCd(), o -> (MstKur)o));
        for(Object objTmp: afterMstList){
          MstKur afterMst = (MstKur)objTmp;
          MstKur beforeMst = beforeMstKurListMap.get(afterMst.getKurCd());
          if(beforeMst == null){
            //　追加の場合
          } else{
            if(Objects.equals(beforeMst, afterMst)){
              // 変更がない場合は次のレコード
              continue;
            } else{
              // 変更の場合
              if(!Objects.equals(beforeMst.getKurName(), afterMst.getKurName())){
                // 変更の場合
                kurCdList.add(afterMst.getKurCd());
              }
            }
          }
        }
        break;
      case "mst_bed":
        // ベッドマスタ key:ベッドコード(bed_cd) 特殊項目:表示フラグ(is_disp) 削除フラグ(is_del)
        Map<Long, MstBed> beforeMstBedListMap = beforeMstList.stream().collect(Collectors.toMap(o -> ((MstBed)o).getBedCd(), o -> (MstBed)o));
        for(Object objTmp: afterMstList) {
          MstBed afterMst = (MstBed) objTmp;
          MstBed beforeMst = beforeMstBedListMap.get(afterMst.getBedCd());
          if (beforeMst == null) {
            //　追加の場合
          } else {
            if (Objects.equals(beforeMst, afterMst)) {
              // 変更がない場合は次のレコード
              continue;
            } else {
              // 変更の場合
              if (!Objects.equals(beforeMst.getMachineNo(), afterMst.getMachineNo())) {
                // 装置番号変更の場合
                bedCdList.add(afterMst.getBedCd());
              }
            }
          }
        }
        break;
      case "mst_machine":
        // 装置マスタ key:装置番号(machine_no) 特殊項目:表示フラグ(is_disp) 削除フラグ(is_del)
        Map<Long, MstMachine> beforeMstMachineSettingListMap = beforeMstList.stream().collect(Collectors.toMap(o -> ((MstMachine)o).getMachineNo(), o -> (MstMachine)o));
        for(Object objTmp: afterMstList) {
          MstMachine afterMst = (MstMachine) objTmp;
          MstMachine beforeMst = beforeMstMachineSettingListMap.get(afterMst.getMachineNo());
          if (beforeMst == null) {
            //　追加の場合
          } else {
            if (Objects.equals(beforeMst, afterMst)) {
              // 変更がない場合は次のレコード
              continue;
            } else {
              // 変更の場合
              if (!Objects.equals(beforeMst.getMachineTypeCd(), afterMst.getMachineTypeCd())) {
                // 型式コード変更の場合
                machineNoList.add(afterMst.getMachineNo());
              } else if (!Objects.equals(beforeMst.getMachineSerial(), afterMst.getMachineSerial())) {
                // 製造番号変更の場合
                machineNoList.add(afterMst.getMachineNo());
              } else if (!Objects.equals(beforeMst.getComType(), afterMst.getComType())) {
                // 通信種別変更の場合
                machineNoList.add(afterMst.getMachineNo());
              } else if (!Objects.equals(beforeMst.getComFormatCd(), afterMst.getComFormatCd())) {
                // 通信フォーマット変更の場合
                machineNoList.add(afterMst.getMachineNo());
              } else if (!Objects.equals(beforeMst.getDeviceEdgeNo(), afterMst.getDeviceEdgeNo())) {
                // デバイスエッジ番号変更の場合
                machineNoList.add(afterMst.getMachineNo());
              } else if (!Objects.equals(beforeMst.getIpAddress(), afterMst.getIpAddress())) {
                // IPアドレス変更の場合
                machineNoList.add(afterMst.getMachineNo());
              } else if (!Objects.equals(beforeMst.getPort(), afterMst.getPort())) {
                // ポート番号変更の場合
                machineNoList.add(afterMst.getMachineNo());
              }
            }
          }
        }
        List<MstBed> mstBedList = mstBedDao.selectByFacilityCdAndMachineNoList(facilityCd, machineNoList);
        bedCdList = mstBedList.stream().map(item -> item.getBedCd()).distinct().collect(Collectors.toList());
        break;
      case "mst_va":
        // VAマスタ key:VAコード(va_cd) 特殊項目:表示フラグ(is_disp) 削除フラグ(is_del)
        mstComsvSettings = mstComsvSettingDao.selectAllByFacilityCdAndCodeList(facilityCd, Arrays.asList(Integer.valueOf(9)));

        if(mstComsvSettings != null && !mstComsvSettings.isEmpty()){
          Map<Integer, MstVa> beforeMstVaListMap = beforeMstList.stream().collect(Collectors.toMap(o -> ((MstVa)o).getVaCd(), o -> (MstVa)o));
          for(Object objTmp: afterMstList){
            MstVa afterMst = (MstVa)objTmp;
            MstVa beforeMst = beforeMstVaListMap.get(afterMst.getVaCd());
            if(beforeMst == null){
              //　追加の場合
            } else{
              if(Objects.equals(beforeMst, afterMst)){
                // 変更がない場合は次のレコード
                continue;
              } else{
                // 変更の場合
                if(!Objects.equals(beforeMst.getVaName(), afterMst.getVaName())){
                  // 変更の場合
                  vaCdForMemoList.add(afterMst.getVaCd());
                }
              }
            }
          }
          if(vaCdForMemoList !=null && !vaCdForMemoList.isEmpty()){
            List<String> deviceEdgeNoList = mstComsvSettings.stream().map(item -> item.getDeviceEdgeNo().toString()).distinct().collect(Collectors.toList());
            bedCdForMemoList = mstBedDao.selectMstComsvBed(deviceEdgeNoList, facilityCd).stream().map(Long::parseLong).collect(Collectors.toList());
          }
        }
        break;
      case "mst_comsv_setting":
        // 装置通信・仮想端末マスタ key:通信サーバー管理コード(comsv_cd) 特殊項目:表示フラグ(is_disp) 削除フラグ(is_del)

        List<MstComsvSetting> changedMstComsvSettingList = new ArrayList<>();

        Map<Long, MstComsvSetting> beforeMstComsvSettingListMap = beforeMstList.stream().collect(Collectors.toMap(o -> ((MstComsvSetting)o).getComsvCd(), o -> (MstComsvSetting)o));
        for(Object objTmp: afterMstList){
          MstComsvSetting afterMst = (MstComsvSetting)objTmp;
          MstComsvSetting beforeMst = beforeMstComsvSettingListMap.get(afterMst.getComsvCd());
          if(beforeMst == null){
            //　追加の場合
          } else{
            if(Objects.equals(beforeMst, afterMst)){
              // 変更がない場合は次のレコード
              continue;
            } else{
              // 変更の場合
              if(!Objects.equals(beforeMst.getLcdNpat(), afterMst.getLcdNpat())){
                // 次患者情報表示設定変更の場合
                changedMstComsvSettingList.add(afterMst);
              }
            }
          }
        }
        if(changedMstComsvSettingList != null && !changedMstComsvSettingList.isEmpty()){
          List<String> deviceEdgeNoList = changedMstComsvSettingList.stream().map(item -> item.getDeviceEdgeNo().toString()).distinct().collect(Collectors.toList());
          bedCdList = mstBedDao.selectMstComsvBed(deviceEdgeNoList, facilityCd).stream().map(Long::parseLong).collect(Collectors.toList());
        }
        break;
      case "mst_dialyzer":
        // ダイアライザマスタ key:ダイアライザコード(dialyzer_cd) 特殊項目:表示フラグ(is_disp) 削除フラグ(is_del)
        mstComsvSettings = mstComsvSettingDao.selectAllByFacilityCdAndCodeList(facilityCd, Arrays.asList(Integer.valueOf(14)));
        List<MstComsvSetting> mstComsvSettingsForEquipment = mstComsvSettingDao.selectAllByFacilityCdAndCodeList(facilityCd, arrayListForEquipmentMemo);

        Map<Integer, MstDialyzer> beforeMstDialyzerListMap = beforeMstList.stream().collect(Collectors.toMap(o -> ((MstDialyzer)o).getDialyzerCd(), o -> (MstDialyzer)o));
        for(Object objTmp: afterMstList){
          MstDialyzer afterMst = (MstDialyzer)objTmp;
          MstDialyzer beforeMst = beforeMstDialyzerListMap.get(afterMst.getDialyzerCd());
          if(beforeMst == null){
            //　追加の場合
          } else{
            if(Objects.equals(beforeMst, afterMst)){
              // 変更がない場合は次のレコード
              continue;
            } else{
              // 変更の場合
              if(!Objects.equals(beforeMst.getDialyzerType(), afterMst.getDialyzerType())){
                // ダイアライザ種別変更の場合
                dialyzerCdList.add(afterMst.getDialyzerCd());
              } else if(!Objects.equals(beforeMst.getGasPurgeTime(), afterMst.getGasPurgeTime())){
                // ガスパージ時間変更の場合
                dialyzerCdList.add(afterMst.getDialyzerCd());
              } else if(!Objects.equals(beforeMst.getSubstituentWashAmt(), afterMst.getSubstituentWashAmt())){
                // 置換洗浄量（透析液）変更の場合
                dialyzerCdList.add(afterMst.getDialyzerCd());
              } else if(!Objects.equals(beforeMst.getMembraneWash(), afterMst.getMembraneWash())){
                // 膜洗浄（中空糸）変更の場合
                dialyzerCdList.add(afterMst.getDialyzerCd());
              } else {
                if(!Objects.equals(beforeMst.getModelNumber(), afterMst.getModelNumber())){
                  // 型番(メモの名称)変更の場合
                  if(mstComsvSettings != null && !mstComsvSettings.isEmpty()){
                    dialyzerCdForMemoList.add(afterMst.getDialyzerCd());
                  } else if (mstComsvSettingsForEquipment != null && !mstComsvSettingsForEquipment.isEmpty()) {
                    dialyzerCdForMemoList.add(afterMst.getDialyzerCd());
                  }
                }
              }
            }
          }
        }
        if(dialyzerCdForMemoList != null && !dialyzerCdForMemoList.isEmpty()){
          if(mstComsvSettings != null && !mstComsvSettings.isEmpty()){
          List<String> deviceEdgeNoList = mstComsvSettings.stream().map(item -> item.getDeviceEdgeNo().toString()).distinct().collect(Collectors.toList());
          bedCdForMemoList = mstBedDao.selectMstComsvBed(deviceEdgeNoList, facilityCd).stream().map(Long::parseLong).collect(Collectors.toList());
        }
          if(mstComsvSettingsForEquipment != null && !mstComsvSettingsForEquipment.isEmpty()){
            List<String> deviceEdgeNoList = mstComsvSettingsForEquipment.stream().map(item -> item.getDeviceEdgeNo().toString()).distinct().collect(Collectors.toList());
            bedCdForMemoForEquipmentList = mstBedDao.selectMstComsvBed(deviceEdgeNoList, facilityCd).stream().map(Long::parseLong).collect(Collectors.toList());
          }
        }
        break;
      case "mst_treatment":
        // 治療方法マスタ key:治療方法コード(treatment_cd) 特殊項目:表示フラグ(is_disp) 削除フラグ(is_del)
        mstComsvSettings = mstComsvSettingDao.selectAllByFacilityCdAndCodeList(facilityCd, Arrays.asList(Integer.valueOf(13)));

        Map<Integer, MstTreatment> beforeMstTreatmentListMap = beforeMstList.stream().collect(Collectors.toMap(o -> ((MstTreatment)o).getTreatmentCd(), o -> (MstTreatment)o));
        for(Object objTmp: afterMstList){
          MstTreatment afterMst = (MstTreatment)objTmp;
          MstTreatment beforeMst = beforeMstTreatmentListMap.get(afterMst.getTreatmentCd());
          if(beforeMst == null){
            //　追加の場合
          } else{
            if(Objects.equals(beforeMst, afterMst)){
              // 変更がない場合は次のレコード
              continue;
            } else{
              // 変更の場合
              if(!Objects.equals(beforeMst.getDeviceMode(), afterMst.getDeviceMode())){
                // モード変更の場合
                treatmenCdList.add(afterMst.getTreatmentCd());
              } else if(!Objects.equals(beforeMst.getTreatmentName(), afterMst.getTreatmentName())){
                // 名称変更の場合　メモのところを治療方法名に変更
                if(mstComsvSettings != null && !mstComsvSettings.isEmpty()){
                  treatmenCdForMemoList.add(afterMst.getTreatmentCd());
                }
              }
            }
          }
        }
        if(treatmenCdForMemoList != null && !treatmenCdForMemoList.isEmpty()){
          List<String> deviceEdgeNoList = mstComsvSettings.stream().map(item -> item.getDeviceEdgeNo().toString()).distinct().collect(Collectors.toList());
          bedCdForMemoList = mstBedDao.selectMstComsvBed(deviceEdgeNoList, facilityCd).stream().map(Long::parseLong).collect(Collectors.toList());
        }
        break;
      case "mst_equipment":
        // 医療材料マスタ key:医療材料コード(equipment_cd) 特殊項目:表示フラグ(is_disp) 削除フラグ(is_del)
        mstComsvSettings = mstComsvSettingDao.selectAllByFacilityCdAndCodeList(facilityCd, arrayListForEquipmentMemo);
        List<MstComsvSetting> mstComsvSettingsForDialyzer = mstComsvSettingDao.selectAllByFacilityCdAndCodeList(facilityCd, Arrays.asList(Integer.valueOf(14)));
        List<MstComsvSetting> mstComsvSettingsForPrimaryMembrane = mstComsvSettingDao.selectAllByFacilityCdAndCodeList(facilityCd, Arrays.asList(Integer.valueOf(64)));
        List<MstComsvSetting> mstComsvSettingsForANeedle = mstComsvSettingDao.selectAllByFacilityCdAndCodeList(facilityCd, Arrays.asList(Integer.valueOf(15)));
        List<MstComsvSetting> mstComsvSettingsForVNeedle = mstComsvSettingDao.selectAllByFacilityCdAndCodeList(facilityCd, Arrays.asList(Integer.valueOf(16)));

        if((mstComsvSettings != null && !mstComsvSettings.isEmpty())
          || (mstComsvSettingsForDialyzer != null && !mstComsvSettingsForDialyzer.isEmpty())
          || (mstComsvSettingsForPrimaryMembrane != null && !mstComsvSettingsForPrimaryMembrane.isEmpty())
          || (mstComsvSettingsForANeedle != null && !mstComsvSettingsForANeedle.isEmpty())
          || (mstComsvSettingsForVNeedle != null && !mstComsvSettingsForVNeedle.isEmpty())){
          Map<Integer, MstEquipment> beforeMstEquipmentListMap = beforeMstList.stream().collect(Collectors.toMap(o -> ((MstEquipment)o).getEquipmentCd(), o -> (MstEquipment)o));
          for(Object objTmp: afterMstList){
            MstEquipment afterMst = (MstEquipment)objTmp;
            MstEquipment beforeMst = beforeMstEquipmentListMap.get(afterMst.getEquipmentCd());
            if(beforeMst == null){
              //　追加の場合
            } else{
              if(Objects.equals(beforeMst, afterMst)){
                // 変更がない場合は次のレコード
                continue;
              } else{
                // 変更の場合
                if(!Objects.equals(beforeMst.getEquipmentName(), afterMst.getEquipmentName())){
                  // 名称変更の場合
                  mstEquipmentCdForMemoList.add(afterMst.getEquipmentCd());
                } else if(!Objects.equals(beforeMst.getEquipmentShortName(), afterMst.getEquipmentShortName())){
                  // 省略名変更の場合
                  mstEquipmentCdForMemoList.add(afterMst.getEquipmentCd());
                } else if(!Objects.equals(beforeMst.getClassCd(), afterMst.getClassCd())){
                  // 分類変更の場合
                  mstEquipmentCdForMemoList.add(afterMst.getEquipmentCd());
                } else if(!Objects.equals(beforeMst.getUnit(), afterMst.getUnit())){
                  // 単位変更の場合
                  mstEquipmentCdForMemoList.add(afterMst.getEquipmentCd());
                }
              }
            }
          }

          if(mstEquipmentCdForMemoList != null && !mstEquipmentCdForMemoList.isEmpty()){
            if(mstComsvSettings != null && !mstComsvSettings.isEmpty()){
            List<String> deviceEdgeNoList = mstComsvSettings.stream().map(item -> item.getDeviceEdgeNo().toString()).distinct().collect(Collectors.toList());
            bedCdForMemoList = mstBedDao.selectMstComsvBed(deviceEdgeNoList, facilityCd).stream().map(Long::parseLong).collect(Collectors.toList());
          }
            if(mstComsvSettingsForDialyzer != null && !mstComsvSettingsForDialyzer.isEmpty()){
              List<String> deviceEdgeNoList = mstComsvSettingsForDialyzer.stream().map(item -> item.getDeviceEdgeNo().toString()).distinct().collect(Collectors.toList());
              bedCdForMemoForDialyzerList = mstBedDao.selectMstComsvBed(deviceEdgeNoList, facilityCd).stream().map(Long::parseLong).collect(Collectors.toList());
            }
            if(mstComsvSettingsForPrimaryMembrane != null && !mstComsvSettingsForPrimaryMembrane.isEmpty()){
              List<String> deviceEdgeNoList = mstComsvSettingsForPrimaryMembrane.stream().map(item -> item.getDeviceEdgeNo().toString()).distinct().collect(Collectors.toList());
              bedCdForMemoForPrimaryMembraneList = mstBedDao.selectMstComsvBed(deviceEdgeNoList, facilityCd).stream().map(Long::parseLong).collect(Collectors.toList());
            }
            if(mstComsvSettingsForANeedle != null && !mstComsvSettingsForANeedle.isEmpty()){
              List<String> deviceEdgeNoList = mstComsvSettingsForANeedle.stream().map(item -> item.getDeviceEdgeNo().toString()).distinct().collect(Collectors.toList());
              bedCdForMemoForANeedleMembraneList = mstBedDao.selectMstComsvBed(deviceEdgeNoList, facilityCd).stream().map(Long::parseLong).collect(Collectors.toList());
            }
            if(mstComsvSettingsForVNeedle != null && !mstComsvSettingsForVNeedle.isEmpty()){
              List<String> deviceEdgeNoList = mstComsvSettingsForVNeedle.stream().map(item -> item.getDeviceEdgeNo().toString()).distinct().collect(Collectors.toList());
              bedCdForMemoForVNeedleMembraneList = mstBedDao.selectMstComsvBed(deviceEdgeNoList, facilityCd).stream().map(Long::parseLong).collect(Collectors.toList());
            }
          }
        }
        break;
      case "mst_ward":
        // 病棟マスタ key:病棟コード(ward_cd) 特殊項目:表示フラグ(is_disp) 削除フラグ(is_del)
        mstComsvSettings = mstComsvSettingDao.selectAllByFacilityCdAndCodeList(facilityCd, Arrays.asList(Integer.valueOf(5)));

        if(mstComsvSettings != null && !mstComsvSettings.isEmpty()){
          Map<Integer, MstWard> beforeMstWardListMap = beforeMstList.stream().collect(Collectors.toMap(o -> ((MstWard)o).getWardCd(), o -> (MstWard)o));
          List<Integer> wardCdList = new ArrayList<>();
          for(Object objTmp: afterMstList){
            MstWard afterMst = (MstWard)objTmp;
            MstWard beforeMst = beforeMstWardListMap.get(afterMst.getWardCd());
            if(beforeMst == null){
              //　追加の場合
            } else{
              if(Objects.equals(beforeMst, afterMst)){
                // 変更がない場合は次のレコード
                continue;
              } else{
                // 変更の場合
                if(!Objects.equals(beforeMst.getWardName(), afterMst.getWardName())){
                  // 変更の場合
                  wardCdList.add(afterMst.getWardCd());
                }
              }
            }
          }
          if(wardCdList != null && !wardCdList.isEmpty()){
            List<PatMain> patMainList = patMainDao.selectByFacilityCdAndWardCd(facilityCd, wardCdList);
            if(patMainList != null && !patMainList.isEmpty()){
              patIdForMemoList = patMainList.stream().map(item -> item.getPat_id()).distinct().collect(Collectors.toList());

              List<String> deviceEdgeNoList = mstComsvSettings.stream().map(item -> item.getDeviceEdgeNo().toString()).distinct().collect(Collectors.toList());
              bedCdForMemoList = mstBedDao.selectMstComsvBed(deviceEdgeNoList, facilityCd).stream().map(Long::parseLong).collect(Collectors.toList());
            }
          }
        }
        break;
      case "mst_course":
        // 診療科マスタ key:診療科コード(course_cd) 特殊項目:表示フラグ(is_disp) 削除フラグ(is_del)
        mstComsvSettings = mstComsvSettingDao.selectAllByFacilityCdAndCodeList(facilityCd, Arrays.asList(Integer.valueOf(6)));

        if(mstComsvSettings != null && !mstComsvSettings.isEmpty()){
          Map<Integer, MstCourse> beforeMstCourseListMap = beforeMstList.stream().collect(Collectors.toMap(o -> ((MstCourse)o).getCourseCd(), o -> (MstCourse)o));
          List<Integer> courseCdList = new ArrayList<>();
          for(Object objTmp: afterMstList){
            MstCourse afterMst = (MstCourse)objTmp;
            MstCourse beforeMst = beforeMstCourseListMap.get(afterMst.getCourseCd());
            if(beforeMst == null){
              //　追加の場合
            } else{
              if(Objects.equals(beforeMst, afterMst)){
                // 変更がない場合は次のレコード
                continue;
              } else{
                // 変更の場合
                if(!Objects.equals(beforeMst.getCourseName(), afterMst.getCourseName())){
                  // 変更の場合
                  courseCdList.add(afterMst.getCourseCd());
                }
              }
            }
          }
          if(courseCdList != null && !courseCdList.isEmpty()){
            List<PatMain> patMainList = patMainDao.selectByFacilityCdAndCourseCd(facilityCd, courseCdList);
            if(patMainList != null && !patMainList.isEmpty()){
              patIdForMemoList = patMainList.stream().map(item -> item.getPat_id()).distinct().collect(Collectors.toList());

              List<String> deviceEdgeNoList = mstComsvSettings.stream().map(item -> item.getDeviceEdgeNo().toString()).distinct().collect(Collectors.toList());
              bedCdForMemoList = mstBedDao.selectMstComsvBed(deviceEdgeNoList, facilityCd).stream().map(Long::parseLong).collect(Collectors.toList());
            }
          }

        }
        break;
      case "mst_personal_user":
        // 利用者マスタ key:利用者ID（内部用ID）(user_id) 特殊項目:表示フラグ(is_disp) 削除フラグ(is_del)
        mstComsvSettings = mstComsvSettingDao.selectAllByFacilityCdAndCodeList(facilityCd, Arrays.asList(Integer.valueOf(7)));

        if(mstComsvSettings != null && !mstComsvSettings.isEmpty()){
          Map<Long, MstPersonalUser> beforeMstPersonalUserListMap = beforeMstList.stream().collect(Collectors.toMap(o -> ((MstPersonalUser)o).getUserId(), o -> (MstPersonalUser)o));
          List<Long> userIdList = new ArrayList<>();
          for(Object objTmp: afterMstList){
            MstPersonalUser afterMst = (MstPersonalUser)objTmp;
            MstPersonalUser beforeMst = beforeMstPersonalUserListMap.get(afterMst.getUserId());
            if(beforeMst == null){
              //　追加の場合
            } else{
              if(Objects.equals(beforeMst, afterMst)){
                // 変更がない場合は次のレコード
                continue;
              } else{
                // 変更の場合
                if(!Objects.equals(beforeMst.getUserLastName(), afterMst.getUserLastName())
                  || !Objects.equals(beforeMst.getUserFirstName(), afterMst.getUserFirstName())){
                  // 利用者名_姓or利用者名_名変更の場合
                  userIdList.add(afterMst.getUserId());
                }
              }
            }
          }
          if(userIdList != null && !userIdList.isEmpty()){
            List<PatMain> patMainList = patMainDao.selectByFacilityCdAndStaffCd(facilityCd, userIdList);
            if(patMainList != null && !patMainList.isEmpty()){
              patIdForMemoList = patMainList.stream().map(item -> item.getPat_id()).distinct().collect(Collectors.toList());

              List<String> deviceEdgeNoList = mstComsvSettings.stream().map(item -> item.getDeviceEdgeNo().toString()).distinct().collect(Collectors.toList());
              bedCdForMemoList = mstBedDao.selectMstComsvBed(deviceEdgeNoList, facilityCd).stream().map(Long::parseLong).collect(Collectors.toList());
            }
          }
        }
        break;
      case "mst_medicine":
        // 薬剤マスタ key:薬剤コード(medicine_cd) 特殊項目:表示フラグ(is_disp) 削除フラグ(is_del)
        mstComsvSettings = mstComsvSettingDao.selectAllByFacilityCdAndCodeList(facilityCd, arrayListForMedicineMemo);
        mstComsvSettingsForDialysate = mstComsvSettingDao.selectAllByFacilityCdAndCodeList(facilityCd, Arrays.asList(Integer.valueOf(35)));
        mstComsvSettingsForAnticoagulant = mstComsvSettingDao.selectAllByFacilityCdAndCodeList(facilityCd, Arrays.asList(Integer.valueOf(17)));

        if((mstComsvSettings != null && !mstComsvSettings.isEmpty())
          || (mstComsvSettingsForDialysate != null && !mstComsvSettingsForDialysate.isEmpty())
          || (mstComsvSettingsForAnticoagulant != null && !mstComsvSettingsForAnticoagulant.isEmpty())){
          Map<Integer, MstMedicine> beforeMstMedicineListMap = beforeMstList.stream().collect(Collectors.toMap(o -> ((MstMedicine)o).getMedicineCd(), o -> (MstMedicine)o));
          for(Object objTmp: afterMstList){
            MstMedicine afterMst = (MstMedicine)objTmp;
            MstMedicine beforeMst = beforeMstMedicineListMap.get(afterMst.getMedicineCd());
            if(beforeMst == null){
              //　追加の場合
            } else{
              if(Objects.equals(beforeMst, afterMst)){
                // 変更がない場合は次のレコード
                continue;
              } else{
                // 変更の場合
                if(!Objects.equals(beforeMst.getMedicineName(), afterMst.getMedicineName())){
                  // 名称変更の場合
                  mstMedicineCdForMemoList.add(afterMst.getMedicineCd());
                } else if(!Objects.equals(beforeMst.getMedicineShortName(), afterMst.getMedicineShortName())){
                  // 省略名変更の場合
                  mstMedicineCdForMemoList.add(afterMst.getMedicineCd());
                } else if(!Objects.equals(beforeMst.getClassCd(), afterMst.getClassCd())){
                  // 分類変更の場合
                  mstMedicineCdForMemoList.add(afterMst.getMedicineCd());
                } else if(!Objects.equals(beforeMst.getUnit(), afterMst.getUnit())){
                  // 単位変更の場合
                  mstMedicineCdForMemoList.add(afterMst.getMedicineCd());
                }
              }
            }
          }
          if(mstMedicineCdForMemoList != null && !mstMedicineCdForMemoList.isEmpty()){
            if(mstComsvSettings != null && !mstComsvSettings.isEmpty()){
            List<String> deviceEdgeNoList = mstComsvSettings.stream().map(item -> item.getDeviceEdgeNo().toString()).distinct().collect(Collectors.toList());
            bedCdForMemoList = mstBedDao.selectMstComsvBed(deviceEdgeNoList, facilityCd).stream().map(Long::parseLong).collect(Collectors.toList());
          }
            if(mstComsvSettingsForDialysate != null && !mstComsvSettingsForDialysate.isEmpty()){
              List<String> deviceEdgeNoList = mstComsvSettingsForDialysate.stream().map(item -> item.getDeviceEdgeNo().toString()).distinct().collect(Collectors.toList());
              bedCdForMemoForDialysateList = mstBedDao.selectMstComsvBed(deviceEdgeNoList, facilityCd).stream().map(Long::parseLong).collect(Collectors.toList());
            }
            if(mstComsvSettingsForAnticoagulant != null && !mstComsvSettingsForAnticoagulant.isEmpty()){
              List<String> deviceEdgeNoList = mstComsvSettingsForAnticoagulant.stream().map(item -> item.getDeviceEdgeNo().toString()).distinct().collect(Collectors.toList());
              bedCdForMemoForAnticoagulantList = mstBedDao.selectMstComsvBed(deviceEdgeNoList, facilityCd).stream().map(Long::parseLong).collect(Collectors.toList());
            }
          }
        }
        break;
      case "mst_medicine_mix":
        // 調製薬剤マスタ key:調整薬剤コード(medicine_mix_cd) 特殊項目:表示フラグ(is_disp) 削除フラグ(is_del)
        mstComsvSettings = mstComsvSettingDao.selectAllByFacilityCdAndCodeList(facilityCd, arrayListForMedicineMemo);
        mstComsvSettingsForDialysate = mstComsvSettingDao.selectAllByFacilityCdAndCodeList(facilityCd, Arrays.asList(Integer.valueOf(35)));
        mstComsvSettingsForAnticoagulant = mstComsvSettingDao.selectAllByFacilityCdAndCodeList(facilityCd, Arrays.asList(Integer.valueOf(17)));

        if((mstComsvSettings != null && !mstComsvSettings.isEmpty())
          || (mstComsvSettingsForDialysate != null && !mstComsvSettingsForDialysate.isEmpty())
          || (mstComsvSettingsForAnticoagulant != null && !mstComsvSettingsForAnticoagulant.isEmpty())){
          Map<Integer, MstMedicineMix> beforeMstMedicineListMap = beforeMstList.stream().collect(Collectors.toMap(o -> ((MstMedicineMix)o).getMedicineMixCd(), o -> (MstMedicineMix)o));
          for(Object objTmp: afterMstList){
            MstMedicineMix afterMst = (MstMedicineMix)objTmp;
            MstMedicineMix beforeMst = beforeMstMedicineListMap.get(afterMst.getMedicineMixCd());
            if(beforeMst == null){
              //　追加の場合
            } else{
              if(Objects.equals(beforeMst, afterMst)){
                // 変更がない場合は次のレコード
                continue;
              } else{
                // 変更の場合
                if(!Objects.equals(beforeMst.getMedicineMixName(), afterMst.getMedicineMixName())){
                  // 名称変更の場合
                  mstMedicineMixCdForMemoList.add(afterMst.getMedicineMixCd());
                } else if(!Objects.equals(beforeMst.getMedicineMixShortName(), afterMst.getMedicineMixShortName())){
                  // 省略名変更の場合
                  mstMedicineMixCdForMemoList.add(afterMst.getMedicineMixCd());
                } else if(!Objects.equals(beforeMst.getClassCd(), afterMst.getClassCd())){
                  // 分類変更の場合
                  mstMedicineMixCdForMemoList.add(afterMst.getMedicineMixCd());
                } else if(!Objects.equals(beforeMst.getUnit(), afterMst.getUnit())){
                  // 単位変更の場合
                  mstMedicineMixCdForMemoList.add(afterMst.getMedicineMixCd());
                }
              }
            }
          }
          if(mstMedicineMixCdForMemoList != null && !mstMedicineMixCdForMemoList.isEmpty()){
            if(mstComsvSettings != null && !mstComsvSettings.isEmpty()){
            List<String> deviceEdgeNoList = mstComsvSettings.stream().map(item -> item.getDeviceEdgeNo().toString()).distinct().collect(Collectors.toList());
            bedCdForMemoList = mstBedDao.selectMstComsvBed(deviceEdgeNoList, facilityCd).stream().map(Long::parseLong).collect(Collectors.toList());
          }
            if(mstComsvSettingsForDialysate != null && !mstComsvSettingsForDialysate.isEmpty()){
              List<String> deviceEdgeNoList = mstComsvSettingsForDialysate.stream().map(item -> item.getDeviceEdgeNo().toString()).distinct().collect(Collectors.toList());
              bedCdForMemoForDialysateList = mstBedDao.selectMstComsvBed(deviceEdgeNoList, facilityCd).stream().map(Long::parseLong).collect(Collectors.toList());
            }
            if(mstComsvSettingsForAnticoagulant != null && !mstComsvSettingsForAnticoagulant.isEmpty()){
              List<String> deviceEdgeNoList = mstComsvSettingsForAnticoagulant.stream().map(item -> item.getDeviceEdgeNo().toString()).distinct().collect(Collectors.toList());
              bedCdForMemoForAnticoagulantList = mstBedDao.selectMstComsvBed(deviceEdgeNoList, facilityCd).stream().map(Long::parseLong).collect(Collectors.toList());
            }
          }
        }
        break;
      default:
        break;
    }

    long totalCnt = treatmenCdList.size() + kurCdList.size() + bedCdList.size() + bedCdForMemoList.size() + dialyzerCdList.size() + dialyzerCdForMemoList.size() + patIdForMemoList.size() + vaCdForMemoList.size() + treatmenCdForMemoList.size() + mstEquipmentCdForMemoList.size() + mstMedicineCdForMemoList.size() + mstMedicineMixCdForMemoList.size();
    if(totalCnt > 0){
      List<MntMachineState> mntMachineStateList = mntMachineStateDao.selectAllByFacilityCd(facilityCd);
      List<Long> ordNoList = mntMachineStateList.stream().map(item -> item.getNextOrdNo()).filter(nextOrdNo -> nextOrdNo != null).distinct().collect(Collectors.toList());

      nextPatInfo1or2ChangedOrdMainList = ordMainDao.selectByListConditionForMstNextPatInfo1or2Changed(facilityCd, ordNoList, treatmenCdList, kurCdList, bedCdList, bedCdForMemoList, bedCdForMemoForEquipmentList, bedCdForMemoForDialyzerList, bedCdForMemoForPrimaryMembraneList, bedCdForMemoForANeedleMembraneList, bedCdForMemoForVNeedleMembraneList, bedCdForMemoForDialysateList, bedCdForMemoForAnticoagulantList, dialyzerCdList, dialyzerCdForMemoList, patIdForMemoList, vaCdForMemoList, treatmenCdForMemoList, mstEquipmentCdForMemoList, mstMedicineCdForMemoList, mstMedicineMixCdForMemoList);

      //add #10806  ベッドマスタで接続装置未登録とした場合にゴミデータが残る。 zrx start
      List<Long> noNextOrdNoBedCds = mntMachineStateList.stream().filter(machineState -> machineState.getNextOrdNo() == null).map(item -> item.getBedCd()).distinct().collect(Collectors.toList());
      if(noNextOrdNoBedCds != null && !noNextOrdNoBedCds.isEmpty()){
        try {
          for(Long bedCd : noNextOrdNoBedCds){
            if(bedCdList.contains(bedCd)){
              webApiCallCommonUtil.OverrideSetNextPatInfo(bedCd, false, LocalDateTime.now(), false, null);
            }
          }
        } catch (URISyntaxException e) {
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("「次患者更新」処理失敗");
          logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessageNew = new EventLogMessage();
          eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
          if (!StringUtils.isEmpty(facilityCd)) {
            eventLogMessageNew.setFacilityCd(facilityCd);
          }
          logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
        }
      }
      //add #10806  ベッドマスタで接続装置未登録とした場合にゴミデータが残る。 zrx end

    }

    return nextPatInfo1or2ChangedOrdMainList;
  }

  /**
   * 次患者更新判定処理（患者情報）
   *
   * @param facilityCd
   * @param beforePatMain 変更前PatMain
   * @param afterPatMain 変更後PatMain
   * @param beforePatPersonalMain 変更前PatPersonalMain
   * @param afterPatPersonalMain 変更後PatPersonalMain
   * @return void
   * @description パラメータで条件送信キャンセル処理しない場合がある
   */
  @Override
  public boolean CheckDoCallNextPatChangeForPat(String facilityCd, PatMain beforePatMain, PatMain afterPatMain, PatPersonalMain beforePatPersonalMain, PatPersonalMain afterPatPersonalMain){
    // --------------------
    // 変更前後PatMain,PatPersonalMainによる次患者送信判定処理
    // --------------------
    if(!Objects.equals(beforePatPersonalMain, afterPatPersonalMain)){
      if(beforePatPersonalMain == null){
        beforePatPersonalMain = new PatPersonalMain();
      }
      if(afterPatPersonalMain == null){
        afterPatPersonalMain = new PatPersonalMain();
      }
      // 次患者情報１：アドレス ０～２１８ 患者名
      if(!Objects.equals(beforePatPersonalMain.getPat_last_name(), afterPatPersonalMain.getPat_last_name())
        || !Objects.equals(beforePatPersonalMain.getPat_first_name(), afterPatPersonalMain.getPat_first_name())){
        return true;
      }
    }
    if(!Objects.equals(beforePatMain, afterPatMain)){
      if(beforePatMain == null){
        beforePatMain = new PatMain();
      }
      if(afterPatMain == null){
        afterPatMain = new PatMain();
      }
      // 次患者情報１：アドレス ０～２１８ 感染症
      if(!Objects.equals(beforePatMain.getIs_infect(), afterPatMain.getIs_infect())){
        return true;
      }
      //----------------------------------------------------
      // 次患者情報１：アドレス ２１９～２３８ プライミング補助、自動プライミング
      // 次患者情報２：アドレス ３１～３３，５１～５３ オンラインプライミング
      // 次患者情報２：アドレス １，５，７～１０、１１（予備），５４～５９ ＤＦＡＳプライミング
      if(!Objects.equals(beforePatMain.getDevice_set_info(), afterPatMain.getDevice_set_info())){
        // beforeDeviceSetInfo
        JSONObject beforeDeviceSetInfoJsonObj = new JSONObject(beforePatMain.getDevice_set_info());
        // afterDeviceSetInfo
        JSONObject afterDeviceSetInfoJsonObj = new JSONObject(afterPatMain.getDevice_set_info());

        //次患者情報１　プライミング
        JSONObject beforePriPatJsonObj = new JSONObject();
        JSONObject afterPriPatJsonObj = new JSONObject();
        // before
        if (beforeDeviceSetInfoJsonObj.has("pri")) {
          JSONObject beforePriObj = beforeDeviceSetInfoJsonObj.getJSONObject("pri");
          beforePriPatJsonObj = (null != beforePriObj && beforePriObj.has("pat")) ? beforePriObj.getJSONObject("pat") : null;
        }
        // after
        if (afterDeviceSetInfoJsonObj.has("pri")) {
          JSONObject afterPriObj = afterDeviceSetInfoJsonObj.getJSONObject("pri");
          afterPriPatJsonObj = (null != afterPriObj && afterPriObj.has("pat")) ? afterPriObj.getJSONObject("pat") : null;
        }
        if(!Objects.equals(beforePriPatJsonObj, afterPriPatJsonObj)
          && (beforePriPatJsonObj != null || afterPriPatJsonObj != null)){
          return true;
        }
        //次患者情報２　プライミング
        JSONObject beforeDfasPatJsonObj = new JSONObject();
        JSONObject afterDfasPatJsonObj = new JSONObject();
        // before
        if (beforeDeviceSetInfoJsonObj.has("dfas")) {
          JSONObject beforeDfasObj = beforeDeviceSetInfoJsonObj.getJSONObject("dfas");
          beforeDfasPatJsonObj = (null != beforeDfasObj && beforeDfasObj.has("pat")) ? beforeDfasObj.getJSONObject("pat") : null;
        }
        // after
        if (afterDeviceSetInfoJsonObj.has("dfas")) {
          JSONObject afterDfasObj = afterDeviceSetInfoJsonObj.getJSONObject("dfas");
          afterDfasPatJsonObj = (null != afterDfasObj && afterDfasObj.has("pat")) ? afterDfasObj.getJSONObject("pat") : null;
        }
        if(!Objects.equals(beforeDfasPatJsonObj, afterDfasPatJsonObj)
          && (beforeDfasPatJsonObj != null || afterDfasPatJsonObj != null)){
          return true;
        }
      }
    }
    return false;
  }

  /**
   * 次患者更新判定処理　次患者情報メモ（患者情報）
   *
   * @param facilityCd
   * @param bedCd
   * @param beforePatMain 変更前PatMain
   * @param afterPatMain 変更後PatMain
   * @param beforePatPersonalMain 変更前PatPersonalMain
   * @param afterPatPersonalMain 変更後PatPersonalMain
   * @return void
   * @description パラメータで条件送信キャンセル処理しない場合がある　
   */
  @Override
  public boolean CheckDoCallNextPatChangeForPatMemo(String facilityCd, Integer bedCd, PatMain beforePatMain, PatMain afterPatMain, PatPersonalMain beforePatPersonalMain, PatPersonalMain afterPatPersonalMain, MstComsvSetting mstComsvInfo){

    if(mstComsvInfo == null){
      List<MstComsvSetting> mstComsvInfos = mstComsvSettingDao.selectByBedCds(facilityCd, Arrays.asList(bedCd));
      if(mstComsvInfos != null && !mstComsvInfos.isEmpty()){
        mstComsvInfo = mstComsvInfos.get(0);
      }
    }

    if (mstComsvInfo != null && mstComsvInfo.getLcdNpat() != null) {
      JSONObject lcdNpat = new JSONObject(mstComsvInfo.getLcdNpat());
      Gson gson = new Gson();
      Type listInfoType = new TypeToken<List<NpatItem>>() {}.getType();

      //get  memo  patInfo
      List<NpatItem> npatList = gson.fromJson(lcdNpat.get("npat_item").toString(), listInfoType);

      JSONObject beforeMedicalCareInfoPatJsonObj = new JSONObject();
      JSONObject afterMedicalCareInfoPatJsonObj = new JSONObject();
      if(!Objects.equals(beforePatMain, afterPatMain)){
        if(beforePatMain != null) beforeMedicalCareInfoPatJsonObj = new JSONObject(beforePatMain.getMedical_care_info());
        if(afterPatMain != null) afterMedicalCareInfoPatJsonObj = new JSONObject(afterPatMain.getMedical_care_info());
      }
      String beforeWardCd = null;
      String afterWardCd = null;
      String beforeMainCourseCd = null;
      String afterMainCourseCd = null;
      String beforeDialysisCourseCd = null;
      String afterDialysisCourseCd = null;

      for(NpatItem npatItem : npatList){
        switch (npatItem.getCode()){
          case 1: // 患者ID
          case 2: // 患者名フリガナ
          case 3: // 性別・年齢
          case 4: // 入外
            if(!Objects.equals(beforePatPersonalMain, afterPatPersonalMain)){
              if(beforePatPersonalMain == null){
                beforePatPersonalMain = new PatPersonalMain();
              }
              if(afterPatPersonalMain == null){
                afterPatPersonalMain = new PatPersonalMain();
              }
              switch (npatItem.getCode()){
                case 1:
                  // 患者ID
                  if(!Objects.equals(beforePatPersonalMain.getHosp_pat_id(), afterPatPersonalMain.getHosp_pat_id())){
                    return true;
                  }
                  break;
                case 2:
                  // 患者名フリガナ
                  if(!Objects.equals(beforePatPersonalMain.getPat_last_name_kana(), afterPatPersonalMain.getPat_last_name_kana())
                    || !Objects.equals(beforePatPersonalMain.getPat_first_name_kana(), afterPatPersonalMain.getPat_first_name_kana())){
                    return true;
                  }
                  break;
                case 3:
                  // 性別・年齢
                  if(!Objects.equals(beforePatPersonalMain.getPat_sex(), afterPatPersonalMain.getPat_sex())){
                    return true;
                  }
                  if(!Objects.equals(beforePatPersonalMain.getPat_birthday(), afterPatPersonalMain.getPat_birthday())){
                    return true;
                  }
                  break;
                case 4:
                  // 入外
                  if(!Objects.equals(beforePatPersonalMain.getIn_out_class(), afterPatPersonalMain.getIn_out_class())){
                    return true;
                  }
                  break;
                default:
                  break;
              }
            }
            break;
          case 5: // 病棟
          case 6: // 診療科(主科コード,透析実施科コード)
          case 7: // 主治医
            if(!Objects.equals(beforePatMain, afterPatMain)){
              if(beforePatMain == null){
                beforePatMain = new PatMain();
              }
              if(afterPatMain == null){
                afterPatMain = new PatMain();
              }
              switch (npatItem.getCode()){
                case 5:
                  // 病棟
                  // before
                  if (beforeMedicalCareInfoPatJsonObj.has("ward_cd")) {
                    beforeWardCd = beforeMedicalCareInfoPatJsonObj.optString("ward_cd");
                  }
                  // after
                  if (afterMedicalCareInfoPatJsonObj.has("ward_cd")) {
                    afterWardCd = afterMedicalCareInfoPatJsonObj.optString("ward_cd");
                  }
                  if(!Objects.equals(beforeWardCd, afterWardCd)
                    && (beforeWardCd != null || afterWardCd != null)){
                    return true;
                  }
                  break;
                case 6:
                  // 診療科
                  // 主科コード
                  // before
                  if (beforeMedicalCareInfoPatJsonObj.has("main_course_cd")) {
                    beforeMainCourseCd = beforeMedicalCareInfoPatJsonObj.optString("main_course_cd");
                  }
                  // after
                  if (afterMedicalCareInfoPatJsonObj.has("main_course_cd")) {
                    afterMainCourseCd = afterMedicalCareInfoPatJsonObj.optString("main_course_cd");
                  }
                  if(!Objects.equals(beforeMainCourseCd, afterMainCourseCd)
                    && (beforeMainCourseCd != null || afterMainCourseCd != null)){
                    return true;
                  }

                  // 透析実施科コード
                  // before
                  if (beforeMedicalCareInfoPatJsonObj.has("dialysis_course_cd")) {
                    beforeDialysisCourseCd = beforeMedicalCareInfoPatJsonObj.optString("dialysis_course_cd");
                  }
                  // after
                  if (afterMedicalCareInfoPatJsonObj.has("dialysis_course_cd")) {
                    afterDialysisCourseCd = afterMedicalCareInfoPatJsonObj.optString("dialysis_course_cd");
                  }
                  if(!Objects.equals(beforeDialysisCourseCd, afterDialysisCourseCd)
                    && (beforeDialysisCourseCd != null || afterDialysisCourseCd != null)){
                    return true;
                  }
                  break;
                case 7:
                  // 主治医
                  List<ChargeStaffDiffInfo> beforChargeStaffInfoList = null;
                  List<ChargeStaffDiffInfo> afterChargeStaffInfoList = null;
                  Type listChargeStaffInfoType = new TypeToken<List<ChargeStaffDiffInfo>>() {}.getType();

                  if(!Objects.equals(beforePatMain.getCharge_staff_info(), afterPatMain.getCharge_staff_info())) {
                    String beforMainDoctorCd = null;
                    String afterMainDoctorCd = null;

                    // beforeIndMediInfo
                    beforChargeStaffInfoList = gson.fromJson(beforePatMain.getCharge_staff_info(), listChargeStaffInfoType);
                    beforChargeStaffInfoList = beforChargeStaffInfoList.stream().filter(o -> Objects.equals(o.getIs_main(),"1")).collect(Collectors.toList());
                    if (beforChargeStaffInfoList != null && !beforChargeStaffInfoList.isEmpty()){
                      beforMainDoctorCd = beforChargeStaffInfoList.get(0).getStaff_cd();
                    }

                    // afterIndMediInfo
                    afterChargeStaffInfoList = gson.fromJson(afterPatMain.getCharge_staff_info(), listChargeStaffInfoType);
                    afterChargeStaffInfoList = afterChargeStaffInfoList.stream().filter(o -> Objects.equals(o.getIs_main(),"1")).collect(Collectors.toList());
                    if (afterChargeStaffInfoList != null && !afterChargeStaffInfoList.isEmpty()){
                      afterMainDoctorCd = afterChargeStaffInfoList.get(0).getStaff_cd();
                    }
                    if(!Objects.equals(beforMainDoctorCd, afterMainDoctorCd)){
                      return true;
                    }
                  }
                  break;
                default:
                  break;
              }
            }
            break;
          default:
            break;
        }
      }
    }
    return false;
  }

  /**
   * 条件送信キャンセル・次患者更新実行纏め処理 治療情報関連次患者情報１or２で変更が発生したかのチェック
   *
   * @param facilityCd
   * @param beforePatUnique 変更前PatUnique
   * @param afterPatUnique 変更後PatUnique
   * @return List<OrdMain>
   * @description 次患者情報１or２で変更が発生した場合の後で呼び出す元側でCallNextPatChangeを呼び出す必要あり
   */
  @Override
  public List<OrdMain> FilterNextPatInfo1or2ChangedForDw(String facilityCd, PatUnique beforePatUnique, PatUnique afterPatUnique){

    List<OrdMain> nextPatInfo1or2ChangedOrdMainList = new ArrayList<>();

    // beforePatUniqueがnullの場合は、そのまま抜ける
    if(beforePatUnique == null){
      return nextPatInfo1or2ChangedOrdMainList;
    }
    if(afterPatUnique == null){
      afterPatUnique = patUniqueDao.selectById(beforePatUnique.getPat_id());
    }

    if(Objects.equals(beforePatUnique, afterPatUnique)){
      return nextPatInfo1or2ChangedOrdMainList;
    }

    Gson gson = new Gson();
    List<MntMachineState> mntMachineStateList = mntMachineStateDao.selectByNextPatIdList(facilityCd, Arrays.asList(beforePatUnique.getPat_id()));
    List<Long> ordNoList = mntMachineStateList.stream().map(item -> item.getNextOrdNo()).distinct().collect(Collectors.toList());
    List<OrdMain> ordMainList = ordMainDao.selectByOrdNoList(ordNoList);
    if(ordMainList == null && ordMainList.isEmpty()){
      return nextPatInfo1or2ChangedOrdMainList;
    }
    List<Integer> bedCdList = mntMachineStateList.stream().map(item -> item.getBedCd().intValue()).distinct().collect(Collectors.toList());
    List<MstComsvSetting> mstComsvInfos = mstComsvSettingDao.selectByBedCds(facilityCd, bedCdList);
    Map<Integer,MstComsvSetting> mstComsvInfosMap = mstComsvInfos.stream().collect(Collectors.toMap(o -> o.getNextPatMode(), o -> o));
    Map<Integer, Boolean> bedCdDwMemoMap = mstComsvInfos.stream()
      .collect(Collectors.toMap(
        o -> o.getNextPatMode(),
        mstComsvInfo -> {
          if (mstComsvInfo != null && mstComsvInfo.getLcdNpat() != null) {
            JSONObject lcdNpat = new JSONObject(mstComsvInfo.getLcdNpat());
            Type listInfoType = new TypeToken<List<NpatItem>>() {}.getType();
            List<NpatItem> npatList = gson.fromJson(lcdNpat.get("npat_item").toString(), listInfoType);
            boolean findedFlg = false;
            for (NpatItem npatItem : npatList) {
              // DW
              if(npatItem.getCode() == 8) {
                findedFlg = true;
                break;
              }
            }
            return findedFlg;
          } else {
            return false; // デフォルトはfalse
          }
        }
      ));

    if(mstComsvInfosMap.isEmpty()){
      return nextPatInfo1or2ChangedOrdMainList;
    }

    if(Objects.equals(beforePatUnique.getPhysical_info(), afterPatUnique.getPhysical_info())){
      return nextPatInfo1or2ChangedOrdMainList;
    }

    Type physicalInfoType = new TypeToken<List<PatPhysicalInfo>>() {}.getType();

    List<PatPhysicalInfo> beforePatPhysicalInfoList = new ArrayList<>();
    if(beforePatUnique.getPhysical_info() != null){
      beforePatPhysicalInfoList = gson.fromJson(beforePatUnique.getPhysical_info(), physicalInfoType);
      beforePatPhysicalInfoList = beforePatPhysicalInfoList.stream().filter(o->o.getDw() != null).sorted(Comparator.comparing(PatPhysicalInfo::getExam_date)).collect(Collectors.toList());
    }
    List<PatPhysicalInfo> afterPatPhysicalInfoList = new ArrayList<>();
    if(afterPatUnique.getPhysical_info() != null){
      afterPatPhysicalInfoList = gson.fromJson(afterPatUnique.getPhysical_info(), physicalInfoType);
      afterPatPhysicalInfoList = afterPatPhysicalInfoList.stream().filter(o->o.getDw() != null).sorted(Comparator.comparing(PatPhysicalInfo::getExam_date)).collect(Collectors.toList());
    }

    //mod #10601 スケジュール表動作不正 start
    Map<String, String> timeLineForDwTmp = new HashMap<>();
    timeLineForDwTmp.put("1900-01-01T00:00:00.000+09:00", "old");

    int sizeJ = afterPatPhysicalInfoList.size();
    int sizeK = beforePatPhysicalInfoList.size();
    int j = 0; // for afterPatPhysicalInfoList
    int k = 0; // for beforePatPhysicalInfoList
    if(sizeJ == 0 && sizeK == 0){
      return nextPatInfo1or2ChangedOrdMainList;
    }
    if(sizeJ == 0){
      timeLineForDwTmp.put(beforePatPhysicalInfoList.get(0).getExam_date(), "new");
    } else if(sizeK == 0){
      timeLineForDwTmp.put(afterPatPhysicalInfoList.get(0).getExam_date(), "new");
    } else{
      String afterExamDate = null;
      String beforeExamDate = null;
      String afterDw = null;
      String beforeDw = null;
      for(int i = 0; i< (sizeJ + sizeK); i++){
        if(j < sizeJ){
          afterDw = afterPatPhysicalInfoList.get(j).getDw();
          afterExamDate = afterPatPhysicalInfoList.get(j).getExam_date();
        }
        if(k < sizeK){
          beforeDw = beforePatPhysicalInfoList.get(k).getDw();
          beforeExamDate = beforePatPhysicalInfoList.get(k).getExam_date();
        }
        if(afterExamDate.compareTo(beforeExamDate) > 0) {
          if(i == 0 && j == 0){
            timeLineForDwTmp.put(beforeExamDate, "new");
          } else {
            timeLineForDwTmp.put(afterExamDate, "new");
          }
          k = k + 1;
        } else if(afterExamDate.compareTo(beforeExamDate) < 0) {
          timeLineForDwTmp.put(afterExamDate, "new");
          j = j + 1;
        } else {
          // afterExamDate = beforeExamDate
          if(Objects.equals(afterDw, beforeDw)){
            timeLineForDwTmp.put(beforeExamDate, "old");
          } else {
            timeLineForDwTmp.put(afterExamDate, "new");
          }
          j = j + 1;
          k = k + 1;
          i = i + 1;
        }
      }
    }
    timeLineForDwTmp.put("9999-12-31T23:59:59.999+09:00", "old");


    Map<String, String> timeLineForDw = new HashMap<>();

    Iterator<Map.Entry<String, String>> iterator = timeLineForDwTmp.entrySet().stream()
      .sorted(Map.Entry.comparingByKey())
      .iterator();

    Map.Entry<String, String> previousEntry = null;

    while (iterator.hasNext()) {
      Map.Entry<String, String> currentEntry = iterator.next();

      // 現在Itemのkey、value
      String currentKey = currentEntry.getKey();
      String currentValue = currentEntry.getValue();

      // 前のItemのkey
      String previousKey = (previousEntry != null) ? previousEntry.getKey() : null;
      String previousValue = (previousEntry != null) ? previousEntry.getValue() : null;

      if(Objects.equals(previousValue, "new")){
        timeLineForDw.put(previousKey, currentKey);
      }

      // 前のItem = 現在Item
      previousEntry = currentEntry;
    }

    for(OrdMain ordMain: ordMainList){
      for (Map.Entry<String, String> entry : timeLineForDw.entrySet()) {
        if(ordMain.getTreatDate().compareTo(this.DateTimeFormatter(entry.getKey())) >= 0
          && ordMain.getTreatDate().compareTo(this.DateTimeFormatter(entry.getValue())) < 0){
          if(bedCdDwMemoMap.containsKey(ordMain.getIndBedCd()) && bedCdDwMemoMap.get(ordMain.getIndBedCd())){
          nextPatInfo1or2ChangedOrdMainList.add(ordMain);
        }
      }
    }
    }
    //mod #10601 スケジュール表動作不正 end

    return nextPatInfo1or2ChangedOrdMainList;
  }

  //add #10601 スケジュール表動作不正 start
  public String DateTimeFormatter(String dateTimeString) {

    LocalDateTime localDateTime = DateTimeFormatUtil.parseDateTime(dateTimeString);

    DateTimeFormatter customFormatter = DateTimeFormatter.ofPattern("yyyyMMdd");
    String formattedDateString = localDateTime.format(customFormatter);
    return formattedDateString;
  }
  //add #10601 スケジュール表動作不正 end

  /**
   * 次患者更新判定処理（治療情報）
   *
   * @param facilityCd
   * @param beforeOrdMain 変更前ord_main
   * @param afterOrdMain 変更後ord_main
   * @return void
   * @description パラメータで条件送信キャンセル処理しない場合がある
   */
  @Override
  public boolean CheckDoCallNextPatChangeForOrdMain(String facilityCd, OrdMain beforeOrdMain, OrdMain afterOrdMain){
    // --------------------
    // 変更前後OrdMainによる次患者送信判定処理
    // --------------------
    if(!Objects.equals(beforeOrdMain, afterOrdMain)){
      if(beforeOrdMain == null){
        beforeOrdMain = new OrdMain();
      }
      if(afterOrdMain == null){
        afterOrdMain = new OrdMain();
      }

      // 次患者情報１：アドレス ０～２１８ 日付
      if(!Objects.equals(beforeOrdMain.getTreatDate(), afterOrdMain.getTreatDate())){
        return true;
      }
      // 次患者情報１：アドレス ０～２１８ クール
      if(!Objects.equals(beforeOrdMain.getIndKurCd(), afterOrdMain.getIndKurCd())){
        return true;
      }
      // 次患者情報１：アドレス ０～２１８ 治療モード
      // 次患者情報２：アドレス ３４ 治療モード
      if(!Objects.equals(beforeOrdMain.getIndTreatmentCd(), afterOrdMain.getIndTreatmentCd())){
        return true;
      }
      // 次患者情報２：アドレス ０ ダイアライザー選択
      // 次患者情報２：アドレス ３０ 補液選択
      if(!Objects.equals(beforeOrdMain.getIndCondInfo(), afterOrdMain.getIndCondInfo())){
        // beforeIndCondInfo
        JSONObject beforeIndCondInfoJsonObj = new JSONObject(beforeOrdMain.getIndCondInfo());
        // afterIndCondInfo
        JSONObject afterIndCondInfoJsonObj = new JSONObject(afterOrdMain.getIndCondInfo());

        //次患者情報２　ダイアライザー選択
        String before5Value = null;
        String after5Value = null;
        // before
        if (beforeIndCondInfoJsonObj.has("5")) {
          JSONObject beforeKey5JsonObj = beforeIndCondInfoJsonObj.getJSONObject("5");
          before5Value = (null != beforeKey5JsonObj && beforeKey5JsonObj.has("value")) ? beforeKey5JsonObj.optString("value") : null;
        }
        // after
        if (afterIndCondInfoJsonObj.has("5")) {
          JSONObject afterKey5JsonObj = afterIndCondInfoJsonObj.getJSONObject("5");
          after5Value = (null != afterKey5JsonObj && afterKey5JsonObj.has("value")) ? afterKey5JsonObj.optString("value") : null;
        }
        if(!Objects.equals(before5Value, after5Value)
          && (before5Value != null || after5Value != null)){
          return true;
        }
        //----------------------------------------------------
        //次患者情報２　補液選択
        String before21Value = null;
        String after21Value = null;
        // before
        if (beforeIndCondInfoJsonObj.has("21")) {
          JSONObject beforeKey21JsonObj = beforeIndCondInfoJsonObj.getJSONObject("21");
          before21Value = (null != beforeKey21JsonObj && beforeKey21JsonObj.has("value")) ? beforeKey21JsonObj.optString("value") : null;
        }
        // after
        if (afterIndCondInfoJsonObj.has("21")) {
          JSONObject afterKey21JsonObj = afterIndCondInfoJsonObj.getJSONObject("21");
          after21Value = (null != afterKey21JsonObj && afterKey21JsonObj.has("value")) ? afterKey21JsonObj.optString("value") : null;
        }
        if(!Objects.equals(before21Value, after21Value)
          && (before21Value != null || after21Value != null)){
          return true;
        }
      }
    }

    return false;
  }

  /**
   * 次患者更新判定処理（１治療条件）
   *
   * @param beforeIndCondInfoJsonObj 変更前OneIndCond
   * @param afterIndCondInfoJsonObj 変更後OneIndCond
   * @param key 比較対象の条件Key
   * @return boolean
   * @description １治療条件に対し、変更前後の差異を比較し、変更ありなし結果を返す
   */
  private boolean DiffCondOne(JSONObject beforeIndCondInfoJsonObj, JSONObject afterIndCondInfoJsonObj, String key){
    // 初期設定
    if(Objects.equals(beforeIndCondInfoJsonObj, afterIndCondInfoJsonObj)){
      return false;
    } else {
      if(beforeIndCondInfoJsonObj == null){
        beforeIndCondInfoJsonObj = new JSONObject();
      }
      if(afterIndCondInfoJsonObj == null){
        afterIndCondInfoJsonObj = new JSONObject();
      }
    }

    // 比較処理
    String beforeCondValue = null;
    String afterCondValue = null;
    // before
    if (beforeIndCondInfoJsonObj.has(key)) {
      JSONObject beforeKeyJsonObj = beforeIndCondInfoJsonObj.getJSONObject(key);
      beforeCondValue = (null != beforeKeyJsonObj && beforeKeyJsonObj.has("value")) ? beforeKeyJsonObj.optString("value") : null;
    }
    // after
    if (afterIndCondInfoJsonObj.has(key)) {
      JSONObject afterKeyJsonObj = afterIndCondInfoJsonObj.getJSONObject(key);
      afterCondValue = (null != afterKeyJsonObj && afterKeyJsonObj.has("value")) ? afterKeyJsonObj.optString("value") : null;
    }
    if(!Objects.equals(beforeCondValue, afterCondValue)
      && (beforeCondValue != null || afterCondValue != null)){
      return true;
    }
    return false;
  }

  /**
   * 次患者更新判定処理（１投与薬剤or１医療材料）
   *
   * @param beforeIndInfoList 変更前OneInd
   * @param afterIndInfoList 変更後OneInd
   * @param index 比較対象の条件Key
   * @return boolean
   * @description １治療条件に対し、変更前後の差異を比較し、変更ありなし結果を返す
   */
  private boolean DiffMediEquipOne(List<IndMediEquipDiffInfo> beforeIndInfoList, List<IndMediEquipDiffInfo> afterIndInfoList, int index){
    //
    int maxInfoSize = 0;
    int minInfoSize = 0;

    if(beforeIndInfoList.size() > afterIndInfoList.size()){
      maxInfoSize = beforeIndInfoList.size();
      minInfoSize = afterIndInfoList.size();
    } else {
      maxInfoSize = afterIndInfoList.size();
      minInfoSize = beforeIndInfoList.size();
    }

    if(minInfoSize >  index) {
      if(!Objects.equals(beforeIndInfoList.get(index).getCd(), afterIndInfoList.get(index).getCd())
        || !Objects.equals(beforeIndInfoList.get(index).getMedicineType(), afterIndInfoList.get(index).getMedicineType())
        || !Objects.equals(beforeIndInfoList.get(index).getAmount(), afterIndInfoList.get(index).getAmount())){
      return true ;
      }
    } else {
      if(maxInfoSize > minInfoSize){
        return true;
      }
    }
    return false;
  }

  /**
   * 次患者更新判定処理　次患者情報メモ（治療情報）
   *
   * @param facilityCd
   * @param beforeOrdMain 変更前ord_main
   * @param afterOrdMain 変更後ord_main
   * @return void
   * @description パラメータで条件送信キャンセル処理しない場合がある
   */
  @Override
  public boolean CheckDoCallNextPatChangeForOrdMainMemo(String facilityCd, OrdMain beforeOrdMain, OrdMain afterOrdMain, MstComsvSetting mstComsvInfo){

    if(mstComsvInfo == null){
      List<MstComsvSetting> mstComsvInfos = mstComsvSettingDao.selectByBedCds(facilityCd, Arrays.asList(beforeOrdMain.getIndBedCd()));
      if(mstComsvInfos != null && !mstComsvInfos.isEmpty()){
        mstComsvInfo = mstComsvInfos.get(0);
      }
    }

    if (mstComsvInfo != null && mstComsvInfo.getLcdNpat() != null) {
      JSONObject lcdNpat = new JSONObject(mstComsvInfo.getLcdNpat());
      Gson gson = new Gson();
      Type listInfoType = new TypeToken<List<NpatItem>>() {}.getType();

      //get  memo  patInfo
      List<NpatItem> npatList = gson.fromJson(lcdNpat.get("npat_item").toString(), listInfoType);

      JSONObject beforeIndCondInfoJsonObj = new JSONObject();
      JSONObject afterIndCondInfoJsonObj = new JSONObject();

      List<IndMediEquipDiffInfo> beforeIndMediInfoList = new ArrayList<>();
      List<IndMediEquipDiffInfo> afterIndMediInfoList = new ArrayList<>();
      Type listMediInfoType = new TypeToken<List<IndMediEquipDiffInfo>>() {}.getType();

      List<IndMediEquipDiffInfo> beforeIndEquipInfoList = new ArrayList<>();
      List<IndMediEquipDiffInfo> afterIndEquipInfoList = new ArrayList<>();
      Type listEquipInfoType = new TypeToken<List<IndMediEquipDiffInfo>>() {}.getType();

      if(npatList !=null && !npatList.isEmpty()){
        // 治療条件
        if(!Objects.equals(beforeOrdMain.getIndCondInfo(), afterOrdMain.getIndCondInfo())) {
          // beforeIndCondInfo
          beforeIndCondInfoJsonObj = new JSONObject(beforeOrdMain.getIndCondInfo());
          // afterIndCondInfo
          afterIndCondInfoJsonObj = new JSONObject(afterOrdMain.getIndCondInfo());
        }
        // 投与薬剤
        if(!Objects.equals(beforeOrdMain.getIndMediInfo(), afterOrdMain.getIndMediInfo())) {
          //mod #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 zrx start
          // beforeIndMediInfo
          String beforeIndMediInfoJson = beforeOrdMain.getIndMediInfo();
          // afterIndMediInfo
          String afterIndMediInfoJson = afterOrdMain.getIndMediInfo();
          beforeIndMediInfoList = beforeIndMediInfoJson != null ? gson.fromJson(beforeIndMediInfoJson, listMediInfoType) : new ArrayList<>();
          afterIndMediInfoList = afterIndMediInfoJson != null ? gson.fromJson(afterIndMediInfoJson, listMediInfoType) : new ArrayList<>();
//          beforeIndMediInfoList = gson.fromJson(beforeOrdMain.getIndMediInfo(), listMediInfoType);
//          afterIndMediInfoList = gson.fromJson(afterOrdMain.getIndMediInfo(), listMediInfoType);
          //mod #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 zrx end
        }
        // 医療材料
        if(!Objects.equals(beforeOrdMain.getIndEquipInfo(), afterOrdMain.getIndEquipInfo())) {
          //mod #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 zrx start
          // beforeIndEquipInfo
          String beforeIndEquipInfoJson = beforeOrdMain.getIndEquipInfo();
          // afterIndMediInfo
          String afterIndMediInfoJson = afterOrdMain.getIndEquipInfo();
          beforeIndEquipInfoList = beforeIndEquipInfoJson != null ? gson.fromJson(beforeIndEquipInfoJson, listEquipInfoType) : new ArrayList<>();
          afterIndEquipInfoList = afterIndMediInfoJson != null ? gson.fromJson(afterIndMediInfoJson, listEquipInfoType) : new ArrayList<>();
//          beforeIndEquipInfoList = gson.fromJson(beforeOrdMain.getIndEquipInfo(), listEquipInfoType);
//          afterIndEquipInfoList = gson.fromJson(afterOrdMain.getIndEquipInfo(), listEquipInfoType);
          //mod #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 zrx end
        }
      }

      for(NpatItem npatItem : npatList){
        switch (npatItem.getCode()){
          case 11:
            // 治療開始予定時刻
            if(!Objects.equals(beforeOrdMain.getIndTreatStartTime(), afterOrdMain.getIndTreatStartTime())) return true;
            break;
          case 12:
            // 治療時間
            if(DiffCondOne(beforeIndCondInfoJsonObj, afterIndCondInfoJsonObj, "1")) return true ;
            break;
          case 8:
            // DW
            if(!Objects.equals(beforeOrdMain.getIndDw(), afterOrdMain.getIndDw())){
              return true;
            }
            break;
          case 56:
            // 目標体重
            if(DiffCondOne(beforeIndCondInfoJsonObj, afterIndCondInfoJsonObj, "3")) return true ;
            break;
          case 14:
            // ダイアライザ選択
            if(DiffCondOne(beforeIndCondInfoJsonObj, afterIndCondInfoJsonObj, "5")) return true ;
            // 吸着カラム
            if(DiffCondOne(beforeIndCondInfoJsonObj, afterIndCondInfoJsonObj, "6")) return true ;
            // 1次膜
            if(DiffCondOne(beforeIndCondInfoJsonObj, afterIndCondInfoJsonObj, "7")) return true ;
            // 2次膜
            if(DiffCondOne(beforeIndCondInfoJsonObj, afterIndCondInfoJsonObj, "8")) return true ;
            break;
          case 64:
            // 1次膜
            if(DiffCondOne(beforeIndCondInfoJsonObj, afterIndCondInfoJsonObj, "7")) return true ;
            break;
          case 57:
            // 血流量
            if(DiffCondOne(beforeIndCondInfoJsonObj, afterIndCondInfoJsonObj, "14")) return true ;
            break;
          case 9:
            // VA
            if(DiffCondOne(beforeIndCondInfoJsonObj, afterIndCondInfoJsonObj, "2")) return true ;
            break;
          case 15:
            // A針名
            if(DiffCondOne(beforeIndCondInfoJsonObj, afterIndCondInfoJsonObj, "9")) return true ;
            // SN針
            if(DiffCondOne(beforeIndCondInfoJsonObj, afterIndCondInfoJsonObj, "11")) return true ;
            break;
          case 16:
            // V針名
            if(DiffCondOne(beforeIndCondInfoJsonObj, afterIndCondInfoJsonObj, "10")) return true ;
            break;
          case 35:
            // 透析液
            if(DiffCondOne(beforeIndCondInfoJsonObj, afterIndCondInfoJsonObj, "15")) return true ;
            break;
          case 61:
            // 補液選択
            if(DiffCondOne(beforeIndCondInfoJsonObj, afterIndCondInfoJsonObj, "19")) return true ;
            break;
          case 62:
            // 補液量
            if(DiffCondOne(beforeIndCondInfoJsonObj, afterIndCondInfoJsonObj, "20")) return true ;
            break;
          case 63:
            // 補液速度
            if(DiffCondOne(beforeIndCondInfoJsonObj, afterIndCondInfoJsonObj, "24")) return true ;
            break;
          case 17:
            // 抗凝固剤名
            if(DiffCondOne(beforeIndCondInfoJsonObj, afterIndCondInfoJsonObj, "25")) return true ;
            break;
          case 18:
            // 抗凝固剤ワンショット量
            if(DiffCondOne(beforeIndCondInfoJsonObj, afterIndCondInfoJsonObj, "26")) return true ;
            break;
          case 19:
            // 抗凝固剤持続注入量
            if(DiffCondOne(beforeIndCondInfoJsonObj, afterIndCondInfoJsonObj, "27")) return true ;
            break;
          case 20:
            // 抗凝固剤持続総量
            if(DiffCondOne(beforeIndCondInfoJsonObj, afterIndCondInfoJsonObj, "28")) return true ;
            break;
          case 21:
            // 抗凝固剤総量
            if(DiffCondOne(beforeIndCondInfoJsonObj, afterIndCondInfoJsonObj, "26")) return true ;
            if(DiffCondOne(beforeIndCondInfoJsonObj, afterIndCondInfoJsonObj, "28")) return true ;
            break;
          case 59:
            // IPワンショット量
            if(DiffCondOne(beforeIndCondInfoJsonObj, afterIndCondInfoJsonObj, "31")) return true ;
            break;
          case 58:
            // IP速度
            if(DiffCondOne(beforeIndCondInfoJsonObj, afterIndCondInfoJsonObj, "32")) return true ;
            break;
          case 60:
            // IP電源自動切り・時間
            if(DiffCondOne(beforeIndCondInfoJsonObj, afterIndCondInfoJsonObj, "36")) return true ;
            break;
          case 36:
            // 投与薬剤1
            if(this.DiffMediEquipOne(beforeIndMediInfoList, afterIndMediInfoList, 0)) return true;
            break;
          case 37:
            // 投与薬剤2
            if(this.DiffMediEquipOne(beforeIndMediInfoList, afterIndMediInfoList, 1)) return true;
            break;
          case 38:
            // 投与薬剤3
            if(this.DiffMediEquipOne(beforeIndMediInfoList, afterIndMediInfoList, 2)) return true;
            break;
          case 39:
            // 投与薬剤4
            if(this.DiffMediEquipOne(beforeIndMediInfoList, afterIndMediInfoList, 3)) return true;
            break;
          case 40:
            // 投与薬剤5
            if(this.DiffMediEquipOne(beforeIndMediInfoList, afterIndMediInfoList, 4)) return true;
            break;
          case 41:
            // 投与薬剤6
            if(this.DiffMediEquipOne(beforeIndMediInfoList, afterIndMediInfoList, 5)) return true;
            break;
          case 42:
            // 投与薬剤7
            if(this.DiffMediEquipOne(beforeIndMediInfoList, afterIndMediInfoList, 6)) return true;
            break;
          case 43:
            // 投与薬剤8
            if(this.DiffMediEquipOne(beforeIndMediInfoList, afterIndMediInfoList, 7)) return true;
            break;
          case 44:
            // 投与薬剤9
            if(this.DiffMediEquipOne(beforeIndMediInfoList, afterIndMediInfoList, 8)) return true;
            break;
          case 45:
            // 投与薬剤10
            if(this.DiffMediEquipOne(beforeIndMediInfoList, afterIndMediInfoList, 9)) return true;
            break;
          case 46:
            // 投与薬剤11
            if(this.DiffMediEquipOne(beforeIndMediInfoList, afterIndMediInfoList, 10)) return true;
            break;
          case 47:
            // 投与薬剤12
            if(this.DiffMediEquipOne(beforeIndMediInfoList, afterIndMediInfoList, 11)) return true;
            break;
          case 48:
            // 投与薬剤13
            if(this.DiffMediEquipOne(beforeIndMediInfoList, afterIndMediInfoList, 12)) return true;
            break;
          case 49:
            // 投与薬剤14
            if(this.DiffMediEquipOne(beforeIndMediInfoList, afterIndMediInfoList, 13)) return true;
            break;
          case 50:
            // 投与薬剤15
            if(this.DiffMediEquipOne(beforeIndMediInfoList, afterIndMediInfoList, 14)) return true;
            break;
          case 51:
            // 投与薬剤16
            if(this.DiffMediEquipOne(beforeIndMediInfoList, afterIndMediInfoList, 15)) return true;
            break;
          case 52:
            // 投与薬剤17
            if(this.DiffMediEquipOne(beforeIndMediInfoList, afterIndMediInfoList, 16)) return true;
            break;
          case 53:
            // 投与薬剤18
            if(this.DiffMediEquipOne(beforeIndMediInfoList, afterIndMediInfoList, 17)) return true;
            break;
          case 54:
            // 投与薬剤19
            if(this.DiffMediEquipOne(beforeIndMediInfoList, afterIndMediInfoList, 18)) return true;
            break;
          case 55:
            // 投与薬剤20
            if(this.DiffMediEquipOne(beforeIndMediInfoList, afterIndMediInfoList, 19)) return true;
            break;
          case 25:
            // 医療材料1
            if(this.DiffMediEquipOne(beforeIndEquipInfoList, afterIndEquipInfoList, 0)) return true;
            break;
          case 26:
            // 医療材料2
            if(this.DiffMediEquipOne(beforeIndEquipInfoList, afterIndEquipInfoList, 1)) return true;
            break;
          case 27:
            // 医療材料3
            if(this.DiffMediEquipOne(beforeIndEquipInfoList, afterIndEquipInfoList, 2)) return true;
            break;
          case 28:
            // 医療材料4
            if(this.DiffMediEquipOne(beforeIndEquipInfoList, afterIndEquipInfoList, 3)) return true;
            break;
          case 29:
            // 医療材料5
            if(this.DiffMediEquipOne(beforeIndEquipInfoList, afterIndEquipInfoList, 4)) return true;
            break;
          case 30:
            // 医療材料6
            if(this.DiffMediEquipOne(beforeIndEquipInfoList, afterIndEquipInfoList, 5)) return true;
            break;
          case 31:
            // 医療材料7
            if(this.DiffMediEquipOne(beforeIndEquipInfoList, afterIndEquipInfoList, 6)) return true;
            break;
          case 32:
            // 医療材料8
            if(this.DiffMediEquipOne(beforeIndEquipInfoList, afterIndEquipInfoList, 7)) return true;
            break;
          case 33:
            // 医療材料9
            if(this.DiffMediEquipOne(beforeIndEquipInfoList, afterIndEquipInfoList, 8)) return true;
            break;
          case 34:
            // 医療材料10
            if(this.DiffMediEquipOne(beforeIndEquipInfoList, afterIndEquipInfoList, 9)) return true;
            break;
          default:
            break;
        }
      }
    }
    return false;
  }

  /**
   * 条件送信キャンセル・次患者更新実行纏め処理 治療情報関連次患者情報１or２で変更が発生したかのチェック
   *
   * @param facilityCd
   * @param beforOrdMainList 変更前ord_mainList
   * @return List<OrdMain>
   * @description 次患者情報１or２で変更が発生した場合の後で呼び出す元側でCallNextPatChangeを呼び出す必要あり
   */
  @Override
  public List<OrdMain> FilterNextPatInfo1or2ChangedForOrdMain(String facilityCd, List<OrdMain> beforOrdMainList){

    List<OrdMain> nextPatInfo1or2ChangedBeforOrdMainList = new ArrayList<>();

    // 空リストで入った場合は、そのまま抜ける
    if(beforOrdMainList == null || beforOrdMainList.isEmpty()){
      return nextPatInfo1or2ChangedBeforOrdMainList;
    }

    // 変更が発生した治療Noのリスト
    List<Long> ordNoList = beforOrdMainList.stream().map(o -> o.getOrdNo()).collect(Collectors.toList());
    // 変更前のベッドリスト
    List<Integer> beforBedCdList = beforOrdMainList.stream().map(o -> o.getIndBedCd()).collect(Collectors.toList());
    // 変更後の治療リスト
    List<OrdMain> afterOrdMainList = ordMainDao.selectByOrdNoList(ordNoList);
    // 変更前の治療リストマップ化
    Map<Long,OrdMain> beforOrdMainMap = beforOrdMainList.stream().collect(Collectors.toMap(o -> o.getOrdNo(), o -> o));
    // 変更後の治療リストマップ化
    Map<Long,OrdMain> afterOrdMainMap = afterOrdMainList.stream().collect(Collectors.toMap(o -> o.getOrdNo(), o -> o));

    List<MstComsvSetting> mstComsvInfos = mstComsvSettingDao.selectByBedCds(facilityCd, beforBedCdList);
    Map<Integer,MstComsvSetting> mstComsvInfosMap = mstComsvInfos.stream().collect(Collectors.toMap(o -> o.getNextPatMode(), o -> o));

    // 繰り返し処理
    for(OrdMain beforOrdMain : beforOrdMainList){
      if(this.CheckDoCallNextPatChangeForOrdMain(facilityCd, beforOrdMain, afterOrdMainMap.get(beforOrdMain.getOrdNo()))) {
        nextPatInfo1or2ChangedBeforOrdMainList.add(beforOrdMain);
        continue;
      }
      if(this.CheckDoCallNextPatChangeForOrdMainMemo(facilityCd, beforOrdMain, afterOrdMainMap.get(beforOrdMain.getOrdNo()),mstComsvInfosMap.get(beforOrdMain.getIndBedCd()))) {
        nextPatInfo1or2ChangedBeforOrdMainList.add(beforOrdMain);
      }
    }
    return nextPatInfo1or2ChangedBeforOrdMainList;
  }

  /**
   * 条件送信キャンセル・次患者更新実行纏め処理
   *
   * @param facilityCd
   * @param beforOrdMainList 変更前ord_mainList
   * @return void
   * @description パラメータで条件送信キャンセル処理しない場合がある
   */
  @Override
  public void CallNextPatChange(String facilityCd, List<OrdMain> beforOrdMainList){
    // 空リストで入った場合は、そのまま抜ける
    if(beforOrdMainList == null || beforOrdMainList.isEmpty()){
      return;
    }
    // 検索条件初期化(検索開始日に現在日+指定時刻を設定)
    DateTimeFormatter format = DateTimeFormatter.ofPattern("yyyyMMdd");
    DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
    // 検索開始時刻が未指定の場合は"000000"を設定
    String startTime = "000000";
    LocalDateTime nowDate = LocalDateTime.parse(LocalDateTime.now().format(format) + startTime, dateFormat);
    String searchStartDate = nowDate.format(format);
    // 変更が発生した治療Noのリスト
    List<Long> ordNoList = beforOrdMainList.stream().map(o -> o.getOrdNo()).collect(Collectors.toList());
    // 変更前のベッドリスト
    List<Integer> beforBedCdList = beforOrdMainList.stream().map(o -> o.getPatId() != null ? o.getIndBedCd() : o.getRstBedCd().intValue()).collect(Collectors.toList());
    // 変更後の治療リスト
    List<OrdMain> afterOrdMainList = ordMainDao.selectByOrdNoList(ordNoList);
    // 変更後のベッドリスト
    List<Integer> afterBedCdList = afterOrdMainList.stream().map(o -> o.getPatId() != null ? o.getIndBedCd() : o.getRstBedCd().intValue()).collect(Collectors.toList());
    // 変更前後のベッドリスト
    List<Integer> bedCdList = Stream.concat(beforBedCdList.stream(), afterBedCdList.stream()).filter(Objects::nonNull).distinct().collect(Collectors.toList());
    // 次患者更新要リスト
    List<NextPatByBedInfo> nextPatByBedInfoList = nextPatDao.selectOrdNoListForNextPatByBedList(facilityCd, searchStartDate, bedCdList, ordNoList);
    // 次患者更新要リストmap
    Map<Long,NextPatByBedInfo> nextPatByBedInfoListMap = nextPatByBedInfoList.stream().collect(Collectors.toMap(o -> o.getBedCd(), o -> o));
    // 変更前の治療リストマップ化
    Map<Long,OrdMain> beforOrdMainMap = beforOrdMainList.stream().collect(Collectors.toMap(o -> o.getOrdNo(), o -> o));
    // 変更後の治療リストマップ化
    Map<Long,OrdMain> afterOrdMainMap = afterOrdMainList.stream().collect(Collectors.toMap(o -> o.getOrdNo(), o -> o));
    // 現在時刻を設定
    LocalDateTime update = LocalDateTime.now();
    for(NextPatByBedInfo nextPatByBedInfo : nextPatByBedInfoList){
      // 先に次患者で一致のOrd_mainを取得
      OrdMain beforOrdMain = beforOrdMainMap.get(nextPatByBedInfo.getNextOrdNo());
      // 次患者ではなく、次患者になりそうな場合を考慮
      if(beforOrdMain == null){
        beforOrdMain = beforOrdMainMap.get(nextPatByBedInfo.getNext_ord_no_stat0());
      }
      if(beforOrdMain != null){
        MntMachineState beforeBedMntMachineState = this.NextPatByBedInfoTMntMachineState(nextPatByBedInfo);
        MstMachine beforeBedMstMachine = this.NextPatByBedInfoTMstMachine(nextPatByBedInfo);
        OrdMain afterOrdMain = afterOrdMainMap.get(beforOrdMain.getOrdNo());
        MntMachineState afterBedMntMachineState = null;
        MstMachine afterBedMstMachine = null;
        if(afterOrdMain != null){
          NextPatByBedInfo afterNextPatByBedInfo = nextPatByBedInfoListMap.get(Long.valueOf(afterOrdMain.getIndBedCd()));
          afterBedMntMachineState = this.NextPatByBedInfoTMntMachineState(afterNextPatByBedInfo);
          afterBedMstMachine = this.NextPatByBedInfoTMstMachine(afterNextPatByBedInfo);
        }
        this.callDoCancelSetNextPatInfo2(facilityCd,
                                          beforOrdMain, afterOrdMain,
                                          beforeBedMntMachineState, afterBedMntMachineState,
                                          beforeBedMstMachine, afterBedMstMachine,
                                          update, beforBedCdList);
      }
    }
  }

  /**
   * 条件送信キャンセル・次患者更新実行
   *
   * @param facilityCd
   * @param beforeOrdMain 変更前ord_main※未登録など処理不要の場合 null
   * @param afterOrdMain  変更後ord_main※未登録など処理不要の場合 null
   * @param beforeBedMntMachineState 変更前bedのmnt_machine_state※未登録など処理不要の場合 null
   * @param afterBedMntMachineState  変更後bedのmnt_machine_state※未登録など処理不要の場合 null
   * @param beforeBedMstMachine 変更前bedのmst_machine※未登録など処理不要の場合 null
   * @param afterBedMstMachine  変更後bedのmst_machine※未登録など処理不要の場合 null
   * @param update      更新日時
   * @return message
   * @description パラメータで条件送信キャンセル処理しない場合がある
   */
  //mod #10601 スケジュール表動作不正 start
  @Override
  public String callDoCancelSetNextPatInfo2(String facilityCd,
                                            OrdMain beforeOrdMain, OrdMain afterOrdMain,
                                            MntMachineState beforeBedMntMachineState, MntMachineState afterBedMntMachineState,
                                            MstMachine beforeBedMstMachine, MstMachine afterBedMstMachine,
                                            LocalDateTime update, List<Integer> beforBedCdList) {
//    public String callDoCancelSetNextPatInfo2(String facilityCd,
//      OrdMain beforeOrdMain, OrdMain afterOrdMain,
//      MntMachineState beforeBedMntMachineState, MntMachineState afterBedMntMachineState,
//      MstMachine beforeBedMstMachine, MstMachine afterBedMstMachine,
//      LocalDateTime update) {
    //mod #10601 スケジュール表動作不正 end
    //開始ログ
    final String className = new Object() {}.getClass().getEnclosingClass().getName();
    final String methodName = new Object() {}.getClass().getEnclosingMethod().getName();
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(className + "." + methodName + " 処理開始");
    logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);

    // flag定義
    boolean beforeDoCancelFlg = false;
    boolean afterDoCancelFlg = false;
    boolean beforeNextPatInfoFlg = false;
    boolean afterNextPatInfoFlg = false;
    //add #10601 スケジュール表動作不正 start
    boolean afterBedJumpFlg = false;
    //add #10601 スケジュール表動作不正 end

    // 処理変数定義
    boolean isDoCancelSuccess = false;
    int postOrderCancelConditionErrorCounter = 0;
    int doCancelErrorCounter = 0;
    int setNextPatInfoErrorCounter = 0;
    int postOrderSendNextPatErrorCounter = 0;
    String message = "";

    // 次患者更新呼出用引数
    boolean isSendCondition = false;
    Long sendConditionOrdNo = null;

    // 引数チェック・補正
    boolean[] prmCheckErr = new boolean[8]; // prm数8
    if(facilityCd == null){ prmCheckErr[0] = true; }
    if(beforeOrdMain == null){
      prmCheckErr[1] = true;
    }else {
      if (beforeOrdMain.getRstDialysisState() == null){ prmCheckErr[1] = true; }
      else if (beforeOrdMain.getOrdNo() == null){ prmCheckErr[1] = true; }
      else if (!Objects.equals(facilityCd, beforeOrdMain.getFacilityCd())){ prmCheckErr[1] = true; }
    }
    if(afterOrdMain == null){
      prmCheckErr[2] = true;
    }else {
      if (afterOrdMain.getRstDialysisState() == null){ prmCheckErr[2] = true; }
      else if (afterOrdMain.getOrdNo() == null){ prmCheckErr[2] = true; }
      else if (!Objects.equals(facilityCd, afterOrdMain.getFacilityCd())){ prmCheckErr[2] = true; }
    }
    if(beforeBedMntMachineState == null){ prmCheckErr[3] = true; }
    if(afterBedMntMachineState == null){ prmCheckErr[4] = true; }
    if(beforeBedMntMachineState == null){ prmCheckErr[5] = true; }
    if(afterBedMntMachineState == null){ prmCheckErr[6] = true; }
    if(update == null){ prmCheckErr[7] = true; }

    // ログ
    for(int i = 0; i < 8; i++){
      if(prmCheckErr[i]){
        message += " パラメータ[" + i + "]未設定";
      }
    }
    if (message != "") {
      eventLogMessage.setLogMessage(className + "." + methodName + message);
      logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      if(prmCheckErr[0] || (prmCheckErr[1] && prmCheckErr[2])){
        JSONObject errorMsgJson = new JSONObject("{}");
        errorMsgJson.put("message", message);
        errorMsgJson.put("doCancel", doCancelErrorCounter);
        errorMsgJson.put("postOrderCancelCondition", postOrderCancelConditionErrorCounter);
        errorMsgJson.put("setNextPatInfo", setNextPatInfoErrorCounter);
        errorMsgJson.put("postOrderSendNextPat", postOrderSendNextPatErrorCounter);
        errorMsgJson.put("isDoCancelSuccess", isDoCancelSuccess);
        eventLogMessage.setLogMessage(className + "." + methodName + " 処理終了");
        logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        return errorMsgJson.toString();
      }
      message = "";
    }

    if(beforeOrdMain == null && afterOrdMain != null){
      eventLogMessage.setLogMessage(className + "." + methodName + " beforeOrdMain未設定、afterOrdMain設定の場合は beforeOrdMain = afterOrdMain");
      logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      //
      beforeOrdMain = afterOrdMain;
    }

    // 更新後ord_main未指定の場合は取得する
    if(afterOrdMain == null){
      afterOrdMain = ordMainDao.selectByOrdNo(beforeOrdMain.getOrdNo());
    }

    // 変更前bedのmnt_machine_state未指定の場合は取得する
    if(beforeBedMntMachineState == null){
      if(beforeOrdMain.getIndBedCd() > 0){
        beforeBedMntMachineState = mntMachineStateDao.selectActiveByBedCd(facilityCd, Long.valueOf(beforeOrdMain.getIndBedCd()));
      } else {
        eventLogMessage.setLogMessage(className + "." + methodName + " 移動前は空ベッドである");
        logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      }
    }

    // 変更後bedのmnt_machine_state未指定の場合は取得する
    if(afterBedMntMachineState == null){
      if(afterOrdMain != null){ // 中止処理ではない
        if(afterOrdMain.getIndBedCd() > 0){ // 変更後bedが登録された場合は取得
          if(!Objects.equals(afterOrdMain.getIndBedCd(), beforeOrdMain.getIndBedCd())){ // 変更後bedと変更前bedが不一致の場合のみ取得
            afterBedMntMachineState = mntMachineStateDao.selectActiveByBedCd(facilityCd, Long.valueOf(afterOrdMain.getIndBedCd()));
          }
        }
      }
    }

    // 変更前bedのmst_machine未指定の場合は取得する
    if(beforeBedMstMachine == null){
      if(beforeOrdMain.getIndBedCd() > 0){
        List<MstMachine> beforeBedMstMachineList = mstMachineDao.selectByBedCd(facilityCd, Long.valueOf(beforeOrdMain.getIndBedCd()));
        if(beforeBedMstMachineList != null && !beforeBedMstMachineList.isEmpty()){
          beforeBedMstMachine = beforeBedMstMachineList.get(0);
        }
      } else {
        eventLogMessage.setLogMessage(className + "." + methodName + " 移動前は空ベッドである");
        logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      }
    }

    // 変更後bedのmst_machine未指定の場合は取得する
    if(afterBedMstMachine == null){
      if(afterOrdMain != null){ // 中止処理ではない
        if(afterOrdMain.getIndBedCd() > 0){ // 変更後bedが登録された場合は取得
          if(!Objects.equals(afterOrdMain.getIndBedCd(), beforeOrdMain.getIndBedCd())){ // 変更後bedと変更前bedが不一致の場合のみ取得
            List<MstMachine>  afterBedMstMachineList = mstMachineDao.selectByBedCd(facilityCd, Long.valueOf(afterOrdMain.getIndBedCd()));
            if(afterBedMstMachineList != null && !afterBedMstMachineList.isEmpty()){
              afterBedMstMachine = afterBedMstMachineList.get(0);
            }
          }
        }
      }
    }

    // update未指定の場合は設定する
    if(update == null){
      update = LocalDateTime.now();
    }

    // --------------------
    // 変更前のベッド 【条件送信キャンセル処理】
    // --------------------
    if (Objects.equals(beforeOrdMain.getRstDialysisState(), "1")  ||
      Objects.equals(beforeOrdMain.getRstDialysisState(), "2")){
      // 変更前の治療状況が1or2（条件送信済みまたは条件確認済み）
      if(afterOrdMain == null){
        // 処理中止の場合
        beforeDoCancelFlg = true;
      } else if(Objects.equals(afterOrdMain.getRstDialysisState(), "0")){
        // 条件送信キャンセルの場合
        beforeDoCancelFlg = true;
      } else {
        // beforeDoCancelFlg = false;
      }
    }

    //【条件送信キャンセル処理】
    if(beforeDoCancelFlg){
      eventLogMessage.setLogMessage(className + "." + methodName + " 変更前ベッド：条件送信キャンセル処理開始");
      logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);

      if(beforeBedMntMachineState != null){
        // 条件送信済みが存在しかつ条件送信済みord_noなら条件送信キャンセル実行
        // 以下の順で処理を行う
        //   1. 条件送信キャンセルのDB更新
        //   2. 次患者更新API要求(通知は不要 ※条件送信キャンセル通知を受けたDE側で実施)
        //   3. 条件送信キャンセル通知

        // ◆1. 条件送信キャンセルのDB更新
        // ◆2. 次患者更新API要求
        //※doCancelにて1と2を実行
        eventLogMessage.setLogMessage(className + "." + methodName + " 変更前ベッド：条件送信キャンセルDB更新&次患者更新API要求開始(doCancel) facilityCd:[" + facilityCd + "] machineTypeCd:[" + beforeBedMntMachineState.getMachineTypeCd() + "] machineSerial:[" + beforeBedMntMachineState.getMachineSerial() + "] ord_no:[" + beforeBedMntMachineState.getOrdNo() + "]");
        logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);

        OrdMain targetOrdMain = afterOrdMain == null ? beforeOrdMain : afterOrdMain;
        SendConditionCancelResponse sendConditionCancelRes = sendConditionCancelService.doCancel2(facilityCd, beforeBedMntMachineState.getMachineTypeCd(), beforeBedMntMachineState.getMachineSerial(), targetOrdMain);

        if (sendConditionCancelRes.isSuccess) {
          isDoCancelSuccess = true;
          // 条件送信キャンセル成功なら通信サーバー通知
          // ◆3. 条件送信キャンセル通知
          eventLogMessage.setLogMessage(className + "." + methodName + " 変更前ベッド：doCancel成功／条件送信キャンセル通知開始 facilityCd:[" + facilityCd + "] machineTypeCd:[" + beforeBedMntMachineState.getMachineTypeCd() + "] machineSerial:[" + beforeBedMntMachineState.getMachineSerial() + "]");
          logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);

          DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
          res = deviceEdgeOrderService.orderCancelCondition(facilityCd, beforeBedMstMachine.getDeviceEdgeNo(), beforeBedMstMachine.getMachineNo());

          if (res.isSuccess) {
            postOrderCancelConditionErrorCounter++;
            eventLogMessage.setLogMessage(className + "." + methodName + " 変更前ベッド：「条件送信キャンセル通信サーバー通知」失敗 facilityCd:[" + facilityCd + "] machineTypeCd:[" + beforeBedMntMachineState.getMachineTypeCd() + "] machineSerial:[" + beforeBedMntMachineState.getMachineSerial() + "]");
            logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        } else {
          doCancelErrorCounter++;
          message = "「条件送信キャンセル」失敗しました";
          eventLogMessage.setLogMessage(className + "." + methodName + " 変更前ベッド：" + message + "(doCancelに失敗 ベッドコード=" + beforeBedMntMachineState.getBedCd());
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        }
      }
    } else {
      eventLogMessage.setLogMessage(className + "." + methodName + " 変更前ベッド：doCancel処理なし");
      logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    }

    // --------------------
    // 変更後のベッド 【条件送信キャンセル処理】
    // --------------------
    if (afterOrdMain != null){ // 中止処理ではない
      if (afterOrdMain.getIndBedCd() > 0){ // 変更後のbedは登録済み
        //mod #10601 スケジュール表動作不正 start
        Integer afterIndBedCd = afterOrdMain.getIndBedCd();
        if(beforBedCdList != null && beforBedCdList.stream().anyMatch(x -> x.equals(afterIndBedCd))){
          afterBedJumpFlg = true;
          eventLogMessage.setLogMessage(className + "." + methodName + " bed交換処理である");
          logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        }
        else {
          if(!Objects.equals(afterOrdMain.getIndBedCd(), beforeOrdMain.getIndBedCd())) { // 変更前後のbedが一致しない
            if (afterBedMntMachineState.getNextOrdNo() != null ) {
              if(Objects.equals(afterBedMntMachineState.getOrdNo(), afterBedMntMachineState.getNextOrdNo())) {
                // 変更後ベッドのmn_machine_stateのord_noとnext_ord_noが同じの場合は条件送信済みor条件確認済みとなる。※治療中はここまでたどり着かない
                OrdMain mntMachineStateOrdMain = ordMainDao.selectByOrdNo(afterBedMntMachineState.getOrdNo());
                if(Objects.equals(mntMachineStateOrdMain.getTreatDate(), afterOrdMain.getTreatDate())
                  && Objects.equals(mntMachineStateOrdMain.getIndKurCd(), afterOrdMain.getIndKurCd())
                  && Objects.equals(mntMachineStateOrdMain.getIndBedCd(), afterOrdMain.getIndBedCd())){
                  afterDoCancelFlg = true;
                } else {
                  eventLogMessage.setLogMessage(className + "." + methodName + " 変更後bedに存在する条件送信済み患者は別治療日・別クールの患者である");
                  logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
                }
              } else {
                eventLogMessage.setLogMessage(className + "." + methodName + " 変更後bedに存在する患者は条件送信済みの状態ではない");
                logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
              }
            } else {
              eventLogMessage.setLogMessage(className + "." + methodName + " 新しいbedへの処理である");
              logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
            }
          } else {
            eventLogMessage.setLogMessage(className + "." + methodName + " 同じbedでの処理である");
            logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        //mod #10601 スケジュール表動作不正 end
      } else {
        eventLogMessage.setLogMessage(className + "." + methodName + " bedを未登録へ変更");
        logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      }
    } else {
      eventLogMessage.setLogMessage(className + "." + methodName + " 治療中止処理である");
      logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    }



    //【条件送信キャンセル処理】
    if(afterDoCancelFlg){
      eventLogMessage.setLogMessage(className + "." + methodName + " 変更後ベッド：条件送信キャンセル処理開始");
      logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);

      if(afterBedMntMachineState != null){
        // 条件送信済みが存在しかつ条件送信済みord_noなら条件送信キャンセル実行
        // 以下の順で処理を行う
        //   1. 条件送信キャンセルのDB更新
        //   2. 次患者更新API要求(通知は不要 ※条件送信キャンセル通知を受けたDE側で実施)
        //   3. 条件送信キャンセル通知

        // ◆1. 条件送信キャンセルのDB更新
        // ◆2. 次患者更新API要求
        //※doCancelにて1と2を実行
        eventLogMessage.setLogMessage(className + "." + methodName + " 変更後ベッド：条件送信キャンセルDB更新&次患者更新API要求開始(doCancel) facilityCd:[" + facilityCd + "] machineTypeCd:[" + afterBedMntMachineState.getMachineTypeCd() + "] machineSerial:[" + afterBedMntMachineState.getMachineSerial() + "] ord_no:[" + afterBedMntMachineState.getOrdNo() + "]");
        logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);

        OrdMain targetOrdMain = ordMainDao.selectByOrdNo(afterBedMntMachineState.getOrdNo());
        SendConditionCancelResponse sendConditionCancelRes = sendConditionCancelService.doCancel2(facilityCd, afterBedMntMachineState.getMachineTypeCd(), afterBedMntMachineState.getMachineSerial(), targetOrdMain);

        if (sendConditionCancelRes.isSuccess) {
          isDoCancelSuccess = true;
          // 条件送信キャンセル成功なら通信サーバー通知
          // ◆3. 条件送信キャンセル通知
          eventLogMessage.setLogMessage(className + "." + methodName + " 変更後ベッド：doCancel成功／条件送信キャンセル通知開始 facilityCd:[" + facilityCd + "] machineTypeCd:[" + afterBedMntMachineState.getMachineTypeCd() + "] machineSerial:[" + afterBedMntMachineState.getMachineSerial() + "]");
          logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
          res = deviceEdgeOrderService.orderCancelCondition(facilityCd, afterBedMstMachine.getDeviceEdgeNo(), afterBedMstMachine.getMachineNo());

          if (res.isSuccess) {
            postOrderCancelConditionErrorCounter++;
            eventLogMessage.setLogMessage(className + "." + methodName + " 変更後ベッド：「条件送信キャンセル通信サーバー通知」失敗 facilityCd:[" + facilityCd + "] machineTypeCd:[" + afterBedMntMachineState.getMachineTypeCd() + "] machineSerial:[" + afterBedMntMachineState.getMachineSerial() + "]");
            logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        } else {
          doCancelErrorCounter++;
          message = "「条件送信キャンセル」失敗しました";
          eventLogMessage.setLogMessage(className + "." + methodName + " 変更後ベッド：" + message + "(doCancelに失敗 ベッドコード=" + afterBedMntMachineState.getBedCd());
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        }
      }
    } else {
      eventLogMessage.setLogMessage(className + "." + methodName + " 変更後ベッド：doCancel処理なし");
      logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    }

    // --------------------
    // 変更前のベッド 【次患者更新処理】
    // --------------------
    // 次患者更新用引数初期化
    isSendCondition = false;
    sendConditionOrdNo = null;

    if (beforeDoCancelFlg){
      // 条件送信キャンセル対象
      beforeNextPatInfoFlg = true;
      // 次患者更新用引数設定
      isSendCondition = false;
      sendConditionOrdNo = null;
    } else {
      if(beforeBedMntMachineState != null){
        if(Objects.equals(beforeBedMntMachineState.getNextOrdNo(), beforeOrdMain.getOrdNo())){
          switch (beforeOrdMain.getRstDialysisState()){
            case "0":
              // 変更前bedの現患者・次患者の場合
              beforeNextPatInfoFlg = true;
              break;
            default:
              break;
          }
        } else {
          // 検索条件初期化(検索開始日に現在日+指定時刻を設定)
          DateTimeFormatter format = DateTimeFormatter.ofPattern("yyyyMMdd");
          DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

          // 検索開始時刻が未指定の場合は"000000"を設定
          String startTime = "000000";
          LocalDateTime nowDate = LocalDateTime.parse(LocalDateTime.now().format(format) + startTime, dateFormat);
          String searchStartDate = nowDate.format(format);
          OrdMain o = ordMainDao.selectByNextPat(facilityCd, beforeBedMntMachineState.getMachineTypeCd(), beforeBedMntMachineState.getMachineSerial(), searchStartDate);
          if(o == null){
            // 中止処理で後で並んでいる患者がいない場合
            beforeNextPatInfoFlg = true;
          } else {
            if(Objects.equals(o.getOrdNo(), beforeOrdMain.getOrdNo())){
              // 次患者の位置へ移動・登録・実績削除の場合
              beforeNextPatInfoFlg = true;
            } else {
              // 次患者と関係ない処理
              // beforeNextPatInfoFlg = false;
            }
          }
        }
        // 次患者更新用引数設定
        if(beforeNextPatInfoFlg){
          if(Objects.equals(beforeBedMntMachineState.getOrdNo(), beforeBedMntMachineState.getNextOrdNo())){
            sendConditionOrdNo = beforeBedMntMachineState.getOrdNo();
            if(sendConditionOrdNo != null){isSendCondition = true;}
          }
        }
      } else {
        // 変更前ベッドが未登録
        // beforeNextPatInfoFlg = false;
      }
    }

    //【次患者更新処理】
    if(beforeNextPatInfoFlg){
      try {
        ResponseEntity<String> responseSetNextPatInfo = null;
        responseSetNextPatInfo = webApiCallCommonUtil.OverrideSetNextPatInfo(beforeBedMntMachineState.getBedCd(), true, update, isSendCondition, sendConditionOrdNo);
        if (responseSetNextPatInfo != null) {
          JSONObject json = new JSONObject(responseSetNextPatInfo.getBody().toString());
          if (! json.has("isSuccess")) {
            // 次患者更新エラー
            setNextPatInfoErrorCounter++;
            eventLogMessage.setLogMessage(className + "." + methodName + " 変更前ベッド：「次患者更新」失敗 facilityCd:[" + facilityCd + "] beforeBedCd:[" + beforeBedMntMachineState.getBedCd() + "]");
            logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          } else if (responseSetNextPatInfo.getStatusCode() != HttpStatus.OK) {
            // 次患者通知エラー
            postOrderSendNextPatErrorCounter++;
            eventLogMessage.setLogMessage(className + "." + methodName + " 変更前ベッド：「次患者更新通信サーバー通知」失敗 facilityCd:[" + facilityCd + "] beforeBedCd:[" + beforeBedMntMachineState.getBedCd() + "]");
            logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
      } catch (URISyntaxException | RuntimeException e) {
        message = "「次患者更新」失敗しました";
        eventLogMessage.setLogMessage(className + "." + methodName + " 変更前ベッド：" + message + "(例外発生 facilityCd:[" + facilityCd + "] beforeBedCd:[" + beforeBedMntMachineState.getBedCd() + "] targetOrdNo:[" + beforeOrdMain.getOrdNo() + "])");
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        EventLogMessage eventLogMessageNew = new EventLogMessage();
        eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
        if (!StringUtils.isEmpty(facilityCd)) {
          eventLogMessageNew.setFacilityCd(facilityCd);
        }
        logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      }
    } else {
      eventLogMessage.setLogMessage(className + "." + methodName + " 変更前ベッド：次患者更新処理なし");
      logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    }

    // --------------------
    // 変更後のベッド 【次患者更新処理】
    // --------------------
    // 次患者更新用引数初期化
    isSendCondition = false;
    sendConditionOrdNo = null;
    //mod #10601 スケジュール表動作不正 start
    if(!afterBedJumpFlg){
      if (afterOrdMain != null){ // 中止処理ではない
        if (afterOrdMain.getIndBedCd() > 0){ // 変更後のbedは登録済み
          if(!Objects.equals(afterOrdMain.getIndBedCd(), beforeOrdMain.getIndBedCd())) { // 変更前後のbedが一致しない
            if(afterDoCancelFlg){
              // 条件送信キャンセル対象
              afterNextPatInfoFlg = true;
              // 次患者更新用引数設定
              isSendCondition = false;
              sendConditionOrdNo = null;
            } else{
              if(afterBedMntMachineState.getNextOrdNo() == null){
                // 次患者が存在しないベッドへ移動の場合。並んでいる患者がいない
                afterNextPatInfoFlg = true;
              } else {
                // 検索条件初期化(検索開始日に現在日+指定時刻を設定)
                DateTimeFormatter format = DateTimeFormatter.ofPattern("yyyyMMdd");
                DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

                // 検索開始時刻が未指定の場合は"000000"を設定
                String startTime = "000000";
                LocalDateTime nowDate = LocalDateTime.parse(LocalDateTime.now().format(format) + startTime, dateFormat);
                String searchStartDate = nowDate.format(format);
                OrdMain o = ordMainDao.selectByNextPat(facilityCd, afterBedMntMachineState.getMachineTypeCd(), afterBedMntMachineState.getMachineSerial(), searchStartDate);
                if(o == null){
                  // 中止処理で後で並んでいる患者がいない場合
                  afterNextPatInfoFlg = true;
                } else {
                  if(Objects.equals(o.getOrdNo(), afterOrdMain.getOrdNo())){
                    // 次患者の位置へ移動・登録の場合
                    afterNextPatInfoFlg = true;
                  } else {
                    // 次患者と関係ない処理
                    // afterNextPatInfoFlg = false;
                  }
                }
              }
              // 次患者更新用引数設定
              if(afterNextPatInfoFlg){
                if(Objects.equals(afterBedMntMachineState.getOrdNo(), afterBedMntMachineState.getNextOrdNo())){
                  sendConditionOrdNo = afterBedMntMachineState.getOrdNo();
                  if(sendConditionOrdNo != null){isSendCondition = true;}
                }
              }
            }
          }
        }
      }
    }
    //mod #10601 スケジュール表動作不正 end

    //【次患者更新処理】
    if(afterNextPatInfoFlg){
      try {
        ResponseEntity<String> responseSetNextPatInfo = null;
        responseSetNextPatInfo = webApiCallCommonUtil.OverrideSetNextPatInfo(afterBedMntMachineState.getBedCd(), true, update, isSendCondition, sendConditionOrdNo);
        if (responseSetNextPatInfo != null) {
          JSONObject json = new JSONObject(responseSetNextPatInfo.getBody().toString());
          if (! json.has("isSuccess")) {
            // 次患者更新エラー
            setNextPatInfoErrorCounter++;
            eventLogMessage.setLogMessage(className + "." + methodName + " 変更後ベッド：「次患者更新」失敗 facilityCd:[" + facilityCd + "] beforeBedCd:[" + afterBedMntMachineState.getBedCd() + "]");
            logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          } else if (responseSetNextPatInfo.getStatusCode() != HttpStatus.OK) {
            // 次患者通知エラー
            postOrderSendNextPatErrorCounter++;
            eventLogMessage.setLogMessage(className + "." + methodName + " 変更後ベッド：「次患者更新通信サーバー通知」失敗 facilityCd:[" + facilityCd + "] beforeBedCd:[" + afterBedMntMachineState.getBedCd() + "]");
            logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
      } catch (URISyntaxException | RuntimeException e) {
        message = "「次患者更新」失敗しました";
        eventLogMessage.setLogMessage(className + "." + methodName + " 変更後ベッド：" + message + "(例外発生 facilityCd:[" + facilityCd + "] beforeBedCd:[" + afterBedMntMachineState.getBedCd() + "] ordNo:[" + afterBedMntMachineState.getOrdNo() + "] nextOrdNo:[" + afterBedMntMachineState.getNextOrdNo() + "])");
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        EventLogMessage eventLogMessageNew = new EventLogMessage();
        eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
        if (!StringUtils.isEmpty(facilityCd)) {
          eventLogMessageNew.setFacilityCd(facilityCd);
        }
        logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      }
    } else {
      eventLogMessage.setLogMessage(className + "." + methodName + " 変更後ベッド：次患者更新処理なし");
      logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    }

    JSONObject errorMsgJson = new JSONObject("{}");
    errorMsgJson.put("message", message);
    errorMsgJson.put("doCancel", doCancelErrorCounter);
    errorMsgJson.put("postOrderCancelCondition", postOrderCancelConditionErrorCounter);
    errorMsgJson.put("setNextPatInfo", setNextPatInfoErrorCounter);
    errorMsgJson.put("postOrderSendNextPat", postOrderSendNextPatErrorCounter);
    errorMsgJson.put("isDoCancelSuccess", isDoCancelSuccess);
    eventLogMessage.setLogMessage(className + "." + methodName + " 処理終了");
    logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    return errorMsgJson.toString();
  }

  private MntMachineState NextPatByBedInfoTMntMachineState(NextPatByBedInfo nextPatByBedInfo){
    if(nextPatByBedInfo == null) {
      return null;
    }
    MntMachineState ret = new MntMachineState();
    BeanUtils.copyProperties(nextPatByBedInfo,ret);
    return ret;
  }

  private MstMachine NextPatByBedInfoTMstMachine(NextPatByBedInfo nextPatByBedInfo){
    if(nextPatByBedInfo == null){
      return null;
    }
    MstMachine ret = new MstMachine();
    BeanUtils.copyProperties(nextPatByBedInfo,ret);
    return ret;
  }

  /**
   * 次患者更新関連マスタデータ取得（マスタ変更）
   *
   * @param facilityCd
   * @param masterPhysicalName
   * @return List<T>
   * @description 注意：マスタデータのデータ物理削除は存在しない前提での処理
   */
  @Override
  public List<Object>  getTableDataBymasterPhysicalName(String facilityCd, String masterPhysicalName){
    //開始ログ
    final String className = new Object() {}.getClass().getEnclosingClass().getName();
    final String methodName = new Object() {}.getClass().getEnclosingMethod().getName();
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(className + "." + methodName + " 処理開始");
    logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);

    List<Object> resultList = new ArrayList<>();
    switch (masterPhysicalName){
      case "mst_kur":
        resultList = this.getTableData(facilityCd, masterPhysicalName, MstKur.class).stream().map(Object.class::cast).collect(Collectors.toList());
        break;
      case "mst_bed":
        resultList = this.getTableData(facilityCd, masterPhysicalName, MstBed.class).stream().map(Object.class::cast).collect(Collectors.toList());
        break;
      case "mst_machine":
        resultList = this.getTableData(facilityCd, masterPhysicalName, MstMachine.class).stream().map(Object.class::cast).collect(Collectors.toList());
        break;
      case "mst_va":
        resultList = this.getTableData(facilityCd, masterPhysicalName, MstVa.class).stream().map(Object.class::cast).collect(Collectors.toList());
        break;
      case "mst_comsv_setting":
        resultList = this.getTableData(facilityCd, masterPhysicalName, MstComsvSetting.class).stream().map(Object.class::cast).collect(Collectors.toList());
        break;
      case "mst_dialyzer":
        resultList = this.getTableData(facilityCd, masterPhysicalName, MstDialyzer.class).stream().map(Object.class::cast).collect(Collectors.toList());
        break;
      case "mst_treatment":
        resultList = this.getTableData(facilityCd, masterPhysicalName, MstTreatment.class).stream().map(Object.class::cast).collect(Collectors.toList());
        break;
      case "mst_equipment":
        resultList = this.getTableData(facilityCd, masterPhysicalName, MstEquipment.class).stream().map(Object.class::cast).collect(Collectors.toList());
        break;
      case "mst_ward":
        resultList = this.getTableData(facilityCd, masterPhysicalName, MstWard.class).stream().map(Object.class::cast).collect(Collectors.toList());
        break;
      case "mst_course":
        resultList = this.getTableData(facilityCd, masterPhysicalName, MstCourse.class).stream().map(Object.class::cast).collect(Collectors.toList());
        break;
      case "mst_personal_user":
        resultList = this.getTableData(facilityCd, masterPhysicalName, MstPersonalUser.class).stream().map(Object.class::cast).collect(Collectors.toList());
        break;
      case "mst_medicine":
        resultList = this.getTableData(facilityCd, masterPhysicalName, MstMedicine.class).stream().map(Object.class::cast).collect(Collectors.toList());
        break;
      case "mst_medicine_mix":
        resultList = this.getTableData(facilityCd, masterPhysicalName, MstMedicineMix.class).stream().map(Object.class::cast).collect(Collectors.toList());
        break;
      default:
        eventLogMessage.setLogMessage(className + "." + methodName + " masterPhysicalNameが正しくありません。ここは次患者送信関連MST変更処理です");
        logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        break;
    }

    eventLogMessage.setLogMessage(className + "." + methodName + " 処理終了");
    logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);

    return resultList;
  }

  private  <T> List<T> getTableData(String facilityCd, String masterPhysicalName, Class<T> clazz) {

    Config config = defaultDbConfig;

    // SelectBuilder
    SelectBuilder builder = SelectBuilder.newInstance(config);

    // SQL構成
    builder.sql("SELECT * FROM ").sql(masterPhysicalName);

    // WHERE条件
    builder.sql("WHERE facility_cd = ").param(String.class, facilityCd);

    // SQL検索
    List<T> resultList = builder.getEntityResultList(clazz);

    return resultList;
  }
}
