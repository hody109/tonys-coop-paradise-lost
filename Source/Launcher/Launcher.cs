using System;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Windows.Forms;
using System.Xml;

namespace ParadiseLostCoop {
internal sealed class LauncherButton : Button {
    protected override void OnPaint(PaintEventArgs e) {
        base.OnPaint(e);
        if(Enabled)return;
        using(var fill=new SolidBrush(BackColor))e.Graphics.FillRectangle(fill,ClientRectangle);
        using(var border=new Pen(Color.FromArgb(66,66,72)))e.Graphics.DrawRectangle(border,0,0,Width-1,Height-1);
        TextRenderer.DrawText(e.Graphics,Text,Font,ClientRectangle,Color.FromArgb(132,128,126),TextFormatFlags.HorizontalCenter|TextFormatFlags.VerticalCenter);
    }
}

public sealed partial class Launcher : Form {
    readonly string root = AppDomain.CurrentDomain.BaseDirectory;
    readonly Color background = Color.FromArgb(19,20,23), panel = Color.FromArgb(29,30,34), ink = Color.FromArgb(233,230,222), muted = Color.FromArgb(160,160,166), red = Color.FromArgb(174,45,39);
    TextBox nickname, address, installation, activity;
    NumericUpDown port, players;
    ComboBox character, difficulty;
    static readonly string[] DifficultyNames={"Liebermode","Too Easy","Very Easy","Easy","Remedial","Average","Aggressive","Hard","Very Hard","Manic","Hestonworld","Insane-o","They Hate Me","POSTAL","Impossible"};
    readonly ToolTip hints=new ToolTip();
    CheckBox listen, fullscreen;
    Button newGame, resume, join, install, browse;
    Label status, checkpoint;
    MusicDeck music;
    Image launcherArt;
    static bool renderPreview;
    Process worker;
    Process testClient;
    Button testPlayer;
    string operation;
    readonly StringBuilder output = new StringBuilder();
    readonly Timer timer = new Timer();

