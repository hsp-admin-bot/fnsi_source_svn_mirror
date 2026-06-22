using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using RldUtility = LayoutDesignerUtilityLib.LayoutDesignerUtility;

namespace LayoutDesigner
{
    // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
    public class SortableBindingList<T> : BindingList<T>
    {
        private bool _isSorted;
        private ListSortDirection _sortDirection = ListSortDirection.Ascending;
        private PropertyDescriptor _sortProperty;

        public event Action RequestRefreshGroupUI;

        // sort core
        protected override bool SupportsSortingCore => true;
        protected override bool IsSortedCore => _isSorted;
        protected override ListSortDirection SortDirectionCore => _sortDirection;
        protected override PropertyDescriptor SortPropertyCore => _sortProperty;

        // datagridview sort
        protected override void ApplySortCore(PropertyDescriptor prop, ListSortDirection direction)
        {
            _sortProperty = prop;
            _sortDirection = direction;
            _isSorted = true;

            var items = this.Items as List<DesignGroupData>;
            if (items == null || items.Count == 0) return;

            // 
            if (prop.Name == nameof(DesignGroupData.ButtonEditFilterText)        // フィルタ
                )
            {
                items.Sort((lhs, rhs) =>
                {
                    int result = CompareButtonColumn(lhs, rhs, prop.Name);
                    return direction == ListSortDirection.Ascending ? result : -result;
                });
            }
            else if (prop.Name == nameof(DesignGroupData.IsNewPage)
                )
            {
                items.Sort((lhs, rhs) =>
                {
                    int result = CompareCheckBoxColumn(lhs, rhs, prop.Name);
                    return direction == ListSortDirection.Ascending ? result : -result;
                });
            }
            else
            {
                items.Sort((x, y) =>
                {
                    var valueX = prop.GetValue(x);
                    var valueY = prop.GetValue(y);

                    if (valueX == null && valueY == null) return 0;
                    if (valueX == null) return -1;
                    if (valueY == null) return 1;

                    return ((IComparable)valueX).CompareTo(valueY) * (direction == ListSortDirection.Ascending ? 1 : -1);
                });
            }

            RequestRefreshGroupUI?.Invoke();
        }

        // button sort
        private int CompareButtonColumn(DesignGroupData lhs, DesignGroupData rhs, string propertyName)
        {
            // get state of button
            bool lhsHasButton = HasButtonContent(lhs, propertyName);
            bool rhsHasButton = HasButtonContent(rhs, propertyName);

            // sort
            if (lhsHasButton && !rhsHasButton) return -1;
            if (!lhsHasButton && rhsHasButton) return 1;

            return 0;
        }

        // check state of display button
        private bool HasButtonContent(DesignGroupData data, string propertyName)
        {
            switch (propertyName)
            {
                // if diaplay button
                case nameof(DesignGroupData.ButtonEditFilterText):          // フィルタ
                    if (string.IsNullOrEmpty(data.FilterState)) return false;
                    return data.CanEditFilter;
                default:
                    // other
                    var value = data.GetType().GetProperty(propertyName)?.GetValue(data);
                    return value != null && !string.IsNullOrEmpty(value.ToString());
            }
        }

        // checkbo
        private enum CheckBoxState
        {
            Checked = 0,
            Unchecked = 1,
            NoCheckBox = 2
        }

        // checkbox sort
        private int CompareCheckBoxColumn(DesignGroupData lhs, DesignGroupData rhs, string propertyName)
        {
            CheckBoxState lhsState = GetCheckBoxState(lhs, propertyName);
            CheckBoxState rhsState = GetCheckBoxState(rhs, propertyName);

            // sort: Checked(0) < Unchecked(1) < NoCheckBox(2)
            return lhsState.CompareTo(rhsState);
        }

        // get state of checkbox
        private CheckBoxState GetCheckBoxState(DesignGroupData data, string propertyName)
        {
            // have checkbox?
            if (!HasCheckBoxFunction(data, propertyName))
            {
                return CheckBoxState.NoCheckBox;
            }

            // checked of checkbox
            return IsCheckBoxChecked(data, propertyName) ?
                CheckBoxState.Checked : CheckBoxState.Unchecked;
        }

        // have checkbox?
        private bool HasCheckBoxFunction(DesignGroupData data, string propertyName)
        {
            switch (propertyName)
            {
                case nameof(DesignGroupData.IsNewPage):
                    return data.CanEditNewPage;
                default:
                    return true;
            }
        }

        // checked of checkbox?
        private bool IsCheckBoxChecked(DesignGroupData data, string propertyName)
        {
            switch (propertyName)
            {
                case nameof(DesignGroupData.IsNewPage):
                    return data.IsNewPage == RldConst.GroupData.VAL_ISNEWPAGE_TRUE;
                default:
                    return GetGenericCheckBoxValue(data, propertyName);
            }
        }

        // custom checkbox
        private bool GetGenericCheckBoxValue(DesignGroupData data, string propertyName)
        {
            var value = data.GetType().GetProperty(propertyName)?.GetValue(data);

            if (value is bool boolValue) return boolValue;
            if (value is string stringValue)
                return stringValue == RldConst.GroupData.VAL_ISNEWPAGE_TRUE;

            return false;
        }

        // remove sort
        protected override void RemoveSortCore()
        {
            _isSorted = false;
            _sortDirection = ListSortDirection.Ascending;
            _sortProperty = null;
        }
    }
    // add #11501 レイアウトデザイナのユーザビリティ改善 高 end

    /// <summary>
    /// レイアウトデータセットクラス
    /// </summary>
    public class LayoutDataSet
    {
        #region メンバ列挙体定義

        #endregion

        #region メンバ定数定義
        #endregion

        #region 生成と破棄

        /// <summary>
        /// レイアウトデータセットの新しいインスタンスを初期化します。
        /// </summary>
        public LayoutDataSet() { }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 設定データの取得及び設定を行います。
        /// </summary>
        public DesignSettingData DesignSettingData { get; set; } = null;

        /// <summary>
        /// データ項目一覧の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public System.ComponentModel.BindingList<DesignItemListData> DataItemList { get; } = new System.ComponentModel.BindingList<DesignItemListData>();

        // add 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 start
        /// <summary>
        /// 変換用データ項目一覧の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public System.ComponentModel.BindingList<DesignItemConvertListData> DataItemConvertList { get; } = new System.ComponentModel.BindingList<DesignItemConvertListData>();

        /// <summary>
        /// 旧帳票のパラメータ編集データの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public System.ComponentModel.BindingList<DesignParamFromOldReportData> DataParamFromOldReportList { get; } = new System.ComponentModel.BindingList<DesignParamFromOldReportData>();

        /// <summary>
        /// 旧帳票のグループ編集データの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public System.ComponentModel.BindingList<DesignGroupFromOldReportData> DataGroupFromOldReportList { get; } = new System.ComponentModel.BindingList<DesignGroupFromOldReportData>();
        // add 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 end

