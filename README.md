# Avto Qarz Kalkulyatori

Avtomobil sotib olish uchun kredit va rassrochka to'lovlarini hisoblash uchun Flutter mobil ilovasi.

## 📱 Ilova haqida

**Avto Qarz Kalkulyatori** - bu foydalanuvchilarga avtomobil sotib olish uchun kredit va rassrochka to'lovlarini aniq hisoblash imkonini beruvchi mobil ilova.

### Kredit turlari:
1. **Bank krediti** - Annuity formulasi asosida professional bank kreditlarini hisoblaydi
2. **Rassrochka** - Qora bozor rassrochka to'lovlarini (simple markup) hisoblaydi

## ✨ Asosiy funksiyalar

### 🏦 Bank Krediti:
- Professional Annuity formula
- Oylik to'lov qoldiq balansdan hisoblanadi
- Foiz har oy kamayib boradi
- Asosiy qarz har oy oshib boradi

### 🛒 Rassrochka (Qora bozor):
- Simple markup calculation
- 12 oygacha: 25% ustama
- 13+ oy: 30% ustama
- Oylik to'lov har oy bir xil
- Tez va sodda

### Kirish maydonlari:
- 🚗 **Avtomobil narxi** - avtomobilning to'liq narxi (so'm)
- 💰 **Dastlabki to'lov** - boshlang'ich to'lov miqdori (so'm)
- 📊 **Foiz/Ustama stavka** - kredit foiz yoki rassrochka ustama (%)
- 📅 **Kredit muddati** - to'lov muddati (oy)

### Hisoblash natijalari:
- 📆 **Oylik to'lov** - har oy to'lanadigan summa
- 💵 **Jami to'lov** - butun muddat davomida to'lanadigan umumiy summa
- 📈 **Jami foiz/ustama** - qo'shimcha to'lanadigan miqdor
- 📋 **To'lov jadvali** - oyma-oy batafsil to'lov jadvali

## 🎨 Dizayn xususiyatlari

- Zamonaviy Material Design 3
- Professional ko'k va oq ranglar
- O'zbek tili interfeysi
- Responsive dizayn
- Splash screen animation
- Smooth transitions
- Intuitiv UI/UX

## 🔧 Texnik ma'lumotlar

- **Framework:** Flutter 3.27.1+
- **Til:** Dart 3.0.0+
- **Package:** uz.autograph.loancalculator
- **Platforma:** Android, iOS
- **Min SDK:** Android 21 (5.0)
- **Target SDK:** Android 34

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_native_splash: ^2.4.0
  lottie: ^3.1.0
```

## 🧮 Hisoblash Formulalari

### Bank Krediti (Annuity):
```
M = P × (r × (1 + r)^n) / ((1 + r)^n - 1)

M = Oylik to'lov
P = Kredit summasi (avtomobil narxi - dastlabki to'lov)
r = Oylik foiz stavka (yillik foiz / 12 / 100)
n = Kredit muddati (oy)
```

### Rassrochka (Simple Markup):
```
Jami = Kredit summasi × (1 + Ustama%)
Oylik = Jami / Oylar

Ustama: 25% (≤12 oy), 30% (>12 oy)
```

## 🚀 O'rnatish va ishga tushirish

### Talablar:
- Flutter SDK (3.27.1+)
- Dart SDK (3.0.0+)
- Android Studio / VS Code
- Android emulator yoki iOS simulator

### Loyihani ishga tushirish:

1. Dependencies'larni o'rnatish:
```bash
flutter pub get
```

2. Ilovani ishga tushirish:
```bash
flutter run
```

## 📦 Build qilish

### Android uchun APK:
```bash
flutter build apk --release
```

### Android uchun App Bundle:
```bash
flutter build appbundle --release
```

### GitHub Actions (Recommended):
```bash
git push origin main
# Automatic build via GitHub Actions
# Download APK/AAB from Artifacts
```

## 💡 Foydalanish

### 1. Kredit turini tanlang:
- Bank krediti (professional, rasmiy)
- Rassrochka (qora bozor, tez)

### 2. Ma'lumotlarni kiriting:
- Avtomobil narxi
- Dastlabki to'lov
- Foiz/Ustama
- Muddat (oy)

### 3. Hisoblang:
- "Hisoblash" tugmasini bosing
- Natijalarni ko'ring
- To'lov jadvalini tekshiring

### 4. Taqqoslang:
- Ikki kredit turini ham hisoblang
- Qaysi biri foydali ekanini aniqlang
- To'g'ri qaror qabul qiling

## 📊 Comparison Example

### 200 million so'm avtomobil, 50 million boshlang'ich, 36 oy:

| Parametr | Bank (18%) | Rassrochka (30%) | Farq |
|----------|------------|------------------|------|
| Oylik | 5,421,779 | 5,416,667 | -5,112 |
| Jami | 195,184,044 | 195,000,000 | -184,044 |
| Qo'shimcha | 45,184,044 | 45,000,000 | -184,044 |

**Natija:** 3 yilga deyarli bir xil!

### 100 million so'm qoldiq, 12 oy:

| Parametr | Bank (18%) | Rassrochka (25%) | Farq |
|----------|------------|------------------|------|
| Oylik | 9,168,387 | 10,416,667 | +1,248,280 |
| Jami | 110,020,644 | 125,000,000 | +14,979,356 |
| Qo'shimcha | 10,020,644 | 25,000,000 | +14,979,356 |

**Natija:** Bank krediti 15 million arzonroq!

## 🔒 Xavfsizlik va validatsiya

- ✅ Bo'sh qiymatlarni tekshirish
- ✅ Manfiy qiymatlarni oldini olish
- ✅ Noto'g'ri formatdagi raqamlarni bloklash
- ✅ Mantiqiy qiymatlarni tekshirish
- ✅ Real-time input formatting
- ✅ Comprehensive error messages

## 📱 Screenshots

_Coming soon..._

## 🎯 Target Audience

- O'zbekiston avtomobil xaridorlari
- AUTOGRAPH mijozlari
- Bank kredit izlovchilar
- Rassrochka talabgorlari
- Financial planners
- Avtosalonlar

## 📈 Future Features (Phase 2)

- 🚗 Car Database (UZ market)
- 🏦 Bank Comparison
- 🔄 Trade-in Calculator
- 💰 Insurance Calculator
- 📞 Lead Generation
- 🔔 Payment Reminders
- 💾 Favorites & History
- 🎁 Special Offers

## 📄 Litsenziya

Bu ilova MIT litsenziyasi ostida tarqatiladi.

## 👨‍💻 Muallif

**AUTOGRAPH AUTOMOTIVE GROUP**
- Website: uz.autograph
- Email: info@autograph.uz
- Phone: +998 XX XXX XX XX

## 📞 Aloqa

Savollar yoki takliflar bo'lsa, iltimos bog'laning.

## 🙏 Acknowledgments

- Flutter team
- Uzbekistan automotive market
- AUTOGRAPH customers
- All contributors

---

## 📝 Changelog

### Version 1.0.0 (2024-11-XX)
- ✅ Initial release
- ✅ Bank credit calculator
- ✅ Installment/Rassrochka calculator
- ✅ Professional splash screen
- ✅ Payment schedule table
- ✅ Input validation
- ✅ Number formatting
- ✅ Material Design 3 UI
- ✅ Uzbek language support

---

**Eslatma:** Bu ilova faqat hisoblash maqsadida yaratilgan. Haqiqiy kredit shartlari bank yoki moliya muassasalari tomonidan boshqacha bo'lishi mumkin.

**⭐ Agar ilova foydali bo'lsa, Play Store da 5 yulduz qoldiring!**
