package jp.co.nikkiso.ntss.web_api.web.rest.util;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.json.JSONException;
import org.json.JSONObject;

import jp.co.nikkiso.ntss.web_api.web.rest.util.WebAPICheckConditionSend.PARAMKEY;
//import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebAPICheckConditionSend.PARAMKEY;
import lombok.Getter;
import lombok.Setter;

/**
 * 透析量プログラム計算クラス
 *
 */
@Getter
@Setter
public class DialysisCalculator {
          // データテーブル用定数定義
          //患者ID
          public static final String PATID = "PATID";
          //患者ID
          public static final String DISP_PATID = "DISP_PATID";
          //患者名
          public static final String NAME = "NAME";
          //透析運転時間(Kt/V用)
          public static final String KTV_RUNNING_TIME = "KTV_RUNNING_TIME";
          //血流量(Kt/V用)
          public static final String KTV_BLOOD_VOLUME = "KTV_BLOOD_VOLUME";
          //KOA(Kt/V用)
          public static final String KTV_KOA = "KTV_KOA";
          //後体重(Kt/V用)
          public static final String KTV_WEIGHT_AFTER = "KTV_WEIGHT_AFTER";
          //目標体重(Kt/V用)
          public static final String KTV_WEIGHT_TARGET = "KTV_WEIGHT_TARGET";
          //除水積算値(Kt/V用)
          public static final String KTV_ADD_TOTAL = "KTV_ADD_TOTAL";
          //警報設定値
          public static final String SET_DATA = "SET_DATA";
          //透析日(体液量＋補正値用)
          public static final String BDY_DIALYSIS_DATE = "BDY_DIALYSIS_DATE";
          //前体重(体液量＋補正値用)
          public static final String BDY_WEIGHT_BEFORE = "BDY_WEIGHT_BEFORE";
          //後体重(体液量＋補正値用)
          public static final String BDY_WEIGHT_AFTER = "BDY_WEIGHT_AFTER";
          //透析前BUN(体液量＋補正値用)
          public static final String BDY_BUN_BEFORE = "BDY_BUN_BEFORE";
          //透析後BUN(体液量＋補正値用)
          public static final String BDY_BUN_AFTER = "BDY_BUN_AFTER";
          //除水積算値(体液量＋補正値用)
          public static final String BDY_ADD_TOTAL = "BDY_ADD_TOTAL";
          //血流量平均値(体液量＋補正値用)
          public static final String BDY_BLOOD_VOLUME = "BDY_BLOOD_VOLUME";
          //血液循環積算値（血流量平均値算出用）
          public static final String BDY_BLOOD_CIRCULATE_TOTAL = "BDY_BLOOD_CIRCULATE_TOTAL";
          //透析運転時間（血流量算出用）
          public static final String BDY_RUNNING_TIME = "BDY_RUNNING_TIME";
          //透析液流量(体液量＋補正値用)
          public static final String BDY_LIQUID_VOLUME = "BDY_LIQUID_VOLUME";
          //KOA(体液量＋補正値用)
          public static final String BDY_KOA = "BDY_KOA";
          

          //XMLタグ名定義
          //透析量プログラム使用有無
          public static final String TAG_NAME_USE_DIALYSIS_PROGRAM = "A-0282";
          //Kt/V目標値
          public static final String TAG_NAME_KT_PER_V_TARGET = "A-0288";
          

          //各種定数
          //透析運転時間なし
          public static final String NONE_RUNNING_TIME = "00:00";
          //体液量＋補正値デフォルト
          public static final double FIXED_BODY_FLUID = 10000;
          //計算繰り返し回数最大値
          public static final int MAX_CALC_ROUND = 10000;
          //使用有無(リスト表示用)・使用
          public static final String USEDIALYSISPROGRAM_ENABLE = "有";
          //使用有無(リスト表示用)・使用しない
          public static final String USEDIALYSISPROGRAM_DISABLE = "無";
          //使用有無(リスト表示用)・データなし
          public static final String USEDIALYSISPROGRAM_DATA_NONE = "";
          //KT/V最大値
          public static final double MAX_KTV = 3.00;
          //KT/V最小値
          public static final double MIN_KTV = 0.01;
          

          //プロパティ

          //採血時透析情報
          private TakeBloodDialysisInfo TakeBloodDialysis ;
          
          //最新透析実績
          private NewestDialysisInfo NewestDialysis ;

          //患者ID
          private String _PatID = "";

          //表示用患者ID 
          private String _DispPatID = "";

          //患者名す
          private String _PatName = "";

          //SET_DATA

          private JSONObject SetData ;

          //透析量プログラム使用有無
          private String _UseDialysisProgram = "";

          //透析量プログラム使用有無を取得します(リスト表示用）        
          public String getUseDialysisProgramSymbol()
          {
            String ret;
            switch (this._UseDialysisProgram)
            {
                case "1":
                    ret = USEDIALYSISPROGRAM_ENABLE;
                    break;
                case "0":
                    ret = USEDIALYSISPROGRAM_DISABLE;
                    break;
                default:
                    ret = USEDIALYSISPROGRAM_DATA_NONE;
                    break;
            }
            return ret;
          }

          //Kt/V目標値
          private String _KtPerVTarget = "";

          //透析日時を取得します
          public Date getDialysisDate()
          {
            return this.TakeBloodDialysis.DialysisDate;
          }

          //透析日時を取得します
          //(yyyy/MM/dd HH:mm形式)
          public String getDialysisDateTime()
          {
                  if (null == this.TakeBloodDialysis.DialysisDate)
                  {
                      return "";
                  }
                  else
                  {
                      return (new SimpleDateFormat("yyyy/MM/dd HH:mm")).format(this.TakeBloodDialysis.DialysisDate);
                  }
          }
          
          //透析運転時間を取得または設定します(HH:mm形式)
          //>設定値がHH:mm形式以外の場合は保持している値を変更しません
            public String    getRunningTime()
              {
                  if (null == this.TakeBloodDialysis.RunningTime)
                  {
                      return NONE_RUNNING_TIME;
                  }
                  else
                  {
                      Date dtmTime = new Date(0);
            
                      Calendar cal = Calendar.getInstance();
                      cal.setTime(dtmTime);
                      cal.add(Calendar.MINUTE, Integer.parseInt(this.TakeBloodDialysis.RunningTime.toString()));
                      return new SimpleDateFormat("HH:MM").format(cal.getTime()) ;
                  }
              }
//            public void setRunningTime()
//              {
//                  DateTime dtmDialTime;
//                  if (DateTime.TryParse(DateTime.MinValue.ToString("yyyy/MM/dd ") + value, out dtmDialTime))
//                  {
//                      // 変換できるときのみ保持する
//                      this.TakeBloodDialysis.RunningTime = dtmDialTime.Hour * 60 + dtmDialTime.Minute;
//                  }
//              }
//


