using System;
using System.Text;
using System.Runtime.InteropServices;

[StructLayout(LayoutKind.Sequential)]
public struct StructureReaderWriterMode
{
    public String strPortName;
    public UInt32 lngBaudRate;
    public byte bytEncryptionMode;
    public IntPtr ptrKar;
    public IntPtr ptrKbr;
}

[StructLayout(LayoutKind.Sequential)]
public struct StructureOpenReaderWriterModeWithoutEncryption
{
    public String strPortName;
    public UInt32 lngBaudRate;
}

[StructLayout(LayoutKind.Sequential)]
public struct StructurePolling
{
    public IntPtr ptrSystemCode;
    public byte bytTimeSlot;
}

[StructLayout(LayoutKind.Sequential)]
public struct StructureCardInformation
{
    public IntPtr ptrCardIdm;
    public IntPtr ptrCardPmm;
}

[StructLayout(LayoutKind.Sequential)]
public struct InputStructureWriteBlockWithoutEncryption
{
    public IntPtr ptrCardIdm;
    public byte bytNumberOfServices;
    public IntPtr ptrServiceCodeList;
    public byte bytNumberOfBlocks;
    public IntPtr ptrBlockList;
    public IntPtr ptrBlockData;

}

[StructLayout(LayoutKind.Sequential)]
public struct OutputStructureWriteBlockWithoutEncryption
{
    public IntPtr ptrStatusFlag1;
    public IntPtr ptrStatusFlag2;
}

[StructLayout(LayoutKind.Sequential)]
public struct InputStructureReadBlockWithoutEncryption
{
    public IntPtr ptrCardIdm;
    public byte bytNumberOfServices;
    public IntPtr ptrServiceCodeList;
    public byte bytNumberOfBlocks;
    public IntPtr ptrBlockList;
}

[StructLayout(LayoutKind.Sequential)]
public struct OutputStructureReadBlockWithoutEncryption
{
    public IntPtr ptrStatusFlag1;
    public IntPtr ptrStatusFlag2;
    public IntPtr ptrResultNumberOfBlocks;
    public IntPtr ptrBlockData;
}

[StructLayout(LayoutKind.Sequential)]
public struct StructureInputRequestService
{
    public IntPtr ptrCardIdm;
    public byte bytNumberOfServices;
    public IntPtr ptrServiceCcodeList;
}

[StructLayout(LayoutKind.Sequential)]
public struct StructureOutputRequestService
{
    public IntPtr ptrNumberOfServices;
    public IntPtr ptrServiceKeyVersionList;
}

[StructLayout(LayoutKind.Sequential)]
public struct StructureInputSystemCode
{
    public IntPtr ptrCardIdm;
}

[StructLayout(LayoutKind.Sequential)]
public struct StructureOutputSystemCode
{
    public byte lngNumberOfSystemCode;
    public IntPtr ptrSystemCodeList;
}

[StructLayout(LayoutKind.Sequential)]
public struct StructureInputSearchServiceCode
{
    public UInt32 lngBufferSizeOfAreaCodes;
    public UInt32 lngBufferSizeOfServiceCodes;
    public UInt16 I16OffsetOfAreaServiceIndex;
}

[StructLayout(LayoutKind.Sequential)]
public struct StructureOutputSearchServiceCode
{
    public UInt32 lngNumberOfServiceCodes;
    public IntPtr ptrServiceCodeList;
    public UInt32 lngNumberOfAreaCodes;
    public IntPtr ptrAreaCodeList;
    public IntPtr ptrEndServiceCodeList;
}

[StructLayout(LayoutKind.Sequential)]
public struct StructureInputDumb
{
    public UInt16 time_out;
    public UInt16 retry_count;
    public IntPtr ptrCardCommandPacketData;
    public byte bytCardCommandPacketLength;
}

[StructLayout(LayoutKind.Sequential)]
public struct StructureOutputDumb
{
    public IntPtr ptrCardResponsePacketData;
    public IntPtr ptrResponsePacketLength;
}

