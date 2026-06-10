package batch.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;

import java.sql.Timestamp;
import java.util.Objects;

@Entity
@Table(name = "sys_monitor_item")
@Getter
@Setter
public class SysMonitorItem extends BaseBlankEntity{
    private  String moniDataNo;
    private  String  moniDataType;
    private  String moniDataName;
    private  String moniDataShortName;
    private Double  dataType;
    private Double decimalFigure;
    private  String unit;
   private Double upper;
    private Double  lower;
    private  String isDisp;
    private  String vitalMonitorClass;
    private String convItem;
    private Timestamp regDate;
    private Timestamp upDate;
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        SysMonitorItem that = (SysMonitorItem) o;
        return Objects.equals(moniDataNo, that.moniDataNo) && Objects.equals(moniDataType, that.moniDataType) && Objects.equals(moniDataName, that.moniDataName) && Objects.equals(moniDataShortName, that.moniDataShortName) && Objects.equals(dataType, that.dataType) && Objects.equals(decimalFigure, that.decimalFigure) && Objects.equals(unit, that.unit) && Objects.equals(upper, that.upper) && Objects.equals(lower, that.lower) && Objects.equals(isDisp, that.isDisp) && Objects.equals(vitalMonitorClass, that.vitalMonitorClass) && Objects.equals(convItem, that.convItem) && Objects.equals(regDate, that.regDate) && Objects.equals(upDate, that.upDate);
    }

    @Override
    public int hashCode() {
        return Objects.hash(moniDataNo, moniDataType, moniDataName, moniDataShortName, dataType, decimalFigure, unit, upper, lower, isDisp, vitalMonitorClass, convItem, regDate, upDate);
    }
}
