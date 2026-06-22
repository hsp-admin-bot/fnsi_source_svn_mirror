package jp.co.nikkiso.ntss.api.service.onPremise;

import jp.co.nikkiso.ntss.core.exception.NotExistException;
import org.springframework.stereotype.Service;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Timestamp;

@Service
class OnPremiseServiceImpl implements OnPremiseService {

  /**
   * {@inheritDoc}
   */
  @Override
  public byte[] getReportFile(String localStore, String filePath, Timestamp upDate) throws NotExistException {
      
      try {
        String fileLocation = localStore + "/" + filePath;
        Path path = Paths.get(fileLocation);
        byte[] bytes = null;
        bytes = Files.readAllBytes(path);
        return bytes;
      } catch (Exception e) {
        // エラーメッセージをログ出力
        throw new NotExistException(e.getMessage());
      }
  }

  /**
   * {@inheritDoc}
   * 
   * @throws IOException
   * @throws FileNotFoundException
   */
  @Override
  public void putFile(String localStore, String destFilePath, Path srcFilePath) throws IOException {
    String fileLocation = localStore + "/" + destFilePath;
    Path path = Paths.get(fileLocation);
    byte[] bytes = null;
    bytes = Files.readAllBytes(srcFilePath);
    if (!Files.exists(path)) {
      Files.createDirectories(path.getParent());
      File file = new File(path.toString());
      file.createNewFile();
    }
    Files.write(path, bytes);
  }

  @Override
  public void writeBytesToFile(String filePath, byte[] bytes) throws IOException {
    Path path = Paths.get(filePath);
    if (!Files.exists(path)) {
      Files.createDirectories(path.getParent());
      File file = new File(path.toString());
      file.createNewFile();
    }
    Files.write(path, bytes);
  }
}
