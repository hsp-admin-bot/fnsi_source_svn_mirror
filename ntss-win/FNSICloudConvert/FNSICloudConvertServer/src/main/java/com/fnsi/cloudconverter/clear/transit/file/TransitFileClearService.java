package com.fnsi.cloudconverter.clear.transit.file;

import java.nio.file.Path;
import java.util.List;

/** 中転ファイル削除 (Module 22) */
public interface TransitFileClearService {
    void clearFacilityFiles(List<String> facilityCodes, Path transitFilePath);
}
