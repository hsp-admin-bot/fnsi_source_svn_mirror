package jp.co.nikkiso.ntss.api.service.journal;

import jp.co.nikkiso.ntss.api.model.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.core.dao.PatExamMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatRadMainDao;
import jp.co.nikkiso.ntss.core.dto.OrdMain.JournalEventLinkByPat;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.OrdPrescription;
import jp.co.nikkiso.ntss.core.entity.PatExamMain;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatRadMain;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.ObjectUtils;

import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;


@Service("journalCreatePayloadServiceImplV2")
public class JournalCreatePayloadServiceImpl implements JournalCreatePayloadService {

  @Autowired
  PatPersonalMainDao patPersonalMainDao;

  @Autowired
  PatExamMainDao patExamMainDao;

  @Autowired
  PatRadMainDao patRadMainDao;

  // del #11004 連携イベント発生部分不正 piao start
  // @Autowired
  // TreatmentRecordService treatmentRecordService;
  // del #11004 連携イベント発生部分不正 piao end


  @Override
  public List<JournalCreateRequestPayload> createJournalPayload(String facilityCd,
                                                                Map<String, List<Object>> resultAllChangedDataInfoList,
                                                                Map<String, List<Object>> resultAllChangeBeforeDataInfoList,
                                                                List<Long> patIdList, Long updId, String actionMode){
    List<JournalCreateRequestPayload> journalList = new ArrayList<>();
    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");

    List<PatPersonalMain> patPersonalMainList = patPersonalMainDao.selectPatPersonalMainForHospPatIdListByPatIdList(facilityCd, patIdList);
    Map<Long, String> patPersonalMainListMap = patPersonalMainList.stream().collect(Collectors.toMap(PatPersonalMain::getPat_id, PatPersonalMain::getHosp_pat_id));

    String option = actionMode;
    // del #11004 連携イベント発生部分不正 piao start
    // int modify_send_class = treatmentRecordService.getCoopIniSchModifySendClass(facilityCd);
    // del #11004 連携イベント発生部分不正 piao end

    // 治療予定が削除　または　クールが指定→未登録へ　変更した場合、発行すべきDイベント &&
    // 治療予定が登録　または　クールが未登録→指定へ　変更した場合、発行すべきCイベントのリスト
    List<JournalEventLinkByPat> journalEventLinkByPatList = new ArrayList<>();
    Map<String, JournalEventLinkByPat> journalEventLinkByPatListMap = journalEventLinkByPatList.stream().collect(Collectors.toMap(value -> value.getUniqueKey(),value -> value));

    if(resultAllChangedDataInfoList != null){
      // Define table priority map
      Map<String, Integer> tablePriorityMap = new HashMap<>();
      tablePriorityMap.put("ord_main", 1);
      tablePriorityMap.put("pat_exam_main", 2);
      tablePriorityMap.put("pat_rad_main", 3);
      tablePriorityMap.put("ord_prescription", 4);
      tablePriorityMap.put("pat_main", 5);
      // Add more tables and their priorities as needed

      // Sort entries by table priority
      List<Map.Entry<String, List<Object>>> sortedEntries = resultAllChangedDataInfoList.entrySet().stream()
        .sorted((e1, e2) -> {
          int p1 = tablePriorityMap.getOrDefault(e1.getKey(), Integer.MAX_VALUE);
          int p2 = tablePriorityMap.getOrDefault(e2.getKey(), Integer.MAX_VALUE);
          return Integer.compare(p1, p2);
        })
        .collect(Collectors.toList());

      // Define a set of tables to process
      Set<String> tablesToProcess = new HashSet<>(Arrays.asList(
        "ord_main", "pat_exam_main", "pat_rad_main", "ord_prescription", "pat_main"
        // Add more tables as needed
      ));

      // 新規・更新・論理削除の判定
      for (Map.Entry<String, List<Object>> entry : sortedEntries) {
        String tablePhysicalName = entry.getKey(); // テーブル名

        List<Object> values = entry.getValue(); // レコード

        List<Object> oldValues = null;
        Map<Long, Object> map = new HashMap<>();
        if(resultAllChangeBeforeDataInfoList != null){
          // 変更前レコードをMap化
          oldValues = resultAllChangeBeforeDataInfoList.get(tablePhysicalName);
          if (oldValues != null) {
            switch (tablePhysicalName){
              case "ord_main":
                map = null;
                map = oldValues.stream().filter(OrdMain.class::isInstance).map(OrdMain.class::cast).collect(Collectors.toMap(value -> value.getOrdNo(), value -> value));
                break;
              case "pat_exam_main":
                map = null;
                map = oldValues.stream().filter(PatExamMain.class::isInstance).map(PatExamMain.class::cast).collect(Collectors.toMap(value -> value.getExamMainCd(), value -> value));
                break;
              case "pat_rad_main":
                map = null;
                map = oldValues.stream().filter(PatRadMain.class::isInstance).map(PatRadMain.class::cast).collect(Collectors.toMap(value -> value.getRadResultCd(), value -> value));
                break;
              case "ord_prescription":
                map = null;
                map = oldValues.stream().filter(OrdPrescription.class::isInstance).map(OrdPrescription.class::cast).collect(Collectors.toMap(value -> value.getOrdPrescriptionNo(), value -> value));
                break;
              default:
                // 連携対象外Tables
                break;
            }
          }
        }

        for (Object value : values) {
          option = actionMode;

          JournalCreateRequestPayload journalCreateRequestPayload = new JournalCreateRequestPayload();
          journalCreateRequestPayload.setFacilityCd(facilityCd);

          OrdMain ordMain = null;
          PatExamMain patExamMain = null;
          PatRadMain patRadMain = null;
          OrdPrescription ordPrescription = null;
          PatMain patMain = null;
          String crud = null;
          Long patId = 0L;
          String changeMode = null;
          String action = null;
          String hospPatId = null;
          switch (tablePhysicalName){
            case "ord_main":
              ordMain = (OrdMain)value;
              OrdMain beforeOrdMain = (OrdMain)map.get(ordMain.getOrdNo());
              changeMode = this.getChangeMode(beforeOrdMain, ordMain);
              action = option + "_" + changeMode;

              if("1".equals(ordMain.getIsDel())){
                crud = "D";
              } else if(Objects.equals(ordMain.getUpDate(), ordMain.getRegDate())){
                crud = "C";
              } else {
                crud = "U";
              }
              // クール指定による補正
              if(ordMain.getIndKurCd() == 0 && (beforeOrdMain !=null && beforeOrdMain.getIndKurCd() != 0)){
                crud = "D";
              }
              // クール指定による補正
              if(ordMain.getIndKurCd() != 0 &&  (beforeOrdMain !=null && beforeOrdMain.getIndKurCd() == 0)){
                crud = "C";
              }

              journalCreateRequestPayload.setFacilityCd(ordMain.getFacilityCd());
              journalCreateRequestPayload.setCrud(crud);

              patId = ordMain.getPatId();
              hospPatId = patPersonalMainListMap.get(patId);

              journalCreateRequestPayload.setPatId(patId);
              journalCreateRequestPayload.setHospPatId(hospPatId);
              journalCreateRequestPayload.setUserId(updId);
              journalCreateRequestPayload.setOpeCd(OPECDENUM.getOpeIdByCrudTablenameOption(tablePhysicalName, crud, action));
              journalCreateRequestPayload.setOrdNo(ordMain.getOrdNo());
              journalCreateRequestPayload.setBaseDate(ordMain.getTreatDate());

              if("SCHEDULE_DAY_CHG".equals(changeMode)){
                if((beforeOrdMain !=null && beforeOrdMain.getIndKurCd() != 0)){
                  JournalCreateRequestPayload journalCreateRequestPayloadDelete = null;
                  journalCreateRequestPayloadDelete = new JournalCreateRequestPayload();
                  journalCreateRequestPayloadDelete.setFacilityCd(ordMain.getFacilityCd());
                  journalCreateRequestPayloadDelete.setCrud("D");
                  journalCreateRequestPayloadDelete.setPatId(patId);
                  journalCreateRequestPayloadDelete.setHospPatId(hospPatId);
                  journalCreateRequestPayloadDelete.setUserId(updId);
                  journalCreateRequestPayloadDelete.setOpeCd(OPECDENUM.getOpeIdByCrudTablenameOption(tablePhysicalName, "D", action));
                  journalCreateRequestPayloadDelete.setOrdNo(ordMain.getOrdNo());
                  journalCreateRequestPayloadDelete.setBaseDate(beforeOrdMain.getTreatDate());
                  journalList.add(journalCreateRequestPayloadDelete);
                  // 治療予定が削除　または　クールが指定→未登録へ　変更した場合、発行すべきDイベント治療日のリストadd
                  this.addToBeDEventTreatDate(journalEventLinkByPatListMap, facilityCd, patId, hospPatId, beforeOrdMain.getTreatDate(), beforeOrdMain.getIndKurCd());
                }
                if(ordMain.getIndKurCd() != 0){
                  crud = "C";
                  journalCreateRequestPayload.setCrud(crud);
                  journalCreateRequestPayload.setOpeCd(OPECDENUM.getOpeIdByCrudTablenameOption(tablePhysicalName, crud, action));
                } else {
                  continue;
                }
              }
              if("SCHEDULE_DAY_CHG_KURNONE".equals(changeMode)){
                if(beforeOrdMain !=null){
                  JournalCreateRequestPayload journalCreateRequestPayloadDelete = null;
                  journalCreateRequestPayloadDelete = new JournalCreateRequestPayload();
                  journalCreateRequestPayloadDelete.setFacilityCd(ordMain.getFacilityCd());
                  journalCreateRequestPayloadDelete.setCrud("D");
                  journalCreateRequestPayloadDelete.setPatId(patId);
                  journalCreateRequestPayloadDelete.setHospPatId(hospPatId);
                  journalCreateRequestPayloadDelete.setUserId(updId);
                  journalCreateRequestPayloadDelete.setOpeCd(OPECDENUM.getOpeIdByCrudTablenameOption(tablePhysicalName, "D", action));
                  journalCreateRequestPayloadDelete.setOrdNo(ordMain.getOrdNo());
                  journalCreateRequestPayloadDelete.setBaseDate(beforeOrdMain.getTreatDate());
                  journalList.add(journalCreateRequestPayloadDelete);
                }
                crud = "C";
                journalCreateRequestPayload.setCrud(crud);
                journalCreateRequestPayload.setOpeCd(OPECDENUM.getOpeIdByCrudTablenameOption(tablePhysicalName, crud, action));
              }

              // 治療予定が削除　または　クールが指定→未登録へ　変更した場合、発行すべきDイベント治療日のリストadd
              if("D".equals(crud) && (beforeOrdMain !=null && beforeOrdMain.getIndKurCd() != 0)){
                this.addToBeDEventTreatDate(journalEventLinkByPatListMap, facilityCd, patId, hospPatId, beforeOrdMain.getTreatDate(), beforeOrdMain.getIndKurCd());
              }
              // 治療予定が登録　または　クールが未登録→指定へ　変更した場合、発行すべきCイベント治療日のリスト
              if("C".equals(crud) && ordMain.getIndKurCd() != 0){
                this.addToBeCEventTreatDate(journalEventLinkByPatListMap, facilityCd, patId, hospPatId, ordMain.getTreatDate(), ordMain.getIndKurCd());
              }
              // 治療予定が　変更した場合、発行すべきUイベント治療日のリスト
              if("U".equals(crud) && ordMain.getIndKurCd() != 0 && beforeOrdMain !=null && beforeOrdMain.getIndKurCd() != 0){
                String indCondInfo = ordMain.getIndCondInfo();
                String treatmentTime = "";
                if (indCondInfo != null) {
                  JSONObject jsonIndCondInfo = new JSONObject(indCondInfo);
                  if (jsonIndCondInfo.has("1")) {
                    JSONObject treatmentTimeO = new JSONObject(jsonIndCondInfo.get("1").toString());
                    if (treatmentTimeO.get("value") != null) {
                      treatmentTime = treatmentTimeO.get("value").toString();
                    }
                  }
                }
                String indCondInfoBefore = beforeOrdMain.getIndCondInfo();
                String treatmentTimeBefore = "";
                if (indCondInfoBefore != null) {
                  JSONObject jsonIndCondInfoBefore = new JSONObject(indCondInfoBefore);
                  if (jsonIndCondInfoBefore.has("1")) {
                    JSONObject treatmentTimeBeforeO = new JSONObject(jsonIndCondInfoBefore.get("1").toString());
                    if (treatmentTimeBeforeO.get("value") != null) {
                      treatmentTimeBefore = treatmentTimeBeforeO.get("value").toString();
                    }
                  }
                }
                if (!Objects.equals(treatmentTime, treatmentTimeBefore) ||
                  !Objects.equals(ordMain.getIndKurCd(), beforeOrdMain.getIndKurCd()) ||
                  !Objects.equals(ordMain.getIndTreatStartTime(), beforeOrdMain.getIndTreatStartTime())) {
                  this.addToBeUEventTreatDate(journalEventLinkByPatListMap, facilityCd, patId, hospPatId, ordMain.getTreatDate(), ordMain.getIndKurCd());
                }
              }

              // #10429新機能反映
              // del #11004 連携イベント発生部分不正 piao start
              // if("U".equals(crud)){
              //
              //   JournalCreateRequestPayload journalCreateRequestPayloadDelete = null;
              //   journalCreateRequestPayloadDelete = new JournalCreateRequestPayload();
              //   journalCreateRequestPayloadDelete.setFacilityCd(ordMain.getFacilityCd());
              //   journalCreateRequestPayloadDelete.setCrud("D");
              //   journalCreateRequestPayloadDelete.setPatId(patId);
              //   journalCreateRequestPayloadDelete.setHospPatId(hospPatId);
              //   journalCreateRequestPayloadDelete.setUserId(updId);
              //   journalCreateRequestPayloadDelete.setOpeCd(OPECDENUM.getOpeIdByCrudTablenameOption(tablePhysicalName, crud, action));
              //   journalCreateRequestPayloadDelete.setOrdNo(ordMain.getOrdNo());
              //   journalCreateRequestPayloadDelete.setBaseDate(ordMain.getTreatDate());
              //
              //   switch (modify_send_class){
              //     case 1:
              //       if (changeMode != null && changeMode.contains("SCHEDULE_")) {
              //         journalList.add(journalCreateRequestPayloadDelete);
              //         journalCreateRequestPayload.setCrud("C");
              //       }
              //       break;
              //     case 2:
              //       if(changeMode != null &&
              //         (changeMode.contains("SCHEDULE_") || changeMode.contains("COND_") ||
              //           changeMode.contains("MEDI_") || changeMode.contains("EQUIP_") || changeMode.contains("COMMENT_") ||
              //           changeMode.contains("TARE_") || changeMode.contains("OFFWATER_"))){
              //         journalList.add(journalCreateRequestPayloadDelete);
              //         journalCreateRequestPayload.setCrud("C");
              //       }
              //       break;
              //     case 0:
              //     default:
              //       break;
              //   }
              // }
              // del #11004 連携イベント発生部分不正 piao end

              break;
            case "pat_exam_main":
              patExamMain = (PatExamMain)value;

              if("1".equals(patExamMain.getPhyOrdClass())){
                option = "PHY_" + option;
              }
              changeMode = this.getChangeModeForActionMode(actionMode);
              action = option + "_" + changeMode;

              journalCreateRequestPayload.setFacilityCd(patExamMain.getFacilityCd());
              if("1".equals(patExamMain.getIsDel())){
                crud = "D";
              } else if(Objects.equals(patExamMain.getUpDate(), patExamMain.getRegDate())){
                crud = "C";
              } else {
                crud = "U";
              }
              journalCreateRequestPayload.setCrud(crud);

              patId = patExamMain.getPatId();
              hospPatId = patPersonalMainListMap.get(patId);

              journalCreateRequestPayload.setPatId(patId);
              journalCreateRequestPayload.setHospPatId(hospPatId);
              journalCreateRequestPayload.setUserId(updId);
              journalCreateRequestPayload.setOpeCd(OPECDENUM.getOpeIdByCrudTablenameOption(tablePhysicalName, crud, action));
              journalCreateRequestPayload.setOrdNo(patExamMain.getExamMainCd());
              journalCreateRequestPayload.setBaseDate(sdf.format(patExamMain.getRegExamDate()));

              // 治療予定が削除　または　クールが指定→未登録へ　変更した場合、発行すべきDイベント除外キーのリスト
              if("D".equals(crud)){
                this.addToBeDEventExcludeExamKey(journalEventLinkByPatListMap, facilityCd, patId, hospPatId, patExamMain.getExamMainCd());
              }
              // 治療予定が登録　または　クールが未登録→指定へ　変更した場合、発行すべきCイベント除外キーのリスト
              if("C".equals(crud)){
                this.addToBeCEventExcludeExamKey(journalEventLinkByPatListMap, facilityCd, patId, hospPatId, patExamMain.getExamMainCd());
              }
              // 治療予定が　変更した場合、発行すべきCイベント除外キーのリスト
              if("U".equals(crud)){
                this.addToBeUEventExcludeExamKey(journalEventLinkByPatListMap, facilityCd, patId, hospPatId, patExamMain.getExamMainCd());
              }
              break;
            case "pat_rad_main":
              patRadMain = (PatRadMain)value;

              changeMode = this.getChangeModeForActionMode(actionMode);
              action = option + "_" + changeMode;

              journalCreateRequestPayload.setFacilityCd(patRadMain.getFacilityCd());
              if("1".equals(patRadMain.getIsDel())){
                crud = "D";
              } else if(Objects.equals(patRadMain.getUpDate(), patRadMain.getRegDate())){
                crud = "C";
              } else {
                crud = "U";
              }
              journalCreateRequestPayload.setCrud(crud);

              patId = patRadMain.getPatId();
              hospPatId = patPersonalMainListMap.get(patId);

              journalCreateRequestPayload.setPatId(patId);
              journalCreateRequestPayload.setHospPatId(hospPatId);
              journalCreateRequestPayload.setUserId(updId);
              journalCreateRequestPayload.setOpeCd(OPECDENUM.getOpeIdByCrudTablenameOption(tablePhysicalName, crud, action));
              journalCreateRequestPayload.setOrdNo(patRadMain.getRadResultCd());
              journalCreateRequestPayload.setBaseDate(sdf.format(patRadMain.getRegRadDate()));

              // 治療予定が削除　または　クールが指定→未登録へ　変更した場合、発行すべきDイベント除外キーのリスト
              if("D".equals(crud)){
                this.addToBeDEventExcludeRadKey(journalEventLinkByPatListMap, facilityCd, patId, hospPatId, patRadMain.getRadResultCd());
              }
              // 治療予定が登録　または　クールが未登録→指定へ　変更した場合、発行すべきCイベント除外キーのリスト
              if("C".equals(crud)){
                this.addToBeCEventExcludeRadKey(journalEventLinkByPatListMap, facilityCd, patId, hospPatId, patRadMain.getRadResultCd());
              }
              // 治療予定が　変更した場合、発行すべきCイベント除外キーのリスト
              if("U".equals(crud)){
                this.addToBeUEventExcludeRadKey(journalEventLinkByPatListMap, facilityCd, patId, hospPatId, patRadMain.getRadResultCd());
              }
              break;
            case "ord_prescription":
              ordPrescription = (OrdPrescription)value;
              journalCreateRequestPayload.setFacilityCd(ordPrescription.getFacilityCd());
              if("1".equals(ordPrescription.getIsDel())){
                crud = "D";
              } else if(Objects.equals(ordPrescription.getUpDate(), ordPrescription.getRegDate())){
                crud = "C";
              } else {
                crud = "U";
              }
              journalCreateRequestPayload.setCrud(crud);
              patId = ordPrescription.getPatId();
              journalCreateRequestPayload.setPatId(patId);
              journalCreateRequestPayload.setHospPatId(patPersonalMainListMap.get(patId));
              journalCreateRequestPayload.setUserId(updId);
              journalCreateRequestPayload.setOpeCd(OPECDENUM.getOpeIdByCrudTablenameOption(tablePhysicalName, crud, option));
              journalCreateRequestPayload.setOrdNo(ordPrescription.getOrdPrescriptionNo());
              journalCreateRequestPayload.setBaseDate(ordPrescription.getIssueDate());
              break;
            case "pat_main":
              patMain = (PatMain)value;
              LocalDateTime nowDate = LocalDateTime.now();
              DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("yyyyMMdd");
              String today = nowDate.format(dateTimeFormatter);
              crud = "U";
              journalCreateRequestPayload.setOpeCd(OPECDENUM.getOpeIdByCrudTablenameOption(tablePhysicalName, crud, option));
              journalCreateRequestPayload.setCrud(crud);
              journalCreateRequestPayload.setFacilityCd(facilityCd);
              journalCreateRequestPayload.setHospPatId(patPersonalMainListMap.get(patId));
              journalCreateRequestPayload.setPatId(patId);
              journalCreateRequestPayload.setBaseDate(today);
              journalCreateRequestPayload.setUserId(updId);
              break;
            default:
              // 連携対象外Tables
              break;
          }
          if (tablesToProcess.contains(tablePhysicalName)) {
            if(journalCreateRequestPayload != null){
              journalList.add(journalCreateRequestPayload);
            }
          }
        }
      }
    }

    // 物理削除の判定
    if(resultAllChangeBeforeDataInfoList != null){
      // Define table priority map
      Map<String, Integer> tablePriorityMap = new HashMap<>();
      tablePriorityMap.put("ord_main", 1);
      tablePriorityMap.put("pat_exam_main", 2);
      tablePriorityMap.put("pat_rad_main", 3);
      tablePriorityMap.put("ord_prescription", 4);
      // Add more tables and their priorities as needed

      // Sort entries by table priority
      List<Map.Entry<String, List<Object>>> sortedEntries = resultAllChangeBeforeDataInfoList.entrySet().stream()
        .sorted((e1, e2) -> {
          int p1 = tablePriorityMap.getOrDefault(e1.getKey(), Integer.MAX_VALUE);
          int p2 = tablePriorityMap.getOrDefault(e2.getKey(), Integer.MAX_VALUE);
          return Integer.compare(p1, p2);
        })
        .collect(Collectors.toList());
      for (Map.Entry<String, List<Object>> entry : sortedEntries) {
        String tablePhysicalName = entry.getKey(); // テーブル名

        List<Object> values = entry.getValue(); // レコード
        List<Long> keyList = new ArrayList<>();
        if(resultAllChangedDataInfoList != null){
          List<Object> afterRecords = resultAllChangedDataInfoList.getOrDefault(tablePhysicalName, Collections.emptyList());
          switch (tablePhysicalName){
            case "ord_main":
              keyList = afterRecords.stream().filter(OrdMain.class::isInstance).map(OrdMain.class::cast).map(OrdMain::getOrdNo).collect(Collectors.toList());
              break;
            case "pat_exam_main":
              keyList = afterRecords.stream().filter(PatExamMain.class::isInstance).map(PatExamMain.class::cast).map(PatExamMain::getExamMainCd).collect(Collectors.toList());
              break;
            case "pat_rad_main":
              keyList = afterRecords.stream().filter(PatRadMain.class::isInstance).map(PatRadMain.class::cast).map(PatRadMain::getRadResultCd).collect(Collectors.toList());
              break;
            case "ord_prescription":
              keyList = afterRecords.stream().filter(OrdPrescription.class::isInstance).map(OrdPrescription.class::cast).map(OrdPrescription::getOrdPrescriptionNo).collect(Collectors.toList());
              break;
            default:
              // 連携対象外Tables
              break;
          }
        }

        for (Object value : values) {
          option = actionMode;
          String changeMode = null;
          String action = null;

          JournalCreateRequestPayload journalCreateRequestPayload = new JournalCreateRequestPayload();
          journalCreateRequestPayload.setFacilityCd(facilityCd);

          OrdMain ordMain = null;
          PatExamMain patExamMain = null;
          PatRadMain patRadMain = null;
          OrdPrescription ordPrescription = null;
          String crud = null;
          Long patId = 0L;
          switch (tablePhysicalName){
            case "ord_main":
              ordMain = (OrdMain)value;
              if (keyList == null || !keyList.contains(ordMain.getOrdNo())) {
                changeMode = this.getChangeMode(ordMain, null);
                action = option + "_" + changeMode;

                crud = "D";
                patId = ordMain.getPatId();
                String hospPatId = patPersonalMainListMap.get(patId);
                journalCreateRequestPayload = this.makeJournalCreateRequestPayload(ordMain.getFacilityCd(), crud, patId, hospPatId, updId,
                  OPECDENUM.getOpeIdByCrudTablenameOption(tablePhysicalName, crud, action),
                  ordMain.getOrdNo(), ordMain.getTreatDate());
                journalList.add(journalCreateRequestPayload);
                if(ordMain.getIndKurCd() !=0){
                  // 治療予定が削除　または　クールが指定→未登録へ　変更した場合、発行すべきDイベント治療日のリスト
                  this.addToBeDEventTreatDate(journalEventLinkByPatListMap, facilityCd, patId, hospPatId, ordMain.getTreatDate(), ordMain.getIndKurCd());
                }
              }
              break;
            case "pat_exam_main":
              patExamMain = (PatExamMain)value;

              changeMode = this.getChangeModeForActionMode(actionMode);

              if (keyList == null || !keyList.contains(patExamMain.getExamMainCd())) {
                crud = "D";
                patId = patExamMain.getPatId();
                String hospPatId = patPersonalMainListMap.get(patId);
                if("1".equals(patExamMain.getPhyOrdClass())){
                  option = "PHY_" + option;
                }
                action = option + "_" + changeMode;

                journalCreateRequestPayload = this.makeJournalCreateRequestPayload(patExamMain.getFacilityCd(), crud, patId, hospPatId, updId,
                  OPECDENUM.getOpeIdByCrudTablenameOption(tablePhysicalName, crud, action),
                  patExamMain.getExamMainCd(), sdf.format(patExamMain.getRegExamDate()));
                journalList.add(journalCreateRequestPayload);

                // 治療予定が削除　または　クールが指定→未登録へ　変更した場合、発行すべきDイベント除外キーのリスト
                if("D".equals(crud)){
                  this.addToBeDEventExcludeExamKey(journalEventLinkByPatListMap, facilityCd, patId, hospPatId, patExamMain.getExamMainCd());
                }
              }
              break;
            case "pat_rad_main":
              patRadMain = (PatRadMain)value;

              changeMode = this.getChangeModeForActionMode(actionMode);
              action = option + "_" + changeMode;

              if (keyList == null || !keyList.contains(patRadMain.getRadResultCd())) {
                crud = "D";
                patId = patRadMain.getPatId();
                journalCreateRequestPayload.setPatId(patId);
                String hospPatId = patPersonalMainListMap.get(patId);

                journalCreateRequestPayload = this.makeJournalCreateRequestPayload(patRadMain.getFacilityCd(), crud, patId, hospPatId, updId,
                  OPECDENUM.getOpeIdByCrudTablenameOption(tablePhysicalName, crud, action),
                  patRadMain.getRadResultCd(), sdf.format(patRadMain.getRegRadDate()));
                journalList.add(journalCreateRequestPayload);

                // 治療予定が削除　または　クールが指定→未登録へ　変更した場合、発行すべきDイベント除外キーのリスト
                if("D".equals(crud)){
                  this.addToBeDEventExcludeRadKey(journalEventLinkByPatListMap, facilityCd, patId, hospPatId, patRadMain.getRadResultCd());
                }
              }
              break;
            case "ord_prescription":
              ordPrescription = (OrdPrescription)value;

              changeMode = this.getChangeModeForActionMode(actionMode);
              action = option + "_" + changeMode;

              if (keyList == null || !keyList.contains(ordPrescription.getOrdPrescriptionNo())) {
                crud = "D";
                patId = ordPrescription.getPatId();
                String hospPatId = patPersonalMainListMap.get(patId);

                journalCreateRequestPayload = this.makeJournalCreateRequestPayload(ordPrescription.getFacilityCd(), crud, patId, hospPatId, updId,
                  OPECDENUM.getOpeIdByCrudTablenameOption(tablePhysicalName, crud, action),
                  ordPrescription.getOrdPrescriptionNo(), ordPrescription.getIssueDate());
                journalList.add(journalCreateRequestPayload);
              }
              break;
            default:
              // 連携対象外Tables
              break;
          }
        }
      }
    }
    //
    journalList.addAll(this.createJournalPayloadForToBeEventTreatDate(journalEventLinkByPatListMap, updId, actionMode));

    journalList = journalList.stream().filter(o -> o.getOpeCd() != null).collect(Collectors.toList());
    return journalList;
  }
  @Override
  public void addToBeDEventTreatDate(Map<String, JournalEventLinkByPat> journalEventLinkByPatListMap,
                                     String facilityCd, Long patId, String hospPatId, String treatDate, Integer indKurCd){
    String uniqueKey = facilityCd + patId.toString();
    JournalEventLinkByPat journalEventLinkByPat = journalEventLinkByPatListMap.get(uniqueKey);
    if(journalEventLinkByPat == null){
      journalEventLinkByPat = new JournalEventLinkByPat();
      journalEventLinkByPat.setFacilityCd(facilityCd);
      journalEventLinkByPat.setPatId(patId);
      journalEventLinkByPat.setHospPatId(hospPatId);
      journalEventLinkByPatListMap.put(uniqueKey, journalEventLinkByPat);
    }
    journalEventLinkByPat.getToBeDEventTreatDateList().add(treatDate);
    journalEventLinkByPat.getToBeDEventTreatDateKurList().add(indKurCd);
  }
  @Override
  public void addToBeDEventExcludeExamKey(Map<String, JournalEventLinkByPat> journalEventLinkByPatListMap,
                                     String facilityCd, Long patId, String hospPatId, Long examMainCd){
    String uniqueKey = facilityCd + patId.toString();
    JournalEventLinkByPat journalEventLinkByPat = journalEventLinkByPatListMap.get(uniqueKey);
    if(journalEventLinkByPat == null){
      journalEventLinkByPat = new JournalEventLinkByPat();
      journalEventLinkByPat.setFacilityCd(facilityCd);
      journalEventLinkByPat.setPatId(patId);
      journalEventLinkByPat.setHospPatId(hospPatId);
      journalEventLinkByPatListMap.put(uniqueKey, journalEventLinkByPat);
    }
    journalEventLinkByPat.getToBeDEventExcludeExamKeyList().add(examMainCd);
  }
  @Override
  public void addToBeDEventExcludeRadKey(Map<String, JournalEventLinkByPat> journalEventLinkByPatListMap,
                                          String facilityCd, Long patId, String hospPatId, Long radResultCd){
    String uniqueKey = facilityCd + patId.toString();
    JournalEventLinkByPat journalEventLinkByPat = journalEventLinkByPatListMap.get(uniqueKey);
    if(journalEventLinkByPat == null){
      journalEventLinkByPat = new JournalEventLinkByPat();
      journalEventLinkByPat.setFacilityCd(facilityCd);
      journalEventLinkByPat.setPatId(patId);
      journalEventLinkByPat.setHospPatId(hospPatId);
      journalEventLinkByPatListMap.put(uniqueKey, journalEventLinkByPat);
    }
    journalEventLinkByPat.getToBeDEventExcludeRadKeyList().add(radResultCd);
  }
  @Override
  public void addToBeCEventTreatDate(Map<String, JournalEventLinkByPat> journalEventLinkByPatListMap,
                                     String facilityCd, Long patId, String hospPatId, String treatDate, Integer indKurCd){
    String uniqueKey = facilityCd + patId.toString();
    JournalEventLinkByPat journalEventLinkByPat = journalEventLinkByPatListMap.get(uniqueKey);
    if(journalEventLinkByPat == null){
      journalEventLinkByPat = new JournalEventLinkByPat();
      journalEventLinkByPat.setFacilityCd(facilityCd);
      journalEventLinkByPat.setPatId(patId);
      journalEventLinkByPat.setHospPatId(hospPatId);
      journalEventLinkByPatListMap.put(uniqueKey, journalEventLinkByPat);
    }
    journalEventLinkByPat.getToBeCEventTreatDateList().add(treatDate);
    journalEventLinkByPat.getToBeCEventTreatDateKurList().add(indKurCd);
  }
  @Override
  public void addToBeCEventExcludeExamKey(Map<String, JournalEventLinkByPat> journalEventLinkByPatListMap,
                                          String facilityCd, Long patId, String hospPatId, Long examMainCd){
    String uniqueKey = facilityCd + patId.toString();
    JournalEventLinkByPat journalEventLinkByPat = journalEventLinkByPatListMap.get(uniqueKey);
    if(journalEventLinkByPat == null){
      journalEventLinkByPat = new JournalEventLinkByPat();
      journalEventLinkByPat.setFacilityCd(facilityCd);
      journalEventLinkByPat.setPatId(patId);
      journalEventLinkByPat.setHospPatId(hospPatId);
      journalEventLinkByPatListMap.put(uniqueKey, journalEventLinkByPat);
    }
    journalEventLinkByPat.getToBeCEventExcludeExamKeyList().add(examMainCd);
  }
  @Override
  public void addToBeCEventExcludeRadKey(Map<String, JournalEventLinkByPat> journalEventLinkByPatListMap,
                                         String facilityCd, Long patId, String hospPatId, Long radResultCd){
    String uniqueKey = facilityCd + patId.toString();
    JournalEventLinkByPat journalEventLinkByPat = journalEventLinkByPatListMap.get(uniqueKey);
    if(journalEventLinkByPat == null){
      journalEventLinkByPat = new JournalEventLinkByPat();
      journalEventLinkByPat.setFacilityCd(facilityCd);
      journalEventLinkByPat.setPatId(patId);
      journalEventLinkByPat.setHospPatId(hospPatId);
      journalEventLinkByPatListMap.put(uniqueKey, journalEventLinkByPat);
    }
    journalEventLinkByPat.getToBeCEventExcludeRadKeyList().add(radResultCd);
  }
  @Override
  public void addToBeUEventTreatDate(Map<String, JournalEventLinkByPat> journalEventLinkByPatListMap,
                                     String facilityCd, Long patId, String hospPatId, String treatDate, Integer indKurCd){
    String uniqueKey = facilityCd + patId.toString();
    JournalEventLinkByPat journalEventLinkByPat = journalEventLinkByPatListMap.get(uniqueKey);
    if(journalEventLinkByPat == null){
      journalEventLinkByPat = new JournalEventLinkByPat();
      journalEventLinkByPat.setFacilityCd(facilityCd);
      journalEventLinkByPat.setPatId(patId);
      journalEventLinkByPat.setHospPatId(hospPatId);
      journalEventLinkByPatListMap.put(uniqueKey, journalEventLinkByPat);
    }
    journalEventLinkByPat.getToBeUEventTreatDateList().add(treatDate);
    journalEventLinkByPat.getToBeUEventTreatDateKurList().add(indKurCd);
  }
  @Override
  public void addToBeUEventExcludeExamKey(Map<String, JournalEventLinkByPat> journalEventLinkByPatListMap,
                                          String facilityCd, Long patId, String hospPatId, Long examMainCd){
    String uniqueKey = facilityCd + patId.toString();
    JournalEventLinkByPat journalEventLinkByPat = journalEventLinkByPatListMap.get(uniqueKey);
    if(journalEventLinkByPat == null){
      journalEventLinkByPat = new JournalEventLinkByPat();
      journalEventLinkByPat.setFacilityCd(facilityCd);
      journalEventLinkByPat.setPatId(patId);
      journalEventLinkByPat.setHospPatId(hospPatId);
      journalEventLinkByPatListMap.put(uniqueKey, journalEventLinkByPat);
    }
    journalEventLinkByPat.getToBeUEventExcludeExamKeyList().add(examMainCd);
  }
  @Override
  public void addToBeUEventExcludeRadKey(Map<String, JournalEventLinkByPat> journalEventLinkByPatListMap,
                                         String facilityCd, Long patId, String hospPatId, Long radResultCd){
    String uniqueKey = facilityCd + patId.toString();
    JournalEventLinkByPat journalEventLinkByPat = journalEventLinkByPatListMap.get(uniqueKey);
    if(journalEventLinkByPat == null){
      journalEventLinkByPat = new JournalEventLinkByPat();
      journalEventLinkByPat.setFacilityCd(facilityCd);
      journalEventLinkByPat.setPatId(patId);
      journalEventLinkByPat.setHospPatId(hospPatId);
      journalEventLinkByPatListMap.put(uniqueKey, journalEventLinkByPat);
    }
    journalEventLinkByPat.getToBeUEventExcludeRadKeyList().add(radResultCd);
  }
  @Override
  public List<JournalCreateRequestPayload> createJournalPayloadForToBeEventTreatDate(Map<String, JournalEventLinkByPat> journalEventLinkByPatListMap, Long updId, String actionMode){
    String option = actionMode + "_LINKED";
    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
    List<JournalCreateRequestPayload> journalCreateRequestPayloadList = new ArrayList<>();
    for (Map.Entry<String, JournalEventLinkByPat> entry : journalEventLinkByPatListMap.entrySet()) {
      String uniqueKey = entry.getKey(); // Map用Key
      JournalEventLinkByPat journalEventLinkByPat = entry.getValue(); // レコード
      List<PatExamMain> patExamMainList =  new ArrayList<>();
      List<PatRadMain> patRadMainList =  new ArrayList<>();
      //
      List<String> toBeDEventTreatDateList = journalEventLinkByPat.getToBeDEventTreatDateList();
      List<String> toBeCEventTreatDateList = journalEventLinkByPat.getToBeCEventTreatDateList();
      List<String> toBeUEventTreatDateList = journalEventLinkByPat.getToBeUEventTreatDateList();
      List<Integer> toBeDEventTreatDateKurList = journalEventLinkByPat.getToBeDEventTreatDateKurList();
      List<Integer> toBeCEventTreatDateKurList = journalEventLinkByPat.getToBeCEventTreatDateKurList();

      Map<String, Integer> treatDateKurMapD = new HashMap<>();
      for (int i = 0; i < toBeDEventTreatDateList.size(); i++) {
        treatDateKurMapD.put(toBeDEventTreatDateList.get(i), toBeDEventTreatDateKurList.get(i));
      }
      Map<String, Integer> treatDateKurMapC = new HashMap<>();
      for (int i = 0; i < toBeCEventTreatDateList.size(); i++) {
        treatDateKurMapC.put(toBeCEventTreatDateList.get(i), toBeCEventTreatDateKurList.get(i));
      }

      Set<String> toBeDEventTreatDateSet = new HashSet<>(toBeDEventTreatDateList);
      Set<String> toBeCEventTreatDateSet = new HashSet<>(toBeCEventTreatDateList);

      toBeCEventTreatDateSet.retainAll(toBeDEventTreatDateSet);

      List<String> retainAllList = new ArrayList<>(toBeCEventTreatDateSet);

      // toBeDEventTreatDateListを更新
      toBeDEventTreatDateList.removeAll(retainAllList);
      // toBeCEventTreatDateListを更新
      toBeCEventTreatDateList.removeAll(retainAllList);
      // toBeUEventTreatDateListを更新
      for (String retain : retainAllList) {
        if (!treatDateKurMapD.get(retain).equals(treatDateKurMapC.get(retain)) && !toBeUEventTreatDateList.contains(retain)) {
          toBeUEventTreatDateList.add(retain);
        }
      }

      // D Event
      if(toBeDEventTreatDateList != null && !toBeDEventTreatDateList.isEmpty()){
        // mod #11203 1日に複数回治療予定が存在する場合のexam_ordの削除イベント発行の動作不正 zrx start
//        patExamMainList = patExamMainDao.selectPatExamMainByDateListAndExcludeKeyList(journalEventLinkByPat.getFacilityCd(),journalEventLinkByPat.getPatId(), toBeDEventTreatDateList, journalEventLinkByPat.getToBeDEventExcludeExamKeyList());
        patExamMainList = patExamMainDao.selectPatExamMainByDateListAndExcludeKeyListD(journalEventLinkByPat.getFacilityCd(),journalEventLinkByPat.getPatId(), toBeDEventTreatDateList, journalEventLinkByPat.getToBeDEventExcludeExamKeyList());
        // mod #11203 1日に複数回治療予定が存在する場合のexam_ordの削除イベント発行の動作不正 zrx end
        if(patExamMainList != null && !patExamMainList.isEmpty()){
          for(PatExamMain patExamMain : patExamMainList){
            if ("0".equals(patExamMain.getRegOrderClass())) {
              continue;
            }
            option = actionMode + "_LINKED";
            if("1".equals(patExamMain.getPhyOrdClass())){
              option = "PHY_" + option;
            }
            JournalCreateRequestPayload journalCreateRequestPayload = this.makeJournalCreateRequestPayload(journalEventLinkByPat.getFacilityCd(), "D", journalEventLinkByPat.getPatId(), journalEventLinkByPat.getHospPatId(), updId,
              OPECDENUM.getOpeIdByCrudTablenameOption("pat_exam_main", "D",  option + "_D"),
              patExamMain.getExamMainCd(), sdf.format(patExamMain.getRegExamDate()));
            journalCreateRequestPayloadList.add(journalCreateRequestPayload);
          }
        }
        // add #11203 1日に複数回治療予定が存在する場合のexam_ordの削除イベント発行の動作不正 zrx start
        List<PatExamMain> patExamMainListCOrD = patExamMainDao.selectPatExamMainByDateListAndExcludeKeyListCOrU(journalEventLinkByPat.getFacilityCd(),journalEventLinkByPat.getPatId(), toBeDEventTreatDateList, journalEventLinkByPat.getToBeDEventExcludeExamKeyList());
        if(patExamMainListCOrD != null && !patExamMainListCOrD.isEmpty()){
          for(PatExamMain patExamMain : patExamMainListCOrD){
            if ("0".equals(patExamMain.getRegOrderClass())) {
              continue;
            }
            option = actionMode + "_LINKED";
            if("1".equals(patExamMain.getPhyOrdClass())){
              option = "PHY_" + option;
            }
            JournalCreateRequestPayload journalCreateRequestPayload = this.makeJournalCreateRequestPayload(journalEventLinkByPat.getFacilityCd(), "U", journalEventLinkByPat.getPatId(), journalEventLinkByPat.getHospPatId(), updId,
              OPECDENUM.getOpeIdByCrudTablenameOption("pat_exam_main", "U",  option + "_U"),
              patExamMain.getExamMainCd(), sdf.format(patExamMain.getRegExamDate()));
            journalCreateRequestPayloadList.add(journalCreateRequestPayload);
          }
        }
        // add #11203 1日に複数回治療予定が存在する場合のexam_ordの削除イベント発行の動作不正 zrx end
        // mod #11203 1日に複数回治療予定が存在する場合のexam_ordの削除イベント発行の動作不正 zrx start
//        patRadMainList = patRadMainDao.selectPatRadMainByDateListAndExcludeKeyList(journalEventLinkByPat.getFacilityCd(),journalEventLinkByPat.getPatId(), toBeDEventTreatDateList, journalEventLinkByPat.getToBeCEventExcludeRadKeyList());
        patRadMainList = patRadMainDao.selectPatRadMainByDateListAndExcludeKeyListD(journalEventLinkByPat.getFacilityCd(),journalEventLinkByPat.getPatId(), toBeDEventTreatDateList, journalEventLinkByPat.getToBeCEventExcludeRadKeyList());
        // mod #11203 1日に複数回治療予定が存在する場合のexam_ordの削除イベント発行の動作不正 zrx end
        if(patRadMainList != null && !patRadMainList.isEmpty()){
          for(PatRadMain patRadMain : patRadMainList){
            option = actionMode + "_LINKED";
            JournalCreateRequestPayload journalCreateRequestPayload = this.makeJournalCreateRequestPayload(journalEventLinkByPat.getFacilityCd(), "D", journalEventLinkByPat.getPatId(), journalEventLinkByPat.getHospPatId(), updId,
              OPECDENUM.getOpeIdByCrudTablenameOption("pat_rad_main", "D", option + "_D"),
              patRadMain.getRadResultCd(), sdf.format(patRadMain.getRegRadDate()));
            journalCreateRequestPayloadList.add(journalCreateRequestPayload);
          }
        }
        // add #11203 1日に複数回治療予定が存在する場合のexam_ordの削除イベント発行の動作不正 zrx start
        List<PatRadMain> patRadMainListCOrU = patRadMainDao.selectPatRadMainByDateListAndExcludeKeyListCOrU(journalEventLinkByPat.getFacilityCd(),journalEventLinkByPat.getPatId(), toBeDEventTreatDateList, journalEventLinkByPat.getToBeCEventExcludeRadKeyList());
        if(patRadMainListCOrU != null && !patRadMainListCOrU.isEmpty()){
          for(PatRadMain patRadMain : patRadMainListCOrU){
            option = actionMode + "_LINKED";
            JournalCreateRequestPayload journalCreateRequestPayload = this.makeJournalCreateRequestPayload(journalEventLinkByPat.getFacilityCd(), "U", journalEventLinkByPat.getPatId(), journalEventLinkByPat.getHospPatId(), updId,
              OPECDENUM.getOpeIdByCrudTablenameOption("pat_rad_main", "U", option + "_U"),
              patRadMain.getRadResultCd(), sdf.format(patRadMain.getRegRadDate()));
            journalCreateRequestPayloadList.add(journalCreateRequestPayload);
          }
        }
        // add #11203 1日に複数回治療予定が存在する場合のexam_ordの削除イベント発行の動作不正 zrx end
      }
      // C Event
      if(toBeCEventTreatDateList !=null && !toBeCEventTreatDateList.isEmpty()){
        List<Long> examToCUEventExcludeExamKeyList = new ArrayList<>();
        examToCUEventExcludeExamKeyList.addAll(journalEventLinkByPat.getToBeCEventExcludeExamKeyList());
        examToCUEventExcludeExamKeyList.addAll(journalEventLinkByPat.getToBeUEventExcludeExamKeyList());
        patExamMainList = patExamMainDao.selectPatExamMainByDateListAndExcludeKeyList(journalEventLinkByPat.getFacilityCd(),journalEventLinkByPat.getPatId(), toBeCEventTreatDateList, examToCUEventExcludeExamKeyList);
        if(patExamMainList != null && !patExamMainList.isEmpty()){
          for(PatExamMain patExamMain : patExamMainList){
            if ("0".equals(patExamMain.getRegOrderClass())) {
              continue;
            }
            option = actionMode + "_LINKED";
            if("1".equals(patExamMain.getPhyOrdClass())){
              option = "PHY_" + option;
            }
            JournalCreateRequestPayload journalCreateRequestPayload = this.makeJournalCreateRequestPayload(journalEventLinkByPat.getFacilityCd(), "C", journalEventLinkByPat.getPatId(), journalEventLinkByPat.getHospPatId(), updId,
              OPECDENUM.getOpeIdByCrudTablenameOption("pat_exam_main", "C", option + "_C"),
              patExamMain.getExamMainCd(), sdf.format(patExamMain.getRegExamDate()));
            journalCreateRequestPayloadList.add(journalCreateRequestPayload);
          }
        }
        patRadMainList = patRadMainDao.selectPatRadMainByDateListAndExcludeKeyList(journalEventLinkByPat.getFacilityCd(),journalEventLinkByPat.getPatId(), toBeCEventTreatDateList, journalEventLinkByPat.getToBeCEventExcludeRadKeyList());
        if(patRadMainList != null && !patRadMainList.isEmpty()){
          for(PatRadMain patRadMain : patRadMainList){
            option = actionMode + "_LINKED";
            JournalCreateRequestPayload journalCreateRequestPayload = this.makeJournalCreateRequestPayload(journalEventLinkByPat.getFacilityCd(), "C", journalEventLinkByPat.getPatId(), journalEventLinkByPat.getHospPatId(), updId,
              OPECDENUM.getOpeIdByCrudTablenameOption("pat_rad_main", "C", option + "_C"),
              patRadMain.getRadResultCd(), sdf.format(patRadMain.getRegRadDate()));
            journalCreateRequestPayloadList.add(journalCreateRequestPayload);
          }
        }
      }
      // U Event
      if(toBeUEventTreatDateList != null && !toBeUEventTreatDateList.isEmpty()){
        patExamMainList = patExamMainDao.selectPatExamMainByDateListAndExcludeKeyList(journalEventLinkByPat.getFacilityCd(),journalEventLinkByPat.getPatId(), toBeUEventTreatDateList, journalEventLinkByPat.getToBeCEventExcludeExamKeyList());
        if(patExamMainList != null && !patExamMainList.isEmpty()){
          for(PatExamMain patExamMain : patExamMainList){
            if ("0".equals(patExamMain.getRegOrderClass())) {
              continue;
            }
            option = actionMode + "_LINKED";
            if("1".equals(patExamMain.getPhyOrdClass())){
              option = "PHY_" + option;
            }
            JournalCreateRequestPayload journalCreateRequestPayload = this.makeJournalCreateRequestPayload(journalEventLinkByPat.getFacilityCd(), "U", journalEventLinkByPat.getPatId(), journalEventLinkByPat.getHospPatId(), updId,
              OPECDENUM.getOpeIdByCrudTablenameOption("pat_exam_main", "U", option + "_U"),
              patExamMain.getExamMainCd(), sdf.format(patExamMain.getRegExamDate()));
            journalCreateRequestPayloadList.add(journalCreateRequestPayload);
          }
        }
        patRadMainList = patRadMainDao.selectPatRadMainByDateListAndExcludeKeyList(journalEventLinkByPat.getFacilityCd(),journalEventLinkByPat.getPatId(), toBeUEventTreatDateList, journalEventLinkByPat.getToBeCEventExcludeRadKeyList());
        if(patRadMainList != null && !patRadMainList.isEmpty()){
          for(PatRadMain patRadMain : patRadMainList){
            option = actionMode + "_LINKED";
            JournalCreateRequestPayload journalCreateRequestPayload = this.makeJournalCreateRequestPayload(journalEventLinkByPat.getFacilityCd(), "U", journalEventLinkByPat.getPatId(), journalEventLinkByPat.getHospPatId(), updId,
              OPECDENUM.getOpeIdByCrudTablenameOption("pat_rad_main", "U", option + "_U"),
              patRadMain.getRadResultCd(), sdf.format(patRadMain.getRegRadDate()));
            journalCreateRequestPayloadList.add(journalCreateRequestPayload);
          }
        }
      }
    }
    return journalCreateRequestPayloadList;
  }

