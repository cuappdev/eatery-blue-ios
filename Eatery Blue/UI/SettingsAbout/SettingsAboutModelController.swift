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
            "TK Kong",
            "William Ma",
            "Conner Swenberg",
            "Connor Reinhold",
            "Gracie Jing",
            "Sergio Diaz",
            "Matthew Wong",
            "Antoinette Torres",
            "Thomas Vignos"
        ]),
        Section(title: "Product Designers", members: [
            "TK Kong",
            "Brendan Elliot",
            "Zain Khoja",
            "Michael Huang",
            "Ravina Patel",
            "Gracie Jing",
            "Zixian Jia",
            "Dennis Quizhpi",
            "Kathleen Anderson",
            "Funmi Olukanmi",
            "Carrie Kim"
        ]),
        Section(title: "iOS Developers", members: [
            "William Ma",
            "Ethan Fine",
            "Gonzalo Gonzalez",
            "Reade Plunkett",
            "Sergio Diaz",
            "Daniel Vebman",
            "Justin Ngai",
            "Jennifer Gu",
            "Antoinette Torres",
            "Jayson Hahn",
            "Peter Bidoshi",
            "Cassidy Xu",
            "Charles Liggins"
        ]),
        Section(title: "Android Developers", members: [
            "Lesley Huang",
            "Jae Young Choi",
            "Jonvi Rollins",
            "Connor Reinhold",
            "Yanlam Ko",
            "Chris Desir",
            "Adam Kadhim",
            "Aastha Shab",
            "Jonah Gershon",
            "Justin Guo",
            "Kevin Sun",
            "Emily Hu",
            "Sophie Meng",
            "Gregor Guerrier",
            "Olivia Jiang",
            "Helen Bian",
            "Amy Wang",
            "Zach Seidner"
        ]),
        Section(title: "Backend Developers", members: [
            "Conner Swenberg",
            "Orko Sinha",
            "Yuna Shin",
            "Alanna Zhou",
            "Raahi Menon",
            "Shungo Najima",
            "Mateo Weiner",
            "Kidus Zegeye",
            "Archit Mehta",
            "Marcus Kim",
            "Thomas Vignos",
            "Aayush Agnihotri",
            "Daniel Weiner",
            "Skye Slattery",
            "Cassidy Xu"
        ]),
        Section(title: "Marketers", members: [
            "Cat Zhang",
            "Faith Earley",
            "Lucy Zhang",
            "Neha Malepati",
            "Vivian Park",
            "Carnell Zhou",
            "Jane Lee",
            "Matthew Wong",
            "Candy Wu",
            "Anvi Savant"
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
