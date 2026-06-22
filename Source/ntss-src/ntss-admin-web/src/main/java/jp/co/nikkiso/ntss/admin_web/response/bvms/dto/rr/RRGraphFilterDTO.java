package jp.co.nikkiso.ntss.admin_web.response.bvms.dto.rr;

import java.math.BigDecimal;

import jakarta.validation.constraints.NotNull;

import lombok.Data;

@Data
public class RRGraphFilterDTO {
    @NotNull
    private BigDecimal graphY1From;
    @NotNull
    private BigDecimal graphY1To;
    
    private BigDecimal graphY2From;
    private BigDecimal graphY2To;
    
    /**
     * 印刷先プリンタ.
     */
    private Long targetPrinter;

    /**
     * PDF格納先パス(Amazon S3).
     */
    private String pdfPath;

}