        //透析運転時間の時間数を取得します
        public int getRunningTimeHours()
            {
                return Integer.parseInt(this.getRunningTime().substring(0, 2));
            }

          //透析運転時間の分数を取得します
        public int getRunningTimeMinutes()
            {
                return Integer.parseInt(this.getRunningTime().substring(3, 2));
            }

        //透析運転時間の総分数を取得または設定します
        public int getRunningTimeTotalMinutes()
            {
                return this.getRunningTimeHours() * 60 + this.getRunningTimeMinutes();
            }
        public void  setRunningTimeTotalMinutes(Integer value)
            {
                this.TakeBloodDialysis.RunningTime = value;
            }

          //
          //血流量を取得または設定します(ml/min)
          //通常、血液循環積算値×1000÷透析運転時間の値を返しますが、
          //計算できない場合は空文字列を返します
          //また、設定値が不正な場合は保持している値を変更しません
        public String getBloodVolume()
            {
                return this._BloodVolume;
            }
        public void setBloodVolume(String value)
            {
                double dBloodVolume;
                try {
                  Double.parseDouble(value) ;
                  this._BloodVolume = value;
                }
                catch(Exception e)
                {
                    //変換失敗
                    //なにもしない
                }
            }
          private String _BloodVolume = "";

          //除水量積算値を取得します
          public String getAddTotal()
              {
                  if (null == this.TakeBloodDialysis.AddTotal)
                  {
                      return "";
                  }
                  else
                  {
                      return String.format("%.2f",this.TakeBloodDialysis.AddTotal.intValue());
                  }
              }

          //前体重を取得します
          public String getWeightBefore()
              {
                  if (null == this.TakeBloodDialysis.WeightBefore)
                  {
                      return "";
                  }
                  else
                  {
                      return String.format("%.2f", this.TakeBloodDialysis.WeightBefore.intValue());
                  }
              }

          //後体重を取得します
          //透析実績測定体重より取得
          public String getWeightAfter()
              {
                  if (null == this.TakeBloodDialysis.WeightAfter)
                  {
                      return "";
                  }
                  else
                  {
                      return String.format("%.2f", this.TakeBloodDialysis.WeightAfter.intValue());
                  }
              }

          //透析液流量を取得します
          public String getLiquidVolume()
              {
                  if (null == this.TakeBloodDialysis.LiquidVolume)
                  {
                      return "";
                  }
                  else
                  {
                      return String.format("%",this.TakeBloodDialysis.LiquidVolume.intValue());
                  }
              }

          //透析前BUNを取得します
          public String getBUNBefore()
              {
                  if (null == this.TakeBloodDialysis.BUNBefore)
                  {
                      return "";
                  }
                  else
                  {
                      return String.format("%.2f",this.TakeBloodDialysis.BUNBefore.intValue());
                  }
              }

          //透析後BUNを取得します
          public String getBUNAfter()
              {
                  if (null == this.TakeBloodDialysis.BUNAfter)
                  {
                      return "";
                  }
                  else
                  {
                      return String.format("%.2f", this.TakeBloodDialysis.BUNAfter.intValue());
                  }
              }

          //体液量＋補正値の計算値
          private double getCalcBodyFluidAndReviseValue()
          {
                  double calcAnswer = 0;
                  boolean calcResult = false;
                  HashMap<PARAMKEY,Double> retVal = new HashMap<>() ;
                  
                  // 計算するための値がそろっている場合
                  if (null != this.TakeBloodDialysis.WeightAfter &&
                      null != this.TakeBloodDialysis.RunningTime &&
                      null != this.TakeBloodDialysis.BUNBefore &&
                      null != this.TakeBloodDialysis.BUNAfter &&
                      null != this.TakeBloodDialysis.AddTotal &&
                      false == this._BloodVolume.equals("") &&
                      null != this.TakeBloodDialysis.LiquidVolume &&
                      null != this.TakeBloodDialysis.KOA)
                  {
                      // 体液量＋補正値を算出
                      calcResult = DialysisCalculator.calBodyFluid(
                                      Double.parseDouble(this.TakeBloodDialysis.WeightAfter.toString()),
                                      Double.parseDouble(this.TakeBloodDialysis.RunningTime.toString()),
                                      Double.parseDouble(this.TakeBloodDialysis.BUNBefore.toString()),
                                      Double.parseDouble(this.TakeBloodDialysis.BUNAfter.toString()),
                                      Double.parseDouble(this.TakeBloodDialysis.AddTotal.toString()),
                                      Double.parseDouble(this._BloodVolume),
                                      Double.parseDouble(this.TakeBloodDialysis.LiquidVolume.toString()),
                                      Double.parseDouble(this.TakeBloodDialysis.KOA.toString()),
                                      this._RecycleRate,
                                      retVal
                                  );
                  }

                  // 計算不能、または計算が失敗した場合
                  if (false == calcResult)
                  {
                      // 計算失敗、計算不能時は固定値「10000」とする
                      return FIXED_BODY_FLUID;
                  }
                  else
                  {
                      // 有効桁数小数点2桁
                    calcAnswer = Double.parseDouble(String.format("%.2f", retVal.get(PARAMKEY.CALVALUE).toString()));
                    return calcAnswer;
                  }
          }

          /**
           * 体液量＋補正値取得処理
           * 計算式より算出
           * @return　体液量＋補正値
           */
          public String getBodyFluidAndReviseValue()
              {
                  // 算出値は単位がmlなので/ 1000してLに変換
                  return String.format("%.2f", this.getCalcBodyFluidAndReviseValue() / 1000);
              }

