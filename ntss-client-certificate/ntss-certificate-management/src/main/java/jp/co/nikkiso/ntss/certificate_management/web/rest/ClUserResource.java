package jp.co.nikkiso.ntss.certificate_management.web.rest;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.security.core.Authentication;

import jp.co.nikkiso.ntss.certificate_management.constant.ClientCertificateConstant.ScreenName;
import jp.co.nikkiso.ntss.certificate_management.constant.ClientCertificateConstant.Uri;
import jp.co.nikkiso.ntss.certificate_management.response.clUser.ResponseClUserSetting;
import jp.co.nikkiso.ntss.certificate_management.security.NtssUser;
import jp.co.nikkiso.ntss.certificate_management.service.ClUserService;
import jp.co.nikkiso.ntss.certificate_management.service.log.LogService;
import jp.co.nikkiso.ntss.core.entity.ClUser;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;

@RestController
@RequestMapping(Uri.CLUSER)
public class ClUserResource {

    // クライアントユーザーサービス
    @Autowired
    ClUserService clUserService;

    // サインイン制限
    @Value("${ntss.certificate.sign-in.restriction}")
    private Boolean signInRestriction;

    // ロギングサービス
    @Autowired
    LogService logService;

    /**
     * すべてのユーザーを取得
     *
     * @return クライアントユーザー
     */
    @GetMapping("/getAllUser")
    //mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
    //public ResponseEntity<List<ClUser>> getAllUser() {
    public ResponseEntity<List<ClUser>> getAllUser(String OrderKey) {
      //mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
        try {
          //mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
          // List<ClUser> list = clUserService.getAllUser();
          List<ClUser> list = clUserService.getAllUser(OrderKey);
          //mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
            return new ResponseEntity<List<ClUser>>(list, HttpStatus.OK);
        } catch (Exception e) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            String errMsg = e.getMessage();
            if (errMsg == null) {
                errMsg = e.toString() + " " + e.getStackTrace()[0];
            }
            eventLogMessage.setLogMessage("jp.co.nikkiso.ntss.certificate_management.web.rest.ClUserResource.java method:getAllUser エラー: " + errMsg);
            logService.log(LogLevel.ERROR, eventLogMessage, null, ScreenName.MANAGEMENT_USER_LIST, null);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * IDでユーザーを削除
     *
     * @param clUser クライアントユーザー
     * @return ストリング
     */
    @PostMapping("/deleteById")
    public ResponseEntity<String> deleteById(@RequestBody ClUser clUser) {
        try {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            NtssUser ntssUser = (NtssUser) authentication.getPrincipal();
            if (ntssUser.getUsername().equals(clUser.getUserId())) {
                EventLogMessage eventLogMessage = new EventLogMessage();
                eventLogMessage.setLogMessage("REST to delete current ClUser: 自分を削除することはできません");
                logService.log(LogLevel.WARN, eventLogMessage, null, ScreenName.MANAGEMENT_USER_LIST, null);
                return new ResponseEntity<String>("自分を削除することはできません", HttpStatus.BAD_REQUEST);
            } else {
                clUserService.deleteUser(clUser.getUserId());
            }
            return new ResponseEntity<String>("success", HttpStatus.OK);
        } catch (Exception e) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            String errMsg = e.getMessage();
            if (errMsg == null) {
                errMsg = e.toString() + " " + e.getStackTrace()[0];
            }
            eventLogMessage.setLogMessage("jp.co.nikkiso.ntss.certificate_management.web.rest.ClUserResource.java method:deleteById エラー: " + errMsg);
            logService.log(LogLevel.ERROR, eventLogMessage, null, ScreenName.MANAGEMENT_USER_LIST, null);
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

    /**
     * IDでユーザーを更新
     *
     * @param clUser クライアントユーザー
     * @return ストリング
     */
    @PostMapping("/updateById")
    public ResponseEntity<String> updateById(@RequestBody ClUser clUser) {
        try {
            if (!clUser.getUserPass().equals("")) {
                clUserService.updateUser(clUser.getId(), clUser.getUserName(), clUser.getUserRole(),
                        clUser.getDepartmentCd(), clUser.getUserPass(), clUser.getUpDate());
            } else {
                clUserService.updateUserNoPass(clUser.getId(), clUser.getUserName(), clUser.getUserRole(),
                        clUser.getDepartmentCd(), clUser.getUpDate());
            }
            return new ResponseEntity<String>("success", HttpStatus.OK);
        } catch (Exception e) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            String errMsg = e.getMessage();
            if (errMsg == null) {
                errMsg = e.toString() + " " + e.getStackTrace()[0];
            }
            eventLogMessage.setLogMessage("jp.co.nikkiso.ntss.certificate_management.web.rest.ClUserResource.java method:updateById エラー: " + errMsg);
            logService.log(LogLevel.ERROR, eventLogMessage, null, ScreenName.MANAGEMENT_USER_EDIT_SCREEN, null);
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

    /**
     * ユーザーを挿入
     *
     * @param clUser クライアントユーザー
     * @return ストリング
     */
    @PostMapping("/insertUser")
    public ResponseEntity<String> insertUser(@RequestBody ClUser clUser) {
        try {
            ClUser userExist = clUserService.selectById(clUser.getUserId());
            if (userExist == null) {
                clUserService.insertUser(clUser.getUserName(), clUser.getUserRole(), clUser.getRegDate(),
                        clUser.getUpDate(), clUser.getDepartmentCd(), clUser.getUserPass(), clUser.getUserId(), 0);
                return new ResponseEntity<String>("success", HttpStatus.OK);
            } else {
                EventLogMessage eventLogMessage = new EventLogMessage();
                eventLogMessage.setLogMessage("REST to insert ClUser: IDは既に存在します。");
                logService.log(LogLevel.WARN, eventLogMessage, null, ScreenName.MANAGEMENT_USER_EDIT_SCREEN, null);
                return new ResponseEntity<String>("duplicated", HttpStatus.BAD_REQUEST);
            }
        } catch (Exception e) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            String errMsg = e.getMessage();
            if (errMsg == null) {
                errMsg = e.toString() + " " + e.getStackTrace()[0];
            }
            eventLogMessage.setLogMessage("jp.co.nikkiso.ntss.certificate_management.web.rest.ClUserResource.java method:insertUser エラー: " + errMsg);
            logService.log(LogLevel.ERROR, eventLogMessage, null, ScreenName.MANAGEMENT_USER_EDIT_SCREEN, null);
            return new ResponseEntity<String>(HttpStatus.BAD_REQUEST);
        }
    }

    /**
     * ユーザー設定を取得
     *
     * @return ユーザー設定
     */
    @GetMapping("/getUserSetting")
    public ResponseEntity<ResponseClUserSetting> getUserSetting() {

        try {
            ResponseClUserSetting userSetting = clUserService.getUserSetting();
            return new ResponseEntity<>(userSetting, HttpStatus.OK);
        } catch (Exception e) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            String errMsg = e.getMessage();
            if (errMsg == null) {
                errMsg = e.toString() + " " + e.getStackTrace()[0];
            }
            eventLogMessage.setLogMessage("jp.co.nikkiso.ntss.certificate_management.web.rest.ClUserResource.java method:getUserSetting エラー: " + errMsg);
            logService.log(LogLevel.ERROR, eventLogMessage, null, ScreenName.MANAGEMENT_USER_EDIT_SCREEN, null);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("/updateLoginAttempt")
    public ResponseEntity<String> updateLoginAttempt(@RequestBody ClUser clUser) {
        try {
            clUserService.updateAttemptFail(clUser.getUserId(), clUser.getNumLoginAttempt());
            return new ResponseEntity<>(null, HttpStatus.OK);
        } catch (Exception e) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            String errMsg = e.getMessage();
            if (errMsg == null) {
                errMsg = e.toString() + " " + e.getStackTrace()[0];
            }
            eventLogMessage.setLogMessage("jp.co.nikkiso.ntss.certificate_management.web.rest.ClUserResource.java method:updateLoginAttempt エラー: " + errMsg);
            logService.log(LogLevel.ERROR, eventLogMessage, null, ScreenName.MANAGEMENT_USER_LIST, null);
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }
}
