# NeenNeen & JameJame — Wedding e-card

การ์ดเชิญงานแต่งงานออนไลน์ (e-card) แบบหน้าเดียว รองรับทั้งมือถือและเดสก์ท็อป
เป็นเว็บ static ล้วน (HTML + CSS + inline SVG) ไม่มี build step ไม่มี dependency
deploy ขึ้น Vercel ได้ทันที

## โครงสร้างไฟล์

```
index.html     หน้าการ์ดเชิญ (เนื้อหา + SVG symbols ของลายประดับ)
rsvp.html      หน้าแบบฟอร์มตอบรับคำเชิญ — ส่งคำตอบเข้า Google Sheet ผ่าน Apps Script
styles.css     ตัวแปรสี/ตัวอักษร, layout มือถือ (default) และเดสก์ท็อป (@media min-width:900px)
base/          ไฟล์ดีไซน์อ้างอิงจาก design tool — ไม่ได้ถูกใช้ตอน runtime
  mobile/DesignG3.dc.html
  desktop/DesignH-wide.dc.html
```

`base/` เก็บไว้เป็น reference เท่านั้น (mockup) หน้าเว็บจริงอ่านแค่ `index.html` + `styles.css`

## ส่วนประกอบของหน้า

| ลำดับ | section | มือถือ | เดสก์ท็อป |
| --- | --- | --- | --- |
| 1 | Hero — ชื่อบ่าวสาว + ภาพคู่ | เรียงแนวตั้ง | 2 คอลัมน์ (ข้อความ / ภาพ) |
| 2 | We'd love you there + Save the date + RSVP | เรียงแนวตั้ง | ข้อความซ้าย / ตั๋ววันที่ขวา แล้ว RSVP อยู่กลาง |
| 3 | Venue — สถานที่ + ที่จอดรถ + ปุ่ม Google Maps | เรียงแนวตั้ง | ภาพซ้าย / ข้อมูลขวา |
| 4 | Program + Details (dress code) | 2 แถบแยกกัน (ฟ้าอ่อน / ขาว) | แถบเดียว 2 คอลัมน์ |
| 5 | Footer — ภาพคู่ + ลายเซ็น Lucky in Love | เรียงแนวตั้ง | ภาพซ้าย / ข้อความขวา |

Breakpoint เดียวคือ `900px` — ต่ำกว่านั้นใช้เลย์เอาต์มือถือ (`base/mobile`),
ตั้งแต่ 900px ขึ้นไปใช้เลย์เอาต์เดสก์ท็อป (`base/desktop`)

## ข้อมูลที่ต้องแก้ก่อนส่งการ์ดจริง

ข้อมูลจริงที่ใส่แล้ว: วันที่ (3 เม.ย. 2570), สถานที่ The Barn at The Upper Ground (จตุจักร)
พร้อมลิงก์ Google Maps 2 จุด, กำหนดการ (กินเลี้ยงฉลอง 10:30 - 13:30),
กำหนดตอบรับ 31 ม.ค. 2570, ชื่อเล่นท้ายการ์ด N & J

ส่วนที่ตัดออกชั่วคราว (เอากลับมาได้ภายหลัง): รูปสถานที่และข้อมูลที่จอดรถในส่วน Venue
(CSS ของ `.venue-photo-link` / `.venue-arch` / `.parking` ยังอยู่ครบ แค่ลบ markup ออก)

ค่าที่ยังเป็น placeholder:

- `rsvp.html` — `SCRIPT_URL` (`[GOOGLE_SCRIPT_URL]`) ใน `<script>` ท้ายไฟล์

### ใส่รูปจริงแทนกล่อง placeholder

กล่อง `[รูปสถานที่]` / `[รูปคู่]` / ภาพบ่าวสาวใน hero เป็น SVG วาดไว้ก่อน
ถ้าจะใส่รูปจริง วางไฟล์ไว้ที่ `images/` แล้วแทนเนื้อใน `.arch` ด้วย:

```html
<div class="arch hero-arch">
  <img src="./images/couple.jpg" alt="NeenNeen และ JameJame"
       style="width:100%;height:100%;object-fit:cover">
</div>
```

`.arch` ตั้ง `overflow:hidden` ไว้แล้ว รูปจะถูกครอบตามทรงโค้งของการ์ดอัตโนมัติ

## การเชื่อม RSVP กับ Google Sheet

หน้า `rsvp.html` มีฟอร์ม 4 ข้อ (ชื่อ-นามสกุล, เข้าร่วมได้หรือไม่, จำนวนผู้เข้าร่วม, ข้อความ)
เมื่อกดส่ง ฟอร์มจะ POST ไปที่ Google Apps Script Web App ซึ่งเขียนแถวใหม่ลง Google Sheet

