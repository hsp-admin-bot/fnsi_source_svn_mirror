using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Windows.Forms;
using System.Reflection;

namespace LayoutDesigner
{
    /// <summary>
    /// DataGridView 用属性を反映させるクラス
    /// </summary>
    public class RldGridRCAttributeReflector
    {
        #region メンバ列挙体定義

        /// <summary>
        /// 適用モードが行モードの場合に設定される列
        /// </summary>
        public enum EnumRowModeColumnIndex
        {
            /// <summary>
            /// プロパティ名
            /// </summary>
            Property = 0,
            /// <summary>
            /// 設定項目名
            /// </summary>
            ItemName,
            /// <summary>
            /// 設定項目値
            /// </summary>
            ItemValue,
            /// <summary>
            /// End
            /// </summary>
            EoC
        }

        #endregion

        /// <summary>
        /// 指定された DataGridView の列に対して属性を反映させます。
        /// </summary>
        /// <param name="aTarget"></param>
        /// <param name="aDataSourceClassProperties"></param>
        public static void ApplyToColumn(DataGridView aTarget, PropertyInfo[] aDataSourceClassProperties)
        {
            try {
                aTarget.SuspendLayout();

                // 並び替えて取得
                var wProps = RldGridRCAttributeReflector.GetSortedProperties(aDataSourceClassProperties);

                for( int i = 0; i < wProps.Length; i++ ) {
                    var wProp = wProps[i];

                    // 列の生成して取得する(取得できなかった場合はスキップ)
                    DataGridViewColumn wColumn = null;
                    if( (wColumn = RldGridRCAttributeReflector.CreateColumn(wProp)) == null ) continue;

                    wColumn.Name = wProp.Name;
                    wColumn.DataPropertyName = wProp.Name;

                    // 表示プロパティ反映
                    var wAttrAppearance = System.Attribute.GetCustomAttribute(wProp, typeof(RldGridRCAppearanceAttribute)) as RldGridRCAppearanceAttribute;
                    if( wAttrAppearance != null ) {
                        wColumn.DisplayIndex = wAttrAppearance.DisplayIndex;
                        wColumn.HeaderText = String.IsNullOrEmpty(wAttrAppearance.HeaderText) ? wProp.Name : wAttrAppearance.HeaderText;
                        wColumn.ToolTipText = wAttrAppearance.ToolTipText;
                        wColumn.Visible = wAttrAppearance.Visible;
                    }

                    // 動作プロパティ反映
                    var wAttrBehavior = System.Attribute.GetCustomAttribute(wProp, typeof(RldGridRCBehaviorAttribute)) as RldGridRCBehaviorAttribute;
                    if( wAttrBehavior != null ) {
                        wColumn.ContextMenuStrip = wAttrBehavior.ContextMenuStrip;
                        wColumn.ReadOnly = wAttrBehavior.ReadOnly;
                        wColumn.Resizable = wAttrBehavior.Resizable;
                        wColumn.SortMode = wAttrBehavior.SortMode;
                    }

                    // 配置プロパティ反映
                    var wAttrLayout = System.Attribute.GetCustomAttribute(wProp, typeof(RldGridRCLayoutAttribute)) as RldGridRCLayoutAttribute;
                    if( wAttrLayout != null ) {
                        wColumn.AutoSizeMode = wAttrLayout.AutoSizeMode;
                        wColumn.DividerWidth = wAttrLayout.DividerWidth;
                        wColumn.FillWeight = wAttrLayout.FillWeight;
                        wColumn.Frozen = wAttrLayout.Frozen;
                        wColumn.MinimumWidth = wAttrLayout.MinimumWidth;
                        wColumn.Width = wAttrLayout.Width;
                    }

                    // 既定のセルスタイルを適用
                    var wAttrDefaultCellStyle = System.Attribute.GetCustomAttribute(wProp, typeof(RldGridRCAppearanceDefaultCellStyleAttribute)) as RldGridRCAppearanceDefaultCellStyleAttribute;
                    if( wAttrDefaultCellStyle != null ) {
                        var wDefaultCellStyle = new DataGridViewCellStyle(wColumn.DefaultCellStyle);
                        {
                            wDefaultCellStyle.NullValue = wAttrDefaultCellStyle.DataNullValue;
                            wDefaultCellStyle.Format = wAttrDefaultCellStyle.BehaviorFormat;
                            wDefaultCellStyle.Alignment = wAttrDefaultCellStyle.LayoutAlignment;
                            wDefaultCellStyle.Padding = wAttrDefaultCellStyle.LayoutPadding;
                            wDefaultCellStyle.WrapMode = wAttrDefaultCellStyle.LayoutWrapMode;
                            wDefaultCellStyle.BackColor = wAttrDefaultCellStyle.AppearanceBackColor;
                            wDefaultCellStyle.Font = wAttrDefaultCellStyle.AppearanceFont;
                            wDefaultCellStyle.ForeColor = wAttrDefaultCellStyle.AppearanceForeColor;
                            wDefaultCellStyle.SelectionBackColor = wAttrDefaultCellStyle.AppearanceSelectionBackColor;
                            wDefaultCellStyle.SelectionForeColor = wAttrDefaultCellStyle.AppearanceSelectionForeColor;
                        }
                        wColumn.DefaultCellStyle = wDefaultCellStyle;
                    }

                    // DataGridViewButtonColumn の場合
                    if( wColumn is DataGridViewButtonColumn wButtonColumn ) {
                        var wAttrAppearanceButton = System.Attribute.GetCustomAttribute(wProp, typeof(RldGridRCAppearanceButtonAttribute)) as RldGridRCAppearanceButtonAttribute;
                        if( wAttrAppearanceButton != null ) {
                            wButtonColumn.FlatStyle = wAttrAppearanceButton.FlatStyle;
                            wButtonColumn.Text = wAttrAppearanceButton.Text;
                            wButtonColumn.UseColumnTextForButtonValue = wAttrAppearanceButton.UseColumnTextForButtonValue;
                        }
                    }

                    // DataGridViewCheckBoxColumn の場合
                    if( wColumn is DataGridViewCheckBoxColumn wCheckBoxColumn ) {

                        var wAttrDataCheckBox = System.Attribute.GetCustomAttribute(wProp, typeof(RldGridRCDataCheckBoxAttribute)) as RldGridRCDataCheckBoxAttribute;
                        if( wAttrDataCheckBox != null ) {
                            wCheckBoxColumn.FalseValue = wAttrDataCheckBox.FalseValue;
                            wCheckBoxColumn.IndeterminateValue = wAttrDataCheckBox.IndeterminateValue;
                            wCheckBoxColumn.TrueValue = wAttrDataCheckBox.TrueValue;
                        }

                        var wAttrAppearanceCheckBox = System.Attribute.GetCustomAttribute(wProp, typeof(RldGridRCAppearanceCheckBoxAttribute)) as RldGridRCAppearanceCheckBoxAttribute;
                        if( wAttrAppearanceCheckBox != null ) {
                            wCheckBoxColumn.FlatStyle = wAttrAppearanceCheckBox.FlatStyle;
                        }
                    }

                    // DataGridViewComboBoxColumn の場合
                    if( wColumn is DataGridViewComboBoxColumn wComboBoxColumn ) {

                        //var wAttrDataComboBox = System.Attribute.GetCustomAttribute(wProp, typeof(RldGridRCDataComboBoxAttribute)) as RldGridRCDataComboBoxAttribute;
                        //if( wAttrDataComboBox != null ) {
                        //    wComboBoxColumn.DataSource = wAttrDataComboBox.DataSource;
                        //    wComboBoxColumn.DisplayMember = wAttrDataComboBox.DisplayMember;
                        //    wComboBoxColumn.ValueMember = wAttrDataComboBox.ValueMemmber;
                        //    wComboBoxColumn.Items.Add(wAttrDataComboBox.Items);
                        //}

                        var wAttrAppearanceComboBox = System.Attribute.GetCustomAttribute(wProp, typeof(RldGridRCAppearanceComboBoxAttribute)) as RldGridRCAppearanceComboBoxAttribute;
                        if( wAttrAppearanceComboBox != null ) {
                            wComboBoxColumn.DisplayStyle = wAttrAppearanceComboBox.DisplayStyle;
                            wComboBoxColumn.DisplayStyleForCurrentCellOnly = wAttrAppearanceComboBox.DisplayStyleForCurrentCellOnly;
                            wComboBoxColumn.FlatStyle = wAttrAppearanceComboBox.FlatStyle;
                        }

                        var wAttrBehaviorComboBox = System.Attribute.GetCustomAttribute(wProp, typeof(RldGridRCBehaviorComboBoxAttribute)) as RldGridRCBehaviorComboBoxAttribute;
                        if( wAttrBehaviorComboBox != null ) {
                            wComboBoxColumn.DropDownWidth = wAttrBehaviorComboBox.DropDownWidth;
                            wComboBoxColumn.MaxDropDownItems = wAttrBehaviorComboBox.MaxDropDownItems;
                        }
                    }

                    // DataGridViewTextBoxColumn の場合
                    if( wColumn is DataGridViewTextBoxColumn wTextBoxColumn ) {

                        var wAttrBehaviorTextBox = System.Attribute.GetCustomAttribute(wProp, typeof(RldGridRCBehaviorTextBoxAttribute)) as RldGridRCBehaviorTextBoxAttribute;
                        if( wAttrBehaviorTextBox != null ) {
                            wTextBoxColumn.MaxInputLength = wAttrBehaviorTextBox.MaxInputLength;
                        }
                    }

                    // 生成した列を追加
                    aTarget.Columns.Add(wColumn);
                }
            }
            catch {
                throw;
            }
            finally {
                aTarget.ResumeLayout();
            }
        }

