using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesignerUtilityLib
{
    /// <summary>
    /// 帳票レイアウトデザイナー用定数クラス
    /// </summary>
    public class LayoutDesignerConstant
    {
        /// <summary>
        /// アプリケーションサンプルレイアウトファイル保存先ディレクトリ名
        /// </summary>
        internal const String DIR_NAME_MODEL_FILES = "Model";
        /// <summary>
        /// アプリケーション一時帳票保存先ディレクトリ名
        /// </summary>
        internal const String DIR_NAME_WORK_FILE = "Work";
        /// <summary>
        /// アプリケーションのログ出力先ディレクトリ名
        /// </summary>
        internal const String DIR_NAME_LOG_FILE = "Log";
        /// <summary>
        /// アプリケーションの最新バージョンファイルのダウンロード先ディレクトリ名
        /// </summary>
        internal const String DIR_NAME_UPDATE_FILES = "Update";
        /// <summary>
        /// マニュアルファイル保存先ディレクトリ名
        /// </summary>
        internal const String DIR_NAME_MANUAL_FILE = "Manual";
        /// <summary>
        /// アプリケーション設定ファイル保存先ディレクトリ名
        /// </summary>
        internal const String DIR_NAME_CONFIG_FILE = "Config";
        /// <summary>
        /// アプリケーション一時ファイル保存先ディレクトリ名
        /// </summary>
        internal const String DIR_NAME_TEMP_FILE = "Temp";
        /// <summary>
        /// 画像ファイル保存先ディレクトリ名
        /// </summary>
        internal const String DIR_NAME_IMAGE_FILE = "Image";
        /// <summary>
        /// バックアップファイル保存先ディレクトリ名
        /// </summary>
        internal const String DIR_NAME_BUCKUP_FILE = "Backup";

        /// <summary>
        /// アプリケーション共通設定ファイルのファイル名
        /// </summary>
        internal const String FILE_NAME_CONFIG_FILE = @"ReportLayoutDesigner.config";
        // add #12093 データとモデルのバージョンが書き換わらない 高 start
        /// <summary>
        /// アプリケーション共通設定ファイルのファイル名
        /// </summary>
        internal const String FILE_NAME_DATAVERSION_FILE = @"DataVersion.xml";
        // add #12093 データとモデルのバージョンが書き換わらない 高 end
        /// <summary>
        /// データ項目リストファイルのファイル名
        /// </summary>
        internal const String FILE_NAME_DATALIST_FILE = @"DataList.xml";

        // add 2023-03-13 NO5616 帳票表示項目の並び順を変更する 鵬 start
        /// <summary>
        /// データ項目ソートファイルのファイル名
        /// </summary>
        internal const String FILE_NAME_DATAORDER_FILE = @"DataOrder.xml";
        // add 2023-03-13 NO5616 鵬 end

        // add 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 start
        /// <summary>
        /// コンバート用データ項目リストファイルのファイル名
        /// </summary>
        internal const String FILE_NAME_CONVERT_DATALIST_FILE = @"ConvertDataList.xml";
        // add 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 end

        /// <summary>
        /// データ項目リストのベースファイルのファイル名
        /// </summary>
        internal const String FILE_NAME_DATALIST_BASE_FILE = @"DataListBase.xml";
        /// <summary>
        /// マスターデータファイルのファイル名
        /// </summary>
        internal const String FILE_NAME_MASTER_FILE = @"Master.xml";

        /// <summary>
        /// ログファイル識別子
        /// </summary>
        internal const String LOG_FILE_EXT = @"LayoutDesigner";
    }
}
