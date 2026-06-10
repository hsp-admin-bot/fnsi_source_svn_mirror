package jp.co.nikkiso.ntss.admin_web.service.salSubscriptionManage;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.SalSubscriptionManage;
import jp.co.nikkiso.ntss.core.entity.SysFunction;
import jp.co.nikkiso.ntss.core.entity.SysFunctionAdvanced;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.json.JSONArray;
import org.json.JSONObject;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import org.springframework.security.access.AccessDeniedException;
import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.admin_web.service.SelectOptionsUtils;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.SalSubscriptionManageStatus;
import jp.co.nikkiso.ntss.admin_web.request.salSubscriptionManage.SalSubManSearchRequest;
import jp.co.nikkiso.ntss.admin_web.request.salSubscriptionManage.SalSubscriptionManageRequest;
import jp.co.nikkiso.ntss.admin_web.response.salSubscriptionManage.SalSubManResponse;
import jp.co.nikkiso.ntss.admin_web.response.sysFunction.SysFunctionResponse;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.SalSubscriptionManageDao;
import jp.co.nikkiso.ntss.core.dao.SysFunctionAdvancedDao;
import jp.co.nikkiso.ntss.core.dao.SysFunctionDao;
import jp.co.nikkiso.ntss.core.entity.custom.SalSubscriptionManageCustom;
import org.springframework.transaction.annotation.Transactional;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * オプション申込のService実装クラス.
 */
@Service
public class SalSubscriptionManageServiceImpl implements SalSubscriptionManageService {

	/**
	 * オプション申込Daoインタフェース.
	 */
	@Autowired
	private SalSubscriptionManageDao salSubscriptionManageDao;

	/**
	 * 利用者マスタ(個人情報DB)のDaoインタフェース.
	 */
	@Autowired
	private MstPersonalUserDao mstPersonalUserDao;

	/**
	 * 機能一覧クラスDaoインタフェース.
	 */
	@Autowired
	private SysFunctionDao sysFunctionDao;

	/**
	 * 拡張機能Daoインタフェース.
	 */
	@Autowired
	private SysFunctionAdvancedDao sysFunctionAdvancedDao;

	/**
	 * 施設マスタのDaoインタフェース.
	 */
	@Autowired
	private MstFacilityDao mstFacilityDao;

  //DB更新ログ出力ロジック wp start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;
  //DB更新ログ出力ロジック wp end

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
  @Autowired
  private LogService logService;
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end

	/**
	   * すべてのオプションアプリケーションを検索
	   * @param pageable
	   * @return オプション申込のResponse
	*/
	@Override
	public Page<SalSubscriptionManage> findAll(Pageable pageable) {
		SelectOptions selectOptions = SelectOptions.get();
		List<SalSubscriptionManage> SalSubscriptionManageList = salSubscriptionManageDao.selectAll(selectOptions);
		return new PageImpl<>(SalSubscriptionManageList, pageable, selectOptions.getCount());
	}

	/**
	   * 施設コードで探す
	   * @param pageable
	   * @param facilityCd 施設コード
	   * @return オプション申込のResponse
	*/
	@Override
	public Page<SalSubscriptionManage> findByFacilityCd(Pageable pageable, String facilityCd) {
		SelectOptions selectOptions = SelectOptions.get();
		List<SalSubscriptionManage> SalSubscriptionManageList = salSubscriptionManageDao
				.selectByFacilityCd(selectOptions, facilityCd);
		return new PageImpl<>(SalSubscriptionManageList, pageable, selectOptions.getCount());
	}

	/**
	   * {@inheritDoc}
	 */
  /* add by yuqinlong  2023-02-02 [Transaction]  */
	@Transactional
	@Override
	public long createSalSubscriptionManage(SalSubscriptionManageRequest salReq, Long userId) throws Exception {
		MstPersonalUser user = mstPersonalUserDao.selectById(userId);
		if(!Integer.valueOf(1).equals(user.getAdministrator())) {
			throw new AccessDeniedException("");
		}
		long nextSeqSubscriptionNo = salSubscriptionManageDao.selectNextSeqSubscriptionNo();

		SalSubscriptionManage salSubscription = new SalSubscriptionManage() {
			{

				setSubscriptionNo(nextSeqSubscriptionNo);
				setFacilityCd(salReq.getFacilityCd());
				setIsFirst(salReq.getIsFirst());
				setSubscriptionPlanName(salReq.getSubscriptionPlanName());
				setSubscriptionFnc(salReq.getSubscriptionFnc());
				setSubscriptionAdv(salReq.getSubscriptionAdv());
				setSubscriptionStatus(salReq.getSubscriptionStatus());
				setApplicant(userId);
			}
		};
		salSubscriptionManageDao.insert(salSubscription);


		if (user.getUserType() == 1 && user.getFacilityCd().equals("nkknkk")) {
			if(user.getAdministrator() == 1) {
				salReq.setSubscriptionStatus("1");
				updateReceptionSalSubscriptionManage(nextSeqSubscriptionNo, salReq, userId);
				salReq.setSubscriptionStatus("2");
				updateCompletionSalSubscriptionManage(nextSeqSubscriptionNo, salReq, userId);
			}

		}
		return nextSeqSubscriptionNo;
	}

