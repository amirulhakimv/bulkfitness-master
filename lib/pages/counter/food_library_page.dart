import 'package:bulkfitness/components/my_appbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_custom_food_page.dart';

class FoodLibraryPage extends StatefulWidget {
  final String mealType;

  const FoodLibraryPage({Key? key, required this.mealType}) : super(key: key);

  @override
  _FoodLibraryPageState createState() => _FoodLibraryPageState();
}

class _FoodLibraryPageState extends State<FoodLibraryPage> {
  static List<Map<String, dynamic>> _defaultFoodLibrary = [
    {'name': 'Nasi Lemak', 'description': '398 kcal, coconut rice with sambal', 'calories': 398},
    {'name': 'Roti Canai', 'description': '301 kcal, flatbread with curry', 'calories': 301},
    {'name': 'Char Kway Teow', 'description': '742 kcal, stir-fried flat noodles', 'calories': 742},
    {'name': 'Satay', 'description': '306 kcal, 5 sticks', 'calories': 306},
    {'name': 'Laksa', 'description': '432 kcal, spicy noodle soup', 'calories': 432},
    {'name': 'Rendang', 'description': '468 kcal, spicy meat dish', 'calories': 468},
    {'name': 'Mee Goreng', 'description': '660 kcal, fried noodles', 'calories': 660},
    {'name': 'Nasi Goreng', 'description': '661 kcal, fried rice', 'calories': 661},
    {'name': 'Curry Laksa', 'description': '518 kcal, coconut curry noodle soup', 'calories': 518},
    {'name': 'Asam Laksa', 'description': '317 kcal, sour fish noodle soup', 'calories': 317},
    {'name': 'Hokkien Mee', 'description': '622 kcal, stir-fried noodles', 'calories': 622},
    {'name': 'Bak Kut Teh', 'description': '368 kcal, pork rib soup', 'calories': 368},
    {'name': 'Chili Crab', 'description': '588 kcal, spicy crab dish', 'calories': 588},
    {'name': 'Murtabak', 'description': '637 kcal, stuffed pancake', 'calories': 637},
    {'name': 'Rojak', 'description': '372 kcal, fruit and vegetable salad', 'calories': 372},
    {'name': 'Cendol', 'description': '373 kcal, iced dessert', 'calories': 373},
    {'name': 'Teh Tarik', 'description': '103 kcal, pulled milk tea', 'calories': 103},
    {'name': 'Nasi Kerabu', 'description': '389 kcal, blue rice salad', 'calories': 389},
    {'name': 'Curry Puff', 'description': '376 kcal, 2 pieces', 'calories': 376},
    {'name': 'Apam Balik', 'description': '377 kcal, turnover pancake', 'calories': 377},
    {'name': 'Kuih Lapis', 'description': '157 kcal, layered cake', 'calories': 157},
    {'name': 'Ais Kacang', 'description': '454 kcal, shaved ice dessert', 'calories': 454},
    {'name': 'Nasi Dagang', 'description': '759 kcal, rice steamed with coconut milk', 'calories': 759},
    {'name': 'Roti Jala', 'description': '244 kcal, net bread', 'calories': 244},
    {'name': 'Popiah', 'description': '189 kcal, fresh spring roll', 'calories': 189},
    {'name': 'Lor Mee', 'description': '511 kcal, braised noodles', 'calories': 511},
    {'name': 'Yong Tau Foo', 'description': '239 kcal, stuffed tofu', 'calories': 239},
    {'name': 'Tau Fu Fa', 'description': '70 kcal, soybean pudding', 'calories': 70},
    {'name': 'Kaya Toast', 'description': '368 kcal, 2 slices', 'calories': 368},
    {'name': 'Nasi Ulam', 'description': '205 kcal, herb rice salad', 'calories': 205},
    {'name': 'Otak-Otak', 'description': '53 kcal, grilled fish cake', 'calories': 53},
    {'name': 'Sambal Udang', 'description': '165 kcal, spicy prawn dish', 'calories': 165},
    {'name': 'Kuih Talam', 'description': '130 kcal, two-layered dessert', 'calories': 130},
    {'name': 'Bubur Cha Cha', 'description': '319 kcal, sweet potato dessert soup', 'calories': 319},
    {'name': 'Mee Rebus', 'description': '571 kcal, boiled noodles in gravy', 'calories': 571},
    {'name': 'Pasembur', 'description': '634 kcal, Malaysian salad', 'calories': 634},
    {'name': 'Nasi Tomato', 'description': '204 kcal, tomato rice', 'calories': 204},
    {'name': 'Lontong', 'description': '391 kcal, rice cake dish', 'calories': 391},
    {'name': 'Kuih Seri Muka', 'description': '270 kcal, two-layered rice cake', 'calories': 270},
    {'name': 'Ayam Percik', 'description': '288 kcal, spicy grilled chicken', 'calories': 288},
    {'name': 'Ikan Bakar', 'description': '150 kcal, grilled fish', 'calories': 150},
    {'name': 'Nasi Kandar', 'description': '735 kcal, mixed rice dish', 'calories': 735},
    {'name': 'Kuih Ketayap', 'description': '186 kcal, rolled crepe with coconut filling', 'calories': 186},
    {'name': 'Pulut Inti', 'description': '213 kcal, glutinous rice with palm sugar', 'calories': 213},
    {'name': 'Mee Siam', 'description': '519 kcal, spicy rice vermicelli', 'calories': 519},
    {'name': 'Putu Piring', 'description': '98 kcal, steamed rice cake', 'calories': 98},
    {'name': 'Kuih Dadar', 'description': '186 kcal, pandan crepe roll', 'calories': 186},
    {'name': 'Sambal Petai', 'description': '137 kcal, stink beans in chili paste', 'calories': 137},
    {'name': 'Nasi Ayam', 'description': '669 kcal, chicken rice', 'calories': 669},
    {'name': 'Kuih Koci', 'description': '200 kcal, glutinous rice dumpling', 'calories': 200},
    {'name': 'Mee Bandung', 'description': '613 kcal, noodles in thick gravy', 'calories': 613},
    {'name': 'Keropok Lekor', 'description': '241 kcal, fish sausage', 'calories': 241},
    {'name': 'Nasi Kerak', 'description': '304 kcal, burnt rice', 'calories': 304},
    {'name': 'Kuih Lapis Sagu', 'description': '157 kcal, steamed layer cake', 'calories': 157},
    {'name': 'Mee Udang', 'description': '495 kcal, prawn noodles', 'calories': 495},
    {'name': 'Pulut Serunding', 'description': '330 kcal, glutinous rice with meat floss', 'calories': 330},
    {'name': 'Kuih Bahulu', 'description': '40 kcal, mini sponge cake', 'calories': 40},
    {'name': 'Nasi Briyani', 'description': '778 kcal, spiced rice dish', 'calories': 778},
    {'name': 'Kuih Kaswi', 'description': '95 kcal, steamed palm sugar cake', 'calories': 95},
    {'name': 'Mee Kari', 'description': '383 kcal, curry noodles', 'calories': 383},
    {'name': 'Sambal Sotong', 'description': '175 kcal, spicy squid dish', 'calories': 175},
    {'name': 'Kuih Bangkit', 'description': '40 kcal, coconut cookie', 'calories': 40},
    {'name': 'Nasi Kunyit', 'description': '241 kcal, turmeric glutinous rice', 'calories': 241},
    {'name': 'Kuih Pie Tee', 'description': '44 kcal, top hats', 'calories': 44},
    {'name': 'Mee Jawa', 'description': '650 kcal, Javanese noodle dish', 'calories': 650},
    {'name': 'Pulut Panggang', 'description': '220 kcal, grilled glutinous rice', 'calories': 220},
    {'name': 'Kuih Kosui', 'description': '115 kcal, palm sugar jelly', 'calories': 115},
    {'name': 'Nasi Minyak', 'description': '206 kcal, ghee rice', 'calories': 206},
    {'name': 'Kuih Bingka Ubi', 'description': '240 kcal, baked cassava cake', 'calories': 240},
    {'name': 'Mee Racun', 'description': '550 kcal, spicy seafood noodles', 'calories': 550},
    {'name': 'Sambal Telur', 'description': '170 kcal, eggs in chili sauce', 'calories': 170},
    {'name': 'Kuih Sagu', 'description': '94 kcal, sago pearls dessert', 'calories': 94},
    {'name': 'Nasi Ambeng', 'description': '890 kcal, Javanese rice platter', 'calories': 890},
    {'name': 'Kuih Puteri Ayu', 'description': '130 kcal, steamed pandan sponge cake', 'calories': 130},
    {'name': 'Mee Hoon Kueh', 'description': '363 kcal, hand-torn noodle soup', 'calories': 363},
    {'name': 'Pulut Tai Tai', 'description': '237 kcal, blue-colored glutinous rice', 'calories': 237},
    {'name': 'Kuih Cara Manis', 'description': '80 kcal, sweet pancake', 'calories': 80},
    {'name': 'Nasi Bukhari', 'description': '557 kcal, spiced rice dish', 'calories': 557},
    {'name': 'Kuih Keria', 'description': '175 kcal, sweet potato doughnut', 'calories': 175},
    {'name': 'Mee Rojak', 'description': '745 kcal, fruit and vegetable salad with noodles', 'calories': 745},
    {'name': 'Sambal Belacan', 'description': '20 kcal, per tablespoon', 'calories': 20},
    {'name': 'Kuih Serimuka', 'description': '270 kcal, pandan custard glutinous rice', 'calories': 270},
    {'name': 'Nasi Tumpang', 'description': '450 kcal, rice packed in banana leaf cone', 'calories': 450},
    {'name': 'Kuih Lompang', 'description': '80 kcal, rice flour cake', 'calories': 80},
    {'name': 'Mee Goreng Mamak', 'description': '660 kcal, Indian Muslim style fried noodles', 'calories': 660},
    {'name': 'Pulut Tekan', 'description': '220 kcal, pressed glutinous rice', 'calories': 220},
    {'name': 'Kuih Cincin', 'description': '80 kcal, interlocked-ring shaped snack', 'calories': 80},
    {'name': 'Nasi Kukus', 'description': '130 kcal, steamed rice', 'calories': 130},
    {'name': 'Kuih Pelita', 'description': '115 kcal, pandan and coconut milk custard', 'calories': 115},
    {'name': 'Mee Kolo', 'description': '384 kcal, dry tossed egg noodles', 'calories': 384},
    {'name': 'Sambal Ikan Bilis', 'description': '60 kcal, spicy anchovies', 'calories': 60},
    {'name': 'Kuih Onde Onde', 'description': '95 kcal, glutinous rice ball with palm sugar', 'calories': 95},
    {'name': 'Nasi Goreng Kampung', 'description': '520 kcal, village style fried rice', 'calories': 520},
    {'name': 'Kuih Getas', 'description': '80 kcal, diamond-shaped snack', 'calories': 80},
    {'name': 'Kuih Kapit', 'description': '56 kcal, folded wafer cookie', 'calories': 56},
    {'name': 'Mee Soto', 'description': '385 kcal, spicy chicken noodle soup', 'calories': 385},
    {'name': 'Pulut Kuning', 'description': '241 kcal, yellow glutinous rice', 'calories': 241},
    {'name': 'Kuih Lidah Buaya', 'description': '120 kcal, pandan jelly dessert', 'calories': 120},
    {'name': 'Nasi Kerabu Tumis', 'description': '410 kcal, stir-fried blue rice', 'calories': 410},
    {'name': 'Kuih Tepung Pelita', 'description': '110 kcal, steamed pandan rice cake', 'calories': 110},
    {'name': 'Mee Sup', 'description': '320 kcal, noodle soup', 'calories': 320},
    {'name': 'Sambal Terung', 'description': '150 kcal, spicy eggplant dish', 'calories': 150},
    {'name': 'Kuih Talam Keladi', 'description': '180 kcal, layered yam cake', 'calories': 180},
    {'name': 'Nasi Lemuni', 'description': '380 kcal, herb-infused rice', 'calories': 380},
    {'name': 'Kuih Lapis Betawi', 'description': '215 kcal, spiced layer cake', 'calories': 215},
    {'name': 'Mee Kuah', 'description': '450 kcal, noodles in gravy', 'calories': 450},
    {'name': 'Pulut Panggang Ikan', 'description': '280 kcal, grilled fish in glutinous rice', 'calories': 280},
    {'name': 'Kuih Kacang Ma\'amoul', 'description': '190 kcal, nut-filled pastry', 'calories': 190},
    {'name': 'Nasi Rawon', 'description': '520 kcal, black beef soup with rice', 'calories': 520},
    {'name': 'Kuih Putu Bambu', 'description': '100 kcal, bamboo rice cake', 'calories': 100},
    {'name': 'Mee Goreng Basah', 'description': '580 kcal, wet fried noodles', 'calories': 580},
    {'name': 'Sambal Kangkung', 'description': '130 kcal, spicy water spinach', 'calories': 130},
    {'name': 'Kuih Bakar', 'description': '220 kcal, baked pandan cake', 'calories': 220},
    {'name': 'Nasi Hujan Panas', 'description': '450 kcal, colorful rice dish', 'calories': 450},
    {'name': 'Kuih Seri Ayu', 'description': '150 kcal, steamed pandan sponge cake', 'calories': 150},
    {'name': 'Mee Kicap', 'description': '410 kcal, soy sauce noodles', 'calories': 410},
    {'name': 'Pulut Udang', 'description': '300 kcal, glutinous rice with shrimp', 'calories': 300},
    {'name': 'Kuih Bom', 'description': '180 kcal, fried dough ball with filling', 'calories': 180},
    {'name': 'Nasi Kepal', 'description': '220 kcal, rice ball', 'calories': 220},
    {'name': 'Kuih Lompong', 'description': '130 kcal, pandan roll cake', 'calories': 130},
    {'name': 'Mee Goreng Udang', 'description': '620 kcal, prawn fried noodles', 'calories': 620},
    {'name': 'Sambal Tumis', 'description': '80 kcal, stir-fried chili paste', 'calories': 80},
    {'name': 'Kuih Kasturi', 'description': '160 kcal, pumpkin cake', 'calories': 160},
    {'name': 'Nasi Goreng Pattaya', 'description': '680 kcal, fried rice wrapped in egg', 'calories': 680},
    {'name': 'Kuih Keria Gula Melaka', 'description': '200 kcal, sweet potato doughnut with palm sugar', 'calories': 200},
    {'name': 'Mee Hailam', 'description': '550 kcal, Hainanese noodles', 'calories': 550},
    {'name': 'Pulut Hitam', 'description': '270 kcal, black glutinous rice dessert', 'calories': 270},
    {'name': 'Kuih Cara Berlauk', 'description': '140 kcal, savory pancake', 'calories': 140},
    {'name': 'Nasi Goreng Ikan Masin', 'description': '590 kcal, salted fish fried rice', 'calories': 590},
    {'name': 'Kuih Lapis Sarawak', 'description': '230 kcal, Sarawak layer cake', 'calories': 230},
    {'name': 'Mee Goreng Sotong', 'description': '580 kcal, squid fried noodles', 'calories': 580},
    {'name': 'Sambal Goreng Tempe', 'description': '220 kcal, spicy fried tempeh', 'calories': 220},
    {'name': 'Kuih Apam Balik Gula Merah', 'description': '390 kcal, turnover pancake with palm sugar', 'calories': 390},
    {'name': 'Nasi Goreng Cili Padi', 'description': '570 kcal, bird\'s eye chili fried rice', 'calories': 570},
    {'name': 'Kuih Bingka Ubi Kayu', 'description': '250 kcal, baked cassava cake', 'calories': 250},
    {'name': 'Mee Rebus Tulang', 'description': '620 kcal, bone broth noodles', 'calories': 620},
    {'name': 'Pulut Durian', 'description': '350 kcal, glutinous rice with durian', 'calories': 350},
    {'name': 'Kuih Sagu Kelantan', 'description': '180 kcal, Kelantanese sago dessert', 'calories': 180},
    {'name': 'Nasi Goreng Belacan', 'description': '540 kcal, shrimp paste fried rice', 'calories': 540},
    {'name': 'Kuih Koci Pulut Hitam', 'description': '220 kcal, black glutinous rice dumpling', 'calories': 220},
    {'name': 'Mee Bandung Muar', 'description': '580 kcal, Muar-style bandung noodles', 'calories': 580},
    {'name': 'Sambal Hijau', 'description': '70 kcal, green chili sambal', 'calories': 70},
    {'name': 'Kuih Lapis Pelangi', 'description': '200 kcal, rainbow layer cake', 'calories': 200},
    {'name': 'Nasi Goreng Kampung Jawa', 'description': '530 kcal, Javanese village fried rice', 'calories': 530},
    {'name': 'Kuih Seri Muka Durian', 'description': '290 kcal, durian custard glutinous rice', 'calories': 290},
    {'name': 'Mee Kari Nyonya', 'description': '520 kcal, Nyonya curry noodles', 'calories': 520},
    {'name': 'Pulut Ikan Kering', 'description': '310 kcal, glutinous rice with dried fish', 'calories': 310},
    {'name': 'Kuih Ketayap Jagung', 'description': '200 kcal, corn-filled crepe roll', 'calories': 200},
    {'name': 'Nasi Goreng Kerabu', 'description': '480 kcal, herb salad fried rice', 'calories': 480},
    {'name': 'Kuih Talam Kelapa Muda', 'description': '170 kcal, young coconut layered cake', 'calories': 170},
    {'name': 'Mee Siam Kuah', 'description': '490 kcal, Siamese noodles in gravy', 'calories': 490},
    {'name': 'Sambal Mangga', 'description': '90 kcal, mango chili sauce', 'calories': 90},
    {'name': 'Kuih Puteri Berendam', 'description': '160 kcal, glutinous rice balls in coconut milk', 'calories': 160},
    {'name': 'Nasi Goreng Daging Merah', 'description': '610 kcal, red meat fried rice', 'calories': 610},
    {'name': 'Kuih Lompat Tikam', 'description': '140 kcal, layered rice flour and palm sugar cake', 'calories': 140},
    {'name': 'Mee Goreng Ikan', 'description': '540 kcal, fish fried noodles', 'calories': 540},
    {'name': 'Pulut Rendang', 'description': '420 kcal, glutinous rice with rendang', 'calories': 420},
    {'name': 'Kuih Cara Berlauk Udang', 'description': '160 kcal, savory shrimp pancake', 'calories': 160},
    {'name': 'Nasi Goreng Petai', 'description': '550 kcal, stink bean fried rice', 'calories': 550},
    {'name': 'Kuih Lapis Legit', 'description': '260 kcal, spiced thousand layer cake', 'calories': 260},
    {'name': 'Mee Kicap Special', 'description': '480 kcal, special soy sauce noodles', 'calories': 480},
    {'name': 'Sambal Ikan Bilis Petai', 'description': '110 kcal, anchovy and stink bean sambal', 'calories': 110},
    {'name': 'Kuih Seri Pandan', 'description': '180 kcal, pandan flavored rice cake', 'calories': 180},
    {'name': 'Nasi Goreng Telur Masin', 'description': '590 kcal, salted egg fried rice', 'calories': 590},
    {'name': 'Kuih Keria Kentang', 'description': '190 kcal, potato doughnut', 'calories': 190},
    {'name': 'Mee Udang Galah', 'description': '580 kcal, giant freshwater prawn noodles', 'calories': 580},
    {'name': 'Pulut Mangga', 'description': '330 kcal, glutinous rice with mango', 'calories': 330},
    {'name': 'Kuih Bakar Pandan', 'description': '230 kcal, baked pandan cake', 'calories': 230},
    {'name': 'Nasi Goreng Kampung Udang', 'description': '560 kcal, village-style prawn fried rice', 'calories': 560},
    {'name': 'Kuih Lapis Sagu Berkuah', 'description': '200 kcal, layered sago cake with sauce', 'calories': 200},
    {'name': 'Mee Goreng Sayur', 'description': '490 kcal, vegetable fried noodles', 'calories': 490},
    {'name': 'Sambal Belacan Petai', 'description': '100 kcal, shrimp paste and stink bean sambal', 'calories': 100},
    {'name': 'Kuih Kacang Merah', 'description': '170 kcal, red bean cake', 'calories': 170},
    {'name': 'Nasi Goreng Ikan Masin Belacan', 'description': '600 kcal, salted fish and shrimp paste fried rice', 'calories': 600},
    {'name': 'Kuih Lapis Surabaya', 'description': '250 kcal, Surabaya layered cake', 'calories': 250},
    {'name': 'Mee Kari Kepala Ikan', 'description': '530 kcal, fish head curry noodles', 'calories': 530},
    {'name': 'Pulut Panggang Kelapa', 'description': '290 kcal, grilled coconut glutinous rice', 'calories': 290},
    {'name': 'Kuih Cara Berlauk Ayam', 'description': '150 kcal, savory chicken pancake', 'calories': 150},
    {'name': 'Nasi Goreng Kampung Ikan Bilis', 'description': '540 kcal, village-style anchovy fried rice', 'calories': 540},
    {'name': 'Kuih Lapis Ubi Kayu', 'description': '220 kcal, layered cassava cake', 'calories': 220},
    {'name': 'Mee Goreng Daging', 'description': '590 kcal, beef fried noodles', 'calories': 590},
    {'name': 'Sambal Tempoyak', 'description': '130 kcal, fermented durian chili paste', 'calories': 130},
    {'name': 'Kuih Sago Gula Melaka', 'description': '180 kcal, sago pearls with palm sugar', 'calories': 180},
    {'name': 'Nasi Goreng Kampung Seafood', 'description': '570 kcal, village-style seafood fried rice', 'calories': 570},
    {'name': 'Kuih Bingka Labu', 'description': '210 kcal, baked pumpkin cake', 'calories': 210},
    {'name': 'Mee Rebus Johor', 'description': '590 kcal, Johor-style boiled noodles', 'calories': 590},
    {'name': 'Pulut Inti Durian', 'description': '360 kcal, glutinous rice with durian filling', 'calories': 360},
    {'name': 'Kuih Lapis Keladi', 'description': '230 kcal, layered yam cake', 'calories': 230},
    {'name': 'Nasi Goreng Cina', 'description': '520 kcal, Chinese-style fried rice', 'calories': 520},
    {'name': 'Kuih Seri Muka Pandan', 'description': '280 kcal, pandan custard glutinous rice', 'calories': 280},
    {'name': 'Mee Bandung Johor', 'description': '610 kcal, Johor-style bandung noodles', 'calories': 610},
    {'name': 'Sambal Sotong Kering', 'description': '190 kcal, dried squid sambal', 'calories': 190},
    {'name': 'Kuih Koci Pandan', 'description': '210 kcal, pandan-flavored glutinous rice dumpling', 'calories': 210},
    {'name': 'Nasi Goreng Kampung Daging', 'description': '580 kcal, village-style beef fried rice', 'calories': 580},
    {'name': 'Kuih Lapis Ubi Ungu', 'description': '240 kcal, layered purple yam cake', 'calories': 240},
    {'name': 'Mee Goreng Kerang', 'description': '570 kcal, cockle fried noodles', 'calories': 570},
    {'name': 'Pulut Panggang Ikan Kering', 'description': '300 kcal, grilled glutinous rice with dried fish', 'calories': 300},
    {'name': 'Kuih Cara Berlauk Sotong', 'description': '170 kcal, savory squid pancake', 'calories': 170},
    {'name': 'Nasi Goreng Kampung Telur Masin', 'description': '590 kcal, village-style salted egg fried rice', 'calories': 590},
    {'name': 'Kuih Lapis Pisang', 'description': '220 kcal, layered banana cake', 'calories': 220},
    {'name': 'Mee Kari Udang', 'description': '540 kcal, prawn curry noodles', 'calories': 540},
    {'name': 'Sambal Terung Ikan Bilis', 'description': '160 kcal, eggplant and anchovy sambal', 'calories': 160},
    {'name': 'Kuih Talam Ubi', 'description': '190 kcal, layered sweet potato cake', 'calories': 190},
    {'name': 'Nasi Goreng Kampung Kerabu', 'description': '510 kcal, village-style herb salad fried rice', 'calories': 510},
    {'name': 'Kuih Seri Ayu Gula Melaka', 'description': '170 kcal, palm sugar pandan sponge cake', 'calories': 170},
    {'name': 'Mee Goreng Telur', 'description': '550 kcal, egg fried noodles', 'calories': 550},
    {'name': 'Pulut Serunding Ayam', 'description': '340 kcal, glutinous rice with chicken floss', 'calories': 340},
    {'name': 'Kuih Lompang Gula Merah', 'description': '140 kcal, palm sugar rice flour cake', 'calories': 140},
    {'name': 'Nasi Goreng Kampung Ikan Masin', 'description': '570 kcal, village-style salted fish fried rice', 'calories': 570},
    {'name': 'Kuih Lapis Legit Prune', 'description': '270 kcal, prune spiced layer cake', 'calories': 270},
    {'name': 'Mee Soto Ayam', 'description': '410 kcal, chicken soto noodles', 'calories': 410},
    {'name': 'Sambal Udang Petai', 'description': '220 kcal, prawn and stink bean sambal', 'calories': 220},
    {'name': 'Kuih Kasturi Nanas', 'description': '180 kcal, pineapple-filled pastry', 'calories': 180},
    {'name': 'Nasi Goreng Kampung Belacan', 'description': '550 kcal, village-style shrimp paste fried rice', 'calories': 550},
    {'name': 'Kuih Lapis Suji', 'description': '230 kcal, pandan leaf layered cake', 'calories': 230},
    {'name': 'Mee Goreng Seafood', 'description': '600 kcal, seafood fried noodles', 'calories': 600},
    {'name': 'Pulut Udang Galah', 'description': '320 kcal, glutinous rice with giant freshwater prawn', 'calories': 320},
    {'name': 'Kuih Cara Berlauk Kerang', 'description': '160 kcal, savory cockle pancake', 'calories': 160},
    {'name': 'Nasi Goreng Kampung Cili Padi', 'description': '560 kcal, village-style bird eye chili fried rice', 'calories': 560},
    {'name': 'Kuih Lapis Kelapa', 'description': '250 kcal, layered coconut cake', 'calories': 250},
    {'name': 'Mee Kicap Ayam', 'description': '490 kcal, chicken soy sauce noodles', 'calories': 490},
    {'name': 'Sambal Ikan Bilis Kacang', 'description': '130 kcal, anchovy and peanut sambal', 'calories': 130},
    {'name': 'Kuih Sago Gula Melaka Kelapa', 'description': '200 kcal, sago pearls with palm sugar and coconut', 'calories': 200},
    {'name': 'Nasi Goreng Kampung Petai', 'description': '570 kcal, village-style stink bean fried rice', 'calories': 570},
    {'name': 'Kuih Bingka Ubi Kayu Gula Merah', 'description': '260 kcal, cassava cake with palm sugar', 'calories': 260},
    {'name': 'Mee Rebus Tulang Rawan', 'description': '630 kcal, cartilage bone noodles', 'calories': 630},
    {'name': 'Pulut Durian Gula Melaka', 'description': '370 kcal, glutinous rice with durian and palm sugar', 'calories': 370},
    {'name': 'Kuih Lapis Seri Kaya', 'description': '240 kcal, coconut jam layered cake', 'calories': 240},
    {'name': 'Nasi Goreng Kampung Ikan Masin Belacan', 'description': '590 kcal, village-style salted fish and shrimp paste fried rice', 'calories': 590},
    {'name': 'Kuih Seri Muka Durian', 'description': '300 kcal, durian custard glutinous rice', 'calories': 300},
    {'name': 'Mee Kari Kepala Ikan Merah', 'description': '550 kcal, red snapper head curry noodles', 'calories': 550},
    {'name': 'Sambal Telur Ikan Masin', 'description': '180 kcal, salted fish egg sambal', 'calories': 180},
    {'name': 'Kuih Lapis Ubi Keledek', 'description': '230 kcal, layered sweet potato cake', 'calories': 230},
    {'name': 'Nasi Goreng Kampung Udang Galah', 'description': '590 kcal, village-style giant freshwater prawn fried rice', 'calories': 590},
    {'name': 'Kuih Koci Kacang Hijau', 'description': '220 kcal, mung bean glutinous rice dumpling', 'calories': 220},
    {'name': 'Mee Goreng Sotong Kering', 'description': '560 kcal, dried squid fried noodles', 'calories': 560},
    {'name': 'Pulut Ikan Keli', 'description': '330 kcal, glutinous rice with catfish', 'calories': 330},
    {'name': 'Kuih Bakar Pandan Gula Melaka', 'description': '250 kcal, baked pandan cake with palm sugar', 'calories': 250},
    {'name': 'Nasi Goreng Kampung Daging Salai', 'description': '580 kcal, village-style smoked beef fried rice', 'calories': 580},
    {'name': 'Kuih Lapis Sagu Durian', 'description': '260 kcal, durian layered sago cake', 'calories': 260},
    {'name': 'Mee Goreng Sayur Campur', 'description': '510 kcal, mixed vegetable fried noodles', 'calories': 510},
    {'name': 'Sambal Belacan Mangga Muda', 'description': '110 kcal, young mango shrimp paste sambal', 'calories': 110},
    {'name': 'Kuih Kacang Merah Kelapa', 'description': '190 kcal, red bean and coconut cake', 'calories': 190},
    {'name': 'Nasi Goreng Kampung Ikan Bilis Petai', 'description': '560 kcal, village-style anchovy and stink bean fried rice', 'calories': 560},
    {'name': 'Kuih Lapis Surabaya Pandan', 'description': '270 kcal, pandan Surabaya layered cake', 'calories': 270},
    {'name': 'Mee Kari Kepala Ikan Jenahak', 'description': '540 kcal, snapper head curry noodles', 'calories': 540},
    {'name': 'Pulut Panggang Kelapa Parut', 'description': '310 kcal, grilled glutinous rice with grated coconut', 'calories': 310},
    {'name': 'Kuih Cara Berlauk Ayam Rempah', 'description': '170 kcal, savory spiced chicken pancake', 'calories': 170},
    {'name': 'Nasi Goreng Kampung Ikan Bilis Kacang', 'description': '550 kcal, village-style anchovy and peanut fried rice', 'calories': 550},
    {'name': 'Kuih Lapis Ubi Kayu Gula Merah', 'description': '240 kcal, cassava layered cake with palm sugar', 'calories': 240},
    {'name': 'Mee Goreng Daging Salai', 'description': '600 kcal, smoked beef fried noodles', 'calories': 600},
    {'name': 'Sambal Tempoyak Ikan Patin', 'description': '220 kcal, fermented durian and river fish sambal', 'calories': 220},
    {'name': 'Kuih Sago Gula Melaka Durian', 'description': '210 kcal, sago pearls with palm sugar and durian', 'calories': 210},
    {'name': 'Nasi Goreng Kampung Seafood Pedas', 'description': '590 kcal, village-style spicy seafood fried rice', 'calories': 590},
    {'name': 'Kuih Bingka Labu Gula Merah', 'description': '230 kcal, pumpkin cake with palm sugar', 'calories': 230},
    {'name': 'Mee Rebus Johor Tulang', 'description': '610 kcal, Johor-style bone broth noodles', 'calories': 610},
    {'name': 'Pulut Inti Durian Gula Melaka', 'description': '380 kcal, glutinous rice with durian and palm sugar filling', 'calories': 380},
    {'name': 'Kuih Lapis Keladi Santan', 'description': '250 kcal, layered yam cake with coconut milk', 'calories': 250},
    {'name': 'Nasi Goreng Cina Seafood', 'description': '540 kcal, Chinese-style seafood fried rice', 'calories': 540},
  ];

