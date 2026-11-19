import SwiftUI

import Playgrounds

struct ContentView: View {
    @State private var name:String = "Lama"
    
    @State private var age:Int = 26
    @State private var bioText:String = "a 26 year old tech enthusiast with a strong urge to learn everything about tech and the world around"
    
    @State private var isEditingBio: Bool = false
    var body: some View {
        NavigationStack{
        List{
            Section{
            
            VStack(spacing ){ Image(.D_1)
                    .resizable()
                    .frame(width: 120, height: 120)
                
                
                Text("Haneen, \(24)")
                Text("About")
                Text("A passionate Graphic and UI/UX Designer dedicated to crafting intuitive digital experiences, currently refining her technical and design craft as an Apple Developer Academy trainee.")
                
                
                
            }
        }
    }
}
#Preview {
    ContentView()
}
