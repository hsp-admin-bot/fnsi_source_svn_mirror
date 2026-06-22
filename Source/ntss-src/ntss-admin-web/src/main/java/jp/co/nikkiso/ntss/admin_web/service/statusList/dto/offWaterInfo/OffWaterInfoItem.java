package jp.co.nikkiso.ntss.admin_web.service.statusList.dto.offWaterInfo;

import java.math.BigDecimal;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 *  除水補正情報構造体.
 */
@NoArgsConstructor
@Getter
@Setter
public class OffWaterInfoItem {
  /** 項目名称 **/
  String name;
  /** 重さ **/
  BigDecimal weight;

}

