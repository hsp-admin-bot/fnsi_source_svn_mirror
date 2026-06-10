using System;
using System.Collections.Generic;
using System.IO;

namespace NKK.BloodPurify
{
    /// <summary>
    /// モニタ項目における[アドレス/名称/小数点桁数/単位/書式整形定義文字列]の定義
    /// </summary>
    public class NkkMonDefine
    {
        /// <summary>定義リスト</summary>
        public List<(int addr, string name, int decimalFigure, string unit, string formattingString)> Items = new List<(int, string, int, string, string)>();
        /// <summary>設定ファイルからモニタ項目をロードできたかどうか</summary>
        public bool IsLoadingSuccess = true;

        public NkkMonDefine()
        {
            LoadFromFile();
        }

        /// <summary>
        /// 設定ファイルからモニタ項目をロードする
        /// </summary>
        private void LoadFromFile()
        {
            try
            {
                string[] readLines = File.ReadAllLines(AppCmn.GetExeDir(true) + "nkkMonDefine.txt");

                string[] split;
                for (int i = 0; i < readLines.Length; i++)
                {
                    split = readLines[i].Split('\t');

                    (int addr, string name, int decimalFigure, string unit, string formattingString) one;

                    // 0:アドレス(0ベース) \t 1:モニタ名称 \t 2:小数点以下桁数 \t 3:単位
                    one.addr = int.Parse(split[0]);
                    one.name = split[1];
                    one.decimalFigure = int.Parse(split[2]);
                    one.unit = split[3];

                    if (0 >= one.decimalFigure)
                    {
                        // 小数点桁数が[0]や[マイナス値(※通常ありえない)]の場合は[0]
                        one.formattingString = "0";
                    }
                    else
                    {
                        // [0.0…]形式の書式整形定義文字列を作成
                        one.formattingString = "0.";
                        for (int j = 0; j < one.decimalFigure; j++)
                        {
                            one.formattingString += "0";
                        }
                    }

                    Items.Add(one);
                }
            }
            catch (Exception ex)
            {
                IsLoadingSuccess = false;

                MyLog.AddLogInfo(this, "", ex);
            }
        }

        /// <summary>
        /// アドレス(0ベース)で定義を取得
        /// </summary>
        /// <param name="argAddr"></param>
        /// <returns></returns>
        public (int addr, string name, int decimalFigure, string unit, string formattingString) GetByAddr(int argAddr)
        {
            foreach (var one in Items)
            {
                if (argAddr == one.addr)
                {
                    return one;
                }
            }

            return (-1, "", 0, "", "0");
        }
    }
}