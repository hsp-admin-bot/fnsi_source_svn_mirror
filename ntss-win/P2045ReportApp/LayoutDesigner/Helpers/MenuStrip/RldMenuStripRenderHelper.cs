using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace LayoutDesigner
{
    /// <summary>
    /// メニュー描画ヘルパークラス
    /// </summary>
    public class RldMenuStripRenderHelper
    {
        #region 内部クラス定義

        /// <summary>
        /// 
        /// </summary>
        protected class RldMenuStripRenderer : System.Windows.Forms.ToolStripProfessionalRenderer
        {
            #region 生成と破棄

            public RldMenuStripRenderer() : base() { }

            public RldMenuStripRenderer(System.Windows.Forms.ProfessionalColorTable aProfessionalColorTable) : base(aProfessionalColorTable) { }

            protected RldToolStripColorTable MyColorTable => base.ColorTable as RldToolStripColorTable;

            protected override void OnRenderArrow(ToolStripArrowRenderEventArgs e)
            {
                if( this.MyColorTable != null ) {
                    if( e.Item is ToolStripMenuItem wMenuItem )
                        e.ArrowColor = this.MyColorTable.ArrowColor;
                }

                base.OnRenderArrow(e);
            }

            protected override void OnRenderItemText(ToolStripItemTextRenderEventArgs e)
            {
                if( this.MyColorTable != null && e.Item is ToolStripMenuItem wMenuItem )
                    e.TextColor = this.MyColorTable.TextColor;

                base.OnRenderItemText(e);
                
            }

            #endregion
        }

        /// <summary>
        /// 
        /// </summary>
        protected class RldToolStripColorTable : System.Windows.Forms.ProfessionalColorTable
        {
            #region 生成と破棄

            public RldToolStripColorTable() : base() { }

            #endregion

            public System.Drawing.Color ArrowColor { get; set; } = System.Drawing.Color.Empty;

            public System.Drawing.Color TextColor { get; set; } = System.Drawing.Color.Empty;

            #region メンバプロパティ定義(override...)

            public override Color MenuStripGradientBegin => System.Drawing.Color.FromArgb(77, 77, 77);

            public override Color MenuStripGradientEnd => System.Drawing.Color.FromArgb(77, 77, 77);

            public override Color MenuItemSelected => System.Drawing.Color.FromArgb(77, 77, 77);

            public override Color MenuItemSelectedGradientBegin => System.Drawing.Color.FromArgb(99, 99, 99);

            public override Color MenuItemSelectedGradientEnd => System.Drawing.Color.FromArgb(99, 99, 99);

            public override Color MenuItemPressedGradientBegin => System.Drawing.Color.FromArgb(55, 55, 55);

            public override Color MenuItemPressedGradientEnd => System.Drawing.Color.FromArgb(55, 55, 55);

            public override Color MenuItemBorder => System.Drawing.Color.FromArgb(99, 99, 99);

            public override Color ToolStripDropDownBackground => System.Drawing.Color.FromArgb(55, 55, 55);

            public override Color ImageMarginGradientBegin => System.Drawing.Color.FromArgb(55, 55, 55);

            public override Color ImageMarginGradientMiddle => System.Drawing.Color.FromArgb(55, 55, 55);

            public override Color ImageMarginGradientEnd => System.Drawing.Color.FromArgb(55, 55, 55);

            // 上までOK
            



            




            #endregion
        }

        #endregion

        #region 生成と破棄

        /// <summary>
        /// 
        /// </summary>
        /// <param name="aMenuStrip"></param>
        public RldMenuStripRenderHelper(System.Windows.Forms.MenuStrip aMenuStrip)
        {
            this.MenuStrip = aMenuStrip;
        }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 
        /// </summary>
        protected System.Windows.Forms.MenuStrip MenuStrip { get; private set; } = null;

        private System.Drawing.Color ForeColorBackup { get; set; } = System.Drawing.Color.Empty;
        private System.Windows.Forms.ToolStripRenderMode RenderModeBackup { get; set; } = System.Windows.Forms.ToolStripRenderMode.ManagerRenderMode;
        private System.Windows.Forms.ToolStripRenderer RendererBackup { get; set; } = null;

        #endregion

        #region メンバ関数定義

        public void Start()
        {
            this.RenderModeBackup = this.MenuStrip.RenderMode;
            this.RendererBackup = this.MenuStrip.Renderer;
            this.MenuStrip.Renderer = new RldMenuStripRenderer(
                new RldToolStripColorTable() {
                    ArrowColor = System.Drawing.Color.White,
                    TextColor = System.Drawing.Color.White
                });

            //this.MenuStrip.ForeColor = System.Drawing.Color.White;
            //foreach( System.Windows.Forms.ToolStripMenuItem wItem in this.MenuStrip.Items )
            //    LFunc_SetMenuItemForeColorRecursive(wItem, System.Drawing.Color.White);
            
            void LFunc_SetMenuItemForeColorRecursive(System.Windows.Forms.ToolStripMenuItem aItem, System.Drawing.Color aForeColor)
            {
                foreach( System.Windows.Forms.ToolStripItem wItem in aItem.DropDownItems ) {
                    wItem.ForeColor = aForeColor;

                    if( wItem is System.Windows.Forms.ToolStripMenuItem wMenuItem && wMenuItem.HasDropDownItems )
                        LFunc_SetMenuItemForeColorRecursive(wMenuItem, aForeColor);
                }
            }
        }

        public void Stop()
        {
            this.MenuStrip.ForeColor = this.ForeColorBackup;
            this.MenuStrip.RenderMode = this.RenderModeBackup;
            this.MenuStrip.Renderer = this.RendererBackup;
        }

        #endregion

    }
}