class felica_dll_wrapper_basic
{
    //DllImport
    [DllImport("felica.dll", CallingConvention = CallingConvention.Cdecl)]
    [return: MarshalAs(UnmanagedType.U1)]
    public static extern bool initialize_library();

    [DllImport("felica.dll", CallingConvention = CallingConvention.Cdecl)]
    [return: MarshalAs(UnmanagedType.U1)]
    public static extern bool get_version_information(
            StringBuilder sbVersionNumber
        );

    [DllImport("felica.dll", CallingConvention = CallingConvention.Cdecl)]
    [return: MarshalAs(UnmanagedType.U1)]
    public static extern bool get_copyright_information(
            StringBuilder sbCopyright
        );

    [DllImport("felica.dll", CallingConvention = CallingConvention.Cdecl)]
    [return: MarshalAs(UnmanagedType.U1)]
    public static extern bool set_reader_writer_control_library(
            string sbLibraryFileName
        );

    [DllImport("felica.dll", CallingConvention = CallingConvention.Cdecl)]
    [return: MarshalAs(UnmanagedType.U1)]
    public static extern bool open_reader_writer_without_encryption(
        ref StructureOpenReaderWriterModeWithoutEncryption
                    udtOpenReaderWriteModeWithoutEncryption
        );

    [DllImport("felica.dll", CallingConvention = CallingConvention.Cdecl)]
    [return: MarshalAs(UnmanagedType.U1)]
    public static extern bool open_reader_writer_auto();

    [DllImport("felica.dll", CallingConvention = CallingConvention.Cdecl)]
    [return: MarshalAs(UnmanagedType.U1)]
    public static extern bool polling_and_get_card_information(
        ref StructurePolling udtPolling,
        ref byte bytNumberOfCards,
        ref StructureCardInformation udtCardInformation
        );

    [DllImport("felica.dll", CallingConvention = CallingConvention.Cdecl)]
    [return: MarshalAs(UnmanagedType.U1)]
    public static extern bool polling_and_request_service(
        ref StructurePolling udtPolling,
        ref StructureInputRequestService udtInputRequestService,
        ref StructureCardInformation udtCardInformation,
        ref StructureOutputRequestService udtOutputRequestService);

    [DllImport("felica.dll", CallingConvention = CallingConvention.Cdecl)]
    [return: MarshalAs(UnmanagedType.U1)]
    public static extern bool polling_and_request_system_code(
        ref StructurePolling udtPolling,
        ref StructureInputSystemCode udtInputSystemCode,
        ref StructureCardInformation udtCardInformation,
        ref StructureOutputSystemCode udtOutputSystemCode);

    [DllImport("felica.dll", CallingConvention = CallingConvention.Cdecl)]
    [return: MarshalAs(UnmanagedType.U1)]
    public static extern bool polling_and_search_service_code(
        ref StructurePolling udtPolling,
        ref StructureInputSearchServiceCode udtInputSearchServiceCode,
        ref StructureCardInformation udtCardInformation,
        ref StructureOutputSearchServiceCode udtOutputSearchServiceCode);

    [DllImport("felica.dll", CallingConvention = CallingConvention.Cdecl)]
    [return: MarshalAs(UnmanagedType.U1)]
    public static extern bool reader_writer_is_alive(
        [MarshalAs(UnmanagedType.U1)] ref bool bReaderWriterIsAliveFlag);

    [DllImport("felica.dll", CallingConvention = CallingConvention.Cdecl)]
    [return: MarshalAs(UnmanagedType.U1)]
    public static extern bool reader_writer_is_open(
        [MarshalAs(UnmanagedType.U1)] ref bool bReaderWriterIsOpenFlag);

    [DllImport("felica.dll", CallingConvention = CallingConvention.Cdecl)]
    [return: MarshalAs(UnmanagedType.U1)]
    public static extern bool get_reader_writer_mode
        (ref StructureReaderWriterMode udtReaderWriterMode);

