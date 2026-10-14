using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;

namespace ParadiseLostCoop {
    // Used by Launch.ps1; applies only to the process launched for this session.
    public static class WindowMode {
        [StructLayout(LayoutKind.Sequential)] public struct Rect { public int Left, Top, Right, Bottom; }
        [StructLayout(LayoutKind.Sequential)] struct MonitorInfo { public int Size; public Rect Monitor, Work; public uint Flags; }
        delegate bool EnumProc(IntPtr window, IntPtr data);
        [DllImport("user32.dll")] static extern bool SetProcessDPIAware();
        [DllImport("user32.dll")] static extern IntPtr GetForegroundWindow();
        [DllImport("user32.dll")] static extern IntPtr MonitorFromWindow(IntPtr window, uint flags);
        [DllImport("user32.dll")] static extern bool GetMonitorInfo(IntPtr monitor, ref MonitorInfo info);
        [DllImport("user32.dll")] static extern bool EnumWindows(EnumProc callback, IntPtr data);
        [DllImport("user32.dll")] static extern uint GetWindowThreadProcessId(IntPtr window, out uint process);
        [DllImport("user32.dll")] static extern bool IsWindowVisible(IntPtr window);
        [DllImport("user32.dll")] static extern bool IsIconic(IntPtr window);
        [DllImport("user32.dll", CharSet=CharSet.Unicode)] static extern int GetClassName(IntPtr window, StringBuilder name, int count);
        [DllImport("user32.dll")] static extern int GetWindowLong(IntPtr window, int index);
        [DllImport("user32.dll")] static extern int SetWindowLong(IntPtr window, int index, int value);
        [DllImport("user32.dll")] static extern bool GetWindowRect(IntPtr window, out Rect rect);
        [DllImport("user32.dll")] static extern bool SetWindowPos(IntPtr window, IntPtr after, int x, int y, int width, int height, uint flags);

        public static Rect CaptureMonitor() {
            SetProcessDPIAware();
            MonitorInfo info=new MonitorInfo(); info.Size=Marshal.SizeOf(typeof(MonitorInfo));
            if(!GetMonitorInfo(MonitorFromWindow(GetForegroundWindow(),2),ref info))
                throw new InvalidOperationException("Could not determine the game monitor.");
            return info.Monitor;
        }
        public static bool Apply(int processId, Rect bounds) {
            bool applied=false;
            EnumWindows(delegate(IntPtr window, IntPtr data) {
                uint owner; GetWindowThreadProcessId(window,out owner);
                if(owner!=(uint)processId || !IsWindowVisible(window) || IsIconic(window))return true;
                var name=new StringBuilder(256); GetClassName(window,name,name.Capacity);
                // Skip splash screens, consoles and error dialogs.
                if(name.ToString().IndexOf("WWindowsViewportWindow",StringComparison.OrdinalIgnoreCase)<0)return true;
                const int decorations=0x00C00000|0x00040000; // caption and sizing frame
                const int edges=0x00000100|0x00000200|0x00020000;
                int style=GetWindowLong(window,-16), extended=GetWindowLong(window,-20);
                bool changed=(style&decorations)!=0 || (extended&edges)!=0;
                if((style&decorations)!=0)SetWindowLong(window,-16,style&~decorations);
                if((extended&edges)!=0)SetWindowLong(window,-20,extended&~edges);
                Rect actual; GetWindowRect(window,out actual);
                if(changed || actual.Left!=bounds.Left || actual.Top!=bounds.Top || actual.Right!=bounds.Right || actual.Bottom!=bounds.Bottom)
                    SetWindowPos(window,IntPtr.Zero,bounds.Left,bounds.Top,bounds.Right-bounds.Left,bounds.Bottom-bounds.Top,0x0004|0x0010|0x0020);
                GetWindowRect(window,out actual);
                applied=actual.Left==bounds.Left && actual.Top==bounds.Top && actual.Right==bounds.Right && actual.Bottom==bounds.Bottom
                    && (GetWindowLong(window,-16)&decorations)==0 && (GetWindowLong(window,-20)&edges)==0;
                return true;
            },IntPtr.Zero);
            return applied;
        }
        public static bool WaitForExit(Process game, Rect bounds) {
            bool applied=false;
            while(!game.HasExited) {
                applied=Apply(game.Id,bounds)||applied;
                game.WaitForExit(500);
            }
            return applied;
        }
    }
}
