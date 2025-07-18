import SwiftUI
import GoogleSignIn
import AuthenticationServices

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
                
                // Social Login Buttons
                VStack(spacing: 12) {
                    // Sign in with Apple
                    SignInWithAppleButton(
                        .signIn,
                        onRequest: { request in
                            authService.handleSignInWithAppleRequest(request)
                        },
                        onCompletion: { result in
                            Task {
                                await authService.handleSignInWithAppleCompletion(result)
                            }
                        }
                    )
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 55)
                    .cornerRadius(12)
                    
                    // Sign in with Google
                    Button(action: signInWithGoogle) {
                        HStack(spacing: 8) {
                            Image("google-logo") // You'll need to add this asset
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            
                            Text("Continue with Google")
                                .font(.headline)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(Color(.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray3), lineWidth: 1)
                        )
                        .cornerRadius(12)
                    }
                    
                    // Divider
                    HStack(spacing: 16) {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(height: 1)
                        
                        Text("OR")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(height: 1)
                    }
                    .padding(.vertical, 8)
                }
                
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
    
    private func signInWithGoogle() {
        guard let presentingViewController = getRootViewController() else {
            authService.errorMessage = "Unable to get presenting view controller"
            return
        }
        
        Task {
            await authService.signInWithGoogle(presenting: presentingViewController)
        }
    }
    
    private func getRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return nil
        }
        
        return window.rootViewController
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

// MARK: - Google Sign In Button (Alternative if no image asset)
struct GoogleSignInButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                // Google "G" logo using SF Symbols approximation
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                    
                    Text("G")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                }
                
                Text("Continue with Google")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .background(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray3), lineWidth: 1)
            )
            .cornerRadius(12)
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(FirebaseAuthService())
}
