package jp.co.nikkiso.ntss.api.config;

import java.net.URI;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.util.StringUtils;

import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.AwsCredentialsProvider;
import software.amazon.awssdk.auth.credentials.DefaultCredentialsProvider;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.http.urlconnection.UrlConnectionHttpClient;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.regions.providers.DefaultAwsRegionProviderChain;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.S3ClientBuilder;
import software.amazon.awssdk.services.s3.S3Configuration;

/**
 * Shared AWS SDK v2 S3 client configuration.
 */
@Configuration
public class AwsS3ClientConfiguration {

  @Value("${cloud.aws.endpoint:#{null}}")
  private String endpoint;

  @Value("${cloud.aws.credentials.accessKey:#{null}}")
  private String accessKey;

  @Value("${cloud.aws.credentials.secretKey:#{null}}")
  private String secretKey;

  @Value("${cloud.aws.region.static:#{null}}")
  private String region;

  @Bean
  @ConditionalOnMissingBean(AwsCredentialsProvider.class)
  public AwsCredentialsProvider awsCredentialsProvider() {
    if (StringUtils.hasText(accessKey) && StringUtils.hasText(secretKey)) {
      return StaticCredentialsProvider.create(AwsBasicCredentials.create(accessKey, secretKey));
    }
    return DefaultCredentialsProvider.create();
  }

  @Bean
  @ConditionalOnMissingBean(S3Client.class)
  public S3Client s3Client(AwsCredentialsProvider awsCredentialsProvider) {
    S3ClientBuilder builder = S3Client.builder()
      .httpClientBuilder(UrlConnectionHttpClient.builder())
      .credentialsProvider(awsCredentialsProvider)
      .region(resolveRegion());

    if (StringUtils.hasText(endpoint)) {
      builder.endpointOverride(URI.create(endpoint));
      builder.serviceConfiguration(S3Configuration.builder()
        .pathStyleAccessEnabled(true)
        .chunkedEncodingEnabled(false)
        .build());
    } else {
      builder.serviceConfiguration(S3Configuration.builder()
        .pathStyleAccessEnabled(true)
        .build());
    }

    return builder.build();
  }

  private Region resolveRegion() {
    if (StringUtils.hasText(region)) {
      return Region.of(region);
    }
    return new DefaultAwsRegionProviderChain().getRegion();
  }
}
