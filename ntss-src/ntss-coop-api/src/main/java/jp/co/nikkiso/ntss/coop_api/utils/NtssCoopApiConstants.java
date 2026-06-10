package jp.co.nikkiso.ntss.coop_api.utils;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.Arrays;
import java.util.List;

/**
 * 電子カルテ連携システム用の定数クラス
 *
 */
public class NtssCoopApiConstants {
  /**
   * 変換ステータスenum
   *
   */
  @Getter
  public enum AnaResult {
    UNPROCESS("0"),
    PROCESSING("1"),
    DONE("9"),
    SKIP("S"),
    INTERNAL_ERROR("E1"),
// mod 2023-01-29 bug #7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 孫 start
//    INTERNAL_ERROR_BY_CARTE("E2");
    INTERNAL_ERROR_BY_CARTE("E2"),
    RESERVE("H");
// mod 2023-01-29 bug #7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 孫 end

    private String result;

    public boolean isSameResult(String target) {
      return this.result.equals(target);
    }

    AnaResult(String result) {
      this.result = result;
    }
  }

  /**
   * 通信ステータスenum
   *
   */
  @Getter
  public enum CoopResult {
    UNPROCESS("0"),
    PROCESSING("1"),
    WAITING("8"),
    DONE("9"),
// add 2023-01-29 bug #7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 孫 start
    RETRY("R"),
// add 2023-01-29 bug #7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 孫 end
    SKIP("S"),
    INTERNAL_ERROR_BY_NTSS("E1"),
// mod 2023-01-29 bug #7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 孫 start
//    INTERNAL_ERROR_BY_CARTE("E2");
    INTERNAL_ERROR_BY_CARTE("E2"),
    RESERVE("H");
// mod 2023-01-29 bug #7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 孫 end

    private String result;

    public boolean isSameResult(String target) {
      return this.result.equals(target);
    }

    CoopResult(String result) {
      this.result = result;
    }
  }

  public static List<String> coopResultSkipList = Arrays.asList(
    CoopResult.UNPROCESS.getResult(),
    CoopResult.RETRY.getResult()
//    , CoopResult.INTERNAL_ERROR_BY_NTSS.getResult()
//    , CoopResult.INTERNAL_ERROR_BY_CARTE.getResult()
  );
  /**
   * 作成更新区分 enum
   *
   */
  @Getter
  public enum Crud {

    CREATE("C"),
    UPDATE("U"),
    DELETE("D");

    private String result;

    public boolean isSameResult(String target) {
      return this.result.equals(target);
    }

    Crud(String result) {
      this.result = result;
    }
  }
  /**
   * IFエッジモニタ情報のステータス
   */
  @AllArgsConstructor
  @Getter
  public enum IFHealthMonitorStatus {
    /** サーバステータス：正常 */
    SERVER_ACTIVE("01"),
    /** サーバステータス：手動停止 */
    SERVER_INACTIVE("F0"),
    /** エッジステータス：正常 */
    FACILITY_ACTIVE("01"),
    /** エッジステータス：手動停止 */
    FACILITY_INACTIVE("F0"),
    /** エッジステータス：異常 */
    FACILITY_ERROR("F1");

    /** ステータス値 */
    private String value;
  }

  /** 属性のvalue値 */
  @Getter
  @AllArgsConstructor
  public enum ElementsValue {
    /** 固定値(const) */
    CONST("const"),
    /** 自己増加する(auto) */
    AUTO("auto"),
    /** データセット(dataset) */
    DATASET("dataset"),
    /** 権限ID(auth_id) */
    AUTH_ID("auth_id"),
// add 2021-10-14 CSIの「【検査予定送信】のスタッフマスタ.職種コード」の対応 孫 start
    /** 職種コード(job_cd) */
    JOB_CD("job_cd"),
// add 2021-10-14 CSIの「【検査予定送信】のスタッフマスタ.職種コード」の対応 孫 end
// add 2021-10-28 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 start
    /** 利用者名(staff_name) */
    STAFF_NAME("staff_name"),
// add 2021-10-28 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 end
// add 2021-12-22 #5888:NEC-iS連携ができない(透析実績(rst_dial)) 孫 start
    /** 院内コード1(in_hospital_cd_1) */
    IN_HOSPITAL_CD_1("in_hospital_cd_1"),
    /** 院内コード2(in_hospital_cd_2) */
    IN_HOSPITAL_CD_2("in_hospital_cd_2"),
// add 2021-12-22 #5888:NEC-iS連携ができない(透析実績(rst_dial)) 孫 end
    /** 未定義(undefined) */
    UNDEFINED("undefined");

    // フィールド変数
    private final String key;

    /**
     * フィールド値に一致するエレメントの取得
     *
     * @param key 検索する値
     * @return エレメント定義
     *  */
    public static ElementsValue getElement(String key) {
      for (ElementsValue val: values()) {
        if (val.key.equals(key)) {
          return val;
        }
      }
      // 一致するvalueがない場合
      return ElementsValue.UNDEFINED;
    }
  }

  /**
   * IFエッジ番号固定値
   * <p>
   * 施設コードに対して 1つの想定のため、1固定
   */
  public static final Integer IF_EDGE_NO_DEFAULT = Integer.valueOf(1);

  /**
   * 発行タイミング（更新）のステータス
   */
  @AllArgsConstructor
  @Getter
  public enum ApiTimingIoStatus {
    /** サーバステータス：/journal/create */
    CREATE("I"),
    /** サーバステータス：/journal/convert */
    CONVERT("C"),
    /** エッジステータス：/journal/delivery */
    // mod 2021-04-02 課題No.1:API連動設定:動作条件に「処理完了時」「処理エラー時」「処理スキップ時」を追加 孫 start
//    DELIVERY("D");
    DELIVERY("D"),
    // mod 2021-06-09 #5278 API連動処理の判定が正しくない wangchen start
    /** 処理ステータス：変換処理完了(A9) */
    ANA_DONE("A9"),
    /** 処理ステータス：変換スキップ(AS) */
    ANA_SKIP("AS"),
    /** 処理ステータス：変換エラー(AE) */
    ANA_ERROR("AE"),

    /** 処理ステータス：配信処理完了(C9) */
    COOP_DONE("C9"),
    /** 処理ステータス：配信キップ(CS) */
    COOP_SKIP("CS"),
    /** 処理ステータス：配信エラー(CE) */
    COOP_ERROR("CE");
    // mod 2021-06-09 #5278 API連動処理の判定が正しくない wangchen end
    // mod 2021-04-02 課題No.1:API連動設定:動作条件に「処理完了時」「処理エラー時」「処理スキップ時」を追加 孫 end

    /** ステータス値 */
    private String status;
  }

  /**
   * 発行タイミング（前後）のステータス
   */
  @AllArgsConstructor
  @Getter
  public enum ApiTimingBaStatus {
    /** 発行タイミング：処理前 */
    BEFORE("B"),
    /** 発行タイミング：処理後 */
    AFTER("A");

    /** ステータス値 */
    private String status;
  }

  // add 2021-04-02 課題No.1:API連動設定:SQL呼び出しを追加 孫 start
  /**
   * API種別
   */
  @AllArgsConstructor
  @Getter
  public enum ApiType {
    /** API種別：http */
    HTTP("0"),
    /** API種別：sql */
    SQL("1");

    /** 種別値 */
    private String value;
  }
  // add 2021-04-02 課題No.1:API連動設定:SQL呼び出しを追加 孫 end
}
