using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using System.Windows.Forms;

namespace ParadiseLostCoop {
public sealed class MusicDeck : UserControl {
    [DllImport("winmm.dll", CharSet=CharSet.Unicode)]
    static extern int mciSendString(string command, StringBuilder result, int length, IntPtr callback);
    [DllImport("winmm.dll", CharSet=CharSet.Unicode)]
    static extern bool mciGetErrorString(int error, StringBuilder text, int length);
    readonly string alias="plmusic"+Guid.NewGuid().ToString("N");
    readonly string file;
    readonly Timer animation=new Timer();
    readonly Button toggle,stop;
    readonly Label caption;
    readonly ToolTip tips=new ToolTip();
    bool opened,playing;
    float angle;
    int ticks;
    public MusicDeck(string path) {
        file=path;Size=new Size(337,76);BackColor=Color.FromArgb(29,30,34);
        SetStyle(ControlStyles.OptimizedDoubleBuffer|ControlStyles.AllPaintingInWmPaint|ControlStyles.UserPaint,true);
        caption=new Label {Text="AH-AH / LAUNCHER RADIO",Location=new Point(85,8),Size=new Size(245,22),ForeColor=Color.FromArgb(233,230,222),Font=new Font("Segoe UI",9,FontStyle.Bold)};
        Controls.Add(caption);
        toggle=MakeButton("PLAY",85,Toggle);stop=MakeButton("STOP",196,Stop);
        tips.SetToolTip(toggle,"Play or pause Ah-Ah");tips.SetToolTip(stop,"Stop and rewind");
        animation.Interval=33;animation.Tick+=delegate {
            if(!playing)return;
            angle=(angle+4)%360;Invalidate(new Rectangle(0,0,78,76));
            if(++ticks%15==0 && Status("mode")=="stopped") {
                if(Command("seek "+alias+" to start") && Command("play "+alias))return;
                SetPlaying(false);
            }
        };animation.Start();
    }
    Button MakeButton(string text,int x,Action action) {
        var b=new Button {Text=text,Location=new Point(x,35),Size=new Size(102,30),FlatStyle=FlatStyle.Flat,BackColor=Color.FromArgb(42,43,48),ForeColor=Color.FromArgb(233,230,222),Cursor=Cursors.Hand,Font=new Font("Segoe UI",9)};
        b.FlatAppearance.BorderColor=Color.FromArgb(66,66,72);b.Click+=delegate{action();};Controls.Add(b);return b;
    }
    bool Command(string command) {
        int code=mciSendString(command,null,0,IntPtr.Zero);
        if(code==0)return true;
        var error=new StringBuilder(256);mciGetErrorString(code,error,error.Capacity);
        caption.Text="AUDIO UNAVAILABLE";tips.SetToolTip(caption,error.ToString());return false;
    }
    public string Status(string key) {
        var value=new StringBuilder(128);
        if(!opened)return "closed";
        mciSendString("status "+alias+" "+key,value,value.Capacity,IntPtr.Zero);return value.ToString().Trim();
    }
    public void Play() {
        if(!opened) {
            if(!File.Exists(file)){caption.Text="TRACK NOT FOUND";return;}
            if(!Command("open \""+file+"\" type mpegvideo alias "+alias))return;
            opened=true;Command("set "+alias+" time format milliseconds");Command("setaudio "+alias+" volume to 250");
        }
        if(Command("play "+alias)) {caption.Text="AH-AH / LAUNCHER RADIO";SetPlaying(true);}
    }
    public void Pause() {if(opened && Command("pause "+alias))SetPlaying(false);}
    public void Stop() {if(opened){Command("stop "+alias);Command("seek "+alias+" to start");}SetPlaying(false);angle=0;Invalidate();}
    void Toggle() {if(playing)Pause();else Play();}
    void SetPlaying(bool value) {playing=value;toggle.Text=value?"PAUSE":"PLAY";Invalidate();}
    protected override void OnPaint(PaintEventArgs e) {
        base.OnPaint(e);var g=e.Graphics;g.SmoothingMode=SmoothingMode.AntiAlias;
        using(var shadow=new SolidBrush(Color.FromArgb(12,12,14)))g.FillEllipse(shadow,6,6,65,65);
        var saved=g.Save();g.TranslateTransform(38,37);g.RotateTransform(angle);
        using(var vinyl=new SolidBrush(Color.FromArgb(15,16,19)))g.FillEllipse(vinyl,-31,-31,62,62);
        using(var groove=new Pen(Color.FromArgb(49,49,54),1))for(int r=18;r<=29;r+=3)g.DrawEllipse(groove,-r,-r,2*r,2*r);
        using(var shine=new Pen(Color.FromArgb(94,94,98),2)) {g.DrawArc(shine,-27,-27,54,54,18,32);g.DrawArc(shine,-27,-27,54,54,198,32);}
        using(var label=new SolidBrush(Color.FromArgb(174,45,39)))g.FillEllipse(label,-14,-14,28,28);
        using(var marker=new Pen(Color.FromArgb(239,224,204),3))g.DrawLine(marker,0,-11,0,-5);
        g.FillEllipse(Brushes.Black,-3,-3,6,6);g.Restore(saved);
        using(var arm=new Pen(Color.FromArgb(166,166,172),3)) {g.DrawLine(arm,69,11,66,42);g.DrawLine(arm,66,42,56,51);}
    }
    protected override void Dispose(bool disposing) {
        if(disposing){animation.Stop();animation.Dispose();tips.Dispose();if(opened){mciSendString("close "+alias,null,0,IntPtr.Zero);opened=false;}}
        base.Dispose(disposing);
    }
}
}
