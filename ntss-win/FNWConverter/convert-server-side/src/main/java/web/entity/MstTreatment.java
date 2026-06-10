package web.entity;

import batch.entity.BaseBlankEntity;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Column;
import org.seasar.doma.Id;
import org.seasar.doma.Table;

import java.sql.Timestamp;
/**
 * 治療方法セットマスタ情報クラス
 */
@Table(name = "mst_treatment")
@Getter
@Setter
public class MstTreatment extends BaseBlankEntity {
    /**
     * 治療方法コード
     */
    @Id
    private Integer treatmentCd;
    /**
     * 施設コード
     */
    private String facilityCd;
    /**
     * FNW治療方法コード
     */
    private String fnTreatmentCd;
    /**
     * 治療方法名
     */
    private String treatmentName;

    /**
     * 装置モード
     */
    private Integer deviceMode;
    /**
     * 治療経過表ID
     */
    private Integer reportId;
    /**
     * 治療経過表ID(手書き)
     */
    private Integer reportIdHw;
    /**
     * 治療経過表ID(前体重)
     */
    private Integer reportIdBw;
    /**
     * 治療経過表ID(後体重)
     */
    private Integer reportIdAw;
    /**
     * 治療経過表ID(装置画像転送用)
     */
    private Integer reportIdDev;
    /**
     * グラフ時間幅
     */
    private Integer graphTimeScale;
    /**
     * 治療条件設定
     */
    private String treatmentConditionSetting;
    /**
     * モニタデータ項目(帳票用)
     */
    private String monitorDataItemPrint;
    /**
     * モニタデータ項目(画面用)
     */
    private String monitorDataItemScreen;
    /**
     * 表示フラグ
     */
    private String isDisp;
    /**
     * 削除フラグ
     */
    private String isDel;
    /**
     * 登録日時
     */
    private Timestamp regDate;
    /**
     * 更新日時
     */
    private Timestamp upDate;
    /**
     * 利用開始日A
     */
    @Column(name = "in_hosp_a_startdate")
    private String inHospAStartdate;
    /**
     * 連携コードA1
     */
    private String inHospitalCdA1;
    /**
     * 連携コードA2
     */
    private String inHospitalCdA2;
    /**
     * 連携コードA3
     */
    private String inHospitalCdA3;
    /**
     * 連携コードA4
     */
    private String inHospitalCdA4;
    /**
     * 利用開始日B
     */
    @Column(name = "in_hosp_b_startdate")
    private String inHospBStartdate;
    /**
     * 連携コードB1
     */
    private String inHospitalCdB1;
    /**
     * 連携コードB2
     */
    private String inHospitalCdB2;
    /**
     * 連携コードB3
     */
    private String inHospitalCdB3;
    /**
     * 連携コードB4
     */
    private String inHospitalCdB4;

    /**
     * 帳票グラフ設定
     */
    private String reportGraphSetting;

    /**
     * 治療経過表ID（実績確定）
     */
    private Integer reportIdAct;
}
