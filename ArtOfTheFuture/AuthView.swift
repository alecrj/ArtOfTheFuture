import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authService: FirebaseAuthService
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var isSignUp = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Logo/Header
                VStack(spacing: 16) {
                    Image(systemName: "paintbrush.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Art of the Future")
                        .font(.largeTitle.weight(.bold))
                        .multilineTextAlignment(.center)
                    
                    Text(isSignUp ? "Create your artist account" : "Welcome back, artist")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 60)
                
                // Email/Password Form
                VStack(spacing: 20) {
                    if isSignUp {
                        TextField("Full Name", text: $displayName)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(CustomTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(CustomTextFieldStyle())
                    
                    if let errorMessage = authService.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Main Action Button
                    Button(action: authenticate) {
                        HStack {
                            if authService.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            
                            Text(isSignUp ? "Create Account" : "Sign In")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(
                        authService.isLoading ||
                        email.isEmpty ||
                        password.isEmpty ||
                        (isSignUp && displayName.isEmpty)
                    )
                    .opacity(
                        email.isEmpty ||
                        password.isEmpty ||
                        (isSignUp && displayName.isEmpty) ? 0.6 : 1.0
                    )
                    
                    // Toggle Sign Up/Sign In
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isSignUp.toggle()
                        }
                        // Clear form when switching
                        email = ""
                        password = ""
                        displayName = ""
                        authService.errorMessage = nil
                    }) {
                        HStack(spacing: 4) {
                            Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                                .foregroundColor(.secondary)
                            Text(isSignUp ? "Sign In" : "Sign Up")
                                .foregroundColor(.blue)
                                .fontWeight(.medium)
                        }
                        .font(.subheadline)
                    }
                }
                
                // Coming Soon Note
                VStack(spacing: 8) {
                    Text("Social Login Coming Soon")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("🍎 Apple • 🌐 Google")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 32)
        }
        .background(
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.05),
                    Color.purple.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
    
    private func authenticate() {
        // Clear any previous errors
        authService.errorMessage = nil
        
        Task {
            if isSignUp {
                await authService.signUp(email: email, password: password, displayName: displayName)
            } else {
                await authService.signIn(email: email, password: password)
            }
        }
    }
}

// MARK: - Custom Text Field Style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .font(.body)
    }
}

#Preview {
    AuthView()
        .environmentObject(FirebaseAuthService())
}
