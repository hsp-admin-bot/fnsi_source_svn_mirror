package jp.co.nikkiso.ntss.admin_web.response.bvms.dto;

import java.math.BigDecimal;

import javax.validation.constraints.NotNull;

import lombok.Data;

@Data
public class BVMSFilterDTO{

    @NotNull
    private BigDecimal graph1Y1From;
    @NotNull
    private BigDecimal graph1Y1To;
    
    @NotNull
    private BigDecimal graph1Y2From;
    @NotNull
    private BigDecimal graph1Y2To;

    @NotNull
    private BigDecimal graph2Y1From;
    @NotNull
    private BigDecimal graph2Y1To;
    
    @NotNull
    private BigDecimal graph2Y2From;
    @NotNull
    private BigDecimal graph2Y2To;
    
    /**
     * 印刷先プリンタ.
     */
    private Long targetPrinter;

    /**
     * PDF格納先パス(Amazon S3).
     */
    private String pdfPath;
}