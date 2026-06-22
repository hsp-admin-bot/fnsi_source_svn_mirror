package jp.co.nikkiso.ntss.core.utils;


import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 *
 *
 *
 */
@Component
public class FilterCalcAmountAndSpeedUtil {

  @Autowired
  private MstMachineDao mstMachineDao;

  /**
   *
   * 透析条件項目定義
   * 2018/11/20現在の@治療条件項目に従い定義
   */
  public enum DIALYSISCOND {
    //治療時間
    COND_TOTAL_TIME("1"),
    //目標体重
    COND_TW("3"),
    //除水量制限
    COND_REMOVE_WATER_LIMIT("4"),
    //血流量
    COND_BLOOD_MEASURE("14"),
    //補液
    COND_REPLENISH_LIQUID("19"),
    //補液量
    COND_REPLENISH_MEASURE("20"),
    //補液選択
    COND_REPLENISH_SELECT("21"),
    //補液速度
    COND_REPLENISH_SPEED("24")
    ;
    //String
    private String strval ;

    DIALYSISCOND(String strval) {
      this.strval = strval ;
    }
    public String get() {
      return this.strval ;
    }
  };

  /**
   *  条件送信結果処理を行う(ord_mainのrst_cond_infoの補液量と補液速度を再設定する)
   *
   * @param ordMainData       ord_mainデータ
   * @param deviceSetInfo     pat_mainから取得のデータ
   */
  public Map<String, String> setRstCondInfoAmountAndSpeedWithFilter(OrdMain ordMainData, JSONObject deviceSetInfo) throws JSONException
  {
    JSONObject rstCondInfo = null == ordMainData.getRstCondInfo() ?
      new JSONObject() :
      new JSONObject(ordMainData.getRstCondInfo());
    Map<String, String> resMap = new HashMap<>();
    if (rstCondInfo.has(DIALYSISCOND.COND_REPLENISH_MEASURE.get()) && rstCondInfo.has(DIALYSISCOND.COND_REPLENISH_SPEED.get())) {

      Double QB = 0d;
      Double Ht = 0d;
      Double TP = 0d;
      Double FF = 0d;
      Double QUF = 0d;
      Double DT = 0d;

      JSONObject condReplenishSelect = new JSONObject(rstCondInfo.get(DIALYSISCOND.COND_REPLENISH_SELECT.get()).toString());
      if (deviceSetInfo != null && !deviceSetInfo.isEmpty()){
        if ("1".equals(String.valueOf(getValueFromJson(condReplenishSelect, "value")))) {
          // "前補液"
          FF = Double.parseDouble(deviceSetInfo.getJSONObject("ope")
            .getJSONObject("dev")
            .getJSONObject("A").get("90").toString());
        } else {
          // "後補液"
          FF = Double.parseDouble(deviceSetInfo.getJSONObject("ope")
            .getJSONObject("dev")
            .getJSONObject("B").get("40").toString());
        }
        Ht = Double.parseDouble(deviceSetInfo.getJSONObject("ope")
          .getJSONObject("dev")
          .getJSONObject("A").get("91").toString());
        TP = Double.parseDouble(deviceSetInfo.getJSONObject("ope")
          .getJSONObject("dev")
          .getJSONObject("A").get("92").toString());
        DT = Double.parseDouble(deviceSetInfo.getJSONObject("ope")
          .getJSONObject("dev")
          .getJSONObject("A").get("398").toString());
      }

      if (rstCondInfo.has(DIALYSISCOND.COND_BLOOD_MEASURE.get()) && !rstCondInfo.isNull(DIALYSISCOND.COND_BLOOD_MEASURE.get())) {
        JSONObject condTimeJson = (JSONObject) rstCondInfo.get(DIALYSISCOND.COND_BLOOD_MEASURE.get());
        QB = condTimeJson.getDouble("value");
      }
      String rstWeight = ordMainData.getRstWeightInfo() ;
      rstWeight = null == rstWeight ? "{}" : rstWeight ;
      JSONObject rstWeightInfoJson = new JSONObject(rstWeight) ;
      // 前体重
      Double weigheBefore = rstWeightInfoJson.isNull("weight_before") ? 0d : rstWeightInfoJson.optDouble("weight_before", 0d);

      // 目標体重
      Double targetWeight = 0d;
      if (rstCondInfo.has(DIALYSISCOND.COND_TW.get()) && !rstCondInfo.isNull(DIALYSISCOND.COND_TW.get())) {
        JSONObject condTimeJson = (JSONObject) rstCondInfo.get(DIALYSISCOND.COND_TW.get());
        targetWeight = condTimeJson.getDouble("value");
      }

      // 透析時間
      Double condTime = 0d;
      if (rstCondInfo.has(DIALYSISCOND.COND_TOTAL_TIME.get()) && !rstCondInfo.isNull(DIALYSISCOND.COND_TOTAL_TIME.get())) {
        JSONObject condTimeJson = (JSONObject) rstCondInfo.get(DIALYSISCOND.COND_TOTAL_TIME.get());
        condTime = condTimeJson.getDouble("value");
      }
      Double dd = 0d;
      if (rstCondInfo.has(DIALYSISCOND.COND_REMOVE_WATER_LIMIT.get()) && !rstCondInfo.isNull(DIALYSISCOND.COND_REMOVE_WATER_LIMIT.get())) {
        JSONObject condTimeJson = (JSONObject) rstCondInfo.get(DIALYSISCOND.COND_REMOVE_WATER_LIMIT.get());
        dd = condTimeJson.getDouble("value");
      }
      JSONObject offWaterInfo = new JSONObject(ordMainData.getIndOffWaterInfo());
      Integer offWaterInfoWeight1 = toWeight(offWaterInfo.get("weight_1").toString());
      Integer offWaterInfoWeight2 = toWeight(offWaterInfo.get("weight_2").toString());
      Integer offWaterInfoWeight3 = toWeight(offWaterInfo.get("weight_3").toString());
      Integer offWaterInfoWeight4 = toWeight(offWaterInfo.get("weight_4").toString());
      Integer offWaterInfoWeight5 = toWeight(offWaterInfo.get("weight_5").toString());
      Integer offWaterInfoWeightAmount = offWaterInfoWeight1+offWaterInfoWeight2+offWaterInfoWeight3+offWaterInfoWeight4+offWaterInfoWeight5;

      // 除水速度
      //QUF = (weigheBefore - targetWeight) / (condTime / 60);
      Double ddRel = weigheBefore + Double.parseDouble(offWaterInfoWeightAmount.toString())/1000  - targetWeight;
      if( ddRel> dd){
        QUF = dd / (condTime / 60);
      }else{
        QUF = ddRel / (condTime / 60);
      }
      QUF = Double.parseDouble(new BigDecimal(QUF).setScale(4, RoundingMode.CEILING).toString());

      Double QPW = ((100 - Ht) / 100) * (1 - (0.0107 * TP)) * QB;
      QPW = Double.parseDouble(new BigDecimal(QPW).setScale(1,RoundingMode.DOWN).toString());

      // 条件から装置情報を取得
      List<MstMachine> machines = mstMachineDao.selectByBedCd(ordMainData.getFacilityCd(), ordMainData.getIndBedCd().longValue());

      // 医器工V3、V4：補液速度、補液量ともに0を展開する。
      if ("3".equals(machines.get(0).getComType().toString())) {
        resMap.put(DIALYSISCOND.COND_REPLENISH_MEASURE.get(), "0");
        resMap.put(DIALYSISCOND.COND_REPLENISH_SPEED.get(), "0");
      } else {
        // 新通信、オフライン
        Double value;
        String valueSaveString = "0";
        if ("1".equals(String.valueOf(getValueFromJson(condReplenishSelect, "value")))) {
          // "前補液"
          value = ((QPW * 60 / 1000 * FF / 100) - QUF) / (1 - (FF / 100));
        } else {
          // "後補液"
          value = (QPW * 60 / 1000 * FF / 100) - QUF;
        }

        String replenishMeasureString = "0";
        if (rstCondInfo.has(DIALYSISCOND.COND_TOTAL_TIME.get()) && !rstCondInfo.isNull(DIALYSISCOND.COND_REPLENISH_LIQUID.get())) {
          BigDecimal valueDec = new BigDecimal(value);
          String valueString = valueDec.setScale(4, RoundingMode.CEILING).toString();
          valueSaveString = valueDec.setScale(2, RoundingMode.CEILING).toString();
          Double replenishMeasure = Double.parseDouble(valueString) * (condTime - DT) / 60;
          BigDecimal replenishMeasureDec = new BigDecimal(replenishMeasure);
          replenishMeasureString = replenishMeasureDec.setScale(1,RoundingMode.DOWN).toString();
        }
        if(weigheBefore==0){
          replenishMeasureString = "0.0";
          valueSaveString = "0.00";
        }
        resMap.put(DIALYSISCOND.COND_REPLENISH_MEASURE.get(), replenishMeasureString);
        resMap.put(DIALYSISCOND.COND_REPLENISH_SPEED.get(), valueSaveString);
      }
    }
    return resMap;
  }

  /**
   * JSONObjectからの値の取得処理
   * 値が取得できない場合(キーが存在しないなど)はnullを返却する
   * @param jObj jsonオブジェクト
   * @param key  キー
   * @return 取得した値(キーが存在しない場合null)
   */
  private Object getValueFromJson(JSONObject jObj,String key)
  {
    Object ret = null ;

    try {
      //Jsonからキーを元に取得
      if(!jObj.isEmpty() && !jObj.isNull(key))
      {
        ret = jObj.get(key) ;
      }
    }
    catch(Exception e)
    {
      //例外が発生したので、戻り値をnullに設定
      ret = null ;
    }
    return ret ;
  }

  public Integer toWeight(String weigh){
    if("null".equals(weigh)){
      return 0;
    }else {
      return Integer.parseInt(weigh);
    }

  }
}