          /**
           * Kt/V上限取得処理
           * /計算式より自動算出
           * @return    Kt/V上限値
           */
          public String getKtPerVUpper()
          {
                  double calcAnswer = 0;
                  HashMap<PARAMKEY,Double> retVal = new HashMap<>();
                  boolean calcResult = false;

                  // 計算するための値がそろっている場合
                  if (null != this.NewestDialysis.RunningTime &&
                      null != this.NewestDialysis.BloodVolume &&
                      null != this.NewestDialysis.KOA &&
                      null != this.NewestDialysis.WeightAfter &&
                      null != this.NewestDialysis.WeightTarget &&
                      null != this.NewestDialysis.AddTotal)
                  {
                      // Kt/V上限を算出
                      calcResult = DialysisCalculator.CalKtvMax(this._PossibleKTVUpper,
                                                                Double.parseDouble(this.NewestDialysis.RunningTime.toString()),
                                                                Double.parseDouble(this.NewestDialysis.BloodVolume.toString()),
                                                                Double.parseDouble(this._RecycleRate.toString()),
                                                                Double.parseDouble(this.NewestDialysis.KOA.toString()),
                                                                this.getCalcBodyFluidAndReviseValue(),
                                                                Double.parseDouble(this.NewestDialysis.WeightAfter.toString()),
                                                                Double.parseDouble(this.NewestDialysis.WeightTarget.toString()),
                                                                Double.parseDouble(this.NewestDialysis.AddTotal.toString()),
                                                                retVal);
                  }

                  // 計算不能、または計算が失敗した場合
                  if (false == calcResult)
                  {
                      // 計算値なしとする
                      return "";
                  }
                  else
                  {
                      calcAnswer = (Double)retVal.get(PARAMKEY.CALVALUE) ;
                      // 上下限以下は計算値不正としてなにも表示しない
                      if (MAX_KTV < calcAnswer || calcAnswer < MIN_KTV)
                      {
                          return "";
                      }
                      else
                      {
                          // 有効桁数小数点2桁
                          return String.format("%.2f", calcAnswer);
                      }
                  }
          }

          /**
           * Kt/V下限値取得処理
           * 計算式より自動算出
           * @return    Kt/V下限値
           */
          public String getKtPerVLower()
          {
                  double calcAnswer = 0;
                  boolean calcResult = false;
                  HashMap<PARAMKEY,Double> retVal = new HashMap<>( );

                  // 計算するための値がそろっている場合
                  if (null != this.NewestDialysis.RunningTime &&
                      null != this.NewestDialysis.BloodVolume &&
                      null != this.NewestDialysis.KOA &&
                      null != this.NewestDialysis.WeightAfter &&
                      null != this.NewestDialysis.WeightTarget &&
                      null != this.NewestDialysis.AddTotal)
                  {
                       //Kt/V下限を算出
                          calcResult = DialysisCalculator.CalKtvMin(this._PossibleKTVLower,
                                Double.parseDouble(this.NewestDialysis.RunningTime.toString()),
                                Double.parseDouble(this.NewestDialysis.BloodVolume.toString()),
                                Double.parseDouble(this._RecycleRate.toString()),
                                Double.parseDouble(this.NewestDialysis.KOA.toString()),
                                                                this.getCalcBodyFluidAndReviseValue(),
                                                                Double.parseDouble(this.NewestDialysis.WeightAfter.toString()),
                                                                Double.parseDouble(this.NewestDialysis.WeightTarget.toString()),
                                                                Double.parseDouble(this.NewestDialysis.toString()),
                                                                retVal);
                  }

                  // 計算不能、または計算が失敗した場合
                  if (false == calcResult)
                  {
                      // 計算値なしとする
                      return "";
                  }
                  else
                  {
                      // 上下限以下は計算値不正としてなにも表示しない
                      if (MAX_KTV < calcAnswer || calcAnswer < MIN_KTV)
                      {
                          return "";
                      }
                      else
                      {
                          // 有効桁数小数点2桁
                          return String.format("%.2f",calcAnswer);
                      }
                  }
          }

          //再循環率(Kt/V計算用定数)
          private Integer _RecycleRate = 0;
          
          //可能なKt/Vの上限(Kt/V計算用定数)
          private int _PossibleKTVUpper = 700;

          //可能なKt/Vの下限(Kt/V計算用定数)
          private int _PossibleKTVLower = 300;
          

