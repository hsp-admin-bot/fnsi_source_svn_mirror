package com.fnsi.cloudconverter.clear.online.file;

import java.nio.file.Path;
import java.util.List;

/** 在線生産ファイル削除 (Module 21) */
public interface OnlineFileClearService {
    void clearFacilityFiles(List<String> facilityCodes, Path efsRootPath);
}
