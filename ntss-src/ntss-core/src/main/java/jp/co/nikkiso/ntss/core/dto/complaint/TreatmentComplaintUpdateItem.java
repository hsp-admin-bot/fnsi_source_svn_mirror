package jp.co.nikkiso.ntss.core.dto.complaint;

import lombok.Data;
import org.apache.commons.lang3.StringUtils;
import org.springframework.util.ObjectUtils;

import java.math.BigDecimal;

@Data
public class TreatmentComplaintUpdateItem {
  private String ctl_no;
  private String itemIdx;
  private String treat_class;
  private String occur_date;
  private String complaint;
  private String treat_name;
  private String medicine_cd;
  private String amount;
  private String procedure_cd;
  private String medicine_type;
  private String treat_staff_cd;

  private String oxygen_start;
  private String oxygen_time;
  private String oxygen_amount;
  private String oxygen_speed;

  private String electrocardiogram_type;
  private String electrocardiogram_start;

  private String linkStartDate;

  @Override
  public boolean equals(Object obj) {

    if (this == obj) return true;
    if (obj == null || getClass() != obj.getClass()) return false;

    TreatmentComplaintUpdateItem item = (TreatmentComplaintUpdateItem) obj;

    return ObjectUtils.nullSafeEquals(ctl_no, item.ctl_no)
      && ObjectUtils.nullSafeEquals(occur_date, item.occur_date)
      && ObjectUtils.nullSafeEquals(complaint, item.complaint)
      && ObjectUtils.nullSafeEquals(treat_name, item.treat_name)
      && ObjectUtils.nullSafeEquals(medicine_cd, item.medicine_cd)
      && convertStringToBigDecimal(amount).compareTo(convertStringToBigDecimal(item.amount)) == 0
      && ObjectUtils.nullSafeEquals(procedure_cd, item.procedure_cd)
      && ObjectUtils.nullSafeEquals(medicine_type, item.medicine_type)
      && ObjectUtils.nullSafeEquals(treat_staff_cd, item.treat_staff_cd)
      && ObjectUtils.nullSafeEquals(oxygen_start, item.oxygen_start)
      && ObjectUtils.nullSafeEquals(oxygen_time, item.oxygen_time)
      && convertStringToBigDecimal(oxygen_amount).compareTo(convertStringToBigDecimal(item.oxygen_amount)) == 0
      && convertStringToBigDecimal(oxygen_speed).compareTo(convertStringToBigDecimal(item.oxygen_speed)) == 0
      && ObjectUtils.nullSafeEquals(electrocardiogram_type, item.electrocardiogram_type)
      && ObjectUtils.nullSafeEquals(electrocardiogram_start, item.electrocardiogram_start)
      && ObjectUtils.nullSafeEquals(linkStartDate, item.linkStartDate);
  }

  private BigDecimal convertStringToBigDecimal(String str) {
    return new BigDecimal(StringUtils.isEmpty(str) || "null".equals(str) ? "0" : str);
  }
}
