package jp.co.nikkiso.ntss.m_notice.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cloud.aws.core.config.AmazonWebserviceClientFactoryBean;
import org.springframework.cloud.aws.core.region.StaticRegionProvider;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.amazonaws.auth.AWSCredentialsProvider;
import com.amazonaws.services.simpleemail.AmazonSimpleEmailServiceClient;

import jp.co.nikkiso.ntss.m_notice.NtssMNoticeProperties;

/**
 * Amazon SESを利用したE-mail送信の設定クラスです。
 * @see org.springframework.cloud.aws.autoconfigure.mail.MailSenderAutoConfiguration
 */
@Configuration
public class MailConfig {
  @Autowired
  private NtssMNoticeProperties ntssMNoticeProperties;
  
  @Bean
  public AmazonWebserviceClientFactoryBean<AmazonSimpleEmailServiceClient> amazonSimpleEmailService(AWSCredentialsProvider credentialsProvider) {
      return new AmazonWebserviceClientFactoryBean<>(AmazonSimpleEmailServiceClient.class,
              credentialsProvider, new StaticRegionProvider(ntssMNoticeProperties.getMail().getSesRegion()));
  }
}
