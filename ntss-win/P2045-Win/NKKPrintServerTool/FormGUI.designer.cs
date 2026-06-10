namespace NKKPrintServerTool
{
    partial class FormGUI
    {
        /// <summary>
        /// 必要なデザイナ変数です。
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// 使用中のリソースをすべてクリーンアップします。
        /// </summary>
        /// <param name="disposing">マネージ リソースが破棄される場合 true、破棄されない場合は false です。</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows フォーム デザイナで生成されたコード

        /// <summary>
        /// デザイナ サポートに必要なメソッドです。このメソッドの内容を
        /// コード エディタで変更しないでください。
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            System.Windows.Forms.ListViewItem listViewItem1 = new System.Windows.Forms.ListViewItem(new string[] {
            "Server処理",
            "未接続",
            "",
            ""}, -1);
            System.Windows.Forms.ListViewItem listViewItem2 = new System.Windows.Forms.ListViewItem(new string[] {
            "WebSocket",
            "未接続",
            "",
            ""}, -1);
            this.listView = new System.Windows.Forms.ListView();
            this.columnHeaderClass = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.columnHeaderState = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.columnHeaderUpdate = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.columnHeaderMessage = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.contextMenuStrip_ListView = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.toolStripMenuItem_Copy = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripSeparator1 = new System.Windows.Forms.ToolStripSeparator();
            this.toolStripMenuItem_Exit2 = new System.Windows.Forms.ToolStripMenuItem();
            this.notifyIcon = new System.Windows.Forms.NotifyIcon(this.components);
            this.contextMenuStrip = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.toolStripMenuItem_View = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItem_Exit = new System.Windows.Forms.ToolStripMenuItem();
            this.menuStrip1 = new System.Windows.Forms.MenuStrip();
            this.ManageToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.MnuPostPrinter = new System.Windows.Forms.ToolStripMenuItem();
            this.MnuUpdatePrinter = new System.Windows.Forms.ToolStripMenuItem();
            this.MnuDeletePrinter = new System.Windows.Forms.ToolStripMenuItem();
            this.contextMenuStrip_ListView.SuspendLayout();
            this.contextMenuStrip.SuspendLayout();
            this.menuStrip1.SuspendLayout();
            this.SuspendLayout();
            // 
            // listView
            // 
            this.listView.Columns.AddRange(new System.Windows.Forms.ColumnHeader[] {
            this.columnHeaderClass,
            this.columnHeaderState,
            this.columnHeaderUpdate,
            this.columnHeaderMessage});
            this.listView.ContextMenuStrip = this.contextMenuStrip_ListView;
            this.listView.Dock = System.Windows.Forms.DockStyle.Fill;
            this.listView.FullRowSelect = true;
            this.listView.GridLines = true;
            this.listView.HeaderStyle = System.Windows.Forms.ColumnHeaderStyle.Nonclickable;
            this.listView.HideSelection = false;
            this.listView.Items.AddRange(new System.Windows.Forms.ListViewItem[] {
            listViewItem1,
            listViewItem2});
            this.listView.Location = new System.Drawing.Point(0, 24);
            this.listView.Name = "listView";
            this.listView.ShowGroups = false;
            this.listView.Size = new System.Drawing.Size(679, 109);
            this.listView.TabIndex = 1;
            this.listView.UseCompatibleStateImageBehavior = false;
            this.listView.View = System.Windows.Forms.View.Details;
            // 
            // columnHeaderClass
            // 
            this.columnHeaderClass.Text = "区分";
            this.columnHeaderClass.Width = 80;
            // 
            // columnHeaderState
            // 
            this.columnHeaderState.Text = "状態";
            this.columnHeaderState.Width = 120;
            // 
            // columnHeaderUpdate
            // 
            this.columnHeaderUpdate.Text = "更新日時";
            this.columnHeaderUpdate.Width = 150;
            // 
            // columnHeaderMessage
            // 
            this.columnHeaderMessage.Text = "内容";
            this.columnHeaderMessage.Width = 300;
            // 
            // contextMenuStrip_ListView
            // 
            this.contextMenuStrip_ListView.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripMenuItem_Copy,
            this.toolStripSeparator1,
            this.toolStripMenuItem_Exit2});
            this.contextMenuStrip_ListView.Name = "contextMenuStrip";
            this.contextMenuStrip_ListView.Size = new System.Drawing.Size(148, 54);
            // 
            // toolStripMenuItem_Copy
            // 
            this.toolStripMenuItem_Copy.Name = "toolStripMenuItem_Copy";
            this.toolStripMenuItem_Copy.Size = new System.Drawing.Size(147, 22);
            this.toolStripMenuItem_Copy.Text = "選択項目コピー";
            this.toolStripMenuItem_Copy.Click += new System.EventHandler(this.ToolStripMenuItem_Copy_Click);
            // 
            // toolStripSeparator1
            // 
            this.toolStripSeparator1.Name = "toolStripSeparator1";
            this.toolStripSeparator1.Size = new System.Drawing.Size(144, 6);
            // 
            // toolStripMenuItem_Exit2
            // 
            this.toolStripMenuItem_Exit2.Name = "toolStripMenuItem_Exit2";
            this.toolStripMenuItem_Exit2.Size = new System.Drawing.Size(147, 22);
            this.toolStripMenuItem_Exit2.Text = "終了";
            this.toolStripMenuItem_Exit2.Click += new System.EventHandler(this.ToolStripMenuItem_Exit_Click);
            // 
            // notifyIcon
            // 
            this.notifyIcon.BalloonTipText = "印刷サーバーアプリ停止中";
            this.notifyIcon.ContextMenuStrip = this.contextMenuStrip;
            this.notifyIcon.Text = "印刷サーバーアプリ停止中";
            this.notifyIcon.Visible = true;
            // 
            // contextMenuStrip
            // 
            this.contextMenuStrip.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripMenuItem_View,
            this.toolStripMenuItem_Exit});
            this.contextMenuStrip.Name = "contextMenuStrip";
            this.contextMenuStrip.Size = new System.Drawing.Size(123, 48);
            // 
            // toolStripMenuItem_View
            // 
            this.toolStripMenuItem_View.Name = "toolStripMenuItem_View";
            this.toolStripMenuItem_View.Size = new System.Drawing.Size(122, 22);
            this.toolStripMenuItem_View.Text = "画面表示";
            this.toolStripMenuItem_View.Click += new System.EventHandler(this.ToolStripMenuItem_View_Click);
            // 
            // toolStripMenuItem_Exit
            // 
            this.toolStripMenuItem_Exit.Name = "toolStripMenuItem_Exit";
            this.toolStripMenuItem_Exit.Size = new System.Drawing.Size(122, 22);
            this.toolStripMenuItem_Exit.Text = "終了";
            this.toolStripMenuItem_Exit.Click += new System.EventHandler(this.ToolStripMenuItem_Exit_Click);
            // 
            // menuStrip1
            // 
            this.menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.ManageToolStripMenuItem});
            this.menuStrip1.Location = new System.Drawing.Point(0, 0);
            this.menuStrip1.Name = "menuStrip1";
            this.menuStrip1.Size = new System.Drawing.Size(679, 24);
            this.menuStrip1.TabIndex = 2;
            this.menuStrip1.Text = "menuStrip1";
            // 
            // ManageToolStripMenuItem
            // 
            this.ManageToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.MnuPostPrinter,
            this.MnuUpdatePrinter,
            this.MnuDeletePrinter});
            this.ManageToolStripMenuItem.Name = "ManageToolStripMenuItem";
            this.ManageToolStripMenuItem.Size = new System.Drawing.Size(43, 20);
            this.ManageToolStripMenuItem.Text = "管理";
            // 
            // MnuPostPrinter
            // 
            this.MnuPostPrinter.Enabled = false;
            this.MnuPostPrinter.Name = "MnuPostPrinter";
            this.MnuPostPrinter.Size = new System.Drawing.Size(180, 22);
            this.MnuPostPrinter.Text = "プリンター登録";
            this.MnuPostPrinter.Click += new System.EventHandler(this.MnuPostPrinter_Click);
            // 
            // MnuUpdatePrinter
            // 
            this.MnuUpdatePrinter.Enabled = false;
            this.MnuUpdatePrinter.Name = "MnuUpdatePrinter";
            this.MnuUpdatePrinter.Size = new System.Drawing.Size(180, 22);
            this.MnuUpdatePrinter.Text = "プリンター更新";
            this.MnuUpdatePrinter.Click += new System.EventHandler(this.ToolStripMenuItem_Click);
            // 
            // MnuDeletePrinter
            // 
            this.MnuDeletePrinter.Name = "MnuDeletePrinter";
            this.MnuDeletePrinter.Size = new System.Drawing.Size(180, 22);
            this.MnuDeletePrinter.Text = "プリンター削除";
            this.MnuDeletePrinter.Click += new System.EventHandler(this.MnuDeletePrinter_Click);
            // 
            // FormGUI
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(679, 133);
            this.Controls.Add(this.listView);
            this.Controls.Add(this.menuStrip1);
            this.MaximizeBox = false;
            this.MinimumSize = new System.Drawing.Size(180, 150);
            this.Name = "FormGUI";
            this.Text = "NKKWeight GUI";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.Form1_FormClosing);
            this.Shown += new System.EventHandler(this.FormViewLog_Shown);
            this.contextMenuStrip_ListView.ResumeLayout(false);
            this.contextMenuStrip.ResumeLayout(false);
            this.menuStrip1.ResumeLayout(false);
            this.menuStrip1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.ListView listView;
        private System.Windows.Forms.NotifyIcon notifyIcon;
        private System.Windows.Forms.ContextMenuStrip contextMenuStrip;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItem_View;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItem_Exit;
        private System.Windows.Forms.ColumnHeader columnHeaderUpdate;
        private System.Windows.Forms.ColumnHeader columnHeaderMessage;
        private System.Windows.Forms.ContextMenuStrip contextMenuStrip_ListView;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItem_Copy;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator1;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItem_Exit2;
        private System.Windows.Forms.ColumnHeader columnHeaderClass;
        private System.Windows.Forms.ColumnHeader columnHeaderState;
        private System.Windows.Forms.MenuStrip menuStrip1;
        private System.Windows.Forms.ToolStripMenuItem ManageToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem MnuPostPrinter;
        // add 2020-09-29 FNSI-仕様追加 印刷アプリを複数登録する 黄 start
        private System.Windows.Forms.ToolStripMenuItem MnuUpdatePrinter;
        private System.Windows.Forms.ToolStripMenuItem MnuDeletePrinter;
        // add 2020-09-29 FNSI-仕様追加 印刷アプリを複数登録する 黄 end
    }
}

