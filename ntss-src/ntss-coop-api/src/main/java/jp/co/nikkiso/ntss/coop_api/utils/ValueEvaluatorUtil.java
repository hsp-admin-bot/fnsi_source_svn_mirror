package jp.co.nikkiso.ntss.coop_api.utils;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import jp.co.nikkiso.ntss.core.entity.json.LayoutExtSetting;
import jp.co.nikkiso.ntss.core.exception.NtssException;

/**
 * 変換レイアウトマスタのvalueカラム（特殊値指定）を評価するユーティリティクラス。
 */
@Component
public class ValueEvaluatorUtil {
  @Autowired
  private EvaluatorJsonUtil evaluatorJsonUtil;
  /**
   * 特殊値指定を評価する。
   *
   * @param itemValue 電文から切り出した項目値
   * @param value 特殊値指定
   * @param facilityCd 施設コード
   * @param layoutExtSetting レイアウトの拡張設定
   * @param existedFlg 電文中タグの有無
   * @return 評価結果
   */
  public String eval(String itemValue, String value, String facilityCd, LayoutExtSetting layoutExtSetting, boolean existedFlg) {

    // 特殊値指定がない（ブランクないしnull）の場合は何もしない。
    if (StringUtils.isEmpty(value)) {
      return itemValue;
    }

    // ":"で分割する。
    // ":"が含まれていない場合は設定誤りとし、例外を発生させる。
    String[] labelAndParam = value.split(JournalConvertConstants.EVAL_LABEL_DELIM, 2);
    if (labelAndParam.length < 2) {
      String errMsg = String.format("特殊値指定に「:」が含まれていません。 項目値:[%s], 特殊値指定:[%s]", itemValue, value);
      throw new NtssException(errMsg);
    }

    // ";"の前の指定により、定数、JSON変換、データセット変換にいずれかに分岐する。
    // （いずれでもない場合は例外を発生させる。）
    return evalByLabel(labelAndParam[0], itemValue, labelAndParam[1], facilityCd, layoutExtSetting, existedFlg);
  }

  /**
   * ラベルにより、使用する評価オブジェクトを取得する。
   *
   * @param label ラベル（const, json, dataset, default）
   * @param itemValue 電文から切り出した項目値
   * @param value 特殊値指定
   * @param layoutExtSetting レイアウトの拡張設定
   * @return 評価オブジェクト
   */
  private String evalByLabel(String label, String itemValue, String value, String facilityCd,
      LayoutExtSetting layoutExtSetting, boolean existedFlg) {

    switch (label) {
    case JournalConvertConstants.EVAL_LABEL_CONST:
      // const指定
      // 電文から切り出した項目の代わりに固定値を返す。
      return EvaluatorConstUtil.eval(value);

    case JournalConvertConstants.EVAL_LABEL_JSON:
      // json指定
      // jsonマップ構造を指定する。切り出した項目をキーとし、対応する値に置換する。
      return evaluatorJsonUtil.eval(itemValue, value, layoutExtSetting);

    case JournalConvertConstants.EVAL_LABEL_DATASET:
      // dataset指定
      // dataset APIを呼び出し、応答結果で置換する。
      return EvaluatorDatasetUtil.eval(itemValue, value, facilityCd);

    case JournalConvertConstants.EVAL_LABEL_DEFAULT:
      // default指定
      // 電文にタグがない場合に固定値を返す。
      return EvaluatorDefaultUtil.eval(itemValue, value, existedFlg);

    default:
      String errMsg = String.format("変換レイアウトの特殊値指定に対応していない形式が指定されています。 特殊値指定:[%s]", label);
      throw new NtssException(errMsg);
    }
  }
}
