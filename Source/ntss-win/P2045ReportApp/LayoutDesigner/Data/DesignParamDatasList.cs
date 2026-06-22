using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Windows.Forms;

namespace LayoutDesigner
{
    public class DesignParamDatasList : BindingList<DesignParamData>
    {
        // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
        private bool _isSorted;
        private ListSortDirection _sortDirection;
        private PropertyDescriptor _sortProperty;

        public event Action RequestRefreshParamUI;

        // sort core
        protected override bool SupportsSortingCore => true;
        protected override bool IsSortedCore => _isSorted;
        protected override ListSortDirection SortDirectionCore => _sortDirection;
        protected override PropertyDescriptor SortPropertyCore => _sortProperty;

        // dataview data sort
        protected override void ApplySortCore(PropertyDescriptor prop, ListSortDirection direction)
        {
            _sortProperty = prop;
            _sortDirection = direction;
            _isSorted = true;

            var list = Items as List<DesignParamData>;
            if (list == null || list.Count == 0) return;

            // 
            if (prop.Name == nameof(DesignParamData.ButtonEditDisplayFormatText)    // 書式変更
                || prop.Name == nameof(DesignParamData.ButtonEditConvertListText)   // 変換リスト
                || prop.Name == nameof(DesignParamData.ButtonEditRepeatText)        // 繰返
                || prop.Name == nameof(DesignParamData.ButtonEditFilterText)        // フィルタ
                || prop.Name == nameof(DesignParamData.ButtonEditLabelItemText)     // ラベル
                || prop.Name == nameof(DesignParamData.ButtonEditBarCodeText)       // バーコード
                )
            {
                list.Sort((lhs, rhs) =>
                {
                    int result = CompareButtonColumn(lhs, rhs, prop.Name);
                    return direction == ListSortDirection.Ascending ? result : -result;
                });
            }
            else if (prop.Name == nameof(DesignParamData.IsNewPage)
                )
            {
                list.Sort((lhs, rhs) =>
                {
                    int result = CompareCheckBoxColumn(lhs, rhs, prop.Name);
                    return direction == ListSortDirection.Ascending ? result : -result;
                });
            }
            // sort in Z型
            else if (prop.Name == nameof(DesignParamData.RepeatAddress))
            {
                list.Sort((lhs, rhs) =>
                {
                    int result = OnComparison(lhs.RepeatAddress, rhs.RepeatAddress);
                    return direction == ListSortDirection.Ascending ? result : -result;
                });
            }
           else if (prop.Name == nameof(DesignParamData.Length))
            {
                list.Sort((lhs, rhs) =>
                {
                    int result = OnComparison(lhs.Length, rhs.Length);
                    return direction == ListSortDirection.Ascending ? result : -result;
                });
            }
            else if (prop.Name == nameof(DesignParamData.CellAddress))
            {
                list.Sort((lhs, rhs) =>
                {
                    int result = OnComparison(lhs.CellAddress, rhs.CellAddress);
                    return direction == ListSortDirection.Ascending ? result : -result;
                });
            }
            else
            {
                // other sort in name
                list.Sort((lhs, rhs) =>
                {
                    var valueX = prop.GetValue(lhs);
                    var valueY = prop.GetValue(rhs);

                    if (valueX == null && valueY == null) return 0;
                    if (valueX == null) return -1;
                    if (valueY == null) return 1;

                    int result = ((IComparable)valueX).CompareTo(valueY);
                    return direction == ListSortDirection.Ascending ? result : -result;
                });
            }

            RequestRefreshParamUI?.Invoke();
        }

