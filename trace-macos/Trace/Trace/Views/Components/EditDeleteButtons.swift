import SwiftUI

struct EditDeleteButtons: View {
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    @State private var editHovered = false
    @State private var deleteHovered = false
    
    var body: some View {
        HStack(spacing: 4) {
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(AppTheme.primaryText)
                    .frame(width: 22, height: 22)
                    .background(AppTheme.cardBackground)
                    .clipShape(Circle())
                    .fineLineBorder(cornerRadius: 11)
                    .scaleEffect(editHovered ? 1.1 : 1.0)
                    .animation(.easeOut(duration: 0.15), value: editHovered)
            }
            .buttonStyle(.plain)
            .onHover { editHovered = $0 }
            .help("Edit")
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(AppTheme.destructive)
                    .frame(width: 22, height: 22)
                    .background(AppTheme.cardBackground)
                    .clipShape(Circle())
                    .fineLineBorder(cornerRadius: 11)
                    .scaleEffect(deleteHovered ? 1.1 : 1.0)
                    .animation(.easeOut(duration: 0.15), value: deleteHovered)
            }
            .buttonStyle(.plain)
            .onHover { deleteHovered = $0 }
            .help("Delete")
        }
    }
}