          //メソッド
          /**
           * コンストラクタ
           * @param drCalcData  計算用データ
           */
          public DialysisCalculator(Map<String,Object> drCalcData)
          {
              // 採血時透析情報生成
              this.TakeBloodDialysis = new TakeBloodDialysisInfo(drCalcData);

              // 透析量プログラム情報生成
              this.NewestDialysis = new NewestDialysisInfo(drCalcData);

              // 患者ID設定
              if (drCalcData.containsKey(PATID))
              {
                  set_PatID((String)drCalcData.get(PATID)) ;
              }

              // 表示用患者ID設定
              if (drCalcData.containsKey(DISP_PATID))
              {
                set_DispPatID((String)drCalcData.get(DISP_PATID));
              }

              // 患者名設定
              if (drCalcData.containsKey(NAME))
              {
                set_PatName((String)drCalcData.get(NAME));
              }

              // XML解析(ここは、透析量プログラムでは関係ない、はず)
              if (drCalcData.containsKey(SET_DATA))
              {
                  // SET_DATAを保持
                  setSetData((JSONObject)drCalcData.get(SET_DATA)) ;

                  // XMLの読み込み
                  JSONObject jsonObj = (JSONObject)drCalcData.get(SET_DATA);

                  // xmlDocが生成できなかった場合は処理しない
                  if (null != jsonObj)
                  {
                      try {
                        // 透析量プログラム使用有無
                        if(null != jsonObj.get(TAG_NAME_USE_DIALYSIS_PROGRAM))
                        {
                            set_UseDialysisProgram((String)jsonObj.get(TAG_NAME_USE_DIALYSIS_PROGRAM));
                        }
  
                        // Kt/V目標値
                        if (null != jsonObj.get(TAG_NAME_KT_PER_V_TARGET))
                        {
                            set_KtPerVTarget((String)jsonObj.get(TAG_NAME_KT_PER_V_TARGET));
                        }
                      }
                      catch(JSONException e)
                      {
                        //JSONエラー発生時、なにもしない    暫定処置(存在しなかった扱いでよいとは思う)
                      }
                  }
              }

              // 血流量平均値
              if (drCalcData.containsKey(BDY_BLOOD_VOLUME))
              {
                  // 血流量平均値カラムあり
                  setBloodVolume((String)drCalcData.get(BDY_BLOOD_VOLUME));
              }
              else
              {
                  // 血流量平均値カラムなし
                  // 血液循環積算値と透析運転時間から、血流量の算出

                  if (null != this.TakeBloodDialysis.BloodCirculateTotal &&
                      null != this.TakeBloodDialysis.RunningTime)
                  {
                      // ゼロ除算にならない場合
                      if (false == this.TakeBloodDialysis.RunningTime.equals(0))
                      {
                          // 血液循環積算値 × 1000 ÷ 透析運転時間
                          setBloodVolume(
                                String.format(
                                    "%.0f",
                                    this.TakeBloodDialysis.BloodCirculateTotal.intValue() * 1000 / this.TakeBloodDialysis.RunningTime.intValue()
                                )
                           );
                      }
                  }
              }
          }
//
//          //
//          /// XMLデータに自タグが存在するか判定
//          /// 
//          /// <param name="xmlDoc">対象データ</param>
//          /// <param name="tagName">XMLタグ名</param>
//          /// <returns>true:あり/false:なし</returns>
//          private static bool ExistsTagName(XmlDocument xmlDoc, String tagName)
//          {
//              if (null == xmlDoc)
//              {
//                  return false;
//              }
//
//              if (true == xmlDoc.GetElementsByTagName(tagName).Count.Equals(0))
//              {
//                  return false;
//              }
//              else
//              {
//                  return true;
//              }
//          }
//
//          //
//          /// このインスタンスが持つ計算用データのコピーをDataTableにして返します
//          /// 
//          /// <returns>計算用データ</returns>
//          public DataTable CopyDataSource()
//          {
//              // 入れ物生成
//              DataTable dt = DialysisCalculator.GetEmptyParamDataTable();
//              DataRow dr = dt.NewRow();
//
//              // 各種値取得
//              dr[PATID] = this.PatID;
//              dr[DISP_PATID] = this.DispPatID;
//              dr[NAME] = this.PatName;
//              if (this.NewestDialysis.RunningTime.HasValue)
//              {
//                  dr[KTV_RUNNING_TIME] = this.NewestDialysis.RunningTime.Value;
//              }
//              if (this.NewestDialysis.BloodVolume.HasValue)
//              {
//                  dr[KTV_BLOOD_VOLUME] = this.NewestDialysis.BloodVolume.Value;
//              }
//              if (this.NewestDialysis.KOA.HasValue)
//              {
//                  dr[KTV_KOA] = this.NewestDialysis.KOA.Value;
//              }
//              if (this.NewestDialysis.WeightAfter.HasValue)
//              {
//                  dr[KTV_WEIGHT_AFTER] = this.NewestDialysis.WeightAfter.Value;
//              }
//              if (this.NewestDialysis.WeightTarget.HasValue)
//              {
//                  dr[KTV_WEIGHT_TARGET] = this.NewestDialysis.WeightTarget.Value;
//              }
//              if (this.NewestDialysis.AddTotal.HasValue)
//              {
//                  dr[KTV_ADD_TOTAL] = this.NewestDialysis.AddTotal.Value;
//              }
//              dr[SET_DATA] = this.SetData;
//              if (this.TakeBloodDialysis.DialysisDate.HasValue)
//              {
//                  dr[BDY_DIALYSIS_DATE] = this.TakeBloodDialysis.DialysisDate.Value;
//              }
//              if (this.TakeBloodDialysis.WeightBefore.HasValue)
//              {
//                  dr[BDY_WEIGHT_BEFORE] = this.TakeBloodDialysis.WeightBefore.Value;
//              }
//              if (this.TakeBloodDialysis.WeightAfter.HasValue)
//              {
//                  dr[BDY_WEIGHT_AFTER] = this.TakeBloodDialysis.WeightAfter.Value;
//              }
//              if (this.TakeBloodDialysis.BUNBefore.HasValue)
//              {
//                  dr[BDY_BUN_BEFORE] = this.TakeBloodDialysis.BUNBefore.Value;
//              }
//              if (this.TakeBloodDialysis.BUNAfter.HasValue)
//              {
//                  dr[BDY_BUN_AFTER] = this.TakeBloodDialysis.BUNAfter.Value;
//              }
//              if (this.TakeBloodDialysis.AddTotal.HasValue)
//              {
//                  dr[BDY_ADD_TOTAL] = this.TakeBloodDialysis.AddTotal.Value;
//              }
//              if (this.TakeBloodDialysis.BloodCirculateTotal.HasValue)
//              {
//                  // 血流量積算値を保持しているので、積算値カラムを追加し、血流量平均値カラムを削除
//                  dt.Columns.Add(BDY_BLOOD_CIRCULATE_TOTAL);
//                  dt.Columns.Remove(BDY_BLOOD_VOLUME);
//                  dr[BDY_BLOOD_CIRCULATE_TOTAL] = this.TakeBloodDialysis.BloodCirculateTotal.Value;
//              }
//              if (this.TakeBloodDialysis.RunningTime.HasValue)
//              {
//                  dr[BDY_RUNNING_TIME] = this.TakeBloodDialysis.RunningTime.Value;
//              }
//              if (this.TakeBloodDialysis.LiquidVolume.HasValue)
//              {
//                  dr[BDY_LIQUID_VOLUME] = this.TakeBloodDialysis.LiquidVolume.Value;
//              }
//              if (this.TakeBloodDialysis.KOA.HasValue)
//              {
//                  dr[BDY_KOA] = this.TakeBloodDialysis.KOA.Value;
//              }
//
//              // コピーしたDataTableを返す
//              dt.Rows.Add(dr);
//              return dt;
//          }
//
//          //
//          /// 透析量プログラム計算クラスリスト取得
//          /// 
//          /// <param name="logInfo">ログ情報</param>
//          /// <param name="dataSource">計算用データ</param>
//          /// <returns>計算クラスリスト</returns>
//          public static List<DialysisCalculator> GetCalculatorList(ILogInfo logInfo, DataTable dataSource)
//          {
//              // リスト生成
//              List<DialysisCalculator> lstCalc = new List<DialysisCalculator>();
//
//              foreach (DataRow dr in dataSource.Rows)
//              {
//                  // 1計算結果インスタンス生成
//                  lstCalc.Add(new DialysisCalculator(logInfo, dr));
//              }
//
//              // 生成したリストを返却
//              return lstCalc;
//          }
//
//          //
//          /// 透析量プログラム計算クラスリスト取得
//          /// データソースがDataView型ヴァージョン
//          /// 
//          /// <param name="logInfo">ログ情報</param>
//          /// <param name="dataSource">計算用データ</param>
//          /// <returns>計算クラスリスト</returns>
//          public static List<DialysisCalculator> GetCalculatorList(ILogInfo logInfo, DataView dataSource)
//          {
//              // オーバーロードメソッド呼び出し
//              return DialysisCalculator.GetCalculatorList(logInfo, dataSource.ToTable());
//          }
//

          /**
           * パラメータ用空List取得処理
           *  血液循環積算値以外の全カラム
           * @return    パラメータ用空List
           */
          public static List<Map<String,Object>> getEmptyParamDataTable()
          {
              List<Map<String,Object>> dt = new ArrayList<Map<String,Object>>();

              dt.get(0).put(PATID,null);
              dt.get(0).put(DISP_PATID,null);
              dt.get(0).put(NAME,null);
              dt.get(0).put(KTV_RUNNING_TIME,null);
              dt.get(0).put(KTV_BLOOD_VOLUME,null);
              dt.get(0).put(KTV_KOA,null);
              dt.get(0).put(KTV_WEIGHT_AFTER,null);
              dt.get(0).put(KTV_WEIGHT_TARGET,null);
              dt.get(0).put(KTV_ADD_TOTAL,null);
              dt.get(0).put(SET_DATA,null);
              dt.get(0).put(BDY_DIALYSIS_DATE,null);
              dt.get(0).put(BDY_RUNNING_TIME,null);
              dt.get(0).put(BDY_WEIGHT_BEFORE,null);
              dt.get(0).put(BDY_WEIGHT_AFTER,null);
              dt.get(0).put(BDY_BUN_BEFORE,null);
              dt.get(0).put(BDY_BUN_AFTER,null);
              dt.get(0).put(BDY_ADD_TOTAL,null);
              dt.get(0).put(BDY_BLOOD_VOLUME,null);
              dt.get(0).put(BDY_LIQUID_VOLUME,null);
              dt.get(0).put(BDY_KOA,null);

              return dt;
          }
          
