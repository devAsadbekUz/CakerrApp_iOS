//
//  MockData.swift
//  CakeShop.2.1
//
//  Created by Asadbek Muzaffarov on 22/11/25.
//



import UIKit

class MockData {

    static let shared = MockData()
    private init() {}

    // MARK: - Banner Items
    let bannerItems: [BannerItem] = [
        BannerItem(id: 1, image: "cake1",
                   title: "🎉 Yangi mahsulotlar",
                   subtitle: "30% chegirma barcha tortlara",
                   backgroundColor: UIColor(red: 0.91, green: 0.26, blue: 0.39, alpha: 1)),

        BannerItem(id: 2, image: "cake2",
                   title: "💝 Maxsus takliflar",
                   subtitle: "Tug'ilgan kun tortlari uchun",
                   backgroundColor: UIColor(red: 0.58, green: 0.26, blue: 0.91, alpha: 1)),

        BannerItem(id: 3, image: "cake3",
                   title: "🎂 To'y tortlari",
                   subtitle: "Yangi dizaynlar mavjud",
                   backgroundColor: UIColor(red: 0.26, green: 0.45, blue: 0.91, alpha: 1)),

        BannerItem(id: 4, image: "cake4",
                   title: "✨ Bepul yetkazib berish",
                   subtitle: "500,000 UZS dan yuqori buyurtmalarga",
                   backgroundColor: UIColor(red: 0.91, green: 0.45, blue: 0.26, alpha: 1))
    ]

    // MARK: - Categories
    let categories: [CategoryItem] = [
        CategoryItem(name: "Tug'ilgan kun", image: "birthdayCat"),
        CategoryItem(name: "To'y", image: "weddingCat"),
        CategoryItem(name: "Yillik", image: "anniversaryCat"),
        CategoryItem(name: "Bolajon", image: "childrenCat"),
        CategoryItem(name: "Shodlik", image: "happinessCat"),
        CategoryItem(name: "Muhabbat", image: "loveCat"),
        CategoryItem(name: "Maxsus tortlar", image: "specialCat")
    ]

