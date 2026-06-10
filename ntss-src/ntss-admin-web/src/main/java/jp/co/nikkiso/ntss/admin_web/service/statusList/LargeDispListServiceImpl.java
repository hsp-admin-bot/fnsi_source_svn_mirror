package jp.co.nikkiso.ntss.admin_web.service.statusList;

import java.io.IOException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.OrdMainConst;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.OrdMainConst.DialysisState;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Treatment.DeviceMode;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.ComType;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.FacilitySettingNo;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.response.statusList.LargeDispListResponse;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.statusList.dto.LargeDispListDTO;
import jp.co.nikkiso.ntss.admin_web.service.utils.StrUtils;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.dao.BbsInfoDao;
import jp.co.nikkiso.ntss.core.dao.LargeDispListDao;
import jp.co.nikkiso.ntss.core.dao.MstBedDao;
import jp.co.nikkiso.ntss.core.dao.MstComsvSettingDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstKurDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.PatExamMainDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.TreatmentStatusListDao;
import jp.co.nikkiso.ntss.core.entity.BbsInfo;
import jp.co.nikkiso.ntss.core.entity.MstBed;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.PatExamMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.entity.custom.LargeDispMonitorData;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainRstWeightInfo;
import jp.co.nikkiso.ntss.core.entity.custom.TreatmentStatusList;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class LargeDispListServiceImpl implements LargeDispListService {

  @Autowired
  LargeDispListDao largeDispListDao;
  @Autowired
  MstComsvSettingDao mstComsvSettingDao;
  @Autowired
  PatPersonalMainDao patPersonalMainDao;
  @Autowired
  PatExamMainDao patExamMainDao;
  @Autowired
  BbsInfoDao bbsInfoDao;

  @Autowired
  MstBedDao mstBedDao;
  @Autowired
  MstKurDao mstKurDao;
  @Autowired
  MstMachineDao mstMachineDao;
  @Autowired
  TreatmentStatusListDao treatmentStatusListDao;
  @Autowired
  PatMainDao patMainDao;

  @Autowired
  private LogService logService;
  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;

  /**
   * ObjectMapper.
   */
  @Autowired
  private ObjectMapper mapper;

  private String getJsonNodeValue(String jsonText, String keyName) {
    try {
      JsonNode node = mapper.readTree(jsonText);

      if (keyName.length() > 0) {
        String[] keyNameArray = keyName.split(",");
        for (String key : keyNameArray) {
          node = node != null && node.has(key) ? node.get(key) : null;
        }
        return node != null ? node.asText() : "";
      } else {
        return "";
      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request error by get getJsonNodeValue : " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }
    return "null";
  }

  private Integer getMachineComType(
    final Long bedCd,
    List<MstBed> bedList,
    List<MstMachine> machineList
  ) {
    Integer machineComType = null;
    if (bedCd != null && bedCd > 0) {
      MstBed bed = bedList.stream()
          .filter(state -> Objects.equals(state.getBedCd(), bedCd))
          .findFirst()
          .orElse(null);
      if (bed != null) {
        // 装置情報
        MstMachine machine = machineList.stream()
            .filter(state -> Objects.equals(state.getMachineNo(), bed.getMachineNo()))
            .findFirst()
            .orElse(null);
        if (machine != null) {
          // 通信種別
          machineComType = machine.getComType();
        }
      }
    }
    return machineComType;
  }

  private LargeDispListResponse makeLargeDispResponse(List<TreatmentStatusList> treatmentStatus, String facilityCd,
      String treatDate) {

    LargeDispListResponse response = new LargeDispListResponse();

    // ベッド情報取得
    List<MstBed> bedList = this.mstBedDao.selectByFacilityCd(facilityCd, "1", "0");
    // 装置情報取得
    List<MstMachine> machineList = this.mstMachineDao.selectByFacility(facilityCd);

    if (treatmentStatus.size() <= 0) {
      return response;
    }
    LocalDateTime nowDate = LocalDateTime.now();
    // 治療状況データ分の患者個人情報をあらかじめ取得
    List<Long> patIds = treatmentStatus.stream()
        .filter(o -> !Objects.isNull(o) && !Objects.isNull(o.getPatId()))
        .map(o -> o.getPatId())
        .distinct()
        .collect(Collectors.toList());
    List<PatPersonalMain> patPersonalList = new ArrayList<>();
    if (patIds.size() > 0) {
      patPersonalList = patPersonalMainDao.selectByIdListFacilityCd(patIds, facilityCd);
    }
    // ordNoList
    List<Long> ordNoList = treatmentStatus.stream()
        .filter(o -> !Objects.isNull(o) && !Objects.isNull(o.getOrdNo()))
        .map(o -> o.getOrdNo())
        .distinct()
        .collect(Collectors.toList());
    // モニタデータ(残り時間・血圧測定情報)取得
    // mod #6264 2022-08-04 治療状況リスト・マップの表示項目の参照先がmni_monitor→mnt_machine_state.monitor_dataに変更されていない。 dou start
//    List<LargeDispMonitorData> moniList = largeDispListDao.selectMonitorDataForEntry(ordNoList);
    List<LargeDispMonitorData> moniList = largeDispListDao.selectMonitorDataForEntry(ordNoList, facilityCd);
    // mod #6264 2022-08-04 治療状況リスト・マップの表示項目の参照先がmni_monitor→mnt_machine_state.monitor_dataに変更されていない。 dou end
    // サービス戻り値用格納リスト(mode0：透析前、mode1：透析中、mode2：透析後)
    List<LargeDispListDTO> mode0List = new ArrayList<LargeDispListDTO>();
    List<LargeDispListDTO> mode1List = new ArrayList<LargeDispListDTO>();
    List<LargeDispListDTO> mode2List = new ArrayList<LargeDispListDTO>();

    // 穿刺待ち・回収待ち件数カウンタ
    int cntReturnWait = 0;
    int cntPuncWait = 0;
    // 治療状況データ分
    for (TreatmentStatusList ord : treatmentStatus) {
      if (ord.getRstDialysisState() == null ||
          ord.getRstDialysisState().equals(OrdMainConst.DialysisState.BEFORE_SEND) ||
          ord.getRstDialysisState().equals(OrdMainConst.DialysisState.AFTER_WEIGHT) ||
          ord.getRstDialysisState().equals(OrdMainConst.DialysisState.PAST_RECORD)) {
        // NOTE: 条件送信前、後体重測定後の状態は表示しない
        continue;
      }
      LargeDispListDTO dto = new LargeDispListDTO();
      dto.setOrdNo(ord.getOrdNo());

      if (ord.getPatId() != null) {
        Long patId = ord.getPatId();
        dto.setPatId(patId);

        // 患者個人名の取得
        PatPersonalMain pat = patPersonalList.stream()
            .filter(o -> Objects.equals(o.getPat_id(), patId))
            .findFirst()
            .orElse(null);
        if (pat != null) {
          dto.setPatFirstName(pat.getPat_first_name());
          dto.setPatLastName(pat.getPat_last_name());

          // 入院
          dto.setInOutClass(pat.getIn_out_class());
        }

        if (ord.getTreatDate() != null) {
          // 治療予定がある実績の場合、検査予定を取得
          LocalDateTime treatDateFrom = null;
          LocalDateTime teratDateTo = null;

          try {
            LocalDate localBaseDate = LocalDate.parse(ord.getTreatDate(), DateTimeFormatter.ofPattern("uuuuMMdd"));
            treatDateFrom = localBaseDate.atTime(0, 0);
            teratDateTo = localBaseDate.plusDays(1).atTime(0, 0);

            List<PatExamMain> patExamList = patExamMainDao.selectPatExamMainForLargeDisp(patId,
                Timestamp.valueOf(treatDateFrom), Timestamp.valueOf(teratDateTo));
            for (PatExamMain patExam : patExamList) {
              if (patExam.getExamStatus().equals("0")) {
                dto.setHasExamSche(true);
              }
            }
          } catch (Exception ex) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage("error by get PatExamMain : " + ex.getMessage());
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          }
        }
      }
      // ベッド情報
      dto.setBedName(ord.getRstBedName());
      dto.setBedCd(ord.getRstBedCd());
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      try {
        // 投薬情報
        dto.setIsMediDone(ord.getRstMediInfo());
      } catch (IOException e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        eventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // 穿刺情報
      dto.setPunc1Done(ord.getRstPunctureDateA());
      dto.setPunc2Done(ord.getRstPunctureDateB());
      // 返血情報
      dto.setReturn1Done(ord.getRstReturnDateA());
      dto.setReturn2Done(ord.getRstReturnDateB());
      // 担当者情報
      dto.setCharge1Done(ord.getRstChargeDateA());
      dto.setCharge2Done(ord.getRstChargeDateB());
      // 前体重測定日時
      String weight = ord.getRstWeightInfo();
      if (weight != null) {
        try {
          OrdMainRstWeightInfo wei = Objects.isNull(weight) || weight.isEmpty() ? new OrdMainRstWeightInfo()
              : mapper.readValue(weight, OrdMainRstWeightInfo.class);
          dto.setWeightBeforeDate(wei.getWeightBeforeDate());
        } catch (IOException e) {
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("JSON parse error by get OrdMainRstWeightInfo : " + e.getMessage());
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        }
      }
      // 条件送信日時
      dto.setCondSendDate(ord.getRstCondSendDate());
      // 治療終了時刻
      dto.setEndDate(ord.getRstEndDate());
      // 治療開始日時
      dto.setStartDate(ord.getRstStartDate());

      // 治療時間取得
      String rstCondInfo = ord.getRstCondInfo();
      if (null != rstCondInfo) {
        String condTimeText = this.getJsonNodeValue(rstCondInfo, "1,value");
        if (StrUtils.isNumber(condTimeText) && ord.getRstStartDate() != null) {
          dto.setEndDatePlan(Long.parseLong(condTimeText), ord.getRstStartDate().toLocalDateTime());
        } else {
          dto.setEndDatePlan(null);
        }
      }

      try {
        // 血圧測定間隔
        String StrBpmiInterval = patMainDao.selectBpmiIntervalById(ord.getPatId());
        // 血圧測定実施確認
        if (Objects.nonNull(StrBpmiInterval) && !StrBpmiInterval.isEmpty()) {
          Long bpmiInterval = Long.valueOf(StrBpmiInterval);
          dto.setIsBpMeasure(moniList, nowDate, bpmiInterval, ord.getRstDialysisState());
        }
      } catch (Exception e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("血圧測定実施確認時にエラー : " + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }

      // #11373対応時のメモ：
      // 残り時間の表示対象は
      // rst_dialysis_state＝3
      // かつ 対象装置の装置マスタのcom_type＝1
      // かつ 治療記録＞実績情報＞治療方法の治療モードが特殊浄化ではない
      // （残り時間が60以下 の条件は setRemainMinutes 内で処理している）
      Integer machineComType = getMachineComType(ord.getRstBedCd(), bedList, machineList);
      if (
        Objects.equals(ord.getRstDialysisState(), DialysisState.DIALYSIS)
        && Objects.equals(machineComType, ComType.NKK_COMM)
        && !Objects.equals(ord.getRstTreatmentDeviceMode(), DeviceMode.PURIFICATION)
      ) {
        // 残り時間
        dto.setRemainMinutes(moniList);
      }

      // 治療状況別の処理
      /// 透析前
      if (Objects.equals(ord.getRstDialysisState(), DialysisState.AFTER_SEND)
          || Objects.equals(ord.getRstDialysisState(), DialysisState.CHECKED_SEND)) {
        // 穿刺待ち件数カウント
        if (!dto.isPunc1Done || !dto.isPunc2Done) {
          cntPuncWait++;
        }

        mode0List.add(dto);
      }
      /// 透析中
      else if (Objects.equals(ord.getRstDialysisState(), DialysisState.DIALYSIS)) {
        // add FNSI-改修内容　状況リスト一覧表示は「透析状態＋透析時間」により判断対応 陳 start
        boolean eturnWaitFlg = false;
        // 回収待ち件数カウント
        //del FNSI redmine 7305 劉祥霖 start
//        if (dto.isReturn1Done == false || dto.isReturn2Done == false) {
        //del FNSI redmine 7305 劉祥霖 end
          //　加算用時
          int hour = 0;

          // 加算用分
          int minu = 0;

          // 治療時間取得の取得
          if (null != rstCondInfo) {

            String condTimeText = this.getJsonNodeValue(rstCondInfo, "1,value");

            // 時の算出
            hour = Integer.parseInt(condTimeText) / 60;

            // 分の算出
            minu = Integer.parseInt(condTimeText) % 60;
          }

          // フォマード設定
          SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");;

          Calendar nowTime = Calendar.getInstance();

          // 予想終了時刻
          String startDay = "";
          if (ord.getRstStartDate() != null) {

            // 実績：治療開始日時
            startDay = String.valueOf(ord.getRstStartDate());

          } else {

            // 治療開始時刻
            String startTime = ord.getIndTreatStartTime() == null ? "0000" :ord.getIndTreatStartTime();

            // 治療日 + 治療開始時刻
            startDay = ord.getTreatDate() + startTime;

            SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmm");

            Date newDate = null;
            try{

              newDate = formatter.parse(startDay);
            }catch (ParseException e){

              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
              EventLogMessage eventLogMessage = new EventLogMessage();
              eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
              if (!StringUtils.isEmpty(facilityCd)) {
                eventLogMessage.setFacilityCd(facilityCd);
              }
              logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
            }

            // 予想終了時刻再設定
            startDay = String.valueOf(sdf.format(newDate));
          }

          try{

            nowTime.setTime(sdf.parse(startDay));
          }catch (ParseException e){

            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
            if (!StringUtils.isEmpty(facilityCd)) {
              eventLogMessage.setFacilityCd(facilityCd);
            }
            logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
          }

          // 期間の計算
          nowTime.add(Calendar.HOUR, hour);
          nowTime.add(Calendar.MINUTE, minu);

          // 現在時刻の取得
          Date now = new Date();

          // 現在時刻 > 予想終了時刻の場合、回収待ち件数カウント
          if (sdf.format(now).compareTo(sdf.format(nowTime.getTime())) >= 0) {

            cntReturnWait++;

            eturnWaitFlg = true;

            mode2List.add(dto);
          }
        //del FNSI redmine 7305 劉祥霖 start
//        }
        //del FNSI redmine 7305 劉祥霖 end
        // add FNSI-改修内容　状況リスト一覧表示は「透析状態＋透析時間」により判断対応 陳 end

        // mod FNSI-改修内容　状況リスト一覧表示は「透析状態＋透析時間」により判断対応 陳 start
        //dto.setEndDatePred(moniList, nowDate);
        //dto.setIsBpMeasure(moniList, nowDate);

        //mode1List.add(dto);

        if (!eturnWaitFlg) {
          // 終了予測
          dto.setEndDatePred(moniList, nowDate);

          mode1List.add(dto);
        }
        // mod FNSI-改修内容　状況リスト一覧表示は「透析状態＋透析時間」により判断対応 陳 end

      }
      // del FNSI-改修内容　状況リスト一覧表示は「透析状態＋透析時間」により判断対応 陳 start
      /// 透析後
      //else if (Objects.equals(ord.getRstDialysisState(), DialysisState.AFTER_DIALYSIS)) {

        // 回収待ち件数カウント
        //if (dto.isReturn1Done == false || dto.isReturn2Done == false) {
        //  cntReturnWait++;
        //}


        //mode2List.add(dto);
      //}
      // del FNSI-改修内容　状況リスト一覧表示は「透析状態＋透析時間」により判断対応 陳 end
    }
    // ソート処理
    List<LargeDispListDTO> mode0_sorted = this.sortList(mode0List, 0);
    List<LargeDispListDTO> mode1_sorted = this.sortList(mode1List, 1);
    List<LargeDispListDTO> mode2_sorted = this.sortList(mode2List, 2);

    // 施設イベント収集
    response.info = this.correctBbsInfo(treatDate, facilityCd);

    response.patList_mode0 = mode0_sorted;
    response.patList_mode1 = mode1_sorted;
    response.patList_mode2 = mode2_sorted;
    response.cntPuncWait = cntPuncWait;
    response.cntReturnWait = cntReturnWait;
    return response;
  }

  @Override
  public LargeDispListResponse getLargeDispPatList(String facilityCd, String treatDate) {

    // エントリー患者一覧取得
    List<TreatmentStatusList> treatmentStatus = treatmentStatusListDao.selectAll(facilityCd);
    // 版未確定分
    List<TreatmentStatusList> treatmentStatus2 = treatmentStatusListDao.selectOrdMainUnedition(facilityCd);
    // 情報の追加登録
    treatmentStatus2.forEach(item -> {
      // 手動実績以外(input_class=1)を追加対象とする
      if (Objects.equals(item.getRstInputClass(), 1)) {
        // 同一情報の重複チェック
        TreatmentStatusList state = treatmentStatus.stream()
            .filter(list -> Objects.equals(list.getOrdNo(), item.getOrdNo()))
            .findFirst()
            .orElse(null);
        if (state == null) {
          // 存在しない場合は追加
          treatmentStatus.add(item);
        }
      }
    });

    return makeLargeDispResponse(treatmentStatus, facilityCd, treatDate);
  };

  /**
   * エントリー患者一覧を時刻の早いもの順に並べる
   * @param list エントリー患者一覧リスト
   * @param mode 治療状況(0:透析前、1:透析中、2:透析後)
   * @return
   */
  private List<LargeDispListDTO> sortList(List<LargeDispListDTO> list, int mode) {
    List<LargeDispListDTO> rtn = new ArrayList<LargeDispListDTO>();
    List<LargeDispListDTO> itemList = list;
    List<LargeDispListDTO> bufList = new ArrayList<LargeDispListDTO>();

    if (mode == 0 || mode == 1 || mode == 2) {
      LocalDateTime bufDate = LocalDateTime.now();

      int listSize = list.size();
      int fastestIndex = 0;

      for (int lop1 = 0; lop1 < listSize; lop1++) {
        for (int lop2 = 0; lop2 < itemList.size(); lop2++) {
          LargeDispListDTO item = itemList.get(lop2);

          LocalDateTime itemDate = null;
          if (mode == 0 && !Objects.isNull(item.getCondSendDate())) {
            itemDate = item.getCondSendDate().toLocalDateTime();
          }
          if (mode == 1 && !Objects.isNull(item.getEndDatePlan())) {
            itemDate = item.getEndDatePlan().toLocalDateTime();
          }
          if (mode == 2 && !Objects.isNull(item.getEndDate())) {
            itemDate = item.getEndDate().toLocalDateTime();
          }
          if (itemDate != null) {
            try {
              if (lop2 == 0) {
                bufDate = itemDate;
                fastestIndex = lop2;
              } else {
                if (itemDate.isBefore(bufDate)) {
                  bufDate = itemDate;
                  fastestIndex = lop2;
                }
              }
            } catch (Exception e) {
              // TODO 自動生成された catch ブロック
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
              EventLogMessage eventLogMessage = new EventLogMessage();
              eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
              logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
            }
          }
        }
        bufList.add(itemList.get(fastestIndex));
        itemList.remove(fastestIndex);
        bufDate = LocalDateTime.now();
        fastestIndex = 0;
      }
      rtn = bufList;
    } else {
      rtn = list;
    }

    return rtn;
  }

  /**
   * 指定日に表示する施設イベントの収集
   * @param targetDate 指定日
   * @param facilityCd 施設コード
   * @return
   */
  private List<LargeDispListResponse.LargeDisoInfo> correctBbsInfo(String targetDate, String facilityCd) {
    List<LargeDispListResponse.LargeDisoInfo> ret = new ArrayList<>();
    Long kindNo = fetchTargetKindNo(facilityCd);
    if (kindNo.compareTo(0L) <= 0) {
      return ret;
    }
    List<BbsInfo> bbsInfo = bbsInfoDao.selectByKindAndDate(facilityCd, kindNo, targetDate);
    for (BbsInfo info : bbsInfo) {
      LargeDispListResponse.LargeDisoInfo d = new LargeDispListResponse().new LargeDisoInfo();
      d.bbsCtlNo = info.getBbs_ctl_no();
      d.content = info.getContent();
      d.endDate = info.getNotice_fac_cal_end_date();
      d.startDate = info.getNotice_fac_cal_start_date();
      d.title = info.getTitle();

      ret.add(d);
    }
    return ret;
  }

  /**
   * 施設設定から対象カテゴリを取得
   * @param facilityCd 施設コード
   * @return
   */
  private Long fetchTargetKindNo(String facilityCd) {
    FacilitySettingInfo infoEnableWeightSelect = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd,
        FacilitySettingNo.LARGE_DISP_INFO_KIND);
    if (infoEnableWeightSelect == null || infoEnableWeightSelect.getValue() == null
        || infoEnableWeightSelect.getValue().isEmpty() || !StrUtils.isNumber(infoEnableWeightSelect.getValue())) {
      return -1L;
    } else {
      return Long.parseLong(infoEnableWeightSelect.getValue());
    }
  }
}