          /**
           * 体液量計算処理
           * @param BW      透析後体重(kg)
           * @param TX      透析時間(min)
           * @param BUN1    透析前 BUN(mg/dL)
           * @param BUN2    透析後 BUN(mg/dL)
           * @param DBWX    除水の総量(L)
           * @param QB      血液量(ml/min)
           * @param QD      透析液流量(ml/min)
           * @param KOA0    KoA(ml/min)
           * @param RR      再循環率(%)
           * @param calValue体液量計算値(返却値)
           * @return    true:成功　false:失敗
           */
          public static boolean calBodyFluid(
              double BW, 
              double TX, 
              double BUN1, 
              double BUN2, 
              double DBWX, 
              double QB,
              double QD, 
              double KOA0, 
              double RR, 
              HashMap<PARAMKEY,Double> calValue)
          {

//            dbgPrint("透析後体重(kg)    BW:" + BW) ;
//            dbgPrint("透析時間(min)     TX:" + TX) ;
//            dbgPrint("透析前 BUN(mg/dL) BUN1:" + BUN1) ;
//            dbgPrint("透析後 BUN(mg/dL) BUN2:" + BUN2) ;
//            dbgPrint("除水の総量(L)     DBWX:" + DBWX) ;
//            dbgPrint("血液量(ml/min)   QB:" + QB) ;
//            dbgPrint("透析液流量(ml/min)QD:" + QD) ;
//            dbgPrint("KoA(ml/min)     KOA0:" + KOA0) ;
//            dbgPrint("再循環率(%)      RR:" + RR) ;
            
            int calRound = 0;

            double R = BUN2 / BUN1;
            double KOA = (-1.1985 + 0.81572 * 0.4343 * Math.log((double)QD)) * KOA0;
            RR = RR / 100;
            double KTVU = -Math.log(R - 0.008 * TX / 60) + (4 - 3.5 * R) * DBWX / BW;
            double K1 = KTVU / TX;
            double VW = BW * 400;
            while(true)
            {
              // 無限ループ防止のため最大計算回数で制限
          ///=========================================================================
              //計算繰り返し回数最大値
              final int MAX_CALC_ROUND = 10000;
          ///=========================================================================
              if (MAX_CALC_ROUND < ++calRound)
              {
                  // 失敗
                  return false;
              }
              double DBW = DBWX / VW;
              double P1 = 0.8306 * Math.pow(10, 10) * Math.pow(DBW, 2) - 0.1118 * Math.pow(10, 7) * DBW - 0.0834 * Math.pow(10, 4);
              double P2 = -2.2858 * Math.pow(10, 8) * Math.pow(DBW, 2) + 1.0900 * Math.pow(10, 5) * DBW + 0.2607 * Math.pow(10, 2);
              double P3 = 0.9600 * Math.pow(10, 6) * Math.pow(DBW, 2) - 1.2556 * Math.pow(10, 3) * DBW - 0.1732;
              double P4 = 0.1248 * Math.pow(10, 4) * Math.pow(DBW, 2) - 0.0728 * 10 * DBW - 0.0076 * Math.pow(10, (-2));
              double K2 = K1 + P1 * Math.pow(K1, 3) + P2 * Math.pow(K1, 2) + P3 * K1 + P4;
              double K21 = K2 * VW;
              double K22 = (1 - RR) * K21 / (1 - RR - RR * K21 / QB);
              double AA = 1 - Math.exp(KOA * (1 / QB - 1 / QD));
              double BB = 1 / QD - 1 / QB * Math.exp(KOA * (1 / QB - 1 / QD));
              double K = AA / BB;
              double D = K22 - K;
              if (D >= 0)
              {
                  break ;
              }
              VW = VW + 20;
            }
            calValue.put(PARAMKEY.CALVALUE,Double.valueOf(VW));

            return true;

              /*
              INPUT"透析後体重(kg)="; BW
              INPUT"透析時間(min)="; TX
              INPUT "透析前 BUN(mg/dL)=";BUN1
              INPUT "透析後 BUN(mg/dL)=";BUN2
              R=BUN2/BUN1
              INPUT"除水の総量(L)=";DBWX
              INPUT"血流量(ml/min)=";QB
              INPUT"透析液流量(ml/min)=";QD
              INPUT"KoA(ml/min)=";KOA0
              KOA=(-1.1985+0.81572*0.4343*LOG(QD))*KOA0
              INPUT"再循環率(%)=";RR
              RR=RR/100
              KTVU=-LOG(R-0.008*TX/60)+(4-3.5*R)*DBWX/BW
              K1=KTVU/TX
              VW=BW*400
          120 DBW=DBWX/VW
              P1=0.8306*10^10*DBW^2-0.1118*10^7*DBW-0.0834*10^4
              P2=-2.2858*10^8*DBW^2+1.0900*10^5*DBW+0.2607*10^2
              P3=0.9600*10^6*DBW^2-1.2556*10^3*DBW-0.1732
              P4=0.1248*10^4*DBW^2-0.0728*10*DBW-0.0076*10^(-2)
              K2=K1+P1*K1^3+P2*K1^2+P3*K1+P4
              K21=K2*VW
              K22=(1-RR)*K21/(1-RR-RR*K21/QB)
              AA=1-exp(KOA*(1/QB-1/QD))
              BB=1/QD-1/QB*exp(KOA *(1/QB-1/QD))
              K=AA/BB
              D=K22-K
              IF D>=0 THEN 270
              VW=VW+20 
              GOTO 120
              PRINT"体水分量(ml)=";VW            
              */
          }

