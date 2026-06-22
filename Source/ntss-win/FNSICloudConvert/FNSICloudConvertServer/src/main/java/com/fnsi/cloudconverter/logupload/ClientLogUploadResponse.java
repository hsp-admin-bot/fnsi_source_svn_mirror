package com.fnsi.cloudconverter.logupload;

public record ClientLogUploadResponse(
        boolean success,
        String path,
        String message
) {
}
