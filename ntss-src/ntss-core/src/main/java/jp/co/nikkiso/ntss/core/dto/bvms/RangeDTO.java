package jp.co.nikkiso.ntss.core.dto.bvms;

import java.math.BigDecimal;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class RangeDTO {
    private BigDecimal before;
    private BigDecimal after;
}
