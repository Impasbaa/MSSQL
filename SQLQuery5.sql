-- Eksik e-posta adreslerinin NULL olarak güncellenmesi
UPDATE [Customers]
SET Email = NULL
WHERE Email NOT LIKE '%@%.%';
-- Yinelenen müşteri kayıtlarının tespit edilmesi
SELECT Name, COUNT(*)
FROM [Customers]
GROUP BY Name
HAVING COUNT(*) > 1;

-- NULL değerleri varsayılan değerlerle değiştirme
UPDATE Musteriler 
SET Telefon = 'Belirtilmemiş'
WHERE Telefon IS NULL;
-- Eksik kayıtları silme
DELETE FROM Siparisler 
WHERE MusteriID IS NULL OR UrunID IS NULL;

-- Format düzeltme (telefon numaraları için)
UPDATE Musteriler
SET Telefon = REPLACE(REPLACE(REPLACE(Telefon, ' ', ''), '(', ''), ')', '')
WHERE Telefon LIKE '%(%' OR Telefon LIKE '%)%';
-- Yanlış veri tiplerini düzeltme
UPDATE Urunler
SET Fiyat = CAST(REPLACE(Fiyat, ',', '.') AS DECIMAL(10,2))
WHERE Fiyat LIKE '%,%';

-- Yinelenen kayıtları bulma ve silme
WITH CTE AS (
  SELECT *, 
         ROW_NUMBER() OVER (PARTITION BY TCKimlikNo ORDER BY KayitTarihi DESC) AS RN
  FROM Musteriler
)
DELETE FROM CTE WHERE RN > 1;

-- Tarih formatlarını standart hale getirme
UPDATE Siparisler
SET SiparisTarihi = CASE
  WHEN SiparisTarihi LIKE '__.__.____' THEN 
    CONVERT(DATETIME, SiparisTarihi, 104) -- DD.MM.YYYY
  WHEN SiparisTarihi LIKE '__-__-____' THEN 
    CONVERT(DATETIME, SiparisTarihi, 110) -- MM-DD-YYYY
  ELSE TRY_CONVERT(DATETIME, SiparisTarihi)
END;

-- Farklı sistemlerden gelen müşteri verilerini birleştirme
INSERT INTO DimMusteri (MusteriKey, Ad, Soyad, Sehir, Ulke)
SELECT 
  c.CustomerID,
  CASE 
    WHEN c.FirstName IS NULL THEN p.Ad ELSE c.FirstName 
  END,
  CASE 
    WHEN c.LastName IS NULL THEN p.Soyad ELSE c.LastName 
  END,
  COALESCE(c.City, p.Sehir, 'Bilinmiyor'),
  COALESCE(c.Country, p.Ulke, 'Bilinmiyor')
FROM CRM.Customers c
FULL OUTER JOIN POS.Musteriler p ON c.Email = p.Eposta;

-- JSON verisini ilişkisel modele dönüştürme
INSERT INTO UrunOzellikleri (UrunID, OzellikAdi, Deger)
SELECT 
  UrunID,
  j.OzellikAdi,
  j.Deger
FROM Urunler
CROSS APPLY OPENJSON(UrunDetay, '$.ozellikler')
WITH (
  OzellikAdi NVARCHAR(100),
  Deger NVARCHAR(255)
) AS j;

TRUNCATE TABLE HedefTablo;
INSERT INTO HedefTablo
SELECT * FROM KaynakTablo;

-- Değişen kayıtları bulma ve güncelleme
MERGE INTO HedefTablo AS target
USING KaynakTablo AS source
ON target.ID = source.ID
WHEN MATCHED AND (target.CheckSum <> CHECKSUM(source.*) OR target.CheckSum IS NULL) THEN
  UPDATE SET target.* = source.*, target.GuncellemeTarihi = GETDATE()
WHEN NOT MATCHED THEN
  INSERT (ID, ...) VALUES (source.ID, ...);

-- Geçici tablo oluşturma ve verileri yükleme
CREATE TABLE Temp_Tablo (...) WITH (PARTITION = ...);
-- Verileri işleme
INSERT INTO Temp_Tablo SELECT * FROM Kaynak WHERE ...;
-- Partition değiştirme
ALTER TABLE HedefTablo SWITCH PARTITION X TO Temp_Tablo;

-- Eksik değer analizi
SELECT 
  COUNT(*) AS ToplamKayit,
  SUM(CASE WHEN Ad IS NULL THEN 1 ELSE 0 END) AS EksikAd,
  SUM(CASE WHEN Soyad IS NULL THEN 1 ELSE 0 END) AS EksikSoyad,
  SUM(CASE WHEN Telefon IS NULL THEN 1 ELSE 0 END) AS EksikTelefon,
  (SUM(CASE WHEN Ad IS NULL OR Soyad IS NULL OR Telefon IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS EksikYuzde
FROM Musteriler;

-- Referans bütünlüğü kontrolü
SELECT 
  'Siparisler' AS TabloAdi,
  COUNT(*) AS GecersizKayitSayisi
FROM Siparisler s
LEFT JOIN Musteriler m ON s.MusteriID = m.MusteriID
WHERE m.MusteriID IS NULL;

-- ETL sürecinde yapılan değişikliklerin özeti
SELECT 
  'Format Düzeltme' AS IslemTipi,
  COUNT(*) AS EtkilenenKayitSayisi
FROM Musteriler
WHERE Telefon LIKE '%(%' OR Telefon LIKE '%)%'
UNION ALL
SELECT 
  'Eksik Değer Doldurma',
  COUNT(*)
FROM Musteriler
WHERE Telefon = 'Belirtilmemiş';

-- Tarihi 'yyyy-MM-dd' biçimine dönüştürme
SELECT CONVERT(VARCHAR(10), OrderDate, 120) AS StandardDate FROM Orders;
-- Şehir isimlerini büyük harfe dönüştürme
UPDATE Customers
SET City = UPPER(City);

-- Temizlenmiş verileri DataWarehouse tablosuna yükleme
INSERT INTO DW_Customers (CustomerID, Name, Email, City)
SELECT CustomerID, Name, Email, City
FROM Staging_Customers
WHERE Email IS NOT NULL;
