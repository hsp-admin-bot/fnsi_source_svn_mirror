package jp.co.nikkiso.ntss.admin_web.response.bvms.dto;

import java.math.BigDecimal;

import jakarta.validation.constraints.NotNull;

import lombok.Data;

@Data
public class RRGraphInputDTO {
    @NotNull
    private BigDecimal graphY1From;
    @NotNull
    private BigDecimal graphY1To;

}