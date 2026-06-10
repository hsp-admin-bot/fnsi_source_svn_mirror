using System;
using System.Diagnostics;
using System.Text;

namespace NKSConverter
{
    internal class EnvironmentVariableDelete
    {
        private string Path;

        public EnvironmentVariableDelete(string path) {
            // インストールパスの取得
            this.Path = path.TrimEnd('\\'); 
        }

        /// <summary>
        /// インストールの時設定の環境変数の削除
        /// </summary>
        public void Delete() {

            if (string.IsNullOrEmpty(Path)) {
                return;
            }
            else
            {
                this.OracleDel();
                this.Path = this.Path + "\\oracle_Client";
            }

            // 環境変数変更後の文字列
            StringBuilder outEveironment = new StringBuilder();

            // 環境変数の取得
            string environment = Environment.GetEnvironmentVariable("Path", EnvironmentVariableTarget.Machine);
            if (!string.IsNullOrEmpty(environment))
            {
                string[] pathList = environment.Split(';');
                foreach (string path in pathList)
                {
                    // 環境変数中の、インストールのOracle Clientを削除する
                    if (this.Path.Equals(path))
                    {
                        continue;
                    }
                    outEveironment.Append(path);
                    if (!path.Equals(pathList[pathList.Length - 1])) {
                        outEveironment.Append(";");
                    }
                }
            }

            // 環境変数の設定
            System.Environment.SetEnvironmentVariable("Path", outEveironment.ToString(), EnvironmentVariableTarget.Machine);
        }

        private string OracleDel()
        {

            string datPath = Path + "\\Tools\\環境構築\\01_FNW(移行元)環境用スクリプト";
            // CMDを使用し、データコンバート環境構築.batを実行する
            Process process = new Process();
            process.StartInfo.FileName = "cmd.exe";
            process.StartInfo.Arguments = $"/c cd {datPath} && データコンバート環境構築削除.bat";
            process.StartInfo.UseShellExecute = false;
            process.StartInfo.RedirectStandardError = true;
            process.StartInfo.CreateNoWindow = true;
            process.Start();

            string ourErr = process.StandardError.ReadToEnd();

            process.WaitForExit();

            return ourErr;
        }
    }
}