        /// <summary>
        /// グループ編集データの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 start
        //public System.ComponentModel.BindingList<DesignGroupData> DesignGroupList { get; } = new System.ComponentModel.BindingList<DesignGroupData>();
        public SortableBindingList<DesignGroupData> DesignGroupList { get; } = new SortableBindingList<DesignGroupData>();
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 end

        /// <summary>
        /// パラメータ編集データの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public DesignParamDatasList DesignParamList { get; } = new DesignParamDatasList();

        /// <summary>
        /// テンプレート繰返しデータの取得及び設定を行います。
        /// </summary>
        public DesignTempleteData DesignTempleteData { get; set; } = null;
        // del 2023-03-22 #8455 【デグレ】グループ情報がクリアされてしまう 鵬 start
        ////and 2019-11-08 #5601 分類タイプ  鄭 start
        //public string FilterData;
        //public string sGroupName;
        ////and 2019-11-08 #5601 分類タイプ  鄭 end
        // del 2023-03-22 #8455 鵬 end

        // add #9651 帳票表示項目の並び順を変更する 高 start
        /// <summary>
        /// 帳票表示項目の並び順項目一覧の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public System.ComponentModel.BindingList<DesignItemListDataOrder> DataItemOrderList { get; } = new System.ComponentModel.BindingList<DesignItemListDataOrder>();
        // add #9651 帳票表示項目の並び順を変更する 高 end

        // add #12616 データ項目の縮小表示が機能しないことがある 高 start
        public string lastSelectAddr = string.Empty;
        // add #12616 データ項目の縮小表示が機能しないことがある 高 end

        #endregion

        #region メンバ関数定義(パラメータ編集データ操作)

        /// <summary>
        /// データ項目リストを元にパラメータ編集データを作成します。
        /// </summary>
        /// <param name="aDataPath"></param>
        /// <returns></returns>
        public DesignParamData CreateDesignParamData(String aDataPath, String aCellA1FormatAddress)
        {
            DesignParamData wRet = null;

            try
            {
                Boolean wPredicate(DesignItemListData ele) => (ele.DataPath == aDataPath);

                // 検索件数を取得
                Int32 wCount = this.DataItemList.Count(wPredicate);

                // 該当データが1件の場合
                if (wCount == 1)
                {
                    var wFindResult = this.DataItemList.Single(wPredicate);

                    wRet = new DesignParamData()
                    {
                        DataPath = aDataPath,
                        DataCategory = wFindResult.DataCategory,
                        DataClass = wFindResult.DataClass,
                        DataName = wFindResult.DataName,
                        SqlCode = wFindResult.SqlCode,
                        DataCode = wFindResult.DataCode,
                        DataType = wFindResult.DataType,
                        PreviewData = wFindResult.PreviewData,
                        DisplayFormat = wFindResult.DisplayFormat,
                        ConvertList = wFindResult.ConvertList,
                        CanRepeat = wFindResult.CanRepeat,
                        RepeatAddress = wFindResult.CanRepeat ? aCellA1FormatAddress : String.Empty,
                        FilterType = wFindResult.FilterType,
                        CellAddress = aCellA1FormatAddress,
                        GroupName = wFindResult.GroupName,
                        ParticularInfo = wFindResult.ParticularInfo,
                        // add 2021-08-30 6009画像 李 start
                        IsImage = wFindResult.IsImage
                        // add 2021-08-30 6009画像 李 end                     
                    };
                }
                // 該当データが見つからない場合
                else if (wCount == 0)
                {

                    // 計算式の場合
                    if (aDataPath.StartsWith(RldConst.CALC_HEADER))
                    {
                        // add radmain #5277 鄧シン start
                        DesignParamDatasList designParamList = RldLib.CurrentLayoutData.DesignParamList;
                        System.ComponentModel.BindingList<DesignItemListData> dataItemList = RldLib.CurrentLayoutData.DataItemList;
                        // mod #12476 FNW帳票取込に莫大な時間がかかることがある 高 start
                        //RldExcelHelper rldExcelHelper = new RldExcelHelper();
                        RldExcelHelper rldExcelHelper = new RldExcelHelper(false);
                        // mod #12476 FNW帳票取込に莫大な時間がかかることがある 高 end
                        // 計算式の場合、プレビューデータを計算する。
                        string previewData = rldExcelHelper.ReSetCalcResult(aDataPath, designParamList, dataItemList);
                        // add radmain #5277 鄧シン end
                        wRet = new DesignParamData()
                        {
                            DataPath = aDataPath,
                            //mod 6720 EXCEL関数で使用できないものがある 吉 start
                            //DataType = RldConst.ParamData.VAL_DATATYPE_DECIMAL,
                            DataType = RldConst.ParamData.VAL_DATATYPE_STRING,
                            //mod 6720 EXCEL関数で使用できないものがある 吉 end
                            // mod radmain #5277 鄧シン start
                            //PreviewData = "0",
                            PreviewData = previewData,
                            // mod radmain #5277 鄧シン end
                            //mod 6720 EXCEL関数で使用できないものがある 吉 start
                            //DisplayFormat = "0",
                            DisplayFormat = "",
                            //mod 6720 EXCEL関数で使用できないものがある 吉 end
                            CanRepeat = false,
                            CellAddress = aCellA1FormatAddress,
                            // add #11535 帳票の汎用バーコード出力対応 高 start
                            CanBarCode = true,
                            // add #11535 帳票の汎用バーコード出力対応 高 end
                            IsCalcResult = true
                        };
                        // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 start
                        string dataType = this.GetFreeDataType(aDataPath);
                        // mod #8335 FNW帳票取込みの動作に問題あり 夏 start
                        //if (RldConst.ParamData.VAL_DATATYPE_DECIMAL.Equals(dataType))
                        if (String.IsNullOrEmpty(dataType) || RldConst.ParamData.VAL_DATATYPE_DECIMAL.Equals(dataType))
                        // mod #8335 FNW帳票取込みの動作に問題あり 夏 end
                        {
                            wRet.DataType = RldConst.ParamData.VAL_DATATYPE_DECIMAL;
                            // mod #11535 帳票の汎用バーコード出力対応 高 start
                            //wRet.DisplayFormat = "0";
                            wRet.DisplayFormat = "G/標準";
                            // mod #11535 帳票の汎用バーコード出力対応 高 end
                        }
                        // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 end
                    }

                    // add 2023-03-20 #8335 FNW帳票取込みの動作に問題あり 鵬 start
                    else if (aDataPath.StartsWith(RldConst.PATH_HEADER))
                    {
                        wRet = new DesignParamData()
                        {
                            DataPath = aDataPath,
                            RepeatAddress = String.Empty,
                            CellAddress = aCellA1FormatAddress,
                        };
                    }
                    // add 2023-03-20 #8335 鵬 end
                }
                // 複数件見つかった場合
                else
                {
                    System.Diagnostics.Debug.Assert(false);
                }

                // フィルタ状態を更新
                //edit #9602 デグレ】フィルタ設定に関する不具合2点 dongzhaolong start
                if (wRet != null && wRet.CanEditFilter)
                {
                    switch (wRet.FilterType)
                    {
                        case RldConst.FilterType.Parameter.MEDICINE:         // 検査項目フィルタ
                            wRet.FilterData = "<SelectSetting><Item tag=\"Medicine\" checkState=\"Checked\" /></SelectSetting>";
                            wRet.FilterState = RldConst.GroupData.VAL_FILTER_STATE_ALL;
                            break;
                        case RldConst.FilterType.Parameter.EQUIP:            // 検査セットフィルタ
                            wRet.FilterData = "<SelectSetting><Item tag=\"Equipment\" checkState=\"Checked\" /></SelectSetting>";
                            wRet.FilterState = RldConst.GroupData.VAL_FILTER_STATE_ALL;
                            break;
                        // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
                        case RldConst.FilterType.Parameter.CATEGORY:
                            wRet.FilterData = "<SelectSetting><Item tag=\"Category\" checkState=\"Checked\" /></SelectSetting>";
                            wRet.FilterState = RldConst.GroupData.VAL_FILTER_STATE_ALL;
                            break;
                        // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end
                        default:
                            wRet.FilterState = RldConst.ParamData.VAL_FILTER_STATE_NO;
                            break;
                    }

                }
                //edit #9602 デグレ】フィルタ設定に関する不具合2点 dongzhaolong start
            }
            catch
            {
                throw;
            }

            return wRet;
        }

