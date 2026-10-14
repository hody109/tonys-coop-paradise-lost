using System;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Security.Cryptography;
using System.Text.RegularExpressions;
using System.Windows.Forms;

namespace ParadiseLostCoop {
public sealed partial class Launcher {
    Process tunnel;
    Form internetDialog;
    TextBox internetLog;
    string claimUrl="", publicAddress="";
    bool useInternet;
    bool hostingSession;
    string PlayitDir { get { return Path.Combine(root,"Private\\Playit"); } }
    bool AgentRunning { get { return tunnel!=null&&!tunnel.HasExited; } }
    void Web(string url) { Process.Start(new ProcessStartInfo(url){UseShellExecute=true}); }
    void Internet() {
        if(internetDialog!=null&&!internetDialog.IsDisposed){internetDialog.Activate();return;}
        var d=new Form {Text="Internet play - Playit.gg",ClientSize=new Size(740,525),StartPosition=FormStartPosition.CenterParent,BackColor=background,ForeColor=ink,Font=Font,FormBorderStyle=FormBorderStyle.FixedDialog,MaximizeBox=false};
        internetDialog=d;
        d.Controls.Add(new Label{Text="Host from your PC. Friends join using your public address.",Location=new Point(20,18),Size=new Size(700,25)});
        d.Controls.Add(new Label{Text="1. Install the agent, then START / LINK AGENT.\n2. OPEN LINK to approve it in your Playit account.\n3. In DASHBOARD add a Custom UDP tunnel (1 port).\n    Local address: 127.0.0.1   Local port: "+port.Value+"\n4. Paste its public hostname:port below and share it with your friend.",Location=new Point(20,50),Size=new Size(700,115)});
        Action<string,int,int,Action> button=(text,x,width,action)=>{var b=new Button{Text=text,Location=new Point(x,175),Size=new Size(width,35),BackColor=panel,ForeColor=ink,FlatStyle=FlatStyle.Flat};b.Click+=delegate{try{action();}catch(Exception e){MessageBox.Show(d,e.Message,"Playit");}};d.Controls.Add(b);};
        button("INSTALL",20,100,()=>{if(worker!=null){MessageBox.Show(d,"Wait for the current operation to finish.");return;}RunScript("InstallPlayit.ps1","","Playit installation");});
        button("START / LINK AGENT",130,190,()=>StartAgent());
        button("OPEN LINK",330,120,()=>{if(claimUrl.Length==0){MessageBox.Show(d,"Start the agent first. If already linked, use DASHBOARD.");return;}Web(claimUrl);});
        button("DASHBOARD",460,140,()=>Web("https://playit.gg/account/tunnels"));
        button("STOP",610,105,()=>StopAgent());
        var input=new TextBox{Text=publicAddress,Location=new Point(20,225),Size=new Size(535,28),BackColor=panel,ForeColor=ink};d.Controls.Add(input);
        var copy=new Button{Text="SAVE / COPY",Location=new Point(565,222),Size=new Size(150,34),BackColor=panel,ForeColor=ink};d.Controls.Add(copy);
        copy.Click+=delegate{if(!ValidAddress(input.Text.Trim(),true)){MessageBox.Show(d,"Enter the public hostname:port shown by Playit.");return;}publicAddress=input.Text.Trim();Clipboard.SetText(publicAddress);SaveSettings();};
        var enabled=new CheckBox{Text="Start Playit automatically when I host",Checked=useInternet,Location=new Point(20,270),Size=new Size(650,25)};d.Controls.Add(enabled);enabled.CheckedChanged+=delegate{useInternet=enabled.Checked;SaveSettings();};
        internetLog=new TextBox{Location=new Point(20,310),Size=new Size(695,155),Multiline=true,ReadOnly=true,ScrollBars=ScrollBars.Vertical,BackColor=panel,ForeColor=ink,Text=AgentRunning?"Agent process running. Confirm Online in the Playit dashboard.":"Agent stopped."};d.Controls.Add(internetLog);
        d.Controls.Add(new Label{Text="Keep your PC on. Only the host needs Playit. After changing the game port,\nupdate the tunnel's local port too. The launcher stops its agent when hosting ends.",Location=new Point(20,478),Size=new Size(700,42),ForeColor=muted});
        d.Show(this);
    }
    bool StartAgent() {
        if(AgentRunning)return true;
        string exe=Path.Combine(PlayitDir,"playit.exe");
        if(!File.Exists(exe)){Internet();MessageBox.Show(internetDialog,"Choose INSTALL first.","Playit");return false;}
        using(var sha=SHA256.Create())using(var stream=File.OpenRead(exe)) {
            if(BitConverter.ToString(sha.ComputeHash(stream)).Replace("-","")!="B2BCFF05044D1B01F3D557E4FC9E8F4DF4BF8FC328DF3010380F82D9C7565684")throw new Exception("Playit checksum mismatch. Reinstall the agent.");
        }
        if(tunnel!=null)tunnel.Dispose();
        var si=new ProcessStartInfo(exe,"--stdout --secret_path "+Quote(Path.Combine(PlayitDir,"playit.toml"))+" start"){WorkingDirectory=PlayitDir,UseShellExecute=false,CreateNoWindow=true,RedirectStandardOutput=true,RedirectStandardError=true};
        tunnel=null;claimUrl="";
        var candidate=new Process{StartInfo=si};
        candidate.OutputDataReceived+=AgentOutput;candidate.ErrorDataReceived+=AgentOutput;
        try {candidate.Start();tunnel=candidate;candidate.BeginOutputReadLine();candidate.BeginErrorReadLine();return true;}
        catch {if(tunnel!=null)StopAgent();else candidate.Dispose();throw;}
    }
    void AgentOutput(object sender,DataReceivedEventArgs e) {
        if(e.Data==null||IsDisposed||!IsHandleCreated)return;
        string line=e.Data;
        // Agent credentials stay in its private config, never in launcher output.
        if(Regex.IsMatch(line,@"(?i)secret[_ -]?(key)?\s*[:=]"))return;
        try{BeginInvoke((Action)delegate{
            Match m=Regex.Match(line,@"https://playit\.gg/claim/[A-Za-z0-9-]+");if(m.Success)claimUrl=m.Value;
            if(internetLog!=null&&!internetLog.IsDisposed){if(internetLog.TextLength>18000)internetLog.Clear();internetLog.AppendText(line+Environment.NewLine);}
        });}catch(InvalidOperationException){}
    }
    void StopAgent() {if(tunnel==null)return;try{if(!tunnel.HasExited){tunnel.Kill();tunnel.WaitForExit(3000);}}catch(InvalidOperationException){}catch(System.ComponentModel.Win32Exception ex){status.Text="Could not stop Playit: "+ex.Message;}finally{tunnel.Dispose();tunnel=null;}if(internetLog!=null&&!internetLog.IsDisposed)internetLog.AppendText("\r\nAgent stopped.\r\n");}
}
}
