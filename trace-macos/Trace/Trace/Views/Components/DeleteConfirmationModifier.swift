import SwiftUI

struct DeleteConfirmationModifier<Item: Identifiable>: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var selectedItem: Item?
    var itemLabel: String = "Item"
    var displayName: (Item) -> String
    var onDelete: (Item) -> Void
    
    func body(content: Content) -> some View {
        content.confirmationDialog(
            "Delete \(itemLabel)",
            isPresented: $isPresented,
            titleVisibility: .visible,
            presenting: selectedItem
        ) { item in
            Button("Delete '\(displayName(item))'", role: .destructive) {
                onDelete(item)
                selectedItem = nil
            }
            Button("Cancel", role: .cancel) {
                selectedItem = nil
            }
        } message: { _ in
            Text("Are you sure you want to delete this \(itemLabel.lowercased())? This action cannot be undone.")
        }
    }
}