          /**
           * KtV上限値計算処理
           * @param QD      可能なKtV上限値
           * @param TX      透析時間(min)
           * @param QB      血液量(ml/min)
           * @param RR      再循環率(%)
           * @param KOA0    KoA(ml/min)
           * @param VWa     体液量 補正値(ml)
           * @param BWa     透析後体重(kg)
           * @param BW2     目標透析終了時体重(kg)
           * @param DBWX    除水量(kg)
           * @param retValue    KtV上限値計算値(返却値)
           * @return        true:成功/false:失敗
           */
          public static boolean CalKtvMax(
                  double QD, 
                  double TX, 
                  double QB, 
                  double RR, 
                  double KOA0, 
                  double VWa, 
                  double BWa,
                  double BW2, 
                  double DBWX, 
                  HashMap<PARAMKEY,Double> retValue)
          {
              int calRound = 0;
                double calValue = 0;
              double DD = 0;
              double N = 0;
              RR = RR / 100;
              double VWX = VWa + (BW2 - BWa) * 1000;
              double DBW = DBWX / VWX;
              if (QB == QD)
              {
                  QD = QB + 10;
              }
              double KOA = (-1.1985 + 0.81572 * 0.4343 * Math.log(QD)) * KOA0;
              double AA = 1 - Math.exp(KOA * (1 / QB - 1 / QD));
              double BB = 1 / QD - 1 / QB * Math.exp(KOA * (1 / QB - 1 / QD));
              double K22 = AA / BB;
              double K21 = K22 * (1 - RR - RR * K22 / QB) / (1 - RR);
              double K2 = K21 / VWX;
              double KTVX = 1.5;
              while(true)
              {
                // 無限ループ防止のため最大計算回数で制限
                if (MAX_CALC_ROUND < ++calRound)
                {
                    // 失敗
                    return false;
                }
                double K1X = KTVX / TX;
                double P1 = 0.8306 * Math.pow(10, 10) * Math.pow(DBW, 2) - 0.1118 * Math.pow(10, 7) * DBW - 0.0834 * Math.pow(10, 4);
                double P2 = -2.2858 * Math.pow(10, 8) * Math.pow(DBW, 2) + 1.0900 * Math.pow(10, 5) * DBW + 0.2607 * Math.pow(10, 2);
                double P3 = 0.9600 * Math.pow(10, 6) * Math.pow(DBW, 2) - 1.2556 * Math.pow(10, 3) * DBW - 0.1732;
                double P4 = 0.1248 * Math.pow(10, 4) * Math.pow(DBW, 2) - 0.0728 * 10 * DBW - 0.0076 * Math.pow(10, (-2));
                double K2X = K1X + P1 * Math.pow(K1X, 3) + P2 * Math.pow(K1X, 2) + P3 * K1X + P4;
                if (N == 99999)
                {
                    //goto goto450;
                }
                else
                {
                  DD = K2 - K2X;
                }
                N = 99999;
                double D = K2 - K2X;
                if (DD > 0)
                {
                  if (D < 0)
                  {
                    break ;
                  }
                  KTVX = KTVX + 0.01;
                }
                else if (DD < 0)
                {
                    if (D > 0)
                    {
                      break ;
                    }
                    KTVX = KTVX - 0.01;
              }
              else if (DD == 0)
              {
                    break ;
              }
            }
            calValue = KTVX - 0.01;

            
            retValue.put(PARAMKEY.CALVALUE,calValue) ;
            return true;

//              /*
//              20 PRINT "**** 可能なKt/Vの上限（QD=700mL/min）****"
//              130 PRINT "透析時間(min) " ; TX
//              140 PRINT "血流量(ml/min) " ; QB
//              150 PRINT "再循環率(%)" ; RR
//              160 PRINT "KOA" ; KOA0
//              170 PRINT "体液量 補正値(ml) ";VWa
//              180 PRINT "透析後体重(kg) ";BWa
//              190 PRINT "目標透析終了時体重(kg)";BW2
//              200 PRINT "除水量(kg) ";DBWX
//              210 QD=700
//              230 RR=RR/100
//              240 VWX= VWa+(BW2-BWa)*1000
//              250 DBW=DBWX/VWX
//              270 IF QB=QD THEN QD=QB+10
//              280 KOA=(-1.1985+0.81572*0.4343*LOG(QD))*KOA0
//              290 AA=1-exp(KOA*(1/QB-1/QD))
//              300 BB=1/QD-1/QB*exp(KOA *(1/QB-1/QD))
//              310 K22=AA/BB
//              320 K21=K22*(1-RR-RR* K21K22/QB)/(1-RR)
//              330 K2=K21/VWX
//              350 KTVX=1.5
//              360 K1X=KTVX/TX
//              370 P1=0.8306*10^10*DBW^2-0.1118*10^7*DBW-0.0834*10^4
//              380 P2=-2.2858*10^8*DBW^2+1.0900*10^5*DBW+0.2607*10^2
//              390 P3=0.9600*10^6*DBW^2-1.2556*10^3*DBW-0.1732
//              400 P4=0.1248*10^4*DBW^2-0.0728*10*DBW-0.0076*10^(-2)
//              410 K2X=K1X+P1*K1X^3+P2*K1X^2+P3*K1X+P4
//              420 IF N=99999 THEN 450
//              430 DD=K2-K2X
//              440 N=99999
//              450 D=K2-K2X
//              460 IF DD>0 THEN 490
//              470 IF DD<0 THEN 520
//              480 IF DD=0 THEN 550
//              490 IF D<0 THEN 550
//              500 KTVX=KTVX+0.01
//              510 GOTO 360
//              520 IF D>0 THEN 550
//              530 KTVX=KTVX-0.01
//              540 GOTO 360
//              550 PRINT " Kt/V上限= "; KTVX-0.01
//              */
          }
//
          /**
           * KtV下限値計算処理
           * @param QD      可能なKtV下限値
           * @param TX      透析時間(min)
           * @param QB      血液量(ml/min)
           * @param RR      再循環率(%)
           * @param KOA0    KoA(ml/min)
           * @param VWa     体液量 補正値(ml)
           * @param BWa     透析後体重(kg)
           * @param BW2     目標透析終了時体重(kg)
           * @param DBWX    除水量(kg)
           * @param retValue    KtV下限値計算値(返却値)
           * @return        true:成功/false:失敗
           */
          public static boolean CalKtvMin(
                double QD, 
                double TX, 
                double QB, 
                double RR, 
                double KOA0, 
                double VWa, 
                double BWa,
                double BW2, 
                double DBWX, 
                HashMap<PARAMKEY,Double> retValue
              )
          {
              int calRound = 0;
              double calValue = 0;
              double DD = 0;
              double N = 0;
              RR = RR / 100;
              double VWX = VWa + (BW2 - BWa) * 1000;
              double DBW = DBWX / VWX;
              if (QB == QD)
              {
                  QD = QB + 10;
              }
              double KOA = (-1.1985 + 0.81572 * 0.4343 * Math.log(QD)) * KOA0;
              double AA = 1 - Math.exp(KOA * (1 / QB - 1 / QD));
              double BB = 1 / QD - 1 / QB * Math.exp(KOA * (1 / QB - 1 / QD));
              double K22 = AA / BB;
              double K21 = K22 * (1 - RR - RR * K22 / QB) / (1 - RR);
              double K2 = K21 / VWX;
              double KTVX = 1.2;
              while(true)
              {
                // 無限ループ防止のため最大計算回数で制限
                if (MAX_CALC_ROUND < ++calRound)
                {
                    // 失敗
                    return false;
                }
                double K1X = KTVX / TX;
                double P1 = 0.8306 * Math.pow(10, 10) * Math.pow(DBW, 2) - 0.1118 * Math.pow(10, 7) * DBW - 0.0834 * Math.pow(10, 4);
                double P2 = -2.2858 * Math.pow(10, 8) * Math.pow(DBW, 2) + 1.0900 * Math.pow(10, 5) * DBW + 0.2607 * Math.pow(10, 2);
                double P3 = 0.9600 * Math.pow(10, 6) * Math.pow(DBW, 2) - 1.2556 * Math.pow(10, 3) * DBW - 0.1732;
                double P4 = 0.1248 * Math.pow(10, 4) * Math.pow(DBW, 2) - 0.0728 * 10 * DBW - 0.0076 * Math.pow(10, (-2));
                double K2X = K1X + P1 * Math.pow(K1X, 3) + P2 * Math.pow(K1X, 2) + P3 * K1X + P4;
                if (N == 99999)
                {
                   //
                }
                else
                {
                  DD = K2 - K2X;
                  N = 99999;
                }
                double D = K2 - K2X;
                
                if (DD > 0)
                {
                  if (D < 0)
                  {
                    break;
                  }
                  KTVX = KTVX + 0.01;
                }
                else if (DD < 0)
                {
                  if (D > 0)
                  {
                      break;
                  }
                  KTVX = KTVX - 0.01;
                }
                else if (DD == 0)
                {
                    break ;
                }
              }
              calValue = KTVX + 0.01; 
              retValue.put(PARAMKEY.CALVALUE,calValue) ;
              return true;
//
//
//
//              /*
//              20 PRINT "**** 可能なKt/Vの下限（QD=300mL/min）****"
//              130 PRINT "透析時間(min) " ; TX
//              140 PRINT "血流量(ml/min) " ; QB
//              150 PRINT "再循環率(%)" ; RR
//              160 PRINT "KOA" ; KOA0
//              170 PRINT "体液量 補正値(ml) ";VWa
//              180 PRINT "透析後体重(kg) ";BWa
//              190 PRINT "目標透析終了時体重(kg)";BW2
//              200 PRINT "除水量(kg) ";DBWX
//              210 QD=300
//              230 RR=RR/100
//              240 VWX= VWa+(BW2-BWa)*1000
//              250 DBW=DBWX/VWX
//              270 IF QB=QD THEN QD=QB+10
//              280 KOA=(-1.1985+0.81572*0.4343*LOG(QD))*KOA0
//              290 AA=1-exp(KOA*(1/QB-1/QD))
//              300 BB=1/QD-1/QB*exp(KOA *(1/QB-1/QD))
//              310 K22=AA/BB
//              320 K21=K22*(1-RR-RR*K21 K22/QB)/(1-RR)
//              330 K2=K21/VWX
//              350 KTVX=1.2
//              360 K1X=KTVX/TX
//              370 P1=0.8306*10^10*DBW^2-0.1118*10^7*DBW-0.0834*10^4
//              380 P2=-2.2858*10^8*DBW^2+1.0900*10^5*DBW+0.2607*10^2
//              390 P3=0.9600*10^6*DBW^2-1.2556*10^3*DBW-0.1732
//              400 P4=0.1248*10^4*DBW^2-0.0728*10*DBW-0.0076*10^(-2)
//              410 K2X=K1X+P1*K1X^3+P2*K1X^2+P3*K1X+P4
//              420 IF N=99999 THEN 450
//              430 DD=K2-K2X
//              440 N=99999
//              450 D=K2-K2X
//              460 IF DD>0 THEN 490
//              470 IF DD<0 THEN 520
//              480 IF DD=0 THEN 550
//              490 IF D<0 THEN 550
//              500 KTVX=KTVX+0.01
//              510 GOTO 360
//              520 IF D>0 THEN 550
//              530 KTVX=KTVX-0.01
//              540 GOTO 360
//              550 PRINT " Kt/V下限= "; KTVX+0.01
//              */
          }
          