    [DllImport("felica.dll", CallingConvention = CallingConvention.Cdecl)]
    [return: MarshalAs(UnmanagedType.U1)]
    public static extern bool write_block_without_encryption(
        ref InputStructureWriteBlockWithoutEncryption udtInputWriteBlockWithoutEncryption,
        ref OutputStructureWriteBlockWithoutEncryption udtOutputWriteBlockWithoutEncryption
        );

    [DllImport("felica.dll", CallingConvention = CallingConvention.Cdecl)]
    [return: MarshalAs(UnmanagedType.U1)]
    public static extern bool read_block_without_encryption(
        ref InputStructureReadBlockWithoutEncryption udtInputReadBlockWithoutEncryption,
        ref OutputStructureReadBlockWithoutEncryption udtOutputReadBlockWithoutEncryption
        );

    [DllImport("felica.dll", CallingConvention = CallingConvention.Cdecl)]
    [return: MarshalAs(UnmanagedType.U1)]
    public static extern bool close_reader_writer();

    [DllImport("felica.dll", CallingConvention = CallingConvention.Cdecl)]
    [return: MarshalAs(UnmanagedType.U1)]
    public static extern bool dispose_library();

    [DllImport("felica.dll", CallingConvention = CallingConvention.Cdecl)]
    [return: MarshalAs(UnmanagedType.U1)]
    public static extern bool transaction_lock();

    [DllImport("felica.dll", CallingConvention = CallingConvention.Cdecl)]
    [return: MarshalAs(UnmanagedType.U1)]
    public static extern bool transaction_unlock();

    [DllImport("felica.dll", CallingConvention = CallingConvention.Cdecl)]
    [return: MarshalAs(UnmanagedType.U1)]
    //add #9731 体重計アプリとFNSiカードアプリが同時にカードをつかえない。 donghao start
    public static extern bool set_lock_timeout(ulong lock_timeout);

    [DllImport("felica.dll", CallingConvention = CallingConvention.Cdecl)]
    [return: MarshalAs(UnmanagedType.U1)]
    //add #9731 体重計アプリとFNSiカードアプリが同時にカードをつかえない。 donghao end
    public static extern bool dumb(
        ref StructureInputDumb udtInputDumb,
        ref StructureOutputDumb udtOutputDumb
    );

    [DllImport("felica.dll", CallingConvention = CallingConvention.Cdecl)]
    [return: MarshalAs(UnmanagedType.U1)]
    public static extern bool get_last_error_types(
        ref EnumrationFeliCaErrorType eFeliCaErrorType,
        ref EnumrationRwErrorType eRwErrorType
        );

    //Wrapper functions
    public bool InitializeLibrary()
    {
        return initialize_library();
    }
    public bool getVersionInformation(
        StringBuilder sbVersionNumber)
    {
        return get_version_information(
                sbVersionNumber);
    }

    public bool getCopyrightInformation(
        StringBuilder sbCopyright)
    {
        return get_copyright_information(
                    sbCopyright);
    }

    public bool SetReaderWriterControlLibrary(
        string strLibraryFileName)
    {
        return set_reader_writer_control_library(
                strLibraryFileName);
    }

    public bool OpenReaderWriterWithoutEncryption(
        ref StructureOpenReaderWriterModeWithoutEncryption
                    udtOpenReaderWriteModeWithoutEncryption)
    {
        return open_reader_writer_without_encryption(
            ref udtOpenReaderWriteModeWithoutEncryption
        );
    }

    public bool OpenReaderWriterAuto()
    {
        return open_reader_writer_auto();
    }

    public bool ReaderWriterIsAlive(
        ref bool bReaderWriterIsAliveFlag)
    {
        return reader_writer_is_alive(
            ref bReaderWriterIsAliveFlag);
    }
    public bool ReaderWriterIsOpen(
        ref bool bReaderWriterIsOpenFlag)
    {
        return reader_writer_is_open(
            ref bReaderWriterIsOpenFlag);
    }

