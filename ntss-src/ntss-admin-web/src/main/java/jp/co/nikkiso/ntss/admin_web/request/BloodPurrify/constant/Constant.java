package jp.co.nikkiso.ntss.admin_web.request.BloodPurrify.constant;

/**
 * 定数クラス
 * @author y.kataguchi
 *
 */
public class Constant {

  /**
   * REST URI定義
   *
   */
  public static class Uri {
//    public final String DATA_FILE_UPLOAD = "/api/post_file";
//    public final String FILE_DOWNLOAD = "/api/s3/download";
//    public static final  String DEVICE_EDGE_ORDER = "/api/device_edge_order";
//
//    /* 装置マスタ */
//    public static final String MACHINES = "/api/machines";
//    /* SMS通知機能用 */
//    public static final String SMS = "/api/sms";
  }

  /**
   * mni_monitor.data_typeの内容
   *
   */
  public static class DataType {
    /**
     * 不明
     */
    public final short UNKNOWN = 0;
    /**
     * モニタデータ
     */
    public final short MONITOR = 1;
    /**
     * 血圧
     */
    public final short BLOODPRESS = 2;
    /**
     * 再循環率
     */
    public final short RECIRCULATION = 3;
  }

  /**
   * mnt_motion_record.log_typeの内容
   *
   */
  public static class LogType {
    /**
     * 不明
     */
    public final short UNKNOWN = 0;
    /**
     * 警報
     */
    public final short ALARM = 1;
    /**
     * 注意
     */
    public final short WARN = 2;
    /**
     * 操作
     */
    public final short OPERATION = 3;
    /**
     * その他
     */
    public final short OTHER = 4;
  }

  public static class OrdMainConst {
    /**
     * 治療状況
     */
    public static class DialysisState {
      /**
       * 条件送信前
       */
      public static final String BEFORE_SEND = "0";
      /**
       * 条件送信済
       */
      public static final String AFTER_SEND = "1";
      /**
       * 条件送信確認済み
       */
      public static final String CHECKED_SEND = "2";
      /**
       * 治療中
       */
      public static final String DIALYSIS = "3";
      /**
       * 排液済
       */
      public static final String AFTER_DIALYSIS = "4";
      /**
       * 後体重測定済み(実績未確定)
       */
      public static final String AFTER_WEIGHT = "5";
      /**
       * 後体重確認済み(過去実績)
       */
      public static final String PAST_RECORD = "6";
    }
  }

  /**
   * ord_mainのind_cond_infoの項目
   *
   */
  public static class CondItemCd {
    /**
     * 透析時間
     */
    public static final short TREAT_TIME = 1;
    /**
     * VA
     */
    public static final short VA = 2;
    /**
     * 目標体重
     */
    public static final short WEIGHT_TARGET = 3;
    /**
     * 除水量制限
     */
    public static final short REMOVAL_LIMIT = 4;
    /**
     * ダイアライザ
     */
    public static final short DIALIZER = 5;
    /**
     * 吸着カラム
     */
    public static final short ADSORBENT = 6;
    /**
     * 1次膜
     */
    public static final short ONECE_MEMBRANE = 7;
    /**
     * 2次膜
     */
    public static final short SECONDARY_MEMBRANE = 8;
    /**
     * 穿刺針(A針)
     */
    public static final short NEEDLE_A = 9;
    /**
     * 穿刺針(V針)
     */
    public static final short NEEDLE_V = 10;
    /**
     * 穿刺針(S針)
     */
    public static final short NEEDLE_S = 11;
    /**
     * シングルニードル使用
     */
    public static final short USE_SINGLE_NEEDLE = 12;
    /**
     * 血液回路
     */
    public static final short BLOOD_CIRCUIT = 13;
    /**
     * 血流量
     */
    public static final short BV = 14;
    /**
     * 透析液
     */
    public static final short DIALYSIS_FLUID = 15;
    /**
     * 透析液流量
     */
    public static final short DIALYSIS_FLOW_RATE = 16;
    /**
     * 透析液量
     */
    public static final short DIALYSIS_FLUID_VOLUME = 17;
    /**
     * 透析液温度
     */
    public static final short DIALYSIS_FLUID_TEMPERATURE = 18;
    /**
     * 補液
     */
    public static final short FLUID_REPLACEMENT = 19;
    /**
     * 補液量
     */
    public static final short FLUID_REPLACEMENT_VOLUME = 20;
    /**
     * 補液選択
     */
    public static final short FLUID_REPLACEMENT_SELECT = 21;
    /**
     * 補液使用数
     */
    public static final short FLUID_REPLACEMENT_USE_CNT = 22;
    /**
     * 補液温度
     */
    public static final short FLUID_REPLACEMENT_TEMPERATURE = 23;
    /**
     * 補液速度
     */
    public static final short FLUID_REPLACEMENT_RATE = 24;
    /**
     * 抗凝固剤
     */
    public static final short ANTICOAGULANT = 25;
    /**
     * 抗凝固剤初回注入量
     */
    public static final short ANT_INPUT_ONESHOT = 26;
    /**
     * 抗凝固剤持続注入量
     */
    public static final short ANT_INPUT_CONT = 27;
    /**
     * 抗凝固剤持続総量
     */
    public static final short ANT_INPUT_CONT_TOTAL = 28;
    /**
     * IP使用選択
     */
    public static final short IP_USE_SELECT = 29;
    /**
     * IPスタート
     */
    public static final short IP_START = 30;
    /**
     * IPワンショット量
     */
    public static final short IP_ONESHOT = 31;
    /**
     * IP速度
     */
    public static final short IP_SPEED = 32;
    /**
     * IP速度最大値
     */
    public static final short IP_SPEED_MAX = 33;
    /**
     * IPワンショットスタート
     */
    public static final short AUTO_ONESHOT = 34;
    /**
     * IP電源自動切り
     */
    public static final short IP_AUTO_POWER_OFF = 35;
    /**
     * IP電源自動切り時間
     */
    public static final short IP_AUTO_POWER_OFF_TIME = 36;
    /**
     * IP電源OKモニタ切り
     */
    public static final short IP_OK_MONITOR_OFF = 37;
    /**
     * IP電源OKモニタ切り時間
     */
    public static final short IP_OK_MONITOR_OFF_TIME = 38;

  }