        public string CreateDesignParamDataStr(String aDataPath, String aCellA1FormatAddress)
        {
            string res = "";
            Boolean wPredicate(DesignItemListData ele) => (ele.DataPath == aDataPath);

            // 検索件数を取得
            Int32 wCount = this.DataItemList.Count(wPredicate);

            // 該当データが1件の場合
            if (wCount == 1)
            {
                var wFindResult = this.DataItemList.Single(wPredicate);
                res = wFindResult.IsImage;
            }
            return res;
        }

        /// <summary>
        /// データ項目リストを元にパラメータ編集データを更新します。
        /// </summary>
        /// <param name="aChangedItems"></param>
        /// <returns></returns>
        public Boolean UpdateDesignParam(out List<DesignParamData> aChangedItems)
        {
            Boolean wRet = false;

            aChangedItems = new List<DesignParamData>();

            try
            {
                foreach (var wData in this.DesignParamList)
                {
                    if ((this.DataItemList.Count(ele => ele.DataPath == wData.DataPath) is Int32 wCount) && wCount == 1)
                    {
                        var wItem = this.DataItemList.Single(ele => ele.DataPath == wData.DataPath);

                        // sqlCode か dataCode が変更されている場合は更新する
                        if (wItem.SqlCode != wData.SqlCode || wItem.DataCode != wData.DataCode)
                        {
                            // 変更リストへ追加
                            aChangedItems.Add(new DesignParamData(wData));
                            // 更新
                            wData.SqlCode = wItem.SqlCode;
                            wData.DataCode = wItem.DataCode;
                        }
                    }
                    else
                    {
                        // 以下の何れかに該当する
                        // 設定されているパラメータがデータ項目リストから削除された場合
                        // カテゴリ/クラス/項目名が同一のデータがデータ項目リスト内に存在する場合
                    }
                }

                // ここまでくればOK
                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }

            return wRet;
        }

        /// <summary>
        /// パラメータ編集データを検索して取得します。
        /// </summary>
        /// <param name="aCellA1FormatAddress"></param>
        /// <returns></returns>
        public DesignParamData FindDesignParamData(String aCellA1FormatAddress)
        {
            DesignParamData wRet = null;
            Boolean wPredicate(DesignParamData ele) => ele.CellAddress == aCellA1FormatAddress;

            if (this.DesignParamList.Count(wPredicate) == 1)
                wRet = this.DesignParamList.Single(wPredicate);

            return wRet;
        }

        /// <summary>
        /// パラメータ編集データを検索して見つかったインデックスを取得します。
        /// 見つからなかった場合は -1 を返します。
        /// </summary>
        /// <param name="aCellA1FormatAddress"></param>
        /// <returns></returns>
        public Int32 FindDesignParamDataIndex(String aCellA1FormatAddress)
        {
            Int32 wRet = -1;

            DesignParamData wData = null;
            if ((wData = this.FindDesignParamData(aCellA1FormatAddress)) != null)
                wRet = this.DesignParamList.IndexOf(wData);

            return wRet;
        }

        /// <summary>
        /// パラメータ編集データを追加します。
        /// </summary>
        /// <param name="aData"></param>
        /// <returns></returns>
        public Boolean AddDesignParamData(DesignParamData aData)
        {
            // mod 2020-08-05 FNSI-仕様修正 修正パラメータを空にするバグ問題 李 start
            if (aData == null)
                return false;
            // mod 2020-08-05 FNSI-仕様修正 修正パラメータを空にするバグ問題 李 end

            Boolean wRet = false;
            //add #8615 zhu start
            //del #9602 デグレ】フィルタ設定に関する不具合2点 dongzhaolong start
            //add #8615 zhu start
            //foreach (var wData in RldLib.CurrentLayoutData.DesignGroupList)
            //{
            //    if (wData.GroupName == aData.GroupName)
            //    {
            //        aData.FilterData = wData.FilterData;
            //        aData.FilterState = wData.FilterState;
            //        aData.FilterType = wData.FilterType;
            //    }
            //}
            //add #8615 zhu end
            //del #9602 デグレ】フィルタ設定に関する不具合2点 dongzhaolong end
            try
            {
                // 追加するパラメータ編集データが繰返し可能項目の場合
                // add #8314 グループタブの表示不正 王占宇 start
                this.DesignParamList.Add(aData);
                // add #8314 グループタブの表示不正 王占宇 end
                if (aData.CanRepeat)
                    // グループが存在するか確認し無ければ追加する
                    if (!this.CreateAndAddDesignGroupData(aData))
                        return false;

                // リストへ追加
                // del #8314 グループタブの表示不正 王占宇 start
                //this.DesignParamList.Add(aData);
                // del #8314 グループタブの表示不正 王占宇 end

                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }

            return wRet;
        }