          //子クラス
          /**
           * 採血時透析情報
           *
           */
          private class TakeBloodDialysisInfo
          {
              //プロパティ

              //透析日
              //患者装置設定より取得
              public Date DialysisDate ;
              //透析運転時間
              //任意の値or患者装置設定より取得
              public Integer RunningTime ;

              //血液循環積算値
              //透析実績より取得
              public Integer BloodCirculateTotal ;
              //KOA
              //透析実績より取得
              public Integer KOA ;
              //除水量積算値
              //透析実績より取得
              public Integer AddTotal ;
              //前体重
              //透析実績測定体重より取得
              public Integer WeightBefore ;
              //後体重
              //透析実績測定体重より取得
              public Integer WeightAfter ;
              //透析液流量
              //透析実績透析条件より取得
            public Integer LiquidVolume ;
              //透析前BUN
              //検査計算なんとかより算出
            public Integer BUNBefore ;
              //透析後BUN
              //検査計算なんとかより算出
            public Integer BUNAfter ;

            /**
             * コンストラクタ
             * @param drTakeBloodDial   採血時透析情報
             */
              public TakeBloodDialysisInfo(Map<String,Object> drTakeBloodDial)
              {
                  // 透析日
                  if (drTakeBloodDial.containsKey(BDY_DIALYSIS_DATE))
                  {
                      Date dtmDialysisDate;
                      dtmDialysisDate = (Date)drTakeBloodDial.get(BDY_DIALYSIS_DATE);
                    this.DialysisDate = dtmDialysisDate;
                  }
                  // 透析運転時間
                  if (drTakeBloodDial.containsKey(BDY_RUNNING_TIME))
                  {
                      int decRunningTime;
                      try {
                        decRunningTime = Integer.parseInt((String)drTakeBloodDial.get(BDY_RUNNING_TIME)) ;
                        this.RunningTime = decRunningTime;
                      }
                      catch(Exception e)
                      {
                          //変換に失敗したらなにもしない
                      }
                  }
                  // 血液循環積算値
                  if (drTakeBloodDial.containsKey(BDY_BLOOD_CIRCULATE_TOTAL))
                  {
                      int decBloodCirculateTotal;
                      try {
                        decBloodCirculateTotal = Integer.parseInt((String)drTakeBloodDial.get(BDY_BLOOD_CIRCULATE_TOTAL)) ;
                        this.BloodCirculateTotal = decBloodCirculateTotal;
                      }
                      catch(Exception e)
                      {
                          //変換に失敗したらなにもしない
                      }
                  }
                  // KOA
                  if (drTakeBloodDial.containsKey(BDY_KOA))
                  {
                      int decKOA;
                      try {
                        decKOA = Integer.parseInt((String)drTakeBloodDial.get(BDY_KOA)) ;
                        this.KOA = decKOA;
                      }
                      catch(Exception e)
                      {
                          //変換に失敗したらなにもしない
                      }
                  }
                  // 除水積算値
                  if (drTakeBloodDial.containsKey(BDY_ADD_TOTAL))
                  {
                      int decAddTotal;
                      try {
                        decAddTotal = Integer.parseInt((String)drTakeBloodDial.get(BDY_ADD_TOTAL)) ;
                        this.AddTotal = decAddTotal;
                      }
                      catch(Exception e)
                      {
                          //変換に失敗したらなにもしない
                      }
                  }
                  // 前体重
                  if (drTakeBloodDial.containsKey(BDY_WEIGHT_BEFORE))
                  {
                      int decWeightBefore;
                      try {
                        decWeightBefore = Integer.parseInt((String)drTakeBloodDial.get(BDY_WEIGHT_BEFORE)) ;
                        this.WeightBefore = decWeightBefore;
                      }
                      catch(Exception e)
                      {
                          //変換に失敗したらなにもしない
                      }
                  }

                  // 後体重
                  if (drTakeBloodDial.containsKey(BDY_WEIGHT_AFTER))
                  {
                      int decWeightAfter;
                      try {
                        decWeightAfter = Integer.parseInt((String)drTakeBloodDial.get(BDY_WEIGHT_AFTER)) ;
                        this.WeightAfter = decWeightAfter;
                      }
                      catch(Exception e)
                      {
                          //変換に失敗したらなにもしない
                      }
                  }

                // 透析液流量
                if (drTakeBloodDial.containsKey(BDY_LIQUID_VOLUME))
                {
                    int decLiquid;
                    try {
                      decLiquid = Integer.parseInt((String)drTakeBloodDial.get(BDY_LIQUID_VOLUME)) ;
                      this.LiquidVolume = decLiquid;
                    }
                    catch(Exception e)
                    {
                        //変換に失敗したらなにもしない
                    }
                }

              // 透析前BUN
              if (drTakeBloodDial.containsKey(BDY_BUN_BEFORE))
              {
                  int decBUNBefore;
                  try {
                    decBUNBefore = Integer.parseInt((String)drTakeBloodDial.get(BDY_BUN_BEFORE)) ;
                    this.BUNBefore = decBUNBefore;
                  }
                  catch(Exception e)
                  {
                      //変換に失敗したらなにもしない
                  }
              }

            // 透析後BUN
            if (drTakeBloodDial.containsKey(BDY_BUN_AFTER))
            {
                int decBUNAfter;
                try {
                  decBUNAfter = Integer.parseInt((String)drTakeBloodDial.get(BDY_BUN_AFTER)) ;
                  this.BUNAfter = decBUNAfter;
                }
                catch(Exception e)
                {
                    //変換に失敗したらなにもしない
                }
            }

              }
            
          }