	/**
	   * {@inheritDoc}
	 */
	@Override
	public void updateReceptionSalSubscriptionManage(Long subscriptionNo, SalSubscriptionManageRequest salReq,
			Long userId) throws Exception {

		MstPersonalUser user = mstPersonalUserDao.selectById(userId);
		if (!Integer.valueOf(1).equals(user.getUserType()) && !user.getFacilityCd().equals("nkknkk")) {
			throw new AccessDeniedException("");
		}
		SalSubscriptionManage oldSal = salSubscriptionManageDao.selectBySubscriptionNo(subscriptionNo);
		if (oldSal.getSubscriptionStatus().equals(SalSubscriptionManageStatus.COMPLETION) || oldSal.getSubscriptionStatus().equals(SalSubscriptionManageStatus.CANCEL)
				|| oldSal.getSubscriptionStatus().equals(SalSubscriptionManageStatus.ACCEPTED)) {
			throw new Exception();
		}
		Timestamp upDate = getCurrentDate();
		SalSubscriptionManage salSubscription = new SalSubscriptionManage() {
			{
				setSubscriptionNo(subscriptionNo);
				setSubscriptionStatus(salReq.getSubscriptionStatus());
				setUpDate(upDate);
				setReceptionist(userId);
				setReceptionDate(upDate);
			}
		};
		salSubscriptionManageDao.updateReception(salSubscription);

	}

