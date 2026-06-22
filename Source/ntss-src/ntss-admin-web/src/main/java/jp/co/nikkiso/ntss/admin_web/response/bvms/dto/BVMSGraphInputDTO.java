package jp.co.nikkiso.ntss.admin_web.response.bvms.dto;

import java.math.BigDecimal;

import jakarta.validation.constraints.NotNull;

import lombok.Data;

@Data
public class BVMSGraphInputDTO{

    @NotNull
    private BigDecimal graph1Y1From;
    @NotNull
    private BigDecimal graph1Y1To;

    @NotNull
    private BigDecimal graph2Y1From;
    @NotNull
    private BigDecimal graph2Y1To;
}