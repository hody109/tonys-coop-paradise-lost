from pathlib import Path
import subprocess, time, json, sys

system = Path(__file__).resolve().parent / 'build' / 'System'
procs = []
si = subprocess.STARTUPINFO()
si.dwFlags |= subprocess.STARTF_USESHOWWINDOW
si.wShowWindow = 0

def start(exe, args, log):
    p = subprocess.Popen([str(system / exe), *args, 'ini=PLCoop5025.ini',
                          'userini=PLCoopUser.ini', f'log={log}', '-unattended', '-newwindow', '-forcelogflush'],
                         cwd=system, startupinfo=si, stdout=subprocess.DEVNULL,
                         stderr=subprocess.STDOUT)
    procs.append(p)
    return p

try:
    server = start('UCC.exe', ['server', 'PL-highlands.fuk?Game=PLCoopAudit.PLCoopTravelProbe?MaxPlayers=3',
                              'MULTIHOME=127.0.0.1'], 'travel-server.log')
    time.sleep(8)
    a = start('PLCoop5025.exe', ['127.0.0.1:7777?Name=PLTestA', '-windowed', '-nosound'], 'travel-client-a.log')
    time.sleep(10)
    b = start('PLCoop5025.exe', ['127.0.0.1:7777?Name=PLTestB', '-windowed', '-nosound'], 'travel-client-b.log')
    print('Both clients launched', flush=True)
    server.wait(timeout=280)
    print(json.dumps({'server_exit': server.poll(), 'client_a_exit': a.poll(), 'client_b_exit': b.poll()}))
finally:
    for p in reversed(procs):
        if p.poll() is None:
            p.terminate()
    for p in procs:
        p.wait(timeout=10)
