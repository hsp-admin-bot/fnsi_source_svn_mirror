using System;
using System.ComponentModel;
using System.Drawing;
using System.Drawing.Design;
using System.Drawing.Drawing2D;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace LayoutDesigner
{
    /// <summary>
    /// 3状態ツリーのコントロール
    /// </summary>
	public class RldTriStateTreeView : TreeView
	{
		private int indexUnchecked;
		private int indexChecked;
		private int indexIndeterminate;
		private bool useCustomImages;
		private bool preserveSelectionHighlight;
		private bool autoRefreshScrollRange;

		private const int TVS_SHOWSELALWAYS = 0x0020;
		private const int CheckboxAreaWidth = 35;
		private const int SB_HORZ = 0;
		private const uint SIF_RANGE = 0x1;
		private const uint SIF_PAGE = 0x2;
		private const uint SIF_POS = 0x4;
		private const uint SIF_ALL = SIF_RANGE | SIF_PAGE | SIF_POS;

        /// <summary>
        /// コンストラクタ
        /// </summary>
		public RldTriStateTreeView() : base() { }

		#region プロパティ

        /// <summary>
        /// 改造画像使用フラグ
        /// </summary>
		[Category( "CheckState" )]
		[DefaultValue(false)]
		public bool UseCustomImages
		{
			get { return this.useCustomImages; }
			set { this.useCustomImages = value; }
		}

        /// <summary>
        /// 選択状態の画像インデックス取得
        /// </summary>
		[Category( "CheckState" )]
		[TypeConverter(typeof(TreeViewImageIndexConverter))]
		[Editor( "System.Windows.Forms.Design.ImageIndexEditor, System.Design, Version=1.0.5000.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a", typeof(UITypeEditor))]
		[DefaultValue(0)]
		public int CheckedImageIndex
		{
			get 
			{
				if( base.ImageList == null )
					return -1;
				if( this.indexChecked >= this.ImageList.Images.Count)
					return Math.Max(0, this.ImageList.Images.Count -1 );
				return this.indexChecked;
			}
			set 
			{ 
				if( value == -1 )
					value = 0;
				if( value < 0 )
					throw new ArgumentException( string.Format( "Index out of bounds! ({0}) index must be equal to or greater then {1}.", value.ToString(), "0"));
				if( this.indexChecked != value )
				{
					this.indexChecked = value;
					if( base.IsHandleCreated)
						base.RecreateHandle();
				}
			}
		}

        /// <summary>
        /// 未選択状態の画像インデックス取得
        /// </summary>
		[Category( "CheckState" )]
		[TypeConverter(typeof(TreeViewImageIndexConverter))]
		[Editor( "System.Windows.Forms.Design.ImageIndexEditor, System.Design, Version=1.0.5000.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a", typeof(UITypeEditor))]
		[DefaultValue(0)]
		public int UncheckedImageIndex
		{
			get 
			{
				if( base.ImageList == null )
					return -1;
				if( this.indexUnchecked >= this.ImageList.Images.Count)
					return Math.Max(0, this.ImageList.Images.Count -1 );
				return this.indexUnchecked;
			}
			set 
			{ 
				if( value == -1 )
					value = 0;
				if( value < 0 )
					throw new ArgumentException( string.Format( "Index out of bounds! ({0}) index must be equal to or greater then {1}.", value.ToString(), "0"));
				if( this.indexUnchecked != value )
				{
					this.indexUnchecked = value;
					if( base.IsHandleCreated)
						base.RecreateHandle();
				}
			}
		}

        /// <summary>
        /// 中間選択状態の画像インデックス取得
        /// </summary>
		[Category( "CheckState" )]
		[TypeConverter(typeof(TreeViewImageIndexConverter))]
		[Editor( "System.Windows.Forms.Design.ImageIndexEditor, System.Design, Version=1.0.5000.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a", typeof(UITypeEditor))]
		[DefaultValue(0)]
		public int IndeterminateImageIndex
		{
			get 
			{
				if( base.ImageList == null )
					return -1;
				if( this.indexIndeterminate >= this.ImageList.Images.Count)
					return Math.Max(0, this.ImageList.Images.Count -1 );
				return this.indexIndeterminate;
			}
			set 
			{ 
				if( value == -1 )
					value = 0;
				if( value < 0 )
					throw new ArgumentException( string.Format( "Index out of bounds! ({0}) index must be equal to or greater then {1}.", value.ToString(), "0"));
				if( this.indexIndeterminate != value )
				{
					this.indexIndeterminate = value;
					if( base.IsHandleCreated)
						base.RecreateHandle();
				}
			}
		}

		/// <summary>
		/// フォーカスを失っても、選択行をフォーカス時と同じハイライト色で表示するかどうかを取得または設定します。
		/// </summary>
		[Category("Appearance")]
		[DefaultValue(false)]
		public bool PreserveSelectionHighlight
		{
			get { return this.preserveSelectionHighlight; }
			set
			{
				if (this.preserveSelectionHighlight == value) return;

				this.preserveSelectionHighlight = value;
				if (value)
					base.HideSelection = false;

				if (base.IsHandleCreated)
					base.RecreateHandle();
			}
		}

		/// <summary>
		/// ノード変更後にスクロール範囲を再計算するかどうかを取得または設定します。
		/// 長いラベルや動的なノード追加がある画面向けです。
		/// </summary>
		[Category("Behavior")]
		[DefaultValue(false)]
		public bool AutoRefreshScrollRange
		{
			get { return this.autoRefreshScrollRange; }
			set { this.autoRefreshScrollRange = value; }
		}

		#endregion

		#region 構造体定義

		[StructLayout(LayoutKind.Sequential)]
		private struct SCROLLINFO
		{
			public int cbSize;
			public uint fMask;
			public int nMin;
			public int nMax;
			public uint nPage;
			public int nPos;
			public int nTrackPos;
		}

		[StructLayout(LayoutKind.Sequential)]
		private struct RECT
		{
			internal int left;
			internal int top;
			internal int right;
			internal int bottom;

			internal RECT(int intLeft, int intTop, int intRight, int intBottom)
			{
				this.left = intLeft;
				this.top = intTop;
				this.right = intRight;
				this.bottom = intBottom;
			}
		}

		[StructLayout(LayoutKind.Sequential)]
		private struct NMHDR
		{
			internal IntPtr hwndFrom;
			internal IntPtr idFrom;
			internal int code;

			internal NMHDR(IntPtr pHwndFrom, IntPtr pIdFrom, int intCode)
			{
				this.hwndFrom = pHwndFrom;
				this.idFrom = pIdFrom;
				this.code = intCode;
			}
		}

		[StructLayout(LayoutKind.Sequential)]
		private struct NMCUSTOMDRAW
		{
			internal NMHDR hdr;
			internal int dwDrawStage;
			internal IntPtr hdc;
			internal RECT rc;
			internal IntPtr dwItemSpec;
			internal int uItemState;
			internal IntPtr lItemlParam;

			internal NMCUSTOMDRAW(NMHDR hdr, int dwDrawStage, IntPtr hdc, RECT rc, IntPtr dwItemSpec, int uItemState, IntPtr lItemlParam)
			{
				this.hdr = hdr;
				this.dwDrawStage = dwDrawStage;
				this.hdc = hdc;
				this.rc = rc;
				this.dwItemSpec = dwItemSpec;
				this.uItemState = uItemState;
				this.lItemlParam = lItemlParam;
			}
		}

		[StructLayout(LayoutKind.Sequential)]
		private struct NMTVCUSTOMDRAW
		{
			internal NMCUSTOMDRAW nmcd;
			internal int clrText;
			internal int clrTextBk;
			internal int iLevel;

			internal NMTVCUSTOMDRAW(NMCUSTOMDRAW nmcd, int clrText, int clrTextBk, int iLevel)
			{
				this.nmcd = nmcd;
				this.clrText = clrText;
				this.clrTextBk = clrTextBk;
				this.iLevel = iLevel;
			}
		}

		#endregion

		#region Win32

		[DllImport("user32.dll")]
		private static extern bool GetScrollInfo(IntPtr hwnd, int fnBar, ref SCROLLINFO lpsi);

		[DllImport("user32.dll")]
		private static extern int SetScrollInfo(IntPtr hwnd, int fnBar, ref SCROLLINFO lpsi, bool fRedraw);

		[DllImport("user32.dll", CharSet = CharSet.Auto)]
		private static extern IntPtr SendMessage(IntPtr hWnd, int msg, IntPtr wParam, IntPtr lParam);

		private const int WM_VSCROLL = 0x115;
		private const int SB_ENDSCROLL = 8;

		#endregion

		#region スクロール範囲

		/// <summary>
		/// 横・縦スクロールバーの範囲を表示内容に合わせて再計算します。
		/// </summary>
		public void RefreshScrollRange()
		{
			if (!this.IsHandleCreated || this.ClientSize.Width <= 0)
				return;

			// 横スクロール: 長いラベル幅を手動で反映
			this.ApplyScrollBar(SB_HORZ, this.GetMaxVisibleNodeWidth(), this.ClientSize.Width);

			// 縦スクロール: Win32 TreeView に範囲の再計算を促す
			SendMessage(this.Handle, WM_VSCROLL, (IntPtr)SB_ENDSCROLL, IntPtr.Zero);
		}

		private void ApplyScrollBar(int aFnBar, int aContentSize, int aPageSize)
		{
			var wSi = new SCROLLINFO();
			wSi.cbSize = Marshal.SizeOf(typeof(SCROLLINFO));
			wSi.fMask = SIF_ALL;
			GetScrollInfo(this.Handle, aFnBar, ref wSi);

			wSi.nMin = 0;
			wSi.nMax = Math.Max(0, aContentSize - 1);
			wSi.nPage = (uint)Math.Max(1, aPageSize);

			int wMaxPos = Math.Max(0, wSi.nMax - (int)wSi.nPage + 1);
			if (wSi.nPos > wMaxPos) wSi.nPos = wMaxPos;
			if (wSi.nPos < wSi.nMin) wSi.nPos = wSi.nMin;

			SetScrollInfo(this.Handle, aFnBar, ref wSi, true);
		}

		private int GetMaxVisibleNodeWidth()
		{
			int wMax = this.ClientSize.Width;
			foreach (TreeNode wNode in this.Nodes)
				this.AccumulateMaxVisibleNodeWidth(wNode, ref wMax);
			return wMax;
		}

		private void AccumulateMaxVisibleNodeWidth(TreeNode aNode, ref int aMax)
		{
			if (!aNode.IsVisible) return;

			int wWidth = CheckboxAreaWidth + (this.Indent * aNode.Level)
				+ TextRenderer.MeasureText(aNode.Text, this.Font, Size.Empty, TextFormatFlags.NoPadding).Width + 4;
			if (wWidth > aMax) aMax = wWidth;

			foreach (TreeNode wChild in aNode.Nodes)
				this.AccumulateMaxVisibleNodeWidth(wChild, ref aMax);
		}

		#endregion

		private int HandleNotify( Message msg )
		{
			const int NM_FIRST = 0;
			const int NM_CUSTOMDRAW = NM_FIRST - 12;

			const int CDDS_PREPAINT		= 0x1;
			const int CDDS_POSTPAINT	= 0x2;

			const int CDDS_ITEM				= 0x10000;
			const int CDDS_ITEMPREPAINT		= ( CDDS_ITEM | CDDS_PREPAINT );
			const int CDDS_ITEMPOSTPAINT	= ( CDDS_ITEM | CDDS_POSTPAINT );

			const int CDRF_DODEFAULT		= 0x0;
			const int CDRF_NOTIFYPOSTPAINT	= 0x10;
			const int CDRF_NOTIFYITEMDRAW	= 0x20;
			const int CDIS_SELECTED			= 0x0001;

			NMHDR tNMHDR;
			NMTVCUSTOMDRAW tNMTVCUSTOMDRAW;
			int iResult = 0;
			object obj;
			TreeNode node;
			RldTriStateTreeNode tsNode;

			try
			{
				if( !msg.LParam.Equals( IntPtr.Zero ))
				{
					obj = msg.GetLParam( typeof(NMHDR) );
					if( obj is NMHDR )
					{
						tNMHDR = (NMHDR)obj;
						if( tNMHDR.code == NM_CUSTOMDRAW )
						{
							obj = msg.GetLParam( typeof(NMTVCUSTOMDRAW));
							if( obj is NMTVCUSTOMDRAW)
							{
								tNMTVCUSTOMDRAW = (NMTVCUSTOMDRAW)obj;
								switch( tNMTVCUSTOMDRAW.nmcd.dwDrawStage )
								{
									case CDDS_PREPAINT:
										iResult = CDRF_NOTIFYITEMDRAW;
										break;
									case CDDS_ITEMPREPAINT:
										if (this.preserveSelectionHighlight
											&& (tNMTVCUSTOMDRAW.nmcd.uItemState & CDIS_SELECTED) != 0)
										{
											tNMTVCUSTOMDRAW.clrTextBk = ColorTranslator.ToWin32(SystemColors.Highlight);
											tNMTVCUSTOMDRAW.clrText = ColorTranslator.ToWin32(SystemColors.HighlightText);
											Marshal.StructureToPtr(tNMTVCUSTOMDRAW, msg.LParam, false);
										}
										iResult = CDRF_NOTIFYPOSTPAINT;
										break;
									case CDDS_ITEMPOSTPAINT:
										node = TreeNode.FromHandle( this, tNMTVCUSTOMDRAW.nmcd.dwItemSpec );
										tsNode = node as RldTriStateTreeNode;
										if( tsNode != null )
										{
											Graphics graph = Graphics.FromHdc( tNMTVCUSTOMDRAW.nmcd.hdc);
											PaintTreeNode( tsNode, graph );
											graph.Dispose();
										}
										iResult = CDRF_DODEFAULT;
										break;
								}
							}
						}
					}
				}
			}
			catch(Exception ex)
			{
				MessageBox.Show( ex.Message );
			}

			return iResult;
		}

		/// <summary>
		/// ツリーノードを描画
		/// </summary>
		/// <param name="node">ノード</param>
		/// <param name="gx">グラフィックス</param>
		private void PaintTreeNode( RldTriStateTreeNode node, Graphics gx )
		{
			if( this.CheckBoxes )
			{
				// 描画エリアを算出
				Rectangle ncRect = new Rectangle( node.Bounds.X - 35, node.Bounds.Y, 15, 15 );

				// 描画エリアをクリア
				ClearCheckbox( ncRect, gx );

				if( this.ShowLines )
				{
					//	罫線表示設定の場合は罫線を描画
					DrawNodeLines( node, ncRect, gx );
				}

				if( node.CheckboxVisible )
				{
					// チェックボックス描画
					switch( node.CheckState )
					{
						case CheckState.Unchecked:			// 未選択
							DrawCheckbox( ncRect, gx, ButtonState.Normal | ButtonState.Flat );
							break;
						case CheckState.Checked:			// 選択
							DrawCheckbox( ncRect, gx, ButtonState.Checked | ButtonState.Flat );
							break;
						case CheckState.Indeterminate:		// 中間
							DrawCheckbox( ncRect, gx, ButtonState.Pushed | ButtonState.Flat );
							break;
					}
				}
			}
		}

		/// <summary>
		/// チェックボックスを背景色でクリアする
		/// </summary>
		/// <param name="bounds">領域</param>
		/// <param name="gx">グラフィックス</param>
		private void ClearCheckbox( Rectangle bounds, Graphics gx )
		{
			// make sure the default checkboxes are gone.
			using( Brush brush = new SolidBrush( this.BackColor ))
			{
				gx.FillRectangle( brush, bounds );
			}
		}

		/// <summary>
		/// 罫線を描画する
		/// </summary>
        /// <param name="node">ツリーのノード</param>
        /// <param name="bounds">罫線のサイズ</param>
		/// <param name="gx">グラフィックス</param>
		private void DrawNodeLines( RldTriStateTreeNode node, Rectangle bounds, Graphics gx )
		{
			NodeLineType lineType = node.NodeLineType;
			if( lineType == NodeLineType.None ) { return; }

			using( Pen pen = new Pen( SystemColors.ControlDark, 1 ))
			{
				pen.DashStyle = DashStyle.Dot;

				gx.DrawLine( pen, new Point( bounds.X, bounds.Y + 8), new Point( bounds.X + 15, bounds.Y + 8 ));
				if( lineType == NodeLineType.WithChildren && node.IsExpanded )
				{
					gx.DrawLine( pen, new Point( bounds.X + 8, bounds.Y + 8 ), new Point( bounds.X + 8, bounds.Y + 16 ));
				}
			}
		}

		/// <summary>
		/// チェックボックスを描画する
		/// </summary>
		/// <param name="bounds">チェックボックスの描画領域</param>
		/// <param name="gx">グラフィックス</param>
		/// <param name="buttonState">チェック状態</param>
		private void DrawCheckbox( Rectangle bounds, Graphics gx, ButtonState buttonState )
		{
			if ( !this.useCustomImages || ( this.useCustomImages && null == this.ImageList ))
			{
				ControlPaint.DrawMixedCheckBox( gx, bounds, buttonState );
				return;
			}
			
			int imageIndex = -1;
			if ((buttonState & ButtonState.Normal) == ButtonState.Normal)
				imageIndex = this.indexUnchecked;
			if ((buttonState & ButtonState.Checked) == ButtonState.Checked)
				imageIndex = this.indexChecked;
			if (( buttonState & ButtonState.Pushed) == ButtonState.Pushed)
				imageIndex = this.indexIndeterminate;
			
			if( imageIndex > -1 && imageIndex < this.ImageList.Images.Count )
			{
				//	イメージを描画
				this.ImageList.Draw( gx, bounds.X, bounds.Y, bounds.Width + 1 , bounds.Height + 1, imageIndex );
			}
			else
			{
				ControlPaint.DrawMixedCheckBox( gx, bounds, buttonState );
			}
		}

		/// <summary>
		/// コントロールの作成時に渡すパラメータを取得します。
		/// </summary>
		protected override CreateParams CreateParams
		{
			get
			{
				CreateParams wCp = base.CreateParams;
				if (this.preserveSelectionHighlight)
					wCp.Style |= TVS_SHOWSELALWAYS;
				return wCp;
			}
		}

		/// <summary>
		/// ウィンドウプロシージャ
		/// </summary>
		/// <param name="m"></param>
		protected override void WndProc(ref Message m)
		{
			const int WM_NOTIFY = 0x4E;
			
			int iResult = 0;
			bool bHandled = false;

			if( m.Msg == (0x2000 | WM_NOTIFY))
			{
				if( m.WParam.Equals( this.Handle ))
				{
					iResult = HandleNotify(m);
					m.Result = new IntPtr( iResult );
					bHandled = ( iResult != 0 );
				}
			}

			if( !bHandled )
				base.WndProc (ref m);
		}

		/// <summary>
		/// EndUpdate 後にスクロール範囲を更新します。
		/// </summary>
		public new void EndUpdate()
		{
			base.EndUpdate();
			if (this.autoRefreshScrollRange)
				this.RefreshScrollRange();
		}

		/// <summary>
		/// リサイズ後にスクロール範囲を更新します。
		/// </summary>
		/// <param name="e"></param>
		protected override void OnResize(EventArgs e)
		{
			base.OnResize(e);
			if (this.autoRefreshScrollRange)
				this.RefreshScrollRange();
		}

		/// <summary>
		/// ノード展開後にスクロール範囲を更新します。
		/// </summary>
		/// <param name="e"></param>
		protected override void OnAfterExpand(TreeViewEventArgs e)
		{
			base.OnAfterExpand(e);
			if (this.autoRefreshScrollRange)
				this.RefreshScrollRange();
		}

		/// <summary>
		/// ノード折りたたみ後にスクロール範囲を更新します。
		/// </summary>
		/// <param name="e"></param>
		protected override void OnAfterCollapse(TreeViewEventArgs e)
		{
			base.OnAfterCollapse(e);
			if (this.autoRefreshScrollRange)
				this.RefreshScrollRange();
		}

		/// <summary>
		/// AfterClickオーバーライド
		/// </summary>
		/// <param name="e"></param>
		protected override void OnAfterCheck(TreeViewEventArgs e)
		{
			TreeNode node = e.Node;
			if( node != null )
			{
				RldTriStateTreeNode clickedNode = node as RldTriStateTreeNode;
				if( clickedNode.CheckboxVisible )
				{
					ToggleNodeState( clickedNode );
				}
			}

            base.OnAfterCheck(e);

        }

        /// <summary>
        /// 選択後の処理(？)
        /// </summary>
        /// <param name="e"></param>
		protected override void OnAfterSelect(TreeViewEventArgs e)
		{
			base.OnAfterSelect (e);
		}

		private void ToggleNodeState( RldTriStateTreeNode node )
		{
			if( null == node ) return;

			CheckState nextState;
			switch( node.CheckState )
			{
				case CheckState.Unchecked:
					nextState = CheckState.Checked;
					break;
				default:
					nextState = CheckState.Unchecked;
					break;
			}

			BeginUpdate();

			node.SetCheckedState( nextState );

			EndUpdate();
		}
	}
}
