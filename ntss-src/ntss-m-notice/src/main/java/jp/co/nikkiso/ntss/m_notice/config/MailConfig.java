package jp.co.nikkiso.ntss.m_notice.config;

import java.io.ByteArrayOutputStream;
import java.util.LinkedHashMap;
import java.util.Map;

import jakarta.mail.internet.MimeMessage;
import jp.co.nikkiso.ntss.m_notice.NtssMNoticeProperties;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.mail.MailException;
import org.springframework.mail.MailSendException;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.JavaMailSenderImpl;
import org.springframework.util.StringUtils;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.AwsCredentialsProvider;
import software.amazon.awssdk.auth.credentials.DefaultCredentialsProvider;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.core.SdkBytes;
import software.amazon.awssdk.http.urlconnection.UrlConnectionHttpClient;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.regions.providers.DefaultAwsRegionProviderChain;
import software.amazon.awssdk.services.ses.SesClient;
import software.amazon.awssdk.services.ses.model.RawMessage;
import software.amazon.awssdk.services.ses.model.SendRawEmailRequest;
import software.amazon.awssdk.services.sns.SnsClient;

/**
 * AWS SDK v2 client configuration for the notice module.
 */
@Configuration
public class MailConfig {

  @Autowired
  private NtssMNoticeProperties ntssMNoticeProperties;

  @Value("${cloud.aws.credentials.accessKey:#{null}}")
  private String accessKey;

  @Value("${cloud.aws.credentials.secretKey:#{null}}")
  private String secretKey;

  @Value("${cloud.aws.region.static:#{null}}")
  private String region;

  @Bean
  public AwsCredentialsProvider awsCredentialsProvider() {
    if (StringUtils.hasText(accessKey) && StringUtils.hasText(secretKey)) {
      return StaticCredentialsProvider.create(AwsBasicCredentials.create(accessKey, secretKey));
    }
    return DefaultCredentialsProvider.create();
  }

  @Bean
  public SnsClient amazonSns(AwsCredentialsProvider awsCredentialsProvider) {
    return SnsClient.builder()
        .httpClientBuilder(UrlConnectionHttpClient.builder())
        .credentialsProvider(awsCredentialsProvider)
        .region(resolveRegion())
        .build();
  }

  @Bean
  public SesClient amazonSimpleEmailService(AwsCredentialsProvider awsCredentialsProvider) {
    return SesClient.builder()
        .httpClientBuilder(UrlConnectionHttpClient.builder())
        .credentialsProvider(awsCredentialsProvider)
        .region(Region.of(ntssMNoticeProperties.getMail().getSesRegion()))
        .build();
  }

  @Bean
  public JavaMailSender javaMailSender(SesClient amazonSimpleEmailService) {
    return new SesJavaMailSender(amazonSimpleEmailService);
  }

  private Region resolveRegion() {
    if (StringUtils.hasText(region)) {
      return Region.of(region);
    }
    return new DefaultAwsRegionProviderChain().getRegion();
  }

  private static class SesJavaMailSender extends JavaMailSenderImpl {

    private final SesClient sesClient;

    private SesJavaMailSender(SesClient sesClient) {
      this.sesClient = sesClient;
    }

    @Override
    protected void doSend(MimeMessage[] mimeMessages, Object[] originalMessages) throws MailException {
      Map<Object, Exception> failedMessages = new LinkedHashMap<>();
      for (int i = 0; i < mimeMessages.length; i++) {
        Object originalMessage = originalMessages != null ? originalMessages[i] : mimeMessages[i];
        try {
          ByteArrayOutputStream output = new ByteArrayOutputStream();
          mimeMessages[i].writeTo(output);
          sesClient.sendRawEmail(SendRawEmailRequest.builder()
              .rawMessage(RawMessage.builder()
                  .data(SdkBytes.fromByteArray(output.toByteArray()))
                  .build())
              .build());
        } catch (Exception e) {
          failedMessages.put(originalMessage, e);
        }
      }
      if (!failedMessages.isEmpty()) {
        throw new MailSendException(failedMessages);
      }
    }
  }
}