          /**
           * 最新の透析実績クラス
           *
           */
          @Getter
          @Setter
          private class NewestDialysisInfo
          {
              //region プロパティ

            //透析運転時間(分)
              //最新の透析実績より取得
            public Integer RunningTime ;
              //血流量(ml/min)
              //最新の透析実績透析条件より取得
            public Integer BloodVolume ;
              //KOA
              //ダイアライザマスタより取得
            public Integer KOA ;
              //後体重
              //最新の透析実績測定体重より取得
              public Integer WeightAfter ;
              //目標体重
              //最新の透析実績より取得
            public Integer WeightTarget ;
              /// 除水積算値
              //最新の透析実績より取得
              public Integer AddTotal ;
              //メソッド
              //コンストラクタ
              //
              /**
               * コンストラクタ
               * @param drNewestDial
               */
              public NewestDialysisInfo(Map<String,Object> drNewestDial)
              {
                  // 透析運転時間
                  if (drNewestDial.containsKey(KTV_RUNNING_TIME))
                  {
                      int decRunningTime;
                      try {
                        decRunningTime = Integer.parseInt((String)drNewestDial.get(KTV_RUNNING_TIME)) ;
                        this.RunningTime = decRunningTime;
                      }
                      catch(Exception e)
                      {
                        //なにもしない
                      }
                  }
                  // 血流量
                  if (drNewestDial.containsKey(KTV_BLOOD_VOLUME))
                  {
                      int decBloodVoluem;
                      try {
                        decBloodVoluem = Integer.parseInt((String)drNewestDial.get(KTV_BLOOD_VOLUME)) ;
                        this.BloodVolume = decBloodVoluem;
                      }
                      catch(Exception e)
                      {
                        //なにもしない
                      }
                  }
                  // KOA
                  if (drNewestDial.containsKey(KTV_KOA))
                  {
                      int decKOA;
                      try {
                        decKOA = Integer.parseInt((String)drNewestDial.get(KTV_KOA)) ;
                        this.KOA = decKOA;
                      }
                      catch(Exception e)
                      {
                        //なにもしない
                      }
                  }
                  // 後体重
                  if (drNewestDial.containsKey(KTV_WEIGHT_AFTER))
                  {
                      int decWeightAfter;
                      try {
                        decWeightAfter = Integer.parseInt((String)drNewestDial.get(KTV_WEIGHT_AFTER)) ;
                        this.WeightAfter = decWeightAfter;
                      }
                      catch(Exception e)
                      {
                        //なにもしない
                      }
                  }
                  // 目標体重
                  if (drNewestDial.containsKey(KTV_WEIGHT_TARGET))
                  {
                      int decWeightTarget;
                      try {
                        decWeightTarget = Integer.parseInt((String)drNewestDial.get(KTV_WEIGHT_TARGET)) ;
                        this.WeightTarget = decWeightTarget;
                      }
                      catch(Exception e)
                      {
                        //なにもしない
                      }
                  }
                  // 除水積算値
                  if (drNewestDial.containsKey(KTV_ADD_TOTAL))
                  {
                      int decAddTotal;
                      try {
                        decAddTotal = Integer.parseInt((String)drNewestDial.get(KTV_ADD_TOTAL)) ;
                        this.AddTotal = decAddTotal;
                      }
                      catch(Exception e)
                      {
                        //なにもしない
                      }
                  }
              }

          }




}
