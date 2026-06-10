using LayoutDesignerUtilityLib;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

using RldUtility = LayoutDesignerUtilityLib.LayoutDesignerUtility;
//add #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 START
using LayoutDesigner.Helpers;
//add #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 END
//add #9767 データ項目を含むセルを結合させるとパラメータ一覧とのリンクが切れる dongzhaolong start
using System.Text.RegularExpressions;
using System.Globalization;
//add #9767 データ項目を含むセルを結合させるとパラメータ一覧とのリンクが切れる dongzhaolong end
//add #9850 印刷範囲外に文字が入力されていないのにメッセージが出る dongzhaolong start
using Excel = Microsoft.Office.Interop.Excel;
//add #9850 印刷範囲外に文字が入力されていないのにメッセージが出る dongzhaolong end
namespace LayoutDesigner
{
    /// <summary>
    /// データ項目リスト画面
    /// </summary>
    public partial class frmDesignChildDataList : frmDesignChildBase
    {
        #region 内部使用クラス定義
        //8559 add  董 start
        private DesignItemListData selectItem = null;
        private bool canDataRead = false;
        //8559 add  董 end
        //add #9850 印刷範囲外に文字が入力されていないのにメッセージが出る dongzhaolong start
        public static int printType = 0;
        private bool confirmPrintArea = false;
        private Microsoft.Office.Interop.Excel.Range usedRange = null;
        private Microsoft.Office.Interop.Excel.Range oldUsedRange = null;
        //add #9850 印刷範囲外に文字が入力されていないのにメッセージが出る dongzhaolong end
        /// <summary>
        /// ドラッグアンドドロップヘルパークラス
        /// </summary>
        private class DragDropHelper : IRldDesignSendOnlyColleague
        {
            #region メンバ定数定義

            private const String WIN32API_COMCTL32 = "comctl32.dll";
            private const String WIN32API_USER232 = "user32.dll";

            #endregion

            #region Win32API宣言

            /// <summary>
            /// (Win32Api) ImageList_BeginDrag
            /// </summary>
            /// <param name="himlTrack">イメージリストのハンドル</param>
            /// <param name="iTrack">ドラッグするイメージの番号</param>
            /// <param name="dxHotspot">ドラッグ位置 (イメージ位置との相対座標)</param>
            /// <param name="dyHotspot">ドラッグ位置 (イメージ位置との相対座標)</param>
            /// <returns></returns>
            [System.Runtime.InteropServices.DllImport(WIN32API_COMCTL32)]
            private static extern Boolean ImageList_BeginDrag(IntPtr himlTrack, int iTrack, int dxHotspot, int dyHotspot);

            /// <summary>
            /// (Win32Api) ImageList_DragEnter
            /// </summary>
            /// <param name="hwndLock">ドラッグするイメージの親となるウィンドウのハンドル</param>
            /// <param name="x">ドラッグするイメージの表示位置 (ウィンドウ位置との相対座標)</param>
            /// <param name="y">ドラッグするイメージの表示位置 (ウィンドウ位置との相対座標)</param>
            /// <returns></returns>
            [System.Runtime.InteropServices.DllImport(WIN32API_COMCTL32)]
            public static extern bool ImageList_DragEnter(IntPtr hwndLock, int x, int y);

            /// <summary>
            /// (Win32Api) ImageList_DragLeave
            /// </summary>
            /// <param name="hwndLock">ドラッグするイメージの親となるウィンドウのハンドル</param>
            /// <returns></returns>
            [System.Runtime.InteropServices.DllImport(WIN32API_COMCTL32)]
            public static extern bool ImageList_DragLeave(IntPtr hwndLock);

            /// <summary>
            /// (Win32Api) ImageList_DragMove
            /// </summary>
            /// <param name="x">ドラッグするイメージの表示位置 (ウィンドウ位置との相対座標)</param>
            /// <param name="y">ドラッグするイメージの表示位置 (ウィンドウ位置との相対座標)</param>
            /// <returns></returns>
            [System.Runtime.InteropServices.DllImport(WIN32API_COMCTL32)]
            public static extern bool ImageList_DragMove(int x, int y);

            /// <summary>
            /// (Win32Api) ImageList_EndDrag
            /// </summary>
            [System.Runtime.InteropServices.DllImport(WIN32API_COMCTL32)]
            public static extern void ImageList_EndDrag();

            /// <summary>
            /// (Win32Api) GetDesktopWindow
            /// </summary>
            /// <returns></returns>
            [System.Runtime.InteropServices.DllImport(WIN32API_USER232)]
            public static extern IntPtr GetDesktopWindow();

            #endregion

            #region メンバ変数定義

            /// <summary>
            /// デスクトップハンドル
            /// </summary>
            private IntPtr m_HandleDesktop = IntPtr.Zero;

            #endregion

            #region メンバイベント定義

            public event EventHandler<RldDesignNotifyInfoEventArgs> NotifyInfo;

            #endregion

            #region 生成と破棄

            /// <summary>
            /// ドラッグアンドドロップヘルパークラスの新しいインスタンスを初期化します。
            /// </summary>
            public DragDropHelper()
            {
                // デスクトップハンドルを取得しておく
                this.m_HandleDesktop = GetDesktopWindow();
            }

            #endregion

            #region メンバプロパティ定義

            /// <summary>
            /// ドラッグ中かどうかの取得を行います。
            /// 値の取得のみ可能です。
            /// </summary>
            public Boolean IsDragIn
            {
                [System.Diagnostics.DebuggerStepThrough()]
                get
                {
                    return !(this.DragDropMouseDownPoint == System.Drawing.Point.Empty);
                }
            }

            /// <summary>
            /// 計算可能項目かどうかの取得を行います。
            /// 値の取得のみ可能です。
            /// </summary>
            public Boolean CanCalc { get; private set; } = false;

            /// <summary>
            /// ドラッグ操作を開始したコントロールの参照の取得を行います。
            /// 値の取得のみ可能です。
            /// </summary>
            public System.Windows.Forms.Control DragStartControl { get; private set; } = null;

            /// <summary>
            /// ドラッグ操作を開始した位置の取得を行います。
            /// 値の取得のみ可能です。
            /// </summary>
            public System.Drawing.Point DragDropMouseDownPoint { get; private set; } = System.Drawing.Point.Empty;

            /// <summary>
            /// ドラッグ中の文字列の取得を行います。
            /// 値の取得のみ可能です。
            /// </summary>
            public String DragText { get; private set; } = String.Empty;

            private System.Windows.Forms.ImageList ImageList { get; } = new ImageList();

            #endregion

            #region メンバ関数定義

            /// <summary>
            /// ドラッグ操作の開始を保持します。
            /// </summary>
            /// <param name="aControl"></param>
            /// <param name="aPoint"></param>
            /// <param name="aText"></param>
            public void SaveStartPoint(System.Windows.Forms.Control aControl, System.Drawing.Point aPoint, String aText) => this.SaveStartPoint(aControl, aPoint, aText, false);

            /// <summary>
            /// ドラッグ操作の開始を保持します。
            /// </summary>
            /// <param name="aControl"></param>
            /// <param name="aPoint"></param>
            /// <param name="aText"></param>
            /// <param name="aCanCalc"></param>
            public void SaveStartPoint(System.Windows.Forms.Control aControl, System.Drawing.Point aPoint, String aText, Boolean aCanCalc)
            {
                this.DragStartControl = aControl;
                this.DragDropMouseDownPoint = aPoint;
                this.DragText = aText;
                this.CanCalc = aCanCalc;

                this.DragStartControl.GiveFeedback += new GiveFeedbackEventHandler(this.OnStartControl_GiveFeedback);
                this.DragStartControl.QueryContinueDrag += new QueryContinueDragEventHandler(this.OnStartControl_QueryContinueDrag);
            }

            /// <summary>
            /// ドラッグ操作の開始を開放します。
            /// </summary>
            public void ReleaseStartPoint()
            {
                this.DragStartControl = null;
                this.DragDropMouseDownPoint = System.Drawing.Point.Empty;
                this.DragText = string.Empty;
                this.CanCalc = false;

                if (this.DragStartControl != null)
                {
                    this.DragStartControl.GiveFeedback -= new GiveFeedbackEventHandler(this.OnStartControl_GiveFeedback);
                    this.DragStartControl.QueryContinueDrag -= new QueryContinueDragEventHandler(this.OnStartControl_QueryContinueDrag);
                }
            }

            /// <summary>
            /// シートへのドラッグアンドロップ操作を開始します。
            /// </summary>
            /// <param name="aCurrentPoint"></param>
            /// <param name="aBitmap"></param>
            /// <returns></returns>
            public Boolean DoDragDrop(System.Drawing.Point aCurrentPoint, System.Drawing.Bitmap aBitmap)
            {
                Boolean wRet = false;

                String wDropCellAddr = String.Empty;
                String wBeforeValue = String.Empty;
                String wAfterValue = String.Empty;
                // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 start
                String oldCellAddr = String.Empty;
                // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 end

                var wRect = new System.Drawing.Rectangle(
                    this.DragDropMouseDownPoint.X - SystemInformation.DragSize.Width / 2,
                    this.DragDropMouseDownPoint.Y - SystemInformation.DragSize.Height / 2,
                    SystemInformation.DragSize.Width,
                    SystemInformation.DragSize.Height);

                if (!wRect.Contains(aCurrentPoint))
                {

                    try
                    {
                        //DEL #9425 テンプレート設定範囲に影響のあるレイアウト変更時は範囲プレビューを更新すること DONGZHAOLONG START
                        //RldLib.XlHelper.IsHandleLayoutSheetEvent = false;
                        //DEL #9425 テンプレート設定範囲に影響のあるレイアウト変更時は範囲プレビューを更新すること DONGZHAOLONG END

                        // ドラッグアンドドロップ処理中フラグ On
                        RldLib.IsRunningDragDrop = true;
                        frmDesignChildLayoutParam.isSkip = false;
                        this.ImageList.Images.Clear();
                        this.ImageList.ImageSize = aBitmap.Size;
                        this.ImageList.Images.Add(aBitmap);

                        DragDropHelper.ImageList_BeginDrag(this.ImageList.Handle, 0, aCurrentPoint.X - this.DragDropMouseDownPoint.X, aCurrentPoint.Y - this.DragDropMouseDownPoint.Y);
                        DragDropHelper.ImageList_DragEnter(DragDropHelper.GetDesktopWindow(), aCurrentPoint.X, aCurrentPoint.Y);

                        // ドラッグアンドドロップ操作を行い結果を取得
                        // mod #7943 帳票レイアウトデザイナーが正しく動作しない 商 start
                        //if ( this.ExecDragDrop(aBitmap, out wDropCellAddr, out wBeforeValue, out wAfterValue) ) {
                        if (this.ExecDragDrop(aBitmap, out wDropCellAddr, out wBeforeValue, out wAfterValue, out oldCellAddr))
                        {
                            // mod #7943 帳票レイアウトデザイナーが正しく動作しない 商 end

                            Int32 wNewIndex = -1;

                            // ドロップ前の位置にデータがある場合
                            if (wBeforeValue.StartsWith(RldConst.PATH_HEADER))
                                wNewIndex = RldLib.CurrentLayoutData.FindDesignParamDataIndex(wDropCellAddr);

                            // Assert
                            System.Diagnostics.Debug.Assert(wAfterValue.StartsWith(RldConst.PATH_HEADER));

                            var wData = RldLib.CurrentLayoutData.CreateDesignParamData(wAfterValue, wDropCellAddr);

                            // add #8394(1) 動作に関する指摘 luantian start
                            if (!string.IsNullOrEmpty(wData.DisplayFormat))
                            {
                                using (var wXlRange = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, wDropCellAddr))
                                {
                                    wXlRange.Range.NumberFormatLocal = wXlRange.Range.NumberFormat = wData.DisplayFormat;
                                }
                            }
                            // add #9400 複数集計で「##印刷情報.抽出条件.期間」が正しく出ない donghao start
                            else
                            {
                                using (var wXlRange = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, wDropCellAddr))
                                {
                                    // mod #11417 レイアウトデザイナでデータ項目フォーカスアウト時に致命的なエラー limingzhe start
                                    //if (wData.DataType == "string")
                                    if (wData.DataType == "string" || wData.DataType == "byte[]")
                                    // mod #11417 レイアウトデザイナでデータ項目フォーカスアウト時に致命的なエラー limingzhe end
                                    {
                                        //edit #9926 【デグレ】データ項目をドロップするとセルの状態がリセットされる dongzhaolong start
                                        //wXlRange.Range.ClearFormats();
                                        wXlRange.Range.NumberFormat = "General";
                                        //edit #9926 【デグレ】データ項目をドロップするとセルの状態がリセットされる dongzhaolong end
                                    }
                                }

                            }
                            // add #9400 複数集計で「##印刷情報.抽出条件.期間」が正しく出ない donghao end
                            // add #8394(1) 動作に関する指摘 luantian end

                            // 不足情報を付加
                            wData = RldLib.ApplyAdditionalInfoToParamData(wData);

                            if (wNewIndex != -1)
                                // ドロップ前も管理対象データだった場合は差し替え
                                RldLib.CurrentLayoutData.SetDesignParamData(wData, wNewIndex);
                            else
                            {
                                // ドロップ後のみ管理対象データだった場合は追加
                                RldLib.CurrentLayoutData.AddDesignParamData(wData);
                                // RldLib.CurrentLayoutData.DesignParamListを並べ替える
                                RldLib.CurrentLayoutData.DesignParamList.Sort();
                            }

                            // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 start
                            if (!String.IsNullOrEmpty(oldCellAddr) && !oldCellAddr.Equals(wDropCellAddr))
                            {
                                RldLib.CurrentLayoutData.DelDesignParamDataListByCellAddress(oldCellAddr);

                                // RldLib.CurrentLayoutData.DesignParamListを並べ替える
                                RldLib.CurrentLayoutData.DesignParamList.Sort();

                                using (var wXlRange = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, oldCellAddr))
                                {
                                    // セルの内容はクリアする
                                    wXlRange.Range.Value2 = string.Empty;
                                }
                            }
                            // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 end
                        }

                        DragDropHelper.ImageList_EndDrag();
                    }
                    catch (Exception ex)
                    {
                        // TODO:
                    }
                    finally
                    {
                        // ドラッグアンドドロップ操作を終了する
                        this.ReleaseStartPoint();
                        // ドラッグアンドドロップ処理中フラグ Off
                        RldLib.IsRunningDragDrop = false;

                        RldLib.XlHelper.IsHandleLayoutSheetEvent = true;
                    }
                    // ドラッグアンドドロップ操作が正常終了した場合は通知
                    if (!string.IsNullOrEmpty(wDropCellAddr))
                    {
                        // mod 8394 動作に関する指摘 吉 start
                        // this.SendNotifyInfo(new RldDesignNotifyInfoNotifyDragDropCompletedEventArgs() { DroppedCellAddress = wDropCellAddr});
                        if (null == wBeforeValue && null == oldCellAddr && null != wAfterValue)
                        {
                            this.SendNotifyInfo(new RldDesignNotifyInfoNotifyDragDropCompletedEventArgs() { DroppedCellAddress = wDropCellAddr, isRefreshAllFlag = true });
                        }
                        else
                        {
                            this.SendNotifyInfo(new RldDesignNotifyInfoNotifyDragDropCompletedEventArgs() { DroppedCellAddress = wDropCellAddr });
                        }

                        // mod 8394 動作に関する指摘 吉 end
                        wRet = true;
                    }
                }

