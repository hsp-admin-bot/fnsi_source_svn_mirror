package jp.co.nikkiso.ntss.m_notice.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import software.amazon.awssdk.services.sns.SnsClient;
import software.amazon.awssdk.services.sns.model.CreateTopicRequest;
import software.amazon.awssdk.services.sns.model.CreateTopicResponse;
import software.amazon.awssdk.services.sns.model.PublishRequest;

@Component
public class SnsNotificationSendar {

  private static final String TOPIC_NAME = "M_NOTICE_SNS";

  private final SnsClient amazonSns;

  @Autowired
  public SnsNotificationSendar(SnsClient amazonSns) {
    this.amazonSns = amazonSns;
  }

  public void send(String subject, String message) {
    CreateTopicResponse topic = amazonSns.createTopic(CreateTopicRequest.builder()
        .name(TOPIC_NAME)
        .build());
    amazonSns.publish(PublishRequest.builder()
        .topicArn(topic.topicArn())
        .message(message)
        .subject(subject)
        .build());
  }
}
