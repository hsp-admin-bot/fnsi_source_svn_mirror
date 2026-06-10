package batch.part;

import lombok.extern.slf4j.Slf4j;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.function.BiPredicate;
import java.util.stream.Collectors;

/**
 * ファイル・フォルダを検索するクラス
 */
@Slf4j
public class FileVisitor{

    /**
     * ディレクトリ内を再帰的に検索し、SQLファイルパスの文字列リストを返す
     * @param startDir 開始ディレクトリ
     * @return SQLファイルパスのリスト
     * @throws IOException
     */
    public static List<String> getSqlFileList(String startDir) throws IOException {
        //すべてのsqlファイル集合を取得
        List<String> retSql = getFileList(startDir, "sql");
        //scvファイル合計の取得
        List<String> retCsv = getFileList(startDir, "csv");
        //sqlファイルとcsvファイルを集合処理する
        retSql.addAll(retCsv);
        return retSql;
    }

    /**
     * ディレクトリ内を再帰的に検索し、Zipファイルパスの文字列リストを返す
     * @param startDir 開始ディレクトリ
     * @return Zipファイルパスのリスト
     * @throws IOException
     */
    public static List<String> getZipFileList(String startDir) throws IOException {
        List<String> ret = getFileList(startDir, "zip");
        return ret;
    }

    /**
     * 再帰的にフォルダ検索し、ファイルリストを返す
     * @param startDir 開始ディレクトリ
     * @param extension 拡張子
     * @return ファイルリスト
     * @throws IOException
     */
    private static List<String> getFileList(String startDir, String extension)  throws IOException
    {
        // パス文字列をPathオブジェクトに変換
        Path startDirPath = Paths.get(startDir);
        // インターフェースの実装
        BiPredicate<Path, BasicFileAttributes> matcher = (path, attr) -> {
            if (extension==null || extension.isEmpty()) {
                if (attr.isRegularFile()) {
                    // 拡張子が設定されていない場合は拡張子での絞り込みを行わない
                    return true;
                }
            } else {
                if (attr.isRegularFile() && path.getFileName().toString().endsWith("." + extension)) {
                    return true;
                }
            }
            return false;
        };
        // ディレクトリを再帰的に検索し、パス文字列のリストで返す
        List<String> ret = Files.find(startDirPath, Integer.MAX_VALUE, matcher)
            .map(file -> file.toAbsolutePath().toString())
            .collect(Collectors.toList());
        ret.forEach(log::debug);
        return ret;
    }

    /**
     * ディレクトリを再帰的に検索し、該当の拡張子のファイルが存在するか返す
     * @param startDir 開始ディレクトリ
     * @return true:存在 false:存在しない
     * @throws IOException
     */
    public static boolean isFileExists(String startDir, String extension) throws IOException{
        List<String> sqlFileList = getFileList(startDir,extension);
        if (sqlFileList.isEmpty()) {
            return false;
        } else {
            return true;
        }
    }

    public static boolean isFileExists(Path startDir, String extension) throws IOException{
        return isFileExists(startDir.toString(),extension);
    }

    /**
     * 指定されたディレクトリ内を再帰的に検索し、配下のディレクトリが空の場合、
     * 該当のディレクトリを削除する
     * @param startDir 開始ディレクトリ
     * @param extension 拡張子
     * @throws IOException
     */
    public static void deleteDirectoryIfEmpty(String startDir,String extension) throws IOException{
        // 最終文字が/でない場合、付与する
        String startDirWork = startDir;
        if(!startDir.endsWith("//")){
            startDirWork += "//";
        }
        // １階層下のディレクトリを取得する
        Path startDirPath = Paths.get(startDirWork);
        List<Path> dirList = new ArrayList<Path>();
        // ディレクトリを走査してリストへ格納
        Files.walk(startDirPath, Integer.MAX_VALUE).forEach(path -> {
            if (path.toFile().isDirectory() && path!=startDirPath) {
                dirList.add(path);
            }
        });
        // 逆順に並び替え
        dirList.sort(Comparator.reverseOrder());
        // ディレクトリ配下にファイルが存在しない場合削除
        for (Path dir : dirList) {
            if(!isFileExists(dir,extension)){
                // ファイルが存在しない場合削除
                dir.toFile().delete();
            }
        }
    }

    /**
     * ファイルを読み込み、注釈内容が含まれているか否かを判断する
     * @param filePath ファイルパス
     * @throws IOException
     **/
    public boolean readFileLineAndCheckAnnotation(String filePath) {
        //mod #9862 close stream 2023-10-27 liushengnan start
        String line = null;
        boolean checkState = false;
        try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(filePath), StandardCharsets.UTF_8))){
            while ((line = br.readLine()) != null) {
                String strBefore = line.substring(0, 2);
                if(strBefore.equals("--")) {
                    checkState = true;
                    break;
                }
            }
            if(checkState) {
                return true;
            }
            return false;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
        //mod #9862 close stream 2023-10-27 liushengnan end
    }
}