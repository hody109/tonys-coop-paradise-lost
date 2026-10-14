from pathlib import Path
import subprocess, json, time

system = Path(__file__).resolve().parent / 'build' / 'System'
out = Path(__file__).resolve().parent / 'day-tests'
out.mkdir(exist_ok=True)
maps = ['PL-highlands', 'PL-Church', 'PL-Junkyard#Junkyardstart',
        'PL-ColemanCave', 'PL-ToraBora', 'PL-Hell_ent', 'pl-suburbs-3#ApocPad?peer']
results = []
si = subprocess.STARTUPINFO()
si.dwFlags |= subprocess.STARTF_USESHOWWINDOW
si.wShowWindow = 0
for day, url in enumerate(maps):
    dest = out / f'day-{day}.log'
    with dest.open('w') as f:
        p = subprocess.Popen([str(system/'UCC.exe'), 'server',
            url + f'?Game=PLCoopAudit.PLCoopCampaignProbe?PLTestDay={day}',
            'ini=PLCoop5025.ini', f'log=probe-{day}.log', 'MULTIHOME=127.0.0.1',
            '-port=7788', '-unattended'], cwd=system, startupinfo=si,
            stdout=f, stderr=subprocess.STDOUT)
        timed_out = False
        try:
            p.wait(timeout=35)
        except subprocess.TimeoutExpired:
            timed_out = True
            p.terminate()
            p.wait(timeout=10)
    text = dest.read_text(errors='replace')
    result = {'day': day, 'map': url, 'exit': p.returncode, 'timeout': timed_out,
              'passed': f'PLPROBE|PASS|day={day}|' in text,
              'warnings': text.count('Accessed None'),
              'critical': 'appError called' in text or 'Critical:' in text}
    results.append(result)
    print(json.dumps(result), flush=True)
    (out/'results.json').write_text(json.dumps(results, indent=2))