        /// <summary>
        /// 指定された DataGridView の行と列に対して属性を反映させます。
        /// </summary>
        /// <param name="aTarget"></param>
        /// <param name="aDataSourceClassProperties"></param>
        public static void ApplyToRow(DataGridView aTarget, PropertyInfo[] aDataSourceClassProperties)
        {
            try {
                // 全行を削除
                aTarget.RowCount = 0;
                // 列数を設定
                aTarget.ColumnCount = Enum.GetValues(typeof(EnumRowModeColumnIndex)).Length;

                // プロパティ名列の設定
                aTarget.Columns[(Int32)EnumRowModeColumnIndex.Property].Visible = false;

                // 設定項目名の設定
                aTarget.Columns[(Int32)EnumRowModeColumnIndex.ItemName].HeaderText = "設定項目名";
                aTarget.Columns[(Int32)EnumRowModeColumnIndex.ItemName].ReadOnly = true;
                aTarget.Columns[(Int32)EnumRowModeColumnIndex.ItemName].SortMode = DataGridViewColumnSortMode.NotSortable;

                // 設定値列の設定
                aTarget.Columns[(Int32)EnumRowModeColumnIndex.ItemValue].HeaderText = "設定値";
                // del #10487 デザイナーウィンドウの動作不良2件 高 start
                //aTarget.Columns[(Int32)EnumRowModeColumnIndex.ItemValue].Width = 170;
                // del #10487 デザイナーウィンドウの動作不良2件 高 end
                aTarget.Columns[(Int32)EnumRowModeColumnIndex.ItemValue].SortMode = DataGridViewColumnSortMode.NotSortable;
                
                // 最終列の設定
                aTarget.Columns[(Int32)EnumRowModeColumnIndex.EoC].ReadOnly = true;
                aTarget.Columns[(Int32)EnumRowModeColumnIndex.EoC].AutoSizeMode = DataGridViewAutoSizeColumnMode.Fill;
                aTarget.Columns[(Int32)EnumRowModeColumnIndex.EoC].FillWeight = 100;
                aTarget.Columns[(Int32)EnumRowModeColumnIndex.EoC].SortMode = DataGridViewColumnSortMode.NotSortable;

                // 並び替えて取得
                var wProps = RldGridRCAttributeReflector.GetSortedProperties(aDataSourceClassProperties);

                for( int i = 0; i < wProps.Length - 1; i++ ) {
                    var wProp = wProps[i];

                    // 列を生成して取得する(取得できなかった場合はスキップ)
                    DataGridViewColumn wColumn = null;
                    if( (wColumn = RldGridRCAttributeReflector.CreateColumn(wProp)) == null ) continue;

                    // 列のインスタンスからセルの型を取得(取得できなかった場合はスキップ)
                    System.Type wCellType = null;
                    if( (wCellType = wColumn.CellType) == null ) continue;

                    // 行を追加して取得
                    var wRow = aTarget.Rows[aTarget.Rows.Add()];

                    // セルの取得と生成
                    var wPropCell = wRow.Cells[(Int32)EnumRowModeColumnIndex.Property];
                    var wHeaderCell = wRow.Cells[(Int32)EnumRowModeColumnIndex.ItemName];
                    var wDataCell = System.Activator.CreateInstance(wCellType) as DataGridViewCell;

                    wPropCell.Value = wProp.Name;

                    // 表示プロパティ反映
                    var wAttrAppearance = System.Attribute.GetCustomAttribute(wProp, typeof(RldGridRCAppearanceAttribute)) as RldGridRCAppearanceAttribute;
                    if( wAttrAppearance != null ) {
                        wHeaderCell.Value = String.IsNullOrEmpty(wAttrAppearance.HeaderText) ? wProp.Name : wAttrAppearance.HeaderText.Replace(System.Environment.NewLine, "");
                        wHeaderCell.ToolTipText = wAttrAppearance.ToolTipText;
                        wRow.Visible = wAttrAppearance.Visible;
                    }

                    // 動作プロパティ反映
                    var wAttrBehavior = System.Attribute.GetCustomAttribute(wProp, typeof(RldGridRCBehaviorAttribute)) as RldGridRCBehaviorAttribute;
                    if( wAttrBehavior != null ) {
                        wRow.ContextMenuStrip = wAttrBehavior.ContextMenuStrip;
                        wRow.ReadOnly = wAttrBehavior.ReadOnly;
                    }

                    //// 配置プロパティ反映
                    //var wAttrLayout = System.Attribute.GetCustomAttribute(wProp, typeof(RldGridRCLayoutAttribute)) as RldGridRCLayoutAttribute;
                    //if( wAttrLayout != null ) {
                    //    wRow.AutoSizeMode = wAttrLayout.AutoSizeMode;
                    //    wRow.DividerWidth = wAttrLayout.DividerWidth;
                    //    wRow.FillWeight = wAttrLayout.FillWeight;
                    //    wRow.Frozen = wAttrLayout.Frozen;
                    //    wRow.MinimumWidth = wAttrLayout.MinimumWidth;
                    //    wRow.Width = wAttrLayout.Width;
                    //}

                    // 既定のセルスタイルを適用
                    var wAttrDefaultCellStyle = System.Attribute.GetCustomAttribute(wProp, typeof(RldGridRCAppearanceDefaultCellStyleAttribute)) as RldGridRCAppearanceDefaultCellStyleAttribute;
                    if( wAttrDefaultCellStyle != null ) {
                        var wDefaultCellStyle = new DataGridViewCellStyle(wColumn.DefaultCellStyle);
                        {
                            wDefaultCellStyle.NullValue = wAttrDefaultCellStyle.DataNullValue;
                            wDefaultCellStyle.Format = wAttrDefaultCellStyle.BehaviorFormat;
                            wDefaultCellStyle.Alignment = wAttrDefaultCellStyle.LayoutAlignment;
                            wDefaultCellStyle.Padding = wAttrDefaultCellStyle.LayoutPadding;
                            wDefaultCellStyle.WrapMode = wAttrDefaultCellStyle.LayoutWrapMode;
                            wDefaultCellStyle.BackColor = wAttrDefaultCellStyle.AppearanceBackColor;
                            wDefaultCellStyle.Font = wAttrDefaultCellStyle.AppearanceFont;
                            wDefaultCellStyle.ForeColor = wAttrDefaultCellStyle.AppearanceForeColor;
                            wDefaultCellStyle.SelectionBackColor = wAttrDefaultCellStyle.AppearanceSelectionBackColor;
                            wDefaultCellStyle.SelectionForeColor = wAttrDefaultCellStyle.AppearanceSelectionForeColor;
                        }
                        wDataCell.Style = wDefaultCellStyle;
                    }

                    // DataGridViewButtonCell の場合
                    if( wDataCell is DataGridViewButtonCell wButtonCell ) {
                        var wAttrAppearanceButton = System.Attribute.GetCustomAttribute(wProp, typeof(RldGridRCAppearanceButtonAttribute)) as RldGridRCAppearanceButtonAttribute;
                        if( wAttrAppearanceButton != null ) {
                            wButtonCell.FlatStyle = wAttrAppearanceButton.FlatStyle;
                            wButtonCell.Value = wAttrAppearanceButton.Text;
                            wButtonCell.UseColumnTextForButtonValue = false;
                        }
                    }

                    // DataGridViewCheckBoxCell の場合
                    if( wDataCell is DataGridViewCheckBoxCell wCheckBoxCell ) {
                        var wAttrDataCheckBox = System.Attribute.GetCustomAttribute(wProp, typeof(RldGridRCDataCheckBoxAttribute)) as RldGridRCDataCheckBoxAttribute;
                        if( wAttrDataCheckBox != null ) {
                            wCheckBoxCell.FalseValue = wAttrDataCheckBox.FalseValue;
                            wCheckBoxCell.IndeterminateValue = wAttrDataCheckBox.IndeterminateValue;
                            wCheckBoxCell.TrueValue = wAttrDataCheckBox.TrueValue;

                            wCheckBoxCell.Value = wAttrDataCheckBox.FalseValue;
                        }

                        var wAttrAppearanceCheckBox = System.Attribute.GetCustomAttribute(wProp, typeof(RldGridRCAppearanceCheckBoxAttribute)) as RldGridRCAppearanceCheckBoxAttribute;
                        if( wAttrAppearanceCheckBox != null ) {
                            wCheckBoxCell.FlatStyle = wAttrAppearanceCheckBox.FlatStyle;
                        }
                    }

                    // DataGridViewComboBoxCell の場合
                    if( wDataCell is DataGridViewComboBoxCell wComboBoxCell ) {
                        var wAttrAppearanceComboBox = System.Attribute.GetCustomAttribute(wProp, typeof(RldGridRCAppearanceComboBoxAttribute)) as RldGridRCAppearanceComboBoxAttribute;
                        if( wAttrAppearanceComboBox != null ) {
                            wComboBoxCell.DisplayStyle = wAttrAppearanceComboBox.DisplayStyle;
                            wComboBoxCell.DisplayStyleForCurrentCellOnly = wAttrAppearanceComboBox.DisplayStyleForCurrentCellOnly;
                            wComboBoxCell.FlatStyle = wAttrAppearanceComboBox.FlatStyle;
                        }

                        var wAttrBehaviorComboBox = System.Attribute.GetCustomAttribute(wProp, typeof(RldGridRCBehaviorComboBoxAttribute)) as RldGridRCBehaviorComboBoxAttribute;
                        if( wAttrBehaviorComboBox != null ) {
                            wComboBoxCell.DropDownWidth = wAttrBehaviorComboBox.DropDownWidth;
                            wComboBoxCell.MaxDropDownItems = wAttrBehaviorComboBox.MaxDropDownItems;
                        }
                    }

                    // DataGridViewTextBoxCell の場合
                    if( wDataCell is DataGridViewTextBoxCell wTextBoxCell ) {
                        var wAttrBehaviorTextBox = System.Attribute.GetCustomAttribute(wProp, typeof(RldGridRCBehaviorTextBoxAttribute)) as RldGridRCBehaviorTextBoxAttribute;
                        if( wAttrBehaviorTextBox != null ) {
                            wTextBoxCell.MaxInputLength = wAttrBehaviorTextBox.MaxInputLength;
                        }
                    }

                    // 生成したセルを行にセット
                    wRow.Cells[(Int32)EnumRowModeColumnIndex.ItemValue] = wDataCell;
                }
            }
            catch {
                throw;
            }
        }
        