    public bool GetReaderWriteMode(
        ref StructureReaderWriterMode udtReaderWriterMode)
    {
        return get_reader_writer_mode(
            ref udtReaderWriterMode);
    }

    public bool WriteBlockWithoutEncryption(
        ref InputStructureWriteBlockWithoutEncryption udtInputWriteBlockWithoutEncryption,
        ref OutputStructureWriteBlockWithoutEncryption udtOutputWriteBlockWithoutEncryption)
    {
        return write_block_without_encryption(
                   ref udtInputWriteBlockWithoutEncryption,
                   ref udtOutputWriteBlockWithoutEncryption
        );
    }
    public bool ReadBlockWithoutEncryption(
        ref InputStructureReadBlockWithoutEncryption udtInputReadBlockWithoutEncryption,
        ref OutputStructureReadBlockWithoutEncryption udtOutputReadBlockWithoutEncryption)
    {
        return read_block_without_encryption(
                   ref udtInputReadBlockWithoutEncryption,
                   ref udtOutputReadBlockWithoutEncryption
        );
    }

    public bool CloseReaderWriter()
    {
        return close_reader_writer();
    }

    public bool DisposeLibrary()
    {
        return dispose_library();
    }

    public bool TransactionLock()
    {
        return transaction_lock();
    }

    public bool TransactionUnlock()
    {
        return transaction_unlock();
    }
    //add #9731 体重計アプリとFNSiカードアプリが同時にカードをつかえない。 donghao start
    public bool SetLockTimeout(ulong timeout)
    {
        return set_lock_timeout(timeout);
    }
    //add #9731 体重計アプリとFNSiカードアプリが同時にカードをつかえない。 donghao end
    public bool Dumb(
        ref StructureInputDumb udtInputDumb,
        ref StructureOutputDumb udtOutputDumb)
    {

        return dumb(
                    ref udtInputDumb,
                    ref udtOutputDumb);
    }

    public bool GetLastErrorTypes(
        ref EnumrationFeliCaErrorType eFeliCaErrorType,
        ref EnumrationRwErrorType eRwErrorType)
    {
        return get_last_error_types(
                   ref eFeliCaErrorType,
                   ref eRwErrorType
        );
    }

    public bool PollingAndGetCardInformation(
        ref StructurePolling udtPolling,
        ref byte bytNumberOfCards,
        ref StructureCardInformation udtCardInformation)
    {
        return polling_and_get_card_information(
                   ref udtPolling,
                   ref bytNumberOfCards,
                   ref udtCardInformation
        );
    }

    public bool PollingAndRequestService(
        ref StructurePolling udtPolling,
        ref StructureInputRequestService udtInputRequestService,
        ref StructureCardInformation udtCardInformation,
        ref StructureOutputRequestService udtOutputRequestService)
    {

        return polling_and_request_service(
                    ref udtPolling,
                    ref udtInputRequestService,
                    ref udtCardInformation,
                    ref udtOutputRequestService);
    }

    public bool PollingAndRequestSystemCode(
        ref StructurePolling udtPolling,
        ref StructureInputSystemCode udtInputSystemCode,
        ref StructureCardInformation udtCardInformation,
        ref StructureOutputSystemCode udtOutputSystemCode)
    {

        return polling_and_request_system_code(
                    ref udtPolling,
                    ref udtInputSystemCode,
                    ref udtCardInformation,
                    ref udtOutputSystemCode);
    }

    public bool PollingAndSearchServiceCode(
        ref StructurePolling udtPolling,
        ref StructureInputSearchServiceCode udtInputSearchServiceCode,
        ref StructureCardInformation udtCardInformation,
        ref StructureOutputSearchServiceCode udtOutputSearchServiceCode)
    {

        return polling_and_search_service_code(
                    ref udtPolling,
                    ref udtInputSearchServiceCode,
                    ref udtCardInformation,
                    ref udtOutputSearchServiceCode);
    }

}