using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Globalization;
using System.Linq;
using System.Text;
//ADD #8394,#8566 日付時刻型のデータ項目に書式設定が反映しない 董 END
using System.Text.RegularExpressions;
//ADD #8394,#8566 日付時刻型のデータ項目に書式設定が反映しない 董 START
using System.Threading.Tasks;

using System.Windows.Forms;

namespace LayoutDesigner
{
    /// <summary>
    /// パラメータ編集用データグリッドビュー制御ヘルパークラス
    /// </summary>
    public class RldDataGridViewParamDataEditHelper : IRldDesignSendOnlyColleague
    {
        #region 内部クラス定義

        /// <summary>
        /// 文字列セル変更監視クラス
        /// </summary>
        private class TextCellObserver : RldDataGridViewCellValueObserver<string>
        {
            /// <summary>
            /// 監視対象の DataGridView と列名を指定して文字列セル変更監視クラスの新しいインスタンスを初期化します。
            /// </summary>
            /// <param name="aTarget"></param>
            /// <param name="aColumnName"></param>
            public TextCellObserver(DataGridView aTarget, string aColumnName) : base(aTarget, aColumnName) { }
        }

        #endregion

        #region メンバ変数定義

        /// <summary>
        /// グループ名変更監視クラス
        /// </summary>
        private TextCellObserver m_ObserverGroupName = null;
        /// <summary>
        /// 表示文字数変更監視クラス
        /// </summary>
        private TextCellObserver m_ObserverLength = null;

        // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
        public static Dictionary<object, string> middleData = new Dictionary<object, string>();
        // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end
        #endregion

        #region メンバイベント定義

        /// <summary>
        /// 通知イベント
        /// </summary>
        public event EventHandler<RldDesignNotifyInfoEventArgs> NotifyInfo;

        #endregion

        #region 生成と破棄

        /// <summary>
        /// 制御対象コントロールを指定してパラメータ編集用データグリッドビュー制御ヘルパークラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aTarget">DataGridView</param>
        public RldDataGridViewParamDataEditHelper(DataGridView aTarget)
        {
            Target = aTarget;

            // データグリッドビューの列を自動生成しないようにする
            Target.AutoGenerateColumns = false;
            // データグリッドビューの表示を調整する
            RldGridRCAttributeReflector.ApplyToColumn(Target, DesignParamData.Properties);

            // 値変更監視クラスを生成
            m_ObserverGroupName = new TextCellObserver(Target, DesignParamData.GetPropertyName(DesignParamData.EnumDataIndex.GroupName));
            m_ObserverLength = new TextCellObserver(Target, DesignParamData.GetPropertyName(DesignParamData.EnumDataIndex.Length));

            // イベントハンドラ割り当て
            aTarget.CellClick += new DataGridViewCellEventHandler(OnTarget_CellClick);
            aTarget.DataBindingComplete += new DataGridViewBindingCompleteEventHandler(OnTarget_DataBindingComplete);
            aTarget.CurrentCellDirtyStateChanged += new EventHandler(OnTarget_CurrentCellDirtyStateChanged);
            m_ObserverGroupName.CellValueChanged += new EventHandler(ObserverGroupName_CellValueChanged);
            m_ObserverLength.CellValueChanged += new EventHandler(ObserverLengh_CellValueChanged);
        }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 制御対象コントロールの取得及び設定を行います。
        /// </summary>
        private DataGridView Target { get; set; } = null;

        #endregion

        #region メンバ関数定義(公開部)

        /// <summary>
        /// 表示内容をクリアします。
        /// </summary>
        public void Clear()
        {
            // mod #12131 レイアウトデザイナのセル移動時のパフォーマンスが再度悪化 高 start
            LFunc_Invoke();

            void LFunc_Invoke()
            {
                if (Target == null || Target.IsDisposed)
                    return;

                if (Target.InvokeRequired)
                {
                    Target.Invoke((MethodInvoker)delegate
                    {
                        LFunc_Invoke();
                    });
                }
                else
                {
                    try
                    {
                        Target.SuspendLayout();
                        Target.DataMember = null;
                        Target.DataSource = null;
                    }
                    catch (Exception)
                    { }
                    finally
                    {
                        Target.ResumeLayout();
                    }
                }
            }
            // mod #12131 レイアウトデザイナのセル移動時のパフォーマンスが再度悪化 高 end
        }

        /// <summary>
        /// 表示データをセットします。
        /// 呼び出しもとで try - catch する必要があります。
        /// </summary>
        /// <param name="aParamList"></param>
        public void SetData(System.ComponentModel.BindingList<DesignParamData> aParamList)
        {
            // mod #12131 レイアウトデザイナのセル移動時のパフォーマンスが再度悪化 高 start
            LFunc_Invoke();

            void LFunc_Invoke()
            {
                if (Target == null || Target.IsDisposed)
                    return;

                if (Target.InvokeRequired)
                {
                    Target.Invoke((MethodInvoker)delegate
                    {
                        LFunc_Invoke();
                    });
                }
                else
                {
                    try
                    {
                        Target.SuspendLayout();

                        // mod #8394(3,4) 動作に関する指摘 luantian start
                        //Target.DataMember = null;
                        //Target.DataSource = aParamList;
                        //if (Target.InvokeRequired)
                        //{
                        //    Action<System.ComponentModel.BindingList<DesignParamData>> actionDelegate = (x) =>
                        //    {
                        //        Target.DataMember = null;
                        //        Target.DataSource = x;
                        //    };
                        //    Target.Invoke(actionDelegate, aParamList);
                        //}
                        //else
                        //{
                        //    Target.DataMember = null;
                        //    Target.DataSource = aParamList;
                        //}
                        // mod #8394(3,4) 動作に関する指摘 luantian start
                        Target.DataMember = null;
                        Target.DataSource = aParamList;
                    }
                    catch
                    {
                        throw;
                    }
                    finally
                    {
                        Target.ResumeLayout();
                    }
                }
                // mod #12131 レイアウトデザイナのセル移動時のパフォーマンスが再度悪化 高 end
            }
        }

        /// <summary>
        /// CellClick イベントを発生させます。
        /// </summary>
        /// <param name="aColumnIndex"></param>
        /// <param name="aRowIndex"></param>
        public void PerformCellClick(int aColumnIndex, int aRowIndex)
        {
            // 制御対象 DataGridViewの CellClick イベントハンドラ
            OnTarget_CellClick(this, new DataGridViewCellEventArgs(aColumnIndex, aRowIndex));
        }

