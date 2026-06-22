using System;
using System.Runtime.InteropServices;

namespace NKSConverter
{
    /// <summary>
    /// タスクバー右クリック／ジャンプ リスト先頭のアプリ表示名のみを変更する。
    /// AssemblyTitle（ファイルの説明）やウィンドウ タイトルは変更しない。
    /// </summary>
    internal static class TaskbarAppIdentity
    {
        internal const string TaskbarDisplayName = "FNWSi コンバートツール";

        private const string ExplicitAppUserModelId = "NIKKISO.FNWSi.FNWSiConvertTool";

        private static readonly Guid IID_IPropertyStore = new Guid("886D8EEB-8CF2-4446-8D02-CDBA1DBDCF99");

        private static readonly PROPERTYKEY PKEY_AppUserModel_ID = new PROPERTYKEY
        {
            fmtid = new Guid("9F4C2855-9F79-4B39-A8D0-E1D42DE1D5F3"),
            pid = 5
        };
        private static readonly PROPERTYKEY PKEY_AppUserModel_RelaunchDisplayNameResource = new PROPERTYKEY
        {
            fmtid = new Guid("9F4C2855-9F79-4B39-A8D0-E1D42DE1D5F3"),
            pid = 4
        };

        private const ushort VT_LPWSTR = 0x001F;

        [StructLayout(LayoutKind.Sequential, Pack = 4)]
        private struct PROPERTYKEY
        {
            public Guid fmtid;
            public uint pid;
        }

        [StructLayout(LayoutKind.Explicit, Size = 24)]
        private struct PropVariant
        {
            [FieldOffset(0)] public ushort vt;
            [FieldOffset(8)] public IntPtr ptr;
        }

        [DllImport("shell32.dll", PreserveSig = true)]
        private static extern int SetCurrentProcessExplicitAppUserModelID([MarshalAs(UnmanagedType.LPWStr)] string appID);

        [DllImport("shell32.dll", PreserveSig = true)]
        private static extern int SHGetPropertyStoreForWindow(IntPtr hwnd, ref Guid riid, out IPropertyStore pps);

        [DllImport("ole32.dll", PreserveSig = true)]
        private static extern int PropVariantClear(ref PropVariant pvar);

        [ComImport, Guid("886D8EEB-8CF2-4446-8D02-CDBA1DBDCF99"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
        private interface IPropertyStore
        {
            [PreserveSig] int GetCount(out uint cProps);
            [PreserveSig] int GetAt(uint iProp, ref PROPERTYKEY pkey);
            [PreserveSig] int GetValue(ref PROPERTYKEY key, ref PropVariant pv);
            [PreserveSig] int SetValue(ref PROPERTYKEY key, ref PropVariant propvar);
            [PreserveSig] int Commit();
        }

        internal static void SetProcessAppUserModelId()
        {
            SetCurrentProcessExplicitAppUserModelID(ExplicitAppUserModelId);
        }

        internal static void ApplyTaskbarDisplayName(IntPtr hwnd)
        {
            if (hwnd == IntPtr.Zero)
                return;

            IPropertyStore store;
            Guid iid = IID_IPropertyStore;
            if (SHGetPropertyStoreForWindow(hwnd, ref iid, out store) != 0 || store == null)
                return;

            var appIdPv = new PropVariant { vt = VT_LPWSTR, ptr = Marshal.StringToCoTaskMemUni(ExplicitAppUserModelId) };
            var displayNamePv = new PropVariant { vt = VT_LPWSTR, ptr = Marshal.StringToCoTaskMemUni(TaskbarDisplayName) };
            try
            {
                var appUserModelIdKey = PKEY_AppUserModel_ID;
                if (store.SetValue(ref appUserModelIdKey, ref appIdPv) == 0)
                {
                    var relaunchDisplayNameKey = PKEY_AppUserModel_RelaunchDisplayNameResource;
                    store.SetValue(ref relaunchDisplayNameKey, ref displayNamePv);
                    store.Commit();
                }
            }
            finally
            {
                PropVariantClear(ref appIdPv);
                PropVariantClear(ref displayNamePv);
            }
        }
    }
}
