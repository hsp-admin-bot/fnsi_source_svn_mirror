package jp.co.nikkiso.ntss.admin_web.web.rest.validation;

import javax.validation.constraints.Pattern;
import javax.validation.constraints.NotBlank;

import lombok.Getter;
import lombok.Setter;

public class ApiEntityMstInfo {

  /**
   * ベッドマスタ一覧取得(空きベッド検索)
   */
  @Getter
  @Setter
  public static class ValiSearchFreeBeds {
    /**
     * 抽出データ（処理対象施設の施設コード）
     */
    @NotBlank(message="値がありません")
    private String facility_cd;
    /**
     * 抽出データ（処理対象患者の患者ID）
     */
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]+",message="数値ではありません。")
    private String pat_id;
    /**
     * 抽出データ（処理対象クールコード）
     */
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]+",message="数値ではありません。")
    private String kur_cd;
    /**
     * 抽出データ（処理対象曜日パターン）
     */
    @NotBlank(message="値がありません")
    private String treat_week_list;
    /**
     * 抽出データ（処理対象指示開始日）
     */
    @NotBlank(message="値がありません")
    private String ind_start_date;
    /**
     * 抽出データ（処理対象指示終了日）
     */
    private String ind_end_date;
    /**
     * 抽出データ（全ベッド取得フラグ）
     */
    @NotBlank(message="値がありません")
    private String is_all;
    /**
     * 選択済みベッドコード
     */
    private Long init_bed_cd;
    /**
    * 抽出データ（処理対象治療予定の指示：クールコード）
    */
    private String ind_kur_cd;
    /**
     * 抽出データ（処理対象治療予定の指示：治療方法コード）
     */
    private String ind_treatment_cd;
  }
}