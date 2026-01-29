//
//  ARTranslationService.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 29.01.2026.
//

import Foundation

final class ARTranslationService {

    // COCO Dataset (80 classes) + ImageNet common classes + everyday objects
    private let dictionary: [String: String] = [
        // COCO Dataset - Person
        "person": "İnsan",
        "man": "Erkek",
        "woman": "Kadın",
        "child": "Çocuk",
        "people": "İnsanlar",

        // COCO Dataset - Vehicles
        "bicycle": "Bisiklet",
        "car": "Araba",
        "motorcycle": "Motosiklet",
        "motorbike": "Motosiklet",
        "airplane": "Uçak",
        "aeroplane": "Uçak",
        "bus": "Otobüs",
        "train": "Tren",
        "truck": "Kamyon",
        "boat": "Tekne",
        "ship": "Gemi",

        // COCO Dataset - Traffic
        "traffic light": "Trafik Işığı",
        "fire hydrant": "Yangın Musluğu",
        "stop sign": "Dur İşareti",
        "parking meter": "Parkmetre",
        "bench": "Bank",

        // COCO Dataset - Animals
        "bird": "Kuş",
        "cat": "Kedi",
        "dog": "Köpek",
        "horse": "At",
        "sheep": "Koyun",
        "cow": "İnek",
        "elephant": "Fil",
        "bear": "Ayı",
        "zebra": "Zebra",
        "giraffe": "Zürafa",
        "lion": "Aslan",
        "tiger": "Kaplan",
        "monkey": "Maymun",
        "rabbit": "Tavşan",
        "duck": "Ördek",
        "chicken": "Tavuk",
        "fish": "Balık",
        "turtle": "Kaplumbağa",
        "snake": "Yılan",
        "spider": "Örümcek",
        "butterfly": "Kelebek",

        // COCO Dataset - Accessories
        "backpack": "Sırt Çantası",
        "umbrella": "Şemsiye",
        "handbag": "El Çantası",
        "tie": "Kravat",
        "suitcase": "Bavul",
        "luggage": "Bagaj",

        // COCO Dataset - Sports
        "frisbee": "Frizbi",
        "skis": "Kayak",
        "snowboard": "Snowboard",
        "sports ball": "Spor Topu",
        "kite": "Uçurtma",
        "baseball bat": "Beyzbol Sopası",
        "baseball glove": "Beyzbol Eldiveni",
        "skateboard": "Kaykay",
        "surfboard": "Sörf Tahtası",
        "tennis racket": "Tenis Raketi",
        "ball": "Top",
        "football": "Futbol Topu",
        "basketball": "Basketbol Topu",
        "volleyball": "Voleybol Topu",

        // COCO Dataset - Kitchen
        "bottle": "Şişe",
        "wine glass": "Şarap Kadehi",
        "cup": "Fincan",
        "mug": "Kupa",
        "fork": "Çatal",
        "knife": "Bıçak",
        "spoon": "Kaşık",
        "bowl": "Kase",
        "plate": "Tabak",
        "glass": "Bardak",

        // COCO Dataset - Food
        "banana": "Muz",
        "apple": "Elma",
        "sandwich": "Sandviç",
        "orange": "Portakal",
        "broccoli": "Brokoli",
        "carrot": "Havuç",
        "hot dog": "Sosisli",
        "pizza": "Pizza",
        "donut": "Donut",
        "doughnut": "Donut",
        "cake": "Pasta",
        "bread": "Ekmek",
        "cheese": "Peynir",
        "egg": "Yumurta",
        "meat": "Et",
        "rice": "Pirinç",
        "pasta": "Makarna",
        "soup": "Çorba",
        "salad": "Salata",
        "hamburger": "Hamburger",
        "ice cream": "Dondurma",
        "chocolate": "Çikolata",
        "cookie": "Kurabiye",

        // COCO Dataset - Furniture
        "chair": "Sandalye",
        "couch": "Koltuk",
        "sofa": "Kanepe",
        "potted plant": "Saksı Bitkisi",
        "bed": "Yatak",
        "dining table": "Yemek Masası",
        "table": "Masa",
        "desk": "Çalışma Masası",
        "toilet": "Tuvalet",
        "lamp": "Lamba",
        "bookcase": "Kitaplık",
        "wardrobe": "Gardrop",
        "cabinet": "Dolap",
        "shelf": "Raf",
        "drawer": "Çekmece",
        "carpet": "Halı",
        "rug": "Kilim",
        "curtain": "Perde",
        "pillow": "Yastık",
        "blanket": "Battaniye",
        "mattress": "Yatak",

        // COCO Dataset - Electronics
        "tv": "Televizyon",
        "television": "Televizyon",
        "laptop": "Dizüstü Bilgisayar",
        "computer": "Bilgisayar",
        "mouse": "Fare",
        "remote": "Kumanda",
        "keyboard": "Klavye",
        "cell phone": "Cep Telefonu",
        "cellphone": "Cep Telefonu",
        "phone": "Telefon",
        "mobile phone": "Cep Telefonu",
        "smartphone": "Akıllı Telefon",
        "tablet": "Tablet",
        "microwave": "Mikrodalga",
        "oven": "Fırın",
        "toaster": "Ekmek Kızartma Makinesi",
        "sink": "Lavabo",
        "refrigerator": "Buzdolabı",
        "fridge": "Buzdolabı",
        "monitor": "Ekran",
        "screen": "Ekran",
        "speaker": "Hoparlör",
        "headphone": "Kulaklık",
        "headphones": "Kulaklık",
        "earphone": "Kulakiçi Kulaklık",
        "camera": "Kamera",
        "printer": "Yazıcı",
        "charger": "Şarj Aleti",
        "cable": "Kablo",
        "battery": "Pil",
        "fan": "Vantilatör",
        "air conditioner": "Klima",
        "heater": "Isıtıcı",
        "washer": "Çamaşır Makinesi",
        "dryer": "Kurutma Makinesi",
        "dishwasher": "Bulaşık Makinesi",
        "vacuum": "Elektrik Süpürgesi",
        "iron": "Ütü",
        "blender": "Blender",
        "coffee maker": "Kahve Makinesi",
        "kettle": "Su Isıtıcı",
        "radio": "Radyo",
        "clock": "Saat",
        "watch": "Kol Saati",
        "alarm clock": "Çalar Saat",

        // COCO Dataset - Indoor Objects
        "book": "Kitap",
        "vase": "Vazo",
        "scissors": "Makas",
        "teddy bear": "Oyuncak Ayı",
        "hair drier": "Saç Kurutma Makinesi",
        "hairdryer": "Saç Kurutma Makinesi",
        "toothbrush": "Diş Fırçası",
        "mirror": "Ayna",
        "picture": "Resim",
        "painting": "Tablo",
        "frame": "Çerçeve",
        "candle": "Mum",
        "box": "Kutu",
        "bag": "Çanta",
        "basket": "Sepet",
        "jar": "Kavanoz",
        "container": "Kap",

        // Office & School
        "notebook": "Defter",
        "pen": "Kalem",
        "pencil": "Kurşun Kalem",
        "paper": "Kağıt",
        "envelope": "Zarf",
        "stapler": "Zımba",
        "calendar": "Takvim",
        "folder": "Dosya",
        "binder": "Klasör",
        "eraser": "Silgi",
        "ruler": "Cetvel",
        "calculator": "Hesap Makinesi",
        "marker": "Marker",
        "highlighter": "Fosforlu Kalem",
        "tape": "Bant",
        "glue": "Yapıştırıcı",
        "whiteboard": "Beyaz Tahta",
        "blackboard": "Kara Tahta",
        "projector": "Projektör",

        // Clothing
        "shirt": "Gömlek",
        "t-shirt": "Tişört",
        "pants": "Pantolon",
        "jeans": "Kot Pantolon",
        "shorts": "Şort",
        "skirt": "Etek",
        "dress": "Elbise",
        "jacket": "Ceket",
        "coat": "Mont",
        "sweater": "Kazak",
        "hoodie": "Kapşonlu",
        "suit": "Takım Elbise",
        "shoe": "Ayakkabı",
        "shoes": "Ayakkabılar",
        "sneaker": "Spor Ayakkabı",
        "sneakers": "Spor Ayakkabılar",
        "boot": "Bot",
        "boots": "Botlar",
        "sandal": "Sandalet",
        "slipper": "Terlik",
        "sock": "Çorap",
        "socks": "Çoraplar",
        "hat": "Şapka",
        "cap": "Kep",
        "scarf": "Atkı",
        "glove": "Eldiven",
        "gloves": "Eldivenler",
        "belt": "Kemer",
        "wallet": "Cüzdan",
        "purse": "El Çantası",
        "glasses": "Gözlük",
        "sunglasses": "Güneş Gözlüğü",
        "ring": "Yüzük",
        "necklace": "Kolye",
        "bracelet": "Bilezik",
        "earring": "Küpe",

        // Nature & Plants
        "tree": "Ağaç",
        "flower": "Çiçek",
        "plant": "Bitki",
        "grass": "Çimen",
        "leaf": "Yaprak",
        "bush": "Çalı",
        "forest": "Orman",
        "mountain": "Dağ",
        "rock": "Kaya",
        "stone": "Taş",
        "sand": "Kum",
        "water": "Su",
        "river": "Nehir",
        "lake": "Göl",
        "ocean": "Okyanus",
        "sea": "Deniz",
        "sky": "Gökyüzü",
        "cloud": "Bulut",
        "sun": "Güneş",
        "moon": "Ay",
        "star": "Yıldız",
        "rain": "Yağmur",
        "snow": "Kar",

        // Drinks
        "coffee": "Kahve",
        "tea": "Çay",
        // water already defined above
        "juice": "Meyve Suyu",
        "milk": "Süt",
        "soda": "Gazoz",
        "beer": "Bira",
        "wine": "Şarap",

        // Buildings & Places
        "house": "Ev",
        "building": "Bina",
        "door": "Kapı",
        "window": "Pencere",
        "wall": "Duvar",
        "floor": "Zemin",
        "ceiling": "Tavan",
        "roof": "Çatı",
        "stairs": "Merdiven",
        "elevator": "Asansör",
        "fence": "Çit",
        "gate": "Kapı",
        "bridge": "Köprü",
        "road": "Yol",
        "street": "Sokak",
        "sidewalk": "Kaldırım",

        // Tools
        "hammer": "Çekiç",
        "screwdriver": "Tornavida",
        "wrench": "İngiliz Anahtarı",
        "pliers": "Pense",
        "drill": "Matkap",
        "saw": "Testere",
        "nail": "Çivi",
        "screw": "Vida",
        "bolt": "Cıvata",
        "key": "Anahtar",
        "lock": "Kilit",
        "chain": "Zincir",
        "rope": "İp",
        "wire": "Tel",
        "ladder": "Merdiven",
        "brush": "Fırça",
        "broom": "Süpürge",
        "mop": "Paspas",
        "bucket": "Kova",
        "hose": "Hortum",

        // Toys & Games
        "toy": "Oyuncak",
        "doll": "Bebek",
        "teddy": "Oyuncak Ayı",
        "robot": "Robot",
        "puzzle": "Bulmaca",
        "lego": "Lego",
        "block": "Blok",
        "card": "Kart",
        "dice": "Zar",
        "game": "Oyun",

        // Music
        "guitar": "Gitar",
        "piano": "Piyano",
        "drum": "Davul",
        "violin": "Keman",
        "flute": "Flüt",
        "microphone": "Mikrofon",
        "headset": "Kulaklık",

        // Medical
        "medicine": "İlaç",
        "pill": "Hap",
        "syringe": "Şırınga",
        "bandage": "Bandaj",
        "mask": "Maske",
        "thermometer": "Termometre",
        "stethoscope": "Stetoskop",

        // Misc
        "towel": "Havlu",
        "tissue": "Peçete",
        "soap": "Sabun",
        "shampoo": "Şampuan",
        "toothpaste": "Diş Macunu",
        "comb": "Tarak",
        "razor": "Tıraş Bıçağı",
        "perfume": "Parfüm",
        "makeup": "Makyaj",
        "lipstick": "Ruj",
        "nail polish": "Oje",
        "lotion": "Losyon",
        "sunscreen": "Güneş Kremi",
    ]

    func translate(word: String) -> String {
        let lowercased = word.lowercased().trimmingCharacters(in: .whitespaces)

        // Direct match
        if let translation = dictionary[lowercased] {
            return translation
        }

        // Try removing plural 's'
        if lowercased.hasSuffix("s") {
            let singular = String(lowercased.dropLast())
            if let translation = dictionary[singular] {
                return translation
            }
        }

        // Try partial match (for compound words like "dining table")
        for (key, value) in dictionary {
            if lowercased.contains(key) || key.contains(lowercased) {
                return value
            }
        }

        return word.capitalized
    }
}
