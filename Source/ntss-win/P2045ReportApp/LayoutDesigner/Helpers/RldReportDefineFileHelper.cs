using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using RldUtility = LayoutDesignerUtilityLib.LayoutDesignerUtility;

namespace LayoutDesigner
{
    /// <summary>
    /// 帳票定義ファイル操作ヘルパークラス
    /// </summary>
    internal class RldReportDefineFileHelper
    {
        #region メンバプロパティ定義

        /// <summary>
        /// 出力先ドキュメントへの参照の取得及び設定を行います。
        /// </summary>
        private System.Xml.XmlDocument XmlDoc { get; set; } = new System.Xml.XmlDocument();
        // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
        private List<string> doPassData = new List<string> { "Medicine", "Equip", "Llt", "Event", "ReceMemo", "DialDiff", "Equipment" };
        // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end

        // add #8713 帳票レイアウトデザイナーの動作指摘 DONGZHAOLONG start
        private String[] excelfunctionNames = {"SUM","MOD","IF","OR","AND","LEFT","RIGHT","MID","SUBSTITUTE","COUNTIF",
                                          "SUMIF","VALUE","VLOOKUP","HLOOKUP","INT","ABS","ROUNDUP","ROUNDDOWN","ROUND","VBRColor"};
        private String[] customfunctionNames = {"+","-","*","/"};
        // add #8713 帳票レイアウトデザイナーの動作指摘 DONGZHAOLONG start
        #endregion

        #region メンバ関数定義(公開部)

        /// <summary>
        /// 指定されたデータセットで帳票定義ファイルデータを作成します。
        /// </summary>
        /// <param name="aDataSet"></param>
        /// <returns></returns>
        public bool CreateData(LayoutDataSet aDataSet)
        {
            bool wRet = false;

            try
            {
                // XML 宣言作成
                this.XmlDoc.AppendChild(this.XmlDoc.CreateXmlDeclaration("1.0", "utf-8", "yes"));

                // ルート要素を作成して追加
                var wRootElement = this.XmlDoc.AddNewElement(RldConst.ReportDefine.TAG_ROOT);

                // 概要部を作成してルート要素に追加
                if (!(wRet = this.CreateData_Summary(wRootElement, aDataSet)))
                {
                    RldUtility.WriteLog(NKKLoggingLib.NKKLogging.LOGGING_CLASS.ERROR, @"概要部の出力時にエラーが発生しました。");
                    return wRet;
                }

                // パラメータ部を作成してルート要素に追加
                if (!(wRet = this.CreateData_Param(wRootElement, aDataSet.DesignParamList)))
                {
                    RldUtility.WriteLog(NKKLoggingLib.NKKLogging.LOGGING_CLASS.ERROR, @"パラメータ部の出力時にエラーが発生しました。");
                    return wRet;
                }

                // グループ部を作成してルード要素に追加
                // mod #8314 グループタブの表示不正 王占宇 start
                // if (!(wRet = this.CreateData_Group(wRootElement, aDataSet.DesignGroupList)))
                System.ComponentModel.BindingList<DesignGroupData> newDesignGroupList = CreateGroupMembers(aDataSet);
                if (!(wRet = this.CreateData_Group(wRootElement, newDesignGroupList)))
                // mod #8314 グループタブの表示不正 王占宇 end
                {
                    RldUtility.WriteLog(NKKLoggingLib.NKKLogging.LOGGING_CLASS.ERROR, @"グループ部の出力時にエラーが発生しました。");
                    return wRet;
                }

                // テンプレート繰り返し部を作成してルード要素に追加
                if (!(wRet = this.CreateData_Templete(wRootElement, aDataSet.DesignTempleteData)))
                {
                    RldUtility.WriteLog(NKKLoggingLib.NKKLogging.LOGGING_CLASS.ERROR, @"テンプレート繰返し部の出力時にエラーが発生しました。");
                    return wRet;
                }

                // add FNSI-523 2次元帳票対応 夏 start
                // 集計部を作成してルード要素に追加
                if (!(wRet = this.CreateData_Total(wRootElement, RldLib.totalLayoutData)))
                {
                    RldUtility.WriteLog(NKKLoggingLib.NKKLogging.LOGGING_CLASS.ERROR, @"集計部の出力時にエラーが発生しました。");
                    return wRet;
                }                
                // add FNSI-523 2次元帳票対応 夏 end

                // ここまでくればOK
                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }

            return wRet;
        }

        // add #8314 グループタブの表示不正 王占宇 start
        private class GroupNameAndTemplete
        {
            public string GroupName;
            public string IsInTemplete;
            public string IsNewPage;
            // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
            public string FilterData;
            public string FilterState;
            // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end
        }
        private System.ComponentModel.BindingList<DesignGroupData> CreateGroupMembers(LayoutDataSet aDataSet)
        {
            System.ComponentModel.BindingList<DesignGroupData> newDesignGroupDataList = new System.ComponentModel.BindingList<DesignGroupData>();
            if (aDataSet.DesignGroupList.Count > 0)
            {
                List<DesignParamData> DesignParamDatasGroupList = new List<DesignParamData>();
                Dictionary<string, string> dicGroupNameAndTemplete = new Dictionary<string, string>();
                List<GroupNameAndTemplete> strGroupNameAndTempleteList = new List<GroupNameAndTemplete>();
                foreach (var DesignGroup in aDataSet.DesignGroupList)
                {
                    GroupNameAndTemplete strGroupNameAndTemplete = new GroupNameAndTemplete();
                    strGroupNameAndTemplete.GroupName = DesignGroup.GroupName;
                    strGroupNameAndTemplete.IsInTemplete = DesignGroup.IsInTemplete;
                    strGroupNameAndTemplete.IsNewPage = DesignGroup.IsNewPage;
                    // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
                    strGroupNameAndTemplete.FilterData = DesignGroup.FilterData;
                    strGroupNameAndTemplete.FilterState = DesignGroup.FilterState;
                    // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end
                    strGroupNameAndTempleteList.Add(strGroupNameAndTemplete);
                }

                foreach (var item in strGroupNameAndTempleteList)
                {
                    foreach (var DesignParam in aDataSet.DesignParamList)
                    {
                        if (DesignParam.GroupName == item.GroupName && DesignParam.IsInTemplete == item.IsInTemplete)
                        {
                            DesignGroupData wRet = new DesignGroupData()
                            {
                                GroupPath = DesignParam.GroupPath,
                                DataCategory = DesignParam.DataCategory,
                                DataClass = DesignParam.DataClass,
                                GroupName = DesignParam.GroupName,
                                IsNewPage = item.IsNewPage,
                                ButtonEditFilterText = DesignParam.ButtonEditFilterText,
                                // mod #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
                                //FilterData = DesignParam.FilterData,
                                FilterData = item.FilterData,
                                //FilterState = DesignParam.FilterState,
                                FilterState = item.FilterState,
                                // mod #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end
                                FilterType = DesignParam.FilterType,
                                RepeatCount = DesignParam.RepeatCount,
                                IsInTemplete = DesignParam.IsInTemplete,
                                EoC = DesignParam.EoC
                            };
                            newDesignGroupDataList.Add(wRet);
                        }
                    }
                }
            }
            return newDesignGroupDataList;
        }
        // add #8314 グループタブの表示不正 王占宇 end

        /// <summary>
        /// 指定されたファイルパスに帳票定義を保存します。
        /// </summary>
        /// <param name="aXmlFilePath"></param>
        /// <returns></returns>
        public bool Save(string aXmlFilePath)
        {
            bool wRet = false;

            try
            {
                // 保存先ディレクトリの存在を確認し無ければ作成
                RldUtility.CheckAndCreateDirectory(System.IO.Path.GetDirectoryName(aXmlFilePath));

                if (this.XmlDoc != null) this.XmlDoc.Save(aXmlFilePath);

                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }

            return wRet;
        }

        #endregion

        #region メンバ関数定義(非公開部)

        /// <summary> 
        /// 帳票定義ファイルデータ(概要部)の作成を行います。
        /// </summary>
        /// <param name="aTargetElement"></param>
        /// <param name="aDataSet"></param>
        /// <returns></returns>
        private bool CreateData_Summary(System.Xml.XmlElement aTargetElement, LayoutDataSet aDataSet)
        {
            bool wRet = false;

            try
            {
                // 帳票タグ追加
                var wReportNode = this.XmlDoc.CreateElement(RldConst.ReportDefine.TAG_REPORT);

                // 帳票種別
                wReportNode.SetAttribute(RldConst.ReportDefine.ATT_REPORT_TYPE, aDataSet.DesignSettingData.ReportClass);
                // テンプレート繰り返し有無
                wReportNode.SetAttribute(RldConst.ReportDefine.ATT_REPORT_HAS_TEMPLETE, aDataSet.DesignSettingData.HasTemplete);

                // ルート要素に追加
                aTargetElement.AppendChild(wReportNode);

                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }

            return wRet;
        }

