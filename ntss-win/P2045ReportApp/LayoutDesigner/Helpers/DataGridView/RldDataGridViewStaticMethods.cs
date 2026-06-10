using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Windows.Forms;

namespace LayoutDesigner
{
    public static class RldDataGridViewStaticMethods
    {
        /// <summary>
        /// 指定された DataGridView の指定せるの読取専用状態を変更します。
        /// Tag データを使用して復元可能な状態で変更します。
        /// </summary>
        /// <param name="aTarget"></param>
        /// <param name="aRowIndex"></param>
        /// <param name="aColumnIndex"></param>
        /// <param name="aIsSetReadOnly">読取専用状態にする場合は True 、それ以外は False</param>
        public static void SetCellReadOnly(DataGridView aTarget, Int32 aRowIndex, Int32 aColumnIndex, Boolean aIsSetReadOnly)
        {
            try {
                // 現在のセルの状態と変更後の状態が一致する場合は抜ける
                if( aTarget.Rows[aRowIndex].Cells[aColumnIndex].ReadOnly == aIsSetReadOnly ) return;

                // 読取専用にセットする場合
                if( aIsSetReadOnly ) {
                    var wNewCell = new DataGridViewTextBoxCell();
                    wNewCell.ToolTipText = aTarget.Rows[aRowIndex].Cells[aColumnIndex].ToolTipText;
                    wNewCell.Tag = aTarget.Rows[aRowIndex].Cells[aColumnIndex];
                    aTarget.Rows[aRowIndex].Cells[aColumnIndex] = wNewCell;
                    aTarget.Rows[aRowIndex].Cells[aColumnIndex].ReadOnly = aIsSetReadOnly;
                }
                // 読取専用を解除する場合
                else {
                    if( aTarget.Rows[aRowIndex].Cells[aColumnIndex] is DataGridViewTextBoxCell wReadOnlyCell ) {
                        if( wReadOnlyCell.Tag != null && wReadOnlyCell.Tag is DataGridViewCell wRestoreCell ) {
                            aTarget.Rows[aRowIndex].Cells[aColumnIndex] = wRestoreCell;
                            aTarget.Rows[aRowIndex].Cells[aColumnIndex].ToolTipText = wRestoreCell.ToolTipText;
                            aTarget.Rows[aRowIndex].Cells[aColumnIndex].ReadOnly = false;
                        }
                        wReadOnlyCell.Dispose();
                    }
                }
            }
            catch {
                throw;
            }
        }

        /// <summary>
        /// 指定された DataGridView の指定せるの読取専用状態を変更します。
        /// Tag データを使用して復元可能な状態で変更します。
        /// </summary>
        /// <param name="aTarget"></param>
        /// <param name="aRowIndex"></param>
        /// <param name="aColumnName"></param>
        /// <param name="aIsSetReadOnly">読取専用状態にする場合は True 、それ以外は False</param>
        public static void SetCellReadOnly(DataGridView aTarget, Int32 aRowIndex, String aColumnName, Boolean aIsSetReadOnly)
        {
            RldDataGridViewStaticMethods.SetCellReadOnly(aTarget, aRowIndex, aTarget.Columns[aColumnName].Index, aIsSetReadOnly);
        }
    }
}
