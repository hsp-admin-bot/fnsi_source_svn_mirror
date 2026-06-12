package jp.co.nikkiso.ntss.admin_web.service.waterSurvey;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import org.apache.commons.lang3.StringUtils;
import org.seasar.doma.jdbc.Config;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.dao.MntWaterSurveyDao;
import jp.co.nikkiso.ntss.core.dao.MstRoomBedGroupDao;
import jp.co.nikkiso.ntss.core.entity.MntWaterSurvey;
import jp.co.nikkiso.ntss.core.entity.MstRoomBedGroup;
import jp.co.nikkiso.ntss.core.entity.custom.WaterSurvey;
import jp.co.nikkiso.ntss.core.entity.custom.WaterSurveyData;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.config.DefaultDb;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class WaterSurveyServiceImpl implements WaterSurveyService {
	@Autowired
	private MntWaterSurveyDao waterSurveyDao;

	@Autowired
	private MstRoomBedGroupDao mstRoomBedGroupDao;

	@Autowired
	private LogService logService;

  //FNSI-修正 ログ対応 wp add start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;

  @Autowired
  @DefaultDb
  private Config defaultDbConfig;
  //FNSI-修正 ログ対応 wp add end

	/**
	 * リストを取得水質管理
	 * @param startDate 開始日
	 * @param endDate 終了日
	 * @param facilityCd 施設コード
	 * @param listSurveyTypeCd リスト調査タイプコード
	 * @param listBedGroupCd リストベッドグループコード
	 * @return
	 */
	@Override
	public List<MntWaterSurvey> filter(String startDate, String endDate, List<Long> listSurveyTypeCd,
			String bedGroupCd, String facilityCd) throws Exception {
		List<Long> listBedCd = new ArrayList<Long>();
		ObjectMapper mapper = new ObjectMapper();
        // add 7290 カレンダーを利用した水質検査の予定作成・結果登録をした際、水質管理画面にその内容が反映されない 周安寧 start
        List<MntWaterSurvey> result = new ArrayList<MntWaterSurvey>();
        // add 7290 カレンダーを利用した水質検査の予定作成・結果登録をした際、水質管理画面にその内容が反映されない 周安寧 end
		if (bedGroupCd == null || bedGroupCd.equals("")) {
		  // mod 7290 カレンダーを利用した水質検査の予定作成・結果登録をした際、水質管理画面にその内容が反映されない 周安寧 start
	      // ベッドグループ未選択の場合、全ベッドグループから選択？？
//	      List<MstRoomBedGroup> bedList = mstRoomBedGroupDao.selectByFacility(facilityCd);
//	      bedList.stream().forEach(bg -> {
//	        List<Long> bedGroupList = null;
//	          try {
//	            if(null != bg.getBedList()){
//	              bedGroupList = mapper.readValue(bg.getBedList(), new TypeReference<List<Long>>() {
//	              });
//	              listBedCd.addAll(bedGroupList);
//	            }
//	          } catch (Exception e) {
//	            e.printStackTrace();
//	          }
          result = waterSurveyDao.filterWithoutBed(startDate, endDate, listSurveyTypeCd, facilityCd);
          // mod 7290 カレンダーを利用した水質検査の予定作成・結果登録をした際、水質管理画面にその内容が反映されない 周安寧 end
    } else {
		  // 検索対象のベッドグループを単体にする
		  MstRoomBedGroup bg = mstRoomBedGroupDao.selectByRoomBedGroupCd(bedGroupCd);
		  List<Long> bedList = null;
	      try {
	        if (null != bg && null != bg.getBedList()) {
	          bedList = mapper.readValue(bg.getBedList(), new TypeReference<List<Long>>() {
	          });
	          listBedCd.addAll(bedList);
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
       // mod 7290 カレンダーを利用した水質検査の予定作成・結果登録をした際、水質管理画面にその内容が反映されない 周安寧 start
       result = waterSurveyDao.filter(startDate, endDate, listSurveyTypeCd, listBedCd, facilityCd);
		}
		//List<MntWaterSurvey> result = waterSurveyDao.filter(startDate, endDate, listSurveyTypeCd, listBedCd, facilityCd);
        // mod 7290 カレンダーを利用した水質検査の予定作成・結果登録をした際、水質管理画面にその内容が反映されない 周安寧 end
		String listBedCdStr = "";
		String listSurveyTypeCdStr = "";
		if (listBedCd.size() > 0) {
			for (int i = 0; i < listBedCd.size(); i++) {
				listBedCdStr += String.valueOf(listBedCd.get(i)) + " ";
			}
		}
		if (listSurveyTypeCd.size() > 0) {
			for (int i = 0; i < listSurveyTypeCd.size(); i++) {
				listSurveyTypeCdStr += String.valueOf(listSurveyTypeCd.get(i)) + " ";
			}
		}
		EventLogMessage eventLogMessage = new EventLogMessage();
		eventLogMessage.setLogMessage("水質調査リストの取得が成功した。");
		eventLogMessage.setSqlIdentification("(facility_cd = " + facilityCd + ", inspection_date >= " +  startDate + ", inspection_date <= " +  endDate +  ", bed_cd IN " + listBedCdStr +  ", survey_type_cd IN " +  listSurveyTypeCdStr + ")");
		logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY, SERVICE_NAME.FNSI, "MntWaterSurveyDao/filter");
		return result;
	}

	/**
	 * リスト水調査を削除
	 * @param surveyRecordNo
	 * @return
	 */
	@Override
	public void deleteWaterSurvey(Long surveyRecordNo, String facilityCd) throws Exception {
		int checkdelete = waterSurveyDao.deleteBySurveyRecordNo(surveyRecordNo, facilityCd);
		if(checkdelete <= 0) {
			EventLogMessage eventLogMessage = new EventLogMessage();
			eventLogMessage.setLogMessage("水質調査の削除が失敗した。");
			eventLogMessage.setSqlIdentification("(survey_record_no = " + surveyRecordNo + ", facility_cd = " +  facilityCd + ")");
			logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY ,SERVICE_NAME.FNSI, "MntWaterSurveyDao/deleteBySurveyRecordNo");
		}else {
			EventLogMessage eventLogMessage = new EventLogMessage();
			eventLogMessage.setLogMessage("水質調査の削除が成功した。");
			eventLogMessage.setSqlIdentification("(survey_record_no = " + surveyRecordNo + ", facility_cd = " +  facilityCd + ")");
			logService.log(LogLevel.INFO, eventLogMessage,FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY ,SERVICE_NAME.FNSI, "MntWaterSurveyDao/deleteBySurveyRecordNo");
		}
	}

	/**
	 * 調査記録による選択いいえ
	 * @param surveyRecordNo 水質調査記録番号
	 * @throws Exception
	 */
	@Override
	public WaterSurvey selectBySurveyRecordNo(Long surveyRecordNo) throws Exception {
		MntWaterSurvey mntWaterSurvey = waterSurveyDao.selectBySurveyRecordNo(surveyRecordNo);

		EventLogMessage eventLogMessage = new EventLogMessage();
		eventLogMessage.setLogMessage("調査記により水質調査の取得が成功した。 (survey record no =" + surveyRecordNo + ")");
		logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY, SERVICE_NAME.FNSI, "MntWaterSurveyDao/selectBySurveyRecordNo");

		WaterSurvey survey = new WaterSurvey();
		survey.setFacilityCd(mntWaterSurvey.getFacilityCd());
		survey.setInspectionDate(mntWaterSurvey.getInspectionDate());
		survey.setSurveyRecordNo(mntWaterSurvey.getSurveyRecordNo());
		survey.setIsDisp(mntWaterSurvey.getIsDisp());
		survey.setIsDel(mntWaterSurvey.getIsDel());
		ObjectMapper mapper = new ObjectMapper();
		List<WaterSurveyData> surveyData = new ArrayList<>();
		if (mntWaterSurvey.getSurveyData() != null) {
			surveyData = mapper.readValue(mntWaterSurvey.getSurveyData(),
					new TypeReference<List<WaterSurveyData>>() {});
		}
		survey.setSurveyData(surveyData);
		return survey;
	}

	/**
	 * 複数の水質管理を節約
	 * @param watSurveys 水質管理のリスト
	 * @return
	 */
	@Override
	@Transactional(rollbackFor = Exception.class)
	public void insertOrUpdateWaterSurveyMulti(List<WaterSurvey> watSurveys) {
		ObjectMapper mapper = new ObjectMapper();
		Timestamp upDate = getCurrentDate();
		if (watSurveys != null && watSurveys.size() > 0) {
			watSurveys.stream().forEach(i -> {
				MntWaterSurvey wat = new MntWaterSurvey();
				wat.setFacilityCd(i.getFacilityCd());
				wat.setInspectionDate(i.getInspectionDate());
				wat.setIsDisp(i.getIsDisp());
				wat.setIsDel(i.getIsDel());
				wat.setRegDate(upDate);
				wat.setUpDate(upDate);
				if (i.getSurveyRecordNo() != null) {
					try {
						wat.setSurveyRecordNo(i.getSurveyRecordNo());
						WaterSurvey oldWaterSurvey = selectBySurveyRecordNo(i.getSurveyRecordNo());
						if (i.getSurveyData().size() > 0) {
							i.getSurveyData().stream().forEach(j -> {
								WaterSurveyData surveyData = oldWaterSurvey.getSurveyData().stream()
									.filter(x -> x.getPoint_cd().equals(j.getPoint_cd())).findAny().orElse(null);
								if (surveyData != null) {
									oldWaterSurvey.getSurveyData().remove(surveyData);
									oldWaterSurvey.getSurveyData().add(j);
								} else {
									oldWaterSurvey.getSurveyData().add(j);
								}
							});
						}
						wat.setSurveyData(mapper.writeValueAsString(oldWaterSurvey.getSurveyData()));


            // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
            LogEventUtils.setOperatorId(wat,logService);
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
            // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
						int updateCount = waterSurveyDao.update(wat);


						if (updateCount <= 0) {
							EventLogMessage eventLogMessage = new EventLogMessage();
							eventLogMessage.setLogMessage("水質調査の更新が失敗した。 (update survey record no =" + i.getSurveyRecordNo() + ")");
							eventLogMessage.setSqlIdentification("(facility_cd = " + wat.getFacilityCd() + ", inspection_date = " + wat.getInspectionDate() + ", survey_data = " + wat.getSurveyData()
								+ ", up_date = " + upDate + ", is_disp = " + wat.getIsDisp()  + ", is_del = " + wat.getIsDel() + ")");
							logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY ,SERVICE_NAME.FNSI, "MntWaterSurveyDao/update");
						} else {
							EventLogMessage eventLogMessage = new EventLogMessage();
							eventLogMessage.setLogMessage("水質調査の更新が成功した。 (update survey record no =" + i.getSurveyRecordNo() + ")");
							eventLogMessage.setSqlIdentification("(facility_cd = " + wat.getFacilityCd() + ", inspection_date = " + wat.getInspectionDate() + ", survey_data = " + wat.getSurveyData()
								+ ", up_date = " + upDate + ", is_disp = " + wat.getIsDisp()  + ", is_del = " + wat.getIsDel() + ")");
							logService.log(LogLevel.INFO, eventLogMessage,FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY ,SERVICE_NAME.FNSI, "MntWaterSurveyDao/update");
						}
					} catch (Exception e) {
						EventLogMessage eventLogMessage = new EventLogMessage();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
            eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
						logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY,SERVICE_NAME.FNSI, null);
					}

				} else {
					try {
						wat.setSurveyData(mapper.writeValueAsString(i.getSurveyData()));
						int insertCount = waterSurveyDao.insert(wat);
						if (insertCount <= 0) {
							EventLogMessage eventLogMessage = new EventLogMessage();
							eventLogMessage.setLogMessage("(水質調査の挿入が失敗した。)");
							eventLogMessage.setSqlIdentification("(facility_cd = " + wat.getFacilityCd() + ", inspection_date = " + wat.getInspectionDate() + ", survey_data = " + wat.getSurveyData()
								+ ", up_date = " + upDate + ", reg_date" + upDate +  ")");
							logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY ,SERVICE_NAME.FNSI, "MntWaterSurveyDao/update");
						} else {
							EventLogMessage eventLogMessage = new EventLogMessage();
							eventLogMessage.setLogMessage("(水質調査の挿入が成功した。)");
							eventLogMessage.setSqlIdentification("(facility_cd = " + wat.getFacilityCd() + ", inspection_date = " + wat.getInspectionDate() + ", survey_data = " + wat.getSurveyData()
								+ ", up_date = " + upDate + ", reg_date" + upDate +  ")");
							logService.log(LogLevel.INFO, eventLogMessage,FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY ,SERVICE_NAME.FNSI, "MntWaterSurveyDao/insert");
						}
					} catch (Exception e) {
						EventLogMessage eventLogMessage = new EventLogMessage();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
            eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
						logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY,SERVICE_NAME.FNSI, null);
					}

				}
			});
		}
	}

	/**
	 * システム日時を取得します
	 *
	 * @return システム日時
	 */
	private Timestamp getCurrentDate() {
		return new Timestamp(System.currentTimeMillis());
	}

	/**
	 * 調査データを削除
	 * @param surveyRecordNo 水質調査記録番号
	 * @param pointCd 調査箇所コード
	 * @param facilityCd 施設コード
	 * @return
	 */
	@Override
	public void deleteSurverDataByPointCd(Long surveyRecordNo, Long pointCd, String facilityCd) throws Exception {
		Timestamp upDate = getCurrentDate();
		ObjectMapper mapper = new ObjectMapper();
		WaterSurvey oldWaterSurvey = selectBySurveyRecordNo(surveyRecordNo);
		if(oldWaterSurvey.getSurveyData().size() > 0) {
			for (int i = 0; i < oldWaterSurvey.getSurveyData().size(); i++) {
				WaterSurveyData surveyData = oldWaterSurvey.getSurveyData().stream()
					.filter(x -> x.getPoint_cd().equals(pointCd)).findAny().orElse(null);
				if (surveyData != null) {
					oldWaterSurvey.getSurveyData().remove(surveyData);
					if (oldWaterSurvey.getSurveyData().size() <= 0) {
							deleteWaterSurvey(surveyRecordNo, facilityCd);
					} else {
						MntWaterSurvey wat = new MntWaterSurvey();
						wat.setFacilityCd(oldWaterSurvey.getFacilityCd());
						wat.setInspectionDate(oldWaterSurvey.getInspectionDate());
						wat.setIsDisp(oldWaterSurvey.getIsDisp());
						wat.setIsDel(oldWaterSurvey.getIsDel());
						wat.setUpDate(upDate);
						wat.setSurveyRecordNo(surveyRecordNo);

						wat.setSurveyData(mapper.writeValueAsString(oldWaterSurvey.getSurveyData()));

            // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
            LogEventUtils.setOperatorId(wat,logService);
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
            // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
						int updateCount = waterSurveyDao.update(wat);
						if (updateCount <= 0) {
							EventLogMessage eventLogMessage = new EventLogMessage();
							eventLogMessage.setLogMessage("水質調査の更新が失敗した。 (update survey record no =" + wat.getSurveyRecordNo() + ")");
							eventLogMessage.setSqlIdentification("(facility_cd = " + wat.getFacilityCd() + ", inspection_date = " + wat.getInspectionDate() + ", survey_data = " + wat.getSurveyData()
								+ ", up_date = " + upDate + ", is_disp = " + wat.getIsDisp()  + ", is_del = " + wat.getIsDel() + ")");
							logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY ,SERVICE_NAME.FNSI, "MntWaterSurveyDao/update");
						} else {
							EventLogMessage eventLogMessage = new EventLogMessage();
							eventLogMessage.setLogMessage("水質調査の更新が成功した。 (update survey record no =" + wat.getSurveyRecordNo() + ")");
							eventLogMessage.setSqlIdentification("(facility_cd = " + wat.getFacilityCd() + ", inspection_date = " + wat.getInspectionDate() + ", survey_data = " + wat.getSurveyData()
								+ ", up_date = " + upDate + ", is_disp = " + wat.getIsDisp()  + ", is_del = " + wat.getIsDel() + ")");
							logService.log(LogLevel.INFO, eventLogMessage,FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY ,SERVICE_NAME.FNSI, "MntWaterSurveyDao/update");
						}
					}
				}
			}
		}else {
			deleteWaterSurvey(surveyRecordNo, facilityCd);
		}

	}

	@Override
	public void deleteListSurverData(Long surveyRecordNo, Map<String, String> pointCds, String facilityCd) throws Exception {
		ObjectMapper mapper = new ObjectMapper();
		if(pointCds.get("listPointCd") != null) {
			List<String> listPointCd = mapper.readValue(pointCds.get("listPointCd"),new TypeReference<List<String>>(){});
			for (int i = 0; i < listPointCd.size(); i++) {
				//add FNSI-水質管理_青田の対応 徐 start
				MntWaterSurvey mntWaterSurvey = waterSurveyDao.selectBySurveyRecordNo(surveyRecordNo);
				if (mntWaterSurvey != null) {
				//add FNSI-水質管理_青田の対応 徐 end
					deleteSurverDataByPointCd(surveyRecordNo, Long.valueOf(listPointCd.get(i)), facilityCd);
				//add FNSI-水質管理_青田の対応 徐 start
				}
				//add FNSI-水質管理_青田の対応 徐 end
			}
		}
	}
	// add FNSI-水質管理_青田の対応 徐 start
	@Override
	public void removeListSurverData(Long surveyRecordNo, Map<String, String> pointCds, String facilityCd) throws Exception {
		ObjectMapper mapper = new ObjectMapper();
		if(pointCds.get("listPointCd") != null) {
			List<String> listPointCd = mapper.readValue(pointCds.get("listPointCd"),new TypeReference<List<String>>(){});
			for (int i = 0; i < listPointCd.size(); i++) {
				MntWaterSurvey mntWaterSurvey = waterSurveyDao.selectBySurveyRecordNo(surveyRecordNo);
				if (mntWaterSurvey != null) {
					removeSurverDataByPointCd(surveyRecordNo, Long.valueOf(listPointCd.get(i)), facilityCd);
				}
			}
		}
	}
	/**
	 * 調査データを結果削除
	 * @param surveyRecordNo 水質調査記録番号
	 * @param pointCd 調査箇所コード
	 * @param facilityCd 施設コード
	 * @return
	 */
	@Override
	public void removeSurverDataByPointCd(Long surveyRecordNo, Long pointCd, String facilityCd) throws Exception {
		Timestamp upDate = getCurrentDate();
		ObjectMapper mapper = new ObjectMapper();
		WaterSurvey oldWaterSurvey = selectBySurveyRecordNo(surveyRecordNo);
		if(oldWaterSurvey.getSurveyData().size() > 0) {
      //FNSI-修正 #5510 BUG対応、ljx modify start-->
			//for (int i = 0; i < oldWaterSurvey.getSurveyData().size(); i++) {
      //FNSI-修正 #5510 BUG対応、ljx modify end-->
				WaterSurveyData surveyData = oldWaterSurvey.getSurveyData().stream()
					.filter(x -> x.getPoint_cd().equals(pointCd)).findAny().orElse(null);
				if (surveyData != null) {

          //FNSI-修正 #5510 BUG対応、ljx add start-->
          int index = oldWaterSurvey.getSurveyData().indexOf(surveyData);
          //FNSI-修正 #5510 BUG対応、ljx add end-->

					oldWaterSurvey.getSurveyData().remove(surveyData);

					if (oldWaterSurvey.getSurveyData().size() <= 0 && surveyData.getPlan() == "0") {
						deleteWaterSurvey(surveyRecordNo, facilityCd);
					} else {
						WaterSurveyData newData = new WaterSurveyData();
						newData.setPoint_cd(surveyData.getPoint_cd());
						newData.setPlan(surveyData.getPlan());
						newData.setTime("");
						newData.setPicker(0L);
						newData.setInspector(0L);
						newData.setValue(null);
						newData.setText("");
            // #5511 徐博 start
            // newData.setMemo(null);
						newData.setMemo("");
            // #5511 徐博 end
						newData.setUnit(surveyData.getUnit());

            //FNSI-修正 #5510 BUG対応、ljx modify start-->
            oldWaterSurvey.getSurveyData().add(index,newData);
            //FNSI-修正 #5510 BUG対応、ljx modify end-->

						MntWaterSurvey wat = new MntWaterSurvey();
						wat.setFacilityCd(oldWaterSurvey.getFacilityCd());
						wat.setInspectionDate(oldWaterSurvey.getInspectionDate());
						wat.setIsDisp(oldWaterSurvey.getIsDisp());
						wat.setIsDel(oldWaterSurvey.getIsDel());
						wat.setUpDate(upDate);
						wat.setSurveyRecordNo(surveyRecordNo);
						wat.setSurveyData(mapper.writeValueAsString(oldWaterSurvey.getSurveyData()));

            // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
            LogEventUtils.setOperatorId(wat,logService);
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
            // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
						int updateCount = waterSurveyDao.update(wat);
						if (updateCount <= 0) {
							EventLogMessage eventLogMessage = new EventLogMessage();
							eventLogMessage.setLogMessage("水質調査の更新が失敗した。 (update survey record no =" + wat.getSurveyRecordNo() + ")");
							eventLogMessage.setSqlIdentification("(facility_cd = " + wat.getFacilityCd() + ", inspection_date = " + wat.getInspectionDate() + ", survey_data = " + wat.getSurveyData()
								+ ", up_date = " + upDate + ", is_disp = " + wat.getIsDisp() + ", is_del = " + wat.getIsDel() + ")");
							logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY, SERVICE_NAME.FNSI, "MntWaterSurveyDao/update");
						} else {
							EventLogMessage eventLogMessage = new EventLogMessage();
							eventLogMessage.setLogMessage("水質調査の更新が成功した。 (update survey record no =" + wat.getSurveyRecordNo() + ")");
							eventLogMessage.setSqlIdentification("(facility_cd = " + wat.getFacilityCd() + ", inspection_date = " + wat.getInspectionDate() + ", survey_data = " + wat.getSurveyData()
								+ ", up_date = " + upDate + ", is_disp = " + wat.getIsDisp() + ", is_del = " + wat.getIsDel() + ")");
							logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY, SERVICE_NAME.FNSI, "MntWaterSurveyDao/update");
						}
					}
				}
      //FNSI-修正 #5510 BUG対応、ljx modify start-->
			//}
      //FNSI-修正 #5510 BUG対応、ljx modify end-->
		}else {
			deleteWaterSurvey(surveyRecordNo, facilityCd);
		}
	}
	// add FNSI-水質管理_青田の対応 徐 end

  //FNSI-修正 ログ対応 wp add start

  /**
   * ログ情報設定
   * @return eventLogMessage
   */
  private EventLogMessage getEventLogMessage() {
    EventLogMessage eventLogMessage = new EventLogMessage();
    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    if (user != null) {
      // 利用者ID
      eventLogMessage.setUserId(user.getUserId().toString());
      // 施設コード
      eventLogMessage.setFacilityCd(user.getFacilityCd());
      // 接続先IPアドレス
      eventLogMessage.setClientIp(user.getClientIpAddress());
      // セッションID
      eventLogMessage.setSessionId(user.getSessionId());
    }

    // サービス名
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + LoggingConstant.SERVICE_NAME.FNSI);
    return   eventLogMessage;
  }

  /**
   * ログ出力共通クラス設定、取得
   * @return logCommon ログ出力共通クラス
   */
  private DataUpdateLogCommonNew getLogCommon(String tableName, StringBuffer whereStr, EventLogMessage eventLogMessage) {
    DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
    logCommon.setEventLoggerFactory(eventLoggerFactory);
    logCommon.setLogServiceCore(logServiceCore);
    logCommon.setConfig(defaultDbConfig);
    logCommon.setTableName(tableName);
    logCommon.setWhereStr(whereStr);
    logCommon.setCommonEventLogMessage(eventLogMessage);
    return logCommon;
  }


  //FNSI-修正 ログ対応 wp add end
}