        /// <summary>
        /// 指定されたインデックスのパラメータ編集データを更新します。
        /// </summary>
        /// <param name="aData">新たにセットするパラメータ編集データ</param>
        /// <param name="aIndex">セットするインデックス</param>
        /// <returns></returns>
        public Boolean SetDesignParamData(DesignParamData aData, Int32 aIndex)
        {
            Boolean wRet = false;

            try
            {
                // 登録済のデータを取得
                DesignParamData wOldData = this.DesignParamList[aIndex];

                // 繰返し可能項目の場合
                if (wOldData != null && wOldData.CanRepeat)
                    // 他に所属するパラメータがない場合はグループを削除する
                    if (!this.RemoveNonReferGroupData(wOldData))
                        return false;

                // mod 2023-03-22 #8455 【デグレ】グループ情報がクリアされてしまう 鵬 start
                // 該当インデックスのデータを更新
                this.DesignParamList[aIndex] = aData;

                // セットするパラメータ編集データが繰返し可能項目の場合
                if (aData.CanRepeat)
                    // グループが存在するか確認し無ければ追加する
                    if (!this.CreateAndAddDesignGroupData(aData))
                        return false;

                //// 該当インデックスのデータを更新
                //this.DesignParamList[aIndex] = aData;
                // mod 2023-03-22 #8455 鵬 end

                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }

            return wRet;
        }

        // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 start
        /// <summary>
        /// 指定されたインデックスのパラメータデータリストを設定します。
        /// </summary>
        /// <param name="index">セットするインデックス</param>
        /// <param name="isShrink">縮小表示</param>
        // mod 8394 動作に関する指摘 吉 start
        // public void SetDesignParamDataList(Int32 index, Boolean isShrink)
        //modify #8586,#8457 表示文字列長の設定、およびフリー計算パラメータの書式設定について dongzhaolong start
        public void SetDesignParamDataList(Int32 index, Boolean isShrink, String format, Boolean reCalc = true)
        //modify #8586,#8457 表示文字列長の設定、およびフリー計算パラメータの書式設定について dongzhaolong end
        // mod 8394 動作に関する指摘 吉 end
        {
            try
            {
                // mod 6438 ログファイルアップロード処理に失敗する 姜 start
                /*// 登録済のデータを取得
                DesignParamData aData = this.DesignParamList[index];

                // 縮小表示設定
                if ((isShrink == true && aData.IsShrink.Equals(RldConst.ParamData.VAL_ISSHRINK_NONE))
                    || (isShrink == false && aData.IsShrink.Equals(RldConst.ParamData.VAL_ISSHRINK_DONE)))
                {
                    aData.IsShrink = isShrink ? RldConst.ParamData.VAL_ISSHRINK_DONE : RldConst.ParamData.VAL_ISSHRINK_NONE;
                }
                // フィルタ設定
                // mod #8335 FNW帳票取込みの動作に問題あり 夏 start
                //if (!String.IsNullOrEmpty(aData.FilterType) && String.IsNullOrEmpty(aData.FilterState))
                if (!String.IsNullOrEmpty(aData.FilterType) 
                    && String.IsNullOrEmpty(aData.FilterState)
                    && aData.CanEditFilter)
                // mod #8335 FNW帳票取込みの動作に問題あり 夏 end
                {
                    aData.FilterState = RldConst.ParamData.VAL_FILTER_STATE_YES;
                }
                // add 8394 動作に関する指摘 吉 start
                aData.DisplayFormat = format;
                // add 8394 動作に関する指摘 吉 end
                // 該当インデックスのデータを更新
                this.DesignParamList[index] = aData;*/

                // 縮小表示設定
                // del #8394(1) 動作に関する指摘 luantian start
                //if ((isShrink == true && aData.IsShrink.Equals(RldConst.ParamData.VAL_ISSHRINK_NONE))
                //    || (isShrink == false && aData.IsShrink.Equals(RldConst.ParamData.VAL_ISSHRINK_DONE)))
                // del #8394(1) 動作に関する指摘 luantian start
                {
                    //modify #8586,#8457 表示文字列長の設定、およびフリー計算パラメータの書式設定について dongzhaolong start
                    if (reCalc == false)
                    {
                        string length = this.DesignParamList[index].Length;
                        this.DesignParamList[index].IsShrink = isShrink ? RldConst.ParamData.VAL_ISSHRINK_DONE : RldConst.ParamData.VAL_ISSHRINK_NONE;
                        this.DesignParamList[index].Length = length;
                    }
                    else
                    {
                        this.DesignParamList[index].IsShrink = isShrink ? RldConst.ParamData.VAL_ISSHRINK_DONE : RldConst.ParamData.VAL_ISSHRINK_NONE;
                    }
                    //modify #8586,#8457 表示文字列長の設定、およびフリー計算パラメータの書式設定について dongzhaolong end
                }
                // フィルタ設定
                if (!String.IsNullOrEmpty(this.DesignParamList[index].FilterType)
                    && String.IsNullOrEmpty(this.DesignParamList[index].FilterState)
                    && this.DesignParamList[index].CanEditFilter)

                {
                    this.DesignParamList[index].FilterState = RldConst.ParamData.VAL_FILTER_STATE_YES;
                }
                // add #10469 単患者帳票で「印刷日時」の書式が反映されない limingzhe start
                if (format.Equals("gyy/m") || format.Equals("ge/m")) format = "gy/m";
                // add #10469 単患者帳票で「印刷日時」の書式が反映されない limingzhe end
                if (!this.DesignParamList[index].DisplayFormat.Equals(format))
                {
                    try
                    {
                        this.DesignParamList[index].DisplayFormat = format;
                    }
                    catch
                    {
                        if ("G/通用格式".Equals(this.DesignParamList[index].DisplayFormat))
                        {
                            return;
                        }
                    }

                }
                // mod 6438 ログファイルアップロード処理に失敗する 姜 end

            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }
        }

        /// <summary>
        /// 指定されたインデックスのパラメータデータリストの繰り返しを設定します。
        /// </summary>
        /// <param name="index">セットするインデックス</param>
        /// <param name="repeatAddressList">繰り返しリスト</param>
        public void SetDesignParamDataListForRepeat(Int32 index, List<String> repeatAddressList)
        {
            try
            {
                // 登録済のデータを取得
                DesignParamData aData = this.DesignParamList[index];

                string repeatAddress = "";
                for (int i = 0; i < repeatAddressList.Count; i++)
                {
                    if (i == 0)
                    {
                        repeatAddress = repeatAddressList[i];
                    }
                    else
                    {
                        repeatAddress = repeatAddress + "," + repeatAddressList[i];
                    }
                }

                if (!repeatAddress.Equals(aData.RepeatAddress))
                {
                    aData.RepeatAddress = repeatAddress;
                }

                // 該当インデックスのデータを更新
                this.DesignParamList[index] = aData;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }
        }

        /// <summary>
        /// 指定されたセルアドレスのパラメータデータリストを削除します。
        /// </summary>
        /// <param name="cellAddress">セルアドレス</param>
        public void DelDesignParamDataListByCellAddress(String cellAddress)
        {
            try
            {
                for (int index = 0; index < this.DesignParamList.Count; index++)
                {
                    // 登録済のデータを取得
                    DesignParamData aData = this.DesignParamList[index];

                    if (cellAddress.Equals(aData.CellAddress))
                    {
                        // 該当データを削除
                        this.RemoveDesignParamData(aData);
                        break;
                    }
                }
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }
        }

