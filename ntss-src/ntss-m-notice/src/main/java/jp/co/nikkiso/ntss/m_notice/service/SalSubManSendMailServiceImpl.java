package jp.co.nikkiso.ntss.m_notice.service;

import java.net.URLEncoder;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import io.micrometer.core.instrument.util.StringUtils;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import tools.jackson.core.JacksonException;
import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityHashDao;
import jp.co.nikkiso.ntss.core.dao.SalSubscriptionManageDao;
import jp.co.nikkiso.ntss.core.dao.SysFunctionAdvancedDao;
import jp.co.nikkiso.ntss.core.dao.SysFunctionDao;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstFacilityHash;
import jp.co.nikkiso.ntss.core.entity.SalSubscriptionManage;
import jp.co.nikkiso.ntss.core.entity.SysFunction;
import jp.co.nikkiso.ntss.core.entity.SysFunctionAdvanced;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import jp.co.nikkiso.ntss.m_notice.constant.MNoticeConstant;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * オプション申請メール送信のService.
 */
@Service
public class SalSubManSendMailServiceImpl implements SalSubManSendMailService {
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
  @Autowired
  private LogService logService;
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end

	/**
	 * システム設定クラスのService実装クラス.
	 */
	@Autowired
	SysSystemDefineService defineService;

	/**
	 * オプション申込のDao.
	 */
	@Autowired
	SalSubscriptionManageDao salSubscriptionManageDao;

	/**
	 * 施設マスタのDao.
	 */
	@Autowired
	MstFacilityDao mstFacilityDao;

	@Autowired
	MstFacilityHashDao mstFacilityHashDao;

	/**
	 * メール送信サービスです.
	 */
	@Autowired
	MailSenderService mailSenderService;

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
	 * メールを送る
	 *
	 * @param salSubscriptionManage
	 * @return
	 */
	@Override
	public void sendMail(Map<String, String> salSubscriptionManage) throws Exception {

		int ctlNo = 0;
		String serviceCd = "";
		String subject = "";
		String mailBody = "";
		Long subscriptionNo = Long.valueOf(salSubscriptionManage.get("subscriptionNo"));
		SalSubscriptionManage salSubMan = salSubscriptionManageDao.selectBySubscriptionNo(subscriptionNo);
		MstFacility facility = mstFacilityDao.selectByCd(salSubMan.getFacilityCd());
      /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
	  // facilityCd = salSubMan.getFacilityCd();
      String facilityCd = salSubMan.getFacilityCd();
      /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
		List<String> targetsEmail = new ArrayList<String>();
		targetsEmail.add(facility.getSalesEmailAddress());
		SysSystemDefine sysSystemDefine = null;
		switch (salSubMan.getSubscriptionStatus()) {
		case MNoticeConstant.SalSubscriptionManageStatus.NOT_ACCEPTED:
			ctlNo = 18;
			serviceCd = "003";
			sysSystemDefine = defineService.selectByCtlNoAndServiceCd(ctlNo, serviceCd);
          /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
			subject = getValueEmail(sysSystemDefine, facilityCd);
			subject = getMailSubject(subject, facility.getFacilityName());

			ctlNo = 19;
			serviceCd = "003";
			sysSystemDefine = defineService.selectByCtlNoAndServiceCd(ctlNo, serviceCd);
			mailBody = getValueEmail(sysSystemDefine, facilityCd);
          // mailBody = getMailBody(mailBody, facility.getFacilityName(), salSubMan.getSubscriptionFnc(),
          //         salSubMan.getSubscriptionAdv(), salSubMan.getRegDate());
          mailBody = getMailBody(mailBody, facility.getFacilityName(), salSubMan.getSubscriptionFnc(),
                  salSubMan.getSubscriptionAdv(), salSubMan.getRegDate(), facilityCd);
          /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
			mailSenderService.sendMessage(targetsEmail, subject, mailBody);
			break;
		case MNoticeConstant.SalSubscriptionManageStatus.COMPLETION:
			ctlNo = 22;
			serviceCd = "003";
			sysSystemDefine = defineService.selectByCtlNoAndServiceCd(ctlNo, serviceCd);

          /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
			subject = getValueEmail(sysSystemDefine, facilityCd);
			subject = getMailSubject(subject, facility.getFacilityName());

			ctlNo = 23;
			serviceCd = "003";
			sysSystemDefine = defineService.selectByCtlNoAndServiceCd(ctlNo, serviceCd);
			mailBody = getValueEmail(sysSystemDefine, facilityCd);
          // mailBody = getMailBody(mailBody, facility.getFacilityName(), salSubMan.getSubscriptionFnc(),
          //         salSubMan.getSubscriptionAdv(), salSubMan.getRegDate());
          mailBody = getMailBody(mailBody, facility.getFacilityName(), salSubMan.getSubscriptionFnc(),
                  salSubMan.getSubscriptionAdv(), salSubMan.getRegDate(), facilityCd);
          /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
			mailSenderService.sendMessage(targetsEmail, subject, mailBody);
			break;
		case MNoticeConstant.SalSubscriptionManageStatus.CANCEL:
			ctlNo = 20;
			serviceCd = "003";
          /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
			sysSystemDefine = defineService.selectByCtlNoAndServiceCd(ctlNo, serviceCd);
			subject = getValueEmail(sysSystemDefine, facilityCd);
			subject = getMailSubject(subject, facility.getFacilityName());

			ctlNo = 21;
			serviceCd = "003";
			sysSystemDefine = defineService.selectByCtlNoAndServiceCd(ctlNo, serviceCd);
			mailBody = getValueEmail(sysSystemDefine, facilityCd);
          // mailBody = getMailBody(mailBody, facility.getFacilityName(), salSubMan.getSubscriptionFnc(),
          //         salSubMan.getSubscriptionAdv(), salSubMan.getRegDate());
          mailBody = getMailBody(mailBody, facility.getFacilityName(), salSubMan.getSubscriptionFnc(),
                  salSubMan.getSubscriptionAdv(), salSubMan.getRegDate(), facilityCd);
          /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
			mailSenderService.sendMessage(targetsEmail, subject, mailBody);
			break;
		default:
			break;
		}

	}

