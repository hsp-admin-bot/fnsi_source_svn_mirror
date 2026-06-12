package com.fnsi.cloudconverter.clear.online.file;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.file.*;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.List;

@Slf4j
@Service
public class OnlineFileClearServiceImpl implements OnlineFileClearService {

    @Override
    public void clearFacilityFiles(List<String> facilityCodes, Path efsRootPath) {
        for (String code : facilityCodes) {
            Path facilityDir = efsRootPath.resolve(code);
            if (Files.exists(facilityDir)) {
                deleteRecursively(facilityDir);
                log.info("[CLEAR_ONLINE_FILE] 削除: {}", facilityDir);
            }
        }
    }

    private void deleteRecursively(Path dir) {
        try {
            Files.walkFileTree(dir, new SimpleFileVisitor<>() {
                @Override
                public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) throws IOException {
                    Files.delete(file);
                    return FileVisitResult.CONTINUE;
                }
                @Override
                public FileVisitResult postVisitDirectory(Path d, IOException exc) throws IOException {
                    Files.delete(d);
                    return FileVisitResult.CONTINUE;
                }
            });
        } catch (IOException e) {
            log.warn("[CLEAR_ONLINE_FILE] 削除失敗: {}", dir, e);
        }
    }
}
