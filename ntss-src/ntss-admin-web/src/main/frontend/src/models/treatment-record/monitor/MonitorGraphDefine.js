/**
 * モニタ画面のモニタグラフ設定を表現するクラス
 */
export class MonitorGraphDefine {
  constructor(
    cd,
    name,
    leftDataIndex,
    //add 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy start
    leftName,
    //add 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy end
    leftColor,
    //add FNSI-改修内容 グラフ様式修正 房 start
    leftLineSize,
    leftLineTypeValue,
    leftPointColor,
    leftPointSize,
    leftPointTypeValue,
    //add FNSI-改修内容 グラフ様式修正 房 end
    rightDataIndex,
    //add 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy start
    rightName,
    //add 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy end
    rightColor,
    //add FNSI-改修内容 グラフ様式修正 房 start
    rightLineSize,
    rightLineTypeValue,
    rightPointColor,
    rightPointSize,
    rightPointTypeValue,
    //add FNSI-9858-改修内容 グラフ様式追加最大値と最小値 杜天成 start
    rightGraphLowerLimit,
    leftGraphLowerLimit,
    rightGraphUpperLimit,
    leftGraphUpperLimit
    //add FNSI-9858-改修内容 グラフ様式追加最大値と最小値 杜天成 end
    //add FNSI-改修内容 グラフ様式修正 房 end
  ) {
    // モニタグラフコード
    this.cd = cd;
    // モニタグラフ名
    this.name = name;
    // 左項目コード
    this.leftDataIndex = leftDataIndex;
    // 左グラフ色
    this.leftColor = leftColor;
    //add FNSI-改修内容 グラフ様式修正 房 start
    //左線サイズ
    this.leftLineSize = leftLineSize;
    //左線タイプ値
    this.leftLineTypeValue = leftLineTypeValue;
    //左ポイント色
    this.leftPointColor = leftPointColor;
    //左ポイントサイズ
    this.leftPointSize = leftPointSize;
    //左ポイントタイプ値
    this.leftPointTypeValue = leftPointTypeValue;
    //add FNSI-改修内容 グラフ様式修正 房 end
    // 右項目コード
    this.rightDataIndex = rightDataIndex;
    // 右グラフ色
    this.rightColor = rightColor;
    //add FNSI-改修内容 グラフ様式修正 房 start
    //右線サイズ
    this.rightLineSize = rightLineSize;
    //右線タイプ値
    this.rightLineTypeValue = rightLineTypeValue;
    //右ポイント色
    this.rightPointColor = rightPointColor;
    //右ポイントサイズ
    this.rightPointSize = rightPointSize;
    //右ポイントタイプ値
    this.rightPointTypeValue = rightPointTypeValue;
    //add FNSI-9858-改修内容 グラフ様式追加最大値と最小値 杜天成 start
    this.rightGraphLowerLimit = rightGraphLowerLimit;
    this.leftGraphLowerLimit = leftGraphLowerLimit;
    this.rightGraphUpperLimit = rightGraphUpperLimit;
    this.leftGraphUpperLimit = leftGraphUpperLimit;
    //add FNSI-9858-改修内容 グラフ様式追加最大値と最小値 杜天成 end
    //add FNSI-改修内容 グラフ様式修正 房 end
    //add 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy start
    this.leftName=leftName;
    this.rightName=rightName;
    //add 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy end
  }
}
