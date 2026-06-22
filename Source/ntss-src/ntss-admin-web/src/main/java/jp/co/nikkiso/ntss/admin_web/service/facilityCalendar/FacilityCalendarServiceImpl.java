package jp.co.nikkiso.ntss.admin_web.service.facilityCalendar;

import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.ObjectMapper;
import com.google.common.base.Strings;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.BbsInfoDao;
import jp.co.nikkiso.ntss.core.dao.FacilityCalendarDao;
import jp.co.nikkiso.ntss.core.dao.MntMotionRecordDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityCalendarLayoutDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatEventDao;
import jp.co.nikkiso.ntss.core.dao.PatExamMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatRadMainDao;
import jp.co.nikkiso.ntss.core.dao.PatUniqueDao;
import jp.co.nikkiso.ntss.core.entity.MntMotionRecordEntity;
import jp.co.nikkiso.ntss.core.entity.MstFacilityCalendarLayout;
import jp.co.nikkiso.ntss.core.entity.PatEvent;
import jp.co.nikkiso.ntss.core.entity.PatExamMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatRadMain;
import jp.co.nikkiso.ntss.core.entity.PatUnique;
import jp.co.nikkiso.ntss.core.entity.TreatDatePatIdList;
import jp.co.nikkiso.ntss.core.entity.custom.dataFacilityCalendar.FacilityCalendar;
import jp.co.nikkiso.ntss.core.entity.custom.dataFacilityCalendar.FacilityCalendarExtends;
import jp.co.nikkiso.ntss.core.entity.custom.dataFacilityCalendar.ItemFacilityCalendar;
import jp.co.nikkiso.ntss.core.entity.custom.dataFacilityCalendar.NumberOfBbsInfo;
import jp.co.nikkiso.ntss.core.entity.custom.dataFacilityCalendar.NumberOfInspectionResult;
import jp.co.nikkiso.ntss.core.entity.custom.dataFacilityCalendar.NumberOfInspectionResultExtends;
import jp.co.nikkiso.ntss.core.entity.custom.dataFacilityCalendar.NumberOfPat;
import jp.co.nikkiso.ntss.core.entity.custom.dataFacilityCalendar.NumberTreatmentsByCourse;
import jp.co.nikkiso.ntss.core.entity.custom.dataFacilityCalendar.SelfDiagnosisResult;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class FacilityCalendarServiceImpl implements FacilityCalendarService {

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
  @Autowired
  private LogService logService;
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end

	// 透析情報DAOクラス
	@Autowired
  OrdMainDao ordMainDao;

	// パット個人メインダオ
	@Autowired
  PatPersonalMainDao patPersonalMainDao;

	// マスター施設カレンダーレイアウトDaoクラス
	@Autowired
  MstFacilityCalendarLayoutDao mstFacilityCalendarLayoutDao;

	// パットユニークダオ
	@Autowired
  PatUniqueDao patUniqueDao;

	// パット試験メインDAO
	@Autowired
  PatExamMainDao patExamMainDao;

	// 患者放射線メインダオ
	@Autowired
  PatRadMainDao patRadMainDao;

	// パットイベントダオ
	@Autowired
  PatEventDao patEventDao;

	// 掲示板登録情報DAO
	@Autowired
  BbsInfoDao bbsInfoDao;
	// 施設カレンダーDAO
	@Autowired
  FacilityCalendarDao facilityCalendarDao;

	//add FNSI6369自己診断結果が表示しない 周 start
  @Autowired
  MntMotionRecordDao mntMotionRecordDao;

  // mod #10063 by zhangruixue 2023-11-17 --start
//  final static String QUALIFIED_INSERT_CD = "- ";       //自己診断結果合格
//  final static String VIGILANT_INSERT_CD = "-  ";       //自己診断結果合格(注意)
//  final static String UNQUALIFIED_INSERT_CD = "-   ";   //自己診断結果不合格
  final static String QUALIFIED_INSERT_CD = "G100";       //自己診断結果合格
  final static String VIGILANT_INSERT_CD = "G102";       //自己診断結果合格(注意)
  final static String UNQUALIFIED_INSERT_CD = "G101";   //自己診断結果不合格
  // mod #10063 by zhangruixue 2023-11-17  --end
	//add FNSI6369自己診断結果が表示しない 周 end

  /* add by chamaojia 2023-11-07 [9717] 同じsqlのプロジェクトを統合するための定数の追加  --start */
  public final static Map<String, Integer> TREATMENT_CASES_COLLECTION_MAP = new HashMap<>(){
    {
      put(AdminWebConstant.FacilityCalendarItem.HD_TREATMENTS, 0);  // HD治療
      put(AdminWebConstant.FacilityCalendarItem.ECUM_TREATMENTS, 1);  // ECUM治療
      put(AdminWebConstant.FacilityCalendarItem.HDF_TREATMENTS, 2);  // HDF治療
      put(AdminWebConstant.FacilityCalendarItem.HF_TREATMENTS, 3);  // HF治療
      put(AdminWebConstant.FacilityCalendarItem.AFBF_TREATMENTS, 6);  // AFBF治療
      put(AdminWebConstant.FacilityCalendarItem.OHDF_TREATMENTS, 7);  // OHDF治療
      put(AdminWebConstant.FacilityCalendarItem.OHF_TREATMENTS, 8);  // OHF治療
      put(AdminWebConstant.FacilityCalendarItem.I_HDF_TREATMENTS_NUMBER, 10);  // I-HDF治療
    }
  };

  public final static Map<String, String> PAT_UNIQUE_NUMBER_COLLECTION_MAP = new HashMap<>(){
    {
      put(AdminWebConstant.FacilityCalendarItem.INTRODUCTIONS_NUMBER, "1");  // 導入
      put(AdminWebConstant.FacilityCalendarItem.MOVE_IN_NUMBER, "2");  // 転入
      put(AdminWebConstant.FacilityCalendarItem.MOVING_OUT_NUMBER, "3");  // 転出
      put(AdminWebConstant.FacilityCalendarItem.HOSPITALIZATIONS_NUMBER, "4");  // 入院
      put(AdminWebConstant.FacilityCalendarItem.DISCHARGES_NUMBER, "5");  // 退院
      put(AdminWebConstant.FacilityCalendarItem.OUTPATIENTS, "6");  // 外来
      put(AdminWebConstant.FacilityCalendarItem.WITHDRAWALS, "7");  // 離脱
      put(AdminWebConstant.FacilityCalendarItem.TRANSPLANTS_NUMBER, "8");  // 移植
      put(AdminWebConstant.FacilityCalendarItem.TEMPORARY_TRANSFERS_OUTS_NUMBER, "9");  // 一時転出(出)
      put(AdminWebConstant.FacilityCalendarItem.REJECTED_UNKNOWN_NUMBER, "10");  // 拒否・不明
    }
  };
  /* add by chamaojia 2023-11-07 [9717] 同じsqlのプロジェクトを統合するための定数の追加  --end */

	@Override
	public List<FacilityCalendar> getDataFacilityCalendar(String startDate, String endDate, Long facCalLayoutCd,
                                                        String facilityCd) {
		List<FacilityCalendar> listData = new ArrayList<>();
		MstFacilityCalendarLayout layout = mstFacilityCalendarLayoutDao.selectById(facCalLayoutCd);
		ObjectMapper objectMapper = new ObjectMapper();
		try {
			if (layout != null) {
				if (!Strings.isNullOrEmpty(layout.getDispItemInfo())) {
					List<Map<String, Object>> layoutItemInfo = objectMapper.readValue(layout.getDispItemInfo(),
							new TypeReference<List<Map<String, Object>>>() {
							});
                  /* modify by chamaojia 2023-11-07 [9717] 呼び出し方法を書き換え、最適化効果を実現  --start */
                  // sqlクエリの結果セットキャッシュ
//                  Map<String, Object> dataSetMap = new HashMap<>();
//                  layoutItemInfo.stream().forEach(item -> {
//                      if(Boolean.valueOf(String.valueOf(item.get("isDisp")))) {
//                          getItemFacilityCalendar(listData, item, startDate, endDate, facilityCd);
//                      }
//                  });
                  listData = getItemFacilityCalendar(layoutItemInfo, startDate, endDate, facilityCd);
                  /* modify by chamaojia 2023-11-07 [9717] 呼び出し方法を書き換え、最適化効果を実現  --end */
				}
			}
		} catch (Exception e) {
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
		return listData;
	}

  /* modify by chamaojia 2023-11-07 [9717] 呼び出し方法を書き換え、最適化効果を実現  --start */
  private List<FacilityCalendar> getItemFacilityCalendar(List<Map<String, Object>> layoutItemInfo
          , String startDate, String endDate, String facilityCd) {
    List<FacilityCalendar> listData = new ArrayList<>();
    FacilityCalendar fc = new FacilityCalendar();
    // 同じkey統合
    Map<String, List<Map<String, Object>>> keyMap = new LinkedHashMap<>();
    layoutItemInfo.forEach(data -> {
      if (Boolean.valueOf(String.valueOf(data.get("isDisp")))) {
        if (keyMap.containsKey(data.get("key").toString())) {
          keyMap.get(data.get("key").toString()).add(data);
        } else {
          keyMap.put(data.get("key").toString(), new ArrayList<>(Arrays.asList(data)));
        }
      }
    });

    // 治療件数に関する同じsql文の合併
    List<Integer> deviceModeCdList = new ArrayList<>();
    TREATMENT_CASES_COLLECTION_MAP.forEach((key, value) -> {
      if (keyMap.containsKey(key) && !keyMap.get(key).isEmpty()) {
        deviceModeCdList.add(value);
      }
    });
    List<ItemFacilityCalendar> treatmentCasesList = null;
    if (!deviceModeCdList.isEmpty()) {
      treatmentCasesList = ordMainDao.getTreatmentsByDeviceModeCd(startDate, endDate, facilityCd, deviceModeCdList);
    }

    // pat_uniqueテーブル件数に関する同じsql文のマージ
    List<String> moveInOutCdList = new ArrayList<>();
    PAT_UNIQUE_NUMBER_COLLECTION_MAP.forEach((key, value) -> {
      if (keyMap.containsKey(key) && !keyMap.get(key).isEmpty()) {
        moveInOutCdList.add(value);
      }
    });
    List<NumberOfPat> numberOfPatList = null;
    if (!moveInOutCdList.isEmpty()) {
      numberOfPatList = patUniqueDao.selectNumberOfInOrOut(startDate, endDate, facilityCd, moveInOutCdList);
    }

    for (String itemKey : keyMap.keySet()) {
      switch (itemKey) {
        // 全治療件数
        case AdminWebConstant.FacilityCalendarItem.TOTAL_TREATMENTS:
          List<ItemFacilityCalendar> ListTotalTreatments = ordMainDao.getTotalTreatments(startDate, endDate, facilityCd);
          if (! ListTotalTreatments.isEmpty()) {
            ListTotalTreatments.stream().forEach(t -> {
              FacilityCalendar fcItem = fc.clone();
              fcItem.setItemName(AdminWebConstant.FacilityCalendarItem.TOTAL_TREATMENTS);
              fcItem.setRouterPath(AdminWebConstant.Router.SCHEDULE_LIST);
              fcItem.setItemValue(t.getRstCount() + "/" + t.getIndCount());
              fcItem.setDate(t.getDate());
              fcItem.setUnit(AdminWebConstant.Unit.ITEM);
              listData.add(fcItem);
            });
          }
          break;
        // 透析治療件数
        case AdminWebConstant.FacilityCalendarItem.DIALYSIS_TREATMENTS:
          List<ItemFacilityCalendar> listTreatments = ordMainDao.getDialysisTreatments(startDate, endDate, facilityCd, 9);
          if (! listTreatments.isEmpty()) {
            listTreatments.stream().forEach(t -> {
              FacilityCalendar fcItem = fc.clone();
              fcItem.setItemName(AdminWebConstant.FacilityCalendarItem.DIALYSIS_TREATMENTS);
              fcItem.setRouterPath(AdminWebConstant.Router.SCHEDULE_LIST);
              fcItem.setItemValue(t.getRstCount() + "/" + t.getIndCount());
              fcItem.setDate(t.getDate());
              fcItem.setUnit(AdminWebConstant.Unit.ITEM);
              listData.add(fcItem);
            });
          }
          break;
        case AdminWebConstant.FacilityCalendarItem.HD_TREATMENTS:  // HD治療件数
        case AdminWebConstant.FacilityCalendarItem.ECUM_TREATMENTS:  // ECUM治療件数
        case AdminWebConstant.FacilityCalendarItem.HDF_TREATMENTS:  // HDF治療件数
        case AdminWebConstant.FacilityCalendarItem.HF_TREATMENTS:  // HF治療件数
        case AdminWebConstant.FacilityCalendarItem.AFBF_TREATMENTS:  // AFBF治療件数
        case AdminWebConstant.FacilityCalendarItem.OHDF_TREATMENTS:  // OHDF治療件数
        case AdminWebConstant.FacilityCalendarItem.OHF_TREATMENTS:  // OHF治療件数
        case AdminWebConstant.FacilityCalendarItem.I_HDF_TREATMENTS_NUMBER:  // I-HDF治療件数
          if (treatmentCasesList != null && treatmentCasesList.size() > 0) {
            List<ItemFacilityCalendar> itemFacilityCalendarList = treatmentCasesList.stream()
                    .filter(t -> t.getDeviceMode() == TREATMENT_CASES_COLLECTION_MAP.get(itemKey)).collect(Collectors.toList());
            if (! itemFacilityCalendarList.isEmpty()) {
              itemFacilityCalendarList.stream().forEach(t -> {
                FacilityCalendar fcItem = fc.clone();
                fcItem.setItemName(itemKey);
                fcItem.setRouterPath(AdminWebConstant.Router.SCHEDULE_LIST);
                // mod 11702 施設カレンダーで過去の集計件数が変わってしまう zkm start
//                fcItem.setItemValue(t.getRstCount() + "/" + t.getIndCount());
                fcItem.setItemValue(t.getRstCount() + "/" + (t.getIndCount() + t.getRstCount()));
                // mod 11702 施設カレンダーで過去の集計件数が変わってしまう zkm end
                fcItem.setDate(t.getDate());
                fcItem.setUnit(AdminWebConstant.Unit.ITEM);
                listData.add(fcItem);
              });
            }
          }
          break;
        // 特殊浄化治療件数
        case AdminWebConstant.FacilityCalendarItem.SPECIAL_PURIFICATION_TREATMENTS_NUMBER:
          List<ItemFacilityCalendar> listSpecialPurificationTreatments = ordMainDao.getSpecialPurificationTreatments(startDate, endDate, facilityCd, 9);
          if (! listSpecialPurificationTreatments.isEmpty()) {
            listSpecialPurificationTreatments.stream().forEach(t -> {
              FacilityCalendar fcItem = fc.clone();
              fcItem.setItemName(AdminWebConstant.FacilityCalendarItem.SPECIAL_PURIFICATION_TREATMENTS_NUMBER);
              fcItem.setRouterPath(AdminWebConstant.Router.SCHEDULE_LIST);
              fcItem.setItemValue(t.getRstCount() + "/" + t.getIndCount());
              fcItem.setDate(t.getDate());
              fcItem.setUnit(AdminWebConstant.Unit.ITEM);
              listData.add(fcItem);
            });
          }
          break;
        case AdminWebConstant.FacilityCalendarItem.OUTPATIENT_TREATMENTS:  // 外来患者治療件数
        case AdminWebConstant.FacilityCalendarItem.INPATIENT_TREATMENTS_NUMBER:  // 入院患者治療件数
          int inOutClass = itemKey.equals(AdminWebConstant.FacilityCalendarItem.OUTPATIENT_TREATMENTS) ? 0 : 1;
          // mod 障害票一覧_施設カレンダー 修正 chen start
//        mod  FNSI 外来/入院患者治療予定件数の不正 5886修正 shan start
          List<String> patIdOutList = patPersonalMainDao.selectPatInfoByInOutClassList(facilityCd, inOutClass);
          List<ItemFacilityCalendar> listOutpatientTreatments = ordMainDao.getTreatmentsByRstInOutClass(startDate, endDate, facilityCd, patIdOutList);
          // add 11702 施設カレンダーで過去の集計件数が変わってしまう zkm start
          List<ItemFacilityCalendar> listOutpatientRstTreatments = ordMainDao.getRstTreatmentsByInOutClass(startDate, endDate, facilityCd, inOutClass);
          // add 11702 施設カレンダーで過去の集計件数が変わってしまう zkm end
          List<String> treatDateList = new ArrayList<String>();
          for (int q = 0; q < listOutpatientTreatments.size(); q++) {
            treatDateList.add(listOutpatientTreatments.get(q).getDate());
          }
          List<TreatDatePatIdList> patIdList = ordMainDao.getTreatmentsTreatDate(treatDateList);
          /* add by chamaojia 2023-10-19 [9717] patIdを統合して再構築し、クエリを行う  --start */
          Set<String> patIdOutSet = new HashSet<>();
          for (TreatDatePatIdList patIdInOut : patIdList) {
            patIdOutSet.addAll(Arrays.asList(patIdInOut.getPatIdList().split(",")));
          }
          List<TreatDatePatIdList> treatDatePatIdOutAllList = patPersonalMainDao.selectPatInfoByInOutClassNew(facilityCd, inOutClass, new ArrayList<>(patIdOutSet));
          /* add by chamaojia 2023-10-19 [9717] patIdを統合して再構築し、クエリを行う  --end */
          for (int w = 0; w < patIdList.size(); w++) {
            List<String> split = Arrays.asList(patIdList.get(w).getPatIdList().split(","));
            /* modify by chamaojia 2023-10-19 [9717] 結果セットから直接データを取得するように変更 --start */
//          List<TreatDatePatIdList> treatDatePatIdList = patPersonalMainDao.selectPatInfoByInOutClassNew(facilityCd, 0, split);
            List<TreatDatePatIdList> treatDatePatIdList = treatDatePatIdOutAllList.stream()
                    .filter(d -> split.contains(d.getPatId().toString())).collect(Collectors.toList());
            /* modify by chamaojia 2023-10-19 [9717] 結果セットから直接データを取得するように変更 --end */
            int patCount = 0;
            for (int r = 0; r < treatDatePatIdList.size(); r++) {
              int count = 0;
              for (int t = 0; t < split.size(); t++) {
                if (split.get(t).equals(treatDatePatIdList.get(r).getPatId().toString())) {
                  count++;
                }

              }
              if (count > 0) {
                count -= 1;
              }
              patCount = patCount + treatDatePatIdList.get(r).getIndCount() + count;
            }
            patIdList.get(w).setIndCount(patCount);
          }
          // List<ItemFacilityCalendar> listOutpatientTreatments = ordMainDao.getTreatmentsByRstInOutClass(startDate, endDate, facilityCd, 0);
          // mod 障害票一覧_施設カレンダー 修正 chen end
//            ItemFacilityCalendar patOutClass = patPersonalMainDao.selectPatInfoByInOutClass(facilityCd, 0);
          if (! listOutpatientTreatments.isEmpty()) {
            listOutpatientTreatments.stream().forEach(t -> {
              FacilityCalendar fcItem = fc.clone();
//                int indCount = 0;
              patIdList.forEach(item -> {
                if (item.getTreatDate().equals(t.getDate())) {
                  t.setIndCount(item.getIndCount());
                }
              });

              // add 11702 施設カレンダーで過去の集計件数が変わってしまう zkm start
              Optional<ItemFacilityCalendar> rstTreatments = listOutpatientRstTreatments
                .stream().filter(rst -> rst.getDate().equals(t.getDate())).findAny();
              Integer rstCount = 0;
              if (rstTreatments.isPresent()) {
                rstCount = rstTreatments.get().getRstCount();
              }
              // add 11702 施設カレンダーで過去の集計件数が変わってしまう zkm end

              fcItem.setItemName(itemKey);
              fcItem.setRouterPath(AdminWebConstant.Router.SCHEDULE_LIST);
              //mod 5886 外来/入院患者治療予定件数の不正 吉 start
//					fcItem.setItemValue(t.getRstCount() + "/" + t.getIndCount());
              // mod 11702 施設カレンダーで過去の集計件数が変わってしまう zkm start
//              fcItem.setItemValue(String.valueOf(t.getRstCount() + "/" + t.getIndCount()));
              fcItem.setItemValue(String.valueOf(rstCount + "/" + (t.getIndCount() + rstCount)));
              // mod 11702 施設カレンダーで過去の集計件数が変わってしまう zkm end
              //mod 5886 外来/入院患者治療予定件数の不正 吉 end
              fcItem.setDate(t.getDate());
              fcItem.setUnit(AdminWebConstant.Unit.ITEM);
              listData.add(fcItem);
            });
          }
          break;
        // クール別治療件数
        case AdminWebConstant.FacilityCalendarItem.TREATMENTS_BY_COURSE_NUMBER:
          List<NumberTreatmentsByCourse> listTreatmentsByCourse = ordMainDao.getTreatmentsByCourse(startDate, endDate, facilityCd);
          if (! listTreatmentsByCourse.isEmpty()) {
            listTreatmentsByCourse.stream().forEach(t -> {
              FacilityCalendar fcItem = fc.clone();
              fcItem.setItemName(t.getKurName());
              fcItem.setRouterPath(AdminWebConstant.Router.SCHEDULE_LIST);
              fcItem.setItemValue(t.getRstKurCount() + "/" + t.getIndKurCount());
              fcItem.setDate(t.getTreatDate());
              fcItem.setUnit(AdminWebConstant.Unit.ITEM);
              listData.add(fcItem);
            });
          }
          break;
        case AdminWebConstant.FacilityCalendarItem.INTRODUCTIONS_NUMBER:  // 導入件数
        case AdminWebConstant.FacilityCalendarItem.MOVE_IN_NUMBER:  // 転入件数
        case AdminWebConstant.FacilityCalendarItem.MOVING_OUT_NUMBER:  // 転出件数
        case AdminWebConstant.FacilityCalendarItem.HOSPITALIZATIONS_NUMBER:  // 入院件数
        case AdminWebConstant.FacilityCalendarItem.DISCHARGES_NUMBER:  // 退院件数
        case AdminWebConstant.FacilityCalendarItem.OUTPATIENTS:  // 外来件数
        case AdminWebConstant.FacilityCalendarItem.WITHDRAWALS:  // 離脱件数
        case AdminWebConstant.FacilityCalendarItem.TRANSPLANTS_NUMBER:  // 移植件数
        case AdminWebConstant.FacilityCalendarItem.TEMPORARY_TRANSFERS_OUTS_NUMBER:  // 一時転出(出)件数
        case AdminWebConstant.FacilityCalendarItem.REJECTED_UNKNOWN_NUMBER:  // 拒否・不明件数
          if (numberOfPatList != null && numberOfPatList.size() > 0) {
            List<NumberOfPat> numberOfPatItemList = numberOfPatList.stream()
                    .filter(n -> PAT_UNIQUE_NUMBER_COLLECTION_MAP.get(itemKey).equals(n.getMoveInOutCd())).collect(Collectors.toList());
            if (! numberOfPatItemList.isEmpty()) {
              numberOfPatItemList.stream().forEach(i -> {
                FacilityCalendar fcItem = fc.clone();
                fcItem.setItemName(itemKey);
                fcItem.setRouterPath(AdminWebConstant.Router.PAT_INFO);
                fcItem.setItemValue(String.valueOf(i.getNumberOfPat()));
                fcItem.setDate(i.getDate());
                fcItem.setUnit(AdminWebConstant.Unit.PERSON);
                listData.add(fcItem);
              });
            }
          }
          break;
        // 一時転出(入)件数
        case AdminWebConstant.FacilityCalendarItem.TEMPORARY_TRANSFERS_IN_NUMBER:
          List<NumberOfPat> listItemOfInOutTemTranIn = patUniqueDao.selectNumberOfInOrOutByPeriodEnd(startDate,
                  endDate, facilityCd, String.valueOf(AdminWebConstant.NumberOfInOut.listItemInOut[8].getId()));
          if (! listItemOfInOutTemTranIn.isEmpty()) {
            listItemOfInOutTemTranIn.stream().forEach(i -> {
              FacilityCalendar fcItem = fc.clone();
              fcItem.setItemName(AdminWebConstant.FacilityCalendarItem.TEMPORARY_TRANSFERS_IN_NUMBER);
              fcItem.setRouterPath(AdminWebConstant.Router.PAT_INFO);
              fcItem.setItemValue(String.valueOf(i.getNumberOfPat()));
              fcItem.setDate(i.getDate());
              fcItem.setUnit(AdminWebConstant.Unit.PERSON);
              listData.add(fcItem);
            });
          }
          break;
        // 死亡件数
        case AdminWebConstant.FacilityCalendarItem.DEATHS:
          List<NumberOfPat> listPatDies = patPersonalMainDao.countDiePat(startDate, endDate, facilityCd);
          if (! listPatDies.isEmpty()) {
            listPatDies.stream().forEach(i -> {
              FacilityCalendar fcItem = fc.clone();
              fcItem.setItemName(AdminWebConstant.FacilityCalendarItem.DEATHS);
              fcItem.setRouterPath(AdminWebConstant.Router.PAT_INFO);
              fcItem.setItemValue(String.valueOf(i.getNumberOfPat()));
              fcItem.setDate(i.getDate());
              fcItem.setUnit(AdminWebConstant.Unit.PERSON);
              listData.add(fcItem);
            });
          }
          break;
        // 検査予定件数
        case AdminWebConstant.FacilityCalendarItem.SCHEDULED_NUMBER_INSPECTIONS:
          List<NumberOfPat> listPatExam = patExamMainDao.countPatExamByRegDate(startDate, endDate, facilityCd);
          if (! listPatExam.isEmpty()) {
            listPatExam.stream().forEach(i -> {
              FacilityCalendar fcItem = fc.clone();
              fcItem.setItemName(AdminWebConstant.FacilityCalendarItem.SCHEDULED_NUMBER_INSPECTIONS);
              fcItem.setRouterPath(AdminWebConstant.Router.EXAM_REQUEST);
              fcItem.setItemValue(String.valueOf(i.getNumberOfPat()));
              fcItem.setDate(i.getDate());
              fcItem.setUnit(AdminWebConstant.Unit.PERSON);
              listData.add(fcItem);
            });
          }
          break;
        // 放射線予定件数
        case AdminWebConstant.FacilityCalendarItem.EXPECTED_NUMBER_RADIATION:
          List<NumberOfPat> listPatRad = patRadMainDao.countPatRadByRegDate(startDate, endDate, facilityCd);
          if (! listPatRad.isEmpty()) {
            listPatRad.stream().forEach(i -> {
              FacilityCalendar fcItem = fc.clone();
              fcItem.setItemName(AdminWebConstant.FacilityCalendarItem.EXPECTED_NUMBER_RADIATION);
              fcItem.setRouterPath(AdminWebConstant.Router.RADIATION_REQUEST);
              fcItem.setItemValue(String.valueOf(i.getNumberOfPat()));
              fcItem.setDate(i.getDate());
              fcItem.setUnit(AdminWebConstant.Unit.PERSON);
              listData.add(fcItem);
            });
          }
          break;
        // 患者イベントカテゴリマスタ分繰り返す
        case AdminWebConstant.FacilityCalendarItem.REPEAT_PAT_EVENT_CATEGORY:
          List<Long> categoryCdList = keyMap.get(itemKey).stream().filter(c -> c.get("cd") != null)
                  .map(c -> Long.valueOf(c.get("cd").toString())).collect(Collectors.toList());
          if (categoryCdList != null && categoryCdList.size() > 0) {
            List<NumberOfPat> listPatEventSum = patEventDao.countPatByEventDate(startDate, endDate, facilityCd, categoryCdList);
            if (! listPatEventSum.isEmpty()) {
              listPatEventSum.stream().forEach(i -> {
                FacilityCalendar fcItem = fc.clone();
                fcItem.setItemName(AdminWebConstant.FacilityCalendarItem.REPEAT_PAT_EVENT_CATEGORY + ":" + i.getBusNo());
                // #9531_Q&A Mod by Zhou.tao 患者イベントサブカテゴリマスタ分繰り返す -> 患者イベントへ遷移する Start
                // fcItem.setRouterPath(AdminWebConstant.Router.PAT_INFO);
                fcItem.setRouterPath(AdminWebConstant.Router.PAT_EVENT);
                // #9531_Q&A Mod by Zhou.tao 患者イベントサブカテゴリマスタ分繰り返す -> 患者イベントへ遷移する End
                fcItem.setItemValue(String.valueOf(i.getNumberOfPat()));
                fcItem.setDate(i.getDate());
                fcItem.setUnit(AdminWebConstant.Unit.PERSON);
                listData.add(fcItem);
              });
            }
          }
          break;
        // 患者イベントサブカテゴリマスタ分繰り返す
        case AdminWebConstant.FacilityCalendarItem.REPEAT_PAT_EVENT_SUBCATEGORY:
          List<Long> subCategoryCdList = keyMap.get(itemKey).stream().filter(c -> c.get("cd") != null)
                  .map(c -> Long.valueOf(c.get("cd").toString())).collect(Collectors.toList());
          if (subCategoryCdList != null && subCategoryCdList.size() > 0) {
            List<NumberOfPat> listPatEventSubSum = patEventDao.countPatByEventDateWithSubCate(startDate, endDate
                    , facilityCd, subCategoryCdList);
            if (!listPatEventSubSum.isEmpty()) {
              listPatEventSubSum.stream().forEach(i -> {
                FacilityCalendar fcItem = fc.clone();
                fcItem.setItemName(AdminWebConstant.FacilityCalendarItem.REPEAT_PAT_EVENT_SUBCATEGORY + ":" + i.getBusNo());
                // #9531_Q&A Mod by Zhou.tao 患者イベントサブカテゴリマスタ分繰り返す -> 患者イベントへ遷移する Start
                // fcItem.setRouterPath(AdminWebConstant.Router.PAT_INFO);
                fcItem.setRouterPath(AdminWebConstant.Router.PAT_EVENT);
                // #9531_Q&A Mod by Zhou.tao 患者イベントサブカテゴリマスタ分繰り返す -> 患者イベントへ遷移する End
                fcItem.setItemValue(String.valueOf(i.getNumberOfPat()));
                fcItem.setDate(i.getDate());
                fcItem.setUnit(AdminWebConstant.Unit.PERSON);
                listData.add(fcItem);
              });
            }
          }
          break;
        //自己診断結果
        case AdminWebConstant.FacilityCalendarItem.SELF_DIAGNOSIS_RESULT:
          // add FNSI-改修内容 自己診断結果：合格xx台、不合格xx台、未実施xx台 dou start
          //mod FNSI6369自己診断結果が表示しない 周 start
          int selfDiagnosisCount = facilityCalendarDao
                  .countSelfDiagnosisMachinesCount(facilityCd);
          List<FacilityCalendar> calList = new ArrayList<>();
          String loopDate = startDate;
          // mod bug 6369 修正 chen start
          // while (-1 == loopDate.compareTo(endDate)) {
          while (loopDate.compareTo(endDate) < 0) {
            // mod bug 6369 修正 chen end
            FacilityCalendar fcItem = fc.clone();
            fcItem.setDate(loopDate);

            // #9531 Added zhou.tao 遠隔監視画面のルータを設定する Start
            fcItem.setRouterPath(AdminWebConstant.Router.OPERATION_VIEWER);
            fcItem.setItemName("自己診断結果");
            fcItem.setStartDate("");
            // #9531 Added zhou.tao 遠隔監視画面のルータを設定する End

            calList.add(fcItem);
            loopDate = DateTimeFormatter.ofPattern("uuuuMMdd").format(LocalDate.parse(loopDate, DateTimeFormatter.ofPattern("uuuuMMdd")).plusDays(1));
          }
          //mod FNSI6369自己診断結果が表示しない 周 start
          SimpleDateFormat sdf = new SimpleDateFormat("YYYYMMdd");
          List<String> montionRecordList = new ArrayList<>();
          montionRecordList.add(QUALIFIED_INSERT_CD);
          montionRecordList.add(VIGILANT_INSERT_CD);
          montionRecordList.add(UNQUALIFIED_INSERT_CD);
          List<MntMotionRecordEntity> mntMotionRecordList =
                  mntMotionRecordDao.selectMntMotionRecord(facilityCd, startDate, endDate, montionRecordList);
          // del FNSI7801-合格しているのにもかかわらず不合格としてカウントされる。 房 start
          // mntMotionRecordList.sort(Comparator.comparing(MntMotionRecordEntity::getMachineSerial));
          // mod FNSI7367-自己診断結果の合格/不合格の集計が更新されない begin
          // mntMotionRecordList.sort(Comparator.comparing(MntMotionRecord::getEventRegDate).reversed());
          // mntMotionRecordList.sort(Comparator.comparing(MntMotionRecordEntity::getEventupdate).reversed());
          // mod FNSI7367-自己診断結果の合格/不合格の集計が更新されない end
          // del FNSI7801-合格しているのにもかかわらず不合格としてカウントされる。 房 end

          List<MntMotionRecordEntity> newMntMotionRecordList = new ArrayList<>();
          String machineSerial = "";
          String regDate = "";

          if(null != mntMotionRecordList && !mntMotionRecordList.isEmpty()) {
            for(MntMotionRecordEntity elem : mntMotionRecordList) {
              // mod FNSI7367-自己診断結果の合格/不合格の集計が更新されない begin
              // mod FNSI7801-合格しているのにもかかわらず不合格としてカウントされる。 chen start
              String elemDate = sdf.format(elem.getEventRegDate());
              // String elemDate = sdf.format(elem.getEventupdate());
              // mod FNSI7801-合格しているのにもかかわらず不合格としてカウントされる。 chen end
              // mod FNSI7367-自己診断結果の合格/不合格の集計が更新されない end
              if(0 != regDate.compareTo(elemDate) || 0 != machineSerial.compareTo(elem.getMachineSerial())) {
                regDate = elemDate;
                machineSerial = elem.getMachineSerial();
                newMntMotionRecordList.add(elem);
              }
            };
          }

          regDate = "";
          // mod FNSI7367-自己診断結果の合格/不合格の集計が更新されない begin
          // mod FNSI7801-合格しているのにもかかわらず不合格としてカウントされる。 chen start
          //newMntMotionRecordList.sort(Comparator.comparing(MntMotionRecord::getEventRegDate).reversed());
          // newMntMotionRecordList.sort(Comparator.comparing(MntMotionRecordEntity::getEventupdate).reversed());
          newMntMotionRecordList.sort(Comparator.comparing(MntMotionRecordEntity::getEventRegDate).reversed());
          // mod FNSI7801-合格しているのにもかかわらず不合格としてカウントされる。 chen end
          // mod FNSI7367-自己診断結果の合格/不合格の集計が更新されない end
          int okCount = 0;
          int okNotCount = 0;
          SelfDiagnosisResult okResult = new SelfDiagnosisResult();
          int ngCount = 0;
          int ngNotCount = 0;
          SelfDiagnosisResult ngResult = new SelfDiagnosisResult();
          int warnCount = 0;
          int warnNotCount = 0;
          SelfDiagnosisResult warnResult = new SelfDiagnosisResult();
          List<String> listStr = new ArrayList<>();
          List<SelfDiagnosisResult> selfDiagnosisResults = new ArrayList<>();
          for(MntMotionRecordEntity elem : newMntMotionRecordList) {
            // mod FNSI7367-自己診断結果の合格/不合格の集計が更新されない begin
            // mod FNSI7801-合格しているのにもかかわらず不合格としてカウントされる。 chen start
            String elemDate = sdf.format(elem.getEventRegDate());
            // String elemDate = sdf.format(elem.getEventupdate());
            // mod FNSI7801-合格しているのにもかかわらず不合格としてカウントされる。 chen end
            // mod FNSI7367-自己診断結果の合格/不合格の集計が更新されない end

            if(0 != regDate.compareTo(elemDate)) {
              regDate = elemDate;
              if(0 != newMntMotionRecordList.indexOf(elem)) {
                selfDiagnosisResults.add(okResult);
                selfDiagnosisResults.add(ngResult);
                selfDiagnosisResults.add(warnResult);
              }

              okCount = 0;
              okNotCount = selfDiagnosisCount - okCount;
              okResult = new SelfDiagnosisResult();
              okResult.setRegDate(elemDate);
              okResult.setMachineRecordCd(QUALIFIED_INSERT_CD);
              okResult.setResultCount(String.valueOf(okCount));
              okResult.setNotDoneCount(String.valueOf(okNotCount));

              ngCount = 0;
              ngNotCount = selfDiagnosisCount - ngCount;
              ngResult = new SelfDiagnosisResult();
              ngResult.setRegDate(elemDate);
              ngResult.setMachineRecordCd(UNQUALIFIED_INSERT_CD);
              ngResult.setResultCount(String.valueOf(ngCount));
              ngResult.setNotDoneCount(String.valueOf(ngNotCount));

              warnCount = 0;
              warnNotCount = selfDiagnosisCount - warnCount;
              warnResult = new SelfDiagnosisResult();
              warnResult.setRegDate(elemDate);
              warnResult.setMachineRecordCd(VIGILANT_INSERT_CD);
              warnResult.setResultCount(String.valueOf(warnCount));
              warnResult.setNotDoneCount(String.valueOf(warnNotCount));
              listStr.clear();
            }
            if(!listStr.contains(elem.getMachineSerial())){
              switch (elem.getMachineRecordCd()) {
                case QUALIFIED_INSERT_CD:
                  okCount++;
                  okNotCount = selfDiagnosisCount - okCount;
                  okResult.setResultCount(String.valueOf(okCount));
                  okResult.setNotDoneCount(String.valueOf(okNotCount));
                  listStr.add(elem.getMachineSerial());
                  break;
                case VIGILANT_INSERT_CD:
                  warnCount++;
                  warnNotCount = selfDiagnosisCount - warnCount;
                  warnResult.setResultCount(String.valueOf(warnCount));
                  warnResult.setNotDoneCount(String.valueOf(warnNotCount));
                  // add FNSI7228-自己診断結果：合格（注意）のカウント不正 周 start
                  okCount++;
                  okResult.setResultCount(String.valueOf(okCount));
                  // add FNSI7228-自己診断結果：合格（注意）のカウント不正 周 end
                  listStr.add(elem.getMachineSerial());
                  break;
                case UNQUALIFIED_INSERT_CD:
                  ngCount++;
                  ngNotCount = selfDiagnosisCount - ngCount;
                  ngResult.setResultCount(String.valueOf(ngCount));
                  ngResult.setNotDoneCount(String.valueOf(ngNotCount));
                  listStr.add(elem.getMachineSerial());
                  break;
                default:
                  break;
              }
            }
          };

          // mod FNSI5415-カレンダー内のセルの表示に時間がかかる 周 start
          if(okCount > 0) {
            selfDiagnosisResults.add(okResult);
          }
          if(ngCount > 0) {
            selfDiagnosisResults.add(ngResult);
          }
          if(warnCount > 0) {
            selfDiagnosisResults.add(warnResult);
          }
          if((okCount + ngCount + warnCount) > 0) {
            selfDiagnosisResults.sort(Comparator.comparing(SelfDiagnosisResult::getRegDate));
          }
          // mod FNSI5415-カレンダー内のセルの表示に時間がかかる 周 end

          if (! selfDiagnosisResults.isEmpty()) {
            selfDiagnosisResults.stream().forEach(i -> {
              calList.stream().forEach(j -> {
                if (j.getDate().equals(i.getRegDate())) {
                  // #9531 Del By Zhou.tao unnecessary setting
//                    j.setItemName(i.getMachineRecordCd());
//                    j.setRouterPath(AdminWebConstant.Router.OPERATION_VIEWER);
                  j.setItemValue(i.getResultCount());
                  j.setStartDate(i.getNotDoneCount());
                }
              });
            });
            List<List<FacilityCalendar>> fcGroupList = new ArrayList<>();
            calList.stream().collect(Collectors.groupingBy(FacilityCalendar::getDate, Collectors.toList()))
                    .forEach((date, listByDate) -> {
                      fcGroupList.add(listByDate);
                    });
            List<FacilityCalendar> calList2 = new ArrayList<>();
            fcGroupList.stream().forEach(x -> {
              FacilityCalendar calendar = x.get(0);
              String okCountStr = "0";
              String ngCountStr = "0";
              String warnCountStr = "0";
              for (int i = 0; i < selfDiagnosisResults.size(); i++) {
                if (calendar.getDate().equals(selfDiagnosisResults.get(i).getRegDate())) {
                  switch (selfDiagnosisResults.get(i).getMachineRecordCd()) {
                    case QUALIFIED_INSERT_CD:
                      okCountStr = selfDiagnosisResults.get(i).getResultCount();
                      break;
                    case UNQUALIFIED_INSERT_CD:
                      ngCountStr = selfDiagnosisResults.get(i).getResultCount();
                      break;
                    case VIGILANT_INSERT_CD:
                      warnCountStr = selfDiagnosisResults.get(i).getResultCount();
                      break;
                    default:
                      break;
                  }
                }
              }
              // mod FNSI7228-自己診断結果：合格（注意）のカウント不正 周 start
//            String str = " 合格 " + okCountStr + "台(注意 " + warnCountStr + "台)、不合格 "
//              + ngCountStr + "台、未実施 " + (selfDiagnosisCount - Integer.valueOf(okCountStr) - Integer.valueOf(warnCountStr) - Integer.valueOf(ngCountStr)) + "台";
              String str = " 合格 " + okCountStr + "台(注意 " + warnCountStr + "台)、不合格 "
                      + ngCountStr + "台、未実施 " + (selfDiagnosisCount - Integer.valueOf(okCountStr) - Integer.valueOf(ngCountStr)) + "台";
              // mod FNSI7228-自己診断結果：合格（注意）のカウント不正 周 end

              // #9531 Del By Zhou.tao unnecessary setting
//                calendar.setItemName("自己診断結果");
//                calendar.setStartDate("");
              calendar.setItemValue(str);

              calList2.add(calendar);
            });
            calList2.stream().forEach(x -> listData.add(x));
          } else {
            List<FacilityCalendar> calList2 = new ArrayList<>();
            calList.stream().forEach(k -> {
              String str = " 合格 0台(注意 0台)、不合格 0台、未実施 " + selfDiagnosisCount + "台";

              // #9531 Del By Zhou.tao unnecessary setting
//                k.setItemName("自己診断結果");
//                k.setStartDate("");
              k.setItemValue(str);

              calList2.add(k);
            });
            calList2.stream().forEach(x -> listData.add(x));
          }
//        List<SelfDiagnosisResult> selfDiagnosisResults = facilityCalendarDao
//          .countSelfDiagnosisResult(startDate, endDate, facilityCd);
//        if (! selfDiagnosisResults.isEmpty()) {
//          selfDiagnosisResults.stream().forEach(i -> {
//            calList.stream().forEach(j -> {
//              if (j.getDate().equals(i.getRegDate())) {
//                j.setItemName(i.getMachineRecordCd());
//                j.setRouterPath(AdminWebConstant.Router.OPERATION_VIEWER);
//                j.setItemValue(i.getResultCount());
//                j.setStartDate(i.getNotDoneCount());
//              }
//            });
//          });
//          List<List<FacilityCalendar>> fcGroupList = new ArrayList<>();
//          calList.stream().collect(Collectors.groupingBy(FacilityCalendar::getDate, Collectors.toList()))
//            .forEach((date, listByDate) -> {
//              fcGroupList.add(listByDate);
//            });
//          List<FacilityCalendar> calList2 = new ArrayList<>();
//          fcGroupList.stream().forEach(x -> {
//            FacilityCalendar calendar = x.get(0);
//            //String notDoneCount = calendar.getStartDate();
//            String okCount = "0";
//            String ngCount = "0";
//            String warnCount = "0";
//            for (int i = 0; i < selfDiagnosisResults.size(); i++) {
//              if (calendar.getDate().equals(selfDiagnosisResults.get(i).getRegDate())) {
//                switch (selfDiagnosisResults.get(i).getMachineRecordCd()) {
//                  case "- ":
//                    okCount = selfDiagnosisResults.get(i).getResultCount();
//                    break;
//                  case "-   ":
//                    ngCount = selfDiagnosisResults.get(i).getResultCount();
//                    break;
//                  case "-  ":
//                    warnCount = selfDiagnosisResults.get(i).getResultCount();
//                    break;
//                  default:
//                    break;
//                }
//              }
//            }
//            String str = " 合格 " + okCount + "台(注意 " + warnCount + "台)、不合格 "
//              + ngCount + "台、未実施 " + (selfDiagnosisCount - Integer.valueOf(okCount) - Integer.valueOf(warnCount) - Integer.valueOf(ngCount)) + "台";
//            calendar.setItemName("自己診断結果");
//            calendar.setItemValue(str);
//            calendar.setStartDate("");
//            calList2.add(calendar);
//          });
//          calList2.stream().forEach(x -> listData.add(x));
//        } else {
//          List<FacilityCalendar> calList2 = new ArrayList<>();
//          calList.stream().forEach(k -> {
//            String str = " 合格 0台(注意 0台)、不合格 0台、未実施 " + selfDiagnosisCount + "台";
//            k.setItemName("自己診断結果");
//            k.setItemValue(str);
//            k.setStartDate("");
//            calList2.add(k);
//          });
//          calList2.stream().forEach(x -> listData.add(x));
//        }
          //mod FNSI6369自己診断結果が表示しない 周 end


//      List<SelfDiagnosisResult> selfDiagnosisResults = facilityCalendarDao
//          .countSelfDiagnosisResult(startDate, endDate, facilityCd);
//      if (!selfDiagnosisResults.isEmpty()) {
//        List<FacilityCalendar> calendarList = new ArrayList<>();
//        selfDiagnosisResults.stream().forEach(i -> {
//          FacilityCalendar fcItem = fc.clone();
//          fcItem.setItemName(i.getMachineRecordCd());
//          fcItem.setRouterPath(AdminWebConstant.Router.OPERATION_VIEWER);
//          fcItem.setItemValue(i.getResultCount());
//          fcItem.setDate(i.getRegDate());
//          fcItem.setStartDate(i.getNotDoneCount());
//          calendarList.add(fcItem);
//        });
//        List<List<FacilityCalendar>> groupList = new ArrayList<>();
//        calendarList.stream().collect(Collectors.groupingBy(FacilityCalendar::getDate,Collectors.toList()))
//          .forEach((date, listByDate)->{
//            groupList.add(listByDate);
//          });
//        List<FacilityCalendar> calendarList2 = new ArrayList<>();
//        groupList.stream().forEach(x -> {
//          FacilityCalendar calendar = x.get(0);
//          String notDoneCount = calendar.getStartDate();
//          String okCount = "0";
//          String ngCount = "0";
//          String warnCount = "0";
//          for (int i = 0; i < x.size(); i++) {
//            switch (x.get(i).getItemName()) {
//              case "G100":
//                okCount = x.get(i).getItemValue();
//                break;
//              case "G101":
//                ngCount = x.get(i).getItemValue();
//                break;
//              case "G102":
//                warnCount = x.get(i).getItemValue();
//                break;
//              default:
//                break;
//            }
//          }
//          String str = " 合格 " + okCount + "台(注意 " + warnCount + "台)、不合格 "
//            + ngCount + "台、未実施 " + notDoneCount + "台";
//          calendar.setItemName("自己診断結果");
//          calendar.setItemValue(str);
//          calendar.setStartDate("");
//          calendarList2.add(calendar);
//        });
//        calendarList2.stream().forEach(x -> listData.add(x));
//      }
          //mod FNSI6369自己診断結果が表示しない 周 end
          // add FNSI-改修内容 自己診断結果：合格xx台、不合格xx台、未実施xx台 dou end
          break;
        // 日常点検列名分繰り返す
        // mod #9552 日常点検の個別選択ができない 商 end
        // case AdminWebConstant.FacilityCalendarItem.REPEAT_DAILY_INSPECTION:
        case AdminWebConstant.FacilityCalendarItem.REPEAT_MAINTE_LAYOUT:
          //add #9552 日常点検の個別選択ができない 20240125 zhaoqi start
          FacilityCalendarExtends fcEx = new FacilityCalendarExtends();
          //add #9552 日常点検の個別選択ができない 20240125 zhaoqi end
          // mod #9552 日常点検の個別選択ができない 商 end
          // add FNSI-改修内容 施設カレンダー バグ 1行で表示されるべきものが複数行に分かれる  dou start
          //mod #9552 日常点検の個別選択ができない 20240125 zhaoqi start
          List<FacilityCalendarExtends> calendarList = new ArrayList<>();
          //mod #9552 日常点検の個別選択ができない 20240125 zhaoqi end
          // add FNSI-改修内容 施設カレンダー バグ 1行で表示されるべきものが複数行に分かれる  dou end
          // mod #9552 日常点検の個別選択ができない 商 start
          // List<NumberOfInspectionResult> listInspectionResult1 = facilityCalendarDao
          //  .countInspectionResultByAns1(startDate, endDate, facilityCd);
          List<String> mainteLayoutCdList = keyMap.get(itemKey).stream().filter(c -> c.get("cd") != null)
                  .map(c -> c.get("cd").toString()).collect(Collectors.toList());
          //mod #9552 日常点検の個別選択ができない 20240125 zhaoqi start
          List<NumberOfInspectionResultExtends> listInspectionResult1 = facilityCalendarDao
                  .countInspectionResultByAns1(startDate, endDate, facilityCd, mainteLayoutCdList);
          //mod #9552 日常点検の個別選択ができない 20240125 zhaoqi end
          // mod #9552 日常点検の個別選択ができない 商 end
          if (!listInspectionResult1.isEmpty()) {
            listInspectionResult1.stream().forEach(i -> {
              String value = "";
              for (int j = 0; j < AdminWebConstant.InspectionResult.listInspectionResultDailyCheck.length; j++) {
                //del #9552 日常点検の個別選択ができない 20240125 zhaoqi start
//                  if (i.getMainteAns() == null) {
//                    value = AdminWebConstant.InspectionResult.listInspectionResultDailyCheck[2].getDescr();
//                  } else {
//                    if (i.getMainteAns().equals(AdminWebConstant.InspectionResult.listInspectionResultDailyCheck[j].getId())) {
//                      value = AdminWebConstant.InspectionResult.listInspectionResultDailyCheck[j].getDescr();
//                    }
//                  }
                //del #9552 日常点検の個別選択ができない 20240125 zhaoqi end

                if (i.getMainteAns().equals(AdminWebConstant.InspectionResult.listInspectionResultDailyCheck[j].getId())) {
                  value = AdminWebConstant.InspectionResult.listInspectionResultDailyCheck[j].getDescr();
                }

              }
              //add #9552 日常点検の個別選択ができない 20240125 zhaoqi start
              FacilityCalendarExtends fcItem = fcEx.clone();
              //add #9552 日常点検の個別選択ができない 20240125 zhaoqi end
              // mod FNSI-改修内容 施設カレンダー バグ 1行で表示されるべきものが複数行に分かれる  dou start
//					fcItem.setItemName(AdminWebConstant.FacilityCalendarItem.REPEAT_DAILY_INSPECTION);
              //add #9552 日常点検の個別選択ができない 20240125 zhaoqi start
              fcItem.setItemCd(i.getLayoutCd());
              //add #9552 日常点検の個別選択ができない 20240125 zhaoqi end
              fcItem.setItemName(i.getLayoutName());
              fcItem.setUpDate(i.getUpDate());
              // mod FNSI-改修内容 施設カレンダー バグ 1行で表示されるべきものが複数行に分かれる  dou end
              fcItem.setRouterPath(AdminWebConstant.Router.DAILY_CHECK);
              fcItem.setItemValue(value + " " + i.getNumberOfMainteAns());
              fcItem.setDate(i.getMainteDate());
              // del FNSI-改修内容 施設カレンダー バグ 1行で表示されるべきものが複数行に分かれる  dou start
//					fcItem.setUnit(AdminWebConstant.Unit.TABLE);
              // del FNSI-改修内容 施設カレンダー バグ 1行で表示されるべきものが複数行に分かれる  dou end
              // mod FNSI-改修内容 施設カレンダー バグ 1行で表示されるべきものが複数行に分かれる  dou start
//          listData.add(fcItem);
              calendarList.add(fcItem);
              // mod FNSI-改修内容 施設カレンダー バグ 1行で表示されるべきものが複数行に分かれる  dou end
            });
            // add FNSI-改修内容 施設カレンダー バグ 1行で表示されるべきものが複数行に分かれる  dou start
            //mod #9552 日常点検の個別選択ができない 20240125 zhaoqi start
            List<List<FacilityCalendarExtends>> groupList = new ArrayList<>();
            calendarList.stream().collect(Collectors.groupingBy(FacilityCalendarExtends::getDate, Collectors.toList()))
                    .forEach((date, listByDate) -> groupList.add(listByDate));
            List<FacilityCalendarExtends> calendarList2 = new ArrayList<>();
            groupList.stream().forEach(x -> {
              List<List<FacilityCalendarExtends>> groupList2 = new ArrayList<>();
              x.stream().collect(Collectors.groupingBy(FacilityCalendarExtends::getItemCd, Collectors.toList()))
                      .forEach((name, listByItemName) -> groupList2.add(listByItemName));
              //mod #9552 日常点検の個別選択ができない 20240125 zhaoqi end
              groupList2.stream().forEach(y -> {
                String str = "";
                if (y.size() == 2) {
                  //mod #9552 日常点検の個別選択ができない 20240125 zhaoqi start
                  FacilityCalendarExtends addCalendar = y.get(0).clone();
                  //mod #9552 日常点検の個別選択ができない 20240125 zhaoqi end
                  //  mod 6295 日常点検 趙 start
//                int result1 = y.get(0).getItemValue().indexOf("pass");
//                if (result1 == - 1) {
//                  addCalendar.setItemValue("pass 0");
//                  y.add(0, addCalendar);
//                } else {
//                  addCalendar.setItemValue("ng 0");
//                  y.add(1, addCalendar);
//                }
                  int result1 = y.get(0).getItemValue().indexOf("pass");
                  int result2 = y.get(1).getItemValue().indexOf("pass");
                  int result3 = y.get(0).getItemValue().indexOf("ng");
                  int result4 = y.get(1).getItemValue().indexOf("ng");
                  int result5 = y.get(0).getItemValue().indexOf("blank");
                  int result6 = y.get(1).getItemValue().indexOf("blank");
                  if (result1 == -1 && result2 == -1) {
                    addCalendar.setItemValue("pass 0");
                    y.add(0, addCalendar);
                  }
                  if (result3 == -1 && result4 == -1) {
                    addCalendar.setItemValue("ng 0");
                    y.add(1, addCalendar);
                  }
                  if (result5 == -1 && result6 == -1) {
                    addCalendar.setItemValue("blank 0");
                    y.add(2, addCalendar);
                  }
                  //  mod 6295 日常点検 趙 end
                } else if (y.size() == 1) {
                  //  mod 6295 日常点検 趙 start
//                FacilityCalendar addCalendar = y.get(0).clone();
//                FacilityCalendar addCalendar2 = y.get(0).clone();
//                addCalendar.setItemValue("pass 0");
//                y.add(0, addCalendar);
//                addCalendar2.setItemValue("ng 0");
//                y.add(1, addCalendar2);
                  int result1 = y.get(0).getItemValue().indexOf("pass");
                  int result2 = y.get(0).getItemValue().indexOf("ng");
                  int result3 = y.get(0).getItemValue().indexOf("blank");
                  //mod #9552 日常点検の個別選択ができない 20240125 zhaoqi start
                  FacilityCalendarExtends addCalendar = y.get(0).clone();
                  addCalendar.setItemValue("ng 0");
                  FacilityCalendarExtends addCalendar2 = y.get(0).clone();
                  addCalendar2.setItemValue("blank 0");
                  FacilityCalendarExtends addCalendar3 = y.get(0).clone();
                  //mod #9552 日常点検の個別選択ができない 20240125 zhaoqi end
                  addCalendar3.setItemValue("pass 0");
                  if (result1 == -1) {
                    y.add(0, addCalendar3);
                  }
                  if (result2 == -1) {
                    y.add(1, addCalendar);
                  }
                  if (result3 == -1) {
                    y.add(2, addCalendar2);
                  }
                  //  mod 6295 日常点検 趙 end
                }
                for (int i = 0; i < y.size(); i++) {
                  str += y.get(i).getItemValue();
                  str += "台、";
                }
                str = str.substring(0, str.length() - 1);
                //mod #9552 日常点検の個別選択ができない 20240125 zhaoqi start
                FacilityCalendarExtends calendar = y.get(0);
                //mod #9552 日常点検の個別選択ができない 20240125 zhaoqi end
                calendar.setItemValue(str);
                calendarList2.add(calendar);
              });
            });
            calendarList2.stream().sorted((x, y) -> x.getUpDate().toString().compareTo(y.getUpDate().toString()))
                    .forEach(x -> listData.add(x));
            // add FNSI-改修内容 施設カレンダー バグ 1行で表示されるべきものが複数行に分かれる  dou end
          }
          break;
        // 定期点検
        case AdminWebConstant.FacilityCalendarItem.PERIODIC_INSPECTION:
          List<NumberOfInspectionResult> listInspectionResult2 = facilityCalendarDao
                  .countInspectionResultByAns2(startDate, endDate, facilityCd);
          //add 4036 の1件にまとめて表示するよう修正願います 吉 start
          List<NumberOfInspectionResult> newlist = new ArrayList<NumberOfInspectionResult>();
          List<NumberOfInspectionResult> listInspectionResultNew = new ArrayList<NumberOfInspectionResult>();
          Map<String, List<NumberOfInspectionResult>> newMap = new HashMap<String, List<NumberOfInspectionResult>>();
          for (NumberOfInspectionResult res : listInspectionResult2) {
            if (newMap.containsKey(res.getMainteDate() + "," + res.getMachineNo())) {
              newMap.get(res.getMainteDate() + "," + res.getMachineNo()).add(res);
            } else {
              List<NumberOfInspectionResult> list = new ArrayList<NumberOfInspectionResult>();
              list.add(res);
              newMap.put(res.getMainteDate() + "," + res.getMachineNo(), list);
            }
          }
          Map<String, String> sumMap = new HashMap<String, String>();
          for (String key : newMap.keySet()) {
            int noCheck = 0;
            int pass = 0;
            int ng = 0;
            List<NumberOfInspectionResult> tmp = newMap.get(key);
            boolean noCheckval = false;
            boolean pass2 = false;
            boolean ng3 = false;

            for (NumberOfInspectionResult bbb : tmp) {
              if ("0".equals(bbb.getMainteAns())) {
                noCheckval = true;
              }
              if ("1".equals(bbb.getMainteAns())) {
                pass2 = true;
              }
              if ("2".equals(bbb.getMainteAns())) {
                ng3 = true;
              }
            }

            if (ng3) {
              ng++;
            } else {
              if (pass2) {
                if (noCheckval) {
                  noCheck++;
                } else {
                  pass++;
                }
              } else {
                noCheck++;
              }
            }
            String newKey = key.split(",")[0];
            if (sumMap.containsKey(newKey)) {
              String[] arr = sumMap.get(newKey).split("-");
              int newPass = pass + Integer.valueOf(arr[0]);
              int newng = ng + Integer.valueOf(arr[1]);
              int newnoCheck = noCheck + Integer.valueOf(arr[2]);
              String value = newPass + "-" + newng + "-" + newnoCheck;
              sumMap.put(newKey, value);
            } else {
              String value = pass + "-" + ng + "-" + noCheck;
              sumMap.put(newKey, value);
            }
          }
          for (String key : sumMap.keySet()) {
            NumberOfInspectionResult rs = new NumberOfInspectionResult();
            rs.setMainteDate(key);
            String[] arr = sumMap.get(key).split("-");
            String value = "pass" + arr[0] + "台、ng" + arr[1] + "台、未実施" + arr[2];
            rs.setMainteAns(value);
            listInspectionResultNew.add(rs);
          }
          //add 4036 の1件にまとめて表示するよう修正願います 吉 end
          //mod 4036 の1件にまとめて表示するよう修正願います 吉 start
//      if (!listInspectionResult2.isEmpty()) {
//        listInspectionResult2.stream().forEach(i -> {
          if (! listInspectionResultNew.isEmpty()) {
            listInspectionResultNew.stream().forEach(i -> {
              //mod 4036 の1件にまとめて表示するよう修正願います 吉 end
//					String value = "";
//					for (int j = 0; j < AdminWebConstant.InspectionResult.listInspectionResultPeriodic.length; j++) {
//						if(i.getMainteAns() == null) {
//							value = AdminWebConstant.InspectionResult.listInspectionResultPeriodic[0].getDescr();
//						}else {
//							if (i.getMainteAns().equals(AdminWebConstant.InspectionResult.listInspectionResultPeriodic[j].getId())) {
//								value = AdminWebConstant.InspectionResult.listInspectionResultPeriodic[j].getDescr();
//							}
//						}
//
//					}
              FacilityCalendar fcItem = fc.clone();
              fcItem.setItemName(AdminWebConstant.FacilityCalendarItem.PERIODIC_INSPECTION);
              fcItem.setRouterPath(AdminWebConstant.Router.PERIODIC_INSPECTION);
              //mod 4036 の1件にまとめて表示するよう修正願います 吉 start
//					fcItem.setItemValue(value + " " + i.getNumberOfMainteAns());
              fcItem.setItemValue(i.getMainteAns());
              //mod 4036 の1件にまとめて表示するよう修正願います 吉 end
              fcItem.setDate(i.getMainteDate());
              fcItem.setUnit(AdminWebConstant.Unit.TABLE);
              listData.add(fcItem);
            });
          }
          break;
        // 水質管理
        case AdminWebConstant.FacilityCalendarItem.WATER_QUALITY_MANAGEMENT:
          // mod 検査中+実績 数修正 chen start
          // List<ItemFacilityCalendar> listWaterSurvey = facilityCalendarDao.countResultWaterSurveyByPlan(startDate,
          // 		endDate, facilityCd, "1");
          List<ItemFacilityCalendar> listWaterSurvey = facilityCalendarDao.countResultWaterSurveyByPlan(startDate,
                  endDate, facilityCd);
          // mod 検査中+実績 数修正 chen end
          // mod FutreNetWeb+SI課題管理No4038対応 趙 start
          // ItemFacilityCalendar indCount = facilityCalendarDao.sumOfSurveyPointRecord(facilityCd);
          List<ItemFacilityCalendar> indCount = facilityCalendarDao.sumOfSurveyPointRecordByPlan(startDate, endDate, facilityCd, "1");
          // mod FutreNetWeb+SI課題管理No4038対応 趙 end
          // add FutreNetWeb+SI課題管理No4037対応 趙 start
          List<ItemFacilityCalendar> totalCount = facilityCalendarDao.sumOfSurveyPointRecordToatl(startDate, endDate, facilityCd, "1");
          // add FutreNetWeb+SI課題管理No4037対応 趙 end
          if (! totalCount.isEmpty()) {
            totalCount.stream().forEach(i -> {
              // mod FutreNetWeb+SI課題管理No4038対応 趙 start
              // int ind = 0;
              // if (indCount != null) {
              //   ind = indCount.getIndCount();
              // }
              // i.setIndCount(ind);
              final int[] ind = {0};
              // add FutreNetWeb+SI課題管理No4037対応 趙 start
              final int[] rst = {0};
              // add FutreNetWeb+SI課題管理No4037対応 趙 end
              if (! indCount.isEmpty()) {
                indCount.stream().forEach(j -> {
                  if (i.getDate().equals(j.getDate())) {
                    ind[0] = j.getIndCount();
                  }
                });
              }
              // add FutreNetWeb+SI課題管理No4037対応 趙 start
              if (! listWaterSurvey.isEmpty()) {
                listWaterSurvey.stream().forEach(j -> {
                  if (i.getDate().equals(j.getDate())) {
                    rst[0] = j.getRstCount();
                  }
                });
              }
              // add FutreNetWeb+SI課題管理No4037対応 趙 end
              i.setIndCount(ind[0]);
              // add FutreNetWeb+SI課題管理No4037対応 趙 start
              i.setRstCount(rst[0]);
              // add FutreNetWeb+SI課題管理No4037対応 趙 end
              // mod FutreNetWeb+SI課題管理No4038対応 趙 end
              FacilityCalendar fcItem = fc.clone();
              fcItem.setItemName(AdminWebConstant.FacilityCalendarItem.WATER_QUALITY_MANAGEMENT);
              fcItem.setRouterPath(AdminWebConstant.Router.WATER_QUALITY_SURVEY);
              fcItem.setItemValue(i.getRstCount() + "/" + i.getIndCount());
              fcItem.setDate(i.getDate());
              fcItem.setUnit(AdminWebConstant.Unit.TABLE);
              listData.add(fcItem);
            });
          }
          break;
        // 施設イベントカテゴリ分繰り返す
        case AdminWebConstant.FacilityCalendarItem.REPEAT_FACILITY_EVENT_CATEGORIES:
          List<Long> kindNoList = keyMap.get(itemKey).stream().filter(c -> c.get("cd") != null)
                  .map(c -> Long.valueOf(c.get("cd").toString())).collect(Collectors.toList());
          if (kindNoList != null && kindNoList.size() > 0) {
            List<NumberOfBbsInfo> listBbsSum = bbsInfoDao.countBbsKindByFacCalDate(startDate, endDate, facilityCd, kindNoList);
            if (!listBbsSum.isEmpty()) {
              listBbsSum.stream().forEach(i -> {
                FacilityCalendar fcItem = fc.clone();
                fcItem.setItemName(i.getKindName());
                fcItem.setRouterPath(AdminWebConstant.Router.BBS_INFO);
                fcItem.setItemValue(String.valueOf(i.getNumberOfBbs()));
                fcItem.setStartDate(i.getStartDate());
                fcItem.setEndDate(i.getEndDate());
                fcItem.setUnit(AdminWebConstant.Unit.TITLE);
                listData.add(fcItem);
              });
            }
          }
          break;
        default:
          break;
      }
    }
    return listData;
  }
  /* modify by chamaojia 2023-11-07 [9717] 呼び出し方法を書き換え、最適化効果を実現  --end */

	@Override
	public List<PatPersonalMain> getPatByItemInFacilityCalendar(String itemName, String date, String facilityCd) {
		List<PatPersonalMain> listPats = new ArrayList<>();
		List<Long> listPatId = new ArrayList<>();
		String[] listItem = itemName.split(":");
		String key = listItem[0].trim();
		if(key != null) {
			switch (key) {
			// 導入件数
			case AdminWebConstant.FacilityCalendarItem.INTRODUCTIONS_NUMBER:
				List<PatUnique> listPatIntro = patUniqueDao.selectPatIdByInOrOut(date, facilityCd,
						AdminWebConstant.NumberOfInOut.listItemInOut[0].getId());
				if (!listPatIntro.isEmpty()) {
					listPatIntro.stream().forEach(i -> {
						listPatId.add(i.getPat_id());
					});
					listPats = patPersonalMainDao.selectByIdList(listPatId);
				}
				break;
			// 転入件数
// mod FNSI-改修内容 転入件数と転出件数、死亡件数が施設カレンダー画面で表示できない dou start
//			case AdminWebConstant.FacilityCalendarItem.MOVE_IN:
			case AdminWebConstant.FacilityCalendarItem.MOVE_IN_NUMBER:
// mod FNSI-改修内容 転入件数と転出件数、死亡件数が施設カレンダー画面で表示できない dou end
				List<PatUnique> listPatMoveIn = patUniqueDao.selectPatIdByInOrOut(date, facilityCd,
						String.valueOf(AdminWebConstant.NumberOfInOut.listItemInOut[1].getId()));
				if (!listPatMoveIn.isEmpty()) {
					listPatMoveIn.stream().forEach(i -> {
						listPatId.add(i.getPat_id());
					});
					listPats = patPersonalMainDao.selectByIdList(listPatId);
				}
				break;
			// 転出件数
// mod FNSI-改修内容 転入件数と転出件数、死亡件数が施設カレンダー画面で表示できない dou start
//			case AdminWebConstant.FacilityCalendarItem.MOVING_OUT:
			case AdminWebConstant.FacilityCalendarItem.MOVING_OUT_NUMBER:
// mod FNSI-改修内容 転入件数と転出件数、死亡件数が施設カレンダー画面で表示できない dou end
				List<PatUnique> listPatMovingOut = patUniqueDao.selectPatIdByInOrOut(date, facilityCd,
						String.valueOf(AdminWebConstant.NumberOfInOut.listItemInOut[2].getId()));
				if (!listPatMovingOut.isEmpty()) {
					listPatMovingOut.stream().forEach(i -> {
						listPatId.add(i.getPat_id());
					});
					listPats = patPersonalMainDao.selectByIdList(listPatId);
				}
				break;
			// 入院件数
			case AdminWebConstant.FacilityCalendarItem.HOSPITALIZATIONS_NUMBER:
				List<PatUnique> listPatHospi = patUniqueDao.selectPatIdByInOrOut(date, facilityCd,
						String.valueOf(AdminWebConstant.NumberOfInOut.listItemInOut[3].getId()));
				if (!listPatHospi.isEmpty()) {
					listPatHospi.stream().forEach(i -> {
						listPatId.add(i.getPat_id());
					});
					listPats = patPersonalMainDao.selectByIdList(listPatId);
				}
				break;
			// 退院件数
			case AdminWebConstant.FacilityCalendarItem.DISCHARGES_NUMBER:
				List<PatUnique> listPatDis = patUniqueDao.selectPatIdByInOrOut(date, facilityCd,
						String.valueOf(AdminWebConstant.NumberOfInOut.listItemInOut[4].getId()));
				if (!listPatDis.isEmpty()) {
					listPatDis.stream().forEach(i -> {
						listPatId.add(i.getPat_id());
					});
					listPats = patPersonalMainDao.selectByIdList(listPatId);
				}
				break;
			// 外来件数
			case AdminWebConstant.FacilityCalendarItem.OUTPATIENTS:
				List<PatUnique> listPatOut = patUniqueDao.selectPatIdByInOrOut(date, facilityCd,
						String.valueOf(AdminWebConstant.NumberOfInOut.listItemInOut[5].getId()));
				if (!listPatOut.isEmpty()) {
					listPatOut.stream().forEach(i -> {
						listPatId.add(i.getPat_id());
					});
					listPats = patPersonalMainDao.selectByIdList(listPatId);
				}
				break;
			// 離脱件数
			case AdminWebConstant.FacilityCalendarItem.WITHDRAWALS:
				List<PatUnique> listPatWithDraw = patUniqueDao.selectPatIdByInOrOut(date, facilityCd,
						String.valueOf(AdminWebConstant.NumberOfInOut.listItemInOut[6].getId()));
				if (!listPatWithDraw.isEmpty()) {
					listPatWithDraw.stream().forEach(i -> {
						listPatId.add(i.getPat_id());
					});
					listPats = patPersonalMainDao.selectByIdList(listPatId);
				}
				break;
			// 移植件数
			case AdminWebConstant.FacilityCalendarItem.TRANSPLANTS_NUMBER:
				List<PatUnique> listPatTrans = patUniqueDao.selectPatIdByInOrOut(date, facilityCd,
						String.valueOf(AdminWebConstant.NumberOfInOut.listItemInOut[7].getId()));
				if (!listPatTrans.isEmpty()) {
					listPatTrans.stream().forEach(i -> {
						listPatId.add(i.getPat_id());
					});
					listPats = patPersonalMainDao.selectByIdList(listPatId);
				}
				break;
			// 一時転出(出)件数
			case AdminWebConstant.FacilityCalendarItem.TEMPORARY_TRANSFERS_OUTS_NUMBER:
				List<PatUnique> listPatTempoOut = patUniqueDao.selectPatIdByInOrOut(date, facilityCd,
						String.valueOf(AdminWebConstant.NumberOfInOut.listItemInOut[8].getId()));
				if (!listPatTempoOut.isEmpty()) {
					listPatTempoOut.stream().forEach(i -> {
						listPatId.add(i.getPat_id());
					});
					listPats = patPersonalMainDao.selectByIdList(listPatId);
				}
				break;
			// 一時転出(入)件数
			case AdminWebConstant.FacilityCalendarItem.TEMPORARY_TRANSFERS_IN_NUMBER:
				List<PatUnique> listPatTempoIn = patUniqueDao.selectPatIdByInOrOutByPeriodEnd(date, facilityCd,
						String.valueOf(AdminWebConstant.NumberOfInOut.listItemInOut[8].getId()));
				if (!listPatTempoIn.isEmpty()) {
					listPatTempoIn.stream().forEach(i -> {
						listPatId.add(i.getPat_id());
					});
					listPats = patPersonalMainDao.selectByIdList(listPatId);
				}
				break;
			// 拒否・不明件数
			case AdminWebConstant.FacilityCalendarItem.REJECTED_UNKNOWN_NUMBER:
				List<PatUnique> listPatReject = patUniqueDao.selectPatIdByInOrOut(date, facilityCd,
						String.valueOf(AdminWebConstant.NumberOfInOut.listItemInOut[9].getId()));
				if (!listPatReject.isEmpty()) {
					listPatReject.stream().forEach(i -> {
						listPatId.add(i.getPat_id());
					});
					listPats = patPersonalMainDao.selectByIdList(listPatId);
				}
				break;
			// 死亡件数
			case AdminWebConstant.FacilityCalendarItem.DEATHS:
				List<PatPersonalMain> listPatDeath = patPersonalMainDao.selectPatIdsByDieDate(date, facilityCd);
				if (!listPatDeath.isEmpty()) {
					listPatDeath.stream().forEach(i -> {
						listPatId.add(i.getPat_id());
					});
					listPats = patPersonalMainDao.selectByIdList(listPatId);
				}
				break;
			// 検査予定件数
			case AdminWebConstant.FacilityCalendarItem.SCHEDULED_NUMBER_INSPECTIONS:
				List<PatExamMain> listPatSche = patExamMainDao.selectPatIdsByRegExamDate(date, facilityCd);
				if (!listPatSche.isEmpty()) {
					listPatSche.stream().forEach(i -> {
						listPatId.add(i.getPatId());
					});
					listPats = patPersonalMainDao.selectByIdList(listPatId);
				}
				break;
			// 放射線予定件数
			case AdminWebConstant.FacilityCalendarItem.EXPECTED_NUMBER_RADIATION:
				List<PatRadMain> listPatExpect = patRadMainDao.selectPatIdsByRegRadDate(date, facilityCd);
				if (!listPatExpect.isEmpty()) {
					listPatExpect.stream().forEach(i -> {
						listPatId.add(i.getPatId());
					});
					listPats = patPersonalMainDao.selectByIdList(listPatId);
				}
				break;
			// 患者イベントカテゴリマスタ分繰り返す
			case AdminWebConstant.FacilityCalendarItem.REPEAT_PAT_EVENT_CATEGORY:
			  if (listItem.length > 1) {
					String[] listItemCateCd = listItem[1].split(",");
					for(String cateCd : listItemCateCd)
					{
						List<PatEvent> listPatEventCate = patEventDao.selectPatIdsByEventDate(date, facilityCd, Long.valueOf(cateCd.trim()));
						if (!listPatEventCate.isEmpty()) {
							listPatEventCate.stream().forEach(i -> {
								listPatId.add(i.getPatId());
							});
							listPats = patPersonalMainDao.selectByIdList(listPatId);
						}
					}
				}
				break;
			// 患者イベントサブカテゴリマスタ分繰り返す
			case AdminWebConstant.FacilityCalendarItem.REPEAT_PAT_EVENT_SUBCATEGORY:
			  if (listItem.length > 1) {
					String[] listCateSubItemCd = listItem[1].split(",");
					for(String cateSubCd : listCateSubItemCd)
					{
						List<PatEvent> listPatEventSubCate = patEventDao.selectPatIdsByEventDateWithSubCate(date, facilityCd, Long.valueOf(cateSubCd.trim()));
						if (!listPatEventSubCate.isEmpty()) {
							listPatEventSubCate.stream().forEach(i -> {
								listPatId.add(i.getPatId());
							});
							listPats = patPersonalMainDao.selectByIdList(listPatId);
						}
					}
				}
				break;
			default:
				break;
			}
		}
		return listPats;
	}

}
