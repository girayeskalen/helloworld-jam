#!/usr/bin/env python3
"""Build only game-used Ovani derivatives; stdlib only, Windows/Linux, no ffmpeg.
No archive extraction. Source material stays outside the repository. License is
not transferred: https://ovanisound.com/policies/terms-of-service .
"""
import argparse
from array import array
import hashlib
import io
import json
import math
from pathlib import Path
import subprocess
import sys
import wave
import zipfile

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'Sound FX Starter Pack Vol. 1/'
PEAK = 10 ** (-1 / 20)
# key, source relative to archive root, maximum seconds, variants, low-pass Hz
SHOTS = [
 ('thunder','Community Requests/Rolling Thunder.wav',3.2,3,0),
 ('siren','Community Requests/Air Raid Siren.wav',8,1,1800),
 ('topple','Hollywood/Wooden Crate Destruction.wav',1.4,1,0),
 ('impact_glass','Hollywood/Metal Glass Destruction.wav',.8,1,0),
 ('slam','Motions and Impacts/Impact Axe Fall.wav',1.2,1,0),
 ('slam','Motions and Impacts/Impact Vox Hammer.wav',1.2,1,0),
 ('boom','Hollywood/Mega Bomb.wav',3.5,1,0),
 ('impact_metal','Motions and Impacts/Impact Metal Hatch.wav',.65,1,0),
 ('block','Medieval/Shield Block.wav',.5,1,0),
 ('dash','Medieval/Weapon Whoosh.wav',.35,1,0),
 ('whoosh_wind','Motions and Impacts/Whoosh Cyberwave.wav',.7,1,0),
 ('whoosh_wind','Motions and Impacts/Swoosh Thunder.wav',.7,1,0),
 ('cast_quake','Magic/Earth Attack.wav',.8,1,0),
 ('cast_flood','Magic/Water Attack.wav',.8,1,0),
 ('cast_storm','Magic/Air Attack.wav',.8,1,0),
 ('hurt','Hollywood/Karate Punch.wav',.45,1,0),
 ('secure','Steampunk/Crack Turn.wav',.7,1,0),
 ('valve','Steampunk/Steampunk Wheel Activate.wav',1,1,0),
 ('breaker','Steampunk/Mechanism Open Close.wav',.7,1,0),
 ('repair','Community Requests/Drill.wav',1.1,1,0),
 ('pickup','UI & Menus/Equip.wav',.4,1,0),
 ('heal','Jingles & Stingers/Full Heal.wav',1.8,1,0),
 ('safe','UI & Menus/Achievement.wav',.7,1,0),
 ('ui_hover','UI & Menus/Hover Over.wav',.18,1,0),
 ('ui_confirm','UI & Menus/Select.wav',.3,1,0),
 ('ui_open','UI & Menus/Inventory.wav',.5,1,0),
 ('ui_start','UI & Menus/Start.wav',.8,1,0),
 ('ui_back','UI & Menus/Quit Out.wav',.4,1,0),
 ('karne_ok','UI & Menus/Notification.wav',.35,1,0),
 ('karne_miss','UI & Menus/Error.wav',.35,1,0),
 ('intro_riser','Motions and Impacts/Riser Distorted Wave.wav',2.3,1,0),
 ('intro_hit','Motions and Impacts/Whoosh Gong.wav',1.6,1,0),
 ('final_intro','Motions and Impacts/Transition Solemn.wav',2.8,1,0),
 ('countdown','Jingles & Stingers/Count Down.wav',4,1,0),
 ('victory','Jingles & Stingers/Level Up.wav',3,1,0),
 ('defeat','Jingles & Stingers/Game Over.wav',4,1,0),
 ('health_low','Jingles & Stingers/Health Low.wav',1.5,1,0),
 ('creak','Horror/Metallic Trembling.wav',1.5,3,0),
]
LOOPS = [
 ('amb_rain','Environment/Rain Urban Loop.wav',24,0),
 ('amb_wind','Environment/Wind Loop.wav',24,0),
 ('amb_hail','Environment/Hail Storm Loop.wav',16,0),
 ('amb_water','Environment/Ocean Loop.wav',24,1500),
 ('amb_interior','Environment/Busy City Apartment Interior Loop.wav',16,0),
 ('amb_quake','Hollywood/Earthquake Loop.wav',0,0),
]
ALIASES = {'rain':'amb_rain','whoosh':'whoosh_wind','impact_wood':'topple',
 'impact_stone':'slam','impact_water':'cast_flood','safety':'valve',
 'collapse_room':'boom','collapse_building':'boom','titan_fuse':'boom',
 'storm_in':'intro_riser','quake_in':'intro_riser','flood_in':'intro_riser',
 'titan_in':'final_intro','storm_out':'whoosh_wind','quake_out':'slam',
 'flood_out':'cast_flood','titan_out':'boom','ui_pause':'ui_open',
 'ui_resume':'ui_back','ui_toggle':'ui_confirm'}


