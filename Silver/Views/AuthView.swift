import SwiftUI

struct AuthView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSignUp: Bool = true   // toggle between sign up and sign in
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 40) {
                    
                    // MARK: Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(isSignUp ? "Create Account" : "Welcome Back")
                            .font(.largeTitle.weight(.bold))
                            .foregroundColor(.white)
                        Text(isSignUp ?
                             "Sign up to start tracking your silver portfolio" :
                             "Sign in to continue tracking your silver portfolio")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, 60)
                    .padding(.horizontal, 24)
                    
                    // MARK: Form Fields
                    VStack(spacing: 16) {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.none)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                        
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 24)
                    
                    // MARK: Primary Button
                    Button {
                        Task {
                            if isSignUp {
                                await authVM.signUp(email: email, password: password)
                            } else {
                                await authVM.signIn(email: email, password: password)
                            }
                        }
                    } label: {
                        Text(isSignUp ? "Sign Up" : "Sign In")
                            .font(.headline.weight(.bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                    
                    // MARK: Toggle Link
                    Button {
                        withAnimation(.easeInOut) {
                            isSignUp.toggle()
                        }
                    } label: {
                        Text(isSignUp ?
                             "Already have an account? Sign in here" :
                             "Don't have an account? Sign up here")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer(minLength: 100)
                }
            }
        }
        .background(
            LinearGradient(
                colors: [Color(red: 0.06, green: 0.09, blue: 0.17),
                         Color(red: 0.12, green: 0.16, blue: 0.23)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
}