        // button sort
        private int CompareButtonColumn(DesignParamData lhs, DesignParamData rhs, string propertyName)
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
        private bool HasButtonContent(DesignParamData data, string propertyName)
        {
            switch (propertyName)
            {
                // if diaplay button
                case nameof(DesignParamData.ButtonEditDisplayFormatText):   // 書式
                    return data.CanEditDisplayFormat;
                case nameof(DesignParamData.ButtonEditConvertListText):     // 変換リスト
                    return data.CanEditConvertList;
                case nameof(DesignParamData.ButtonEditRepeatText):          // 繰返
                    return data.CanEditRepeat;
                case nameof(DesignParamData.ButtonEditFilterText):          // フィルタ
                    if (string.IsNullOrEmpty(data.FilterState)) return false;
                    return data.CanEditFilter;
                case nameof(DesignParamData.ButtonEditLabelItemText):       // ラベル
                    return data.CanEditLabelItem;
                case nameof(DesignParamData.ButtonEditBarCodeText):         // バーコード
                    return data.CanBarCode;
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
        private int CompareCheckBoxColumn(DesignParamData lhs, DesignParamData rhs, string propertyName)
        {
            CheckBoxState lhsState = GetCheckBoxState(lhs, propertyName);
            CheckBoxState rhsState = GetCheckBoxState(rhs, propertyName);

            // sort: Checked(0) < Unchecked(1) < NoCheckBox(2)
            return lhsState.CompareTo(rhsState);
        }

        // get state of checkbox
        private CheckBoxState GetCheckBoxState(DesignParamData data, string propertyName)
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
        private bool HasCheckBoxFunction(DesignParamData data, string propertyName)
        {
            switch (propertyName)
            {
                case nameof(DesignParamData.IsNewPage):
                    return data.CanEditNewPage;
                default:
                    return true;
            }
        }

        // checked of checkbox?
        private bool IsCheckBoxChecked(DesignParamData data, string propertyName)
        {
            switch (propertyName)
            {
                case nameof(DesignParamData.IsNewPage):
                    return data.IsNewPage == RldConst.GroupData.VAL_ISNEWPAGE_TRUE;
                default:
                    return GetGenericCheckBoxValue(data, propertyName);
            }
        }

        // custom checkbox
        private bool GetGenericCheckBoxValue(DesignParamData data, string propertyName)
        {
            var value = data.GetType().GetProperty(propertyName)?.GetValue(data);

            if (value is bool boolValue) return boolValue;
            if (value is string stringValue)
                return stringValue == RldConst.GroupData.VAL_ISNEWPAGE_TRUE;

            return false;
        }

        // remove sort state
        protected override void RemoveSortCore()
        {
            _isSorted = false;
            _sortProperty = null;
        }

        // sort
        public new void Sort()
        {
            _isSorted = false;
            _sortProperty = null;

            var list = Items as List<DesignParamData>;
            if (list == null) return;

            list.Sort((lhs, rhs) => OnComparison(lhs.CellAddress, rhs.CellAddress));
        }

        // Excelのセル位置をZ型で比較する。第1引数の方が小さければ-1, 大きければ1, おなじならば0を返す
        int OnComparison(string lhs, string rhs)
        {

            // null data
            if (lhs == null && rhs == null) return 0;
            if (lhs == null) return -1;
            if (rhs == null) return 1;

            // empty data
            if (string.IsNullOrEmpty(lhs) && string.IsNullOrEmpty(rhs)) return 0;
            if (string.IsNullOrEmpty(lhs)) return -1;
            if (string.IsNullOrEmpty(rhs)) return 1;

            bool isLhsNumber = int.TryParse(lhs, out int lNum);
            bool isRhsNumber = int.TryParse(rhs, out int rNum);

            // all is pure number
            if (isLhsNumber && isRhsNumber)
            {
                return lNum.CompareTo(rNum);
            }

            // one is number and other is not number
            if (isLhsNumber) return -1;
            if (isRhsNumber) return 1;

            return OnComparisonOriginal(lhs, rhs);
        }

        // Excelのセル位置をZ型で比較する。第1引数の方が小さければ-1, 大きければ1, おなじならば0を返す
        private int OnComparisonOriginal(string lhs, string rhs)
        { 
            try
            {
                string lhsValue = lhs;
                string rhsValue = rhs;

                if (lhsValue == null)
                {
                    return (rhsValue == null) ? 0 : -1;
                }
                else if (rhsValue == null)
                {
                    return 1;
                }

                char[] chars = { '1', '2', '3', '4', '5', '6', '7', '8', '9', '0' };

                // セル位置の行番号部分
                string[] lCellAddresses = lhsValue.Split(':');
                string[] rCellAddresses = rhsValue.Split(':');

                // 数値が出現する位置
                int lPos = lCellAddresses[0].IndexOfAny(chars);
                int rPos = rCellAddresses[0].IndexOfAny(chars);

                //int lRow = int.Parse(lCellAddresses[0].Substring(lPos));
                if (int.TryParse(lCellAddresses[0].Substring(lPos), out int lRow) == false)
                {
                    lRow = 1;
                }

                // = int.Parse(rCellAddresses[0].Substring(rPos));
                if (int.TryParse(rCellAddresses[0].Substring(rPos), out int rRow) == false)
                {
                    rRow = 1;
                }

                if (lRow < rRow)
                {
                    // lはrの前
                    System.Diagnostics.Debug.Print(lRow.ToString() + " < " + rRow.ToString() + " なので -1");
                    return -1;
                }
                else if (lRow > rRow)
                {
                    // lはrの後
                    System.Diagnostics.Debug.Print(lRow.ToString() + " > " + rRow.ToString() + " なので 1");
                    return 1;
                }
                else
                {
                    // 行は同じ
                    //System.Diagnostics.Debug.Print(lRow.ToString() + " = " + rRow.ToString() + " なので 0");
                    //ret = lCellAddresses[0].Substring(0, lPos).CompareTo(rCellAddresses[0].Substring(0, rPos));

                    string lCol = lCellAddresses[0].Substring(0, lPos);
                    string rCol = rCellAddresses[0].Substring(0, rPos);
                    int lColAddressLength = lCol.Length;
                    int rColAddressLength = rCol.Length;
                    if (lColAddressLength < rColAddressLength)
                    {
                        // 列部分が長いので第1引数の方が前にくる
                        return -1;
                    }
                    else if (lColAddressLength > rColAddressLength)
                    {
                        // 列部分が短いので第1引数の方が後ろにくる
                        return 1;
                    }

                    // 長さが同じなのでCompareToの戻り値をそのまま返す
                    return lCol.CompareTo(rCol);
                }
            }
            catch (Exception ex)
            {
                return string.Compare(lhs ?? "", rhs ?? "", StringComparison.Ordinal);
            }
            // mod #11501 レイアウトデザイナのユーザビリティ改善 高 end
        }

        // is pure number
        private bool IsPureNumber(string input)
        {
            return !string.IsNullOrEmpty(input) && input.All(char.IsDigit);
        }
    }

}
