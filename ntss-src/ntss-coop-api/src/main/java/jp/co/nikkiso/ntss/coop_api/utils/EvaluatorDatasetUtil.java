package jp.co.nikkiso.ntss.coop_api.utils;

import java.io.IOException;
import java.io.StringReader;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletResponse;

import org.apache.http.HttpEntity;
import org.apache.http.StatusLine;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.ContentType;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.type.CollectionType;
import com.fasterxml.jackson.databind.type.MapType;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.core.exception.NtssException;

/**
 * 変換レイアウトマスタのvalue（特殊値指定）のうち、dataset指定を評価するクラス。
 */
public class EvaluatorDatasetUtil {

  /**
   * ジャーナル変換用の設定値（application.ymlで設定される）
   */
  private static ConverterConf conf;

  /**
   * ジャーナル変換用の設定値を設定する。
   * @param cs 設定値オブジェクト
   */
  public static synchronized void setConf(ConverterConf cs) {
    // 本クラスはユーティリティクラスであり、すべてのメソッドがstaticである。
    // そのため直接DIでConverterSettingsオブジェクトを設定できないので、ConvertTextServiceImpl等の
    // 実装クラスから設定する。

    if (conf == null) {
      conf = cs;
    }
  }

  /**
   * dataset指定を評価する。
   *
   * @param itemValue 電文から切り出した項目値
   * @param value 特殊値指定（dataset）
   * @param facilityCd 施設コード
   * @return 評価結果
   */
  public static String eval(String itemValue, String value, String facilityCd) {

    // 引数を置換する。（パース取得値、施設コード値）
    // （当初はJSON文字列からマップに変換した後、引数部分の%VALUE%, %FACILITYCD%を置換する想定であった。
    // だが、この方法では%VALUE%等がダブルクォートで括られていないとJSON変換エラーとなる。
    // 仕様に合致しないため、最初に文字列置換で解決する方法を採った。）
    value = replaceParams(value, itemValue, facilityCd);

    // JSON文字列からマップに変換する。
    Map<String, Object> params = getParamByJson(value);

    //    log.warn("conf = " + datasetConf);
    // データセットAPIにリクエストを送信する。
    // String response = sendRequest(datasetConf.getUrl(), params);
    String datasetUrl = (String) conf.getDatasetApi().get("url"); // FIXME リテラル
    String response = sendRequest(datasetUrl, params);

    // 応答結果（JSON文字列）から1行目1カラム目の値を取得する。
    String responseValue = getResponseValue(response);

    return responseValue;
  }

  /**
   * JSON形式文字列からデータセット変換のリクエストパラメータを取得する。
   *
   * @param value JSON形式文字列
   * @return リクエストパラメータ
   */
  private static Map<String, Object> getParamByJson(String value) {

    StringReader sr = new StringReader(value);
    try {
      MapType mapType = ObjectMapperUtil.getObjectMapper().getTypeFactory().constructMapType(Map.class, String.class,
          Object.class);
      return ObjectMapperUtil.getObjectMapper().readValue(sr, mapType);
    } catch (IOException e) {
      throw new NtssException("リクエストパラメータをJSONオブジェクトに変換する時にエラーが発生しました。", e);
    }
  }

  /**
   * データセット変換リクエストパラメータのうち、%VALUE%と%FACILITYCD%を置換する。
   *
   * @param map データセット変換リクエストパラメータ（"dataKey"キー配下の部分）
   * @param value 電文から切り出した項目
   * @param facilityCd 施設コード
   */
  private static String replaceParams(String value, String itemValue, String facilityCd) {
    return value.replaceAll(JournalConvertConstants.EVAL_DATASET_PARAM_FACILITY_CD, facilityCd)
        .replaceAll(JournalConvertConstants.EVAL_DATASET_PARAM_ITEM_VALUE, itemValue);
  }

  /**
   * データセット取得APIを呼び出す。
   *
   * @param params リクエストパラメータ
   * @return レスポンス文字列
   */
  private static String sendRequest(String uri, Map<String, Object> params) {

    CloseableHttpClient httpClient = HttpClients.createDefault();
    HttpPost httpPost = new HttpPost(uri);

    String s = null;

    try {
      s = ObjectMapperUtil.getObjectMapper().writeValueAsString(params);
    } catch (JsonProcessingException e) {
      throw new NtssException("データセット取得サービスで、引数のJSON変換時にエラーが発生しました。", e);
    }

    StringEntity se = new StringEntity(s, ContentType.APPLICATION_JSON);
    httpPost.setEntity(se);

    try (CloseableHttpResponse response = httpClient.execute(httpPost)) {

      StatusLine status = response.getStatusLine();
      int statusCode = status.getStatusCode();

      if (statusCode != HttpServletResponse.SC_OK) {
        String errMsg = String.format("データセット取得サービスで通信エラーが発生しました。ステータスコード:[%d]", statusCode);
        throw new NtssException(errMsg);
      }

      HttpEntity responseEntity = response.getEntity();

      return EntityUtils.toString(responseEntity);

    } catch (ClientProtocolException e) {
      throw new NtssException("データセット取得サービスでエラーが発生しました。", e);
    } catch (IOException e) {
      throw new NtssException("データセット取得サービスでエラーが発生しました。", e);
    }
  }

  /**
   * データセット取得APIの呼び出し結果から、1行目第1カラム目の値を取得する。
   *
   * @param response データセット取得APIの呼び出し結果
   * @return 1行目第1カラム目の値
   */
  private static String getResponseValue(String response) {

    if (StringUtils.isEmpty(response)) {
      return response;
    }

    StringReader sr = new StringReader(response);
    List<Object> l = null;

    try {
      CollectionType listType = ObjectMapperUtil.getObjectMapper().getTypeFactory().constructCollectionType(List.class,
          Object.class);
      l = ObjectMapperUtil.getObjectMapper().readValue(sr, listType);
    } catch (IOException e) {
      throw new NtssException("データセット応答結果をJSONに変換する時にエラーが発生しました。", e);
    }

    if (CollectionUtils.isEmpty(l)) {
      return null;
    }

    if (l.get(0) == null) {
      return null;
    }

    Map<String, String> m = ObjectMapperUtil.castToStringStringMap(l.get(0));

    return String.valueOf(m.values().iterator().next());
  }

}
