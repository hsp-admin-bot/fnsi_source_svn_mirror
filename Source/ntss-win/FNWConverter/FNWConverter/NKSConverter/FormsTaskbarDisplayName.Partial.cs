using System;
using System.Windows.Forms;

namespace NKSConverter
{
    partial class FrmSignIn
    {
        protected override void OnHandleCreated(EventArgs e)
        {
            base.OnHandleCreated(e);
            TaskbarAppIdentity.ApplyTaskbarDisplayName(Handle);
        }
    }

    partial class MainForm
    {
        protected override void OnHandleCreated(EventArgs e)
        {
            base.OnHandleCreated(e);
            TaskbarAppIdentity.ApplyTaskbarDisplayName(Handle);
        }
    }

    partial class ConvertForm
    {
        protected override void OnHandleCreated(EventArgs e)
        {
            base.OnHandleCreated(e);
            TaskbarAppIdentity.ApplyTaskbarDisplayName(Handle);
        }
    }

    partial class ConvertFormOffLine
    {
        protected override void OnHandleCreated(EventArgs e)
        {
            base.OnHandleCreated(e);
            TaskbarAppIdentity.ApplyTaskbarDisplayName(Handle);
        }
    }

    partial class ConfigSetting
    {
        protected override void OnHandleCreated(EventArgs e)
        {
            base.OnHandleCreated(e);
            TaskbarAppIdentity.ApplyTaskbarDisplayName(Handle);
        }
    }

    partial class UploadForm
    {
        protected override void OnHandleCreated(EventArgs e)
        {
            base.OnHandleCreated(e);
            TaskbarAppIdentity.ApplyTaskbarDisplayName(Handle);
        }
    }

    partial class ExtendedManagement
    {
        protected override void OnHandleCreated(EventArgs e)
        {
            base.OnHandleCreated(e);
            TaskbarAppIdentity.ApplyTaskbarDisplayName(Handle);
        }
    }

    partial class DialysisCondSet
    {
        protected override void OnHandleCreated(EventArgs e)
        {
            base.OnHandleCreated(e);
            TaskbarAppIdentity.ApplyTaskbarDisplayName(Handle);
        }
    }
}
