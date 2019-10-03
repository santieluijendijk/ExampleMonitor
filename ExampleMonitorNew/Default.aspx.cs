using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Configuration;
using System.Web.Configuration;
using System.Diagnostics;

public partial class _Default : System.Web.UI.Page
{
    TimeSpan Timeout = TimeSpan.FromMinutes(10);

    protected void Page_Load(object sender, EventArgs e)
    {
        Dictionary<String, String> KeyValues = new Dictionary<string, string>();

        foreach (String Key in Request.QueryString.Keys)
        {
            KeyValues.Add(Key, Request.QueryString[Key]);
        }
        foreach (String Key in Request.Form)
        {
            if (!KeyValues.ContainsKey(Key))
            {
                KeyValues.Add(Key, Request.Form[Key]);
            }
        }
        if (!KeyValues.ContainsKey("Form"))
        {
            KeyValues.Add("Form", "MainMenu");
        }
        if (Session["Configuration"] == null || (DateTime.Now - (DateTime)Session["StartTime"] > Timeout))
        {
            Debug.WriteLine(String.Format("Get configuration {0}", DateTime.Now));
            Configuration Configuration = WebConfigurationManager.OpenWebConfiguration("/ExampleMonitorNew");
            DataAbstraction.Cascades.CascadesIOCache2.Instance.Configuration = Configuration;
            Session["Configuration"] = Configuration;
            Session["StartTime"] = DateTime.Now;
        }
        String FormName = KeyValues["Form"];
        String Content = null;
        Content = DataAbstraction.Cascades.CascadesIOCache2.Instance.GetBodyContent(KeyValues["Form"], KeyValues);
        Response.Write(Content);
    }
}