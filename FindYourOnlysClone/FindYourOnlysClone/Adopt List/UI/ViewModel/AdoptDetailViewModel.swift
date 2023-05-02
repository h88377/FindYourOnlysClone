//
//  AdoptDetailViewModel.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/5/2.
//

import Foundation

final class AdoptDetailViewModel<Image> {
    private let pet: Pet
    private let image: Image?
    
    init(pet: Pet, image: Image?) {
        self.pet = pet
        self.image = image
    }
    
    var petImage: Image? {
        return image
    }
    
    var statusText: String {
        switch pet.status {
        case PetStatusType.open.rawValue:
            return "開放認養"
            
        case PetStatusType.close.rawValue:
            return "不開放認養"
            
        default:
            return "無"
        }
    }
    
    var kindText: String {
        return pet.kind
    }
    
    var genderText: String {
        switch pet.gender {
        case PetGenderType.male.rawValue:
            return "♂"
            
        case PetGenderType.female.rawValue:
            return "♀"
            
        default:
            return "無"
        }
    }
    
    var varietyText: String {
        return pet.variety
    }
    
    var idText: String {
        return String(pet.id)
    }
    
    var ageText: String {
        switch pet.age {
        case PetAgeType.adult.rawValue:
            return "成年"
            
        case PetAgeType.child.rawValue:
            return "幼年"
            
        default:
            return "無"
        }
    }
    
    var colorText: String {
        return pet.color
    }
    
    var bodyTypeText: String {
        switch pet.bodyType {
        case PetBodyType.small.rawValue:
            return "小型"
            
        case PetBodyType.medium.rawValue:
            return "中型"
            
        case PetBodyType.big.rawValue:
            return "大型"
            
        default:
            return "無"
        }
    }
    
    var foundPlaceText: String {
        return pet.foundPlace
    }
    
    var sterilizationText: String {
        switch pet.sterilization {
        case PetBoolStatus.beTrue.rawValue:
            return "是"
            
        case PetBoolStatus.beFalse.rawValue:
            return "否"
            
        default:
            return "無"
        }
    }
    
    var bacterinText: String {
        switch pet.bacterin {
        case PetBoolStatus.beTrue.rawValue:
            return "是"
            
        case PetBoolStatus.beFalse.rawValue:
            return "否"
            
        default:
            return "無"
        }
    }
    
    var openForAdoptionDateText: String {
        return pet.openDate == "" ? "無" : pet.openDate
    }
    
    var closeForAdoptionDateText: String {
        return pet.closedDate == "" ? "無" : pet.closedDate
    }
    
    var updatedDateText: String {
        return pet.updatedDate == "" ? "無" : pet.updatedDate
    }
    
    var createdDateText: String {
        return pet.createdDate == "" ? "無" : pet.createdDate
    }
    
    var shelterNameText: String {
        return pet.shelterName
    }
    
    var addressText: String {
        return pet.address
    }
    
    var telephoneText: String {
        return pet.telephone
    }
    
    var remarkText: String {
        return pet.remark == "" ? "無" : pet.remark
    }
}

extension AdoptDetailViewModel {
    enum PetStatusType: String {
        case open = "OPEN"
        case close = "CLOSE"
    }
    
    enum PetGenderType: String {
        case male = "M"
        case female = "F"
    }
    
    enum PetBodyType: String {
        case small = "SMALL"
        case medium = "MEDIUM"
        case big = "BIG"
    }
    
    enum PetAgeType: String {
        case adult = "ADULT"
        case child = "CHILD"
    }
    
    enum PetBoolStatus: String {
        case beTrue = "T"
        case beFalse = "F"
    }
}