        /// <summary>
        /// グループ名が変更された場合の処理を行います。
        /// </summary>
        /// <param name="aGroupNameCell"></param>
        /// <param name="aBindData"></param>
        /// <param name="aOldGroupName"></param>
        public void PerformCellEndEdit_GroupName(DataGridViewCell aGroupNameCell, DesignParamData aBindData, string aOldGroupName)
        {
            // 該当セルを取得
            var wCell = aGroupNameCell;

            // 変更前のグループ名をセット
            string wOldGroupName = aOldGroupName, wNewGroupName = wCell.Value as string;

            // 空文字の場合は元に戻す
            // mod #8314 グループタブの表示不正 王占宇 start
            // if (string.IsNullOrEmpty(wNewGroupName))
            if (string.IsNullOrEmpty(wNewGroupName)||string.IsNullOrEmpty(wNewGroupName.Trim()))
            // mod #8314 グループタブの表示不正 王占宇 end
            {
                wCell.Value = wOldGroupName;
                return;
            }

            // 該当行にバインドされているパラメータデータを取得
            if (aBindData == null)
            {
                return;
            }

            // add #10487 デザイナーウィンドウの動作不良2件 高 start
            if (wOldGroupName == wNewGroupName)
                return;
            // add #10487 デザイナーウィンドウの動作不良2件 高 end

            try
            {
                // 今回変更したパラメータ以外に該当グループに属するパラメータがない場合は確認
                if (RldLib.CurrentLayoutData.DesignParamList.Count(ele => ele.GroupName == wOldGroupName && ele.CellAddress != aBindData.CellAddress) <= 0)
                {
                    var wEventArgs = new RldDesignNotifyInfoRequestShowMessageEventArgs()
                    {
                        Text = string.Format(@"グループ名を変更すると該当グループは削除され、グループの設定内容も削除されます。{0}変更してもよろしいですか？", System.Environment.NewLine),
                        Caption = @"確認してください",
                        Buttons = MessageBoxButtons.YesNo,
                        Icon = MessageBoxIcon.Question,
                        DefaultButton = MessageBoxDefaultButton.Button2
                    };
                    SendNotifyInfo(wEventArgs);
                    if (wEventArgs.DialogResult == DialogResult.No)
                    {
                        wCell.Value = wOldGroupName;
                        return;
                    }
                }

                aBindData.GroupName = wNewGroupName;

                // 変更前もグループに属していた場合
                if (!string.IsNullOrEmpty(wOldGroupName))
                {
                    // 同一グループに属しているパラメータがない場合はグループを削除する

                    // add #6066 1つの項目を増やすごとに1つの項目が増えるグループ 鄭  2022-02-08 start
                    //if (!RldLib.CurrentLayoutData.RemoveNonReferGroupData(aBindData.DataCategory, aBindData.DataClass, wOldGroupName, aBindData.IsInTemplete))
                    //{
                    //    return;
                    //}
                    // mod #8314 グループタブの表示不正 王占宇 start
                    // if (!RldLib.CurrentLayoutData.RemoveNonReferGroupData(aBindData.DataCategory, aBindData.DataClass, wOldGroupName, aBindData.IsInTemplete, aBindData.CellAddress))
                    if (!RldLib.CurrentLayoutData.NewRemoveNonReferGroupData(aBindData.DataCategory, aBindData.DataClass, wOldGroupName, aBindData.IsInTemplete, aBindData.CellAddress))
                    // mod #8314 グループタブの表示不正 王占宇 end
                    {
                        return;
                    }
                    // add #6066 1つの項目を増やすごとに1つの項目が増えるグループ 鄭  2022-02-08 start
                }

                // 変更後もグループに属する場合は所属先グループが存在するか確認し、無ければ作成して追加する
                // mod #8314 グループタブの表示不正 王占宇 start
                // if (!RldLib.CurrentLayoutData.CreateAndAddDesignGroupData(aBindData))
                if (!RldLib.CurrentLayoutData.NewCreateAndAddDesignGroupData(aBindData))
                // mod #8314 グループタブの表示不正 王占宇 end
                {
                    return;
                }
            }
            catch (Exception ex)
            {
                SendNotifyInfo(new RldDesignNotifyInfoRequestRecordExceptionEventArgs(ex, true));
            }
        }

        #endregion

        #region メンバ関数定義(非公開部)

        /// <summary>
        /// 通知イベントを発行します。
        /// </summary>
        /// <param name="e"></param>
        private void SendNotifyInfo(RldDesignNotifyInfoEventArgs e)
        {
            NotifyInfo?.Invoke(this, e);
        }

        #endregion

        #region カスタムイベントハンドラ定義

        /// <summary>
        /// 表示文字数変更監視クラスの CellValueChanged イベントハンドラ
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void ObserverLengh_CellValueChanged(object sender, System.EventArgs e)
        {
            // 表示文字数が変更された場合
            var wCell = Target[m_ObserverLength.ColumnIndex, m_ObserverLength.RowIndex];

            try
            {
                if (Convert.ToInt32(wCell.FormattedValue) < 0)
                {
                    throw new System.Exception("文字数が負値です");
                }
            }
            catch
            {
                wCell.Value = 0;
            }
        }

        /// <summary>
        /// グループ名変更監視クラスの CellValueChanged イベントハンドラ
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void ObserverGroupName_CellValueChanged(object sender, System.EventArgs e)
        {
            // 該当セルを取得
            var wCell = Target[m_ObserverGroupName.ColumnIndex, m_ObserverGroupName.RowIndex];

            // 該当行にバインドされているパラメータデータを取得
            if (!(this.Target.Rows[this.m_ObserverGroupName.RowIndex].DataBoundItem is DesignParamData wData))
            {
                return;
            }
            //add #8615 zhu start
            foreach (var wDataD in RldLib.CurrentLayoutData.DesignGroupList)
            {
                // mod #12486 レイアウトアプリでバーコード非対応の項目で設定ができてしまう 高 start
                //if (wData.GroupName == wDataD.GroupName)
                if (wData.GroupName == wDataD.GroupName 
                    && wData.FilterType == wDataD.FilterType
                    && wData.FilterType != RldConst.FilterType.Group.EXAMINE
                    && wData.FilterType != RldConst.FilterType.Group.EXAM_SET
                    && wData.FilterType != RldConst.FilterType.Group.INSPECTION
                    // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
                    && wData.FilterType != RldConst.FilterType.Group.WQTESTPOINT
                    // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
                    )
                {
                    wData.FilterData = wDataD.FilterData;
                    wData.FilterState = wDataD.FilterState;
                    //wData.FilterType = wDataD.FilterType;
                }
                // mod #12486 レイアウトアプリでバーコード非対応の項目で設定ができてしまう 高 end
            }
            //add #8615 zhu end
            // 変更後処理を行う
            PerformCellEndEdit_GroupName(wCell, wData, m_ObserverGroupName.OldValue);
        }

        /// <summary>
        /// 制御対象コントロールの DataGridViewの CellClick イベントハンドラ
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void OnTarget_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            // ヘッダのクリック時は抜ける
            if (e.RowIndex < 0 || e.ColumnIndex < 0)
            {
                return;
            }

            // セルが読取専用の場合は抜ける
            if (Target[e.ColumnIndex, e.RowIndex].ReadOnly)
            {
                return;
            }

