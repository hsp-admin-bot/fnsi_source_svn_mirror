package jp.co.nikkiso.ntss.core.entity.custom;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.databind.PropertyNamingStrategy;
import com.fasterxml.jackson.databind.annotation.JsonNaming;

import lombok.Data;

@Data
@JsonNaming(PropertyNamingStrategy.SnakeCaseStrategy.class)
public class ReloopInfo {
    @JsonProperty("bio_moni_ctl_no")
    private Long bioMoniCtlNo;
    @JsonProperty("reloop_comment")
    private String reloopComment;
}
