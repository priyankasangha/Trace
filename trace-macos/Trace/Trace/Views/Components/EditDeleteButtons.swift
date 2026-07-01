import SwiftUI

struct EditDeleteButtons: View {
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(AppTheme.primaryText)
                    .frame(width: 20, height: 20)
                    .background(AppTheme.cardBackground)
                    .clipShape(Circle())
                    .fineLineBorder()
            }
            .buttonStyle(.plain)
            .help("Edit")
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.red)
                    .frame(width: 20, height: 20)
                    .background(AppTheme.cardBackground)
                    .clipShape(Circle())
                    .fineLineBorder()
            }
            .buttonStyle(.plain)
            .help("Delete")
        }
    }
}
