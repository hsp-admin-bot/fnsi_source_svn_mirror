using System;
using NKK.FN3.Common.Library.TcpSocket;

namespace ComScaleBed
{
    /// <summary>
    /// 受信データバッファ保持クラス
    /// </summary>
    public class ReceiveDataBuffer
    {

        #region インスタンス変数

        /// <summary>
        /// 受信データバッファ(Byte配列)
        /// </summary>
        private byte[] _buffer;

        //public byte[] Buffer
        //{
        //    get { return (byte[])buffer.Clone(); }
        //    set { buffer = value; }
        //}

        /// <summary>
        /// 受信バッファ長
        /// </summary>
        private int _size;

        public int Size
        {
            get { return _size; }
            set { _size = value; }
        }

        private Exception _except = null;
        
        /// <summary>
        /// 例外情報
        /// </summary>
        public Exception Exception
        {
            get { return this._except; }
        }

        #endregion

        /// <summary>
        /// 受信バッファに受信データを追加する
        /// </summary>
        /// <param name="rs">受信データ</param>
        public void Add(ReceiveStream rs)
        {
            Add(rs.rcvSize, rs.rcvData);
        }

        /// <summary>
        /// 受信バッファに受信データを追加する
        /// </summary>
        /// <param name="rcvSize">受信データ長</param>
        /// <param name="rcvData">受信データByte</param>
        public bool Add(int rcvSize, byte[] rcvData)
        {
            // 受信データをBuffer配列に追加する

            byte[] dataBuffers = new byte[this._size + rcvSize];

            try
            {
                int i;
                // 既に保持しているデータを新規領域にコピーする
                for (i = 0; i < this._size; i++)
                {
                    dataBuffers[i] = this._buffer[i];
                }

                // 今回受信したデータを受信バッファに結合する
                for (i = 0; i < rcvSize; i++)
                {
                    dataBuffers[this._size + i] = rcvData[i];
                }

                // 今回の追加を反映させたBYTE配列をセットする
                this._buffer = dataBuffers;
                this.Size += rcvSize;
                return true;
            }
            catch (Exception ex)
            {
                // 例外発生時にバッファを空にする
                this._except = ex;
                this._size = 0;
                this._buffer = new byte[this._size];
                return false;
            }

        }

        /// <summary>
        /// 保持しているByte配列を返す
        /// </summary>
        /// <returns></returns>
        public byte[] GetBuffer()
        {
            // バッファを返す
            return this._buffer;
        }

        /// <summary>
        /// 指定されたバイト数を内部保持バッファの先頭から除去する
        /// </summary>
        /// <param name="removeLength">先頭から除去するバイト数</param>
        public bool RemoveHead(int removeLength)
        {
            try
            {
                // 指定されたバイト数を内部保持バッファの先頭から除去する
                int length = this.Size - removeLength;
                byte[] leaveBuffer = new byte[length];
                for (int i = 0; i < length; i++)
                {
                    leaveBuffer[i] = this._buffer[removeLength + i];
                }

                // 新しく生成したByte配列をセットする
                this._size = length;
                this._buffer = leaveBuffer;
                return true;
            }
            catch (Exception ex)
            {
                // 例外発生時にバッファを空にする
                this._except = ex;
                this._size = 0;
                this._buffer = new byte[this._size];
                return false;
            }
        }

    }
}