        /// <summary>
        /// 指定されたデータパスの計算式のデータ種類を取得します。
        /// </summary>
        /// <param name="dataPath">データパス</param>
        private string GetFreeDataType(String dataPath)
        {
            string dataType = string.Empty;
            string newDataPath = string.Empty;
            int fromIndex = 0;
            int toIndex = 0;

            fromIndex = dataPath.IndexOf("[");
            toIndex = dataPath.IndexOf("]");

            if (fromIndex >= 0 && toIndex > fromIndex)
            {
                newDataPath = dataPath.Substring(fromIndex + 1, toIndex - fromIndex - 1);
            }

            if (newDataPath.StartsWith(RldConst.PATH_HEADER))
            {
                Boolean wPredicate(DesignItemListData ele) => (ele.DataPath == newDataPath);

                // 検索件数を取得
                Int32 wCount = this.DataItemList.Count(wPredicate);

                // 該当データが1件の場合
                if (wCount == 1)
                {
                    var wFindResult = this.DataItemList.Single(wPredicate);

                    dataType = wFindResult.DataType;
                }
            }

            return dataType;
        }
        // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 end

        /// <summary>
        /// 指定されたパラメータ編集データを削除します。
        /// </summary>
        /// <param name="aData"></param>
        /// <returns></returns>
        public Boolean RemoveDesignParamData(DesignParamData aData)
        {
            // null の場合は成功とする
            if (aData == null) return true;

            Boolean wRet = false;

            try
            {
                // 繰返し可能項目の場合
                if (aData.CanRepeat)
                    // 他に所属するパラメータがない場合はグループを削除する
                    if (!this.RemoveNonReferGroupData(aData))
                        return false;

                // 該当データを削除
                this.DesignParamList.Remove(aData);

                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }

            return wRet;
        }

        #endregion

        #region メンバ関数定義(グループデータ操作)

        /// <summary>
        /// パラメータ編集データからグループ編集データを作成します。
        /// </summary>
        /// <param name="aParam"></param>
        /// <returns></returns>
        private DesignGroupData CreateDesignGroupData(DesignParamData aParam)
        {
            DesignGroupData wRet = null;

            try
            {
                wRet = new DesignGroupData()
                {
                    GroupPath = aParam.GroupPath,
                    DataCategory = aParam.DataCategory,
                    DataClass = aParam.DataClass,
                    GroupName = aParam.GroupName,

                    // mod #6066 FNW帳票移行時にグループ名が移行されていない。 董 start
                    //IsNewPage = String.Empty,
                    IsNewPage = aParam.IsNewPage,
                    // mod #6066 FNW帳票移行時にグループ名が移行されていない。 董 end

                    FilterType = aParam.FilterType,
                    RepeatCount = aParam.RepeatCount,
                    IsInTemplete = aParam.IsInTemplete
                };

                // フィルタ状態を更新
                // mod #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
                //if (wRet.CanEditFilter) wRet.FilterState = RldConst.GroupData.VAL_FILTER_STATE_ALL;
                if (wRet.CanEditFilter)
                {
                    if (wRet.FilterType == RldConst.FilterType.Group.MEDICINE)    // 薬剤
                    {
                        wRet.FilterData = "<SelectSetting><Item tag=\"Medicine\" checkState=\"Checked\" /></SelectSetting>";
                        wRet.FilterState = RldConst.GroupData.VAL_FILTER_STATE_ALL;
                        if (RldDataGridViewParamDataEditHelper.middleData.ContainsKey(wRet.GroupPath))
                        {
                            RldDataGridViewParamDataEditHelper.middleData[wRet.GroupPath] = wRet.FilterData;
                        }
                    }
                    else if (wRet.FilterType == RldConst.FilterType.Group.EQUIP)       // 医材
                    {
                        wRet.FilterData = "<SelectSetting><Item tag=\"Equipment\" checkState=\"Checked\" /></SelectSetting>";
                        wRet.FilterState = RldConst.GroupData.VAL_FILTER_STATE_ALL;
                        if (RldDataGridViewParamDataEditHelper.middleData.ContainsKey(wRet.GroupPath))
                        {
                            RldDataGridViewParamDataEditHelper.middleData[wRet.GroupPath] = wRet.FilterData;
                        }
                    }
                    else if (wRet.FilterType == RldConst.FilterType.Group.CATEGORY)
                    {
                        wRet.FilterData = "<SelectSetting><Item tag=\"Category\" checkState=\"Checked\" /></SelectSetting>";
                        wRet.FilterState = RldConst.GroupData.VAL_FILTER_STATE_ALL;
                        if (RldDataGridViewParamDataEditHelper.middleData.ContainsKey(wRet.GroupPath))
                        {
                            RldDataGridViewParamDataEditHelper.middleData[wRet.GroupPath] = wRet.FilterData;
                        }
                        //wRet.FilterState = RldConst.ParamData.VAL_FILTER_STATE_NO;
                    }
                    // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe start
                    else if (wRet.FilterType == RldConst.FilterType.Group.PECEIPT)
                    {
                        wRet.FilterData = "<SelectSetting><Item tag=\"Receipt\" checkState=\"Checked\" /></SelectSetting>";
                        wRet.FilterState = RldConst.GroupData.VAL_FILTER_STATE_ALL;
                        if (RldDataGridViewParamDataEditHelper.middleData.ContainsKey(wRet.GroupPath))
                        {
                            RldDataGridViewParamDataEditHelper.middleData[wRet.GroupPath] = wRet.FilterData;
                        }
                    }
                    // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe end
                    // add #11625 クラス「指示履歴」の仕様変更② 高 start
                    else if (wRet.FilterType == RldConst.FilterType.Group.LOGTARGET)
                    {
                        wRet.FilterData = "<SelectSetting><Item tag=\"logTarget\" checkState=\"Checked\" /></SelectSetting>";
                        wRet.FilterState = RldConst.GroupData.VAL_FILTER_STATE_ALL;
                        if (RldDataGridViewParamDataEditHelper.middleData.ContainsKey(wRet.GroupPath))
                        {
                            RldDataGridViewParamDataEditHelper.middleData[wRet.GroupPath] = wRet.FilterData;
                        }
                    }
                    // add #11625 クラス「指示履歴」の仕様変更② 高 end
                    // add #12006 感染症がフィルタできない 高 start
                    else if (wRet.FilterType == RldConst.FilterType.Group.INFECTION)
                    {
                        wRet.FilterData = "<SelectSetting><Item tag=\"Infection\" checkState=\"Checked\" /></SelectSetting>";
                        wRet.FilterState = RldConst.GroupData.VAL_FILTER_STATE_ALL;
                        if (RldDataGridViewParamDataEditHelper.middleData.ContainsKey(wRet.GroupPath))
                        {
                            RldDataGridViewParamDataEditHelper.middleData[wRet.GroupPath] = wRet.FilterData;
                        }
                    }
                    // add #12006 感染症がフィルタできない 高 end
                    // add #12756 クラス「##準備リスト.物品情報」のフィルタ設定が不十分 高 start
                    else if (wRet.FilterType == RldConst.FilterType.Group.GOODS)
                    {
                        wRet.FilterData = "<SelectSetting><Item tag=\"Goods\" checkState=\"Checked\" /></SelectSetting>";
                        wRet.FilterState = RldConst.GroupData.VAL_FILTER_STATE_ALL;
                        if (RldDataGridViewParamDataEditHelper.middleData.ContainsKey(wRet.GroupPath))
                        {
                            RldDataGridViewParamDataEditHelper.middleData[wRet.GroupPath] = wRet.FilterData;
                        }
                    }
                    // add #12756 クラス「##準備リスト.物品情報」のフィルタ設定が不十分 高 end
                    // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 start
                    // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
                    else if (wRet.FilterType == RldConst.FilterType.Group.WQTESTTYPE)
                    {
                        wRet.FilterData = "<SelectSetting><Item tag=\"WQTestType\" checkState=\"Checked\" /></SelectSetting>";
                        wRet.FilterState = RldConst.GroupData.VAL_FILTER_STATE_ALL;
                        if (RldDataGridViewParamDataEditHelper.middleData.ContainsKey(wRet.GroupPath))
                        {
                            RldDataGridViewParamDataEditHelper.middleData[wRet.GroupPath] = wRet.FilterData;
                        }
                    }
                    // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
                    // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 end
                    // add #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe start
                    else if (wRet.FilterType == RldConst.FilterType.Group.EQUIP_DIA)
                    {
                        wRet.FilterData = "<SelectSetting><Item tag=\"EquipDia\" checkState=\"Checked\" /></SelectSetting>";
                        wRet.FilterState = RldConst.GroupData.VAL_FILTER_STATE_ALL;
                        if (RldDataGridViewParamDataEditHelper.middleData.ContainsKey(wRet.GroupPath))
                        {
                            RldDataGridViewParamDataEditHelper.middleData[wRet.GroupPath] = wRet.FilterData;
                        }
                    }
                    // add #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe end
                }
                // mod #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end
            }
            catch
            {
                throw;
            }

            return wRet;
        }

