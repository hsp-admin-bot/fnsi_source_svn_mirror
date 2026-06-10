package jp.co.nikkiso.ntss.coop_api.utils;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import jp.co.nikkiso.ntss.coop_api.utils.LayoutExtSettingUtil;
import jp.co.nikkiso.ntss.core.entity.json.LayoutExtSetting;

/**
 * 変換レイアウトマスタのvalue（特殊値指定）のうち、json指定を評価するクラス。
 */
@Component
public class EvaluatorJsonUtil {
  @Autowired
  private LayoutExtSettingUtil layoutExtSettingUtil;

  /**
   * json指定を評価する。
   *
   * @param itemValue 電文から切り出した項目値
   * @param value 特殊値指定（「json:」の後）
   * @param layoutExtSetting レイアウトの拡張設定
   * @return 評価結果
   */
  public String eval(String itemValue, String value, LayoutExtSetting layoutExtSetting) {
    return layoutExtSettingUtil.lookupExtSettingJsonValue(layoutExtSetting, value, itemValue);
  }
}
