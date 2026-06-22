package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.service.userAccount.UserAccountService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MstUserAuthenticationDao;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterUpdateResponse;
import jp.co.nikkiso.ntss.admin_web.service.MstInfoService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.master.user.MstUserService;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;

/**
 * 2要素認証登録/削除処理のResourceクラス.
 */
@RestController
@RequestMapping(Uri.REGISTER_OTP_AT_SIGN_IN)
public class registerOtpResource {

    /**
    * 利用者一覧Service.
    */
    @Autowired
    private MstUserService mstUserService;

    /**
    * マスタService.
    */
    @Autowired
    MstInfoService mstInfoService;

    @Autowired
    LogService logService;

    /**
    * 利用者マスタ(認証DB)のDaoインタフェース.
    */
    @Autowired
    MstUserAuthenticationDao mstUserAuthenticationDao;

    @Autowired
    private UserAccountService userAccountService;

    /**
    * ユーザーOTPを作成
    *
    * @param dispUserId 表示用利用者ID
    * @param facilityCd 施設コード
    * @return 秘密鍵、QRコード(Base64形式)
    *
    */
    @GetMapping("/cre_mst_user_otp/{dispUserId}/{facilityCd}")
    public ResponseEntity<?> createMstUserOTP(@PathVariable String dispUserId, @PathVariable String facilityCd) {
      try {
        return new ResponseEntity<>(mstUserService.createSecretKey(dispUserId, facilityCd), HttpStatus.OK);
      } catch (Exception e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("Exception message : " + e.getMessage());
        logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE,SERVICE_NAME.REMS, null);
        return null;
      }
    }

    /**
    * ワンタイムパスワードのチェック（登録時）
    *
    * @param otp ワンタイムパスワード
    * @param secretKey 秘密鍵
    * @return 認証成功=true, 認証失敗=false
    *
    */
    @PutMapping("/checkOTP/{otp}/{secretKey}")
    public ResponseEntity<?> checkOTP(@PathVariable String otp, @PathVariable String secretKey) {
      try {
        Boolean response = mstUserService.checkOtpOnRegister(secretKey, otp);
        return new ResponseEntity<>(response, HttpStatus.OK);
      } catch (Exception e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("Exception message : " + e.getMessage());
        logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE,SERVICE_NAME.REMS, null);
        return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()),
            HttpStatus.BAD_REQUEST);
      }
    }

    /**
    * ユーザーOTPの更新
    *
    * @param userId 利用者ID（内部用ID）
    * @param secretKey 秘密鍵
    * @return DB更新結果
    *
    */
    @PutMapping("/upd_scret_key/{userId}/{secretKey}")
    public ResponseEntity<?> updateSecretKey(@PathVariable String userId,@PathVariable String secretKey,
                                             // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                             @AuthenticationPrincipal NtssUser ntssUser
                                             // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(ntssUser != null && !ntssUser.isNkkAdminUser()) {
        MstUser mstUser = mstUserService.getByUserId(Long.parseLong(userId));
        if (mstUser != null && mstUser.getFacilityCd() != null && !mstUser.getFacilityCd().equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                  "mstUser.getFacilityCd()=" + mstUser.getFacilityCd() + " ";
          InvestigateLogUtils.info("11205",msg_11205_FORBIDDEN,"11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

      try {
        MasterUpdateResponse response = mstUserService.updateSecretKey(Long.parseLong(userId), secretKey);
        if(response.isSuccess){
          userAccountService.updateOptStatus("2", Long.parseLong(userId));
        }
        return new ResponseEntity<>(response, HttpStatus.OK);
      } catch (Exception e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("Exception message : " + e.getMessage());
        logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE,SERVICE_NAME.REMS, null);
        return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()),
            HttpStatus.BAD_REQUEST);
      }
    }

    /**
    * 秘密鍵設定フラグを更新
    *
    * @param userId 利用者ID（内部用ID）
    * @param isSetQrCode 秘密鍵設定フラグ
    * @return 更新件数
    *
    */
    @PutMapping("/upd_is_set_qr_code/{userId}/{isSetQrCode}")
    public ResponseEntity<?> updateIsSetQrCode(@PathVariable String userId,@PathVariable String isSetQrCode,
                                               // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                               @AuthenticationPrincipal NtssUser ntssUser
                                               // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(ntssUser != null && !ntssUser.isNkkAdminUser()) {
        MstUser mstUser = mstUserService.getByUserId(Long.parseLong(userId));
        if (mstUser != null && mstUser.getFacilityCd() != null && !mstUser.getFacilityCd().equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                  "mstUser.getFacilityCd()=" + mstUser.getFacilityCd() + " ";
          InvestigateLogUtils.info("11205",msg_11205_FORBIDDEN,"11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

      try {
        int response = mstUserService.updateIsSetQrCode(Long.parseLong(userId), Integer.parseInt(isSetQrCode));
        return new ResponseEntity<>(response, HttpStatus.OK);
      } catch (Exception e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("Exception message : " + e.getMessage());
        logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE,SERVICE_NAME.REMS, null);
        return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()),
            HttpStatus.BAD_REQUEST);
      }
    }

    /**
    * 表示用利用者IDから内部用利用者IDを取得
    *
    * @param dispUserId 表示用利用者ID
    * @param facilityCd 施設コード
    * @return 内部用利用者ID
    *
    */
    @PutMapping("/get_user_id/{dispUserId}/{facilityCd}")
    public ResponseEntity<?> getUserId(@PathVariable String dispUserId, @PathVariable String facilityCd
) {
      try {
        String response = mstUserAuthenticationDao.selectUserId(dispUserId, facilityCd);
        return new ResponseEntity<>(response, HttpStatus.OK);
      } catch (Exception e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("Exception message : " + e.getMessage());
        logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE,SERVICE_NAME.REMS, null);
        return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()),
            HttpStatus.BAD_REQUEST);
      }
    }

    /**
    * 秘密鍵を削除する
    *
    * @param userId 利用者ID（内部用ID）
    * @return DB更新結果
    *
    */
    @PutMapping("/del_scret_key/{userId}")
    public ResponseEntity<?> deleteSecretKey(@PathVariable String userId,
                                             // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                             @AuthenticationPrincipal NtssUser ntssUser
                                             // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        MstUser mstUser = mstUserService.getByUserId(Long.parseLong(userId));
        if (mstUser != null && mstUser.getFacilityCd() != null && !mstUser.getFacilityCd().equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                  "mstUser.getFacilityCd()=" + mstUser.getFacilityCd() + " ";
          InvestigateLogUtils.info("11205",msg_11205_FORBIDDEN,"11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request to update jobCd : " +  userId);
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE,SERVICE_NAME.REMS, null);

      try {
        MasterUpdateResponse response = mstUserService.deleteSecretKey(Long.parseLong(userId));
        if(response.isSuccess){
          userAccountService.updateOptStatus("2", Long.parseLong(userId));
        }
        return new ResponseEntity<>(response, HttpStatus.OK);
      } catch (Exception e) {
        eventLogMessage.setLogMessage("Exception message : " + e.getMessage());
        logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE,SERVICE_NAME.REMS, null);
        return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()),
            HttpStatus.BAD_REQUEST);
      }
    }
}
