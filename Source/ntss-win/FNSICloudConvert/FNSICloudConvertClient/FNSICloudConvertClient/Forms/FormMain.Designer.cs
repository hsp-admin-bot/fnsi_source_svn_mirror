namespace FNSICloudConvertClient.Forms
{
    partial class FormMain
    {
        private System.ComponentModel.IContainer components = null;

        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
                components.Dispose();
            base.Dispose(disposing);
        }

        private void InitializeComponent()
        {
            // ============================================================
            // 最上部: 施設情報バー
            // ============================================================
            this.pnlFacilityBar    = new System.Windows.Forms.Panel();
            this.lblFacilities     = new System.Windows.Forms.Label();
            this.btnChangeFacility = new System.Windows.Forms.Button();
            // ============================================================
            // 上部: 設定表示 GroupBox（読み取り専用・左右分割）
            // ============================================================
            this.grpSettings           = new System.Windows.Forms.GroupBox();
            this.btnSettings           = new System.Windows.Forms.Button();
            this.splitSettings         = new System.Windows.Forms.SplitContainer();
            // 左: オンプレ側
            this.lblOnpreSettingsTitle = new System.Windows.Forms.Label();
            this.pnlSepOnpre           = new System.Windows.Forms.Panel();
            this.lblRdbIpCaption       = new System.Windows.Forms.Label();
            this.lblRdbIpValue         = new System.Windows.Forms.Label();
            this.lblMongoIpCaption     = new System.Windows.Forms.Label();
            this.lblMongoIpValue       = new System.Windows.Forms.Label();
            this.lblFnsiCaption        = new System.Windows.Forms.Label();
            this.lblFnsiValue          = new System.Windows.Forms.Label();
            this.lblOnpreTmpCaption    = new System.Windows.Forms.Label();
            this.lblOnpreTmpValue      = new System.Windows.Forms.Label();
            // 右: クラウド側
            this.lblCloudSettingsTitle = new System.Windows.Forms.Label();
            this.pnlSepCloud           = new System.Windows.Forms.Panel();
            this.lblCloudTmpCaption    = new System.Windows.Forms.Label();
            this.lblCloudTmpValue      = new System.Windows.Forms.Label();
            this.lblCloudDbCaption     = new System.Windows.Forms.Label();
            this.lblCloudDbValue       = new System.Windows.Forms.Label();
            // ============================================================
            // 中部: 状態表示（上段）+ 操作ボタン（下段）
            // ============================================================
            this.pnlMiddle    = new System.Windows.Forms.Panel();
            this.pnlStatusRow = new System.Windows.Forms.Panel();
            this.lblMode      = new System.Windows.Forms.Label();
            this.lblModeValue = new System.Windows.Forms.Label();
            this.lblStatus    = new System.Windows.Forms.Label();
            this.pnlSepMid    = new System.Windows.Forms.Panel();
            this.btnStart     = new System.Windows.Forms.Button();
            this.btnLanLeft   = new System.Windows.Forms.Button();
            this.btnLanRight  = new System.Windows.Forms.Button();
            this.btnStop      = new System.Windows.Forms.Button();
            // ============================================================
            // 下部: 左右分割（オンプレ / クラウド）
            // ============================================================
            this.splitBottom        = new System.Windows.Forms.SplitContainer();
            this.splitOnpre         = new System.Windows.Forms.SplitContainer();
            this.lblOnpreCountTitle = new System.Windows.Forms.Label();
            this.lblOnpreCount      = new System.Windows.Forms.Label();
            this.lblPgTitle         = new System.Windows.Forms.Label();
            this.pbPostgres         = new ProgressBarEx();
            this.rtbPgLog           = new System.Windows.Forms.RichTextBox();
            this.splitCloud         = new System.Windows.Forms.SplitContainer();
            this.lblCloudCountTitle = new System.Windows.Forms.Label();
            this.lblCloudCount      = new System.Windows.Forms.Label();
            this.lblMongoTitle      = new System.Windows.Forms.Label();
            this.pbMongo            = new ProgressBarEx();
            this.rtbMongoLog        = new System.Windows.Forms.RichTextBox();

            this.pnlFacilityBar.SuspendLayout();
            this.grpSettings.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitSettings)).BeginInit();
            this.splitSettings.Panel1.SuspendLayout();
            this.splitSettings.Panel2.SuspendLayout();
            this.pnlMiddle.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitBottom)).BeginInit();
            this.splitBottom.Panel1.SuspendLayout();
            this.splitBottom.Panel2.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitOnpre)).BeginInit();
            this.splitOnpre.Panel1.SuspendLayout();
            this.splitOnpre.Panel2.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitCloud)).BeginInit();
            this.splitCloud.Panel1.SuspendLayout();
            this.splitCloud.Panel2.SuspendLayout();
            this.SuspendLayout();

            // ==============================================================
            // pnlFacilityBar
            // ==============================================================
            this.pnlFacilityBar.Location    = new System.Drawing.Point(5, 5);
            this.pnlFacilityBar.Size        = new System.Drawing.Size(970, 34);
            this.pnlFacilityBar.BackColor   = System.Drawing.Color.FromArgb(232, 240, 255);
            this.pnlFacilityBar.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.pnlFacilityBar.Anchor      = System.Windows.Forms.AnchorStyles.Left
                                            | System.Windows.Forms.AnchorStyles.Right
                                            | System.Windows.Forms.AnchorStyles.Top;
            this.pnlFacilityBar.Controls.Add(this.lblFacilities);
            this.pnlFacilityBar.Controls.Add(this.btnChangeFacility);

            this.lblFacilities.AutoSize  = false;
            this.lblFacilities.Location  = new System.Drawing.Point(8, 7);
            this.lblFacilities.Size      = new System.Drawing.Size(840, 20);
            this.lblFacilities.Text      = "対象施設: ---";
            this.lblFacilities.Font      = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Bold);
            this.lblFacilities.ForeColor = System.Drawing.Color.FromArgb(30, 80, 160);
            this.lblFacilities.Anchor    = System.Windows.Forms.AnchorStyles.Left
                                         | System.Windows.Forms.AnchorStyles.Right
                                         | System.Windows.Forms.AnchorStyles.Top;

            this.btnChangeFacility.Location  = new System.Drawing.Point(862, 5);
            this.btnChangeFacility.Size      = new System.Drawing.Size(96, 24);
            this.btnChangeFacility.Text      = "施設変更...";
            this.btnChangeFacility.Font      = new System.Drawing.Font("MS UI Gothic", 8F);
            this.btnChangeFacility.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnChangeFacility.Anchor    = System.Windows.Forms.AnchorStyles.Right
                                             | System.Windows.Forms.AnchorStyles.Top;
            this.btnChangeFacility.Click    += new System.EventHandler(this.btnChangeFacility_Click);

            // ==============================================================
            // grpSettings（設定表示グループ）
            // キャプション左・値右の横並び、4行 + タイトル + セパレータ
            // ==============================================================
            this.grpSettings.Location = new System.Drawing.Point(5, 44);
            this.grpSettings.Size     = new System.Drawing.Size(970, 138);
            this.grpSettings.Text     = "設定";
            this.grpSettings.Font     = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Bold);
            this.grpSettings.Anchor   = System.Windows.Forms.AnchorStyles.Left
                                      | System.Windows.Forms.AnchorStyles.Right
                                      | System.Windows.Forms.AnchorStyles.Top;
            this.grpSettings.Controls.Add(this.btnSettings);
            this.grpSettings.Controls.Add(this.splitSettings);

            this.btnSettings.Location  = new System.Drawing.Point(878, 14);
            this.btnSettings.Size      = new System.Drawing.Size(80, 22);
            this.btnSettings.Text      = "設定...";
            this.btnSettings.Font      = new System.Drawing.Font("MS UI Gothic", 8F);
            this.btnSettings.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnSettings.Anchor    = System.Windows.Forms.AnchorStyles.Right
                                       | System.Windows.Forms.AnchorStyles.Top;
            this.btnSettings.Click    += new System.EventHandler(this.btnSettings_Click);

            // splitSettings（設定左右分割）
            this.splitSettings.Location         = new System.Drawing.Point(8, 22);
            this.splitSettings.Size             = new System.Drawing.Size(954, 110);
            this.splitSettings.Anchor           = System.Windows.Forms.AnchorStyles.Left
                                                | System.Windows.Forms.AnchorStyles.Right
                                                | System.Windows.Forms.AnchorStyles.Top;
            this.splitSettings.Orientation      = System.Windows.Forms.Orientation.Vertical;
            this.splitSettings.SplitterDistance = 470;
            this.splitSettings.SplitterWidth    = 4;
            this.splitSettings.TabStop          = false;

            // --------------------------------------------------
            // Panel1: オンプレ側（キャプション左・値右）
            // --------------------------------------------------
            this.splitSettings.Panel1.Controls.Add(this.lblOnpreSettingsTitle);
            this.splitSettings.Panel1.Controls.Add(this.pnlSepOnpre);
            this.splitSettings.Panel1.Controls.Add(this.lblRdbIpCaption);
            this.splitSettings.Panel1.Controls.Add(this.lblRdbIpValue);
            this.splitSettings.Panel1.Controls.Add(this.lblMongoIpCaption);
            this.splitSettings.Panel1.Controls.Add(this.lblMongoIpValue);
            this.splitSettings.Panel1.Controls.Add(this.lblFnsiCaption);
            this.splitSettings.Panel1.Controls.Add(this.lblFnsiValue);
            this.splitSettings.Panel1.Controls.Add(this.lblOnpreTmpCaption);
            this.splitSettings.Panel1.Controls.Add(this.lblOnpreTmpValue);

            this.lblOnpreSettingsTitle.AutoSize  = false;
            this.lblOnpreSettingsTitle.Location  = new System.Drawing.Point(4, 3);
            this.lblOnpreSettingsTitle.Size      = new System.Drawing.Size(120, 16);
            this.lblOnpreSettingsTitle.Text      = "オンプレ側";
            this.lblOnpreSettingsTitle.Font      = new System.Drawing.Font("MS UI Gothic", 8F, System.Drawing.FontStyle.Bold);
            this.lblOnpreSettingsTitle.ForeColor = System.Drawing.Color.FromArgb(60, 60, 60);

            this.pnlSepOnpre.Location  = new System.Drawing.Point(0, 20);
            this.pnlSepOnpre.Size      = new System.Drawing.Size(2000, 1);
            this.pnlSepOnpre.BackColor = System.Drawing.Color.FromArgb(200, 200, 200);
            this.pnlSepOnpre.Anchor    = System.Windows.Forms.AnchorStyles.Left
                                       | System.Windows.Forms.AnchorStyles.Right
                                       | System.Windows.Forms.AnchorStyles.Top;

            // ---- 共通: キャプション幅 = 170px、値 x = 174 ----
            // 行1: RDB IPアドレス  (y=24)
            this.lblRdbIpCaption.AutoSize  = false;
            this.lblRdbIpCaption.Location  = new System.Drawing.Point(4, 24);
            this.lblRdbIpCaption.Size      = new System.Drawing.Size(168, 18);
            this.lblRdbIpCaption.Text      = "RDB IPアドレス:";
            this.lblRdbIpCaption.Font      = new System.Drawing.Font("MS UI Gothic", 8F);
            this.lblRdbIpCaption.ForeColor = System.Drawing.Color.FromArgb(80, 80, 80);
            this.lblRdbIpCaption.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;

            this.lblRdbIpValue.AutoSize    = false;
            this.lblRdbIpValue.Location    = new System.Drawing.Point(174, 24);
            this.lblRdbIpValue.Size        = new System.Drawing.Size(280, 18);
            this.lblRdbIpValue.Text        = "---";
            this.lblRdbIpValue.Font        = new System.Drawing.Font("MS UI Gothic", 9F);
            this.lblRdbIpValue.ForeColor   = System.Drawing.Color.FromArgb(0, 80, 160);
            this.lblRdbIpValue.Cursor      = System.Windows.Forms.Cursors.Hand;
            this.lblRdbIpValue.Anchor      = System.Windows.Forms.AnchorStyles.Left
                                           | System.Windows.Forms.AnchorStyles.Right
                                           | System.Windows.Forms.AnchorStyles.Top;
            this.lblRdbIpValue.Click      += new System.EventHandler(this.lblSettingsValue_Click);

            // 行2: MongoDB IPアドレス (y=46)
            this.lblMongoIpCaption.AutoSize  = false;
            this.lblMongoIpCaption.Location  = new System.Drawing.Point(4, 46);
            this.lblMongoIpCaption.Size      = new System.Drawing.Size(168, 18);
            this.lblMongoIpCaption.Text      = "MongoDB IPアドレス:";
            this.lblMongoIpCaption.Font      = new System.Drawing.Font("MS UI Gothic", 8F);
            this.lblMongoIpCaption.ForeColor = System.Drawing.Color.FromArgb(80, 80, 80);
            this.lblMongoIpCaption.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;

            this.lblMongoIpValue.AutoSize    = false;
            this.lblMongoIpValue.Location    = new System.Drawing.Point(174, 46);
            this.lblMongoIpValue.Size        = new System.Drawing.Size(280, 18);
            this.lblMongoIpValue.Text        = "---";
            this.lblMongoIpValue.Font        = new System.Drawing.Font("MS UI Gothic", 9F);
            this.lblMongoIpValue.ForeColor   = System.Drawing.Color.FromArgb(0, 80, 160);
            this.lblMongoIpValue.Cursor      = System.Windows.Forms.Cursors.Hand;
            this.lblMongoIpValue.Anchor      = System.Windows.Forms.AnchorStyles.Left
                                            | System.Windows.Forms.AnchorStyles.Right
                                            | System.Windows.Forms.AnchorStyles.Top;
            this.lblMongoIpValue.Click      += new System.EventHandler(this.lblSettingsValue_Click);

            // 行3: FNSiフォルダ (y=68)
            this.lblFnsiCaption.AutoSize  = false;
            this.lblFnsiCaption.Location  = new System.Drawing.Point(4, 68);
            this.lblFnsiCaption.Size      = new System.Drawing.Size(168, 18);
            this.lblFnsiCaption.Text      = "FNSiルートフォルダ:";
            this.lblFnsiCaption.Font      = new System.Drawing.Font("MS UI Gothic", 8F);
            this.lblFnsiCaption.ForeColor = System.Drawing.Color.FromArgb(80, 80, 80);
            this.lblFnsiCaption.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;

            this.lblFnsiValue.AutoSize    = false;
            this.lblFnsiValue.Location    = new System.Drawing.Point(174, 68);
            this.lblFnsiValue.Size        = new System.Drawing.Size(280, 18);
            this.lblFnsiValue.Text        = "---";
            this.lblFnsiValue.Font        = new System.Drawing.Font("MS UI Gothic", 9F);
            this.lblFnsiValue.ForeColor   = System.Drawing.Color.FromArgb(0, 80, 160);
            this.lblFnsiValue.Cursor      = System.Windows.Forms.Cursors.Hand;
            this.lblFnsiValue.Anchor      = System.Windows.Forms.AnchorStyles.Left
                                          | System.Windows.Forms.AnchorStyles.Right
                                          | System.Windows.Forms.AnchorStyles.Top;
            this.lblFnsiValue.Click      += new System.EventHandler(this.lblSettingsValue_Click);

            // 行4: オンプレ臨時フォルダ (y=90)
            this.lblOnpreTmpCaption.AutoSize  = false;
            this.lblOnpreTmpCaption.Location  = new System.Drawing.Point(4, 90);
            this.lblOnpreTmpCaption.Size      = new System.Drawing.Size(168, 18);
            this.lblOnpreTmpCaption.Text      = "臨時フォルダ:";
            this.lblOnpreTmpCaption.Font      = new System.Drawing.Font("MS UI Gothic", 8F);
            this.lblOnpreTmpCaption.ForeColor = System.Drawing.Color.FromArgb(80, 80, 80);
            this.lblOnpreTmpCaption.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;

            this.lblOnpreTmpValue.AutoSize    = false;
            this.lblOnpreTmpValue.Location    = new System.Drawing.Point(174, 90);
            this.lblOnpreTmpValue.Size        = new System.Drawing.Size(280, 18);
            this.lblOnpreTmpValue.Text        = "---";
            this.lblOnpreTmpValue.Font        = new System.Drawing.Font("MS UI Gothic", 9F);
            this.lblOnpreTmpValue.ForeColor   = System.Drawing.Color.FromArgb(0, 80, 160);
            this.lblOnpreTmpValue.Cursor      = System.Windows.Forms.Cursors.Hand;
            this.lblOnpreTmpValue.Anchor      = System.Windows.Forms.AnchorStyles.Left
                                             | System.Windows.Forms.AnchorStyles.Right
                                             | System.Windows.Forms.AnchorStyles.Top;
            this.lblOnpreTmpValue.Click      += new System.EventHandler(this.lblSettingsValue_Click);

            // --------------------------------------------------
            // Panel2: クラウド側（キャプション左・値右）
            // --------------------------------------------------
            this.splitSettings.Panel2.Controls.Add(this.lblCloudSettingsTitle);
            this.splitSettings.Panel2.Controls.Add(this.pnlSepCloud);
            this.splitSettings.Panel2.Controls.Add(this.lblCloudTmpCaption);
            this.splitSettings.Panel2.Controls.Add(this.lblCloudTmpValue);
            this.splitSettings.Panel2.Controls.Add(this.lblCloudDbCaption);
            this.splitSettings.Panel2.Controls.Add(this.lblCloudDbValue);

            this.lblCloudSettingsTitle.AutoSize  = false;
            this.lblCloudSettingsTitle.Location  = new System.Drawing.Point(8, 3);
            this.lblCloudSettingsTitle.Size      = new System.Drawing.Size(120, 16);
            this.lblCloudSettingsTitle.Text      = "クラウド側";
            this.lblCloudSettingsTitle.Font      = new System.Drawing.Font("MS UI Gothic", 8F, System.Drawing.FontStyle.Bold);
            this.lblCloudSettingsTitle.ForeColor = System.Drawing.Color.FromArgb(60, 60, 60);

            this.pnlSepCloud.Location  = new System.Drawing.Point(0, 20);
            this.pnlSepCloud.Size      = new System.Drawing.Size(2000, 1);
            this.pnlSepCloud.BackColor = System.Drawing.Color.FromArgb(200, 200, 200);
            this.pnlSepCloud.Anchor    = System.Windows.Forms.AnchorStyles.Left
                                       | System.Windows.Forms.AnchorStyles.Right
                                       | System.Windows.Forms.AnchorStyles.Top;

            // 行1: コンバーターサーバ (y=24)
            this.lblCloudTmpCaption.AutoSize  = false;
            this.lblCloudTmpCaption.Location  = new System.Drawing.Point(8, 24);
            this.lblCloudTmpCaption.Size      = new System.Drawing.Size(168, 18);
            this.lblCloudTmpCaption.Text      = "FNSiクラウドコンバートサーバ:";
            this.lblCloudTmpCaption.Font      = new System.Drawing.Font("MS UI Gothic", 8F);
            this.lblCloudTmpCaption.ForeColor = System.Drawing.Color.FromArgb(80, 80, 80);
            this.lblCloudTmpCaption.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;

            this.lblCloudTmpValue.AutoSize    = false;
            this.lblCloudTmpValue.Location    = new System.Drawing.Point(180, 24);
            this.lblCloudTmpValue.Size        = new System.Drawing.Size(280, 18);
            this.lblCloudTmpValue.Text        = "---";
            this.lblCloudTmpValue.Font        = new System.Drawing.Font("MS UI Gothic", 9F);
            this.lblCloudTmpValue.ForeColor   = System.Drawing.Color.FromArgb(0, 80, 160);
            this.lblCloudTmpValue.Cursor      = System.Windows.Forms.Cursors.Hand;
            this.lblCloudTmpValue.Anchor      = System.Windows.Forms.AnchorStyles.Left
                                               | System.Windows.Forms.AnchorStyles.Right
                                               | System.Windows.Forms.AnchorStyles.Top;
            this.lblCloudTmpValue.Click      += new System.EventHandler(this.lblSettingsValue_Click);

            // 行2: コンバーターDB (y=46)
            this.lblCloudDbCaption.AutoSize  = false;
            this.lblCloudDbCaption.Location  = new System.Drawing.Point(8, 46);
            this.lblCloudDbCaption.Size      = new System.Drawing.Size(168, 18);
            this.lblCloudDbCaption.Text      = "FNSiクラウドコンバートDB:";
            this.lblCloudDbCaption.Font      = new System.Drawing.Font("MS UI Gothic", 8F);
            this.lblCloudDbCaption.ForeColor = System.Drawing.Color.FromArgb(80, 80, 80);
            this.lblCloudDbCaption.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;

            this.lblCloudDbValue.AutoSize    = false;
            this.lblCloudDbValue.Location    = new System.Drawing.Point(180, 46);
            this.lblCloudDbValue.Size        = new System.Drawing.Size(280, 18);
            this.lblCloudDbValue.Text        = "---";
            this.lblCloudDbValue.Font        = new System.Drawing.Font("MS UI Gothic", 9F);
            this.lblCloudDbValue.ForeColor   = System.Drawing.Color.FromArgb(0, 80, 160);
            this.lblCloudDbValue.Cursor      = System.Windows.Forms.Cursors.Hand;
            this.lblCloudDbValue.Anchor      = System.Windows.Forms.AnchorStyles.Left
                                              | System.Windows.Forms.AnchorStyles.Right
                                              | System.Windows.Forms.AnchorStyles.Top;
            this.lblCloudDbValue.Click      += new System.EventHandler(this.lblSettingsValue_Click);

            // ==============================================================
            // pnlMiddle
            // ==============================================================
            this.pnlMiddle.Location    = new System.Drawing.Point(5, 187);
            this.pnlMiddle.Size        = new System.Drawing.Size(970, 90);
            this.pnlMiddle.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.pnlMiddle.Anchor      = System.Windows.Forms.AnchorStyles.Left
                                       | System.Windows.Forms.AnchorStyles.Right
                                       | System.Windows.Forms.AnchorStyles.Top;
            this.pnlMiddle.Controls.Add(this.pnlStatusRow);
            this.pnlMiddle.Controls.Add(this.pnlSepMid);
            this.pnlMiddle.Controls.Add(this.btnStart);
            this.pnlMiddle.Controls.Add(this.btnLanLeft);
            this.pnlMiddle.Controls.Add(this.btnLanRight);
            this.pnlMiddle.Controls.Add(this.btnStop);

            // 上段: 状態表示行（全幅・背景色で状態を表現）
            this.pnlStatusRow.Location  = new System.Drawing.Point(0, 0);
            this.pnlStatusRow.Size      = new System.Drawing.Size(970, 44);
            this.pnlStatusRow.BackColor = System.Drawing.Color.FromArgb(220, 220, 220);
            this.pnlStatusRow.Anchor    = System.Windows.Forms.AnchorStyles.Left
                                        | System.Windows.Forms.AnchorStyles.Right
                                        | System.Windows.Forms.AnchorStyles.Top;
            this.pnlStatusRow.Controls.Add(this.lblMode);
            this.pnlStatusRow.Controls.Add(this.lblModeValue);
            this.pnlStatusRow.Controls.Add(this.lblStatus);

            this.lblMode.AutoSize  = true;
            this.lblMode.Font      = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Bold);
            this.lblMode.Location  = new System.Drawing.Point(8, 6);
            this.lblMode.Text      = "操作モード: ";
            this.lblMode.BackColor = System.Drawing.Color.Transparent;

            this.lblModeValue.AutoSize  = true;
            this.lblModeValue.Font      = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Bold | System.Drawing.FontStyle.Underline);
            this.lblModeValue.Location  = new System.Drawing.Point(90, 6);
            this.lblModeValue.Text      = "---";
            this.lblModeValue.BackColor = System.Drawing.Color.Transparent;
            this.lblModeValue.ForeColor = System.Drawing.Color.FromArgb(0, 80, 160);
            this.lblModeValue.Cursor    = System.Windows.Forms.Cursors.Hand;
            this.lblModeValue.Click    += new System.EventHandler(this.lblModeValue_Click);

            this.lblStatus.AutoSize  = true;
            this.lblStatus.Font      = new System.Drawing.Font("MS UI Gothic", 9F);
            this.lblStatus.Location  = new System.Drawing.Point(8, 24);
            this.lblStatus.Text      = "状態: 待機中";
            this.lblStatus.BackColor = System.Drawing.Color.Transparent;

            // 上段・下段の区切り線
            this.pnlSepMid.Location  = new System.Drawing.Point(0, 44);
            this.pnlSepMid.Size      = new System.Drawing.Size(970, 1);
            this.pnlSepMid.BackColor = System.Drawing.Color.FromArgb(210, 213, 218);
            this.pnlSepMid.Anchor    = System.Windows.Forms.AnchorStyles.Left
                                     | System.Windows.Forms.AnchorStyles.Right
                                     | System.Windows.Forms.AnchorStyles.Top;

            // 下段: 操作ボタン
            this.btnStart.Location  = new System.Drawing.Point(680, 50);
            this.btnStart.Size      = new System.Drawing.Size(80, 34);
            this.btnStart.Text      = "開始";
            this.btnStart.Font      = new System.Drawing.Font("MS UI Gothic", 10F, System.Drawing.FontStyle.Bold);
            this.btnStart.BackColor = System.Drawing.Color.FromArgb(46, 139, 87);
            this.btnStart.ForeColor = System.Drawing.Color.White;
            this.btnStart.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnStart.Anchor    = System.Windows.Forms.AnchorStyles.Right | System.Windows.Forms.AnchorStyles.Top;
            this.btnStart.TabIndex  = 0;
            this.btnStart.Click    += new System.EventHandler(this.btnStart_Click);

            // LAN モード用ボタン（左側: オンプレ or クラウド操作）
            this.btnLanLeft.Location  = new System.Drawing.Point(20, 50);
            this.btnLanLeft.Size      = new System.Drawing.Size(150, 34);
            this.btnLanLeft.Text      = "---";
            this.btnLanLeft.Font      = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Bold);
            this.btnLanLeft.BackColor = System.Drawing.Color.FromArgb(46, 139, 87);
            this.btnLanLeft.ForeColor = System.Drawing.Color.White;
            this.btnLanLeft.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnLanLeft.Anchor    = System.Windows.Forms.AnchorStyles.Left | System.Windows.Forms.AnchorStyles.Top;
            this.btnLanLeft.Visible   = false;
            this.btnLanLeft.TabIndex  = 10;
            this.btnLanLeft.Click    += new System.EventHandler(this.btnLanLeft_Click);

            // LAN モード用ボタン（右側: クラウド or オンプレ操作）
            // Anchor=Right により btnStop の左隣に固定（リサイズ時も右側に維持）
            this.btnLanRight.Location  = new System.Drawing.Point(710, 50);
            this.btnLanRight.Size      = new System.Drawing.Size(150, 34);
            this.btnLanRight.Text      = "---";
            this.btnLanRight.Font      = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Bold);
            this.btnLanRight.BackColor = System.Drawing.Color.FromArgb(24, 119, 242);
            this.btnLanRight.ForeColor = System.Drawing.Color.White;
            this.btnLanRight.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnLanRight.Anchor    = System.Windows.Forms.AnchorStyles.Right | System.Windows.Forms.AnchorStyles.Top;
            this.btnLanRight.Visible   = false;
            this.btnLanRight.TabIndex  = 11;
            this.btnLanRight.Click    += new System.EventHandler(this.btnLanRight_Click);

            this.btnStop.Location  = new System.Drawing.Point(870, 50);
            this.btnStop.Size      = new System.Drawing.Size(80, 34);
            this.btnStop.Text      = "中止";
            this.btnStop.Font      = new System.Drawing.Font("MS UI Gothic", 10F, System.Drawing.FontStyle.Bold);
            this.btnStop.BackColor = System.Drawing.Color.FromArgb(178, 34, 34);
            this.btnStop.ForeColor = System.Drawing.Color.White;
            this.btnStop.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnStop.Enabled   = false;
            this.btnStop.Anchor    = System.Windows.Forms.AnchorStyles.Right | System.Windows.Forms.AnchorStyles.Top;
            this.btnStop.TabIndex  = 1;
            this.btnStop.Click    += new System.EventHandler(this.btnStop_Click);

            // ==============================================================
            // splitBottom（オンプレ / クラウド 左右分割）
            // ==============================================================
            this.splitBottom.Location         = new System.Drawing.Point(5, 282);
            this.splitBottom.Size             = new System.Drawing.Size(970, 357);
            this.splitBottom.Orientation      = System.Windows.Forms.Orientation.Vertical;
            this.splitBottom.SplitterDistance = 483;
            this.splitBottom.Anchor           = System.Windows.Forms.AnchorStyles.Left
                                              | System.Windows.Forms.AnchorStyles.Right
                                              | System.Windows.Forms.AnchorStyles.Top
                                              | System.Windows.Forms.AnchorStyles.Bottom;

            // --------------------------------------------------
            // splitBottom.Panel1: オンプレ側 → splitOnpre で 2:8 分割
            // pbPostgres は Dock=Top で全幅表示（件数・ログタイトルの上）
            // --------------------------------------------------
            this.splitBottom.Panel1.Controls.Add(this.splitOnpre);
            this.splitBottom.Panel1.Controls.Add(this.pbPostgres);

            this.splitOnpre.Dock             = System.Windows.Forms.DockStyle.Fill;
            this.splitOnpre.Orientation      = System.Windows.Forms.Orientation.Vertical;
            this.splitOnpre.SplitterDistance = 100;   // 初期値（Load時に22%へ自動調整）
            this.splitOnpre.SplitterWidth    = 3;
            this.splitOnpre.TabStop          = false;

            // splitOnpre.Panel1: 件数（18%）
            this.splitOnpre.Panel1.Controls.Add(this.lblOnpreCount);
            this.splitOnpre.Panel1.Controls.Add(this.lblOnpreCountTitle);

            this.lblOnpreCountTitle.AutoSize  = false;
            this.lblOnpreCountTitle.Dock      = System.Windows.Forms.DockStyle.Top;
            this.lblOnpreCountTitle.Height    = 22;
            this.lblOnpreCountTitle.Text      = "オンプレ  処理件数";
            this.lblOnpreCountTitle.Font      = new System.Drawing.Font("MS UI Gothic", 7F, System.Drawing.FontStyle.Bold);
            this.lblOnpreCountTitle.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.lblOnpreCountTitle.BackColor = System.Drawing.Color.FromArgb(40, 80, 140);
            this.lblOnpreCountTitle.ForeColor = System.Drawing.Color.White;

            this.lblOnpreCount.AutoSize  = false;
            this.lblOnpreCount.Dock      = System.Windows.Forms.DockStyle.Fill;
            this.lblOnpreCount.Text      = "DB4: ---\nDB5: ---\nDB6: ---\nMongo: ---";
            this.lblOnpreCount.Font      = new System.Drawing.Font("Consolas", 8F);
            this.lblOnpreCount.TextAlign = System.Drawing.ContentAlignment.TopLeft;
            this.lblOnpreCount.ForeColor = System.Drawing.Color.FromArgb(30, 80, 160);
            this.lblOnpreCount.Padding   = new System.Windows.Forms.Padding(4, 4, 0, 0);

            // splitOnpre.Panel2: 実行ログ（78%）
            this.splitOnpre.Panel2.Controls.Add(this.lblPgTitle);
            this.splitOnpre.Panel2.Controls.Add(this.rtbPgLog);

            this.lblPgTitle.AutoSize  = false;
            this.lblPgTitle.Dock      = System.Windows.Forms.DockStyle.Top;
            this.lblPgTitle.Height    = 22;
            this.lblPgTitle.Text      = "オンプレ  実行ログ";
            this.lblPgTitle.Font      = new System.Drawing.Font("MS UI Gothic", 8F, System.Drawing.FontStyle.Bold);
            this.lblPgTitle.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.lblPgTitle.BackColor = System.Drawing.Color.FromArgb(40, 80, 140);
            this.lblPgTitle.ForeColor = System.Drawing.Color.White;

            this.pbPostgres.Dock   = System.Windows.Forms.DockStyle.Top;
            this.pbPostgres.Height = 22;

            this.rtbPgLog.Dock          = System.Windows.Forms.DockStyle.Fill;
            this.rtbPgLog.ReadOnly      = true;
            this.rtbPgLog.HideSelection = false;
            this.rtbPgLog.BackColor     = System.Drawing.Color.Black;
            this.rtbPgLog.ForeColor     = System.Drawing.Color.LightGreen;
            this.rtbPgLog.Font          = new System.Drawing.Font("Consolas", 8.5F);
            this.rtbPgLog.ScrollBars    = System.Windows.Forms.RichTextBoxScrollBars.Vertical;

            // --------------------------------------------------
            // splitBottom.Panel2: クラウド側 → splitCloud で 2:8 分割
            // pbMongo は Dock=Top で全幅表示（件数・ログタイトルの上）
            // --------------------------------------------------
            this.splitBottom.Panel2.Controls.Add(this.splitCloud);
            this.splitBottom.Panel2.Controls.Add(this.pbMongo);

            this.splitCloud.Dock             = System.Windows.Forms.DockStyle.Fill;
            this.splitCloud.Orientation      = System.Windows.Forms.Orientation.Vertical;
            this.splitCloud.SplitterDistance = 100;   // 初期値（Load時に22%へ自動調整）
            this.splitCloud.SplitterWidth    = 3;
            this.splitCloud.TabStop          = false;

            // splitCloud.Panel1: 件数（18%）
            this.splitCloud.Panel1.Controls.Add(this.lblCloudCount);
            this.splitCloud.Panel1.Controls.Add(this.lblCloudCountTitle);

            this.lblCloudCountTitle.AutoSize  = false;
            this.lblCloudCountTitle.Dock      = System.Windows.Forms.DockStyle.Top;
            this.lblCloudCountTitle.Height    = 22;
            this.lblCloudCountTitle.Text      = "クラウド  処理件数";
            this.lblCloudCountTitle.Font      = new System.Drawing.Font("MS UI Gothic", 7F, System.Drawing.FontStyle.Bold);
            this.lblCloudCountTitle.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.lblCloudCountTitle.BackColor = System.Drawing.Color.FromArgb(30, 100, 80);
            this.lblCloudCountTitle.ForeColor = System.Drawing.Color.White;

            this.lblCloudCount.AutoSize  = false;
            this.lblCloudCount.Dock      = System.Windows.Forms.DockStyle.Fill;
            this.lblCloudCount.Text      = "---";
            this.lblCloudCount.Font      = new System.Drawing.Font("Consolas", 8F);
            this.lblCloudCount.TextAlign = System.Drawing.ContentAlignment.TopLeft;
            this.lblCloudCount.ForeColor = System.Drawing.Color.FromArgb(20, 100, 60);
            this.lblCloudCount.Padding   = new System.Windows.Forms.Padding(4, 4, 0, 0);

            // splitCloud.Panel2: 実行ログ（78%）
            this.splitCloud.Panel2.Controls.Add(this.lblMongoTitle);
            this.splitCloud.Panel2.Controls.Add(this.rtbMongoLog);

            this.lblMongoTitle.AutoSize  = false;
            this.lblMongoTitle.Dock      = System.Windows.Forms.DockStyle.Top;
            this.lblMongoTitle.Height    = 22;
            this.lblMongoTitle.Text      = "クラウド  実行ログ";
            this.lblMongoTitle.Font      = new System.Drawing.Font("MS UI Gothic", 8F, System.Drawing.FontStyle.Bold);
            this.lblMongoTitle.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.lblMongoTitle.BackColor = System.Drawing.Color.FromArgb(30, 100, 80);
            this.lblMongoTitle.ForeColor = System.Drawing.Color.White;

            this.pbMongo.Dock   = System.Windows.Forms.DockStyle.Top;
            this.pbMongo.Height = 22;

            this.rtbMongoLog.Dock          = System.Windows.Forms.DockStyle.Fill;
            this.rtbMongoLog.ReadOnly      = true;
            this.rtbMongoLog.HideSelection = false;
            this.rtbMongoLog.BackColor     = System.Drawing.Color.Black;
            this.rtbMongoLog.ForeColor     = System.Drawing.Color.Cyan;
            this.rtbMongoLog.Font          = new System.Drawing.Font("Consolas", 8.5F);
            this.rtbMongoLog.ScrollBars    = System.Windows.Forms.RichTextBoxScrollBars.Vertical;

            // ==============================================================
            // FormMain
            // ==============================================================
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode       = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize          = new System.Drawing.Size(980, 648);
            this.Controls.Add(this.pnlFacilityBar);
            this.Controls.Add(this.grpSettings);
            this.Controls.Add(this.pnlMiddle);
            this.Controls.Add(this.splitBottom);
            this.MinimumSize     = new System.Drawing.Size(700, 560);
            this.Name            = "FormMain";
            this.StartPosition   = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text            = "FutureNetWeb\u207ASi\u30aa\u30f3\u30d7\u30ec\u2192\u30af\u30e9\u30a6\u30c9\u30b3\u30f3\u30d0\u30fc\u30c8";
            this.FormClosed     += new System.Windows.Forms.FormClosedEventHandler(this.FormMain_FormClosed);

            this.pnlFacilityBar.ResumeLayout(false);
            this.pnlFacilityBar.PerformLayout();
            this.grpSettings.ResumeLayout(false);
            this.splitSettings.Panel1.ResumeLayout(false);
            this.splitSettings.Panel1.PerformLayout();
            this.splitSettings.Panel2.ResumeLayout(false);
            this.splitSettings.Panel2.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitSettings)).EndInit();
            this.splitSettings.ResumeLayout(false);
            this.pnlMiddle.ResumeLayout(false);
            this.pnlMiddle.PerformLayout();
            this.splitOnpre.Panel1.ResumeLayout(false);
            this.splitOnpre.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitOnpre)).EndInit();
            this.splitOnpre.ResumeLayout(false);
            this.splitCloud.Panel1.ResumeLayout(false);
            this.splitCloud.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitCloud)).EndInit();
            this.splitCloud.ResumeLayout(false);
            this.splitBottom.Panel1.ResumeLayout(false);
            this.splitBottom.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitBottom)).EndInit();
            this.splitBottom.ResumeLayout(false);
            this.ResumeLayout(false);
        }

        // 最上部
        private System.Windows.Forms.Panel       pnlFacilityBar;
        private System.Windows.Forms.Label       lblFacilities;
        private System.Windows.Forms.Button      btnChangeFacility;
        // 設定
        private System.Windows.Forms.GroupBox      grpSettings;
        private System.Windows.Forms.Button        btnSettings;
        private System.Windows.Forms.SplitContainer splitSettings;
        private System.Windows.Forms.Label         lblOnpreSettingsTitle;
        private System.Windows.Forms.Panel         pnlSepOnpre;
        private System.Windows.Forms.Label         lblRdbIpCaption;
        private System.Windows.Forms.Label         lblRdbIpValue;
        private System.Windows.Forms.Label         lblMongoIpCaption;
        private System.Windows.Forms.Label         lblMongoIpValue;
        private System.Windows.Forms.Label         lblFnsiCaption;
        private System.Windows.Forms.Label         lblFnsiValue;
        private System.Windows.Forms.Label         lblOnpreTmpCaption;
        private System.Windows.Forms.Label         lblOnpreTmpValue;
        private System.Windows.Forms.Label         lblCloudSettingsTitle;
        private System.Windows.Forms.Panel         pnlSepCloud;
        private System.Windows.Forms.Label         lblCloudTmpCaption;
        private System.Windows.Forms.Label         lblCloudTmpValue;
        private System.Windows.Forms.Label         lblCloudDbCaption;
        private System.Windows.Forms.Label         lblCloudDbValue;
        // 中部
        private System.Windows.Forms.Panel       pnlMiddle;
        private System.Windows.Forms.Panel       pnlStatusRow;
        private System.Windows.Forms.Label       lblMode;
        private System.Windows.Forms.Label       lblModeValue;
        private System.Windows.Forms.Label       lblStatus;
        private System.Windows.Forms.Panel       pnlSepMid;
        private System.Windows.Forms.Button      btnStart;
        private System.Windows.Forms.Button      btnLanLeft;
        private System.Windows.Forms.Button      btnLanRight;
        private System.Windows.Forms.Button      btnStop;
        // 下部
        private System.Windows.Forms.SplitContainer splitBottom;
        private System.Windows.Forms.SplitContainer splitOnpre;
        private System.Windows.Forms.Label       lblOnpreCountTitle;
        private System.Windows.Forms.Label       lblOnpreCount;
        private System.Windows.Forms.Label       lblPgTitle;
        private ProgressBarEx            pbPostgres;
        private System.Windows.Forms.RichTextBox rtbPgLog;
        private System.Windows.Forms.SplitContainer splitCloud;
        private System.Windows.Forms.Label       lblCloudCountTitle;
        private System.Windows.Forms.Label       lblCloudCount;
        private System.Windows.Forms.Label       lblMongoTitle;
        private ProgressBarEx            pbMongo;
        private System.Windows.Forms.RichTextBox rtbMongoLog;
    }
}
