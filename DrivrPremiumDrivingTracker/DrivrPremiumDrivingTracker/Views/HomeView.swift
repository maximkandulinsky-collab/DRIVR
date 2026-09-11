import SwiftUI

public struct HomeView: View {
    @ObservedObject var viewModel: VehicleSetupViewModel
    
    public init(viewModel: VehicleSetupViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("DRIVR")
                    .font(.largeTitle.bold())
                    .foregroundColor(DrivrTheme.primaryText)
                
                Button(action: {}) {
                    Text("Start Drive")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding()
        }
        .drivrBackground()
    }
}