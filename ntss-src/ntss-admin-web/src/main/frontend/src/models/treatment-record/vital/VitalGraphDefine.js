/**
 * バイタル画面のバイタルグラフ設定を表現するクラス
 */
export class VitalGraphDefine {
  constructor(
    vitalGraphCd,
    vitalGraphName,
    vitalLineColor,
    vitalLineSize,
    vitalLineTypeValue,
    vitalPointColor,
    vitalPointSize,
    vitalPointTypeValue
  ) {
    // バイタルグラフコード
    this.vitalGraphCd = vitalGraphCd;
    // バイタルグラフ名
    this.vitalGraphName = vitalGraphName;
    // 左項目コード
    this.vitalLineColor = vitalLineColor;
    // 左グラフ色
    this.vitalLineSize = vitalLineSize;
    //左線タイプ値
    this.vitalLineTypeValue = vitalLineTypeValue;
    //左ポイント色
    this.vitalPointColor = vitalPointColor;
    //左ポイントサイズ
    this.vitalPointSize = vitalPointSize;
    // 右項目コード
    this.vitalPointTypeValue = vitalPointTypeValue;
  }
}
