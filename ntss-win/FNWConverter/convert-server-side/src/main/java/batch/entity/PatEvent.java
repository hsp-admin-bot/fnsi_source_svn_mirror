package batch.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import java.sql.Timestamp;

/**
 * 患者イベント管理クラス
 */
@Entity
@Table(name = "pat_event")
@Getter
@Setter
public class PatEvent extends BaseEntity {

    /**
     * システムで管理する一意な患者イベントコード
     */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long patEventCd;
    /**
     * システムで管理する一意な患者ID
     */
    Long patId;
    /**
     * 施設コード
     */
    String facilityCd;
    /**
     * FNW+で管理する施設内の一意なシーケンスID
     */
    Long fnCtlNo;
    /**
     * 状況区分
     */
    String eventStatus;
    /**
     * テンプレートコード
     */
    Long templateCd;
    /**
     * テンプレート名称
     */
    String templateName;
    /**
     * カテゴリコード
     */
    Long categoryCd;
    /**
     * カテゴリ名称
     */
    String categoryName;
    /**
     * 利用種別
     */
    Integer useType;
    /**
     * システムで管理する一意なオーダ番号
     */
    Long ordNo;
    /**
     * 項目情報
     */
    String inputParams;
    /**
     * イベント開始日時
     */
    String eventStartDate;
    /**
     * イベント終了日時
     */
    String eventEndDate;
    /**
     * イベント開始時刻
     */
    String eventStartTime;
    /**
     * イベント終了時刻
     */
    String eventEndTime;
    /**
     * サブカテゴリコード
     */
    Long subCategoryCd;
    /**
     * サブカテゴリ名称
     */
    String subCategoryName;
    /**
     * 項目実績
     */
    String resultParams;
    /**
     * スコア合計
     */
    Integer scoreTotal;
    /**
     * 起票者情報
     */
    String regStaffInfo;
    /**
     * 編集者情報
     */
    String upStaffInfo;
    /**
     * 掲示板管理番号
     */
    Long bbsCtlNo;
    /**
     * 最新フラグ
     */
    String isNewest;
    /**
     * 削除フラグ
     */
    String isDel;

    /**
     * 登録日時
     */
    private Timestamp regDate;

    /**
     * 更新日時
     */
    private Timestamp upDate;

    /**
     * 紹介状データ
     */
    String letterInfo;

    String reportUrl;

    String reportDate;

}
