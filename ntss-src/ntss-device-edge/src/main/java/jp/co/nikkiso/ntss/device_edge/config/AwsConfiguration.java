package jp.co.nikkiso.ntss.device_edge.config;

import com.amazonaws.ClientConfiguration;
import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.client.builder.AwsClientBuilder;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.util.StringUtils;

/**
 * Configuration for AWS S3
 */
@Configuration
@ComponentScan("jp.co.nikkiso.ntss.device_edge")
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

  /**
   * @see AmazonS3
   * @return {@link AmazonS3}
   */
  @Bean
  public AmazonS3 s3() {

    ClientConfiguration clientConfiguration = new ClientConfiguration();
    clientConfiguration.setSignerOverride("AWSS3V4SignerType");

    AmazonS3ClientBuilder builder = AmazonS3ClientBuilder.standard();
    builder.setPathStyleAccessEnabled(true);
    builder.setClientConfiguration(clientConfiguration);
    if (endpoint != null && !StringUtils.isEmpty(endpoint)) {
      builder.setEndpointConfiguration(new AwsClientBuilder.EndpointConfiguration(endpoint, region));
    } else {
      if (!StringUtils.isEmpty(region)) {
        builder.setRegion(region);
      }
    }
    if (accessKey != null && secretKey != null) {
      builder.setCredentials(new AWSStaticCredentialsProvider( new BasicAWSCredentials(accessKey, secretKey)));
    }
    return builder.build();
  }
}
