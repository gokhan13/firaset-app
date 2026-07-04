#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Firaset içerik doğrulayıcı - şema + ETİK KAPI.
Kullanım:  python3 tools/validate_content.py  [content/v1]
Çıkış kodu 0 = geçti, 1 = hata. Her içerik değişikliğinde çalıştırılır (CLAUDE.md Kural 6).
"""
import json
import sys
from pathlib import Path
from collections import Counter

YON = {"olumlu", "olumsuz", "notr", "karisik"}
KANAL = {"kamera_mesh", "kamera_goruntu", "kamera_el", "ses_kaydi", "oz_bildirim", "yok"}
DURUM = {"onay_bekliyor", "onaylandi", "haric", "haric_onerisi"}
AKTIF = {"onay_bekliyor", "onaylandi"}

# ETİK KAPI: bu bölgeler hiçbir koşulda AKTİF olamaz (CLAUDE.md Altın Kural 2).
YASAK_BOLGE_PARCALARI = ["ten rengi", "mahrem", "göz rengi", "saç rengi"]
# Aktif kuralların kullanıcı metinlerinde geçemeyecek ifadeler (kelime sınırlı desenler):
import re
YASAK_DESENLER = [re.compile(p, re.UNICODE) for p in
                  (r"\bhastalık", r"\bteşhis", r"\bırk\b", r"\betnik")]

hatalar, uyarilar = [], []


def hata(m):
    hatalar.append(m)


def uyari(m):
    uyarilar.append(m)


def yukle(yol: Path):
    try:
        return json.loads(yol.read_text(encoding="utf-8"))
    except FileNotFoundError:
        hata(f"{yol} bulunamadı")
    except json.JSONDecodeError as e:
        hata(f"{yol} geçersiz JSON: {e}")
    return None


def kural_kontrol(k, kaynak):
    kid = k.get("id", "?")
    for alan in ("id", "bolge", "deger", "yon", "kanal", "sayfa"):
        if alan not in k:
            hata(f"[{kaynak}:{kid}] zorunlu alan yok: {alan}")
    if k.get("yon") not in YON:
        hata(f"[{kaynak}:{kid}] geçersiz yon: {k.get('yon')}")
    if k.get("kanal") not in KANAL:
        hata(f"[{kaynak}:{kid}] geçersiz kanal: {k.get('kanal')}")
    if not isinstance(k.get("sayfa"), int):
        hata(f"[{kaynak}:{kid}] sayfa int olmalı")
    durum = k.get("durum", "onay_bekliyor")
    if durum not in DURUM:
        hata(f"[{kaynak}:{kid}] geçersiz durum: {durum}")
    if ("ozellikler" in k) == ("esleme" in k):  # tam olarak biri olmalı
        hata(f"[{kaynak}:{kid}] 'ozellikler' YA DA 'esleme' (tam biri) olmalı")
    if durum in {"haric", "haric_onerisi"} and not k.get("haric_nedeni"):
        hata(f"[{kaynak}:{kid}] {durum} için haric_nedeni zorunlu")
    if durum in AKTIF:
        if not k.get("uygulama"):
            hata(f"[{kaynak}:{kid}] aktif kural için 'uygulama' metni zorunlu")
        if k.get("kanal") == "yok":
            hata(f"[{kaynak}:{kid}] aktif kural kanal='yok' olamaz")
        bolge = k.get("bolge", "").lower()
        for yasak in YASAK_BOLGE_PARCALARI:
            if yasak in bolge:
                hata(f"[{kaynak}:{kid}] ETİK KAPI: '{yasak}' bölgesi aktif olamaz")
        metin = (k.get("uygulama", "") + " " + " ".join(k.get("ozellikler", []))).lower()
        for desen in YASAK_DESENLER:
            if desen.search(metin):
                uyari(f"[{kaynak}:{kid}] aktif metinde riskli ifade: '{desen.pattern}' - editör baksın")


def dosya01(d):
    kurallar = d.get("kurallar_bas_boyun", []) + d.get("kurallar_diger_uzuvlar", [])
    if not kurallar:
        hata("[01] kural listeleri boş/eksik")
        return
    idler = [k.get("id") for k in kurallar]
    for i, n in Counter(idler).items():
        if n > 1:
            hata(f"[01] tekrar eden id: {i}")
    for k in kurallar:
        kural_kontrol(k, "01")
    if d.get("kadin_32_alamet", {}).get("durum") != "haric":
        hata("[01] kadin_32_alamet 'haric' olmalı (güzellik puanı yasağı)")
    say = Counter(k.get("durum", "onay_bekliyor") for k in kurallar)
    print(f"  01: {len(kurallar)} kural -> aktif {sum(say[s] for s in AKTIF)}, "
          f"karar_bekleyen {say['haric_onerisi']}, hariç {say['haric']}")


def dosya02(d):
    mizaclar = d.get("mizaclar", [])
    if {m.get("id") for m in mizaclar} != {"demevi", "safravi", "balgami", "sevdavi"}:
        hata("[02] dört mizaç (demevi/safravi/balgami/sevdavi) eksik veya fazla")
    eksenler = {"sicak", "soguk", "nem", "kuru"}
    hiltler = {"kan", "safra", "balgam", "sevda"}
    for m in d.get("test", {}).get("maddeler", []):
        tid = m.get("id", "?")
        if m.get("tip") == "secim":
            for s, v in m.get("secenekler", {}).items():
                if v and v.get("hilt") not in hiltler:
                    hata(f"[02:{tid}] geçersiz hilt: {v}")
        else:
            p = m.get("puan", {})
            if not p or not set(p) <= eksenler:
                hata(f"[02:{tid}] puan anahtarları {eksenler} içinde olmalı")
    print(f"  02: 4 mizaç, {len(d.get('test', {}).get('maddeler', []))} test maddesi")


def dosya03(d):
    seg = d.get("segirme", {}).get("maddeler", [])
    for i, n in Counter(s.get("id") for s in seg).items():
        if n > 1:
            hata(f"[03] tekrar eden seğirme id: {i}")
    for s in seg:
        if not all(a in s for a in ("uzuv", "sag", "sol", "sayfa")):
            hata(f"[03:{s.get('id','?')}] seğirme alanları eksik")
    yillar = d.get("oniki_hayvan_takvimi", {}).get("yillar", [])
    if sorted(y.get("sira") for y in yillar) != list(range(1, 13)):
        hata("[03] 12 hayvan yılı sira 1-12 tam olmalı")
    for y in yillar:
        if set(y.get("dogum", {})) != {"basi", "ortasi", "sonu"}:
            hata(f"[03] {y.get('ad')}: dogum basi/ortasi/sonu tam olmalı")
    print(f"  03: {len(seg)} seğirme, {len(yillar)} hayvan yılı")


def main():
    kok = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("content/v1")
    print(f"Doğrulanıyor: {kok}/")
    d1 = yukle(kok / "01_kiyafetname_kurallari.json")
    d2 = yukle(kok / "02_mizac_sistemi.json")
    d3 = yukle(kok / "03_ek_moduller.json")
    if d1: dosya01(d1)
    if d2: dosya02(d2)
    if d3: dosya03(d3)
    for u in uyarilar:
        print(f"  UYARI  {u}")
    if hatalar:
        for h in hatalar:
            print(f"  HATA   {h}")
        print(f"SONUÇ: {len(hatalar)} hata, {len(uyarilar)} uyarı -> BAŞARISIZ")
        sys.exit(1)
    print(f"SONUÇ: 0 hata, {len(uyarilar)} uyarı -> GEÇTİ ✓")
    sys.exit(0)


if __name__ == "__main__":
    main()