        /// <summary>
        /// 帳票定義ファイルデータ(パラメータ部)の作成を行います。
        /// </summary>
        /// <param name="aTargetElement">追加先となる親要素</param>
        /// <param name="aList"></param>
        /// <returns></returns>
        private bool CreateData_Param(System.Xml.XmlElement aTargetElement, System.ComponentModel.BindingList<DesignParamData> aList)
        {
            bool wRet = false;

            try
            {
                // パラメータテーブル追加
                var wParamsNode = this.XmlDoc.CreateElement(RldConst.ReportDefine.TAG_PARAMTABLE);

                // Excel書式文字列とJava書式文字列の変換テーブル
                JavaFormatStrings keyValues = JavaFormatStrings.GetInstance();

                // パラメータを列挙してパラメータテーブルへ追加
                foreach (var wData in aList)
                {
                    // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
                    bool inF = true;
                    if (doPassData.Contains(wData.FilterType)) {
                        inF = false;
                    }
                    // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end
                    string wSetValue = string.Empty;

                    var wElement = this.XmlDoc.CreateElement(RldConst.ReportDefine.TAG_PARAM);
                    wElement.SetAttribute(RldConst.ReportDefine.ATT_PARAM_ID, wData.CellAddress);
                    wElement.SetAttribute(RldConst.ReportDefine.ATT_PARAM_DISPTYPE, wData.IsCalcResult ? RldConst.ReportDefine.VAL_PARAM_DISPTYPE_CALC : RldConst.ReportDefine.VAL_PARAM_DISPTYPE_DATA);
                    wElement.SetAttribute(RldConst.ReportDefine.ATT_PARAM_DATACODE, wData.DataCode);
                    // add #11276 キー日付に対するデータ引き当て仕様対応 高 start
                    wElement.SetAttribute(RldConst.ReportDefine.ATT_PARAM_DATAPATH, wData.DataPath);
                    // add #11276 キー日付に対するデータ引き当て仕様対応 高 end
                    wElement.SetAttribute(RldConst.ReportDefine.ATT_PARAM_SQLCODE, wData.SqlCode);
                    wElement.SetAttribute(RldConst.ReportDefine.ATT_PARAM_DATATYPE, wData.DataType);
                    wElement.SetAttribute(RldConst.ReportDefine.ATT_PARAM_ISSHRINK, wData.IsShrink == RldConst.ParamData.VAL_ISSHRINK_DONE ? RldConst.ReportDefine.VAL_PARAM_ISSHRINK_DONE : RldConst.ReportDefine.VAL_PARAM_ISSHRINK_NONE);
                    wElement.SetAttribute(RldConst.ReportDefine.ATT_PARAM_DISPLENGTH, wData.Length);
                    //update #8489 zhu start
                    //wElement.SetAttribute(RldConst.ReportDefine.ATT_PARAM_FILTERTYPE, wData.CanEditFilter ? wData.FilterType : string.Empty);
                    wElement.SetAttribute(RldConst.ReportDefine.ATT_PARAM_FILTERTYPE, wData.FilterType);
                    //update #8489 zhu end
                    //wElement.SetAttribute(RldConst.ReportDefine.ATT_PARAM_DISPFORMAT, wData.DisplayFormat);
                    //EDTT #8394,#8566 日付時刻型のデータ項目に書式設定が反映しない 董 START
                    if (keyValues[wData.DisplayFormat] == "" && wData.DataType == "DateTime")
                    {
                        wElement.SetAttribute(RldConst.ReportDefine.ATT_PARAM_DISPFORMAT, wData.DisplayFormat);
                    }
                    else
                    {
                        wElement.SetAttribute(RldConst.ReportDefine.ATT_PARAM_DISPFORMAT, keyValues[wData.DisplayFormat]);
                    }
                    //EDIT #8394,#8566 日付時刻型のデータ項目に書式設定が反映しない 董 END
                    wElement.SetAttribute(RldConst.ReportDefine.ATT_PARAM_FORMULA, wData.IsCalcResult ? CreateData_Param_Formula(wData.DataPath) : string.Empty);
                    wElement.SetAttribute(RldConst.ReportDefine.ATT_PARAM_GROUPID, wData.GroupPath);
					// add 2021-08-30 6009画像 李 start
                    wElement.SetAttribute(RldConst.ReportDefine.ATT_PARAM_ISIMAGE, wData.IsImage);
					// add 2021-08-30 6009画像 李 end

                    // テンプレート繰返し範囲内外
                    switch (wData.IsInTemplete)
                    {
                        case RldConst.ParamData.VAL_IS_IN_TEMPLETE_IN:
                            wSetValue = RldConst.ReportDefine.VAL_PARAM_ISINTEMPLETE_YES;
                            break;
                        case RldConst.ParamData.VAL_IS_IN_TEMPLETE_OUT:
                            wSetValue = RldConst.ReportDefine.VAL_PARAM_ISINTEMPLETE_NO;
                            break;
                        default:
                            wSetValue = RldConst.ReportDefine.VAL_PARAM_ISINTEMPLETE_NONE;
                            break;
                    }
                    wElement.SetAttribute(RldConst.ReportDefine.ATT_PARAM_ISINTEMPLETE, wSetValue);

                    // 文字数オーバーで改ページする
                    wElement.SetAttribute(RldConst.ReportDefine.ATT_PARAM_ISNEWPAGE, wData.IsNewPage);

                    // colWidth属性 にセル幅を設定する
                    wElement.SetAttribute("colWidth", wData.CellWidth.ToString());
                    // add #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
                    // rowHeight属性 にセル幅を設定する
                    wElement.SetAttribute("rowHeight", wData.CellHeight.ToString());
                    // add #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
                    // 変換テーブル
                    if (wData.ConvertList.Count > 0)
                    {
                        _ = wElement.AppendChild(XmlDoc.ImportNode(wData.ConvertList.ToXmlElement(), true));
                    }

                    // フィルタテーブル
                    // mod #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
                    //if (wData.CanEditFilter)
                    if (wData.CanEditFilter && inF)
                    // mod #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end
                    {
                        // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
                        if (wData.FilterType != RldConst.FilterType.Group.MEDICINE &&    // 薬剤
                            wData.FilterType != RldConst.FilterType.Group.EQUIP &&       // 医材
                            wData.FilterType != RldConst.FilterType.Group.CATEGORY)
                        {
                        // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end
                            // フィルターテーブル用ルート要素を作成
                            var wFilterRootElement = this.XmlDoc.CreateElement(RldConst.ReportDefine.TAG_PARAM_FILTERTABLE);
                            // フィルターテーブルを作成してパラメータ要素へ追加
                            // mod #12026 帳票移植時にフィルタ設定が無効化する（初期対応） 高 start
                            //wElement.AppendChild(this.CreateData_Param_Filter(wFilterRootElement, wData.FilterData));
                            // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                            if (wData.FilterType == RldConst.FilterType.Group.INSPECTION)
                            {
                                wElement.AppendChild(this.CreateData_Group_Filter(wFilterRootElement, wData.FilterData));
                            }
                            else
                            // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
                            wElement.AppendChild(this.CreateData_Param_Filter(wFilterRootElement, wData.FilterData, wData.FilterType));
                            // mod #12026 帳票移植時にフィルタ設定が無効化する（初期対応） 高 end
                        }
                    }

                    // wElement要素ノードの子ノードのリストの末尾に、function要素ノードを追加します
                    if (wData.IsCalcResult)
                    {
                        // add #9423 テンプレート繰返し時に元々値があるセルは上書きしないようにすること limingzhe start
                        // ローカル関数
                        void AppendChild(string elementName, string attributeName, string attributeValue)
                        {
                            // function要素
                            System.Xml.XmlElement elem = this.XmlDoc.CreateElement(elementName);
                            elem.SetAttribute(attributeName, attributeValue);
                            _ = wElement.AppendChild(elem);

                        }

                        // function要素を追加
                        AppendChild("function", "name", wData.DataPath.Substring(3));
                        // add #9423 テンプレート繰返し時に元々値があるセルは上書きしないようにすること limingzhe end
                        // del #9423 テンプレート繰返し時に元々値があるセルは上書きしないようにすること limingzhe start
                        //edit #8713 帳票レイアウトデザイナーの動作指摘 dongzhaolong start
                        //    Boolean isExcelFormula = false;
                        //    Boolean isCustomFormula = false;
                        //    for (int i = 0; i < excelfunctionNames.Length; i++)
                        //    {
                        //        if (wData.DataPath.IndexOf(excelfunctionNames[i]) >= 0)
                        //        {
                        //            isExcelFormula = true;
                        //            break;
                        //        }
                        //    }

                        //    for (int j = 0; j < customfunctionNames.Length; j++)
                        //    {
                        //        if (wData.DataPath.IndexOf(customfunctionNames[j]) >= 0)
                        //        {
                        //            isCustomFormula = true;
                        //            break;
                        //        }
                        //    }

                        //    if (isExcelFormula)
                        //    {
                        //        int pos = wData.DataPath.IndexOf("(");
                        //        if (pos >= 0)
                        //        {

                        //            // ローカル関数
                        //            void AppendChild(string elementName, string attributeName, string attributeValue)
                        //            {
                        //                // function要素
                        //                System.Xml.XmlElement elem = this.XmlDoc.CreateElement(elementName);
                        //                elem.SetAttribute(attributeName, attributeValue);
                        //                _ = wElement.AppendChild(elem);

                        //            }

                        //            // function要素を追加
                        //            AppendChild("function", "name", wData.DataPath.Substring(3));

                        //            // "("の次から式末尾の2文字目までを切り出してarg属性値とする
                        //            int length = wData.DataPath.Length - pos - 2;
                        //            if (length > 0)
                        //            {
                        //                AppendChild("targetCell", "ids", wData.DataPath.Substring(pos + 1, length));
                        //            }
                        //        }
                        //    }
                        //    else if (isCustomFormula == true)
                        //    {
                        //        // ローカル関数
                        //        void AppendChild(string elementName, string attributeName, string attributeValue)
                        //        {
                        //            // function要素
                        //            System.Xml.XmlElement elem = this.XmlDoc.CreateElement(elementName);
                        //            elem.SetAttribute(attributeName, attributeValue);
                        //            _ = wElement.AppendChild(elem);

                        //        }

                        //        string formula = wData.DataPath.Substring(3);
                        //        // function要素を追加
                        //        AppendChild("function", "name", formula);
                        //        for (int k = 0; k < customfunctionNames.Length; k++)
                        //        {
                        //            if (wData.DataPath.IndexOf(customfunctionNames[k]) >= 0)
                        //            {
                        //                formula = formula.Replace(customfunctionNames[k],",");
                        //            }
                        //        }
                        //        formula = formula.Replace("[", "").Replace("]", "");
                        //        AppendChild("targetCell", "ids", formula);
                        //    }
                        //    //edit #8713 帳票レイアウトデザイナーの動作指摘 dongzhaolong end
                        // del #9423 テンプレート繰返し時に元々値があるセルは上書きしないようにすること limingzhe end
                    }

                    // 条件付き書式
                    // del #11443 帳票ファイル「パラメータ」シートの未使用箇所対応 高 start
                    //if (wData.FormatCondition.Count > 0)
                    //{

                    //    // 条件付き書式ルール用ルート要素を作成
                    //    var wFormatCondRootElement = this.XmlDoc.CreateElement("formatConditions");

                    //    for (int i = 0; i < wData.FormatCondition.Count; i++)
                    //    {
                    //        // formatCondition タグを生成
                    //        var wChildElement = wFormatCondRootElement.OwnerDocument.CreateElement("formatCondition");
                    //        // 属性値をセット
                    //        wChildElement.SetAttribute("comparisonOperator", wData.FormatCondition[i].ComparisonOperator);
                    //        wChildElement.SetAttribute("value", wData.FormatCondition[i].Value);
                    //        wChildElement.InnerText = wData.FormatCondition[i].CssClass;
                    //        wFormatCondRootElement.AppendChild(wChildElement);
                    //    }

                    //    // 条件付き書式ルールを作成してパラメータ要素へ追加
                    //    wElement.AppendChild(wFormatCondRootElement);

                    //}
                    // del #11443 帳票ファイル「パラメータ」シートの未使用箇所対応 高 start

                    // 分類別情報であればParticular属性を追加し、値を"Label"とする
                    if (IsClassficationInfo(wData.DataCategory, wData.DataClass, wData.DataName))
                    {

                        // particular属性追加
                        wElement.SetAttribute("particular", "Label");

                        // dataCode用ルート要素を作成
                        System.Xml.XmlElement newChild = this.XmlDoc.CreateElement("dataCodes");

                        // このノードの子ノードのリストの末尾に、新しいノードを追加するローカル関数
                        void appendChild(System.Xml.XmlElement xmlElement, string name, string innerText)
                        {
                            System.Xml.XmlElement element = xmlElement.OwnerDocument.CreateElement(name);
                            element.InnerText = innerText;
                            xmlElement.AppendChild(element);
                        }

                        // 分類別情報のループ
                        var doc = new System.Xml.XmlDocument();

                        // XMLをロード
                        doc.LoadXml(wData.LabelItem);

                        // ルートを無視して中のアイテムを取得
                        System.Xml.XmlNodeList nodes = doc.GetElementsByTagName(frmEditLabelClass.XML_ITEM);

                        // DataType属性が設定されているノードのみを抽出する
                        IEnumerable<(System.Xml.XmlNode item, System.Xml.XmlAttribute att)> enumerable()
                        {
                            foreach (System.Xml.XmlNode item in nodes)
                            {
                                var att = item.Attributes[frmEditLabelClass.XML_ATT_TYPE];
                                if (null != att)
                                {
                                    yield return (item, att);
                                }
                            }
                        }

                        // add #11619 分類別情報編集ダイアログに「全分類」を追加 高 start
                        string allDataCode = string.Empty;
                        string allFixString = string.Empty;
                        // add #11619 分類別情報編集ダイアログに「全分類」を追加 高 end

                        // System.Xml.XmlNodeListの子ノードの中でDataType属性が設定されているノードに対して処理
                        foreach ((System.Xml.XmlNode item, System.Xml.XmlAttribute att) in enumerable())
                        {

                            // 分類
                            var attClass = att.Value;

                            // dataCode
                            System.Xml.XmlAttribute attKey = item.Attributes[frmEditLabelClass.XML_ATT_KEY];
                            string dataCode = string.Empty;
                            if (null != attKey)
                            {
                                // dataCode をセット
                                dataCode = attKey.Value;
                            }

                            // 固定文字列
                            System.Xml.XmlAttribute attFixString = item.Attributes[frmEditLabelClass.XML_ATT_FIX];
                            string fixString = string.Empty;
                            if (null != attFixString)
                            {
                                // 固定文字列をセット
                                fixString = attFixString.Value;
                            }

                            // add #11619 分類別情報編集ダイアログに「全分類」を追加 高 start
                            if ("AllClass".Equals(attClass)) 
                            {
                                allDataCode = dataCode;
                                allFixString = fixString;
                            }
                            // add #11619 分類別情報編集ダイアログに「全分類」を追加 高 end

                            // dataCodesノードに分類別情報ノードを追加
                            //appendDataCodeElement(attClass, dataCode);
                            // dataCode タグを生成
                            System.Xml.XmlElement wChildElement = newChild.OwnerDocument.CreateElement("classificationData");
                            // 属性値をセット
                            wChildElement.SetAttribute("classNo", attClass);
                            // add #11619 分類別情報編集ダイアログに「全分類」を追加 高 start
                            if (string.IsNullOrEmpty(dataCode) && string.IsNullOrEmpty(fixString))
                            {
                                appendChild(wChildElement, "dataCode", allDataCode);
                                appendChild(wChildElement, "fixString", allFixString);
                            }
                            else
                            {
                            // add #11619 分類別情報編集ダイアログに「全分類」を追加 高 end
                                appendChild(wChildElement, "dataCode", dataCode);
                                appendChild(wChildElement, "fixString", fixString);
                            }

                            newChild.AppendChild(wChildElement);

                        }

                        // 分類別情報を作成してパラメータ要素へ追加
                        wElement.AppendChild(newChild);

                    }
                    //EDTT #8524 董 START
                    if (wData.CanRepeat)
                    {
                        wElement.SetAttribute(RldConst.ReportDefine.ATT_PARAM_REPEATADDRESS, wData.RepeatAddress);
                    }
                    //EDTT #8524 董 START
                    //#9397 表示文字列長の設定、およびフリー計算パラメータの書式設定について dongzhaolong start
                    wElement.SetAttribute(RldConst.ReportDefine.ATT_PARAM_ROWCOUNT, wData.RowCount);
                    //#9397 表示文字列長の設定、およびフリー計算パラメータの書式設定について dongzhaolong end
                    // add #11535 帳票の汎用バーコード出力対応 高 start
                    // バーコード enable
                    wElement.SetAttribute(@"canBarCode", wData.CanBarCode == true ? "1" : "0");
                    wElement.SetAttribute(@"barCode", RldLib.barCodeDic[wData.BarCode]);
                    // add #11535 帳票の汎用バーコード出力対応 高 end
                    // パラメータテーブルへパラメータを追加
                    wParamsNode.AppendChild(wElement);

                }

                // 帳票種別がラベル かつ 物品情報に属する項目が貼られていない場合はパラメータに追加する
                // かつ分類別情報がパラメータに含まれていない
                if (RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_LABEL)
                {
                    // 1ラベル1レコードとなるレコードセットを含めるために分類別情報に指定されたSQLコードを指定したパラメータを追加する
                    IEnumerable<DesignItemListData> enumerator = RldLib.CurrentLayoutData.DataItemList.Where(n => IsClassficationInfo(n.DataCategory, n.DataClass, n.DataName));
                    if (enumerator.Count() > 0)
                    {
                        var element = this.XmlDoc.CreateElement(RldConst.ReportDefine.TAG_PARAM);
                        element.SetAttribute(RldConst.ReportDefine.ATT_PARAM_SQLCODE, enumerator.First().SqlCode);
                        wParamsNode.AppendChild(element);
                    }

                }

                // ルート要素へパラメータテーブルを追加
                aTargetElement.AppendChild(wParamsNode);

                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }

            return wRet;
        }

