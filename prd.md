# Mini Oyunlar Koleksiyonu PRD

## Proje Özeti
Bu proje, Flutter kullanılarak geliştirilecek 20 farklı mini oyunu içeren bir mobil uygulamadır. Uygulama, kullanıcılara eğlenceli ve bağımlılık yaratmayan oyun deneyimi sunmayı hedeflemektedir.

## Teknik Altyapı Durumu

### ✅ Tamamlanan
1. Temel Proje Yapısı
   - [x] Flutter projesi oluşturuldu
   - [x] GetX state management entegre edildi
   - [x] Tema sistemi kuruldu
   - [x] Rota yönetimi yapıldı

2. Ayarlar Sistemi
   - [x] Ayarlar sayfası tasarımı
   - [x] SharedPreferences ile veri saklama
   - [x] Tema değiştirme (Dark/Light mode)
   - [x] Ses ayarları arayüzü
   - [x] Çözünürlük ve FPS ayarları arayüzü

3. Ses Sistemi
   - [x] AudioService sınıfı oluşturuldu
   - [x] Müzik kontrolü (play, pause, resume, stop)
   - [x] Ses efektleri sistemi
   - [x] Ses seviyesi kontrolü
   - [x] Önbellekleme sistemi

4. Çoklu Dil Desteği
   - [x] LocalizationService sınıfı oluşturuldu
   - [x] 4 dil desteği (TR, EN, ES, DE)
   - [x] Sistem dili algılama
   - [x] Dil değiştirme sistemi
   - [x] Tüm metinler için çeviriler

5. Kullanıcı Profil Sistemi
   - [x] Profil sayfası tasarımı
   - [x] Kullanıcı adı ve avatar özelleştirme
   - [x] İstatistikler görüntüleme
   - [x] Yüksek skorları görüntüleme
   - [x] Favori oyunlar listesi

6. Skor Tablosu Sistemi
   - [x] Kategori bazlı skor listeleme
   - [x] Oyun bazlı yüksek skorlar
   - [x] Son oynanma tarihi gösterimi
   - [x] Madalya/Rütbe sistemi

### 📝 Yapılacak
1. Asset Yönetimi
   - [x] Ses dosyalarının eklenmesi
   - [x] Görsel dosyaların eklenmesi
   - [ ] Animasyon dosyalarının eklenmesi

2. Oyun Geliştirme
   - [x] Oyun motorunun oluşturulması
   - [ ] Fizik sisteminin entegrasyonu
   - [x] Skor sisteminin oluşturulması
   - [ ] Başarım sisteminin oluşturulması

## Oyun Listesi ve Durumları

### Refleks Oyunları
1. Hızlı Tıklama Yarışı
   - [x] Tamamlandı
   - Belirli sürede ekranda beliren hedeflere tıklama
   - Skor sistemi ve zorluk seviyeleri

2. Renk Eşleştirme
   - [x] Tamamlandı
   - Ekranda beliren renkleri doğru sırayla eşleştirme
   - Zamana karşı yarış modu

3. Tepki Testi
   - [x] Tamamlandı
   - Işık yeşil olduğunda tıklama
   - Reaksiyon süresini ölçme

### Bulmaca Oyunları
4. Sayı Bulmaca
   - [x] Tamamlandı
   - 2048 benzeri sayı birleştirme oyunu
   - Highscore sistemi

5. Kelime Avı
   - [x] Tamamlandı
   - Harfleri birleştirerek kelime oluşturma
   - Türkçe kelime veritabanı

6. Hafıza Kartları
   - [x] Tamamlandı
   - Eşleşen kartları bulma
   - Farklı zorluk seviyeleri

### Arcade Oyunları
7. Snake (Yılan)
   - [x] Tamamlandı
   - Klasik yılan oyunu
   - Modern grafikler ve güçlendirmeler

8. Space Shooter
   - [x] Tamamlandı
   - Uzay gemisiyle düşmanları vurma
   - Power-up sistemi

9. Bounce Ball
   - [x] Tamamlandı
   - Topu platformlar üzerinde zıplatma
   - Engeller ve bonuslar

### Strateji Oyunları
10. Mini Satranç
    - [x] Tamamlandı
    - Basitleştirilmiş satranç varyantı
    - AI rakip sistemi

11. Tic Tac Toe
    - [x] Tamamlandı
    - İki kişilik mod
    - Bilgisayara karşı mod

12. Connect Four
    - [x] Tamamlandı
    - Dört taş birleştirme
    - Online multiplayer

### Eğitici Oyunlar
13. Matematik Yarışı
    - [x] Tamamlandı
    - Hızlı matematik problemleri
    - Zorluk seviyeleri

14. Bayrak Bilmece
    - [x] Tamamlandı
    - Ülke bayraklarını tanıma
    - Çoktan seçmeli sorular

15. Kelime Öğrenme
    - [x] Tamamlandı
    - İngilizce kelime öğrenme oyunu
    - İlerleme takibi

