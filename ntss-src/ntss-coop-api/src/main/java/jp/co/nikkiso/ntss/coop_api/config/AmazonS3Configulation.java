package jp.co.nikkiso.ntss.coop_api.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import jp.co.nikkiso.ntss.coop_api.utils.AmazonS3Wrapper;

/**
 * Amazon S3 Configulation
 *
 */
@Configuration
@ComponentScan("jp.co.nikkiso.ntss.coop_api.service")
public class AmazonS3Configulation {
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
}