        /// <summary>
        /// 分類別情報かどうかを判定する
        /// </summary>
        /// <param name="dataCategory">カテゴリ</param>
        /// <param name="dataClass">クラス</param>
        /// <param name="dataName">項目名</param>
        /// <returns>分類別情報の場合 True。それ以外の場合 False。</returns>
        private static bool IsClassficationInfo(string dataCategory, string dataClass, string dataName)
        {
            return dataCategory.Equals(DesignItemListData.dcLabel) &&
                                    dataClass.Equals(DesignItemListData.dcMaterialInfo) &&
                                    dataName.Equals(DesignItemListData.dcClassificationInfo);
        }

        /// <summary>
        /// 帳票定義ファイルデータ(パラメータ部内計算式)の作成を行います。
        /// </summary>
        /// <param name="aFormula"></param>
        /// <returns></returns>
        private string CreateData_Param_Formula(string aFormula)
        {
            string wRet = aFormula.Replace(RldConst.CALC_HEADER, string.Empty);

            int wStartPos = -1, wEndPos = -1;

            // mod #10444 複数患者帳票のオンライン保存でエラーになることがある 高 start
            //string cal_start = RldConst.CALC_ITEM_START + RldConst.PATH_HEADER;
            ////while ((wStartPos = aFormula.IndexOf(RldConst.CALC_ITEM_START, wEndPos + 1)) >= 0)
            //while ((wStartPos = aFormula.IndexOf(cal_start, wEndPos + 1)) >= 0)
            //{
            //    wEndPos = aFormula.IndexOf(RldConst.CALC_ITEM_END, wStartPos + 1);
            //    if (wEndPos == -1)
            //        break;

            //    // データ項目名を切り出し
            //    var wItemPath = aFormula.Substring(wStartPos + 1, wEndPos - wStartPos - 1);

            //    if (RldLib.CurrentLayoutData.DataItemList.Count(ele => ele.DataPath == wItemPath) > 0)
            //    {
            //        var wData = RldLib.CurrentLayoutData.DataItemList.Single(ele => ele.DataPath == wItemPath);
            //        wRet = wRet.Replace(wItemPath, string.Format("{0}{2}{1}", wData.SqlCode, wData.DataCode, RldConst.PATH_SPLIT));
            //    }
            //}
            //return wRet;
            string wTemp = string.Empty;
            int commStrPos = -1, commEndPos = -1;
            bool endFlag = false;
            string cal_start = RldConst.CALC_ITEM_START + RldConst.PATH_HEADER;

            while ((commStrPos = wRet.IndexOf("\"", commEndPos + 1)) >= 0)
            {
                {
                    string wRetTemp = wRet.Substring(commEndPos + 1, commStrPos - commEndPos - 1);
                    string wTmp = wRetTemp;
                    wStartPos = -1;
                    wEndPos = -1;
                    while ((wStartPos = wTmp.IndexOf(cal_start, wEndPos + 1)) >= 0)
                    {
                        wEndPos = wTmp.IndexOf(RldConst.CALC_ITEM_END, wStartPos + 1);
                        if (wEndPos == -1)
                            break;

                        // データ項目名を切り出し
                        var wItemPath = wTmp.Substring(wStartPos + 1, wEndPos - wStartPos - 1);
                        if (RldLib.CurrentLayoutData.DataItemList.Count(ele => ele.DataPath == wItemPath) > 0)
                        {
                            var wData = RldLib.CurrentLayoutData.DataItemList.Single(ele => ele.DataPath == wItemPath);
                            // mod #11556 「##=」型の計算式で関数が使用できなくなっている 高 start
                            if (string.IsNullOrEmpty(wData.SqlCode))
                                wRetTemp = wRetTemp.Replace($"{RldConst.CALC_ITEM_START}{wItemPath}{RldConst.CALC_ITEM_END}",
                                             // mod #12125 文字列型の組み合わせが正しく表示されない場合がある limingzhe start
                                             //string.Format("{3}{0}{2}{1}{4}", "0", wData.DataCode, RldConst.PATH_SPLIT, RldConst.CALC_ITEM_START, RldConst.CALC_ITEM_END));
                                             string.Format("{3}{0}{2}{1}{2}{5}{4}", "0", wData.DataCode, RldConst.PATH_SPLIT, RldConst.CALC_ITEM_START, RldConst.CALC_ITEM_END, wData.ConvertList.Count > 0 ? true : false));
                                             // mod #12125 文字列型の組み合わせが正しく表示されない場合がある limingzhe end
                            else
                                //wRetTemp = wRetTemp.Replace(wItemPath, string.Format("{0}{2}{1}", wData.SqlCode, wData.DataCode, RldConst.PATH_SPLIT));
                                wRetTemp = wRetTemp.Replace($"{RldConst.CALC_ITEM_START}{wItemPath}{RldConst.CALC_ITEM_END}",
                                            // mod #12125 文字列型の組み合わせが正しく表示されない場合がある limingzhe start
                                            //string.Format("{3}{0}{2}{1}{4}", wData.SqlCode, wData.DataCode, RldConst.PATH_SPLIT, RldConst.CALC_ITEM_START, RldConst.CALC_ITEM_END));
                                            string.Format("{3}{0}{2}{1}{2}{5}{4}", wData.SqlCode, wData.DataCode, RldConst.PATH_SPLIT, RldConst.CALC_ITEM_START, RldConst.CALC_ITEM_END, wData.ConvertList.Count > 0 ? true : false));
                                            // mod #12125 文字列型の組み合わせが正しく表示されない場合がある limingzhe end
                            // mod #11556 「##=」型の計算式で関数が使用できなくなっている 高 end
                        }
                    }
                    wTemp = wTemp + wRetTemp;
                    commEndPos = wRet.IndexOf("\"", commStrPos + 1);
                    if (commEndPos == -1)
                    {
                        wTemp = wTemp + wRet.Substring(commStrPos);
                        endFlag = true;
                        break;
                    }
                    else
                    {
                        wTemp = wTemp + wRet.Substring(commStrPos, commEndPos - commStrPos + 1);
                    }
                }
            }

            // del #11556 「##=」型の計算式で関数が使用できなくなっている 高 start
            //if (endFlag == false)
            // del #11556 「##=」型の計算式で関数が使用できなくなっている 高 end
            {
                string wRetTemp = wRet.Substring(commEndPos + 1);
                string wTmp = wRetTemp;
                wStartPos = -1;
                wEndPos = -1;
                while ((wStartPos = wTmp.IndexOf(cal_start, wEndPos + 1)) >= 0)
                {
                    wEndPos = wTmp.IndexOf(RldConst.CALC_ITEM_END, wStartPos + 1);
                    if (wEndPos == -1)
                        break;

                    // データ項目名を切り出し
                    var wItemPath = wTmp.Substring(wStartPos + 1, wEndPos - wStartPos - 1);
                    if (RldLib.CurrentLayoutData.DataItemList.Count(ele => ele.DataPath == wItemPath) > 0)
                    {
                        var wData = RldLib.CurrentLayoutData.DataItemList.Single(ele => ele.DataPath == wItemPath);
                        // mod #11556 「##=」型の計算式で関数が使用できなくなっている 高 start
                        if (string.IsNullOrEmpty(wData.SqlCode))
                            wRetTemp = wRetTemp.Replace($"{RldConst.CALC_ITEM_START}{wItemPath}{RldConst.CALC_ITEM_END}",
                                        // mod #12125 文字列型の組み合わせが正しく表示されない場合がある limingzhe start
                                        //string.Format("{3}{0}{2}{1}{4}", "0", wData.DataCode, RldConst.PATH_SPLIT, RldConst.CALC_ITEM_START, RldConst.CALC_ITEM_END));
                                        string.Format("{3}{0}{2}{1}{2}{5}{4}", "0", wData.DataCode, RldConst.PATH_SPLIT, RldConst.CALC_ITEM_START, RldConst.CALC_ITEM_END, wData.ConvertList.Count > 0 ? true : false));
                                        // mod #12125 文字列型の組み合わせが正しく表示されない場合がある limingzhe end
                        else
                            //wRetTemp = wRetTemp.Replace(wItemPath, string.Format("{0}{2}{1}", wData.SqlCode, wData.DataCode, RldConst.PATH_SPLIT));
                            wRetTemp = wRetTemp.Replace($"{RldConst.CALC_ITEM_START}{wItemPath}{RldConst.CALC_ITEM_END}",
                                        // mod #12125 文字列型の組み合わせが正しく表示されない場合がある limingzhe start
                                        //string.Format("{3}{0}{2}{1}{4}", wData.SqlCode, wData.DataCode, RldConst.PATH_SPLIT, RldConst.CALC_ITEM_START, RldConst.CALC_ITEM_END));
                                        string.Format("{3}{0}{2}{1}{2}{5}{4}", wData.SqlCode, wData.DataCode, RldConst.PATH_SPLIT, RldConst.CALC_ITEM_START, RldConst.CALC_ITEM_END, wData.ConvertList.Count > 0 ? true : false));
                                        // mod #12125 文字列型の組み合わせが正しく表示されない場合がある limingzhe end
                        // mod #11556 「##=」型の計算式で関数が使用できなくなっている 高 end
                    }

                }
                wTemp = wTemp + wRetTemp;
            }
            return wTemp;
            // mod #10444 複数患者帳票のオンライン保存でエラーになることがある 高 end
        }

