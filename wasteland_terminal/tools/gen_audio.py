#!/usr/bin/env python3
"""Synthesises the combat sound effects (22.05 kHz mono 16-bit WAV, same format as
the existing ones) into assets/audio/.  python3 tools/gen_audio.py"""
import os, wave
import numpy as np
from scipy.signal import butter, lfilter

SR = 22050
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'assets', 'audio')
rng = np.random.RandomState(7)


def T(sec): return np.arange(int(SR * sec)) / SR
def noise(n): return rng.normal(0, 1, n)
def env_exp(t, k): return np.exp(-t * k)
def lp(x, f): b, a = butter(2, f / (SR / 2), 'low'); return lfilter(b, a, x)
def hp(x, f): b, a = butter(2, f / (SR / 2), 'high'); return lfilter(b, a, x)
def bp(x, lo, hi): b, a = butter(2, [lo / (SR / 2), hi / (SR / 2)], 'band'); return lfilter(b, a, x)
def sine(f, t): return np.sin(2 * np.pi * np.cumsum(np.broadcast_to(f, t.shape)) / SR)
def attack(x, ms=3):
    n = max(1, int(SR * ms / 1000)); x = x.copy(); x[:n] *= np.linspace(0, 1, n); return x


def save(name, x, peak=0.85):
    x = x / (np.max(np.abs(x)) + 1e-9) * peak
    fade = int(SR * .006); x[-fade:] *= np.linspace(1, 0, fade)
    with wave.open(os.path.join(OUT, name + '.wav'), 'wb') as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes((x * 32767).astype('<i2').tobytes())


def whoosh():
    t = T(.30); n = noise(len(t))
    f = 300 + 2400 * np.sin(np.pi * np.clip(t / .30, 0, 1)) ** 1.5           # sweep up then down
    y = np.zeros_like(n); s = 0.0
    for i in range(len(n)):                                                  # time-varying low-pass
        a = min(1.0, 2 * np.pi * f[i] / SR); s += a * (n[i] - s); y[i] = s
    e = np.sin(np.pi * np.clip(t / .30, 0, 1)) ** 1.4
    return attack(y * e)


def thud():
    t = T(.30)
    body = sine(95 * np.exp(-t * 7) + 40, t) * env_exp(t, 15)
    click = lp(noise(len(t)), 900) * env_exp(t, 70) * .7
    return attack(body + click, 1)


def slash():
    t = T(.34); n = hp(noise(len(t)), 1800)
    swish = n * env_exp(t, 16) * (1 - np.exp(-t * 90))
    ring = (sine(2150, t) * .35 + sine(3260, t) * .25 + sine(4310, t) * .12) * env_exp(t, 22)
    return attack(swish + ring, 1)


def gunshot():
    t = T(.55)
    crack = hp(noise(len(t)), 600) * env_exp(t, 38)
    boom = sine(72 * np.exp(-t * 4) + 38, t) * env_exp(t, 9)
    tail = lp(noise(len(t)), 700) * env_exp(t, 6) * .28
    return np.tanh(2.2 * attack(crack * .9 + boom * 1.1 + tail, 1))


def plasma():
    t = T(.58)
    f = 260 + 1300 * (t / .58) ** 1.4
    saw = 2 * ((np.cumsum(f) / SR) % 1) - 1
    trem = .65 + .35 * np.sin(2 * np.pi * 38 * t)
    sizzle = hp(noise(len(t)), 3500) * .45 * (t / .58)
    e = np.minimum(t / .04, 1) * np.exp(-np.maximum(t - .30, 0) * 7)
    return (saw * trem * .6 + sizzle) * e


def crit():
    t = T(.46)
    t1 = thud()[:len(t)]
    t1 = np.pad(t1, (0, len(t) - len(t1)))
    ping = (sine(1320, t) * .5 + sine(1980, t) * .35 + sine(2640, t) * .18) * env_exp(t, 9)
    click = hp(noise(len(t)), 2500) * env_exp(t, 90) * .5
    return t1 * .9 + ping * .8 + click


def block():
    t = T(.34)
    clang = sum(a * sine(f, t) * env_exp(t, k) for f, a, k in [(520, .5, 12), (1180, .4, 15), (1710, .3, 18), (2430, .2, 22)])
    thump = sine(120 * np.exp(-t * 10) + 60, t) * env_exp(t, 25) * .8
    return attack(clang + thump + hp(noise(len(t)), 2000) * env_exp(t, 80) * .3, 1)


def heal():
    out = np.zeros(int(SR * .75))
    for i, f in enumerate([659.3, 830.6, 987.8, 1318.5]):
        t = T(.34); s = (sine(f, t) + .35 * sine(f * 2, t)) * env_exp(t, 7) * np.minimum(t / .01, 1)
        o = int(SR * .1 * i); out[o:o + len(s)] += s[:len(out) - o]
    return out


def death():
    t = T(.85)
    fall = sine(240 * np.exp(-t * 3.4) + 30, t) * env_exp(t, 3.2)
    crackle = lp(noise(len(t)), 2400) * (rng.rand(len(t)) > .93) * env_exp(t, 4) * 1.4
    rumble = lp(noise(len(t)), 260) * env_exp(t, 4) * .6
    return attack(fall + crackle + rumble, 2)


def charge():
    t = T(.72)
    f = 110 + 420 * (t / .72) ** 2
    sq = np.sign(sine(f, t)) * .5 + sine(f * 1.5, t) * .25
    trem = .6 + .4 * np.sin(2 * np.pi * (8 + 14 * t / .72) * t)
    return sq * trem * np.minimum(t / .05, 1) * (np.minimum(1, (.72 - t) / .03))


def brace():
    t = T(.34)
    tone = sine(150 + 60 * (t / .34), t) * env_exp(t, 9) + .35 * sine(300, t) * env_exp(t, 12)
    air = bp(noise(len(t)), 400, 1800) * env_exp(t, 14) * .35
    return attack(tone + air, 3)


if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    for n, f in dict(whoosh=whoosh, thud=thud, slash=slash, gunshot=gunshot, plasma=plasma, crit=crit,
                     block=block, heal=heal, death=death, charge=charge, brace=brace).items():
        save(n, f()); print('wrote', n)