	/**
	 * {@inheritDoc}
	 */
  /* add by yuqinlong  2023-02-02 [Transaction]  */
  @Transactional
	@Override
	public void updateCompletionSalSubscriptionManage(Long subscriptionNo, SalSubscriptionManageRequest salReq,
			Long userId) throws Exception {
		MstPersonalUser user = mstPersonalUserDao.selectById(userId);
		if (!Integer.valueOf(1).equals(user.getUserType()) && !Integer.valueOf(1).equals(user.getAdministrator()) && !user.getFacilityCd().equals("nkknkk")) {
			throw new AccessDeniedException("");
		}
		SalSubscriptionManage oldSal = salSubscriptionManageDao.selectBySubscriptionNo(subscriptionNo);
		if (oldSal.getSubscriptionStatus().equals(SalSubscriptionManageStatus.NOT_ACCEPTED) || oldSal.getSubscriptionStatus().equals(SalSubscriptionManageStatus.COMPLETION) || oldSal.getSubscriptionStatus().equals(SalSubscriptionManageStatus.CANCEL)) {
			throw new Exception();
		}

		Timestamp upDate = getCurrentDate();
		SalSubscriptionManage salSubscription = new SalSubscriptionManage() {
			{
				setSubscriptionNo(subscriptionNo);
				setSubscriptionStatus(salReq.getSubscriptionStatus());
				setUpDate(upDate);
				setCompleter(userId);
				setCompleteDate(upDate);
			}
		};
		int check = salSubscriptionManageDao.updateCompletion(salSubscription);
		ObjectMapper mapper = new ObjectMapper();
		if (check > 0) {
			MstFacility facility = mstFacilityDao.selectByCd(oldSal.getFacilityCd());
			List<String> functionsAll = new ArrayList<>();
			List<String> functionsAdvsAll = new ArrayList<>();
			if(oldSal.getSubscriptionFnc() != null) {
				Map<String, List<String>> functions = mapper.readValue(oldSal.getSubscriptionFnc(), new TypeReference<Map<String, List<String>>>(){});
				if(functions.get("item_cd") != null && functions.get("item_cd").size() > 0) {
					functionsAll.addAll(functions.get("item_cd"));
				}
			}
			if(oldSal.getSubscriptionAdv() != null) {
				Map<String, List<String>> functionAdvs = mapper.readValue(oldSal.getSubscriptionAdv(), new TypeReference<Map<String, List<String>>>(){});
				if(functionAdvs.get("item_cd") != null && functionAdvs.get("item_cd").size() > 0) {
					functionsAdvsAll.addAll(functionAdvs.get("item_cd"));
				}
			}
			if (facility.getUseFunction() != null) {
				JSONObject functionData = new JSONObject(facility.getUseFunction());
				JSONArray functionCds = functionData.getJSONArray("func_cds");
				if(!functionsAll.isEmpty()) {

					functionsAll.stream().forEach(i -> {
						if (!facility.getUseFunction().contains(i)) {
							JSONObject func = new JSONObject();
							func.put("func_cd", i);
							functionCds.put(func);

						}
					});
					functionData.put("func_cds", functionCds);
				}
				MstFacility facilityUpDate = new MstFacility() {
					{
						setFacilityCd(facility.getFacilityCd());
						setUseFunction(functionData.toString());
						setUpDate(upDate);
					}
				};

        //FNSI-修正 ログ対応 wp add start

        String mmsTbN = "mst_facility";

        // SQL検索条件
        StringBuffer wheres = new StringBuffer("");
        wheres.append(" WHERE\n");
        wheres.append(" facility_cd = '" + facilityUpDate.getFacilityCd() + "'" +"\n");
        // logCommon設定
        // logCommon設定
        DataUpdateLogCommonNew logCommon = getLogCommon(mstFacilityDao, mmsTbN, wheres, getEventLogMessage());
        // ログ出力カラム情報及び更新前データ情報取得
        boolean setResult = logCommon.setInfo();
        //FNSI-修正 ログ対応 wp add end

				int updateCount = mstFacilityDao.updateUseFunction(facilityUpDate);

        //FNSI-修正 ログ対応 wp add start
        // 更新後データ取得、差分あれば、log出力
        if (setResult && updateCount > 0) {
          logCommon.updateLog();
        }
        //FNSI-修正 ログ対応 wp add end
			} else {
				JSONObject functionData = new JSONObject();
				JSONArray functionCds = new JSONArray();
				if(functionsAll.size() > 0) {
					functionsAll.stream().forEach(i -> {
						JSONObject func = new JSONObject();
						func.put("func_cd", i);
						functionCds.put(func);
					});
					functionData.put("func_cds", functionCds);
					MstFacility facilityUpDate = new MstFacility() {
						{
							setFacilityCd(facility.getFacilityCd());
							setUseFunction(functionData.toString());
							setUpDate(upDate);
						}
					};
          //FNSI-修正 ログ対応 wp add start

          String mmsTbN = "mst_facility";

          // SQL検索条件
          StringBuffer wheres = new StringBuffer("");
          wheres.append(" WHERE\n");
          wheres.append(" facility_cd = '" + facilityUpDate.getFacilityCd() + "'" +"\n");
          // logCommon設定
          // logCommon設定
          DataUpdateLogCommonNew logCommon = getLogCommon(mstFacilityDao, mmsTbN, wheres, getEventLogMessage());
          // ログ出力カラム情報及び更新前データ情報取得
          boolean setResult = logCommon.setInfo();
          //FNSI-修正 ログ対応 wp add end
					int updateCount = mstFacilityDao.updateUseFunction(facilityUpDate);

          //FNSI-修正 ログ対応 wp add start
          // 更新後データ取得、差分あれば、log出力
          if (setResult && updateCount > 0) {
            logCommon.updateLog();
          }
          //FNSI-修正 ログ対応 wp add end
				}
			}
			if (facility.getAdvancedSettings() != null) {
				JSONObject advancedData = new JSONObject(facility.getAdvancedSettings());
				JSONArray functionAdvcds = advancedData.getJSONArray("func_advcds");
				if(!functionsAdvsAll.isEmpty()) {
					functionsAdvsAll.stream().forEach(i -> {
						if (!facility.getAdvancedSettings().contains(i)) {
							JSONObject funcAdv = new JSONObject();
							funcAdv.put("func_advcd", i);
							functionAdvcds.put(funcAdv);
						}
					});
					advancedData.put("func_advcds", functionAdvcds);
				}
				MstFacility AdvancedSettingsUpDate = new MstFacility() {
					{
						setFacilityCd(facility.getFacilityCd());
						setAdvancedSettings(advancedData.toString());
						setUpDate(upDate);
					}
				};
				mstFacilityDao.updateAdvancedSettings(AdvancedSettingsUpDate);
			} else {
				JSONObject advancedData = new JSONObject();
				JSONArray functionAdvcds = new JSONArray();
				if(functionsAdvsAll.size() > 0) {
					functionsAdvsAll.stream().forEach(i -> {
						JSONObject funcAdv = new JSONObject();
						funcAdv.put("func_advcd", i);
						functionAdvcds.put(funcAdv);
					});
					advancedData.put("func_advcds", functionAdvcds);
					MstFacility AdvancedSettingsUpDate = new MstFacility() {
						{
							setFacilityCd(facility.getFacilityCd());
							setAdvancedSettings(advancedData.toString());
							setUpDate(upDate);
						}
					};
					mstFacilityDao.updateAdvancedSettings(AdvancedSettingsUpDate);
				}

			}

		}

	}

