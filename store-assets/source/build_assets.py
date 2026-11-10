"""Ảnh Google Play cho Tự Xem Phong Thuỷ 1.2.0 (com.huanhuynh.la_ban_phong_thuy).
Chạy: python3 store-assets/source/build_assets.py   (cần: pip install playwright pillow && playwright install chromium)
Màn hình dựng lại bằng HTML theo đúng lib/compass/CompassStatefulWidget.dart, author_card.dart, palette.dart
(ảnh la bàn, kim, ấn triện lấy từ assets/ của app; công thức Mệnh / Can Chi / Cung phi như CanChiUtils.dart).
Không có quảng cáo trong ảnh. Ra: screenshots/labanphongthuy-NN-*.png (1080x1920) + labanphongthuy-feature-graphic-1024x500.png.
"""
import base64, json, os
from playwright.sync_api import sync_playwright
from PIL import Image

SRC = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.abspath(os.path.join(SRC, ".."))
PREFIX = "labanphongthuy"

def uri(name, mime=None):
    mime = mime or ("image/jpeg" if name.endswith(".jpg") else "image/png")
    return f"data:{mime};base64," + base64.b64encode(open(os.path.join(SRC, name), "rb").read()).decode()

# ---- công thức (CanChiUtils.dart) ----
CAN = ['Giáp', 'Ất', 'Bính', 'Đinh', 'Mậu', 'Kỷ', 'Canh', 'Tân', 'Nhâm', 'Quý']
CHI = ['Tý', 'Sửu', 'Dần', 'Mão', 'Thìn', 'Tỵ', 'Ngọ', 'Mùi', 'Thân', 'Dậu', 'Tuất', 'Hợi']
MENH = ['Tích Lịch Hoả', 'Tùng Bách Mộc', 'Trường Lưu Thủy', 'Sa Trung Kim', 'Sơn Hạ Hoả', 'Bình Địa Mộc', 'Bích Thượng Thổ',
        'Kim Bạch Kim', 'Hú Đăng Hoả', 'Thiên Hà Thủy', 'Đại Dịch Thổ', 'Thoa Xuyến Kim', 'Tang Đố Mộc', 'Đại Khê Thủy',
        'Sa Trung Thổ', 'Thiên Thượng Hoả', 'Thạch Lựu Mộc', 'Đại Hải Thủy', 'Hải Trung Kim', 'Lộ Trung Hoả', 'Đại Lâm Mộc',
        'Lộ Bàng Thổ', 'Kiếm Phong Kim', 'Sơn Đầu Hoả', 'Giản Hạ Thủy', 'Thành Đầu Thổ', 'Bạch Lạp Kim', 'Dương Liễu Mộc',
        'Tuyền Trung Thủy', 'Ốc Thượng Thổ']
NAM = ['Tốn', 'Chấn', 'Khôn', 'Khảm', 'Ly', 'Cấn', 'Đoài', 'Kiền', 'Khôn']
NU = ['Khôn', 'Chấn', 'Tốn', 'Cấn', 'Kiền', 'Đoài', 'Cấn', 'Ly', 'Khảm']
NAM_IMG = ['1_Ton.jpg', '2_Chan.jpg', '3_Khon.jpg', '4_Kham.jpg', '5_Ly.jpg', '6_Can.jpg', '7_Đoai.jpg', '8_Can.jpg', '3_Khon.jpg']
NU_IMG = ['3_Khon.jpg', '2_Chan.jpg', '1_Ton.jpg', '6_Can.jpg', '8_Can.jpg', '7_Đoai.jpg', '6_Can.jpg', '5_Ly.jpg', '4_Kham.jpg']
EL = {'Kim': ('#B08A1E', '#6E5308', '#FFF4D6'), 'Mộc': ('#2E7D4F', '#1B5234', '#E3F2E8'), 'Thủy': ('#1F5F99', '#123C63', '#E1EEF8'),
      'Hoả': ('#B8322A', '#7A1A14', '#FBE4E1'), 'Thổ': ('#8D5A2B', '#5C3816', '#F5E8DA')}
DIRS = ['Bắc', 'Đông Bắc', 'Đông', 'Đông Nam', 'Nam', 'Tây Nam', 'Tây', 'Tây Bắc']