        /// <summary>
        /// 帳票定義ファイルデータ(パラメータ部内フィルター部)の作成を行います。
        /// </summary>
        /// <param name="aData"></param>
        /// <returns></returns>
        // mod #12026 帳票移植時にフィルタ設定が無効化する（初期対応） 高 start
        //private System.Xml.XmlElement CreateData_Param_Filter(System.Xml.XmlElement aRootElement, string aXmlText)
        private System.Xml.XmlElement CreateData_Param_Filter(System.Xml.XmlElement aRootElement, string aXmlText, string aFilterType)
        // mod #12026 帳票移植時にフィルタ設定が無効化する（初期対応） 高 end
        {
            // フィルタの設定がない場合は抜ける
            if (string.IsNullOrEmpty(aXmlText)) return aRootElement;

            var wRet = aRootElement;

            try
            {
                var wXmlDoc = new System.Xml.XmlDocument();
                // フィルタ設定を読み込む
                wXmlDoc.LoadXml(aXmlText);

                // Item タグを検索(1つしか存在しない)
                string wXPath = string.Format(@"//{0}", RldConst.FilterData.TAG_ITEM);

                foreach (System.Xml.XmlElement wElement in wXmlDoc.SelectNodes(wXPath))
                {
                    // filter タグを生成
                    var wChildElement = wRet.OwnerDocument.CreateElement(RldConst.ReportDefine.TAG_PARAM_FILTER);
                    // 属性値をセット
                    wChildElement.SetAttribute(RldConst.ReportDefine.ATT_PARAM_FILTER_CODE, wElement.Attributes[RldConst.FilterData.ATT_ITEM_CODE].Value);
                    // add #12026 帳票移植時にフィルタ設定が無効化する（初期対応） 高 start
                    // mod #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 start
                    if (aFilterType == RldConst.FilterType.Group.EXAMINE
                        || aFilterType == RldConst.FilterType.Group.EXAM_SET
                        || aFilterType == RldConst.FilterType.Group.INSPECTION
                        // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
                        || aFilterType == RldConst.FilterType.Group.WQTESTPOINT
                        // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
                        )
                    {
                        var attribute = wElement.Attributes[RldConst.FilterData.ATT_ITEM_NAME];
                        wChildElement.SetAttribute(RldConst.ReportDefine.ATT_PARAM_FILTER_NAME, attribute?.Value ?? string.Empty);
                    }
                    // mod #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 end
                    // add #12026 帳票移植時にフィルタ設定が無効化する（初期対応） 高 end
                    wChildElement.SetAttribute(RldConst.ReportDefine.ATT_PARAM_FILTER_EXAM_BEFORE, wElement.Attributes[RldConst.FilterData.ATT_ITEM_EXAMCLASS_BEFORE].Value);
                    wChildElement.SetAttribute(RldConst.ReportDefine.ATT_PARAM_FILTER_EXAM_AFTER, wElement.Attributes[RldConst.FilterData.ATT_ITEM_EXAMCLASS_AFTER].Value);
                    wChildElement.SetAttribute(RldConst.ReportDefine.ATT_PARAM_FILTER_EXAM_OTHER, wElement.Attributes[RldConst.FilterData.ATT_ITEM_EXAMCLASS_OTHER].Value);

                    // 親要素へ追加
                    wRet.AppendChild(wChildElement);
                }
            }
            finally
            {
            }

            return wRet;
        }