def find_zip():
    candidates = []
    try:
        desktop = subprocess.check_output(['xdg-user-dir','DESKTOP'],text=True,stderr=subprocess.DEVNULL).strip()
        if desktop: candidates.append(Path(desktop))
    except (OSError, subprocess.CalledProcessError): pass
    candidates += [Path.home()/'Masaüstü',Path.home()/'Desktop']
    for folder in candidates:
        for path in sorted(folder.glob('*.zip')):
            if path.name.lower().startswith('sound_fx_starter_pack'): return path
    raise FileNotFoundError('Sound_FX_Starter_Pack*.zip not found; supply --zip PATH')


def read(z, name, mono):
    with wave.open(io.BytesIO(z.read(PREFIX+name))) as w:
        if (w.getsampwidth(), w.getnchannels()) != (2,2):
            raise ValueError('Expected 16-bit stereo 44.1 kHz: '+name)
        rate=w.getframerate()
        raw=array('h',w.readframes(w.getnframes()))
        if sys.byteorder!='little': raw.byteswap()
    channels = [array('f',((raw[i]+raw[i+1])/65536 for i in range(0,len(raw),2)))] if mono else [array('f',(v/32768 for v in raw[c::2])) for c in (0,1)]
    if rate != 44100:
        converted=[]
        for x in channels:
            y=array('f')
            for i in range(round(len(x)*44100/rate)):
                pos=i*rate/44100; j=min(int(pos),len(x)-1); f=pos-j
                y.append(x[j]*(1-f)+x[min(j+1,len(x)-1)]*f)
            converted.append(y)
        channels=converted
    return channels


def lowpass(x, rate, hz):
    if not hz: return x
    a=1-math.exp(-2*math.pi*hz/rate); y=0.0
    out=array('f')
    for v in x:
        y+=a*(v-y); out.append(y)
    return out


def trim(x):
    threshold=10**(-50/20); a=0; b=len(x)
    while a<b and abs(x[a])<threshold: a+=1
    while b>a and abs(x[b-1])<threshold: b-=1
    if b==a: raise ValueError('Silent source')
    return x[a:b],a


