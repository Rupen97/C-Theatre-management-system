using System;
using System.Diagnostics;
using System.Threading;
using System.Configuration;
using Oracle.ManagedDataAccess.Client;

namespace Data_and_Web_Coursework
{
    /// <summary>
    /// Golden Hour Cancellation Worker.
    /// Runs every 15 minutes and automatically cancels any BOOKING 
    /// with STATUS='Reserved' where the linked showtime starts within 1 hour.
    /// Business Rule: "If a booking remains Reserved within 1 hour of showtime, it is cancelled."
    /// </summary>
    public static class BookingCancellationWorker
    {
        private static Timer _timer;
        private static readonly object _lock = new object();

        private const int IntervalMs = 15 * 60 * 1000; // 15 minutes

        // SQL 1: Delete tickets for 'Reserved' bookings about to expire.
        private const string DeleteTicketsSql = @"
            DELETE FROM ""TICKET"" 
            WHERE BOOKING_ID IN (
                SELECT b.BOOKING_ID 
                FROM ""BOOKING"" b
                JOIN ""SHOWTIME"" s ON b.SHOWTIME_ID = s.SHOW_ID
                WHERE b.STATUS = 'Reserved'
                AND s.START_TIME < (SYSDATE + 1/24)
            )";

        // SQL 2: Cancel all 'Reserved' bookings whose showtime starts within 1 hour from now.
        private const string CancellationSql = @"
            UPDATE ""BOOKING"" 
            SET STATUS = 'Cancelled'
            WHERE STATUS = 'Reserved'
            AND SHOWTIME_ID IN (
                SELECT s.SHOW_ID
                FROM ""SHOWTIME"" s
                WHERE s.START_TIME < (SYSDATE + 1/24)
            )";

        /// <summary>
        /// Start the background timer. Called from Global.asax Application_Start.
        /// </summary>
        public static void Start()
        {
            // Run once immediately then every 15 minutes
            _timer = new Timer(RunCancellationJob, null, TimeSpan.Zero, TimeSpan.FromMilliseconds(IntervalMs));
            Trace.TraceInformation("[BookingCancellationWorker] Started. Interval: 15 min.");
        }

        /// <summary>
        /// Stop the background timer. Called from Global.asax Application_End.
        /// </summary>
        public static void Stop()
        {
            _timer?.Dispose();
            _timer = null;
            Trace.TraceInformation("[BookingCancellationWorker] Stopped.");
        }

        /// <summary>
        /// Execute the cancellation SQL and log the result.
        /// </summary>
        public static int RunNow()
        {
            return RunCancellationCore();
        }

        private static void RunCancellationJob(object state)
        {
            // Prevent overlapping runs if the job takes longer than the interval
            if (!Monitor.TryEnter(_lock)) return;
            try
            {
                int cancelled = RunCancellationCore();
                Trace.TraceInformation(
                    "[BookingCancellationWorker] {0} | Auto-cancelled {1} expired booking(s).",
                    DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"), cancelled);
            }
            finally
            {
                Monitor.Exit(_lock);
            }
        }

        private static int RunCancellationCore()
        {
            try
            {
                string connStr = ConfigurationManager.ConnectionStrings["OracleConn"].ConnectionString;
                using (var conn = new OracleConnection(connStr))
                {
                    conn.Open();
                    
                    // First, delete tickets for bookings being cancelled
                    using (var cmdDel = new OracleCommand(DeleteTicketsSql, conn))
                    {
                        cmdDel.ExecuteNonQuery();
                    }

                    // Then, update booking status
                    using (var cmdUpd = new OracleCommand(CancellationSql, conn))
                    {
                        return cmdUpd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                Trace.TraceError("[BookingCancellationWorker] Error: {0}", ex.Message);
                return 0;
            }
        }
    }
}