        /// <summary>
        /// 帳票定義ファイルデータ(グループ部)の作成を行います。
        /// </summary>
        /// <param name="aTargetElement"></param>
        /// <param name="aList"></param>
        /// <returns></returns>
        private bool CreateData_Group(System.Xml.XmlElement aTargetElement, System.ComponentModel.BindingList<DesignGroupData> aList)
        {
            bool wRet = false;

            try
            {
                // グループテーブル追加
                var wGroupNode = this.XmlDoc.CreateElement(RldConst.ReportDefine.TAG_GROUPTABLE);
                // add #11106 集計帳票で集計範囲外のグループ項目が出力されない 高 start
                string totalAddress = RldLib.totalLayoutData.UnitVAddress.Trim() + "," + RldLib.totalLayoutData.UnitHAddress.Trim();
                List<string> totalAddressList = new List<string>(totalAddress.Split(','));
                // add #11106 集計帳票で集計範囲外のグループ項目が出力されない 高 end

                // グループを列挙してグループテーブルへ追加
                foreach (var wData in aList)
                {
                    // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
                    if (RldDataGridViewParamDataEditHelper.middleData.ContainsKey(wData.GroupPath)) {
                        wData.FilterData = RldDataGridViewParamDataEditHelper.middleData[wData.GroupPath];
                    }
                    // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end
                    var wElement = this.XmlDoc.CreateElement(RldConst.ReportDefine.TAG_GROUP);
                    wElement.SetAttribute(RldConst.ReportDefine.ATT_GROUP_ID, wData.GroupPath);
                    wElement.SetAttribute(RldConst.ReportDefine.ATT_GROUP_REPEATMAX, wData.RepeatCount);
                    // mon 20211009 #5598 単集計，複数集計ページ変更方法を変更する   鄭  start
                    //wElement.SetAttribute(RldConst.ReportDefine.ATT_GROUP_ISNEWPAGE, wData.IsNewPage == RldConst.GroupData.VAL_ISNEWPAGE_TRUE ? RldConst.ReportDefine.VAL_GROUP_ISNEWPAGE_TRUE : RldConst.ReportDefine.VAL_GROUP_ISNEWPAGE_FALSE);
                    if ("OneTotal".Equals(RldLib.CurrentLayoutData.DesignSettingData.ReportClass) || "MultiTotal".Equals(RldLib.CurrentLayoutData.DesignSettingData.ReportClass))
                    {
                        // mod #10858 「##=[##データ項目」」の形式で null が出力される 高 start
                        if (RldLib.CurrentLayoutData.DesignTempleteData != null)
                        {
                            // mod #11106 集計帳票で集計範囲外のグループ項目が出力されない 高 start
                            //wElement.SetAttribute(RldConst.ReportDefine.ATT_GROUP_ISNEWPAGE, RldLib.CurrentLayoutData.DesignTempleteData.IsNewPage == RldConst.GroupData.VAL_ISNEWPAGE_TRUE ? RldConst.ReportDefine.VAL_GROUP_ISNEWPAGE_TRUE : RldConst.ReportDefine.VAL_GROUP_ISNEWPAGE_FALSE);
                            if (totalAddressList != null)
                            {
                                String groupName = wData.GroupName;
                                bool bFind = false;
                                foreach (var wList in totalAddressList)
                                {
                                    foreach (var wDataParam in RldLib.CurrentLayoutData.DesignParamList)
                                    {
                                        if (wDataParam.CellAddress.Equals(wList))
                                        {
                                            // mod #12274 集計使用項目と同じグループ名を禁止するエラーの頻度が高くなりすぎる 高 start
                                            //if (groupName == wDataParam.GroupName)
                                            if (groupName == wDataParam.GroupName || wData.IsInTemplete == RldConst.ParamData.VAL_IS_IN_TEMPLETE_IN)
                                            // mod #12274 集計使用項目と同じグループ名を禁止するエラーの頻度が高くなりすぎる 高 end
                                            {
                                                bFind = true;
                                                wElement.SetAttribute(RldConst.ReportDefine.ATT_GROUP_ISNEWPAGE, RldLib.CurrentLayoutData.DesignTempleteData.IsNewPage == RldConst.GroupData.VAL_ISNEWPAGE_TRUE ? RldConst.ReportDefine.VAL_GROUP_ISNEWPAGE_TRUE : RldConst.ReportDefine.VAL_GROUP_ISNEWPAGE_FALSE);
                                                break;
                                            }
                                        }
                                    }
                                }
                                if (bFind == false)
                                {
                                    wElement.SetAttribute(RldConst.ReportDefine.ATT_GROUP_ISNEWPAGE, wData.IsNewPage == RldConst.GroupData.VAL_ISNEWPAGE_TRUE ? RldConst.ReportDefine.VAL_GROUP_ISNEWPAGE_TRUE : RldConst.ReportDefine.VAL_GROUP_ISNEWPAGE_FALSE);
                                }
                            }
                            else
                            {
                                wElement.SetAttribute(RldConst.ReportDefine.ATT_GROUP_ISNEWPAGE, wData.IsNewPage == RldConst.GroupData.VAL_ISNEWPAGE_TRUE ? RldConst.ReportDefine.VAL_GROUP_ISNEWPAGE_TRUE : RldConst.ReportDefine.VAL_GROUP_ISNEWPAGE_FALSE);
                            }
                            // mod #11106 集計帳票で集計範囲外のグループ項目が出力されない 高 end
                        }
                        else
                        {
                            wElement.SetAttribute(RldConst.ReportDefine.ATT_GROUP_ISNEWPAGE, wData.IsNewPage == RldConst.GroupData.VAL_ISNEWPAGE_TRUE ? RldConst.ReportDefine.VAL_GROUP_ISNEWPAGE_TRUE : RldConst.ReportDefine.VAL_GROUP_ISNEWPAGE_FALSE);
                        }
                        // mod #10858 「##=[##データ項目」」の形式で null が出力される 高 end
                    }
                    else {
                        wElement.SetAttribute(RldConst.ReportDefine.ATT_GROUP_ISNEWPAGE, wData.IsNewPage == RldConst.GroupData.VAL_ISNEWPAGE_TRUE ? RldConst.ReportDefine.VAL_GROUP_ISNEWPAGE_TRUE : RldConst.ReportDefine.VAL_GROUP_ISNEWPAGE_FALSE);

                    }
                    // mon 20211009 #5598 単集計，複数集計ページ変更方法を変更する 鄭  end
                    wElement.SetAttribute(RldConst.ReportDefine.ATT_GROUP_FILTERTYPE, wData.CanEditFilter ? wData.FilterType : string.Empty);

                    switch (wData.FilterType)
                    {
                        case RldConst.FilterType.Group.MEDICINE:        // 薬剤
                        case RldConst.FilterType.Group.EQUIP:           // 医材
                        case RldConst.FilterType.Group.PATEVENT:        // イベント
                        case RldConst.FilterType.Group.ADDITION:        // 加算
                        case RldConst.FilterType.Group.DIALDIFF:        // 透析困難コメント
                        case RldConst.FilterType.Group.OBSKIND:         // 観察記録種別
                        //add #8489 zhu start
                        case RldConst.FilterType.Group.DISTRIBUTION:
                        //add #8489 zhu end
                        // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
                        case RldConst.FilterType.Group.CATEGORY:
                        // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end
                        // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe start
                        case RldConst.FilterType.Group.PECEIPT:
                        // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe end
                        // add #11625 クラス「指示履歴」の仕様変更② 高 start
                        case RldConst.FilterType.Group.LOGTARGET:
                        // add #11625 クラス「指示履歴」の仕様変更② 高 end
                        // add #12006 感染症がフィルタできない 高 start
                        case RldConst.FilterType.Group.INFECTION:
                        // add #12006 感染症がフィルタできない 高 end
                        // add #12756 クラス「##準備リスト.物品情報」のフィルタ設定が不十分 高 start
                        case RldConst.FilterType.Group.GOODS:
                        // add #12756 クラス「##準備リスト.物品情報」のフィルタ設定が不十分 高 end
                        // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 start
                        // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
                        case RldConst.FilterType.Group.WQTESTTYPE:
                        // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
                        // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 end
                        // add #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe start
                        case RldConst.FilterType.Group.EQUIP_DIA:        // 器材
                        // add #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe end
                            //add #8615 zhu start
                            // フィルタテーブル
                            if (wData.CanEditFilter)
                            {
                                // フィルターテーブル用ルート要素を作成
                                var wFilterRootElement = this.XmlDoc.CreateElement(RldConst.ReportDefine.TAG_GROUP_FILTERTABLE);
                                // フィルターテーブルを作成してグループ要素へ追加
                                //update #8489 zhu start
                                // mod #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
                                if (wData.FilterType == RldConst.FilterType.Group.CATEGORY)
                                {
                                    //wElement.AppendChild(this.CreateData_Param_Filter(wFilterRootElement, wData.FilterData));
                                    wElement.AppendChild(this.CreateData_Group_Filter(wFilterRootElement, wData.FilterData));
                                }
                                //if (wData.FilterType != "Distribution")
                                else if (wData.FilterType != "Distribution")
                                // mod #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end
                                {
                                    wElement.AppendChild(this.CreateData_Group_Filter(wFilterRootElement, wData.FilterData));
                                }
                                else
                                {
                                    wElement.AppendChild(this.CreateData_Group_Filter_Distribution(wFilterRootElement, wData.FilterData));
                                }
                                //update #8489 zhu end
                                
                            }
                            //add #8615 zhu end                            
                            break;

                        default:
                            break;
                    
                    }

                    // グループテーブルへグループを追加
                    wGroupNode.AppendChild(wElement);
                }

                // ルート要素へグループテーブルを追加
                aTargetElement.AppendChild(wGroupNode);

                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }

            return wRet;
        }

