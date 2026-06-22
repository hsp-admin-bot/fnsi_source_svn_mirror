package jp.co.nikkiso.ntss.coop_api.utils;

import java.util.Map;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import lombok.Data;

/**
 * ジャーナル変換の設定値を保持するクラス。
 */
@Component
@ConfigurationProperties(prefix = JournalConvertConstants.SETTING_TOP_KEY)
@Data
public class ConverterConf {

  /**
   * dataset変換呼び出しパラメータ。
   */
  private Map<String, Object> datasetApi;

  /**
   * CSV解析用設定。
   */
  private Map<String, Object> csv;
}
