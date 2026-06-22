package web.constant;

/**
 * 定数クラス
 *
 */
public class CommonConstants {

    // add #9132 コンバート処理中にDBが高負荷となり停止 zkm start
    // psqlでCOPYを実行した後、AUTOVACUUMが実行され、追加したデータのインデクス作成にかかる時間
    public static final long motionSleepMillis = 1500L;
    // add #9132 コンバート処理中にDBが高負荷となり停止 zkm end

    public static final int NUMBER_ZERO = 0;
    public static final int NUMBER_ONE = 1;
    public static final int NUMBER_TWO = 2;
    public static final int NUMBER_THREE = 3;
    public static final int NUMBER_FOUR = 4;
    public static final int NUMBER_FIVE = 5;
    public static final int NUMBER_SIX = 6;
    public static final int NUMBER_SEVEN = 7;
    public static final int NUMBER_EIGHT = 8;
    public static final int NUMBER_NINE = 9;
    public static final int NUMBER_TEN = 10;

    public static final String STRING_ZERO = "0";
    public static final String STRING_ONE = "1";
    public static final String STRING_TWO = "2";
    public static final String STRING_THREE = "3";
    public static final String STRING_FOUR = "4";
    public static final String STRING_FIVE = "5";
    public static final String STRING_SIX = "6";
    public static final String STRING_SEVEN = "7";
    public static final String STRING_EIGHT = "8";
    public static final String STRING_NINE = "9";
    public static final String STRING_TEN = "10";

}