        /// <summary>
        /// パラメータ編集データの所属先グループが存在するか確認し、無ければ作成して追加します。
        /// 既に存在する場合は true を返します。
        /// </summary>
        /// <param name="aData"></param>
        /// <returns></returns>
        public Boolean CreateAndAddDesignGroupData(DesignParamData aData)
        {
            Boolean wRet = false;
            DesignGroupData wGroupData = null;

            try
            {
                // 繰返し可能項目ではない場合は抜ける
                if (!aData.CanRepeat) return false;

                // 所属先グループを検索して既に存在している場合は抜ける
                if ((wGroupData = this.FindDesignGroupData(aData)) != null)
                {

                    return true;
                }

                // 存在しない場合はグループを作成
                if ((wGroupData = this.CreateDesignGroupData(aData)) == null)
                {

                    return false;
                }
                // del 2023-03-22 #8455 【デグレ】グループ情報がクリアされてしまう 鵬 start
                ////and 2019-11-08 #5601 分類タイプ  鄭 start
                //wGroupData.FilterData = FilterData;

                //if (!string.IsNullOrEmpty(sGroupName))
                //{
                //    wGroupData.GroupName = sGroupName;
                //    sGroupName = string.Empty;
                //}
                ////and 2019-11-08 #5601 分類タイプ  鄭 end
                // del 2023-03-22 #8455 鵬 end
                // 正常に作成できれば追加
                if (!this.AddDesignGroupData(wGroupData))
                {

                    return false;
                }
                // add #8314 グループタブの表示不正 王占宇 start
                NewFilterDesignGroupData();
                // add #8314 グループタブの表示不正 王占宇 end

                // ここまでくればOK
                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }

            return wRet;
        }

        //add #9484 因島帳票の表示不具合（帳票種別：紹介状）dongzhaolong start
        public Boolean UpdateDesignGroupData(DesignParamData aData, bool canEdit)
        {
            Boolean wRet = false;
            DesignGroupData wGroupData = null;

            Boolean wPredicate(DesignGroupData ele) =>
                ele.GroupName == aData.GroupName && ele.IsInTemplete == aData.IsInTemplete;

            if (this.DesignGroupList.Count(wPredicate) > 0)
            {
                wGroupData = this.DesignGroupList.Single(wPredicate);
            }
            if (wGroupData != null)
            {
                wGroupData.CanEditNewPage = canEdit;
            }
            return wRet;
        }
        //add #9484 因島帳票の表示不具合（帳票種別：紹介状）dongzhaolong end

        // add #8314 グループタブの表示不正 王占宇 start
        /// <summary>
        /// パラメータ編集データの所属先グループが存在するか確認し、無ければ作成して追加します。
        /// 既に存在する場合は true を返します。
        /// </summary>
        /// <param name="aData"></param>
        /// <returns></returns>
        public Boolean NewCreateAndAddDesignGroupData(DesignParamData aData)
        {
            Boolean wRet = false;
            DesignGroupData wGroupData = null;

            try
            {
                // 繰返し可能項目ではない場合は抜ける
                if (!aData.CanRepeat) return false;

                // 所属先グループを検索して既に存在している場合は抜ける
                if ((wGroupData = this.FindDesignGroupData(aData)) != null)
                {
                    return true;
                }

                // 存在しない場合はグループを作成
                if ((wGroupData = this.CreateDesignGroupData(aData)) == null)
                {
                    return false;
                }
                // del 2023-03-22 #8455 【デグレ】グループ情報がクリアされてしまう 鵬 start
                //wGroupData.FilterData = FilterData;

                //if (!string.IsNullOrEmpty(sGroupName))
                //{
                //    wGroupData.GroupName = sGroupName;
                //    sGroupName = string.Empty;
                //}
                // del 2023-03-22 #8455 鵬 end
                // 正常に作成できれば追加
                if (!this.AddDesignGroupData(wGroupData))
                {
                    return false;
                }
                // ここまでくればOK
                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }

            return wRet;
        }

        /// <summary>
        /// グループ処理
        /// </summary>
        private void NewFilterDesignGroupData()
        {
            try
            {
                List<DesignGroupData> addTempList = new List<DesignGroupData>();
                var newList = RldLib.CurrentLayoutData.DesignGroupList.GroupBy(p => new { p.GroupName, p.IsInTemplete });
                foreach (var item in newList)
                {
                    if (this.DesignParamList.Where(p => p.GroupName == item.Key.GroupName && p.IsInTemplete == item.Key.IsInTemplete).ToList().Count > 0)
                        addTempList.Add(item.ToList()[0]);
                }
                List<DesignGroupData> itemList = new List<DesignGroupData>();
                itemList = RldLib.CurrentLayoutData.DesignGroupList.ToList();
                itemList.ForEach(p => RldLib.CurrentLayoutData.DesignGroupList.Remove(p));
                addTempList.ForEach(ele => RldLib.CurrentLayoutData.DesignGroupList.Add(ele));
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }
        }
        // add #8314 グループタブの表示不正 王占宇 end