    [STAThread] public static void Main(string[] args) {
        Application.EnableVisualStyles(); Application.SetCompatibleTextRenderingDefault(false);
        if (args.Length > 0 && args[0] == "--self-test") { SelfTest(); return; }
        if(args.Length>0 && args[0]=="--render-preview") {
            renderPreview=true;
            using(var form=new Launcher()) {
                form.Opacity=0;form.Show();Application.DoEvents();
                using(var bitmap=new Bitmap(form.ClientSize.Width,form.ClientSize.Height)) {
                    // Render the client area without the Windows frame.
                    using(var full=new Bitmap(form.Width,form.Height)) {
                        form.DrawToBitmap(full,new Rectangle(Point.Empty,form.Size));
                        Point origin=form.PointToScreen(Point.Empty)-new Size(form.Location);
                        using(var g=Graphics.FromImage(bitmap))g.DrawImage(full,-origin.X,-origin.Y);
                    }
                    bitmap.Save(Path.Combine(form.root,"Validation\\launcher-preview.png"));
                }
            }
            return;
        }
        Application.Run(new Launcher());
    }
    public Launcher() {
        Text="Tony's coop: Paradise Lost"; ClientSize=new Size(860,690); MinimumSize=MaximumSize=Size;
        FormBorderStyle=FormBorderStyle.FixedSingle; MaximizeBox=false; StartPosition=FormStartPosition.CenterScreen;
        BackColor=background; ForeColor=ink; Font=new Font("Segoe UI",10); AutoScaleMode=AutoScaleMode.Dpi;
        DoubleBuffered=true;
        string art=Path.Combine(root,"Assets\\dude.png");
        if(File.Exists(art))using(var source=Image.FromFile(art))launcherArt=new Bitmap(source);
        Label title=LabelAt("TONY'S COOP",26,22,450,48,27,ink); title.Font=new Font("Segoe UI",27,FontStyle.Bold);
        LabelAt("PARADISE LOST / COMMUNITY BUILD",29,73,420,23,9,Color.FromArgb(234,139,104));
        LabelAt("Return to Paradise. Bring a friend.",29,104,420,26,12,ink);
        LabelAt("PLAYER",29,143,170,20,8,muted);
        nickname=Input("Dude",29,165,177);
        LabelAt("CHARACTER",224,143,220,20,8,muted);
        character=new ComboBox{Location=new Point(224,165),Size=new Size(220,28),DropDownStyle=ComboBoxStyle.DropDownList,BackColor=panel,ForeColor=ink,Font=new Font("Segoe UI",10)};
        character.Items.AddRange(new object[]{"Paradise Lost Dude (default)","Classic Dude","Red Dude","Blue Dude","Beta Dude","Santa Dude","Taliban Dude","Scientist Dude","Scientist Dude (alternative)","Eternal Damnation Dude","Corkscrew Dude","Corkscrew Dude (alternative)","POSTAL 1 Dude","POSTAL 3 Dude","POSTAL Redux Dude","Punisher Dude"});
        character.FlatStyle=FlatStyle.Flat;character.DrawMode=DrawMode.OwnerDrawFixed;character.ItemHeight=22;
        character.DrawItem+=delegate(object sender,DrawItemEventArgs e) {
            bool selected=(e.State&DrawItemState.Selected)!=0;
            using(var fill=new SolidBrush(selected?red:panel))e.Graphics.FillRectangle(fill,e.Bounds);
            if(e.Index>=0)TextRenderer.DrawText(e.Graphics,character.Items[e.Index].ToString(),character.Font,e.Bounds,ink,TextFormatFlags.Left|TextFormatFlags.VerticalCenter|TextFormatFlags.EndEllipsis);
            e.DrawFocusRectangle();
        };
        character.SelectedIndex=0;Controls.Add(character);
        LabelAt("HOST A CAMPAIGN",29,211,400,22,10,ink);
        newGame=ButtonAt("NEW CAMPAIGN",29,240,198,43,delegate { Play(listen.Checked?"ListenNew":"New"); },true);
        resume=ButtonAt("CONTINUE",239,240,205,43,delegate { Play(listen.Checked?"ListenContinue":"Continue"); },false);
        LabelAt("PLAYERS",29,297,110,20,8,muted); players=Number(29,318,65,2,8,4);
        LabelAt("UDP PORT",112,297,120,20,8,muted); port=Number(112,318,112,1024,65535,7777);
        LabelAt("DIFFICULTY (NEW GAME)",242,297,202,20,8,muted);
        difficulty=new ComboBox{Location=new Point(242,318),Size=new Size(202,29),DropDownStyle=ComboBoxStyle.DropDownList,BackColor=panel,ForeColor=ink,FlatStyle=FlatStyle.Flat,Font=new Font("Segoe UI",11)};
        difficulty.Items.AddRange(DifficultyNames);difficulty.SelectedIndex=5;Controls.Add(difficulty);
        hints.SetToolTip(difficulty,"Host's new campaign difficulty. Continue keeps the saved difficulty. Joining uses the host's setting.");
        fullscreen=new CheckBox {Text="Fullscreen",Location=new Point(29,356),Size=new Size(125,24),BackColor=Color.Transparent,ForeColor=ink};Controls.Add(fullscreen);
        listen=new CheckBox {Text="Direct host (experimental)",Location=new Point(165,356),Size=new Size(279,24),BackColor=Color.Transparent,ForeColor=muted,Font=new Font("Segoe UI",9)};Controls.Add(listen);
        checkpoint=LabelAt("",29,385,415,35,9,muted);
        LabelAt("JOIN A FRIEND",29,425,400,20,9,ink);
        address=Input("",29,449,280);
        join=ButtonAt("JOIN GAME",321,447,123,34,delegate { Play("Join"); },false);
        LabelAt("GAME INSTALLATION",29,493,400,20,8,muted);
        installation=Input(@"C:\Program Files (x86)\Steam\steamapps\common\POSTAL2Complete",29,516,280);
        installation.Font=new Font("Segoe UI",9);
        browse=ButtonAt("...",321,513,32,32,delegate { using(var d=new FolderBrowserDialog()) { d.Description="Select your POSTAL2Complete folder"; if(Directory.Exists(installation.Text))d.SelectedPath=installation.Text; if(d.ShowDialog(this)==DialogResult.OK)installation.Text=d.SelectedPath; } },false);
        install=ButtonAt("SET UP",365,513,79,32,delegate { SetUp(); },false);install.Font=new Font("Segoe UI",8);
        status=LabelAt("",29,556,415,34,9,ink);
        activity=new TextBox {Location=new Point(29,596),Size=new Size(415,41),Multiline=true,ReadOnly=true,ScrollBars=ScrollBars.Vertical,BackColor=panel,ForeColor=muted,BorderStyle=BorderStyle.None,Font=new Font("Consolas",8)};Controls.Add(activity);
        ButtonAt("HELP",29,651,88,27,delegate { OpenFile("README-LAUNCHER.txt"); },false);
        ButtonAt("LOGS",129,651,88,27,delegate { OpenFolder("Runtime\\System"); },false);
        ButtonAt("INTERNET",229,651,215,27,delegate { Internet(); },false);
        music=new MusicDeck(Path.Combine(root,"Assets\\Ah-Ah.mp3")){Location=new Point(499,550)};Controls.Add(music);
        testPlayer=ButtonAt("TEST SECOND PLAYER",499,645,337,33,StartTestPlayer,false);
        Shown+=delegate {if(!renderPreview)music.Play();};
        LoadSettings(); RefreshReady();testPlayer.Enabled=false;
        timer.Interval=250; timer.Tick+=Poll; timer.Start();
        FormClosing+=delegate(object sender,FormClosingEventArgs e) { if(worker!=null&&!worker.HasExited) { e.Cancel=true; WindowState=FormWindowState.Minimized; } else {SaveSettings();StopAgent();} };
    }
    protected override void OnPaintBackground(PaintEventArgs e) {
        base.OnPaintBackground(e);
        if(launcherArt==null)return;
        e.Graphics.DrawImage(launcherArt,ClientRectangle);
        using(var shade=new System.Drawing.Drawing2D.LinearGradientBrush(ClientRectangle,Color.Black,Color.Transparent,0f)) {
            shade.InterpolationColors=new System.Drawing.Drawing2D.ColorBlend {
                Positions=new float[]{0f,0.49f,0.67f,1f},
                Colors=new Color[]{Color.FromArgb(232,12,10,10),Color.FromArgb(222,12,10,10),Color.FromArgb(35,12,10,10),Color.FromArgb(0,12,10,10)}
            };
            e.Graphics.FillRectangle(shade,ClientRectangle);
        }
        using(var rule=new Pen(Color.FromArgb(110,184,65,39))) {
            e.Graphics.DrawLine(rule,29,136,444,136);
            e.Graphics.DrawLine(rule,29,421,444,421);
            e.Graphics.DrawLine(rule,29,489,444,489);
        }
    }
    protected override void Dispose(bool disposing) {
        if(disposing){hints.Dispose();timer.Dispose();if(launcherArt!=null){launcherArt.Dispose();launcherArt=null;}}
        base.Dispose(disposing);
    }
    Label LabelAt(string text,int x,int y,int w,int h,float size,Color color) { var l=new Label{Text=text,Location=new Point(x,y),Size=new Size(w,h),Font=new Font("Segoe UI",size),ForeColor=color,BackColor=Color.Transparent};Controls.Add(l);l.BringToFront();return l; }
    TextBox Input(string value,int x,int y,int w) { var t=new TextBox{Text=value,Location=new Point(x,y),Size=new Size(w,32),Font=new Font("Segoe UI",12),BackColor=panel,ForeColor=ink,BorderStyle=BorderStyle.FixedSingle};Controls.Add(t);return t; }
    NumericUpDown Number(int x,int y,int w,int min,int max,int value) { var n=new NumericUpDown{Location=new Point(x,y),Size=new Size(w,32),Minimum=min,Maximum=max,Value=value,BackColor=panel,ForeColor=ink,Font=new Font("Segoe UI",12)};Controls.Add(n);n.BringToFront();return n; }
    Button ButtonAt(string text,int x,int y,int w,int h,Action action,bool primary) { var b=new LauncherButton{Text=text,Location=new Point(x,y),Size=new Size(w,h),FlatStyle=FlatStyle.Flat,BackColor=primary?red:panel,ForeColor=ink,Cursor=Cursors.Hand,UseVisualStyleBackColor=false};b.FlatAppearance.BorderColor=primary?red:Color.FromArgb(66,66,72);b.Click+=delegate{action();};Controls.Add(b);b.BringToFront();return b; }
    bool Ready { get { return File.Exists(Path.Combine(root,"Runtime\\System\\PLCoop5025.exe")) && File.Exists(Path.Combine(root,"Runtime\\System\\Server.ini")); } }
    string SavedMap() { string f=Path.Combine(root,"Runtime\\System\\NicksCoopSave.ini"); if(!File.Exists(f))return ""; Match m=Regex.Match(File.ReadAllText(f),@"(?im)^CoopSave_ServerNextLevel=(.+)$"); return m.Success?m.Groups[1].Value.Trim():""; }
    void RefreshReady() { bool ready=Ready;string map=SavedMap();newGame.Enabled=join.Enabled=ready;resume.Enabled=ready&&map.Length>0;install.Text=ready?"VERIFY":"SET UP";checkpoint.Text=map.Length>0?"Checkpoint: "+map.Split('?')[0]:"No checkpoint yet. Progress is saved when you change locations.";status.Text=ready?"Ready to play":"Select your game folder, then choose SET UP."; }
    void Busy(bool busy) { foreach(Control c in Controls) if(c is Button||c is TextBox||c is NumericUpDown||c is CheckBox||c is ComboBox)c.Enabled=!busy;activity.Enabled=true; testPlayer.Enabled=false; if(!busy)RefreshReady(); }
    void Play(string mode) {
        if(!Regex.IsMatch(nickname.Text,@"^[A-Za-z0-9_-]{1,24}$")) { status.Text="Enter a nickname using 1-24 letters, numbers, _ or -.";nickname.Focus();return; }
        if(mode=="Join"&&!ValidAddress(address.Text,false)) { status.Text="Enter your friend's IP address or hostname.";address.Focus();return; }
        if(mode!="Join"&&useInternet){
            if(!File.Exists(Path.Combine(PlayitDir,"playit.toml"))||publicAddress.Length==0){Internet();status.Text="Link Playit and save your public address before hosting online.";return;}
            try{if(!StartAgent())return;}catch(Exception ex){status.Text=ex.Message;return;}
        }
        hostingSession=mode!="Join";
        SaveSettings(); string args="-Mode "+mode+" -PlayerName "+Quote(nickname.Text)+" -Port "+port.Value+" -MaxPlayers "+players.Value;
        args+=" -Character "+character.SelectedIndex;
        if(mode=="New"||mode=="ListenNew")args+=" -Difficulty "+difficulty.SelectedIndex;
        if(mode=="Join")args+=" -Address "+Quote(address.Text); if(fullscreen.Checked)args+=" -Fullscreen";
        music.Pause();
        RunScript("Launch.ps1",args,"Game session");
    }
    void SetUp() { if(!Directory.Exists(installation.Text)) { status.Text="Choose an existing POSTAL2Complete folder.";return; }SaveSettings();RunScript("Setup.ps1","-GamePath "+Quote(installation.Text)+(Ready?" -CheckOnly":""),Ready?"File verification":"Installation"); }
    void RunScript(string name,string args,string label) {
        if(worker!=null)return;
        try {
            lock(output){output.Clear();}activity.Clear();operation=label;
            var info=new ProcessStartInfo(Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.System),"WindowsPowerShell\\v1.0\\powershell.exe"),"-NoProfile -ExecutionPolicy Bypass -File "+Quote(Path.Combine(root,name))+" "+args);
            info.WorkingDirectory=root;info.UseShellExecute=false;info.CreateNoWindow=true;info.RedirectStandardOutput=info.RedirectStandardError=true;
            // Windows PowerShell must initialize its own module paths, not inherit PowerShell 7 paths.
            info.EnvironmentVariables.Remove("PSModulePath");
            worker=new Process{StartInfo=info}; worker.OutputDataReceived+=Receive;worker.ErrorDataReceived+=Receive;
            worker.Start();worker.BeginOutputReadLine();worker.BeginErrorReadLine();Busy(true);status.Text=label+" running. Keep the launcher open; closing it minimizes it.";
        } catch(Exception ex) { if(worker!=null)worker.Dispose();worker=null;if(label=="Game session" && hostingSession)StopAgent();Busy(false);status.Text="Could not start. See details below.";activity.Text=ex.Message; }
    }
    void Receive(object sender,DataReceivedEventArgs e) { if(e.Data!=null)lock(output){output.AppendLine(e.Data);} }
    void Poll(object sender,EventArgs e) {
        if(testClient!=null && testClient.HasExited){testClient.Dispose();testClient=null;}
        lock(output){testPlayer.Enabled=Ready && worker!=null && hostingSession && operation=="Game session" && testClient==null && output.ToString().Contains("Starting the game.");}
        if(worker==null)return;string text;lock(output){text=output.ToString();}if(activity.Text!=text){activity.Text=text;activity.SelectionStart=activity.TextLength;activity.ScrollToCaret();}if(worker.HasExited){worker.WaitForExit();int code=worker.ExitCode;lock(output){activity.Text=output.ToString();}worker.Dispose();worker=null;Busy(false);if(operation=="Game session"){if(hostingSession)StopAgent();Show();WindowState=FormWindowState.Normal;Activate();}status.Text=code==0?operation+" finished.":operation+" failed. See details above.";} }
    void StartTestPlayer() {
        if(testClient!=null || worker==null || !hostingSession)return;
        try {
            if(!ValidAddress(publicAddress,true)) {
                status.Text="Save your Playit public address in INTERNET before testing.";return;
            }
            if(!File.Exists(Path.Combine(PlayitDir,"playit.toml"))) {
                status.Text="Link your Playit agent in INTERNET before testing.";return;
            }
            if(!StartAgent())return;
            string system=Path.Combine(root,"Runtime\\System");
            File.Copy(Path.Combine(system,"Client.ini"),Path.Combine(system,"TestClient.ini"),true);
            if(!File.Exists(Path.Combine(system,"TestClientUser.ini")))
                File.Copy(Path.Combine(system,"PLCoopUser.ini"),Path.Combine(system,"TestClientUser.ini"));
            string guest=nickname.Text.Substring(0,Math.Min(18,nickname.Text.Length))+"_Test";
            string url=publicAddress+"?Name="+guest+"?PLHostKey=?Skin=MPSkins.BlueTeam.MW__007__Avg_Dude";
            testClient=Process.Start(new ProcessStartInfo(Path.Combine(system,"PLCoop5025.exe"),Quote(url)+" ini=TestClient.ini userini=TestClientUser.ini log=PLCoop-TestPlayer.log -windowed -newwindow") {WorkingDirectory=system,UseShellExecute=false});
            status.Text="Test player connecting through Playit. Use Alt+Tab to switch games.";
        } catch(Exception ex){status.Text="Test player could not start: "+ex.Message;}
    }
    void OpenFile(string relative) { try { Process.Start(new ProcessStartInfo(Path.Combine(root,relative)){UseShellExecute=true}); }catch(Exception ex){status.Text=ex.Message;} }
    void OpenFolder(string relative) { string path=Path.Combine(root,relative);if(Directory.Exists(path))OpenFile(relative);else status.Text="Set up the game first."; }
    void SaveSettings() { try { string destination=Path.Combine(root,"launcher-settings.xml");string temporary=destination+".tmp"; using(XmlWriter w=XmlWriter.Create(temporary,new XmlWriterSettings{Indent=true})) {w.WriteStartElement("settings");w.WriteElementString("character",character.SelectedIndex.ToString());w.WriteElementString("difficulty",difficulty.SelectedIndex.ToString());w.WriteElementString("nickname",nickname.Text);w.WriteElementString("address",address.Text);w.WriteElementString("installation",installation.Text);w.WriteElementString("port",port.Value.ToString());w.WriteElementString("players",players.Value.ToString());w.WriteElementString("listen",listen.Checked.ToString());w.WriteElementString("fullscreen",fullscreen.Checked.ToString());w.WriteElementString("useInternet",useInternet.ToString());w.WriteElementString("publicAddress",publicAddress);w.WriteEndElement();} if(File.Exists(destination))File.Replace(temporary,destination,destination+".bak");else File.Move(temporary,destination); }catch(Exception ex){activity.Text="Could not save launcher preferences: "+ex.Message;} }
    void LoadSettings() { try {var doc=new XmlDocument();doc.XmlResolver=null;string f=Path.Combine(root,"launcher-settings.xml");if(!File.Exists(f))return;doc.Load(f);int difficultyIndex;if(int.TryParse(Value(doc,"difficulty","5"),out difficultyIndex)&&difficultyIndex>=0&&difficultyIndex<DifficultyNames.Length)difficulty.SelectedIndex=difficultyIndex;int skinIndex;if(int.TryParse(Value(doc,"character","0"),out skinIndex)&&skinIndex>=0&&skinIndex<character.Items.Count)character.SelectedIndex=skinIndex;nickname.Text=Value(doc,"nickname",nickname.Text);address.Text=Value(doc,"address",address.Text);installation.Text=Value(doc,"installation",installation.Text);decimal n;if(decimal.TryParse(Value(doc,"port","7777"),out n))port.Value=Math.Max(port.Minimum,Math.Min(port.Maximum,n));if(decimal.TryParse(Value(doc,"players","4"),out n))players.Value=Math.Max(players.Minimum,Math.Min(players.Maximum,n));listen.Checked=Value(doc,"listen","False")=="True";fullscreen.Checked=Value(doc,"fullscreen","False")=="True";useInternet=Value(doc,"useInternet","False")=="True";publicAddress=Value(doc,"publicAddress","");}catch{activity.Text="Preferences could not be loaded. Using defaults.";} }
    internal static bool ValidAddress(string value,bool requirePort) {
        Match match=Regex.Match(value??"",@"^[A-Za-z0-9][A-Za-z0-9.-]*(?::(?<port>[0-9]{1,5}))?$");
        if(!match.Success)return false;
        if(!match.Groups["port"].Success)return !requirePort;
        int number;
        return int.TryParse(match.Groups["port"].Value,out number) && number>=1 && number<=65535;
    }
    static string Value(XmlDocument doc,string name,string fallback) {XmlNode node=doc.SelectSingleNode("/settings/"+name);return node==null?fallback:node.InnerText;}
    // Windows CommandLineToArgvW quoting; values are arguments, never shell source.
    internal static string Quote(string value) {return "\""+Regex.Replace(value,@"(\\*)\""","$1$1\\\"")+Regex.Match(value,@"\\*$").Value+"\"";}
    static void SelfTest() { if(Quote("hello world")!="\"hello world\""||Quote("C:\\test\\")!="\"C:\\test\\\\\"")throw new Exception("Argument quoting failed");using(var form=new Launcher()){if(form.Ready&&!form.newGame.Enabled)throw new Exception("Ready state failed");if(form.ClientSize.Width<800)throw new Exception("Layout failed");}File.WriteAllText(Path.Combine(AppDomain.CurrentDomain.BaseDirectory,"launcher-selftest.txt"),"PASS: argument quoting, form construction, runtime readiness."); }
}
}


