package jp.co.nikkiso.ntss.api.constant;

/**
 * ntss-apiの定数クラス.
 */
public class ApiConstant {

   /**
   * ON/OFFフラグ
   */
  public static class FlagType {

    /**
     * OFF.
     */
    public static final String FLAG_OFF = "0";

    /**
     * ON.
     */
    public static final String FLAG_ON = "1";
  }

  /**
   * 月の最大日数
   */
  public static final int MONTH_DAYS = 31;

  // add redmain #4822 鄧シン start
  /**
   * 帳票グラフ設定が未登録時の初期値
   */
  public  static final String DEFAULT_JSON_DATA = "[{is_bp:true,cd:\"90\",type:1,plot_type:\"triangle-down-b\",plot_color:\"#999999\",plot_size:5,line_type:\"Solid\",line_color:\"#999999\",line_thickness:2,max:250,min:0},{is_bp:true,cd:\"92\",type:1,plot_type:\"circle\",plot_color:\"#999999\",plot_size:5,line_type:\"Solid\",line_color:\"#999999\",line_thickness:2,max:250,min:0},{is_bp:true,cd:\"91\",type:1,plot_type:\"triangle-b\",plot_color:\"#999999\",plot_size:5,line_type:\"Solid\",line_color:\"#999999\",line_thickness:2,max:250,min:0}]";
  // add redmain #4822 鄧シン end
}
