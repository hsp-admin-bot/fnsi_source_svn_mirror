package jp.co.nikkiso.ntss.core.utils;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;

import org.springframework.util.StringUtils;

/**
 * Lightweight EC2 metadata helper that avoids depending on the AWS SDK core.
 */
public final class Ec2MetadataHelper {

  private static final URI TOKEN_URI = URI.create("http://169.254.169.254/latest/api/token");
  private static final URI PRIVATE_IP_URI = URI.create("http://169.254.169.254/latest/meta-data/local-ipv4");
  private static final Duration REQUEST_TIMEOUT = Duration.ofSeconds(1);

  private Ec2MetadataHelper() {
  }

  public static String getPrivateIp() {
    try {
      HttpClient client = HttpClient.newBuilder()
          .connectTimeout(REQUEST_TIMEOUT)
          .build();

      String token = fetchImdsV2Token(client);
      String privateIp = fetchPrivateIp(client, token);
      if (StringUtils.hasText(privateIp)) {
        return privateIp;
      }
    } catch (InterruptedException ex) {
      Thread.currentThread().interrupt();
    } catch (IOException | IllegalArgumentException ex) {
      // Fall through to null and let callers use their existing local fallback.
    }
    return null;
  }

  private static String fetchImdsV2Token(HttpClient client) throws IOException, InterruptedException {
    HttpRequest request = HttpRequest.newBuilder(TOKEN_URI)
        .timeout(REQUEST_TIMEOUT)
        .header("X-aws-ec2-metadata-token-ttl-seconds", "21600")
        .method("PUT", HttpRequest.BodyPublishers.noBody())
        .build();

    HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
    if (response.statusCode() >= 200 && response.statusCode() < 300) {
      return response.body();
    }
    return null;
  }

  private static String fetchPrivateIp(HttpClient client, String token) throws IOException, InterruptedException {
    HttpRequest.Builder requestBuilder = HttpRequest.newBuilder(PRIVATE_IP_URI)
        .timeout(REQUEST_TIMEOUT)
        .GET();
    if (StringUtils.hasText(token)) {
      requestBuilder.header("X-aws-ec2-metadata-token", token);
    }

    HttpResponse<String> response = client.send(requestBuilder.build(), HttpResponse.BodyHandlers.ofString());
    if (response.statusCode() >= 200 && response.statusCode() < 300) {
      return response.body();
    }
    return null;
  }
}