	/**
	 * メール本文を取得
	 *
	 * @param mailText
	 *            メール本文
	 * @param facilityName
	 *            施設名
	 * @param function
	 *            機能一覧クラス
	 * @param functionAdv
	 *            拡張機能
	 * @param date
	 *            日付
	 * @return
	 */
    /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
	// private String getMailBody(String mailText, String facilityName, String function, String functionAdv,
	// 		Timestamp date) throws Exception {
    private String getMailBody(String mailText, String facilityName, String function, String functionAdv,
         Timestamp date, String facilityCd) throws Exception {
    /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
		ObjectMapper mapper = new ObjectMapper();
		List<String> functionsAll = new ArrayList<>();
		if (functionAdv != null) {
			Map<String, List<String>> functionAdvs = mapper.readValue(functionAdv, new TypeReference<Map<String, List<String>>>(){});
			if (functionAdvs.get("item_cd") != null && functionAdvs.get("item_cd").size() > 0) {
				functionAdvs.get("item_cd").forEach(i -> {
					SysFunctionAdvanced fun = sysFunctionAdvancedDao.selectByFunctionAdvCd(i);
					functionsAll.add(i + ": " + fun.getFunctionAdvName());
				});
			}
		}

		if (function != null) {
			Map<String, List<String>> functions = mapper.readValue(function, new TypeReference<Map<String, List<String>>>(){});
			if (functions.get("item_cd") != null && functions.get("item_cd").size() > 0) {
				functions.get("item_cd").forEach(i -> {
					SysFunction fun = sysFunctionDao.selectByFunctionCd(i);
					functionsAll.add(i + ": " + fun.getFunctionName());
				});
			}
		}
		String functionName = "";
		if (functionsAll.size() > 0) {
			functionName = functionsAll.stream().map(n -> String.valueOf(n))
					.collect(Collectors.joining(", ", "[", "]"));
		}
    /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
    // String url = getUrl();
    String url = getUrl(facilityCd);
    /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
		String mailbody = mailText.replace("[申込施設名]", facilityName).replace("[申込日時]", date.toString()).replace("[申込機能一覧]",
				functionName).replace("[URL]", url);
		return mailbody;
	}

  /* del by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  // String facilityCd;
  /* del by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

  /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  // private String getUrl() {
  private String getUrl(String facilityCd) {
  /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
    ObjectMapper mapper = new ObjectMapper();
    int ctlNo = 4;
    String serviceCd = "003";
    String url = "";
    SysSystemDefine sysSystemDefine = defineService.selectByCtlNoAndServiceCd(ctlNo, serviceCd);
    try {
      Map<String, String> urlDefine = mapper.readValue(sysSystemDefine.getValue(), new TypeReference<Map<String, String>>(){});
      MstFacilityHash mstFacilityHash = mstFacilityHashDao.selectByFacilityCd(facilityCd);
      url = urlDefine.get("url") + URLEncoder.encode(mstFacilityHash.getHashValue(), "UTF-8") + "&FUNC=038";
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (!StringUtils.isEmpty(facilityCd)) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }
    return url;
  }

	private String getMailSubject(String mailText, String facilityName) {
		String mailSubject = mailText.replace("[申込施設名]", facilityName);
		return mailSubject;
	}

  /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
	// private String getValueEmail(SysSystemDefine sysSystemDefine, String facilityCd) {
  private String getValueEmail(SysSystemDefine sysSystemDefine, String facilityCd) {
    /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
		ObjectMapper mapper = new ObjectMapper();
		String value = "";
		if (sysSystemDefine.getCtlNo().intValue() == 18 || sysSystemDefine.getCtlNo().intValue() == 20 || sysSystemDefine.getCtlNo().intValue() == 22) {
			try {
				JsonNode root = mapper.readTree(sysSystemDefine.getValue());
				value = root.get("mail_subject").asText();
			} catch (JacksonException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        if (!StringUtils.isEmpty(facilityCd)) {
          eventLogMessage.setFacilityCd(facilityCd);
        }
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
			}
		}
		if (sysSystemDefine.getCtlNo().intValue() == 19 || sysSystemDefine.getCtlNo().intValue() ==  21 || sysSystemDefine.getCtlNo().intValue() ==  23) {
			try {
				JsonNode root = mapper.readTree(sysSystemDefine.getValue());
				value = root.get("mail_body").asText();
			} catch (JacksonException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        if (!StringUtils.isEmpty(facilityCd)) {
          eventLogMessage.setFacilityCd(facilityCd);
        }
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
			}
		}

		return value;
	}

}