def energetic_windows(x, width, count):
    """RMS envelope, 10 ms hop; avoid near-identical overlapping variants."""
    width=min(width,len(x)); hop=441
    energies=[sum(v*v for v in x[i:i+hop]) for i in range(0,len(x),hop)]
    prefix=[0.0]
    for e in energies: prefix.append(prefix[-1]+e)
    blocks=max(1,width//hop)
    ranked=sorted(range(max(1,len(energies)-blocks)), key=lambda i:prefix[min(len(energies),i+blocks)]-prefix[i], reverse=True)
    selected=[]
    for i in ranked:
        at=min(i*hop,len(x)-width)
        if all(abs(at-other)>=width*.65 for other in selected): selected.append(at)
        if len(selected)==count: break
    if len(selected)!=count: raise ValueError('Source too short for distinct variants')
    return [(x[at:at+width],at) for at in selected]


def one_shot(x, rate=44100):
    n=len(x); fade_in=int(rate*.004); fade_out=min(int(rate*.08),n//3)
    envelope=array('f',(min(1,i/max(1,fade_in),(n-1-i)/max(1,fade_out)) for i in range(n)))
    mean=sum(x)/n
    out=array('f',((v-mean)*e for v,e in zip(x,envelope)))
    # Remove the tiny residual after windowing without introducing edge clicks.
    correction=sum(out)/sum(envelope)
    out=array('f',(v-correction*e for v,e in zip(out,envelope)))
    gain=PEAK/max(abs(v) for v in out)
    return array('f',(v*gain for v in out))


def loop_audio(channels, seconds, hz):
    rate=32000; n=round((seconds or len(channels[0])/44100)*rate); fade=rate
    result=[]
    for x in channels:
        x=lowpass(x,44100,hz)
        sampled=array('f')
        for i in range(n+fade):
            pos=(i*44100/rate)%len(x); j=int(pos); frac=pos-j
            sampled.append(x[j]*(1-frac)+x[(j+1)%len(x)]*frac)
        # Body followed by an equal-power tail->head seam, retaining exact length.
        out=sampled[fade:n]
        out.extend(sampled[n+i]*math.cos(i/(fade-1)*math.pi/2)+sampled[i]*math.sin(i/(fade-1)*math.pi/2) for i in range(fade))
        # Match the boundary over 5 ms, not an abrupt silent hole.
        join=(out[0]+out[-1])*.5
        start_delta=join-out[0]; end_delta=join-out[-1]
        for i in range(160):
            out[i]+=start_delta*(1-i/160);out[-1-i]+=end_delta*(1-i/160)
        mean=sum(out)/len(out)
        result.append(array('f',(v-mean for v in out)))
    rms=math.sqrt(sum(v*v for x in result for v in x)/(n*2))
    peak=max(abs(v) for x in result for v in x)
    if peak/max(rms,1e-9) > 12:
        # Rain's isolated close impacts otherwise force the whole bed below -30 dB.
        ceiling=rms*8
        result=[array('f',(ceiling*math.tanh(v/ceiling) for v in x)) for x in result]
        for x in result:
            mean=sum(x)/len(x)
            for i in range(len(x)): x[i]-=mean
        rms=math.sqrt(sum(v*v for x in result for v in x)/(n*2))
        peak=max(abs(v) for x in result for v in x)
    gain=min(10**(-24/20)/max(rms,1e-9),PEAK/max(peak,1e-9))
    return [array('f',(v*gain for v in x)) for x in result],rate


def write_asset(out_dir,key,index,source,channels,rate,loop,limit,offset):
    name=f'{key}_{index:02d}' if index else key
    relative=f'{"ambience" if loop else "sfx"}/{name}.wav'; dest=out_dir/relative
    dest.parent.mkdir(parents=True,exist_ok=True)
    pcm=array('h',(round(max(-1,min(1,v))*32767) for frame in zip(*channels) for v in frame))
    values=[array('f',(v/32768 for v in pcm[c::len(channels)])) for c in range(len(channels))]
    if sys.byteorder!='little':pcm.byteswap()
    with wave.open(str(dest),'wb') as w:
        w.setnchannels(len(channels));w.setsampwidth(2);w.setframerate(rate);w.writeframes(pcm.tobytes())
    n=len(channels[0]);peak=max(abs(v) for x in values for v in x)
    rms=math.sqrt(sum(v*v for x in values for v in x)/(n*len(channels)))
    # Stable import instructions. Editor fills in resource hashes/UIDs on import.
    imp=dest.with_suffix('.wav.import')
    params=f'[params]\n\nforce/8_bit=false\nforce/mono=false\nforce/max_rate=false\nforce/max_rate_hz=44100\nedit/trim=false\nedit/normalize=false\nedit/loop_mode={2 if loop else 1}\nedit/loop_begin=0\nedit/loop_end={n}\ncompress/mode=2\n'
    if imp.exists():
        header=imp.read_text().split('[params]')[0]
    else: header='[remap]\n\nimporter="wav"\ntype="AudioStreamWAV"\n\n'
    imp.write_text(header+params)
    return dict(name=name,key=key,file=relative,source=source,source_offset_seconds=offset,
                duration=n/rate,channels=len(channels),sample_rate=rate,frames=n,peak=peak,
                peak_dbfs=20*math.log10(max(peak,1e-12)),rms=rms,rms_dbfs=20*math.log10(max(rms,1e-12)),
                dc=max(abs(sum(x)/n) for x in values),seam=max(abs(x[-1]-x[0]) for x in values),
                loop=loop,max_seconds=limit,bytes=dest.stat().st_size,sha256=hashlib.sha256(dest.read_bytes()).hexdigest())


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--zip',type=Path);parser.add_argument('--output',type=Path,default=ROOT/'assets/audio')
    args=parser.parse_args(); source=args.zip or find_zip(); out=args.output;out.mkdir(parents=True,exist_ok=True)
    rows=[]; counts={}
    with zipfile.ZipFile(source) as z:
        names=[x for x in z.namelist() if not x.startswith('__MACOSX/') and not x.endswith('.DS_Store')]
        missing=[p for p in {s[1] for s in SHOTS+LOOPS}|{'Community Requests/Hammer Fall.wav'} if PREFIX+p not in names]
        if missing: raise FileNotFoundError('Missing sources: '+repr(missing))
        for key,path,seconds,hz in LOOPS:
            x,rate=loop_audio(read(z,path,False),seconds,hz)
            rows.append(write_asset(out,key,0,[path],x,rate,True,seconds or len(x[0])/rate,0))
        for key,path,limit,variants,hz in SHOTS:
            x,trim_at=trim(read(z,path,True)[0]);sources=[path]
            windows=[(x[-round(limit*44100):],max(0,len(x)-round(limit*44100)))] if key=='intro_riser' else energetic_windows(x,round(limit*44100),variants)
            for data,at in windows:
                data=lowpass(data,44100,hz)
                if key=='repair':
                    hammer,_=trim(read(z,'Community Requests/Hammer Fall.wav',True)[0]);sources.append('Community Requests/Hammer Fall.wav')
                    start=int(len(data)*.48)
                    for i in range(min(len(hammer),len(data)-start)): data[start+i]+=.65*hammer[i]
                data=one_shot(data)
                counts[key]=counts.get(key,0)+1
                rows.append(write_asset(out,key,counts[key],sources,[data],44100,False,limit,(trim_at+at)/44100))
    total=sum(r['bytes'] for r in rows)
    if total>25_000_000: raise ValueError(f'Audio size exceeds 25 MB: {total}')
    manifest={'schema':1,'provider':'Ovani Sound','pack':'Sound FX Starter Pack Vol. 1','license':'https://ovanisound.com/policies/terms-of-service','source_wav_count':sum(x.lower().endswith('.wav') for x in names),'total_bytes':total,'aliases':ALIASES,'outputs':rows}
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
    print(f'{len(rows)} derivatives, {total/1_000_000:.2f} MB; source WAVs: {manifest["source_wav_count"]}; source: {source}')
    print('Manifest:',out/'manifest.json')

if __name__=='__main__':main()
