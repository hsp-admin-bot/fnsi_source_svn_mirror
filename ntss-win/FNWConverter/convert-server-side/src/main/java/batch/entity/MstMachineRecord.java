package batch.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;

import java.sql.Timestamp;
import java.util.Objects;

@Entity
@Table(name = "mst_machine_record")
@Getter
@Setter
public class MstMachineRecord extends BaseBlankEntity{
    private  String  machineRecordCd;
    private  String machineRecordMessage;
    /**
     * 登録日時.
     */
    private Timestamp regDate;
    /**
     * 更新日時.
     */
    private Timestamp upDate;
    private String isDefault;
    private  String logClass;
    private  String targetModel;
    private String dispFlg;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        MstMachineRecord that = (MstMachineRecord) o;
        return Objects.equals(machineRecordCd, that.machineRecordCd) && Objects.equals(machineRecordMessage, that.machineRecordMessage) && Objects.equals(regDate, that.regDate) && Objects.equals(upDate, that.upDate) && Objects.equals(isDefault, that.isDefault) && Objects.equals(logClass, that.logClass) && Objects.equals(targetModel, that.targetModel) && Objects.equals(dispFlg, that.dispFlg);
    }

    @Override
    public int hashCode() {
        return Objects.hash(machineRecordCd, machineRecordMessage, regDate, upDate, isDefault, logClass, targetModel, dispFlg);
    }
}
