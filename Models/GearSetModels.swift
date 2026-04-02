import Foundation

// MARK: - Gear Set (preset of equipped items)
struct GearSet: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var equippedItems: [EquippedItem]

    init(id: UUID = UUID(), name: String = "Default", equippedItems: [EquippedItem] = []) {
        self.id = id
        self.name = name
        self.equippedItems = equippedItems
    }

    func item(in slot: EquipmentSlot) -> EquippedItem? {
        equippedItems.first { $0.slot == slot }
    }
}
