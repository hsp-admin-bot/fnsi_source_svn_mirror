package web.entity;

import batch.entity.BaseBlankEntity;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Id;
import org.seasar.doma.Table;

import java.sql.Timestamp;


/**
 * pat_treatment_pattern(患者治療パターン)のエンティティクラス
 */
@Table(name = "pat_treatment_pattern")
@Getter
@Setter
public class PatTreatmentPatternPatMain extends BaseBlankEntity {

    @Id
    /**
     * システムで管理する一意な患者ID
     */
    private Long patId;

    @Id
    /**
     * 管理番号
     */
    private Long ctlNo;

    /**
     * 施設コード
     */
    private String facilityCd;

    /**
     * 治療種別
     */
    private Double treatType;

    /**
     * 適用開始日
     */
    private String indTreatStartDate;

    /**
     * 指示：治療方法コード
     */
    private Integer indTreatmentCd;

    /**
     * 指示：クールコード
     */
    private Long indKurCd;

    /**
     * 治療曜日
     */
    private Short treatWeek;

    /**
     * 指示：スケジュール情報
     */
    private String indSchInfo;

    /**
     * 指示：治療条件情報
     */
    private String indCondInfo;

    /**
     * 指示：投与薬剤情報
     */
    private String indMediInfo;

    /**
     * 指示：医療材料情報
     */
    private String indEquipInfo;

    /**
     * 指示：指示コメント情報
     */
    private String indIndCommentInfo;

    /**
     * 指示：風袋補正情報
     */
    private String indTareInfo;

    /**
     * 指示：除水補正情報
     */
    private String indOffWaterInfo;

    /**
     * 指示：装置設定情報
     */
    private String indDeviceSetInfo;

    /**
     * 登録日時
     */
    private Timestamp regDate;

    /**
     * 更新日時
     */
    private Timestamp upDate;

    /**
     * スケジュール延長最終日
     */
    private String schExtEndDate;
}
