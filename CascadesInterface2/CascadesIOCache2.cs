using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Configuration;
using System.Diagnostics;
using System.Messaging;
using System.IO;
using DataAbstraction.Cascades.Runtime;
using System.Xml.Xsl;
using System.Xml;

namespace DataAbstraction.Cascades
{
    public class CascadesIOCache2
    {
        private static CascadesIOCache2 _Instance;

        //Local dictionary Session 
        private Dictionary<String, Object> Session;
        private static object SyncLock = new Object();
        public Configuration Configuration { get; set; }

        StatusReader CascadesIO;
        TimeSpan Timeout = TimeSpan.FromMinutes(1);
        TimeSpan RefreshTime = TimeSpan.FromSeconds(2);

        private CascadesIOCache2()
        {
            Session = new Dictionary<string, object>();
            Session.Add("CascadesIO2", null);
        }

        public static CascadesIOCache2 Instance
        {
            get
            {
                if (_Instance == null)
                {
                    lock (SyncLock)
                    {
                        if (_Instance == null)
                            _Instance = new CascadesIOCache2();
                    }
                }
                return _Instance;
            }
        }

        private void ResetSessionMessage()
        {
            Session["CascadesIO2"] = CascadesIO;
            Session["StartTime"] = DateTime.Now;
            Session["Message"] = null;
        }

        private void UpdateSessionMessage(Message message)
        {
            Session["Message"] = message;
            Session["StartTime"] = DateTime.Now;
        }

        private void UpdateCascadesIO(Dictionary<String, String> parameters)
        {
            if (Session["CascadesIO2"] == null || (DateTime.Now - (DateTime)Session["StartTime"] > Timeout))
            {
                CascadesIO = new DataAbstraction.Cascades.StatusReader(Configuration);
                RefreshTime = CascadesIO.RefreshTime;
                ResetSessionMessage();
                CascadesIO.Start();
            }
            else
            {
                CascadesIO = Session["CascadesIO2"] as DataAbstraction.Cascades.StatusReader;
            }

            CascadesIO.Connect();
        }

        public String GetBodyContent(String formName, Dictionary<String, String> parameters)
        {
            String Content = null;
            Message Message = null;
            try
            {
                UpdateCascadesIO(parameters);
                if (!Session.ContainsKey("Message") || Session["Message"] == null || (DateTime.Now - (DateTime)Session["StartTime"] > RefreshTime))
                {
                    Message = CascadesIO.Receive();
                    Debug.WriteLine(String.Format("CascadesIO.Receive {0}", DateTime.Now));
                    UpdateSessionMessage(Message);
                }
                else
                {
                    Message = Session["Message"] as Message;
                }
                Content = CascadesIO.TransformBodyContent(Message, formName, parameters);
                CascadesIO.Disconnect();
            }
            catch (Exception e)
            {
                Content = e.ToString();
            }
            return Content;
        }
    }
}