  /**
   * 透析日報表示項目
   */
  public static class DailyReportDispItemCd {
    /**
     * 透析開始時刻
     */
    public static final short START_TIME = 1;
    /**
     * 透析終了時刻
     */
    public static final short END_DATE = 2;
    /**
     * 目標体重
     */
    public static final short WEIGHT_TARGET = 3;
    /**
     * 前体重
     */
    public static final short WEIGHT_BEFORE = 4;
    /**
     * 前最高血圧
     */
    public static final short BP_MAX_BEFORE = 5;
    /**
     * 前最低血圧
     */
    public static final short BP_MIN_BEFORE = 6;
    /**
     * 前平均血圧
     */
    public static final short BP_AVE_BEFORE = 7;
    /**
     * 前脈拍
     */
    public static final short PULSE_BEFORE = 8;
    /**
     * 後体重
     */
    public static final short WEIGHT_AFTER = 9;
    /**
     * 後最高血圧
     */
    public static final short BP_MAX_AFTER = 10;
    /**
     * 後最低血圧
     */
    public static final short BP_MIN_AFTER = 11;
    /**
     * 後平均血圧
     */
    public static final short BP_AVE_AFTER = 12;
    /**
     * 後脈拍
     */
    public static final short PULSE_AFTER = 13;
    /**
     * 除水速度制限
     */
    public static final short UFR_LIMIT = 14;
    /**
     * 除水量制限
     */
    public static final short REMOVAL_LIMIT = 15;
    /**
     * 透析時間
     */
    public static final short TREAT_TIME = 16;
    /**
     * 目標所水量
     */
    public static final short REMOVAL_TARGET = 17;
    /**
     * 血流量
     */
    public static final short BV = 18;
    /**
     * IP速度
     */
    public static final short IP_SPEED = 19;
    /**
     * 透析回数
     */
    public static final short DIALYSIS_CNT = 20;
    /**
     * 実績除水量
     */
    public static final short RST_REMOVAL = 21;
    /**
     * 実績血液循環量
     */
    public static final short RST_BV_CIRCULATE = 22;
    /**
     * 治療法
     */
    public static final short TREAT_NAME = 23;
    /**
     * DW
     */
    public static final short DW = 24;
    /**
     * CTR
     */
    public static final short CTR = 25;
    /**
     * 血液型
     */
    public static final short BLOOD_TYPE_ABO = 26;
    /**
     * RH
     */
    public static final short BLOOD_TYPE_RH = 27;
    /**
     * VA
     */
    public static final short VA = 28;
    /**
     * ダイアライザ
     */
    public static final short DIALYZER = 29;
    /**
     * 透析液
     */
    public static final short DIALYSIS_FLUID = 30;
    /**
     * 抗凝固剤
     */
    public static final short ANTICOAGULANT = 31;
    /**
     * (凝)初回注入量
     */
    public static final short ANT_INPUT_ONESHOT = 32;
    /**
     * (凝)持続注入量
     */
    public static final short ANT_INPUT_CONT = 33;
    /**
     * (凝)持続総量
     */
    public static final short ANT_INPUT_CONT_TOTAL = 34;
    /**
     * (凝)合計注入量
     */
    public static final short ANT_INPUT_TOTAL = 35;
    /**
     * 前回後体重
     */
    public static final short LAST_WEIGHT_AFTER = 36;
    /**
     * 除水速度
     */
    public static final short UFR = 37;
    /**
     * 補液速度
     */
    public static final short FLUID_REPLACEMENT_RATE = 38;
    /**
     * 補液温度設定値
     */
    public static final short FLUID_REPLACEMENT_TEMPERATURE = 39;
    /**
     * 補液量設定値
     */
    public static final short FLUID_REPLACEMENT_VOLUME_SETTING = 40;
    /**
     * 補液速度限界値
     */
    public static final short FLUID_REPLACEMENT_RATE_LIMIT = 41;
    /**
     * 補液量設定値制限
     */
    public static final short FLUID_REPLACEMENT_VOLUME_SETTING_LIMIT = 42;
    /**
     * 入外区分
     */
    public static final short IN_OUT = 43;
    /**
     * 前体重ーDW
     */
    public static final short BEFORE_WEIGHT_MINUS_DW = 44;
    /**
     * 前体重ー前回後体
     */
    public static final short BEFORE_WEIGHT_MINUS_LAST_AFTER_WEIGHT = 45;
    /**
     * 前回後体重ー前体
     */
    public static final short LAST_AFTER_WEIGHT_MINUS_BEFORE_WEIGHT = 46;
    /**
     * 前体重ー後体重
     */
    public static final short BEFORE_WEIGHT_MINUS_AFTER_WEIGHT = 47;
    /**
     * 後体重ー前体重
     */
    public static final short AFTER_WEIGHT_MINUS_BEFORE_WEIGHT = 48;
    /**
     * 除水補正値合計g
     */
    public static final short UFR_AMEND_TOTAL_G = 49;
    /**
     * 除水補正値合計L
     */
    public static final short UFR_AMEND_TOTAL_L = 50;
    /**
     * クール名
     */
    public static final short KUR_NAME = 51;
    /**
     * ベッド名
     */
    public static final short BED_NAME = 52;
    /**
     * 穿刺者
     */
    public static final short PUNCTURE_NAME = 53;
    /**
     * 回収者
     */
    public static final short RETURN_NAME = 54;
    /**
     * 病棟名
     */
    public static final short WARD_NAME = 55;
    /**
     * ダイアライザ幕面積
     */
    public static final short DIALYZER_AREA = 56;
    /**
     * 消耗品01
     */
    public static final short EQUIP01 = 57;
    /**
     * 消耗品02
     */
    public static final short EQUIP02 = 58;
    /**
     * 消耗品03
     */
    public static final short EQUIP03 = 59;
    /**
     * 消耗品04
     */
    public static final short EQUIP04 = 60;
    /**
     * 消耗品05
     */
    public static final short EQUIP05 = 61;
    /**
     * 消耗品06
     */
    public static final short EQUIP06 = 62;
    /**
     * 消耗品07
     */
    public static final short EQUIP07 = 63;
    /**
     * 消耗品08
     */
    public static final short EQUIP08 = 64;
    /**
     * 消耗品09
     */
    public static final short EQUIP09 = 65;
    /**
     * 消耗品10
     */
    public static final short EQUIP10 = 66;
    /**
     * 薬剤01
     */
    public static final short MEDI01 = 67;
    /**
     * 薬剤02
     */
    public static final short MEDI02 = 68;
    /**
     * 薬剤03
     */
    public static final short MEDI03 = 69;
    /**
     * 薬剤04
     */
    public static final short MEDI04 = 70;
    /**
     * 薬剤05
     */
    public static final short MEDI05 = 71;
    /**
     * 薬剤06
     */
    public static final short MEDI06 = 72;
    /**
     * 薬剤07
     */
    public static final short MEDI07 = 73;
    /**
     * 薬剤08
     */
    public static final short MEDI08 = 74;
    /**
     * 薬剤09
     */
    public static final short MEDI09 = 75;
    /**
     * 薬剤10
     */
    public static final short MEDI10 = 76;
    /**
     * 薬剤11
     */
    public static final short MEDI11 = 77;
    /**
     * 薬剤12
     */
    public static final short MEDI12 = 78;
    /**
     * 薬剤13
     */
    public static final short MEDI13 = 79;
    /**
     * 薬剤14
     */
    public static final short MEDI14 = 80;
    /**
     * 薬剤15
     */
    public static final short MEDI15 = 81;
    /**
     * 薬剤16
     */
    public static final short MEDI16 = 82;
    /**
     * 薬剤17
     */
    public static final short MEDI17 = 83;
    /**
     * 薬剤18
     */
    public static final short MEDI18 = 84;
    /**
     * 薬剤19
     */
    public static final short MEDI19 = 85;
    /**
     * 薬剤20
     */
    public static final short MEDI20 = 86;

  }

