#!/usr/bin/env python3
"""Genera app/assets/audio/tono_alarma.wav: pitidos de 880 Hz, 2 s, mono, 22 050 Hz.

Solo biblioteca estándar. Salida determinista. Uso: python3 -I tools/generar_tono.py
"""
import math
import struct
import sys
import wave
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
SALIDA = RAIZ / "app" / "assets" / "audio" / "tono_alarma.wav"
FS = 22050
FREQ = 880.0
DURACION = 2.0
# Cuatro pitidos de 0,2 s con 0,3 s de silencio entre ellos.
PITIDO = 0.2
PERIODO = 0.5
AMPLITUD = 0.6
RAMPA = 0.01


def muestra(i: int) -> int:
    t = i / FS
    fase = t % PERIODO
    if fase >= PITIDO:
        return 0
    env = min(1.0, fase / RAMPA, (PITIDO - fase) / RAMPA)
    return int(round(AMPLITUD * env * math.sin(2 * math.pi * FREQ * t) * 32767))


def main() -> int:
    SALIDA.parent.mkdir(parents=True, exist_ok=True)
    n = int(FS * DURACION)
    with wave.open(str(SALIDA), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(FS)
        w.writeframes(b"".join(struct.pack("<h", muestra(i)) for i in range(n)))
    print(f"OK {SALIDA.relative_to(RAIZ)} ({SALIDA.stat().st_size} bytes)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