    // MARK: - ALL CAKES (FLAT LIST)
    lazy var allCakes: [CakeItem] = {

        return  [
            
            // MARK: - Tug'ilgan kun
            CakeItem(
                id: "1",
                name: "Shokoladli tort this is a very long to test what will happen",
                category: "Tug'ilgan kun",
                images: ["cake1"],
                pricesByServing: [
                    2: 90000, 4: 130000, 6: 170000, 8: 210000, 12: 260000, 15: 310000
                ],
                
                servings: [2, 4, 6, 8, 12, 15],
                description: "Boy shokoladli krem bilan tayyorlangan klassik tug'ilgan kun torti.",
                status: "Tayyor",
                innerFlavors: ["Shokolad"],
                outerCoating: ["Chocolate Ganache"],
                innerCoating: ["Shokoladli krem"],     // <-- added
                toppings: ["Gilos", "Shokolad bo'laklari"]
            ),

            CakeItem(
                id: "2",
                name: "Qulupnayli tort",
                category: "Tug'ilgan kun",
                images: ["cake2"],
                pricesByServing: [
                    2: 90000, 4: 130000, 6: 170000, 8: 210000, 12: 260000, 15: 310000
                ],
                
                servings: [2, 4, 6, 8, 12, 15],
                description: "Yumshoq biskvit va yangi qulupnay bilan bezatilgan yorqin tug'ilgan kun torti.",
                status: "Tayyor",
                innerFlavors: ["Qulupnay", "Vanil"],
                outerCoating: ["Cream Cheese"],
                innerCoating: ["Qulupnayli krem"],     // <-- added
                toppings: ["Qulupnay", "Shakar kukuni"]
            ),

            CakeItem(
                id: "3",
                name: "Vanilli tort",
                category: "Tug'ilgan kun",
                images: ["cake3"],
                pricesByServing: [
                    2: 90000, 4: 130000, 6: 170000, 8: 210000, 12: 260000, 15: 310000
                ],
                
                servings: [2, 4, 6, 8, 12, 15],
                description: "Yengil vanilli krem bilan yumshoq biskvitli klassik tort.",
                status: nil,
                innerFlavors: ["Vanil"],
                outerCoating: ["Buttercream"],
                innerCoating: ["Vanilli krem"],        // <-- added
                toppings: ["Vanil kukuni"]
            ),

            CakeItem(
                id: "4",
                name: "Karamelli tort",
                category: "Tug'ilgan kun",
                images: ["cake4"],
                pricesByServing: [
                    2: 90000, 4: 130000, 6: 170000, 8: 210000, 12: 260000, 15: 310000
                ],
                
                servings: [2, 4, 6, 8, 12, 15],
                description: "Qaymoqli karamel bilan to'ldirilgan mazali tort.",
                status: nil,
                innerFlavors: ["Karamel"],
                outerCoating: ["Cream Caramel"],
                innerCoating: ["Karamelli krem"],       // <-- added
                toppings: ["Karamel tilimlari"]
            ),

            // MARK: - To‘y
            CakeItem(
                id: "5",
                name: "Oq to'y torti",
                category: "To'y",
                images: ["cake1"],
                pricesByServing: [
                    2: 150000, 4: 230000, 6: 300000, 8: 380000, 12: 520000, 15: 650000
                ],
                
                servings: [2, 4, 6, 8, 12, 15],
                description: "Klassik oq to'y torti, nafis dizayn va maxsus bezaklar.",
                status: "Tayyor",
                innerFlavors: ["Vanil", "Shokolad"],
                outerCoating: ["Mastika"],
                innerCoating: ["Vanilli krem", "Shokoladli krem"],   // <-- added
                toppings: ["Gul bezaklar"]
            ),

            CakeItem(
                id: "6",
                name: "Gullashgan tort",
                category: "To'y",
                images: ["cake2"],
                pricesByServing: [
                    2: 150000, 4: 230000, 6: 300000, 8: 380000, 12: 520000, 15: 650000
                ],
                
                servings: [2, 4, 6, 8, 12, 15],
                description: "Gullar bilan bezatilgan romantik to'y torti.",
                status: nil,
                innerFlavors: ["Vanil"],
                outerCoating: ["Cream Cheese"],
                innerCoating: ["Vanilli krem"],         // <-- added
                toppings: ["Yasama gullar"]
            ),

            CakeItem(
                id: "7",
                name: "Classic to‘y torti",
                category: "To'y",
                images: ["cake3"],
                pricesByServing: [
                    2: 150000, 4: 230000, 6: 300000, 8: 380000, 12: 520000, 15: 650000
                ],
                
                servings: [2, 4, 6, 8, 12, 15],
                description: "Klassik uch qavatli to'y torti.",
                status: nil,
                innerFlavors: ["Shokolad", "Karamel"],
                outerCoating: ["Fondant"],
                innerCoating: ["Shokoladli krem", "Karamelli krem"], // <-- added
                toppings: ["Gul bezaklar"]
            ),

            // MARK: - Yillik
            CakeItem(
                id: "8",
                name: "Medovik",
                category: "Yillik",
                images: ["cake4"],
                pricesByServing: [
                    2: 100000, 4: 150000, 6: 200000, 8: 250000, 12: 320000, 15: 400000
                ],
                
                servings: [2, 4, 6, 8, 12, 15],
                description: "Asalli yumshoq qatlamli klassik medovik.",
                status: nil,
                innerFlavors: ["Asalli krem"],
                outerCoating: ["Cream"],
                innerCoating: ["Asalli ichki krem"],    // <-- added
                toppings: ["Asal tomchilari"]
            ),

            CakeItem(
                id: "9",
                name: "Napoleon",
                category: "Yillik",
                images: ["cake1"],
                pricesByServing: [
                    2: 100000, 4: 150000, 6: 200000, 8: 250000, 12: 320000, 15: 400000
                ],
                
                servings: [2, 4, 6, 8, 12, 15],
                description: "Yupqa qatlamli, qaymoqli klassik napoleon torti.",
                status: nil,
                innerFlavors: ["Vanil krem"],
                outerCoating: ["Cream"],
                innerCoating: ["Vanil ichki krem"],     // <-- added
                toppings: ["Napoleon bo'laklari"]
            ),

            // MARK: - Bolajon
            CakeItem(
                id: "10",
                name: "Pushti bolajon torti",
                category: "Bolajon",
                images: ["cake2"],
                pricesByServing: [
                    2: 80000, 4: 120000, 6: 160000, 8: 200000, 12: 240000, 15: 300000
                ],
                
                servings: [2, 4, 6, 8, 12, 15],
                description: "Bolajonlar uchun pushti rangli tort.",
                status: nil,
                innerFlavors: ["Qulupnay"],
                outerCoating: ["Cream"],
                innerCoating: ["Qulupnayli krem"],      // <-- added
                toppings: ["Shirin bezaklar"]
            ),

            CakeItem(
                id: "11",
                name: "Ko‘k bolajon torti",
                category: "Bolajon",
                images: ["cake3"],
                pricesByServing: [
                    2: 80000, 4: 120000, 6: 160000, 8: 200000, 12: 240000, 15: 300000
                ],
                
                servings: [2, 4, 6, 8, 12, 15],
                description: "Ko‘k rangli yumshoq bolalar torti.",
                status: nil,
                innerFlavors: ["Vanil"],
                outerCoating: ["Cream"],
                innerCoating: ["Vanilli krem"],         // <-- added
                toppings: ["Shirin bezaklar"]
            ),

            // MARK: - Shodlik
            CakeItem(
                id: "12",
                name: "Rangli shodlik",
                category: "Shodlik",
                images: ["cake4"],
                pricesByServing: [
                    2: 110000, 4: 160000, 6: 210000, 8: 260000, 12: 340000, 15: 420000
                ],
                
                servings: [2, 4, 6, 8, 12, 15],
                description: "Bayramlar uchun mos rangli tort.",
                status: nil,
                innerFlavors: ["Shokolad", "Vanil"],
                outerCoating: ["Buttercream"],
                innerCoating: ["Shokoladli krem", "Vanilli krem"], // <-- added
                toppings: ["Rangli konfetlar"]
            ),

            CakeItem(
                id: "13",
                name: "Bayram torti",
                category: "Shodlik",
                images: ["cake1"],
                pricesByServing: [
                    2: 110000, 4: 160000, 6: 210000, 8: 260000, 12: 340000, 15: 420000
                ],
                
                servings: [2, 4, 6, 8, 12, 15],
                description: "Bayramona dizayndagi tort.",
                status: nil,
                innerFlavors: ["Vanil"],
                outerCoating: ["Cream"],
                innerCoating: ["Vanilli krem"],         // <-- added
                toppings: ["Rangli yulduzchalar"]
            ),

            // MARK: - Muhabbat
            CakeItem(
                id: "14",
                name: "Yurakli tort",
                category: "Muhabbat",
                images: ["cake2"],
                pricesByServing: [
                    2: 110000, 4: 160000, 6: 210000, 8: 260000, 12: 340000, 15: 420000
                ],
                
                servings: [2, 4, 6, 8, 12, 15],
                description: "Sevgi timsoli — yurak shaklidagi tort.",
                status: nil,
                innerFlavors: ["Qulupnay"],
                outerCoating: ["Pink Cream"],
                innerCoating: ["Qulupnayli krem"],       // <-- added
                toppings: ["Qizil yurakchalar"]
            ),

            CakeItem(
                id: "15",
                name: "Qizil tort",
                category: "Muhabbat",
                images: ["cake3"],
                pricesByServing: [
                    2: 110000, 4: 160000, 6: 210000, 8: 260000, 12: 340000, 15: 420000
                ],
                
                servings: [2, 4, 6, 8, 12, 15],
                description: "Loviya qizil krem bilan bezatilgan tort.",
                status: nil,
                innerFlavors: ["Shokolad"],
                outerCoating: ["Red Velvet Cream"],
                innerCoating: ["Shokoladli krem"],       // <-- added
                toppings: ["Qizil bo'yoqlar"]
            ),

            // MARK: - Maxsus tortlar
            CakeItem(
                id: "16",
                name: "Maxsus dizayn",
                category: "Maxsus tortlar",
                images: ["cake4"],
                pricesByServing: [
                    2: 140000, 4: 200000, 6: 270000, 8: 350000, 12: 480000, 15: 600000
                ],
                
                servings: [2, 4, 6, 8, 12, 15],
                description: "Buyurtma asosida maxsus dizayn bilan tayyorlanadi.",
                status: nil,
                innerFlavors: ["Shokolad", "Vanil"],
                outerCoating: ["Fondant"],
                innerCoating: ["Vanilli krem", "Shokoladli krem"],  // <-- added
                toppings: ["Maxsus bezaklar"]
            ),

            CakeItem(
                id: "17",
                name: "Individual tort",
                category: "Maxsus tortlar",
                images: ["cake1"],
                pricesByServing: [
                    2: 140000, 4: 200000, 6: 270000, 8: 350000, 12: 480000, 15: 600000
                ],

                servings: [2, 4, 6, 8, 12, 15],
                description: "Individual dizayndagi tort. Maxsus ehtiyojlarga mos.",
                status: nil,
                innerFlavors: ["Karamel"],
                outerCoating: ["Chocolate Cream"],
                innerCoating: ["Karamelli krem"],       // <-- added
                toppings: ["Maxsus bezaklar"]
            )

        ]
    }()

    // MARK: - Grouped by Category
    var cakesByCategory: [[CakeItem]] {
        categories.map { category in
            allCakes.filter { $0.category == category.name }
        }
    }
}

