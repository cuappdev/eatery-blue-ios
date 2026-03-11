//
//  SettingsAboutModelController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/27/22.
//

import Foundation

class SettingsAboutModelController: SettingsAboutViewController {
    private struct Section {
        let title: String
        let members: [String]
    }

    private let sections = [
        Section(title: "Pod Leads", members: [
            "Aayush Agnihotri",
            "Stefanie Rivera-Osorio",
            "Anvi Savant",
            "Angela Chiang",
            "Leah Kim",
            "Angelina Chen",
            "Adelynn Wu",
            "Amy Wang",
            "Ashley Herrera",
            "Nina Zambrano"
        ]),
        Section(title: "Product Designers", members: [
            "Yoobin Lee",
            "Gillian Fang",
            "Selena Chen",
            "Angela Chiang",
            "Leah Kim",
            "Lorna Ding",
            "Seojin Park",
            "Ethan G.R. Lee",
            "Wonjin Eum",
            "Funmi Olukanmi",
            "Lauren Jun"
        ]),
        Section(title: "iOS Developers", members: [
            "Charles Liggins",
            "Jay Zheng",
            "Zain Bilal",
            "Angelina Chen",
            "Adelynn Wu",
            "Duru Alayli",
            "Jiwon Jeong",
            "Asen Kim Ou",
            "Andrew Gao",
            "Peter Bidoshi",
            "Alyssa Wang",
            "Arielle Nudelman",
            "Caitlyn Jin",
            "Isha Nagireddy",
            "Amy Yang",
            "Kaylee Ulep",
            "Gabriel Castillo",
            "Anatoli Monsalve",
            "Antoinette Torres"
        ]),
        Section(title: "Android Developers", members: [
            "Andrew Cheung",
            "Connie Liu",
            "Melissa Velasquez",
            "Amy Wang",
            "Caleb Shim",
            "Emil Jiang",
            "Ryan Cheung",
            "Danny McCance",
            "Gregor Guerrier",
            "Brian Hu",
            "Mabel Qiu",
            "Jarmin Weng",
            "Abigail Labanok",
            "Preston Williams",
            "Zachary Seidner",
            "Helen Bian",
            "Jonathan Chen"
        ]),
        Section(title: "Backend Developers", members: [
            "Joshua Dirga",
            "Fanhao Yu",
            "Chimdi Ejiogu",
            "Ashley Herrera",
            "Wyatt Cox",
            "Skye Slattery",
            "Lauren Ah-Hot",
            "Cindy Liang",
            "Sophie Strausberg",
            "Chris Voon",
            "Claire Yu",
            "Anik Dey",
            "Tran Tran",
            "Olivia Yu",
            "Kevin Biliguun",
            "Anton Matchev"
        ]),
        Section(title: "Marketers", members: [
            "Christine Tao",
            "Nina Zambrano",
            "Rohan Sabbella",
            "William Lee",
            "Maya Levine",
            "Parker Woo",
            "Michael Hsieh",
            "Enzo Hiu",
            "Anna Felten",
            "Wendy Yu",
            "Carolyn Fu",
            "Amber Dong",
            "Monica Lee",
            "Julia Kwon",
            "Michael Abaseber",
            "Candy Wu"
        ])
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpCarouselViews()
    }

    private func setUpCarouselViews() {
        let sections = [sections[0]] + sections[1...].shuffled()
        for section in sections {
            addCarouselView(section)
        }
    }

    private func addCarouselView(_ section: Section) {
        addCarouselView { carouselView in
            carouselView.addTitleView(section.title)
            carouselView.addSeparator()

            for (i, member) in section.members.shuffled().enumerated() {
                carouselView.addMemberView(name: member)

                if i != section.members.count - 1 {
                    carouselView.addSeparator()
                }
            }
        }
    }
}
