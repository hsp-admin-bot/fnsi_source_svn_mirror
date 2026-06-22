using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Windows.Forms;

namespace LayoutDesigner
{
    /// <summary>
    /// DataGridView 選択状態描画クラス
    /// </summary>
    public class RldDataGridViewSelectionRenderer
    {
        #region 生成と破棄

        public RldDataGridViewSelectionRenderer(DataGridView aTarget)
        {
            // TODO: 作成中

            // イベントハンドラ割り当て
            //aTarget.SelectionChanged += new EventHandler(this.aTarget_SelectionChanged);
            //aTarget.CellEnter += new DataGridViewCellEventHandler(this.aTarget_CellEnter);

            //aTarget.CellPainting += ATarget_CellPainting;
            //aTarget.CellFormatting += ATarget_CellFormatting;

        }

        private void ATarget_CellFormatting(object sender, DataGridViewCellFormattingEventArgs e)
        {
            var wTarget = sender as DataGridView;

            if( wTarget.CurrentCell == null ) return;

            if( e.RowIndex == wTarget.CurrentCell.RowIndex && e.ColumnIndex == wTarget.CurrentCell.ColumnIndex )
                e.CellStyle.SelectionBackColor = wTarget.DefaultCellStyle.BackColor;
            else
                e.CellStyle.SelectionBackColor = wTarget.DefaultCellStyle.SelectionBackColor;

    //        If uxContacts.CurrentCell IsNot Nothing Then
    //    If e.RowIndex = uxContacts.CurrentCell.RowIndex And e.ColumnIndex = uxContacts.CurrentCell.ColumnIndex Then
    //        e.CellStyle.SelectionBackColor = Color.SteelBlue
    //    Else
    //        e.CellStyle.SelectionBackColor = uxContacts.DefaultCellStyle.SelectionBackColor
    //    End If
    //End If



        }

        private void ATarget_CellPainting(object sender, DataGridViewCellPaintingEventArgs e)
        {
            // ヘッダは対象外
            if( e.RowIndex < 0 || e.ColumnIndex < 0 ) return;

            var wTarget = sender as DataGridView;

            if( (e.PaintParts & DataGridViewPaintParts.SelectionBackground) == DataGridViewPaintParts.SelectionBackground ) {
                
            }


        }

        private void ATarget_RowPostPaint(object sender, DataGridViewRowPostPaintEventArgs e)
        {
            throw new NotImplementedException();
            
        }

        #endregion

        #region カスタムイベントハンドラ定義

        private void aTarget_CellEnter(object sender, DataGridViewCellEventArgs e)
        {
            


            
        }

        /// <summary>
        /// 制御対象コントロールの SelectionChanged イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void aTarget_SelectionChanged(object sender, EventArgs e)
        {
            var wTarget = sender as DataGridView;
            if( wTarget.CurrentCell == null ) return;

            Int32 wRowIndex = wTarget.CurrentCell.RowIndex, wColIndex = wTarget.CurrentCell.ColumnIndex;

            wTarget[0, wRowIndex].Style.BackColor = System.Drawing.Color.Empty;

            //wTarget.Rows[wRowIndex].InheritedStyle.BackColor = System.Drawing.Color.Red;
            //wTarget.CurrentCell.InheritedStyle.BackColor = wTarget.CurrentCell.Style.BackColor;
        }

        #endregion
    }
}
