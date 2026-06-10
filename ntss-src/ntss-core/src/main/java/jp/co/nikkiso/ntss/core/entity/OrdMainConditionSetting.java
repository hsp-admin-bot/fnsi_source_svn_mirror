package jp.co.nikkiso.ntss.core.entity;

import lombok.Data;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import java.io.Serializable;

/**
 * @className: OrdMainConditionSetting
 * @author: kangjie
 * @date: 2024/05/21 13:44
 * @Version: 1.0
 * @description: 9664 add conditionSetting result
 */
@Entity( naming = NamingType.SNAKE_LOWER_CASE)
@Data
public class OrdMainConditionSetting implements Serializable {

  private String treatmentConditionSetting;

  private Integer indDeviceMode;

}