### Fizik Tabanlı Oyunlar
16. Angry Birds Benzeri
    - [x] Tamamlandı
    - Nesneleri fırlatma ve yıkma
    - Fizik motoru entegrasyonu

17. Cut the Rope Tarzı
    - [x] Tamamlandı
    - İp kesme ve nesne yönlendirme
    - Bölüm tasarımları

18. Doodle Jump Benzeri
    - [x] Tamamlandı
    - Sürekli yukarı zıplama
    - Rastgele platform oluşturma

### Ritim Oyunları
19. Müzik Notaları
    - [x] Tamamlandı
    - Ritim tutturma
    - Farklı müzik türleri

20. Piano Tiles
    - [x] Tamamlandı
    - Siyah tuşlara tıklama
    - Popüler şarkılar

## Öncelik Sırası
1. [x] Ana menü ve oyun seçim ekranı
2. [x] Ayarlar sistemi
3. [x] Ses sistemi
4. [x] Çoklu dil desteği
5. [x] İlk 6 oyunun geliştirilmesi (6/6 tamamlandı)
6. [x] Kullanıcı profil sistemi
7. [x] Skor tablosu
8. [x] Kalan oyunların geliştirilmesi
9. [ ] Test ve optimizasyon
10. [ ] Mağaza yayını

## Notlar
- Her oyun için tutorial eklenecek
- Oyunlar arası geçiş akıcı olmalı
- Reklam gösterimi kullanıcı deneyimini bozmamalı
- Düzenli güncelleme planı yapılmalı 

## Proje Durumu

### ✅ Yapıldı
- PRD dökümanı oluşturuldu
- Oyun listesi ve kategorileri belirlendi
- Teknik gereksinimlerin belirlenmesi
- Kullanıcı arayüzü gereksinimlerinin belirlenmesi
- Zaman planlaması
- Flutter projesinin oluşturulması
- Gerekli paketlerin eklenmesi
- Temel dosya yapısının oluşturulması
- Tema sistemi kurulumu
- Rota yönetimi implementasyonu
- Ses sistemi entegrasyonu
- Çoklu dil desteği
- Ana menü tasarımı
- Ayarlar menüsü tasarımı
- Asset klasörleri yapılandırması
- Refleks oyunları kategorisi ekranı
- "Hızlı Tıklama Yarışı" oyunu
- "Tepki Testi" oyunu
- "Renk Eşleştirme" oyunu
- "Sayı Bulmaca" oyunu
- Splash screen eklendi
- Profil sayfası oluşturuldu
- Skor tablosu sistemi eklendi
- Bulmaca oyunları kategorisi ekranı
- "Kelime Avı" oyunu
- "Hafıza Kartları" oyunu
- Arcade oyunları kategorisi ekranı
- "Snake (Yılan)" oyunu
- "Space Shooter" oyunu
- "Bounce Ball" oyunu
- Strateji oyunları kategorisi ekranı
- "Mini Satranç" oyunu  
- "Tic Tac Toe" oyunu
- "Connect Four" oyunu
- Eğitici oyunlar kategorisi ekranı
- "Matematik Yarışı" oyunu
- "Bayrak Bilmece" oyunu
- "Kelime Öğrenme" oyunu
- Fizik tabanlı oyunlar kategorisi ekranı
- "Angry Birds Benzeri" oyunu
- "Cut the Rope Tarzı" oyunu
- "Doodle Jump Benzeri" oyunu
- Ritim oyunları kategorisi ekranı
- "Müzik Notaları" oyunu
- "Piano Tiles" oyunu

### 📝 Yapılacak
1. Proje Kurulumu ✅
   - Flutter projesinin oluşturulması ✅
   - Gerekli paketlerin eklenmesi ✅
   - Temel dosya yapısının oluşturulması ✅

2. Temel Altyapı ✅
   - Tema sistemi ✅
   - Rota yönetimi ✅
   - Veri yönetimi altyapısı ✅
   - Ses sistemi entegrasyonu ✅

3. Ana Menü ve UI ✅
   - Splash screen ✅
   - Ana menü tasarımı ✅
   - Oyun seçim ekranı ✅
   - Ayarlar menüsü ✅
   - Profil sayfası ✅
   - Skor tablosu ✅

4. Oyun Geliştirme ✅
   - Refleks oyunları (3 adet) (3/3) ✅
   - Bulmaca oyunları (3 adet) (3/3) ✅
   - Arcade oyunları (3 adet) (3/3) ✅
   - Strateji oyunları (3 adet) (3/3) ✅
   - Eğitici oyunlar (3 adet) (3/3) ✅
   - Fizik tabanlı oyunlar (3 adet) (3/3) ✅
   - Ritim oyunları (2 adet) (2/2) ✅

5. Ek Özellikler 🔄
   - Skor tablosu sistemi ✅
   - Başarım sistemi
   - İstatistik takibi ✅
   - Çevrimiçi özellikler
   - Reklam entegrasyonu

7. Yayın Hazırlığı
   - App Store hazırlıkları
   - Play Store hazırlıkları
   - Marketing materyalleri
   - Lansman planı 