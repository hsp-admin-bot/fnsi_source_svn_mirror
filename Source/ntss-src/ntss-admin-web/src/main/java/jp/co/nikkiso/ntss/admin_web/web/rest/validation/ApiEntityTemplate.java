package jp.co.nikkiso.ntss.admin_web.web.rest.validation;

import jakarta.validation.constraints.Pattern;

import jakarta.validation.constraints.NotBlank;

import lombok.Data;

public class ApiEntityTemplate {

    @Data
    public static class ValiTreatAndKurDataFromDB {
      @NotBlank
      @Pattern(regexp = "^[0-9]+")
      public String ord_no ;
      @NotBlank
      @Pattern(regexp = "^[0-9]+")
      public String pat_id ;
      @NotBlank
      @Pattern(regexp = "^[0-9]+")
      public String facility_cd ;
      @NotBlank
      @Pattern(regexp = "^[0-9]{4}-[0-9]{2}-[0-9]{2}")
      public String dialysis_date ;
    }
    
    @Data
    public static class SendHistoryDataSet {
      public String logdata ;
    }

}