        /// <summary>
        /// 指定したプロパティから DataGridViewColumn クラスを生成します。
        /// </summary>
        /// <param name="aProp"></param>
        /// <returns></returns>
        private static DataGridViewColumn CreateColumn(PropertyInfo aProp)
        {
            DataGridViewColumn wRet = null;

            System.Type wColumnType = null;
            var wAttrDesign = System.Attribute.GetCustomAttribute(aProp, typeof(RldGridRCDesignAttribute)) as RldGridRCDesignAttribute;
            if( wAttrDesign != null )
                // 列の型を取得
                wColumnType = wAttrDesign.ColumnType;

            // 列を生成
            if( wColumnType != null )
                wRet = System.Activator.CreateInstance(wColumnType) as DataGridViewColumn;

            return wRet;
        }

        /// <summary>
        /// プロパティリストを並び替えた結果のコピーを取得します。
        /// </summary>
        /// <param name="aSource"></param>
        /// <returns></returns>
        private static PropertyInfo[] GetSortedProperties(PropertyInfo[] aSource)
        {
            // 必要なプロパティのみ抽出
            var wRet = new List<PropertyInfo>();
            foreach( var wProp in aSource ) {
                var wAttrAppearance = System.Attribute.GetCustomAttribute(wProp, typeof(RldGridRCAppearanceAttribute)) as RldGridRCAppearanceAttribute;
                if( wAttrAppearance != null )
                    wRet.Add(wProp);
            }

            // 表示順にソートする
            Int32 wGetDisplayIndex(PropertyInfo ele) => 
                (ele.GetCustomAttribute(typeof(RldGridRCAppearanceAttribute)) as RldGridRCAppearanceAttribute).DisplayIndex;
            wRet.Sort((ele1, ele2) => wGetDisplayIndex(ele1) - wGetDisplayIndex(ele2));

            return wRet.ToArray();
        }
    }
}
