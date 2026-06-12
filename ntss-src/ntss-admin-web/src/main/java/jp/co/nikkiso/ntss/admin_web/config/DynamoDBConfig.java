package jp.co.nikkiso.ntss.admin_web.config;

import java.net.URI;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.util.StringUtils;

import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.AwsCredentialsProvider;
import software.amazon.awssdk.auth.credentials.DefaultCredentialsProvider;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.http.urlconnection.UrlConnectionHttpClient;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.dynamodb.DynamoDbClient;

/**
 * DynamoDB設定
 */
@Configuration
public class DynamoDBConfig {
	@Value("${amazon.dynamodb.accesskey}")
	private String amazonDynamoDBAccessKey;

	@Value("${amazon.dynamodb.secretkey}")
	private String amazonDynamoDBSecretKey;

  @Value("${amazon.dynamodb.endpoint}")
  private String amazonDynamoDBEndpoint;

  @Value("${amazon.dynamodb.region}")
  private String amazonDynamoDBRegion;

  private AwsCredentialsProvider amazonAwsCredentialsProvider() {
    if (StringUtils.hasText(amazonDynamoDBAccessKey) && StringUtils.hasText(amazonDynamoDBSecretKey)) {
      return StaticCredentialsProvider.create(AwsBasicCredentials.create(amazonDynamoDBAccessKey, amazonDynamoDBSecretKey));
    }
    return DefaultCredentialsProvider.create();
  }

  @Bean
  public DynamoDbClient dynamoDbClient() {
    return DynamoDbClient.builder()
      .httpClientBuilder(UrlConnectionHttpClient.builder())
      .credentialsProvider(amazonAwsCredentialsProvider())
      .endpointOverride(URI.create(amazonDynamoDBEndpoint))
      .region(Region.of(amazonDynamoDBRegion))
      .build();
  }
}