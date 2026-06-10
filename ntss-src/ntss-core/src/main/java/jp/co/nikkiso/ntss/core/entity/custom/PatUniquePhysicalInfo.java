package jp.co.nikkiso.ntss.core.entity.custom;

import java.sql.Timestamp;

import org.seasar.doma.Entity;

import com.fasterxml.jackson.annotation.JsonFormat;

import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import lombok.Data;

@Entity
@Data
public class PatUniquePhysicalInfo {
  private String dw;
  private String ctr;
  private String memo;
  private Integer ctl_no;
  private String height;
  private String chest_dia;

  @JsonFormat(pattern = CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601, timezone = CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO)
  private Timestamp exam_date;

  private String breast_dia;
  private String ctr_weight;
  private Integer order_class;
  private Integer indicator_cd;
  private String target_weight;
  private String pre_scale_lower;
  private String pre_scale_upper;
  private String indicator_start_date;
  //add #9507 zrx start
  private Integer changer_cd;
  //add #9507 zrx end
}
