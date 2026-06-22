using System.Collections.Generic;
using System.Runtime.InteropServices;

namespace CoopExtractXMLMaker
{
    public static class Commons
    {
        /// <summary>
        /// このアプリケーションの名前
        /// </summary>
        public static string AppName;

        /// <summary>
        /// 戻り値：正常
        /// </summary>
        public const int RetCode_Success = 1;

        /// <summary>
        /// 戻り値：ファイルなし
        /// </summary>
        public const int RetCode_Nothing = 0;

        /// <summary>
        /// 戻り値：エラー
        /// </summary>
        public const int RetCode_Error = -1;

        /// <summary>
        /// 文字列比較（数値を数値として比較を行う）
        /// </summary>
        /// <param name="x"></param>
        /// <param name="y"></param>
        /// <returns></returns>
        [DllImport("shlwapi.dll", CharSet = CharSet.Unicode)]
        public static extern int StrCmpLogicalW(string x, string y);

        /// <summary>
        /// key1マッピング処理
        /// </summary>
        /// <param name="strkey1"></param>
        /// <param name="strINI_SECTION"></param>
        /// <param name="isFirst">最初のXMLからのkey1マッチングか</param>
        /// <param name="isInsert">既にあるkey1への追加か</param>
        public static void key1Func(string strkey1, string strINI_SECTION, bool isFirst, bool isInsert)
        {
            List<ConversionDataItem> tempList = new List<ConversionDataItem>();

            bool isAddSectionItem = false;
            int firstFindPos = -1;   // 最初にINI_SECTIONを発見した位置
            for (int i = ConversionFNWDataManager.ConversionFNWDataList.Count - 1; i >= 0; i--)
            {
                if (ConversionFNWDataManager.ConversionFNWDataList[i].INI_SECTION != strINI_SECTION)
                {
                    continue;
                }

                bool key1Find = false;
                int j;
                for (j = 0; j < ConversionDataManager.ConversionDataList.Count; j++)
                {
                    if (ConversionDataManager.ConversionDataList[j].key1 != strkey1)
                    {
                        continue;
                    }

                    key1Find = true;

                    if (firstFindPos == -1)
                    {
                        // 最初にINI_SECTIONを発見した位置を覚えておく
                        firstFindPos = j;
                    }

                    if (ConversionFNWDataManager.ConversionFNWDataList[i].INI_KEY ==
                        ConversionDataManager.ConversionDataList[j].key2)
                    {
                        break;
                    }
                }

                if (key1Find == false) continue;

                ConversionFNWDataItem fnwItem = ConversionFNWDataManager.ConversionFNWDataList[i];

                if (isFirst == true)
                {
                    // 初回は個別に除外されている可能性もあるのでチェックする

                    // 除外設定があるか取得する
                    var wkItem = MappingSettingManager.GetExcludeIndividualItem(fnwItem.INI_SECTION, fnwItem.INI_KEY, true);
                    if (wkItem != null)
                    {
                        // 除外設定があるのでマッピングしない
                        continue;
                    }
                }

                if (j < ConversionDataManager.ConversionDataList.Count)
                {
                    // key1とkey2が同じデータを発見
                    ConversionDataItem fnsiItem = ConversionDataManager.ConversionDataList[j];

                    fnsiItem.ConvTarget = "key1";
                    fnsiItem.INI_SECTION = fnwItem.INI_SECTION;
                    fnsiItem.INI_KEY = fnwItem.INI_KEY;
                    fnsiItem.INI_VALUE = fnwItem.INI_VALUE;
                    fnsiItem.DEFAULT_VALUE = fnwItem.DEFAULT_VALUE;
                    fnsiItem.KEY_TITLE = fnwItem.KEY_TITLE;
                    fnsiItem.MEMO = fnwItem.MEMO;
                    fnsiItem.FnwPos = fnwItem.FnwPos;
                    fnsiItem.Is_TempAdd = false;
                    ConversionFNWDataManager.ConversionFNWDataList.Remove(fnwItem);
                }
                else
                {
                    // key1は発見できたがkey2が同じデータが見つからなかった場合

                    ConversionDataItem addItem = new ConversionDataItem();

                    addItem.ConvTarget = "key1";
                    addItem.key1 = strkey1;
                    addItem.key2 = fnwItem.INI_KEY;
                    addItem.INI_SECTION = fnwItem.INI_SECTION;
                    addItem.INI_KEY = fnwItem.INI_KEY;
                    addItem.INI_VALUE = fnwItem.INI_VALUE;
                    addItem.DEFAULT_VALUE = fnwItem.DEFAULT_VALUE;
                    addItem.KEY_TITLE = fnwItem.KEY_TITLE;
                    addItem.MEMO = fnwItem.MEMO;
                    addItem.FnwPos = fnwItem.FnwPos;
                    addItem.Is_TempAdd = true;  // 相手のkey2無しで追加する
                    tempList.Add(addItem);

                    ConversionFNWDataManager.ConversionFNWDataList.Remove(fnwItem);
                }

                if (isFirst == false && isAddSectionItem == false && isInsert == false)
                {
                    Item addItem = new Item();
                    addItem.INI_SECTION = fnwItem.INI_SECTION;
                    addItem.INI_KEY = null;
                    addItem.Key1 = strkey1;
                    addItem.Key2 = null;
                    addItem.PublicList = null;
                    addItem.LocalList = null;
                    MappingSettingManager.AddSectionItem(addItem);

                    isAddSectionItem = true;
                }
            }

            // 新規追加行があれば位置を考慮しつつ行を差し込む
            if (tempList.Count > 0)
            {
                for (int i = 0; i < tempList.Count; i++)
                {
                    int j;
                    bool isSet = false;
                    for (j = firstFindPos; j < ConversionDataManager.ConversionDataList.Count; j++)
                    {
                        if (ConversionDataManager.ConversionDataList[j].key1 != tempList[i].key1)
                        {
                            break;
                        }

                        if (string.Compare(tempList[i].INI_KEY, ConversionDataManager.ConversionDataList[j].key2) < 0)
                        {
                            ConversionDataManager.ConversionDataList.Insert(j, tempList[i]);
                            //dgvIncludeView.Rows[0].Cells["To"].Style.SelectionForeColor = Color.Red;
                            isSet = true;
                            break;
                        }
                    }

                    if (isSet == false)
                    {
                        ConversionDataManager.ConversionDataList.Insert(j, tempList[i]);

                    }
                }
            }
        }
    }
}
