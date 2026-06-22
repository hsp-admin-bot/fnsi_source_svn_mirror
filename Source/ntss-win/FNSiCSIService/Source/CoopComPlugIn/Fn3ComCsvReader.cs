///////////////////////////////////////////////////////////////////////////////
//
// システム名：FutureNetⅢ
// 機能名    ：CSV入力機能
// ファイル名：Fn3ComCsvReader.cs
// 説明      ：CSV入力機能を提供する
//
//	Copyright(C) 2014 NIKKISO CO., LTD. All Rights Reserved 
//
// 更新履歴
//	日付		担当				理由
//	2014/09/05	阿部 浩幸			新規作成
//
///////////////////////////////////////////////////////////////////////////////
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace jp.co.nikkiso.fn3.Cooperation.CoopComPlugIn
{
    /// <summary>
    /// CSV入力(受信)クラス
    /// </summary>
    public class Fn3ComCsvReader : IDisposable
    {
        #region メンバ変数
        /// <summary>ファイルパス</summary>
        private string _path;
        /// <summary>文字エンコーディンング</summary>
        private Encoding _encoding;
        /// <summary>StreamReaderクラス</summary>
        private StreamReader _streamReader;
        
        /// <summary>項目数</summary>
        private int _itemCount;

        #endregion

        #region プロパティ
        /// <summary>
        /// CSVファイルから取得したデータの項目数を取得します。
        /// </summary>  
        public int ItemCount
        {
            get
            {
                return _itemCount;
            }
        }

        /// <summary>
        /// 次に読み込む文字があるかどうかを取得します。
        /// あればtrue、なければfalse
        /// </summary>  
        public bool ExistNextData
        {
            get
            {
                return this.ExistNextReadData();
            }
        }

        #endregion

        #region 公開メソッド
        /// <summary>
        /// CSVファイルから１行分の文字を読み込み、カンマを削除して文字列で返します。
        /// ex) a,b,c ⇒ abc
        /// ★while文でExistNextDataがtrueの間を指定すると全行の取得が可能です。
        /// </summary>
        /// <returns>１行分の文字列(カンマを削除、スペースはそのまま)</returns>
        public string ReadLineString()
        {
            StringBuilder sb = new StringBuilder();
            string readLine = "";
            int itemCount = 0; // 要素数

            if (_streamReader.Peek() > -1)
            {
                // 1行取得
                readLine = _streamReader.ReadLine();
            }
            
            // カンマで分割
            string[] itemList = readLine.Split(',');

            string txt = "";
            for (int cnt = 0; cnt < itemList.Length; cnt++)
            {
                txt = txt + itemList[cnt]; // 取り込みデータの','分割文字列を保存

                // '"'で開始している場合は'"'で終了するまでデータを結合する
                if (txt.StartsWith("\""))
                {
                    if (txt.EndsWith("\""))
                    {
                        // '"'で開始 '"'で終了
                        int txtLength = txt.Length - 2;
                        // 前後'"'を削除する
                        txt = txt.Substring(1, txtLength);
                    }
                    else
                    {
                        // Split()で取り除かれたカンマを付加
                        txt = txt + ",";
                        continue;
                    }
                }

                // 取得文字列に連結
                sb.Append(txt);
                itemCount++;
                txt = "";
            }

            _itemCount = itemCount;

            return sb.ToString();
        }

        /// <summary>
        /// CSVファイルから１行分の文字を読み込み、カンマで分割してリストに格納して返します。
        /// ex) a,b,c ⇒ List[0] = a、List[1] = b、List[2] = c 
        /// ★while文でExistNextDataがtrueの間を指定すると全行の取得が可能です。
        /// </summary>
        /// <returns>CSV１行データリスト(リスト1要素＝CSV１行の１項目)</returns>
        public List<string> ReadLineList()
        {
            List<string> lstRet = new List<string>();
            string readLine = "";
            int itemCount = 0; // 要素数

            if (_streamReader.Peek() > -1)
            {
                // 1行取得
                readLine = _streamReader.ReadLine();
            }

            // カンマで分割
            string[] itemList = readLine.Split(',');

            string txt = "";
            for (int cnt = 0; cnt < itemList.Length; cnt++)
            {
                txt = txt + itemList[cnt]; // 取り込みデータの','分割文字列を保存

                // '"'で開始している場合は'"'で終了するまでデータを結合する
                if (txt.StartsWith("\""))
                {
                    if (txt.EndsWith("\""))
                    {
                        // '"'で開始 '"'で終了
                        int txtLength = txt.Length - 2;
                        // 前後'"'を削除する
                        txt = txt.Substring(1, txtLength);
                    }
                    else
                    {
                        // Split()で取り除かれたカンマを付加
                        txt = txt + ",";
                        continue;
                    }
                }

                // リストに追加
                lstRet.Add(txt);
                itemCount++;
                txt = "";
            }

            _itemCount = itemCount;

            return lstRet;
        }

        ///// <summary>
        ///// CSVファイルから全行の文字を読み込み、カンマを削除して１行ずつリストに格納して返します。
        ///// Dictionaryのkyeに文字列、valueに要素数を格納します。
        ///// ★★プロパティのSizeを使用しても0が返るので注意★★
        ///// </summary>
        ///// <returns>CSV全行データリスト(リスト1要素＝CSV１行)</returns>
        //public Dictionary<string, int> ReadAllLineDictionary()
        //{
        //    Dictionary<string, int> dicRet = new Dictionary<string, int>();
        //    string line = "";

        //    while (this.ExistNextReadData())
        //    {
        //        // 1行読み込んでリストに格納(内容が全く同じなら格納しない)
        //        line = this.ReadLineString();
        //        if (!dicRet.ContainsKey(line))
        //        {
        //            dicRet.Add(line, this._itemCount);
        //        }
        //    }

        //    return dicRet;
        //}

        /// <summary>
        /// 次に読み込む文字があるかどうかを確認する。
        /// </summary>
        /// <returns>読み取り対象の次の文字があればtrue、なければfalse</returns>
        private bool ExistNextReadData()
        {
            if (_streamReader.Peek() > -1)
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        #endregion

        #region コンストラクタ
        /// <summary>
        /// 文字エンコーディングを設定して、指定したファイル名用のFn3ComCsvReaderクラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="path">指定ファイルパス</param>
        /// <param name="encoding">文字エンコーディング</param>
        public Fn3ComCsvReader(string path, Encoding encoding)
        {
            _path = path;
            _encoding = encoding;
            _streamReader = new StreamReader(_path, _encoding);

            _itemCount = 0;
        }

        #endregion

        #region IDisposable メンバ
        /// <summary>
        /// リソースを解放します。
        /// </summary>
        void IDisposable.Dispose()
        {
            _streamReader.Dispose();
        }

        #endregion
    }
}
