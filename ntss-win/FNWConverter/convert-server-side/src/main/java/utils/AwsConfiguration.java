package utils;

import java.net.URI;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.util.ObjectUtils;

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

/* TODO: ntss-admin-webのAwsConfiguration.javaからfileを移動する */

/**
 * Configuration for AWS S3.
 */
@Configuration
@ComponentScan
public class AwsConfiguration {

  /**
   * AWS S3 擬似環境URL.
   */
  @Value("${cloud.aws.endpoint:#{null}}")
  private String endpoint;

  /**
   * アクセスキー.
   */
  @Value("${cloud.aws.credentials.accessKey:#{null}}")
  private String accessKey;

  /**
   * シークレットキー.
   */
  @Value("${cloud.aws.credentials.secretKey:#{null}}")
  private String secretKey;

  /**
   * リージョン.
   */
  @Value("${cloud.aws.region.static:#{null}}")
  private String region;

  @Bean
  public AwsCredentialsProvider awsCredentialsProvider() {
    if (!ObjectUtils.isEmpty(accessKey) && !ObjectUtils.isEmpty(secretKey)) {
      return StaticCredentialsProvider.create(AwsBasicCredentials.create(accessKey, secretKey));
    }
    return DefaultCredentialsProvider.create();
  }
  /**
   * @see S3Client
   * @return {@link S3Client}
   */
  @Bean
  public S3Client s3(AwsCredentialsProvider awsCredentialsProvider) {
    S3ClientBuilder builder = S3Client.builder()
      .httpClientBuilder(UrlConnectionHttpClient.builder())
      .credentialsProvider(awsCredentialsProvider)
      .region(resolveRegion())
      .serviceConfiguration(S3Configuration.builder()
        .pathStyleAccessEnabled(true)
        // S3疑似環境でこれを有効のままにすると、アップロード時にMD5チェックに引っかかる場合がある
        .chunkedEncodingEnabled(!hasEndpointOverride())
        .build());

    if (hasEndpointOverride()) {
      builder.endpointOverride(URI.create(endpoint));
    }

    return builder.build();
  }

  private boolean hasEndpointOverride() {
    return !ObjectUtils.isEmpty(endpoint);
  }

  private Region resolveRegion() {
    if (!ObjectUtils.isEmpty(region)) {
      return Region.of(region);
    }
    return new DefaultAwsRegionProviderChain().getRegion();
  }
}
