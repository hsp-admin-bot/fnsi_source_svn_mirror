package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class OrdMainUptSchInfoVo{

  private Long ordNo;

  private Long indKurCd;

  private String indKurName;

  private String indTreatStartTime;

  private Long indBedCd;

  private String indBedName;

  private Long indUserId;

  private Long updUserid;

  private Integer updateMode;

  private String indUserLastName;

  private String indUserFirstName;

  private boolean rstUpdFlg;
}


