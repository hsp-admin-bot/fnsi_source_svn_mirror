package jp.co.nikkiso.ntss.m_notice.service;

import com.amazonaws.services.sns.AmazonSNS;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cloud.aws.messaging.core.NotificationMessagingTemplate;
import org.springframework.stereotype.Component;

@Component
public class SnsNotificationSendar {

  private final NotificationMessagingTemplate notificationMessagingTemplate;

  @Autowired
    public SnsNotificationSendar(AmazonSNS amazonSns) {
        this.notificationMessagingTemplate = new
NotificationMessagingTemplate(amazonSns);
    }

  public void send(String subject, String message) {
    this.notificationMessagingTemplate.sendNotification("M_NOTICE_SNS", message, subject);
  }
}
