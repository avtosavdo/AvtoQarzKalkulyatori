# Avto Qarz Kalkulyatori

Avtomobil sotib olish uchun kredit to'lovlarini hisoblash uchun Flutter mobil ilovasi.

## 📱 Ilova haqida

**Avto Qarz Kalkulyatori** - bu foydalanuvchilarga avtomobil sotib olish uchun kredit to'lovlarini aniq hisoblash imkonini beruvchi mobil ilova. Ilova Annuity formulasi asosida oylik to'lovlar, jami to'lovlar va foizlarni hisoblaydi.

## ✨ Asosiy funksiyalar

### Kirish maydonlari:
- 🚗 **Avtomobil narxi** - avtomobilning to'liq narxi (so'm)
- 💰 **Dastlabki to'lov** - boshlang'ich to'lov miqdori (so'm)
- 📊 **Yillik foiz stavka** - kredit foiz stavkasi (%)
- 📅 **Kredit muddati** - to'lov muddati (oy)

### Hisoblash natijalari:
- 📆 **Oylik to'lov** - har oy to'lanadigan summa
- 💵 **Jami to'lov** - butun muddat davomida to'lanadigan umumiy summa
- 📈 **Jami foiz** - qo'shimcha to'lanadigan foiz miqdori
- 📋 **To'lov jadvali** - oyma-oy batafsil to'lov jadvali

## 🎨 Dizayn xususiyatlari

- Zamonaviy va sodda Material Design
- Professional ko'k va oq ranglar
- O'zbek tili interfeysi
- Responsive dizayn (barcha ekranlar uchun)
- Intuitiv va qulay foydalanish

## 🔧 Texnik ma'lumotlar

- **Framework:** Flutter 3.x
- **Til:** Dart
- **Package:** dev.diyor.loancalculator
- **Platforma:** Android, iOS
- **Hisoblash formulasi:** Annuity formula

### Annuity formulasi:
```
M = P × (r × (1 + r)^n) / ((1 + r)^n - 1)

M = Oylik to'lov
P = Kredit summasi (avtomobil narxi - dastlabki to'lov)
r = Oylik foiz stavka (yillik foiz / 12 / 100)
n = Kredit muddati (oy)
```

## 🚀 O'rnatish va ishga tushirish

### Talablar:
- Flutter SDK (3.x yoki yuqori)
- Dart SDK
- Android Studio / VS Code
- Android emulator yoki iOS simulator

### Loyihani ishga tushirish:

1. Repositoriyani klonlash:
```bash
cd avto_qarz_kalkulyatori
```

2. Dependencies'larni o'rnatish:
```bash
flutter pub get
```

3. Ilovani ishga tushirish:
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

### iOS uchun:
```bash
flutter build ios --release
```

## 💡 Foydalanish

1. **Ma'lumotlarni kiriting:**
   - Avtomobil narxini kiriting
   - Dastlabki to'lov miqdorini belgilang
   - Yillik foiz stavkani kiriting
   - Kredit muddatini tanlang

2. **Hisoblash tugmasini bosing:**
   - Ilova avtomatik ravishda hisoblab beradi

3. **Natijalarni ko'ring:**
   - Oylik to'lov miqdori
   - Jami to'lov summasi
   - Jami foiz summasi
   - Batafsil to'lov jadvali

## 🔒 Xavfsizlik va validatsiya

Ilova quyidagi input validatsiyalarni amalga oshiradi:
- ✅ Bo'sh qiymatlarni tekshirish
- ✅ Manfiy qiymatlarni oldini olish
- ✅ Noto'g'ri formatdagi raqamlarni bloklash
- ✅ Mantiqiy qiymatlarni tekshirish (masalan: dastlabki to'lov avtomobil narxidan kam bo'lishi kerak)

## 📄 Litsenziya

Bu ilova MIT litsenziyasi ostida tarqatiladi.

## 👨‍💻 Muallif

Avtomobil Qarz Kalkulyatori - uz.autograph

## 📞 Aloqa

Savollar yoki takliflar bo'lsa, iltimos bog'laning.

---

**Eslatma:** Bu ilova faqat hisoblash maqsadida yaratilgan. Haqiqiy kredit shartlari bank yoki moliya muassasalari tomonidan boshqacha bo'lishi mumkin.