        /// <summary>
        /// グループ編集データを検索して取得します。
        /// </summary>
        /// <param name="aParam"></param>
        /// <returns></returns>
        public DesignGroupData FindDesignGroupData(DesignParamData aParam)
        {
            DesignGroupData wRet = null;

            // mod #8314 グループタブの表示不正 王占宇 start
            // Boolean wPredicate(DesignGroupData ele) => ele.GroupPath == aParam.GroupPath;
            // if (this.DesignGroupList.Count(wPredicate) == 1)
            // mod #8314 グループタブの表示不正 王占宇 start
            // Boolean wPredicate(DesignGroupData ele) =>
            //     ele.GroupPath.Split(RldConst.PATH_SPLIT.ToCharArray()).AsQueryable().Last() == aParam.CellAddress;
            // if (this.DesignGroupList.Count(wPredicate) > 0)
            Boolean wPredicate(DesignGroupData ele) =>
                ele.GroupName == aParam.GroupName && ele.IsInTemplete == aParam.IsInTemplete;
            // mod #8314 グループタブの表示不正 王占宇 start
            // Boolean wPredicateParm(DesignParamData ele) =>
            //     ele.GroupName == aParam.GroupName && ele.IsInTemplete == aParam.IsInTemplete;
            // mod #8314 グループタブの表示不正 王占宇 end
            // if (this.DesignGroupList.Count(wPredicate) > 0 && this.DesignParamList.Count(wPredicateParm) == 1)
            if (this.DesignGroupList.Count(wPredicate) > 0)
                // mod #8314 グループタブの表示不正 王占宇 end
                // mod #8314 グループタブの表示不正 王占宇 end
                wRet = this.DesignGroupList.Single(wPredicate);

            return wRet;
        }
        // add #8314 グループタブの表示不正 王占宇 start
        /// <summary>
        /// グループ編集データを検索して取得します。
        /// </summary>
        /// <param name="aParam"></param>
        /// <returns></returns>
        public DesignGroupData FindDesignGroupDataForRemove(DesignParamData aParam)
        {
            DesignGroupData wRet = null;
            Boolean wPredicate(DesignGroupData ele) =>
                ele.GroupName == aParam.GroupName && ele.IsInTemplete == aParam.IsInTemplete;
            Boolean wPredicateParm(DesignParamData ele) =>
                ele.GroupName == aParam.GroupName && ele.IsInTemplete == aParam.IsInTemplete;
            if (this.DesignGroupList.Count(wPredicate) > 0 && this.DesignParamList.Count(wPredicateParm) == 1)
                wRet = this.DesignGroupList.Single(wPredicate);
            return wRet;
        }
        // add #8314 グループタブの表示不正 王占宇 end

        /// <summary>
        /// グループ編集データを検索して取得します。
        /// </summary>
        /// <param name="aParam"></param>
        /// <returns></returns>
        public Int32 FindDesignGroupDataIndex(DesignParamData aParam)
        {
            Int32 wRet = -1;

            DesignGroupData wData = null;
            if ((wData = this.FindDesignGroupData(aParam)) != null)
                wRet = this.DesignGroupList.IndexOf(wData);

            return wRet;
        }

        /// <summary>
        /// グループデータを追加します。
        /// </summary>
        /// <param name="aData"></param>
        /// <returns></returns>
        public Boolean AddDesignGroupData(DesignGroupData aData)
        {
            Boolean wRet = false;

            try
            {
                // リストへ追加
                this.DesignGroupList.Add(aData);

                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }

            return wRet;
        }

        /// <summary>
        /// 指定されたグループデータを削除します。
        /// </summary>
        /// <param name="aData"></param>
        /// <returns></returns>
        public Boolean RemoveDesignGroupData(DesignGroupData aData)
        {
            Boolean wRet = false;

            try
            {
                // 該当データを削除
                this.DesignGroupList.Remove(aData);

                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }

            return wRet;
        }

        /// <summary>
        /// パラメータ編集データで参照されていないグループデータを削除します。
        /// </summary>
        /// <param name="aParam"></param>
        /// <returns></returns>
        public Boolean RemoveNonReferGroupData(DesignParamData aParam)
        {
            Boolean wRet = false;

            try
            {
                // 該当データが1件以上の場合は削除する必要がないので抜ける
                // mod #8314 グループタブの表示不正 王占宇 start
                // if (this.DesignParamList.Count(ele => ele.GroupPath == aParam.GroupPath) > 1)
                if (this.DesignParamList.Count(ele => ele.CellAddress == aParam.CellAddress) > 1)
                    // mod #8314 グループタブの表示不正 王占宇 end
                    return true;

                // 該当グループを取得
                DesignGroupData wGroupData = null;
                // mod #8314 グループタブの表示不正 王占宇 start
                //if ((wGroupData = this.FindDesignGroupData(aParam)) != null)
                if ((wGroupData = this.FindDesignGroupDataForRemove(aParam)) != null)
                // mod #8314 グループタブの表示不正 王占宇 end
                {
                    // 該当データ削除
                    // del 2023-03-22 #8455 【デグレ】グループ情報がクリアされてしまう 鵬 start
                    ////and 2019-11-08 #5601 分類タイプ  鄭 start
                    //FilterData = wGroupData.FilterData;
                    ////and 2019-11-08 #5601 分類タイプ  鄭 end

                    //sGroupName = wGroupData.GroupName;
                    // del 2023-03-22 #8455 鵬 end
                    if (!this.RemoveDesignGroupData(wGroupData))
                    {
                        System.Diagnostics.Debug.Assert(false);
                        return false;
                    }
                }
                // add #8314 グループタブの表示不正 王占宇 start
                // NewFilterDesignGroupData();
                // add #8314 グループタブの表示不正 王占宇 end
                // ここまでくればOK
                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }

            return wRet;
        }

