package jp.co.nikkiso.ntss.m_notice.web.rest;

import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.m_notice.service.LogEventUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.core.dao.MstDestinationGroupDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.entity.MstDestinationGroup;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.m_notice.constant.MNoticeConstant.MailSetting;
import jp.co.nikkiso.ntss.m_notice.service.MailSenderService;
import jp.co.nikkiso.ntss.m_notice.service.SalSubManSendMailService;
import jp.co.nikkiso.ntss.m_notice.web.dto.MakerNoticeDTO;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@RestController
public class MakerNoticeResource {

  /**
   * 施設マスタのDAOインターフェース
   */
  @Autowired
  private MstFacilityDao mstFacilityDao;

  /**
   * 利用者マスタのDAOインターフェース
   */
  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;

  /**
   * メール送信サービス.
   */
  @Autowired
  private MailSenderService mailSenderService;

  /**
   * 送信先グループマスタのDAOインターフェース
   */
  @Autowired
  private MstDestinationGroupDao mstDestinationGroupDao;

  /**
   * オプション申請メール送信のService
   */
  @Autowired
  private SalSubManSendMailService salSubManSendMailService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  @PostMapping("/api/makerNotice")
  public ResponseEntity<Void> makerNotice(@RequestBody MakerNoticeDTO dto) throws UnsupportedEncodingException {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "/api/makerNotice";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    String subject = new String(dto.getSubject());
    String body = new String(dto.getBody());

    List<MstFacility> mstFacilityList = mstFacilityDao.selectAll();
    // 施設単位でメール送信を行う
    for (MstFacility facilityData : mstFacilityList) {
      // メーカー通知の対象となる送信先グループを取得
      List<MstDestinationGroup> destinationGroupList = mstDestinationGroupDao
          .selectByFacilityCdAndIsNotice(facilityData.getFacilityCd());

      // 利用者一覧を作成する
      List<Long> userList = new ArrayList<Long>();
      for (MstDestinationGroup groupData : destinationGroupList) {
        List<MstDestinationGroup.User> users = groupData.getDestinationTarget().getUsers();
        users.stream()
            .filter(user -> !userList.contains(user.getUserId()))
            .forEach(user -> userList.add(user.getUserId()));
      }
      if (userList.size() != 0) {
        List<String> adressList = new ArrayList<String>();
        adressList = getEMailAdress(destinationGroupList, userList);

        // 宛先が50件以上の場合は送信グループを分ける
        List<String> sendAdress = new ArrayList<>();
        for (int i = 0; i < adressList.size(); i++) {
          sendAdress.add(adressList.get(i));
          if (sendAdress.size() == MailSetting.MAX_ADDRESS || i == adressList.size() - 1) {
            // メール送信
            mailSenderService.sendMessage(sendAdress, subject, body);
            sendAdress = new ArrayList<>();
          }
        }
      }
    }

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(null, HttpStatus.OK);
  }

  /**
   * メーカー通知の送信対象メールアドレス取得処理.
   *
   * @return
   */
  private List<String> getEMailAdress(List<MstDestinationGroup> destinationGroupList, List<Long> userList) {
    // 対象メールアドレスチェック用フォーマット
    String mailFormat = "^[A-Za-z0-9]{1}[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@{1}[a-zA-Z0-9-]+(?:\\.[a-zA-Z0-9-]+)*$";
    List<String> adressList = new ArrayList<String>();

    // 利用者のメールアドレスを取得する
    List<MstPersonalUser> personaUserlList = mstPersonalUserDao.selectByIdList(userList);

    // メールアドレスリストを作成する
    for (MstPersonalUser userData : personaUserlList) {

      // 対象のアドレス送信クラグがtrueかつリストに同じアドレスがない場合リストにアドレスを設定
      for (MstDestinationGroup groupData : destinationGroupList) {
        List<MstDestinationGroup.User> users = groupData.getDestinationTarget().getUsers();
        users.stream()
            .filter(user -> userData.getUserId().equals(user.getUserId()))
            .forEach(user -> {
              if (user.isAddress1Send()
                  && !adressList.contains(userData.getUserEmailAddress1())
                  && !StringUtils.isEmpty(userData.getUserEmailAddress1())
                  && userData.getUserEmailAddress1().matches(mailFormat)){
                adressList.add(userData.getUserEmailAddress1());
              }
              if (user.isAddress2Send()
                  && !adressList.contains(userData.getUserEmailAddress2())
                  && !StringUtils.isEmpty(userData.getUserEmailAddress2())
                  && userData.getUserEmailAddress2().matches(mailFormat)){
                adressList.add(userData.getUserEmailAddress2());
              }
            });
      }
    }
    return adressList;
  }

  /**
   * オプション申請メール送信.
   * @param salSubscriptionManage
   * @return
   */
  @PostMapping("/api/makerNotice/salSubManage/sendMail")
  private  ResponseEntity<Void> salSubManSendMail(@RequestBody Map<String, String> salSubscriptionManage){

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "/api/makerNotice/salSubManage/sendMail";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
	try {
		salSubManSendMailService.sendMail(salSubscriptionManage);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
		return new ResponseEntity<>(HttpStatus.OK);
	} catch (Exception e) {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
    // wp アプリケーションログの適正化 Add Start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
    // wp アプリケーションログの適正化 Add End

		return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
	}

  }
  /**
   * クラス名取得
   */
  private String getClassName() {
    return this.getClass().getName();
  }

  /**
   * メソッド名取得
   */
  private String getMethodName() {
    return Thread.currentThread().getStackTrace()[2].getMethodName();
  }

}
