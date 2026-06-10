package jp.co.nikkiso.ntss.admin_web.response.bvms.dto;

import java.math.BigDecimal;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CoordinateDTO {
    private BigDecimal yAxis;
    private long xAxis;
}
