package batch.reader;

import org.springframework.batch.infrastructure.item.file.FlatFileItemReader;
import org.springframework.batch.infrastructure.item.file.mapping.PassThroughLineMapper;
import org.springframework.core.io.FileSystemResource;

/**
 * プレーンテキストファイルを１行ずつ読み込むReader
 */
public class FlatFileLineReader extends FlatFileItemReader<String>{

    /**
     * コンストラクタ
     * 
     * @param readFilePath 読み込むファイルをフルパスで指定
     * @param encode        読み込むファイルの文字コードを指定 encode指定例： ・Windows-31j ・UTF-8
     *                      ・java.nio.charset.StandardCharsetsに定義されているもの
     */
    public FlatFileLineReader(String readFilePath, String encode){
        super(new PassThroughLineMapper());
        this.setSaveState(false);
        this.setResource(new FileSystemResource(readFilePath));
        this.setEncoding(encode);
    }
}