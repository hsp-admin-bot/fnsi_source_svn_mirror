package jp.co.nikkiso.ntss.admin_web.security;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import jp.co.nikkiso.ntss.admin_web.service.FacilitySettingService;
import jp.co.nikkiso.ntss.admin_web.service.master.user.MstUserService;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.TwoFactAuth;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logevent.ILogEventService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;

import java.util.Objects;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpOutputMessage;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.http.server.ServletServerHttpResponse;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.WebAttributes;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;

import com.google.common.base.Strings;

import jp.co.nikkiso.ntss.core.constant.CoreConstant.FacilitySettingNo;
import jp.co.nikkiso.ntss.core.dao.MstFacilityHashDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstUserDao;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.admin_web.response.LoginOtpResponse;
import jp.co.nikkiso.ntss.admin_web.response.LoginResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.web.authentication.WebAuthenticationDetails;
import org.springframework.util.StringUtils;

/**
 * NTSS認証成功ハンドラー実装クラス.
 */
@Slf4j
public class NtssAuthenticationSuccessHandler implements AuthenticationSuccessHandler {

  /** modify by wangying 2022-11-18[6505]サインイン・サインアウトの用語統一が行われていない -- start */
  //FNSI-修正 ログ対応 xiebzh add start
  /** ログメッセージフォーマット */
  private final static String LOG_MESSAGE = "%sが正常にサインインしました。";
  //FNSI-修正 ログ対応 xiebzh add end
  /** modify by wangying 2022-11-18[6505]サインイン・サインアウトの用語統一が行われていない -- end */

  @Autowired
  MappingJackson2HttpMessageConverter httpMessageConverter;

  @Autowired
  FacilitySettingService facilitySettingService;

  /**
   * ロギングのServiceインタフェース.
   */
  @Autowired
  private LogService logService;

  /**
   * 施設設定マスタDaoインタフェース.
   */
  @Autowired
  MstFacilitySettingDao mstFacilitySettingDao;

  /**
   * 利用者マスタのDaoインタフェース.
   */
  @Autowired
  MstUserDao mstUserDao;

  /**
   * 利用者マスタ(個人情報DB)Daoインタフェース.
   */
  @Autowired
  private MstUserService mstUserService;

  /**
   * 施設マスタハッシュのDaoインタフェース.
   */
  @Autowired
  private MstFacilityHashDao mstFacilityHashDao;

  /**
   * 利用者マスタ(個人情報DB)のDaoインタフェース.
   */
  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;

  @Autowired
  ILogEventService logEventService;

