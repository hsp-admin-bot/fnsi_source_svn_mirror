package com.fnsi.cloudconverter.job.model;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;

import java.util.List;
import java.util.Map;

/**
 * JOB 作成リクエスト (02_api.md § 7)
 *
 * off2on: direction="off2on", facilityCodes, uploadIds 必須
 * on2off: direction="on2off", facilityCodes, seqStartMap 必須
 */
public record CreateJobRequest(
        @NotBlank String direction,
        @NotEmpty List<String> facilityCodes,
        UploadIds uploadIds,
        Map<String, Long> seqStartMap,
        JobOptions options
) {}
