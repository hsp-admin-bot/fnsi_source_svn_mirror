package jp.co.nikkiso.ntss.admin_web.service.scaleBed.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CheckScaleMessage {
  /**
   * 計算式
   */
  private String calc;

  /**
   * 表示条件
   */
  private ViewCondition condition;
  /**
   * 計算結果
   */
  private String value;
  /**
   * 表示内容
   */
  private String message;
  /**
   * 正常範囲外フラグ
   */
  private boolean isWarnValue;
  /**
   * 警報フラグ
   */
  private boolean isWarn;
  /**
   * エラーフラグ
   */
  private boolean isError;
  /**
   * 警報チェックフラグ
   */
  private boolean isChecked;
  /**
   * 表示フラグ
   */
  private boolean isDisp;

  @Getter
  @Setter
  public static class ViewCondition {
    private Integer use;
    private String left;
    private String right;
    private Integer ineq;
    private Boolean result;
  }

  public CheckScaleMessage() {
    this.isWarnValue = false;
    this.isWarn = false;
    this.isError = false;
    this.isChecked = false;
    this.isDisp = false;
    this.message = "";
    this.value = null;
    this.calc = null;
    this.condition = new ViewCondition();
  }

  public CheckScaleMessage(String calc, Integer useCondition, String conditionLeft, String conditionRight, Integer conditionIneq) {
    this.isWarnValue = false;
    this.isWarn = false;
    this.isError = false;
    this.isChecked = false;
    this.isDisp = false;
    this.message = "";
    this.value = null;
    this.calc = calc;
    this.condition = new ViewCondition();
    this.condition.setLeft(conditionLeft);
    this.condition.setRight(conditionRight);
    this.condition.setUse(useCondition);
    this.condition.setIneq(conditionIneq);
  }


  public static class UseCondition {
    /**
     * 常に表示
     */
    public static final int ALWAYS = 0;
    /**
     * 満たす場合に表示
     */
    public static final int IS_TRUE_VIEW = 1;
    /**
     * 満たさない場合に表示
     */
    public static final int IS_FALSE_VIEW = 2;
  }

  public static class ConditionIneq {
    /**
     * >
     */
    public static final int MORE = 0;
    /**
     * >=
     */
    public static final int MORE_EQUAL = 1;
    /**
     * ==
     */
    public static final int EQUAL = 2;
    /**
     * !=
     */
    public static final int NOT_EQUAL = 3;

    /**
     * <=
     */
    public static final int LESS_EQUAL = 4;

    /**
     * <
     */
    public static final int LESS = 5;

  }
  public static class Sendable {
    /**
     * 条件送信可能
     */
    public static final int OK = 0;
    /**
     * 正常範囲外確認チェック
     */
    public static final int CHECK_WARN = 1;
    /**
     * 正常範囲外送信不可
     */
    public static final int CHECK_ERROR = 2;
    /**
     * 表示時確認チェック
     */
    public static final int VIEW_WARN = 3;
    /**
     * 表示時送信不可
     */
    public static final int VIEW_ERROR = 4;
  }
}
