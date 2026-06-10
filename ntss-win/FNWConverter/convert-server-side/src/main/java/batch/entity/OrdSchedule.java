package batch.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import java.sql.Timestamp;
import java.time.LocalDateTime;

/**
 * 治療スケジュール
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "ord_schedule")
@Getter
@Setter
public class OrdSchedule {

    /** 施設コード */
    private String facilityCd;
    /** システムで管理する一意なオーダ番号 */
    private Long ordNo;
    /** 治療日 */
    private String treatDate;
    /** クールコード */
    private Integer kurCd;
    /** ベッドコード */
    private Integer bedCd;
    /** システムで管理する一意な患者ID */
    private Long patId;
    /** ダミーフラグ */
    private String isDummy;
    /** 治療曜日 */
    private Short treatWeek;
    /** 登録日時 */
    private Timestamp regDate;
    /** 更新日時 */
    private Timestamp upDate;

    @Override
    public String toString() {
        StringBuffer sb = new StringBuffer();
        sb.append(facilityCd==null ? "" : facilityCd).append(",")
                .append(ordNo==null ? "" : ordNo).append(",")
                .append(treatDate==null ? "" : treatDate).append(",")
                .append(kurCd==null ? "" : kurCd).append(",")
                .append(bedCd==null ? "" : bedCd).append(",")
                .append(patId==null ? "" : patId).append(",")
                .append(isDummy==null ? "" : isDummy).append(",")
                // mod #9839 ダミースケジュールがコンバートされていない zs start
                .append(treatWeek==null ? "" : treatWeek).append(",")
                .append(upDate==null ? Timestamp.valueOf(LocalDateTime.now()) : upDate).append(",")
                .append(regDate==null ? Timestamp.valueOf(LocalDateTime.now()) : regDate);
                // mod #9839 ダミースケジュールがコンバートされていない zs end
        return sb.toString();
    }
}