### ขั้นตอนตั้งค่า (ทำครั้งเดียว)

1. สร้าง Google Sheet ใหม่ ตั้งหัวตาราง row แรก: `เวลา | ชื่อ | เข้าร่วม | จำนวน | ข้อความ`
2. ใน Sheet เปิด **Extensions → Apps Script** แล้ววางโค้ดนี้แทนของเดิม:

   ```js
   function doPost(e) {
     var sheet = SpreadsheetApp.getActiveSpreadsheet().getSheets()[0];
     var p = e.parameter;
     sheet.appendRow([new Date(), p.name, p.attending, p.guests || "", p.message || ""]);
     return ContentService.createTextOutput("ok");
   }
   ```

3. กด **Deploy → New deployment → Web app** ตั้งค่า:
   - Execute as: **Me**
   - Who has access: **Anyone**
4. คัดลอก **Web app URL** (ลงท้าย `/exec`) มาแทน `[GOOGLE_SCRIPT_URL]`
   ในตัวแปร `SCRIPT_URL` ท้ายไฟล์ `rsvp.html`
5. ทดสอบส่งฟอร์ม 1 ครั้ง แล้วเช็กว่ามีแถวใหม่ขึ้นใน Sheet

หมายเหตุ: ฟอร์มส่งแบบ `no-cors` จึงอ่านคำตอบจากเซิร์ฟเวอร์ไม่ได้ —
ถ้า fetch สำเร็จจะถือว่าส่งแล้วและโชว์หน้า Thank you ทันที
ถ้าแก้โค้ด Apps Script ภายหลัง ต้อง Deploy → **Manage deployments → Edit → New version** URL เดิมถึงจะอัปเดต

## รันดูในเครื่อง

ต้องเสิร์ฟผ่าน http (เปิดจาก `file://` ฟอนต์/SVG บาง browser จะบล็อก):

```bash
python3 -m http.server 4321
# เปิด http://localhost:4321
```

## Deploy ขึ้น Vercel

เป็น static site ล้วน — ไม่ต้องตั้ง framework, build command หรือ output directory

### วิธีที่ 1 — ผูกกับ GitHub (แนะนำ: push แล้ว deploy อัตโนมัติ)

1. push โค้ดขึ้น repo นี้ (`git push origin main`)
2. เข้า https://vercel.com/new → **Import Git Repository** → เลือก `nj-s-wedding`
3. ตั้งค่า:
   - Framework Preset: **Other**
   - Root Directory: `./`
   - Build Command: *(เว้นว่าง)*
   - Output Directory: *(เว้นว่าง)*
4. กด **Deploy** — หลังจากนี้ทุก push ที่ `main` จะ deploy production ให้เอง และ branch อื่นได้ preview URL

### วิธีที่ 2 — Vercel CLI

```bash
npm i -g vercel      # หรือใช้ npx vercel
vercel login
vercel               # deploy เป็น preview
vercel --prod        # deploy ขึ้น production
```

### โดเมนของตัวเอง

Project → **Settings → Domains** → Add เช่น `naneen-jamejame.com`
แล้วชี้ DNS ตามที่ Vercel แจ้ง (A record `76.76.21.21` หรือ CNAME ไป `cname.vercel-dns.com`)

## หมายเหตุทางเทคนิค

- ฟอนต์ **Mali** (ไทย/อังกฤษ) และ **Pacifico** (ลายมือ) โหลดจาก Google Fonts ผ่าน `<link>` + `preconnect`
- ลายประดับทุกชิ้น (พวงไฟ, ขอบกระดาษฉีก, ใบไม้, ประกาย, เมฆ, กรอบซิกแซก) เป็น SVG `<symbol>` อยู่หัวไฟล์ แล้วเรียกซ้ำด้วย `<use>` — ไม่มีไฟล์รูปให้โหลดเพิ่ม
- พวงไฟด้านบน/ล่างใช้ SVG `<pattern>` กว้าง 288px ปูซ้ำ จึงยืดตามความกว้างจอได้ทุกขนาด
- ตำแหน่งลายประดับทั้งหมดคุมด้วย CSS (คลาส `.deco` / `.dot`) แยกค่ามือถือกับเดสก์ท็อป ไม่ปะปนกับ markup
- สีทั้งชุดเป็น CSS custom properties ใน `:root` (`--rose`, `--brick`, `--mustard`, `--golden`, `--coral`, `--palm`, `--sand`, `--sky`, `--mist`, `--ink`) แก้ที่เดียวเปลี่ยนทั้งเว็บ
