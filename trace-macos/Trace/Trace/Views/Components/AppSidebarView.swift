import SwiftUI
import AppKit

struct AppSidebarView: View {
    let totalTimelinesCount: Int
    let recentActivities: [ActivityLogItem]
    @Binding var showFeedbackSheet: Bool
    
    // Smooth layout interaction states
    @State private var footerHeartScale: CGFloat = 1.0
    @State private var feedbackCardHovered: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            
            // PROFILE IDENTITY CARD
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppTheme.roseGoldLight.opacity(0.4))
                        .frame(width: 68, height: 68)
                    
                    Text("PS")
                        .font(.system(size: 20, weight: .medium, design: .serif))
                        .foregroundColor(AppTheme.roseGoldDark)
                }
                .overlay(Circle().stroke(AppTheme.roseGoldBase.opacity(0.5), lineWidth: AppTheme.thinLineWidth))
                
                VStack(spacing: 3) {
                    Text("Priyanka Sangha")
                        .font(AppTheme.title)
                        .foregroundColor(AppTheme.primaryText)
                    
                    Text("Architect & Creator")
                        .font(AppTheme.appTagline)
                        .tracking(AppTheme.placardTracking)
                        .foregroundColor(AppTheme.roseGoldDark)
                }
            }
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity)
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.4))
            .cornerRadius(12)
            .fineLineBorder()
            
            // METRICS / OVERVIEW MONITOR
            VStack(alignment: .leading, spacing: 14) {
                Text("OVERVIEW")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(AppTheme.titleTracking)
                    .foregroundColor(AppTheme.roseGoldDark)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(AppTheme.roseGoldDark.opacity(0.5))
                        .frame(width: 4, height: 4)
                    Rectangle()
                        .fill(AppTheme.roseGoldLight.opacity(0.3))
                        .frame(height: AppTheme.thinLineWidth)
                    Circle()
                        .fill(AppTheme.roseGoldDark.opacity(0.5))
                        .frame(width: 4, height: 4)
                }
                .padding(.bottom, 2)
                
                Group {
                    MetricRow(label: "Total Timelines", value: "\(totalTimelinesCount)")
                    MetricRow(label: "Active Contexts", value: "1")
                    MetricRow(label: "Shared Spaces", value: "2")
                    MetricRow(label: "Pinned Milestones", value: "8")
                    MetricRow(label: "Total Contributors", value: "5")
                }
            }
            .padding(16)
            .background(AppTheme.roseGoldLight.opacity(0.08))
            .cornerRadius(12)
            
            // INTERACTIVE COLLABORATION PANEL
            Button(action: { showFeedbackSheet.toggle() }) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.roseGoldDark.opacity(0.12))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(AppTheme.roseGoldDark)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Shrey's Feedback Corner")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppTheme.primaryText)
                        
                        Text("Review critiques & system notes")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(AppTheme.primaryText.opacity(0.5))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(AppTheme.roseGoldDark.opacity(0.6))
                        .offset(x: feedbackCardHovered ? 2 : 0)
                        .animation(.easeOut(duration: 0.2), value: feedbackCardHovered)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    AppTheme.roseGoldLight.opacity(feedbackCardHovered ? 0.16 : 0.05)
                )
                .cornerRadius(12)
                .fineLineBorder(color: AppTheme.roseGoldDark.opacity(feedbackCardHovered ? 0.35 : 0.15))
                .scaleEffect(feedbackCardHovered ? 1.012 : 1.0)
                .animation(.interpolatingSpring(stiffness: 300, damping: 22), value: feedbackCardHovered)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                feedbackCardHovered = hovering
            }
            
            // LOG ENGINE PLACARD
            VStack(alignment: .leading, spacing: 12) {
                Text("RECENT ACTIVITY")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(AppTheme.titleTracking)
                    .foregroundColor(AppTheme.roseGoldDark)
                
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(recentActivities) { log in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(log.message)
                                .font(.system(size: 11))
                                .foregroundColor(AppTheme.primaryText.opacity(0.85))
                                .lineLimit(1)
                            
                            Text(log.timestamp)
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(AppTheme.roseGoldDark.opacity(0.7))
                        }
                        
                        if log.id != recentActivities.last?.id {
                            Divider()
                                .opacity(0.15)
                        }
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.2))
            .cornerRadius(12)
            .fineLineBorder()
            
            Spacer()
            
            // SIGNATURE PLACARD FOOTER
            HStack(spacing: 6) {
                Text("By Priyanka, For Shrey")
                    .font(AppTheme.dedicationPlacard)
                    .foregroundColor(AppTheme.primaryText.opacity(0.4))
                
                Image(systemName: "heart.fill")
                    .font(.system(size: 9))
                    .foregroundColor(AppTheme.roseGoldDark.opacity(0.5))
                    .scaleEffect(footerHeartScale)
            }
            .padding(.bottom, 16)
            .onHover { hovering in
                withAnimation(.interpolatingSpring(stiffness: 120, damping: 8)) {
                    footerHeartScale = hovering ? 1.3 : 1.0
                }
            }
        }
        .padding(.top, AppTheme.windowTopSafetyPadding)
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
        .background(AppTheme.primaryBackground.opacity(0.95))
        .frame(minWidth: 260, idealWidth: 280, maxWidth: 400)
    }
}

// Small layout helper wrapper to reduce structural duplication
private struct MetricRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(AppTheme.subtitle)
                .foregroundColor(AppTheme.primaryText.opacity(AppTheme.accentOpacity))
            Spacer()
            Text(value)
                .font(AppTheme.body)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.roseGoldDark)
        }
    }
}