  public static class NextPatMemoItemCd {
    /**
    * 患者ID
    */
    public static final int patId = 1;
    /**
    * 患者名フリガナ
    */
    public static final int patNameKana = 2;
    /**
    * 性別・年齢
    */
    public static final int patSexAge = 3;
    /**
    * 状態 (内容は入外区分)
    */
    public static final int inOutClass = 4;
    /**
    * 病棟名
    */
    public static final int wardName = 5;
    /**
    * 所属科名
    */
    public static final int courseName = 6;
    /**
    * 担当医名
    */
    public static final int doctorName = 7;
    /**
    * DW
    */
    public static final int dw = 8;
    /**
    * VA
    */
    public static final int va = 9;
    /**
    * 治療項目名
    */
    public static final int treatName = 10;
    /**
    * 開始時間
    */
    public static final int treatStartTime = 11;
    /**
    * 透析時間
    */
    public static final int treatTime = 12;
    /**
    * 治療モード
    */
    public static final int treatMode = 13;
    /**
    * ダイアライザ名
    */
    public static final int dialyzer = 14;
    /**
    * A針名
    */
    public static final int needle_A = 15;
    /**
    * V針名
    */
    public static final int needle_V = 16;
    /**
    * 抗凝固剤名
    */
    public static final int anticoagulant = 17;
    /**
    * ワンショット量
    */
    public static final int antInputOneShot = 18;
    /**
    * 持続注入量
    */
    public static final int antInputCont = 19;
    /**
    * 持続総量
    */
    public static final int antInputContTotal = 20;
    /**
    * 合計注入量
    */
    public static final int antInputTotal = 21;
    /**
    * (未使用)
    */
    public static final int blank22 = 22;
    /**
    * (未使用)
    */
    public static final int blank23 = 23;
    /**
    * (未使用)
    */
    public static final int blank24 = 24;
    /**
    * 消耗品１
    */
    public static final int equip01 = 25;
    /**
    * 消耗品２
    */
    public static final int equip02 = 26;
    /**
    * 消耗品３
    */
    public static final int equip03 = 27;
    /**
    * 消耗品４
    */
    public static final int equip04 = 28;
    /**
    * 消耗品５
    */
    public static final int equip05 = 29;
    /**
    * 消耗品６
    */
    public static final int equip06 = 30;
    /**
    * 消耗品７
    */
    public static final int equip07 = 31;
    /**
    * 消耗品８
    */
    public static final int equip08 = 32;
    /**
    * 消耗品９
    */
    public static final int equip09 = 33;
    /**
    * 消耗品１０
    */
    public static final int equip10 = 34;
    /**
    * 透析液
    */
    public static final int dialysisFluid = 35;
    /**
    * 投与薬剤１
    */
    public static final int medi01 = 36;
    /**
    * 投与薬剤２
    */
    public static final int medi02 = 37;
    /**
    * 投与薬剤３
    */
    public static final int medi03 = 38;
    /**
    * 投与薬剤４
    */
    public static final int medi04 = 39;
    /**
    * 投与薬剤５
    */
    public static final int medi05 = 40;
    /**
    * 投与薬剤６
    */
    public static final int medi06 = 41;
    /**
    * 投与薬剤７
    */
    public static final int medi07 = 42;
    /**
    * 投与薬剤８
    */
    public static final int medi08 = 43;
    /**
    * 投与薬剤９
    */
    public static final int medi09 = 44;
    /**
    * 投与薬剤１０
    */
    public static final int medi10 = 45;
    /**
    * 投与薬剤１１
    */
    public static final int medi11 = 46;
    /**
    * 投与薬剤１２
    */
    public static final int medi12 = 47;
    /**
    * 投与薬剤１３
    */
    public static final int medi13 = 48;
    /**
    * 投与薬剤１４
    */
    public static final int medi14 = 49;
    /**
    * 投与薬剤１５
    */
    public static final int medi15 = 50;
    /**
    * 投与薬剤１６
    */
    public static final int medi16 = 51;
    /**
    * 投与薬剤１７
    */
    public static final int medi17 = 52;
    /**
    * 投与薬剤１８
    */
    public static final int medi18 = 53;
    /**
    * 投与薬剤１９
    */
    public static final int medi19 = 54;
    /**
    * 投与薬剤２０
    */
    public static final int medi20 = 55;
    /**
    * (空白)
    */
    public static final int blank91 = 91;
    /**
    * (空白)
    */
    public static final int blank92 = 92;
    /**
    * (空白)
    */
    public static final int blank93 = 93;
    /**
    * (空白)
    */
    public static final int blank94 = 94;
    /**
    * (空白)
    */
    public static final int blank95 = 95;
    /**
    * (空白)
    */
    public static final int blank96 = 96;
    /**
    * (空白)
    */
    public static final int blank97 = 97;
    /**
    * (空白)
    */
    public static final int blank98 = 98;
    /**
    * (空白)
    */
    public static final int blank99 = 99;

  }