  private JournalCreateRequestPayload makeJournalCreateRequestPayload(String facilityCd, String crud, Long patId, String hospPatId, Long userId, String opeCd, Long ordNo, String baseDate){
    JournalCreateRequestPayload journalCreateRequestPayload = new JournalCreateRequestPayload();
    journalCreateRequestPayload.setFacilityCd(facilityCd);
    journalCreateRequestPayload.setCrud(crud);
    journalCreateRequestPayload.setPatId(patId);
    journalCreateRequestPayload.setHospPatId(hospPatId);
    journalCreateRequestPayload.setUserId(userId);
    journalCreateRequestPayload.setOpeCd(opeCd);
    journalCreateRequestPayload.setOrdNo(ordNo);
    journalCreateRequestPayload.setBaseDate(baseDate);
    return journalCreateRequestPayload;
  }

  @Override
  public List<JournalCreateRequestPayload> createJournalPayloadForOrdPrescription(String facilityCd,
                                                                                  List<OrdPrescription> ordRps,
                                                                                  List<OrdPrescription> ordRpsBeforeData,
                                                                                  List<Long> patIdList, Long updId, String actionMode){
    List<JournalCreateRequestPayload> journalList = new ArrayList<>();
    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");

    List<PatPersonalMain> patPersonalMainList = patPersonalMainDao.selectPatPersonalMainForHospPatIdListByPatIdList(facilityCd, patIdList);
    Map<Long, String> patPersonalMainListMap = patPersonalMainList.stream().collect(Collectors.toMap(PatPersonalMain::getPat_id, PatPersonalMain::getHosp_pat_id));

    String option = actionMode;
//    int modify_send_class = treatmentRecordService.getCoopIniSchModifySendClass(facilityCd);
    String tablePhysicalName = "ord_prescription"; // テーブル名
    for(OrdPrescription ordRp : ordRps){

      JournalCreateRequestPayload journalCreateRequestPayload = new JournalCreateRequestPayload();
      journalCreateRequestPayload.setFacilityCd(facilityCd);

      OrdPrescription ordPrescription = null;
      String crud = null;
      Long patId = 0L;
      switch (tablePhysicalName){
        case "ord_prescription":
          ordPrescription = (OrdPrescription)ordRp;
          journalCreateRequestPayload.setFacilityCd(ordPrescription.getFacilityCd());
          if("1".equals(ordPrescription.getIsDel())){
            crud = "D";
          } else if(Objects.equals(ordPrescription.getUpDate(), ordPrescription.getRegDate())){
            crud = "C";
          } else {
            crud = "U";
          }
          journalCreateRequestPayload.setCrud(crud);
          patId = ordPrescription.getPatId();
          journalCreateRequestPayload.setPatId(patId);
          journalCreateRequestPayload.setHospPatId(patPersonalMainListMap.get(patId));
          journalCreateRequestPayload.setUserId(updId);
          journalCreateRequestPayload.setOpeCd(OPECDENUM.getOpeIdByCrudTablenameOption(tablePhysicalName, crud, option));
          journalCreateRequestPayload.setOrdNo(ordPrescription.getOrdPrescriptionNo());
          journalCreateRequestPayload.setBaseDate(ordPrescription.getIssueDate());
          break;
        default:
          // 連携対象外Tables
          break;
      }
      if("ord_prescription".equals(tablePhysicalName)){
        journalList.add(journalCreateRequestPayload);
      }
    }

    return journalList;
  }