	/**
	  * {@inheritDoc}
	 */
	@Override
	public void updateCancelSalSubscriptionManage(Long subscriptionNo, SalSubscriptionManageRequest salReq, Long userId)
			throws Exception {
		MstPersonalUser user = mstPersonalUserDao.selectById(userId);
		SalSubscriptionManage oldSal = salSubscriptionManageDao.selectBySubscriptionNo(subscriptionNo);
		if (!Integer.valueOf(1).equals(user.getUserType()) && !user.getFacilityCd().equals("nkknkk")) {
			if(!Integer.valueOf(1).equals(user.getAdministrator())) {
				throw new AccessDeniedException("");
			}else {
				if (oldSal.getSubscriptionStatus().equals(SalSubscriptionManageStatus.ACCEPTED) || oldSal.getSubscriptionStatus().equals(SalSubscriptionManageStatus.COMPLETION) || oldSal.getSubscriptionStatus().equals(SalSubscriptionManageStatus.CANCEL)) {
					throw new Exception();
				}
			}
		}else {
			if (oldSal.getSubscriptionStatus().equals(SalSubscriptionManageStatus.COMPLETION) || oldSal.getSubscriptionStatus().equals(SalSubscriptionManageStatus.CANCEL)) {
				throw new Exception();
			}
		}
		Timestamp upDate = getCurrentDate();
		SalSubscriptionManage salSubscription = new SalSubscriptionManage() {
			{
				setSubscriptionNo(subscriptionNo);
				setSubscriptionStatus(salReq.getSubscriptionStatus());
				setUpDate(upDate);
				setCanceller(userId);
				setCancelDate(upDate);
			}
		};

		salSubscriptionManageDao.updateCancel(salSubscription);
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
	  * {@inheritDoc}
	  */
	@Override
	public Page<SalSubManResponse> findByDataSearch(SalSubManSearchRequest request, Long userId, Pageable pageable) {
		MstPersonalUser user = mstPersonalUserDao.selectById(userId);
		if (!Integer.valueOf(1).equals(user.getUserType()) && !user.getFacilityCd().equals("nkknkk")) {
			throw new AccessDeniedException("");
		}
		ObjectMapper mapper = new ObjectMapper();
		String text = null;
		if(request.getFreeWord() != null){
			text = request.getFreeWord().toUpperCase();
		}
		SelectOptions selectOptions = SelectOptionsUtils.get(pageable, false);
		List<SalSubscriptionManageCustom> listSalSub = salSubscriptionManageDao.selectBySearchCondition(
				request.getStartDate(), request.getEndDate(), request.getPrefecturesCd(), request.getDepartmentCd(),
				text, request.getSubscriptionStatusList(), selectOptions);
		List<SalSubManResponse> response = new ArrayList<SalSubManResponse>();
		if (listSalSub.size() > 0) {
			listSalSub.stream().forEach(i -> {
				List<SysFunctionResponse> functionList = new ArrayList<SysFunctionResponse>();
				SalSubManResponse sal = new SalSubManResponse();
				sal.setSubscriptionNo(i.getSubscriptionNo());
				sal.setFacilityCd(i.getFacilityCd());
				sal.setFacilityName(i.getFacilityName());
				sal.setIsFirst(i.getIsFirst());
				sal.setSubscriptionPlanName(i.getSubscriptionPlanName());
				try {
					if (i.getSubscriptionFnc() != null) {
						Map<String, List<String>> functions = mapper.readValue(i.getSubscriptionFnc(), new TypeReference<Map<String, List<String>>>(){});
						if (functions.get("item_cd") != null && functions.get("item_cd").size() > 0) {
							functions.get("item_cd").forEach(j -> {
								SysFunction fun = sysFunctionDao.selectByFunctionCd(j);
                // add FNSI-nullpointの異常を防止する 付 start
								if (!Objects.isNull(fun)) {
                  SysFunctionResponse funRes = new SysFunctionResponse();
                  funRes.setFunctionCd(fun.getFunctionCd());
                  funRes.setFunctionName(fun.getFunctionName());
                  funRes.setDispOrder(fun.getDispOrder());
                  funRes.setAdv(false);
                  if (SalSubscriptionManageStatus.COMPLETION.equals(i.getSubscriptionStatus())) {
                    funRes.setUsedStatus(true);
                  } else {
                    funRes.setUsedStatus(false);
                  }
                  functionList.add(funRes);
                }
                // add FNSI-nullpointの異常を防止する 付 end
							});
						}
					}
					if (i.getSubscriptionAdv() != null) {
						Map<String, List<String>> functionAdvs = mapper.readValue(i.getSubscriptionAdv(), new TypeReference<Map<String, List<String>>>(){});
						if (functionAdvs.get("item_cd") != null && functionAdvs.get("item_cd").size() > 0) {
							functionAdvs.get("item_cd").forEach(j -> {
								SysFunctionAdvanced fun = sysFunctionAdvancedDao.selectByFunctionAdvCd(j);
								// add FNSI-nullpointの異常を防止する 付 start
								if (!Objects.isNull(fun)) {
                  SysFunctionResponse funRes = new SysFunctionResponse();
                  funRes.setFunctionCd(fun.getFunctionAdvCd());
                  funRes.setFunctionName(fun.getFunctionAdvName());
                  funRes.setDispOrder(fun.getDispOrder());
                  funRes.setAdv(true);
                  if (SalSubscriptionManageStatus.COMPLETION.equals(i.getSubscriptionStatus())) {
                    funRes.setUsedStatus(true);
                  } else {
                    funRes.setUsedStatus(false);
                  }
                  functionList.add(funRes);
                }
                // add FNSI-nullpointの異常を防止する 付 end
							});
						}
					}

				} catch (JsonParseException e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
				} catch (JsonMappingException e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
				} catch (IOException e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
				}
				sal.setSysFunctionList(functionList);
				sal.setSubscriptionStatus(i.getSubscriptionStatus());
				if (i.getApplicant() != null) {
					sal.setApplicant(i.getApplicant());
					MstPersonalUser applicant = mstPersonalUserDao.selectById(Long.valueOf(i.getApplicant()));
					sal.setApplicantName(applicant.getUserLastName() + " " + applicant.getUserFirstName());
					sal.setRegDate(i.getRegDate());
				}
				if (i.getReceptionist() != null) {
					sal.setReceptionist(i.getReceptionist());
					MstPersonalUser receptionist = mstPersonalUserDao.selectById(Long.valueOf(i.getReceptionist()));
					sal.setReceptionistName(receptionist.getUserLastName() + " " + receptionist.getUserFirstName());
					sal.setReceptionDate(i.getReceptionDate());
				}
				if (i.getCompleter() != null) {
					sal.setCompleter(i.getCompleter());
					MstPersonalUser completer = mstPersonalUserDao.selectById(Long.valueOf(i.getCompleter()));
					sal.setCompleterName(completer.getUserLastName() + " " + completer.getUserFirstName());
					sal.setCompleteDate(i.getCompleteDate());
				}
				if (i.getCanceller() != null) {
				  sal.setCanceller(i.getCanceller());
				  MstPersonalUser completer = mstPersonalUserDao.selectById(Long.valueOf(i.getCanceller()));
				  sal.setCancellerName(completer.getUserLastName() + " " + completer.getUserFirstName());
				  sal.setCancelDate(i.getCancelDate());
				}
				response.add(sal);
			});
		}
		return new PageImpl<>(response, pageable, selectOptions.getCount());
	}

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
  private DataUpdateLogCommonNew getLogCommon(Object dao, String tableName, StringBuffer whereStr, EventLogMessage eventLogMessage) {
    DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
    logCommon.setEventLoggerFactory(eventLoggerFactory);
    logCommon.setLogServiceCore(logServiceCore);
    logCommon.setConfig(Config.get(dao));
    logCommon.setTableName(tableName);
    logCommon.setWhereStr(whereStr);
    logCommon.setCommonEventLogMessage(eventLogMessage);
    return logCommon;
  }

  //FNSI-修正 ログ対応 wp add end

}