  /* del by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  // /**
  //  * WebSocket通知用定数
  //  */
  // public static class NotifyTarget {
  //   /**
  //    * デバイスエッジメインアプリケーション対象通知トピック用文字列
  //    */
  //   public static String DEVICE_EDGE_MAIN_LABEL = "EDGE";

  //   /**
  //    * デバイスエッジアップデータアプリケーション対象通知トピック用文字列
  //    */
  //   public static String DEVICE_EDGE_UPDATER_LABEL = "UPDEDGE";

  //   /**
  //    * ブラウザ対象通知トピック用文字列
  //    */
  //   public static String WEB_BROWSER_LABEL = "BROWSER";

  //   /**
  //    * 体重計接続サービスアプリ対象通知トピック用文字列
  //    */
  //   public static String WEB_WEIGHT_APP_LABEL = "WSCALE";

  //   /**
  //    * デバイスエッジ対象接続サーバータイプ
  //    */
  //   public static Integer DEVICE_EDGE_SERVER_TYPE = 0;

  //   /**
  //    * ブラウザ対象接続サーバータイプ
  //    */
  //   public static Integer WEB_BROWSER_SERVER_TYPE = 1;
  // }
  /* del by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

  /**
   * WebSocket通知識別用トピック情報
   *
   */
  public static class WebSocketTopic {
    /**
     * 体重計装置を操作する指示用
     *
     */
    public static class WeightState {
      /**
       * 患者カード読み取り
       */
      public static final String CARD_READ = "WEIGHT/CARD_READ";
      /**
       * 体重計入力取得
       */
      public static final String SCALE = "WEIGHT/SCALE_VALUE";
      /**
       * カード書き込み指示
       */
      public static final String CARD_WRITE = "WEIGHT/CARD_WRITE";
      /**
       * カード書き込み結果参照指示
       */
      public static final String CARD_WRITE_RESULT = "WEIGHT/CARD_WRITE_RESULT";
      /**
       * 体重計接続状態更新
       */
      public static final String WEIGHT_CONNECT = "WEIGHT/CONNECT";
      /**
       * 条件送信結果
       */
      public static final String SEND_RESULT = "WEIGHT/SEND_RESULT";
    }