  private String getChangeModeForActionMode(String actionMode){
    String ret = null;
    switch (actionMode){
      case "SCHEDULE_LIST":
        ret = "SCHEDULE_DAY_CHG";
        break;
      case "PAT_VIEWER_WEEK_PATTERN":
        ret = "SCHEDULE_DAY_CHG";
        break;
      case "PAT_VIEWER_MOVE":
        ret = "SCHEDULE_DAY_CHG";
        break;
      case "PAT_VIEWER_STOP":
        ret = "SCHEDULE_DELETE";
        break;
      case "MST_EXAM_SET":
      case "MST_RAD_SET":
      case "MST_EXAM_ITEM":
        ret = "MST";
        break;
      case "PAT_DEATH":
        ret = "DEATH_DELETE";
        break;
      // add 12005 患者削除時の予定中止は行われるが検査依頼・一般撮影検査依頼の削除が行われない zkm start
      case "PAT_DEL":
        ret = "DEL_DELETE";
        break;
      // add 12005 患者削除時の予定中止は行われるが検査依頼・一般撮影検査依頼の削除が行われない zkm end
      case "PAT_EXAM_MAIN_RESULT":
        ret = "RET";
        break;
      default:
        break;
    }
    return ret;
  }
  private String getChangeMode(OrdMain beforeOrdMain, OrdMain afterOrdMain){
    String ret = null;

    if(ret == null && afterOrdMain == null){
      if(beforeOrdMain.getIndKurCd() != 0){
        ret = "SCHEDULE_DELETE";
      } else {
        ret = "SCHEDULE_DELETE_KURNONE";
      }
    }
    if(ret == null && beforeOrdMain == null){
      if(afterOrdMain.getIndKurCd() != 0){
        ret = "SCHEDULE_CREATE";
      } else {
        ret = "SCHEDULE_CREATE_KURNONE";
      }
    }
    if(ret == null && !Objects.equals(beforeOrdMain.getTreatDate(),afterOrdMain.getTreatDate())){
      ret = "SCHEDULE_DAY_CHG";
//      if(beforeOrdMain.getIndKurCd() == 0){
//        ret = "SCHEDULE_DAY_CHG_KUR_SIGN";
//      } else if (afterOrdMain.getIndKurCd() == 0) {
//        ret = "SCHEDULE_DAY_CHG_KUR_DOWN";
//      } else if (!Objects.equals(beforeOrdMain.getIndKurCd(), afterOrdMain.getIndKurCd())) {
//        ret = "SCHEDULE_DAY_CHG_KUR_CHG";
//      } else {
//        ret = "SCHEDULE_DAY_CHG";
//      }
      if (beforeOrdMain.getIndKurCd() == 0 && afterOrdMain.getIndKurCd() == 0) {
        ret = "SCHEDULE_DAY_CHG_KURNONE";
      }
    }
    if(ret == null && !Objects.equals(beforeOrdMain.getIndKurCd(),afterOrdMain.getIndKurCd())){
      if(beforeOrdMain.getIndKurCd() == 0){
        ret = "SCHEDULE_KUR_SIGN";
      } else if (afterOrdMain.getIndKurCd() == 0) {
        ret = "SCHEDULE_KUR_DOWN";
      } else {
        ret = "SCHEDULE_KUR_CHG";
      }
    }
    if(ret == null && !Objects.equals(beforeOrdMain.getIndTreatStartTime(),afterOrdMain.getIndTreatStartTime())){
      ret = "SCHEDULE_STARTTIME";
    }
    if(ret == null && !Objects.equals(beforeOrdMain.getIndBedCd(),afterOrdMain.getIndBedCd())){
      if(afterOrdMain.getIndKurCd() != 0){
        if(beforeOrdMain.getIndBedCd() == 0){
          ret = "SCHEDULE_BED_SIGN";
        } else if (afterOrdMain.getIndBedCd() == 0) {
          ret = "SCHEDULE_BED_DOWN";
        } else {
          ret = "SCHEDULE_BED_CHG";
        }
      } else {
        if(beforeOrdMain.getIndBedCd() == 0){
          ret = "SCHEDULE_BED_SIGN_KURNONE";
        } else if (afterOrdMain.getIndBedCd() == 0) {
          ret = "SCHEDULE_BED_DOWN_KURNONE";
        } else {
          ret = "SCHEDULE_BED_CHG_KURNONE";
        }
      }
    }
    if(ret == null && !Objects.equals(beforeOrdMain.getIndCondInfo(),afterOrdMain.getIndCondInfo())){
      JSONObject beforeIndCondInfo = null == beforeOrdMain.getIndCondInfo() ? new JSONObject() : new JSONObject(beforeOrdMain.getIndCondInfo());
      JSONObject afterIndCondInfo = null == afterOrdMain.getIndCondInfo() ? new JSONObject() : new JSONObject(afterOrdMain.getIndCondInfo());
      if(ret == null && this.chenckIndCondInfoChange("1", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY1";
      }
      if(ret == null && this.chenckIndCondInfoChange("2", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY2";
      }
      if(ret == null && this.chenckIndCondInfoChange("3", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY3";
      }
      if(ret == null && this.chenckIndCondInfoChange("4", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY4";
      }
      if(ret == null && this.chenckIndCondInfoChange("5", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY5";
      }
      if(ret == null && this.chenckIndCondInfoChange("6", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY6";
      }
      if(ret == null && this.chenckIndCondInfoChange("7", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY7";
      }
      if(ret == null && this.chenckIndCondInfoChange("8", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY8";
      }
      if(ret == null && this.chenckIndCondInfoChange("9", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY9";
      }
      if(ret == null && this.chenckIndCondInfoChange("10", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY10";
      }
      if(ret == null && this.chenckIndCondInfoChange("11", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY11";
      }
      if(ret == null && this.chenckIndCondInfoChange("12", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY12";
      }
      if(ret == null && this.chenckIndCondInfoChange("13", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY13";
      }
      if(ret == null && this.chenckIndCondInfoChange("14", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY14";
      }
      if(ret == null && this.chenckIndCondInfoChange("15", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY15";
      }
      if(ret == null && this.chenckIndCondInfoChange("16", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY16";
      }
      if(ret == null && this.chenckIndCondInfoChange("17", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY17";
      }
      if(ret == null && this.chenckIndCondInfoChange("18", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY18";
      }
      if(ret == null && this.chenckIndCondInfoChange("19", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY19";
      }
      if(ret == null && this.chenckIndCondInfoChange("20", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY20";
      }
      if(ret == null && this.chenckIndCondInfoChange("21", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY21";
      }
      if(ret == null && this.chenckIndCondInfoChange("22", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY22";
      }
      if(ret == null && this.chenckIndCondInfoChange("23", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY23";
      }
      if(ret == null && this.chenckIndCondInfoChange("24", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY24";
      }
      if(ret == null && this.chenckIndCondInfoChange("25", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY25";
      }
      if(ret == null && this.chenckIndCondInfoChange("26", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY26";
      }
      if(ret == null && this.chenckIndCondInfoChange("27", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY27";
      }
      if(ret == null && this.chenckIndCondInfoChange("28", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY28";
      }
      if(ret == null && this.chenckIndCondInfoChange("29", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY29";
      }
      if(ret == null && this.chenckIndCondInfoChange("30", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY30";
      }
      if(ret == null && this.chenckIndCondInfoChange("31", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY31";
      }
      if(ret == null && this.chenckIndCondInfoChange("32", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY32";
      }
      if(ret == null && this.chenckIndCondInfoChange("33", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY33";
      }
      if(ret == null && this.chenckIndCondInfoChange("34", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY34";
      }
      if(ret == null && this.chenckIndCondInfoChange("35", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY35";
      }
      if(ret == null && this.chenckIndCondInfoChange("36", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY36";
      }
      if(ret == null && this.chenckIndCondInfoChange("37", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY37";
      }
      if(ret == null && this.chenckIndCondInfoChange("38", beforeIndCondInfo, afterIndCondInfo)){
        ret = "COND_KEY38";
      }
      //mod #10553 治療条件変更連携送信不正 関 start
      // ret = "COND_CHG";
      //mod #10553 治療条件変更連携送信不正 関 end
      if(afterOrdMain.getIndKurCd() == 0){
        ret = ret + "_KURNONE";
      }
    }
    if(ret == null && !Objects.equals(beforeOrdMain.getIndDw(),afterOrdMain.getIndDw())){
      ret = "COND_DW";
    }
    if(ret == null && !Objects.equals(beforeOrdMain.getIndMediInfo(),afterOrdMain.getIndMediInfo())) {
      JSONArray beforeIndMediJsonArr = new JSONArray(ObjectUtils.isEmpty(beforeOrdMain.getIndMediInfo())? "[]" : beforeOrdMain.getIndMediInfo());
      JSONArray afterIndMediJsonArr = new JSONArray(ObjectUtils.isEmpty(afterOrdMain.getIndMediInfo())? "[]" : afterOrdMain.getIndMediInfo());

      if (ret == null && beforeIndMediJsonArr.length() > afterIndMediJsonArr.length()) {
        ret = "MEDI_DEL";
      } else if (ret == null && beforeIndMediJsonArr.length() < afterIndMediJsonArr.length()) {
        ret = "MEDI_ADD";
      } else {
        ret = "MEDI_UPD";
      }
      if(afterOrdMain.getIndKurCd() == 0){
        ret = ret + "_KURNONE";
      }
    }
    if(ret == null && !Objects.equals(beforeOrdMain.getIndEquipInfo(),afterOrdMain.getIndEquipInfo())) {
      JSONArray beforeIndEquipJsonArr = new JSONArray(ObjectUtils.isEmpty(beforeOrdMain.getIndEquipInfo())? "[]" : beforeOrdMain.getIndEquipInfo());
      JSONArray afterIndEquipJsonArr = new JSONArray(ObjectUtils.isEmpty(afterOrdMain.getIndEquipInfo())? "[]" : afterOrdMain.getIndEquipInfo());

      if (ret == null && beforeIndEquipJsonArr.length() > afterIndEquipJsonArr.length()) {
        ret = "EQUIP_DEL";
      } else if (ret == null && beforeIndEquipJsonArr.length() < afterIndEquipJsonArr.length()) {
        ret = "EQUIP_ADD";
      } else {
        ret = "EQUIP_UPD";
      }
      if(afterOrdMain.getIndKurCd() == 0){
        ret = ret + "_KURNONE";
      }
    }
    if(ret == null && !Objects.equals(beforeOrdMain.getIndIndCommentInfo(),afterOrdMain.getIndIndCommentInfo())) {
      JSONArray beforeIndCommentJsonArr = new JSONArray(ObjectUtils.isEmpty(beforeOrdMain.getIndIndCommentInfo())? "[]" : beforeOrdMain.getIndIndCommentInfo());
      JSONArray afterIndCommentJsonArr = new JSONArray(ObjectUtils.isEmpty(afterOrdMain.getIndIndCommentInfo())? "[]" : afterOrdMain.getIndIndCommentInfo());

      if (ret == null && beforeIndCommentJsonArr.length() > afterIndCommentJsonArr.length()) {
        ret = "COMMENT_DEL";
      } else if (ret == null && beforeIndCommentJsonArr.length() < afterIndCommentJsonArr.length()) {
        ret = "COMMENT_ADD";
      } else {
        ret = "COMMENT_UPD";
      }
      if(afterOrdMain.getIndKurCd() == 0){
        ret = ret + "_KURNONE";
      }
    }
    if(ret == null && !Objects.equals(beforeOrdMain.getIndTareInfo(),afterOrdMain.getIndTareInfo())){
      if(afterOrdMain.getIndKurCd() != 0) {
        ret = "TARE_CHG";
      } else {
        ret = "TARE_CHG_KURNONE";
      }
    }
    if(ret == null && !Objects.equals(beforeOrdMain.getIndOffWaterInfo(),afterOrdMain.getIndOffWaterInfo())){
      if(afterOrdMain.getIndKurCd() != 0) {
        ret = "OFFWATER_CHG";
      } else {
        ret = "OFFWATER_CHG_KURNONE";
      }
    }
    // TODO 装置プログラム関連
    if(ret == null && !Objects.equals(beforeOrdMain.getIndDeviceSetInfo(),afterOrdMain.getIndDeviceSetInfo())) {
      JSONObject beforeObject = new JSONObject(beforeOrdMain.getIndDeviceSetInfo());
      JSONObject afterObject = new JSONObject(afterOrdMain.getIndDeviceSetInfo());

      if(ret == null && !Objects.equals(beforeObject.get("na").toString(), afterObject.get("na").toString())) {//Na注入プログラム
        ret = "NA";
      }
      if(ret == null && !Objects.equals(beforeObject.get("dc").toString(), afterObject.get("dc").toString())) {//透析液濃度プログラム
        ret = "DC";
      }
      if(ret == null && !Objects.equals(beforeObject.get("ufr").toString(), afterObject.get("ufr").toString())) {//UFRプログラム
        ret = "UFR";
      }
      if(ret == null && !Objects.equals(beforeObject.get("qbqd").toString(), afterObject.get("qbqd").toString())) {//血流量・透析液流量プログラム
        ret = "QBQD";
      }
      if(ret == null && !Objects.equals(beforeObject.get("bvufc").toString(), afterObject.get("bvufc").toString())) {//BV-UFC
        ret = "BVUFC";
      }
      if(ret == null && !Objects.equals(beforeObject.get("ihdf").toString(), afterObject.get("ihdf").toString())) {//I-HDF
        ret = "IHDF";
      }
      if(ret == null && !Objects.equals(beforeObject.get("dia").toString(), afterObject.get("dia").toString())) {//dia
        ret = "DIA";
      }
    }
    //手動実績作成
    if(ret == null && "5".equals(afterOrdMain.getRstDialysisState()) && afterOrdMain.getRstCondSendDate() == null) {
      ret = "SEND_COND_RESULT_CREATE";
    }
    //送信(前体重測定)  入室(特殊浄化)  後体重測定
    if(ret == null && "5".equals(afterOrdMain.getRstDialysisState()) && afterOrdMain.getRstCondSendDate() == null) {
      if("9".equals(afterOrdMain.getIndDeviceMode())) {
        ret = "COND_SEND_SPECIAL_PURIFICATION"; //特殊浄化
      } else {
        if("0".equals(beforeOrdMain.getRstDialysisState())) {
          ret = "COND_SEND";//前体重測定
        } else {
          ret = "AFTER_WEIGHT";//後体重測定
        }
      }
    }
    return ret;
  }

  @Override
  public void addToMapList(Map<String, List<Object>> map, String key, Object value) {
      // Map内存在しない場合は新規で入れる
      if (!map.containsKey(key)) {
        List<Object> list = new ArrayList<>();
        list.addAll((List<?>) value);
        map.put(key, list);
      } else {
        // Map内既に存在するのであれば、既存リストへデータマージ
        List<Object> list = map.get(key);
        list.addAll((List<?>) value);
        list.stream().distinct().collect(Collectors.toList());
      }
  }

  private boolean chenckIndCondInfoChange(String key, JSONObject beforeIndCondInfo, JSONObject afterIndCondInfo) {
    if (beforeIndCondInfo.has(key) && !afterIndCondInfo.has(key)) {
      return true;
    } else if (!beforeIndCondInfo.has(key) && afterIndCondInfo.has(key)) {
      return true;
    } else if (beforeIndCondInfo.has(key) && afterIndCondInfo.has(key)
      && !beforeIndCondInfo.getJSONObject(key).similar(afterIndCondInfo.getJSONObject(key))) {
      return true;
    } else {
      return false;
    }
  }

  private enum OPECDENUM {
    // add #10053 処方連携 piao start
    RX_ORD_029001_PAT_RAD_MAIN_C("029001", "ord_prescription","C", "ORD_PRESCRIPTION_SAVE"), // 処方追加
    RX_ORD_029002_PAT_RAD_MAIN_U("029002", "ord_prescription","U", "ORD_PRESCRIPTION_SAVE"), // 処方更新
    RX_ORD_029003_PAT_RAD_MAIN_D("029003", "ord_prescription","D", "ORD_PRESCRIPTION_DELETE"), // 処方削除
    RX_ORD_029004_PAT_RAD_MAIN_U("029004", "ord_prescription","U", "ORD_PRESCRIPTION_UPDATE_STATE"), // 処方一覧一括交付
    RX_ORD_029005_PAT_RAD_MAIN_C("029005", "ord_prescription","C", "ORD_PRESCRIPTION_COPY"), // 処方一覧一括コピー
    // add #10053 処方連携 piao end

    /**
     * 患者統合経過ビューア
     */
    // 予定作成
    IND_DIAL_004078_ORD_MAIN_C( "004078", "ord_main","C", "PAT_VIEWER_PLAN_SCHEDULE_CREATE_KURNONE"), // 患者経過総合ビューア・予定作成
    // 予定中止
    IND_DIAL_004072_ORD_MAIN_D( "004072", "ord_main","D", "PAT_VIEWER_STOP_SCHEDULE_DELETE_KURNONE"), // 患者経過総合ビューア・予定中止
    IND_DIAL_004001_ORD_MAIN_D( "004001", "ord_main","D", "PAT_VIEWER_STOP_SCHEDULE_DELETE"), // 患者経過総合ビューア・予定中止
    // 患者経過総合ビューア・曜日パターン変更
    IND_DIAL_004002_ORD_MAIN_C( "004002", "ord_main","C", "PAT_VIEWER_WEEK_PATTERN_SCHEDULE_DAY_CHG"), // 患者経過総合ビューア・曜日パターン変更
    IND_DIAL_004076_ORD_MAIN_D( "004076", "ord_main","D", "PAT_VIEWER_WEEK_PATTERN_SCHEDULE_DAY_CHG_KURNONE"), // 患者経過総合ビューア・曜日パターン変更
    IND_DIAL_004086_ORD_MAIN_C( "004086", "ord_main","C", "PAT_VIEWER_WEEK_PATTERN_SCHEDULE_DAY_CHG_KURNONE"), // 患者経過総合ビューア・曜日パターン変更
    IND_DIAL_004061_ORD_MAIN_D( "004061", "ord_main","D", "PAT_VIEWER_WEEK_PATTERN_SCHEDULE_DAY_CHG"), // 患者経過総合ビューア・曜日パターン変更
    IND_DIAL_004062_ORD_MAIN_D( "004062", "ord_main","D", "PAT_VIEWER_WEEK_PATTERN_SCHEDULE_DELETE"),// 患者経過総合ビューア・曜日パターン変更
    IND_DIAL_004063_ORD_MAIN_U( "004063", "ord_main","U", "PAT_VIEWER_WEEK_PATTERN_SCHEDULE_BED_DOWN"),// 患者経過総合ビューア・曜日パターン変更
    IND_DIAL_004079_ORD_MAIN_C( "004079", "ord_main","C", "PAT_VIEWER_WEEK_PATTERN_SCHEDULE_CREATE"),// 患者経過総合ビューア・曜日パターン変更
    IND_DIAL_004103_ORD_MAIN_C( "004103", "ord_main","C", "PAT_VIEWER_WEEK_PATTERN_SCHEDULE_CREATE_KURNONE"),// 患者経過総合ビューア・曜日パターン変更
    IND_DIAL_004105_ORD_MAIN_D( "004105", "ord_main","D", "PAT_VIEWER_WEEK_PATTERN_SCHEDULE_DELETE_KURNONE"),// 患者経過総合ビューア・曜日パターン変更
    IND_DIAL_004003_ORD_MAIN_U( "004003", "ord_main","U", "PAT_VIEWER_TREATMENT"), // 患者経過総合ビューア・治療方法編集
    // 患者経過総合ビューア・スケジュール編集
    IND_DIAL_004004_ORD_MAIN_C( "004004", "ord_main","C", "PAT_VIEWER_SCHEDULE_KUR_SIGN"), // 患者経過総合ビューア・スケジュール編集・クール未登録→それ以外
    IND_DIAL_004005_ORD_MAIN_U( "004005", "ord_main","U", "PAT_VIEWER_SCHEDULE_KUR_CHG"), // 患者経過総合ビューア・スケジュール編集・クール未登録以外→未登録以外
    IND_DIAL_004006_ORD_MAIN_D( "004006", "ord_main","D", "PAT_VIEWER_SCHEDULE_KUR_DOWN"), // 患者経過総合ビューア・スケジュール編集・クール未登録以外→未登録
    IND_DIAL_004040_ORD_MAIN_U( "004040", "ord_main","U", "PAT_VIEWER_SCHEDULE_STARTTIME"), // 患者経過総合ビューア・スケジュール編集・治療開始時刻変更
    IND_DIAL_004041_ORD_MAIN_U( "004041", "ord_main","U", "PAT_VIEWER_SCHEDULE_BED_SIGN"), // 患者経過総合ビューア・スケジュール編集・ベッド未登録→新たなベッド
    IND_DIAL_004042_ORD_MAIN_U( "004042", "ord_main","U", "PAT_VIEWER_SCHEDULE_BED_CHG"), // 患者経過総合ビューア・スケジュール編集・ベッド指定ベッド→新たなベッド
    IND_DIAL_004043_ORD_MAIN_U( "004043", "ord_main","U", "PAT_VIEWER_SCHEDULE_BED_DOWN"), // 患者経過総合ビューア・スケジュール編集・ベッド指定ベッド→未登録
    IND_DIAL_004109_ORD_MAIN_U( "004109", "ord_main","U", "PAT_VIEWER_SCHEDULE_BED_SIGN_KURNONE"), // 患者経過総合ビューア・スケジュール編集・ベッド未登録→新たなベッド
    IND_DIAL_004110_ORD_MAIN_U( "004110", "ord_main","U", "PAT_VIEWER_SCHEDULE_BED_CHG_KURNONE"), // 患者経過総合ビューア・スケジュール編集・ベッド指定ベッド→新たなベッド
    IND_DIAL_004111_ORD_MAIN_U( "004111", "ord_main","U", "PAT_VIEWER_SCHEDULE_BED_DOWN_KURNONE"), // 患者経過総合ビューア・スケジュール編集・ベッド指定ベッド→未登録
    // 患者経過総合ビューア・予定コピー
    IND_DIAL_004064_ORD_MAIN_C( "004064", "ord_main","C", "PAT_VIEWER_COPY_SCHEDULE_CREATE"), // 患者経過総合ビューア・予定コピー・クール指定
    IND_DIAL_004104_ORD_MAIN_C( "004104", "ord_main","C", "PAT_VIEWER_COPY_SCHEDULE_CREATE_KURNONE"), // 患者経過総合ビューア・予定コピー・クール指定
    // 患者経過総合ビューア・予定移動
    IND_DIAL_004007_ORD_MAIN_C( "004007", "ord_main","C", "PAT_VIEWER_MOVE_SCHEDULE_DAY_CHG"), // 患者経過総合ビューア・予定移動・クール未登録→それ以外
    IND_DIAL_004009_ORD_MAIN_D( "004009", "ord_main","D", "PAT_VIEWER_MOVE_SCHEDULE_DAY_CHG"), // 患者経過総合ビューア・予定移動・クール未登録以外→未登録
    IND_DIAL_004077_ORD_MAIN_D( "004077", "ord_main","D", "PAT_VIEWER_MOVE_SCHEDULE_DAY_CHG_KURNONE"), // 患者経過総合ビューア・予定移動・クール未登録以外→未登録以外
    IND_DIAL_004087_ORD_MAIN_C( "004087", "ord_main","C", "PAT_VIEWER_MOVE_SCHEDULE_DAY_CHG_KURNONE"), // 患者経過総合ビューア・予定移動・クール未登録以外→未登録以外
    IND_DIAL_004097_ORD_MAIN_C( "004097", "ord_main","C", "PAT_VIEWER_MOVE_SCHEDULE_KUR_SIGN"), // 患者経過総合ビューア・予定移動・クール未登録→それ以外
    IND_DIAL_004098_ORD_MAIN_U( "004098", "ord_main","U", "PAT_VIEWER_MOVE_SCHEDULE_KUR_CHG"), // 患者経過総合ビューア・予定移動・クール未登録以外→未登録以外
    IND_DIAL_004099_ORD_MAIN_D( "004099", "ord_main","D", "PAT_VIEWER_MOVE_SCHEDULE_KUR_DOWN"), // 患者経過総合ビューア・予定移動・クール未登録以外→未登録
    IND_DIAL_004100_ORD_MAIN_U( "004100", "ord_main","U", "PAT_VIEWER_MOVE_SCHEDULE_BED_SIGN"), // 患者経過総合ビューア・予定移動・ベッド未登録→新たなベッド
    IND_DIAL_004101_ORD_MAIN_U( "004101", "ord_main","U", "PAT_VIEWER_MOVE_SCHEDULE_BED_CHG"), // 患者経過総合ビューア・予定移動・ベッド指定ベッド→新たなベッド
    IND_DIAL_004102_ORD_MAIN_U( "004102", "ord_main","U", "PAT_VIEWER_MOVE_SCHEDULE_BED_DOWN"), // 患者経過総合ビューア・予定移動・ベッド指定ベッド→未登録
    IND_DIAL_004106_ORD_MAIN_U( "004106", "ord_main","U", "PAT_VIEWER_MOVE_SCHEDULE_BED_SIGN_KURNONE"), // 患者経過総合ビューア・予定移動・ベッド未登録→新たなベッド
    IND_DIAL_004107_ORD_MAIN_U( "004107", "ord_main","U", "PAT_VIEWER_MOVE_SCHEDULE_BED_CHG_KURNONE"), // 患者経過総合ビューア・予定移動・ベッド指定ベッド→新たなベッド
    IND_DIAL_004108_ORD_MAIN_U( "004108", "ord_main","U", "PAT_VIEWER_MOVE_SCHEDULE_BED_DOWN_KURNONE"), // 患者経過総合ビューア・予定移動・ベッド指定ベッド→未登録
    // 患者経過総合ビューア・治療条件
    IND_DIAL_004010_ORD_MAIN_U_1( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY1"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_2( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY2"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_3( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY3"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_4( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY4"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_5( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY5"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_6( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY6"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_7( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY7"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_8( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY8"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_9( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY9"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_10( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY10"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_11( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY11"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_12( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY12"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_13( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY13"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_14( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY14"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_15( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY15"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_16( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY16"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_17( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY17"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_18( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY18"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_19( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY19"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_20( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY20"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_21( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY21"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_22( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY22"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_23( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY23"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_24( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY24"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_25( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY25"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_26( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY26"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_27( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY27"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_28( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY28"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_29( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY29"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_30( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY30"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_31( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY31"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_32( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY32"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_33( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY33"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_34( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY34"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_35( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY35"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_36( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY36"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_37( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY37"), // 患者経過総合ビューア・治療条件・クール未登録以外
    IND_DIAL_004010_ORD_MAIN_U_38( "004010", "ord_main","U", "PAT_VIEWER_TREAT_ALL_COND_KEY38"), // 患者経過総合ビューア・治療条件・クール未登録以外
    // 患者経過総合ビューア・治療条件・治療時間編集
    IND_DIAL_004011_ORD_MAIN_U( "004011", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY1"), // 患者経過総合ビューア・治療時間編集・クール未登録以外
    // 患者経過総合ビューア・治療条件・VA編集
    IND_DIAL_004012_ORD_MAIN_U( "004012", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY2"), // 患者経過総合ビューア・VA編集・クール未登録以外
    // 患者経過総合ビューア・治療条件・身体情報
    IND_DIAL_004013_ORD_MAIN_U( "004013", "ord_main","U", "PAT_VIEWER_TREAT_CONDITION_DW"), // 患者経過総合ビューア・身体情報・クール未登録以外
    // 患者経過総合ビューア・治療条件・DW/目標体重/除水量制限編集
    IND_DIAL_004014_ORD_MAIN_U_3( "004014", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY3"), // 患者経過総合ビューア・目標体重・クール未登録以外
    IND_DIAL_004014_ORD_MAIN_U_4( "004014", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY4"), // 患者経過総合ビューア・除水量制限・クール未登録以外
    IND_DIAL_004013_ORD_MAIN_U_DW( "004013", "ord_main","U", "PAT_VIEWER_TREAT_COND_DW"), // 患者経過総合ビューア・DW・クール未登録以外
    // 患者経過総合ビューア・治療条件・ダイアライザ/吸着カラム編集
    IND_DIAL_004015_ORD_MAIN_U_5( "004015", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY5"), // 患者経過総合ビューア・ダイアライザ・クール未登録以外
    IND_DIAL_004015_ORD_MAIN_U_6( "004015", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY6"), // 患者経過総合ビューア・吸着カラム・クール未登録以外
    // 患者経過総合ビューア・治療条件・1次膜/2次膜編集
    IND_DIAL_004016_ORD_MAIN_U_7( "004016", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY7"), // 患者経過総合ビューア・1次膜・クール未登録以外
    IND_DIAL_004016_ORD_MAIN_U_8( "004016", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY8"), // 患者経過総合ビューア・2次膜・クール未登録以外
    // 患者経過総合ビューア・治療条件・穿刺針情報編集
    IND_DIAL_004017_ORD_MAIN_U_9( "004017", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY9"), // 患者経過総合ビューア・穿刺針(A針)・クール未登録以外
    IND_DIAL_004017_ORD_MAIN_U_10( "004017", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY10"), // 患者経過総合ビューア・穿刺針(V針)・クール未登録以外
    IND_DIAL_004017_ORD_MAIN_U_11( "004017", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY11"), // 患者経過総合ビューア・穿刺針(SN)・クール未登録以外
    IND_DIAL_004017_ORD_MAIN_U_12( "004017", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY12"), // 患者経過総合ビューア・シングルニードル使用・クール未登録以外
    // 患者経過総合ビューア・治療条件・血液回路編集
    IND_DIAL_004018_ORD_MAIN_U( "004018", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY13"), // 患者経過総合ビューア・血液回路編集・クール未登録以外
    // 患者経過総合ビューア・治療条件・血流量編集
    IND_DIAL_004019_ORD_MAIN_U( "004019", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY14"), // 患者経過総合ビューア・血流量編集・クール未登録以外
    // 患者経過総合ビューア・治療条件・透析液情報編集
    IND_DIAL_004020_ORD_MAIN_U_15( "004020", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY15"), // 患者経過総合ビューア・透析液・クール未登録以外
    IND_DIAL_004020_ORD_MAIN_U_16( "004020", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY16"), // 患者経過総合ビューア・透析液流量・クール未登録以外
    IND_DIAL_004020_ORD_MAIN_U_17( "004020", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY17"), // 患者経過総合ビューア・透析液量・クール未登録以外
    IND_DIAL_004020_ORD_MAIN_U_18( "004020", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY18"), // 患者経過総合ビューア・透析液温度・クール未登録以外
    // 患者経過総合ビューア・治療条件・補液情報編集
    IND_DIAL_004021_ORD_MAIN_U_19( "004021", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY19"), // 患者経過総合ビューア・補液・クール未登録以外
    IND_DIAL_004021_ORD_MAIN_U_20( "004021", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY20"), // 患者経過総合ビューア・補液量・クール未登録以外
    IND_DIAL_004021_ORD_MAIN_U_21( "004021", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY21"), // 患者経過総合ビューア・補液選択・クール未登録以外
    IND_DIAL_004021_ORD_MAIN_U_22( "004021", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY22"), // 患者経過総合ビューア・補液使用数・クール未登録以外
    IND_DIAL_004021_ORD_MAIN_U_23( "004021", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY23"), // 患者経過総合ビューア・補液温度・クール未登録以外
    IND_DIAL_004021_ORD_MAIN_U_24( "004021", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY24"), // 患者経過総合ビューア・補液速度・クール未登録以外
    // 患者経過総合ビューア・治療条件・抗凝固剤情報編集
    IND_DIAL_004022_ORD_MAIN_U_25( "004022", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY25"), // 患者経過総合ビューア・抗凝固剤・クール未登録以外
    IND_DIAL_004022_ORD_MAIN_U_26( "004022", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY26"), // 患者経過総合ビューア・抗凝固剤ワンショット量・クール未登録以外
    IND_DIAL_004022_ORD_MAIN_U_27( "004022", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY27"), // 患者経過総合ビューア・抗凝固剤持続速度・クール未登録以外
    IND_DIAL_004022_ORD_MAIN_U_28( "004022", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY28"), // 患者経過総合ビューア・抗凝固剤持続総量・クール未登録以外
    IND_DIAL_004022_ORD_MAIN_U_29( "004022", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY29"), // 患者経過総合ビューア・IP使用選択・クール未登録以外
    IND_DIAL_004022_ORD_MAIN_U_30( "004022", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY30"), // 患者経過総合ビューア・IPスタート・クール未登録以外
    IND_DIAL_004022_ORD_MAIN_U_31( "004022", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY31"), // 患者経過総合ビューア・IPワンショット量・クール未登録以外
    IND_DIAL_004022_ORD_MAIN_U_32( "004022", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY32"), // 患者経過総合ビューア・IP速度・クール未登録以外
    IND_DIAL_004022_ORD_MAIN_U_33( "004022", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY33"), // 患者経過総合ビューア・IP速度最大値・クール未登録以外
    IND_DIAL_004022_ORD_MAIN_U_34( "004022", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY34"), // 患者経過総合ビューア・自動ワンショット・クール未登録以外
    IND_DIAL_004022_ORD_MAIN_U_35( "004022", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY35"), // 患者経過総合ビューア・IP電源自動切り・クール未登録以外
    IND_DIAL_004022_ORD_MAIN_U_36( "004022", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY36"), // 患者経過総合ビューア・IP電源自動切り時間・クール未登録以外
    IND_DIAL_004022_ORD_MAIN_U_37( "004022", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY37"), // 患者経過総合ビューア・IP電源OKモニタ切り・クール未登録以外
    IND_DIAL_004022_ORD_MAIN_U_38( "004022", "ord_main","U", "PAT_VIEWER_TREAT_COND_KEY38"), // 患者経過総合ビューア・IP電源OKモニタ切り時間・クール未登録以外
    // 患者経過総合ビューア・治療条件・治療時間編集・LINKED
    EXAM_ORD_004117_PAT_EXAM_MAIN_U( "004117", "pat_exam_main","U", "PAT_VIEWER_TREAT_LINKED_U"), // 患者経過総合ビューア・治療条件・治療時間編集・クール未登録以外→クール未登録以外
    EXAM_ORD_004118_PAT_EXAM_MAIN_U( "004118", "pat_exam_main","U", "PHY_PAT_VIEWER_TREAT_LINKED_U"), // 患者経過総合ビューア・治療条件・治療時間編集・クール未登録以外→クール未登録以外
    RAD_ORD_004119_PAT_EXAM_MAIN_U( "004119", "pat_rad_main","U", "PAT_VIEWER_TREAT_LINKED_U"), // 患者経過総合ビューア・治療条件・治療時間編集・クール未登録以外→クール未登録以外
    EXAM_ORD_004117_PAT_EXAM_MAIN_U_ALL( "004117", "pat_exam_main","U", "PAT_VIEWER_TREAT_ALL_LINKED_U"), // 患者経過総合ビューア・治療条件・治療時間・クール未登録以外→クール未登録以外
    EXAM_ORD_004118_PAT_EXAM_MAIN_U_ALL( "004118", "pat_exam_main","U", "PHY_PAT_VIEWER_TREAT_ALL_LINKED_U"), // 患者経過総合ビューア・治療条件・治療時間・クール未登録以外→クール未登録以外
    RAD_ORD_004119_PAT_EXAM_MAIN_U_ALL( "004119", "pat_rad_main","U", "PAT_VIEWER_TREAT_ALL_LINKED_U"), // 患者経過総合ビューア・治療条件・治療時間・クール未登録以外→クール未登録以外
    // 患者経過総合ビューア・投与薬剤
    IND_DIAL_004023_ORD_MAIN_U( "004023", "ord_main","U", "PAT_VIEWER_MEDI_ADD"), // 患者経過総合ビューア・投与薬剤編集
    IND_DIAL_004024_ORD_MAIN_U( "004024", "ord_main","U", "PAT_VIEWER_MEDI_UPD"), // 患者経過総合ビューア・投与薬剤編集
    IND_DIAL_004025_ORD_MAIN_U( "004025", "ord_main","U", "PAT_VIEWER_MEDI_DEL"), // 患者経過総合ビューア・投与薬剤編集
    // 患者経過総合ビューア・医療材料
    IND_DIAL_004026_ORD_MAIN_U( "004026", "ord_main","U", "PAT_VIEWER_EQUIP_ADD"), // 患者経過総合ビューア・医療材料編集
    IND_DIAL_004027_ORD_MAIN_U( "004027", "ord_main","U", "PAT_VIEWER_EQUIP_UPD"), // 患者経過総合ビューア・医療材料編集
    IND_DIAL_004028_ORD_MAIN_U( "004028", "ord_main","U", "PAT_VIEWER_EQUIP_DEL"), // 患者経過総合ビューア・医療材料編集
    // 患者経過総合ビューア・指示コメント
    IND_DIAL_004029_ORD_MAIN_U_ADD( "004029", "ord_main","U", "PAT_VIEWER_COMMENT_ADD"), // 患者経過総合ビューア・指示コメント
    IND_DIAL_004029_ORD_MAIN_U_UPD( "004029", "ord_main","U", "PAT_VIEWER_COMMENT_UPD"), // 患者経過総合ビューア・指示コメント
    IND_DIAL_004029_ORD_MAIN_U_DEL( "004029", "ord_main","U", "PAT_VIEWER_COMMENT_DEL"), // 患者経過総合ビューア・指示コメント
    // 患者経過総合ビューア・風袋
    IND_DIAL_004030_ORD_MAIN_U( "004030", "ord_main","U", "PAT_VIEWER_TARE_CHG"), // 患者経過総合ビューア・風袋
    // 患者経過総合ビューア・除水
    IND_DIAL_004031_ORD_MAIN_U( "004031", "ord_main","U", "PAT_VIEWER_OFFWATER_CHG"), // 患者経過総合ビューア・除水

    // 患者経過総合ビューア・スケジュール編集・#10125
    EXAM_ORD_004052_PAT_EXAM_MAIN_C( "004052", "pat_exam_main","C", "PAT_VIEWER_LINKED_C"), // 患者経過総合ビューア・スケジュール編集・クール未登録→それ以外
    EXAM_ORD_004053_PAT_EXAM_MAIN_D( "004053", "pat_exam_main","D", "PAT_VIEWER_LINKED_D"), // 患者経過総合ビューア・スケジュール編集・クール未登録以外→未登録
    EXAM_ORD_004054_PAT_EXAM_MAIN_U( "004054", "pat_exam_main","U", "PAT_VIEWER_LINKED_U"), // 患者経過総合ビューア・スケジュール編集・クール未登録以外→クール未登録以外
    EXAM_ORD_004065_PAT_EXAM_MAIN_C( "004065", "pat_exam_main","C", "PAT_VIEWER_COPY_LINKED_C"), // 患者経過総合ビューア・コピー・クール指定
    EXAM_ORD_004073_PAT_EXAM_MAIN_D( "004073", "pat_exam_main","D", "PAT_VIEWER_STOP_LINKED_D"), // 患者経過総合ビューア・中止・クール指定
    EXAM_ORD_004073_PAT_EXAM_MAIN_U( "004073", "pat_exam_main","U", "PAT_VIEWER_STOP_LINKED_U"), // 患者経過総合ビューア・中止・クール指定
    EXAM_ORD_004080_PAT_EXAM_MAIN_C( "004080", "pat_exam_main","C", "PAT_VIEWER_WEEK_PATTERN_LINKED_C"), // 患者経過総合ビューア・曜日パターン変更・移動＆新規・クール指定
    EXAM_ORD_004081_PAT_EXAM_MAIN_D( "004081", "pat_exam_main","D", "PAT_VIEWER_WEEK_PATTERN_LINKED_D"), // 患者経過総合ビューア・曜日パターン変更・移動＆中止・クール指定
    EXAM_ORD_004081_PAT_EXAM_MAIN_U( "004081", "pat_exam_main","U", "PAT_VIEWER_WEEK_PATTERN_LINKED_U"), // 患者経過総合ビューア・曜日パターン変更・移動＆中止・クール指定
    EXAM_ORD_004089_PAT_EXAM_MAIN_C( "004089", "pat_exam_main","C", "PAT_VIEWER_MOVE_LINKED_C"), // 患者経過総合ビューア・曜日パターン変更・移動＆新規・クール指定
    EXAM_ORD_004090_PAT_EXAM_MAIN_D( "004090", "pat_exam_main","D", "PAT_VIEWER_MOVE_LINKED_D"), // 患者経過総合ビューア・曜日パターン変更・移動＆中止・クール指定
    EXAM_ORD_004095_PAT_EXAM_MAIN_U( "004095", "pat_exam_main","U", "PAT_VIEWER_MOVE_LINKED_U"), // 患者経過総合ビューア・曜日パターン変更・移動＆中止・クール指定
    // 患者経過総合ビューア
    EXAM_ORD_004044_PAT_EXAM_MAIN_D("004044", "pat_exam_main", "D", "PAT_VIEWER_STOP_SCHEDULE_DELETE"), // 患者経過総合ビューア・予定中止の場合（004001）
    EXAM_ORD_004045_PAT_EXAM_MAIN_D("004045", "pat_exam_main", "D", "PAT_VIEWER_WEEK_PATTERN_SCHEDULE_DAY_CHG"), // 患者経過総合ビューア・曜日パターン変更の場合（004002）
    EXAM_ORD_004055_PAT_EXAM_MAIN_C("004055", "pat_exam_main", "C", "PAT_VIEWER_WEEK_PATTERN_SCHEDULE_DAY_CHG"), // 患者経過総合ビューア・曜日パターン変更の場合（004002）
    EXAM_ORD_004999_PAT_EXAM_MAIN_C("004056", "pat_exam_main", "U", "PAT_VIEWER_WEEK_PATTERN_SCHEDULE_DAY_CHG"),// 患者経過総合ビューア・曜日パターン変更

    EXAM_ORD_004046_PAT_EXAM_MAIN_C("004046", "pat_exam_main", "C", "OPE_CD_004004"), // 患者経過総合ビューア・クール未登録→それ以外（004004）
    EXAM_ORD_004047_PAT_EXAM_MAIN_U("004047", "pat_exam_main", "U", "OPE_CD_004005"), // 患者経過総合ビューア・スケジュール編集・クール未登録以外→未登録以外（004005）
    EXAM_ORD_004048_PAT_EXAM_MAIN_D("004048", "pat_exam_main", "D", "OPE_CD_004006"), // 患者経過総合ビューア・スケジュール編集・クール未登録以外→未登録（004006）
    EXAM_ORD_004049_PAT_EXAM_MAIN_C("004049", "pat_exam_main", "C", "PAT_VIEWER_MOVE_SCHEDULE_DAY_CHG"), // 患者経過総合ビューア・予定移動・クール未登録→それ以外（004007）
    EXAM_ORD_004051_PAT_EXAM_MAIN_D("004051", "pat_exam_main", "D", "PAT_VIEWER_MOVE_SCHEDULE_DAY_CHG"), // 患者経過総合ビューア・予定移動・クール未登録以外→未登録（004009）
    EXAM_ORD_004088_PAT_EXAM_MAIN_U("004088", "pat_exam_main", "U", "PAT_VIEWER_MOVE_SCHEDULE_DAY_CHG"), // 患者経過総合ビューア・予定移動・クール未登録→それ以外（004007）
    //add #10125 VUE calls journal -> API calls journal zrx start
    EXAM_ORD_004044_PAT_EXAM_MAIN_D_KURNONE( "004044", "pat_exam_main","D", "PAT_VIEWER_STOP_SCHEDULE_DELETE_KURNONE"), // 患者経過総合ビューア・予定中止(クール未登録予定)
    EXAM_ORD_004045_PAT_EXAM_MAIN_D_KURNONE( "004045", "pat_exam_main","D", "PAT_VIEWER_WEEK_PATTERN_SCHEDULE_DAY_CHG_KURNONE"), // 患者経過総合ビューア・曜日パターン変更(クール未登録予定)
    EXAM_ORD_004055_PAT_EXAM_MAIN_C_KURNONE( "004055", "pat_exam_main","C", "PAT_VIEWER_WEEK_PATTERN_SCHEDULE_DAY_CHG_KURNONE"), // 患者経過総合ビューア・曜日パターン変更(クール未登録予定)
    EXAM_ORD_004056_PAT_EXAM_MAIN_U_KURNONE( "004056", "pat_exam_main","U", "PAT_VIEWER_WEEK_PATTERN_SCHEDULE_DAY_CHG_KURNONE"), // 患者経過総合ビューア・曜日パターン変更(クール未登録予定)
    EXAM_ORD_004045_PAT_EXAM_MAIN_D_SCHEDULE_DELETE_KURNONE( "004045", "pat_exam_main","D", "PAT_VIEWER_WEEK_PATTERN_SCHEDULE_DELETE_KURNONE"),// 患者経過総合ビューア・曜日パターン変更
    EXAM_ORD_004051_PAT_EXAM_MAIN_D_KURNONE( "004051", "pat_exam_main","D", "PAT_VIEWER_MOVE_SCHEDULE_DAY_CHG_KURNONE"), // 患者経過総合ビューア・予定移動・クール未登録以外→未登録以外
    EXAM_ORD_004049_PAT_EXAM_MAIN_C_KURNONE( "004049", "pat_exam_main","C", "PAT_VIEWER_MOVE_SCHEDULE_DAY_CHG_KURNONE"), // 患者経過総合ビューア・予定移動・クール未登録以外→未登録以外
    EXAM_ORD_004088_PAT_EXAM_MAIN_U_KURNONE( "004088", "pat_exam_main","U", "PAT_VIEWER_MOVE_SCHEDULE_DAY_CHG_KURNONE"), // 患者経過総合ビューア・予定移動・クール未登録以外→未登録以外
    EXAM_ORD_009009_ORD_MAIN_D_KURNONE( "009009", "pat_exam_main","D", "SCHEDULE_LIST_SCHEDULE_DAY_CHG_KURNONE"), // スケジュール・スケジュール・日付変更・別クール
    EXAM_ORD_009007_ORD_MAIN_C_KURNONE( "009007", "pat_exam_main","C", "SCHEDULE_LIST_SCHEDULE_DAY_CHG_KURNONE"), // スケジュール・スケジュール・日付変更・別クール
    EXAM_ORD_009008_ORD_MAIN_U_KURNONE( "009008", "pat_exam_main","U", "SCHEDULE_LIST_SCHEDULE_DAY_CHG_KURNONE"), // スケジュール・スケジュール・日付変更・別クール

    //add #10125 VUE calls journal -> API calls journal zrx end
    PHY_ORD_004152_PAT_EXAM_MAIN_C( "004152", "pat_exam_main","C", "PHY_PAT_VIEWER_LINKED_C"), // 患者経過総合ビューア・スケジュール編集・クール未登録→それ以外
    PHY_ORD_004153_PAT_EXAM_MAIN_D( "004153", "pat_exam_main","D", "PHY_PAT_VIEWER_LINKED_D"), // 患者経過総合ビューア・スケジュール編集・クール未登録以外→未登録
    PHY_ORD_004154_PAT_EXAM_MAIN_U( "004154", "pat_exam_main","U", "PHY_PAT_VIEWER_LINKED_U"), // 患者経過総合ビューア・スケジュール編集・クール未登録以外→クール未登録以外
    PHY_ORD_004165_PAT_EXAM_MAIN_C( "004165", "pat_exam_main","C", "PHY_PAT_VIEWER_COPY_LINKED_C"), // 患者経過総合ビューア・コピー・クール指定
    PHY_ORD_004074_PAT_EXAM_MAIN_D( "004074", "pat_exam_main","D", "PHY_PAT_VIEWER_STOP_LINKED_D"), // 患者経過総合ビューア・中止・クール指定
    PHY_ORD_004074_PAT_EXAM_MAIN_U( "004074", "pat_exam_main","U", "PHY_PAT_VIEWER_STOP_LINKED_U"), // 患者経過総合ビューア・中止・クール指定
    PHY_ORD_004082_PAT_EXAM_MAIN_C( "004082", "pat_exam_main","C", "PHY_PAT_VIEWER_WEEK_PATTERN_LINKED_C"), // 患者経過総合ビューア・曜日パターン変更・移動＆新規・クール指定
    PHY_ORD_004083_PAT_EXAM_MAIN_D( "004083", "pat_exam_main","D", "PHY_PAT_VIEWER_WEEK_PATTERN_LINKED_D"), // 患者経過総合ビューア・曜日パターン変更・移動＆中止・クール指定
    PHY_ORD_004083_PAT_EXAM_MAIN_U( "004083", "pat_exam_main","U", "PHY_PAT_VIEWER_WEEK_PATTERN_LINKED_U"), // 患者経過総合ビューア・曜日パターン変更・移動＆中止・クール指定
    PHY_ORD_004091_PAT_EXAM_MAIN_C( "004091", "pat_exam_main","C", "PHY_PAT_VIEWER_MOVE_LINKED_C"), // 患者経過総合ビューア・曜日パターン変更・移動＆新規・クール指定
    PHY_ORD_004092_PAT_EXAM_MAIN_D( "004092", "pat_exam_main","D", "PHY_PAT_VIEWER_MOVE_LINKED_D"), // 患者経過総合ビューア・曜日パターン変更・移動＆中止・クール指定
    PHY_ORD_004092_PAT_EXAM_MAIN_U( "004096", "pat_exam_main","U", "PHY_PAT_VIEWER_MOVE_LINKED_U"), // 患者経過総合ビューア・曜日パターン変更・移動＆中止・クール指定
    // 患者経過総合ビューア
    PHY_ORD_004144_PAT_EXAM_MAIN_D("004144", "pat_exam_main", "D", "PHY_PAT_VIEWER_STOP_SCHEDULE_DELETE"), // 患者経過総合ビューア・予定中止の場合（004001）
    PHY_ORD_004145_PAT_EXAM_MAIN_D("004145", "pat_exam_main", "D", "PHY_PAT_VIEWER_WEEK_PATTERN_SCHEDULE_DAY_CHG"), // 患者経過総合ビューア・曜日パターン変更の場合（004002）
    PHY_ORD_004155_PAT_EXAM_MAIN_C("004155", "pat_exam_main", "C", "PHY_PAT_VIEWER_WEEK_PATTERN_SCHEDULE_DAY_CHG"), // 患者経過総合ビューア・曜日パターン変更の場合（004002）
    //add #10125 VUE calls journal -> API calls journal zrx start
    PHY_ORD_004144_PAT_EXAM_MAIN_D_KURNONE( "004144", "pat_exam_main","D", "PHY_PAT_VIEWER_STOP_SCHEDULE_DELETE_KURNONE"), // 患者経過総合ビューア・予定中止(クール未登録予定)
    PHY_ORD_004145_PAT_EXAM_MAIN_D_KURNONE( "004145", "pat_exam_main","D", "PHY_PAT_VIEWER_WEEK_PATTERN_SCHEDULE_DAY_CHG_KURNONE"), // 患者経過総合ビューア・曜日パターン変更(クール未登録予定)
    PHY_ORD_004155_PAT_EXAM_MAIN_C_KURNONE( "004155", "pat_exam_main","C", "PHY_PAT_VIEWER_WEEK_PATTERN_SCHEDULE_DAY_CHG_KURNONE"), // 患者経過総合ビューア・曜日パターン変更(クール未登録予定)
    PHY_ORD_004145_PAT_EXAM_MAIN_D_SCHEDULE_DELETE_KURNONE( "004145", "pat_exam_main","D", "PHY_PAT_VIEWER_WEEK_PATTERN_SCHEDULE_DELETE_KURNONE"),// 患者経過総合ビューア・曜日パターン変更
    PHY_ORD_004151_PAT_EXAM_MAIN_D_KURNONE( "004151", "pat_exam_main","D", "PHY_PAT_VIEWER_MOVE_SCHEDULE_DAY_CHG_KURNONE"), // 患者経過総合ビューア・予定移動・クール未登録以外→未登録以外
    PHY_ORD_004149_PAT_EXAM_MAIN_C_KURNONE( "004149", "pat_exam_main","C", "PHY_PAT_VIEWER_MOVE_SCHEDULE_DAY_CHG_KURNONE"), // 患者経過総合ビューア・予定移動・クール未登録以外→未登録以外
    PHY_ORD_009109_ORD_MAIN_D_KURNONE( "009109", "pat_exam_main","D", "PHY_SCHEDULE_LIST_SCHEDULE_DAY_CHG_KURNONE"), // スケジュール・スケジュール・日付変更・別クール
    PHY_ORD_009107_ORD_MAIN_C_KURNONE( "009107", "pat_exam_main","C", "PHY_SCHEDULE_LIST_SCHEDULE_DAY_CHG_KURNONE"), // スケジュール・スケジュール・日付変更・別クール

    //add #10125 VUE calls journal -> API calls journal zrx end

    PHY_ORD_004146_PAT_EXAM_MAIN_C("004146", "pat_exam_main", "C", "PHY_OPE_CD_004004"), // 患者経過総合ビューア・クール未登録→それ以外（004004）
    PHY_ORD_004147_PAT_EXAM_MAIN_U("004147", "pat_exam_main", "U", "PHY_OPE_CD_004005"), // 患者経過総合ビューア・スケジュール編集・クール未登録以外→未登録以外（004005）
    PHY_ORD_004148_PAT_EXAM_MAIN_D("004148", "pat_exam_main", "D", "PHY_OPE_CD_004006"), // 患者経過総合ビューア・スケジュール編集・クール未登録以外→未登録（004006）
    PHY_ORD_004149_PAT_EXAM_MAIN_C("004149", "pat_exam_main", "C", "PHY_PAT_VIEWER_MOVE_SCHEDULE_DAY_CHG"), // 患者経過総合ビューア・予定移動・クール未登録→それ以外（004007）
    PHY_ORD_004151_PAT_EXAM_MAIN_D("004151", "pat_exam_main", "D", "PHY_PAT_VIEWER_MOVE_SCHEDULE_DAY_CHG"), // 患者経過総合ビューア・予定移動・クール未登録以外→未登録（004009）

    RAD_ORD_004058_PAT_RAD_MAIN_C( "004058", "pat_rad_main","C", "PAT_VIEWER_LINKED_C"), // 患者経過総合ビューア・スケジュール編集・クール未登録→それ以外
    RAD_ORD_004059_PAT_RAD_MAIN_D( "004059", "pat_rad_main","D", "PAT_VIEWER_LINKED_D"), // 患者経過総合ビューア・スケジュール編集・クール未登録以外→未登録
    RAD_ORD_004060_PAT_RAD_MAIN_U( "004060", "pat_rad_main","U", "PAT_VIEWER_LINKED_U"), // 患者経過総合ビューア・スケジュール編集・クール未登録以外→クール未登録以外

    RAD_ORD_004066_PAT_RAD_MAIN_C( "004066", "pat_rad_main","C", "PAT_VIEWER_COPY_LINKED_C"), // 患者経過総合ビューア・コピー・クール指定
    RAD_ORD_004075_PAT_RAD_MAIN_D( "004075", "pat_rad_main","D", "PAT_VIEWER_STOP_LINKED_D"), // 患者経過総合ビューア・中止・クール指定
    RAD_ORD_004075_PAT_RAD_MAIN_U( "004075", "pat_rad_main","U", "PAT_VIEWER_STOP_LINKED_U"), // 患者経過総合ビューア・中止・クール指定
    RAD_ORD_004084_PAT_RAD_MAIN_C( "004084", "pat_rad_main","C", "PAT_VIEWER_WEEK_PATTERN_LINKED_C"), // 患者経過総合ビューア・曜日パターン変更・移動＆新規・クール指定
    RAD_ORD_004085_PAT_RAD_MAIN_D( "004085", "pat_rad_main","D", "PAT_VIEWER_WEEK_PATTERN_LINKED_D"), // 患者経過総合ビューア・曜日パターン変更・移動＆中止・クール指定
    RAD_ORD_004085_PAT_RAD_MAIN_U( "004085", "pat_rad_main","U", "PAT_VIEWER_WEEK_PATTERN_LINKED_U"), // 患者経過総合ビューア・曜日パターン変更・移動＆中止・クール指定
    RAD_ORD_004093_PAT_RAD_MAIN_C( "004093", "pat_rad_main","C", "PAT_VIEWER_MOVE_LINKED_C"), // 患者経過総合ビューア・曜日パターン変更・移動＆新規・クール指定
    RAD_ORD_004094_PAT_RAD_MAIN_D( "004094", "pat_rad_main","D", "PAT_VIEWER_MOVE_LINKED_D"), // 患者経過総合ビューア・曜日パターン変更・移動＆中止・クール指定
    RAD_ORD_004116_PAT_RAD_MAIN_U( "004116", "pat_rad_main","U", "PAT_VIEWER_MOVE_LINKED_U"), // 患者経過総合ビューア・曜日パターン変更・移動＆中止・クール指定

    RAD_ORD_004067_PAT_RAD_MAIN_C( "004067", "pat_rad_main","C", "PAT_VIEWER_WEEK_PATTERN_SCHEDULE_DAY_CHG"), // 患者経過総合ビューア・曜日パターン変更の場合
    RAD_ORD_004068_PAT_RAD_MAIN_D( "004068", "pat_rad_main","D", "PAT_VIEWER_WEEK_PATTERN_SCHEDULE_DAY_CHG"), // 患者経過総合ビューア・曜日パターン変更の場合

    RAD_ORD_004069_PAT_RAD_MAIN_C( "004069", "pat_rad_main","C", "PAT_VIEWER_MOVE_SCHEDULE_DAY_CHG"), // 患者経過総合ビューア・スケジュール編集・クール未登録→それ以外
    RAD_ORD_004070_PAT_RAD_MAIN_D( "004070", "pat_rad_main","D", "PAT_VIEWER_MOVE_SCHEDULE_DAY_CHG"), // 患者経過総合ビューア・スケジュール編集・クール未登録以外→未登録
    RAD_ORD_004071_PAT_RAD_MAIN_C( "004071", "pat_rad_main","D", "PAT_VIEWER_STOP_SCHEDULE_DELETE"),// 患者経過総合ビューア・予定中止の場合（004001）

    //add #10125 VUE calls journal -> API calls journal zrx start
    RAD_ORD_004071_PAT_RAD_MAIN_D_KURNONE( "004071", "pat_rad_main","D", "PAT_VIEWER_STOP_SCHEDULE_DELETE_KURNONE"), // 患者経過総合ビューア・予定中止(クール未登録予定)
    RAD_ORD_004068_PAT_RAD_MAIN_D_KURNONE( "004068", "pat_rad_main","D", "PAT_VIEWER_WEEK_PATTERN_SCHEDULE_DAY_CHG_KURNONE"), // 患者経過総合ビューア・曜日パターン変更(クール未登録予定)
    RAD_ORD_004067_PAT_RAD_MAIN_C_KURNONE( "004067", "pat_rad_main","C", "PAT_VIEWER_WEEK_PATTERN_SCHEDULE_DAY_CHG_KURNONE"), // 患者経過総合ビューア・曜日パターン変更(クール未登録予定)
    RAD_ORD_004068_PAT_RAD_MAIN_D_SCHEDULE_DELETE_KURNONE( "004068", "pat_rad_main","D", "PAT_VIEWER_WEEK_PATTERN_SCHEDULE_DELETE_KURNONE"),// 患者経過総合ビューア・曜日パターン変更
    RAD_ORD_004070_PAT_EXAM_MAIN_D_KURNONE( "004070", "pat_rad_main","D", "PAT_VIEWER_MOVE_SCHEDULE_DAY_CHG_KURNONE"), // 患者経過総合ビューア・予定移動・クール未登録以外→未登録以外
    RAD_ORD_004069_PAT_EXAM_MAIN_C_KURNONE( "004069", "pat_rad_main","C", "PAT_VIEWER_MOVE_SCHEDULE_DAY_CHG_KURNONE"), // 患者経過総合ビューア・予定移動・クール未登録以外→未登録以外
    RAD_ORD_009012_ORD_MAIN_D_KURNONE( "009012", "pat_rad_main","D", "SCHEDULE_LIST_SCHEDULE_DAY_CHG_KURNONE"), // スケジュール・スケジュール・日付変更・別クール
    RAD_ORD_009010_ORD_MAIN_C_KURNONE( "009010", "pat_rad_main","C", "SCHEDULE_LIST_SCHEDULE_DAY_CHG_KURNONE"), // スケジュール・スケジュール・日付変更・別クール

    /**設定*/
    PAT_MAIN_010003_PAT_MAIN_OPE_U( "010003", "pat_main","U", "PAT_MAIN_OPE"), // 設定・操作範囲
    PAT_MAIN_010004_PAT_MAIN_ECUM_U( "010004", "pat_main","U", "PAT_MAIN_ECUM"), // 設定・ECUM設定
    PAT_MAIN_010005_PAT_MAIN_WAR_U( "010005", "pat_main","U", "PAT_MAIN_WAR"), // 設定・警報点
    PAT_MAIN_010006_PAT_MAIN_CPRO_U( "010006", "pat_main","U", "PAT_MAIN_CPRO"), // 設定・濃度プロ自動設定警報
    PAT_MAIN_010007_PAT_MAIN_BP_U( "010007", "pat_main","U", "PAT_MAIN_BP"), // 設定・血圧計
    PAT_MAIN_010008_PAT_MAIN_BV_U( "010008", "pat_main","U", "PAT_MAIN_BV"), // 設定・BV
    PAT_MAIN_010009_PAT_MAIN_PRI_U( "010009", "pat_main","U", "PAT_MAIN_PRI"), // 設定・プライミング
    PAT_MAIN_010010_PAT_MAIN_DFAS_U( "010010", "pat_main","U", "PAT_MAIN_DFAS"), // 設定・dfas
    PAT_MAIN_010011_PAT_MAIN_IAP_U( "010011", "pat_main","U", "PAT_MAIN_IAP"), // 設定・静的静脈圧

    /**プログラム  TODO CHG_KURNONE未实现*/
    PROGRAM_NA_004033_ORD_MAIN_U( "004033", "ord_main","U", "ORD_MAIN_NA"), // 患者経過総合ビューア・Na注入プログラム
    PROGRAM_DC_004034_ORD_MAIN_U( "004034", "ord_main","U", "ORD_MAIN_DC"), // 患者経過総合ビューア・透析液濃度プログラム
    PROGRAM_UFR_004032_ORD_MAIN_U( "004032", "ord_main","U", "ORD_MAIN_UFR"), // 患者経過総合ビューア・UFRプログラム
    PROGRAM_QBQD_004035_ORD_MAIN_U( "004035", "ord_main","U", "ORD_MAIN_QBQD"), // 患者経過総合ビューア・血流量・透析液流量プログラム
    PROGRAM_BVUFC_004037_ORD_MAIN_U( "004037", "ord_main","U", "ORD_MAIN_BVUFC"), // 患者経過総合ビューア・BV-UFC
    PROGRAM_IHDF_004036_ORD_MAIN_U( "004036", "ord_main","U", "ORD_MAIN_IHDF"), // 患者経過総合ビューア・I-HDF
    PROGRAM_DIA_004038_ORD_MAIN_U( "004038", "ord_main","U", "ORD_MAIN_DIA"), // 患者経過総合ビューア・dia

    /**検査結果*/
    EXAM_ORD_018001_EXAM_RESULT_C("018001", "pat_exam_main", "C", "PAT_EXAM_MAIN_RESULT_RET"),
    EXAM_ORD_018002_EXAM_RESULT_U("018002", "pat_exam_main", "U", "PAT_EXAM_MAIN_RESULT_RET"),
    EXAM_ORD_018003_EXAM_RESULT_D("018003", "pat_exam_main", "D", "PAT_EXAM_MAIN_RESULT_RET"),
    //add #10125 VUE calls journal -> API calls journal zrx end

    /**
     * マスタメンテナンス(クールマスタ)
     */
    EXAM_ORD_005002_PAT_EXAM_MAIN_D( "005002", "pat_exam_main","D", "MST_KUR_LINKED_D"), // クールマスタ・クール未登録以外→未登録
    PHY_ORD_005003_PAT_EXAM_MAIN_D( "005003", "pat_exam_main","D", "PHY_MST_KUR_LINKED_D"), // クールマスタ・クール未登録以外→未登録当・ベッド登録済み→新たなベッド
    RAD_ORD_005004_PAT_RAD_MAIN_D( "005004", "pat_rad_main","D", "MST_KUR_LINKED_D"), // クールマスタ・クール未登録以外→未登録

    /**
     * スケジュール表
     */
    IND_DIAL_009001_ORD_MAIN_C( "009001", "ord_main","C", "SCHEDULE_LIST_SCHEDULE_KUR_SIGN"), // スケジュール・スケジュール・クール未登録→それ以外
    IND_DIAL_009002_ORD_MAIN_U( "009002", "ord_main","U", "SCHEDULE_LIST_SCHEDULE_KUR_CHG"), // スケジュール・スケジュール・クール未登録以外→未登録以外
    IND_DIAL_009003_ORD_MAIN_D( "009003", "ord_main","D", "SCHEDULE_LIST_SCHEDULE_KUR_DOWN"), // スケジュール・スケジュール・クール未登録以外→未登録
    IND_DIAL_009004_ORD_MAIN_U( "009004", "ord_main","U", "SCHEDULE_LIST_SCHEDULE_BED_SIGN"), // スケジュール・スケジュール・ベッド未登録→新たなベッド
    IND_DIAL_009005_ORD_MAIN_U( "009005", "ord_main","U", "SCHEDULE_LIST_SCHEDULE_BED_CHG"), // スケジュール・スケジュール・ベッド指定ベッド→新たなベッド
    IND_DIAL_009006_ORD_MAIN_U( "009006", "ord_main","U", "SCHEDULE_LIST_SCHEDULE_BED_DOWN"), // スケジュール・スケジュール・ベッド指定ベッド→未登録

    IND_DIAL_009013_ORD_MAIN_D( "009013", "ord_main","D", "SCHEDULE_LIST_SCHEDULE_DAY_CHG"), // スケジュール・スケジュール・日付変更・別クール
    IND_DIAL_009024_ORD_MAIN_D( "009024", "ord_main","D", "SCHEDULE_LIST_SCHEDULE_DAY_CHG_KURNONE"), // スケジュール・スケジュール・日付変更・別クール
    IND_DIAL_009025_ORD_MAIN_C( "009025", "ord_main","C", "SCHEDULE_LIST_SCHEDULE_DAY_CHG_KURNONE"), // スケジュール・スケジュール・日付変更・別クール
    IND_DIAL_009014_ORD_MAIN_C( "009014", "ord_main","C", "SCHEDULE_LIST_SCHEDULE_DAY_CHG"), // スケジュール・スケジュール・日付変更・別クール

    EXAM_ORD_009019_PAT_EXAM_MAIN_C( "009019", "pat_exam_main","C", "SCHEDULE_LIST_LINKED_C"), // スケジュール表・スケジュール編集・クール未登録→クール未登録以外（009001）
    EXAM_ORD_009020_PAT_EXAM_MAIN_U( "009020", "pat_exam_main","U", "SCHEDULE_LIST_LINKED_U"), // スケジュール表・スケジュール編集・クール未登録以外→クール未登録以外（009002）
    EXAM_ORD_009021_PAT_EXAM_MAIN_D( "009021", "pat_exam_main","D", "SCHEDULE_LIST_LINKED_D"), // スケジュール表・スケジュール編集・クール未登録以外→クール未登録（009003）

    // スケジュール表
    EXAM_ORD_009007_PAT_EXAM_MAIN_C("009007", "pat_exam_main", "C", "SCHEDULE_LIST_SCHEDULE_DAY_CHG"), // スケジュール・スケジュール・クール未登録→それ以外（009014）
    EXAM_ORD_009008_PAT_EXAM_MAIN_C("009008", "pat_exam_main", "U", "SCHEDULE_LIST_SCHEDULE_DAY_CHG"), // スケジュール・スケジュール・クール未登録→それ以外（009014）
    EXAM_ORD_009009_PAT_EXAM_MAIN_D("009009", "pat_exam_main", "D", "SCHEDULE_LIST_SCHEDULE_DAY_CHG"), // スケジュール・スケジュール・クール未登録以外→未登録（009013）

    PHY_ORD_009015_PAT_EXAM_MAIN_C( "009015", "pat_exam_main","C", "PHY_SCHEDULE_LIST_LINKED_C"), // スケジュール表・スケジュール編集・クール未登録→クール未登録以外（009001）
    PHY_ORD_009016_PAT_EXAM_MAIN_U( "009016", "pat_exam_main","U", "PHY_SCHEDULE_LIST_LINKED_U"), // スケジュール表・スケジュール編集・クール未登録以外→クール未登録以外（009002）
    PHY_ORD_009022_PAT_EXAM_MAIN_D( "009022", "pat_exam_main","D", "PHY_SCHEDULE_LIST_LINKED_D"), // スケジュール表・スケジュール編集・クール未登録以外→クール未登録（009003）

    // スケジュール表
    PHY_ORD_009107_PAT_EXAM_MAIN_C("009107", "pat_exam_main", "C", "PHY_SCHEDULE_LIST_SCHEDULE_DAY_CHG"), // スケジュール・スケジュール・クール未登録→それ以外（009014）
    PHY_ORD_009109_PAT_EXAM_MAIN_D("009109", "pat_exam_main", "D", "PHY_SCHEDULE_LIST_SCHEDULE_DAY_CHG"), // スケジュール・スケジュール・クール未登録以外→未登録（009013）

    RAD_ORD_009017_PAT_RAD_MAIN_C( "009017", "pat_rad_main","C", "SCHEDULE_LIST_LINKED_C"), // スケジュール表・スケジュール編集・クール未登録→クール未登録以外（009001）
    RAD_ORD_009018_PAT_RAD_MAIN_U( "009018", "pat_rad_main","U", "SCHEDULE_LIST_LINKED_U"), // スケジュール表・スケジュール編集・クール未登録以外→クール未登録以外（009002）
    RAD_ORD_009023_PAT_RAD_MAIN_U( "009023", "pat_rad_main","D", "SCHEDULE_LIST_LINKED_D"), // スケジュール表・スケジュール編集・クール未登録以外→クール未登録（009003）

    // スケジュール表
    RAD_ORD_009010_PAT_RAD_MAIN_C("009010", "pat_rad_main","C", "SCHEDULE_LIST_SCHEDULE_DAY_CHG"), // スケジュール・スケジュール・クール未登録→それ以外（009014）
    RAD_ORD_009012_PAT_RAD_MAIN_D("009012", "pat_rad_main","D", "SCHEDULE_LIST_SCHEDULE_DAY_CHG"), // スケジュール・スケジュール・クール未登録以外→未登録（009013）

    /**
     * 治療状況リスト
     */
    IND_DIAL_011010_ORD_MAIN_C( "011010", "ord_main","C", "STATUS_LIST_QUESTION_PAT_SCHEDULE_CREATE"), // 治療状況リスト・????患者スケジュール割当・ベッド未登録→新たなベッド

    EXAM_ORD_011011_PAT_EXAM_MAIN_C( "011011", "pat_exam_main","C", "STATUS_LIST_QUESTION_PAT_LINKED_C"), // 治療状況リスト・????患者スケジュール割当・ベッド未登録→新たなベッド

    PHY_ORD_011012_PAT_EXAM_MAIN_C( "011012", "pat_exam_main","C", "PHY_STATUS_LIST_QUESTION_PAT_LINKED_C"), // 治療状況リスト・????患者スケジュール割当・ベッド未登録→新たなベッド

    RAD_ORD_011013_PAT_RAD_MAIN_C( "011013", "pat_rad_main","C", "STATUS_LIST_QUESTION_PAT_LINKED_C"), // 治療状況リスト・????患者スケジュール割当・ベッド未登録→新たなベッド

    /**
     * 治療状況マップ
     */
    IND_DIAL_012019_ORD_MAIN_C( "012019", "ord_main","C", "STATUS_MAP_QUESTION_PAT_SCHEDULE_CREATE"), // 治療状況マップ・????患者スケジュール割当・ベッド未登録→新たなベッド

    IND_DIAL_012001_ORD_MAIN_C( "012018", "ord_main","C", "STATUS_MAP_SCHEDULE_KUR_SIGN"), // 治療状況マップ・スケジュール・クール未登録→それ以外
    IND_DIAL_012002_ORD_MAIN_U( "012002", "ord_main","U", "STATUS_MAP_SCHEDULE_KUR_CHG"), // 治療状況マップ・スケジュール・クール未登録以外→未登録以外
    IND_DIAL_012003_ORD_MAIN_D( "012003", "ord_main","D", "STATUS_MAP_SCHEDULE_KUR_DOWN"), // 治療状況マップ・スケジュール・クール未登録以外→未登録
    IND_DIAL_012004_ORD_MAIN_U( "012004", "ord_main","U", "STATUS_MAP_SCHEDULE_BED_SIGN"), // 治療状況マップ・スケジュール・ベッド未登録→新たなベッド
    IND_DIAL_012005_ORD_MAIN_U( "012005", "ord_main","U", "STATUS_MAP_SCHEDULE_BED_CHG"), // 治療状況マップ・スケジュール・ベッド指定ベッド→新たなベッド
    IND_DIAL_012006_ORD_MAIN_U( "012006", "ord_main","U", "STATUS_MAP_SCHEDULE_BED_DOWN"), // 治療状況マップ・スケジュール・ベッド指定ベッド→未登録

    EXAM_ORD_012007_PAT_EXAM_MAIN_C( "012007", "pat_exam_main","C", "STATUS_MAP_LINKED_C"), // 治療状況マップ・スケジュール編集・クール未登録→クール未登録以外
    EXAM_ORD_012008_PAT_EXAM_MAIN_U( "012008", "pat_exam_main","U", "STATUS_MAP_LINKED_U"), // 治療状況マップ・スケジュール編集・クール未登録以外→クール未登録以外
    EXAM_ORD_012013_PAT_EXAM_MAIN_C( "012013", "pat_exam_main","C", "STATUS_MAP_QUESTION_PAT_LINKED_C"), // 治療状況マップ・????患者スケジュール割当・ベッド未登録→新たなベッド

    PHY_ORD_012009_PAT_EXAM_MAIN_C( "012009", "pat_exam_main","C", "PHY_STATUS_MAP_LINKED_C"), // 治療状況マップ・スケジュール編集・クール未登録→クール未登録以外
    PHY_ORD_012010_PAT_EXAM_MAIN_U( "012010", "pat_exam_main","U", "PHY_STATUS_MAP_LINKED_U"), // 治療状況マップ・スケジュール編集・クール未登録以外→クール未登録以外
    PHY_ORD_012015_PAT_EXAM_MAIN_C( "012015", "pat_exam_main","C", "PHY_STATUS_MAP_QUESTION_PAT_LINKED_C"), // 治療状況マップ・????患者スケジュール割当・ベッド未登録→新たなベッド

    RAD_ORD_012011_PAT_RAD_MAIN_C( "012011", "pat_rad_main","C", "STATUS_MAP_LINKED_C"), // 治療状況マップ・スケジュール編集・クール未登録→クール未登録以外
    RAD_ORD_012012_PAT_RAD_MAIN_U( "012012", "pat_rad_main","U", "STATUS_MAP_LINKED_U"), // 治療状況マップ・スケジュール編集・クール未登録以外→クール未登録以外
    RAD_ORD_012017_PAT_RAD_MAIN_C( "012017", "pat_rad_main","C", "STATUS_MAP_QUESTION_PAT_LINKED_C"), // 治療状況マップ・????患者スケジュール割当・ベッド未登録→新たなベッド

    /**
     * 体重計・条件送信
     */
    IND_DIAL_013001_ORD_MAIN_C( "013001", "ord_main","C", "WEIGHT_MEASUREMENT_COND_SEND"), // 体重測定・条件送信
    IND_DIAL_013002_ORD_MAIN_U( "013002", "ord_main","U", "WEIGHT_MEASUREMENT_AFTER_WEIGHT"), // 体重測定・後体重測定
    IND_DIAL_013003_ORD_MAIN_C( "013003", "ord_main","U", "WEIGHT_MEASUREMENT_SCHEDULE_KUR_CHG"), // 体重測定・スケジュール・クール未登録以外→未登録以外
    IND_DIAL_013004_ORD_MAIN_U( "013004", "ord_main","U", "WEIGHT_MEASUREMENT_COND_KEY3"), // 体重測定・目標体重編集
    IND_DIAL_013005_ORD_MAIN_U( "013005", "ord_main","U", "WEIGHT_MEASUREMENT_COND_KEY4"), // 体重測定・除水量制限編集
    IND_DIAL_013006_ORD_MAIN_C( "013006", "ord_main","C", "WEIGHT_MEASUREMENT_SCHEDULE_KUR_SIGN"), // 体重測定・スケジュール・クール未登録→それ以外
    IND_DIAL_013007_ORD_MAIN_U( "013007", "ord_main","D", "WEIGHT_MEASUREMENT_SCHEDULE_KUR_DOWN"), // 体重測定・スケジュール・クール未登録以外→未登録
    IND_DIAL_013011_ORD_MAIN_U( "013011", "ord_main","U", "WEIGHT_MEASUREMENT_SCHEDULE_STARTTIME"), // 体重測定・スケジュール・開始時刻編集
    IND_DIAL_013008_ORD_MAIN_U( "013008", "ord_main","U", "WEIGHT_MEASUREMENT_SCHEDULE_BED_DOWN"), // 体重測定・スケジュール・ベッド指定ベッド→未登録
    IND_DIAL_013009_ORD_MAIN_U( "013009", "ord_main","U", "WEIGHT_MEASUREMENT_SCHEDULE_BED_SIGN"), // 体重測定・スケジュール・ベッド未登録→新たなベッド
    IND_DIAL_013010_ORD_MAIN_U( "013010", "ord_main","U", "WEIGHT_MEASUREMENT_SCHEDULE_BED_CHG"), // 体重測定・スケジュール・ベッド指定ベッド→新たなベッド
    IND_DIAL_013024_ORD_MAIN_U( "013024", "ord_main","U", "WEIGHT_MEASUREMENT_SCHEDULE_BED_DOWN_KURNONE"), // 体重測定・スケジュール・ベッド指定ベッド→未登録
    IND_DIAL_013025_ORD_MAIN_U( "013025", "ord_main","U", "WEIGHT_MEASUREMENT_SCHEDULE_BED_SIGN_KURNONE"), // 体重測定・スケジュール・ベッド未登録→新たなベッド
    IND_DIAL_013026_ORD_MAIN_U( "013026", "ord_main","U", "WEIGHT_MEASUREMENT_SCHEDULE_BED_CHG_KURNONE"), // 体重測定・スケジュール・ベッド指定ベッド→新たなベッド
    // 013012欠番
    IND_DIAL_013013_ORD_MAIN_U( "013013", "ord_main","U", "WEIGHT_MEASUREMENT_TARE_CHG"), // 体重測定・デバイス・風袋
    IND_DIAL_013014_ORD_MAIN_U( "013014", "ord_main","U", "WEIGHT_MEASUREMENT_OFFWATER_CHG"), // 体重測定・デバイス・除水
    // 体重測定・スケジュール編集・#10125
    EXAM_ORD_013015_PAT_EXAM_MAIN_C( "013015", "pat_exam_main","C", "WEIGHT_MEASUREMENT_LINKED_C"), // 体重測定・スケジュール編集・クール未登録→それ以外
    EXAM_ORD_013016_PAT_EXAM_MAIN_D( "013016", "pat_exam_main","D", "WEIGHT_MEASUREMENT_LINKED_D"), // 体重測定・スケジュール編集・クール未登録以外→未登録
    EXAM_ORD_013017_PAT_EXAM_MAIN_U( "013017", "pat_exam_main","U", "WEIGHT_MEASUREMENT_LINKED_U"), // 体重測定・スケジュール編集・クール未登録以外→クール未登録以外
    PHY_ORD_013018_PAT_EXAM_MAIN_C( "013018", "pat_exam_main","C", "PHY_WEIGHT_MEASUREMENT_LINKED_C"), // 体重測定・スケジュール編集・クール未登録→それ以外
    PHY_ORD_013019_PAT_EXAM_MAIN_D( "013019", "pat_exam_main","D", "PHY_WEIGHT_MEASUREMENT_LINKED_D"), // 体重測定・スケジュール編集・クール未登録以外→未登録
    PHY_ORD_013020_PAT_EXAM_MAIN_U( "013020", "pat_exam_main","U", "PHY_WEIGHT_MEASUREMENT_LINKED_U"), // 体重測定・スケジュール編集・クール未登録以外→クール未登録以外
    RAD_ORD_013021_PAT_RAD_MAIN_C( "013021", "pat_rad_main","C", "WEIGHT_MEASUREMENT_LINKED_C"), // 体重測定・スケジュール編集・クール未登録→それ以外
    RAD_ORD_013022_PAT_RAD_MAIN_D( "013022", "pat_rad_main","D", "WEIGHT_MEASUREMENT_LINKED_D"), // 体重測定・スケジュール編集・クール未登録以外→未登録
    RAD_ORD_013023_PAT_RAD_MAIN_U( "013023", "pat_rad_main","U", "WEIGHT_MEASUREMENT_LINKED_U"), // 体重測定・スケジュール編集・クール未登録以外→クール未登録以外

    // 患者情報
//    IND_DIAL_031002_ORD_MAIN_D( "031002", "ord_main","D", "PAT_INFO"), // 死亡情報受信・患者の死亡に伴い送信済み未来日の予定の削除を送信
//    EXAM_ORD_031003_PAT_EXAM_MAIN_D("031003", "pat_exam_main", "D", "PAT_INFO"), // 死亡情報受信・患者の死亡に伴い送信済み未来日の予定の削除を送信
//    PHY_ORD_031013_PAT_EXAM_MAIN_D("031013", "pat_exam_main", "D", "PHY_PAT_INFO"), // 死亡情報受信・患者の死亡に伴い送信済み未来日の予定の削除を送信
//    RAD_ORD_031004_PAT_RAD_MAIN_D("031004", "pat_rad_main","D", "PAT_INFO"), // 死亡情報受信・患者の死亡に伴い送信済み未来日の予定の削除を送信
    IND_DIAL_008001_ORD_MAIN_U( "008001", "ord_main","U", "DATA_LIST_PAT_INFO_DW"), // データリスト・データリスト・身体情報（追加登録）情報を追加して保存されたら、影響している透析予約の電文を作成する

    //add #10901 死亡患者受信時処理について zrx start
    // 死亡情報受信・患者の死亡に伴い送信済み未来日の予定の削除を送信
    IND_DIAL_031002_ORD_MAIN_D( "031002", "ord_main","D", "PAT_DEATH_SCHEDULE_DELETE"),
    IND_DIAL_031007_ORD_MAIN_D( "031007", "ord_main","D", "PAT_DEATH_SCHEDULE_DELETE_KURNONE"),
    PHY_EXAM_ORD_031013_PAT_EXAM_MAIN_D("031013", "pat_exam_main", "D", "PHY_PAT_DEATH_DEATH_DELETE"),
    EXAM_ORD_031003_PAT_EXAM_MAIN_D("031003", "pat_exam_main", "D", "PAT_DEATH_DEATH_DELETE"),
    RAD_ORD_031004_PAT_RAD_MAIN_D( "031004", "pat_rad_main","D", "PAT_DEATH_DEATH_DELETE"),

    // add 12005 患者削除時の予定中止は行われるが検査依頼・一般撮影検査依頼の削除が行われない zkm start
    // 患者削除
    IND_DIAL_007020_ORD_MAIN_D( "007020", "ord_main","D", "PAT_DEL_SCHEDULE_DELETE"),
    IND_DIAL_007021_ORD_MAIN_D( "007021", "ord_main","D", "PAT_DEL_SCHEDULE_DELETE_KURNONE"),
    PHY_EXAM_ORD_007018_PAT_EXAM_MAIN_D("007018", "pat_exam_main", "D", "PHY_PAT_DEL_DEL_DELETE"),
    EXAM_ORD_007017_PAT_EXAM_MAIN_D("007017", "pat_exam_main", "D", "PAT_DEL_DEL_DELETE"),
    RAD_ORD_007019_PAT_RAD_MAIN_D( "007019", "pat_rad_main","D", "PAT_DEL_DEL_DELETE"),
    // add 12005 患者削除時の予定中止は行われるが検査依頼・一般撮影検査依頼の削除が行われない zkm end

    // 手動実績作成
    IND_DIAL_004039_ORD_MAIN_C( "004039", "ord_main","C", "PAT_VIEWER_SEND_COND_RESULT_CREATE"),

    // 体重測定・条件送信 特殊浄化
    IND_DIAL_013028_ORD_MAIN_C( "013028", "ord_main","C", "WEIGHT_MEASUREMENT_COND_SEND_SPECIAL_PURIFICATION"),
    //add #10901 死亡患者受信時処理について zrx end

    /**
     * 検査依頼
     */
    EXAM_ORD_021001_PAT_EXAM_MAIN_C("021001", "pat_exam_main", "C", "EXAM_REQUEST_LIST_C"), // 検査オーダ	検査依頼一覧・その日の透析区分（透析前、透析後、その他）で最初の指示だった場合
    EXAM_ORD_021002_PAT_EXAM_MAIN_U("021002", "pat_exam_main", "U", "EXAM_REQUEST_LIST_U"), // 検査オーダ	検査依頼一覧・その日の透析区分（透析前、透析後、その他）で既に指示があった場合
    EXAM_ORD_021003_PAT_EXAM_MAIN_U("021003", "pat_exam_main", "U", "EXAM_REQUEST_LIST_OTH"), // 検査オーダ	検査依頼一覧・その日の同じ透析区分（透析前、透析後、その他）で他に指示があった場合
    EXAM_ORD_021004_PAT_EXAM_MAIN_D("021004", "pat_exam_main", "D", "EXAM_REQUEST_LIST_D"), // 検査オーダ	検査依頼一覧・その日の透析区分（透析前、透析後、その他）で指示がなくなる場合
    EXAM_ORD_021005_PAT_EXAM_MAIN_C("021005", "pat_exam_main", "C", "EXAM_REQUEST_C"), // 検査オーダ	検査依頼・その日の透析区分（透析前、透析後、その他）で最初の指示だった場合
    EXAM_ORD_021006_PAT_EXAM_MAIN_U("021006", "pat_exam_main", "U", "EXAM_REQUEST_U"), // 検査オーダ	検査依頼・その日の透析区分（透析前、透析後、その他）で既に指示があった場合
    EXAM_ORD_021007_PAT_EXAM_MAIN_U("021007", "pat_exam_main", "U", "EXAM_REQUEST_OTH"), // 検査オーダ	検査依頼・その日の同じ透析区分（透析前、透析後、その他）で他に指示があった場合
    EXAM_ORD_021008_PAT_EXAM_MAIN_D("021008", "pat_exam_main", "D", "EXAM_REQUEST_D"), // 検査オーダ	検査依頼・その日の透析区分（透析前、透析後、その他）で指示がなくなる場合

    // 検査オーダ
    PHY_ORD_021011_PAT_EXAM_MAIN_C("021011", "pat_exam_main", "C", "PHY_EXAM_REQUEST_LIST_C"), // 検査オーダ	検査依頼一覧・その日の透析区分（透析前、透析後、その他）で最初の指示だった場合
    PHY_ORD_021014_PAT_EXAM_MAIN_D("021014", "pat_exam_main", "D", "PHY_EXAM_REQUEST_LIST_D"), // 検査オーダ	検査依頼一覧・その日の透析区分（透析前、透析後、その他）で指示がなくなる場合
    PHY_ORD_021015_PAT_EXAM_MAIN_C("021015", "pat_exam_main", "C", "PHY_EXAM_REQUEST_C"), // 検査オーダ	検査依頼・その日の透析区分（透析前、透析後、その他）で最初の指示だった場合
    PHY_ORD_021018_PAT_EXAM_MAIN_D("021018", "pat_exam_main", "D", "PHY_EXAM_REQUEST_D"), // 検査オーダ	検査依頼・その日の透析区分（透析前、透析後、その他）で指示がなくなる場合

    /**
     * 放射線検査依頼
     */
    RAD_ORD_022001_PAT_RAD_MAIN_C("022001", "pat_rad_main","C", "RAD_REQUEST_LIST_C"), // 一般撮影検査オーダ・一般撮影検査依頼一覧・その日の最初の指示だった場合
    RAD_ORD_022004_PAT_RAD_MAIN_D("022004", "pat_rad_main","D", "RAD_REQUEST_LIST_D"), // 一般撮影検査オーダ・一般撮影検査依頼一覧・その日の指示がなくなる場合
    RAD_ORD_022005_PAT_RAD_MAIN_C("022005", "pat_rad_main","C", "RAD_REQUEST_C"), // 一般撮影検査オーダ・一般撮影検査依頼・その日の最初の指示だった場合
    RAD_ORD_022008_PAT_RAD_MAIN_D("022008", "pat_rad_main","D", "RAD_REQUEST_D"), // 一般撮影検査オーダ・一般撮影検査依頼・その日の指示がなくなる場合

    // 患者経過総合ビューア
    RAD_ORD_022009_PAT_RAD_MAIN_C("022009", "pat_rad_main","C", "option"), // 患者経過総合ビューア・スケジュール・検査日の同じ日の透析予約が別日へ移動が発生した時、追従設定だった場合
    RAD_ORD_022010_PAT_RAD_MAIN_D("022010", "pat_rad_main","D", "option"), // 患者経過総合ビューア・スケジュール・検査日の同じ日の透析予約が別日へ移動が発生した時、削除設定だった場合

    //add 11217 検査予定に関する連携イベント作成不備 #10125からの分割 zrx start
    /**
     * マスタ編集
     */
    //検査項目マスタ
    EXAM_ORD_900007_PAT_EXAM_MAIN_U("900007", "pat_exam_main", "U", "MST_EXAM_ITEM_MST"),
    PHY_ORD_900017_PAT_EXAM_MAIN_U("900017", "pat_exam_main", "U", "PHY_MST_EXAM_ITEM_MST"),
    //検査セットマスタ
    EXAM_ORD_900008_PAT_EXAM_MAIN_U("900008", "pat_exam_main", "U", "MST_EXAM_SET_MST"),
    PHY_ORD_900018_PAT_EXAM_MAIN_U("900018", "pat_exam_main", "U", "PHY_MST_EXAM_SET_MST"),
    EXAM_ORD_900009_PAT_EXAM_MAIN_D("900009", "pat_exam_main", "D", "MST_EXAM_SET_MST"),
    PHY_ORD_900019_PAT_EXAM_MAIN_D("900019", "pat_exam_main", "D", "PHY_MST_EXAM_SET_MST"),
    //一般撮影検査依頼マスタ
    RAD_ORD_900021_PAT_RAD_MAIN_D("900021", "pat_rad_main", "D", "MST_RAD_SET_MST"),
    RADORD_900020_PAT_RAD_MAIN_U("900020", "pat_rad_main", "U", "MST_RAD_SET_MST"),
    //add 11217 検査予定に関する連携イベント作成不備 #10125からの分割 zrx end

    /**
     * 指示受け・指示承認
     */
    IND_DIAL_028001_PAT_IND_APPROVE_U( "028001", "pat_ind_approve","U", "PAT_IND_APPROVE_IMPLEMENT"), // 指示受け・指示承認・指示受け・治療単位モード時・指示受け実施時（１，２とも）
    IND_DIAL_028002_PAT_IND_APPROVE_U( "028002", "pat_ind_approve","U", "PAT_IND_APPROVE_PIC_CHG"), // 指示受け・指示承認・指示受け・治療単位モード時・指示受け者変更時（１，２とも）
    IND_DIAL_028003_PAT_IND_APPROVE_U( "028003", "pat_ind_approve","U", "PAT_IND_APPROVE_CANCEL"), // 指示受け・指示承認・指示受け・治療単位モード時・指示受け取り消し（１，２とも）
    IND_DIAL_028012_PAT_IND_APPROVE_U( "028012", "pat_ind_approve","U", "PAT_IND_APPROVE_IMPLEMENT_ALL1"), // 指示受け・指示承認・指示受け・治療単位モード時・指示受け１一括指示受け
    IND_DIAL_028013_PAT_IND_APPROVE_U( "028013", "pat_ind_approve","U", "PAT_IND_APPROVE_IMPLEMENT_ALL2"), // 指示受け・指示承認・指示受け・治療単位モード時・指示受け２一括指示受け

    // 日次処理
    IND_DIAL_900001_ORD_MAIN_C( "900001", "ord_main","C", "SCHEDULE_EXTEND_ORD_MAIN"), // 日次処理（透析予定）・日次処理のスケジュール延長により透析予定が追加されたら追加分の電文を作成する
    EXAM_ORD_900002_PAT_EXAM_MAIN_C("900002", "pat_exam_main", "C", "SCHEDULE_EXTEND_PAT_EXAM_MAIN"), // 日次処理（検査オーダ）・日次処理のスケジュール延長により検査オーダが追加されたら追加分の電文を作成する
    PHY_ORD_900012_PAT_EXAM_MAIN_C("900012", "pat_exam_main", "C", "PHY_SCHEDULE_EXTEND_PAT_EXAM_MAIN"), // 日次処理（検査オーダ）・日次処理のスケジュール延長により検査オーダが追加されたら追加分の電文を作成する
    RAD_ORD_900003_PAT_RAD_MAIN_C("900003", "pat_rad_main","C", "SCHEDULE_EXTEND_PAT_RAD_MAIN"); // 日次処理（放射線オーダ）・日次処理のスケジュール延長により一般撮影検査オーダが追加されたら追加分の電文を作成する

    // 枚举常量的字段
    private final String opeId;
    private final String tablename;
    private final String crud;
    private final String option;

    private static final Map<String, String> opeIdMap = new HashMap<>();

    OPECDENUM(String opeId, String tablename, String crud, String option) {
      this.opeId = opeId;
      this.tablename = tablename;
      this.crud = crud;
      this.option = option;
    }

    static {
      initializeOpeIdMap();
    }

    private static void initializeOpeIdMap() {
      for (OPECDENUM myEnum : OPECDENUM.values()) {
        String key = myEnum.tablename + "_" + myEnum.crud + "_" + myEnum.option;
        opeIdMap.put(key, myEnum.opeId);
      }
    }

    public String getOpeId() {
      return opeId;
    }

    public String getTablename() {
      return tablename;
    }

    public String getCrud() {
      return crud;
    }

    public String getOption() {
      return option;
    }

    public static String getOpeIdByCrudTablenameOption(String tablename,String crud, String option) {
      String key = tablename + "_" + crud + "_" + option;
      return opeIdMap.get(key);
    }

  }
}