  /**
   * {@inheritDoc}
   */
	@Override
	public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
			Authentication authentication) throws IOException, ServletException {
		if (response.isCommitted()) {
			EventLogMessage eventLogMessage = new EventLogMessage();
			eventLogMessage.setLogMessage("Response has already been committed.");
			logService.log(LogLevel.INFO, eventLogMessage, null, null, null);
			return;
		}

		// ユーザーの情報をJSONで返す
		NtssUser ntssUser = (NtssUser) authentication.getPrincipal();

		HttpOutputMessage outputMessage = new ServletServerHttpResponse(response);

		// requestパラメータの passwd、funcCd が特定の値だった場合は、自動ログインの為、OTP認証処理をスキップする
		String paramPasswd = request.getParameter("password") != null ? request.getParameter("password") : "";
		String paramFuncCd = request.getParameter("funcCd") != null ? request.getParameter("funcCd") : "";

		// user_type[2]、administrator[0] は [ユーザー操作無しアプリ]向けのシステム用アカウント なので OTP認証スキップ
		MstPersonalUser mpu = mstPersonalUserDao.selectById(ntssUser.getUserId());
		if (Objects.equals(mpu.getUserType(), 2) && Objects.equals(mpu.getAdministrator(), 0)) {
		  paramPasswd = "_";
		  paramFuncCd = "_";
		}

		// 無効なOTP
		boolean isInvalidOtp = false;
		// Otp画面のリダイレクト
		boolean redirectOtp = false;
		// 最初のログインOTPのリダイレクト
		boolean redirectFirstLoginOtp = false;
		TwoFactAuth tFA = new TwoFactAuth();
		FacilitySettingInfo facilitySetting = mstFacilitySettingDao.getValueSignInByFacilityCd(ntssUser.getFacilityCd());
		MstUser user = mstUserDao.selectById(ntssUser.getUserId());
		// 新しいアカウントで最初のログインの時は実施しない
		if (user.getIsProvisional() == 0 && !(paramPasswd.equals("_") && paramFuncCd.equals("_"))) {
			// OTPコードリクエストを取得する
			String otpCd = "";
			if (request.getParameter("otpCd") != null) {
				otpCd = request.getParameter("otpCd").toString();
			}
			// 結果チェックOTP
			boolean checkOtp = mstUserService.checkOtpPassword(ntssUser.getUserId(), otpCd);
			// 必須使用
			if (facilitySetting.getValue().equals("2")) {
				// otpより多くの時間でログインする
				if (user.getIsSetQrCode() == 1) {
					if (!Strings.isNullOrEmpty(otpCd) || request.getParameter("otpCd") == "") {
						if (checkOtp == false) {
							isInvalidOtp = true;
						}
					} else {
						redirectOtp = true;
					}
				} else {
					if (!Strings.isNullOrEmpty(otpCd) || request.getParameter("otpCd") == "") {
						if (checkOtp == false) {
							isInvalidOtp = true;
						}
					} else {
						redirectFirstLoginOtp = true;
					}
				}
			} else
			// 任意使用
			if (facilitySetting.getValue().equals("1")) {
				// 存在するユーザーの秘密鍵を確認してください
				if (user.getSecretKey() != null) {
					// otpより多くの時間でログインする
					if (user.getIsSetQrCode() == 1) {
						if (!Strings.isNullOrEmpty(otpCd) || request.getParameter("otpCd") == "") {
							if (checkOtp == false) {
								isInvalidOtp = true;
							}
						} else {
							redirectOtp = true;
						}
					}
				}
			}

		}

		// add #12587 スタッフ切替 start
	    if(((WebAuthenticationDetails)authentication.getDetails()).getSessionId() != null){
	      redirectOtp = false;
	    }
		// add #12587 スタッフ切替 end

		if (isInvalidOtp || redirectOtp || redirectFirstLoginOtp) {

			if (isInvalidOtp) {
				// 無効なOTPコードによりロックされています

				response.setStatus(HttpServletResponse.SC_FORBIDDEN);
				LoginOtpResponse loginOtpResponse = new LoginOtpResponse("0", "ワンタイムパスワードが正しくありません");
				httpMessageConverter.write(loginOtpResponse, MediaType.APPLICATION_JSON_UTF8, outputMessage);
				request.getSession().invalidate();
				SecurityContextHolder.getContext().getAuthentication().setAuthenticated(false);

			}
			if (redirectOtp) {
				// OTP画面をリダイレクトする必要があるためロックされています

				response.setStatus(HttpServletResponse.SC_OK);
				LoginOtpResponse loginOtpResponse = new LoginOtpResponse("1", "OTP画面にリダイレクト。");
				httpMessageConverter.write(loginOtpResponse, MediaType.APPLICATION_JSON_UTF8, outputMessage);
				request.getSession().invalidate();
				SecurityContextHolder.getContext().getAuthentication().setAuthenticated(false);
			}
			if (redirectFirstLoginOtp) {
				// QRコードを生成するためにリダイレクトによってロックされています

				// QRコード生成用データをJSON文字列で返す（実際の生成は画面側で生成ボタンを押すタイミング）
				String template = "{\"dispUserId\": \"%s\", \"facilityCd\": \"%s\"}";
				String QRcode = String.format(template, ntssUser.getUsername(), ntssUser.getFacilityCd());

				response.setStatus(HttpServletResponse.SC_OK);
				LoginOtpResponse loginOtpResponse = new LoginOtpResponse("2", QRcode);
				httpMessageConverter.write(loginOtpResponse, MediaType.APPLICATION_JSON_UTF8, outputMessage);
				request.getSession().invalidate();
				SecurityContextHolder.getContext().getAuthentication().setAuthenticated(false);
			}
		} else {

			LoginResponse loginResponse = new LoginResponse(ntssUser.getFacilityCd(), ntssUser.getUserId(),
					ntssUser.getUserType());
			httpMessageConverter.write(loginResponse, MediaType.APPLICATION_JSON_UTF8, outputMessage);
			// 認証時に設定したモードをHTTPリクエストから取得
			String paramMode = request.getParameter("mode") != null ? request.getParameter("mode") : "";
			// 強制サインアウトする/しないフラグ初期化（0:強制サインアウトする）
			String forceTimeOutFlg = "0";
			/* 体重計モード ((FUNC=013 or FUNC=01301) and MODE=1) の場合 */
			if ((paramFuncCd.equals("013") || paramFuncCd.equals("01301")) && paramMode.equals("1")) {
				// 施設設定マスタから強制サインアウトする/しないの状態を取得
				forceTimeOutFlg = facilitySettingService.getFacilitySettingValue(ntssUser.getFacilityCd(), FacilitySettingNo.FORCE_SIGN_OUT_IN_WEIGHT_MODE);
			}
			// 施設設定マスタからサインアウト時間を取得
			final int timeOutSec = Integer.valueOf(facilitySettingService
					.getFacilitySettingValue(ntssUser.getFacilityCd(), FacilitySettingNo.TIME_OUT_MINUTES)) * 60;
			request.getSession().setMaxInactiveInterval(forceTimeOutFlg.equals("0") ? timeOutSec : 0);
			response.setStatus(HttpStatus.OK.value());
			clearAuthenticationAttributes(request);

			// セッションIDを認証情報に確認
			ntssUser.setSessionId(request.getSession().getId());
			// 接続先IPアドレス
			String clientIp = request.getHeader("X-FORWARDED-FOR");
			if (StringUtils.isEmpty(clientIp)) {
				clientIp = request.getRemoteAddr();
			}
			ntssUser.setClientIpAddress(clientIp);

			// 成功時のログ
			EventLogMessage eventLogMessage = new EventLogMessage();
      //FNSI-修正 ログ対応 xiebzh add start
			//eventLogMessage.setLogMessage("正常にサインインしました。");
      eventLogMessage.setLogMessage(String.format(LOG_MESSAGE, logEventService.getPersonalUserName(ntssUser.getUserId())));
      eventLogMessage.setFunctionName("サインイン");
      //FNSI-修正 ログ対応 xiebzh add end
			logService.log(LogLevel.MONGO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
		}
	}

  /**
   * Removes temporary authentication-related data which may have been stored in the
   * session during the authentication process.
   */
  private void clearAuthenticationAttributes(HttpServletRequest request) {
    HttpSession session = request.getSession(false);

    if (session == null) {
      return;
    }
    session.removeAttribute(WebAttributes.AUTHENTICATION_EXCEPTION);
  }
}