  List<Map<String, dynamic>> _customFoodLibrary = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomFoods();
  }

  Future<void> _loadCustomFoods() async {
    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('custom_foods').get();
      setState(() {
        _customFoodLibrary = querySnapshot.docs
            .map((doc) => {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        })
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading custom foods: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _foodLibrary => [..._defaultFoodLibrary, ..._customFoodLibrary];

  Future<void> _addCustomFood(Map<String, dynamic> newFood) async {
    try {
      DocumentReference docRef = await FirebaseFirestore.instance.collection('custom_foods').add(newFood);
      setState(() {
        _customFoodLibrary.add({
          'id': docRef.id,
          ...newFood,
        });
      });
    } catch (e) {
      print('Error adding custom food: $e');
    }
  }

  void _openAddCustomFoodPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCustomFoodPage(onAddFood: _addCustomFood),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      // The custom food was already added in _addCustomFood, so we don't need to do anything here
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredFood = _foodLibrary
        .where((food) =>
        food['name'].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: MyAppbar(showBackButton: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Search Food',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[800],
                prefixIcon: Icon(Icons.search, color: Colors.white70),
                suffixIcon: IconButton(
                  icon: Icon(Icons.add, color: Colors.white),
                  onPressed: _openAddCustomFoodPage,
                  tooltip: 'Add Custom Food',
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: filteredFood.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    filteredFood[index]['name'],
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    filteredFood[index]['description'],
                    style: TextStyle(color: Colors.white70),
                  ),
                  onTap: () {
                    Navigator.pop(context, filteredFood[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}