using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Net;
using System.Net.Sockets;

// Keep the public UDP socket alive while Unreal replaces its map/net driver.
// Each remote endpoint has its own backend socket so players remain distinct.
internal static class UdpRelay {
    sealed class Peer {
        internal Socket Socket;
        internal EndPoint Address;
        internal string Key;
        internal double LastSeen;
    }
    static int Main(string[] args) {
        if(args.Length!=4)return 2;
        int frontPort,backPort,parentId;
        if(!int.TryParse(args[0],out frontPort)||!int.TryParse(args[1],out backPort)
            ||!int.TryParse(args[2],out parentId)||frontPort<1024||frontPort>65535
            ||backPort<1024||backPort>65535||frontPort==backPort)return 2;
        try {
            using(var log=new StreamWriter(args[3],false)) {
                log.AutoFlush=true;
                try {Run(frontPort,backPort,parentId,log);return 0;}
                catch(Exception ex){log.WriteLine("ERROR: "+ex.Message);return 1;}
            }
        } catch {return 1;}
    }
    static void Run(int frontPort,int backPort,int parentId,StreamWriter log) {
        var byAddress=new Dictionary<string,Peer>();
        var bySocket=new Dictionary<Socket,Peer>();
        var clock=Stopwatch.StartNew();
        using(var parent=Process.GetProcessById(parentId))
        using(var front=new Socket(AddressFamily.InterNetwork,SocketType.Dgram,ProtocolType.Udp)) {
            front.ExclusiveAddressUse=true;
            front.Bind(new IPEndPoint(IPAddress.Any,frontPort));
            front.Blocking=false;
            var backend=new IPEndPoint(IPAddress.Loopback,backPort);
            var buffer=new byte[65535];
            double nextMaintenance=0;
            log.WriteLine("READY UDP "+frontPort+" -> 127.0.0.1:"+backPort);
            try {
                while(true) {
                    double now=clock.Elapsed.TotalSeconds;
                    if(now>=nextMaintenance) {
                        parent.Refresh();if(parent.HasExited)break;
                        var expired=new List<Peer>();
                        foreach(var p in bySocket.Values)if(now-p.LastSeen>180)expired.Add(p);
                        foreach(var p in expired){bySocket.Remove(p.Socket);byAddress.Remove(p.Key);p.Socket.Close();}
                        nextMaintenance=now+1;
                    }
                    var ready=new List<Socket>{front};ready.AddRange(bySocket.Keys);
                    Socket.Select(ready,null,null,200000);
                    foreach(var socket in ready) {
                        try {
                            if(socket==front) {
                                EndPoint source=new IPEndPoint(IPAddress.Any,0);
                                int count=front.ReceiveFrom(buffer,ref source);
                                string key=source.ToString();Peer peer;
                                if(!byAddress.TryGetValue(key,out peer)) {
                                    if(byAddress.Count>=64)continue;
                                    var upstream=new Socket(AddressFamily.InterNetwork,SocketType.Dgram,ProtocolType.Udp);
                                    try {upstream.Connect(backend);upstream.Blocking=false;}
                                    catch {upstream.Close();throw;}
                                    peer=new Peer{Socket=upstream,Address=source,Key=key};
                                    byAddress.Add(key,peer);bySocket.Add(upstream,peer);
                                }
                                peer.LastSeen=now;peer.Socket.Send(buffer,0,count,SocketFlags.None);
                            } else {
                                Peer peer=bySocket[socket];
                                int count=socket.Receive(buffer);
                                peer.LastSeen=now;front.SendTo(buffer,0,count,SocketFlags.None,peer.Address);
                            }
                        } catch(SocketException ex) {
                            // A map change temporarily closes the backend port. Keep the
                            // public endpoint and other players alive until it returns.
                            if(ex.SocketErrorCode!=SocketError.ConnectionReset
                                && ex.SocketErrorCode!=SocketError.ConnectionRefused
                                && ex.SocketErrorCode!=SocketError.WouldBlock)throw;
                        }
                    }
                }
            } finally {foreach(var p in bySocket.Values)p.Socket.Close();}
            log.WriteLine("STOPPED: launcher session ended.");
        }
    }
}