                return wRet;
            }

            /// <summary>
            /// ドラッグアンドドロップ操作を行います。
            /// </summary>
            /// <param name="aBitmap"></param>
            /// <param name="aCellAddress"></param>
            /// <param name="aBeforeValue"></param>
            /// <param name="aAfterValue"></param>
            /// <param name="oldCellAddress"></param>
            /// <returns></returns>
            // mod #7943 帳票レイアウトデザイナーが正しく動作しない 商 start
            //private Boolean ExecDragDrop(System.Drawing.Bitmap aBitmap, out String aCellAddress,  out String aBeforeValue, out String aAfterValue)
            private Boolean ExecDragDrop(System.Drawing.Bitmap aBitmap, out String aCellAddress, out String aBeforeValue, out String aAfterValue, out String oldCellAddress)
            // mod #7943 帳票レイアウトデザイナーが正しく動作しない 商 end
            {
                Boolean wRet = false;

                // 初期化しておく
                aCellAddress = String.Empty;
                aBeforeValue = String.Empty;
                aAfterValue = String.Empty;
                // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 start
                oldCellAddress = String.Empty;
                // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 end

                try
                {
                    // 現在のレイアウトシート上の画像ファイル数を取得
                    Int32 wImgCount = 0;
                    using (var wXlShapes = new ExcelShapesEx(RldLib.XlHelper.XlSheetLayout))
                        wImgCount = wXlShapes.Shapes.Count;

                    // ドラッグアンドドロップ開始
                    var wBitmap = new System.Drawing.Bitmap(1, 1);
                    var wDragDropEffects = this.DragStartControl.DoDragDrop(wBitmap, DragDropEffects.Copy);

                    if (wDragDropEffects == DragDropEffects.Copy)
                    {

                        try
                        {
                            //RldLib.XlHelper.XlApp.Application.ScreenUpdating = false;

                            using (var wXlShapes = new ExcelShapesEx(RldLib.XlHelper.XlSheetLayout))
                            {
                                if (wXlShapes.Shapes.Count == wImgCount + 1)
                                {

                                    // ドロップした画像を削除する
                                    using (var wXlShape = new ExcelShapeEx(wXlShapes, wImgCount + 1))
                                        wXlShape.Shape.Delete();

                                    // アクティブセルに文字列をセット
                                    using (var wXlRange = RldLib.XlHelper.XlApp.GetActiveCell)
                                    {

                                        // ドロップ先のアドレスを取得
                                        aCellAddress = wXlRange.Range.Address[false, false];

                                        // 結合セルへのドロップの場合は正しい範囲を取得
                                        if (wXlRange.Range.MergeCells)
                                        {
                                            using (var wXlMerge = new ExcelRangeEx(wXlRange.Range.MergeArea))
                                                aCellAddress = wXlMerge.Range.Address[false, false];
                                        }

                                        // add 2020-08-17 FNSI-仕様追加 繰り返し範囲に項目配置ができる。 李 start
                                        //ループ領域のドラッグ不可能性の判断を増やす
                                        foreach (DesignParamData paramData in RldLib.CurrentLayoutData.DesignParamList)
                                        {
                                            // mod #10083 【デグレ】データ項目をドロップすると他の場所のデータ項目が消える donghao start
                                            //if (!string.IsNullOrEmpty(paramData.RepeatAddress) && paramData.RepeatAddress.Contains(aCellAddress))
                                            //{
                                            //    // mod #7943 帳票レイアウトデザイナーが正しく動作しない 商 start
                                            //    //return false;
                                            //    oldCellAddress = paramData.CellAddress;
                                            //    // mod #7943 帳票レイアウトデザイナーが正しく動作しない 商 end
                                            //}

                                            if (!string.IsNullOrEmpty(paramData.RepeatAddress))
                                            {
                                                if (!paramData.RepeatAddress.Contains(","))
                                                {
                                                    if (paramData.RepeatAddress == aCellAddress)
                                                    {
                                                        oldCellAddress = paramData.CellAddress;
                                                    }                                                    
                                                }
                                                else
                                                {
                                                    string[] repeatAdress = paramData.RepeatAddress.Split(',');

                                                    for (int i = 0; i < repeatAdress.Length - 1 ; i++)
                                                    {
                                                        if (repeatAdress[i] == aCellAddress)
                                                        {
                                                            oldCellAddress = paramData.CellAddress;
                                                        }
                                                    }
                                                }
                                            }
                                            // mod #10083 【デグレ】データ項目をドロップすると他の場所のデータ項目が消える donghao end
                                        }
                                        // add 2020-08-17 FNSI-仕様追加 繰り返し範囲に項目配置ができる。 李 end

                                        // 変更前後の値を取得しておく
                                        aBeforeValue = wXlRange.Range.Value2 as String ?? String.Empty;
                                        aAfterValue = this.DragText;

                                        // 新しい値をセット
                                        wXlRange.Range.Value2 = this.DragText;

                                        /*// add 2021-08-30 6009画像 李 start
                                        string isImage = RldLib.CurrentLayoutData.CreateDesignParamDataStr(aAfterValue, aCellAddress);
                                        // 画像ファイルがある場合はセルの大きさに合わせて挿入する
                                        if (isImage != "" && isImage.Equals("true"))
                                        {
                                            wXlRange.Range.Value2 = string.Empty;   // セルの内容はクリアする
                                            string wImageFilePath = string.Format(@"{0}{1}{2}", RldUtility.ImageDirPath, System.IO.Path.DirectorySeparatorChar, "placeholder.jpg");
                                            if (System.IO.File.Exists(wImageFilePath))
                                            {
                                                using (var wXlShape = new ExcelShapeEx(wXlShapes.Shapes.AddPicture(wImageFilePath, Microsoft.Office.Core.MsoTriState.msoFalse, Microsoft.Office.Core.MsoTriState.msoTrue, wXlRange.Range.Left + 1.0f, wXlRange.Range.Top + 1.0f, 0, 0)))
                                                {
                                                    wXlShape.Shape.Width = (float)wXlRange.GetWidth() - 2.0f;
                                                    wXlShape.Shape.Height = (float)wXlRange.GetHeight() - 2.0f;
                                                }
                                            }
                                        }
                                        // add 2021-08-30 6009画像 李 end*/

                                    }

                                    wRet = true;
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            throw;
                        }
                        finally
                        {
                            //if( !RldLib.XlHelper.XlApp.Application.ScreenUpdating )
                            //    RldLib.XlHelper.XlApp.Application.ScreenUpdating = true;
                        }
                    }

                    // 画像を解放
                    wBitmap?.Dispose();

                    // 最後にチェック
                    if (String.IsNullOrEmpty(aBeforeValue)) aBeforeValue = String.Empty;
                }
                catch
                {
                    // TODO:
                }

                return wRet;
            }

            /// <summary>
            /// イベントを通知します。
            /// </summary>
            /// <param name="e"></param>
            public void SendNotifyInfo(RldDesignNotifyInfoEventArgs e) => this.NotifyInfo?.Invoke(this, e);

            #endregion

            #region カスタムイベントハンドラ定義

            /// <summary>
            /// ドラッグ開始コントロールの GiveFeedback イベント
            /// </summary>
            /// <param name="sender"></param>
            /// <param name="e"></param>
            private void OnStartControl_GiveFeedback(object sender, GiveFeedbackEventArgs e)
            {
                //e.UseDefaultCursors = false;
            }

            /// <summary>
            /// ドラッグ開始コントロールの QueryContinueDrag イベント
            /// </summary>
            /// <param name="sender"></param>
            /// <param name="e"></param>
            private void OnStartControl_QueryContinueDrag(object sender, QueryContinueDragEventArgs e)
            {
                DragDropHelper.ImageList_DragMove(Cursor.Position.X, Cursor.Position.Y);
            }

            #endregion
        }

        #endregion

        #region メンバ変数定義

        /// <summary>
        /// 
        /// </summary>
        private RldMenuStripRenderHelper m_MenuStripRenderHelper;
        /// <summary>
        /// ドラッグアンドドロップヘルパークラス
        /// </summary>
        private DragDropHelper m_DragDropHelper;

        //add 8559 zhu start
        private bool isInRange = true;
        private DesignItemListData oldselectItem = null;
        private int gridCount = 30;
        //add 8559 zhu end

        // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
        /// <summary>
        /// edit file name
        /// </summary>
        public string editFileName = string.Empty;
        // add #11501 レイアウトデザイナのユーザビリティ改善 高 end

        // add #9398 「オンラインで保存」の通常保存時は「新規登録」の時のみ「帳票保存設定」が出るようにすること donghao start
        public static bool blMnuFilesaveOnlineSave { get; set; } = false;
        public static bool blMnuFileSaveOnlineReturn { get; set; } = false;

        public static bool blMnuFileSaveOnlineExit { get; set; } = false;
        private readonly ToolStripMenuItem mnuEditResetWindowLayout = new ToolStripMenuItem();
        // add #9398 「オンラインで保存」の通常保存時は「新規登録」の時のみ「帳票保存設定」が出るようにすること donghao end

        #endregion

        #region 生成と破棄

        /// <summary>
        /// データ項目リスト画面の新しいインスタンスを初期化します。
        /// </summary>
        public frmDesignChildDataList()
        {
            InitializeComponent();

            // イベントハンドラ割り当て
            this.btnCalcAddition.Click += new EventHandler(this.OnCalcButtonClick);
            this.btnCalcDivision.Click += new EventHandler(this.OnCalcButtonClick);
            this.btnCalcMultiply.Click += new EventHandler(this.OnCalcButtonClick);
            this.btnCalcSubtract.Click += new EventHandler(this.OnCalcButtonClick);
            this.btnCalcClear.Click += new EventHandler(this.OnCalcButtonClick);

            this.txtFreeCalc.DragEnter += new DragEventHandler(this.txtFreeCalc_DragEnter);
            this.txtFreeCalc.DragDrop += new DragEventHandler(this.txtFreeCalc_DragDrop);

            this.txtDropCalc.MouseDown += new MouseEventHandler(this.txtDropCalc_MouseDown);
            this.txtDropCalc.MouseUp += new MouseEventHandler(this.txtDropCalc_MouseUp);
            this.txtDropCalc.MouseMove += new MouseEventHandler(this.txtDropCalc_MouseMove);

            this.btnExtClear.Click += new EventHandler(this.btnExtClear_Click);
            //add #8559 dongzhaolong start
            this.btnExtract.Click += new EventHandler(this.btnExtract_Click);
            //add #8559 dongzhaolong end
            //this.txtExtFree.TextChanged += new System.EventHandler(this.txtExtFree_TextChanged);
            this.rldUpDownSwitchButton.Click += new EventHandler(this.rldUpDownSwitchButton_Click);
            this.rldTriStateTreeViewCategory.AfterCheck += new TreeViewEventHandler(this.rldTriStateTreeViewCategory_AfterCheck);

            this.dgvItemList.CellMouseDown += new System.Windows.Forms.DataGridViewCellMouseEventHandler(this.dgvItemList_CellMouseDown);
            this.dgvItemList.CellMouseMove += new System.Windows.Forms.DataGridViewCellMouseEventHandler(this.dgvItemList_CellMouseMove);
            this.dgvItemList.CellMouseUp += new System.Windows.Forms.DataGridViewCellMouseEventHandler(this.dgvItemList_CellMouseUp);
            this.dgvItemList.CellPainting += new System.Windows.Forms.DataGridViewCellPaintingEventHandler(this.dgvItemList_CellPainting);
            //add #8559 dongzhaolong start
            this.dgvItemList.Scroll += new System.Windows.Forms.ScrollEventHandler(this.dgvItemList_Scroll);
            //add #8559 dongzhaolong end

            // メニュー
            //this.mnuFileSaveOnlineReturn.Click += new EventHandler(this.OnMenuFileSaveDropClick);
            //this.mnuFileSaveOnlineExit.Click += new EventHandler(this.OnMenuFileSaveDropClick);
            //this.mnuFileSaveTemp.Click += new EventHandler(this.OnMenuFileSaveDropClick);
            this.mnuFileSaveTempReturn.Click += new EventHandler(this.OnMenuFileSaveDropClick);
            this.mnuFileSaveTempExit.Click += new EventHandler(this.OnMenuFileSaveDropClick);
            this.mnuFileDropTempReturn.Click += new EventHandler(this.OnMenuFileSaveDropClick);
            this.mnuFileDropTempExit.Click += new EventHandler(this.OnMenuFileSaveDropClick);
            this.mnuFileForcible.Click += new EventHandler(this.OnMenuFileForcibleClick);

            //this.mnuEditHistory.Click += new EventHandler(this.OnMenuEditClick);
            //this.mnuEditAllDelete.Click += new EventHandler(this.OnMenuEditClick);
            this.mnuEditResetWindowLayout.Name = "mnuEditResetWindowLayout";
            this.mnuEditResetWindowLayout.Size = new Size(178, 22);
            this.mnuEditResetWindowLayout.Text = "画面配置初期化(&R)";
            this.mnuEditResetWindowLayout.Click += new EventHandler(this.OnMenuEditClick);
            this.mnuEdit.DropDownItems.Insert(0, this.mnuEditResetWindowLayout);

            // メニュー描画ヘルパークラスを生成
            this.m_MenuStripRenderHelper = new RldMenuStripRenderHelper(this.MenuStrip);

            // データグリッドビューの列を自動生成しないようにする
            this.dgvItemList.AutoGenerateColumns = false;
            // データグリッドビューの表示を調整する
            RldGridRCAttributeReflector.ApplyToColumn(this.dgvItemList, typeof(DesignItemListData).GetProperties());

            // ドラッグアンドドロップヘルパークラスを生成
            this.m_DragDropHelper = new DragDropHelper();
            this.m_DragDropHelper.NotifyInfo += (s, e) => base.SendNotifyInfo(s, e);

            // オフライン時はオンラインで保存を無効化
            if (!SignInLib.SignIn.SignInInfo.IsOnline)
                this.mnuFileSaveOnline.Enabled = false;
        }

        #endregion

        #region メンバ関数定義(override)

        /// <summary>
        /// Form.FormClosing イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnFormClosing(FormClosingEventArgs e)
        {
            base.OnFormClosing(e);

            if (!RldLib.IsStartDesignWindowClosing) e.Cancel = true;
        }

        /// <summary>
        /// Form.FormClosed イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnFormClosed(FormClosedEventArgs e)
        {
            base.OnFormClosed(e);

            // メニューの表示変更を終了
            this.m_MenuStripRenderHelper.Stop();
        }

        /// <summary>
        /// Form.Load イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnLoad(System.EventArgs e)
        {
            base.OnLoad(e);

            if (base.DesignMode) return;

            // 画面をクリア
            this.DataClear(true);

            // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
            setCurrentFileName(editFileName);
            // add #11501 レイアウトデザイナのユーザビリティ改善 高 end

            // スプリットコンテナの分割ラインを移動
            this.splitContainer1.SplitterDistance = this.splitContainer1.Panel1MinSize;
            this.splitContainer2.SplitterDistance = this.splitContainer2.Panel1MinSize;

            // ツリービューコントロールの位置を調整
            this.rldTriStateTreeViewCategory.Top = this.rldUpDownSwitchButton.Bottom + 1;
            this.rldTriStateTreeViewCategory.Left = this.rldUpDownSwitchButton.Left;
            this.rldTriStateTreeViewCategory.Width = this.rldUpDownSwitchButton.Width;

            // メニューの表示を変更
            this.m_MenuStripRenderHelper.Start();

            // 抽出条件の分類用リストを作成
            this.MakeCategoryList();

            // 初期状態へ
            this.InitCategoryTreeView();

            // データ項目一覧を画面に表示
            this.DataRead();

            // add #8394(5) 動作に関する指摘 luantian start
            this.MoveNextEnterKey = false;
            // add #8394(5) 動作に関する指摘 luantian end
            //edit #9966 初回オンライン保存時に印刷範囲が強制変更される dongzhaolong start
            GlobalVariables.usedRangeAddress = string.Empty;
            GlobalVariables.oldUsedRangeAddress = string.Empty;
            GlobalVariables.printType = 0;
            //edit #9966 初回オンライン保存時に印刷範囲が強制変更される dongzhaolong end
        }

        /// <summary>
        /// 通知イベント受信時処理を行います。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected override void ReceiveNotifyInfo(object sender, RldDesignNotifyInfoEventArgs e)
        {
            base.ReceiveNotifyInfo(sender, e);

            if (sender.GetType() == typeof(LayoutDataSetChecker))
            {
                switch (e.InfoType)
                {
                    case RldDesignNotifyInfoEventArgs.EnumInfoType.RequestShowMessage:
                        base.SendNotifyInfo(sender, e);
                        break;

                    default:
                        break;
                }
            }
        }

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// 画面の入力内容をクリアします。
        /// </summary>
        /// <param name="aIsKeyClear">未使用</param>
        private void DataClear(Boolean aIsKeyClear)
        {
            // フリー計算領域クリア
            this.DataClearFreeCalcArea(aIsKeyClear);
            // 抽出条件領域クリア
            this.DataClearFilterArea(aIsKeyClear);
        }

        /// <summary>
        /// フリー計算領域の入力内容をクリアします。
        /// </summary>
        /// <param name="aIsKeyClear">未使用</param>
        private void DataClearFreeCalcArea(Boolean aIsKeyClear)
        {
            this.txtFreeCalc.Clear();
            this.txtDropCalc.Clear();
        }

        /// <summary>
        /// 抽出条件領域の入力内容をクリアします。
        /// </summary>
        private void DataClearFilterArea(Boolean aIsKeyClear)
        {
            if (aIsKeyClear)
            {
                this.rldTriStateTreeViewCategory.Nodes.Clear();
            }

            this.txtExtFree.Clear();
            this.dgvItemList.DataSource = null;
        }

        /// <summary>
        /// 入力内容を確認します。
        /// </summary>
        /// <returns></returns>
        private Boolean DataCheck()
        {
            Boolean wRet = false;

            LayoutDataSetChecker wChecker = null;
            try
            {
                // 対話モードを一時停止
                RldLib.XlHelper.XlApp.Application.Interactive = false;

                // 整合性チェッカーを生成
                wChecker = new LayoutDataSetChecker(RldLib.CurrentLayoutData, RldLib.XlHelper);
                // エラーメッセージ受信用イベントハンドラ割り当て
                wChecker.NotifyInfo += new EventHandler<RldDesignNotifyInfoEventArgs>(this.ReceiveNotifyInfo);
                // 整合性を確認
                wRet = wChecker.CheckConsistency();
            }
            catch (Exception ex)
            {
                // 例外情報を生成
                var wEx = new System.ApplicationException("入力内容の確認中にエラーが発生しました。\r\n編集途中の場合は編集を完了して下さい。", ex);
                // 例外情報を記録(画面にメッセージボックスを表示)
                base.SendNotifyInfo(this, new RldDesignNotifyInfoRequestRecordExceptionEventArgs(wEx, true));
            }
            finally
            {
                if (wChecker != null)
                {
                    // エラーメッセージ受信用イベントハンドラ割り当て解除
                    wChecker.NotifyInfo -= new EventHandler<RldDesignNotifyInfoEventArgs>(base.ReceiveNotifyInfo);
                    wChecker = null;
                }

                // 対話モードを戻す
                if (!RldLib.XlHelper.XlApp.Application.Interactive)
                    RldLib.XlHelper.XlApp.Application.Interactive = true;
            }

            return wRet;
        }

        /// <summary>
        /// 抽出条件の分類リストを作成します。
        /// </summary>
        // mod #9651 帳票表示項目の並び順を変更する 高 start
        //private void MakeCategoryList()
        //{
        //    String wCategory = String.Empty, wClass = String.Empty;
        //    RldTriStateTreeNode wRoot = null, wTarget = null;

        //    try
        //    {
        //        this.rldTriStateTreeViewCategory.SuspendLayout();

        //        // ルートノードを作成して追加
        //        this.rldTriStateTreeViewCategory.Nodes.Add(
        //            wRoot = new RldTriStateTreeNode()
        //            {
        //                CheckboxVisible = true,
        //                IsContainer = true,
        //                Tag = "DataItemList",
        //                Text = "すべて"
        //            });

        //        // mod 2020-09-27 FNSI-仕様追加 DataListデータリストにソート機能を追加 李 start
        //        //foreach( var wItem in RldLib.CurrentLayoutData.DataItemList ) {

        //        //    if( wCategory != wItem.DataCategory ) {
        //        //        // ルートノードへ追加
        //        //        if( wTarget != null ) wRoot.Nodes.Add(wTarget);

        //        //        wTarget = new RldTriStateTreeNode() {
        //        //            CheckboxVisible = true,
        //        //            IsContainer = true,
        //        //            Tag = wItem.DataCategory,
        //        //            Text = wItem.DataCategory
        //        //        };
        //        //        // カテゴリを記憶
        //        //        wCategory = wItem.DataCategory;
        //        //        // クラスをクリア
        //        //        wClass = String.Empty;
        //        //    }

        //        //    var wClassTemp = String.Format("{0}{2}{1}", wItem.DataCategory, wItem.DataClass, RldConst.PATH_SPLIT);

        //        //    if( wClass != wClassTemp ) {
        //        //        wTarget.Nodes.Add(new RldTriStateTreeNode() {
        //        //            CheckboxVisible = true,
        //        //            Tag = wClassTemp,
        //        //            Text = wItem.DataClass
        //        //        });
        //        //        // クラスを記憶
        //        //        wClass = wClassTemp;
        //        //    }
        //        //}
        //        //// 最後のカテゴリをルートノードへ追加
        //        //if( wTarget != null ) wRoot.Nodes.Add(wTarget);

        //        var dataCategory = RldLib.CurrentLayoutData.DataItemList
        //            .OrderBy(d => ((!string.IsNullOrEmpty(d.DataSort) && d.DataSort.Split('.').Length >= 1) ? d.DataSort.Split('.')[0] : string.Empty))
        //            .Select(d => d.DataCategory).Distinct().ToList();

        //        dataCategory.ForEach(d =>
        //        {
        //            wRoot.Nodes.Add(wTarget = new RldTriStateTreeNode()
        //            {
        //                CheckboxVisible = true,
        //                IsContainer = true,
        //                Tag = d,
        //                Text = d
        //            });

        //            RldLib.CurrentLayoutData.DataItemList.Where(dl => dl.DataCategory == d)
        //                .OrderBy(dl => ((!string.IsNullOrEmpty(dl.DataSort) && dl.DataSort.Split('.').Length >= 2) ? dl.DataSort.Split('.')[1] : string.Empty))
        //                .Select(dl => dl.DataClass).Distinct().ToList().ForEach(dl =>
        //                {
        //                    wTarget.Nodes.Add(new RldTriStateTreeNode()
        //                    {
        //                        CheckboxVisible = true,
        //                        Tag = String.Format("{0}{2}{1}", d, dl, RldConst.PATH_SPLIT),
        //                        Text = dl
        //                    });
        //                });
        //        });
        //        // mod 2020-09-27 FNSI-仕様追加 DataListデータリストにソート機能を追加 李 end

        //    }
        //    catch (Exception ex)
        //    {
        //        base.SendNotifyInfo(this, new RldDesignNotifyInfoRequestRecordExceptionEventArgs(ex, true));
        //    }
        //    finally
        //    {
        //        this.rldTriStateTreeViewCategory.ResumeLayout();
        //    }
        //}
        /// <summary>
        /// 抽出条件の分類リストを作成します。
        /// </summary>

        private void MakeCategoryList()
        {
            String wCategory = String.Empty, wClass = String.Empty;
            RldTriStateTreeNode wRoot = null, wTarget = null;

            try
            {
                this.rldTriStateTreeViewCategory.SuspendLayout();

                // ルートノードを作成して追加
                this.rldTriStateTreeViewCategory.Nodes.Add(
                    wRoot = new RldTriStateTreeNode()
                    {
                        CheckboxVisible = true,
                        IsContainer = true,
                        Tag = "DataItemList",
                        Text = "すべて"
                    });

                // create dictionary of DataItemOrderList
                var orderLookup = new Dictionary<string, int>();
                for (int i = 0; i < RldLib.CurrentLayoutData.DataItemOrderList.Count; i++)
                {
                    var orderItem = RldLib.CurrentLayoutData.DataItemOrderList[i];
                    string key = (orderItem.DataCategory ?? "") + "|" + (orderItem.DataClass ?? "");
                    if (!orderLookup.ContainsKey(key))
                    {
                        orderLookup[key] = i;
                    }
                }

                // sort all Category
                var dataCategory = RldLib.CurrentLayoutData.DataItemList
                    .Select(d => d.DataCategory)
                    .Distinct()
                    .ToList();

                // sort for Category: first, sort with DataOrder.xml, second, sort wich DataSort of DataList.xml
                var sortedCategories = dataCategory
                    .OrderBy(category =>
                    {
                        // check Category, is exist in DataOrder.xml
                        var categoryInOrder = RldLib.CurrentLayoutData.DataItemOrderList
                            .FirstOrDefault(o => o.DataCategory == category);

                        if (categoryInOrder != null)
                        {
                            // if is exist in DataOrder.xml，use index of DataOrder.xml
                            return RldLib.CurrentLayoutData.DataItemOrderList.IndexOf(categoryInOrder);
                        }

                        // if is not exist in DataOrder.xml, set larger value , sort in last position
                        return int.MaxValue;
                    })
                    .ThenBy(category =>
                    {
                        // sort
                        var firstItem = RldLib.CurrentLayoutData.DataItemList
                            .FirstOrDefault(d => d.DataCategory == category);

                        if (firstItem != null && !string.IsNullOrEmpty(firstItem.DataSort))
                        {
                            var sortParts = firstItem.DataSort.Split('.');
                            if (sortParts.Length >= 1)
                            {
                                return sortParts[0];
                            }
                        }
                        return string.Empty;
                    })
                    .ToList();

                // add item of sorted Category
                sortedCategories.ForEach(category =>
                {
                    wRoot.Nodes.Add(wTarget = new RldTriStateTreeNode()
                    {
                        CheckboxVisible = true,
                        IsContainer = true,
                        Tag = category,
                        Text = category
                    });

                    // get all Class of Category
                    var dataClasses = RldLib.CurrentLayoutData.DataItemList
                        .Where(dl => dl.DataCategory == category)
                        .Select(dl => dl.DataClass)
                        .Distinct()
                        .ToList();

                    // sort for Class: first, sort with DataOrder.xml, second, sort wich DataSort of DataList.xml
                    var sortedClasses = dataClasses
                        .OrderBy(class_ =>
                        {
                            // check Category+Class, is exist in DataOrder.xml
                            string key = (category ?? "") + "|" + (class_ ?? "");
                            if (orderLookup.TryGetValue(key, out int orderIndex))
                            {
                                return orderIndex;
                            }

                            // if is not exist in DataOrder.xml, set larger value , sort in last position
                            return int.MaxValue;
                        })
                        .ThenBy(class_ =>
                        {
                            // sort
                            var firstItem = RldLib.CurrentLayoutData.DataItemList
                                .FirstOrDefault(dl => dl.DataCategory == category && dl.DataClass == class_);

                            if (firstItem != null && !string.IsNullOrEmpty(firstItem.DataSort))
                            {
                                var sortParts = firstItem.DataSort.Split('.');
                                if (sortParts.Length >= 2)
                                {
                                    return sortParts[1];
                                }
                            }
                            return string.Empty;
                        })
                        .ToList();

                    // add item of sorted Class
                    sortedClasses.ForEach(class_ =>
                    {
                        wTarget.Nodes.Add(new RldTriStateTreeNode()
                        {
                            CheckboxVisible = true,
                            Tag = String.Format("{0}{2}{1}", category, class_, RldConst.PATH_SPLIT),
                            Text = class_
                        });
                    });
                });
            }
            catch (Exception ex)
            {
                base.SendNotifyInfo(this, new RldDesignNotifyInfoRequestRecordExceptionEventArgs(ex, true));
            }
            finally
            {
                this.rldTriStateTreeViewCategory.ResumeLayout();
            }
        }
        // mod #9651 帳票表示項目の並び順を変更する 高 end

        /// <summary>
        /// 画面にデータ項目一覧を表示します。
        /// </summary>
        private void DataRead()
        {
            try
            {
                this.dgvItemList.SuspendLayout();

                // 作業用リストを生成
                var wList = new List<DesignItemListData>(RldLib.CurrentLayoutData.DataItemList);

                // 分類ツリービューの全ノードを取得
                Func<TreeNodeCollection, List<RldTriStateTreeNode>> wFuncGetAllNodes = null;
                wFuncGetAllNodes = aCollection => {
                    var wNodeList = new List<RldTriStateTreeNode>();
                    foreach (TreeNode wNode in aCollection)
                    {
                        wNodeList.Add(wNode as RldTriStateTreeNode);
                        if (wNode.GetNodeCount(false) > 0) wNodeList.AddRange(wFuncGetAllNodes(wNode.Nodes));
                    }
                    return wNodeList;
                };

                // 分類によるフィルタリングを適用
                foreach (var wNode in wFuncGetAllNodes(this.rldTriStateTreeViewCategory.Nodes).Where(ele => ele.CheckState == CheckState.Unchecked))
                    wList.RemoveAll(ele => String.Format("{0}{2}{1}", ele.DataCategory, ele.DataClass, RldConst.PATH_SPLIT) == wNode.Tag as String);

                // フリーワードによるフィルタリングを適用
                if (!String.IsNullOrEmpty(this.txtExtFree.Text))
                {

                    // 日本語用の検索パラメータ指定用データを取得
                    var wCompareInfo = System.Globalization.CultureInfo.CurrentCulture.CompareInfo;

                    System.Func<String, Int32> wFuncFindIndex = aTarget => wCompareInfo.IndexOf(
                        aTarget,
                        this.txtExtFree.Text,
                        System.Globalization.CompareOptions.IgnoreCase | System.Globalization.CompareOptions.IgnoreWidth);

                    wList = wList.FindAll(ele => wFuncFindIndex(ele.DataCategory) >= 0 || wFuncFindIndex(ele.DataClass) >= 0 || wFuncFindIndex(ele.DataName) >= 0);
                }

                // バインド用リストを生成してバインド
                // mod 2020-09-29 FNSI-仕様追加 DataListデータリストにソート機能を追加 李 start
                //this.dgvItemList.DataSource = new System.ComponentModel.BindingList<DesignItemListData>(wList);

                var list = new List<DesignItemListData>();
                wFuncGetAllNodes(this.rldTriStateTreeViewCategory.Nodes).Where(d => d.Checked).ToList().ForEach(
                    d => {
                        wFuncGetAllNodes(d.Nodes).Where(dd => dd.Checked).ToList().ForEach(dd => {
                            list.AddRange(wList.Where(dl => dl.DataCategory == d.Text && dl.DataClass == dd.Text).OrderBy(dl => ((!string.IsNullOrEmpty(dl.DataSort) && dl.DataSort.Split('.').Length >= 3) ? dl.DataSort.Split('.')[2] : string.Empty)).ToList());
                        });

                    });
                this.dgvItemList.DataSource = new System.ComponentModel.BindingList<DesignItemListData>(list);
                // mod 2020-09-29 FNSI-仕様追加 DataListデータリストにソート機能を追加 李 end
                //8559 add  董 start
                //mod #8559 zhu start
                if (this.dgvItemList.Rows.Count > 0)
                {
                    gridCount = this.dgvItemList.Height / this.dgvItemList.Rows[0].Height;
                }
                //mod #8559 zhu end

                if (selectItem != null)
                {
                    bool bExit = false;
                    foreach (DataGridViewRow item in this.dgvItemList.Rows)
                    {
                        if (item.DataBoundItem.Equals(selectItem))
                        {
                            item.Selected = true;
                            bExit = true;
                            this.dgvItemList.FirstDisplayedScrollingRowIndex = item.Index;
                            this.dgvItemList.HorizontalScrollingOffset = item.Index;
                            break;
                        }
                    }
                    if (this.dgvItemList.Rows.Count > 0 && !bExit)
                    {
                        selectItem = this.dgvItemList.Rows[0].DataBoundItem as DesignItemListData;
                        this.dgvItemList.CurrentCell = this.dgvItemList[0, 0];
                    }
                }
                else
                {
                    if (this.dgvItemList.Rows.Count > 0)
                    {
                        selectItem = this.dgvItemList.Rows[0].DataBoundItem as DesignItemListData;
                    }
                }
                //mod #8559 zhu start
                if (!isInRange)
                {
                    if (this.dgvItemList.Rows.Count > 0)
                    {
                        selectItem = this.dgvItemList.Rows[0].DataBoundItem as DesignItemListData;
                        this.dgvItemList.CurrentCell = this.dgvItemList[0, 0];
                    }
                }

                if (this.dgvItemList.Rows.Count > 0)
                {
                    gridCount = this.dgvItemList.Height / this.dgvItemList.Rows[0].Height;
                }
                //mod #8559 zhu end
                //8559 add  董 end
                // 読み込み件数を表示
                this.lblDataCount.Text = String.Format("{0}件", wList.Count);

                // ボタンのテキストとツールチップテキストを更新
                this.UpdateUpDownButtonText();
            }
            catch (Exception ex)
            {
                base.SendNotifyInfo(this, new RldDesignNotifyInfoRequestRecordExceptionEventArgs(ex, true));
            }
            finally
            {
                this.dgvItemList.ResumeLayout();
            }
        }

        /// <summary>
        /// ツリービューコントロール開閉用ボタンのテキストとツールチップテキストを更新します。
        /// </summary>
        private void UpdateUpDownButtonText()
        {
            String wText = String.Empty;

            // ルートノードを取得
            var wRootNode = this.rldTriStateTreeViewCategory.Nodes[0] as RldTriStateTreeNode;

            switch (wRootNode.CheckState)
            {
                case CheckState.Checked:
                    wText = "全ての分類を選択中";
                    break;

                case CheckState.Unchecked:
                    wText = "選択中の分類はありません";
                    break;

                case CheckState.Indeterminate:
                    foreach (RldTriStateTreeNode wNode in wRootNode.Nodes)
                        if (wNode.CheckState != CheckState.Unchecked)
                            wText += String.Format(
                                "{0}の{1}, ",
                                wNode.Text,
                                wNode.CheckState == CheckState.Checked ? "全て" : "一部");
                    wText = wText.Substring(0, wText.Length - 2);
                    wText = String.Format("以下のいずれかの分類を選択中 ({0})", wText);
                    break;
            }

            this.rldUpDownSwitchButton.Text = wText;
            this.toolTipDesignChildDataList.SetToolTip(this.rldUpDownSwitchButton, wText);
        }

        /// <summary>
        /// フリー計算領域の計算式内に文字列を挿入します。
        /// </summary>
        /// <param name="aOperator"></param>
        private void InsertTextToFreeCalcTextBox(string aOperator)
        {
            int wIndex = this.txtFreeCalc.SelectionStart;

            this.txtFreeCalc.Text = this.txtFreeCalc.Text.Insert(wIndex, aOperator);
            this.txtFreeCalc.SelectionStart = wIndex + aOperator.Length;
        }

        /// <summary>
        /// 分類表示用ツリービューコントロールを初期表示状態に設定します。
        /// </summary>
        private void InitCategoryTreeView()
        {
            // ノードがない場合は抜ける
            if (this.rldTriStateTreeViewCategory.GetNodeCount(true) <= 0) return;

            var wFirstNode = (RldTriStateTreeNode)this.rldTriStateTreeViewCategory.Nodes[0];

            // 全選択状態へ
            wFirstNode.SetCheckedState(CheckState.Checked);

            // 展開しておく         
            wFirstNode.Collapse(false);
            wFirstNode.Expand();
        }

        #endregion

        #region コントロールイベントハンドラ定義

        /// <summary>
        /// フリー計算領域の四則演算ボタンとクリアボタンの Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void OnCalcButtonClick(object sender, System.EventArgs e)
        {
            if (sender == this.btnCalcAddition)
                this.InsertTextToFreeCalcTextBox("+");
            else if (sender == this.btnCalcDivision)
                this.InsertTextToFreeCalcTextBox("/");
            else if (sender == this.btnCalcMultiply)
                this.InsertTextToFreeCalcTextBox("*");
            else if (sender == this.btnCalcSubtract)
                this.InsertTextToFreeCalcTextBox("-");
            else if (sender == this.btnCalcClear)
                this.DataClearFreeCalcArea(false);
        }

        /// <summary>
        /// フリー計算領域の入力計算式の DragEnter イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void txtFreeCalc_DragEnter(object sender, DragEventArgs e)
        {
            if (e.Data.GetDataPresent("SymbolicLink"))
                // エクセルからのドラッグの場合
                e.Effect = DragDropEffects.Copy;

            else if (e.Data.GetDataPresent(typeof(Bitmap)))
                // 抽出条件領域のデータ項目リストからのドラッグで計算対象項目の場合
                // mod #12009 データ項目リストからフリー計算にすべての項目がD&Dできない 高 start
                //if (this.m_DragDropHelper.IsDragIn && this.m_DragDropHelper.CanCalc)
                if (this.m_DragDropHelper.IsDragIn)
                // mod #12009 データ項目リストからフリー計算にすべての項目がD&Dできない 高 end
                    e.Effect = DragDropEffects.Copy;
        }

        /// <summary>
        /// フリー計算領域の入力計算式の DragDrop イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void txtFreeCalc_DragDrop(object sender, DragEventArgs e)
        {
            String wDropStr = String.Empty;

            // add FNSI-フリー計算機能:Excelのセル側からD & Dした際に、引数名ではなく、セル名称（A3など）になってしまい、保存できなくなる。 孫 start
            bool freeCalcFlag = false;
            // add FNSI-フリー計算機能:Excelのセル側からD & Dした際に、引数名ではなく、セル名称（A3など）になってしまい、保存できなくなる。 孫 end

            if (e.Data.GetDataPresent("SymbolicLink"))
            {
                // mod #12502 セル編集中にフリー計算枠にセルをドラッグ＆ドロップするとフリーズ 高 start
                // エクセルからのドロップの場合
                bool success = Task.Run(() =>
                {
                    // add #11784 レイアウトデザイナのフリー計算ツールにセル番地がドロップできない 高 start
                    using (var wXlRange = RldLib.XlHelper.XlApp.GetSelectedCell)
                    {
                        wDropStr = String.Format("{0}", wXlRange.Range.Address[false, false]);
                        string[] cellArea = wDropStr.Split(':');
                        if (cellArea.Length == 2)
                        {
                            Object wMergeCell = wXlRange.Range.MergeCells;
                            if (wMergeCell != System.DBNull.Value)
                            {
                                if ((Boolean)wMergeCell)
                                {
                                    wDropStr = cellArea[0].ToString();
                                }
                            }
                        }
                    }
                    freeCalcFlag = true;
                }).Wait(TimeSpan.FromSeconds(2));
                // mod #12502 セル編集中にフリー計算枠にセルをドラッグ＆ドロップするとフリーズ 高 end

                // add #11784 レイアウトデザイナのフリー計算ツールにセル番地がドロップできない 高 end

                // del #11784 レイアウトデザイナのフリー計算ツールにセル番地がドロップできない 高 start
                //using (var wXlRange = RldLib.XlHelper.XlApp.GetSelectedCell)
                //    wDropStr = String.Format("{0}{1}", RldConst.PATH_HEADER, wXlRange.Range.Address[false, false]);

                //// add FNSI-フリー計算機能:Excelのセル側からD & Dした際に、引数名ではなく、セル名称（A3など）になってしまい、保存できなくなる。 孫 start
                //// Excel側からセルの内容にフリー計算領域を設定する
                //using (var wXlActiveRange = RldLib.XlHelper.XlApp.GetActiveCell)
                //{
                //    // セルの内容
                //    var activeRangeValue = wXlActiveRange.Range.Value;

                //    // セルのタイプがStringか
                //    var activeRangeType = wXlActiveRange.Range.Value2 as String ?? String.Empty;

                //    // セルの内容がnullの場合
                //    if (activeRangeValue == null)
                //    {
                //        wDropStr = "";
                //        freeCalcFlag = true;
                //    }
                //    else
                //    {
                //        // セルのタイプがString以外の場合
                //        if (String.IsNullOrEmpty(activeRangeType))
                //        {
                //            wDropStr = (String)activeRangeValue;
                //            freeCalcFlag = true;
                //        }
                //        else if (!String.IsNullOrEmpty(activeRangeValue))
                //        {
                //            // セルのタイプがString、かつ セルの内容がnull以外の場合
                //            if (activeRangeValue.StartsWith("##="))
                //            {
                //                // 計算式
                //                wDropStr = activeRangeValue.Substring(3);
                //                freeCalcFlag = true;
                //            }
                //            else if (activeRangeValue.StartsWith("##"))
                //            {
                //                // 計算式以外
                //                wDropStr = activeRangeValue;
                //            }
                //        }
                //    }
                //}
                //// add FNSI-フリー計算機能:Excelのセル側からD & Dした際に、引数名ではなく、セル名称（A3など）になってしまい、保存できなくなる。 孫 end
                // del #11784 レイアウトデザイナのフリー計算ツールにセル番地がドロップできない 高 end
            }
            else if (e.Data.GetDataPresent(typeof(Bitmap)))
            {
                // 抽出条件領域のデータ項目リストからのドロップの場合
                wDropStr = this.m_DragDropHelper.DragText;
            }

            // フォーカスを取得
            this.Activate();
            this.txtFreeCalc.Focus();

            // add #12502 セル編集中にフリー計算枠にセルをドラッグ＆ドロップするとフリーズ 高 start
            if (string.IsNullOrEmpty(wDropStr))
                return;
            // add #12502 セル編集中にフリー計算枠にセルをドラッグ＆ドロップするとフリーズ 高 end

            // 取得できた文字列を入力計算式のカーソル位置へ挿入
            // add FNSI-フリー計算機能:Excelのセル側からD & Dした際に、引数名ではなく、セル名称（A3など）になってしまい、保存できなくなる。 孫 start
            if (freeCalcFlag)
            {
                this.InsertTextToFreeCalcTextBox(wDropStr);
            }
            else
            {
                // add FNSI-フリー計算機能:Excelのセル側からD & Dした際に、引数名ではなく、セル名称（A3など）になってしまい、保存できなくなる。 孫 end

                this.InsertTextToFreeCalcTextBox(String.Format("{0}{1}{2}", RldConst.CALC_ITEM_START, wDropStr, RldConst.CALC_ITEM_END));

                // add FNSI-フリー計算機能:Excelのセル側からD & Dした際に、引数名ではなく、セル名称（A3など）になってしまい、保存できなくなる。 孫 start
            }
            // add FNSI-フリー計算機能:Excelのセル側からD & Dした際に、引数名ではなく、セル名称（A3など）になってしまい、保存できなくなる。 孫 end
        }

        /// <summary>
        /// フリー計算領域のドロップ計算式の MouseDown イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void txtDropCalc_MouseDown(object sender, MouseEventArgs e)
        {
            if (e.Button != MouseButtons.Left)
                this.m_DragDropHelper.ReleaseStartPoint();
            else
            {
                if (!String.IsNullOrEmpty(this.txtFreeCalc.Text))
                    this.m_DragDropHelper.SaveStartPoint(this.txtDropCalc, e.Location, RldConst.CALC_HEADER + this.txtFreeCalc.Text);
            }
        }

        /// <summary>
        /// フリー計算領域のドロップ計算式の MouseUp イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void txtDropCalc_MouseUp(object sender, MouseEventArgs e)
        {
            this.m_DragDropHelper.ReleaseStartPoint();
        }

        /// <summary>
        /// フリー計算領域のドロップ計算式の MouseMove イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void txtDropCalc_MouseMove(object sender, MouseEventArgs e)
        {
            // ドラッグ中ではない場合は抜ける
            if (!this.m_DragDropHelper.IsDragIn) return;

            // ドラッグアンドドロップ操作を開始
            if (this.m_DragDropHelper.DoDragDrop(e.Location, new Bitmap(1, 1)))
                this.txtFreeCalc.Clear();
        }

        /// <summary>
        /// 抽出条件領域のクリアボタンの Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnExtClear_Click(object sender, System.EventArgs e)
        {
            // 入力内容をクリア
            this.DataClearFilterArea(false);

            // 分類は全選択状態に設定
            this.InitCategoryTreeView();

            // データ項目一覧を再表示
            this.DataRead();
        }

        /// <summary>
        /// 抽出条ボタンの Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnExtract_Click(object sender, System.EventArgs e)
        {

            // データ項目一覧を再表示
            this.DataRead();

        }
        /// <summary>
        /// 分類表示用ツリービューコントロールの AfterCheck イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void rldTriStateTreeViewCategory_AfterCheck(object sender, TreeViewEventArgs e)
        {
            // データ項目一覧を更新
            this.DataRead();
        }

        /// <summary>
        /// ツリービューコントロール開閉用ボタンの Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void rldUpDownSwitchButton_Click(object sender, EventArgs e)
        {
            const Int32 PANEL_EXT_EXPAND_SIZE = 260;

            Boolean wIsClosed = this.rldUpDownSwitchButton.UpDownState == RldUpDownSwitchButton.EnumUpDownState.Down;
            Int32 wLimitValue = wIsClosed ? PANEL_EXT_EXPAND_SIZE : this.splitContainer2.Panel1MinSize;

            if (wIsClosed) this.rldTriStateTreeViewCategory.Visible = true;

            while (wIsClosed ? this.splitContainer2.Panel1.Height < wLimitValue : this.splitContainer2.Panel1.Height > wLimitValue)
            {
                this.splitContainer2.SplitterDistance += this.splitContainer2.SplitterIncrement * (wIsClosed ? 1 : -1);
                this.splitContainer2.Refresh();
            }
            if (!wIsClosed) this.rldTriStateTreeViewCategory.Visible = false;

            this.rldUpDownSwitchButton.UpDownState = wIsClosed ? RldUpDownSwitchButton.EnumUpDownState.Up : RldUpDownSwitchButton.EnumUpDownState.Down;
            //8559 add  董 start
            if (selectItem != null)
            {
                bool bExit = false;
                foreach (DataGridViewRow item in this.dgvItemList.Rows)
                {
                    if (item.DataBoundItem.Equals(selectItem))
                    {
                        item.Selected = true;
                        bExit = true;
                        this.dgvItemList.FirstDisplayedScrollingRowIndex = item.Index;
                        this.dgvItemList.HorizontalScrollingOffset = item.Index;
                        break;
                    }
                }
                if (this.dgvItemList.Rows.Count > 0 && !bExit)
                {
                    selectItem = this.dgvItemList.Rows[0].DataBoundItem as DesignItemListData;
                    this.dgvItemList.CurrentCell = this.dgvItemList[0, 0];
                }
            }
            else
            {
                if (this.dgvItemList.Rows.Count > 0)
                {
                    selectItem = this.dgvItemList.Rows[0].DataBoundItem as DesignItemListData;
                }
            }
            //8559 add  董 end	
        }
        //delete #8559 dongzhaolong start
        /// <summary>
        /// 抽出条件領域のフリーワードの TextChanged イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        //private void txtExtFree_TextChanged(object sender, System.EventArgs e)
        //{
        //    // データ項目一覧を更新
        //    this.DataRead();
        //    //add #8559 dongzhaolong start
        //    canDataRead = false;
        //    //add #8559 dongzhaolong end
        //}
        //delete #8559 dongzhaolong start
        /// <summary>
        /// 抽出条件領域のデータ項目リストの CellMouseDown イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvItemList_CellMouseDown(object sender, DataGridViewCellMouseEventArgs e)
        {
            if ((e.Button != MouseButtons.Left) || (e.RowIndex < 0))
                this.m_DragDropHelper.ReleaseStartPoint();
            else
            {
                var wBindData = selectItem = (sender as DataGridView).Rows[e.RowIndex].DataBoundItem as DesignItemListData;
                //add 8559 zhu start
                isInRange = true;
                //add 8559 zhu end

                if (wBindData != null)
                    this.m_DragDropHelper.SaveStartPoint(this.dgvItemList, e.Location, wBindData.DataPath, wBindData.CanCalc);
            }
        }

        /// <summary>
        /// 抽出条件領域のデータ項目リストの CellMouseUp イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvItemList_CellMouseUp(object sender, DataGridViewCellMouseEventArgs e)
        {
            this.m_DragDropHelper.ReleaseStartPoint();
        }

        /// <summary>
        /// 抽出条件領域のデータ項目リストの CellMouseMove イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvItemList_CellMouseMove(object sender, DataGridViewCellMouseEventArgs e)
        {
            // ドラッグ中ではない場合は抜ける
            if (!this.m_DragDropHelper.IsDragIn) return;

            Bitmap wBitmap = null;

            #region 選択行のイメージを取得する場合

            //var wClientRect = this.dgvItemList.ClientRectangle;

            //// 選択行の画像を生成
            //using( var wTmpBitmap = new Bitmap(wClientRect.Width, wClientRect.Height) ) {

            //    // DataGridView 全体を描画
            //    this.dgvItemList.DrawToBitmap(wTmpBitmap, new Rectangle(0, 0, wClientRect.Width, wClientRect.Height));
            //    // 選択行の矩形領域を取得
            //    var wRect = this.dgvItemList.GetRowDisplayRectangle(this.dgvItemList.CurrentRow.Index, true);

            //    Double wRateV = wRect.Height <= 256 ? 1 : 256.0 / wRect.Height;
            //    Double wRateH = wRect.Width <= 256 ? 1 : 256.0 / wRect.Width;
            //    Double wRate = wRateV < wRateH ? wRateV : wRateH;

            //    wBitmap = new Bitmap((int)(wRect.Width * wRate), (int)(wRect.Height * wRate));

            //    using( var wGraphics = System.Drawing.Graphics.FromImage(wBitmap) ) {
            //        wGraphics.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.HighQualityBicubic;
            //        wGraphics.DrawImage(wTmpBitmap.Clone(wRect, System.Drawing.Imaging.PixelFormat.DontCare), 0, 0, wBitmap.Width, wBitmap.Height);
            //    }
            //}

            #endregion

            #region イメージを作成する場合

            // バインドされているデータを取得(取得できなかった場合は抜ける)
            if (!(this.dgvItemList.CurrentRow.DataBoundItem is DesignItemListData wBindData)) return;

            var wBaseImageSize = new Size(128, 128);

            const int BLOCK_HEIGHT = 17;

            using (var wDragItemImage = Bitmap.FromHicon(Properties.Resources.DragItemImage.Handle))
            using (var wBaseImage = new Bitmap(wDragItemImage, wBaseImageSize))
            using (var wGraphics = Graphics.FromImage(wBaseImage))
            {

                // カテゴリを描画
                LFunc_DrawText(new Rectangle(25, 40, 76, BLOCK_HEIGHT), wBindData.DataCategory, true);
                // クラスを描画
                LFunc_DrawText(new Rectangle(25, 40 + BLOCK_HEIGHT, 76, BLOCK_HEIGHT), wBindData.DataClass, true);
                // 項目名を描画
                LFunc_DrawText(new Rectangle(25, 40 + BLOCK_HEIGHT * 2, 76, BLOCK_HEIGHT * 2), wBindData.DataName, false);

                wBitmap = wBaseImage.Clone() as Bitmap;

                /// <summary>
                /// テキストを描画します。
                /// </summary>
                /// <param name="g">グラフィックオブジェクト</param>
                /// <param name="size">サイズ</param>
                /// <param name="str">出力する文字列</param>
                /// <returns>フォントサイズ</returns>
                void LFunc_DrawText(Rectangle aTargetArea, String aText, Boolean aIsShrink)
                {
                    var wCalcFontSize = this.Font.Size;
                    if (aIsShrink)
                    {
                        // フォントサイズを取得
                        wCalcFontSize = LFunc_CalcFontSize();
                        wCalcFontSize = wCalcFontSize > this.Font.Size ? this.Font.Size : wCalcFontSize;
                    }

                    using (var wFont = new Font(this.Font.FontFamily, wCalcFontSize))
                    {

                        wGraphics.DrawString(aText, wFont, Brushes.Black, aTargetArea, new StringFormat()
                        {
                            Alignment = StringAlignment.Center,
                            //LineAlignment = StringAlignment.Center
                        });
                    }

                    /// <summary>
                    /// 最適なフォントサイズを算出します。
                    /// </summary>
                    float LFunc_CalcFontSize()
                    {
                        var wSize = new SizeF(0.1F, 0.1F);
                        var a = 0.1F;
                        var b = 0.1F;

                        if (!string.IsNullOrEmpty(aText))
                        {
                            wSize = wGraphics.MeasureString(aText, new Font(this.Font.Name, 1));
                            a = (aTargetArea.Size.Width / wSize.Width);
                            b = (aTargetArea.Size.Height / wSize.Height);
                        }
                        return (a < b) ? a : b;
                    }
                }
            }

            #endregion

            this.m_DragDropHelper.DoDragDrop(e.Location, wBitmap);
            wBitmap?.Dispose();
        }

        /// <summary>
        /// 抽出条件領域のデータ項目リストの CellPainting イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvItemList_CellPainting(object sender, DataGridViewCellPaintingEventArgs e)
        {
            if (e.RowIndex < 0) return;

            // セルの下側罫線を削除
            e.AdvancedBorderStyle.Bottom = DataGridViewAdvancedCellBorderStyle.None;

            var wDisplayIndex = (DesignItemListData.EnumDataIndex)this.dgvItemList.Columns[e.ColumnIndex].DisplayIndex;

            // 項目名列以降の列は上側罫線を追加
            if (wDisplayIndex >= DesignItemListData.EnumDataIndex.DataName)
            {
                e.AdvancedBorderStyle.Top = DataGridViewAdvancedCellBorderStyle.Single;
                return;
            }

            // 背景色を既定値にセット
            e.CellStyle.BackColor = dgvItemList.RowsDefaultCellStyle.BackColor;

            Boolean wIsNormal = true;

            if (e.RowIndex > 0)
            {
                if (wDisplayIndex == DesignItemListData.EnumDataIndex.DataCategory &&
                    LFunc_IsEqualCellValue(this.dgvItemList[(Int32)DesignItemListData.EnumDataIndex.DataCategory, e.RowIndex - 1].Value, e.Value))
                    // カテゴリ列の場合
                    wIsNormal = false;

                else if (wDisplayIndex == DesignItemListData.EnumDataIndex.DataClass &&
                        LFunc_IsEqualCellValue(this.dgvItemList[(Int32)DesignItemListData.EnumDataIndex.DataCategory, e.RowIndex - 1].Value, this.dgvItemList[(Int32)DesignItemListData.EnumDataIndex.DataCategory, e.RowIndex].Value) &&
                        LFunc_IsEqualCellValue(this.dgvItemList[(Int32)DesignItemListData.EnumDataIndex.DataClass, e.RowIndex - 1].Value, e.Value))
                    // クラス列の場合
                    wIsNormal = false;

                /// <summary>
                /// (ローカル関数) セルの値が等しいか取得します。
                /// </summary>
                /// <param name="aCellValue1"></param>
                /// <param name="aCellValue2"></param>
                Boolean LFunc_IsEqualCellValue(Object aCellValue1, Object aCellValue2)
                {
                    return String.CompareOrdinal(aCellValue1 as String, aCellValue2 as String) == 0;
                }
            }

            if (wIsNormal)
                e.AdvancedBorderStyle.Top = DataGridViewAdvancedCellBorderStyle.Single;
            else
                e.CellStyle.ForeColor = Color.Transparent;
        }

        #endregion

        #region コントロールイベントハンドラ定義(メニュー)

        // add #10230 コピーした内容がリセットされる 高 start
        private frmDesignChildLayoutTemplete FindTemplete(Control parentCtrl)
        {
            foreach (Control ctrl in parentCtrl.Controls)
            {
                if (ctrl is frmDesignChildLayoutTemplete)
                {
                    return (frmDesignChildLayoutTemplete)ctrl;
                }
                else if (ctrl.HasChildren)
                {
                    frmDesignChildLayoutTemplete template = FindTemplete(ctrl);
                    if (template != null)
                    {
                        return template;
                    }
                }
            }
            return null;
        }
        // 画像を更新
        private void UpdateTempleteAreaImage(frmDesignChildLayout fdcl)
        {
            frmDesignChildLayoutTemplete template = null;
            template = FindTemplete(fdcl);
            if(template != null)
            {
                template.UpdateTempleteAreaImage();
            }
        }
        // add #10230 コピーした内容がリセットされる 高 end

        /// <summary>
        /// ファイルメニュー以下の 保存/破棄用 ToolStripMenuItem の Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void OnMenuFileSaveDropClick(Object sender, System.EventArgs e)
        {
            // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 start
            if (RldLib.chkExeclDialog(1) == false)
                return;
            // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 end

            // add #12516 項目の設定されていない帳票出力時にシステムエラーが発生する 高 start
            if (sender == this.mnuFilesaveOnlineSave || sender == this.mnuFileSaveOnlineReturn || sender == this.mnuFileSaveOnlineExit || sender == this.mnuFileSaveTempReturn || sender == this.mnuFileSaveTempExit)
            {

                if (RldLib.CurrentLayoutData.DesignParamList.Count == 0)
                {
                    var wData = new RldDesignNotifyInfoRequestShowMessageEventArgs()
                    {
                        Text = RldConst.DATA_EMPTY_MESSAGE,
                        Caption = RldConst.DATA_EMPTY_CAPTION,
                        Buttons = System.Windows.Forms.MessageBoxButtons.OK,
                        Icon = System.Windows.Forms.MessageBoxIcon.Exclamation
                    };
                    base.SendNotifyInfo(this, wData);
                    return;
                }
            }
            // add #12516 項目の設定されていない帳票出力時にシステムエラーが発生する 高 end

            //edit #9648 【デグレ】オンライン保存の実行中Excelのウインドウがグレーで潰れる dongzhaolong start
            //add #9767 データ項目を含むセルを結合させるとパラメータ一覧とのリンクが切れる dongzhaolong start
            var wXlRange = RldLib.XlHelper.XlApp.GetSelectedCell;
            //add #9767 データ項目を含むセルを結合させるとパラメータ一覧とのリンクが切れる dongzhaolong end

            Form formzd = new Form();
            formzd.StartPosition = FormStartPosition.Manual;
            formzd.FormBorderStyle = FormBorderStyle.None;
            frmDesignParent fdp = (frmDesignParent)this.Owner;
            List<IRldDesignColleague> m_Colleagues = fdp.m_Colleagues;
            frmDesignChildSelectedItem fdclp = (frmDesignChildSelectedItem)m_Colleagues[0];
            frmDesignChildDataList fdcdl = (frmDesignChildDataList)m_Colleagues[1];
            frmDesignChildLayout fdcl = (frmDesignChildLayout)m_Colleagues[2];
            formzd.Location = new Point((int)this.Width, (int)fdclp.Height);
            int width = Screen.PrimaryScreen.Bounds.Width;
            int height = Screen.PrimaryScreen.Bounds.Height;
            formzd.Size = new Size(width - fdcl.Width - fdcdl.Width, height - (int)fdclp.Height - 30);
            // add #10230 コピーした内容がリセットされる 高 start
            UpdateTempleteAreaImage(fdcl);
            // add #10230 コピーした内容がリセットされる 高 end
            //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 START
            formzd.ControlBox = false;
            formzd.ShowInTaskbar = false;
            formzd.BackColor = Color.LightGray;
            formzd.Opacity = 0.01;
            //formzd.TopMost = true;
            //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 END

            //add #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 START
            frmDesignChildLayoutTemplete frmDesChiLayTem = new frmDesignChildLayoutTemplete();
            frmDesignChildLayoutTotal frmDesChiLayTot = new frmDesignChildLayoutTotal();
            frmEditRepeat frmEditRepeat = new frmEditRepeat();
            //add #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 END
            // 4画面上の処理中ローディングは、現在操作中のデータ項目リスト側のモニタへ出す。
            LoadingHelper.ShowLoadingDialog(this);
            try
            {
                //del #9878 【デグレ】Excelの編集欄が更新されないときがある dongzhaolong start
                //RldLib.XlHelper.XlApp.Application.ScreenUpdating = false;
                //RldLib.XlHelper.IsHandleLayoutSheetEvent = false;
                //del #9878 【デグレ】Excelの編集欄が更新されないときがある dongzhaolong end
                confirmPrintArea = true;
                Boolean wIsSave = false, wIsWorkFile = false;
                DialogResult wResult = DialogResult.None;
                // add #8559 動作に関する指摘２ 邾 start

                // オンランで保存 -> 保存して続ける
                if (sender == this.mnuFilesaveOnlineSave)
                {
                    // add #9398 「オンラインで保存」の通常保存時は「新規登録」の時のみ「帳票保存設定」が出るようにすること donghao start
                    blMnuFilesaveOnlineSave = true;
                    // add #9398 「オンラインで保存」の通常保存時は「新規登録」の時のみ「帳票保存設定」が出るようにすること donghao end
                    //del 8615-15 zhu start
                    //add #8615 zhu start
                    //string groupName = "";
                    //foreach (var wData in RldLib.CurrentLayoutData.DesignGroupList)
                    //{
                    //    string strRepeatCount = "";
                    //    int i = 0;
                    //    foreach (var wDataItem in RldLib.CurrentLayoutData.DesignParamList)
                    //    {
                    //        if (wData.GroupName == wDataItem.GroupName)
                    //        {
                    //            if (i == 0)
                    //            {
                    //                strRepeatCount = wDataItem.RepeatCount;
                    //                i = 1;
                    //            }
                    //            else if (i == 1)

                    //            {
                    //                if (wDataItem.RepeatCount != strRepeatCount)
                    //                {
                    //                    groupName += wDataItem.GroupName + "-";
                    //                    i = 2;
                    //                }
                    //            }
                    //        }
                    //    }
                    //    i = 0;
                    //}
                    //if (groupName != "")
                    //{
                    //    System.Windows.Forms.MessageBox.Show("グループ「" + groupName + "」に複数の設定がされています。1グループに設定は１つです。", "同一グループに複数の設定があります");
                    //    return;
                    //}
                    //add #8615 zhu end
                    //del 8615-15 zhu end
                    wIsSave = true; wIsWorkFile = false;
                    wResult = DialogResult.Yes;

                    //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 START

                    //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 END

                    formzd.Show();
                    RldLib.XlHelper.XlApp.Application.Visible = true;

                    //add #8647 start
                    MnuFileSaveAsOther.Visible = true;
                    this.MnuFileSaveAsReturn.Visible = true;
                    this.MnuFileSaveAsExit.Visible = true;
                    //add #8647 end

                    // del #9816 テンプレート設定に関する処理がデザイナと帳票生成時で重複している limingzhe start
                    //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 START
                    //frmEditRepeat.syncStyle();
                    //frmDesChiLayTem.syncStyle(frmDesChiLayTem.meditTotal);
                    /* if (!frmDesChiLayTem.meditTotal)
                     {
                         frmDesChiLayTot.syncStyle(frmDesChiLayTot.medit);
                     }*/
                    //frmDesChiLayTot.syncStyle(frmDesChiLayTot.medit);
                    //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 END
                    // del #9816 テンプレート設定に関する処理がデザイナと帳票生成時で重複している limingzhe end
                }
                // add #8559 動作に関する指摘２ 邾 end
                // オンランで保存 -> 戻る
                else if (sender == this.mnuFileSaveOnlineReturn)
                {
                    confirmPrintArea = true;
                    // add #9398 「オンラインで保存」の通常保存時は「新規登録」の時のみ「帳票保存設定」が出るようにすること donghao start
                    blMnuFileSaveOnlineReturn = true;
                    // add #9398 「オンラインで保存」の通常保存時は「新規登録」の時のみ「帳票保存設定」が出るようにすること donghao end

                    wIsSave = true; wIsWorkFile = false;
                    wResult = DialogResult.Yes;

                    formzd.Show();
                    RldLib.XlHelper.XlApp.Application.Visible = true;

                    // del #9816 テンプレート設定に関する処理がデザイナと帳票生成時で重複している limingzhe start
                    //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 START\
                    //frmEditRepeat.syncStyle();
                    //frmDesChiLayTem.syncStyle(frmDesChiLayTem.meditTotal);
                    /*if (!frmDesChiLayTem.meditTotal)
                    {
                        frmDesChiLayTot.syncStyle(frmDesChiLayTot.medit);
                    }*/
                    //frmDesChiLayTot.syncStyle(frmDesChiLayTot.medit);
                    //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 END
                    // del #9816 テンプレート設定に関する処理がデザイナと帳票生成時で重複している limingzhe end

                    wIsSave = true; wIsWorkFile = false;
                    wResult = DialogResult.OK;
                }
                // オンラインで保存 -> 終了
                else if (sender == this.mnuFileSaveOnlineExit)
                {
                    confirmPrintArea = true;
                    // add #9398 「オンラインで保存」の通常保存時は「新規登録」の時のみ「帳票保存設定」が出るようにすること donghao start
                    blMnuFileSaveOnlineExit = true;
                    // add #9398 「オンラインで保存」の通常保存時は「新規登録」の時のみ「帳票保存設定」が出るようにすること donghao end

                    wIsSave = true; wIsWorkFile = false;
                    wResult = DialogResult.Yes;

                    formzd.Show();
                    RldLib.XlHelper.XlApp.Application.Visible = true;

                    // del #9816 テンプレート設定に関する処理がデザイナと帳票生成時で重複している limingzhe start
                    //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 START
                    //frmEditRepeat.syncStyle();
                    //frmDesChiLayTem.syncStyle(frmDesChiLayTem.meditTotal);
                    /* if (!frmDesChiLayTem.meditTotal)
                     {
                         frmDesChiLayTot.syncStyle(frmDesChiLayTot.medit);
                     }*/
                    //frmDesChiLayTot.syncStyle(frmDesChiLayTot.medit);
                    //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 END
                    // del #9816 テンプレート設定に関する処理がデザイナと帳票生成時で重複している limingzhe end

                    wIsSave = true; wIsWorkFile = false;
                    wResult = DialogResult.Cancel;
                }
                // 一時ファイルとして保存のみ
                //else if (sender == this.mnuFileSaveTemp)
                //{
                //    wIsSave = true; wIsWorkFile = false;
                //    wResult = DialogResult.Yes;

                //    formzd.Show();
                //    RldLib.XlHelper.XlApp.Application.Visible = true;

                // del #9816 テンプレート設定に関する処理がデザイナと帳票生成時で重複している limingzhe start
                //    //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 START
                //    frmEditRepeat.syncStyle();
                //    frmDesChiLayTem.syncStyle(frmDesChiLayTem.meditTotal);
                //    /*if (!frmDesChiLayTem.meditTotal)
                //    {
                //        frmDesChiLayTot.syncStyle(frmDesChiLayTot.medit);
                //    }*/
                //    frmDesChiLayTot.syncStyle(frmDesChiLayTot.medit);
                //    //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 END
                // del #9816 テンプレート設定に関する処理がデザイナと帳票生成時で重複している limingzhe end

                //    wIsSave = true; wIsWorkFile = true;
                //}
                // 一時ファイルとして保存 -> 戻る
                else if (sender == this.mnuFileSaveTempReturn)
                {
                    confirmPrintArea = false;
                    wIsSave = true; wIsWorkFile = false;
                    wResult = DialogResult.Yes;

                    formzd.Show();
                    RldLib.XlHelper.XlApp.Application.Visible = true;

                    // del #9816 テンプレート設定に関する処理がデザイナと帳票生成時で重複している limingzhe start
                    //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 START
                    //frmEditRepeat.syncStyle();
                    //frmDesChiLayTem.syncStyle(frmDesChiLayTem.meditTotal);
                    /*if (!frmDesChiLayTem.meditTotal)
                    {
                        frmDesChiLayTot.syncStyle(frmDesChiLayTot.medit);
                    }*/
                    //frmDesChiLayTot.syncStyle(frmDesChiLayTot.medit);
                    //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 END
                    // del #9816 テンプレート設定に関する処理がデザイナと帳票生成時で重複している limingzhe end

                    wIsSave = true; wIsWorkFile = true;
                    wResult = DialogResult.OK;
                }
                // 一時ファイルとして保存 -> 終了
                else if (sender == this.mnuFileSaveTempExit)
                {
                    confirmPrintArea = false;
                    wIsSave = true; wIsWorkFile = false;
                    wResult = DialogResult.Yes;

                    formzd.Show();
                    RldLib.XlHelper.XlApp.Application.Visible = true;

                    // del #9816 テンプレート設定に関する処理がデザイナと帳票生成時で重複している limingzhe start
                    //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 START
                    //frmEditRepeat.syncStyle();
                    //frmDesChiLayTem.syncStyle(frmDesChiLayTem.meditTotal);
                    /*if (!frmDesChiLayTem.meditTotal)
                    {
                        frmDesChiLayTot.syncStyle(frmDesChiLayTot.medit);
                    }*/
                    //frmDesChiLayTot.syncStyle(frmDesChiLayTot.medit);
                    //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 END
                    // del #9816 テンプレート設定に関する処理がデザイナと帳票生成時で重複している limingzhe end

                    wIsSave = true; wIsWorkFile = true;
                    wResult = DialogResult.Cancel;
                }
                // 一時ファイルを破棄 -> 戻る
                else if (sender == this.mnuFileDropTempReturn)
                {
                    confirmPrintArea = false;
                    wIsSave = false; wIsWorkFile = true;
                    wResult = DialogResult.OK;
                }
                // 一時ファイルを破棄 -> 終了
                else if (sender == this.mnuFileDropTempExit)
                {
                    confirmPrintArea = false;
                    wIsSave = false; wIsWorkFile = true;
                    wResult = DialogResult.Cancel;
                }
                else
                {
                    confirmPrintArea = false;
                    System.Diagnostics.Debug.Assert(false);
                }

                //LoadingHelper.CloseLoadingDialog();

                // ファイルを保存/破棄する
                //edit #9767 データ項目を含むセルを結合させるとパラメータ一覧とのリンクが切れる dongzhaolong start
                SaveDropFile(wIsSave, wIsWorkFile, wResult, RldLib.CurrentReport.ReportCode == long.MinValue, wXlRange.Range.Address[false,false], confirmPrintArea);
                //edit #9767 データ項目を含むセルを結合させるとパラメータ一覧とのリンクが切れる dongzhaolong end

                //LoadingHelper.ShowLoadingDialog();

                // add #9398 「オンラインで保存」の通常保存時は「新規登録」の時のみ「帳票保存設定」が出るようにすること donghao start
                if (frmDesignParent.blCancel)
                {
                    if (!frmDesignParent.blWes || string.IsNullOrEmpty(RldLib.CurrentLayoutData.DesignSettingData.ReportCode))
                    {
                        this.MnuFileSaveAsOther.Visible = false;
                        this.MnuFileSaveAsReturn.Visible = false;
                        this.MnuFileSaveAsExit.Visible = false;
                    }
                    else
                    {
                        if (frmMainMenuChildMakeReport.sinkiFlg)
                        {
                            this.MnuFileSaveAsOther.Visible = false;
                            this.MnuFileSaveAsReturn.Visible = false;
                            this.MnuFileSaveAsExit.Visible = false;
                        }
                        else
                        {
                            this.MnuFileSaveAsOther.Visible = true;
                            this.MnuFileSaveAsReturn.Visible = true;
                            this.MnuFileSaveAsExit.Visible = true;
                        }
                    }
                }

                blMnuFileSaveOnlineExit = false;
                blMnuFileSaveOnlineReturn = false;
                blMnuFilesaveOnlineSave = false;
                frmMainMenuChildMakeReport.sinkiFlg = false;
                frmDesignParent.blCancel = false;
                frmDesignParent.blWes = false;
                // add #9398 「オンラインで保存」の通常保存時は「新規登録」の時のみ「帳票保存設定」が出るようにすること donghao end
            }
            catch (Exception ex)
            {

                throw;
            }
            finally
            {
                formzd.Close();
                LoadingHelper.CloseLoadingDialog();
                //del #9878 【デグレ】Excelの編集欄が更新されないときがある dongzhaolong start
                //RldLib.XlHelper.XlApp.Application.ScreenUpdating = true;
                //RldLib.XlHelper.IsHandleLayoutSheetEvent = true;
                //del #9878 【デグレ】Excelの編集欄が更新されないときがある dongzhaolong end
            }
            //edit #9648 【デグレ】オンライン保存の実行中Excelのウインドウがグレーで潰れる dongzhaolong end
        }

        /// <summary>
        /// ファイルを保存/破棄する
        /// </summary>
        /// <param name="wIsSave">ファイルを保存する場合 True。保存しない場合 False。</param>
        /// <param name="wIsWorkFile">一時ファイルを生成する場合 True。保存しない場合 False。</param>
        /// <param name="wResult">メインメニューへ戻る場合 DialogResult.OK。終了する場合 DialogResult.Cancel。</param>
        /// <param name="wIsSaveAs">名前を付けて保存する場合 True。そうでない場合 False。</param>
        //edit #9767 データ項目を含むセルを結合させるとパラメータ一覧とのリンクが切れる dongzhaolong start
        private void SaveDropFile(bool wIsSave, bool wIsWorkFile, DialogResult wResult, bool wIsSaveAs,string lastCellAddress,bool confirmPrintArea)
        //edit #9767 データ項目を含むセルを結合させるとパラメータ一覧とのリンクが切れる dongzhaolong end

        {
            // add #11758 セルを編集中のまま、保存作業を行うと致命的なエラーが発生する 高 start
            RldLib.SendExeclTAB();
            // add #11758 セルを編集中のまま、保存作業を行うと致命的なエラーが発生する 高 end

            //add #9850 印刷範囲外に文字が入力されていないのにメッセージが出る dongzhaolong start
            if (confirmPrintArea)
            {
                this.ConfirmPrintArea(ref printType);
                GlobalVariables.printType = printType;
            }
            //add #9850 印刷範囲外に文字が入力されていないのにメッセージが出る dongzhaolong end
            // add #9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 高 start
            foreach (DesignParamData paramData in RldLib.CurrentLayoutData.DesignParamList)
            {
                if(RldLib.XlHelper.XlApp.IsInTemplete(paramData.CellAddress, lastCellAddress))
                {
                    bool isShrinkParam = false;
                    // paramData = 縮小表示ONの場所
                    if ("1".Equals(paramData.IsShrink))
                    {
                        isShrinkParam = true;
                    }
                    using (var wXlRange = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, paramData.CellAddress))
                    {
                        //
                        object wValue = wXlRange.Range.ShrinkToFit;
                        bool wIsShrink = wValue == DBNull.Value || (bool)wValue;
                        // cell.縮小表示 != paramData.縮小表示
                        bool reCalc = (wIsShrink != isShrinkParam);
                        if (reCalc == true)
                        {
                            paramData.IsShrink = wIsShrink ? RldConst.ParamData.VAL_ISSHRINK_DONE : RldConst.ParamData.VAL_ISSHRINK_NONE;
                        }
                    }
                }
            }
            // add #9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 高 end
            string path = RldLib.XlHelper.XlBookFilePath;
            // add #7943 帳票レイアウトデザイナーが正しく動作しないの対応 夏 start
            if (wIsSave && !RldLib.IsSaveLayoutSheet)
            {
                RldLib.IsSaveLayoutSheet = true;
                RldLib.XlHelper.XlBook.Workbook.Save();
                RldLib.IsSaveLayoutSheet = false;
            }
            // add #7943 帳票レイアウトデザイナーが正しく動作しないの対応 夏 end

            // 破棄時以外は入力内容をチェック
            // mod 2021-07-16 一時ファイルを生成する場合 no check 李 start
            if (wIsWorkFile == false)
            {
                if (wIsSave && !this.DataCheck()) return;
            }
            //add #9767 データ項目を含むセルを結合させるとパラメータ一覧とのリンクが切れる dongzhaolong start

            //var wXlRange = RldLib.XlHelper.XlApp.GetSelectedCell
            DesignParamData wData = RldLib.CurrentLayoutData.FindDesignParamData(lastCellAddress);
            if (wData != null)
            {
                this.UpdateLayoutSheetRangeFormatSetting(wData);
            }
            //add #9767 データ項目を含むセルを結合させるとパラメータ一覧とのリンクが切れる dongzhaolong end

            // mod 2021-07-16 一時ファイルを生成する場合 no check 李 end

            /* ファイルの保存/破棄を依頼
             * 一時ファイルとして保存する場合は作業用ファイルを保存
             * そうでない場合は xlsx/html/xml ファイルを生成
             */
            var wSaveDropFileArg = new RldDesignNotifyInfoRequestSaveDropFileEventArgs()
            {
                IsSave = wIsSave,
                IsWorkFile = wIsWorkFile,
                IsCanceled = false,
                IsSaveAs = wIsSaveAs
            };
            base.SendNotifyInfo(this, wSaveDropFileArg);

            // add #7943 帳票レイアウトデザイナーが正しく動作しないの対応 夏 start
            if (!wSaveDropFileArg.Result) return;
            // add #7943 帳票レイアウトデザイナーが正しく動作しないの対応 夏 end

            // キャンセル時はデザイン画面に留まる
            if (wSaveDropFileArg.IsCanceled) return;
            // 一時ファイルとして保存のみの場合はデザイン画面に留まる
            if (wResult == DialogResult.None)
            {
                // ブックがロックされている場合は解除
                if (RldLib.XlHelper.XlBook.IsProtected) RldLib.XlHelper.XlBook.IsProtected = false;
                // レイアウトシートがロックされている場合は解除
                if (RldLib.XlHelper.XlSheetLayout.IsProtected) RldLib.XlHelper.XlSheetLayout.IsProtected = false;

                return;
            }
            // add #8559 動作に関する指摘２ 邾 end
            if (wResult == DialogResult.Yes)
            {
                RldLib.XlHelper.XlApp.Application.Visible = true;
                RldLib.XlHelper.Open(path);
                return;
            }
            // add #8559 動作に関する指摘２ 邾 end
            // 閉じる(戻る or 終了)
            base.SendNotifyInfo(this, new RldDesignNotifyInfoRequestCloseEventArgs(CloseReason.UserClosing, false, wResult));

        }
        //add #9850 印刷範囲外に文字が入力されていないのにメッセージが出る dongzhaolong start
        public bool ConfirmPrintArea(ref int printType)
        {
            bool wRet = false;

            try
            {
                RldLib.XlHelper.IsHandleLayoutSheetEvent = false;
                // 警告表示を無効化
                RldLib.XlHelper.XlApp.Application.DisplayAlerts = false;

                foreach (Microsoft.Office.Interop.Excel.Worksheet sheet in RldLib.XlHelper.XlBook.Workbook.Worksheets)
                {
                    sheet.Unprotect();
                }
                // ブックを保存する
                // del #12557 レイアウトデザイナで開くExcelのワークシートが編集可能 高 start
                //RldLib.XlHelper.XlBook.Workbook.Unprotect();
                // del #12557 レイアウトデザイナで開くExcelのワークシートが編集可能 高 end

                if (null == RldLib.XlHelper.XlSheetLayout.Worksheet.PageSetup.PrintArea)
                {
                    Microsoft.Office.Interop.Excel.Range range = RldLib.XlHelper.XlSheetLayout.Worksheet.UsedRange;
                    //edit #9966 初回オンライン保存時に印刷範囲が強制変更される dongzhaolong start
                    //if (RldLib.XlHelper.XlSheetLayout.Worksheet.PageSetup.Pages.Count > 0)
                    //{
                    //    Microsoft.Office.Interop.Excel.Range lastColRange = range.Cells.Find(What: "*", LookIn: -4123, LookAt: 2, SearchOrder: 2, SearchDirection: Microsoft.Office.Interop.Excel.XlSearchDirection.xlPrevious, MatchCase: false);
                    //    Microsoft.Office.Interop.Excel.Range lastRowRange = range.Cells.Find(What: "*", LookIn: -4123, LookAt: 2, SearchOrder: 1, SearchDirection: Microsoft.Office.Interop.Excel.XlSearchDirection.xlPrevious, MatchCase: false);

                    //    if (lastColRange != null && lastRowRange != null)
                    //    {
                    //        long lastRow = range.Cells.Find(What: "*", LookIn: -4123, LookAt: 2, SearchOrder: 1, SearchDirection: Microsoft.Office.Interop.Excel.XlSearchDirection.xlPrevious, MatchCase: false).Row;
                    //        long lastCol = range.Cells.Find(What: "*", LookIn: -4123, LookAt: 2, SearchOrder: 2, SearchDirection: Microsoft.Office.Interop.Excel.XlSearchDirection.xlPrevious, MatchCase: false).Column;
                    //        String strRow = lastRowRange.Address;
                    //        String strCol = lastColRange.Address;
                    //        if (lastRowRange.MergeCells && lastRowRange.MergeArea != null)
                    //        {
                    //            if (lastRowRange.MergeArea.Rows.CountLarge > 1)
                    //            {
                    //                lastRow += lastRowRange.MergeArea.Rows.CountLarge - 1;
                    //            }
                    //        }
                    //        if (lastColRange.MergeCells && lastColRange.MergeArea != null)
                    //        {
                    //            if (lastColRange.MergeArea.Rows.CountLarge > 1)
                    //            {
                    //                lastCol += lastColRange.MergeArea.Rows.CountLarge - 1;
                    //            }
                    //        }

                    //        if (RldLib.CurrentLayoutData.DesignSettingData.HasTemplete == RldConst.SettingData.VAL_HAS_TEMPLETE_YES &&
                    //            RldLib.CurrentLayoutData.DesignTempleteData.RepeatStartPosList.Count > 0)
                    //        {
                    //            if (lastCol <= RldLib.CurrentLayoutData.DesignTempleteData.RepeatStartPosList[RldLib.CurrentLayoutData.DesignTempleteData.RepeatStartPosList.Count - 1].X
                    //                              + RldLib.CurrentLayoutData.DesignTempleteData.ColumnCount)
                    //            {
                    //                lastCol = RldLib.CurrentLayoutData.DesignTempleteData.RepeatStartPosList[RldLib.CurrentLayoutData.DesignTempleteData.RepeatStartPosList.Count - 1].X
                    //                              + RldLib.CurrentLayoutData.DesignTempleteData.ColumnCount - 1;
                    //            }
                    //            if (lastRow <= RldLib.CurrentLayoutData.DesignTempleteData.RepeatStartPosList[RldLib.CurrentLayoutData.DesignTempleteData.RepeatStartPosList.Count - 1].Y
                    //                              + RldLib.CurrentLayoutData.DesignTempleteData.RowCount)
                    //            {
                    //                lastRow = RldLib.CurrentLayoutData.DesignTempleteData.RepeatStartPosList[RldLib.CurrentLayoutData.DesignTempleteData.RepeatStartPosList.Count - 1].Y
                    //                              + RldLib.CurrentLayoutData.DesignTempleteData.RowCount - 1;
                    //            }
                    //        }
                    //        range = RldLib.XlHelper.XlSheetLayout.Worksheet.Range[range.get_Address(false, false).Substring(0, 2), frmDesignChildLayoutParam.ToName((int)lastCol - 1) + lastRow];
                    //    }
                    //}
                    StringBuilder sbPrintRange = new StringBuilder();
                    string[] printArea = range.get_Address().Split(':');
                    if (printArea.Length == 1)
                    {
                        sbPrintRange.Append("$A$1");
                        sbPrintRange.Append(":");
                        sbPrintRange.Append(printArea[0].ToString());
                    }
                    else
                    {
                        sbPrintRange.Append("$A$1");
                        sbPrintRange.Append(":");
                        sbPrintRange.Append(printArea[1].ToString());
                    }
                    RldLib.XlHelper.XlSheetLayout.Worksheet.PageSetup.PrintArea = sbPrintRange.ToString();
                    //edit #9966 初回オンライン保存時に印刷範囲が強制変更される dongzhaolong end
                }

                if (null != RldLib.XlHelper.XlSheetLayout.Worksheet.PageSetup.PrintArea)
                {
                    bool msgFlg = false;

                    Microsoft.Office.Interop.Excel.Range printRange = RldLib.XlHelper.XlSheetLayout.Worksheet.Range[RldLib.XlHelper.XlSheetLayout.Worksheet.PageSetup.PrintArea];
                    
                    //edit #9850 印刷範囲外に文字が入力されていないのにメッセージが出る dongzhaolong start
                    if (GlobalVariables.usedRangeAddress == string.Empty)
                    {
                        usedRange = RldLib.XlHelper.XlSheetLayout.Worksheet.UsedRange;
                    }
                    else
                    {
                        usedRange = RldLib.XlHelper.XlSheetLayout.Worksheet.Range[GlobalVariables.usedRangeAddress.ToString()];
                    }
                    //edit #9850 印刷範囲外に文字が入力されていないのにメッセージが出る dongzhaolong end
                    Microsoft.Office.Interop.Excel.Range intersectRange = RldLib.XlHelper.XlApp.Application.Intersect(printRange, usedRange);
                    bool isOverlap = (intersectRange != null && intersectRange.Count == usedRange.Count && intersectRange.Count == printRange.Count);
                    bool isRangeContains = (intersectRange != null && intersectRange.Address == usedRange.Address);

                    if (isOverlap || isRangeContains)
                    {
                        msgFlg = false;
                    }
                    else
                    {
                        msgFlg = true;
                    }
                    // add #11331 「印刷範囲外に～」のメッセージが編集開始後最初の保存で毎回出る 高 start
                    int findLeftUp = 0;
                    if (RldLib.XlHelper.XlApp.IsSameLast(printRange, RldLib.XlHelper.XlSheetLayout.Worksheet.UsedRange))
                    {
                        findLeftUp = RldLib.XlHelper.XlApp.FindLeftUpRange(printRange);
                        if (findLeftUp == 0)
                        {
                            if (msgFlg)
                                msgFlg = false;
                        }
                        else
                        {
                            msgFlg = true;
                        }
                    }
                    // add #11331 「印刷範囲外に～」のメッセージが編集開始後最初の保存で毎回出る 高 end
                    //edit #9850 印刷範囲外に文字が入力されていないのにメッセージが出る dongzhaolong start
                    if (GlobalVariables.oldUsedRangeAddress != string.Empty)
                    {
                        // mod #11331 「印刷範囲外に～」のメッセージが編集開始後最初の保存で毎回出る 高 start
                        //if (GlobalVariables.oldUsedRangeAddress != RldLib.XlHelper.XlSheetLayout.Worksheet.UsedRange.Address)
                        if (GlobalVariables.oldUsedRangeAddress != RldLib.XlHelper.XlSheetLayout.Worksheet.UsedRange.Address
                            && ((RldLib.XlHelper.XlSheetLayout.Worksheet.UsedRange.Row + RldLib.XlHelper.XlSheetLayout.Worksheet.UsedRange.Rows.Count) > (printRange.Row + printRange.Rows.Count)
                             || (RldLib.XlHelper.XlSheetLayout.Worksheet.UsedRange.Column + RldLib.XlHelper.XlSheetLayout.Worksheet.UsedRange.Columns.Count) > (printRange.Column + printRange.Columns.Count)))
                        // mod #11331 「印刷範囲外に～」のメッセージが編集開始後最初の保存で毎回出る 高 end
                        {
                            msgFlg = true;
                        }
                    }
                    else
                    {
                        oldUsedRange = RldLib.XlHelper.XlSheetLayout.Worksheet.UsedRange;
                    }
                    //edit #9850 印刷範囲外に文字が入力されていないのにメッセージが出る dongzhaolong end
                    // 印刷範囲外に内容がある場合
                    if (msgFlg)
                    {
                        LoadingHelper.CloseLoadingDialog();
                        // 保存確認は owner を付けて、サブモニタ作業中に主画面へ飛ばさない。
                        DialogResult dr = MessageBox.Show(this, "印刷範囲外にデータが入力されています。削除してから保存しますか？", "保存確認", MessageBoxButtons.YesNo);

                        // 「いいえ」を選択した場合、そのまま保存
                        if (dr == DialogResult.No)
                        {
                            printType = (int)Microsoft.Office.Interop.Excel.XlSourceType.xlSourceSheet;
                        }
                        // 「はい」を選択した場合、削除してから保存
                        else
                        {
                            //edit #9966 初回オンライン保存時に印刷範囲が強制変更される dongzhaolong start
                            // mod #11331 「印刷範囲外に～」のメッセージが編集開始後最初の保存で毎回出る 高 start
                            //Microsoft.Office.Interop.Excel.Range upRange = null;
                            Microsoft.Office.Interop.Excel.Range downRange = null;
                            Microsoft.Office.Interop.Excel.Range upRange = null;
                            Microsoft.Office.Interop.Excel.Range leftRange = null;
                            // mod #11331 「印刷範囲外に～」のメッセージが編集開始後最初の保存で毎回出る 高 end
                            Microsoft.Office.Interop.Excel.Range rightRange = null;
                            Microsoft.Office.Interop.Excel.Range paramRange = null;
                            Microsoft.Office.Interop.Excel.Range unionRange = RldLib.XlHelper.XlSheetLayout.Worksheet.Range["XFD1048576:XFD1048576"];
                            string unionRangeAddress = string.Empty;
                            //if (printRange.Row > 1)
                            //{
                            //    string upRangeAddress = "A1:XFD" + (printRange.Row - 1).ToString() + "";
                            //    upRange = RldLib.XlHelper.XlApp.Application.Intersect(RldLib.XlHelper.XlSheetLayout.Worksheet.Range[upRangeAddress], RldLib.XlHelper.XlSheetLayout.Worksheet.UsedRange);
                            //    if (upRange != null)
                            //    {
                            //        unionRange = RldLib.XlHelper.XlApp.Application.Union(unionRange, upRange);
                            //        unionRangeAddress = unionRange.Address;
                            //        upRange.Clear();
                            //    }
                            //}
                            //if (printRange.Column > 1)
                            //{
                            //    string leftRangeAddress = "A1:" + ConvertNumberToLetter(printRange.Column - 1) + "1048576";
                            //    leftRange = RldLib.XlHelper.XlApp.Application.Intersect(RldLib.XlHelper.XlSheetLayout.Worksheet.Range[leftRangeAddress], RldLib.XlHelper.XlSheetLayout.Worksheet.UsedRange);
                            //    if (leftRange != null)
                            //    {
                            //        unionRange = RldLib.XlHelper.XlApp.Application.Union(unionRange, leftRange);
                            //        unionRangeAddress = unionRange.Address;
                            //        leftRange.Clear();
                            //    }
                            //}
                            //edit #9966 初回オンライン保存時に印刷範囲が強制変更される dongzhaolong end
                            // add #11331 「印刷範囲外に～」のメッセージが編集開始後最初の保存で毎回出る 高 start
                            // leftRange
                            if (printRange.Column > 1)
                            {
                                string leftRangeAddress = "A1:" + ConvertNumberToLetter(printRange.Column - 1) + (printRange.Row - 1 + printRange.Rows.Count);
                                leftRange = RldLib.XlHelper.XlSheetLayout.Worksheet.Range[leftRangeAddress];
                                if (leftRange != null)
                                {
                                    unionRange = RldLib.XlHelper.XlApp.Application.Union(unionRange, leftRange);
                                    unionRangeAddress = unionRange.Address;
                                    leftRange.Clear();
                                }
                            }
                            // upRange
                            if (printRange.Row > 1)
                            {
                                string upRangeAddress = "A1:" + ConvertNumberToLetter(printRange.Column - 1 + printRange.Columns.Count) + (printRange.Row - 1);
                                upRange = RldLib.XlHelper.XlSheetLayout.Worksheet.Range[upRangeAddress];
                                if (upRange != null)
                                {
                                    unionRange = RldLib.XlHelper.XlApp.Application.Union(unionRange, upRange);
                                    unionRangeAddress = unionRange.Address;
                                    upRange.Clear();
                                }
                            }
                            // add #11331 「印刷範囲外に～」のメッセージが編集開始後最初の保存で毎回出る 高 end
                            string downRangeAddress = "A" + (printRange.Row + printRange.Rows.Count) + ":XFD1048576";
                            downRange = RldLib.XlHelper.XlApp.Application.Intersect(RldLib.XlHelper.XlSheetLayout.Worksheet.Range[downRangeAddress], RldLib.XlHelper.XlSheetLayout.Worksheet.UsedRange);
                            if (downRange != null)
                            {
                                unionRange = RldLib.XlHelper.XlApp.Application.Union(unionRange, downRange);
                                unionRangeAddress = unionRange.Address;
                                downRange.Delete();
                            }
                            string rightRangeAddress = "" + ConvertLetterToNumber(printRange.Column + printRange.Columns.Count) + "1:XFD1048576";
                            rightRange = RldLib.XlHelper.XlApp.Application.Intersect(RldLib.XlHelper.XlSheetLayout.Worksheet.Range[rightRangeAddress], RldLib.XlHelper.XlSheetLayout.Worksheet.UsedRange);
                            if (rightRange != null)
                            {
                                unionRange = RldLib.XlHelper.XlApp.Application.Union(unionRange, rightRange);
                                unionRangeAddress = unionRange.Address;
                                rightRange.Delete();
                            }


                                string[] add = unionRangeAddress.Split(',');
                                StringBuilder sb = new StringBuilder();
                                if (add.Length > 1)
                                {
                                    for (int i = 0; i < add.Length; i++)
                                    {
                                        if (i > 0 && i < add.Length - 1)
                                        {
                                            sb.Append(add[i]);
                                            sb.Append(",");
                                        }
                                        else if (i == add.Length - 1)
                                        {
                                            sb.Append(add[i]);
                                        }
                                    }
                                }
                                if (sb.ToString() != string.Empty)
                                {
                                    unionRange = RldLib.XlHelper.XlSheetLayout.Worksheet.Range[sb.ToString()];
                                    for (int i = 0; i < RldLib.CurrentLayoutData.DesignParamList.Count; i++)
                                    {
                                        paramRange = RldLib.XlHelper.XlSheetLayout.Worksheet.Range[RldLib.CurrentLayoutData.DesignParamList[i].CellAddress];
                                        if (RldLib.XlHelper.XlApp.Application.Intersect(paramRange, unionRange) != null)
                                        {
                                            RldLib.CurrentLayoutData.RemoveDesignParamData(RldLib.CurrentLayoutData.DesignParamList[i]);
                                            i -= 1;
                                        }
                                    }
                                    // mod #10146 オンライン保存時の「印刷範囲外データを削除しますか」メッセージが「はい」にして毎回出る 高 start
                                    //edit #9850 印刷範囲外に文字が入力されていないのにメッセージが出る dongzhaolong start
                                    //GlobalVariables.usedRangeAddress = printRange.Address;
                                    //GlobalVariables.oldUsedRangeAddress = RldLib.XlHelper.XlSheetLayout.Worksheet.UsedRange.Address;
                                    //edit #9850 印刷範囲外に文字が入力されていないのにメッセージが出る dongzhaolong end
                                }
                            GlobalVariables.usedRangeAddress = printRange.Address;
                            GlobalVariables.oldUsedRangeAddress = RldLib.XlHelper.XlSheetLayout.Worksheet.UsedRange.Address;
                            // mod #10146 オンライン保存時の「印刷範囲外データを削除しますか」メッセージが「はい」にして毎回出る 高 end

                            //if (unionRange != null)
                            //{
                            //    unionRange.Clear();
                            //}
                            //foreach (DesignParamData paramData in RldLib.CurrentLayoutData.DesignParamList)
                            //{
                            //    paramRange = RldLib.XlHelper.XlSheetLayout.Worksheet.Range[paramData.CellAddress];
                            //    if (RldLib.XlHelper.XlApp.Application.Intersect(paramRange,unionRange) != null)
                            //    {
                            //        RldLib.CurrentLayoutData.RemoveDesignParamData(paramData);
                            //    }
                            //}
                            printType = (int)Microsoft.Office.Interop.Excel.XlSourceType.xlSourcePrintArea;
                        }
                        LoadingHelper.ShowLoadingDialog(this);
                    }
                    else
                    {
                        printType = (int)Microsoft.Office.Interop.Excel.XlSourceType.xlSourcePrintArea;
                    }
                }
                else
                {
                    printType = (int)Microsoft.Office.Interop.Excel.XlSourceType.xlSourceSheet;
                }

                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }
            finally
            {
                // 警告表示を有効化
                RldLib.XlHelper.XlApp.Application.DisplayAlerts = true;
                RldLib.XlHelper.IsHandleLayoutSheetEvent = true;
            }
            return wRet;
        }
        private static string ConvertNumberToLetter(int colIndex)
        {
            string result = "";
            while (colIndex > 0)
            {
                int remainder = (colIndex - 1) % 26;
                char letter = (char)('A' + remainder);
                result = letter + result;
                colIndex = (colIndex - 1) / 26;
            }
            return result;
        }

        private static string ConvertLetterToNumber(int colIndex)
        {
            string result = "";
            while (colIndex > 0)
            {
                int remainder = (colIndex - 1) % 26;
                char letter = (char)('A' + remainder);
                result = letter + result;
                colIndex = (colIndex - 1) / 26;
            }
            return result;
        }
        //add #9850 印刷範囲外に文字が入力されていないのにメッセージが出る dongzhaolong end
        /// <summary>
        /// ファイルメニュー内の強制終了 Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void OnMenuFileForcibleClick(Object sender, System.EventArgs e)
        {
            // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 start
            if (RldLib.chkExeclDialog(1) == false)
                return;
            // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 end

            // 終了確認
            var wEventArgs = new RldDesignNotifyInfoRequestShowMessageEventArgs();
            wEventArgs.Text = "ファイルは破棄され保存されません。\r\nエクセルが終了出来ない状態になった時だけ使用して下さい。\r\n終了してよろしいですか？";
            wEventArgs.Caption = "強制終了確認";
            wEventArgs.Buttons = MessageBoxButtons.YesNo;
            wEventArgs.Icon = MessageBoxIcon.Question;
            wEventArgs.DefaultButton = MessageBoxDefaultButton.Button2;

            // メッセージボックス表示要求
            this.SendNotifyInfo(this, wEventArgs);

            // 拒否した場合は抜ける
            if (wEventArgs.DialogResult == DialogResult.No) return;

            // ファイルの削除(依頼のみ)
            base.SendNotifyInfo(this, new RldDesignNotifyInfoRequestSaveDropFileEventArgs()
            {
                IsSave = false,
                IsWorkFile = true
            });

            // 閉じる(終了)
            base.SendNotifyInfo(this, new RldDesignNotifyInfoRequestCloseEventArgs(CloseReason.UserClosing, false, DialogResult.Cancel));
        }

        /// <summary>
        /// 編集メニュー以下の ToolStripMenuItem の Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void OnMenuEditClick(Object sender, System.EventArgs e)
        {
            if (sender == this.mnuEditResetWindowLayout)
            {
                // 画面配置初期化は Excel アラート状態の確認を使うと誤検知しやすいため、
                // 既存の軽い状態確認のみ行ってから再配置する。
                if (RldLib.chkExeclDialog(1) == false)
                    return;

                var wOwner = this.Owner as frmDesignParent;
                if (wOwner != null)
                {
                    wOwner.ResetWindowLayout(Screen.FromControl(this).WorkingArea);
                }

                return;
            }

            // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 start
            if (RldLib.chkExeclDialog(2) == false)
                return;
            // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 end

            // 変更履歴
            if (sender == this.mnuEditHistory)
            {

                using (var wDlg = new frmHistoryList())
                {

                    // ダイアログの表示を要求
                    this.SendNotifyInfo(this, new RldDesignNotifyInfoRequestOpenDialogEventArgs(wDlg)
                    {
                        IsAllWindowLock = true,
                        IsProtectLayoutSheet = true
                    });
                }
            }
            // データセット全削除
            else if (sender == this.mnuEditAllDelete)
            {
                try
                {
                    // Excel の再描画処理を停止
                    RldLib.XlHelper.XlApp.Application.ScreenUpdating = false;
                    // レイアウトシートからのイベントを受けないように設定
                    RldLib.XlHelper.IsHandleLayoutSheetEvent = false;

                    // レイアウトシートの内容をクリア
                    RldLib.XlHelper.ClearSheetLayout();

                    // レイアウトウィンドウへ画面のクリア要求を通知
                    base.SendNotifyInfo(this, new RldDesignNotifyInfoRequestRemoveAllParamEventArgs());
                }
                catch (Exception ex)
                {
                    // 例外情報を生成
                    var wEx = new System.ApplicationException("データセット全削除中にエラーが発生しました。\r\n編集途中の場合は編集を完了して下さい。", ex);
                    // 例外情報を記録(画面にメッセージボックスを表示)
                    base.SendNotifyInfo(this, new RldDesignNotifyInfoRequestRecordExceptionEventArgs(wEx, true));
                }
                finally
                {
                    // レイアウトシートからのイベントを受けるように設定
                    RldLib.XlHelper.IsHandleLayoutSheetEvent = true;
                    // Excel の再描画処理を再開
                    if (!RldLib.XlHelper.XlApp.Application.ScreenUpdating)
                        RldLib.XlHelper.XlApp.Application.ScreenUpdating = true;
                }
            }
        }

        /// <summary>
        /// ヘルプメニュー以下の ToolStripMenuItem の Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void OnMenuHelpClick(Object sender, System.EventArgs e)
        {
            if (sender == this.mnuHelpManual)
                System.Diagnostics.Process.Start(RldUtility.ManualDirPath);
            else if (sender == this.mnuHelpVersion)
            {
                //var wInfo = System.Diagnostics.FileVersionInfo.GetVersionInfo(System.Windows.Forms.Application.StartupPath);

                //var wText = new System.Text.StringBuilder();
                //wText.Length = 0;
                //wText.AppendLine(wInfo.ProductName)
                //    .AppendLine()
                //    .AppendFormat("Version: {0}", wInfo.FileVersion);

                //base.SendNotifyInfo(
                //    this,
                //    new RldDesignNotifyInfoRequestShowMessageEventArgs() {
                //        Caption = "バージョン情報",
                //        Text = wText.ToString(),
                //        Buttons = MessageBoxButtons.OK,
                //        Icon = MessageBoxIcon.Information
                //    });

                // バージョン情報を表示する
                using (var about = new Forms.AboutBox1())
                {
                    about.ShowDialog(this);
                }

            }
        }

        #endregion

        #region 退避

        private void mnuEditAllAdd_Click(object sender, System.EventArgs e)
        {
            /*
                        if (false == ComParam.IsUltraMode)
                        {
                            if (DialogResult.Yes != MessageBox.Show(this, "表示中の項目を、タイトルA列、データB列、計算式C列に配置します。\r\n列が上書きされますが続行してよろしいですか？", "実行確認", MessageBoxButtons.YesNo, MessageBoxIcon.Question))
                            {
                                return;
                            }
                        }

                        try
                        {
                            ComParam.ExcelCtrl.SheetLayout.Cells.ShrinkToFit = true;

                            Xls.Range r;

                            r = ComParam.ExcelCtrl.SheetLayout.Cells[1, 1] as Xls.Range;
                            r.ColumnWidth = 15;

                            for (int i = 2; i < 2 + ToolConst.TEST_REPEAT_COUNT; i++)
                            {
                                r = ComParam.ExcelCtrl.SheetLayout.Cells[1, i] as Xls.Range;
                                r.ColumnWidth = 22;
                            }

                            int offset = 0;
                            string cc = null;
                            string bcc = null;

                            for (int i = 0; i < grdItem.Rows.Count; i++)
                            {
                                cc = grdItem[Category.Name, i].Value as string + "." + grdItem[Class.Name, i].Value as string;

                                if (cc != bcc)
                                {
                                    r = ComParam.ExcelCtrl.SheetLayout.get_Range(new CellRect(1, i + 1 + offset, 1, 0).Address, Type.Missing);
                                    r.Merge(Type.Missing);
                                    r.Interior.Color = 0xFF8080;
                                    r.Value2 = cc;
                                    bcc = cc;
                                    offset++;
                                    i--;
                                    continue;
                                }

                                string work = grdItem[Path.Name, i].Value as string;

                                if (string.IsNullOrEmpty(work))
                                {
                                    continue;
                                }

                                if (work.Length < 2)
                                {
                                    continue;
                                }

                                List<ItemParam> param = ComParam.SettingList.FindAll(ele => ele.Path == work);
                                if (1 != param.Count)
                                {
                                    continue;
                                }

                                r = ComParam.ExcelCtrl.SheetLayout.Cells[i + 1 + offset, 1] as Xls.Range;
                                r.Value2 = grdItem[Item.Name, i].Value as string;
                                r.BorderAround(Type.Missing, Xls.XlBorderWeight.xlThin, Xls.XlColorIndex.xlColorIndexAutomatic, Type.Missing);

                                if (param[0].ImageFlg)
                                {
                                    r.RowHeight = 108;
                                }

                                r = ComParam.ExcelCtrl.SheetLayout.Cells[i + 1 + offset, 2] as Xls.Range;
                                r.Value2 = work;
                                r.BorderAround(Type.Missing, Xls.XlBorderWeight.xlThin, Xls.XlColorIndex.xlColorIndexAutomatic, Type.Missing);

                                if (param[0].Repeat)
                                {
                                    for (int j = 3; j < 2 + ToolConst.TEST_REPEAT_COUNT; j++)
                                    {
                                        r = ComParam.ExcelCtrl.SheetLayout.Cells[i + 1 + offset, j] as Xls.Range;
                                        r.BorderAround(Type.Missing, Xls.XlBorderWeight.xlThin, Xls.XlColorIndex.xlColorIndexAutomatic, Type.Missing);
                                    }
                                }
                                else if (param[0].CalcFlg)
                                {
                                    r = ComParam.ExcelCtrl.SheetLayout.Cells[i + 1 + offset, 3] as Xls.Range;
                                    r.Value2 = "##=[" + work + "]+[" + work + "]";
                                    r.BorderAround(Type.Missing, Xls.XlBorderWeight.xlThin, Xls.XlColorIndex.xlColorIndexAutomatic, Type.Missing);
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            LogManager.WriteErrorLog(this, null, "テストデータ配置中に例外発生", ex);
                            MessageBox.Show(this, "テストデータ配置中に例外発生", "エラー", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                            return;
                        }
            */
        }

        /// <summary>
        /// ウルトラ処理開始
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void mnuEditUltra_Click(object sender, System.EventArgs e)
        {
            /*
                        try
                        {
                            // フォルダ選択ダイアログも現在の4画面モニタへ表示する。
                            if (DialogResult.OK == this.fldUltraSave.ShowDialog(this))
                            {
                                ComParam.IsUltraMode = true;
                                ComParam.UseUltraTemp = false;

                                switch (ComParam.ReportType)
                                {
                                    case RepType.DIALYSIS:
                                    case RepType.EQUIPMENT_LIST:
                                        break;
                                    case RepType.ONE_PATIENT:
                                        if (DialogResult.Yes == MessageBox.Show(this, "テンプレートを使用しますか？", "テンプレート使用", MessageBoxButtons.YesNo, MessageBoxIcon.Question))
                                        {
                                            ComParam.UseUltraTemp = true;
                                        }
                                        break;
                                    case RepType.MULTI_PATIENT:
                                    case RepType.DISTRIBUTE_LIST_BED:
                                    case RepType.DISTRIBUTE_LIST_EQUIPMENT:
                                    case RepType.DEVICE:
                                    case RepType.LABEL:
                                        ComParam.UseUltraTemp = true;
                                        break;
                                }

                                int backIndex = this.cmbExtCategory.SelectedIndex;
                                int count = 0;

                                for (int i = 0; i < this.cmbExtCategory.Items.Count; i++)
                                {
                                    this.cmbExtCategory.SelectedIndex = i;

                                    string work = this.cmbExtCategory.SelectedValue as string;
                                    if (string.IsNullOrEmpty(work))
                                    {
                                        continue;
                                    }
                                    else if (work.IndexOf('.') < 0)
                                    {
                                        continue;
                                    }

                                    count++;

                                    this.cmbExtCategory.SelectedIndex = i;
                                    this.Refresh();
                                    //this.ShowDataList();

                                    this.mnuEditAllAdd_Click(mnuEditAllAdd, EventArgs.Empty);

                                    if (DialogResult.Yes != this.ProcSave())
                                    {
                                        MessageBox.Show(this, "処理中にエラー", "エラー", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                                        return;
                                    }

                                    this.Refresh();


                                    string savePath;

                                    if ((ComParam.UseUltraTemp) &&
                                        (
                                        (RepType.ONE_PATIENT == ComParam.ReportType) ||
                                        (RepType.MULTI_PATIENT == ComParam.ReportType))
                                        )
                                    {
                                        ComParam.ExcelCtrl.ToolSetting = ToolSetType.DIALYSIS;
                                        savePath = fldUltraSave.SelectedPath + "\\" + StaticFunctions.RepTypeDispString(ComParam.ReportType) + "_透析日" + count.ToString("_000_") + cmbExtCategory.SelectedValue + ".xls";
                                        if (false == ComParam.ExcelCtrl.Save(savePath, false))
                                        {
                                            MessageBox.Show(this, "保存でエラー", "エラー", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                                            return;
                                        }
                                        ComParam.ExcelCtrl.ToolSetting = ToolSetType.EXAMIN;
                                        savePath = fldUltraSave.SelectedPath + "\\" + StaticFunctions.RepTypeDispString(ComParam.ReportType) + "_検査日" + count.ToString("_000_") + cmbExtCategory.SelectedValue + ".xls";
                                        if (false == ComParam.ExcelCtrl.Save(savePath, false))
                                        {
                                            MessageBox.Show(this, "保存でエラー", "エラー", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                                            return;
                                        }
                                    }
                                    else
                                    {
                                        ComParam.ExcelCtrl.ToolSetting = ToolSetType.NONE;
                                        savePath = fldUltraSave.SelectedPath + "\\" + StaticFunctions.RepTypeDispString(ComParam.ReportType) + "_単純" + count.ToString("_000_") + cmbExtCategory.SelectedValue + ".xls";
                                        if (false == ComParam.ExcelCtrl.Save(savePath, false))
                                        {
                                            MessageBox.Show(this, "保存でエラー", "エラー", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                                            return;
                                        }
                                    }

                                    ComParam.ExcelCtrl.Close();
                                    ComParam.ExcelCtrl = null;

                                    this.OpenExcel();
                                    ComParam.ExcelCtrl.IsLayoutProtected = false;
                                }

                                this.cmbExtCategory.SelectedIndex = backIndex;

                                MessageBox.Show(this, "処理が終了しました", "終了", MessageBoxButtons.OK, MessageBoxIcon.Information);
                            }
                        }
                        finally
                        {
                            ComParam.IsUltraMode = false;
                        }
            */
        }

        /// <summary>
        /// Webサーバへの接続設定編集画面表示
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void mnuHelpWebSetting_Click(object sender, System.EventArgs e)
        {
            /*
                        frmEditServerIP frm = new frmEditServerIP();

                        frm.ShowDialog(this);
            */
        }

        #endregion
        //add 8647 【デグレ】別名をつけて保存することができない zhu start
        private void MnuFileSaveAsOther_Click(object sender, EventArgs e)
        {
            try
            {
                // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 start
                if (RldLib.chkExeclDialog(1) == false)
                    return;
                // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 end

                // add #12516 項目の設定されていない帳票出力時にシステムエラーが発生する 高 start
                if (RldLib.CurrentLayoutData.DesignParamList.Count == 0)
                {
                    var wData = new RldDesignNotifyInfoRequestShowMessageEventArgs()
                    {
                        Text = RldConst.DATA_EMPTY_MESSAGE,
                        Caption = RldConst.DATA_EMPTY_CAPTION,
                        Buttons = System.Windows.Forms.MessageBoxButtons.OK,
                        Icon = System.Windows.Forms.MessageBoxIcon.Exclamation
                    };
                    base.SendNotifyInfo(this, wData);
                    return;
                }
                // add #12516 項目の設定されていない帳票出力時にシステムエラーが発生する 高 end

                // add #10230 コピーした内容がリセットされる 高 start
                frmDesignParent fdp = (frmDesignParent)this.Owner;
                List<IRldDesignColleague> m_Colleagues = fdp.m_Colleagues;
                frmDesignChildLayout fdcl = (frmDesignChildLayout)m_Colleagues[2];
                UpdateTempleteAreaImage(fdcl);
                // add #10230 コピーした内容がリセットされる 高 end
                // 名前を付けて保存して続ける
                //edit #9767 データ項目を含むセルを結合させるとパラメータ一覧とのリンクが切れる dongzhaolong start
                var wXlRange = RldLib.XlHelper.XlApp.GetSelectedCell;
                confirmPrintArea = true;
                this.SaveDropFile(true, false, DialogResult.Yes, true, wXlRange.Range.Address[false, false], confirmPrintArea);
                //edit #9767 データ項目を含むセルを結合させるとパラメータ一覧とのリンクが切れる dongzhaolong end
                // add #10108 テンプレート領域を超えた繰り返し設定が自動的に変更されるのはNG 高 start
                LoadingHelper.CloseLoadingDialog();
                // add #10108 テンプレート領域を超えた繰り返し設定が自動的に変更されるのはNG 高 end
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(this, ex, true);
            }
        }
        // add 8647 【デグレ】別名をつけて保存することができない zhu end
        private void MnuFileSaveAsReturn_Click(object sender, EventArgs e)
        {
            try
            {
                // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 start
                if (RldLib.chkExeclDialog(1) == false)
                    return;
                // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 end

                // add #12516 項目の設定されていない帳票出力時にシステムエラーが発生する 高 start
                if (RldLib.CurrentLayoutData.DesignParamList.Count == 0)
                {
                    var wData = new RldDesignNotifyInfoRequestShowMessageEventArgs()
                    {
                        Text = RldConst.DATA_EMPTY_MESSAGE,
                        Caption = RldConst.DATA_EMPTY_CAPTION,
                        Buttons = System.Windows.Forms.MessageBoxButtons.OK,
                        Icon = System.Windows.Forms.MessageBoxIcon.Exclamation
                    };
                    base.SendNotifyInfo(this, wData);
                    return;
                }
                // add #12516 項目の設定されていない帳票出力時にシステムエラーが発生する 高 end

                // 名前を付けて保存して戻る
                //edit #9767 データ項目を含むセルを結合させるとパラメータ一覧とのリンクが切れる dongzhaolong start
                var wXlRange = RldLib.XlHelper.XlApp.GetSelectedCell;
                confirmPrintArea = true;
                this.SaveDropFile(true, false, DialogResult.OK, true, wXlRange.Range.Address[false, false], confirmPrintArea);
                //edit #9767 データ項目を含むセルを結合させるとパラメータ一覧とのリンクが切れる dongzhaolong end
                // add #10108 テンプレート領域を超えた繰り返し設定が自動的に変更されるのはNG 高 end
                LoadingHelper.CloseLoadingDialog();
                // add #10108 テンプレート領域を超えた繰り返し設定が自動的に変更されるのはNG 高 end

            }
            catch (Exception ex)
            {
                RldUtility.RecordException(this, ex, true);
            }
        }
        private void MnuFileSaveAsExit_Click(object sender, EventArgs e)
        {
            try
            {
                // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 start
                if (RldLib.chkExeclDialog(1) == false)
                    return;
                // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 end

                // add #12516 項目の設定されていない帳票出力時にシステムエラーが発生する 高 start
                if (RldLib.CurrentLayoutData.DesignParamList.Count == 0)
                {
                    var wData = new RldDesignNotifyInfoRequestShowMessageEventArgs()
                    {
                        Text = RldConst.DATA_EMPTY_MESSAGE,
                        Caption = RldConst.DATA_EMPTY_CAPTION,
                        Buttons = System.Windows.Forms.MessageBoxButtons.OK,
                        Icon = System.Windows.Forms.MessageBoxIcon.Exclamation
                    };
                    base.SendNotifyInfo(this, wData);
                    return;
                }
                // add #12516 項目の設定されていない帳票出力時にシステムエラーが発生する 高 end

                // 名前を付けて保存して終了
                //edit #9767 データ項目を含むセルを結合させるとパラメータ一覧とのリンクが切れる dongzhaolong start
                var wXlRange = RldLib.XlHelper.XlApp.GetSelectedCell;
                confirmPrintArea = true;
                this.SaveDropFile(true, false, DialogResult.Cancel, true, wXlRange.Range.Address[false, false], confirmPrintArea);
                //edit #9767 データ項目を含むセルを結合させるとパラメータ一覧とのリンクが切れる dongzhaolong end
                // add #10108 テンプレート領域を超えた繰り返し設定が自動的に変更されるのはNG 高 end
                LoadingHelper.CloseLoadingDialog();
                // add #10108 テンプレート領域を超えた繰り返し設定が自動的に変更されるのはNG 高 end

            }
            catch (Exception ex)
            {
                RldUtility.RecordException(this, ex, true);
            }

        }
        private void frmDesignChildDataList_Load(object sender, EventArgs e)
        {
            try
            {

                // 新規作成の場合、名前を付けて保存メニューを非表示にする
                if (RldLib.CurrentReport.ReportCode == long.MinValue)
                {
                    // 新規作成の場合、名前を付けて保存メニューを非表示にする
                    //add 8647 【デグレ】別名をつけて保存することができない zhu start
                    this.MnuFileSaveAsOther.Visible = false;
                    //add 8647 【デグレ】別名をつけて保存することができない zhu end
                    this.MnuFileSaveAsReturn.Visible = false;
                    this.MnuFileSaveAsExit.Visible = false;
                }

            }
            catch (Exception ex)
            {
                RldUtility.RecordException(this, ex, true);
            }

        }

        // add 2020-11-02 UTバグ7の修正 マニュアル表示対応 夏 start
        private void OnMenuHelpManuaClick(Object sender, System.EventArgs e)
        {
            string docPath = System.IO.Path.Combine(AppDomain.CurrentDomain.BaseDirectory, LayoutDesignerUtility.HelpDocument);
            if (File.Exists(docPath))
                System.Diagnostics.Process.Start(docPath);
            else
                MessageBox.Show(this, "ヘルプファイルが存在しません、確認してください!");
        }


        // add 8394 動作に関する指摘 吉 start
        private void txtExtFree_PreviewKeyDown(object sender, PreviewKeyDownEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                // データ項目一覧を更新
                this.DataRead();
            }
        }
        // add 8394 動作に関する指摘 吉 end

        // add 8394 動作に関する指摘 吉 start
        private void frmDesignChildDataList_Deactivate(object sender, EventArgs e)
        {
            // del 8559 動作に関する指摘２ 邾 start
            //this.DataRead();
            // del 8559 動作に関する指摘２ 邾 end
        }

        private void frmDesignChildDataList_FormClosing(object sender, FormClosingEventArgs e)
        {
            this.Deactivate -= new System.EventHandler(this.frmDesignChildDataList_Deactivate);
        }
        //delete #8559 dongzhaolong start
        //private void txtExtFree_Leave(object sender, EventArgs e)
        //{
        //    if (canDataRead)
        //    {
        //        this.DataRead();
        //        canDataRead = false;
        //    }
        //}
        //private void txtExtFree_TextChanged_1(object sender, EventArgs e)
        //{
        //    canDataRead = true;
        //}
        //delete #8559 dongzhaolong end
        // add 8394 動作に関する指摘 吉 end
        // add 2020-11-02 UTバグ7の修正 マニュアル表示対応 夏 end

        //add 8559 zhu start
        private void dgvItemList_Scroll(object sender, ScrollEventArgs e)
        {
            if (e.NewValue > dgvItemList.SelectedRows[0].Index || dgvItemList.SelectedRows[0].Index > e.NewValue + gridCount)
            {
                if (selectItem != null)
                {
                    oldselectItem = selectItem;
                    selectItem = null;
                }
                isInRange = false;
            }
            else
            {
                if (oldselectItem != null && selectItem == null)
                {
                    selectItem = oldselectItem;
                    oldselectItem = null;
                }
                isInRange = true;
            }
        }
        //add 8559 zhu start

        //add #9767 データ項目を含むセルを結合させるとパラメータ一覧とのリンクが切れる dongzhaolong start
        /// <summary>
        /// 指定されたデータで レイアウトシートのセルの書式設定を更新します。
        /// </summary>
        /// <param name="aData"></param>
        public void UpdateLayoutSheetRangeFormatSetting(DesignParamData aData,bool isLast = false)
        {
            try
            {
                using (var wXlRange = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, aData.CellAddress))
                {
                    // add #11417 レイアウトデザイナでデータ項目フォーカスアウト時に致命的なエラー limingzhe start
                    object wValueFormat = wXlRange.Range.NumberFormatLocal;
                    string format = wValueFormat == DBNull.Value ? string.Empty : (string)wValueFormat;
                    // add #11417 レイアウトデザイナでデータ項目フォーカスアウト時に致命的なエラー limingzhe end
                    // 書式
                    if (aData.DataType != "DateTime")
                    {
                        // mod #11417 レイアウトデザイナでデータ項目フォーカスアウト時に致命的なエラー limingzhe start
                        //aData.DisplayFormat = wXlRange.Range.NumberFormatLocal;
                        aData.DisplayFormat = format;
                        // mod #11417 レイアウトデザイナでデータ項目フォーカスアウト時に致命的なエラー limingzhe end
                    }
                    else
                    {
                        // mod #11417 レイアウトデザイナでデータ項目フォーカスアウト時に致命的なエラー limingzhe start
                        //string strFormat = wXlRange.Range.NumberFormatLocal;
                        string strFormat = format;
                        // mod #11417 レイアウトデザイナでデータ項目フォーカスアウト時に致命的なエラー limingzhe end
                        
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
        private string GetDateFormat(string orgFormat, string strBasic = "[]()AYMDHMSGEPymdhmsagep:/-時間分秒年月曜日\"")
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
                    if (!(orgFormat.Substring(orgFormat.IndexOf("[") + 1, 1) == "h"))
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
        //add #9767 データ項目を含むセルを結合させるとパラメータ一覧とのリンクが切れる dongzhaolong end

        // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
        public void setCurrentFileName(string editFileName)
        {
            this.lblFileName.Text = editFileName;
        }
        // add #11501 レイアウトデザイナのユーザビリティ改善 高 end
    }
}