        /// <summary>
        /// パラメータ編集データで参照されていないグループデータを削除します。
        /// #6066 追加aCellAddress  鄭
        /// </summary>
        /// <param name="aDataCategory"></param>
        /// <param name="aDataClass"></param>
        /// <param name="aGroupName"></param>
        /// <param name="aIsInTemplete"></param>
        /// <param name="aCellAddress"></param>
        /// <returns></returns>
        [Obsolete()]
        public Boolean RemoveNonReferGroupData(String aDataCategory, String aDataClass, String aGroupName, String aIsInTemplete, String aCellAddress)
        {
            Boolean wRet = false;

            try
            {
                // グループパスを作成
                // mon #6066 1つの項目を増やすごとに1つの項目が増えるグループ 鄭  2022-02-08 start
                // String wGroupPath = LayoutDataSet.MakeGroupPath(aDataCategory, aDataClass, aGroupName, aIsInTemplete);
                String wGroupPath = LayoutDataSet.MakeGroupPath(aDataCategory, aDataClass, aGroupName, aIsInTemplete, aCellAddress);
                // mon #6066 1つの項目を増やすごとに1つの項目が増えるグループ 鄭  2022-02-08 end

                // 該当データが1件以上の場合は削除する必要がないので抜ける
                // mod #8314 グループタブの表示不正 王占宇 start
                // if (this.DesignParamList.Count(ele => ele.GroupPath == wGroupPath) >= 1)
                // // mod #8314 グループタブの表示不正 王占宇 start
                // if (this.DesignParamList.Count(
                //     ele => ele.CellAddress == wGroupPath.Split(RldConst.PATH_SPLIT.ToCharArray()).AsQueryable().Last()) >= 1)
                // // mod #8314 グループタブの表示不正 王占宇 end
                if (this.DesignParamList.Count(
                    ele => ele.GroupName == aGroupName && ele.IsInTemplete == aIsInTemplete) >= 1)
                    // mod #8314 グループタブの表示不正 王占宇 end
                    return true;

                // グループ存在確認
                // mod #8314 グループタブの表示不正 王占宇 start
                // if (this.DesignGroupList.Count(ele => ele.GroupPath == wGroupPath) != 1)
                // // mod #8314 グループタブの表示不正 王占宇 start
                // if (this.DesignGroupList.Count(
                //     ele => ele.GroupPath.Split(RldConst.PATH_SPLIT.ToCharArray()).AsQueryable().Last() 
                //     == wGroupPath.Split(RldConst.PATH_SPLIT.ToCharArray()).AsQueryable().Last()) != 1)
                // // mod #8314 グループタブの表示不正 王占宇 end
                if (this.DesignGroupList.Count(
                    ele => ele.GroupName == aGroupName && ele.IsInTemplete == aIsInTemplete) != 1)
                // mod #8314 グループタブの表示不正 王占宇 end
                {
                    System.Diagnostics.Debug.Assert(false);
                    return false;
                }

                // 該当グループを取得
                // mod #8314 グループタブの表示不正 王占宇 start
                // DesignGroupData wGroupData = this.DesignGroupList.Single(ele => ele.GroupPath == wGroupPath);
                // // mod #8314 グループタブの表示不正 王占宇 start
                // DesignGroupData wGroupData = this.DesignGroupList.Single(
                //    ele => ele.GroupPath.Split(RldConst.PATH_SPLIT.ToCharArray()).AsQueryable().Last()
                //    == wGroupPath.Split(RldConst.PATH_SPLIT.ToCharArray()).AsQueryable().Last());
                // // mod #8314 グループタブの表示不正 王占宇 end
                DesignGroupData wGroupData = this.DesignGroupList.Single(
                    ele => ele.GroupName == aGroupName && ele.IsInTemplete == aIsInTemplete);
                // mod #8314 グループタブの表示不正 王占宇 end

                // 該当グループ削除
                if (!this.RemoveDesignGroupData(wGroupData))
                {
                    return false;
                }

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
        /// <summary>
        /// パラメータ編集データで参照されていないグループデータを削除します。
        /// </summary>
        /// <param name="aDataCategory"></param>
        /// <param name="aDataClass"></param>
        /// <param name="aGroupName"></param>
        /// <param name="aIsInTemplete"></param>
        /// <param name="aCellAddress"></param>
        /// <returns></returns>
        public Boolean NewRemoveNonReferGroupData(String aDataCategory, String aDataClass, String aGroupName, String aIsInTemplete, String aCellAddress)
        {
            Boolean wRet = false;
            try
            {
                // グループパスを作成
                String wGroupPath = LayoutDataSet.MakeGroupPath(aDataCategory, aDataClass, aGroupName, aIsInTemplete, aCellAddress);
                if (this.DesignParamList.Count(
                    ele => ele.GroupName == aGroupName && ele.IsInTemplete == aIsInTemplete) >= 1)
                    return true;
                // 該当グループを取得
                // mod 2023-03-22 #8455 【デグレ】グループ情報がクリアされてしまう 鵬 start
                //DesignGroupData wGroupData = this.DesignGroupList.Single(
                //    ele => ele.GroupName == aGroupName && ele.IsInTemplete == aIsInTemplete);

                DesignGroupData wGroupData = this.DesignGroupList.SingleOrDefault(
                    ele => ele.GroupName == aGroupName && ele.IsInTemplete == aIsInTemplete);

                if (wGroupData != null)
                {
                    // 該当グループ削除
                    if (!this.RemoveDesignGroupData(wGroupData))
                    {
                        return false;
                    }
                }
                // mod 2023-03-22 #8455 鵬 end

                // ここまでくればOK
                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }

            return wRet;
        }
        // add #8314 グループタブの表示不正 王占宇 end

        #endregion

        #region メンバ関数定義(テンプレート繰返し)
        #endregion

        #region メンバ関数定義(その他)

        /// <summary>
        /// データパスを作成します。
        /// </summary>
        /// <param name="aDataCategory"></param>
        /// <param name="aDataClass"></param>
        /// <param name="aDataName"></param>
        /// <returns></returns>
        public static String MakeDataPath(String aDataCategory, String aDataClass, String aDataName)
        {
            if (String.IsNullOrEmpty(aDataName)) return String.Empty;
            return String.Format("{0}{1}{4}{2}{4}{3}",
                RldConst.PATH_HEADER, aDataCategory, aDataClass, aDataName, RldConst.PATH_SPLIT);
        }

        /// <summary>
        /// グループパスを作成します。
        /// #6066 1つの項目を増やすごとに1つの項目が増えるグループ   追加CellAddress  2020-02-08 鄭
        /// </summary>
        /// <param name="aDataCategory"></param>
        /// <param name="aDataClass"></param>
        /// <param name="aGroupName"></param>
        /// <param name="aIsInTemplete"></param>
        /// <param name="aCellAddress"></param>  
        /// <returns></returns>
        public static String MakeGroupPath(String aDataCategory, String aDataClass, String aGroupName, String aIsInTemplete, String aCellAddress)
        {
            if (String.IsNullOrEmpty(aGroupName)) return String.Empty;

            var wRet = String.Format("{0}{3}{1}{3}{2}", aDataCategory, aDataClass, aGroupName, RldConst.PATH_SPLIT);

            if (aIsInTemplete != RldConst.ParamData.VAL_IS_IN_TEMPLETE_NONE)
                wRet += String.Format("{0}{1}", RldConst.PATH_SPLIT, aIsInTemplete);

            // add #6066 1つの項目を増やすごとに1つの項目が増えるグループ 鄭  2020-08-02 start
            if (aCellAddress != "")
            {
                wRet += "." + aCellAddress;
            }
            // add #60661つの項目を増やすごとに1つの項目が増えるグループ  鄭 2020-08-02 end

            return wRet;
        }

        #endregion

    }
}