def profile(gender, year):
    canchi = f"{CAN[(year - 4) % 10]} {CHI[(year - 4) % 12]}"
    menh = MENH[((year - 28) // 2) % 30]
    i = year % 1924 % 9
    cung = (NAM if gender == 'Nam' else NU)[i]
    img = (NAM_IMG if gender == 'Nam' else NU_IMG)[i]
    el = next((v for k, v in EL.items() if k in menh), EL['Thổ'])
    return dict(gender=gender, year=year, canchi=canchi, menh=menh, cung=cung, img=img, el=el)

ICON = {
 'apps': 'M4 8h4V4H4v4zm6 12h4v-4h-4v4zm-6 0h4v-4H4v4zm0-6h4v-4H4v4zm6 0h4v-4h-4v4zm6-10v4h4V4h-4zm-6 4h4V4h-4v4zm6 6h4v-4h-4v4zm0 6h4v-4h-4v4z',
 'call': 'M6.62 10.79c1.44 2.83 3.76 5.14 6.59 6.59l2.2-2.2c.27-.27.67-.36 1.02-.24 1.12.37 2.33.57 3.57.57.55 0 1 .45 1 1V20c0 .55-.45 1-1 1-9.39 0-17-7.61-17-17 0-.55.45-1 1-1h3.5c.55 0 1 .45 1 1 0 1.25.2 2.45.57 3.57.11.35.03.74-.25 1.02l-2.2 2.2z',
 'mail': 'M20 4H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 14H4V8l8 5 8-5v10zm-8-7L4 6h16l-8 5z',
 'bank': 'M4 10v7h3v-7H4zm6 0v7h3v-7h-3zM2 22h19v-3H2v3zm14-12v7h3v-7h-3zm-4.5-9L2 6v2h19V6l-9.5-5z',
 'chev': 'M10 6L8.59 7.41 13.17 12l-4.58 4.59L10 18l6-6z',
 'copy': 'M16 1H4c-1.1 0-2 .9-2 2v14h2V3h12V1zm3 4H8c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h11c1.1 0 2-.9 2-2V7c0-1.1-.9-2-2-2zm0 16H8V7h11v14z',
 'cake': 'M12 6c1.11 0 2-.9 2-2 0-.38-.1-.73-.29-1.03L12 0l-1.71 2.97c-.19.3-.29.65-.29 1.03 0 1.1.9 2 2 2zm6 3h-5V7h-2v2H6c-1.66 0-3 1.34-3 3v9c0 .55.45 1 1 1h16c.55 0 1-.45 1-1v-9c0-1.66-1.34-3-3-3zm1 11H5v-3c.9-.01 1.76-.37 2.4-1.01l1.09-1.07 1.07 1.07c1.31 1.31 3.59 1.3 4.89 0l1.08-1.07 1.07 1.07c.64.64 1.5 1 2.4 1.01v3z',
 'drop': 'M7 10l5 5 5-5z',
}
def ic(name, size, color):
    return f'<svg width="{size}" height="{size}" viewBox="0 0 24 24" style="flex:none;display:block"><path d="{ICON[name]}" fill="{color}"/></svg>'

INK, MUTED, LINE, PAPER = '#2E2A24', '#6F665A', '#E6DCC8', '#F7F2E8'
APPS = {a['id']: a for a in json.load(open(os.path.join(SRC, 'apps.json'), encoding='utf-8'))['apps']}
SPIRITUAL = ['com.huanhuynh.lichvannien', 'com.huanhuynh.vankhan', 'com.huanhuynh.xinxam', 'com.huanhuynh.numerology']
OTHER = ['com.huanhuynh.sochitieu', 'com.huanhuynh.waterreminder', 'com.huanhuynh.cyclecare', 'com.huanhuynh.freshnest', 'com.huanhuynh.spin_the_wheel']

def screen(p, heading, sheet=None, installed=()):
    pri, dark, light = p['el']
    d = DIRS[int(((heading % 360) + 22.5) // 45) % 8]
    pill = lambda l, v: f'<div style="flex:1;padding:8px 10px;border-radius:12px;background:rgba(255,255,255,.14);border:1px solid rgba(255,255,255,.22);min-width:0"><div style="font-size:11px;color:rgba(255,255,255,.8)">{l}</div><div style="font-size:{14.5 if len(v) <= 9 else 13}px;font-weight:700;color:#fff;white-space:nowrap;margin-top:2px">{v}</div></div>'
    seg = lambda t, sym, on: f'<div style="flex:1;display:flex;align-items:center;justify-content:center;gap:6px;height:40px;font-size:14px;font-weight:500;{"background:"+pri+";color:#fff" if on else "background:#fff;color:"+INK}"><span style="font-size:17px">{sym}</span>{t}</div>'
    link = lambda t: f'<span style="font-size:13px;font-weight:600;color:{pri}">{t}</span>'
    dot = '<span style="font-size:13px;color:' + MUTED + '">&nbsp;&nbsp;·&nbsp;&nbsp;</span>'
    line = lambda icn, inner: f'<div style="display:flex;align-items:center;gap:6px;margin-top:3px">{ic(icn,14,MUTED)}<div style="white-space:nowrap;overflow:hidden">{inner}</div></div>'
    html = f'''<div style="position:absolute;inset:0;background:{PAPER};display:flex;flex-direction:column;font-family:Roboto,Inter,sans-serif;color:{INK}">
<div style="background:{pri};color:#fff;height:28px;display:flex;justify-content:space-between;align-items:center;padding:0 22px;font-size:13px;font-weight:600"><span>9:41</span><span style="letter-spacing:3px">▲◢▮</span></div>
<div style="background:{pri};height:56px;display:flex;align-items:center;padding:0 8px 0 16px;color:#fff"><div style="flex:1;font-size:19px;font-weight:700">Tự Xem Phong Thuỷ</div><div style="padding:12px">{ic('apps',24,'#fff')}</div></div>
<div style="padding:4px 16px 16px;background:linear-gradient({pri},{dark});border-radius:0 0 24px 24px">
 <div style="display:flex;align-items:flex-end;gap:10px"><div style="font-size:34px;font-weight:800;color:#fff;line-height:1">{round(heading)}°</div><div style="font-size:17px;font-weight:600;color:#fff;padding-bottom:3px">Hướng {d}</div></div>
 <div style="display:flex;gap:8px;margin-top:12px">{pill('Mệnh', p['menh'])}{pill('Can Chi', p['canchi'])}{pill('Cung phi', p['cung'])}</div>
</div>
<div style="flex:1;display:flex;align-items:center;justify-content:center;padding:12px 12px 8px;min-height:0;container-type:size">
 <div style="width:min(100cqw,100cqh);height:min(100cqw,100cqh);flex:none;border-radius:50%;background:#fff;border:2px solid {pri}59;box-shadow:0 6px 18px {dark}40;padding:8px;position:relative;overflow:hidden">
  <img src="{uri(p['img'])}" style="width:100%;height:100%;border-radius:50%;transform:rotate({-heading}deg);display:block">
  <img src="{uri('Needle.png')}" style="position:absolute;left:20%;top:20%;width:60%;height:60%;object-fit:contain">
  <div style="position:absolute;inset:0;display:flex;align-items:center;justify-content:center;text-align:center;color:{dark};font-size:18px;font-weight:900;font-family:'Noto Serif','DejaVu Serif',serif;line-height:1.15;letter-spacing:.3px;text-shadow:0 0 2px #fff,0 0 6px #fff,0 0 12px #fff,0 0 12px #fff">Nguyễn Nhan<br>Thái Thạnh</div>
 </div>
</div>
<div style="display:flex;gap:10px;padding:0 16px">
 <div style="flex:1;display:flex;border:1px solid {LINE};border-radius:20px;overflow:hidden">{seg('Nam','♂',p['gender']=='Nam')}<div style="width:1px;background:{LINE}"></div>{seg('Nữ','♀',p['gender']=='Nữ')}</div>
 <div style="flex:1;display:flex;align-items:center;justify-content:center;gap:4px;height:42px;border:1px solid {LINE};border-radius:21px;background:#fff;font-size:14px;font-weight:700">{ic('cake',18,pri)}<span style="margin-left:2px">Năm sinh {p['year']}</span>{ic('drop',22,INK)}</div>
</div>
<div style="height:8px"></div>
<div style="margin:0 16px;background:#fff;border:1px solid {LINE};border-radius:16px;padding:10px 12px;display:flex;gap:12px">
 <div style="padding:3px;background:#FBF7EF;border:1px solid {LINE};border-radius:8px;flex:none"><img src="{uri('Signature.png')}" style="height:62px;display:block"></div>
 <div style="flex:1;min-width:0">
  <div style="display:flex;align-items:center"><div style="flex:1;font-size:10.5px;letter-spacing:1.2px;font-weight:600;color:{pri}">TÁC GIẢ LA BÀN</div>{ic('chev',18,MUTED)}</div>
  <div style="font-size:16px;font-weight:800;font-family:'Noto Serif','DejaVu Serif',serif;white-space:nowrap">Nguyễn Nhan Thái Thạnh</div>
  <div style="height:4px"></div>
  {line('call', link('0913013489') + dot + link('0934131468'))}
  {line('mail', link('thaithanh87@gmail.com'))}
  {line('bank', '<span style="font-size:13px">NamABank – </span>' + link('0913013489'))}
 </div>
</div>
<div style="height:24px"></div>
</div>'''
    if sheet:
        html += f'<div style="position:absolute;inset:0;background:rgba(0,0,0,.32)"></div><div style="position:absolute;left:0;right:0;bottom:0;background:{PAPER};border-radius:28px 28px 0 0;padding:0 0 26px;font-family:Roboto,Inter,sans-serif;color:{INK}"><div style="width:32px;height:4px;border-radius:2px;background:#79747E;opacity:.4;margin:22px auto 18px"></div>{sheet}</div>'
    return html

def promo(ids, pri, installed, title):
    rows = ''
    for i, aid in enumerate(ids):
        a = APPS[aid]
        btn = 'Mở' if aid in installed else 'Cài'
        rows += (('' if i == 0 else f'<div style="height:1px;background:{LINE}"></div>') +
                 f'<div style="display:flex;align-items:center;padding:10px 0"><img src="{uri("icons/"+aid+".png")}" style="width:44px;height:44px;border-radius:11px;background:#EEF0F3;flex:none">'
                 f'<div style="flex:1;margin-left:12px;min-width:0"><div style="font-size:14.5px;font-weight:600;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">{a["name"]}</div><div style="font-size:12px;color:{MUTED};line-height:1.3">{a["tagline"]}</div></div>'
                 f'<div style="padding:8px 12px;color:{pri};font-size:14px;font-weight:600">{btn}</div></div>')
    return (f'<div style="font-size:12.5px;font-weight:700;color:{MUTED};letter-spacing:.6px;padding:0 0 10px 2px">{title}</div>'
            f'<div style="background:#fff;border:1px solid {LINE};border-radius:16px;padding:2px 14px">{rows}</div>')

def year_sheet(p):
    pri = p['el'][0]; y0 = p['year'] - 7
    cells = ''
    for y in range(y0, y0 + 24):
        sel = y == p['year']
        st = f'background:{pri};color:#fff' if sel else f'color:{INK}'
        cells += f'<div style="display:flex;justify-content:center"><div style="width:72px;height:36px;border-radius:18px;display:flex;align-items:center;justify-content:center;font-size:16px;{st}">{y}</div></div>'
    return (f'<div style="padding:0 20px 8px;font-size:18px;font-weight:800">Chọn năm sinh (âm lịch)</div>'
            f'<div style="display:grid;grid-template-columns:repeat(3,1fr);row-gap:16px;padding:6px 12px 10px;height:330px;overflow:hidden">{cells}</div>')

def author_sheet(p, installed):
    pri, dark, light = p['el']
    tile = lambda icn, t, v, tr: (f'<div style="display:flex;align-items:center;padding:10px 16px;gap:16px"><div style="width:40px;height:40px;border-radius:50%;background:{light};display:flex;align-items:center;justify-content:center">{ic(icn,20,pri)}</div>'
                                  f'<div style="flex:1"><div style="font-size:12.5px;color:{MUTED}">{t}</div><div style="font-size:16px;font-weight:600">{v}</div></div>{ic(tr,20,MUTED)}</div>')
    div = f'<div style="height:1px;background:{LINE}"></div>'
    return (f'<div style="padding:0 16px">'
            f'<div style="display:flex;align-items:center;gap:16px"><div style="padding:3px;background:#FBF7EF;border:1px solid {LINE};border-radius:8px"><img src="{uri("Signature.png")}" style="height:72px;display:block"></div>'
            f'<div><div style="font-size:11px;letter-spacing:1.4px;font-weight:600;color:{pri}">TÁC GIẢ LA BÀN</div><div style="font-size:21px;font-weight:800;font-family:\'Noto Serif\',\'DejaVu Serif\',serif;margin-top:4px">Nguyễn Nhan Thái Thạnh</div><div style="font-size:13px;color:{MUTED}">Lý Số Việt Nam</div></div></div>'
            f'<div style="margin-top:12px;background:#fff;border:1px solid {LINE};border-radius:16px">'
            + tile('call', 'Điện thoại', '0913013489', 'chev') + div + tile('call', 'Điện thoại', '0934131468', 'chev') + div
            + tile('mail', 'Email', 'thaithanh87@gmail.com', 'chev') + div + tile('bank', 'Ngân hàng NamABank', '0913013489', 'copy') + '</div>'
            f'<div style="height:20px"></div>{promo(SPIRITUAL, pri, installed, "ỨNG DỤNG TÂM LINH CỦA CHÚNG TÔI")}</div>')

def apps_sheet(p, installed):
    pri = p['el'][0]
    return (f'<div style="padding:0 16px"><div style="font-size:19px;font-weight:800">Ứng dụng khác của chúng tôi</div>'
            f'<div style="font-size:13px;color:{MUTED};margin-top:4px">Lịch âm, văn khấn, xin xăm, thần số học… miễn phí từ cùng nhà phát triển.</div><div style="height:14px"></div>'
            + promo(SPIRITUAL, pri, installed, 'ỨNG DỤNG TÂM LINH') + '<div style="height:16px"></div>' + promo(OTHER[:3], pri, installed, 'ỨNG DỤNG KHÁC') + '</div>')

P_THUY = profile('Nam', 1996); P_MOC = profile('Nữ', 1989); P_HOA = profile('Nam', 1987); P_THO = profile('Nam', 1991)
INST = {'com.huanhuynh.lichvannien', 'com.huanhuynh.vankhan'}
SCREENS = [
    ("01-la-ban", "La bàn phong thuỷ theo tuổi", "Bát trạch đúng cung phi của bạn · xoay theo hướng thật", screen(P_THUY, 128)),
    ("02-menh", "Mệnh · Can Chi · Cung phi", "Hiện ngay đầu trang, màu theo ngũ hành", screen(P_MOC, 52)),
    ("03-nam-sinh", "Đổi tuổi chỉ một chạm", "Chọn Nam/Nữ và năm sinh âm lịch – la bàn đổi theo", screen(P_HOA, 205, year_sheet(P_HOA))),
    ("04-tac-gia", "Tác giả: Lý Số Việt Nam", "Nguyễn Nhan Thái Thạnh · gọi điện, email một chạm", screen(P_THO, 300, author_sheet(P_THO, INST))),
    ("05-ung-dung", "Lịch âm, văn khấn, xin xăm", "Ứng dụng tâm linh cùng nhà phát triển – đã cài thì mở nhanh", screen(P_THUY, 128, apps_sheet(P_THUY, INST))),
]

CSS = """*{box-sizing:border-box;margin:0;padding:0}body{font-family:Inter,sans-serif;-webkit-font-smoothing:antialiased}
.page{width:540px;height:960px;position:relative;overflow:hidden;background:linear-gradient(165deg,#5A2A1A 0%,#2E140C 55%,#170A05 100%)}
.ring{position:absolute;border-radius:50%;border:1.5px solid rgba(232,198,112,.16)}
.head{position:absolute;top:44px;left:0;right:0;text-align:center;color:#fff;padding:0 22px}
.head h1{font-size:32px;font-weight:800;letter-spacing:-.3px;line-height:1.15}
.head p{font-size:16.5px;font-weight:600;color:#E8C670;margin-top:10px}
.phone{position:absolute;left:96px;top:158px;width:348px;height:772px;border-radius:44px;background:#120804;padding:7px;box-shadow:0 26px 60px rgba(0,0,0,.55),0 0 0 2px rgba(232,198,112,.4)}
.screen{width:334px;height:758px;border-radius:38px;overflow:hidden;position:relative}
.inner{position:absolute;left:0;top:0;width:360px;height:817px;transform:scale(.9278);transform-origin:0 0;overflow:hidden}"""
RINGS = '<div class="ring" style="width:520px;height:520px;right:-230px;top:-200px"></div><div class="ring" style="width:380px;height:380px;right:-160px;top:-130px"></div><div class="ring" style="width:420px;height:420px;left:-250px;bottom:-140px"></div>'

def shot_html(title, sub, inner):
    return f'<!doctype html><html lang="vi"><head><meta charset="utf-8"><style>{CSS}</style></head><body><div class="page">{RINGS}<div class="head"><h1>{title}</h1><p>{sub}</p></div><div class="phone"><div class="screen"><div class="inner">{inner}</div></div></div></div></body></html>'

def feature_html(inner):
    return f'''<!doctype html><html lang="vi"><head><meta charset="utf-8"><style>{CSS}
.fg{{width:1024px;height:500px;position:relative;overflow:hidden;background:linear-gradient(135deg,#5A2A1A 0%,#2E140C 60%,#170A05 100%)}}
.icon{{position:absolute;left:64px;top:56px;width:112px;height:112px;border-radius:26px;overflow:hidden;box-shadow:0 10px 30px rgba(0,0,0,.45),0 0 0 2px rgba(232,198,112,.5)}}
.t{{position:absolute;left:64px;top:192px;color:#fff;width:560px}}.t h1{{font-size:56px;font-weight:800;letter-spacing:-1px}}
.t p{{font-size:24px;font-weight:600;color:#E8C670;margin-top:8px;line-height:1.35}}
.chips{{position:absolute;left:64px;top:388px;display:flex;gap:10px}}
.chip{{background:rgba(255,255,255,.07);border:1px solid rgba(232,198,112,.55);color:#fff;font-weight:700;font-size:18px;padding:9px 18px;border-radius:24px}}
.fphone{{position:absolute;right:84px;top:38px;width:300px;height:650px;border-radius:38px;background:#120804;padding:7px;transform:rotate(-7deg);box-shadow:0 30px 60px rgba(0,0,0,.6),0 0 0 2px rgba(232,198,112,.4)}}
.fscreen{{width:286px;height:636px;border-radius:32px;overflow:hidden;position:relative}}
.finner{{position:absolute;left:0;top:0;width:360px;height:800px;transform:scale(.7944);transform-origin:0 0;overflow:hidden}}
</style></head><body><div class="fg">
<div class="ring" style="width:620px;height:620px;left:380px;top:-160px"></div><div class="ring" style="width:440px;height:440px;left:470px;top:-70px"></div>
<div class="icon"><img src="{uri('icon.png')}" style="width:136px;height:136px;margin:-12px"></div>
<div class="t"><h1>Tự Xem Phong Thuỷ</h1><p>La bàn bát trạch theo tuổi – xem hướng nhà,<br>hướng bếp, hướng bàn thờ</p></div>
<div class="chips"><span class="chip">Cung phi</span><span class="chip">Mệnh ngũ hành</span><span class="chip">Can Chi</span></div>
<div class="fphone"><div class="fscreen"><div class="finner">{inner}</div></div></div></div></body></html>'''

def render(b, html, vw, vh, dpr, out):
    tmp = os.path.join(SRC, "_tmp.html")
    open(tmp, "w", encoding="utf-8").write(html)
    p = b.new_page(viewport={"width": vw, "height": vh}, device_scale_factor=dpr)
    p.goto("file://" + tmp); p.wait_for_timeout(400)
    p.screenshot(path=out); p.close(); os.remove(tmp)
    Image.open(out).convert("RGB").save(out)

def main():
    d = os.path.join(OUT, "screenshots"); os.makedirs(d, exist_ok=True)
    with sync_playwright() as pw:
        b = pw.chromium.launch()
        for name, title, sub, inner in SCREENS:
            render(b, shot_html(title, sub, inner), 540, 960, 2, os.path.join(d, f"{PREFIX}-{name}.png"))
        render(b, feature_html(screen(P_THUY, 128)), 1024, 500, 1, os.path.join(OUT, f"{PREFIX}-feature-graphic-1024x500.png"))
        b.close()
    print("done")

if __name__ == "__main__":
    main()
