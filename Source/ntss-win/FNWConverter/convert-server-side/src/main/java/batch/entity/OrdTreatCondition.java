package batch.entity;

import lombok.Getter;
import lombok.Setter;
import org.json.JSONObject;
import org.seasar.doma.Id;
import org.seasar.doma.Table;

import java.sql.Timestamp;

@Table(name = "ord_treat_condition")
@Getter
@Setter
public class OrdTreatCondition extends BaseEntity {

    /**
     * 治療条件管理番号
     */
    @Id
    private Long conditionCd;

    /**
     * オーダー番号
     */
    private Long ordNo;

    /**
     * 施設コード
     */
    private String facilityCd;

    /**
     * 装置番号
     */
    private Long machineNo;

    /**
     * 条件取得日時
     */
    private Timestamp receiveDate;

    /**
     * 治療条件
     */
    private JSONObject treatCondition;

    /**
     * 区分
     */
    private Long treatClass;

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
     * 重写ToString方法，将DTO转换为以逗号隔开字符串
     *
     * @return Str
     */
    @Override
    public String toString() {
        StringBuffer sb = new StringBuffer();
        sb.append(upDate==null ? "" : upDate).append(",")
                .append(regDate==null ? "" : regDate).append(",")
                .append(facilityCd==null ? "" : facilityCd).append(",")
                .append(machineNo==null ? "" : machineNo).append(",")
                .append(receiveDate==null ? "" : receiveDate).append(",")
                .append(treatClass==null ? "" : treatClass).append(",")
                .append(isDisp==null ? "" : isDisp).append(",")
                .append(isDel==null ? "" : isDel).append(",")
                .append(ordNo==null ? "" : ordNo).append(",")
                .append(treatCondition==null ? "" : treatCondition.toString().replace(",", "|"));
        return sb.toString();
    }
}