    /**
     * 通信サーバー用
     */
    public static class ComSv {
      /**
       * 条件送信指示
       */
      public static final String SEND_CONDITION = "COMSV/1";
      /**
       * 装置オプション読出し指示
       */
      public static final String READ_OPTION = "COMSV/2";
      /**
       * 設定値読出し指示
       */
      public static final String READ_SETTING_VALUE = "COMSV/3";
      /**
       * 次患者情報転送指示
       */
      public static final String SEND_NEXT_PAT = "COMSV/4";
      /**
       * 通信サーバー設定更新指示
       */
      public static final String RELOAD_COMSV_SETTING = "COMSV/5";
      /**
       * 愁訴処置マスタ更新指示
       */
      public static final String RELOAD_TREAT_MASTER = "COMSV/6";
      /**
       * スタッフマスタ更新指示
       */
      public static final String RELOAD_STAFF_MASTER = "COMSV/7";
      /**
       * 未登録患者割付指示
       */
      public static final String SET_UNKNOWN_PAT = "COMSV/8";
      /**
       * 条件送信キャンセル指示
       */
      public static final String CANCEL_CONDITION = "COMSV/9";
      /**
       * 投薬指示変更指示
       */
      public static final String CHANGE_IND_MEDI  = "COMSV/10";
      /**
       * 後体重測定指示
       */
      public static final String AFTER_WEIGHT  = "COMSV/11";
      /**
       * 治療状況確認指示
       */
      public static final String CHECK_STATUS  = "COMSV/12";
    }
  }

}
