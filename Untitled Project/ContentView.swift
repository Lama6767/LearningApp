import SwiftUI
import Playgrounds

struct PresentMeView: View {
    var body: some View {
        
        
        
            VStack{
                
                Image(.D_1)
                    //.resizable()
                    .frame(width:120, height: 120)
                
                Text("Lama, \(26)")
                    .font(.title)
                    .fontWeight(.semibold)
                
                
                
                Section{
                    Text("I'm a 26 years old with a passion of  ")
                }
                
                
            }
            
        }
    }



#Preview {
    PresentMeView()
    
    
}

