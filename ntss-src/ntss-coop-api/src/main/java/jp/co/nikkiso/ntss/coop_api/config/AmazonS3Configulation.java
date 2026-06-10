package jp.co.nikkiso.ntss.coop_api.config;

import com.amazonaws.client.builder.AwsClientBuilder;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import com.amazonaws.ClientConfiguration;
import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.BasicAWSCredentials;
import jp.co.nikkiso.ntss.coop_api.utils.AmazonS3Wrapper;
import org.springframework.util.StringUtils;

/**
 * Amazon S3 Configulation
 *
 */
@Configuration
@ComponentScan("jp.co.nikkiso.ntss.coop_api.service")
public class AmazonS3Configulation {
  // mod 2021-03-19 問題確認：NODEJS側に確認JAVA側のPDFファイルを送付しました。 孫 start
//  /**  use bucket name*/
//  @Value(("${cloud.aws.s3.bucket-name:#{null}}"))
//  private String bucketName;
//  /** Access keys */
//  @Value(("${cloud.aws.s3.access-key:#{null}}"))
//  private String accessKey;
//  @Value(("${cloud.aws.s3.secret-key:#{null}}"))
//  private String secretKey;
//  @Value(("${cloud.aws.s3.region:#{null}}"))
//  private String region;
//  /** Proxy */
//  @Value(("${cloud.aws.s3.proxy.host:#{null}}"))
//  private String proxyHost;
//  @Value(("${cloud.aws.s3.proxy.port:0}"))
//  private int proxyPort;
//  @Value(("${cloud.aws.s3.proxy.username:#{null}}"))
//  private String proxyUsername;
//  @Value(("${cloud.aws.s3.proxy.password:#{null}}"))
//  private String proxyPassword;
//
//  /** permission */
//  @Value(("${cloud.aws.s3.permission.connect:false}"))
//  private boolean permissionConnect;
//
//  /** other */
//  /** S3が利用できない場合にローカルで一旦保持するためのカレントパス */
//  @Value(("${cloud.aws.s3.save-local-file-path:#{null}}"))
//  private String saveLocalFilePath;

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
  // mod 2021-03-19 問題確認：NODEJS側に確認JAVA側のPDFファイルを送付しました。 孫 end

  /**
   * Spring起動時に行うAmazonS3に関する初期化処理
   * @return {@link AmazonS3Wrapper}
   */
  @Bean
  public AmazonS3Wrapper instantiate() {
    // mod 2021-03-19 問題確認：NODEJS側に確認JAVA側のPDFファイルを送付しました。 孫 start
//    ClientConfiguration clientConfiguration = new ClientConfiguration();
//    clientConfiguration.setSignerOverride("AWSS3V4SignerType");
//
//    // Proxyは必須ではないので、ymlに定義されていれば設定するよう制御する
//    if (StringUtils.isNotEmpty(proxyHost) &&
//        proxyPort != 0 &&
//        StringUtils.isNotEmpty(proxyUsername) &&
//        StringUtils.isNotEmpty(proxyPassword)){
//      clientConfiguration.setProxyProtocol(Protocol.HTTP);
//      clientConfiguration.setProxyHost(proxyHost);
//      clientConfiguration.setProxyPort(proxyPort);
//      clientConfiguration.setProxyUsername(proxyUsername);
//      clientConfiguration.setProxyPassword(proxyPassword);
//    }
//
//    AWSStaticCredentialsProvider provider = new AWSStaticCredentialsProvider(new BasicAWSCredentials(accessKey, secretKey));
//    return new AmazonS3Wrapper(bucketName, region, saveLocalFilePath, clientConfiguration, provider, permissionConnect);

    return new AmazonS3Wrapper();
    // mod 2021-03-19 問題確認：NODEJS側に確認JAVA側のPDFファイルを送付しました。 孫 end
  }

  // add 2021-03-09 問題確認：NODEJS側に確認JAVA側のPDFファイルを送付しました。 孫 start
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
      builder.disableChunkedEncoding(); // S3疑似環境でこれをつけないとアップロード時にMD5チェックに引っかかってアップロードできない場合あり
    } else {
      if (!StringUtils.isEmpty(region)) {
        builder.setRegion(region);
      }
    }
    if (!StringUtils.isEmpty(accessKey) && !StringUtils.isEmpty(secretKey)) {
      builder.setCredentials(new AWSStaticCredentialsProvider( new BasicAWSCredentials(accessKey, secretKey)));
    }
    return builder.build();
  }
  // add 2021-03-09 問題確認：NODEJS側に確認JAVA側のPDFファイルを送付しました。 孫 end
}