        // add FNSI-523 2次元帳票対応 夏 start
        /// <summary>
        /// 帳票定義ファイルデータ(集計部)の作成を行います。
        /// </summary>
        /// <param name="aTargetElement"></param>
        /// <param name="aList"></param>
        /// <returns></returns>
        private bool CreateData_Total(System.Xml.XmlElement aTargetElement, TotalLayoutData atotalData)
        {
            bool wRet = false;

            try
            {
                // テンプレート繰返しノード追加
                var wTotalNode = this.XmlDoc.CreateElement(RldConst.ReportDefine.TAG_TOTALTABLE);

                // テンプレート繰返し設定データがある場合
                if (atotalData != null)
                {
                    wTotalNode.SetAttribute(RldConst.ReportDefine.ATT_TOTALUNITV, atotalData.UnitV);
                    // add #11011 集計内訳タブ仕様変更 高 start
                    wTotalNode.SetAttribute(RldConst.ReportDefine.ATT_TOTALUNITVADDRESS, atotalData.UnitVAddress);
                    // add #11011 集計内訳タブ仕様変更 高 end
                    wTotalNode.SetAttribute(RldConst.ReportDefine.ATT_TOTALUNITDATE, atotalData.UnitDate);
                    wTotalNode.SetAttribute(RldConst.ReportDefine.ATT_TOTALUNITH, atotalData.UnitH);
                    // add #11011 集計内訳タブ仕様変更 高 start
                    wTotalNode.SetAttribute(RldConst.ReportDefine.ATT_TOTALUNITHADDRESS, atotalData.UnitHAddress);
                    // add #11011 集計内訳タブ仕様変更 高 end
                    // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe start
                    wTotalNode.SetAttribute(RldConst.ReportDefine.ATT_TOTAL_EFFECT_DATA_V, atotalData.EffectDataV);
                    // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe end
                    // add #12218 集計の縦単位でも値のない行が出力できない limingzhe start
                    wTotalNode.SetAttribute(RldConst.ReportDefine.ATT_TOTAL_EFFECT_DATA_H, atotalData.EffectDataH);
                    // add #12218 集計の縦単位でも値のない行が出力できない limingzhe end
                    wTotalNode.SetAttribute(RldConst.ReportDefine.ATT_TOTALCONTENTS, atotalData.Contents);
                    // add #11973 日常点検一覧帳票が正常に出せない 高 start
                    wTotalNode.SetAttribute(RldConst.ReportDefine.ATT_TOTALCONTENTSTYPE, atotalData.ContentsType);
                    // add #11973 日常点検一覧帳票が正常に出せない 高 end
                    wTotalNode.SetAttribute(RldConst.ReportDefine.ATT_TOTALCONVERSION, atotalData.Conversion);
                    wTotalNode.SetAttribute(RldConst.ReportDefine.ATT_TOTALCOUNTH, atotalData.CountH);
                    wTotalNode.SetAttribute(RldConst.ReportDefine.ATT_TOTALCOUNTV, atotalData.CountV);
                    wTotalNode.SetAttribute(RldConst.ReportDefine.ATT_TOTALORIGINRANGE, atotalData.OriginRange);
 
                }

                // ルート要素へテンプレート繰返しノードを追加
                aTargetElement.AppendChild(wTotalNode);

                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }

            return wRet;
        }
        // add FNSI-523 2次元帳票対応 夏 end
        //add #8489 zhu strart
        private System.Xml.XmlElement CreateData_Group_Filter_Distribution(System.Xml.XmlElement aRootElement, string aXmlText)
        {
            // フィルタの設定がない場合は抜ける
            if (string.IsNullOrEmpty(aXmlText)) return aRootElement;

            var wRet = aRootElement;

            try
            {
                var wXmlDoc = new System.Xml.XmlDocument();
                wXmlDoc.LoadXml(aXmlText);
                var b = new System.Xml.XmlDocument();
                // CheckState 属性値が Checked のノードを抽出
                // wXPath ← "//Item[@checkState='Checked']"
                string wXPath = string.Format(@"//{0}[@{1}='{2}']",
                    RldConst.FilterData.TAG_ITEM,
                    RldConst.FilterData.ATT_ITEM_CHECKSTATE,
                    System.Windows.Forms.CheckState.Checked);

                // filterタグとitem属性の値のコレクションを返す
                for (int i = 0; i < wXmlDoc.DocumentElement.ChildNodes.Count; i++)
                {
                    try
                    {


                        b = new System.Xml.XmlDocument();

                        System.Xml.XmlElement xe1 = b.CreateElement( "selectsetting");
                        b.AppendChild(xe1);
                        b.FirstChild.AppendChild(b.ImportNode(wXmlDoc.DocumentElement.ChildNodes[i],true));
                    }
                    catch (Exception ex)
                    { 
                        
                    }


                    IEnumerable<(System.Xml.XmlElement wChildElement, string itemValue)> enumerable()
                    {
                        // "checkState='Checked'"と一致するノード群から取り出した filterタグとitem属性の値 組み合わせのコレクションを返す
                        return from System.Xml.XmlElement wElement in b.DocumentElement.SelectNodes(wXPath)
                               let wChildElement = wRet.OwnerDocument.CreateElement(RldConst.ReportDefine.TAG_GROUP_FILTER)
                               let itemValue = LFunc_GetFilterPathRecursive(wElement)
                               select (wChildElement, itemValue);
                        
                    }

                    // 薬剤フィルタかどうか
                    bool isMedicine = wXmlDoc.DocumentElement.ChildNodes[i].Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.MEDICINE;
                    bool isEquipment = wXmlDoc.DocumentElement.ChildNodes[i].Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.EQUIPMENT;

                    // filterタグとitem属性の値のコレクション の分だけ繰り返す
                    foreach ((System.Xml.XmlElement wChildElement, string itemValue) in enumerable())
                    {

                        // itemValueには "2" や "3.2.1" のように入っている
                        string[] vs = itemValue.Split('.');
                        string colValue = string.Empty;
                        // item属性をセット
                        wChildElement.SetAttribute(RldConst.ReportDefine.ATT_GROUP_FILTER_ITEM, itemValue);

                        // Medicineの場合に属性値colをセットする
                        if (isMedicine)
                        {
                            switch (vs.Length)
                            {
                                case 0:
                                case 1:
                                    colValue = "medicine_type";
                                    break;
                                case 2:
                                    colValue = "medicine_type.medi_class_cd";
                                    break;
                                default:
                                    colValue = "medicine_type.medi_class_cd.medi_cd";
                                    break;

                            }
                        }
                        else if (isEquipment)
                        {
                            switch (vs.Length)
                            {
                                case 0:
                                case 1:
                                    colValue = "equip_class_cd";
                                    break;
                                case 2:
                                    colValue = "equip_class_cd.cd";
                                    break;
                                default:
                                    colValue = "equip_class_cd.cd";
                                    break;

                            }
                        }
                        else
                        {
                            switch (vs.Length)
                            {
                                case 0:
                                case 1:
                                    colValue = "medi_class_cd";
                                    break;
                                case 2:
                                    colValue = "medi_class_cd.cd";
                                    break;
                                default:
                                    colValue = "medi_class_cd.equip_class_type.cd";
                                    break;

                            }
                        }
                        wChildElement.SetAttribute("col", colValue);

                        // 親要素へ追加
                        wRet.AppendChild(wChildElement);
                    }
                }


                /// <summary>
                /// (ローカル関数) 指定したノードに対する全ての親ノードの属性値を取得します。
                /// </summary>
                /// <param name="aXmlNode"></param>
                /// <returns></returns>
                string LFunc_GetFilterPathRecursive(System.Xml.XmlNode aXmlNode)
                {
                    string wLFuncRet = aXmlNode.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value;

                    if ((aXmlNode.ParentNode != null) && (aXmlNode.ParentNode.Attributes[RldConst.FilterData.ATT_ITEM_TAG] != null) &&
                        (aXmlNode.ParentNode.ParentNode != null) && (aXmlNode.ParentNode.ParentNode.Attributes[RldConst.FilterData.ATT_ITEM_TAG] != null))
                    {

                        wLFuncRet = $"{LFunc_GetFilterPathRecursive(aXmlNode.ParentNode)}{RldConst.FilterData.SPLITSTR_FILTER}{wLFuncRet}";

                    }

                    return wLFuncRet;
                }
            }
            finally
            {
            }

            return wRet;
        }
        //add #8489 zhu end
        /// <summary>
        /// 帳票定義ファイルデータ(グループ部内フィルター部)の作成を行います。
        /// </summary>
        /// <param name="aRootElement"></param>
        /// <returns></returns>
        private System.Xml.XmlElement CreateData_Group_Filter(System.Xml.XmlElement aRootElement, string aXmlText)
        {
            // フィルタの設定がない場合は抜ける
            if (string.IsNullOrEmpty(aXmlText)) return aRootElement;

            var wRet = aRootElement;

            try
            {
                var wXmlDoc = new System.Xml.XmlDocument();
                // フィルタ設定を読み込む
                // <SelectSetting>
                //     <Item tag="Medicine" checkState="Indeterminate">
                //         <Item tag="1" checkState="Checked" />
                //         <Item tag="2" checkState="Indeterminate">
                //             <Item tag="1" checkState="Checked" />
                //         </Item>
                //         <Item tag="3" checkState="Indeterminate">
                //             <Item tag="1" checkState="Indeterminate">
                //                 <Item tag="3" checkState="Checked" />
                //             </Item>
                //         </Item>
                //     </Item>
                // </SelectSetting>
                wXmlDoc.LoadXml(aXmlText);

                // CheckState 属性値が Checked のノードを抽出
                // wXPath ← "//Item[@checkState='Checked']"
                string wXPath = string.Format(@"//{0}[@{1}='{2}']",
                    RldConst.FilterData.TAG_ITEM,
                    RldConst.FilterData.ATT_ITEM_CHECKSTATE,
                    System.Windows.Forms.CheckState.Checked);

                // filterタグとitem属性の値のコレクションを返す
                IEnumerable<(System.Xml.XmlElement wChildElement, string itemValue)> enumerable()
                {
                    // "checkState='Checked'"と一致するノード群から取り出した filterタグとitem属性の値 組み合わせのコレクションを返す
                    return from System.Xml.XmlElement wElement in wXmlDoc.SelectNodes(wXPath)
                           let wChildElement = wRet.OwnerDocument.CreateElement(RldConst.ReportDefine.TAG_GROUP_FILTER)
                           let itemValue = LFunc_GetFilterPathRecursive(wElement)
                           let itemType = Lfunc_getFilterType(wElement)
                           select (wChildElement, itemValue);
                }

                // 薬剤フィルタかどうか
                bool isMedicine = wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.MEDICINE;

                //and #5601  2021-09-23 医材 鄭 start
                if (!isMedicine) {
                    isMedicine = wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.EQUIPMENT;
                }
                //and #5601 2021-09-23 医材 鄭 end
                // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
                if (!isMedicine)
                {
                    isMedicine = wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.CATEGORY;
                }
                // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end
                // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe start
                if (!isMedicine)
                {
                    isMedicine = wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.PECEIPT;
                }
                // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe end
                // add #11625 クラス「指示履歴」の仕様変更② 高 start
                if (!isMedicine)
                {
                    isMedicine = wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.LOGTARGET;
                }
                // add #11625 クラス「指示履歴」の仕様変更② 高 end
                // add #12006 感染症がフィルタできない 高 start
                if (!isMedicine)
                {
                    isMedicine = wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.INFECTION;
                }
                // add #12006 感染症がフィルタできない 高 end
                // add #12756 クラス「##準備リスト.物品情報」のフィルタ設定が不十分 高 start
                if (!isMedicine)
                {
                    isMedicine = wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.GOODS;
                }
                // add #12756 クラス「##準備リスト.物品情報」のフィルタ設定が不十分 高 end
                // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 start
                // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
                if (!isMedicine)
                {
                    isMedicine = wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.WQTESTTYPE;
                }
                // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
                // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 end
                // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                if (!isMedicine)
                {
                    isMedicine = wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.INSPECTION;
                }
                // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
                // add #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe start
                if (!isMedicine)
                {
                    isMedicine = wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.EQUIP_DIA;
                }
                // add #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe end

                // filterタグとitem属性の値のコレクション の分だけ繰り返す
                foreach ((System.Xml.XmlElement wChildElement, string itemValue) in enumerable())
                {

                    // item属性をセット
                    wChildElement.SetAttribute(RldConst.ReportDefine.ATT_GROUP_FILTER_ITEM, itemValue);

                    // Medicineの場合に属性値colをセットする
                    if (isMedicine)
                    {

                        // itemValueには "2" や "3.2.1" のように入っている
                        string[] vs = itemValue.Split('.');
                        string colValue = string.Empty;
                        switch (vs.Length)
                        {
                            case 0:
                            case 1:
                                // ある特定の薬剤分類全て
                                // mod #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
                                //colValue = "medi_class_cd";
                                if (wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.MEDICINE)
                                {
                                    colValue = "medicine_type";
                                }
                                //add #8616 帳票処理の不具合 董 start
                                else if (wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.EQUIPMENT)
                                {
                                    colValue = "equip_class_cd";
                                }
                                //add #8616 帳票処理の不具合 董 end
                                // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
                                else if (wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.CATEGORY)
                                {
                                    colValue = "category_cd";
                                }
                                // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end
                                // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe start
                                else if (wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.PECEIPT)
                                {
                                    colValue = "receipt_class_cd";
                                }
                                // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe end
                                // add #11625 クラス「指示履歴」の仕様変更② 高 start
                                else if (wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.LOGTARGET)
                                {
                                    colValue = "logTarget_class_cd";
                                }
                                // add #11625 クラス「指示履歴」の仕様変更② 高 end
                                // add #12006 感染症がフィルタできない 高 start
                                else if (wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.INFECTION)
                                {
                                    colValue = "infection_cd";
                                }
                                // add #12006 感染症がフィルタできない 高 end
                                // add #12756 クラス「##準備リスト.物品情報」のフィルタ設定が不十分 高 start
                                else if (wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.GOODS)
                                {
                                    colValue = "goods_type";
                                }
                                // add #12756 クラス「##準備リスト.物品情報」のフィルタ設定が不十分 高 end
                                // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 start
                                // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
                                else if (wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.WQTESTTYPE)
                                {
                                    colValue = "survey_type_cd";
                                }
                                // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
                                // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 end
                                // add #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe start
                                else if (wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.EQUIP_DIA)
                                {
                                    colValue = "class_cd";
                                }
                                // add #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe end
                                // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                                else if (wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.INSPECTION)
                                {
                                    colValue = "mainte_category_cd";
                                }
                                // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
                                else
                                {
                                    colValue = "medi_class_cd";
                                }
                                // mod #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end
                                break;
                            case 2:


                                //mon #5601 2021-09-23 医材 鄭 start
                                // ある特定の薬剤分類の通常薬剤か調製薬剤のいずれか
                                //colValue = "medi_class_cd.medi_class_type";
                                if (wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.MEDICINE)
                                {
                                    // ある特定の薬剤分類の通常薬剤か調製薬剤のいずれか
                                    // mod #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
                                    //colValue = "medi_class_cd.medicine_type";
                                    colValue = "medicine_type.medi_class_cd";
                                    // mod #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end
                                }
                                //add #8616 帳票処理の不具合 董 start
                                else if (wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.EQUIPMENT)
                                {
                                    colValue = "equip_class_cd.cd";
                                }
                                //add #8616 帳票処理の不具合 董 end
                                // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
                                else if (wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.CATEGORY)
                                {
                                    colValue = "category_cd.sub_category_cd";
                                }
                                // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end
                                // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe start
                                else if (wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.PECEIPT)
                                {
                                    colValue = "receipt_class_cd.receipt_kind_cd";
                                }
                                // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe end
                                // add #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe start
                                else if (wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.EQUIP_DIA)
                                {
                                    colValue = "class_cd.cd";
                                }
                                // add #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe end
                                // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                                else if (wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.INSPECTION)
                                {
                                    colValue = "mainte_category_cd.mainte_detail_cd";
                                }
                                // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
                                // add #12756 クラス「##準備リスト.物品情報」のフィルタ設定が不十分 高 start
                                else if (wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.GOODS)
                                {
                                    colValue = "goods_type.class_cd";
                                }
                                // add #12756 クラス「##準備リスト.物品情報」のフィルタ設定が不十分 高 end
                                else
                                {
                                    // ある特定の薬剤分類の通常薬剤か調製薬剤のいずれか
                                    colValue = "medi_class_cd.cd";
                                }
                                //mon  #5601 2021-09-23 医材 鄭 end
                                break;
                            default:
                                //mon  #5601 2021-09-23 医材 鄭 start
                                // ある特定の薬剤
                                //colValue = "medi_class_cd.medi_class_type.medi_cd";
                                if (wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.MEDICINE)
                                {
                                    // ある特定の薬剤
                                    // mod #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
                                    //colValue = "medi_class_cd.medicine_type.medi_cd";
                                    colValue = "medicine_type.medi_class_cd.medi_cd";
                                    // mod #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end
                                }
                                //add #8616 帳票処理の不具合 董 start
                                else if (wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.EQUIPMENT)
                                {
                                    colValue = "equip_class_cd";
                                }
                                //add #8616 帳票処理の不具合 董 end
                                // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
                                else if (wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.CATEGORY)
                                {
                                    colValue = "category_cd";
                                }
                                // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end
                                // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe start
                                else if (wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.PECEIPT)
                                {
                                    colValue = "receipt_class_cd.receipt_kind_cd.receipt_cd";
                                }
                                // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe end
                                // add #11625 クラス「指示履歴」の仕様変更② 高 start
                                else if (wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.LOGTARGET)
                                {
                                    colValue = "logTarget_class_cd";
                                }
                                // add #11625 クラス「指示履歴」の仕様変更② 高 end
                                // add #12006 感染症がフィルタできない 高 start
                                else if (wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.INFECTION)
                                {
                                    colValue = "infection_cd";
                                }
                                // add #12006 感染症がフィルタできない 高 end
                                // add #12756 クラス「##準備リスト.物品情報」のフィルタ設定が不十分 高 start
                                else if (wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.GOODS)
                                {
                                    colValue = "goods_type.class_cd.cd";
                                }
                                // add #12756 クラス「##準備リスト.物品情報」のフィルタ設定が不十分 高 end
                                // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 start
                                // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
                                else if (wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.WQTESTTYPE)
                                {
                                    colValue = "survey_type_cd";
                                }
                                // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
                                // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 end
                                // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                                else if (wXmlDoc.DocumentElement.FirstChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value == RldConst.FilterType.Group.INSPECTION)
                                {
                                    colValue = "mainte_category_cd.mainte_detail_cd";
                                }
                                // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
                                else
                                {
                                    // ある特定の薬剤
                                    colValue = "medi_class_cd.equip_class_type.cd";
                                }
                                //mon #5601  2021-09-23 医材 鄭 end
                                break;
                        }
                        wChildElement.SetAttribute("col", colValue);

                    }

                    // 親要素へ追加
                    wRet.AppendChild(wChildElement);
                }

                /// <summary>
                /// (ローカル関数) 指定したノードに対する全ての親ノードの属性値を取得します。
                /// </summary>
                /// <param name="aXmlNode"></param>
                /// <returns></returns>
                string LFunc_GetFilterPathRecursive(System.Xml.XmlNode aXmlNode)
                {
                    string wLFuncRet = aXmlNode.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value;

                    if ((aXmlNode.ParentNode != null) && (aXmlNode.ParentNode.Attributes[RldConst.FilterData.ATT_ITEM_TAG] != null) &&
                        (aXmlNode.ParentNode.ParentNode != null) && (aXmlNode.ParentNode.ParentNode.Attributes[RldConst.FilterData.ATT_ITEM_TAG] != null))
                    {

                        wLFuncRet = $"{LFunc_GetFilterPathRecursive(aXmlNode.ParentNode)}{RldConst.FilterData.SPLITSTR_FILTER}{wLFuncRet}";

                    }

                    return wLFuncRet;
                }
                //add #8489 zhu start
                string Lfunc_getFilterType(System.Xml.XmlNode aXmlNode)
                {
                    string wLFuncRet = aXmlNode.Attributes[RldConst.FilterData.ATT_ITEM_TAG].Value;

                    if ((aXmlNode.ParentNode != null) && (aXmlNode.ParentNode.Attributes[RldConst.FilterData.ATT_ITEM_TAG] != null) &&
                        (aXmlNode.ParentNode.ParentNode != null) && (aXmlNode.ParentNode.ParentNode.Attributes[RldConst.FilterData.ATT_ITEM_TAG] != null))
                    {

                        wLFuncRet = $"{LFunc_GetFilterPathRecursive(aXmlNode.ParentNode)}{RldConst.FilterData.SPLITSTR_FILTER}{wLFuncRet}";

                    }

                    return wLFuncRet;
                }

            }
            finally
            {
            }

            return wRet;
        }

