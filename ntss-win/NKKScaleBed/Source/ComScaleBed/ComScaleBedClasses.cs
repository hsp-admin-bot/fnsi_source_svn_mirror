using NKK.FN3.Common.Library.TcpSocket;
using System;

namespace ComScaleBed
{
    /// <summary>
    /// 接続先情報
    /// </summary>
    public class ComScaleBedConnectionParam
    {
        private string _ipAddress;
        private int _portNo;
        private int _dispOrder;
        private string _bedName;
        private int _bedCd;
        private BaseSocket _socket;

        /// <summary>
        /// 接続先IPアドレス
        /// </summary>
        public string IPAddress
        {
            get { return _ipAddress; }
            set { _ipAddress = value; }
        }
        /// <summary>
        /// 接続先ポートNo.
        /// </summary>
        public int PortNo
        {
            get { return _portNo; }
            set { _portNo = value; }
        }
        /// <summary>
        /// 表示順
        /// </summary>
        public int DispOrder
        {
            get { return _dispOrder; }
            set { _dispOrder = value; }
        }
        /// <summary>
        /// 接続先ベッド名称
        /// </summary>
        public string BedName
        {
            get { return _bedName; }
            set { _bedName = value; }
        }
        /// <summary>
        /// 接続先ベッドコード
        /// </summary>
        public int BedCd
        {
            get { return _bedCd; }
            set { _bedCd = value; }
        }
        /// <summary>
        /// 接続ソケット情報
        /// </summary>
        public BaseSocket Socket
        {
            get { return _socket; }
            set { _socket = value; }
        }
        /// <summary>
        /// 接続先情報
        /// </summary>
        /// <param name="aIPAddress">接続先IPアドレス</param>
        /// <param name="aPortNo">接続先ポートNo.</param>
        /// <param name="aDispOrder">表示順</param>
        /// <param name="aBedCd">接続先ベッドコード</param>
        /// <param name="aBedName">接続先ベッド名称</param>
        public ComScaleBedConnectionParam(string aIPAddress, int aPortNo, int aDispOrder, string aBedName, int aBedCd)
        {
            IPAddress = aIPAddress;
            PortNo = aPortNo;
            DispOrder = aDispOrder;
            BedName = aBedName;
            BedCd = aBedCd;
        }
    }

    /// <summary>
    /// 受信情報
    /// </summary>
    public class ComScaleBedReceivedData
    {
        private string _ipAddress;
        private int _portNo;
        private int _dispOrder;
        private string _bedName;
        private int _bedCd;
        private double _data;
        private string _mdCode;
        private DateTime _recvTime;

        /// <summary>
        /// 受信元IPアドレス
        /// </summary>
        public string IPAddress
        {
            get { return _ipAddress; }
            set { _ipAddress = value; }
        }
        /// <summary>
        /// 受信元ポートNo.
        /// </summary>
        public int PortNo
        {
            get { return _portNo; }
            set { _portNo = value; }
        }
        /// <summary>
        /// 受信元表示順
        /// </summary>
        public int DispOrder
        {
            get { return _dispOrder; }
            set { _dispOrder = value; }
        }
        /// <summary>
        /// 受信元ベッド名称
        /// </summary>
        public string BedName
        {
            get { return _bedName; }
            set { _bedName = value; }
        }
        /// <summary>
        /// 受信元ベッドコード
        /// </summary>
        public int BedCd
        {
            get { return _bedCd; }
            set { _bedCd = value; }
        }
        /// <summary>
        /// 受信データ(測定値)
        /// </summary>
        public double Data
        {
            get { return _data; }
            set { _data = value; }
        }
        /// <summary>
        /// 受信データ（MDコード）
        /// </summary>
        public string MDCode
        {
            get { return _mdCode; }
            set { _mdCode = value; }
        }
        /// <summary>
        /// 受信時間
        /// </summary>
        public DateTime RecvTime
        {
            get { return _recvTime; }
            set { _recvTime = value; }
        }

        /// <summary>
        /// 受信バッファ
        /// </summary>
        private ReceiveDataBuffer _receiveBuffer = new ReceiveDataBuffer();

        /// <summary>
        /// 受信バッファ
        /// </summary>
        public ReceiveDataBuffer ReceiveBuffer
        {
            get { return _receiveBuffer; }
            set { _receiveBuffer = value; }
        }

        /// <summary>
        /// 受信元情報
        /// </summary>
        /// <param name="aIPAddress">受信元IPアドレス</param>
        /// <param name="aPortNo">受信元ポートNo.</param>
        /// <param name="aBedCd">受信元ベッドコード</param>
        public ComScaleBedReceivedData(string aIPAddress, int aPortNo, int aDispOrder, string aBedName, int aBedCd)
        {
            IPAddress = aIPAddress;
            PortNo = aPortNo;
            DispOrder = aDispOrder;
            BedName = aBedName;
            BedCd = aBedCd;
        }

        /// <summary>
        /// 受信元情報
        /// </summary>
        /// <param name="aIPAddress">受信元IPアドレス</param>
        /// <param name="aPortNo">受信元ポートNo.</param>
        /// <param name="aBedCd">受信元ベッドコード</param>
        /// <param name="aData">受信データ</param>
        /// <param name="aDM">受信データ（DM）</param>
        /// <param name="aDt">受信時間</param>
        public ComScaleBedReceivedData(string aIPAddress, int aPortNo, int aDispOrder, string aBedName, int aBedCd, double aData, string aDM, DateTime aDt)
        {
            IPAddress = aIPAddress;
            PortNo = aPortNo;
            DispOrder = aDispOrder;
            BedName = aBedName;
            BedCd = aBedCd;
            Data = aData;
            MDCode = aDM;
            RecvTime = aDt;
        }
    }
}
