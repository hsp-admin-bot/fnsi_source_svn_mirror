package com.fnsi.cloudconverter.system.model;

public record SystemInfoResponse(
        String converterDbHost,
        int converterDbPort
) {}