            // 該当行にバインドされているパラメータデータを取得
            if (!(this.Target.Rows[e.RowIndex].DataBoundItem is DesignParamData wData))
            {
                return;
            }

            // 列チェック用
            bool wFuncEqualColumn(DesignParamData.EnumDataIndex aIndex)
            {
                return e.ColumnIndex == Target.Columns[DesignParamData.GetPropertyName(aIndex)].Index;
            }

            // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 start
            if (RldLib.chkExeclDialog(2) == false)
                return;
            // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 end

            // 書式編集クリック時
            if (wFuncEqualColumn(DesignParamData.EnumDataIndex.ButtonEditDisplayFormatText))
            {

                // 書式選択画面
                using (var wDlg = new frmSelectFormat())
                {
                    //// add #8394 動作に関する指摘 董 start
                    for (int i = 0; i < RldLib.CurrentLayoutData.DesignParamList.Count; i++)
                    {
                        bool isShrink = false;
                        String format;

                        using (var wXlRange = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, RldLib.CurrentLayoutData.DesignParamList[i].CellAddress))
                        {
                            // mod #11417 レイアウトデザイナでデータ項目フォーカスアウト時に致命的なエラー limingzhe start
                            //format = wXlRange.Range.NumberFormatLocal;
                            object wValueFormat = wXlRange.Range.NumberFormatLocal;
                            format = wValueFormat == DBNull.Value ? string.Empty : (string)wValueFormat;
                            // mod #11417 レイアウトデザイナでデータ項目フォーカスアウト時に致命的なエラー limingzhe end
                            // mod #11228 セルの編集から抜ける際に演算子エラー 高 start
                            object wValue = wXlRange.Range.ShrinkToFit;
                            bool wIsShrink = wValue == DBNull.Value || (bool)wValue;
                            //if (wXlRange.Range.ShrinkToFit == true)
                            if (wIsShrink == true)
                            // mod #11228 セルの編集から抜ける際に演算子エラー 高 end
                            {
                                isShrink = true;
                            }
                        }

                        // mod #11008 文字数設定がリセットされる 高 start
                        // RldLib.CurrentLayoutData.SetDesignParamDataList(i, isShrink, format);
                        RldLib.CurrentLayoutData.SetDesignParamDataList(i, isShrink, format, false);
                        // mod #11008 文字数設定がリセットされる 高 end

                    }

                    UpdateLayoutSheetRangeFormatSetting(wData);
                    //// add #8394 動作に関する指摘 董 end

                    // 必要なパラメータをセット
                    wDlg.DataPath = wData.DataPath;
                    wDlg.DataType = wData.DataType;
                    wDlg.SelectedFormat = wData.DisplayFormat;
                    // add #10230 コピーした内容がリセットされる 高 start
                    wData.DisplayFormatUpdate = true;
                    // add #10230 コピーした内容がリセットされる 高 end

                    // ダイアログの表示を要求
                    SendNotifyInfo(new RldDesignNotifyInfoRequestOpenDialogEventArgs(wDlg)
                    {
                        IsAllWindowLock = true,
                        IsProtectLayoutSheet = true
                    });

                    // OKボタン押下時は書式を更新
                    if (wDlg.DialogResult == DialogResult.OK)
                    {
                        wData.DisplayFormat = wDlg.SelectedFormat;
                    }
                }
            }
            // データ変換編集クリック時
            else if (wFuncEqualColumn(DesignParamData.EnumDataIndex.ButtonEditConvertListText))
            {

                // 変換項目編集画面
                using (var wDlg = new frmEditConvList())
                {
                    // 必要なパラメータをセット
                    wDlg.DataPath = wData.DataPath;
                    wDlg.ConvertList = wData.ConvertList;

                    // ダイアログの表示を要求
                    SendNotifyInfo(new RldDesignNotifyInfoRequestOpenDialogEventArgs(wDlg)
                    {
                        IsAllWindowLock = true,
                        IsProtectLayoutSheet = true
                    });

                    // OKボタン押下時は変換リストを更新
                    if (wDlg.DialogResult == DialogResult.OK)
                    {
                        wData.ConvertList = wDlg.ConvertList;
                    }
                }
            }
            // 繰返し編集クリック時
            else if (wFuncEqualColumn(DesignParamData.EnumDataIndex.ButtonEditRepeatText))
            {

                // 繰り返しエリア編集画面
                using (var wDlg = new frmEditRepeat())
                {
                    // 必要なパラメータをセット
                    wDlg.DataPath = wData.DataPath;
                    wDlg.MainCellAddr = wData.CellAddress;
                    wDlg.SelectedRepeatAddress = wData.RepeatAddress;

                    // ダイアログの表示を要求
                    SendNotifyInfo(new RldDesignNotifyInfoRequestOpenDialogEventArgs(wDlg)
                    {
                        IsAllWindowLock = false,
                        IsProtectLayoutSheet = true
                    });

                    if (wDlg.DialogResult == DialogResult.OK)
                    {
                        // 繰返し範囲を更新
                        wData.RepeatAddress = wDlg.SelectedRepeatAddress;
                        // add #11294 紹介状で集計部分がずれて出力される 高 start
                        wData.repDirection = wDlg.RepDirection;
                        // add #11294 紹介状で集計部分がずれて出力される 高 end

                        // TODO: 繰返し対象セルの書式を変更する

                        // グループデータを取得して繰返し回数を更新
                        DesignGroupData wGrpData = RldLib.CurrentLayoutData.FindDesignGroupData(wData);
                        if (wGrpData != null)
                        {
                            wGrpData.RepeatCount = wData.RepeatCount;
                        }
                    }
                }
            }
            // フィルタ編集クリック時
            else if (wFuncEqualColumn(DesignParamData.EnumDataIndex.ButtonEditFilterText))
            {
                // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
                bool gorupData = true;
                // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end
                switch (wData.FilterType)
                {
                    case RldConst.FilterType.Parameter.EXAMINE:
                    case RldConst.FilterType.Parameter.EXAM_SET:
					// del #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                    //// add FNSI-699,700,751 装置帳票の記録簿対応 夏 start
                    //case RldConst.FilterType.Parameter.INSPECTION:
                    //// add FNSI-699,700,751 装置帳票の記録簿対応 夏 end
					// del #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end

                    // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
                    case RldConst.FilterType.Parameter.WQTESTPOINT:
                    // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
                    // add FNSI-5915 李 start
                    case RldConst.FilterType.Parameter.CATEGORY:
                    // add FNSI-5915 李 end
                        // 検査項目・検査セット選択画面
                        using (var wDlg = new frmSelectExamFilter())
                        {
                            wDlg.Path = wData.DataPath;
                            //add #9711 既存帳票を開くと致命的エラーが発生 dongzhaolong start
                            wDlg.CellAddress = wData.CellAddress;
                            //add #9711 既存帳票を開くと致命的エラーが発生 dongzhaolong end

                            // add FNSI-699,700,751 装置帳票の記録簿対応 夏 start
                            if ("Inspection".Equals(wData.FilterType))
                            {
                                wDlg.FilterType = frmSelectExamFilter.EnumFilterType.Inspection;
                            }
                            // add FNSI-5915 李 start
                            else if ("Category".Equals(wData.FilterType)) {
                                wDlg.FilterType = frmSelectExamFilter.EnumFilterType.Category;
                            }
                            // add FNSI-5915 李 end
                            // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
                            else if (RldConst.FilterType.Parameter.WQTESTPOINT.Equals(wData.FilterType))
                            {
                                wDlg.FilterType = frmSelectExamFilter.EnumFilterType.WQTestPoint;
                            }
                            // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
                            else
                            {
                                // add FNSI-699,700,751 装置帳票の記録簿対応 夏 end
                                wDlg.FilterType = wData.FilterType == RldConst.FilterType.Parameter.EXAMINE ? frmSelectExamFilter.EnumFilterType.ExaminItem : frmSelectExamFilter.EnumFilterType.ExaminSet;
                            }
                            wDlg.FilterData = wData.FilterData;

                            // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
                            bool initSuccess = wDlg.InitializeAsync().GetAwaiter().GetResult();
                            if (initSuccess)
                            // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
                            {
                                // ダイアログの表示を要求
                                SendNotifyInfo(new RldDesignNotifyInfoRequestOpenDialogEventArgs(wDlg)
                                {
                                    IsAllWindowLock = true,
                                    IsProtectLayoutSheet = true
                                });

                                // OKボタン押下時はフィルタを更新
                                if (wDlg.DialogResult == DialogResult.OK)
                                {
                                    wData.FilterData = wDlg.FilterData;
                                    wData.FilterState = RldConst.ParamData.VAL_FILTER_STATE_YES;

                                    // 同一グループへフィルタを適用する場合
                                    if (wDlg.IsApplySameGroup)
                                    {
                                        // add #10530 個別フィルタダイアログの「同グループの別項目に展開」機能が動いていない 高 start
                                        //foreach (DesignParamData wElement in RldLib.CurrentLayoutData.DesignParamList.Where(ele => ele.FilterType == wData.FilterType && ele.GroupPath == wData.GroupPath && ele.CellAddress != wData.CellAddress))
                                        foreach (DesignParamData wElement in RldLib.CurrentLayoutData.DesignParamList.Where(ele => ele.FilterType == wData.FilterType && ele.GroupName == wData.GroupName && ele.CellAddress != wData.CellAddress))
                                        // add #10530 個別フィルタダイアログの「同グループの別項目に展開」機能が動いていない 高 end
                                        {
                                            wElement.FilterData = wData.FilterData;
                                            wElement.FilterState = wData.FilterState;
                                        }
                                    }
                                }
                            }
                        }
                        // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
                        gorupData = false;
                        // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end
                        break;
					
					// add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                    case RldConst.FilterType.Parameter.INSPECTION:
                        // 日常点検・定期点検選択画面
                        using (var wDlg = new frmSelectMainteFilter())
                        {
                            wDlg.Path = wData.DataPath;
                            wDlg.CellAddress = wData.CellAddress;

                            if ("Inspection".Equals(wData.FilterType))
                            {
                                wDlg.FilterType = frmSelectMainteFilter.EnumFilterType.Inspection;
                            }

                            wDlg.FilterData = wData.FilterData;

                            // ダイアログの表示を要求
                            SendNotifyInfo(new RldDesignNotifyInfoRequestOpenDialogEventArgs(wDlg)
                            {
                                IsAllWindowLock = true,
                                IsProtectLayoutSheet = true
                            });

                            // OKボタン押下時はフィルタを更新
                            if (wDlg.DialogResult == DialogResult.OK)
                            {
                                wData.FilterData = wDlg.FilterData;
                                wData.FilterState = RldConst.ParamData.VAL_FILTER_STATE_YES;

                                // 同一グループへフィルタを適用する場合
                                if (wDlg.IsApplySameGroup)
                                {
                                    foreach (DesignParamData wElement in RldLib.CurrentLayoutData.DesignParamList.Where(ele => ele.FilterType == wData.FilterType && ele.GroupName == wData.GroupName && ele.CellAddress != wData.CellAddress))
                                    {
                                        wElement.FilterData = wData.FilterData;
                                        wElement.FilterState = wData.FilterState;
                                    }
                                }
                            }
                        }
                        gorupData = false;
                        break;
                    // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
					
                    // UNDONE: FNWベースで実装しコメントアウト
                    ////case RldConst.FilterType.Parameter.WATER_SURVEY:
                    ////    // 水質調査箇所選択画面
                    ////    using( var wDlg = new frmSelectWaterSurveyPointFilter() ) {
                    ////        wDlg.Path = wData.DataPath;
                    ////        wDlg.FilterData = wData.FilterData;

                    ////        // ダイアログの表示を要求
                    ////        SendNotifyInfo(new RldDesignNotifyInfoRequestOpenDialogEventArgs(wDlg) {
                    ////            IsAllWindowLock = true,
                    ////            IsProtectLayoutSheet = true
                    ////        });

                    ////        // OKボタン押下時はフィルタを更新
                    ////        if( wDlg.DialogResult == DialogResult.OK ) {
                    ////            wData.FilterData = wDlg.FilterData;
                    ////            wData.FilterState = RldConst.ParamData.VAL_FILTER_STATE_YES;

                    ////            // 同一グループへフィルタを適用する場合
                    ////            if( wDlg.IsApplySameGroup ) {
                    ////                foreach( DesignParamData wElement in RldLib.CurrentLayoutData.DesignParamList.Where(ele => ele.FilterType == wData.FilterType && ele.GroupPath == wData.GroupPath && ele.CellAddress != wData.CellAddress) ) {
                    ////                    wElement.FilterData = wData.FilterData;
                    ////                    wElement.FilterState = wData.FilterState;
                    ////                }
                    ////            }
                    ////        }
                    ////    }
                    ////    break;

                    default:
                        break;
                }
                // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
                // フィルタ編集クリック時
                if (gorupData){
                    using (var wDlg = new frmSelectGenericFilter())
                    {
                        switch (wData.FilterType)
                        {
                            case RldConst.FilterType.Group.OBSKIND:
                                wDlg.Path = wData.GroupPath;
                                wDlg.FilterType = frmSelectGenericFilter.EnumFilterType.ObsKind;
                                wDlg.FilterData = wData.FilterData;
                                break;

                            case RldConst.FilterType.Group.MEDICINE:
                                wDlg.Path = wData.GroupPath;
                                wDlg.FilterType = frmSelectGenericFilter.EnumFilterType.Medicine;
                                wDlg.FilterData = wData.FilterData;
                                break;

                            case RldConst.FilterType.Group.EQUIP:
                                wDlg.Path = wData.GroupPath;
                                wDlg.FilterType = frmSelectGenericFilter.EnumFilterType.Equipment;
                                wDlg.FilterData = wData.FilterData;
                                break;

                            case RldConst.FilterType.Group.DIALDIFF:
                                wDlg.Path = wData.GroupPath;
                                wDlg.FilterType = frmSelectGenericFilter.EnumFilterType.DialDiff;
                                wDlg.FilterData = wData.FilterData;
                                break;

                            case RldConst.FilterType.Group.PATEVENT:
                                wDlg.Path = wData.GroupPath;
                                wDlg.FilterType = frmSelectGenericFilter.EnumFilterType.PatEvent;
                                wDlg.FilterData = wData.FilterData;
                                break;

                            case RldConst.FilterType.Group.ADDITION:
                                wDlg.Path = wData.GroupPath;
                                wDlg.FilterType = frmSelectGenericFilter.EnumFilterType.Addition;
                                wDlg.FilterData = wData.FilterData;
                                break;

                        }

                        // ダイアログの表示を要求
                        this.SendNotifyInfo(new RldDesignNotifyInfoRequestOpenDialogEventArgs(wDlg)
                        {
                            IsAllWindowLock = true,
                            IsProtectLayoutSheet = true
                        });

                        // OKボタン押下時はフィルタを更新
                        if (wDlg.DialogResult == DialogResult.OK)
                        {
                            wData.FilterData = wDlg.FilterData;
                            wData.FilterState = wDlg.IsSelectPart ? RldConst.GroupData.VAL_FILTER_STATE_PART : RldConst.GroupData.VAL_FILTER_STATE_ALL;
                        }
                    }
                }
                // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end
            }
            // del #11390 【たくしん会】レイアウトデザイナの「条件付き書式」機能は廃止する limingzhe start
            // 条件付き書式編集クリック時
            //else if (wFuncEqualColumn(DesignParamData.EnumDataIndex. ButtonEditFormatConditionText))
            //{
            //    // 条件付き書式編集画面
            //    using (var wDlg = new FrmFormatConditions())
            //    {
            //        // 条件付き書式ルール
            //        wDlg.Rules = wData.FormatCondition;
            //        // ダイアログの表示を要求
            //        SendNotifyInfo(new RldDesignNotifyInfoRequestOpenDialogEventArgs(wDlg)
            //        {
            //            IsAllWindowLock = true,
            //            IsProtectLayoutSheet = true
            //        });
            //        if (wDlg.DialogResult == DialogResult.OK)
            //        {
            //            // wData に記憶する
            //            wData.FormatCondition = wDlg.Rules;
            //            // DataGridViewセルの背景色を設定する
            //            void SetBackColor(DataGridViewCellStyle cellStyle, System.Drawing.Color backColor)
            //            {
            //                if (cellStyle.BackColor != backColor)
            //                {
            //                    cellStyle.BackColor = backColor;
            //                }
            //            }
            //            if (wDlg.Rules.Count > 0)
            //            {
            //                //　オレンジでなければ、オレンジにする
            //                SetBackColor((global::System.Windows.Forms.DataGridViewCellStyle)this.Target[(int)e.ColumnIndex, (int)e.RowIndex].Style, System.Drawing.Color.DarkOrange);
            //            }
            //            else
            //            {
            //                // 黒でなければ黒にする
            //                SetBackColor((global::System.Windows.Forms.DataGridViewCellStyle)this.Target[(int)e.ColumnIndex, (int)e.RowIndex].Style, System.Drawing.Color.Black);
            //            }
            //        }
            //    }
            //}
            // del #11390 【たくしん会】レイアウトデザイナの「条件付き書式」機能は廃止する limingzhe end
            // ラベル項目編集クリック時
            else if (wFuncEqualColumn(DesignParamData.EnumDataIndex.ButtonEditLabelItemText))
            {
                // 分類別情報編集ダイアログを表示する
                using (var wDlg = new frmEditLabelClass())
                {

                    // 必要なパラメータをセット
                    wDlg.LabelClassSetting = wData.LabelItem;

                    // ダイアログの表示を要求
                    this.SendNotifyInfo(new RldDesignNotifyInfoRequestOpenDialogEventArgs(wDlg)
                    {
                        IsAllWindowLock = true,
                        IsProtectLayoutSheet = true
                    });

                    // OKボタン押下時は分類別情報を更新
                    if (wDlg.DialogResult == DialogResult.OK)
                    {
                        wData.LabelItem = wDlg.LabelClassSetting;
                    }

                }

            }
            // add #11535 帳票の汎用バーコード出力対応 高 start
            // バーコード編集クリック時
            else if (wFuncEqualColumn(DesignParamData.EnumDataIndex.ButtonEditBarCodeText))
            {

                // バーコード選択画面
                using (var wDlg = new frmSelectFormat())
                {
                    // 必要なパラメータをセット
                    wDlg.DataPath = wData.DataPath;
                    wDlg.DataType = "BarCode";
                    wDlg.SelectedFormat = wData.BarCode;
                    // add #10230 コピーした内容がリセットされる 高 start
                    wData.DisplayFormatUpdate = true;
                    // add #10230 コピーした内容がリセットされる 高 end

                    // ダイアログの表示を要求
                    SendNotifyInfo(new RldDesignNotifyInfoRequestOpenDialogEventArgs(wDlg)
                    {
                        IsAllWindowLock = true,
                        IsProtectLayoutSheet = true
                    });

                    // OKボタン押下時は書式を更新
                    if (wDlg.DialogResult == DialogResult.OK)
                    {
                        wData.BarCode = wDlg.SelectedFormat;
                    }
                }
            }
            // add #11535 帳票の汎用バーコード出力対応 高 end
        }

        /// <summary>
        /// 制御対象コントロールの CurrentCellDirtyStateChanged イベントハンドラ
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void OnTarget_CurrentCellDirtyStateChanged(object sender, EventArgs e)
        {
            var wDataGridView = (DataGridView)sender;

            if (wDataGridView.IsCurrentCellDirty)
            {
                if (wDataGridView.CurrentCell is DataGridViewCheckBoxCell)
                {
                    wDataGridView.EndEdit();
                }
            }
        }

        /// <summary>
        /// 制御対象コントロールの DataGridViewの DataBindingComplete イベントハンドラ
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void OnTarget_DataBindingComplete(object sender, DataGridViewBindingCompleteEventArgs e)
        {
            foreach (DataGridViewRow wRow in Target.Rows)
            {

                // 該当行にバインドされているデータを取得
                if (!(wRow.DataBoundItem is DesignParamData wBindData))
                {
                    continue;
                }

                /// <summary>
                /// 指定されたデータインデックスのセルを読取専用に変更します。
                /// </summary>
                /// <param name="aDataIndex"></param>
                void wFuncSetCellReadOnly(DesignParamData.EnumDataIndex aDataIndex, bool aIsSetReadOnly) =>
                    RldDataGridViewStaticMethods.SetCellReadOnly(Target, wRow.Index, DesignParamData.GetPropertyName(aDataIndex), aIsSetReadOnly);

                // 読取専用状態を更新
                wFuncSetCellReadOnly(DesignParamData.EnumDataIndex.ButtonEditDisplayFormatText, !wBindData.CanEditDisplayFormat);
                wFuncSetCellReadOnly(DesignParamData.EnumDataIndex.ButtonEditConvertListText, !wBindData.CanEditConvertList);
                wFuncSetCellReadOnly(DesignParamData.EnumDataIndex.ButtonEditRepeatText, !wBindData.CanEditRepeat);
                wFuncSetCellReadOnly(DesignParamData.EnumDataIndex.IsShrink, !wBindData.CanEditShrink);
                wFuncSetCellReadOnly(DesignParamData.EnumDataIndex.Length, !wBindData.CanEditLength);
                // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
                if (wBindData.FilterType == RldConst.FilterType.Group.MEDICINE)    // 薬剤
                {
                    wFuncSetCellReadOnly(DesignParamData.EnumDataIndex.ButtonEditFilterText, true);
                    wBindData.FilterState = string.Empty;
                }
                else if (wBindData.FilterType == RldConst.FilterType.Group.EQUIP)    // 医材
                {
                    wFuncSetCellReadOnly(DesignParamData.EnumDataIndex.ButtonEditFilterText, true);
                    wBindData.FilterState = string.Empty;
                }
                else if (wBindData.FilterType == RldConst.FilterType.Group.CATEGORY)
                {
                    wFuncSetCellReadOnly(DesignParamData.EnumDataIndex.ButtonEditFilterText, true);
                    wBindData.FilterState = string.Empty;
                }
                // add #12006 感染症がフィルタできない 高 start
                else if (wBindData.FilterType == RldConst.FilterType.Group.INFECTION    // 感染症
                        || wBindData.FilterType == RldConst.FilterType.Group.PECEIPT    // レセプト
                        || wBindData.FilterType == RldConst.FilterType.Group.LOGTARGET  // 指示履歴
                        || wBindData.FilterType == RldConst.FilterType.Group.EQUIP_DIA  // 器材
                        // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 start
                        // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
                        || wBindData.FilterType == RldConst.FilterType.Group.WQTESTTYPE  // 水質検査
                        // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
                        // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 end
                        // add #12756 クラス「##準備リスト.物品情報」のフィルタ設定が不十分 高 start
                        || wBindData.FilterType == RldConst.FilterType.Group.GOODS  // 物品情報
                        // add #12756 クラス「##準備リスト.物品情報」のフィルタ設定が不十分 高 start
                        )
                {
                    wFuncSetCellReadOnly(DesignParamData.EnumDataIndex.ButtonEditFilterText, true);
                    wBindData.FilterState = string.Empty;
                }
                // add #12006 感染症がフィルタできない 高 end
                else
                {
                    // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end
                    wFuncSetCellReadOnly(DesignParamData.EnumDataIndex.ButtonEditFilterText, !wBindData.CanEditFilter);
                }
                wFuncSetCellReadOnly(DesignParamData.EnumDataIndex.IsNewPage, !wBindData.CanEditNewPage);
                wFuncSetCellReadOnly(DesignParamData.EnumDataIndex.ButtonEditLabelItemText, !wBindData.CanEditLabelItem);
                wFuncSetCellReadOnly(DesignParamData.EnumDataIndex.GroupName, !wBindData.CanEditGroupName);
                // add #11535 帳票の汎用バーコード出力対応 高 start
                wFuncSetCellReadOnly(DesignParamData.EnumDataIndex.ButtonEditBarCodeText, !wBindData.CanEditBarCode);
                // add #11535 帳票の汎用バーコード出力対応 高 end
                // add #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 start
                wFuncSetCellReadOnly(DesignParamData.EnumDataIndex.PreviewData, wBindData.CanEditBarCode);
                // add #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 end
            }
        }

        //// add #8394 動作に関する指摘 董 start
        /// <summary>
        /// 指定されたデータで レイアウトシートのセルの書式設定を更新します。
        /// </summary>
        /// <param name="aData"></param>
        private void UpdateLayoutSheetRangeFormatSetting(DesignParamData aData)
        {
            try
            {
                using (var wXlRange = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, aData.CellAddress))
                {
                    // 書式
                    if (aData.DataType != "DateTime")
                    {
                        wXlRange.Range.NumberFormatLocal = aData.DisplayFormat;
                    }
                    else
                    {
                        string strFormat = aData.DisplayFormat;
                        //ADD #8394,#8566 日付時刻型のデータ項目に書式設定が反映しない 董 start
                        if (strFormat.Contains("[$-F800]"))
                        {
                            //wXlRange.Range.NumberFormatLocal = 
                            strFormat = "yyyy\"年\"m\"月\"d\"日\"";
                        }
                        else if (strFormat.Contains("[$-F400]"))
                        {
                            //wXlRange.Range.NumberFormatLocal = 
                            strFormat = "h:mm:ss";
                        }
                        // del #10469 単患者帳票で「印刷日時」の書式が反映されない limingzhe start
                        //else if (strFormat.Contains("mm/d"))
                        //{
                        //    //wXlRange.Range.NumberFormatLocal = 
                        //    strFormat = strFormat.Replace("mm/", "MM/");
                        //}
                        //else if (strFormat.Contains("m/d"))
                        //{
                        //    //wXlRange.Range.NumberFormatLocal = 
                        //    strFormat = strFormat.Replace("m/", "M/");
                        //}
                        //else if (strFormat.Contains("yyyy-mm-dd"))
                        //{
                        //    //wXlRange.Range.NumberFormatLocal = 
                        //    strFormat = strFormat.Replace("-mm-", "-MM-");
                        //}
                        // del #10469 単患者帳票で「印刷日時」の書式が反映されない limingzhe end
                        if (GetDateFormat(strFormat).Replace(" ", "").Length > 0)
                        {
                            if (GetDateFormat(strFormat, GetDateFormat(strFormat).Replace(" ", "")).Length > 0)
                            {
                                //wXlRange.Range.NumberFormatLocal = 
                                strFormat = GetDateFormat(strFormat, GetDateFormat(strFormat).Replace(" ", ""));
                            }
                            else
                            {
                                //wXlRange.Range.NumberFormatLocal = 
                                strFormat = "yyyy/mm/dd hh:mm";
                            }
                        }
                        else
                        {
                            //wXlRange.Range.NumberFormatLocal = 
                            strFormat = GetSubString(strFormat);
                        }
                        // mod #10469 単患者帳票で「印刷日時」の書式が反映されない limingzhe start
                        if (strFormat.Equals("gyy/m") || strFormat.Equals("ge/m") || strFormat.Equals("gy/m"))
                        {
                            wXlRange.Range.NumberFormatLocal = "ge/m";
                            aData.DisplayFormat = "gy/m";
                        }
                        else
                        {
                            wXlRange.Range.NumberFormatLocal = aData.DisplayFormat = strFormat;
                        }
                        // mod #10469 単患者帳票で「印刷日時」の書式が反映されない limingzhe end
                        // 6096_日付の書式を変更した際、プレビューデータの欄に反映されない 2021/08/25 add start 李

                        DateTime dt = DateTime.Now;
                        string year = dt.Year.ToString();
                        string mounth = dt.Month.ToString();
                        string mounth2 = mounth.Length == 2 ? mounth : "0" + mounth;
                        string day = dt.Day.ToString();
                        string day2 = day.Length == 2 ? day : "0" + day;
                        string hour = dt.Hour.ToString();
                        string hour2 = hour.Length == 2 ? hour : "0" + hour;
                        string minute = dt.Minute.ToString();
                        string mimute2 = minute.Length == 2 ? minute : "0" + minute;
                        string second = dt.Second.ToString();
                        string second2 = second.Length == 2 ? second : "0" + second;
                        string week = GetWeek(dt.DayOfWeek.ToString());

                        // edit #8394 4-1,#8566 日付時刻型のデータ項目に書式設定が反映しない 董 start
                        DateTime dtBasic = new DateTime(1899, 12, 31);
                        TimeSpan tsNow = dt.Subtract(dtBasic);
                        int totalDays = tsNow.Days + 1;
                        string totalHours = (totalDays * 24 + dt.Hour).ToString();
                        // edit #8394 4-1,#8566 日付時刻型のデータ項目に書式設定が反映しない 董 end

                        // add #7297 初回リリース対象外の機能とその関連機能を隠す xiaosonglei start
                        // string res = "";
                        string res = aData.PreviewData;
                        // add #7297 初回リリース対象外の機能とその関連機能を隠す xiaosonglei end

                        // add #8394(1) 動作に関する指摘 luantian start
                        CultureInfo jpCulture = new CultureInfo("ja-JP", true);

                        //ADD #8394,#8566 日付時刻型のデータ項目に書式設定が反映しない 董 START
                        CultureInfo currentCulture = new CultureInfo(System.Threading.Thread.CurrentThread.CurrentUICulture.Name, true);
                        //ADD #8394,#8566 日付時刻型のデータ項目に書式設定が反映しない 董 END
                        jpCulture.DateTimeFormat.Calendar = new JapaneseCalendar();

                        var eraTable = new Dictionary<int, string>();
                        for (char e = 'A'; e <= 'Z'; e++)
                        {
                            int eraIndex = jpCulture.DateTimeFormat.GetEra(e.ToString());
                            if (eraIndex > 0)
                                eraTable.Add(eraIndex, e.ToString());
                        }
                        string eraLetter = "";
                        int eraNumber = jpCulture.DateTimeFormat.Calendar.GetEra(dt);
                        if (eraTable[eraNumber] != null)
                        {
                            eraLetter = eraTable[eraNumber];
                        }
                        // add #8394(1) 動作に関する指摘 luantian end

                        if (aData.DisplayFormat.Equals("yyyy\"年\"m\"月\"d\"日\"(aaa) h\"時\"mm\"分\""))
                        {
                            res = year + "年" + mounth + "月" + day + "日(" + week + ")" + hour + "時" + mimute2 + "分";
                        }
                        else if (aData.DisplayFormat.Equals("yyyy\"年\"m\"月\"d\"日\" h\"時\"mm\"分\""))
                        {
                            res = year + "年" + mounth + "月" + day + "日 " + hour + "時" + mimute2 + "分";
                        }
                        else if (aData.DisplayFormat.Equals("yyyy/m/d h:mm"))
                        {
                            res = year + "/" + mounth + "/" + day + " " + hour + ":" + mimute2;
                        }
                        else if (aData.DisplayFormat.Equals("yyyy/mm/dd hh:mm"))
                        {
                            res = year + "/" + mounth2 + "/" + day2 + " " + hour2 + ":" + mimute2;
                        }
                        else if (aData.DisplayFormat.Equals("yyyy\"年\"m\"月\""))
                        {
                            res = year + "年" + mounth + "月";
                        }
                        else if (aData.DisplayFormat.Equals("yyyy\"年\"m\"月\"d\"日\"(aaa)"))
                        {
                            res = year + "年" + mounth + "月" + day + "日(" + week + ")";
                        }
                        else if (aData.DisplayFormat.Equals("yyyy\"年\"m\"月\"d\"日\""))
                        {
                            res = year + "年" + mounth + "月" + day + "日";
                        }
                        else if (aData.DisplayFormat.Equals("yyyy/m/d"))
                        {
                            res = year + "/" + mounth + "/" + day;
                        }
                        else if (aData.DisplayFormat.Equals("yyyy/mm/dd"))
                        {
                            res = year + "/" + mounth2 + "/" + day2;
                        }
                        else if (aData.DisplayFormat.Equals("m\"月\"d\"日\"(aaa)"))
                        {
                            res = mounth + "月" + day + "日(" + week + ")";
                        }
                        else if (aData.DisplayFormat.Equals("m\"月\"d\"日\""))
                        {
                            res = mounth + "月" + day + "日";
                        }
                        else if (aData.DisplayFormat.Equals("m/d(aaa)") || aData.DisplayFormat.Equals("M/d(aaa)"))
                        {
                            res = mounth + "/" + day + "(" + week + ")";
                        }
                        else if (aData.DisplayFormat.Equals("m/d"))
                        {
                            res = mounth + "/" + day;
                        }
                        else if (aData.DisplayFormat.Equals("(aaa)"))
                        {
                            res = "(" + week + ")";
                        }
                        else if (aData.DisplayFormat.Equals("aaa\"曜日\""))
                        {
                            res = week + "曜日";
                        }
                        else if (aData.DisplayFormat.Equals("m/d h:mm"))
                        {
                            res = mounth + "/" + day + " " + hour + ":" + mimute2;
                        }
                        else if (aData.DisplayFormat.Equals("h:mm:ss"))
                        {
                            res = hour + ":" + mimute2 + ":" + second2;
                        }
                        else if (aData.DisplayFormat.Equals("h\"時\"mm\"分\"ss\"秒\""))
                        {
                            res = hour + "時" + mimute2 + "分" + second2 + "秒";
                        }
                        else if (aData.DisplayFormat.Equals("h:mm"))
                        {
                            res = hour + ":" + mimute2;
                        }
                        else if (aData.DisplayFormat.Equals("hh:mm"))
                        {
                            res = hour2 + ":" + mimute2;
                        }
                        else if (aData.DisplayFormat.Equals("h\"時\"mm\"分\""))
                        {
                            res = hour + "時" + mimute2 + "分";
                        }
                        // add #8394(3,4) 動作に関する指摘 luantian start
                        else if (aData.DisplayFormat.Equals("gy/m"))
                        {
                            res = eraLetter + dt.ToString("y/", jpCulture) + mounth;
                        }
                        else if (aData.DisplayFormat.Equals("ggge\"年\"m\"月\"d\"日\"(aaa)"))
                        {
                            res = dt.ToString("gggy\"年\"" + mounth + "\"月\"d\"日\"(", jpCulture) + week + ")";
                        }
                        else if (aData.DisplayFormat.Equals("ggge\"年\"m\"月\"d\"日\""))
                        {
                            res = dt.ToString("gggy\"年\"" + mounth + "\"月\"d\"日\"", jpCulture);
                        }
                        else if (aData.DisplayFormat.Equals("ge/m/d"))
                        {
                            res = eraLetter + dt.ToString("y/" + mounth + "/d", jpCulture);
                        }
                        // edit #8394 4-1,#8566 日付時刻型のデータ項目に書式設定が反映しない 董 start
                        else if (aData.DisplayFormat.Equals("[h]:mm:ss"))
                        {
                            //res = dt.ToString("h:mm:ss", jpCulture);
                            res = totalHours + ":" + mimute2 + ":" + second2;
                        }
                        else if (aData.DisplayFormat.Equals("[h]\"時間\"mm\"分\"ss\"秒\""))
                        {
                            //res = dt.ToString("h\"時間\"mm\"分\"ss\"秒\"", jpCulture);
                            res = totalHours + "時間" + mimute2 + "分" + second2 + "秒";
                        }
                        else if (aData.DisplayFormat.Equals("[h]:mm"))
                        {
                            //res = dt.ToString("h:mm", jpCulture);
                            res = totalHours + ":" + mimute2;
                        }
                        else if (aData.DisplayFormat.Equals("[h]\"時間\"mm\"分\""))
                        {
                            //res = dt.ToString("h\"時間\"mm\"分\"", jpCulture);
                            res = totalHours + "時間" + mimute2 + "分";
                        }
                        // edit #8394 4-1,#8566 日付時刻型のデータ項目に書式設定が反映しない 董 end
                        else if (aData.DisplayFormat.Equals("h:mm AM/PM"))
                        {
                            res = dt.ToString("h:mm ", jpCulture) + dt.ToString("tt", jpCulture);
                        }
                        //ADD #8394,#8566 日付時刻型のデータ項目に書式設定が反映しない 董 START
                        else
                        {
                            if (aData.DisplayFormat == "mmmmm")
                            {
                                res = aData.DisplayFormat.Replace("mmmmm", dt.ToString("MMMMM", CultureInfo.CreateSpecificCulture("en-GB")).Substring(0, 1));
                            }
                            else if (aData.DisplayFormat.Contains("mmmmm"))
                            {
                                res = dt.ToString(aData.DisplayFormat.Replace("AM/PM", "tt").Replace("mmmmm", dt.ToString("MMMMM", CultureInfo.CreateSpecificCulture("en-GB")).Substring(0, 1)), currentCulture);
                            }
                            else if (aData.DisplayFormat.Contains("mmmm"))
                            {
                                res = dt.ToString(aData.DisplayFormat.Replace("AM/PM", "tt").Replace("mmmm", dt.ToString("MMMM", CultureInfo.CreateSpecificCulture("en-GB"))), currentCulture);
                            }
                            else if (aData.DisplayFormat.Contains("mmm"))
                            {
                                res = dt.ToString(aData.DisplayFormat.Replace("AM/PM", "tt").Replace("mmm", dt.ToString("MMM", CultureInfo.CreateSpecificCulture("en-GB"))), currentCulture);
                            }
                            else
                            {
                                res = dt.ToString(aData.DisplayFormat.Replace("AM/PM", "tt"), currentCulture);
                            }
                        }
                        //ADD #8394,#8566 日付時刻型のデータ項目に書式設定が反映しない 董 END

                        // add #8394(3,4) 動作に関する指摘 luantian start
                        aData.PreviewData = res;
                    }

                    //ADD #8394,#8566 日付時刻型のデータ項目に書式設定が反映しない 董 END
                    // 6096_日付の書式を変更した際、プレビューデータの欄に反映されない 2021/08/25 add end 李
                    // 縮小して全体を表示
                    wXlRange.Range.ShrinkToFit = aData.IsShrink == RldConst.ParamData.VAL_ISSHRINK_NONE ? false : true;
                }
            }
            catch
            {
                throw;
            }
        }

        private string GetWeek(string EngWeek)
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("Monday", "月");
            data.Add("Tuesday", "火");
            data.Add("Wednesday", "水");
            data.Add("Thursday", "木");
            data.Add("Friday", "金");
            data.Add("Saturday", "土");
            data.Add("Sunday", "日");
            return data[EngWeek];
        }
        //// add #8394 動作に関する指摘 董 end

        //ADD #8394,#8566 日付時刻型のデータ項目に書式設定が反映しない 董 START
        private string GetDateFormat(string orgFormat,string strBasic = "[]()AYMDHMSGEPymdhmsagep:/-時間分秒年月曜日\"")
        {
            orgFormat = GetSubString(orgFormat);
            int len = orgFormat.Length;
            char[] s2 = new char[len];
            int index = 0;
            for (int i = 0; i < len; i++)
            {
                char c = orgFormat[i];
                if (!strBasic.Contains(c))
                    s2[index++] = c;
            }
            return new String(s2, 0, index);
        }

        private string GetSubString(string orgFormat)
        {
            if (orgFormat.Contains("[") && orgFormat.Contains("]"))
            {
                if (orgFormat.IndexOf("]") - orgFormat.IndexOf("[") == 2)
                {
                    if (!(orgFormat.Substring(orgFormat.IndexOf("[") +1, 1) == "h"))
                    {
                        string strLeft = orgFormat.Remove(orgFormat.IndexOf("["));
                        string strRight = orgFormat.Substring(orgFormat.IndexOf("]") + 1);
                        orgFormat = strLeft + strRight;
                    }

                }
                else
                {
                    if (orgFormat.IndexOf("]") < orgFormat.IndexOf("["))
                    {
                        orgFormat = Regex.Replace(orgFormat, @"\[\]", "");
                    }
                    else
                    {
                        string strLeft = orgFormat.Remove(orgFormat.IndexOf("["));
                        string strRight = orgFormat.Substring(orgFormat.IndexOf("]") + 1);
                        orgFormat = strLeft + strRight;
                    }

                }
            }
            else
            {
                orgFormat = Regex.Replace(orgFormat, @"\[\]", "");
            }
            return orgFormat;
        }
        //ADD #8394,#8566 日付時刻型のデータ項目に書式設定が反映しない 董 END
        ///
        #endregion
    }
}
