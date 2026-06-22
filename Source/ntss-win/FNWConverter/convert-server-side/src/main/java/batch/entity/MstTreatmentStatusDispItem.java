package batch.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;

import java.sql.Timestamp;
import java.util.Objects;

@Entity
@Table(name = "mst_treatment_status_disp_item")
@Getter
@Setter
public class MstTreatmentStatusDispItem extends BaseBlankEntity{
    private  Integer itemCd;
    private  String dataClass;
    private  String machineClass;
    private  String itemName;
    private  String tableName;
    private  String fieldName;
    private  String jsonKeyName;
    private  Integer dispOrder;
    private  String isDisp;
    private  String isDel;
    private Timestamp regDate;
    private Timestamp upDate;
    private  String unit;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        MstTreatmentStatusDispItem that = (MstTreatmentStatusDispItem) o;
        return Objects.equals(itemCd, that.itemCd) && Objects.equals(dataClass, that.dataClass) && Objects.equals(machineClass, that.machineClass) && Objects.equals(itemName, that.itemName) && Objects.equals(tableName, that.tableName) && Objects.equals(fieldName, that.fieldName) && Objects.equals(jsonKeyName, that.jsonKeyName) && Objects.equals(dispOrder, that.dispOrder) && Objects.equals(isDisp, that.isDisp) && Objects.equals(isDel, that.isDel) && Objects.equals(regDate, that.regDate) && Objects.equals(upDate, that.upDate) && Objects.equals(unit, that.unit);
    }

    @Override
    public int hashCode() {
        return Objects.hash(itemCd, dataClass, machineClass, itemName, tableName, fieldName, jsonKeyName, dispOrder, isDisp, isDel, regDate, upDate, unit);
    }
}
