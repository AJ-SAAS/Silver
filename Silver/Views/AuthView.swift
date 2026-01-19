import SwiftUI

struct AuthView: View {
    
    @EnvironmentObject private var viewModel: AuthViewModel
    
    @State private var email = ""
    @State private var password = ""
    @State private var isSignInMode = true
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Branding
                VStack(spacing: 12) {
                    Image(systemName: "cube.box.2.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 88, height: 88)
                        .foregroundStyle(.blue.gradient)
                    
                    Text("Silver")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    
                    Text("Track • Stack • Stay Ahead")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // Form
                VStack(spacing: 20) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(.rect(cornerRadius: 14))
                    
                    SecureField(isSignInMode ? "Password" : "Create password", text: $password)
                        .textContentType(isSignInMode ? .password : .newPassword)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(.rect(cornerRadius: 14))
                    
                    Button {
                        Task {
                            if isSignInMode {
                                await viewModel.signIn(email: email, password: password)
                            } else {
                                await viewModel.signUp(email: email, password: password)
                            }
                        }
                    } label: {
                        ZStack {
                            if viewModel.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text(isSignInMode ? "Sign In" : "Create Account")
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(.rect(cornerRadius: 14))
                    }
                    .disabled(viewModel.isLoading || email.isEmpty || password.count < 6)
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding(.horizontal, 28)
                
                Spacer()
                
                // Toggle
                Button {
                    withAnimation(.easeInOut) {
                        isSignInMode.toggle()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(isSignInMode ? "Need an account?" : "Already have an account?")
                            .foregroundStyle(.secondary)
                        Text(isSignInMode ? "Sign up" : "Sign in")
                            .fontWeight(.semibold)
                            .foregroundStyle(.blue)
                    }
                    .font(.subheadline)
                }
            }
            .padding(.top, 60)
            .padding(.bottom, 50)
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
}