        /// <summary>
        /// 帳票定義ファイルデータ(テンプレート繰返し部)の作成を行います。
        /// </summary>
        /// <param name="aTargetElement">テンプレート繰返しノードを追加する追加先要素</param>
        /// <param name="aTempleteData">テンプレート繰り返しデータ</param>
        /// <returns>作成に成功した場合 True。例外発生した場合 False。</returns>
        private bool CreateData_Templete(System.Xml.XmlElement aTargetElement, DesignTempleteData aTempleteData)
        {
            bool wRet = false;

            try
            {
                // テンプレート繰返しノード追加
                var wTmplNode = this.XmlDoc.CreateElement(RldConst.ReportDefine.TAG_TEMPLETE);

                // テンプレート繰返し設定データがある場合
                if (aTempleteData != null && !string.IsNullOrEmpty(aTempleteData.Range))
                {

                    int wRepeatMax = RldLib.ConvertStrToInt32(aTempleteData.RepeatCountH, false) * RldLib.ConvertStrToInt32(aTempleteData.RepeatCountV, false);

                    wTmplNode.SetAttribute(RldConst.ReportDefine.ATT_TEMPLETE_ID, aTempleteData.Range);
                    wTmplNode.SetAttribute(RldConst.ReportDefine.ATT_TEMPLETE_REPEATMODE, aTempleteData.RepeatMode);
                    //add #8763 zhu start
                    wTmplNode.SetAttribute(RldConst.ReportDefine.ATT_TEMPLETE_REPEATNO, getRepeatNo(aTempleteData.RepeatMode));
                    //add #8763 zhu end
                    // add 2020-12-18 FNSI-改修 ファイル保存のExcel出力不正 夏 start
                    wTmplNode.SetAttribute(RldConst.ReportDefine.ATT_TEMPLETE_REPEAT_COUNTH, aTempleteData.RepeatCountH);
                    wTmplNode.SetAttribute(RldConst.ReportDefine.ATT_TEMPLETE_REPEAT_COUNTV, aTempleteData.RepeatCountV);
                    wTmplNode.SetAttribute(RldConst.ReportDefine.ATT_TEMPLETE_MARGINV, aTempleteData.MarginV);
                    wTmplNode.SetAttribute(RldConst.ReportDefine.ATT_TEMPLETE_MARGINH, aTempleteData.MarginH);
                    // add 2020-12-18 FNSI-改修 ファイル保存のExcel出力不正 夏 end
                    wTmplNode.SetAttribute(RldConst.ReportDefine.ATT_TEMPLETE_REPEATMAX, wRepeatMax.ToString());
                    wTmplNode.SetAttribute(RldConst.ReportDefine.ATT_TEMPLETE_ISNEWPAGE, aTempleteData.IsNewPage == RldConst.TempleteData.VAL_ISNEWPAGE_TRUE ? RldConst.ReportDefine.VAL_TEMPLETE_ISNEWPAGE_TRUE : RldConst.ReportDefine.VAL_TEMPLETE_ISNEWPAGE_FALSE);

                    // 繰り返し方向 N型の場合 0。Z型の場合 1。
                    wTmplNode.SetAttribute("direction", aTempleteData.DirectionData == RldConst.TempleteData.VAL_DIRECTION_N ? "0" : "1");

                    if (RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_LABEL)
                    {
                        // 帳票種別がラベルの場合
                        // 1ラベル1レコードとなるSQL文のSQLコードをbaseSqlCd属性に指定する

                        // 分類別情報のパラメータを取得する列挙子
                        IEnumerable<DesignItemListData> enumerator = RldLib.CurrentLayoutData.DataItemList.Where(n => IsClassficationInfo(n.DataCategory, n.DataClass, n.DataName));

                        if (enumerator.Count() > 0)
                        {
                            // 分類別情報のパラメータが存在する

                            // ベースレコードのSQLコードを設定する
                            string sqlCode = enumerator.First().SqlCode;
                            wTmplNode.SetAttribute("baseSqlCd", sqlCode);

                            // 結合先レコードのSQLコードを設定する
                            // 分類別情報の候補項目が設定されいない方のSQLコードを返す列挙子
                            IEnumerable<DesignItemListData> enumeratorJoin = RldLib.CurrentLayoutData.DataItemList.Where(n => !n.SqlCode.Equals(sqlCode));
                            if (enumeratorJoin.Count() > 0)
                            {
                                wTmplNode.SetAttribute("joinSqlCd", enumeratorJoin.First().SqlCode);
                            }

                            // add 2021-08-06 #5981:ラベルが検査に対応していないの対応 孫 start
                            // 配置されているパラメータがあり場合、結合先レコードのSQLコードを再設定する
                            // del #7949 「帳票種別：ラベル　sqlcode=16とsqlcode=17の項目を1つの帳票に設定すると、保存できない」 商 start
                            //var wParamsNode = aTargetElement.GetElementsByTagName(RldConst.ReportDefine.TAG_PARAM);
                            //for (int i = 0; i < wParamsNode.Count; i++)
                            //{
                            //    string joinSqlCd = wParamsNode[i].Attributes.GetNamedItem(RldConst.ReportDefine.ATT_PARAM_SQLCODE).Value;
                            //    if (string.IsNullOrEmpty(joinSqlCd) || (!string.IsNullOrEmpty(joinSqlCd) && joinSqlCd.Equals(sqlCode)) )
                            //    {
                            //        continue;
                            //    }
                            //    else
                            //    {
                            //        wTmplNode.SetAttribute("joinSqlCd", joinSqlCd);
                            //        break;
                            //    }
                            //}
                            // del #7949 「帳票種別：ラベル　sqlcode=16とsqlcode=17の項目を1つの帳票に設定すると、保存できない」 商 end
                            // add 2021-08-06 #5981:ラベルが検査に対応していないの対応 孫 end
                        }
                    }

                }

                // ルート要素へテンプレート繰返しノードを追加
                aTargetElement.AppendChild(wTmplNode);

                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }

            return wRet;
        }
        //add 8763-3 zhu start
        private string getRepeatNo(string repeatMode)
        {
            switch (repeatMode)
            {
                case "Dialysis":
                    return "ord_no";
                case "Examin":
                    return "exam_main_cd";
                case "issue_date":
                    return "ord_prescription_no";
                case "reg_rad_date":
                    return "rad_result_cd";
                case "mainte_date":
                    return "mainte_no";
                // add #10605 観察記録がテンプレート繰返しされない 高 start
                case "event_start_date":
                    return "pat_event_cd";
                // add #10605 観察記録がテンプレート繰返しされない 高 end
            }
            return ""; 
        }
        //add 8763-3 zhu end
        #endregion
    }
}
