using System;
using System.Web;

namespace Data_and_Web_Coursework
{
    public class Global : HttpApplication
    {
        protected void Application_Start(object sender, EventArgs e)
        {
            // Start the Golden Hour booking cancellation background worker
            BookingCancellationWorker.Start();
        }

        protected void Application_End(object sender, EventArgs e)
        {
            // Gracefully stop the timer when the app pool shuts down
            BookingCancellationWorker.Stop();
        }

        protected void Application_Error(object sender, EventArgs e)
        {
            Exception ex = Server.GetLastError();
            if (ex != null)
            {
                System.Diagnostics.Trace.TraceError("[Application_Error] {0}", ex.Message);
            }
        }
    }
}
